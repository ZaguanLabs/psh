
.work/round29/candidate/Src/zsh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000440dc0 <hasher>:
  440dc0:	0f b6 17             	movzbl (%rdi),%edx
  440dc3:	31 c0                	xor    %eax,%eax
  440dc5:	85 d2                	test   %edx,%edx
  440dc7:	75 46                	jne    440e0f <hasher+0x4f>
  440dc9:	c3                   	ret
  440dca:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  440dd0:	0f b6 77 02          	movzbl 0x2(%rdi),%esi
  440dd4:	85 f6                	test   %esi,%esi
  440dd6:	74 50                	je     440e28 <hasher+0x68>
  440dd8:	44 0f b6 47 03       	movzbl 0x3(%rdi),%r8d
  440ddd:	45 85 c0             	test   %r8d,%r8d
  440de0:	74 5e                	je     440e40 <hasher+0x80>
  440de2:	69 d2 61 8c 00 00    	imul   $0x8c61,%edx,%edx
  440de8:	48 83 c7 04          	add    $0x4,%rdi
  440dec:	69 c0 81 18 12 00    	imul   $0x121881,%eax,%eax
  440df2:	69 c9 41 04 00 00    	imul   $0x441,%ecx,%ecx
  440df8:	01 d0                	add    %edx,%eax
  440dfa:	89 f2                	mov    %esi,%edx
  440dfc:	c1 e2 05             	shl    $0x5,%edx
  440dff:	44 01 c0             	add    %r8d,%eax
  440e02:	01 f2                	add    %esi,%edx
  440e04:	01 d0                	add    %edx,%eax
  440e06:	0f b6 17             	movzbl (%rdi),%edx
  440e09:	01 c8                	add    %ecx,%eax
  440e0b:	85 d2                	test   %edx,%edx
  440e0d:	74 51                	je     440e60 <hasher+0xa0>
  440e0f:	0f b6 4f 01          	movzbl 0x1(%rdi),%ecx
  440e13:	85 c9                	test   %ecx,%ecx
  440e15:	75 b9                	jne    440dd0 <hasher+0x10>
  440e17:	89 c1                	mov    %eax,%ecx
  440e19:	c1 e1 05             	shl    $0x5,%ecx
  440e1c:	01 c8                	add    %ecx,%eax
  440e1e:	01 d0                	add    %edx,%eax
  440e20:	c3                   	ret
  440e21:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  440e28:	89 c6                	mov    %eax,%esi
  440e2a:	c1 e6 05             	shl    $0x5,%esi
  440e2d:	01 c6                	add    %eax,%esi
  440e2f:	01 f2                	add    %esi,%edx
  440e31:	89 d0                	mov    %edx,%eax
  440e33:	c1 e0 05             	shl    $0x5,%eax
  440e36:	01 d0                	add    %edx,%eax
  440e38:	01 c8                	add    %ecx,%eax
  440e3a:	c3                   	ret
  440e3b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  440e40:	89 c7                	mov    %eax,%edi
  440e42:	c1 e7 05             	shl    $0x5,%edi
  440e45:	01 f8                	add    %edi,%eax
  440e47:	01 d0                	add    %edx,%eax
  440e49:	89 c2                	mov    %eax,%edx
  440e4b:	c1 e2 05             	shl    $0x5,%edx
  440e4e:	01 c2                	add    %eax,%edx
  440e50:	01 ca                	add    %ecx,%edx
  440e52:	89 d0                	mov    %edx,%eax
  440e54:	c1 e0 05             	shl    $0x5,%eax
  440e57:	01 d0                	add    %edx,%eax
  440e59:	01 f0                	add    %esi,%eax
  440e5b:	c3                   	ret
  440e5c:	0f 1f 40 00          	nopl   0x0(%rax)
  440e60:	c3                   	ret

Disassembly of section .fini:
