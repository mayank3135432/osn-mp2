#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void run_for_time(int time) {
  int start = uptime();
  while (uptime() - start < time) {
    // Busy wait to simulate CPU-bound process
  }
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Usage: %s <num_processes>\n", argv[0]);
    exit(1);
  }

  int num_processes = atoi(argv[1]);
  int times[] = {10, 20, 30, 40, 50}; // Varying lengths of time

  for (int i = 0; i < num_processes; i++) {
    int pid = fork();
    if (pid < 0) {
      printf("fork failed\n");
      exit(1);
    }
    if (pid == 0) {
      // Child process
      run_for_time(times[i % 5]);
      printf("Process %d finished\n", getpid());
      exit(0);
    }
  }

  for (int i = 0; i < num_processes; i++) {
    wait(0);
  }

  printf("MLFQ test completed\n");
  exit(0);
}