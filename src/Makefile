
.PHONY: all
all: set-cpu hibernate

set-cpu: set-cpu.cc
	g++ -std=c++17 -O2 -o set-cpu set-cpu.cc

hibernate: hibernate.c
	gcc -std=c99 -O2 -o hibernate hibernate.c
