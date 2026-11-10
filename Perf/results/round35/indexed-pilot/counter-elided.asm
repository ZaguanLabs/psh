
/home/stig/dev/challenge/zsh-perf/zsh-5.9.2/.work/round35/pilot-zsh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000442f80 <psh_scope_setlevel>:
  442f80:	49 89 fa             	mov    %rdi,%r10
  442f83:	41 89 f1             	mov    %esi,%r9d
  442f86:	85 f6                	test   %esi,%esi
  442f88:	7e 0f                	jle    442f99 <psh_scope_setlevel+0x19>
  442f8a:	8b 05 9c 09 09 00    	mov    0x9099c(%rip),%eax        # 4d392c <scope_valid>
  442f90:	85 c0                	test   %eax,%eax
  442f92:	74 05                	je     442f99 <psh_scope_setlevel+0x19>
  442f94:	e8 17 f6 ff ff       	call   4425b0 <scope_mark_parameter.part.0>
  442f99:	45 89 4a 48          	mov    %r9d,0x48(%r10)
  442f9d:	c3                   	ret

Disassembly of section .fini:
