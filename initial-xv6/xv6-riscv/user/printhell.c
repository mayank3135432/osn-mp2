#include "kernel/types.h"
#include "user/user.h"

void handler() {
  printf("_________________________Alarm!_________________________\n");
  sigreturn();
}

int main(int argc, char *argv[]) {
  sigalarm(3, handler);
  uint64 i = 0;
  while(i<1000000000){
    //printf("\n_____!!!!+_____+!!!!_____i: %ld_____!!!!+_____+!!!!_____\n", i);
    i++;
    
  }
  
  sigalarm(0, 0);  // Disable alarm
  printf("Test complete, i=%ld\n",i);
  exit(0);
}