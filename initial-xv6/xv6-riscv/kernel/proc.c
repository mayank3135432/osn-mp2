#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "number_syscall.h"


struct cpu cpus[NCPU];

struct proc proc[NPROC];



struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

#define NUM_QUEUES 4
//#define PRIORITY_BOOST_TICKS 48
#define PRIORITY_BOOST_TICKS 48
/* struct {
  struct proc* queue[NPROC];
  int front;
  int rear;
} mlfq[NUM_QUEUES];
 */
int time_slices[NUM_QUEUES] = {1, 4, 8, 16};
int global_ticks = 0;
/* 
void print_queue(int priority) {
  printf("Queue %d: ", priority);
  int i = mlfq[priority].front;
  while (i != mlfq[priority].rear) {
    struct proc* p = mlfq[priority].queue[i];
    printf("%d ", p->pid);
    i = (i + 1) % NPROC;
  }
  printf("\n");
}
void print_all_queues() {
  for (int i = 0; i < NUM_QUEUES; i++) {
    print_queue(i);
  }
}

void enqueue(int priority, struct proc* p) {
  int rear = mlfq[priority].rear;
  mlfq[priority].queue[rear] = p;
  mlfq[priority].rear = (rear + 1) % NPROC;
  printf("Enqueued process %d to queue %d\n", p->pid, priority); // debug line
  //print_all_queues();   // debug line
}

struct proc* dequeue(int priority) {
  if (mlfq[priority].front == mlfq[priority].rear)
    return 0;
  struct proc* p = mlfq[priority].queue[mlfq[priority].front];
  mlfq[priority].front = (mlfq[priority].front + 1) % NPROC;
  return p;
}
void move_to_lower_queue(struct proc* p) {
  if (p->priority < NUM_QUEUES - 1) {
    p->priority++;
  }
  p->time_slice = time_slices[p->priority];
  p->total_ticks = 0;
  enqueue(p->priority, p);
}

void priority_boost() {
  for (int i = 1; i < NUM_QUEUES; i++) {
    while (mlfq[i].front != mlfq[i].rear) {
      struct proc* p = dequeue(i);
      p->priority = 0;
      p->time_slice = time_slices[0];
      p->total_ticks = 0;
      enqueue(0, p);
    }
  }
  global_ticks = 0;
}



  */
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
  }
    // Initialize MLFQ data structures
  /* for (int i = 0; i < NUM_QUEUES; i++) {
    mlfq[i].front = 0;
    mlfq[i].rear = 0;
  } */
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid()
{
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc* allocproc(void) {
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;
  p->tickets = 1;  // Default to 1 ticket
  p->arrival_time = ticks;  // Current system time
  p->priority = 0;  // Start in the highest priority queue
  p->time_slice = time_slices[0];
  p->total_ticks = 0;
  p->handling_alarm = 0;

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  // Add the process to the highest priority queue
  //printf("Adding process %d to queue 0\n", p->pid); // debug line
  p->priority = 0;  // Start in the highest priority
  p->time_slice = time_slices[0];
  p->total_ticks = 0;
  //print_all_queues(); // debug line

  return p;
}
// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;

  p->alarm_interval = 0;
  p->alarm_handler = 0;
  p->handling_alarm = 0;
  p->ticks_count = 0;
  
  if(p->alarm_trapframe){
    kfree((void*)p->alarm_trapframe);
  }
  p->alarm_trapframe = 0;
  p->trapframe = 0;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// assembled from ../user/initcode.S
// od -t xC ../user/initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;
  

  /* // Copy alarm-related fields
  np->alarm_interval = p->alarm_interval;
  np->alarm_handler = p->alarm_handler;
  np->ticks_count = 0;
  np->alarm_on = p->alarm_on;
  np->alarm_trapframe = 0;
   */
  
  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  np->priority = 0; // Start with the highest priority
  np->time_slice = time_slices[0];
  np->total_ticks = 0;
  release(&np->lock);


  // copy over MLFQ fields
  //printf("__________________________FORKED AND Copying over MLFQ fields__________________________\n"); -- debug line
  np->priority = 0; // minimum process priority
  np->time_slice = time_slices[0];
  np->total_ticks = 0;
  //np->arrival_time = ticks;
  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void exit(int status) {
  struct proc *p = myproc();
  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);

  acquire(&p->lock);
  p->xstate = status;
  p->state = ZOMBIE;
  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}
// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(uint64 addr) {
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();
  acquire(&wait_lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(pp = proc; pp < &proc[NPROC]; pp++){
      if(pp->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);
        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock);  // DOC: wait-sleep
  }
}
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.

void RR_scheduler(void) { // RR
printf("Robin Scheduler\n");
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;

  for(;;) {
    //sprintf("Scheduler loop start\n");

    // Enable interrupts to avoid deadlock
    intr_on();

    int found = 0;
    //print_proc_array();
    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      //printf("Checking process %d, state: %d\n", p->pid, p->state);
      if(p->state == RUNNABLE) {
        //printf("Checking process %d, state: %d\n", p->pid, p->state);
        //printf("Switching to process %d\n", p->pid);
        // Switch to chosen process
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);
        // Process is done running for now
        // It should have changed its p->state before coming back
        c->proc = 0;
        found = 1;
      }
      release(&p->lock);
    }

    if(found == 0) {
      // No runnable process found, wait for an interrupt
      //printf("No runnable process found, waiting for interrupt\n");
      intr_on();
      asm volatile("wfi");
    }
  }
}

void MLFQ_scheduler(void) {
  printf("MLFQ SCHEDULER\n");
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;

  for(;;) {
    // Enable interrupts to avoid deadlock
    //printf("Scheduler loop start\n"); // debug line
    intr_on();

    struct proc *highest_priority_proc = 0;
    int highest_priority = -1;

    for (p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if (p->state == RUNNABLE && p->priority > highest_priority) {
        highest_priority = p->priority;
        highest_priority_proc = p;
      }
      release(&p->lock);
    }

    if (highest_priority_proc) {
      p = highest_priority_proc;
      acquire(&p->lock);
      p->state = RUNNING;
      c->proc = p;
      swtch(&c->context, &p->context);
      c->proc = 0;

      if (p->state == RUNNABLE) {
        if (p->total_ticks >= p->time_slice) {
          if (p->priority < NUM_QUEUES - 1) {
            printf("Process %d moving to lower queue\n", p->pid);
            p->priority++;
          }
          p->time_slice = time_slices[p->priority];
          p->total_ticks = 0;
        }
      }
      release(&p->lock);
    } else {
      //printf("No runnable process found, waiting for interrupt\n"); // debug line
      intr_on();
      asm volatile("wfi");
    }
  }
}

void scheduler(void) {
    #ifdef MLFQ
      printf("MLFQ SCHEDULER\n");
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;

  for(;;) {
    // Enable interrupts to avoid deadlock
    //printf("Scheduler loop start\n"); // debug line
    intr_on();

    struct proc *highest_priority_proc = 0;
    int highest_priority = -1;

    for (p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if (p->state == RUNNABLE && p->priority > highest_priority) {
        highest_priority = p->priority;
        highest_priority_proc = p;
      }
      release(&p->lock);
    }

    if (highest_priority_proc) {
      p = highest_priority_proc;
      acquire(&p->lock);
      p->state = RUNNING;
      c->proc = p;
      swtch(&c->context, &p->context);
      c->proc = 0;

      if (p->state == RUNNABLE) {
        if (p->total_ticks >= p->time_slice) {
          if (p->priority < NUM_QUEUES - 1) {
            p->priority++;
          }
          p->time_slice = time_slices[p->priority];
          p->total_ticks = 0;
        }
      }
      release(&p->lock);
    } else {
      //printf("No runnable process found, waiting for interrupt\n"); // debug line
      intr_on();
      asm volatile("wfi");
    }
  }
    #else
      printf("Robin Scheduler\n");
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;

  for(;;) {
    //sprintf("Scheduler loop start\n");

    // Enable interrupts to avoid deadlock
    intr_on();

    int found = 0;
    //print_proc_array();
    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      //printf("Checking process %d, state: %d\n", p->pid, p->state);
      if(p->state == RUNNABLE) {
        //printf("Checking process %d, state: %d\n", p->pid, p->state);
        //printf("Switching to process %d\n", p->pid);
        // Switch to chosen process
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);
        // Process is done running for now
        // It should have changed its p->state before coming back
        c->proc = 0;
        found = 1;
      }
      release(&p->lock);
    }

    if(found == 0) {
      // No runnable process found, wait for an interrupt
      //printf("No runnable process found, waiting for interrupt\n");
      intr_on();
      asm volatile("wfi");
    }
  }
    #endif
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  //printf("!_____________!sched run!_____________!\n"); // debug line
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  if(p->state == SLEEPING || p->state == RUNNABLE) {
    p->time_slice = time_slices[p->priority];
  }

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
  //printf("!_____________!sched QUIT!_____________!");
}

// Give up the CPU for one scheduling round.
void yield(void) {
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  if (p->time_slice > 0) {
    // Process is yielding voluntarily (e.g., for I/O)
    // No need to change priority, just reset the time slice
    p->time_slice = time_slices[p->priority];
  } else {
    // Process used its entire time slice, move to lower priority
    if (p->priority < NUM_QUEUES - 1) {
      p->priority++;
    }
    p->time_slice = time_slices[p->priority];
    p->total_ticks = 0;
  }
  sched();
  release(&p->lock);
}
// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);

    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void
setkilled(struct proc *p)
{
  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

int
killed(struct proc *p)
{
  int k;
  
  acquire(&p->lock);
  k = p->killed;
  release(&p->lock);
  return k;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
  static char *states[] = {
    [UNUSED]    "unused",
    [USED]      "used",
    [SLEEPING]  "sleep ",
    [RUNNABLE]  "runble",
    [RUNNING]   "run   ",
    [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++) {
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    
    #ifdef MLFQ
      printf("%d %s %s Priority: %d Time Slice: %d\n", p->pid, state, p->name, p->priority, p->time_slice);
    #else
      printf("%d %s %s\n", p->pid, state, p->name);
    #endif
  }
}int
sigalarm(int ticks, void (*handler)()){
  struct proc *p = myproc();
  //acquire(&p->lock);  // Acquire the process lock
  p->alarm_interval = ticks;
  p->alarm_handler = (void (*)())handler;
  p->ticks_count = ticks; // not zero
  p->alarm_on = (ticks > 0) ? 1 : 0;  // Only enable if ticks > 0
  p->handling_alarm = 0;  // Add this field to struct proc
  //release(&p->lock);  // Release the process lock
  if (p->alarm_trapframe == 0) p->alarm_trapframe = kalloc();
  return 0;
}

/* int
sigreturn(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);  // Acquire the process lock
  if(p->alarm_trapframe && p->handling_alarm) {
    memmove(p->trapframe, p->alarm_trapframe, sizeof(struct trapframe));
    kfree(p->alarm_trapframe);
    p->alarm_trapframe = 0;
    p->handling_alarm = 0;
    p->ticks_count = 0;  // Reset tick count
  }
  release(&p->lock);  // Release the process lock
  return 0;
} */
int
sigreturn(void)
{
  struct proc *process = myproc();

  if (process->alarm_trapframe == 0)
    return -1;

  // Restore the saved trapframe
  memmove(process->trapframe, process->alarm_trapframe, PGSIZE);
  process->handling_alarm = 0;
  process->alarm_on = 0;

  return 0;
}