#define NUMBER_OF_SYSCALLS 22

#ifndef SYSCALL_COUNTS
#define SYSCALL_COUNTS
extern uint64 syscall_counts[NUMBER_OF_SYSCALLS+1];
#endif