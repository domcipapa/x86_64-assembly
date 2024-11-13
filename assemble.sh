#!/usr/bin/env bash
nasm -felf64 average.asm
gcc -o average -z noexecstack -no-pie average.o
./average
