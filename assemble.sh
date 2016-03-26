#!/bin/bash
if [ -z $1 ];
then
    echo "specify an argument to compile"
    exit 1
fi
as -g -as $1.s -o $1.o && ld $1.o -o $1 && chmod +x $1
#nasm -f elf64 -g $1.asm -o $1.o && ld $1.o -o $1 && chmod +x $1
