#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  /* struct proc* p = myproc();
  p->alarm_interval = 0;
  p->alarm_handler = 0;
  p->ticks_count = 0;
  if(p->alarm_trapframe ) {
    kfree(p->alarm_trapframe);
    p->alarm_trapframe = 0;
  } */
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_getSyscount(void)
{
  int mask;
  argint(0, &mask);
  if(mask < 0)
    return -1;
  
  // Find the syscall number from the mask
  int syscall_num = -1;
  for(int i = 0; i < 32; i++) {
    if(mask == (1 << i)) {
      syscall_num = i;
      break;
    }
  }
  
  if(syscall_num == -1)
    return -1;
  //struct proc *p = myproc();

  int RETVALL = syscall_counts[syscall_num];

  // reset count
  for(int i=0; i<=NUMBER_OF_SYSCALLS; i++){
    syscall_counts[i] = 0;
  }
  return RETVALL;
}

uint64
sys_sigalarm(void)
{
  int interval;
  uint64 handler;
  argint(0, &interval);
  argaddr(1, &handler);
  return sigalarm(interval, (void(*)())handler);
}

uint64
sys_sigreturn(void)
{
  return sigreturn();
}
uint64
sys_settickets(void)
{
  int number;
  argint(0, &number);
  if(number <= 0)
    return -1;
  myproc()->tickets = number;
  return number;
}
