# xv6
A global variable array indexed by syscall numbers is declared in to store number of calls to syscall  
getSyscount returns the value present at index i of the array.
The array is 1-indexed and the 0th element is not used ever.
Modified files: kernel/sysproc.c kernel/syscall.h  
