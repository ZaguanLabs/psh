
/usr/local/psh/releases/1.0.0-rc0-56f97a85e8cb/bin/psh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000440dc0 <hasher@@Base>:
  440dc0:	0f b6 17             	movzbl (%rdi),%edx
  440dc3:	85 d2                	test   %edx,%edx
  440dc5:	74 39                	je     440e00 <hasher@@Base+0x40>
  440dc7:	48 83 c7 01          	add    $0x1,%rdi
  440dcb:	31 c0                	xor    %eax,%eax
  440dcd:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  440dd4:	00 
  440dd5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  440ddc:	00 00 00 00 
  440de0:	89 c1                	mov    %eax,%ecx
  440de2:	48 83 c7 01          	add    $0x1,%rdi
  440de6:	c1 e1 05             	shl    $0x5,%ecx
  440de9:	01 c8                	add    %ecx,%eax
  440deb:	01 d0                	add    %edx,%eax
  440ded:	0f b6 57 ff          	movzbl -0x1(%rdi),%edx
  440df1:	85 d2                	test   %edx,%edx
  440df3:	75 eb                	jne    440de0 <hasher@@Base+0x20>
  440df5:	c3                   	ret
  440df6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  440dfd:	00 00 00 
  440e00:	31 c0                	xor    %eax,%eax
  440e02:	c3                   	ret

Disassembly of section .fini:
