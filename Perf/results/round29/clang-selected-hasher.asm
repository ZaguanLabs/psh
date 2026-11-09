
.work/round29/clang-candidate/Src/zsh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000043cd60 <hasher>:
  43cd60:	0f b6 07             	movzbl (%rdi),%eax
  43cd63:	85 c0                	test   %eax,%eax
  43cd65:	0f 84 a0 00 00 00    	je     43ce0b <hasher+0xab>
  43cd6b:	0f b6 4f 01          	movzbl 0x1(%rdi),%ecx
  43cd6f:	85 c9                	test   %ecx,%ecx
  43cd71:	0f 84 93 00 00 00    	je     43ce0a <hasher+0xaa>
  43cd77:	0f b6 57 02          	movzbl 0x2(%rdi),%edx
  43cd7b:	85 d2                	test   %edx,%edx
  43cd7d:	0f 84 8b 00 00 00    	je     43ce0e <hasher+0xae>
  43cd83:	0f b6 77 03          	movzbl 0x3(%rdi),%esi
  43cd87:	85 f6                	test   %esi,%esi
  43cd89:	0f 84 86 00 00 00    	je     43ce15 <hasher+0xb5>
  43cd8f:	69 c0 61 8c 00 00    	imul   $0x8c61,%eax,%eax
  43cd95:	69 c9 41 04 00 00    	imul   $0x441,%ecx,%ecx
  43cd9b:	01 c1                	add    %eax,%ecx
  43cd9d:	89 d0                	mov    %edx,%eax
  43cd9f:	c1 e0 05             	shl    $0x5,%eax
  43cda2:	01 d0                	add    %edx,%eax
  43cda4:	01 f0                	add    %esi,%eax
  43cda6:	01 c8                	add    %ecx,%eax
  43cda8:	0f b6 4f 04          	movzbl 0x4(%rdi),%ecx
  43cdac:	84 c9                	test   %cl,%cl
  43cdae:	74 5a                	je     43ce0a <hasher+0xaa>
  43cdb0:	48 83 c7 08          	add    $0x8,%rdi
  43cdb4:	66 66 66 2e 0f 1f 84 	data16 data16 cs nopw 0x0(%rax,%rax,1)
  43cdbb:	00 00 00 00 00 
  43cdc0:	0f b6 d1             	movzbl %cl,%edx
  43cdc3:	0f b6 4f fd          	movzbl -0x3(%rdi),%ecx
  43cdc7:	85 c9                	test   %ecx,%ecx
  43cdc9:	74 5d                	je     43ce28 <hasher+0xc8>
  43cdcb:	0f b6 77 fe          	movzbl -0x2(%rdi),%esi
  43cdcf:	85 f6                	test   %esi,%esi
  43cdd1:	74 61                	je     43ce34 <hasher+0xd4>
  43cdd3:	44 0f b6 47 ff       	movzbl -0x1(%rdi),%r8d
  43cdd8:	45 85 c0             	test   %r8d,%r8d
  43cddb:	74 67                	je     43ce44 <hasher+0xe4>
  43cddd:	69 c0 81 18 12 00    	imul   $0x121881,%eax,%eax
  43cde3:	69 d2 61 8c 00 00    	imul   $0x8c61,%edx,%edx
  43cde9:	01 c2                	add    %eax,%edx
  43cdeb:	69 c9 41 04 00 00    	imul   $0x441,%ecx,%ecx
  43cdf1:	89 f0                	mov    %esi,%eax
  43cdf3:	c1 e0 05             	shl    $0x5,%eax
  43cdf6:	01 f0                	add    %esi,%eax
  43cdf8:	01 d0                	add    %edx,%eax
  43cdfa:	01 c8                	add    %ecx,%eax
  43cdfc:	44 01 c0             	add    %r8d,%eax
  43cdff:	0f b6 0f             	movzbl (%rdi),%ecx
  43ce02:	48 83 c7 04          	add    $0x4,%rdi
  43ce06:	84 c9                	test   %cl,%cl
  43ce08:	75 b6                	jne    43cdc0 <hasher+0x60>
  43ce0a:	c3                   	ret
  43ce0b:	31 c0                	xor    %eax,%eax
  43ce0d:	c3                   	ret
  43ce0e:	01 c1                	add    %eax,%ecx
  43ce10:	c1 e0 05             	shl    $0x5,%eax
  43ce13:	eb 0e                	jmp    43ce23 <hasher+0xc3>
  43ce15:	01 c1                	add    %eax,%ecx
  43ce17:	c1 e0 05             	shl    $0x5,%eax
  43ce1a:	01 c1                	add    %eax,%ecx
  43ce1c:	89 c8                	mov    %ecx,%eax
  43ce1e:	c1 e0 05             	shl    $0x5,%eax
  43ce21:	01 d1                	add    %edx,%ecx
  43ce23:	01 c1                	add    %eax,%ecx
  43ce25:	89 c8                	mov    %ecx,%eax
  43ce27:	c3                   	ret
  43ce28:	89 c1                	mov    %eax,%ecx
  43ce2a:	c1 e1 05             	shl    $0x5,%ecx
  43ce2d:	01 c1                	add    %eax,%ecx
  43ce2f:	01 d1                	add    %edx,%ecx
  43ce31:	89 c8                	mov    %ecx,%eax
  43ce33:	c3                   	ret
  43ce34:	89 c6                	mov    %eax,%esi
  43ce36:	c1 e6 05             	shl    $0x5,%esi
  43ce39:	01 c6                	add    %eax,%esi
  43ce3b:	01 d6                	add    %edx,%esi
  43ce3d:	89 f0                	mov    %esi,%eax
  43ce3f:	c1 e0 05             	shl    $0x5,%eax
  43ce42:	eb 17                	jmp    43ce5b <hasher+0xfb>
  43ce44:	89 c7                	mov    %eax,%edi
  43ce46:	c1 e7 05             	shl    $0x5,%edi
  43ce49:	01 c7                	add    %eax,%edi
  43ce4b:	01 d7                	add    %edx,%edi
  43ce4d:	89 f8                	mov    %edi,%eax
  43ce4f:	c1 e0 05             	shl    $0x5,%eax
  43ce52:	01 f8                	add    %edi,%eax
  43ce54:	01 c8                	add    %ecx,%eax
  43ce56:	89 c1                	mov    %eax,%ecx
  43ce58:	c1 e1 05             	shl    $0x5,%ecx
  43ce5b:	01 f0                	add    %esi,%eax
  43ce5d:	01 c8                	add    %ecx,%eax
  43ce5f:	c3                   	ret

Disassembly of section .fini:
