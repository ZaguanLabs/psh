
.work/round23/candidate/Src/zsh:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000045e300 <op>:
  45e300:	8b 05 5a 03 07 00    	mov    0x7035a(%rip),%eax        # 4ce660 <errflag>
  45e306:	85 c0                	test   %eax,%eax
  45e308:	0f 85 ea 01 00 00    	jne    45e4f8 <op+0x1f8>
  45e30e:	8b 05 2c be 06 00    	mov    0x6be2c(%rip),%eax        # 4ca140 <sp>
  45e314:	85 c0                	test   %eax,%eax
  45e316:	0f 88 e4 01 00 00    	js     45e500 <op+0x200>
  45e31c:	41 57                	push   %r15
  45e31e:	48 63 d7             	movslq %edi,%rdx
  45e321:	48 63 c8             	movslq %eax,%rcx
  45e324:	41 56                	push   %r14
  45e326:	48 89 d6             	mov    %rdx,%rsi
  45e329:	48 c1 e1 05          	shl    $0x5,%rcx
  45e32d:	41 54                	push   %r12
  45e32f:	55                   	push   %rbp
  45e330:	53                   	push   %rbx
  45e331:	48 83 ec 50          	sub    $0x50,%rsp
  45e335:	44 8b 14 95 c0 21 4b 	mov    0x4b21c0(,%rdx,4),%r10d
  45e33c:	00 
  45e33d:	48 8b 15 0c 94 07 00 	mov    0x7940c(%rip),%rdx        # 4d7750 <stack>
  45e344:	48 01 d1             	add    %rdx,%rcx
  45e347:	8b 79 18             	mov    0x18(%rcx),%edi
  45e34a:	41 f6 c2 7c          	test   $0x7c,%r10b
  45e34e:	75 20                	jne    45e370 <op+0x70>
  45e350:	83 ff 04             	cmp    $0x4,%edi
  45e353:	0f 84 e7 01 00 00    	je     45e540 <op+0x240>
  45e359:	83 fe 2e             	cmp    $0x2e,%esi
  45e35c:	0f 87 6e 02 00 00    	ja     45e5d0 <op+0x2d0>
  45e362:	89 f6                	mov    %esi,%esi
  45e364:	ff 24 f5 b8 1c 4b 00 	jmp    *0x4b1cb8(,%rsi,8)
  45e36b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45e370:	83 ff 04             	cmp    $0x4,%edi
  45e373:	75 4b                	jne    45e3c0 <op+0xc0>
  45e375:	48 89 cf             	mov    %rcx,%rdi
  45e378:	89 74 24 40          	mov    %esi,0x40(%rsp)
  45e37c:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
  45e381:	4c 89 4c 24 28       	mov    %r9,0x28(%rsp)
  45e386:	44 89 54 24 10       	mov    %r10d,0x10(%rsp)
  45e38b:	48 89 0c 24          	mov    %rcx,(%rsp)
  45e38f:	e8 6c fe ff ff       	call   45e200 <getmathparam>
  45e394:	48 8b 0c 24          	mov    (%rsp),%rcx
  45e398:	8b 74 24 40          	mov    0x40(%rsp),%esi
  45e39c:	4c 8b 44 24 20       	mov    0x20(%rsp),%r8
  45e3a1:	4c 8b 4c 24 28       	mov    0x28(%rsp),%r9
  45e3a6:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45e3aa:	44 8b 54 24 10       	mov    0x10(%rsp),%r10d
  45e3af:	48 89 51 18          	mov    %rdx,0x18(%rcx)
  45e3b3:	8b 05 87 bd 06 00    	mov    0x6bd87(%rip),%eax        # 4ca140 <sp>
  45e3b9:	48 8b 15 90 93 07 00 	mov    0x79390(%rip),%rdx        # 4d7750 <stack>
  45e3c0:	8d 78 ff             	lea    -0x1(%rax),%edi
  45e3c3:	8b 05 97 02 07 00    	mov    0x70297(%rip),%eax        # 4ce660 <errflag>
  45e3c9:	89 3d 71 bd 06 00    	mov    %edi,0x6bd71(%rip)        # 4ca140 <sp>
  45e3cf:	85 c0                	test   %eax,%eax
  45e3d1:	0f 85 51 01 00 00    	jne    45e528 <op+0x228>
  45e3d7:	4c 8b 79 10          	mov    0x10(%rcx),%r15
  45e3db:	4c 8b 59 18          	mov    0x18(%rcx),%r11
  45e3df:	48 63 c7             	movslq %edi,%rax
  45e3e2:	4c 89 5c 24 08       	mov    %r11,0x8(%rsp)
  45e3e7:	44 89 dd             	mov    %r11d,%ebp
  45e3ea:	4c 89 f9             	mov    %r15,%rcx
  45e3ed:	48 c1 e0 05          	shl    $0x5,%rax
  45e3f1:	4c 89 3c 24          	mov    %r15,(%rsp)
  45e3f5:	4c 8d 1c 02          	lea    (%rdx,%rax,1),%r11
  45e3f9:	41 83 7b 18 04       	cmpl   $0x4,0x18(%r11)
  45e3fe:	75 09                	jne    45e409 <op+0x109>
  45e400:	83 fe 1d             	cmp    $0x1d,%esi
  45e403:	0f 85 3f 0a 00 00    	jne    45ee48 <op+0xb48>
  45e409:	8d 47 ff             	lea    -0x1(%rdi),%eax
  45e40c:	89 05 2e bd 06 00    	mov    %eax,0x6bd2e(%rip)        # 4ca140 <sp>
  45e412:	41 89 c4             	mov    %eax,%r12d
  45e415:	8b 05 45 02 07 00    	mov    0x70245(%rip),%eax        # 4ce660 <errflag>
  45e41b:	85 c0                	test   %eax,%eax
  45e41d:	0f 85 ed 00 00 00    	jne    45e510 <op+0x210>
  45e423:	49 8b 5b 10          	mov    0x10(%r11),%rbx
  45e427:	49 8b 53 18          	mov    0x18(%r11),%rdx
  45e42b:	8b 05 2f 02 07 00    	mov    0x7022f(%rip),%eax        # 4ce660 <errflag>
  45e431:	85 c0                	test   %eax,%eax
  45e433:	0f 85 ae 00 00 00    	jne    45e4e7 <op+0x1e7>
  45e439:	8b 05 f1 92 07 00    	mov    0x792f1(%rip),%eax        # 4d7730 <noeval>
  45e43f:	49 89 db             	mov    %rbx,%r11
  45e442:	41 89 d6             	mov    %edx,%r14d
  45e445:	41 f6 c2 50          	test   $0x50,%r10b
  45e449:	0f 84 29 01 00 00    	je     45e578 <op+0x278>
  45e44f:	83 e2 02             	and    $0x2,%edx
  45e452:	74 10                	je     45e464 <op+0x164>
  45e454:	66 48 0f 6e db       	movq   %rbx,%xmm3
  45e459:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45e45f:	f2 4c 0f 2c db       	cvttsd2si %xmm3,%r11
  45e464:	40 f6 c5 02          	test   $0x2,%bpl
  45e468:	0f 85 92 01 00 00    	jne    45e600 <op+0x300>
  45e46e:	85 c0                	test   %eax,%eax
  45e470:	0f 85 12 05 00 00    	jne    45e988 <op+0x688>
  45e476:	83 ee 08             	sub    $0x8,%esi
  45e479:	41 f6 c2 08          	test   $0x8,%r10b
  45e47d:	0f 85 6d 01 00 00    	jne    45e5f0 <op+0x2f0>
  45e483:	83 fe 2b             	cmp    $0x2b,%esi
  45e486:	0f 87 04 05 00 00    	ja     45e990 <op+0x690>
  45e48c:	ff 24 f5 30 1e 4b 00 	jmp    *0x4b1e30(,%rsi,8)
  45e493:	48 8b 79 10          	mov    0x10(%rcx),%rdi
  45e497:	48 8b 51 18          	mov    0x18(%rcx),%rdx
  45e49b:	48 8d 77 01          	lea    0x1(%rdi),%rsi
  45e49f:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e4a3:	74 12                	je     45e4b7 <op+0x1b7>
  45e4a5:	66 48 0f 6e e7       	movq   %rdi,%xmm4
  45e4aa:	f2 0f 58 25 9e 25 05 	addsd  0x5259e(%rip),%xmm4        # 4b0a50 <execfuncs+0xdb0>
  45e4b1:	00 
  45e4b2:	66 48 0f 7e e6       	movq   %xmm4,%rsi
  45e4b7:	48 63 3d 82 bc 06 00 	movslq 0x6bc82(%rip),%rdi        # 4ca140 <sp>
  45e4be:	48 c1 e7 05          	shl    $0x5,%rdi
  45e4c2:	48 03 3d 87 92 07 00 	add    0x79287(%rip),%rdi        # 4d7750 <stack>
  45e4c9:	e8 d2 eb ff ff       	call   45d0a0 <setmathvar>
  45e4ce:	48 63 05 6b bc 06 00 	movslq 0x6bc6b(%rip),%rax        # 4ca140 <sp>
  45e4d5:	48 c1 e0 05          	shl    $0x5,%rax
  45e4d9:	48 03 05 70 92 07 00 	add    0x79270(%rip),%rax        # 4d7750 <stack>
  45e4e0:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45e4e4:	0f 11 00             	movups %xmm0,(%rax)
  45e4e7:	48 83 c4 50          	add    $0x50,%rsp
  45e4eb:	5b                   	pop    %rbx
  45e4ec:	5d                   	pop    %rbp
  45e4ed:	41 5c                	pop    %r12
  45e4ef:	41 5e                	pop    %r14
  45e4f1:	41 5f                	pop    %r15
  45e4f3:	c3                   	ret
  45e4f4:	0f 1f 40 00          	nopl   0x0(%rax)
  45e4f8:	c3                   	ret
  45e4f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  45e500:	bf 68 df 4a 00       	mov    $0x4adf68,%edi
  45e505:	31 c0                	xor    %eax,%eax
  45e507:	e9 a4 33 04 00       	jmp    4a18b0 <zerr>
  45e50c:	0f 1f 40 00          	nopl   0x0(%rax)
  45e510:	48 8b 1d 09 92 07 00 	mov    0x79209(%rip),%rbx        # 4d7720 <zero_mnumber>
  45e517:	48 8b 15 0a 92 07 00 	mov    0x7920a(%rip),%rdx        # 4d7728 <zero_mnumber+0x8>
  45e51e:	e9 08 ff ff ff       	jmp    45e42b <op+0x12b>
  45e523:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45e528:	4c 8b 3d f1 91 07 00 	mov    0x791f1(%rip),%r15        # 4d7720 <zero_mnumber>
  45e52f:	4c 8b 1d f2 91 07 00 	mov    0x791f2(%rip),%r11        # 4d7728 <zero_mnumber+0x8>
  45e536:	e9 a4 fe ff ff       	jmp    45e3df <op+0xdf>
  45e53b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45e540:	48 89 cf             	mov    %rcx,%rdi
  45e543:	89 74 24 10          	mov    %esi,0x10(%rsp)
  45e547:	48 89 0c 24          	mov    %rcx,(%rsp)
  45e54b:	e8 b0 fc ff ff       	call   45e200 <getmathparam>
  45e550:	48 8b 0c 24          	mov    (%rsp),%rcx
  45e554:	8b 74 24 10          	mov    0x10(%rsp),%esi
  45e558:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45e55c:	8b 05 fe 00 07 00    	mov    0x700fe(%rip),%eax        # 4ce660 <errflag>
  45e562:	48 89 51 18          	mov    %rdx,0x18(%rcx)
  45e566:	85 c0                	test   %eax,%eax
  45e568:	0f 84 eb fd ff ff    	je     45e359 <op+0x59>
  45e56e:	e9 74 ff ff ff       	jmp    45e4e7 <op+0x1e7>
  45e573:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45e578:	39 d5                	cmp    %edx,%ebp
  45e57a:	0f 84 ee fe ff ff    	je     45e46e <op+0x16e>
  45e580:	83 fe 2b             	cmp    $0x2b,%esi
  45e583:	0f 84 b7 09 00 00    	je     45ef40 <op+0xc40>
  45e589:	83 fa 04             	cmp    $0x4,%edx
  45e58c:	0f 84 41 0a 00 00    	je     45efd3 <op+0xcd3>
  45e592:	f6 c2 01             	test   $0x1,%dl
  45e595:	74 14                	je     45e5ab <op+0x2ab>
  45e597:	66 0f ef d2          	pxor   %xmm2,%xmm2
  45e59b:	41 be 02 00 00 00    	mov    $0x2,%r14d
  45e5a1:	f2 48 0f 2a d3       	cvtsi2sd %rbx,%xmm2
  45e5a6:	66 49 0f 7e d3       	movq   %xmm2,%r11
  45e5ab:	40 f6 c5 01          	test   $0x1,%bpl
  45e5af:	0f 84 b9 fe ff ff    	je     45e46e <op+0x16e>
  45e5b5:	66 0f ef c9          	pxor   %xmm1,%xmm1
  45e5b9:	bd 02 00 00 00       	mov    $0x2,%ebp
  45e5be:	f2 49 0f 2a cf       	cvtsi2sd %r15,%xmm1
  45e5c3:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  45e5c8:	e9 a1 fe ff ff       	jmp    45e46e <op+0x16e>
  45e5cd:	0f 1f 00             	nopl   (%rax)
  45e5d0:	bf e0 df 4a 00       	mov    $0x4adfe0,%edi
  45e5d5:	48 83 c4 50          	add    $0x50,%rsp
  45e5d9:	31 c0                	xor    %eax,%eax
  45e5db:	5b                   	pop    %rbx
  45e5dc:	5d                   	pop    %rbp
  45e5dd:	41 5c                	pop    %r12
  45e5df:	41 5e                	pop    %r14
  45e5e1:	41 5f                	pop    %r15
  45e5e3:	e9 c8 32 04 00       	jmp    4a18b0 <zerr>
  45e5e8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  45e5ef:	00 
  45e5f0:	83 fe 2b             	cmp    $0x2b,%esi
  45e5f3:	0f 87 59 04 00 00    	ja     45ea52 <op+0x752>
  45e5f9:	ff 24 f5 90 1f 4b 00 	jmp    *0x4b1f90(,%rsi,8)
  45e600:	66 49 0f 6e e7       	movq   %r15,%xmm4
  45e605:	bd 01 00 00 00       	mov    $0x1,%ebp
  45e60a:	f2 48 0f 2c cc       	cvttsd2si %xmm4,%rcx
  45e60f:	e9 5a fe ff ff       	jmp    45e46e <op+0x16e>
  45e614:	48 8b 79 10          	mov    0x10(%rcx),%rdi
  45e618:	48 8b 51 18          	mov    0x18(%rcx),%rdx
  45e61c:	48 8d 77 ff          	lea    -0x1(%rdi),%rsi
  45e620:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e624:	0f 84 8d fe ff ff    	je     45e4b7 <op+0x1b7>
  45e62a:	66 48 0f 6e ef       	movq   %rdi,%xmm5
  45e62f:	f2 0f 5c 2d 19 24 05 	subsd  0x52419(%rip),%xmm5        # 4b0a50 <execfuncs+0xdb0>
  45e636:	00 
  45e637:	66 48 0f 7e ee       	movq   %xmm5,%rsi
  45e63c:	e9 76 fe ff ff       	jmp    45e4b7 <op+0x1b7>
  45e641:	48 8b 41 10          	mov    0x10(%rcx),%rax
  45e645:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e649:	0f 84 61 08 00 00    	je     45eeb0 <op+0xbb0>
  45e64f:	66 48 0f 6e c0       	movq   %rax,%xmm0
  45e654:	f2 0f 58 05 f4 23 05 	addsd  0x523f4(%rip),%xmm0        # 4b0a50 <execfuncs+0xdb0>
  45e65b:	00 
  45e65c:	f2 0f 11 41 10       	movsd  %xmm0,0x10(%rcx)
  45e661:	48 63 3d d8 ba 06 00 	movslq 0x6bad8(%rip),%rdi        # 4ca140 <sp>
  45e668:	48 8b 71 10          	mov    0x10(%rcx),%rsi
  45e66c:	48 8b 51 18          	mov    0x18(%rcx),%rdx
  45e670:	48 c1 e7 05          	shl    $0x5,%rdi
  45e674:	48 03 3d d5 90 07 00 	add    0x790d5(%rip),%rdi        # 4d7750 <stack>
  45e67b:	e8 20 ea ff ff       	call   45d0a0 <setmathvar>
  45e680:	48 63 05 b9 ba 06 00 	movslq 0x6bab9(%rip),%rax        # 4ca140 <sp>
  45e687:	48 c1 e0 05          	shl    $0x5,%rax
  45e68b:	48 03 05 be 90 07 00 	add    0x790be(%rip),%rax        # 4d7750 <stack>
  45e692:	e9 49 fe ff ff       	jmp    45e4e0 <op+0x1e0>
  45e697:	48 8b 41 10          	mov    0x10(%rcx),%rax
  45e69b:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e69f:	0f 84 7b 08 00 00    	je     45ef20 <op+0xc20>
  45e6a5:	66 48 0f 6e c0       	movq   %rax,%xmm0
  45e6aa:	f2 0f 5c 05 9e 23 05 	subsd  0x5239e(%rip),%xmm0        # 4b0a50 <execfuncs+0xdb0>
  45e6b1:	00 
  45e6b2:	f2 0f 11 41 10       	movsd  %xmm0,0x10(%rcx)
  45e6b7:	eb a8                	jmp    45e661 <op+0x361>
  45e6b9:	48 63 05 80 ba 06 00 	movslq 0x6ba80(%rip),%rax        # 4ca140 <sp>
  45e6c0:	48 c1 e0 05          	shl    $0x5,%rax
  45e6c4:	48 03 05 85 90 07 00 	add    0x79085(%rip),%rax        # 4d7750 <stack>
  45e6cb:	e9 10 fe ff ff       	jmp    45e4e0 <op+0x1e0>
  45e6d0:	48 63 0d 69 ba 06 00 	movslq 0x6ba69(%rip),%rcx        # 4ca140 <sp>
  45e6d7:	48 8b 15 72 90 07 00 	mov    0x79072(%rip),%rdx        # 4d7750 <stack>
  45e6de:	48 89 c8             	mov    %rcx,%rax
  45e6e1:	48 c1 e1 05          	shl    $0x5,%rcx
  45e6e5:	48 01 d1             	add    %rdx,%rcx
  45e6e8:	83 79 18 04          	cmpl   $0x4,0x18(%rcx)
  45e6ec:	75 25                	jne    45e713 <op+0x413>
  45e6ee:	48 89 cf             	mov    %rcx,%rdi
  45e6f1:	48 89 0c 24          	mov    %rcx,(%rsp)
  45e6f5:	e8 06 fb ff ff       	call   45e200 <getmathparam>
  45e6fa:	48 8b 0c 24          	mov    (%rsp),%rcx
  45e6fe:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45e702:	8b 05 38 ba 06 00    	mov    0x6ba38(%rip),%eax        # 4ca140 <sp>
  45e708:	48 89 51 18          	mov    %rdx,0x18(%rcx)
  45e70c:	48 8b 15 3d 90 07 00 	mov    0x7903d(%rip),%rdx        # 4d7750 <stack>
  45e713:	8b 35 47 ff 06 00    	mov    0x6ff47(%rip),%esi        # 4ce660 <errflag>
  45e719:	83 e8 01             	sub    $0x1,%eax
  45e71c:	89 05 1e ba 06 00    	mov    %eax,0x6ba1e(%rip)        # 4ca140 <sp>
  45e722:	85 f6                	test   %esi,%esi
  45e724:	0f 85 ae 07 00 00    	jne    45eed8 <op+0xbd8>
  45e72a:	4c 8b 79 10          	mov    0x10(%rcx),%r15
  45e72e:	48 8b 49 18          	mov    0x18(%rcx),%rcx
  45e732:	49 89 c9             	mov    %rcx,%r9
  45e735:	41 89 ce             	mov    %ecx,%r14d
  45e738:	48 63 c8             	movslq %eax,%rcx
  45e73b:	4d 89 f8             	mov    %r15,%r8
  45e73e:	48 c1 e1 05          	shl    $0x5,%rcx
  45e742:	48 01 d1             	add    %rdx,%rcx
  45e745:	83 79 18 04          	cmpl   $0x4,0x18(%rcx)
  45e749:	75 39                	jne    45e784 <op+0x484>
  45e74b:	48 89 cf             	mov    %rcx,%rdi
  45e74e:	4c 89 4c 24 18       	mov    %r9,0x18(%rsp)
  45e753:	48 89 0c 24          	mov    %rcx,(%rsp)
  45e757:	4c 89 7c 24 10       	mov    %r15,0x10(%rsp)
  45e75c:	e8 9f fa ff ff       	call   45e200 <getmathparam>
  45e761:	48 8b 0c 24          	mov    (%rsp),%rcx
  45e765:	4c 8b 44 24 10       	mov    0x10(%rsp),%r8
  45e76a:	4c 8b 4c 24 18       	mov    0x18(%rsp),%r9
  45e76f:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45e773:	8b 05 c7 b9 06 00    	mov    0x6b9c7(%rip),%eax        # 4ca140 <sp>
  45e779:	48 89 51 18          	mov    %rdx,0x18(%rcx)
  45e77d:	48 8b 15 cc 8f 07 00 	mov    0x78fcc(%rip),%rdx        # 4d7750 <stack>
  45e784:	8b 3d d6 fe 06 00    	mov    0x6fed6(%rip),%edi        # 4ce660 <errflag>
  45e78a:	83 e8 01             	sub    $0x1,%eax
  45e78d:	89 05 ad b9 06 00    	mov    %eax,0x6b9ad(%rip)        # 4ca140 <sp>
  45e793:	85 ff                	test   %edi,%edi
  45e795:	0f 85 25 07 00 00    	jne    45eec0 <op+0xbc0>
  45e79b:	4c 8b 59 10          	mov    0x10(%rcx),%r11
  45e79f:	4c 8b 51 18          	mov    0x18(%rcx),%r10
  45e7a3:	48 63 c8             	movslq %eax,%rcx
  45e7a6:	4c 89 1c 24          	mov    %r11,(%rsp)
  45e7aa:	48 c1 e1 05          	shl    $0x5,%rcx
  45e7ae:	4c 89 54 24 08       	mov    %r10,0x8(%rsp)
  45e7b3:	48 01 d1             	add    %rdx,%rcx
  45e7b6:	83 79 18 04          	cmpl   $0x4,0x18(%rcx)
  45e7ba:	75 43                	jne    45e7ff <op+0x4ff>
  45e7bc:	48 89 cf             	mov    %rcx,%rdi
  45e7bf:	4c 89 4c 24 38       	mov    %r9,0x38(%rsp)
  45e7c4:	4c 89 5c 24 40       	mov    %r11,0x40(%rsp)
  45e7c9:	44 89 54 24 20       	mov    %r10d,0x20(%rsp)
  45e7ce:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
  45e7d3:	4c 89 44 24 30       	mov    %r8,0x30(%rsp)
  45e7d8:	e8 23 fa ff ff       	call   45e200 <getmathparam>
  45e7dd:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
  45e7e2:	4c 8b 4c 24 38       	mov    0x38(%rsp),%r9
  45e7e7:	4c 8b 5c 24 40       	mov    0x40(%rsp),%r11
  45e7ec:	44 8b 54 24 20       	mov    0x20(%rsp),%r10d
  45e7f1:	48 89 51 18          	mov    %rdx,0x18(%rcx)
  45e7f5:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45e7f9:	8b 05 41 b9 06 00    	mov    0x6b941(%rip),%eax        # 4ca140 <sp>
  45e7ff:	8b 15 5b fe 06 00    	mov    0x6fe5b(%rip),%edx        # 4ce660 <errflag>
  45e805:	8d 78 ff             	lea    -0x1(%rax),%edi
  45e808:	89 3d 32 b9 06 00    	mov    %edi,0x6b932(%rip)        # 4ca140 <sp>
  45e80e:	85 d2                	test   %edx,%edx
  45e810:	0f 85 f2 06 00 00    	jne    45ef08 <op+0xc08>
  45e816:	48 8b 71 10          	mov    0x10(%rcx),%rsi
  45e81a:	48 8b 49 18          	mov    0x18(%rcx),%rcx
  45e81e:	8b 15 3c fe 06 00    	mov    0x6fe3c(%rip),%edx        # 4ce660 <errflag>
  45e824:	85 d2                	test   %edx,%edx
  45e826:	0f 85 bb fc ff ff    	jne    45e4e7 <op+0x1e7>
  45e82c:	83 e1 02             	and    $0x2,%ecx
  45e82f:	0f 84 8b 07 00 00    	je     45efc0 <op+0xcc0>
  45e835:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45e839:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  45e83e:	66 0f 2e d0          	ucomisd %xmm0,%xmm2
  45e842:	0f 8a 81 07 00 00    	jp     45efc9 <op+0xcc9>
  45e848:	0f 85 7b 07 00 00    	jne    45efc9 <op+0xcc9>
  45e84e:	45 89 f2             	mov    %r14d,%r10d
  45e851:	4d 89 fb             	mov    %r15,%r11
  45e854:	4c 89 ca             	mov    %r9,%rdx
  45e857:	45 89 d2             	mov    %r10d,%r10d
  45e85a:	4d 89 d8             	mov    %r11,%r8
  45e85d:	48 b9 00 00 00 00 ff 	movabs $0xffffffff00000000,%rcx
  45e864:	ff ff ff 
  45e867:	48 21 ca             	and    %rcx,%rdx
  45e86a:	4c 09 d2             	or     %r10,%rdx
  45e86d:	49 89 d1             	mov    %rdx,%r9
  45e870:	83 ff 63             	cmp    $0x63,%edi
  45e873:	0f 84 78 07 00 00    	je     45eff1 <op+0xcf1>
  45e879:	89 05 c1 b8 06 00    	mov    %eax,0x6b8c1(%rip)        # 4ca140 <sp>
  45e87f:	48 98                	cltq
  45e881:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45e885:	48 c1 e0 05          	shl    $0x5,%rax
  45e889:	48 03 05 c0 8e 07 00 	add    0x78ec0(%rip),%rax        # 4d7750 <stack>
  45e890:	4c 89 40 10          	mov    %r8,0x10(%rax)
  45e894:	4c 89 48 18          	mov    %r9,0x18(%rax)
  45e898:	0f 11 00             	movups %xmm0,(%rax)
  45e89b:	e9 40 fc ff ff       	jmp    45e4e0 <op+0x1e0>
  45e8a0:	31 c0                	xor    %eax,%eax
  45e8a2:	bf b8 df 4a 00       	mov    $0x4adfb8,%edi
  45e8a7:	e8 04 30 04 00       	call   4a18b0 <zerr>
  45e8ac:	48 63 05 8d b8 06 00 	movslq 0x6b88d(%rip),%rax        # 4ca140 <sp>
  45e8b3:	48 c1 e0 05          	shl    $0x5,%rax
  45e8b7:	48 03 05 92 8e 07 00 	add    0x78e92(%rip),%rax        # 4d7750 <stack>
  45e8be:	e9 1d fc ff ff       	jmp    45e4e0 <op+0x1e0>
  45e8c3:	48 63 05 76 b8 06 00 	movslq 0x6b876(%rip),%rax        # 4ca140 <sp>
  45e8ca:	48 8b 51 10          	mov    0x10(%rcx),%rdx
  45e8ce:	48 c1 e0 05          	shl    $0x5,%rax
  45e8d2:	48 03 05 77 8e 07 00 	add    0x78e77(%rip),%rax        # 4d7750 <stack>
  45e8d9:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e8dd:	0f 84 0d 06 00 00    	je     45eef0 <op+0xbf0>
  45e8e3:	66 48 0f 6e f2       	movq   %rdx,%xmm6
  45e8e8:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45e8ec:	31 d2                	xor    %edx,%edx
  45e8ee:	be 00 00 00 00       	mov    $0x0,%esi
  45e8f3:	66 0f 2e f0          	ucomisd %xmm0,%xmm6
  45e8f7:	c7 41 18 01 00 00 00 	movl   $0x1,0x18(%rcx)
  45e8fe:	0f 9b c2             	setnp  %dl
  45e901:	48 0f 45 d6          	cmovne %rsi,%rdx
  45e905:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45e909:	e9 d2 fb ff ff       	jmp    45e4e0 <op+0x1e0>
  45e90e:	48 63 05 2b b8 06 00 	movslq 0x6b82b(%rip),%rax        # 4ca140 <sp>
  45e915:	48 8b 51 10          	mov    0x10(%rcx),%rdx
  45e919:	48 c1 e0 05          	shl    $0x5,%rax
  45e91d:	48 03 05 2c 8e 07 00 	add    0x78e2c(%rip),%rax        # 4d7750 <stack>
  45e924:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e928:	0f 84 02 06 00 00    	je     45ef30 <op+0xc30>
  45e92e:	66 48 0f 6e fa       	movq   %rdx,%xmm7
  45e933:	c7 41 18 01 00 00 00 	movl   $0x1,0x18(%rcx)
  45e93a:	f2 48 0f 2c d7       	cvttsd2si %xmm7,%rdx
  45e93f:	48 f7 d2             	not    %rdx
  45e942:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45e946:	e9 95 fb ff ff       	jmp    45e4e0 <op+0x1e0>
  45e94b:	48 63 05 ee b7 06 00 	movslq 0x6b7ee(%rip),%rax        # 4ca140 <sp>
  45e952:	48 8b 51 10          	mov    0x10(%rcx),%rdx
  45e956:	48 c1 e0 05          	shl    $0x5,%rax
  45e95a:	48 03 05 ef 8d 07 00 	add    0x78def(%rip),%rax        # 4d7750 <stack>
  45e961:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
  45e965:	0f 84 35 05 00 00    	je     45eea0 <op+0xba0>
  45e96b:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  45e970:	66 0f 57 05 88 0b 05 	xorpd  0x50b88(%rip),%xmm0        # 4af500 <tiedarr_gsu+0x70>
  45e977:	00 
  45e978:	f2 0f 11 41 10       	movsd  %xmm0,0x10(%rcx)
  45e97d:	e9 5e fb ff ff       	jmp    45e4e0 <op+0x1e0>
  45e982:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  45e988:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45e98e:	31 c9                	xor    %ecx,%ecx
  45e990:	41 83 e2 60          	and    $0x60,%r10d
  45e994:	0f 84 96 03 00 00    	je     45ed30 <op+0xa30>
  45e99a:	48 63 c7             	movslq %edi,%rax
  45e99d:	49 89 c8             	mov    %rcx,%r8
  45e9a0:	4c 89 ca             	mov    %r9,%rdx
  45e9a3:	48 b9 00 00 00 00 ff 	movabs $0xffffffff00000000,%rcx
  45e9aa:	ff ff ff 
  45e9ad:	48 c1 e0 05          	shl    $0x5,%rax
  45e9b1:	48 03 05 98 8d 07 00 	add    0x78d98(%rip),%rax        # 4d7750 <stack>
  45e9b8:	48 21 ca             	and    %rcx,%rdx
  45e9bb:	4c 89 c6             	mov    %r8,%rsi
  45e9be:	48 89 c7             	mov    %rax,%rdi
  45e9c1:	44 89 f0             	mov    %r14d,%eax
  45e9c4:	48 09 c2             	or     %rax,%rdx
  45e9c7:	48 89 3c 24          	mov    %rdi,(%rsp)
  45e9cb:	e8 d0 e6 ff ff       	call   45d0a0 <setmathvar>
  45e9d0:	48 8b 3c 24          	mov    (%rsp),%rdi
  45e9d4:	48 89 d1             	mov    %rdx,%rcx
  45e9d7:	48 89 c2             	mov    %rax,%rdx
  45e9da:	8b 05 60 b7 06 00    	mov    0x6b760(%rip),%eax        # 4ca140 <sp>
  45e9e0:	48 8b 37             	mov    (%rdi),%rsi
  45e9e3:	83 f8 63             	cmp    $0x63,%eax
  45e9e6:	0f 84 9c 05 00 00    	je     45ef88 <op+0xc88>
  45e9ec:	83 c0 01             	add    $0x1,%eax
  45e9ef:	89 05 4b b7 06 00    	mov    %eax,0x6b74b(%rip)        # 4ca140 <sp>
  45e9f5:	48 98                	cltq
  45e9f7:	48 c1 e0 05          	shl    $0x5,%rax
  45e9fb:	48 03 05 4e 8d 07 00 	add    0x78d4e(%rip),%rax        # 4d7750 <stack>
  45ea02:	48 89 50 10          	mov    %rdx,0x10(%rax)
  45ea06:	48 89 48 18          	mov    %rcx,0x18(%rax)
  45ea0a:	48 89 30             	mov    %rsi,(%rax)
  45ea0d:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
  45ea14:	00 
  45ea15:	e9 cd fa ff ff       	jmp    45e4e7 <op+0x1e7>
  45ea1a:	48 85 c9             	test   %rcx,%rcx
  45ea1d:	0f 88 d9 06 00 00    	js     45f0fc <op+0xdfc>
  45ea23:	0f 84 00 07 00 00    	je     45f129 <op+0xe29>
  45ea29:	48 8d 51 ff          	lea    -0x1(%rcx),%rdx
  45ea2d:	b9 01 00 00 00       	mov    $0x1,%ecx
  45ea32:	f6 c2 01             	test   $0x1,%dl
  45ea35:	75 09                	jne    45ea40 <op+0x740>
  45ea37:	4c 89 d9             	mov    %r11,%rcx
  45ea3a:	48 83 ea 01          	sub    $0x1,%rdx
  45ea3e:	72 12                	jb     45ea52 <op+0x752>
  45ea40:	49 0f af cb          	imul   %r11,%rcx
  45ea44:	48 83 ea 02          	sub    $0x2,%rdx
  45ea48:	49 0f af cb          	imul   %r11,%rcx
  45ea4c:	48 83 fa ff          	cmp    $0xffffffffffffffff,%rdx
  45ea50:	75 ee                	jne    45ea40 <op+0x740>
  45ea52:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45ea58:	e9 33 ff ff ff       	jmp    45e990 <op+0x690>
  45ea5d:	0f 1f 00             	nopl   (%rax)
  45ea60:	48 8b 54 24 08       	mov    0x8(%rsp),%rdx
  45ea65:	89 e8                	mov    %ebp,%eax
  45ea67:	48 89 0c 24          	mov    %rcx,(%rsp)
  45ea6b:	41 89 ee             	mov    %ebp,%r14d
  45ea6e:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
  45ea73:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
  45ea78:	48 ba 00 00 00 00 ff 	movabs $0xffffffff00000000,%rdx
  45ea7f:	ff ff ff 
  45ea82:	49 89 f0             	mov    %rsi,%r8
  45ea85:	49 21 d0             	and    %rdx,%r8
  45ea88:	49 09 c0             	or     %rax,%r8
  45ea8b:	4d 89 c1             	mov    %r8,%r9
  45ea8e:	e9 fd fe ff ff       	jmp    45e990 <op+0x690>
  45ea93:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45ea99:	4d 85 db             	test   %r11,%r11
  45ea9c:	0f 95 c0             	setne  %al
  45ea9f:	48 85 c9             	test   %rcx,%rcx
  45eaa2:	0f 95 c2             	setne  %dl
  45eaa5:	31 d0                	xor    %edx,%eax
  45eaa7:	0f b6 c8             	movzbl %al,%ecx
  45eaaa:	e9 e1 fe ff ff       	jmp    45e990 <op+0x690>
  45eaaf:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45eab5:	49 09 cb             	or     %rcx,%r11
  45eab8:	0f 95 c1             	setne  %cl
  45eabb:	0f b6 c9             	movzbl %cl,%ecx
  45eabe:	e9 cd fe ff ff       	jmp    45e990 <op+0x690>
  45eac3:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45eac9:	4d 85 db             	test   %r11,%r11
  45eacc:	0f 95 c0             	setne  %al
  45eacf:	48 85 c9             	test   %rcx,%rcx
  45ead2:	0f 95 c1             	setne  %cl
  45ead5:	0f b6 c9             	movzbl %cl,%ecx
  45ead8:	48 21 c1             	and    %rax,%rcx
  45eadb:	e9 b0 fe ff ff       	jmp    45e990 <op+0x690>
  45eae0:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45eae6:	49 d3 fb             	sar    %cl,%r11
  45eae9:	4c 89 d9             	mov    %r11,%rcx
  45eaec:	e9 9f fe ff ff       	jmp    45e990 <op+0x690>
  45eaf1:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45eaf7:	49 d3 e3             	shl    %cl,%r11
  45eafa:	4c 89 d9             	mov    %r11,%rcx
  45eafd:	e9 8e fe ff ff       	jmp    45e990 <op+0x690>
  45eb02:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45eb08:	4c 09 d9             	or     %r11,%rcx
  45eb0b:	e9 80 fe ff ff       	jmp    45e990 <op+0x690>
  45eb10:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45eb16:	4c 31 d9             	xor    %r11,%rcx
  45eb19:	e9 72 fe ff ff       	jmp    45e990 <op+0x690>
  45eb1e:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45eb24:	4c 21 d9             	and    %r11,%rcx
  45eb27:	e9 64 fe ff ff       	jmp    45e990 <op+0x690>
  45eb2c:	41 83 fe 01          	cmp    $0x1,%r14d
  45eb30:	0f 84 e4 fe ff ff    	je     45ea1a <op+0x71a>
  45eb36:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  45eb3b:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45eb3f:	66 0f 2f c1          	comisd %xmm1,%xmm0
  45eb43:	0f 83 85 05 00 00    	jae    45f0ce <op+0xdce>
  45eb49:	66 49 0f 6e c3       	movq   %r11,%xmm0
  45eb4e:	66 0f ef d2          	pxor   %xmm2,%xmm2
  45eb52:	66 0f 2f d0          	comisd %xmm0,%xmm2
  45eb56:	76 1e                	jbe    45eb76 <op+0x876>
  45eb58:	f2 48 0f 2c c1       	cvttsd2si %xmm1,%rax
  45eb5d:	66 0f ef d2          	pxor   %xmm2,%xmm2
  45eb61:	f2 48 0f 2a d0       	cvtsi2sd %rax,%xmm2
  45eb66:	66 0f 2e d1          	ucomisd %xmm1,%xmm2
  45eb6a:	0f 8a 7b 05 00 00    	jp     45f0eb <op+0xdeb>
  45eb70:	0f 85 75 05 00 00    	jne    45f0eb <op+0xdeb>
  45eb76:	4c 89 4c 24 28       	mov    %r9,0x28(%rsp)
  45eb7b:	89 7c 24 10          	mov    %edi,0x10(%rsp)
  45eb7f:	44 89 14 24          	mov    %r10d,(%rsp)
  45eb83:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
  45eb88:	e8 33 10 fb ff       	call   40fbc0 <pow@plt>
  45eb8d:	44 8b 14 24          	mov    (%rsp),%r10d
  45eb91:	8b 7c 24 10          	mov    0x10(%rsp),%edi
  45eb95:	4c 8b 4c 24 28       	mov    0x28(%rsp),%r9
  45eb9a:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  45eb9f:	e9 ec fd ff ff       	jmp    45e990 <op+0x690>
  45eba4:	41 83 fe 02          	cmp    $0x2,%r14d
  45eba8:	0f 85 da 00 00 00    	jne    45ec88 <op+0x988>
  45ebae:	66 48 0f 6e f9       	movq   %rcx,%xmm7
  45ebb3:	66 49 0f 6e cb       	movq   %r11,%xmm1
  45ebb8:	f2 0f 58 cf          	addsd  %xmm7,%xmm1
  45ebbc:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  45ebc1:	e9 ca fd ff ff       	jmp    45e990 <op+0x690>
  45ebc6:	48 85 c9             	test   %rcx,%rcx
  45ebc9:	75 09                	jne    45ebd4 <op+0x8d4>
  45ebcb:	83 e5 01             	and    $0x1,%ebp
  45ebce:	0f 85 0d 05 00 00    	jne    45f0e1 <op+0xde1>
  45ebd4:	41 83 fe 02          	cmp    $0x2,%r14d
  45ebd8:	0f 85 e7 00 00 00    	jne    45ecc5 <op+0x9c5>
  45ebde:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  45ebe3:	66 49 0f 6e c3       	movq   %r11,%xmm0
  45ebe8:	4c 89 4c 24 28       	mov    %r9,0x28(%rsp)
  45ebed:	89 7c 24 10          	mov    %edi,0x10(%rsp)
  45ebf1:	44 89 14 24          	mov    %r10d,(%rsp)
  45ebf5:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
  45ebfa:	e8 11 0e fb ff       	call   40fa10 <fmod@plt>
  45ebff:	44 8b 14 24          	mov    (%rsp),%r10d
  45ec03:	8b 7c 24 10          	mov    0x10(%rsp),%edi
  45ec07:	4c 8b 4c 24 28       	mov    0x28(%rsp),%r9
  45ec0c:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  45ec11:	e9 7a fd ff ff       	jmp    45e990 <op+0x690>
  45ec16:	48 85 c9             	test   %rcx,%rcx
  45ec19:	75 09                	jne    45ec24 <op+0x924>
  45ec1b:	83 e5 01             	and    $0x1,%ebp
  45ec1e:	0f 85 bd 04 00 00    	jne    45f0e1 <op+0xde1>
  45ec24:	41 83 fe 02          	cmp    $0x2,%r14d
  45ec28:	0f 85 c6 00 00 00    	jne    45ecf4 <op+0x9f4>
  45ec2e:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  45ec33:	66 49 0f 6e fb       	movq   %r11,%xmm7
  45ec38:	f2 0f 5e f9          	divsd  %xmm1,%xmm7
  45ec3c:	66 48 0f 7e f9       	movq   %xmm7,%rcx
  45ec41:	e9 4a fd ff ff       	jmp    45e990 <op+0x690>
  45ec46:	41 83 fe 02          	cmp    $0x2,%r14d
  45ec4a:	75 59                	jne    45eca5 <op+0x9a5>
  45ec4c:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  45ec51:	66 49 0f 6e f3       	movq   %r11,%xmm6
  45ec56:	f2 0f 5c f1          	subsd  %xmm1,%xmm6
  45ec5a:	66 48 0f 7e f1       	movq   %xmm6,%rcx
  45ec5f:	e9 2c fd ff ff       	jmp    45e990 <op+0x690>
  45ec64:	41 83 fe 02          	cmp    $0x2,%r14d
  45ec68:	75 2c                	jne    45ec96 <op+0x996>
  45ec6a:	66 48 0f 6e f9       	movq   %rcx,%xmm7
  45ec6f:	66 49 0f 6e f3       	movq   %r11,%xmm6
  45ec74:	f2 0f 59 f7          	mulsd  %xmm7,%xmm6
  45ec78:	66 48 0f 7e f1       	movq   %xmm6,%rcx
  45ec7d:	e9 0e fd ff ff       	jmp    45e990 <op+0x690>
  45ec82:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45ec88:	4c 01 d9             	add    %r11,%rcx
  45ec8b:	e9 00 fd ff ff       	jmp    45e990 <op+0x690>
  45ec90:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45ec96:	49 0f af cb          	imul   %r11,%rcx
  45ec9a:	e9 f1 fc ff ff       	jmp    45e990 <op+0x690>
  45ec9f:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45eca5:	49 29 cb             	sub    %rcx,%r11
  45eca8:	4c 89 d9             	mov    %r11,%rcx
  45ecab:	e9 e0 fc ff ff       	jmp    45e990 <op+0x690>
  45ecb0:	48 85 c9             	test   %rcx,%rcx
  45ecb3:	75 0a                	jne    45ecbf <op+0x9bf>
  45ecb5:	40 80 e5 01          	and    $0x1,%bpl
  45ecb9:	0f 85 22 04 00 00    	jne    45f0e1 <op+0xde1>
  45ecbf:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45ecc5:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
  45ecc9:	0f 84 26 04 00 00    	je     45f0f5 <op+0xdf5>
  45eccf:	4c 89 d8             	mov    %r11,%rax
  45ecd2:	48 99                	cqto
  45ecd4:	48 f7 f9             	idiv   %rcx
  45ecd7:	48 89 d1             	mov    %rdx,%rcx
  45ecda:	e9 b1 fc ff ff       	jmp    45e990 <op+0x690>
  45ecdf:	48 85 c9             	test   %rcx,%rcx
  45ece2:	75 0a                	jne    45ecee <op+0x9ee>
  45ece4:	40 80 e5 01          	and    $0x1,%bpl
  45ece8:	0f 85 f3 03 00 00    	jne    45f0e1 <op+0xde1>
  45ecee:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45ecf4:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
  45ecf8:	0f 84 20 04 00 00    	je     45f11e <op+0xe1e>
  45ecfe:	4c 89 d8             	mov    %r11,%rax
  45ed01:	48 99                	cqto
  45ed03:	48 f7 f9             	idiv   %rcx
  45ed06:	48 89 c1             	mov    %rax,%rcx
  45ed09:	e9 82 fc ff ff       	jmp    45e990 <op+0x690>
  45ed0e:	44 89 f2             	mov    %r14d,%edx
  45ed11:	41 83 fe 02          	cmp    $0x2,%r14d
  45ed15:	0f 84 35 03 00 00    	je     45f050 <op+0xd50>
  45ed1b:	49 39 cb             	cmp    %rcx,%r11
  45ed1e:	41 89 d6             	mov    %edx,%r14d
  45ed21:	0f 9c c1             	setl   %cl
  45ed24:	0f b6 c9             	movzbl %cl,%ecx
  45ed27:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  45ed2e:	00 00 
  45ed30:	4c 89 c8             	mov    %r9,%rax
  45ed33:	49 89 c8             	mov    %rcx,%r8
  45ed36:	44 89 f2             	mov    %r14d,%edx
  45ed39:	48 b9 00 00 00 00 ff 	movabs $0xffffffff00000000,%rcx
  45ed40:	ff ff ff 
  45ed43:	48 21 c8             	and    %rcx,%rax
  45ed46:	48 09 d0             	or     %rdx,%rax
  45ed49:	49 89 c1             	mov    %rax,%r9
  45ed4c:	41 83 fc 63          	cmp    $0x63,%r12d
  45ed50:	0f 84 02 02 00 00    	je     45ef58 <op+0xc58>
  45ed56:	89 3d e4 b3 06 00    	mov    %edi,0x6b3e4(%rip)        # 4ca140 <sp>
  45ed5c:	48 63 c7             	movslq %edi,%rax
  45ed5f:	66 0f ef c0          	pxor   %xmm0,%xmm0
  45ed63:	48 c1 e0 05          	shl    $0x5,%rax
  45ed67:	48 03 05 e2 89 07 00 	add    0x789e2(%rip),%rax        # 4d7750 <stack>
  45ed6e:	4c 89 40 10          	mov    %r8,0x10(%rax)
  45ed72:	4c 89 48 18          	mov    %r9,0x18(%rax)
  45ed76:	0f 11 00             	movups %xmm0,(%rax)
  45ed79:	e9 69 f7 ff ff       	jmp    45e4e7 <op+0x1e7>
  45ed7e:	44 89 f2             	mov    %r14d,%edx
  45ed81:	41 83 fe 02          	cmp    $0x2,%r14d
  45ed85:	0f 84 e0 02 00 00    	je     45f06b <op+0xd6b>
  45ed8b:	49 39 cb             	cmp    %rcx,%r11
  45ed8e:	41 89 d6             	mov    %edx,%r14d
  45ed91:	0f 95 c1             	setne  %cl
  45ed94:	0f b6 c9             	movzbl %cl,%ecx
  45ed97:	eb 97                	jmp    45ed30 <op+0xa30>
  45ed99:	ba 01 00 00 00       	mov    $0x1,%edx
  45ed9e:	41 83 fe 02          	cmp    $0x2,%r14d
  45eda2:	0f 84 e7 02 00 00    	je     45f08f <op+0xd8f>
  45eda8:	49 39 cb             	cmp    %rcx,%r11
  45edab:	41 89 d6             	mov    %edx,%r14d
  45edae:	0f 94 c1             	sete   %cl
  45edb1:	0f b6 c9             	movzbl %cl,%ecx
  45edb4:	e9 77 ff ff ff       	jmp    45ed30 <op+0xa30>
  45edb9:	ba 01 00 00 00       	mov    $0x1,%edx
  45edbe:	41 83 fe 02          	cmp    $0x2,%r14d
  45edc2:	0f 84 6d 02 00 00    	je     45f035 <op+0xd35>
  45edc8:	49 39 cb             	cmp    %rcx,%r11
  45edcb:	41 89 d6             	mov    %edx,%r14d
  45edce:	0f 9f c1             	setg   %cl
  45edd1:	0f b6 c9             	movzbl %cl,%ecx
  45edd4:	e9 57 ff ff ff       	jmp    45ed30 <op+0xa30>
  45edd9:	44 89 f2             	mov    %r14d,%edx
  45eddc:	eb c0                	jmp    45ed9e <op+0xa9e>
  45edde:	ba 01 00 00 00       	mov    $0x1,%edx
  45ede3:	e9 29 ff ff ff       	jmp    45ed11 <op+0xa11>
  45ede8:	ba 01 00 00 00       	mov    $0x1,%edx
  45eded:	41 83 fe 02          	cmp    $0x2,%r14d
  45edf1:	0f 84 bc 02 00 00    	je     45f0b3 <op+0xdb3>
  45edf7:	49 39 cb             	cmp    %rcx,%r11
  45edfa:	41 89 d6             	mov    %edx,%r14d
  45edfd:	0f 9d c1             	setge  %cl
  45ee00:	0f b6 c9             	movzbl %cl,%ecx
  45ee03:	e9 28 ff ff ff       	jmp    45ed30 <op+0xa30>
  45ee08:	ba 01 00 00 00       	mov    $0x1,%edx
  45ee0d:	41 83 fe 02          	cmp    $0x2,%r14d
  45ee11:	0f 84 03 02 00 00    	je     45f01a <op+0xd1a>
  45ee17:	49 39 cb             	cmp    %rcx,%r11
  45ee1a:	41 89 d6             	mov    %edx,%r14d
  45ee1d:	0f 9e c1             	setle  %cl
  45ee20:	0f b6 c9             	movzbl %cl,%ecx
  45ee23:	e9 08 ff ff ff       	jmp    45ed30 <op+0xa30>
  45ee28:	ba 01 00 00 00       	mov    $0x1,%edx
  45ee2d:	e9 4f ff ff ff       	jmp    45ed81 <op+0xa81>
  45ee32:	44 89 f2             	mov    %r14d,%edx
  45ee35:	eb 87                	jmp    45edbe <op+0xabe>
  45ee37:	44 89 f2             	mov    %r14d,%edx
  45ee3a:	eb d1                	jmp    45ee0d <op+0xb0d>
  45ee3c:	44 89 f2             	mov    %r14d,%edx
  45ee3f:	eb ac                	jmp    45eded <op+0xaed>
  45ee41:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  45ee48:	4c 89 df             	mov    %r11,%rdi
  45ee4b:	89 74 24 4c          	mov    %esi,0x4c(%rsp)
  45ee4f:	4c 89 44 24 30       	mov    %r8,0x30(%rsp)
  45ee54:	4c 89 4c 24 38       	mov    %r9,0x38(%rsp)
  45ee59:	44 89 54 24 20       	mov    %r10d,0x20(%rsp)
  45ee5e:	4c 89 5c 24 10       	mov    %r11,0x10(%rsp)
  45ee63:	4c 89 7c 24 40       	mov    %r15,0x40(%rsp)
  45ee68:	e8 93 f3 ff ff       	call   45e200 <getmathparam>
  45ee6d:	4c 8b 5c 24 10       	mov    0x10(%rsp),%r11
  45ee72:	8b 3d c8 b2 06 00    	mov    0x6b2c8(%rip),%edi        # 4ca140 <sp>
  45ee78:	8b 74 24 4c          	mov    0x4c(%rsp),%esi
  45ee7c:	4c 8b 44 24 30       	mov    0x30(%rsp),%r8
  45ee81:	4c 8b 4c 24 38       	mov    0x38(%rsp),%r9
  45ee86:	48 8b 4c 24 40       	mov    0x40(%rsp),%rcx
  45ee8b:	49 89 43 10          	mov    %rax,0x10(%r11)
  45ee8f:	49 89 53 18          	mov    %rdx,0x18(%r11)
  45ee93:	44 8b 54 24 20       	mov    0x20(%rsp),%r10d
  45ee98:	e9 6c f5 ff ff       	jmp    45e409 <op+0x109>
  45ee9d:	0f 1f 00             	nopl   (%rax)
  45eea0:	48 f7 da             	neg    %rdx
  45eea3:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45eea7:	e9 34 f6 ff ff       	jmp    45e4e0 <op+0x1e0>
  45eeac:	0f 1f 40 00          	nopl   0x0(%rax)
  45eeb0:	48 83 c0 01          	add    $0x1,%rax
  45eeb4:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45eeb8:	e9 a4 f7 ff ff       	jmp    45e661 <op+0x361>
  45eebd:	0f 1f 00             	nopl   (%rax)
  45eec0:	4c 8b 1d 59 88 07 00 	mov    0x78859(%rip),%r11        # 4d7720 <zero_mnumber>
  45eec7:	4c 8b 15 5a 88 07 00 	mov    0x7885a(%rip),%r10        # 4d7728 <zero_mnumber+0x8>
  45eece:	e9 d0 f8 ff ff       	jmp    45e7a3 <op+0x4a3>
  45eed3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45eed8:	4c 8b 3d 41 88 07 00 	mov    0x78841(%rip),%r15        # 4d7720 <zero_mnumber>
  45eedf:	48 8b 0d 42 88 07 00 	mov    0x78842(%rip),%rcx        # 4d7728 <zero_mnumber+0x8>
  45eee6:	e9 47 f8 ff ff       	jmp    45e732 <op+0x432>
  45eeeb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45eef0:	48 85 d2             	test   %rdx,%rdx
  45eef3:	0f 94 c2             	sete   %dl
  45eef6:	0f b6 d2             	movzbl %dl,%edx
  45eef9:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45eefd:	e9 de f5 ff ff       	jmp    45e4e0 <op+0x1e0>
  45ef02:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  45ef08:	48 8b 35 11 88 07 00 	mov    0x78811(%rip),%rsi        # 4d7720 <zero_mnumber>
  45ef0f:	48 8b 0d 12 88 07 00 	mov    0x78812(%rip),%rcx        # 4d7728 <zero_mnumber+0x8>
  45ef16:	e9 03 f9 ff ff       	jmp    45e81e <op+0x51e>
  45ef1b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45ef20:	48 83 e8 01          	sub    $0x1,%rax
  45ef24:	48 89 41 10          	mov    %rax,0x10(%rcx)
  45ef28:	e9 34 f7 ff ff       	jmp    45e661 <op+0x361>
  45ef2d:	0f 1f 00             	nopl   (%rax)
  45ef30:	48 f7 d2             	not    %rdx
  45ef33:	48 89 51 10          	mov    %rdx,0x10(%rcx)
  45ef37:	e9 a4 f5 ff ff       	jmp    45e4e0 <op+0x1e0>
  45ef3c:	0f 1f 40 00          	nopl   0x0(%rax)
  45ef40:	85 c0                	test   %eax,%eax
  45ef42:	0f 84 18 fb ff ff    	je     45ea60 <op+0x760>
  45ef48:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45ef4e:	31 c9                	xor    %ecx,%ecx
  45ef50:	e9 db fd ff ff       	jmp    45ed30 <op+0xa30>
  45ef55:	0f 1f 00             	nopl   (%rax)
  45ef58:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
  45ef5d:	bf fc ad 4a 00       	mov    $0x4aadfc,%edi
  45ef62:	31 c0                	xor    %eax,%eax
  45ef64:	4c 89 04 24          	mov    %r8,(%rsp)
  45ef68:	e8 43 29 04 00       	call   4a18b0 <zerr>
  45ef6d:	8b 3d cd b1 06 00    	mov    0x6b1cd(%rip),%edi        # 4ca140 <sp>
  45ef73:	4c 8b 04 24          	mov    (%rsp),%r8
  45ef77:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
  45ef7c:	e9 db fd ff ff       	jmp    45ed5c <op+0xa5c>
  45ef81:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  45ef88:	31 c0                	xor    %eax,%eax
  45ef8a:	bf fc ad 4a 00       	mov    $0x4aadfc,%edi
  45ef8f:	48 89 54 24 10       	mov    %rdx,0x10(%rsp)
  45ef94:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
  45ef99:	48 89 34 24          	mov    %rsi,(%rsp)
  45ef9d:	e8 0e 29 04 00       	call   4a18b0 <zerr>
  45efa2:	8b 05 98 b1 06 00    	mov    0x6b198(%rip),%eax        # 4ca140 <sp>
  45efa8:	48 8b 34 24          	mov    (%rsp),%rsi
  45efac:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
  45efb1:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
  45efb6:	e9 3a fa ff ff       	jmp    45e9f5 <op+0x6f5>
  45efbb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  45efc0:	48 85 f6             	test   %rsi,%rsi
  45efc3:	0f 84 85 f8 ff ff    	je     45e84e <op+0x54e>
  45efc9:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
  45efce:	e9 81 f8 ff ff       	jmp    45e854 <op+0x554>
  45efd3:	83 fe 1d             	cmp    $0x1d,%esi
  45efd6:	0f 85 cf f5 ff ff    	jne    45e5ab <op+0x2ab>
  45efdc:	85 c0                	test   %eax,%eax
  45efde:	0f 84 7c fa ff ff    	je     45ea60 <op+0x760>
  45efe4:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45efea:	31 c9                	xor    %ecx,%ecx
  45efec:	e9 a9 f9 ff ff       	jmp    45e99a <op+0x69a>
  45eff1:	31 c0                	xor    %eax,%eax
  45eff3:	bf fc ad 4a 00       	mov    $0x4aadfc,%edi
  45eff8:	4c 89 1c 24          	mov    %r11,(%rsp)
  45effc:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
  45f001:	e8 aa 28 04 00       	call   4a18b0 <zerr>
  45f006:	8b 05 34 b1 06 00    	mov    0x6b134(%rip),%eax        # 4ca140 <sp>
  45f00c:	4c 8b 04 24          	mov    (%rsp),%r8
  45f010:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
  45f015:	e9 65 f8 ff ff       	jmp    45e87f <op+0x57f>
  45f01a:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  45f01f:	66 49 0f 6e cb       	movq   %r11,%xmm1
  45f024:	31 c9                	xor    %ecx,%ecx
  45f026:	41 89 d6             	mov    %edx,%r14d
  45f029:	66 0f 2f f1          	comisd %xmm1,%xmm6
  45f02d:	0f 93 c1             	setae  %cl
  45f030:	e9 fb fc ff ff       	jmp    45ed30 <op+0xa30>
  45f035:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  45f03a:	66 49 0f 6e fb       	movq   %r11,%xmm7
  45f03f:	31 c9                	xor    %ecx,%ecx
  45f041:	41 89 d6             	mov    %edx,%r14d
  45f044:	66 0f 2f fe          	comisd %xmm6,%xmm7
  45f048:	0f 97 c1             	seta   %cl
  45f04b:	e9 e0 fc ff ff       	jmp    45ed30 <op+0xa30>
  45f050:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  45f055:	66 49 0f 6e fb       	movq   %r11,%xmm7
  45f05a:	31 c9                	xor    %ecx,%ecx
  45f05c:	41 89 d6             	mov    %edx,%r14d
  45f05f:	66 0f 2f f7          	comisd %xmm7,%xmm6
  45f063:	0f 97 c1             	seta   %cl
  45f066:	e9 c5 fc ff ff       	jmp    45ed30 <op+0xa30>
  45f06b:	66 48 0f 6e f1       	movq   %rcx,%xmm6
  45f070:	66 49 0f 6e fb       	movq   %r11,%xmm7
  45f075:	31 c9                	xor    %ecx,%ecx
  45f077:	b8 01 00 00 00       	mov    $0x1,%eax
  45f07c:	66 0f 2e fe          	ucomisd %xmm6,%xmm7
  45f080:	41 89 d6             	mov    %edx,%r14d
  45f083:	0f 9a c1             	setp   %cl
  45f086:	48 0f 45 c8          	cmovne %rax,%rcx
  45f08a:	e9 a1 fc ff ff       	jmp    45ed30 <op+0xa30>
  45f08f:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  45f094:	66 49 0f 6e f3       	movq   %r11,%xmm6
  45f099:	31 c9                	xor    %ecx,%ecx
  45f09b:	b8 00 00 00 00       	mov    $0x0,%eax
  45f0a0:	66 0f 2e f1          	ucomisd %xmm1,%xmm6
  45f0a4:	41 89 d6             	mov    %edx,%r14d
  45f0a7:	0f 9b c1             	setnp  %cl
  45f0aa:	48 0f 45 c8          	cmovne %rax,%rcx
  45f0ae:	e9 7d fc ff ff       	jmp    45ed30 <op+0xa30>
  45f0b3:	66 48 0f 6e f9       	movq   %rcx,%xmm7
  45f0b8:	66 49 0f 6e cb       	movq   %r11,%xmm1
  45f0bd:	31 c9                	xor    %ecx,%ecx
  45f0bf:	41 89 d6             	mov    %edx,%r14d
  45f0c2:	66 0f 2f cf          	comisd %xmm7,%xmm1
  45f0c6:	0f 93 c1             	setae  %cl
  45f0c9:	e9 62 fc ff ff       	jmp    45ed30 <op+0xa30>
  45f0ce:	41 f6 c6 01          	test   $0x1,%r14b
  45f0d2:	0f 84 71 fa ff ff    	je     45eb49 <op+0x849>
  45f0d8:	4d 85 db             	test   %r11,%r11
  45f0db:	0f 85 68 fa ff ff    	jne    45eb49 <op+0x849>
  45f0e1:	bf eb ad 4a 00       	mov    $0x4aadeb,%edi
  45f0e6:	e9 ea f4 ff ff       	jmp    45e5d5 <op+0x2d5>
  45f0eb:	bf 90 df 4a 00       	mov    $0x4adf90,%edi
  45f0f0:	e9 e0 f4 ff ff       	jmp    45e5d5 <op+0x2d5>
  45f0f5:	31 c9                	xor    %ecx,%ecx
  45f0f7:	e9 94 f8 ff ff       	jmp    45e990 <op+0x690>
  45f0fc:	66 0f ef c9          	pxor   %xmm1,%xmm1
  45f100:	41 be 02 00 00 00    	mov    $0x2,%r14d
  45f106:	f2 49 0f 2a cb       	cvtsi2sd %r11,%xmm1
  45f10b:	66 49 0f 7e cb       	movq   %xmm1,%r11
  45f110:	66 0f ef c9          	pxor   %xmm1,%xmm1
  45f114:	f2 48 0f 2a c9       	cvtsi2sd %rcx,%xmm1
  45f119:	e9 2b fa ff ff       	jmp    45eb49 <op+0x849>
  45f11e:	4c 89 d9             	mov    %r11,%rcx
  45f121:	48 f7 d9             	neg    %rcx
  45f124:	e9 67 f8 ff ff       	jmp    45e990 <op+0x690>
  45f129:	41 be 01 00 00 00    	mov    $0x1,%r14d
  45f12f:	b9 01 00 00 00       	mov    $0x1,%ecx
  45f134:	e9 57 f8 ff ff       	jmp    45e990 <op+0x690>

Disassembly of section .fini:
