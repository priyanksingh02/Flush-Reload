all: calibration
calibration: calibration.c cacheutils.h
	gcc -std=gnu11 -O2 -o $@ $@.c

clean:
	rm -f calibration
