
.work/round26/resume/Src/zsh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004a2930 <zstrtol_underscore>:
  4a2930:	push   %r14
  4a2932:	movslq %edx,%r8
  4a2935:	push   %r13
  4a2937:	push   %r12
  4a2939:	push   %rbp
  4a293a:	mov    %rsi,%rbp
  4a293d:	push   %rbx
  4a293e:	mov    %rdi,%rbx
  4a2941:	mov    %ecx,%edi
  4a2943:	movzbl (%rbx),%eax
  4a2946:	mov    %rax,%rsi
  4a2949:	movzwl 0x4dc940(%rax,%rax,1),%eax
  4a2951:	cmp    $0xa,%r8d
  4a2955:	je     4a2b98 <zstrtol_underscore+0x268>
  4a295b:	test   $0x8,%al
  4a295d:	je     4a2975 <zstrtol_underscore+0x45>
  4a295f:	nop
  4a2960:	movzbl 0x1(%rbx),%eax
  4a2964:	add    $0x1,%rbx
  4a2968:	mov    %rax,%rsi
  4a296b:	testb  $0x8,0x4dc940(%rax,%rax,1)
  4a2973:	jne    4a2960 <zstrtol_underscore+0x30>
  4a2975:	cmp    $0x2d,%sil
  4a2979:	je     4a29d0 <zstrtol_underscore+0xa0>
  4a297b:	cmp    $0x9b,%sil
  4a297f:	je     4a29d0 <zstrtol_underscore+0xa0>
  4a2981:	xor    %r12d,%r12d
  4a2984:	cmp    $0x2b,%sil
  4a2988:	je     4a29d6 <zstrtol_underscore+0xa6>
  4a298a:	test   %r8d,%r8d
  4a298d:	jne    4a29df <zstrtol_underscore+0xaf>
  4a298f:	movsbq (%rbx),%rdx
  4a2993:	mov    $0xa,%r8d
  4a2999:	cmp    $0x30,%dl
  4a299c:	je     4a2d80 <zstrtol_underscore+0x450>
  4a29a2:	xor    %r13d,%r13d
  4a29a5:	cmp    $0x2f,%dl
  4a29a8:	jg     4a2c30 <zstrtol_underscore+0x300>
  4a29ae:	test   %rbp,%rbp
  4a29b1:	je     4a29b7 <zstrtol_underscore+0x87>
  4a29b3:	mov    %rbx,0x0(%rbp)
  4a29b7:	mov    %r13,%rax
  4a29ba:	neg    %rax
  4a29bd:	test   %r12d,%r12d
  4a29c0:	cmovne %rax,%r13
  4a29c4:	pop    %rbx
  4a29c5:	mov    %r13,%rax
  4a29c8:	pop    %rbp
  4a29c9:	pop    %r12
  4a29cb:	pop    %r13
  4a29cd:	pop    %r14
  4a29cf:	ret
  4a29d0:	mov    $0x1,%r12d
  4a29d6:	add    $0x1,%rbx
  4a29da:	test   %r8d,%r8d
  4a29dd:	je     4a298f <zstrtol_underscore+0x5f>
  4a29df:	lea    -0x2(%r8),%eax
  4a29e3:	cmp    $0x22,%eax
  4a29e6:	ja     4a2d9d <zstrtol_underscore+0x46d>
  4a29ec:	cmp    $0xa,%r8d
  4a29f0:	jle    4a2e1f <zstrtol_underscore+0x4ef>
  4a29f6:	test   %edi,%edi
  4a29f8:	mov    %rbx,%rcx
  4a29fb:	lea    0x36(%r8),%r11d
  4a29ff:	movslq %r8d,%r10
  4a2a02:	setne  %r13b
  4a2a06:	lea    0x56(%r8),%r9d
  4a2a0a:	xor    %esi,%esi
  4a2a0c:	xor    %edi,%edi
  4a2a0e:	xchg   %ax,%ax
  4a2a10:	movzbl (%rcx),%edx
  4a2a13:	mov    %rdx,%rax
  4a2a16:	testb  $0x1,0x4dc940(%rdx,%rdx,1)
  4a2a1e:	je     4a2a69 <zstrtol_underscore+0x139>
  4a2a20:	mov    %rsi,%rdx
  4a2a23:	test   %rdi,%rdi
  4a2a26:	jne    4a2ad5 <zstrtol_underscore+0x1a5>
  4a2a2c:	cmp    $0x5f,%al
  4a2a2e:	je     4a2a4f <zstrtol_underscore+0x11f>
  4a2a30:	mov    %r10,%rdi
  4a2a33:	movsbl %al,%eax
  4a2a36:	mov    %rdx,%rsi
  4a2a39:	imul   %rdx,%rdi
  4a2a3d:	sub    $0x30,%eax
  4a2a40:	cltq
  4a2a42:	lea    (%rax,%rdi,1),%rdx
  4a2a46:	cmp    %rsi,%rdx
  4a2a49:	jb     4a2b58 <zstrtol_underscore+0x228>
  4a2a4f:	movzbl 0x1(%rcx),%esi
  4a2a53:	add    $0x1,%rcx
  4a2a57:	xor    %edi,%edi
  4a2a59:	mov    %rsi,%rax
  4a2a5c:	testb  $0x1,0x4dc940(%rsi,%rsi,1)
  4a2a64:	jne    4a2a2c <zstrtol_underscore+0xfc>
  4a2a66:	mov    %rdx,%rsi
  4a2a69:	cmp    $0x60,%al
  4a2a6b:	jle    4a2af7 <zstrtol_underscore+0x1c7>
  4a2a71:	movsbl %al,%edx
  4a2a74:	cmp    %edx,%r9d
  4a2a77:	jge    4a2b38 <zstrtol_underscore+0x208>
  4a2a7d:	mov    %rsi,%r13
  4a2a80:	test   %rdi,%rdi
  4a2a83:	jne    4a2e41 <zstrtol_underscore+0x511>
  4a2a89:	test   %rsi,%rsi
  4a2a8c:	jns    4a2e34 <zstrtol_underscore+0x504>
  4a2a92:	mov    %rsi,%rax
  4a2a95:	jmp    4a2cca <zstrtol_underscore+0x39a>
  4a2a9a:	nopl   0x0(%rax,%rax,1)
  4a2a9f:	data16 cs nopw 0x0(%rax,%rax,1)
  4a2aaa:	data16 cs nopw 0x0(%rax,%rax,1)
  4a2ab5:	data16 cs nopw 0x0(%rax,%rax,1)
  4a2ac0:	lea    0x2(%rdx),%rcx
  4a2ac4:	movzbl 0x2(%rdx),%edx
  4a2ac8:	mov    %rdx,%rax
  4a2acb:	testb  $0x1,0x4dc940(%rdx,%rdx,1)
  4a2ad3:	je     4a2a69 <zstrtol_underscore+0x139>
  4a2ad5:	mov    %rcx,%rdx
  4a2ad8:	movzbl 0x1(%rdx),%r14d
  4a2add:	lea    0x1(%rdx),%rcx
  4a2ae1:	mov    %r14,%rax
  4a2ae4:	testb  $0x1,0x4dc940(%r14,%r14,1)
  4a2aed:	jne    4a2ac0 <zstrtol_underscore+0x190>
  4a2aef:	cmp    $0x60,%al
  4a2af1:	jg     4a2a71 <zstrtol_underscore+0x141>
  4a2af7:	cmp    $0x40,%al
  4a2af9:	jle    4a2a7d <zstrtol_underscore+0x14d>
  4a2aff:	movsbl %al,%edx
  4a2b02:	cmp    %edx,%r11d
  4a2b05:	jl     4a2b80 <zstrtol_underscore+0x250>
  4a2b07:	test   %rdi,%rdi
  4a2b0a:	je     4a2c20 <zstrtol_underscore+0x2f0>
  4a2b10:	movzbl 0x1(%rcx),%edx
  4a2b14:	add    $0x1,%rcx
  4a2b18:	mov    %rdx,%rax
  4a2b1b:	testb  $0x1,0x4dc940(%rdx,%rdx,1)
  4a2b23:	je     4a2a69 <zstrtol_underscore+0x139>
  4a2b29:	add    $0x1,%rcx
  4a2b2d:	jmp    4a2a10 <zstrtol_underscore+0xe0>
  4a2b32:	nopw   0x0(%rax,%rax,1)
  4a2b38:	test   %rdi,%rdi
  4a2b3b:	jne    4a2b10 <zstrtol_underscore+0x1e0>
  4a2b3d:	mov    %r10,%rdi
  4a2b40:	imul   %rsi,%rdi
  4a2b44:	and    $0x1f,%eax
  4a2b47:	add    $0x9,%rax
  4a2b4b:	lea    (%rax,%rdi,1),%rdx
  4a2b4f:	cmp    %rsi,%rdx
  4a2b52:	jae    4a2a4f <zstrtol_underscore+0x11f>
  4a2b58:	movzbl 0x1(%rcx),%edi
  4a2b5c:	lea    0x1(%rcx),%rdx
  4a2b60:	testb  $0x1,0x4dc940(%rdi,%rdi,1)
  4a2b68:	mov    %rdi,%rax
  4a2b6b:	mov    %rcx,%rdi
  4a2b6e:	mov    %rdx,%rcx
  4a2b71:	je     4a2a69 <zstrtol_underscore+0x139>
  4a2b77:	jmp    4a2ad8 <zstrtol_underscore+0x1a8>
  4a2b7c:	nopl   0x0(%rax)
  4a2b80:	cmp    $0x5f,%al
  4a2b82:	jne    4a2a7d <zstrtol_underscore+0x14d>
  4a2b88:	test   %r13b,%r13b
  4a2b8b:	jne    4a2b29 <zstrtol_underscore+0x1f9>
  4a2b8d:	jmp    4a2a7d <zstrtol_underscore+0x14d>
  4a2b92:	nopw   0x0(%rax,%rax,1)
  4a2b98:	test   $0x8,%al
  4a2b9a:	jne    4a2960 <zstrtol_underscore+0x30>
  4a2ba0:	mov    %rbx,%rcx
  4a2ba3:	xor    %r12d,%r12d
  4a2ba6:	xor    %r13d,%r13d
  4a2ba9:	nop
  4a2baa:	data16 cs nopw 0x0(%rax,%rax,1)
  4a2bb5:	data16 cs nopw 0x0(%rax,%rax,1)
  4a2bc0:	movsbq (%rcx),%rax
  4a2bc4:	movsbl %al,%edx
  4a2bc7:	sub    $0x30,%edx
  4a2bca:	cmp    $0x9,%edx
  4a2bcd:	ja     4a2db4 <zstrtol_underscore+0x484>
  4a2bd3:	lea    0x0(%r13,%r13,4),%rdx
  4a2bd8:	add    $0x1,%r12d
  4a2bdc:	add    $0x1,%rcx
  4a2be0:	lea    -0x30(%rax,%rdx,2),%r13
  4a2be5:	cmp    $0x12,%r12d
  4a2be9:	jne    4a2bc0 <zstrtol_underscore+0x290>
  4a2beb:	movsbq (%rcx),%rax
  4a2bef:	lea    -0x30(%rax),%esi
  4a2bf2:	mov    %rax,%rdx
  4a2bf5:	cmp    $0x9,%esi
  4a2bf8:	jbe    4a2e0e <zstrtol_underscore+0x4de>
  4a2bfe:	test   %edi,%edi
  4a2c00:	je     4a2c0a <zstrtol_underscore+0x2da>
  4a2c02:	cmp    $0x5f,%al
  4a2c04:	je     4a2e0e <zstrtol_underscore+0x4de>
  4a2c0a:	test   %rbp,%rbp
  4a2c0d:	je     4a29c4 <zstrtol_underscore+0x94>
  4a2c13:	mov    %rcx,0x0(%rbp)
  4a2c17:	jmp    4a29c4 <zstrtol_underscore+0x94>
  4a2c1c:	nopl   0x0(%rax)
  4a2c20:	movslq %r8d,%rdi
  4a2c23:	imul   %rsi,%rdi
  4a2c27:	jmp    4a2b44 <zstrtol_underscore+0x214>
  4a2c2c:	nopl   0x0(%rax)
  4a2c30:	lea    0x2f(%r8),%r9d
  4a2c34:	mov    %rbx,%rcx
  4a2c37:	xor    %esi,%esi
  4a2c39:	movsbl %dl,%eax
  4a2c3c:	test   %edi,%edi
  4a2c3e:	movslq %r8d,%r10
  4a2c41:	setne  %r11b
  4a2c45:	xor    %edi,%edi
  4a2c47:	nopw   0x0(%rax,%rax,1)
  4a2c50:	cmp    %r9d,%eax
  4a2c53:	jg     4a2d10 <zstrtol_underscore+0x3e0>
  4a2c59:	test   %rdi,%rdi
  4a2c5c:	je     4a2c9b <zstrtol_underscore+0x36b>
  4a2c5e:	movzbl 0x1(%rcx),%edx
  4a2c62:	cmp    $0x2f,%dl
  4a2c65:	jg     4a2cf8 <zstrtol_underscore+0x3c8>
  4a2c6b:	mov    %rbx,%rax
  4a2c6e:	mov    %rsi,%r13
  4a2c71:	lea    0x1(%rcx),%rbx
  4a2c75:	mov    %edi,%esi
  4a2c77:	mov    %rax,%rdx
  4a2c7a:	mov    $0x4aee98,%edi
  4a2c7f:	sub    %eax,%esi
  4a2c81:	xor    %eax,%eax
  4a2c83:	call   4a2810 <zwarn>
  4a2c88:	jmp    4a29ae <zstrtol_underscore+0x7e>
  4a2c8d:	nopl   (%rax)
  4a2c90:	movsbl %dl,%esi
  4a2c93:	cmp    %r9d,%esi
  4a2c96:	mov    %rax,%rsi
  4a2c99:	jg     4a2d10 <zstrtol_underscore+0x3e0>
  4a2c9b:	mov    %r10,%rax
  4a2c9e:	imul   %rsi,%rax
  4a2ca2:	lea    -0x30(%rax,%rdx,1),%rax
  4a2ca7:	cmp    %rsi,%rax
  4a2caa:	jb     4a2d40 <zstrtol_underscore+0x410>
  4a2cb0:	movsbq 0x1(%rcx),%rdx
  4a2cb5:	add    $0x1,%rcx
  4a2cb9:	cmp    $0x2f,%dl
  4a2cbc:	jg     4a2c90 <zstrtol_underscore+0x360>
  4a2cbe:	mov    %rax,%r13
  4a2cc1:	test   %rax,%rax
  4a2cc4:	jns    4a2e39 <zstrtol_underscore+0x509>
  4a2cca:	test   %r12d,%r12d
  4a2ccd:	je     4a2d48 <zstrtol_underscore+0x418>
  4a2ccf:	mov    %rax,%rdx
  4a2cd2:	btr    $0x3f,%rdx
  4a2cd7:	test   %rdx,%rdx
  4a2cda:	jne    4a2d48 <zstrtol_underscore+0x418>
  4a2cdc:	test   %rbp,%rbp
  4a2cdf:	je     4a2ce5 <zstrtol_underscore+0x3b5>
  4a2ce1:	mov    %rcx,0x0(%rbp)
  4a2ce5:	movabs $0x8000000000000000,%r13
  4a2cef:	jmp    4a29c4 <zstrtol_underscore+0x94>
  4a2cf4:	nopl   0x0(%rax)
  4a2cf8:	movsbl %dl,%eax
  4a2cfb:	cmp    %r9d,%eax
  4a2cfe:	jle    4a2d60 <zstrtol_underscore+0x430>
  4a2d00:	add    $0x1,%rcx
  4a2d04:	nop
  4a2d05:	data16 cs nopw 0x0(%rax,%rax,1)
  4a2d10:	cmp    $0x5f,%dl
  4a2d13:	jne    4a2a7d <zstrtol_underscore+0x14d>
  4a2d19:	test   %r11b,%r11b
  4a2d1c:	je     4a2a7d <zstrtol_underscore+0x14d>
  4a2d22:	movsbq 0x1(%rcx),%rdx
  4a2d27:	add    $0x1,%rcx
  4a2d2b:	cmp    $0x2f,%dl
  4a2d2e:	jle    4a2a7d <zstrtol_underscore+0x14d>
  4a2d34:	movsbl %dl,%eax
  4a2d37:	jmp    4a2c50 <zstrtol_underscore+0x320>
  4a2d3c:	nopl   0x0(%rax)
  4a2d40:	mov    %rcx,%rdi
  4a2d43:	jmp    4a2d22 <zstrtol_underscore+0x3f2>
  4a2d45:	nopl   (%rax)
  4a2d48:	xor    %edx,%edx
  4a2d4a:	lea    -0x1(%rcx),%rdi
  4a2d4e:	div    %r8
  4a2d51:	mov    %rax,%r13
  4a2d54:	mov    %rbx,%rax
  4a2d57:	mov    %rcx,%rbx
  4a2d5a:	jmp    4a2c75 <zstrtol_underscore+0x345>
  4a2d5f:	nop
  4a2d60:	movzbl 0x2(%rcx),%edx
  4a2d64:	add    $0x2,%rcx
  4a2d68:	cmp    $0x2f,%dl
  4a2d6b:	jle    4a2a7d <zstrtol_underscore+0x14d>
  4a2d71:	movsbl %dl,%eax
  4a2d74:	cmp    %eax,%r9d
  4a2d77:	jge    4a2c5e <zstrtol_underscore+0x32e>
  4a2d7d:	jmp    4a2d10 <zstrtol_underscore+0x3e0>
  4a2d7f:	nop
  4a2d80:	movsbq 0x1(%rbx),%rdx
  4a2d85:	mov    %edx,%eax
  4a2d87:	and    $0xffffffdf,%eax
  4a2d8a:	cmp    $0x58,%al
  4a2d8c:	jne    4a2dd8 <zstrtol_underscore+0x4a8>
  4a2d8e:	add    $0x2,%rbx
  4a2d92:	mov    $0x10,%r8d
  4a2d98:	jmp    4a29f6 <zstrtol_underscore+0xc6>
  4a2d9d:	mov    %r8d,%esi
  4a2da0:	mov    $0x4ac988,%edi
  4a2da5:	xor    %eax,%eax
  4a2da7:	xor    %r13d,%r13d
  4a2daa:	call   4a19b0 <zerr>
  4a2daf:	jmp    4a29c4 <zstrtol_underscore+0x94>
  4a2db4:	test   %r12d,%r12d
  4a2db7:	jne    4a2beb <zstrtol_underscore+0x2bb>
  4a2dbd:	cmp    $0x2d,%sil
  4a2dc1:	je     4a2dff <zstrtol_underscore+0x4cf>
  4a2dc3:	cmp    $0x9b,%sil
  4a2dc7:	je     4a2dff <zstrtol_underscore+0x4cf>
  4a2dc9:	cmp    $0x2b,%sil
  4a2dcd:	jne    4a29df <zstrtol_underscore+0xaf>
  4a2dd3:	jmp    4a29d6 <zstrtol_underscore+0xa6>
  4a2dd8:	cmp    $0x42,%al
  4a2dda:	jne    4a2df0 <zstrtol_underscore+0x4c0>
  4a2ddc:	movsbq 0x2(%rbx),%rdx
  4a2de1:	mov    $0x2,%r8d
  4a2de7:	add    $0x2,%rbx
  4a2deb:	jmp    4a29a2 <zstrtol_underscore+0x72>
  4a2df0:	add    $0x1,%rbx
  4a2df4:	mov    $0x8,%r8d
  4a2dfa:	jmp    4a29a2 <zstrtol_underscore+0x72>
  4a2dff:	add    $0x1,%rbx
  4a2e03:	mov    $0x1,%r12d
  4a2e09:	jmp    4a29df <zstrtol_underscore+0xaf>
  4a2e0e:	mov    %r13,%rsi
  4a2e11:	mov    $0x39,%r9d
  4a2e17:	xor    %r12d,%r12d
  4a2e1a:	jmp    4a2c3c <zstrtol_underscore+0x30c>
  4a2e1f:	movsbq (%rbx),%rdx
  4a2e23:	cmp    $0x2f,%dl
  4a2e26:	jg     4a2c30 <zstrtol_underscore+0x300>
  4a2e2c:	xor    %r13d,%r13d
  4a2e2f:	jmp    4a29ae <zstrtol_underscore+0x7e>
  4a2e34:	test   %rdi,%rdi
  4a2e37:	jne    4a2e41 <zstrtol_underscore+0x511>
  4a2e39:	mov    %rcx,%rbx
  4a2e3c:	jmp    4a29ae <zstrtol_underscore+0x7e>
  4a2e41:	mov    %rbx,%rax
  4a2e44:	mov    %rcx,%rbx
  4a2e47:	jmp    4a2c75 <zstrtol_underscore+0x345>

Disassembly of section .fini:
