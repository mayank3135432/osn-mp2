#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int i;
  //int numcount=0;
  for(i = 1; i < argc; i++){
    //printf("loop %d\n", i);
    write(1, argv[i], strlen(argv[i]));
    //printf("write %d\n", ++numcount);
    if(i + 1 < argc){
      write(1, " ", 1);
      //printf("write %d\n", ++numcount);
    } else {
      write(1, "\n", 1);
      //printf("write %d\n", ++numcount);
    }
  }
  exit(0);
}
