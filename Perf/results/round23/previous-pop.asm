
.work/round23/previous/Src/zsh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000045e300 <pop>:
  45e300:	48 83 ec 18          	sub    $0x18,%rsp
  45e304:	48 63 0d 35 be 06 00 	movslq 0x6be35(%rip),%rcx        # 4ca140 <sp>
  45e30b:	48 89 c8             	mov    %rcx,%rax
  45e30e:	48 c1 e1 05          	shl    $0x5,%rcx
  45e312:	48 03 0d 37 94 07 00 	add    0x79437(%rip),%rcx        # 4d7750 <stack>
  45e319:	83 79 18 04          	cmpl   $0x4,0x18(%rcx)
  45e31d:	75 05                	jne    45e324 <pop+0x24>
  45e31f:	83 e7 01             	and    $0x1,%edi
  45e322:	74 3c                	je     45e360 <pop+0x60>
  45e324:	83 e8 01             	sub    $0x1,%eax
  45e327:	89 05 13 be 06 00    	mov    %eax,0x6be13(%rip)        # 4ca140 <sp>
  45e32d:	8b 05 2d 03 07 00    	mov    0x7032d(%rip),%eax        # 4ce660 <errflag>
  45e333:	85 c0                	test   %eax,%eax
  45e335:	75 11                	jne    45e348 <pop+0x48>
  45e337:	48 8b 41 10          	mov    0x10(%rcx),%rax
  45e33b:	48 8b 51 18          	mov    0x18(%rcx),%rdx
  45e33f:	48 83 c4 18          	add    $0x18,%rsp
  45e343:	c3                   	ret
  45e344:	0f 1f 40 00          	nopl   0x0(%rax)
  45e348:	48 8b 05 d1 93 07 00 	mov    0x793d1(%rip),%rax        # 4d7720 <zero_mnumber>
  45e34f:	48 8b 15 d2 93 07 00 	mov    0x793d2(%rip),%rdx        # 4d7728 <zero_mnumber+0x8>
  45e356:	48 83 c4 18          	add    $0x18,%rsp
  45e35a:	c3                   	ret
  45e35b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45e360:	48 89 cf             	mov    %rcx,%rdi
  45e363:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  45e368:	e8 93 fe ff ff       	call   45e200 <getmathparam>
  45e36d:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
  45e372:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45e376:	8b 05 c4 bd 06 00    	mov    0x6bdc4(%rip),%eax        # 4ca140 <sp>
  45e37c:	48 89 51 18          	mov    %rdx,0x18(%rcx)
  45e380:	eb a2                	jmp    45e324 <pop+0x24>

Disassembly of section .fini:
