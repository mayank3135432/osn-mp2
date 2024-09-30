#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/number_syscall.h"


void printsyscall(int sid){
  switch(sid) {
    case 1<<1:
      printf("fork");
      break;
    case 1<<2:
      printf("exit");
      break;
    case 1<<3:
      printf("wait");
      break;
    case 1<<4:
      printf("pipe");
      break;
    case 1<<5:
      printf("read");
      break;
    case 1<<6:
      printf("kill");
      break;
    case 1<<7:
      printf("exec");
      break;
    case 1<<8:
      printf("fstat");
      break;
    case 1<<9:
      printf("chdir");
      break;
    case 1<<10:
      printf("dup");
      break;
    case 1<<11:
      printf("getpid");
      break;
    case 1<<12:
      printf("sbrk");
      break;
    case 1<<13:
      printf("sleep");
      break;
    case 1<<14:
      printf("uptime");
      break;
    case 1<<15:
      printf("open");
      break;
    case 1<<16:
      printf("write");
      break;
    case 1<<17:
      printf("mknod");
      break;
    case 1<<18:
      printf("unlink");
      break;
    case 1<<19:
      printf("link");
      break;
    case 1<<20:
      printf("mkdir");
      break;
    case 1<<21:
      printf("close");
      break;
    case 1<<22:
      printf("getSyscount");
    default:
      printf("Invalid system call");
      break;
  }
}

int
main(int argc, char *argv[])
{
  if(argc < 3){
    fprintf(2, "Usage: syscount <mask> command [args]\n");
    exit(1);
  }

  int mask = atoi(argv[1]);
  getsyscount(mask);
  int pid = fork();
  if(pid < 0){
    fprintf(2, "fork failed\n");
    exit(1);
  }
  
  if(pid == 0){
    // Child process
    exec(argv[2], &argv[2]);
    fprintf(2, "exec %s failed\n", argv[2]);
    exit(1);
  } else {
    // Parent process
    int status;
    wait(&status);
    int count = getsyscount(mask);
    
    printf("PID %d called ", pid);
    //printf("%d",mask);
    printsyscall(mask);
    printf(" %d times\n", count);
    exit(0);
  }
}