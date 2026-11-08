
.work/round23/previous/Src/zsh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000045e390 <op>:
  45e390:	8b 05 ca 02 07 00    	mov    0x702ca(%rip),%eax        # 4ce660 <errflag>
  45e396:	85 c0                	test   %eax,%eax
  45e398:	0f 85 82 01 00 00    	jne    45e520 <op+0x190>
  45e39e:	48 63 0d 9b bd 06 00 	movslq 0x6bd9b(%rip),%rcx        # 4ca140 <sp>
  45e3a5:	85 c9                	test   %ecx,%ecx
  45e3a7:	0f 88 7b 01 00 00    	js     45e528 <op+0x198>
  45e3ad:	41 57                	push   %r15
  45e3af:	48 63 c7             	movslq %edi,%rax
  45e3b2:	41 56                	push   %r14
  45e3b4:	48 89 c6             	mov    %rax,%rsi
  45e3b7:	41 55                	push   %r13
  45e3b9:	41 54                	push   %r12
  45e3bb:	55                   	push   %rbp
  45e3bc:	53                   	push   %rbx
  45e3bd:	48 83 ec 48          	sub    $0x48,%rsp
  45e3c1:	44 8b 14 85 c0 21 4b 	mov    0x4b21c0(,%rax,4),%r10d
  45e3c8:	00 
  45e3c9:	41 f6 c2 7c          	test   $0x7c,%r10b
  45e3cd:	75 31                	jne    45e400 <op+0x70>
  45e3cf:	48 c1 e1 05          	shl    $0x5,%rcx
  45e3d3:	48 03 0d 76 93 07 00 	add    0x79376(%rip),%rcx        # 4d7750 <stack>
  45e3da:	83 79 18 04          	cmpl   $0x4,0x18(%rcx)
  45e3de:	0f 84 54 01 00 00    	je     45e538 <op+0x1a8>
  45e3e4:	83 fe 2e             	cmp    $0x2e,%esi
  45e3e7:	0f 87 db 01 00 00    	ja     45e5c8 <op+0x238>
  45e3ed:	89 f6                	mov    %esi,%esi
  45e3ef:	ff 24 f5 b8 1c 4b 00 	jmp    *0x4b1cb8(,%rsi,8)
  45e3f6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  45e3fd:	00 00 00 
  45e400:	31 ff                	xor    %edi,%edi
  45e402:	4c 89 44 24 30       	mov    %r8,0x30(%rsp)
  45e407:	4c 89 4c 24 38       	mov    %r9,0x38(%rsp)
  45e40c:	44 89 54 24 20       	mov    %r10d,0x20(%rsp)
  45e411:	89 04 24             	mov    %eax,(%rsp)
  45e414:	e8 e7 fe ff ff       	call   45e300 <pop>
  45e419:	31 ff                	xor    %edi,%edi
  45e41b:	83 3c 24 1d          	cmpl   $0x1d,(%rsp)
  45e41f:	40 0f 94 c7          	sete   %dil
  45e423:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
  45e428:	49 89 d7             	mov    %rdx,%r15
  45e42b:	89 d3                	mov    %edx,%ebx
  45e42d:	e8 ce fe ff ff       	call   45e300 <pop>
  45e432:	49 89 c3             	mov    %rax,%r11
  45e435:	8b 05 25 02 07 00    	mov    0x70225(%rip),%eax        # 4ce660 <errflag>
  45e43b:	85 c0                	test   %eax,%eax
  45e43d:	0f 85 c4 00 00 00    	jne    45e507 <op+0x177>
  45e443:	44 8b 54 24 20       	mov    0x20(%rsp),%r10d
  45e448:	89 d7                	mov    %edx,%edi
  45e44a:	8b 34 24             	mov    (%rsp),%esi
  45e44d:	4c 89 d8             	mov    %r11,%rax
  45e450:	8b 15 da 92 07 00    	mov    0x792da(%rip),%edx        # 4d7730 <noeval>
  45e456:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
  45e45b:	41 f6 c2 50          	test   $0x50,%r10b
  45e45f:	4c 8b 44 24 30       	mov    0x30(%rsp),%r8
  45e464:	4c 8b 4c 24 38       	mov    0x38(%rsp),%r9
  45e469:	0f 84 01 01 00 00    	je     45e570 <op+0x1e0>
  45e46f:	40 f6 c7 02          	test   $0x2,%dil
  45e473:	74 0f                	je     45e484 <op+0xf4>
  45e475:	66 49 0f 6e db       	movq   %r11,%xmm3
  45e47a:	bf 01 00 00 00       	mov    $0x1,%edi
  45e47f:	f2 48 0f 2c c3       	cvttsd2si %xmm3,%rax
  45e484:	f6 c3 02             	test   $0x2,%bl
  45e487:	0f 85 73 01 00 00    	jne    45e600 <op+0x270>
  45e48d:	85 d2                	test   %edx,%edx
  45e48f:	0f 85 db 03 00 00    	jne    45e870 <op+0x4e0>
  45e495:	83 ee 08             	sub    $0x8,%esi
  45e498:	41 f6 c2 08          	test   $0x8,%r10b
  45e49c:	0f 85 46 01 00 00    	jne    45e5e8 <op+0x258>
  45e4a2:	83 fe 2b             	cmp    $0x2b,%esi
  45e4a5:	0f 87 cc 03 00 00    	ja     45e877 <op+0x4e7>
  45e4ab:	ff 24 f5 30 1e 4b 00 	jmp    *0x4b1e30(,%rsi,8)
  45e4b2:	48 63 05 87 bc 06 00 	movslq 0x6bc87(%rip),%rax        # 4ca140 <sp>
  45e4b9:	48 8b 51 10          	mov    0x10(%rcx),%rdx
  45e4bd:	48 c1 e0 05          	shl    $0x5,%rax
  45e4c1:	48 03 05 88 92 07 00 	add    0x79288(%rip),%rax        # 4d7750 <stack>
  45e4c8:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e4cc:	0f 84 3e 08 00 00    	je     45ed10 <op+0x980>
  45e4d2:	66 48 0f 6e fa       	movq   %rdx,%xmm7
  45e4d7:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45e4db:	31 d2                	xor    %edx,%edx
  45e4dd:	be 00 00 00 00       	mov    $0x0,%esi
  45e4e2:	66 0f 2e f8          	ucomisd %xmm0,%xmm7
  45e4e6:	c7 41 18 01 00 00 00 	movl   $0x1,0x18(%rcx)
  45e4ed:	0f 9b c2             	setnp  %dl
  45e4f0:	48 0f 45 d6          	cmovne %rsi,%rdx
  45e4f4:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45e4f8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  45e4ff:	00 
  45e500:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45e504:	0f 11 00             	movups %xmm0,(%rax)
  45e507:	48 83 c4 48          	add    $0x48,%rsp
  45e50b:	5b                   	pop    %rbx
  45e50c:	5d                   	pop    %rbp
  45e50d:	41 5c                	pop    %r12
  45e50f:	41 5d                	pop    %r13
  45e511:	41 5e                	pop    %r14
  45e513:	41 5f                	pop    %r15
  45e515:	c3                   	ret
  45e516:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  45e51d:	00 00 00 
  45e520:	c3                   	ret
  45e521:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  45e528:	bf 68 df 4a 00       	mov    $0x4adf68,%edi
  45e52d:	e9 7e 31 04 00       	jmp    4a16b0 <zerr>
  45e532:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  45e538:	48 89 cf             	mov    %rcx,%rdi
  45e53b:	48 89 0c 24          	mov    %rcx,(%rsp)
  45e53f:	89 44 24 10          	mov    %eax,0x10(%rsp)
  45e543:	e8 b8 fc ff ff       	call   45e200 <getmathparam>
  45e548:	48 8b 0c 24          	mov    (%rsp),%rcx
  45e54c:	8b 74 24 10          	mov    0x10(%rsp),%esi
  45e550:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45e554:	8b 05 06 01 07 00    	mov    0x70106(%rip),%eax        # 4ce660 <errflag>
  45e55a:	48 89 51 18          	mov    %rdx,0x18(%rcx)
  45e55e:	85 c0                	test   %eax,%eax
  45e560:	0f 84 7e fe ff ff    	je     45e3e4 <op+0x54>
  45e566:	eb 9f                	jmp    45e507 <op+0x177>
  45e568:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  45e56f:	00 
  45e570:	41 39 ff             	cmp    %edi,%r15d
  45e573:	0f 84 14 ff ff ff    	je     45e48d <op+0xfd>
  45e579:	83 fe 2b             	cmp    $0x2b,%esi
  45e57c:	0f 84 d6 07 00 00    	je     45ed58 <op+0x9c8>
  45e582:	83 ff 04             	cmp    $0x4,%edi
  45e585:	0f 84 5e 08 00 00    	je     45ede9 <op+0xa59>
  45e58b:	40 f6 c7 01          	test   $0x1,%dil
  45e58f:	74 13                	je     45e5a4 <op+0x214>
  45e591:	66 0f ef c9          	pxor   %xmm1,%xmm1
  45e595:	bf 02 00 00 00       	mov    $0x2,%edi
  45e59a:	f2 49 0f 2a cb       	cvtsi2sd %r11,%xmm1
  45e59f:	66 48 0f 7e c8       	movq   %xmm1,%rax
  45e5a4:	f6 c3 01             	test   $0x1,%bl
  45e5a7:	0f 84 e0 fe ff ff    	je     45e48d <op+0xfd>
  45e5ad:	66 0f ef ff          	pxor   %xmm7,%xmm7
  45e5b1:	bb 02 00 00 00       	mov    $0x2,%ebx
  45e5b6:	f2 48 0f 2a f9       	cvtsi2sd %rcx,%xmm7
  45e5bb:	66 48 0f 7e f9       	movq   %xmm7,%rcx
  45e5c0:	e9 c8 fe ff ff       	jmp    45e48d <op+0xfd>
  45e5c5:	0f 1f 00             	nopl   (%rax)
  45e5c8:	bf e0 df 4a 00       	mov    $0x4adfe0,%edi
  45e5cd:	48 83 c4 48          	add    $0x48,%rsp
  45e5d1:	31 c0                	xor    %eax,%eax
  45e5d3:	5b                   	pop    %rbx
  45e5d4:	5d                   	pop    %rbp
  45e5d5:	41 5c                	pop    %r12
  45e5d7:	41 5d                	pop    %r13
  45e5d9:	41 5e                	pop    %r14
  45e5db:	41 5f                	pop    %r15
  45e5dd:	e9 ce 30 04 00       	jmp    4a16b0 <zerr>
  45e5e2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  45e5e8:	83 fe 2b             	cmp    $0x2b,%esi
  45e5eb:	0f 87 52 03 00 00    	ja     45e943 <op+0x5b3>
  45e5f1:	ff 24 f5 90 1f 4b 00 	jmp    *0x4b1f90(,%rsi,8)
  45e5f8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  45e5ff:	00 
  45e600:	66 48 0f 6e e1       	movq   %rcx,%xmm4
  45e605:	bb 01 00 00 00       	mov    $0x1,%ebx
  45e60a:	f2 48 0f 2c cc       	cvttsd2si %xmm4,%rcx
  45e60f:	e9 79 fe ff ff       	jmp    45e48d <op+0xfd>
  45e614:	48 63 05 25 bb 06 00 	movslq 0x6bb25(%rip),%rax        # 4ca140 <sp>
  45e61b:	48 8b 51 10          	mov    0x10(%rcx),%rdx
  45e61f:	48 c1 e0 05          	shl    $0x5,%rax
  45e623:	48 03 05 26 91 07 00 	add    0x79126(%rip),%rax        # 4d7750 <stack>
  45e62a:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e62e:	0f 84 f4 06 00 00    	je     45ed28 <op+0x998>
  45e634:	66 48 0f 6e d2       	movq   %rdx,%xmm2
  45e639:	c7 41 18 01 00 00 00 	movl   $0x1,0x18(%rcx)
  45e640:	f2 48 0f 2c d2       	cvttsd2si %xmm2,%rdx
  45e645:	48 f7 d2             	not    %rdx
  45e648:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45e64c:	e9 af fe ff ff       	jmp    45e500 <op+0x170>
  45e651:	48 8b 79 10          	mov    0x10(%rcx),%rdi
  45e655:	48 8b 51 18          	mov    0x18(%rcx),%rdx
  45e659:	48 8d 77 01          	lea    0x1(%rdi),%rsi
  45e65d:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e661:	74 12                	je     45e675 <op+0x2e5>
  45e663:	66 48 0f 6e ef       	movq   %rdi,%xmm5
  45e668:	f2 0f 58 2d e0 23 05 	addsd  0x523e0(%rip),%xmm5        # 4b0a50 <execfuncs+0xdb0>
  45e66f:	00 
  45e670:	66 48 0f 7e ee       	movq   %xmm5,%rsi
  45e675:	48 63 3d c4 ba 06 00 	movslq 0x6bac4(%rip),%rdi        # 4ca140 <sp>
  45e67c:	48 c1 e7 05          	shl    $0x5,%rdi
  45e680:	48 03 3d c9 90 07 00 	add    0x790c9(%rip),%rdi        # 4d7750 <stack>
  45e687:	e8 14 ea ff ff       	call   45d0a0 <setmathvar>
  45e68c:	48 63 05 ad ba 06 00 	movslq 0x6baad(%rip),%rax        # 4ca140 <sp>
  45e693:	48 c1 e0 05          	shl    $0x5,%rax
  45e697:	48 03 05 b2 90 07 00 	add    0x790b2(%rip),%rax        # 4d7750 <stack>
  45e69e:	e9 5d fe ff ff       	jmp    45e500 <op+0x170>
  45e6a3:	48 8b 79 10          	mov    0x10(%rcx),%rdi
  45e6a7:	48 8b 51 18          	mov    0x18(%rcx),%rdx
  45e6ab:	48 8d 77 ff          	lea    -0x1(%rdi),%rsi
  45e6af:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e6b3:	74 c0                	je     45e675 <op+0x2e5>
  45e6b5:	66 48 0f 6e f7       	movq   %rdi,%xmm6
  45e6ba:	f2 0f 5c 35 8e 23 05 	subsd  0x5238e(%rip),%xmm6        # 4b0a50 <execfuncs+0xdb0>
  45e6c1:	00 
  45e6c2:	66 48 0f 7e f6       	movq   %xmm6,%rsi
  45e6c7:	eb ac                	jmp    45e675 <op+0x2e5>
  45e6c9:	48 63 05 70 ba 06 00 	movslq 0x6ba70(%rip),%rax        # 4ca140 <sp>
  45e6d0:	48 c1 e0 05          	shl    $0x5,%rax
  45e6d4:	48 03 05 75 90 07 00 	add    0x79075(%rip),%rax        # 4d7750 <stack>
  45e6db:	e9 20 fe ff ff       	jmp    45e500 <op+0x170>
  45e6e0:	48 63 05 59 ba 06 00 	movslq 0x6ba59(%rip),%rax        # 4ca140 <sp>
  45e6e7:	48 8b 51 10          	mov    0x10(%rcx),%rdx
  45e6eb:	48 c1 e0 05          	shl    $0x5,%rax
  45e6ef:	48 03 05 5a 90 07 00 	add    0x7905a(%rip),%rax        # 4d7750 <stack>
  45e6f6:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e6fa:	0f 84 38 06 00 00    	je     45ed38 <op+0x9a8>
  45e700:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  45e705:	66 0f 57 05 f3 0d 05 	xorpd  0x50df3(%rip),%xmm0        # 4af500 <tiedarr_gsu+0x70>
  45e70c:	00 
  45e70d:	f2 0f 11 41 10       	movsd  %xmm0,0x10(%rcx)
  45e712:	e9 e9 fd ff ff       	jmp    45e500 <op+0x170>
  45e717:	31 ff                	xor    %edi,%edi
  45e719:	e8 e2 fb ff ff       	call   45e300 <pop>
  45e71e:	31 ff                	xor    %edi,%edi
  45e720:	48 89 d5             	mov    %rdx,%rbp
  45e723:	49 89 c6             	mov    %rax,%r14
  45e726:	e8 d5 fb ff ff       	call   45e300 <pop>
  45e72b:	31 ff                	xor    %edi,%edi
  45e72d:	48 89 04 24          	mov    %rax,(%rsp)
  45e731:	49 89 d5             	mov    %rdx,%r13
  45e734:	89 d3                	mov    %edx,%ebx
  45e736:	e8 c5 fb ff ff       	call   45e300 <pop>
  45e73b:	48 89 d6             	mov    %rdx,%rsi
  45e73e:	8b 15 1c ff 06 00    	mov    0x6ff1c(%rip),%edx        # 4ce660 <errflag>
  45e744:	85 d2                	test   %edx,%edx
  45e746:	0f 85 bb fd ff ff    	jne    45e507 <op+0x177>
  45e74c:	83 e6 02             	and    $0x2,%esi
  45e74f:	48 8b 0c 24          	mov    (%rsp),%rcx
  45e753:	0f 84 7f 06 00 00    	je     45edd8 <op+0xa48>
  45e759:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45e75d:	66 48 0f 6e c8       	movq   %rax,%xmm1
  45e762:	66 0f 2e c8          	ucomisd %xmm0,%xmm1
  45e766:	0f 8a 75 06 00 00    	jp     45ede1 <op+0xa51>
  45e76c:	0f 85 6f 06 00 00    	jne    45ede1 <op+0xa51>
  45e772:	49 89 e9             	mov    %rbp,%r9
  45e775:	89 eb                	mov    %ebp,%ebx
  45e777:	4c 89 f1             	mov    %r14,%rcx
  45e77a:	4c 89 c8             	mov    %r9,%rax
  45e77d:	49 89 c8             	mov    %rcx,%r8
  45e780:	89 da                	mov    %ebx,%edx
  45e782:	48 b9 00 00 00 00 ff 	movabs $0xffffffff00000000,%rcx
  45e789:	ff ff ff 
  45e78c:	48 21 c8             	and    %rcx,%rax
  45e78f:	48 09 d0             	or     %rdx,%rax
  45e792:	49 89 c1             	mov    %rax,%r9
  45e795:	8b 05 a5 b9 06 00    	mov    0x6b9a5(%rip),%eax        # 4ca140 <sp>
  45e79b:	83 f8 63             	cmp    $0x63,%eax
  45e79e:	0f 84 62 06 00 00    	je     45ee06 <op+0xa76>
  45e7a4:	83 c0 01             	add    $0x1,%eax
  45e7a7:	89 05 93 b9 06 00    	mov    %eax,0x6b993(%rip)        # 4ca140 <sp>
  45e7ad:	48 98                	cltq
  45e7af:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45e7b3:	48 c1 e0 05          	shl    $0x5,%rax
  45e7b7:	48 03 05 92 8f 07 00 	add    0x78f92(%rip),%rax        # 4d7750 <stack>
  45e7be:	4c 89 40 10          	mov    %r8,0x10(%rax)
  45e7c2:	4c 89 48 18          	mov    %r9,0x18(%rax)
  45e7c6:	0f 11 00             	movups %xmm0,(%rax)
  45e7c9:	e9 32 fd ff ff       	jmp    45e500 <op+0x170>
  45e7ce:	31 c0                	xor    %eax,%eax
  45e7d0:	bf b8 df 4a 00       	mov    $0x4adfb8,%edi
  45e7d5:	e8 d6 2e 04 00       	call   4a16b0 <zerr>
  45e7da:	48 63 05 5f b9 06 00 	movslq 0x6b95f(%rip),%rax        # 4ca140 <sp>
  45e7e1:	48 c1 e0 05          	shl    $0x5,%rax
  45e7e5:	48 03 05 64 8f 07 00 	add    0x78f64(%rip),%rax        # 4d7750 <stack>
  45e7ec:	e9 0f fd ff ff       	jmp    45e500 <op+0x170>
  45e7f1:	48 8b 41 10          	mov    0x10(%rcx),%rax
  45e7f5:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e7f9:	0f 84 01 05 00 00    	je     45ed00 <op+0x970>
  45e7ff:	66 48 0f 6e c0       	movq   %rax,%xmm0
  45e804:	f2 0f 58 05 44 22 05 	addsd  0x52244(%rip),%xmm0        # 4b0a50 <execfuncs+0xdb0>
  45e80b:	00 
  45e80c:	f2 0f 11 41 10       	movsd  %xmm0,0x10(%rcx)
  45e811:	48 63 3d 28 b9 06 00 	movslq 0x6b928(%rip),%rdi        # 4ca140 <sp>
  45e818:	48 8b 71 10          	mov    0x10(%rcx),%rsi
  45e81c:	48 8b 51 18          	mov    0x18(%rcx),%rdx
  45e820:	48 c1 e7 05          	shl    $0x5,%rdi
  45e824:	48 03 3d 25 8f 07 00 	add    0x78f25(%rip),%rdi        # 4d7750 <stack>
  45e82b:	e8 70 e8 ff ff       	call   45d0a0 <setmathvar>
  45e830:	48 63 05 09 b9 06 00 	movslq 0x6b909(%rip),%rax        # 4ca140 <sp>
  45e837:	48 c1 e0 05          	shl    $0x5,%rax
  45e83b:	48 03 05 0e 8f 07 00 	add    0x78f0e(%rip),%rax        # 4d7750 <stack>
  45e842:	e9 b9 fc ff ff       	jmp    45e500 <op+0x170>
  45e847:	48 8b 41 10          	mov    0x10(%rcx),%rax
  45e84b:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e84f:	0f 84 f3 04 00 00    	je     45ed48 <op+0x9b8>
  45e855:	66 48 0f 6e c0       	movq   %rax,%xmm0
  45e85a:	f2 0f 5c 05 ee 21 05 	subsd  0x521ee(%rip),%xmm0        # 4b0a50 <execfuncs+0xdb0>
  45e861:	00 
  45e862:	f2 0f 11 41 10       	movsd  %xmm0,0x10(%rcx)
  45e867:	eb a8                	jmp    45e811 <op+0x481>
  45e869:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  45e870:	bf 01 00 00 00       	mov    $0x1,%edi
  45e875:	31 c9                	xor    %ecx,%ecx
  45e877:	41 83 e2 60          	and    $0x60,%r10d
  45e87b:	0f 84 6f 03 00 00    	je     45ebf0 <op+0x860>
  45e881:	48 63 05 b8 b8 06 00 	movslq 0x6b8b8(%rip),%rax        # 4ca140 <sp>
  45e888:	48 89 ce             	mov    %rcx,%rsi
  45e88b:	48 ba 00 00 00 00 ff 	movabs $0xffffffff00000000,%rdx
  45e892:	ff ff ff 
  45e895:	48 83 c0 01          	add    $0x1,%rax
  45e899:	48 c1 e0 05          	shl    $0x5,%rax
  45e89d:	48 03 05 ac 8e 07 00 	add    0x78eac(%rip),%rax        # 4d7750 <stack>
  45e8a4:	49 89 c2             	mov    %rax,%r10
  45e8a7:	89 f8                	mov    %edi,%eax
  45e8a9:	4c 89 cf             	mov    %r9,%rdi
  45e8ac:	48 21 d7             	and    %rdx,%rdi
  45e8af:	4c 89 14 24          	mov    %r10,(%rsp)
  45e8b3:	48 09 c7             	or     %rax,%rdi
  45e8b6:	48 89 fa             	mov    %rdi,%rdx
  45e8b9:	4c 89 d7             	mov    %r10,%rdi
  45e8bc:	e8 df e7 ff ff       	call   45d0a0 <setmathvar>
  45e8c1:	4c 8b 14 24          	mov    (%rsp),%r10
  45e8c5:	48 89 d1             	mov    %rdx,%rcx
  45e8c8:	48 89 c2             	mov    %rax,%rdx
  45e8cb:	8b 05 6f b8 06 00    	mov    0x6b86f(%rip),%eax        # 4ca140 <sp>
  45e8d1:	49 8b 32             	mov    (%r10),%rsi
  45e8d4:	83 f8 63             	cmp    $0x63,%eax
  45e8d7:	0f 84 93 04 00 00    	je     45ed70 <op+0x9e0>
  45e8dd:	83 c0 01             	add    $0x1,%eax
  45e8e0:	89 05 5a b8 06 00    	mov    %eax,0x6b85a(%rip)        # 4ca140 <sp>
  45e8e6:	48 98                	cltq
  45e8e8:	48 c1 e0 05          	shl    $0x5,%rax
  45e8ec:	48 03 05 5d 8e 07 00 	add    0x78e5d(%rip),%rax        # 4d7750 <stack>
  45e8f3:	48 89 50 10          	mov    %rdx,0x10(%rax)
  45e8f7:	48 89 48 18          	mov    %rcx,0x18(%rax)
  45e8fb:	48 89 30             	mov    %rsi,(%rax)
  45e8fe:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
  45e905:	00 
  45e906:	e9 fc fb ff ff       	jmp    45e507 <op+0x177>
  45e90b:	48 85 c9             	test   %rcx,%rcx
  45e90e:	0f 88 f0 05 00 00    	js     45ef04 <op+0xb74>
  45e914:	0f 84 1d 06 00 00    	je     45ef37 <op+0xba7>
  45e91a:	48 8d 51 ff          	lea    -0x1(%rcx),%rdx
  45e91e:	b9 01 00 00 00       	mov    $0x1,%ecx
  45e923:	f6 c2 01             	test   $0x1,%dl
  45e926:	75 09                	jne    45e931 <op+0x5a1>
  45e928:	48 89 c1             	mov    %rax,%rcx
  45e92b:	48 83 ea 01          	sub    $0x1,%rdx
  45e92f:	72 12                	jb     45e943 <op+0x5b3>
  45e931:	48 0f af c8          	imul   %rax,%rcx
  45e935:	48 83 ea 02          	sub    $0x2,%rdx
  45e939:	48 0f af c8          	imul   %rax,%rcx
  45e93d:	48 83 fa ff          	cmp    $0xffffffffffffffff,%rdx
  45e941:	75 ee                	jne    45e931 <op+0x5a1>
  45e943:	bf 01 00 00 00       	mov    $0x1,%edi
  45e948:	e9 2a ff ff ff       	jmp    45e877 <op+0x4e7>
  45e94d:	0f 1f 00             	nopl   (%rax)
  45e950:	4d 89 f8             	mov    %r15,%r8
  45e953:	89 d8                	mov    %ebx,%eax
  45e955:	89 df                	mov    %ebx,%edi
  45e957:	48 ba 00 00 00 00 ff 	movabs $0xffffffff00000000,%rdx
  45e95e:	ff ff ff 
  45e961:	49 21 d0             	and    %rdx,%r8
  45e964:	49 09 c0             	or     %rax,%r8
  45e967:	4d 89 c1             	mov    %r8,%r9
  45e96a:	e9 08 ff ff ff       	jmp    45e877 <op+0x4e7>
  45e96f:	bf 01 00 00 00       	mov    $0x1,%edi
  45e974:	48 85 c0             	test   %rax,%rax
  45e977:	0f 95 c0             	setne  %al
  45e97a:	48 85 c9             	test   %rcx,%rcx
  45e97d:	0f 95 c1             	setne  %cl
  45e980:	0f b6 c9             	movzbl %cl,%ecx
  45e983:	48 21 c1             	and    %rax,%rcx
  45e986:	e9 ec fe ff ff       	jmp    45e877 <op+0x4e7>
  45e98b:	bf 01 00 00 00       	mov    $0x1,%edi
  45e990:	48 09 c1             	or     %rax,%rcx
  45e993:	e9 df fe ff ff       	jmp    45e877 <op+0x4e7>
  45e998:	bf 01 00 00 00       	mov    $0x1,%edi
  45e99d:	48 31 c1             	xor    %rax,%rcx
  45e9a0:	e9 d2 fe ff ff       	jmp    45e877 <op+0x4e7>
  45e9a5:	bf 01 00 00 00       	mov    $0x1,%edi
  45e9aa:	48 d3 f8             	sar    %cl,%rax
  45e9ad:	48 89 c1             	mov    %rax,%rcx
  45e9b0:	e9 c2 fe ff ff       	jmp    45e877 <op+0x4e7>
  45e9b5:	bf 01 00 00 00       	mov    $0x1,%edi
  45e9ba:	48 d3 e0             	shl    %cl,%rax
  45e9bd:	48 89 c1             	mov    %rax,%rcx
  45e9c0:	e9 b2 fe ff ff       	jmp    45e877 <op+0x4e7>
  45e9c5:	bf 01 00 00 00       	mov    $0x1,%edi
  45e9ca:	48 85 c0             	test   %rax,%rax
  45e9cd:	0f 95 c0             	setne  %al
  45e9d0:	48 85 c9             	test   %rcx,%rcx
  45e9d3:	0f 95 c2             	setne  %dl
  45e9d6:	31 d0                	xor    %edx,%eax
  45e9d8:	0f b6 c8             	movzbl %al,%ecx
  45e9db:	e9 97 fe ff ff       	jmp    45e877 <op+0x4e7>
  45e9e0:	bf 01 00 00 00       	mov    $0x1,%edi
  45e9e5:	48 09 c8             	or     %rcx,%rax
  45e9e8:	0f 95 c1             	setne  %cl
  45e9eb:	0f b6 c9             	movzbl %cl,%ecx
  45e9ee:	e9 84 fe ff ff       	jmp    45e877 <op+0x4e7>
  45e9f3:	83 ff 01             	cmp    $0x1,%edi
  45e9f6:	0f 84 0f ff ff ff    	je     45e90b <op+0x57b>
  45e9fc:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  45ea01:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45ea05:	66 0f 2f c1          	comisd %xmm1,%xmm0
  45ea09:	0f 83 ce 04 00 00    	jae    45eedd <op+0xb4d>
  45ea0f:	66 48 0f 6e c0       	movq   %rax,%xmm0
  45ea14:	66 0f ef d2          	pxor   %xmm2,%xmm2
  45ea18:	66 0f 2f d0          	comisd %xmm0,%xmm2
  45ea1c:	76 1e                	jbe    45ea3c <op+0x6ac>
  45ea1e:	f2 48 0f 2c c1       	cvttsd2si %xmm1,%rax
  45ea23:	66 0f ef d2          	pxor   %xmm2,%xmm2
  45ea27:	f2 48 0f 2a d0       	cvtsi2sd %rax,%xmm2
  45ea2c:	66 0f 2e d1          	ucomisd %xmm1,%xmm2
  45ea30:	0f 8a c4 04 00 00    	jp     45eefa <op+0xb6a>
  45ea36:	0f 85 be 04 00 00    	jne    45eefa <op+0xb6a>
  45ea3c:	4c 89 4c 24 28       	mov    %r9,0x28(%rsp)
  45ea41:	89 7c 24 10          	mov    %edi,0x10(%rsp)
  45ea45:	44 89 14 24          	mov    %r10d,(%rsp)
  45ea49:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
  45ea4e:	e8 6d 11 fb ff       	call   40fbc0 <pow@plt>
  45ea53:	44 8b 14 24          	mov    (%rsp),%r10d
  45ea57:	8b 7c 24 10          	mov    0x10(%rsp),%edi
  45ea5b:	4c 8b 4c 24 28       	mov    0x28(%rsp),%r9
  45ea60:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  45ea65:	e9 0d fe ff ff       	jmp    45e877 <op+0x4e7>
  45ea6a:	83 ff 02             	cmp    $0x2,%edi
  45ea6d:	0f 85 e3 00 00 00    	jne    45eb56 <op+0x7c6>
  45ea73:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  45ea78:	66 48 0f 6e d0       	movq   %rax,%xmm2
  45ea7d:	f2 0f 5c d6          	subsd  %xmm6,%xmm2
  45ea81:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  45ea86:	e9 ec fd ff ff       	jmp    45e877 <op+0x4e7>
  45ea8b:	83 ff 02             	cmp    $0x2,%edi
  45ea8e:	0f 85 d2 00 00 00    	jne    45eb66 <op+0x7d6>
  45ea94:	66 48 0f 6e e9       	movq   %rcx,%xmm5
  45ea99:	66 48 0f 6e d0       	movq   %rax,%xmm2
  45ea9e:	f2 0f 58 d5          	addsd  %xmm5,%xmm2
  45eaa2:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  45eaa7:	e9 cb fd ff ff       	jmp    45e877 <op+0x4e7>
  45eaac:	48 85 c9             	test   %rcx,%rcx
  45eaaf:	75 09                	jne    45eaba <op+0x72a>
  45eab1:	83 e3 01             	and    $0x1,%ebx
  45eab4:	0f 85 36 04 00 00    	jne    45eef0 <op+0xb60>
  45eaba:	83 ff 02             	cmp    $0x2,%edi
  45eabd:	0f 85 cc 00 00 00    	jne    45eb8f <op+0x7ff>
  45eac3:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  45eac8:	66 48 0f 6e d0       	movq   %rax,%xmm2
  45eacd:	f2 0f 5e d6          	divsd  %xmm6,%xmm2
  45ead1:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  45ead6:	e9 9c fd ff ff       	jmp    45e877 <op+0x4e7>
  45eadb:	48 85 c9             	test   %rcx,%rcx
  45eade:	75 09                	jne    45eae9 <op+0x759>
  45eae0:	83 e3 01             	and    $0x1,%ebx
  45eae3:	0f 85 07 04 00 00    	jne    45eef0 <op+0xb60>
  45eae9:	83 ff 02             	cmp    $0x2,%edi
  45eaec:	0f 85 c7 00 00 00    	jne    45ebb9 <op+0x829>
  45eaf2:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  45eaf7:	66 48 0f 6e c0       	movq   %rax,%xmm0
  45eafc:	4c 89 4c 24 28       	mov    %r9,0x28(%rsp)
  45eb01:	89 7c 24 10          	mov    %edi,0x10(%rsp)
  45eb05:	44 89 14 24          	mov    %r10d,(%rsp)
  45eb09:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
  45eb0e:	e8 fd 0e fb ff       	call   40fa10 <fmod@plt>
  45eb13:	44 8b 14 24          	mov    (%rsp),%r10d
  45eb17:	8b 7c 24 10          	mov    0x10(%rsp),%edi
  45eb1b:	4c 8b 4c 24 28       	mov    0x28(%rsp),%r9
  45eb20:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  45eb25:	e9 4d fd ff ff       	jmp    45e877 <op+0x4e7>
  45eb2a:	83 ff 02             	cmp    $0x2,%edi
  45eb2d:	75 44                	jne    45eb73 <op+0x7e3>
  45eb2f:	66 48 0f 6e e9       	movq   %rcx,%xmm5
  45eb34:	66 48 0f 6e d0       	movq   %rax,%xmm2
  45eb39:	f2 0f 59 d5          	mulsd  %xmm5,%xmm2
  45eb3d:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  45eb42:	e9 30 fd ff ff       	jmp    45e877 <op+0x4e7>
  45eb47:	bf 01 00 00 00       	mov    $0x1,%edi
  45eb4c:	e9 32 fe ff ff       	jmp    45e983 <op+0x5f3>
  45eb51:	bf 01 00 00 00       	mov    $0x1,%edi
  45eb56:	48 29 c8             	sub    %rcx,%rax
  45eb59:	48 89 c1             	mov    %rax,%rcx
  45eb5c:	e9 16 fd ff ff       	jmp    45e877 <op+0x4e7>
  45eb61:	bf 01 00 00 00       	mov    $0x1,%edi
  45eb66:	48 01 c1             	add    %rax,%rcx
  45eb69:	e9 09 fd ff ff       	jmp    45e877 <op+0x4e7>
  45eb6e:	bf 01 00 00 00       	mov    $0x1,%edi
  45eb73:	48 0f af c8          	imul   %rax,%rcx
  45eb77:	e9 fb fc ff ff       	jmp    45e877 <op+0x4e7>
  45eb7c:	48 85 c9             	test   %rcx,%rcx
  45eb7f:	75 09                	jne    45eb8a <op+0x7fa>
  45eb81:	80 e3 01             	and    $0x1,%bl
  45eb84:	0f 85 66 03 00 00    	jne    45eef0 <op+0xb60>
  45eb8a:	bf 01 00 00 00       	mov    $0x1,%edi
  45eb8f:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
  45eb93:	0f 84 93 03 00 00    	je     45ef2c <op+0xb9c>
  45eb99:	48 99                	cqto
  45eb9b:	48 f7 f9             	idiv   %rcx
  45eb9e:	48 89 c1             	mov    %rax,%rcx
  45eba1:	e9 d1 fc ff ff       	jmp    45e877 <op+0x4e7>
  45eba6:	48 85 c9             	test   %rcx,%rcx
  45eba9:	75 09                	jne    45ebb4 <op+0x824>
  45ebab:	80 e3 01             	and    $0x1,%bl
  45ebae:	0f 85 3c 03 00 00    	jne    45eef0 <op+0xb60>
  45ebb4:	bf 01 00 00 00       	mov    $0x1,%edi
  45ebb9:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
  45ebbd:	0f 84 62 03 00 00    	je     45ef25 <op+0xb95>
  45ebc3:	48 99                	cqto
  45ebc5:	48 f7 f9             	idiv   %rcx
  45ebc8:	48 89 d1             	mov    %rdx,%rcx
  45ebcb:	e9 a7 fc ff ff       	jmp    45e877 <op+0x4e7>
  45ebd0:	89 fa                	mov    %edi,%edx
  45ebd2:	83 ff 02             	cmp    $0x2,%edi
  45ebd5:	0f 84 df 02 00 00    	je     45eeba <op+0xb2a>
  45ebdb:	48 39 c8             	cmp    %rcx,%rax
  45ebde:	89 d7                	mov    %edx,%edi
  45ebe0:	0f 94 c1             	sete   %cl
  45ebe3:	0f b6 c9             	movzbl %cl,%ecx
  45ebe6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  45ebed:	00 00 00 
  45ebf0:	48 ba 00 00 00 00 ff 	movabs $0xffffffff00000000,%rdx
  45ebf7:	ff ff ff 
  45ebfa:	89 f8                	mov    %edi,%eax
  45ebfc:	4c 89 cf             	mov    %r9,%rdi
  45ebff:	49 89 c8             	mov    %rcx,%r8
  45ec02:	48 21 d7             	and    %rdx,%rdi
  45ec05:	48 09 c7             	or     %rax,%rdi
  45ec08:	8b 05 32 b5 06 00    	mov    0x6b532(%rip),%eax        # 4ca140 <sp>
  45ec0e:	49 89 f9             	mov    %rdi,%r9
  45ec11:	83 f8 63             	cmp    $0x63,%eax
  45ec14:	0f 84 8e 01 00 00    	je     45eda8 <op+0xa18>
  45ec1a:	83 c0 01             	add    $0x1,%eax
  45ec1d:	89 05 1d b5 06 00    	mov    %eax,0x6b51d(%rip)        # 4ca140 <sp>
  45ec23:	48 98                	cltq
  45ec25:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45ec29:	48 c1 e0 05          	shl    $0x5,%rax
  45ec2d:	48 03 05 1c 8b 07 00 	add    0x78b1c(%rip),%rax        # 4d7750 <stack>
  45ec34:	4c 89 40 10          	mov    %r8,0x10(%rax)
  45ec38:	4c 89 48 18          	mov    %r9,0x18(%rax)
  45ec3c:	0f 11 00             	movups %xmm0,(%rax)
  45ec3f:	e9 c3 f8 ff ff       	jmp    45e507 <op+0x177>
  45ec44:	89 fa                	mov    %edi,%edx
  45ec46:	83 ff 02             	cmp    $0x2,%edi
  45ec49:	0f 84 e0 01 00 00    	je     45ee2f <op+0xa9f>
  45ec4f:	48 39 c8             	cmp    %rcx,%rax
  45ec52:	89 d7                	mov    %edx,%edi
  45ec54:	0f 9d c1             	setge  %cl
  45ec57:	0f b6 c9             	movzbl %cl,%ecx
  45ec5a:	eb 94                	jmp    45ebf0 <op+0x860>
  45ec5c:	89 fa                	mov    %edi,%edx
  45ec5e:	83 ff 02             	cmp    $0x2,%edi
  45ec61:	0f 84 39 02 00 00    	je     45eea0 <op+0xb10>
  45ec67:	48 39 c8             	cmp    %rcx,%rax
  45ec6a:	89 d7                	mov    %edx,%edi
  45ec6c:	0f 9f c1             	setg   %cl
  45ec6f:	0f b6 c9             	movzbl %cl,%ecx
  45ec72:	e9 79 ff ff ff       	jmp    45ebf0 <op+0x860>
  45ec77:	89 fa                	mov    %edi,%edx
  45ec79:	83 ff 02             	cmp    $0x2,%edi
  45ec7c:	0f 84 c7 01 00 00    	je     45ee49 <op+0xab9>
  45ec82:	48 39 c8             	cmp    %rcx,%rax
  45ec85:	89 d7                	mov    %edx,%edi
  45ec87:	0f 95 c1             	setne  %cl
  45ec8a:	0f b6 c9             	movzbl %cl,%ecx
  45ec8d:	e9 5e ff ff ff       	jmp    45ebf0 <op+0x860>
  45ec92:	89 fa                	mov    %edi,%edx
  45ec94:	83 ff 02             	cmp    $0x2,%edi
  45ec97:	0f 84 e9 01 00 00    	je     45ee86 <op+0xaf6>
  45ec9d:	48 39 c8             	cmp    %rcx,%rax
  45eca0:	89 d7                	mov    %edx,%edi
  45eca2:	0f 9e c1             	setle  %cl
  45eca5:	0f b6 c9             	movzbl %cl,%ecx
  45eca8:	e9 43 ff ff ff       	jmp    45ebf0 <op+0x860>
  45ecad:	89 fa                	mov    %edi,%edx
  45ecaf:	83 ff 02             	cmp    $0x2,%edi
  45ecb2:	0f 84 b4 01 00 00    	je     45ee6c <op+0xadc>
  45ecb8:	48 39 c8             	cmp    %rcx,%rax
  45ecbb:	89 d7                	mov    %edx,%edi
  45ecbd:	0f 9c c1             	setl   %cl
  45ecc0:	0f b6 c9             	movzbl %cl,%ecx
  45ecc3:	e9 28 ff ff ff       	jmp    45ebf0 <op+0x860>
  45ecc8:	ba 01 00 00 00       	mov    $0x1,%edx
  45eccd:	e9 00 ff ff ff       	jmp    45ebd2 <op+0x842>
  45ecd2:	ba 01 00 00 00       	mov    $0x1,%edx
  45ecd7:	eb a0                	jmp    45ec79 <op+0x8e9>
  45ecd9:	ba 01 00 00 00       	mov    $0x1,%edx
  45ecde:	eb cf                	jmp    45ecaf <op+0x91f>
  45ece0:	ba 01 00 00 00       	mov    $0x1,%edx
  45ece5:	e9 74 ff ff ff       	jmp    45ec5e <op+0x8ce>
  45ecea:	ba 01 00 00 00       	mov    $0x1,%edx
  45ecef:	eb a3                	jmp    45ec94 <op+0x904>
  45ecf1:	ba 01 00 00 00       	mov    $0x1,%edx
  45ecf6:	e9 4b ff ff ff       	jmp    45ec46 <op+0x8b6>
  45ecfb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45ed00:	48 83 c0 01          	add    $0x1,%rax
  45ed04:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45ed08:	e9 04 fb ff ff       	jmp    45e811 <op+0x481>
  45ed0d:	0f 1f 00             	nopl   (%rax)
  45ed10:	48 85 d2             	test   %rdx,%rdx
  45ed13:	0f 94 c2             	sete   %dl
  45ed16:	0f b6 d2             	movzbl %dl,%edx
  45ed19:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45ed1d:	e9 de f7 ff ff       	jmp    45e500 <op+0x170>
  45ed22:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  45ed28:	48 f7 d2             	not    %rdx
  45ed2b:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45ed2f:	e9 cc f7 ff ff       	jmp    45e500 <op+0x170>
  45ed34:	0f 1f 40 00          	nopl   0x0(%rax)
  45ed38:	48 f7 da             	neg    %rdx
  45ed3b:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45ed3f:	e9 bc f7 ff ff       	jmp    45e500 <op+0x170>
  45ed44:	0f 1f 40 00          	nopl   0x0(%rax)
  45ed48:	48 83 e8 01          	sub    $0x1,%rax
  45ed4c:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45ed50:	e9 bc fa ff ff       	jmp    45e811 <op+0x481>
  45ed55:	0f 1f 00             	nopl   (%rax)
  45ed58:	85 d2                	test   %edx,%edx
  45ed5a:	0f 84 f0 fb ff ff    	je     45e950 <op+0x5c0>
  45ed60:	bf 01 00 00 00       	mov    $0x1,%edi
  45ed65:	31 c9                	xor    %ecx,%ecx
  45ed67:	e9 84 fe ff ff       	jmp    45ebf0 <op+0x860>
  45ed6c:	0f 1f 40 00          	nopl   0x0(%rax)
  45ed70:	31 c0                	xor    %eax,%eax
  45ed72:	bf fc ad 4a 00       	mov    $0x4aadfc,%edi
  45ed77:	48 89 54 24 10       	mov    %rdx,0x10(%rsp)
  45ed7c:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
  45ed81:	48 89 34 24          	mov    %rsi,(%rsp)
  45ed85:	e8 26 29 04 00       	call   4a16b0 <zerr>
  45ed8a:	8b 05 b0 b3 06 00    	mov    0x6b3b0(%rip),%eax        # 4ca140 <sp>
  45ed90:	48 8b 34 24          	mov    (%rsp),%rsi
  45ed94:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
  45ed99:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
  45ed9e:	e9 43 fb ff ff       	jmp    45e8e6 <op+0x556>
  45eda3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45eda8:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
  45edad:	31 c0                	xor    %eax,%eax
  45edaf:	bf fc ad 4a 00       	mov    $0x4aadfc,%edi
  45edb4:	48 89 0c 24          	mov    %rcx,(%rsp)
  45edb8:	e8 f3 28 04 00       	call   4a16b0 <zerr>
  45edbd:	8b 05 7d b3 06 00    	mov    0x6b37d(%rip),%eax        # 4ca140 <sp>
  45edc3:	4c 8b 04 24          	mov    (%rsp),%r8
  45edc7:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
  45edcc:	e9 52 fe ff ff       	jmp    45ec23 <op+0x893>
  45edd1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  45edd8:	48 85 c0             	test   %rax,%rax
  45eddb:	0f 84 91 f9 ff ff    	je     45e772 <op+0x3e2>
  45ede1:	4d 89 e9             	mov    %r13,%r9
  45ede4:	e9 91 f9 ff ff       	jmp    45e77a <op+0x3ea>
  45ede9:	83 fe 1d             	cmp    $0x1d,%esi
  45edec:	0f 85 b2 f7 ff ff    	jne    45e5a4 <op+0x214>
  45edf2:	85 d2                	test   %edx,%edx
  45edf4:	0f 84 56 fb ff ff    	je     45e950 <op+0x5c0>
  45edfa:	bf 01 00 00 00       	mov    $0x1,%edi
  45edff:	31 c9                	xor    %ecx,%ecx
  45ee01:	e9 7b fa ff ff       	jmp    45e881 <op+0x4f1>
  45ee06:	31 c0                	xor    %eax,%eax
  45ee08:	bf fc ad 4a 00       	mov    $0x4aadfc,%edi
  45ee0d:	4c 89 04 24          	mov    %r8,(%rsp)
  45ee11:	4c 89 4c 24 08       	mov    %r9,0x8(%rsp)
  45ee16:	e8 95 28 04 00       	call   4a16b0 <zerr>
  45ee1b:	8b 05 1f b3 06 00    	mov    0x6b31f(%rip),%eax        # 4ca140 <sp>
  45ee21:	4c 8b 04 24          	mov    (%rsp),%r8
  45ee25:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
  45ee2a:	e9 7e f9 ff ff       	jmp    45e7ad <op+0x41d>
  45ee2f:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  45ee34:	66 48 0f 6e c8       	movq   %rax,%xmm1
  45ee39:	31 c9                	xor    %ecx,%ecx
  45ee3b:	89 d7                	mov    %edx,%edi
  45ee3d:	66 0f 2f ca          	comisd %xmm2,%xmm1
  45ee41:	0f 93 c1             	setae  %cl
  45ee44:	e9 a7 fd ff ff       	jmp    45ebf0 <op+0x860>
  45ee49:	66 48 0f 6e f0       	movq   %rax,%xmm6
  45ee4e:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  45ee53:	31 c9                	xor    %ecx,%ecx
  45ee55:	b8 01 00 00 00       	mov    $0x1,%eax
  45ee5a:	66 0f 2e f1          	ucomisd %xmm1,%xmm6
  45ee5e:	89 d7                	mov    %edx,%edi
  45ee60:	0f 9a c1             	setp   %cl
  45ee63:	48 0f 45 c8          	cmovne %rax,%rcx
  45ee67:	e9 84 fd ff ff       	jmp    45ebf0 <op+0x860>
  45ee6c:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  45ee71:	66 48 0f 6e e8       	movq   %rax,%xmm5
  45ee76:	31 c9                	xor    %ecx,%ecx
  45ee78:	89 d7                	mov    %edx,%edi
  45ee7a:	66 0f 2f d5          	comisd %xmm5,%xmm2
  45ee7e:	0f 97 c1             	seta   %cl
  45ee81:	e9 6a fd ff ff       	jmp    45ebf0 <op+0x860>
  45ee86:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  45ee8b:	66 48 0f 6e d0       	movq   %rax,%xmm2
  45ee90:	31 c9                	xor    %ecx,%ecx
  45ee92:	89 d7                	mov    %edx,%edi
  45ee94:	66 0f 2f f2          	comisd %xmm2,%xmm6
  45ee98:	0f 93 c1             	setae  %cl
  45ee9b:	e9 50 fd ff ff       	jmp    45ebf0 <op+0x860>
  45eea0:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  45eea5:	66 48 0f 6e e8       	movq   %rax,%xmm5
  45eeaa:	31 c9                	xor    %ecx,%ecx
  45eeac:	89 d7                	mov    %edx,%edi
  45eeae:	66 0f 2f ee          	comisd %xmm6,%xmm5
  45eeb2:	0f 97 c1             	seta   %cl
  45eeb5:	e9 36 fd ff ff       	jmp    45ebf0 <op+0x860>
  45eeba:	66 48 0f 6e f8       	movq   %rax,%xmm7
  45eebf:	66 48 0f 6e e9       	movq   %rcx,%xmm5
  45eec4:	31 c9                	xor    %ecx,%ecx
  45eec6:	b8 00 00 00 00       	mov    $0x0,%eax
  45eecb:	66 0f 2e fd          	ucomisd %xmm5,%xmm7
  45eecf:	89 d7                	mov    %edx,%edi
  45eed1:	0f 9b c1             	setnp  %cl
  45eed4:	48 0f 45 c8          	cmovne %rax,%rcx
  45eed8:	e9 13 fd ff ff       	jmp    45ebf0 <op+0x860>
  45eedd:	40 f6 c7 01          	test   $0x1,%dil
  45eee1:	0f 84 28 fb ff ff    	je     45ea0f <op+0x67f>
  45eee7:	48 85 c0             	test   %rax,%rax
  45eeea:	0f 85 1f fb ff ff    	jne    45ea0f <op+0x67f>
  45eef0:	bf eb ad 4a 00       	mov    $0x4aadeb,%edi
  45eef5:	e9 d3 f6 ff ff       	jmp    45e5cd <op+0x23d>
  45eefa:	bf 90 df 4a 00       	mov    $0x4adf90,%edi
  45eeff:	e9 c9 f6 ff ff       	jmp    45e5cd <op+0x23d>
  45ef04:	66 0f ef d2          	pxor   %xmm2,%xmm2
  45ef08:	66 0f ef c9          	pxor   %xmm1,%xmm1
  45ef0c:	bf 02 00 00 00       	mov    $0x2,%edi
  45ef11:	f2 48 0f 2a d0       	cvtsi2sd %rax,%xmm2
  45ef16:	f2 48 0f 2a c9       	cvtsi2sd %rcx,%xmm1
  45ef1b:	66 48 0f 7e d0       	movq   %xmm2,%rax
  45ef20:	e9 ea fa ff ff       	jmp    45ea0f <op+0x67f>
  45ef25:	31 c9                	xor    %ecx,%ecx
  45ef27:	e9 4b f9 ff ff       	jmp    45e877 <op+0x4e7>
  45ef2c:	48 f7 d8             	neg    %rax
  45ef2f:	48 89 c1             	mov    %rax,%rcx
  45ef32:	e9 40 f9 ff ff       	jmp    45e877 <op+0x4e7>
  45ef37:	bf 01 00 00 00       	mov    $0x1,%edi
  45ef3c:	b9 01 00 00 00       	mov    $0x1,%ecx
  45ef41:	e9 31 f9 ff ff       	jmp    45e877 <op+0x4e7>

Disassembly of section .fini:
