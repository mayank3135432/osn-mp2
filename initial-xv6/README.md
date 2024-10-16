# xv6  
A global variable array indexed by syscall numbers is declared in to store number of calls to syscall  
getSyscount returns the value present at index i of the array.  
The array is 1-indexed and the 0th element is not used ever.  
Modified files: kernel/sysproc.c kernel/syscall.h  
  
2. Wake me up when my timer ends  
printhell is the user program to test sigalarm.  
there is a bug in sigalarm/sigreturn that causes error in acquiring lock for the next process to be run. (near line 64 of bio.c)  

3. mlf who ? mlfq !  
to run with mlfq, type make clean ; make qemu SCHEDULER=MLFQ CPUS=1  
because mlfq only supports single core  
I did not allocate queue data structure to implement mlfq's, instead I had priority be a field within struct proc.  
Unfortunately I could not get lbs to run without bugs and removed it from my final submission.  

