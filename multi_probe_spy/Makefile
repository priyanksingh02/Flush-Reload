threshold := `[ -f ../threshold.txt ] && cat ../threshold.txt || echo 120`

all: spy

spy: spy.c
	gcc -std=gnu11 -O2 -o $@ $@.c -DTHRESHOLD=$(threshold)

clean:
	rm -f spy
