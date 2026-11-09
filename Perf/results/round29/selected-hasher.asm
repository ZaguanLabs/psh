
.work/round29/candidate/Src/zsh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000440dc0 <hasher>:
  440dc0:	0f b6 07             	movzbl (%rdi),%eax
  440dc3:	85 c0                	test   %eax,%eax
  440dc5:	0f 84 ad 00 00 00    	je     440e78 <hasher+0xb8>
  440dcb:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
  440dcf:	85 d2                	test   %edx,%edx
  440dd1:	0f 84 a1 00 00 00    	je     440e78 <hasher+0xb8>
  440dd7:	0f b6 4f 02          	movzbl 0x2(%rdi),%ecx
  440ddb:	85 c9                	test   %ecx,%ecx
  440ddd:	0f 84 84 00 00 00    	je     440e67 <hasher+0xa7>
  440de3:	0f b6 77 03          	movzbl 0x3(%rdi),%esi
  440de7:	85 f6                	test   %esi,%esi
  440de9:	0f 84 91 00 00 00    	je     440e80 <hasher+0xc0>
  440def:	69 d2 41 04 00 00    	imul   $0x441,%edx,%edx
  440df5:	69 c0 61 8c 00 00    	imul   $0x8c61,%eax,%eax
  440dfb:	01 d0                	add    %edx,%eax
  440dfd:	89 ca                	mov    %ecx,%edx
  440dff:	c1 e2 05             	shl    $0x5,%edx
  440e02:	01 f0                	add    %esi,%eax
  440e04:	01 ca                	add    %ecx,%edx
  440e06:	01 d0                	add    %edx,%eax
  440e08:	0f b6 57 04          	movzbl 0x4(%rdi),%edx
  440e0c:	85 d2                	test   %edx,%edx
  440e0e:	74 68                	je     440e78 <hasher+0xb8>
  440e10:	48 83 c7 04          	add    $0x4,%rdi
  440e14:	eb 49                	jmp    440e5f <hasher+0x9f>
  440e16:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  440e1d:	00 00 00 
  440e20:	0f b6 77 02          	movzbl 0x2(%rdi),%esi
  440e24:	85 f6                	test   %esi,%esi
  440e26:	74 58                	je     440e80 <hasher+0xc0>
  440e28:	44 0f b6 47 03       	movzbl 0x3(%rdi),%r8d
  440e2d:	45 85 c0             	test   %r8d,%r8d
  440e30:	74 66                	je     440e98 <hasher+0xd8>
  440e32:	69 d2 61 8c 00 00    	imul   $0x8c61,%edx,%edx
  440e38:	48 83 c7 04          	add    $0x4,%rdi
  440e3c:	69 c0 81 18 12 00    	imul   $0x121881,%eax,%eax
  440e42:	69 c9 41 04 00 00    	imul   $0x441,%ecx,%ecx
  440e48:	01 d0                	add    %edx,%eax
  440e4a:	89 f2                	mov    %esi,%edx
  440e4c:	c1 e2 05             	shl    $0x5,%edx
  440e4f:	44 01 c0             	add    %r8d,%eax
  440e52:	01 f2                	add    %esi,%edx
  440e54:	01 d0                	add    %edx,%eax
  440e56:	0f b6 17             	movzbl (%rdi),%edx
  440e59:	01 c8                	add    %ecx,%eax
  440e5b:	85 d2                	test   %edx,%edx
  440e5d:	74 19                	je     440e78 <hasher+0xb8>
  440e5f:	0f b6 4f 01          	movzbl 0x1(%rdi),%ecx
  440e63:	85 c9                	test   %ecx,%ecx
  440e65:	75 b9                	jne    440e20 <hasher+0x60>
  440e67:	89 c1                	mov    %eax,%ecx
  440e69:	c1 e1 05             	shl    $0x5,%ecx
  440e6c:	01 c8                	add    %ecx,%eax
  440e6e:	01 d0                	add    %edx,%eax
  440e70:	c3                   	ret
  440e71:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  440e78:	c3                   	ret
  440e79:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  440e80:	89 c6                	mov    %eax,%esi
  440e82:	c1 e6 05             	shl    $0x5,%esi
  440e85:	01 c6                	add    %eax,%esi
  440e87:	01 f2                	add    %esi,%edx
  440e89:	89 d0                	mov    %edx,%eax
  440e8b:	c1 e0 05             	shl    $0x5,%eax
  440e8e:	01 d0                	add    %edx,%eax
  440e90:	01 c8                	add    %ecx,%eax
  440e92:	c3                   	ret
  440e93:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  440e98:	89 c7                	mov    %eax,%edi
  440e9a:	c1 e7 05             	shl    $0x5,%edi
  440e9d:	01 f8                	add    %edi,%eax
  440e9f:	01 d0                	add    %edx,%eax
  440ea1:	89 c2                	mov    %eax,%edx
  440ea3:	c1 e2 05             	shl    $0x5,%edx
  440ea6:	01 c2                	add    %eax,%edx
  440ea8:	01 ca                	add    %ecx,%edx
  440eaa:	89 d0                	mov    %edx,%eax
  440eac:	c1 e0 05             	shl    $0x5,%eax
  440eaf:	01 d0                	add    %edx,%eax
  440eb1:	01 f0                	add    %esi,%eax
  440eb3:	c3                   	ret

Disassembly of section .fini:
