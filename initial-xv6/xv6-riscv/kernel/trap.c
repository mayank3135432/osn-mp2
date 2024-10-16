#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct spinlock tickslock;
uint ticks;

extern char trampoline[], uservec[], userret[];

// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void
trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

//
// handle an interrupt, exception, or system call from user space.
// called from trampoline.S
//

void OLDusertrap(void)
{
  int which_dev = 0;

  if ((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  w_stvec((uint64)kernelvec);

  struct proc *p = myproc();

  // save user program counter.
  p->trapframe->epc = r_sepc();

  if (r_scause() == 8)
  {
    // system call
    if (killed(p))
      exit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    intr_on();

    syscall();
  }
  else if ((which_dev = devintr()) != 0)
  {
    // ok
  }
  else
  {
    printf("usertrap(): unexpected scause %lx pid=%d\n", r_scause(), p->pid);
    printf("            sepc=%lx stval=%lx\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if (p->alarm_interval > 0 && !p->alarm_handler)
  {
    p->ticks_count++;
    if (p->ticks_count >= p->alarm_interval)
    {
      p->ticks_count = 0;
      //p->alarm_handler = 1;

      // Save the current trapframe
      memmove(p->alarm_trapframe, p->trapframe, sizeof(struct trapframe));

      // Set the trapframe to call the handler
      p->trapframe->epc = (uint64)p->alarm_handler;
    }
  }

  if (killed(p))
    exit(-1);

  if (which_dev == 2)
    yield();

  usertrapret();
}


void
BADOLDIE_usertrap(void)
{
  int which_dev = 0;

  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);

  struct proc *p = myproc();
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
  //printf("scause is %ld\n", r_scause());
  
  if(r_scause() == 8){
    // system call

    if(killed(p))
      exit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    // an interrupt will change sepc, scause, and sstatus,
    // so enable only now that we're done with those registers.
    intr_on();

    syscall();
  } else if((which_dev = devintr()) != 0){
    // ok
  } else {
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if(killed(p))
    exit(-1);

 
  /* if(which_dev == 2) {
    // timer interrupt
    if(p->alarm_interval > 0 && p->state == RUNNING) {
      p->ticks_count++;
      if(p->ticks_count >= p->alarm_interval && p->alarm_handler != 0) {
        p->ticks_count = 0;
        if(p->alarm_trapframe == 0) {
          p->alarm_trapframe = kalloc();
          if(p->alarm_trapframe == 0) {
            printf("usertrap: out of memory\n");
            p->killed = 1;
          } else {
            memmove(p->alarm_trapframe, p->trapframe, sizeof(struct trapframe));
            p->trapframe->epc = (uint64)p->alarm_handler;
          }
        }
      }
    }
  } */
 if(which_dev == 2) {
    // timer interrupt
    if(p->alarm_on && p->alarm_interval > 0) {
      p->ticks_count++;
      printf("Process %d: ticks_count = %d, alarm_interval = %d\n", 
             p->pid, p->ticks_count, p->alarm_interval);
      if(p->ticks_count >= p->alarm_interval) {
        printf("Process %d: Alarm triggered\n", p->pid);
        if(p->alarm_trapframe == 0) {
          p->alarm_trapframe = kalloc();
          if(p->alarm_trapframe == 0) {
            printf("usertrap: out of memory\n");
            p->killed = 1;
          } else {
            memmove(p->alarm_trapframe, p->trapframe, sizeof(struct trapframe));
            p->trapframe->epc = (uint64)p->alarm_handler;
            p->ticks_count = 0;
            printf("Process %d: Calling alarm handler at %p\n", p->pid, (void*)p->alarm_handler);
          }
        }
      }
    }
  }

  usertrapret();
}


void
usertrap(void)
{
  int which_dev = 0;
  //printf("dev is %d\n", devintr());
  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);

  struct proc *p = myproc();
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
  //printf("scause is %ld\n", r_scause());
  
  if(r_scause() == 8){
    // system call

    if(killed(p))
      exit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    // an interrupt will change sepc, scause, and sstatus,
    // so enable only now that we're done with those registers.
    intr_on();

    syscall();
  } else if((which_dev = devintr()) != 0){
    // ok
  } else {
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if(killed(p))
    exit(-1);

 
  /* if(which_dev == 2) {
    // timer interrupt
    if(p->alarm_on && p->alarm_interval > 0 && !p->handling_alarm) {
      p->ticks_count++;
      if(p->ticks_count >= p->alarm_interval) {
        p->handling_alarm = 1;  // Set handling_alarm flag
        if(p->alarm_trapframe == 0) {
          p->alarm_trapframe = kalloc();
          if(p->alarm_trapframe == 0) {
            panic("usertrap: out of memory");
          }
        }
        memmove(p->alarm_trapframe, p->trapframe, sizeof(struct trapframe));
        p->trapframe->epc = (uint64)p->alarm_handler;
      }
    }
    yield();
  } */
 if(p != 0 && p->state == RUNNING && p->alarm_on && p->alarm_interval > 0) {
      p->ticks_count++;
      printf("Process %d: ticks_count = %d, alarm_interval = %d\n", 
             p->pid, p->ticks_count, p->alarm_interval);
      if(p->ticks_count >= p->alarm_interval) {
        printf("Process %d: Alarm triggered\n", p->pid);
        if(p->alarm_trapframe == 0) {
          p->alarm_trapframe = kalloc();
          if(p->alarm_trapframe == 0) {
            printf("usertrap: out of memory\n");
            p->killed = 1;
          } else {
            memmove(p->alarm_trapframe, p->trapframe, sizeof(struct trapframe));
            p->trapframe->epc = (uint64)p->alarm_handler;
            p->ticks_count = 0;
            printf("Process %d: Calling alarm handler at %p\n", p->pid, (void*)p->alarm_handler);
          }
        }
      }
  }
 if(which_dev == 2) {
    // timer interrupt
    
    yield();
  }

  usertrapret();
}

//
// return to user space
//
void
usertrapret(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64))trampoline_userret)(satp);
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void 
kerneltrap()
{
  int which_dev = 0;
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();
  
  if((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if(intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  if((which_dev = devintr()) == 0){
    // interrupt or trap from an unknown source
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    panic("kerneltrap");
  }

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2 && myproc() != 0)
    yield();

  // the yield() may have caused some traps to occur,
  // so restore trap registers for use by kernelvec.S's sepc instruction.
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void
clockintr()
{
  if(cpuid() == 0){
    acquire(&tickslock);
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
}

// check if it's an external interrupt or software interrupt,
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){ // -9223372036854775803
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();

    if(irq == UART0_IRQ){
      uartintr();
    } else if(irq == VIRTIO0_IRQ){
      virtio_disk_intr();
    } else if(irq){
      printf("unexpected interrupt irq=%d\n", irq);
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
  }
}

