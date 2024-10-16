// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.


#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"

struct {
  struct spinlock lock;
  struct buf buf[NBUF];

  // Linked list of all buffers, through prev/next.
  // Sorted by how recently the buffer was used.
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void
binit(void)
{
  struct buf *b;

  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  //printf("bget: acquiring bcache.lock\n"); // debug line
  acquire(&bcache.lock); // problem is here for sigreturn/sigalarm
  //printf("bget: bcache.lock acquired\n"); // debug line
  // Is the block already cached?
  //printf("bget: checking if block is already cached\n"); // debug line
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    // printf("bget: inspecting buffer with dev=%u, blockno=%u\n", b->dev, b->blockno); // debug line
    if(b->dev == dev && b->blockno == blockno){
      // printf("bget: found cached buffer, incrementing refcnt\n"); // debug line
      b->refcnt++;
      // printf("bget: releasing bcache.lock\n"); // debug line
      release(&bcache.lock);
      // printf("bget: acquiring b->lock\n"); // debug line
      acquiresleep(&b->lock);
      // printf("bget: returning cached buffer\n"); // debug line
      return b;
    }
  }

  // Not cached.
  // Recycle the least recently used (LRU) unused buffer.
  // printf("bget: block not cached, looking for LRU buffer\n"); // debug line
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    // printf("bget: inspecting LRU buffer with refcnt=%d\n", b->refcnt); // debug line
    if(b->refcnt == 0) {
      // printf("bget: found LRU buffer, recycling it\n"); // debug line
      b->dev = dev;
      b->blockno = blockno;
      b->valid = 0;
      b->refcnt = 1;
      // printf("bget: releasing bcache.lock\n"); // debug line
      release(&bcache.lock);
      // printf("bget: acquiring b->lock\n"); // debug line
      acquiresleep(&b->lock);
      // printf("bget: returning new buffer\n"); // debug line
      return b;
    }
  }
  // printf("bget: no buffers available, panicking\n"); // debug line
  panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;
  // printf("bread before bget\n"); // debug line
  b = bget(dev, blockno); // problem is here in bget for sigreturn/sigalarm
  // printf("bread after bget\n"); // debug line
  if(!b->valid) {
    // printf("bread before virtio_disk_rw\n"); // debug line
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  // printf("bread before return b\n"); // debug line
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  virtio_disk_rw(b, 1);
}

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");

  releasesleep(&b->lock);

  acquire(&bcache.lock);
  b->refcnt--;
  if (b->refcnt == 0) {
    // no one is waiting for it.
    b->next->prev = b->prev;
    b->prev->next = b->next;
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
  
  release(&bcache.lock);
}

void
bpin(struct buf *b) {
  acquire(&bcache.lock);
  b->refcnt++;
  release(&bcache.lock);
}

void
bunpin(struct buf *b) {
  acquire(&bcache.lock);
  b->refcnt--;
  release(&bcache.lock);
}
