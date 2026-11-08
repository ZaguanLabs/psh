
.work/round25/candidate/Src/zsh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004a3da0 <itype_end>:
  4a3da0:	push   %r12
  4a3da2:	mov    %edx,%r12d
  4a3da5:	push   %rbp
  4a3da6:	push   %rbx
  4a3da7:	mov    %rdi,%rbx
  4a3daa:	sub    $0x20,%rsp
  4a3dae:	cmpb   $0x0,0x33ae4(%rip)        # 4d7899 <opts+0x79>
  4a3db5:	je     4a3ea0 <itype_end+0x100>
  4a3dbb:	cmp    $0x80,%esi
  4a3dc1:	jne    4a3dd0 <itype_end+0x30>
  4a3dc3:	cmpb   $0x0,0x33adf(%rip)        # 4d78a9 <opts+0x89>
  4a3dca:	jne    4a3ea0 <itype_end+0x100>
  4a3dd0:	movq   $0x0,0x3decd(%rip)        # 4e1ca8 <mb_shiftstate>
  4a3ddb:	mov    %esi,%ebp
  4a3ddd:	jmp    4a3df9 <itype_end+0x59>
  4a3ddf:	nop
  4a3de0:	test   %ebp,%eax
  4a3de2:	je     4a3e90 <itype_end+0xf0>
  4a3de8:	mov    $0x1,%eax
  4a3ded:	add    %rax,%rbx
  4a3df0:	test   %r12d,%r12d
  4a3df3:	jne    4a3e90 <itype_end+0xf0>
  4a3df9:	movzbl (%rbx),%eax
  4a3dfc:	test   %al,%al
  4a3dfe:	je     4a3e90 <itype_end+0xf0>
  4a3e04:	movswl 0x4dc940(%rax,%rax,1),%eax
  4a3e0c:	jns    4a3de0 <itype_end+0x40>
  4a3e0e:	test   $0x10,%al
  4a3e10:	jne    4a3de0 <itype_end+0x40>
  4a3e12:	lea    0x1c(%rsp),%rsi
  4a3e17:	mov    %rbx,%rdi
  4a3e1a:	call   4a3890 <mb_metacharlenconv>
  4a3e1f:	mov    %eax,%ecx
  4a3e21:	test   %eax,%eax
  4a3e23:	je     4a3e90 <itype_end+0xf0>
  4a3e25:	mov    0x1c(%rsp),%esi
  4a3e29:	cmp    $0xffffffff,%esi
  4a3e2c:	je     4a3ef0 <itype_end+0x150>
  4a3e32:	cmp    $0x1,%eax
  4a3e35:	je     4a3f40 <itype_end+0x1a0>
  4a3e3b:	mov    %ecx,0x8(%rsp)
  4a3e3f:	cmp    $0x20,%ebp
  4a3e42:	je     4a3f50 <itype_end+0x1b0>
  4a3e48:	mov    %esi,%edi
  4a3e4a:	cmp    $0x400,%ebp
  4a3e50:	jne    4a3f18 <itype_end+0x178>
  4a3e56:	mov    %esi,0xc(%rsp)
  4a3e5a:	call   40f560 <iswalnum@plt>
  4a3e5f:	mov    0x8(%rsp),%ecx
  4a3e63:	test   %eax,%eax
  4a3e65:	jne    4a3f0b <itype_end+0x16b>
  4a3e6b:	mov    0x3de66(%rip),%rdx        # 4e1cd8 <wordchars_wide+0x8>
  4a3e72:	mov    0xc(%rsp),%esi
  4a3e76:	mov    0x3de53(%rip),%rdi        # 4e1cd0 <wordchars_wide>
  4a3e7d:	call   40f4a0 <wmemchr@plt>
  4a3e82:	mov    0x8(%rsp),%ecx
  4a3e86:	test   %rax,%rax
  4a3e89:	jne    4a3f0b <itype_end+0x16b>
  4a3e8f:	nop
  4a3e90:	mov    %rbx,%rax
  4a3e93:	add    $0x20,%rsp
  4a3e97:	pop    %rbx
  4a3e98:	pop    %rbp
  4a3e99:	pop    %r12
  4a3e9b:	ret
  4a3e9c:	nopl   0x0(%rax)
  4a3ea0:	mov    %rbx,%rax
  4a3ea3:	jmp    4a3ec1 <itype_end+0x121>
  4a3ea5:	nopl   (%rax)
  4a3ea8:	movswl 0x4dc940(%rdx,%rdx,1),%edx
  4a3eb0:	test   %esi,%edx
  4a3eb2:	je     4a3e93 <itype_end+0xf3>
  4a3eb4:	mov    $0x1,%edx
  4a3eb9:	add    %rdx,%rax
  4a3ebc:	test   %r12d,%r12d
  4a3ebf:	jne    4a3e93 <itype_end+0xf3>
  4a3ec1:	movzbl (%rax),%edx
  4a3ec4:	cmp    $0x83,%dl
  4a3ec7:	jne    4a3ea8 <itype_end+0x108>
  4a3ec9:	movzbl 0x1(%rax),%edx
  4a3ecd:	xor    $0x20,%edx
  4a3ed0:	movzbl %dl,%edx
  4a3ed3:	movswl 0x4dc940(%rdx,%rdx,1),%edx
  4a3edb:	test   %esi,%edx
  4a3edd:	je     4a3e93 <itype_end+0xf3>
  4a3edf:	mov    $0x2,%edx
  4a3ee4:	jmp    4a3eb9 <itype_end+0x119>
  4a3ee6:	cs nopw 0x0(%rax,%rax,1)
  4a3ef0:	movzbl (%rbx),%eax
  4a3ef3:	cmp    $0x83,%al
  4a3ef5:	je     4a3f30 <itype_end+0x190>
  4a3ef7:	movzbl %al,%eax
  4a3efa:	cmp    $0x7f,%eax
  4a3efd:	jg     4a3e90 <itype_end+0xf0>
  4a3eff:	movswl 0x4dc940(%rax,%rax,1),%eax
  4a3f07:	test   %ebp,%eax
  4a3f09:	je     4a3e90 <itype_end+0xf0>
  4a3f0b:	movslq %ecx,%rax
  4a3f0e:	jmp    4a3ded <itype_end+0x4d>
  4a3f13:	nopl   0x0(%rax,%rax,1)
  4a3f18:	call   40f560 <iswalnum@plt>
  4a3f1d:	mov    0x8(%rsp),%ecx
  4a3f21:	test   %eax,%eax
  4a3f23:	jne    4a3f0b <itype_end+0x16b>
  4a3f25:	jmp    4a3e90 <itype_end+0xf0>
  4a3f2a:	nopw   0x0(%rax,%rax,1)
  4a3f30:	movzbl 0x1(%rbx),%eax
  4a3f34:	xor    $0x20,%eax
  4a3f37:	jmp    4a3ef7 <itype_end+0x157>
  4a3f39:	nopl   0x0(%rax)
  4a3f40:	movsbq (%rbx),%rax
  4a3f44:	test   %al,%al
  4a3f46:	jns    4a3eff <itype_end+0x15f>
  4a3f48:	jmp    4a3e3b <itype_end+0x9b>
  4a3f4d:	nopl   (%rax)
  4a3f50:	mov    0x3dd71(%rip),%rdx        # 4e1cc8 <ifs_wide+0x8>
  4a3f57:	mov    0x3dd62(%rip),%rdi        # 4e1cc0 <ifs_wide>
  4a3f5e:	call   40f4a0 <wmemchr@plt>
  4a3f63:	mov    0x8(%rsp),%ecx
  4a3f67:	test   %rax,%rax
  4a3f6a:	jne    4a3f0b <itype_end+0x16b>
  4a3f6c:	jmp    4a3e90 <itype_end+0xf0>

Disassembly of section .fini:
