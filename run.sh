riscv64-linux-gnu-as -o prime.o prime.s
riscv64-linux-gnu-gcc -o prime prime.o
export QEMU_LD_PREFIX=/usr/riscv64-linux-gnu/
qemu-riscv64-static prime