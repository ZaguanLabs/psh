
.work/round26/previous/Src/zsh:     file format elf64-x86-64


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
  4a293e:	movzbl (%rdi),%edx
  4a2941:	mov    %rdi,%rbx
  4a2944:	testb  $0x8,0x4dc940(%rdx,%rdx,1)
  4a294c:	je     4a2d3b <zstrtol_underscore+0x40b>
  4a2952:	nopl   (%rax)
  4a2955:	data16 cs nopw 0x0(%rax,%rax,1)
  4a2960:	movzbl 0x1(%rbx),%edx
  4a2964:	add    $0x1,%rbx
  4a2968:	mov    %rdx,%rax
  4a296b:	testb  $0x8,0x4dc940(%rdx,%rdx,1)
  4a2973:	jne    4a2960 <zstrtol_underscore+0x30>
  4a2975:	cmp    $0x2d,%al
  4a2977:	sete   %r12b
  4a297b:	cmp    $0x9b,%al
  4a297d:	sete   %dl
  4a2980:	or     %dl,%r12b
  4a2983:	jne    4a2a38 <zstrtol_underscore+0x108>
  4a2989:	cmp    $0x2b,%al
  4a298b:	je     4a2a38 <zstrtol_underscore+0x108>
  4a2991:	test   %r8d,%r8d
  4a2994:	jne    4a2a45 <zstrtol_underscore+0x115>
  4a299a:	movsbq (%rbx),%rdx
  4a299e:	mov    $0xa,%r8d
  4a29a4:	cmp    $0x30,%dl
  4a29a7:	je     4a2d00 <zstrtol_underscore+0x3d0>
  4a29ad:	cmp    $0x2f,%dl
  4a29b0:	jle    4a2cd8 <zstrtol_underscore+0x3a8>
  4a29b6:	test   %ecx,%ecx
  4a29b8:	lea    0x2f(%r8),%r9d
  4a29bc:	mov    %rbx,%rcx
  4a29bf:	movslq %r8d,%r10
  4a29c2:	setne  %r11b
  4a29c6:	xor    %esi,%esi
  4a29c8:	xor    %edi,%edi
  4a29ca:	nopw   0x0(%rax,%rax,1)
  4a29d0:	movsbl %dl,%eax
  4a29d3:	cmp    %r9d,%eax
  4a29d6:	jg     4a2c90 <zstrtol_underscore+0x360>
  4a29dc:	test   %rdi,%rdi
  4a29df:	je     4a2b1f <zstrtol_underscore+0x1ef>
  4a29e5:	movzbl 0x1(%rcx),%edx
  4a29e9:	cmp    $0x2f,%dl
  4a29ec:	jg     4a2c78 <zstrtol_underscore+0x348>
  4a29f2:	mov    %rbx,%rax
  4a29f5:	mov    %rsi,%r13
  4a29f8:	lea    0x1(%rcx),%rbx
  4a29fc:	mov    %edi,%esi
  4a29fe:	mov    %rax,%rdx
  4a2a01:	mov    $0x4aeea0,%edi
  4a2a06:	sub    %eax,%esi
  4a2a08:	xor    %eax,%eax
  4a2a0a:	call   4a2810 <zwarn>
  4a2a0f:	test   %rbp,%rbp
  4a2a12:	je     4a2a18 <zstrtol_underscore+0xe8>
  4a2a14:	mov    %rbx,0x0(%rbp)
  4a2a18:	mov    %r13,%rax
  4a2a1b:	neg    %rax
  4a2a1e:	test   %r12b,%r12b
  4a2a21:	cmovne %rax,%r13
  4a2a25:	pop    %rbx
  4a2a26:	mov    %r13,%rax
  4a2a29:	pop    %rbp
  4a2a2a:	pop    %r12
  4a2a2c:	pop    %r13
  4a2a2e:	pop    %r14
  4a2a30:	ret
  4a2a31:	nopl   0x0(%rax)
  4a2a38:	add    $0x1,%rbx
  4a2a3c:	test   %r8d,%r8d
  4a2a3f:	je     4a299a <zstrtol_underscore+0x6a>
  4a2a45:	lea    -0x2(%r8),%eax
  4a2a49:	cmp    $0x22,%eax
  4a2a4c:	ja     4a2d1d <zstrtol_underscore+0x3ed>
  4a2a52:	cmp    $0xa,%r8d
  4a2a56:	jle    4a2d7a <zstrtol_underscore+0x44a>
  4a2a5c:	test   %ecx,%ecx
  4a2a5e:	movslq %r8d,%r10
  4a2a61:	lea    0x36(%r8),%r11d
  4a2a65:	mov    %rbx,%rcx
  4a2a68:	setne  %r13b
  4a2a6c:	lea    0x56(%r8),%r9d
  4a2a70:	xor    %esi,%esi
  4a2a72:	xor    %edi,%edi
  4a2a74:	nop
  4a2a75:	data16 cs nopw 0x0(%rax,%rax,1)
  4a2a80:	movzbl (%rcx),%edx
  4a2a83:	mov    %rdx,%rax
  4a2a86:	testb  $0x1,0x4dc940(%rdx,%rdx,1)
  4a2a8e:	je     4a2ad9 <zstrtol_underscore+0x1a9>
  4a2a90:	mov    %rsi,%rdx
  4a2a93:	test   %rdi,%rdi
  4a2a96:	jne    4a2c38 <zstrtol_underscore+0x308>
  4a2a9c:	cmp    $0x5f,%al
  4a2a9e:	je     4a2abf <zstrtol_underscore+0x18f>
  4a2aa0:	mov    %r10,%rdi
  4a2aa3:	movsbl %al,%eax
  4a2aa6:	mov    %rdx,%rsi
  4a2aa9:	imul   %rdx,%rdi
  4a2aad:	sub    $0x30,%eax
  4a2ab0:	cltq
  4a2ab2:	lea    (%rax,%rdi,1),%rdx
  4a2ab6:	cmp    %rsi,%rdx
  4a2ab9:	jb     4a2c00 <zstrtol_underscore+0x2d0>
  4a2abf:	movzbl 0x1(%rcx),%esi
  4a2ac3:	add    $0x1,%rcx
  4a2ac7:	xor    %edi,%edi
  4a2ac9:	mov    %rsi,%rax
  4a2acc:	testb  $0x1,0x4dc940(%rsi,%rsi,1)
  4a2ad4:	jne    4a2a9c <zstrtol_underscore+0x16c>
  4a2ad6:	mov    %rdx,%rsi
  4a2ad9:	cmp    $0x60,%al
  4a2adb:	jle    4a2ba0 <zstrtol_underscore+0x270>
  4a2ae1:	movsbl %al,%edx
  4a2ae4:	cmp    %edx,%r9d
  4a2ae7:	jge    4a2be0 <zstrtol_underscore+0x2b0>
  4a2aed:	mov    %rsi,%r13
  4a2af0:	test   %rdi,%rdi
  4a2af3:	jne    4a2d48 <zstrtol_underscore+0x418>
  4a2af9:	test   %rsi,%rsi
  4a2afc:	jns    4a2d43 <zstrtol_underscore+0x413>
  4a2b02:	mov    %rsi,%rax
  4a2b05:	jmp    4a2b4e <zstrtol_underscore+0x21e>
  4a2b07:	nopw   0x0(%rax,%rax,1)
  4a2b10:	movsbl %dl,%esi
  4a2b13:	cmp    %esi,%r9d
  4a2b16:	mov    %rax,%rsi
  4a2b19:	jl     4a2c90 <zstrtol_underscore+0x360>
  4a2b1f:	mov    %r10,%rax
  4a2b22:	imul   %rsi,%rax
  4a2b26:	lea    -0x30(%rax,%rdx,1),%rax
  4a2b2b:	cmp    %rsi,%rax
  4a2b2e:	jb     4a2cc0 <zstrtol_underscore+0x390>
  4a2b34:	movsbq 0x1(%rcx),%rdx
  4a2b39:	add    $0x1,%rcx
  4a2b3d:	cmp    $0x2f,%dl
  4a2b40:	jg     4a2b10 <zstrtol_underscore+0x1e0>
  4a2b42:	mov    %rax,%r13
  4a2b45:	test   %rax,%rax
  4a2b48:	jns    4a2d83 <zstrtol_underscore+0x453>
  4a2b4e:	test   %r12b,%r12b
  4a2b51:	je     4a2b80 <zstrtol_underscore+0x250>
  4a2b53:	mov    %rax,%rdx
  4a2b56:	btr    $0x3f,%rdx
  4a2b5b:	test   %rdx,%rdx
  4a2b5e:	jne    4a2b80 <zstrtol_underscore+0x250>
  4a2b60:	test   %rbp,%rbp
  4a2b63:	je     4a2b69 <zstrtol_underscore+0x239>
  4a2b65:	mov    %rcx,0x0(%rbp)
  4a2b69:	movabs $0x8000000000000000,%r13
  4a2b73:	jmp    4a2a25 <zstrtol_underscore+0xf5>
  4a2b78:	nopl   0x0(%rax,%rax,1)
  4a2b80:	xor    %edx,%edx
  4a2b82:	lea    -0x1(%rcx),%rdi
  4a2b86:	div    %r8
  4a2b89:	mov    %rax,%r13
  4a2b8c:	mov    %rbx,%rax
  4a2b8f:	mov    %rcx,%rbx
  4a2b92:	jmp    4a29fc <zstrtol_underscore+0xcc>
  4a2b97:	nopw   0x0(%rax,%rax,1)
  4a2ba0:	cmp    $0x40,%al
  4a2ba2:	jle    4a2aed <zstrtol_underscore+0x1bd>
  4a2ba8:	movsbl %al,%edx
  4a2bab:	cmp    %edx,%r11d
  4a2bae:	jl     4a2c20 <zstrtol_underscore+0x2f0>
  4a2bb0:	test   %rdi,%rdi
  4a2bb3:	je     4a2cc8 <zstrtol_underscore+0x398>
  4a2bb9:	movzbl 0x1(%rcx),%edx
  4a2bbd:	add    $0x1,%rcx
  4a2bc1:	mov    %rdx,%rax
  4a2bc4:	testb  $0x1,0x4dc940(%rdx,%rdx,1)
  4a2bcc:	je     4a2ad9 <zstrtol_underscore+0x1a9>
  4a2bd2:	add    $0x1,%rcx
  4a2bd6:	jmp    4a2a80 <zstrtol_underscore+0x150>
  4a2bdb:	nopl   0x0(%rax,%rax,1)
  4a2be0:	test   %rdi,%rdi
  4a2be3:	jne    4a2bb9 <zstrtol_underscore+0x289>
  4a2be5:	mov    %r10,%rdi
  4a2be8:	imul   %rsi,%rdi
  4a2bec:	and    $0x1f,%eax
  4a2bef:	add    $0x9,%rax
  4a2bf3:	lea    (%rax,%rdi,1),%rdx
  4a2bf7:	cmp    %rsi,%rdx
  4a2bfa:	jae    4a2abf <zstrtol_underscore+0x18f>
  4a2c00:	movzbl 0x1(%rcx),%edx
  4a2c04:	lea    0x1(%rcx),%r14
  4a2c08:	mov    %rcx,%rdi
  4a2c0b:	mov    %rdx,%rax
  4a2c0e:	testb  $0x1,0x4dc940(%rdx,%rdx,1)
  4a2c16:	jne    4a2c40 <zstrtol_underscore+0x310>
  4a2c18:	mov    %r14,%rcx
  4a2c1b:	jmp    4a2ad9 <zstrtol_underscore+0x1a9>
  4a2c20:	cmp    $0x5f,%al
  4a2c22:	jne    4a2aed <zstrtol_underscore+0x1bd>
  4a2c28:	test   %r13b,%r13b
  4a2c2b:	jne    4a2bd2 <zstrtol_underscore+0x2a2>
  4a2c2d:	jmp    4a2aed <zstrtol_underscore+0x1bd>
  4a2c32:	nopw   0x0(%rax,%rax,1)
  4a2c38:	mov    %rcx,%r14
  4a2c3b:	nopl   0x0(%rax,%rax,1)
  4a2c40:	movzbl 0x1(%r14),%edx
  4a2c45:	lea    0x1(%r14),%rcx
  4a2c49:	mov    %rdx,%rax
  4a2c4c:	testb  $0x1,0x4dc940(%rdx,%rdx,1)
  4a2c54:	je     4a2ad9 <zstrtol_underscore+0x1a9>
  4a2c5a:	movzbl 0x2(%r14),%edx
  4a2c5f:	add    $0x2,%r14
  4a2c63:	mov    %rdx,%rax
  4a2c66:	testb  $0x1,0x4dc940(%rdx,%rdx,1)
  4a2c6e:	jne    4a2c40 <zstrtol_underscore+0x310>
  4a2c70:	jmp    4a2c18 <zstrtol_underscore+0x2e8>
  4a2c72:	nopw   0x0(%rax,%rax,1)
  4a2c78:	movsbl %dl,%eax
  4a2c7b:	cmp    %r9d,%eax
  4a2c7e:	jle    4a2ce0 <zstrtol_underscore+0x3b0>
  4a2c80:	add    $0x1,%rcx
  4a2c84:	nop
  4a2c85:	data16 cs nopw 0x0(%rax,%rax,1)
  4a2c90:	cmp    $0x5f,%dl
  4a2c93:	jne    4a2aed <zstrtol_underscore+0x1bd>
  4a2c99:	test   %r11b,%r11b
  4a2c9c:	je     4a2aed <zstrtol_underscore+0x1bd>
  4a2ca2:	movsbq 0x1(%rcx),%rdx
  4a2ca7:	add    $0x1,%rcx
  4a2cab:	cmp    $0x2f,%dl
  4a2cae:	jle    4a2aed <zstrtol_underscore+0x1bd>
  4a2cb4:	jmp    4a29d0 <zstrtol_underscore+0xa0>
  4a2cb9:	nopl   0x0(%rax)
  4a2cc0:	mov    %rcx,%rdi
  4a2cc3:	jmp    4a2ca2 <zstrtol_underscore+0x372>
  4a2cc5:	nopl   (%rax)
  4a2cc8:	movslq %r8d,%rdi
  4a2ccb:	imul   %rsi,%rdi
  4a2ccf:	jmp    4a2bec <zstrtol_underscore+0x2bc>
  4a2cd4:	nopl   0x0(%rax)
  4a2cd8:	xor    %r13d,%r13d
  4a2cdb:	jmp    4a2a0f <zstrtol_underscore+0xdf>
  4a2ce0:	movzbl 0x2(%rcx),%edx
  4a2ce4:	add    $0x2,%rcx
  4a2ce8:	cmp    $0x2f,%dl
  4a2ceb:	jle    4a2aed <zstrtol_underscore+0x1bd>
  4a2cf1:	movsbl %dl,%eax
  4a2cf4:	cmp    %eax,%r9d
  4a2cf7:	jge    4a29e5 <zstrtol_underscore+0xb5>
  4a2cfd:	jmp    4a2c90 <zstrtol_underscore+0x360>
  4a2cff:	nop
  4a2d00:	movsbq 0x1(%rbx),%rdx
  4a2d05:	mov    %edx,%eax
  4a2d07:	and    $0xffffffdf,%eax
  4a2d0a:	cmp    $0x58,%al
  4a2d0c:	jne    4a2d53 <zstrtol_underscore+0x423>
  4a2d0e:	add    $0x2,%rbx
  4a2d12:	mov    $0x10,%r8d
  4a2d18:	jmp    4a2a5c <zstrtol_underscore+0x12c>
  4a2d1d:	xor    %eax,%eax
  4a2d1f:	xor    %r13d,%r13d
  4a2d22:	mov    %r8d,%esi
  4a2d25:	mov    $0x4ac988,%edi
  4a2d2a:	call   4a19b0 <zerr>
  4a2d2f:	pop    %rbx
  4a2d30:	mov    %r13,%rax
  4a2d33:	pop    %rbp
  4a2d34:	pop    %r12
  4a2d36:	pop    %r13
  4a2d38:	pop    %r14
  4a2d3a:	ret
  4a2d3b:	mov    %rdx,%rax
  4a2d3e:	jmp    4a2975 <zstrtol_underscore+0x45>
  4a2d43:	test   %rdi,%rdi
  4a2d46:	je     4a2d83 <zstrtol_underscore+0x453>
  4a2d48:	mov    %rbx,%rax
  4a2d4b:	mov    %rcx,%rbx
  4a2d4e:	jmp    4a29fc <zstrtol_underscore+0xcc>
  4a2d53:	cmp    $0x42,%al
  4a2d55:	jne    4a2d6b <zstrtol_underscore+0x43b>
  4a2d57:	movsbq 0x2(%rbx),%rdx
  4a2d5c:	mov    $0x2,%r8d
  4a2d62:	add    $0x2,%rbx
  4a2d66:	jmp    4a29ad <zstrtol_underscore+0x7d>
  4a2d6b:	add    $0x1,%rbx
  4a2d6f:	mov    $0x8,%r8d
  4a2d75:	jmp    4a29ad <zstrtol_underscore+0x7d>
  4a2d7a:	movsbq (%rbx),%rdx
  4a2d7e:	jmp    4a29ad <zstrtol_underscore+0x7d>
  4a2d83:	mov    %rcx,%rbx
  4a2d86:	jmp    4a2a0f <zstrtol_underscore+0xdf>

Disassembly of section .fini:
