# start sequence of the bootloader
#
#
#include <smp.h>
#define DRAM_BASE 0x80000000

  .section .text.init
  .option norvc
  .globl _prog_start
_prog_start:
  smp_pause(s1, s2)
  li sp, 0x9ff00000
  call main
  smp_resume(s1, s2)
//  li t0,3
//  li t0,4
//  add a1,t0,t1
//  li a5, DRAM_BASE
//  sw a1,4(a5)
//  lw t0,4(a5)
//  addi a0,a0,5
//  sw a0,8(a5)
  csrr a0, mhartid
  la a1, _dtb
  li s1, DRAM_BASE
  jr s1

  .section .dtb
  .globl _dtb
  .align 4, 0
_dtb:
  .incbin "ariane.dtb"
