#include "kernel/types.h"
#include "user/user.h"
int jk=0;
void
alarm_handler()
{
  printf("_____________!Alarm!_______________\n");
  for(int i=0;i<jk;i++){
    printf("%d\n",i);
  }
  jk++;
  sigreturn();
}

int
main(int argc, char *argv[])
{
  sigalarm(1, &alarm_handler);  // Set alarm for every 3 ticks
  while(1){
    printf("%d\n",getpid());
  }
  sigalarm(0, 0);  // Turn off the alarm
  exit(0);
}