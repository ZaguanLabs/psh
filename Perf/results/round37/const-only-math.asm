
/home/stig/dev/challenge/zsh-perf/zsh-5.9.2/.work/round37/object-probes/const-only.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <setmathvar>:
       0:	41 57                	push   %r15
       2:	49 89 ff             	mov    %rdi,%r15
       5:	41 56                	push   %r14
       7:	41 89 d6             	mov    %edx,%r14d
       a:	41 55                	push   %r13
       c:	49 89 d5             	mov    %rdx,%r13
       f:	41 54                	push   %r12
      11:	49 89 f4             	mov    %rsi,%r12
      14:	55                   	push   %rbp
      15:	48 89 d5             	mov    %rdx,%rbp
      18:	53                   	push   %rbx
      19:	48 89 f3             	mov    %rsi,%rbx
      1c:	48 83 ec 18          	sub    $0x18,%rsp
      20:	48 89 34 24          	mov    %rsi,(%rsp)
      24:	48 83 7f 08 00       	cmpq   $0x0,0x8(%rdi)
      29:	74 4e                	je     79 <setmathvar+0x79>
      2b:	48 8b 3f             	mov    (%rdi),%rdi
      2e:	be 5b 00 00 00       	mov    $0x5b,%esi
      33:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
      38:	e8 00 00 00 00       	call   3d <setmathvar+0x3d>
			39: R_X86_64_PLT32	strchr-0x4
      3d:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
      42:	48 85 c0             	test   %rax,%rax
      45:	74 0c                	je     53 <setmathvar+0x53>
      47:	89 c6                	mov    %eax,%esi
      49:	29 fe                	sub    %edi,%esi
      4b:	e8 00 00 00 00       	call   50 <setmathvar+0x50>
			4c: R_X86_64_PLT32	dupstrpfx-0x4
      50:	48 89 c7             	mov    %rax,%rdi
      53:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 5a <setmathvar+0x5a>
			56: R_X86_64_PC32	paramtab-0x4
      5a:	48 89 fe             	mov    %rdi,%rsi
      5d:	48 89 c7             	mov    %rax,%rdi
      60:	ff 50 40             	call   *0x40(%rax)
      63:	49 8b 7f 08          	mov    0x8(%r15),%rdi
      67:	48 39 47 08          	cmp    %rax,0x8(%rdi)
      6b:	0f 84 9f 00 00 00    	je     110 <setmathvar+0x110>
      71:	49 c7 47 08 00 00 00 	movq   $0x0,0x8(%r15)
      78:	00 
      79:	49 8b 3f             	mov    (%r15),%rdi
      7c:	48 85 ff             	test   %rdi,%rdi
      7f:	0f 84 cb 00 00 00    	je     150 <setmathvar+0x150>
      85:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 8b <setmathvar+0x8b>
			87: R_X86_64_PC32	noeval-0x4
      8b:	85 c0                	test   %eax,%eax
      8d:	74 19                	je     a8 <setmathvar+0xa8>
      8f:	48 83 c4 18          	add    $0x18,%rsp
      93:	4c 89 e0             	mov    %r12,%rax
      96:	4c 89 ea             	mov    %r13,%rdx
      99:	5b                   	pop    %rbx
      9a:	5d                   	pop    %rbp
      9b:	41 5c                	pop    %r12
      9d:	41 5d                	pop    %r13
      9f:	41 5e                	pop    %r14
      a1:	41 5f                	pop    %r15
      a3:	c3                   	ret
      a4:	0f 1f 40 00          	nopl   0x0(%rax)
      a8:	e8 00 00 00 00       	call   ad <setmathvar+0xad>
			a9: R_X86_64_PLT32	untokenize-0x4
      ad:	49 8b 3f             	mov    (%r15),%rdi
      b0:	48 89 de             	mov    %rbx,%rsi
      b3:	48 89 ea             	mov    %rbp,%rdx
      b6:	e8 00 00 00 00       	call   bb <setmathvar+0xbb>
			b7: R_X86_64_PLT32	setnparam-0x4
      bb:	48 85 c0             	test   %rax,%rax
      be:	74 30                	je     f0 <setmathvar+0xf0>
      c0:	8b 40 10             	mov    0x10(%rax),%eax
      c3:	83 e0 1f             	and    $0x1f,%eax
      c6:	8d 50 fc             	lea    -0x4(%rax),%edx
      c9:	83 e2 fb             	and    $0xfffffffb,%edx
      cc:	74 62                	je     130 <setmathvar+0x130>
      ce:	83 f8 02             	cmp    $0x2,%eax
      d1:	75 1d                	jne    f0 <setmathvar+0xf0>
      d3:	41 83 fe 01          	cmp    $0x1,%r14d
      d7:	74 17                	je     f0 <setmathvar+0xf0>
      d9:	66 48 0f 6e c3       	movq   %rbx,%xmm0
      de:	41 be 01 00 00 00    	mov    $0x1,%r14d
      e4:	f2 48 0f 2c c0       	cvttsd2si %xmm0,%rax
      e9:	48 89 04 24          	mov    %rax,(%rsp)
      ed:	0f 1f 00             	nopl   (%rax)
      f0:	4c 89 e8             	mov    %r13,%rax
      f3:	4c 8b 24 24          	mov    (%rsp),%r12
      f7:	48 ba 00 00 00 00 ff 	movabs $0xffffffff00000000,%rdx
      fe:	ff ff ff 
     101:	48 21 d0             	and    %rdx,%rax
     104:	4c 09 f0             	or     %r14,%rax
     107:	49 89 c5             	mov    %rax,%r13
     10a:	eb 83                	jmp    8f <setmathvar+0x8f>
     10c:	0f 1f 40 00          	nopl   0x0(%rax)
     110:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 116 <setmathvar+0x116>
			112: R_X86_64_PC32	noeval-0x4
     116:	85 d2                	test   %edx,%edx
     118:	0f 85 71 ff ff ff    	jne    8f <setmathvar+0x8f>
     11e:	48 89 de             	mov    %rbx,%rsi
     121:	48 89 ea             	mov    %rbp,%rdx
     124:	e8 00 00 00 00       	call   129 <setmathvar+0x129>
			125: R_X86_64_PLT32	setnumvalue-0x4
     129:	e9 61 ff ff ff       	jmp    8f <setmathvar+0x8f>
     12e:	66 90                	xchg   %ax,%ax
     130:	41 83 fe 02          	cmp    $0x2,%r14d
     134:	74 ba                	je     f0 <setmathvar+0xf0>
     136:	66 0f ef c9          	pxor   %xmm1,%xmm1
     13a:	41 be 02 00 00 00    	mov    $0x2,%r14d
     140:	f2 48 0f 2a cb       	cvtsi2sd %rbx,%xmm1
     145:	f2 0f 11 0c 24       	movsd  %xmm1,(%rsp)
     14a:	eb a4                	jmp    f0 <setmathvar+0xf0>
     14c:	0f 1f 40 00          	nopl   0x0(%rax)
     150:	31 c0                	xor    %eax,%eax
     152:	bf 00 00 00 00       	mov    $0x0,%edi
			153: R_X86_64_32	.rodata.str1.8
     157:	45 31 e4             	xor    %r12d,%r12d
     15a:	e8 00 00 00 00       	call   15f <setmathvar+0x15f>
			15b: R_X86_64_PLT32	zerr-0x4
     15f:	4c 89 e8             	mov    %r13,%rax
     162:	48 ba 00 00 00 00 ff 	movabs $0xffffffff00000000,%rdx
     169:	ff ff ff 
     16c:	48 21 d0             	and    %rdx,%rax
     16f:	48 83 c8 01          	or     $0x1,%rax
     173:	49 89 c5             	mov    %rax,%r13
     176:	e9 14 ff ff ff       	jmp    8f <setmathvar+0x8f>
     17b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000000180 <math_strtod>:
     180:	41 55                	push   %r13
     182:	41 54                	push   %r12
     184:	55                   	push   %rbp
     185:	48 89 f5             	mov    %rsi,%rbp
     188:	53                   	push   %rbx
     189:	48 89 fb             	mov    %rdi,%rbx
     18c:	48 83 ec 18          	sub    $0x18,%rsp
     190:	0f b6 07             	movzbl (%rdi),%eax
     193:	8d 50 d0             	lea    -0x30(%rax),%edx
     196:	80 fa 09             	cmp    $0x9,%dl
     199:	76 65                	jbe    200 <math_strtod+0x80>
     19b:	3c 2e                	cmp    $0x2e,%al
     19d:	74 61                	je     200 <math_strtod+0x80>
     19f:	31 f6                	xor    %esi,%esi
     1a1:	bf 01 00 00 00       	mov    $0x1,%edi
     1a6:	e8 00 00 00 00       	call   1ab <math_strtod+0x2b>
			1a7: R_X86_64_PLT32	setlocale-0x4
     1ab:	48 89 c7             	mov    %rax,%rdi
     1ae:	e8 00 00 00 00       	call   1b3 <math_strtod+0x33>
			1af: R_X86_64_PLT32	dupstring-0x4
     1b3:	be 00 00 00 00       	mov    $0x0,%esi
			1b4: R_X86_64_32	.rodata.str1.1+0x2
     1b8:	bf 01 00 00 00       	mov    $0x1,%edi
     1bd:	49 89 c4             	mov    %rax,%r12
     1c0:	e8 00 00 00 00       	call   1c5 <math_strtod+0x45>
			1c1: R_X86_64_PLT32	setlocale-0x4
     1c5:	48 89 ee             	mov    %rbp,%rsi
     1c8:	48 89 df             	mov    %rbx,%rdi
     1cb:	e8 00 00 00 00       	call   1d0 <math_strtod+0x50>
			1cc: R_X86_64_PLT32	strtod-0x4
     1d0:	4d 85 e4             	test   %r12,%r12
     1d3:	74 19                	je     1ee <math_strtod+0x6e>
     1d5:	4c 89 e6             	mov    %r12,%rsi
     1d8:	bf 01 00 00 00       	mov    $0x1,%edi
     1dd:	f2 0f 11 44 24 08    	movsd  %xmm0,0x8(%rsp)
     1e3:	e8 00 00 00 00       	call   1e8 <math_strtod+0x68>
			1e4: R_X86_64_PLT32	setlocale-0x4
     1e8:	f2 0f 10 44 24 08    	movsd  0x8(%rsp),%xmm0
     1ee:	48 83 c4 18          	add    $0x18,%rsp
     1f2:	5b                   	pop    %rbx
     1f3:	5d                   	pop    %rbp
     1f4:	41 5c                	pop    %r12
     1f6:	41 5d                	pop    %r13
     1f8:	c3                   	ret
     1f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
     200:	e8 00 00 00 00       	call   205 <math_strtod+0x85>
			201: R_X86_64_PLT32	__errno_location-0x4
     205:	31 ff                	xor    %edi,%edi
     207:	44 8b 28             	mov    (%rax),%r13d
     20a:	49 89 c4             	mov    %rax,%r12
     20d:	e8 00 00 00 00       	call   212 <math_strtod+0x92>
			20e: R_X86_64_PLT32	uselocale-0x4
     212:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
     216:	74 08                	je     220 <math_strtod+0xa0>
     218:	45 89 2c 24          	mov    %r13d,(%r12)
     21c:	eb 81                	jmp    19f <math_strtod+0x1f>
     21e:	66 90                	xchg   %ax,%ax
     220:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 227 <math_strtod+0xa7>
			223: R_X86_64_PC32	.bss+0x64
     227:	48 85 c0             	test   %rax,%rax
     22a:	74 24                	je     250 <math_strtod+0xd0>
     22c:	45 89 2c 24          	mov    %r13d,(%r12)
     230:	48 83 c4 18          	add    $0x18,%rsp
     234:	48 89 ee             	mov    %rbp,%rsi
     237:	48 89 df             	mov    %rbx,%rdi
     23a:	48 89 c2             	mov    %rax,%rdx
     23d:	5b                   	pop    %rbx
     23e:	5d                   	pop    %rbp
     23f:	41 5c                	pop    %r12
     241:	41 5d                	pop    %r13
     243:	e9 00 00 00 00       	jmp    248 <math_strtod+0xc8>
			244: R_X86_64_PLT32	strtod_l-0x4
     248:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
     24f:	00 
     250:	31 d2                	xor    %edx,%edx
     252:	be 00 00 00 00       	mov    $0x0,%esi
			253: R_X86_64_32	.rodata.str1.1
     257:	bf bf 1f 00 00       	mov    $0x1fbf,%edi
     25c:	e8 00 00 00 00       	call   261 <math_strtod+0xe1>
			25d: R_X86_64_PLT32	newlocale-0x4
     261:	45 89 2c 24          	mov    %r13d,(%r12)
     265:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 26c <math_strtod+0xec>
			268: R_X86_64_PC32	.bss+0x64
     26c:	48 85 c0             	test   %rax,%rax
     26f:	0f 84 2a ff ff ff    	je     19f <math_strtod+0x1f>
     275:	eb b9                	jmp    230 <math_strtod+0xb0>
     277:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
     27e:	00 00 

0000000000000280 <lexconstant>:
     280:	53                   	push   %rbx
     281:	48 83 ec 20          	sub    $0x20,%rsp
     285:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 28c <lexconstant+0xc>
			288: R_X86_64_PC32	.bss+0x8c
     28c:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
     291:	0f b6 17             	movzbl (%rdi),%edx
     294:	80 fa 2d             	cmp    $0x2d,%dl
     297:	0f 84 d3 01 00 00    	je     470 <lexconstant+0x1f0>
     29d:	48 89 f9             	mov    %rdi,%rcx
     2a0:	80 fa 9b             	cmp    $0x9b,%dl
     2a3:	0f 84 c7 01 00 00    	je     470 <lexconstant+0x1f0>
     2a9:	80 fa 30             	cmp    $0x30,%dl
     2ac:	0f 84 d4 01 00 00    	je     486 <lexconstant+0x206>
     2b2:	80 fa 5f             	cmp    $0x5f,%dl
     2b5:	74 0d                	je     2c4 <lexconstant+0x44>
     2b7:	0f b6 c2             	movzbl %dl,%eax
     2ba:	f6 84 00 00 00 00 00 	testb  $0x1,0x0(%rax,%rax,1)
     2c1:	01 
			2bd: R_X86_64_32S	typtab
     2c2:	74 3e                	je     302 <lexconstant+0x82>
     2c4:	48 8d 41 01          	lea    0x1(%rcx),%rax
     2c8:	66 90                	xchg   %ax,%ax
     2ca:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
     2d1:	00 00 00 00 
     2d5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
     2dc:	00 00 00 00 
     2e0:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
     2e5:	0f b6 30             	movzbl (%rax),%esi
     2e8:	48 89 c1             	mov    %rax,%rcx
     2eb:	48 83 c0 01          	add    $0x1,%rax
     2ef:	48 89 f2             	mov    %rsi,%rdx
     2f2:	f6 84 36 00 00 00 00 	testb  $0x1,0x0(%rsi,%rsi,1)
     2f9:	01 
			2f5: R_X86_64_32S	typtab
     2fa:	75 e4                	jne    2e0 <lexconstant+0x60>
     2fc:	40 80 fe 5f          	cmp    $0x5f,%sil
     300:	74 de                	je     2e0 <lexconstant+0x60>
     302:	8d 42 d2             	lea    -0x2e(%rdx),%eax
     305:	3c 37                	cmp    $0x37,%al
     307:	0f 87 fb 02 00 00    	ja     608 <lexconstant+0x388>
     30d:	48 be 01 00 80 00 00 	movabs $0x80000000800001,%rsi
     314:	00 80 00 
     317:	48 0f a3 c6          	bt     %rax,%rsi
     31b:	0f 83 e7 02 00 00    	jae    608 <lexconstant+0x388>
     321:	c7 05 00 00 00 00 02 	movl   $0x2,0x0(%rip)        # 32b <lexconstant+0xab>
     328:	00 00 00 
			323: R_X86_64_PC32	.bss+0x80
     32b:	80 fa 2e             	cmp    $0x2e,%dl
     32e:	0f 84 6c 02 00 00    	je     5a0 <lexconstant+0x320>
     334:	48 8b 74 24 18       	mov    0x18(%rsp),%rsi
     339:	0f b6 06             	movzbl (%rsi),%eax
     33c:	83 e0 df             	and    $0xffffffdf,%eax
     33f:	3c 45                	cmp    $0x45,%al
     341:	75 7b                	jne    3be <lexconstant+0x13e>
     343:	48 8d 46 01          	lea    0x1(%rsi),%rax
     347:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
     34c:	0f b6 56 01          	movzbl 0x1(%rsi),%edx
     350:	8d 4a d5             	lea    -0x2b(%rdx),%ecx
     353:	81 e1 fd 00 00 00    	and    $0xfd,%ecx
     359:	74 05                	je     360 <lexconstant+0xe0>
     35b:	80 fa 9b             	cmp    $0x9b,%dl
     35e:	75 0d                	jne    36d <lexconstant+0xed>
     360:	48 8d 46 02          	lea    0x2(%rsi),%rax
     364:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
     369:	0f b6 56 02          	movzbl 0x2(%rsi),%edx
     36d:	80 fa 5f             	cmp    $0x5f,%dl
     370:	74 0e                	je     380 <lexconstant+0x100>
     372:	f6 84 12 00 00 00 00 	testb  $0x1,0x0(%rdx,%rdx,1)
     379:	01 
			375: R_X86_64_32S	typtab
     37a:	0f 84 a3 03 00 00    	je     723 <lexconstant+0x4a3>
     380:	48 83 c0 01          	add    $0x1,%rax
     384:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
     38a:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
     391:	00 00 00 00 
     395:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
     39c:	00 00 00 00 
     3a0:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
     3a5:	0f b6 10             	movzbl (%rax),%edx
     3a8:	48 89 c6             	mov    %rax,%rsi
     3ab:	48 83 c0 01          	add    $0x1,%rax
     3af:	80 fa 5f             	cmp    $0x5f,%dl
     3b2:	74 ec                	je     3a0 <lexconstant+0x120>
     3b4:	f6 84 12 00 00 00 00 	testb  $0x1,0x0(%rdx,%rdx,1)
     3bb:	01 
			3b7: R_X86_64_32S	typtab
     3bc:	75 e2                	jne    3a0 <lexconstant+0x120>
     3be:	48 39 f7             	cmp    %rsi,%rdi
     3c1:	73 64                	jae    427 <lexconstant+0x1a7>
     3c3:	48 89 f8             	mov    %rdi,%rax
     3c6:	eb 11                	jmp    3d9 <lexconstant+0x159>
     3c8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
     3cf:	00 
     3d0:	48 83 c0 01          	add    $0x1,%rax
     3d4:	48 39 f0             	cmp    %rsi,%rax
     3d7:	74 4e                	je     427 <lexconstant+0x1a7>
     3d9:	80 38 5f             	cmpb   $0x5f,(%rax)
     3dc:	75 f2                	jne    3d0 <lexconstant+0x150>
     3de:	48 29 fe             	sub    %rdi,%rsi
     3e1:	48 89 34 24          	mov    %rsi,(%rsp)
     3e5:	89 f3                	mov    %esi,%ebx
     3e7:	e8 00 00 00 00       	call   3ec <lexconstant+0x16c>
			3e8: R_X86_64_PLT32	dupstring-0x4
     3ec:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 3f3 <lexconstant+0x173>
			3ef: R_X86_64_PC32	.bss+0x8c
     3f3:	48 89 c7             	mov    %rax,%rdi
     3f6:	8b 04 24             	mov    (%rsp),%eax
     3f9:	85 c0                	test   %eax,%eax
     3fb:	75 0c                	jne    409 <lexconstant+0x189>
     3fd:	eb 28                	jmp    427 <lexconstant+0x1a7>
     3ff:	90                   	nop
     400:	48 83 c7 01          	add    $0x1,%rdi
     404:	83 eb 01             	sub    $0x1,%ebx
     407:	74 17                	je     420 <lexconstant+0x1a0>
     409:	80 3f 5f             	cmpb   $0x5f,(%rdi)
     40c:	75 f2                	jne    400 <lexconstant+0x180>
     40e:	48 89 3c 24          	mov    %rdi,(%rsp)
     412:	e8 00 00 00 00       	call   417 <lexconstant+0x197>
			413: R_X86_64_PLT32	chuck-0x4
     417:	48 8b 3c 24          	mov    (%rsp),%rdi
     41b:	83 eb 01             	sub    $0x1,%ebx
     41e:	75 e9                	jne    409 <lexconstant+0x189>
     420:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 427 <lexconstant+0x1a7>
			423: R_X86_64_PC32	.bss+0x8c
     427:	48 8d 74 24 18       	lea    0x18(%rsp),%rsi
     42c:	e8 4f fd ff ff       	call   180 <math_strtod>
     431:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
     436:	48 39 05 00 00 00 00 	cmp    %rax,0x0(%rip)        # 43d <lexconstant+0x1bd>
			439: R_X86_64_PC32	.bss+0x8c
     43d:	f2 0f 11 05 00 00 00 	movsd  %xmm0,0x0(%rip)        # 445 <lexconstant+0x1c5>
     444:	00 
			441: R_X86_64_PC32	.bss+0x7c
     445:	0f 84 25 02 00 00    	je     670 <lexconstant+0x3f0>
     44b:	80 38 2e             	cmpb   $0x2e,(%rax)
     44e:	0f 84 1c 02 00 00    	je     670 <lexconstant+0x3f0>
     454:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 45b <lexconstant+0x1db>
			457: R_X86_64_PC32	.bss+0x8c
     45b:	48 83 c4 20          	add    $0x20,%rsp
     45f:	b8 2f 00 00 00       	mov    $0x2f,%eax
     464:	5b                   	pop    %rbx
     465:	c3                   	ret
     466:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
     46d:	00 00 00 
     470:	48 8d 4f 01          	lea    0x1(%rdi),%rcx
     474:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
     479:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     47d:	80 fa 30             	cmp    $0x30,%dl
     480:	0f 85 2c fe ff ff    	jne    2b2 <lexconstant+0x32>
     486:	48 8d 59 01          	lea    0x1(%rcx),%rbx
     48a:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
     48f:	48 89 0c 24          	mov    %rcx,(%rsp)
     493:	48 89 5c 24 18       	mov    %rbx,0x18(%rsp)
     498:	e8 00 00 00 00       	call   49d <lexconstant+0x21d>
			499: R_X86_64_PLT32	__ctype_tolower_loc-0x4
     49d:	48 8b 0c 24          	mov    (%rsp),%rcx
     4a1:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
     4a6:	48 8b 00             	mov    (%rax),%rax
     4a9:	48 0f be 49 01       	movsbq 0x1(%rcx),%rcx
     4ae:	44 8b 04 88          	mov    (%rax,%rcx,4),%r8d
     4b2:	48 89 ca             	mov    %rcx,%rdx
     4b5:	41 83 f8 78          	cmp    $0x78,%r8d
     4b9:	0f 84 d5 01 00 00    	je     694 <lexconstant+0x414>
     4bf:	41 83 f8 62          	cmp    $0x62,%r8d
     4c3:	0f 84 cb 01 00 00    	je     694 <lexconstant+0x414>
     4c9:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 4d0 <lexconstant+0x250>
			4cb: R_X86_64_PC32	opts+0x7b
     4d0:	48 89 d9             	mov    %rbx,%rcx
     4d3:	0f 84 d9 fd ff ff    	je     2b2 <lexconstant+0x32>
     4d9:	80 fa 5f             	cmp    $0x5f,%dl
     4dc:	74 22                	je     500 <lexconstant+0x280>
     4de:	0f b6 d2             	movzbl %dl,%edx
     4e1:	f6 84 12 00 00 00 00 	testb  $0x1,0x0(%rdx,%rdx,1)
     4e8:	01 
			4e4: R_X86_64_32S	typtab
     4e9:	0f 84 98 01 00 00    	je     687 <lexconstant+0x407>
     4ef:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
     4f5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
     4fc:	00 00 00 00 
     500:	0f b6 51 01          	movzbl 0x1(%rcx),%edx
     504:	48 83 c1 01          	add    $0x1,%rcx
     508:	48 89 d0             	mov    %rdx,%rax
     50b:	f6 84 12 00 00 00 00 	testb  $0x1,0x0(%rdx,%rdx,1)
     512:	01 
			50e: R_X86_64_32S	typtab
     513:	75 eb                	jne    500 <lexconstant+0x280>
     515:	80 fa 5f             	cmp    $0x5f,%dl
     518:	74 e6                	je     500 <lexconstant+0x280>
     51a:	48 39 cb             	cmp    %rcx,%rbx
     51d:	0f 83 64 01 00 00    	jae    687 <lexconstant+0x407>
     523:	80 fa 23             	cmp    $0x23,%dl
     526:	0f 84 5b 01 00 00    	je     687 <lexconstant+0x407>
     52c:	83 e8 2e             	sub    $0x2e,%eax
     52f:	3c 37                	cmp    $0x37,%al
     531:	77 14                	ja     547 <lexconstant+0x2c7>
     533:	48 ba 01 00 80 00 00 	movabs $0x80000000800001,%rdx
     53a:	00 80 00 
     53d:	48 0f a3 c2          	bt     %rax,%rdx
     541:	0f 82 40 01 00 00    	jb     687 <lexconstant+0x407>
     547:	31 d2                	xor    %edx,%edx
     549:	b9 01 00 00 00       	mov    $0x1,%ecx
     54e:	be 00 00 00 00       	mov    $0x0,%esi
			54f: R_X86_64_32	.bss+0x90
     553:	e8 00 00 00 00       	call   558 <lexconstant+0x2d8>
			554: R_X86_64_PLT32	zstrtol_underscore-0x4
     558:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 55f <lexconstant+0x2df>
			55a: R_X86_64_PC32	opts+0x38
     55f:	c7 05 00 00 00 00 08 	movl   $0x8,0x0(%rip)        # 569 <lexconstant+0x2e9>
     566:	00 00 00 
			561: R_X86_64_PC32	lastbase-0x8
     569:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 570 <lexconstant+0x2f0>
			56c: R_X86_64_PC32	.bss+0x7c
     570:	0f 84 e5 fe ff ff    	je     45b <lexconstant+0x1db>
     576:	c7 05 00 00 00 00 02 	movl   $0x2,0x0(%rip)        # 580 <lexconstant+0x300>
     57d:	00 00 00 
			578: R_X86_64_PC32	.bss+0x80
     580:	66 0f ef c0          	pxor   %xmm0,%xmm0
     584:	f2 48 0f 2a c0       	cvtsi2sd %rax,%xmm0
     589:	f2 0f 11 05 00 00 00 	movsd  %xmm0,0x0(%rip)        # 591 <lexconstant+0x311>
     590:	00 
			58d: R_X86_64_PC32	.bss+0x7c
     591:	e9 c5 fe ff ff       	jmp    45b <lexconstant+0x1db>
     596:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
     59d:	00 00 00 
     5a0:	48 8d 71 01          	lea    0x1(%rcx),%rsi
     5a4:	48 89 74 24 18       	mov    %rsi,0x18(%rsp)
     5a9:	0f b6 41 01          	movzbl 0x1(%rcx),%eax
     5ad:	3c 5f                	cmp    $0x5f,%al
     5af:	74 11                	je     5c2 <lexconstant+0x342>
     5b1:	0f b6 d0             	movzbl %al,%edx
     5b4:	f6 84 12 00 00 00 00 	testb  $0x1,0x0(%rdx,%rdx,1)
     5bb:	01 
			5b7: R_X86_64_32S	typtab
     5bc:	0f 84 7a fd ff ff    	je     33c <lexconstant+0xbc>
     5c2:	48 83 c1 02          	add    $0x2,%rcx
     5c6:	0f 1f 40 00          	nopl   0x0(%rax)
     5ca:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
     5d1:	00 00 00 00 
     5d5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
     5dc:	00 00 00 00 
     5e0:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
     5e5:	0f b6 01             	movzbl (%rcx),%eax
     5e8:	48 89 ce             	mov    %rcx,%rsi
     5eb:	48 83 c1 01          	add    $0x1,%rcx
     5ef:	3c 5f                	cmp    $0x5f,%al
     5f1:	74 ed                	je     5e0 <lexconstant+0x360>
     5f3:	0f b6 d0             	movzbl %al,%edx
     5f6:	f6 84 12 00 00 00 00 	testb  $0x1,0x0(%rdx,%rdx,1)
     5fd:	01 
			5f9: R_X86_64_32S	typtab
     5fe:	75 e0                	jne    5e0 <lexconstant+0x360>
     600:	e9 37 fd ff ff       	jmp    33c <lexconstant+0xbc>
     605:	0f 1f 00             	nopl   (%rax)
     608:	ba 0a 00 00 00       	mov    $0xa,%edx
     60d:	b9 01 00 00 00       	mov    $0x1,%ecx
     612:	be 00 00 00 00       	mov    $0x0,%esi
			613: R_X86_64_32	.bss+0x90
     617:	e8 00 00 00 00       	call   61c <lexconstant+0x39c>
			618: R_X86_64_PLT32	zstrtol_underscore-0x4
     61c:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 623 <lexconstant+0x3a3>
			61f: R_X86_64_PC32	.bss+0x7c
     623:	48 89 c2             	mov    %rax,%rdx
     626:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 62d <lexconstant+0x3ad>
			629: R_X86_64_PC32	.bss+0x8c
     62d:	80 38 23             	cmpb   $0x23,(%rax)
     630:	0f 84 c1 00 00 00    	je     6f7 <lexconstant+0x477>
     636:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 63d <lexconstant+0x3bd>
			638: R_X86_64_PC32	opts+0x38
     63d:	0f 84 18 fe ff ff    	je     45b <lexconstant+0x1db>
     643:	c7 05 00 00 00 00 02 	movl   $0x2,0x0(%rip)        # 64d <lexconstant+0x3cd>
     64a:	00 00 00 
			645: R_X86_64_PC32	.bss+0x80
     64d:	66 0f ef c0          	pxor   %xmm0,%xmm0
     651:	f2 48 0f 2a 05 00 00 	cvtsi2sdq 0x0(%rip),%xmm0        # 65a <lexconstant+0x3da>
     658:	00 00 
			656: R_X86_64_PC32	.bss+0x7c
     65a:	f2 0f 11 05 00 00 00 	movsd  %xmm0,0x0(%rip)        # 662 <lexconstant+0x3e2>
     661:	00 
			65e: R_X86_64_PC32	.bss+0x7c
     662:	e9 f4 fd ff ff       	jmp    45b <lexconstant+0x1db>
     667:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
     66e:	00 00 
     670:	31 c0                	xor    %eax,%eax
     672:	bf 00 00 00 00       	mov    $0x0,%edi
			673: R_X86_64_32	.rodata.str1.1+0x8
     677:	e8 00 00 00 00       	call   67c <lexconstant+0x3fc>
			678: R_X86_64_PLT32	zerr-0x4
     67c:	48 83 c4 20          	add    $0x20,%rsp
     680:	b8 2c 00 00 00       	mov    $0x2c,%eax
     685:	5b                   	pop    %rbx
     686:	c3                   	ret
     687:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
     68c:	0f b6 11             	movzbl (%rcx),%edx
     68f:	e9 1e fc ff ff       	jmp    2b2 <lexconstant+0x32>
     694:	31 d2                	xor    %edx,%edx
     696:	b9 01 00 00 00       	mov    $0x1,%ecx
     69b:	be 00 00 00 00       	mov    $0x0,%esi
			69c: R_X86_64_32	.bss+0x90
     6a0:	44 89 04 24          	mov    %r8d,(%rsp)
     6a4:	e8 00 00 00 00       	call   6a9 <lexconstant+0x429>
			6a5: R_X86_64_PLT32	zstrtol_underscore-0x4
     6a9:	83 3c 24 62          	cmpl   $0x62,(%rsp)
     6ad:	b9 02 00 00 00       	mov    $0x2,%ecx
     6b2:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 6b9 <lexconstant+0x439>
			6b5: R_X86_64_PC32	.bss+0x7c
     6b9:	48 89 c2             	mov    %rax,%rdx
     6bc:	b8 10 00 00 00       	mov    $0x10,%eax
     6c1:	0f 44 c1             	cmove  %ecx,%eax
     6c4:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 6cb <lexconstant+0x44b>
			6c6: R_X86_64_PC32	opts+0x38
     6cb:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 6d1 <lexconstant+0x451>
			6cd: R_X86_64_PC32	lastbase-0x4
     6d1:	0f 84 84 fd ff ff    	je     45b <lexconstant+0x1db>
     6d7:	c7 05 00 00 00 00 02 	movl   $0x2,0x0(%rip)        # 6e1 <lexconstant+0x461>
     6de:	00 00 00 
			6d9: R_X86_64_PC32	.bss+0x80
     6e1:	66 0f ef c0          	pxor   %xmm0,%xmm0
     6e5:	f2 48 0f 2a c2       	cvtsi2sd %rdx,%xmm0
     6ea:	f2 0f 11 05 00 00 00 	movsd  %xmm0,0x0(%rip)        # 6f2 <lexconstant+0x472>
     6f1:	00 
			6ee: R_X86_64_PC32	.bss+0x7c
     6f2:	e9 64 fd ff ff       	jmp    45b <lexconstant+0x1db>
     6f7:	48 8d 78 01          	lea    0x1(%rax),%rdi
     6fb:	b9 01 00 00 00       	mov    $0x1,%ecx
     700:	be 00 00 00 00       	mov    $0x0,%esi
			701: R_X86_64_32	.bss+0x90
     705:	89 15 00 00 00 00    	mov    %edx,0x0(%rip)        # 70b <lexconstant+0x48b>
			707: R_X86_64_PC32	lastbase-0x4
     70b:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 712 <lexconstant+0x492>
			70e: R_X86_64_PC32	.bss+0x8c
     712:	e8 00 00 00 00       	call   717 <lexconstant+0x497>
			713: R_X86_64_PLT32	zstrtol_underscore-0x4
     717:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 71e <lexconstant+0x49e>
			71a: R_X86_64_PC32	.bss+0x7c
     71e:	e9 13 ff ff ff       	jmp    636 <lexconstant+0x3b6>
     723:	48 89 c6             	mov    %rax,%rsi
     726:	e9 93 fc ff ff       	jmp    3be <lexconstant+0x13e>
     72b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000000730 <zzlex>:
     730:	48 83 ec 28          	sub    $0x28,%rsp
     734:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 73b <zzlex+0xb>
			737: R_X86_64_PC32	.bss+0x8c
     73b:	c7 05 00 00 00 00 01 	movl   $0x1,0x0(%rip)        # 745 <zzlex+0x15>
     742:	00 00 00 
			73d: R_X86_64_PC32	.bss+0x80
     745:	4c 8d 47 01          	lea    0x1(%rdi),%r8
     749:	4c 89 05 00 00 00 00 	mov    %r8,0x0(%rip)        # 750 <zzlex+0x20>
			74c: R_X86_64_PC32	.bss+0x8c
     750:	41 0f b6 40 ff       	movzbl -0x1(%r8),%eax
     755:	3c 7f                	cmp    $0x7f,%al
     757:	74 2f                	je     788 <zzlex+0x58>
     759:	84 c0                	test   %al,%al
     75b:	78 13                	js     770 <zzlex+0x40>
     75d:	3c 7e                	cmp    $0x7e,%al
     75f:	77 27                	ja     788 <zzlex+0x58>
     761:	ff 24 c5 00 00 00 00 	jmp    *0x0(,%rax,8)
			764: R_X86_64_32S	.rodata
     768:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
     76f:	00 
     770:	3c 9b                	cmp    $0x9b,%al
     772:	0f 84 b8 00 00 00    	je     830 <zzlex+0x100>
     778:	3c 9e                	cmp    $0x9e,%al
     77a:	75 0c                	jne    788 <zzlex+0x58>
     77c:	4c 89 c7             	mov    %r8,%rdi
     77f:	eb c4                	jmp    745 <zzlex+0x15>
     781:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
     788:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 78f <zzlex+0x5f>
			78b: R_X86_64_PC32	.bss+0x8c
     78f:	0f b6 17             	movzbl (%rdi),%edx
     792:	f6 84 12 00 00 00 00 	testb  $0x1,0x0(%rdx,%rdx,1)
     799:	01 
			795: R_X86_64_32S	typtab
     79a:	0f 85 58 04 00 00    	jne    bf8 <zzlex+0x4c8>
     7a0:	80 fa 2e             	cmp    $0x2e,%dl
     7a3:	0f 84 4f 04 00 00    	je     bf8 <zzlex+0x4c8>
     7a9:	80 fa 23             	cmp    $0x23,%dl
     7ac:	0f 85 9e 05 00 00    	jne    d50 <zzlex+0x620>
     7b2:	4c 89 05 00 00 00 00 	mov    %r8,0x0(%rip)        # 7b9 <zzlex+0x89>
			7b5: R_X86_64_PC32	.bss+0x8c
     7b9:	0f b6 47 01          	movzbl 0x1(%rdi),%eax
     7bd:	3c 5c                	cmp    $0x5c,%al
     7bf:	0f 84 55 06 00 00    	je     e1a <zzlex+0x6ea>
     7c5:	3c 23                	cmp    $0x23,%al
     7c7:	0f 84 4d 06 00 00    	je     e1a <zzlex+0x6ea>
     7cd:	4c 89 c7             	mov    %r8,%rdi
     7d0:	31 d2                	xor    %edx,%edx
     7d2:	be 80 00 00 00       	mov    $0x80,%esi
     7d7:	e8 00 00 00 00       	call   7dc <zzlex+0xac>
			7d8: R_X86_64_PLT32	itype_end-0x4
     7dc:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 7e3 <zzlex+0xb3>
			7df: R_X86_64_PC32	.bss+0x8c
     7e3:	48 39 c7             	cmp    %rax,%rdi
     7e6:	0f 84 a1 08 00 00    	je     108d <zzlex+0x95d>
     7ec:	48 89 c6             	mov    %rax,%rsi
     7ef:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 7f6 <zzlex+0xc6>
			7f2: R_X86_64_PC32	.bss+0x8c
     7f6:	48 29 fe             	sub    %rdi,%rsi
     7f9:	48 83 fe 03          	cmp    $0x3,%rsi
     7fd:	0f 84 d5 07 00 00    	je     fd8 <zzlex+0x8a8>
     803:	44 0f b6 00          	movzbl (%rax),%r8d
     807:	41 80 f8 5b          	cmp    $0x5b,%r8b
     80b:	0f 84 f4 08 00 00    	je     1105 <zzlex+0x9d5>
     811:	e8 00 00 00 00       	call   816 <zzlex+0xe6>
			812: R_X86_64_PLT32	dupstrpfx-0x4
     816:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 81d <zzlex+0xed>
			819: R_X86_64_PC32	.bss+0x74
     81d:	b8 32 00 00 00       	mov    $0x32,%eax
     822:	48 83 c4 28          	add    $0x28,%rsp
     826:	c3                   	ret
     827:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
     82e:	00 00 
     830:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     834:	80 fa 2d             	cmp    $0x2d,%dl
     837:	0f 84 03 04 00 00    	je     c40 <zzlex+0x510>
     83d:	80 fa 9b             	cmp    $0x9b,%dl
     840:	0f 84 fa 03 00 00    	je     c40 <zzlex+0x510>
     846:	80 fa 3d             	cmp    $0x3d,%dl
     849:	0f 84 63 07 00 00    	je     fb2 <zzlex+0x882>
     84f:	8b 0d 00 00 00 00    	mov    0x0(%rip),%ecx        # 855 <zzlex+0x125>
			851: R_X86_64_PC32	.data
     855:	b8 0f 00 00 00       	mov    $0xf,%eax
     85a:	85 c9                	test   %ecx,%ecx
     85c:	74 c4                	je     822 <zzlex+0xf2>
     85e:	0f b6 c2             	movzbl %dl,%eax
     861:	f6 84 00 00 00 00 00 	testb  $0x1,0x0(%rax,%rax,1)
     868:	01 
			864: R_X86_64_32S	typtab
     869:	75 0a                	jne    875 <zzlex+0x145>
     86b:	b8 07 00 00 00       	mov    $0x7,%eax
     870:	80 fa 2e             	cmp    $0x2e,%dl
     873:	75 ad                	jne    822 <zzlex+0xf2>
     875:	e8 06 fa ff ff       	call   280 <lexconstant>
     87a:	83 f8 2f             	cmp    $0x2f,%eax
     87d:	0f 84 0c 07 00 00    	je     f8f <zzlex+0x85f>
     883:	66 90                	xchg   %ax,%ax
     885:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
     88c:	00 00 00 00 
     890:	b8 2c 00 00 00       	mov    $0x2c,%eax
     895:	eb 8b                	jmp    822 <zzlex+0xf2>
     897:	b8 02 00 00 00       	mov    $0x2,%eax
     89c:	80 7f 01 3d          	cmpb   $0x3d,0x1(%rdi)
     8a0:	75 80                	jne    822 <zzlex+0xf2>
     8a2:	48 83 c7 02          	add    $0x2,%rdi
     8a6:	b8 17 00 00 00       	mov    $0x17,%eax
     8ab:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 8b2 <zzlex+0x182>
			8ae: R_X86_64_PC32	.bss+0x8c
     8b2:	e9 6b ff ff ff       	jmp    822 <zzlex+0xf2>
     8b7:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 8be <zzlex+0x18e>
			8ba: R_X86_64_PC32	.bss+0x8c
     8be:	eb d0                	jmp    890 <zzlex+0x160>
     8c0:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     8c4:	80 fa 26             	cmp    $0x26,%dl
     8c7:	0f 84 c3 03 00 00    	je     c90 <zzlex+0x560>
     8cd:	b8 08 00 00 00       	mov    $0x8,%eax
     8d2:	80 fa 3d             	cmp    $0x3d,%dl
     8d5:	0f 85 47 ff ff ff    	jne    822 <zzlex+0xf2>
     8db:	48 83 c7 02          	add    $0x2,%rdi
     8df:	b8 23 00 00 00       	mov    $0x23,%eax
     8e4:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 8eb <zzlex+0x1bb>
			8e7: R_X86_64_PC32	.bss+0x8c
     8eb:	e9 32 ff ff ff       	jmp    822 <zzlex+0xf2>
     8f0:	b8 2b 00 00 00       	mov    $0x2b,%eax
     8f5:	e9 28 ff ff ff       	jmp    822 <zzlex+0xf2>
     8fa:	b8 0d 00 00 00       	mov    $0xd,%eax
     8ff:	80 7f 01 3d          	cmpb   $0x3d,0x1(%rdi)
     903:	0f 85 19 ff ff ff    	jne    822 <zzlex+0xf2>
     909:	48 83 c7 02          	add    $0x2,%rdi
     90d:	b8 22 00 00 00       	mov    $0x22,%eax
     912:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 919 <zzlex+0x1e9>
			915: R_X86_64_PC32	.bss+0x8c
     919:	e9 04 ff ff ff       	jmp    822 <zzlex+0xf2>
     91e:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 925 <zzlex+0x1f5>
			921: R_X86_64_PC32	mypid-0x4
     925:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 92c <zzlex+0x1fc>
			928: R_X86_64_PC32	.bss+0x7c
     92c:	b8 2f 00 00 00       	mov    $0x2f,%eax
     931:	e9 ec fe ff ff       	jmp    822 <zzlex+0xf2>
     936:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     93a:	80 fa 3c             	cmp    $0x3c,%dl
     93d:	0f 84 7d 03 00 00    	je     cc0 <zzlex+0x590>
     943:	b8 12 00 00 00       	mov    $0x12,%eax
     948:	80 fa 3d             	cmp    $0x3d,%dl
     94b:	0f 85 d1 fe ff ff    	jne    822 <zzlex+0xf2>
     951:	48 83 c7 02          	add    $0x2,%rdi
     955:	b8 13 00 00 00       	mov    $0x13,%eax
     95a:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 961 <zzlex+0x231>
			95d: R_X86_64_PC32	.bss+0x8c
     961:	e9 bc fe ff ff       	jmp    822 <zzlex+0xf2>
     966:	b8 1c 00 00 00       	mov    $0x1c,%eax
     96b:	e9 b2 fe ff ff       	jmp    822 <zzlex+0xf2>
     970:	b8 0c 00 00 00       	mov    $0xc,%eax
     975:	80 7f 01 3d          	cmpb   $0x3d,0x1(%rdi)
     979:	0f 85 a3 fe ff ff    	jne    822 <zzlex+0xf2>
     97f:	48 83 c7 02          	add    $0x2,%rdi
     983:	b8 21 00 00 00       	mov    $0x21,%eax
     988:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 98f <zzlex+0x25f>
			98b: R_X86_64_PC32	.bss+0x8c
     98f:	e9 8e fe ff ff       	jmp    822 <zzlex+0xf2>
     994:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 99a <zzlex+0x26a>
			996: R_X86_64_PC32	.data
     99a:	b8 1b 00 00 00       	mov    $0x1b,%eax
     99f:	85 d2                	test   %edx,%edx
     9a1:	0f 84 7b fe ff ff    	je     822 <zzlex+0xf2>
     9a7:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 9ae <zzlex+0x27e>
			9aa: R_X86_64_PC32	lastval-0x4
     9ae:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 9b5 <zzlex+0x285>
			9b1: R_X86_64_PC32	.bss+0x7c
     9b5:	e9 72 ff ff ff       	jmp    92c <zzlex+0x1fc>
     9ba:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     9be:	80 fa 3e             	cmp    $0x3e,%dl
     9c1:	0f 84 29 03 00 00    	je     cf0 <zzlex+0x5c0>
     9c7:	b8 14 00 00 00       	mov    $0x14,%eax
     9cc:	80 fa 3d             	cmp    $0x3d,%dl
     9cf:	0f 85 4d fe ff ff    	jne    822 <zzlex+0xf2>
     9d5:	48 83 c7 02          	add    $0x2,%rdi
     9d9:	b8 15 00 00 00       	mov    $0x15,%eax
     9de:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 9e5 <zzlex+0x2b5>
			9e1: R_X86_64_PC32	.bss+0x8c
     9e5:	e9 38 fe ff ff       	jmp    822 <zzlex+0xf2>
     9ea:	b8 1d 00 00 00       	mov    $0x1d,%eax
     9ef:	80 7f 01 3d          	cmpb   $0x3d,0x1(%rdi)
     9f3:	0f 85 29 fe ff ff    	jne    822 <zzlex+0xf2>
     9f9:	48 83 c7 02          	add    $0x2,%rdi
     9fd:	b8 16 00 00 00       	mov    $0x16,%eax
     a02:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # a09 <zzlex+0x2d9>
			a05: R_X86_64_PC32	.bss+0x8c
     a09:	e9 14 fe ff ff       	jmp    822 <zzlex+0xf2>
     a0e:	b8 03 00 00 00       	mov    $0x3,%eax
     a13:	e9 0a fe ff ff       	jmp    822 <zzlex+0xf2>
     a18:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     a1c:	80 fa 5e             	cmp    $0x5e,%dl
     a1f:	0f 84 e3 01 00 00    	je     c08 <zzlex+0x4d8>
     a25:	b8 09 00 00 00       	mov    $0x9,%eax
     a2a:	80 fa 3d             	cmp    $0x3d,%dl
     a2d:	0f 85 ef fd ff ff    	jne    822 <zzlex+0xf2>
     a33:	48 83 c7 02          	add    $0x2,%rdi
     a37:	b8 24 00 00 00       	mov    $0x24,%eax
     a3c:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # a43 <zzlex+0x313>
			a3f: R_X86_64_PC32	.bss+0x8c
     a43:	e9 da fd ff ff       	jmp    822 <zzlex+0xf2>
     a48:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     a4c:	f6 84 12 00 00 00 00 	testb  $0x1,0x0(%rdx,%rdx,1)
     a53:	01 
			a4f: R_X86_64_32S	typtab
     a54:	0f 85 60 06 00 00    	jne    10ba <zzlex+0x98a>
     a5a:	80 fa 23             	cmp    $0x23,%dl
     a5d:	0f 85 f1 05 00 00    	jne    1054 <zzlex+0x924>
     a63:	48 8d 47 02          	lea    0x2(%rdi),%rax
     a67:	b9 01 00 00 00       	mov    $0x1,%ecx
     a6c:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # a73 <zzlex+0x343>
			a6f: R_X86_64_PC32	.bss+0x8c
     a73:	0f b6 57 02          	movzbl 0x2(%rdi),%edx
     a77:	80 fa 23             	cmp    $0x23,%dl
     a7a:	75 14                	jne    a90 <zzlex+0x360>
     a7c:	48 8d 47 03          	lea    0x3(%rdi),%rax
     a80:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
     a85:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # a8c <zzlex+0x35c>
			a88: R_X86_64_PC32	.bss+0x8c
     a8c:	0f b6 57 03          	movzbl 0x3(%rdi),%edx
     a90:	0f b6 f2             	movzbl %dl,%esi
     a93:	f6 84 36 00 00 00 00 	testb  $0x1,0x0(%rsi,%rsi,1)
     a9a:	01 
			a96: R_X86_64_32S	typtab
     a9b:	0f 85 ef 00 00 00    	jne    b90 <zzlex+0x460>
     aa1:	80 fa 5f             	cmp    $0x5f,%dl
     aa4:	0f 85 aa 05 00 00    	jne    1054 <zzlex+0x924>
     aaa:	31 c9                	xor    %ecx,%ecx
     aac:	48 8d 78 01          	lea    0x1(%rax),%rdi
     ab0:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # ab7 <zzlex+0x387>
			ab3: R_X86_64_PC32	.bss+0x8c
     ab7:	0f b6 50 01          	movzbl 0x1(%rax),%edx
     abb:	f6 84 12 00 00 00 00 	testb  $0x1,0x0(%rdx,%rdx,1)
     ac2:	01 
			abe: R_X86_64_32S	typtab
     ac3:	0f 85 87 04 00 00    	jne    f50 <zzlex+0x820>
     ac9:	c7 05 00 00 00 00 03 	movl   $0x3,0x0(%rip)        # ad3 <zzlex+0x3a3>
     ad0:	00 00 00 
			acb: R_X86_64_PC32	outputunderscore-0x8
     ad3:	0f b6 40 01          	movzbl 0x1(%rax),%eax
     ad7:	3c 5d                	cmp    $0x5d,%al
     ad9:	0f 85 75 05 00 00    	jne    1054 <zzlex+0x924>
     adf:	85 c9                	test   %ecx,%ecx
     ae1:	0f 85 e4 00 00 00    	jne    bcb <zzlex+0x49b>
     ae7:	48 83 c7 01          	add    $0x1,%rdi
     aeb:	e9 55 fc ff ff       	jmp    745 <zzlex+0x15>
     af0:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     af4:	80 fa 7c             	cmp    $0x7c,%dl
     af7:	0f 84 63 01 00 00    	je     c60 <zzlex+0x530>
     afd:	b8 0a 00 00 00       	mov    $0xa,%eax
     b02:	80 fa 3d             	cmp    $0x3d,%dl
     b05:	0f 85 17 fd ff ff    	jne    822 <zzlex+0xf2>
     b0b:	48 83 c7 02          	add    $0x2,%rdi
     b0f:	b8 25 00 00 00       	mov    $0x25,%eax
     b14:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # b1b <zzlex+0x3eb>
			b17: R_X86_64_PC32	.bss+0x8c
     b1b:	e9 02 fd ff ff       	jmp    822 <zzlex+0xf2>
     b20:	0f b6 47 01          	movzbl 0x1(%rdi),%eax
     b24:	3c 2b                	cmp    $0x2b,%al
     b26:	0f 84 cf 02 00 00    	je     dfb <zzlex+0x6cb>
     b2c:	3c 3d                	cmp    $0x3d,%al
     b2e:	0f 84 46 04 00 00    	je     f7a <zzlex+0x84a>
     b34:	83 3d 00 00 00 00 01 	cmpl   $0x1,0x0(%rip)        # b3b <zzlex+0x40b>
			b36: R_X86_64_PC32	.data-0x1
     b3b:	19 c0                	sbb    %eax,%eax
     b3d:	83 e0 08             	and    $0x8,%eax
     b40:	83 c0 06             	add    $0x6,%eax
     b43:	e9 da fc ff ff       	jmp    822 <zzlex+0xf2>
     b48:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     b4c:	80 fa 2a             	cmp    $0x2a,%dl
     b4f:	0f 84 cb 01 00 00    	je     d20 <zzlex+0x5f0>
     b55:	b8 0b 00 00 00       	mov    $0xb,%eax
     b5a:	80 fa 3d             	cmp    $0x3d,%dl
     b5d:	0f 85 bf fc ff ff    	jne    822 <zzlex+0xf2>
     b63:	48 83 c7 02          	add    $0x2,%rdi
     b67:	b8 20 00 00 00       	mov    $0x20,%eax
     b6c:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # b73 <zzlex+0x443>
			b6f: R_X86_64_PC32	.bss+0x8c
     b73:	e9 aa fc ff ff       	jmp    822 <zzlex+0xf2>
     b78:	b8 01 00 00 00       	mov    $0x1,%eax
     b7d:	e9 a0 fc ff ff       	jmp    822 <zzlex+0xf2>
     b82:	31 c0                	xor    %eax,%eax
     b84:	e9 99 fc ff ff       	jmp    822 <zzlex+0xf2>
     b89:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
     b90:	48 89 c7             	mov    %rax,%rdi
     b93:	ba 0a 00 00 00       	mov    $0xa,%edx
     b98:	be 00 00 00 00       	mov    $0x0,%esi
			b99: R_X86_64_32	.bss+0x90
     b9d:	89 0c 24             	mov    %ecx,(%rsp)
     ba0:	e8 00 00 00 00       	call   ba5 <zzlex+0x475>
			ba1: R_X86_64_PLT32	zstrtol-0x4
     ba5:	8b 0c 24             	mov    (%rsp),%ecx
     ba8:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # baf <zzlex+0x47f>
			bab: R_X86_64_PC32	.bss+0x8c
     baf:	0f af c8             	imul   %eax,%ecx
     bb2:	89 0d 00 00 00 00    	mov    %ecx,0x0(%rip)        # bb8 <zzlex+0x488>
			bb4: R_X86_64_PC32	outputradix-0x4
     bb8:	0f b6 07             	movzbl (%rdi),%eax
     bbb:	3c 5f                	cmp    $0x5f,%al
     bbd:	0f 84 8e 05 00 00    	je     1151 <zzlex+0xa21>
     bc3:	3c 5d                	cmp    $0x5d,%al
     bc5:	0f 85 89 04 00 00    	jne    1054 <zzlex+0x924>
     bcb:	8b 35 00 00 00 00    	mov    0x0(%rip),%esi        # bd1 <zzlex+0x4a1>
			bcd: R_X86_64_PC32	outputradix-0x4
     bd1:	89 f0                	mov    %esi,%eax
     bd3:	f7 d8                	neg    %eax
     bd5:	0f 48 c6             	cmovs  %esi,%eax
     bd8:	83 e8 02             	sub    $0x2,%eax
     bdb:	83 f8 22             	cmp    $0x22,%eax
     bde:	0f 86 03 ff ff ff    	jbe    ae7 <zzlex+0x3b7>
     be4:	bf 00 00 00 00       	mov    $0x0,%edi
			be5: R_X86_64_32	.rodata.str1.8+0x48
     be9:	31 c0                	xor    %eax,%eax
     beb:	e8 00 00 00 00       	call   bf0 <zzlex+0x4c0>
			bec: R_X86_64_PLT32	zerr-0x4
     bf0:	e9 9b fc ff ff       	jmp    890 <zzlex+0x160>
     bf5:	0f 1f 00             	nopl   (%rax)
     bf8:	48 83 c4 28          	add    $0x28,%rsp
     bfc:	e9 7f f6 ff ff       	jmp    280 <lexconstant>
     c01:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
     c08:	48 8d 47 02          	lea    0x2(%rdi),%rax
     c0c:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # c13 <zzlex+0x4e3>
			c0f: R_X86_64_PC32	.bss+0x8c
     c13:	b8 1a 00 00 00       	mov    $0x1a,%eax
     c18:	80 7f 02 3d          	cmpb   $0x3d,0x2(%rdi)
     c1c:	0f 85 00 fc ff ff    	jne    822 <zzlex+0xf2>
     c22:	48 83 c7 03          	add    $0x3,%rdi
     c26:	b8 2a 00 00 00       	mov    $0x2a,%eax
     c2b:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # c32 <zzlex+0x502>
			c2e: R_X86_64_PC32	.bss+0x8c
     c32:	e9 eb fb ff ff       	jmp    822 <zzlex+0xf2>
     c37:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
     c3e:	00 00 
     c40:	48 83 c7 02          	add    $0x2,%rdi
     c44:	83 3d 00 00 00 00 01 	cmpl   $0x1,0x0(%rip)        # c4b <zzlex+0x51b>
			c46: R_X86_64_PC32	.data-0x1
     c4b:	19 c0                	sbb    %eax,%eax
     c4d:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # c54 <zzlex+0x524>
			c50: R_X86_64_PC32	.bss+0x8c
     c54:	83 e0 d7             	and    $0xffffffd7,%eax
     c57:	83 c0 2e             	add    $0x2e,%eax
     c5a:	e9 c3 fb ff ff       	jmp    822 <zzlex+0xf2>
     c5f:	90                   	nop
     c60:	48 8d 47 02          	lea    0x2(%rdi),%rax
     c64:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # c6b <zzlex+0x53b>
			c67: R_X86_64_PC32	.bss+0x8c
     c6b:	b8 19 00 00 00       	mov    $0x19,%eax
     c70:	80 7f 02 3d          	cmpb   $0x3d,0x2(%rdi)
     c74:	0f 85 a8 fb ff ff    	jne    822 <zzlex+0xf2>
     c7a:	48 83 c7 03          	add    $0x3,%rdi
     c7e:	b8 29 00 00 00       	mov    $0x29,%eax
     c83:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # c8a <zzlex+0x55a>
			c86: R_X86_64_PC32	.bss+0x8c
     c8a:	e9 93 fb ff ff       	jmp    822 <zzlex+0xf2>
     c8f:	90                   	nop
     c90:	48 8d 47 02          	lea    0x2(%rdi),%rax
     c94:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # c9b <zzlex+0x56b>
			c97: R_X86_64_PC32	.bss+0x8c
     c9b:	b8 18 00 00 00       	mov    $0x18,%eax
     ca0:	80 7f 02 3d          	cmpb   $0x3d,0x2(%rdi)
     ca4:	0f 85 78 fb ff ff    	jne    822 <zzlex+0xf2>
     caa:	48 83 c7 03          	add    $0x3,%rdi
     cae:	b8 28 00 00 00       	mov    $0x28,%eax
     cb3:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # cba <zzlex+0x58a>
			cb6: R_X86_64_PC32	.bss+0x8c
     cba:	e9 63 fb ff ff       	jmp    822 <zzlex+0xf2>
     cbf:	90                   	nop
     cc0:	48 8d 47 02          	lea    0x2(%rdi),%rax
     cc4:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # ccb <zzlex+0x59b>
			cc7: R_X86_64_PC32	.bss+0x8c
     ccb:	b8 10 00 00 00       	mov    $0x10,%eax
     cd0:	80 7f 02 3d          	cmpb   $0x3d,0x2(%rdi)
     cd4:	0f 85 48 fb ff ff    	jne    822 <zzlex+0xf2>
     cda:	48 83 c7 03          	add    $0x3,%rdi
     cde:	b8 26 00 00 00       	mov    $0x26,%eax
     ce3:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # cea <zzlex+0x5ba>
			ce6: R_X86_64_PC32	.bss+0x8c
     cea:	e9 33 fb ff ff       	jmp    822 <zzlex+0xf2>
     cef:	90                   	nop
     cf0:	48 8d 47 02          	lea    0x2(%rdi),%rax
     cf4:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # cfb <zzlex+0x5cb>
			cf7: R_X86_64_PC32	.bss+0x8c
     cfb:	b8 11 00 00 00       	mov    $0x11,%eax
     d00:	80 7f 02 3d          	cmpb   $0x3d,0x2(%rdi)
     d04:	0f 85 18 fb ff ff    	jne    822 <zzlex+0xf2>
     d0a:	48 83 c7 03          	add    $0x3,%rdi
     d0e:	b8 27 00 00 00       	mov    $0x27,%eax
     d13:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # d1a <zzlex+0x5ea>
			d16: R_X86_64_PC32	.bss+0x8c
     d1a:	e9 03 fb ff ff       	jmp    822 <zzlex+0xf2>
     d1f:	90                   	nop
     d20:	48 8d 47 02          	lea    0x2(%rdi),%rax
     d24:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # d2b <zzlex+0x5fb>
			d27: R_X86_64_PC32	.bss+0x8c
     d2b:	b8 31 00 00 00       	mov    $0x31,%eax
     d30:	80 7f 02 3d          	cmpb   $0x3d,0x2(%rdi)
     d34:	0f 85 e8 fa ff ff    	jne    822 <zzlex+0xf2>
     d3a:	48 83 c7 03          	add    $0x3,%rdi
     d3e:	b8 33 00 00 00       	mov    $0x33,%eax
     d43:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # d4a <zzlex+0x61a>
			d46: R_X86_64_PC32	.bss+0x8c
     d4a:	e9 d3 fa ff ff       	jmp    822 <zzlex+0xf2>
     d4f:	90                   	nop
     d50:	31 d2                	xor    %edx,%edx
     d52:	be 80 00 00 00       	mov    $0x80,%esi
     d57:	e8 00 00 00 00       	call   d5c <zzlex+0x62c>
			d58: R_X86_64_PLT32	itype_end-0x4
     d5c:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # d63 <zzlex+0x633>
			d5f: R_X86_64_PC32	.bss+0x8c
     d63:	48 39 c7             	cmp    %rax,%rdi
     d66:	0f 84 24 fb ff ff    	je     890 <zzlex+0x160>
     d6c:	48 89 c6             	mov    %rax,%rsi
     d6f:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # d76 <zzlex+0x646>
			d72: R_X86_64_PC32	.bss+0x8c
     d76:	48 29 fe             	sub    %rdi,%rsi
     d79:	48 83 fe 03          	cmp    $0x3,%rsi
     d7d:	0f 85 e5 00 00 00    	jne    e68 <zzlex+0x738>
     d83:	44 8b 15 00 00 00 00 	mov    0x0(%rip),%r10d        # d8a <zzlex+0x65a>
			d86: R_X86_64_PC32	emulation-0x4
     d8a:	41 83 e2 08          	and    $0x8,%r10d
     d8e:	0f 85 d4 00 00 00    	jne    e68 <zzlex+0x738>
     d94:	0f b6 17             	movzbl (%rdi),%edx
     d97:	83 e2 df             	and    $0xffffffdf,%edx
     d9a:	80 fa 4e             	cmp    $0x4e,%dl
     d9d:	0f 85 61 02 00 00    	jne    1004 <zzlex+0x8d4>
     da3:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
     da7:	83 e2 df             	and    $0xffffffdf,%edx
     daa:	80 fa 41             	cmp    $0x41,%dl
     dad:	75 10                	jne    dbf <zzlex+0x68f>
     daf:	0f b6 57 02          	movzbl 0x2(%rdi),%edx
     db3:	83 e2 df             	and    $0xffffffdf,%edx
     db6:	80 fa 4e             	cmp    $0x4e,%dl
     db9:	0f 84 57 03 00 00    	je     1116 <zzlex+0x9e6>
     dbf:	44 0f b6 00          	movzbl (%rax),%r8d
     dc3:	41 80 f8 5b          	cmp    $0x5b,%r8b
     dc7:	0f 84 2c 02 00 00    	je     ff9 <zzlex+0x8c9>
     dcd:	be 03 00 00 00       	mov    $0x3,%esi
     dd2:	45 85 d2             	test   %r10d,%r10d
     dd5:	0f 85 36 fa ff ff    	jne    811 <zzlex+0xe1>
     ddb:	41 80 f8 28          	cmp    $0x28,%r8b
     ddf:	0f 84 80 02 00 00    	je     1065 <zzlex+0x935>
     de5:	e8 00 00 00 00       	call   dea <zzlex+0x6ba>
			de6: R_X86_64_PLT32	dupstrpfx-0x4
     dea:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # df1 <zzlex+0x6c1>
			ded: R_X86_64_PC32	.bss+0x74
     df1:	b8 30 00 00 00       	mov    $0x30,%eax
     df6:	e9 27 fa ff ff       	jmp    822 <zzlex+0xf2>
     dfb:	48 83 c7 02          	add    $0x2,%rdi
     dff:	83 3d 00 00 00 00 01 	cmpl   $0x1,0x0(%rip)        # e06 <zzlex+0x6d6>
			e01: R_X86_64_PC32	.data-0x1
     e06:	19 c0                	sbb    %eax,%eax
     e08:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # e0f <zzlex+0x6df>
			e0b: R_X86_64_PC32	.bss+0x8c
     e0f:	83 e0 d7             	and    $0xffffffd7,%eax
     e12:	83 c0 2d             	add    $0x2d,%eax
     e15:	e9 08 fa ff ff       	jmp    822 <zzlex+0xf2>
     e1a:	48 8d 47 02          	lea    0x2(%rdi),%rax
     e1e:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # e25 <zzlex+0x6f5>
			e21: R_X86_64_PC32	.bss+0x8c
     e25:	80 7f 02 00          	cmpb   $0x0,0x2(%rdi)
     e29:	0f 84 98 01 00 00    	je     fc7 <zzlex+0x897>
     e2f:	48 8d 4c 24 1c       	lea    0x1c(%rsp),%rcx
     e34:	ba 47 00 00 00       	mov    $0x47,%edx
     e39:	31 f6                	xor    %esi,%esi
     e3b:	48 89 c7             	mov    %rax,%rdi
     e3e:	4c 89 04 24          	mov    %r8,(%rsp)
     e42:	e8 00 00 00 00       	call   e47 <zzlex+0x717>
			e43: R_X86_64_PLT32	getkeystring-0x4
     e47:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # e4e <zzlex+0x71e>
			e4a: R_X86_64_PC32	.bss+0x8c
     e4e:	48 85 c0             	test   %rax,%rax
     e51:	0f 84 49 02 00 00    	je     10a0 <zzlex+0x970>
     e57:	48 63 44 24 1c       	movslq 0x1c(%rsp),%rax
     e5c:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # e63 <zzlex+0x733>
			e5f: R_X86_64_PC32	.bss+0x7c
     e63:	e9 c4 fa ff ff       	jmp    92c <zzlex+0x1fc>
     e68:	44 0f b6 00          	movzbl (%rax),%r8d
     e6c:	41 80 f8 5b          	cmp    $0x5b,%r8b
     e70:	0f 85 65 ff ff ff    	jne    ddb <zzlex+0x6ab>
     e76:	45 31 d2             	xor    %r10d,%r10d
     e79:	41 b9 5d 00 00 00    	mov    $0x5d,%r9d
     e7f:	48 8d 70 01          	lea    0x1(%rax),%rsi
     e83:	48 89 35 00 00 00 00 	mov    %rsi,0x0(%rip)        # e8a <zzlex+0x75a>
			e86: R_X86_64_PC32	.bss+0x8c
     e8a:	0f b6 40 01          	movzbl 0x1(%rax),%eax
     e8e:	84 c0                	test   %al,%al
     e90:	0f 84 80 00 00 00    	je     f16 <zzlex+0x7e6>
     e96:	ba 01 00 00 00       	mov    $0x1,%edx
     e9b:	eb 3a                	jmp    ed7 <zzlex+0x7a7>
     e9d:	0f 1f 00             	nopl   (%rax)
     ea0:	41 38 c1             	cmp    %al,%r9b
     ea3:	74 4b                	je     ef0 <zzlex+0x7c0>
     ea5:	3c 5c                	cmp    $0x5c,%al
     ea7:	75 5f                	jne    f08 <zzlex+0x7d8>
     ea9:	80 7e 01 00          	cmpb   $0x0,0x1(%rsi)
     ead:	74 59                	je     f08 <zzlex+0x7d8>
     eaf:	48 8d 46 01          	lea    0x1(%rsi),%rax
     eb3:	b9 01 00 00 00       	mov    $0x1,%ecx
     eb8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
     ebf:	00 
     ec0:	48 8d 70 01          	lea    0x1(%rax),%rsi
     ec4:	48 89 35 00 00 00 00 	mov    %rsi,0x0(%rip)        # ecb <zzlex+0x79b>
			ec7: R_X86_64_PC32	.bss+0x8c
     ecb:	0f b6 40 01          	movzbl 0x1(%rax),%eax
     ecf:	84 c0                	test   %al,%al
     ed1:	74 43                	je     f16 <zzlex+0x7e6>
     ed3:	84 c9                	test   %cl,%cl
     ed5:	74 3f                	je     f16 <zzlex+0x7e6>
     ed7:	41 38 c0             	cmp    %al,%r8b
     eda:	75 c4                	jne    ea0 <zzlex+0x770>
     edc:	83 fa ff             	cmp    $0xffffffff,%edx
     edf:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # ee6 <zzlex+0x7b6>
			ee2: R_X86_64_PC32	.bss+0x8c
     ee6:	0f 95 c1             	setne  %cl
     ee9:	83 c2 01             	add    $0x1,%edx
     eec:	eb d2                	jmp    ec0 <zzlex+0x790>
     eee:	66 90                	xchg   %ax,%ax
     ef0:	83 fa 01             	cmp    $0x1,%edx
     ef3:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # efa <zzlex+0x7ca>
			ef6: R_X86_64_PC32	.bss+0x8c
     efa:	0f 95 c1             	setne  %cl
     efd:	83 ea 01             	sub    $0x1,%edx
     f00:	eb be                	jmp    ec0 <zzlex+0x790>
     f02:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
     f08:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # f0f <zzlex+0x7df>
			f0b: R_X86_64_PC32	.bss+0x8c
     f0f:	b9 01 00 00 00       	mov    $0x1,%ecx
     f14:	eb aa                	jmp    ec0 <zzlex+0x790>
     f16:	29 fe                	sub    %edi,%esi
     f18:	44 89 54 24 0c       	mov    %r10d,0xc(%rsp)
     f1d:	44 88 04 24          	mov    %r8b,(%rsp)
     f21:	e8 00 00 00 00       	call   f26 <zzlex+0x7f6>
			f22: R_X86_64_PLT32	dupstrpfx-0x4
     f26:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # f2d <zzlex+0x7fd>
			f29: R_X86_64_PC32	.bss+0x74
     f2d:	b8 34 00 00 00       	mov    $0x34,%eax
     f32:	80 3c 24 28          	cmpb   $0x28,(%rsp)
     f36:	0f 84 e6 f8 ff ff    	je     822 <zzlex+0xf2>
     f3c:	83 7c 24 0c 00       	cmpl   $0x0,0xc(%rsp)
     f41:	0f 85 d6 f8 ff ff    	jne    81d <zzlex+0xed>
     f47:	e9 a5 fe ff ff       	jmp    df1 <zzlex+0x6c1>
     f4c:	0f 1f 40 00          	nopl   0x0(%rax)
     f50:	ba 0a 00 00 00       	mov    $0xa,%edx
     f55:	be 00 00 00 00       	mov    $0x0,%esi
			f56: R_X86_64_32	.bss+0x90
     f5a:	89 0c 24             	mov    %ecx,(%rsp)
     f5d:	e8 00 00 00 00       	call   f62 <zzlex+0x832>
			f5e: R_X86_64_PLT32	zstrtol-0x4
     f62:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # f69 <zzlex+0x839>
			f65: R_X86_64_PC32	.bss+0x8c
     f69:	8b 0c 24             	mov    (%rsp),%ecx
     f6c:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # f72 <zzlex+0x842>
			f6e: R_X86_64_PC32	outputunderscore-0x4
     f72:	0f b6 07             	movzbl (%rdi),%eax
     f75:	e9 5d fb ff ff       	jmp    ad7 <zzlex+0x3a7>
     f7a:	48 83 c7 02          	add    $0x2,%rdi
     f7e:	b8 1e 00 00 00       	mov    $0x1e,%eax
     f83:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # f8a <zzlex+0x85a>
			f86: R_X86_64_PC32	.bss+0x8c
     f8a:	e9 93 f8 ff ff       	jmp    822 <zzlex+0xf2>
     f8f:	83 3d 00 00 00 00 02 	cmpl   $0x2,0x0(%rip)        # f96 <zzlex+0x866>
			f91: R_X86_64_PC32	.bss+0x83
     f96:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # f9d <zzlex+0x86d>
			f99: R_X86_64_PC32	.bss+0x7c
     f9d:	0f 84 d0 00 00 00    	je     1073 <zzlex+0x943>
     fa3:	48 f7 d8             	neg    %rax
     fa6:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # fad <zzlex+0x87d>
			fa9: R_X86_64_PC32	.bss+0x7c
     fad:	e9 7a f9 ff ff       	jmp    92c <zzlex+0x1fc>
     fb2:	48 83 c7 02          	add    $0x2,%rdi
     fb6:	b8 1f 00 00 00       	mov    $0x1f,%eax
     fbb:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # fc2 <zzlex+0x892>
			fbe: R_X86_64_PC32	.bss+0x8c
     fc2:	e9 5b f8 ff ff       	jmp    822 <zzlex+0xf2>
     fc7:	bf 00 00 00 00       	mov    $0x0,%edi
			fc8: R_X86_64_32	.rodata.str1.8+0x78
     fcc:	31 c0                	xor    %eax,%eax
     fce:	e8 00 00 00 00       	call   fd3 <zzlex+0x8a3>
			fcf: R_X86_64_PLT32	zerr-0x4
     fd3:	e9 b8 f8 ff ff       	jmp    890 <zzlex+0x160>
     fd8:	41 ba 01 00 00 00    	mov    $0x1,%r10d
     fde:	f6 05 00 00 00 00 08 	testb  $0x8,0x0(%rip)        # fe5 <zzlex+0x8b5>
			fe0: R_X86_64_PC32	emulation-0x5
     fe5:	0f 84 a9 fd ff ff    	je     d94 <zzlex+0x664>
     feb:	44 0f b6 00          	movzbl (%rax),%r8d
     fef:	41 80 f8 5b          	cmp    $0x5b,%r8b
     ff3:	0f 85 18 f8 ff ff    	jne    811 <zzlex+0xe1>
     ff9:	41 b9 5d 00 00 00    	mov    $0x5d,%r9d
     fff:	e9 7b fe ff ff       	jmp    e7f <zzlex+0x74f>
    1004:	80 fa 49             	cmp    $0x49,%dl
    1007:	0f 85 b2 fd ff ff    	jne    dbf <zzlex+0x68f>
    100d:	0f b6 57 01          	movzbl 0x1(%rdi),%edx
    1011:	83 e2 df             	and    $0xffffffdf,%edx
    1014:	80 fa 4e             	cmp    $0x4e,%dl
    1017:	0f 85 a2 fd ff ff    	jne    dbf <zzlex+0x68f>
    101d:	0f b6 57 02          	movzbl 0x2(%rdi),%edx
    1021:	83 e2 df             	and    $0xffffffdf,%edx
    1024:	80 fa 46             	cmp    $0x46,%dl
    1027:	0f 85 92 fd ff ff    	jne    dbf <zzlex+0x68f>
    102d:	f2 0f 10 05 00 00 00 	movsd  0x0(%rip),%xmm0        # 1035 <zzlex+0x905>
    1034:	00 
			1031: R_X86_64_PC32	.LC11-0x4
    1035:	66 0f ef c9          	pxor   %xmm1,%xmm1
    1039:	c7 05 00 00 00 00 02 	movl   $0x2,0x0(%rip)        # 1043 <zzlex+0x913>
    1040:	00 00 00 
			103b: R_X86_64_PC32	.bss+0x80
    1043:	f2 0f 5e c1          	divsd  %xmm1,%xmm0
    1047:	f2 0f 11 05 00 00 00 	movsd  %xmm0,0x0(%rip)        # 104f <zzlex+0x91f>
    104e:	00 
			104b: R_X86_64_PC32	.bss+0x7c
    104f:	e9 d8 f8 ff ff       	jmp    92c <zzlex+0x1fc>
    1054:	bf 00 00 00 00       	mov    $0x0,%edi
			1055: R_X86_64_32	.rodata.str1.8+0x28
    1059:	31 c0                	xor    %eax,%eax
    105b:	e8 00 00 00 00       	call   1060 <zzlex+0x930>
			105c: R_X86_64_PLT32	zerr-0x4
    1060:	e9 2b f8 ff ff       	jmp    890 <zzlex+0x160>
    1065:	45 31 d2             	xor    %r10d,%r10d
    1068:	41 b9 29 00 00 00    	mov    $0x29,%r9d
    106e:	e9 0c fe ff ff       	jmp    e7f <zzlex+0x74f>
    1073:	66 48 0f 6e c0       	movq   %rax,%xmm0
    1078:	66 0f 57 05 00 00 00 	xorpd  0x0(%rip),%xmm0        # 1080 <zzlex+0x950>
    107f:	00 
			107c: R_X86_64_PC32	.LC4-0x4
    1080:	f2 0f 11 05 00 00 00 	movsd  %xmm0,0x0(%rip)        # 1088 <zzlex+0x958>
    1087:	00 
			1084: R_X86_64_PC32	.bss+0x7c
    1088:	e9 9f f8 ff ff       	jmp    92c <zzlex+0x1fc>
    108d:	31 ff                	xor    %edi,%edi
    108f:	e8 00 00 00 00       	call   1094 <zzlex+0x964>
			1090: R_X86_64_PLT32	poundgetfn-0x4
    1094:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 109b <zzlex+0x96b>
			1097: R_X86_64_PC32	.bss+0x7c
    109b:	e9 8c f8 ff ff       	jmp    92c <zzlex+0x1fc>
    10a0:	bf 00 00 00 00       	mov    $0x0,%edi
			10a1: R_X86_64_32	.rodata.str1.8+0xa8
    10a5:	e8 00 00 00 00       	call   10aa <zzlex+0x97a>
			10a6: R_X86_64_PLT32	zerr-0x4
    10aa:	4c 8b 04 24          	mov    (%rsp),%r8
    10ae:	4c 89 05 00 00 00 00 	mov    %r8,0x0(%rip)        # 10b5 <zzlex+0x985>
			10b1: R_X86_64_PC32	.bss+0x8c
    10b5:	e9 d6 f7 ff ff       	jmp    890 <zzlex+0x160>
    10ba:	ba 0a 00 00 00       	mov    $0xa,%edx
    10bf:	be 00 00 00 00       	mov    $0x0,%esi
			10c0: R_X86_64_32	.bss+0x90
    10c4:	4c 89 c7             	mov    %r8,%rdi
    10c7:	e8 00 00 00 00       	call   10cc <zzlex+0x99c>
			10c8: R_X86_64_PLT32	zstrtol-0x4
    10cc:	48 89 c2             	mov    %rax,%rdx
    10cf:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 10d6 <zzlex+0x9a6>
			10d2: R_X86_64_PC32	.bss+0x8c
    10d6:	80 38 5d             	cmpb   $0x5d,(%rax)
    10d9:	75 19                	jne    10f4 <zzlex+0x9c4>
    10db:	48 8d 78 01          	lea    0x1(%rax),%rdi
    10df:	48 89 3d 00 00 00 00 	mov    %rdi,0x0(%rip)        # 10e6 <zzlex+0x9b6>
			10e2: R_X86_64_PC32	.bss+0x8c
    10e6:	0f b6 40 01          	movzbl 0x1(%rax),%eax
    10ea:	f6 84 00 00 00 00 00 	testb  $0x1,0x0(%rax,%rax,1)
    10f1:	01 
			10ed: R_X86_64_32S	typtab
    10f2:	75 41                	jne    1135 <zzlex+0xa05>
    10f4:	bf 00 00 00 00       	mov    $0x0,%edi
			10f5: R_X86_64_32	.rodata.str1.1+0x24
    10f9:	31 c0                	xor    %eax,%eax
    10fb:	e8 00 00 00 00       	call   1100 <zzlex+0x9d0>
			10fc: R_X86_64_PLT32	zerr-0x4
    1100:	e9 8b f7 ff ff       	jmp    890 <zzlex+0x160>
    1105:	41 ba 01 00 00 00    	mov    $0x1,%r10d
    110b:	41 b9 5d 00 00 00    	mov    $0x5d,%r9d
    1111:	e9 69 fd ff ff       	jmp    e7f <zzlex+0x74f>
    1116:	c7 05 00 00 00 00 02 	movl   $0x2,0x0(%rip)        # 1120 <zzlex+0x9f0>
    111d:	00 00 00 
			1118: R_X86_64_PC32	.bss+0x80
    1120:	66 0f ef c0          	pxor   %xmm0,%xmm0
    1124:	f2 0f 5e c0          	divsd  %xmm0,%xmm0
    1128:	f2 0f 11 05 00 00 00 	movsd  %xmm0,0x0(%rip)        # 1130 <zzlex+0xa00>
    112f:	00 
			112c: R_X86_64_PC32	.bss+0x7c
    1130:	e9 f7 f7 ff ff       	jmp    92c <zzlex+0x1fc>
    1135:	be 00 00 00 00       	mov    $0x0,%esi
			1136: R_X86_64_32	.bss+0x90
    113a:	89 15 00 00 00 00    	mov    %edx,0x0(%rip)        # 1140 <zzlex+0xa10>
			113c: R_X86_64_PC32	lastbase-0x4
    1140:	e8 00 00 00 00       	call   1145 <zzlex+0xa15>
			1141: R_X86_64_PLT32	zstrtol-0x4
    1145:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 114c <zzlex+0xa1c>
			1148: R_X86_64_PC32	.bss+0x7c
    114c:	e9 db f7 ff ff       	jmp    92c <zzlex+0x1fc>
    1151:	48 89 f8             	mov    %rdi,%rax
    1154:	b9 01 00 00 00       	mov    $0x1,%ecx
    1159:	e9 4e f9 ff ff       	jmp    aac <zzlex+0x37c>
    115e:	66 90                	xchg   %ax,%ax

0000000000001160 <getmathparam>:
    1160:	53                   	push   %rbx
    1161:	48 89 fb             	mov    %rdi,%rbx
    1164:	48 83 ec 10          	sub    $0x10,%rsp
    1168:	48 8b 7f 08          	mov    0x8(%rdi),%rdi
    116c:	48 85 ff             	test   %rdi,%rdi
    116f:	74 3f                	je     11b0 <getmathparam+0x50>
    1171:	e8 00 00 00 00       	call   1176 <getmathparam+0x16>
			1172: R_X86_64_PLT32	getnumvalue-0x4
    1176:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 117d <getmathparam+0x1d>
			1178: R_X86_64_PC32	opts+0x38
    117d:	48 89 c6             	mov    %rax,%rsi
    1180:	89 d1                	mov    %edx,%ecx
    1182:	74 05                	je     1189 <getmathparam+0x29>
    1184:	83 fa 01             	cmp    $0x1,%edx
    1187:	74 67                	je     11f0 <getmathparam+0x90>
    1189:	48 bf 00 00 00 00 ff 	movabs $0xffffffff00000000,%rdi
    1190:	ff ff ff 
    1193:	48 89 f0             	mov    %rsi,%rax
    1196:	89 ce                	mov    %ecx,%esi
    1198:	48 89 d1             	mov    %rdx,%rcx
    119b:	48 21 f9             	and    %rdi,%rcx
    119e:	48 09 f1             	or     %rsi,%rcx
    11a1:	48 89 ca             	mov    %rcx,%rdx
    11a4:	48 83 c4 10          	add    $0x10,%rsp
    11a8:	5b                   	pop    %rbx
    11a9:	c3                   	ret
    11aa:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    11b0:	48 8b 03             	mov    (%rbx),%rax
    11b3:	bf 28 00 00 00       	mov    $0x28,%edi
    11b8:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    11bd:	e8 00 00 00 00       	call   11c2 <getmathparam+0x62>
			11be: R_X86_64_PLT32	zhalloc-0x4
    11c2:	48 8d 74 24 08       	lea    0x8(%rsp),%rsi
    11c7:	ba 01 00 00 00       	mov    $0x1,%edx
    11cc:	48 89 43 08          	mov    %rax,0x8(%rbx)
    11d0:	48 89 c7             	mov    %rax,%rdi
    11d3:	e8 00 00 00 00       	call   11d8 <getmathparam+0x78>
			11d4: R_X86_64_PLT32	getvalue-0x4
    11d8:	48 85 c0             	test   %rax,%rax
    11db:	74 2b                	je     1208 <getmathparam+0xa8>
    11dd:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 11e3 <getmathparam+0x83>
			11df: R_X86_64_PC32	errflag-0x4
    11e3:	85 c0                	test   %eax,%eax
    11e5:	75 3b                	jne    1222 <getmathparam+0xc2>
    11e7:	48 8b 7b 08          	mov    0x8(%rbx),%rdi
    11eb:	eb 84                	jmp    1171 <getmathparam+0x11>
    11ed:	0f 1f 00             	nopl   (%rax)
    11f0:	66 0f ef c0          	pxor   %xmm0,%xmm0
    11f4:	b9 02 00 00 00       	mov    $0x2,%ecx
    11f9:	f2 48 0f 2a c0       	cvtsi2sd %rax,%xmm0
    11fe:	66 48 0f 7e c6       	movq   %xmm0,%rsi
    1203:	eb 84                	jmp    1189 <getmathparam+0x29>
    1205:	0f 1f 00             	nopl   (%rax)
    1208:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 120f <getmathparam+0xaf>
			120a: R_X86_64_PC32	opts+0xad
    120f:	74 3f                	je     1250 <getmathparam+0xf0>
    1211:	48 c7 43 08 00 00 00 	movq   $0x0,0x8(%rbx)
    1218:	00 
    1219:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 1220 <getmathparam+0xc0>
			121b: R_X86_64_PC32	opts+0x38
    1220:	75 1e                	jne    1240 <getmathparam+0xe0>
    1222:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 1229 <getmathparam+0xc9>
			1225: R_X86_64_PC32	zero_mnumber-0x4
    1229:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 1230 <getmathparam+0xd0>
			122c: R_X86_64_PC32	zero_mnumber+0x4
    1230:	48 83 c4 10          	add    $0x10,%rsp
    1234:	5b                   	pop    %rbx
    1235:	c3                   	ret
    1236:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    123d:	00 00 00 
    1240:	31 c0                	xor    %eax,%eax
    1242:	ba 02 00 00 00       	mov    $0x2,%edx
    1247:	e9 58 ff ff ff       	jmp    11a4 <getmathparam+0x44>
    124c:	0f 1f 40 00          	nopl   0x0(%rax)
    1250:	48 8b 33             	mov    (%rbx),%rsi
    1253:	bf 00 00 00 00       	mov    $0x0,%edi
			1254: R_X86_64_32	.rodata.str1.1+0x34
    1258:	e8 00 00 00 00       	call   125d <getmathparam+0xfd>
			1259: R_X86_64_PLT32	zerr-0x4
    125d:	eb b2                	jmp    1211 <getmathparam+0xb1>
    125f:	90                   	nop

0000000000001260 <op>:
    1260:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 1266 <op+0x6>
			1262: R_X86_64_PC32	errflag-0x4
    1266:	85 c0                	test   %eax,%eax
    1268:	0f 85 ea 01 00 00    	jne    1458 <op+0x1f8>
    126e:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 1274 <op+0x14>
			1270: R_X86_64_PC32	.data-0x4
    1274:	85 c0                	test   %eax,%eax
    1276:	0f 88 e4 01 00 00    	js     1460 <op+0x200>
    127c:	41 57                	push   %r15
    127e:	48 63 d7             	movslq %edi,%rdx
    1281:	48 63 c8             	movslq %eax,%rcx
    1284:	41 56                	push   %r14
    1286:	48 89 d6             	mov    %rdx,%rsi
    1289:	48 c1 e1 05          	shl    $0x5,%rcx
    128d:	41 54                	push   %r12
    128f:	55                   	push   %rbp
    1290:	53                   	push   %rbx
    1291:	48 83 ec 50          	sub    $0x50,%rsp
    1295:	44 8b 14 95 00 00 00 	mov    0x0(,%rdx,4),%r10d
    129c:	00 
			1299: R_X86_64_32S	.rodata+0x900
    129d:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 12a4 <op+0x44>
			12a0: R_X86_64_PC32	.bss+0x4c
    12a4:	48 01 d1             	add    %rdx,%rcx
    12a7:	8b 79 18             	mov    0x18(%rcx),%edi
    12aa:	41 f6 c2 7c          	test   $0x7c,%r10b
    12ae:	75 20                	jne    12d0 <op+0x70>
    12b0:	83 ff 04             	cmp    $0x4,%edi
    12b3:	0f 84 e7 01 00 00    	je     14a0 <op+0x240>
    12b9:	83 fe 2e             	cmp    $0x2e,%esi
    12bc:	0f 87 6e 02 00 00    	ja     1530 <op+0x2d0>
    12c2:	89 f6                	mov    %esi,%esi
    12c4:	ff 24 f5 00 00 00 00 	jmp    *0x0(,%rsi,8)
			12c7: R_X86_64_32S	.rodata+0x3f8
    12cb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    12d0:	83 ff 04             	cmp    $0x4,%edi
    12d3:	75 4b                	jne    1320 <op+0xc0>
    12d5:	48 89 cf             	mov    %rcx,%rdi
    12d8:	89 74 24 40          	mov    %esi,0x40(%rsp)
    12dc:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
    12e1:	4c 89 4c 24 28       	mov    %r9,0x28(%rsp)
    12e6:	44 89 54 24 10       	mov    %r10d,0x10(%rsp)
    12eb:	48 89 0c 24          	mov    %rcx,(%rsp)
    12ef:	e8 6c fe ff ff       	call   1160 <getmathparam>
    12f4:	48 8b 0c 24          	mov    (%rsp),%rcx
    12f8:	8b 74 24 40          	mov    0x40(%rsp),%esi
    12fc:	4c 8b 44 24 20       	mov    0x20(%rsp),%r8
    1301:	4c 8b 4c 24 28       	mov    0x28(%rsp),%r9
    1306:	48 89 41 10          	mov    %rax,0x10(%rcx)
    130a:	44 8b 54 24 10       	mov    0x10(%rsp),%r10d
    130f:	48 89 51 18          	mov    %rdx,0x18(%rcx)
    1313:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 1319 <op+0xb9>
			1315: R_X86_64_PC32	.data-0x4
    1319:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 1320 <op+0xc0>
			131c: R_X86_64_PC32	.bss+0x4c
    1320:	8d 78 ff             	lea    -0x1(%rax),%edi
    1323:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 1329 <op+0xc9>
			1325: R_X86_64_PC32	errflag-0x4
    1329:	89 3d 00 00 00 00    	mov    %edi,0x0(%rip)        # 132f <op+0xcf>
			132b: R_X86_64_PC32	.data-0x4
    132f:	85 c0                	test   %eax,%eax
    1331:	0f 85 51 01 00 00    	jne    1488 <op+0x228>
    1337:	4c 8b 79 10          	mov    0x10(%rcx),%r15
    133b:	4c 8b 59 18          	mov    0x18(%rcx),%r11
    133f:	48 63 c7             	movslq %edi,%rax
    1342:	4c 89 5c 24 08       	mov    %r11,0x8(%rsp)
    1347:	44 89 dd             	mov    %r11d,%ebp
    134a:	4c 89 f9             	mov    %r15,%rcx
    134d:	48 c1 e0 05          	shl    $0x5,%rax
    1351:	4c 89 3c 24          	mov    %r15,(%rsp)
    1355:	4c 8d 1c 02          	lea    (%rdx,%rax,1),%r11
    1359:	41 83 7b 18 04       	cmpl   $0x4,0x18(%r11)
    135e:	75 09                	jne    1369 <op+0x109>
    1360:	83 fe 1d             	cmp    $0x1d,%esi
    1363:	0f 85 3f 0a 00 00    	jne    1da8 <op+0xb48>
    1369:	8d 47 ff             	lea    -0x1(%rdi),%eax
    136c:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 1372 <op+0x112>
			136e: R_X86_64_PC32	.data-0x4
    1372:	41 89 c4             	mov    %eax,%r12d
    1375:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 137b <op+0x11b>
			1377: R_X86_64_PC32	errflag-0x4
    137b:	85 c0                	test   %eax,%eax
    137d:	0f 85 ed 00 00 00    	jne    1470 <op+0x210>
    1383:	49 8b 5b 10          	mov    0x10(%r11),%rbx
    1387:	49 8b 53 18          	mov    0x18(%r11),%rdx
    138b:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 1391 <op+0x131>
			138d: R_X86_64_PC32	errflag-0x4
    1391:	85 c0                	test   %eax,%eax
    1393:	0f 85 ae 00 00 00    	jne    1447 <op+0x1e7>
    1399:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 139f <op+0x13f>
			139b: R_X86_64_PC32	noeval-0x4
    139f:	49 89 db             	mov    %rbx,%r11
    13a2:	41 89 d6             	mov    %edx,%r14d
    13a5:	41 f6 c2 50          	test   $0x50,%r10b
    13a9:	0f 84 29 01 00 00    	je     14d8 <op+0x278>
    13af:	83 e2 02             	and    $0x2,%edx
    13b2:	74 10                	je     13c4 <op+0x164>
    13b4:	66 48 0f 6e db       	movq   %rbx,%xmm3
    13b9:	41 be 01 00 00 00    	mov    $0x1,%r14d
    13bf:	f2 4c 0f 2c db       	cvttsd2si %xmm3,%r11
    13c4:	40 f6 c5 02          	test   $0x2,%bpl
    13c8:	0f 85 92 01 00 00    	jne    1560 <op+0x300>
    13ce:	85 c0                	test   %eax,%eax
    13d0:	0f 85 12 05 00 00    	jne    18e8 <op+0x688>
    13d6:	83 ee 08             	sub    $0x8,%esi
    13d9:	41 f6 c2 08          	test   $0x8,%r10b
    13dd:	0f 85 6d 01 00 00    	jne    1550 <op+0x2f0>
    13e3:	83 fe 2b             	cmp    $0x2b,%esi
    13e6:	0f 87 04 05 00 00    	ja     18f0 <op+0x690>
    13ec:	ff 24 f5 00 00 00 00 	jmp    *0x0(,%rsi,8)
			13ef: R_X86_64_32S	.rodata+0x570
    13f3:	48 8b 79 10          	mov    0x10(%rcx),%rdi
    13f7:	48 8b 51 18          	mov    0x18(%rcx),%rdx
    13fb:	48 8d 77 01          	lea    0x1(%rdi),%rsi
    13ff:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
    1403:	74 12                	je     1417 <op+0x1b7>
    1405:	66 48 0f 6e e7       	movq   %rdi,%xmm4
    140a:	f2 0f 58 25 00 00 00 	addsd  0x0(%rip),%xmm4        # 1412 <op+0x1b2>
    1411:	00 
			140e: R_X86_64_PC32	.LC11-0x4
    1412:	66 48 0f 7e e6       	movq   %xmm4,%rsi
    1417:	48 63 3d 00 00 00 00 	movslq 0x0(%rip),%rdi        # 141e <op+0x1be>
			141a: R_X86_64_PC32	.data-0x4
    141e:	48 c1 e7 05          	shl    $0x5,%rdi
    1422:	48 03 3d 00 00 00 00 	add    0x0(%rip),%rdi        # 1429 <op+0x1c9>
			1425: R_X86_64_PC32	.bss+0x4c
    1429:	e8 d2 eb ff ff       	call   0 <setmathvar>
    142e:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 1435 <op+0x1d5>
			1431: R_X86_64_PC32	.data-0x4
    1435:	48 c1 e0 05          	shl    $0x5,%rax
    1439:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 1440 <op+0x1e0>
			143c: R_X86_64_PC32	.bss+0x4c
    1440:	66 0f ef c0          	pxor   %xmm0,%xmm0
    1444:	0f 11 00             	movups %xmm0,(%rax)
    1447:	48 83 c4 50          	add    $0x50,%rsp
    144b:	5b                   	pop    %rbx
    144c:	5d                   	pop    %rbp
    144d:	41 5c                	pop    %r12
    144f:	41 5e                	pop    %r14
    1451:	41 5f                	pop    %r15
    1453:	c3                   	ret
    1454:	0f 1f 40 00          	nopl   0x0(%rax)
    1458:	c3                   	ret
    1459:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    1460:	bf 00 00 00 00       	mov    $0x0,%edi
			1461: R_X86_64_32	.rodata.str1.8+0xd8
    1465:	31 c0                	xor    %eax,%eax
    1467:	e9 00 00 00 00       	jmp    146c <op+0x20c>
			1468: R_X86_64_PLT32	zerr-0x4
    146c:	0f 1f 40 00          	nopl   0x0(%rax)
    1470:	48 8b 1d 00 00 00 00 	mov    0x0(%rip),%rbx        # 1477 <op+0x217>
			1473: R_X86_64_PC32	zero_mnumber-0x4
    1477:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 147e <op+0x21e>
			147a: R_X86_64_PC32	zero_mnumber+0x4
    147e:	e9 08 ff ff ff       	jmp    138b <op+0x12b>
    1483:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    1488:	4c 8b 3d 00 00 00 00 	mov    0x0(%rip),%r15        # 148f <op+0x22f>
			148b: R_X86_64_PC32	zero_mnumber-0x4
    148f:	4c 8b 1d 00 00 00 00 	mov    0x0(%rip),%r11        # 1496 <op+0x236>
			1492: R_X86_64_PC32	zero_mnumber+0x4
    1496:	e9 a4 fe ff ff       	jmp    133f <op+0xdf>
    149b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    14a0:	48 89 cf             	mov    %rcx,%rdi
    14a3:	89 74 24 10          	mov    %esi,0x10(%rsp)
    14a7:	48 89 0c 24          	mov    %rcx,(%rsp)
    14ab:	e8 b0 fc ff ff       	call   1160 <getmathparam>
    14b0:	48 8b 0c 24          	mov    (%rsp),%rcx
    14b4:	8b 74 24 10          	mov    0x10(%rsp),%esi
    14b8:	48 89 41 10          	mov    %rax,0x10(%rcx)
    14bc:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 14c2 <op+0x262>
			14be: R_X86_64_PC32	errflag-0x4
    14c2:	48 89 51 18          	mov    %rdx,0x18(%rcx)
    14c6:	85 c0                	test   %eax,%eax
    14c8:	0f 84 eb fd ff ff    	je     12b9 <op+0x59>
    14ce:	e9 74 ff ff ff       	jmp    1447 <op+0x1e7>
    14d3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    14d8:	39 d5                	cmp    %edx,%ebp
    14da:	0f 84 ee fe ff ff    	je     13ce <op+0x16e>
    14e0:	83 fe 2b             	cmp    $0x2b,%esi
    14e3:	0f 84 b7 09 00 00    	je     1ea0 <op+0xc40>
    14e9:	83 fa 04             	cmp    $0x4,%edx
    14ec:	0f 84 41 0a 00 00    	je     1f33 <op+0xcd3>
    14f2:	f6 c2 01             	test   $0x1,%dl
    14f5:	74 14                	je     150b <op+0x2ab>
    14f7:	66 0f ef d2          	pxor   %xmm2,%xmm2
    14fb:	41 be 02 00 00 00    	mov    $0x2,%r14d
    1501:	f2 48 0f 2a d3       	cvtsi2sd %rbx,%xmm2
    1506:	66 49 0f 7e d3       	movq   %xmm2,%r11
    150b:	40 f6 c5 01          	test   $0x1,%bpl
    150f:	0f 84 b9 fe ff ff    	je     13ce <op+0x16e>
    1515:	66 0f ef c9          	pxor   %xmm1,%xmm1
    1519:	bd 02 00 00 00       	mov    $0x2,%ebp
    151e:	f2 49 0f 2a cf       	cvtsi2sd %r15,%xmm1
    1523:	66 48 0f 7e c9       	movq   %xmm1,%rcx
    1528:	e9 a1 fe ff ff       	jmp    13ce <op+0x16e>
    152d:	0f 1f 00             	nopl   (%rax)
    1530:	bf 00 00 00 00       	mov    $0x0,%edi
			1531: R_X86_64_32	.rodata.str1.8+0x150
    1535:	48 83 c4 50          	add    $0x50,%rsp
    1539:	31 c0                	xor    %eax,%eax
    153b:	5b                   	pop    %rbx
    153c:	5d                   	pop    %rbp
    153d:	41 5c                	pop    %r12
    153f:	41 5e                	pop    %r14
    1541:	41 5f                	pop    %r15
    1543:	e9 00 00 00 00       	jmp    1548 <op+0x2e8>
			1544: R_X86_64_PLT32	zerr-0x4
    1548:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    154f:	00 
    1550:	83 fe 2b             	cmp    $0x2b,%esi
    1553:	0f 87 59 04 00 00    	ja     19b2 <op+0x752>
    1559:	ff 24 f5 00 00 00 00 	jmp    *0x0(,%rsi,8)
			155c: R_X86_64_32S	.rodata+0x6d0
    1560:	66 49 0f 6e e7       	movq   %r15,%xmm4
    1565:	bd 01 00 00 00       	mov    $0x1,%ebp
    156a:	f2 48 0f 2c cc       	cvttsd2si %xmm4,%rcx
    156f:	e9 5a fe ff ff       	jmp    13ce <op+0x16e>
    1574:	48 8b 79 10          	mov    0x10(%rcx),%rdi
    1578:	48 8b 51 18          	mov    0x18(%rcx),%rdx
    157c:	48 8d 77 ff          	lea    -0x1(%rdi),%rsi
    1580:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
    1584:	0f 84 8d fe ff ff    	je     1417 <op+0x1b7>
    158a:	66 48 0f 6e ef       	movq   %rdi,%xmm5
    158f:	f2 0f 5c 2d 00 00 00 	subsd  0x0(%rip),%xmm5        # 1597 <op+0x337>
    1596:	00 
			1593: R_X86_64_PC32	.LC11-0x4
    1597:	66 48 0f 7e ee       	movq   %xmm5,%rsi
    159c:	e9 76 fe ff ff       	jmp    1417 <op+0x1b7>
    15a1:	48 8b 41 10          	mov    0x10(%rcx),%rax
    15a5:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
    15a9:	0f 84 61 08 00 00    	je     1e10 <op+0xbb0>
    15af:	66 48 0f 6e c0       	movq   %rax,%xmm0
    15b4:	f2 0f 58 05 00 00 00 	addsd  0x0(%rip),%xmm0        # 15bc <op+0x35c>
    15bb:	00 
			15b8: R_X86_64_PC32	.LC11-0x4
    15bc:	f2 0f 11 41 10       	movsd  %xmm0,0x10(%rcx)
    15c1:	48 63 3d 00 00 00 00 	movslq 0x0(%rip),%rdi        # 15c8 <op+0x368>
			15c4: R_X86_64_PC32	.data-0x4
    15c8:	48 8b 71 10          	mov    0x10(%rcx),%rsi
    15cc:	48 8b 51 18          	mov    0x18(%rcx),%rdx
    15d0:	48 c1 e7 05          	shl    $0x5,%rdi
    15d4:	48 03 3d 00 00 00 00 	add    0x0(%rip),%rdi        # 15db <op+0x37b>
			15d7: R_X86_64_PC32	.bss+0x4c
    15db:	e8 20 ea ff ff       	call   0 <setmathvar>
    15e0:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 15e7 <op+0x387>
			15e3: R_X86_64_PC32	.data-0x4
    15e7:	48 c1 e0 05          	shl    $0x5,%rax
    15eb:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 15f2 <op+0x392>
			15ee: R_X86_64_PC32	.bss+0x4c
    15f2:	e9 49 fe ff ff       	jmp    1440 <op+0x1e0>
    15f7:	48 8b 41 10          	mov    0x10(%rcx),%rax
    15fb:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
    15ff:	0f 84 7b 08 00 00    	je     1e80 <op+0xc20>
    1605:	66 48 0f 6e c0       	movq   %rax,%xmm0
    160a:	f2 0f 5c 05 00 00 00 	subsd  0x0(%rip),%xmm0        # 1612 <op+0x3b2>
    1611:	00 
			160e: R_X86_64_PC32	.LC11-0x4
    1612:	f2 0f 11 41 10       	movsd  %xmm0,0x10(%rcx)
    1617:	eb a8                	jmp    15c1 <op+0x361>
    1619:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 1620 <op+0x3c0>
			161c: R_X86_64_PC32	.data-0x4
    1620:	48 c1 e0 05          	shl    $0x5,%rax
    1624:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 162b <op+0x3cb>
			1627: R_X86_64_PC32	.bss+0x4c
    162b:	e9 10 fe ff ff       	jmp    1440 <op+0x1e0>
    1630:	48 63 0d 00 00 00 00 	movslq 0x0(%rip),%rcx        # 1637 <op+0x3d7>
			1633: R_X86_64_PC32	.data-0x4
    1637:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 163e <op+0x3de>
			163a: R_X86_64_PC32	.bss+0x4c
    163e:	48 89 c8             	mov    %rcx,%rax
    1641:	48 c1 e1 05          	shl    $0x5,%rcx
    1645:	48 01 d1             	add    %rdx,%rcx
    1648:	83 79 18 04          	cmpl   $0x4,0x18(%rcx)
    164c:	75 25                	jne    1673 <op+0x413>
    164e:	48 89 cf             	mov    %rcx,%rdi
    1651:	48 89 0c 24          	mov    %rcx,(%rsp)
    1655:	e8 06 fb ff ff       	call   1160 <getmathparam>
    165a:	48 8b 0c 24          	mov    (%rsp),%rcx
    165e:	48 89 41 10          	mov    %rax,0x10(%rcx)
    1662:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 1668 <op+0x408>
			1664: R_X86_64_PC32	.data-0x4
    1668:	48 89 51 18          	mov    %rdx,0x18(%rcx)
    166c:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 1673 <op+0x413>
			166f: R_X86_64_PC32	.bss+0x4c
    1673:	8b 35 00 00 00 00    	mov    0x0(%rip),%esi        # 1679 <op+0x419>
			1675: R_X86_64_PC32	errflag-0x4
    1679:	83 e8 01             	sub    $0x1,%eax
    167c:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 1682 <op+0x422>
			167e: R_X86_64_PC32	.data-0x4
    1682:	85 f6                	test   %esi,%esi
    1684:	0f 85 ae 07 00 00    	jne    1e38 <op+0xbd8>
    168a:	4c 8b 79 10          	mov    0x10(%rcx),%r15
    168e:	48 8b 49 18          	mov    0x18(%rcx),%rcx
    1692:	49 89 c9             	mov    %rcx,%r9
    1695:	41 89 ce             	mov    %ecx,%r14d
    1698:	48 63 c8             	movslq %eax,%rcx
    169b:	4d 89 f8             	mov    %r15,%r8
    169e:	48 c1 e1 05          	shl    $0x5,%rcx
    16a2:	48 01 d1             	add    %rdx,%rcx
    16a5:	83 79 18 04          	cmpl   $0x4,0x18(%rcx)
    16a9:	75 39                	jne    16e4 <op+0x484>
    16ab:	48 89 cf             	mov    %rcx,%rdi
    16ae:	4c 89 4c 24 18       	mov    %r9,0x18(%rsp)
    16b3:	48 89 0c 24          	mov    %rcx,(%rsp)
    16b7:	4c 89 7c 24 10       	mov    %r15,0x10(%rsp)
    16bc:	e8 9f fa ff ff       	call   1160 <getmathparam>
    16c1:	48 8b 0c 24          	mov    (%rsp),%rcx
    16c5:	4c 8b 44 24 10       	mov    0x10(%rsp),%r8
    16ca:	4c 8b 4c 24 18       	mov    0x18(%rsp),%r9
    16cf:	48 89 41 10          	mov    %rax,0x10(%rcx)
    16d3:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 16d9 <op+0x479>
			16d5: R_X86_64_PC32	.data-0x4
    16d9:	48 89 51 18          	mov    %rdx,0x18(%rcx)
    16dd:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 16e4 <op+0x484>
			16e0: R_X86_64_PC32	.bss+0x4c
    16e4:	8b 3d 00 00 00 00    	mov    0x0(%rip),%edi        # 16ea <op+0x48a>
			16e6: R_X86_64_PC32	errflag-0x4
    16ea:	83 e8 01             	sub    $0x1,%eax
    16ed:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 16f3 <op+0x493>
			16ef: R_X86_64_PC32	.data-0x4
    16f3:	85 ff                	test   %edi,%edi
    16f5:	0f 85 25 07 00 00    	jne    1e20 <op+0xbc0>
    16fb:	4c 8b 59 10          	mov    0x10(%rcx),%r11
    16ff:	4c 8b 51 18          	mov    0x18(%rcx),%r10
    1703:	48 63 c8             	movslq %eax,%rcx
    1706:	4c 89 1c 24          	mov    %r11,(%rsp)
    170a:	48 c1 e1 05          	shl    $0x5,%rcx
    170e:	4c 89 54 24 08       	mov    %r10,0x8(%rsp)
    1713:	48 01 d1             	add    %rdx,%rcx
    1716:	83 79 18 04          	cmpl   $0x4,0x18(%rcx)
    171a:	75 43                	jne    175f <op+0x4ff>
    171c:	48 89 cf             	mov    %rcx,%rdi
    171f:	4c 89 4c 24 38       	mov    %r9,0x38(%rsp)
    1724:	4c 89 5c 24 40       	mov    %r11,0x40(%rsp)
    1729:	44 89 54 24 20       	mov    %r10d,0x20(%rsp)
    172e:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
    1733:	4c 89 44 24 30       	mov    %r8,0x30(%rsp)
    1738:	e8 23 fa ff ff       	call   1160 <getmathparam>
    173d:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
    1742:	4c 8b 4c 24 38       	mov    0x38(%rsp),%r9
    1747:	4c 8b 5c 24 40       	mov    0x40(%rsp),%r11
    174c:	44 8b 54 24 20       	mov    0x20(%rsp),%r10d
    1751:	48 89 51 18          	mov    %rdx,0x18(%rcx)
    1755:	48 89 41 10          	mov    %rax,0x10(%rcx)
    1759:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 175f <op+0x4ff>
			175b: R_X86_64_PC32	.data-0x4
    175f:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 1765 <op+0x505>
			1761: R_X86_64_PC32	errflag-0x4
    1765:	8d 78 ff             	lea    -0x1(%rax),%edi
    1768:	89 3d 00 00 00 00    	mov    %edi,0x0(%rip)        # 176e <op+0x50e>
			176a: R_X86_64_PC32	.data-0x4
    176e:	85 d2                	test   %edx,%edx
    1770:	0f 85 f2 06 00 00    	jne    1e68 <op+0xc08>
    1776:	48 8b 71 10          	mov    0x10(%rcx),%rsi
    177a:	48 8b 49 18          	mov    0x18(%rcx),%rcx
    177e:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 1784 <op+0x524>
			1780: R_X86_64_PC32	errflag-0x4
    1784:	85 d2                	test   %edx,%edx
    1786:	0f 85 bb fc ff ff    	jne    1447 <op+0x1e7>
    178c:	83 e1 02             	and    $0x2,%ecx
    178f:	0f 84 8b 07 00 00    	je     1f20 <op+0xcc0>
    1795:	66 0f ef c0          	pxor   %xmm0,%xmm0
    1799:	66 48 0f 6e d6       	movq   %rsi,%xmm2
    179e:	66 0f 2e d0          	ucomisd %xmm0,%xmm2
    17a2:	0f 8a 81 07 00 00    	jp     1f29 <op+0xcc9>
    17a8:	0f 85 7b 07 00 00    	jne    1f29 <op+0xcc9>
    17ae:	45 89 f2             	mov    %r14d,%r10d
    17b1:	4d 89 fb             	mov    %r15,%r11
    17b4:	4c 89 ca             	mov    %r9,%rdx
    17b7:	45 89 d2             	mov    %r10d,%r10d
    17ba:	4d 89 d8             	mov    %r11,%r8
    17bd:	48 b9 00 00 00 00 ff 	movabs $0xffffffff00000000,%rcx
    17c4:	ff ff ff 
    17c7:	48 21 ca             	and    %rcx,%rdx
    17ca:	4c 09 d2             	or     %r10,%rdx
    17cd:	49 89 d1             	mov    %rdx,%r9
    17d0:	83 ff 63             	cmp    $0x63,%edi
    17d3:	0f 84 78 07 00 00    	je     1f51 <op+0xcf1>
    17d9:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 17df <op+0x57f>
			17db: R_X86_64_PC32	.data-0x4
    17df:	48 98                	cltq
    17e1:	66 0f ef c0          	pxor   %xmm0,%xmm0
    17e5:	48 c1 e0 05          	shl    $0x5,%rax
    17e9:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 17f0 <op+0x590>
			17ec: R_X86_64_PC32	.bss+0x4c
    17f0:	4c 89 40 10          	mov    %r8,0x10(%rax)
    17f4:	4c 89 48 18          	mov    %r9,0x18(%rax)
    17f8:	0f 11 00             	movups %xmm0,(%rax)
    17fb:	e9 40 fc ff ff       	jmp    1440 <op+0x1e0>
    1800:	31 c0                	xor    %eax,%eax
    1802:	bf 00 00 00 00       	mov    $0x0,%edi
			1803: R_X86_64_32	.rodata.str1.8+0x128
    1807:	e8 00 00 00 00       	call   180c <op+0x5ac>
			1808: R_X86_64_PLT32	zerr-0x4
    180c:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 1813 <op+0x5b3>
			180f: R_X86_64_PC32	.data-0x4
    1813:	48 c1 e0 05          	shl    $0x5,%rax
    1817:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 181e <op+0x5be>
			181a: R_X86_64_PC32	.bss+0x4c
    181e:	e9 1d fc ff ff       	jmp    1440 <op+0x1e0>
    1823:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 182a <op+0x5ca>
			1826: R_X86_64_PC32	.data-0x4
    182a:	48 8b 51 10          	mov    0x10(%rcx),%rdx
    182e:	48 c1 e0 05          	shl    $0x5,%rax
    1832:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 1839 <op+0x5d9>
			1835: R_X86_64_PC32	.bss+0x4c
    1839:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
    183d:	0f 84 0d 06 00 00    	je     1e50 <op+0xbf0>
    1843:	66 48 0f 6e f2       	movq   %rdx,%xmm6
    1848:	66 0f ef c0          	pxor   %xmm0,%xmm0
    184c:	31 d2                	xor    %edx,%edx
    184e:	be 00 00 00 00       	mov    $0x0,%esi
    1853:	66 0f 2e f0          	ucomisd %xmm0,%xmm6
    1857:	c7 41 18 01 00 00 00 	movl   $0x1,0x18(%rcx)
    185e:	0f 9b c2             	setnp  %dl
    1861:	48 0f 45 d6          	cmovne %rsi,%rdx
    1865:	48 89 51 10          	mov    %rdx,0x10(%rcx)
    1869:	e9 d2 fb ff ff       	jmp    1440 <op+0x1e0>
    186e:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 1875 <op+0x615>
			1871: R_X86_64_PC32	.data-0x4
    1875:	48 8b 51 10          	mov    0x10(%rcx),%rdx
    1879:	48 c1 e0 05          	shl    $0x5,%rax
    187d:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 1884 <op+0x624>
			1880: R_X86_64_PC32	.bss+0x4c
    1884:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
    1888:	0f 84 02 06 00 00    	je     1e90 <op+0xc30>
    188e:	66 48 0f 6e fa       	movq   %rdx,%xmm7
    1893:	c7 41 18 01 00 00 00 	movl   $0x1,0x18(%rcx)
    189a:	f2 48 0f 2c d7       	cvttsd2si %xmm7,%rdx
    189f:	48 f7 d2             	not    %rdx
    18a2:	48 89 51 10          	mov    %rdx,0x10(%rcx)
    18a6:	e9 95 fb ff ff       	jmp    1440 <op+0x1e0>
    18ab:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 18b2 <op+0x652>
			18ae: R_X86_64_PC32	.data-0x4
    18b2:	48 8b 51 10          	mov    0x10(%rcx),%rdx
    18b6:	48 c1 e0 05          	shl    $0x5,%rax
    18ba:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 18c1 <op+0x661>
			18bd: R_X86_64_PC32	.bss+0x4c
    18c1:	f6 41 18 02          	testb  $0x2,0x18(%rcx)
    18c5:	0f 84 35 05 00 00    	je     1e00 <op+0xba0>
    18cb:	66 48 0f 6e c2       	movq   %rdx,%xmm0
    18d0:	66 0f 57 05 00 00 00 	xorpd  0x0(%rip),%xmm0        # 18d8 <op+0x678>
    18d7:	00 
			18d4: R_X86_64_PC32	.LC4-0x4
    18d8:	f2 0f 11 41 10       	movsd  %xmm0,0x10(%rcx)
    18dd:	e9 5e fb ff ff       	jmp    1440 <op+0x1e0>
    18e2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    18e8:	41 be 01 00 00 00    	mov    $0x1,%r14d
    18ee:	31 c9                	xor    %ecx,%ecx
    18f0:	41 83 e2 60          	and    $0x60,%r10d
    18f4:	0f 84 96 03 00 00    	je     1c90 <op+0xa30>
    18fa:	48 63 c7             	movslq %edi,%rax
    18fd:	49 89 c8             	mov    %rcx,%r8
    1900:	4c 89 ca             	mov    %r9,%rdx
    1903:	48 b9 00 00 00 00 ff 	movabs $0xffffffff00000000,%rcx
    190a:	ff ff ff 
    190d:	48 c1 e0 05          	shl    $0x5,%rax
    1911:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 1918 <op+0x6b8>
			1914: R_X86_64_PC32	.bss+0x4c
    1918:	48 21 ca             	and    %rcx,%rdx
    191b:	4c 89 c6             	mov    %r8,%rsi
    191e:	48 89 c7             	mov    %rax,%rdi
    1921:	44 89 f0             	mov    %r14d,%eax
    1924:	48 09 c2             	or     %rax,%rdx
    1927:	48 89 3c 24          	mov    %rdi,(%rsp)
    192b:	e8 d0 e6 ff ff       	call   0 <setmathvar>
    1930:	48 8b 3c 24          	mov    (%rsp),%rdi
    1934:	48 89 d1             	mov    %rdx,%rcx
    1937:	48 89 c2             	mov    %rax,%rdx
    193a:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 1940 <op+0x6e0>
			193c: R_X86_64_PC32	.data-0x4
    1940:	48 8b 37             	mov    (%rdi),%rsi
    1943:	83 f8 63             	cmp    $0x63,%eax
    1946:	0f 84 9c 05 00 00    	je     1ee8 <op+0xc88>
    194c:	83 c0 01             	add    $0x1,%eax
    194f:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 1955 <op+0x6f5>
			1951: R_X86_64_PC32	.data-0x4
    1955:	48 98                	cltq
    1957:	48 c1 e0 05          	shl    $0x5,%rax
    195b:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 1962 <op+0x702>
			195e: R_X86_64_PC32	.bss+0x4c
    1962:	48 89 50 10          	mov    %rdx,0x10(%rax)
    1966:	48 89 48 18          	mov    %rcx,0x18(%rax)
    196a:	48 89 30             	mov    %rsi,(%rax)
    196d:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
    1974:	00 
    1975:	e9 cd fa ff ff       	jmp    1447 <op+0x1e7>
    197a:	48 85 c9             	test   %rcx,%rcx
    197d:	0f 88 d9 06 00 00    	js     205c <op+0xdfc>
    1983:	0f 84 00 07 00 00    	je     2089 <op+0xe29>
    1989:	48 8d 51 ff          	lea    -0x1(%rcx),%rdx
    198d:	b9 01 00 00 00       	mov    $0x1,%ecx
    1992:	f6 c2 01             	test   $0x1,%dl
    1995:	75 09                	jne    19a0 <op+0x740>
    1997:	4c 89 d9             	mov    %r11,%rcx
    199a:	48 83 ea 01          	sub    $0x1,%rdx
    199e:	72 12                	jb     19b2 <op+0x752>
    19a0:	49 0f af cb          	imul   %r11,%rcx
    19a4:	48 83 ea 02          	sub    $0x2,%rdx
    19a8:	49 0f af cb          	imul   %r11,%rcx
    19ac:	48 83 fa ff          	cmp    $0xffffffffffffffff,%rdx
    19b0:	75 ee                	jne    19a0 <op+0x740>
    19b2:	41 be 01 00 00 00    	mov    $0x1,%r14d
    19b8:	e9 33 ff ff ff       	jmp    18f0 <op+0x690>
    19bd:	0f 1f 00             	nopl   (%rax)
    19c0:	48 8b 54 24 08       	mov    0x8(%rsp),%rdx
    19c5:	89 e8                	mov    %ebp,%eax
    19c7:	48 89 0c 24          	mov    %rcx,(%rsp)
    19cb:	41 89 ee             	mov    %ebp,%r14d
    19ce:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
    19d3:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
    19d8:	48 ba 00 00 00 00 ff 	movabs $0xffffffff00000000,%rdx
    19df:	ff ff ff 
    19e2:	49 89 f0             	mov    %rsi,%r8
    19e5:	49 21 d0             	and    %rdx,%r8
    19e8:	49 09 c0             	or     %rax,%r8
    19eb:	4d 89 c1             	mov    %r8,%r9
    19ee:	e9 fd fe ff ff       	jmp    18f0 <op+0x690>
    19f3:	41 be 01 00 00 00    	mov    $0x1,%r14d
    19f9:	4d 85 db             	test   %r11,%r11
    19fc:	0f 95 c0             	setne  %al
    19ff:	48 85 c9             	test   %rcx,%rcx
    1a02:	0f 95 c2             	setne  %dl
    1a05:	31 d0                	xor    %edx,%eax
    1a07:	0f b6 c8             	movzbl %al,%ecx
    1a0a:	e9 e1 fe ff ff       	jmp    18f0 <op+0x690>
    1a0f:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1a15:	49 09 cb             	or     %rcx,%r11
    1a18:	0f 95 c1             	setne  %cl
    1a1b:	0f b6 c9             	movzbl %cl,%ecx
    1a1e:	e9 cd fe ff ff       	jmp    18f0 <op+0x690>
    1a23:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1a29:	4d 85 db             	test   %r11,%r11
    1a2c:	0f 95 c0             	setne  %al
    1a2f:	48 85 c9             	test   %rcx,%rcx
    1a32:	0f 95 c1             	setne  %cl
    1a35:	0f b6 c9             	movzbl %cl,%ecx
    1a38:	48 21 c1             	and    %rax,%rcx
    1a3b:	e9 b0 fe ff ff       	jmp    18f0 <op+0x690>
    1a40:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1a46:	49 d3 fb             	sar    %cl,%r11
    1a49:	4c 89 d9             	mov    %r11,%rcx
    1a4c:	e9 9f fe ff ff       	jmp    18f0 <op+0x690>
    1a51:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1a57:	49 d3 e3             	shl    %cl,%r11
    1a5a:	4c 89 d9             	mov    %r11,%rcx
    1a5d:	e9 8e fe ff ff       	jmp    18f0 <op+0x690>
    1a62:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1a68:	4c 09 d9             	or     %r11,%rcx
    1a6b:	e9 80 fe ff ff       	jmp    18f0 <op+0x690>
    1a70:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1a76:	4c 31 d9             	xor    %r11,%rcx
    1a79:	e9 72 fe ff ff       	jmp    18f0 <op+0x690>
    1a7e:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1a84:	4c 21 d9             	and    %r11,%rcx
    1a87:	e9 64 fe ff ff       	jmp    18f0 <op+0x690>
    1a8c:	41 83 fe 01          	cmp    $0x1,%r14d
    1a90:	0f 84 e4 fe ff ff    	je     197a <op+0x71a>
    1a96:	66 48 0f 6e c9       	movq   %rcx,%xmm1
    1a9b:	66 0f ef c0          	pxor   %xmm0,%xmm0
    1a9f:	66 0f 2f c1          	comisd %xmm1,%xmm0
    1aa3:	0f 83 85 05 00 00    	jae    202e <op+0xdce>
    1aa9:	66 49 0f 6e c3       	movq   %r11,%xmm0
    1aae:	66 0f ef d2          	pxor   %xmm2,%xmm2
    1ab2:	66 0f 2f d0          	comisd %xmm0,%xmm2
    1ab6:	76 1e                	jbe    1ad6 <op+0x876>
    1ab8:	f2 48 0f 2c c1       	cvttsd2si %xmm1,%rax
    1abd:	66 0f ef d2          	pxor   %xmm2,%xmm2
    1ac1:	f2 48 0f 2a d0       	cvtsi2sd %rax,%xmm2
    1ac6:	66 0f 2e d1          	ucomisd %xmm1,%xmm2
    1aca:	0f 8a 7b 05 00 00    	jp     204b <op+0xdeb>
    1ad0:	0f 85 75 05 00 00    	jne    204b <op+0xdeb>
    1ad6:	4c 89 4c 24 28       	mov    %r9,0x28(%rsp)
    1adb:	89 7c 24 10          	mov    %edi,0x10(%rsp)
    1adf:	44 89 14 24          	mov    %r10d,(%rsp)
    1ae3:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
    1ae8:	e8 00 00 00 00       	call   1aed <op+0x88d>
			1ae9: R_X86_64_PLT32	pow-0x4
    1aed:	44 8b 14 24          	mov    (%rsp),%r10d
    1af1:	8b 7c 24 10          	mov    0x10(%rsp),%edi
    1af5:	4c 8b 4c 24 28       	mov    0x28(%rsp),%r9
    1afa:	66 48 0f 7e c1       	movq   %xmm0,%rcx
    1aff:	e9 ec fd ff ff       	jmp    18f0 <op+0x690>
    1b04:	41 83 fe 02          	cmp    $0x2,%r14d
    1b08:	0f 85 da 00 00 00    	jne    1be8 <op+0x988>
    1b0e:	66 48 0f 6e f9       	movq   %rcx,%xmm7
    1b13:	66 49 0f 6e cb       	movq   %r11,%xmm1
    1b18:	f2 0f 58 cf          	addsd  %xmm7,%xmm1
    1b1c:	66 48 0f 7e c9       	movq   %xmm1,%rcx
    1b21:	e9 ca fd ff ff       	jmp    18f0 <op+0x690>
    1b26:	48 85 c9             	test   %rcx,%rcx
    1b29:	75 09                	jne    1b34 <op+0x8d4>
    1b2b:	83 e5 01             	and    $0x1,%ebp
    1b2e:	0f 85 0d 05 00 00    	jne    2041 <op+0xde1>
    1b34:	41 83 fe 02          	cmp    $0x2,%r14d
    1b38:	0f 85 e7 00 00 00    	jne    1c25 <op+0x9c5>
    1b3e:	66 48 0f 6e c9       	movq   %rcx,%xmm1
    1b43:	66 49 0f 6e c3       	movq   %r11,%xmm0
    1b48:	4c 89 4c 24 28       	mov    %r9,0x28(%rsp)
    1b4d:	89 7c 24 10          	mov    %edi,0x10(%rsp)
    1b51:	44 89 14 24          	mov    %r10d,(%rsp)
    1b55:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
    1b5a:	e8 00 00 00 00       	call   1b5f <op+0x8ff>
			1b5b: R_X86_64_PLT32	fmod-0x4
    1b5f:	44 8b 14 24          	mov    (%rsp),%r10d
    1b63:	8b 7c 24 10          	mov    0x10(%rsp),%edi
    1b67:	4c 8b 4c 24 28       	mov    0x28(%rsp),%r9
    1b6c:	66 48 0f 7e c1       	movq   %xmm0,%rcx
    1b71:	e9 7a fd ff ff       	jmp    18f0 <op+0x690>
    1b76:	48 85 c9             	test   %rcx,%rcx
    1b79:	75 09                	jne    1b84 <op+0x924>
    1b7b:	83 e5 01             	and    $0x1,%ebp
    1b7e:	0f 85 bd 04 00 00    	jne    2041 <op+0xde1>
    1b84:	41 83 fe 02          	cmp    $0x2,%r14d
    1b88:	0f 85 c6 00 00 00    	jne    1c54 <op+0x9f4>
    1b8e:	66 48 0f 6e c9       	movq   %rcx,%xmm1
    1b93:	66 49 0f 6e fb       	movq   %r11,%xmm7
    1b98:	f2 0f 5e f9          	divsd  %xmm1,%xmm7
    1b9c:	66 48 0f 7e f9       	movq   %xmm7,%rcx
    1ba1:	e9 4a fd ff ff       	jmp    18f0 <op+0x690>
    1ba6:	41 83 fe 02          	cmp    $0x2,%r14d
    1baa:	75 59                	jne    1c05 <op+0x9a5>
    1bac:	66 48 0f 6e c9       	movq   %rcx,%xmm1
    1bb1:	66 49 0f 6e f3       	movq   %r11,%xmm6
    1bb6:	f2 0f 5c f1          	subsd  %xmm1,%xmm6
    1bba:	66 48 0f 7e f1       	movq   %xmm6,%rcx
    1bbf:	e9 2c fd ff ff       	jmp    18f0 <op+0x690>
    1bc4:	41 83 fe 02          	cmp    $0x2,%r14d
    1bc8:	75 2c                	jne    1bf6 <op+0x996>
    1bca:	66 48 0f 6e f9       	movq   %rcx,%xmm7
    1bcf:	66 49 0f 6e f3       	movq   %r11,%xmm6
    1bd4:	f2 0f 59 f7          	mulsd  %xmm7,%xmm6
    1bd8:	66 48 0f 7e f1       	movq   %xmm6,%rcx
    1bdd:	e9 0e fd ff ff       	jmp    18f0 <op+0x690>
    1be2:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1be8:	4c 01 d9             	add    %r11,%rcx
    1beb:	e9 00 fd ff ff       	jmp    18f0 <op+0x690>
    1bf0:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1bf6:	49 0f af cb          	imul   %r11,%rcx
    1bfa:	e9 f1 fc ff ff       	jmp    18f0 <op+0x690>
    1bff:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1c05:	49 29 cb             	sub    %rcx,%r11
    1c08:	4c 89 d9             	mov    %r11,%rcx
    1c0b:	e9 e0 fc ff ff       	jmp    18f0 <op+0x690>
    1c10:	48 85 c9             	test   %rcx,%rcx
    1c13:	75 0a                	jne    1c1f <op+0x9bf>
    1c15:	40 80 e5 01          	and    $0x1,%bpl
    1c19:	0f 85 22 04 00 00    	jne    2041 <op+0xde1>
    1c1f:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1c25:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
    1c29:	0f 84 26 04 00 00    	je     2055 <op+0xdf5>
    1c2f:	4c 89 d8             	mov    %r11,%rax
    1c32:	48 99                	cqto
    1c34:	48 f7 f9             	idiv   %rcx
    1c37:	48 89 d1             	mov    %rdx,%rcx
    1c3a:	e9 b1 fc ff ff       	jmp    18f0 <op+0x690>
    1c3f:	48 85 c9             	test   %rcx,%rcx
    1c42:	75 0a                	jne    1c4e <op+0x9ee>
    1c44:	40 80 e5 01          	and    $0x1,%bpl
    1c48:	0f 85 f3 03 00 00    	jne    2041 <op+0xde1>
    1c4e:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1c54:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
    1c58:	0f 84 20 04 00 00    	je     207e <op+0xe1e>
    1c5e:	4c 89 d8             	mov    %r11,%rax
    1c61:	48 99                	cqto
    1c63:	48 f7 f9             	idiv   %rcx
    1c66:	48 89 c1             	mov    %rax,%rcx
    1c69:	e9 82 fc ff ff       	jmp    18f0 <op+0x690>
    1c6e:	44 89 f2             	mov    %r14d,%edx
    1c71:	41 83 fe 02          	cmp    $0x2,%r14d
    1c75:	0f 84 35 03 00 00    	je     1fb0 <op+0xd50>
    1c7b:	49 39 cb             	cmp    %rcx,%r11
    1c7e:	41 89 d6             	mov    %edx,%r14d
    1c81:	0f 9c c1             	setl   %cl
    1c84:	0f b6 c9             	movzbl %cl,%ecx
    1c87:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    1c8e:	00 00 
    1c90:	4c 89 c8             	mov    %r9,%rax
    1c93:	49 89 c8             	mov    %rcx,%r8
    1c96:	44 89 f2             	mov    %r14d,%edx
    1c99:	48 b9 00 00 00 00 ff 	movabs $0xffffffff00000000,%rcx
    1ca0:	ff ff ff 
    1ca3:	48 21 c8             	and    %rcx,%rax
    1ca6:	48 09 d0             	or     %rdx,%rax
    1ca9:	49 89 c1             	mov    %rax,%r9
    1cac:	41 83 fc 63          	cmp    $0x63,%r12d
    1cb0:	0f 84 02 02 00 00    	je     1eb8 <op+0xc58>
    1cb6:	89 3d 00 00 00 00    	mov    %edi,0x0(%rip)        # 1cbc <op+0xa5c>
			1cb8: R_X86_64_PC32	.data-0x4
    1cbc:	48 63 c7             	movslq %edi,%rax
    1cbf:	66 0f ef c0          	pxor   %xmm0,%xmm0
    1cc3:	48 c1 e0 05          	shl    $0x5,%rax
    1cc7:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 1cce <op+0xa6e>
			1cca: R_X86_64_PC32	.bss+0x4c
    1cce:	4c 89 40 10          	mov    %r8,0x10(%rax)
    1cd2:	4c 89 48 18          	mov    %r9,0x18(%rax)
    1cd6:	0f 11 00             	movups %xmm0,(%rax)
    1cd9:	e9 69 f7 ff ff       	jmp    1447 <op+0x1e7>
    1cde:	44 89 f2             	mov    %r14d,%edx
    1ce1:	41 83 fe 02          	cmp    $0x2,%r14d
    1ce5:	0f 84 e0 02 00 00    	je     1fcb <op+0xd6b>
    1ceb:	49 39 cb             	cmp    %rcx,%r11
    1cee:	41 89 d6             	mov    %edx,%r14d
    1cf1:	0f 95 c1             	setne  %cl
    1cf4:	0f b6 c9             	movzbl %cl,%ecx
    1cf7:	eb 97                	jmp    1c90 <op+0xa30>
    1cf9:	ba 01 00 00 00       	mov    $0x1,%edx
    1cfe:	41 83 fe 02          	cmp    $0x2,%r14d
    1d02:	0f 84 e7 02 00 00    	je     1fef <op+0xd8f>
    1d08:	49 39 cb             	cmp    %rcx,%r11
    1d0b:	41 89 d6             	mov    %edx,%r14d
    1d0e:	0f 94 c1             	sete   %cl
    1d11:	0f b6 c9             	movzbl %cl,%ecx
    1d14:	e9 77 ff ff ff       	jmp    1c90 <op+0xa30>
    1d19:	ba 01 00 00 00       	mov    $0x1,%edx
    1d1e:	41 83 fe 02          	cmp    $0x2,%r14d
    1d22:	0f 84 6d 02 00 00    	je     1f95 <op+0xd35>
    1d28:	49 39 cb             	cmp    %rcx,%r11
    1d2b:	41 89 d6             	mov    %edx,%r14d
    1d2e:	0f 9f c1             	setg   %cl
    1d31:	0f b6 c9             	movzbl %cl,%ecx
    1d34:	e9 57 ff ff ff       	jmp    1c90 <op+0xa30>
    1d39:	44 89 f2             	mov    %r14d,%edx
    1d3c:	eb c0                	jmp    1cfe <op+0xa9e>
    1d3e:	ba 01 00 00 00       	mov    $0x1,%edx
    1d43:	e9 29 ff ff ff       	jmp    1c71 <op+0xa11>
    1d48:	ba 01 00 00 00       	mov    $0x1,%edx
    1d4d:	41 83 fe 02          	cmp    $0x2,%r14d
    1d51:	0f 84 bc 02 00 00    	je     2013 <op+0xdb3>
    1d57:	49 39 cb             	cmp    %rcx,%r11
    1d5a:	41 89 d6             	mov    %edx,%r14d
    1d5d:	0f 9d c1             	setge  %cl
    1d60:	0f b6 c9             	movzbl %cl,%ecx
    1d63:	e9 28 ff ff ff       	jmp    1c90 <op+0xa30>
    1d68:	ba 01 00 00 00       	mov    $0x1,%edx
    1d6d:	41 83 fe 02          	cmp    $0x2,%r14d
    1d71:	0f 84 03 02 00 00    	je     1f7a <op+0xd1a>
    1d77:	49 39 cb             	cmp    %rcx,%r11
    1d7a:	41 89 d6             	mov    %edx,%r14d
    1d7d:	0f 9e c1             	setle  %cl
    1d80:	0f b6 c9             	movzbl %cl,%ecx
    1d83:	e9 08 ff ff ff       	jmp    1c90 <op+0xa30>
    1d88:	ba 01 00 00 00       	mov    $0x1,%edx
    1d8d:	e9 4f ff ff ff       	jmp    1ce1 <op+0xa81>
    1d92:	44 89 f2             	mov    %r14d,%edx
    1d95:	eb 87                	jmp    1d1e <op+0xabe>
    1d97:	44 89 f2             	mov    %r14d,%edx
    1d9a:	eb d1                	jmp    1d6d <op+0xb0d>
    1d9c:	44 89 f2             	mov    %r14d,%edx
    1d9f:	eb ac                	jmp    1d4d <op+0xaed>
    1da1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    1da8:	4c 89 df             	mov    %r11,%rdi
    1dab:	89 74 24 4c          	mov    %esi,0x4c(%rsp)
    1daf:	4c 89 44 24 30       	mov    %r8,0x30(%rsp)
    1db4:	4c 89 4c 24 38       	mov    %r9,0x38(%rsp)
    1db9:	44 89 54 24 20       	mov    %r10d,0x20(%rsp)
    1dbe:	4c 89 5c 24 10       	mov    %r11,0x10(%rsp)
    1dc3:	4c 89 7c 24 40       	mov    %r15,0x40(%rsp)
    1dc8:	e8 93 f3 ff ff       	call   1160 <getmathparam>
    1dcd:	4c 8b 5c 24 10       	mov    0x10(%rsp),%r11
    1dd2:	8b 3d 00 00 00 00    	mov    0x0(%rip),%edi        # 1dd8 <op+0xb78>
			1dd4: R_X86_64_PC32	.data-0x4
    1dd8:	8b 74 24 4c          	mov    0x4c(%rsp),%esi
    1ddc:	4c 8b 44 24 30       	mov    0x30(%rsp),%r8
    1de1:	4c 8b 4c 24 38       	mov    0x38(%rsp),%r9
    1de6:	48 8b 4c 24 40       	mov    0x40(%rsp),%rcx
    1deb:	49 89 43 10          	mov    %rax,0x10(%r11)
    1def:	49 89 53 18          	mov    %rdx,0x18(%r11)
    1df3:	44 8b 54 24 20       	mov    0x20(%rsp),%r10d
    1df8:	e9 6c f5 ff ff       	jmp    1369 <op+0x109>
    1dfd:	0f 1f 00             	nopl   (%rax)
    1e00:	48 f7 da             	neg    %rdx
    1e03:	48 89 51 10          	mov    %rdx,0x10(%rcx)
    1e07:	e9 34 f6 ff ff       	jmp    1440 <op+0x1e0>
    1e0c:	0f 1f 40 00          	nopl   0x0(%rax)
    1e10:	48 83 c0 01          	add    $0x1,%rax
    1e14:	48 89 41 10          	mov    %rax,0x10(%rcx)
    1e18:	e9 a4 f7 ff ff       	jmp    15c1 <op+0x361>
    1e1d:	0f 1f 00             	nopl   (%rax)
    1e20:	4c 8b 1d 00 00 00 00 	mov    0x0(%rip),%r11        # 1e27 <op+0xbc7>
			1e23: R_X86_64_PC32	zero_mnumber-0x4
    1e27:	4c 8b 15 00 00 00 00 	mov    0x0(%rip),%r10        # 1e2e <op+0xbce>
			1e2a: R_X86_64_PC32	zero_mnumber+0x4
    1e2e:	e9 d0 f8 ff ff       	jmp    1703 <op+0x4a3>
    1e33:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    1e38:	4c 8b 3d 00 00 00 00 	mov    0x0(%rip),%r15        # 1e3f <op+0xbdf>
			1e3b: R_X86_64_PC32	zero_mnumber-0x4
    1e3f:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 1e46 <op+0xbe6>
			1e42: R_X86_64_PC32	zero_mnumber+0x4
    1e46:	e9 47 f8 ff ff       	jmp    1692 <op+0x432>
    1e4b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    1e50:	48 85 d2             	test   %rdx,%rdx
    1e53:	0f 94 c2             	sete   %dl
    1e56:	0f b6 d2             	movzbl %dl,%edx
    1e59:	48 89 51 10          	mov    %rdx,0x10(%rcx)
    1e5d:	e9 de f5 ff ff       	jmp    1440 <op+0x1e0>
    1e62:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1e68:	48 8b 35 00 00 00 00 	mov    0x0(%rip),%rsi        # 1e6f <op+0xc0f>
			1e6b: R_X86_64_PC32	zero_mnumber-0x4
    1e6f:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 1e76 <op+0xc16>
			1e72: R_X86_64_PC32	zero_mnumber+0x4
    1e76:	e9 03 f9 ff ff       	jmp    177e <op+0x51e>
    1e7b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    1e80:	48 83 e8 01          	sub    $0x1,%rax
    1e84:	48 89 41 10          	mov    %rax,0x10(%rcx)
    1e88:	e9 34 f7 ff ff       	jmp    15c1 <op+0x361>
    1e8d:	0f 1f 00             	nopl   (%rax)
    1e90:	48 f7 d2             	not    %rdx
    1e93:	48 89 51 10          	mov    %rdx,0x10(%rcx)
    1e97:	e9 a4 f5 ff ff       	jmp    1440 <op+0x1e0>
    1e9c:	0f 1f 40 00          	nopl   0x0(%rax)
    1ea0:	85 c0                	test   %eax,%eax
    1ea2:	0f 84 18 fb ff ff    	je     19c0 <op+0x760>
    1ea8:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1eae:	31 c9                	xor    %ecx,%ecx
    1eb0:	e9 db fd ff ff       	jmp    1c90 <op+0xa30>
    1eb5:	0f 1f 00             	nopl   (%rax)
    1eb8:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    1ebd:	bf 00 00 00 00       	mov    $0x0,%edi
			1ebe: R_X86_64_32	.rodata.str1.1+0x5b
    1ec2:	31 c0                	xor    %eax,%eax
    1ec4:	4c 89 04 24          	mov    %r8,(%rsp)
    1ec8:	e8 00 00 00 00       	call   1ecd <op+0xc6d>
			1ec9: R_X86_64_PLT32	zerr-0x4
    1ecd:	8b 3d 00 00 00 00    	mov    0x0(%rip),%edi        # 1ed3 <op+0xc73>
			1ecf: R_X86_64_PC32	.data-0x4
    1ed3:	4c 8b 04 24          	mov    (%rsp),%r8
    1ed7:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
    1edc:	e9 db fd ff ff       	jmp    1cbc <op+0xa5c>
    1ee1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    1ee8:	31 c0                	xor    %eax,%eax
    1eea:	bf 00 00 00 00       	mov    $0x0,%edi
			1eeb: R_X86_64_32	.rodata.str1.1+0x5b
    1eef:	48 89 54 24 10       	mov    %rdx,0x10(%rsp)
    1ef4:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
    1ef9:	48 89 34 24          	mov    %rsi,(%rsp)
    1efd:	e8 00 00 00 00       	call   1f02 <op+0xca2>
			1efe: R_X86_64_PLT32	zerr-0x4
    1f02:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 1f08 <op+0xca8>
			1f04: R_X86_64_PC32	.data-0x4
    1f08:	48 8b 34 24          	mov    (%rsp),%rsi
    1f0c:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
    1f11:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
    1f16:	e9 3a fa ff ff       	jmp    1955 <op+0x6f5>
    1f1b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    1f20:	48 85 f6             	test   %rsi,%rsi
    1f23:	0f 84 85 f8 ff ff    	je     17ae <op+0x54e>
    1f29:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
    1f2e:	e9 81 f8 ff ff       	jmp    17b4 <op+0x554>
    1f33:	83 fe 1d             	cmp    $0x1d,%esi
    1f36:	0f 85 cf f5 ff ff    	jne    150b <op+0x2ab>
    1f3c:	85 c0                	test   %eax,%eax
    1f3e:	0f 84 7c fa ff ff    	je     19c0 <op+0x760>
    1f44:	41 be 01 00 00 00    	mov    $0x1,%r14d
    1f4a:	31 c9                	xor    %ecx,%ecx
    1f4c:	e9 a9 f9 ff ff       	jmp    18fa <op+0x69a>
    1f51:	31 c0                	xor    %eax,%eax
    1f53:	bf 00 00 00 00       	mov    $0x0,%edi
			1f54: R_X86_64_32	.rodata.str1.1+0x5b
    1f58:	4c 89 1c 24          	mov    %r11,(%rsp)
    1f5c:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
    1f61:	e8 00 00 00 00       	call   1f66 <op+0xd06>
			1f62: R_X86_64_PLT32	zerr-0x4
    1f66:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 1f6c <op+0xd0c>
			1f68: R_X86_64_PC32	.data-0x4
    1f6c:	4c 8b 04 24          	mov    (%rsp),%r8
    1f70:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
    1f75:	e9 65 f8 ff ff       	jmp    17df <op+0x57f>
    1f7a:	66 48 0f 6e f1       	movq   %rcx,%xmm6
    1f7f:	66 49 0f 6e cb       	movq   %r11,%xmm1
    1f84:	31 c9                	xor    %ecx,%ecx
    1f86:	41 89 d6             	mov    %edx,%r14d
    1f89:	66 0f 2f f1          	comisd %xmm1,%xmm6
    1f8d:	0f 93 c1             	setae  %cl
    1f90:	e9 fb fc ff ff       	jmp    1c90 <op+0xa30>
    1f95:	66 48 0f 6e f1       	movq   %rcx,%xmm6
    1f9a:	66 49 0f 6e fb       	movq   %r11,%xmm7
    1f9f:	31 c9                	xor    %ecx,%ecx
    1fa1:	41 89 d6             	mov    %edx,%r14d
    1fa4:	66 0f 2f fe          	comisd %xmm6,%xmm7
    1fa8:	0f 97 c1             	seta   %cl
    1fab:	e9 e0 fc ff ff       	jmp    1c90 <op+0xa30>
    1fb0:	66 48 0f 6e f1       	movq   %rcx,%xmm6
    1fb5:	66 49 0f 6e fb       	movq   %r11,%xmm7
    1fba:	31 c9                	xor    %ecx,%ecx
    1fbc:	41 89 d6             	mov    %edx,%r14d
    1fbf:	66 0f 2f f7          	comisd %xmm7,%xmm6
    1fc3:	0f 97 c1             	seta   %cl
    1fc6:	e9 c5 fc ff ff       	jmp    1c90 <op+0xa30>
    1fcb:	66 48 0f 6e f1       	movq   %rcx,%xmm6
    1fd0:	66 49 0f 6e fb       	movq   %r11,%xmm7
    1fd5:	31 c9                	xor    %ecx,%ecx
    1fd7:	b8 01 00 00 00       	mov    $0x1,%eax
    1fdc:	66 0f 2e fe          	ucomisd %xmm6,%xmm7
    1fe0:	41 89 d6             	mov    %edx,%r14d
    1fe3:	0f 9a c1             	setp   %cl
    1fe6:	48 0f 45 c8          	cmovne %rax,%rcx
    1fea:	e9 a1 fc ff ff       	jmp    1c90 <op+0xa30>
    1fef:	66 48 0f 6e c9       	movq   %rcx,%xmm1
    1ff4:	66 49 0f 6e f3       	movq   %r11,%xmm6
    1ff9:	31 c9                	xor    %ecx,%ecx
    1ffb:	b8 00 00 00 00       	mov    $0x0,%eax
    2000:	66 0f 2e f1          	ucomisd %xmm1,%xmm6
    2004:	41 89 d6             	mov    %edx,%r14d
    2007:	0f 9b c1             	setnp  %cl
    200a:	48 0f 45 c8          	cmovne %rax,%rcx
    200e:	e9 7d fc ff ff       	jmp    1c90 <op+0xa30>
    2013:	66 48 0f 6e f9       	movq   %rcx,%xmm7
    2018:	66 49 0f 6e cb       	movq   %r11,%xmm1
    201d:	31 c9                	xor    %ecx,%ecx
    201f:	41 89 d6             	mov    %edx,%r14d
    2022:	66 0f 2f cf          	comisd %xmm7,%xmm1
    2026:	0f 93 c1             	setae  %cl
    2029:	e9 62 fc ff ff       	jmp    1c90 <op+0xa30>
    202e:	41 f6 c6 01          	test   $0x1,%r14b
    2032:	0f 84 71 fa ff ff    	je     1aa9 <op+0x849>
    2038:	4d 85 db             	test   %r11,%r11
    203b:	0f 85 68 fa ff ff    	jne    1aa9 <op+0x849>
    2041:	bf 00 00 00 00       	mov    $0x0,%edi
			2042: R_X86_64_32	.rodata.str1.1+0x4a
    2046:	e9 ea f4 ff ff       	jmp    1535 <op+0x2d5>
    204b:	bf 00 00 00 00       	mov    $0x0,%edi
			204c: R_X86_64_32	.rodata.str1.8+0x100
    2050:	e9 e0 f4 ff ff       	jmp    1535 <op+0x2d5>
    2055:	31 c9                	xor    %ecx,%ecx
    2057:	e9 94 f8 ff ff       	jmp    18f0 <op+0x690>
    205c:	66 0f ef c9          	pxor   %xmm1,%xmm1
    2060:	41 be 02 00 00 00    	mov    $0x2,%r14d
    2066:	f2 49 0f 2a cb       	cvtsi2sd %r11,%xmm1
    206b:	66 49 0f 7e cb       	movq   %xmm1,%r11
    2070:	66 0f ef c9          	pxor   %xmm1,%xmm1
    2074:	f2 48 0f 2a c9       	cvtsi2sd %rcx,%xmm1
    2079:	e9 2b fa ff ff       	jmp    1aa9 <op+0x849>
    207e:	4c 89 d9             	mov    %r11,%rcx
    2081:	48 f7 d9             	neg    %rcx
    2084:	e9 67 f8 ff ff       	jmp    18f0 <op+0x690>
    2089:	41 be 01 00 00 00    	mov    $0x1,%r14d
    208f:	b9 01 00 00 00       	mov    $0x1,%ecx
    2094:	e9 57 f8 ff ff       	jmp    18f0 <op+0x690>
    2099:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000000020a0 <mathparse>:
    20a0:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 20a6 <mathparse+0x6>
			20a2: R_X86_64_PC32	errflag-0x4
    20a6:	85 c0                	test   %eax,%eax
    20a8:	74 06                	je     20b0 <mathparse+0x10>
    20aa:	c3                   	ret
    20ab:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    20b0:	41 57                	push   %r15
    20b2:	41 56                	push   %r14
    20b4:	41 55                	push   %r13
    20b6:	41 54                	push   %r12
    20b8:	55                   	push   %rbp
    20b9:	53                   	push   %rbx
    20ba:	89 fb                	mov    %edi,%ebx
    20bc:	48 81 ec 48 01 00 00 	sub    $0x148,%rsp
    20c3:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 20c9 <mathparse+0x29>
			20c5: R_X86_64_PC32	queueing_enabled-0x4
    20c9:	48 8b 2d 00 00 00 00 	mov    0x0(%rip),%rbp        # 20d0 <mathparse+0x30>
			20cc: R_X86_64_PC32	.bss+0x8c
    20d0:	83 c0 01             	add    $0x1,%eax
    20d3:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 20d9 <mathparse+0x39>
			20d5: R_X86_64_PC32	queueing_enabled-0x4
    20d9:	e8 52 e6 ff ff       	call   730 <zzlex>
    20de:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 20e5 <mathparse+0x45>
			20e1: R_X86_64_PC32	.bss+0x5c
    20e5:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 20eb <mathparse+0x4b>
			20e7: R_X86_64_PC32	.bss+0x54
    20eb:	41 89 c6             	mov    %eax,%r14d
    20ee:	8b 81 ac 00 00 00    	mov    0xac(%rcx),%eax
    20f4:	83 c0 01             	add    $0x1,%eax
    20f7:	39 d8                	cmp    %ebx,%eax
    20f9:	75 0a                	jne    2105 <mathparse+0x65>
    20fb:	41 83 fe 2c          	cmp    $0x2c,%r14d
    20ff:	0f 84 37 0f 00 00    	je     303c <mathparse+0xf9c>
    2105:	49 63 c6             	movslq %r14d,%rax
    2108:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 210e <mathparse+0x6e>
			210a: R_X86_64_PC32	.data
    210e:	44 8b 3c 85 00 00 00 	mov    0x0(,%rax,4),%r15d
    2115:	00 
			2112: R_X86_64_32S	.rodata+0x900
    2116:	41 f6 c7 fc          	test   $0xfc,%r15b
    211a:	0f 84 90 08 00 00    	je     29b0 <mathparse+0x910>
    2120:	85 d2                	test   %edx,%edx
    2122:	0f 85 98 08 00 00    	jne    29c0 <mathparse+0x920>
    2128:	41 c1 ef 08          	shr    $0x8,%r15d
    212c:	41 83 e7 01          	and    $0x1,%r15d
    2130:	41 83 f7 01          	xor    $0x1,%r15d
    2134:	44 89 3d 00 00 00 00 	mov    %r15d,0x0(%rip)        # 213b <mathparse+0x9b>
			2137: R_X86_64_PC32	.data
    213b:	4c 8d 3c 85 00 00 00 	lea    0x0(,%rax,4),%r15
    2142:	00 
    2143:	3b 1c 81             	cmp    (%rcx,%rax,4),%ebx
    2146:	0f 8c 9c 00 00 00    	jl     21e8 <mathparse+0x148>
    214c:	0f 1f 40 00          	nopl   0x0(%rax)
    2150:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 2156 <mathparse+0xb6>
			2152: R_X86_64_PC32	errflag-0x4
    2156:	85 d2                	test   %edx,%edx
    2158:	0f 85 0a 0c 00 00    	jne    2d68 <mathparse+0xcc8>
    215e:	45 85 f6             	test   %r14d,%r14d
    2161:	0f 84 a1 06 00 00    	je     2808 <mathparse+0x768>
    2167:	41 8d 56 e5          	lea    -0x1b(%r14),%edx
    216b:	83 fa 19             	cmp    $0x19,%edx
    216e:	77 10                	ja     2180 <mathparse+0xe0>
    2170:	ff 24 d5 00 00 00 00 	jmp    *0x0(,%rdx,8)
			2173: R_X86_64_32S	.rodata+0x830
    2177:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    217e:	00 00 
    2180:	8b 34 85 00 00 00 00 	mov    0x0(,%rax,4),%esi
			2183: R_X86_64_32S	.rodata+0x900
    2187:	8b 2d 00 00 00 00    	mov    0x0(%rip),%ebp        # 218d <mathparse+0xed>
			2189: R_X86_64_PC32	noeval-0x4
    218d:	83 e6 03             	and    $0x3,%esi
    2190:	83 fe 02             	cmp    $0x2,%esi
    2193:	0f 84 9b 0d 00 00    	je     2f34 <mathparse+0xe94>
    2199:	42 8b 3c 39          	mov    (%rcx,%r15,1),%edi
    219d:	31 c0                	xor    %eax,%eax
    219f:	83 fe 01             	cmp    $0x1,%esi
    21a2:	0f 95 c0             	setne  %al
    21a5:	29 c7                	sub    %eax,%edi
    21a7:	e8 f4 fe ff ff       	call   20a0 <mathparse>
    21ac:	44 89 f7             	mov    %r14d,%edi
    21af:	89 2d 00 00 00 00    	mov    %ebp,0x0(%rip)        # 21b5 <mathparse+0x115>
			21b1: R_X86_64_PC32	noeval-0x4
    21b5:	e8 a6 f0 ff ff       	call   1260 <op>
    21ba:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 21c1 <mathparse+0x121>
			21bd: R_X86_64_PC32	.bss+0x54
    21c1:	49 89 c6             	mov    %rax,%r14
    21c4:	90                   	nop
    21c5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    21cc:	00 00 00 00 
    21d0:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 21d7 <mathparse+0x137>
			21d3: R_X86_64_PC32	.bss+0x5c
    21d7:	4c 8d 3c 85 00 00 00 	lea    0x0(,%rax,4),%r15
    21de:	00 
    21df:	39 1c 81             	cmp    %ebx,(%rcx,%rax,4)
    21e2:	0f 8e 68 ff ff ff    	jle    2150 <mathparse+0xb0>
    21e8:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 21ef <mathparse+0x14f>
			21ea: R_X86_64_PC32	queueing_enabled-0x5
    21ef:	0f 85 6d 01 00 00    	jne    2362 <mathparse+0x2c2>
    21f5:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 21fb <mathparse+0x15b>
			21f7: R_X86_64_PC32	queue_front-0x4
    21fb:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 2201 <mathparse+0x161>
			21fd: R_X86_64_PC32	queue_rear-0x4
    2201:	39 c2                	cmp    %eax,%edx
    2203:	0f 84 59 01 00 00    	je     2362 <mathparse+0x2c2>
    2209:	48 8d ac 24 c0 00 00 	lea    0xc0(%rsp),%rbp
    2210:	00 
    2211:	4c 8d 74 24 30       	lea    0x30(%rsp),%r14
    2216:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    221d:	00 00 00 
    2220:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2226 <mathparse+0x186>
			2222: R_X86_64_PC32	queue_front-0x4
    2226:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    222a:	48 89 ef             	mov    %rbp,%rdi
    222d:	83 c0 01             	add    $0x1,%eax
    2230:	99                   	cltd
    2231:	c1 ea 19             	shr    $0x19,%edx
    2234:	01 d0                	add    %edx,%eax
    2236:	83 e0 7f             	and    $0x7f,%eax
    2239:	29 d0                	sub    %edx,%eax
    223b:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 2241 <mathparse+0x1a1>
			223d: R_X86_64_PC32	queue_front-0x4
    2241:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2248 <mathparse+0x1a8>
			2244: R_X86_64_PC32	queue_front-0x4
    2248:	48 c1 e0 07          	shl    $0x7,%rax
    224c:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2253:	00 
			2250: R_X86_64_32S	signal_mask_queue
    2254:	0f 11 04 24          	movups %xmm0,(%rsp)
    2258:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    225f:	00 
			225c: R_X86_64_32S	signal_mask_queue+0x10
    2260:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    2265:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    226c:	00 
			2269: R_X86_64_32S	signal_mask_queue+0x20
    226d:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    2272:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2279:	00 
			2276: R_X86_64_32S	signal_mask_queue+0x30
    227a:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    227f:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2286:	00 
			2283: R_X86_64_32S	signal_mask_queue+0x40
    2287:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    228c:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2293:	00 
			2290: R_X86_64_32S	signal_mask_queue+0x50
    2294:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    2299:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    22a0:	00 
			229d: R_X86_64_32S	signal_mask_queue+0x60
    22a1:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    22a6:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    22ad:	00 
			22aa: R_X86_64_32S	signal_mask_queue+0x70
    22ae:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    22b3:	e8 00 00 00 00       	call   22b8 <mathparse+0x218>
			22b4: R_X86_64_PLT32	signal_setmask-0x4
    22b8:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 22bf <mathparse+0x21f>
			22bb: R_X86_64_PC32	queue_front-0x4
    22bf:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    22c3:	8b 3c 85 00 00 00 00 	mov    0x0(,%rax,4),%edi
			22c6: R_X86_64_32S	signal_queue
    22ca:	e8 00 00 00 00       	call   22cf <mathparse+0x22f>
			22cb: R_X86_64_PLT32	zhandler-0x4
    22cf:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    22d3:	4c 89 f7             	mov    %r14,%rdi
    22d6:	66 0f 6f 84 24 40 01 	movdqa 0x140(%rsp),%xmm0
    22dd:	00 00 
    22df:	0f 11 04 24          	movups %xmm0,(%rsp)
    22e3:	66 0f 6f 84 24 50 01 	movdqa 0x150(%rsp),%xmm0
    22ea:	00 00 
    22ec:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    22f1:	66 0f 6f 84 24 60 01 	movdqa 0x160(%rsp),%xmm0
    22f8:	00 00 
    22fa:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    22ff:	66 0f 6f 84 24 70 01 	movdqa 0x170(%rsp),%xmm0
    2306:	00 00 
    2308:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    230d:	66 0f 6f 84 24 80 01 	movdqa 0x180(%rsp),%xmm0
    2314:	00 00 
    2316:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    231b:	66 0f 6f 84 24 90 01 	movdqa 0x190(%rsp),%xmm0
    2322:	00 00 
    2324:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    2329:	66 0f 6f 84 24 a0 01 	movdqa 0x1a0(%rsp),%xmm0
    2330:	00 00 
    2332:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    2337:	66 0f 6f 84 24 b0 01 	movdqa 0x1b0(%rsp),%xmm0
    233e:	00 00 
    2340:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    2345:	e8 00 00 00 00       	call   234a <mathparse+0x2aa>
			2346: R_X86_64_PLT32	signal_setmask-0x4
    234a:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 2350 <mathparse+0x2b0>
			234c: R_X86_64_PC32	queue_front-0x4
    2350:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    2354:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 235a <mathparse+0x2ba>
			2356: R_X86_64_PC32	queue_rear-0x4
    235a:	39 c2                	cmp    %eax,%edx
    235c:	0f 85 be fe ff ff    	jne    2220 <mathparse+0x180>
    2362:	48 81 c4 48 01 00 00 	add    $0x148,%rsp
    2369:	5b                   	pop    %rbx
    236a:	5d                   	pop    %rbp
    236b:	41 5c                	pop    %r12
    236d:	41 5d                	pop    %r13
    236f:	41 5e                	pop    %r14
    2371:	41 5f                	pop    %r15
    2373:	c3                   	ret
    2374:	0f 1f 40 00          	nopl   0x0(%rax)
    2378:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 237f <mathparse+0x2df>
			237b: R_X86_64_PC32	.bss+0x74
    237f:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 2385 <mathparse+0x2e5>
			2381: R_X86_64_PC32	noeval-0x4
    2385:	4c 8b 35 00 00 00 00 	mov    0x0(%rip),%r14        # 238c <mathparse+0x2ec>
			2388: R_X86_64_PC32	zero_mnumber-0x4
    238c:	4c 8b 3d 00 00 00 00 	mov    0x0(%rip),%r15        # 2393 <mathparse+0x2f3>
			238f: R_X86_64_PC32	zero_mnumber+0x4
    2393:	48 89 04 24          	mov    %rax,(%rsp)
    2397:	85 d2                	test   %edx,%edx
    2399:	0f 84 d1 08 00 00    	je     2c70 <mathparse+0xbd0>
    239f:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 23a5 <mathparse+0x305>
			23a1: R_X86_64_PC32	.data-0x4
    23a5:	83 f8 63             	cmp    $0x63,%eax
    23a8:	0f 84 ef 0b 00 00    	je     2f9d <mathparse+0xefd>
    23ae:	83 c0 01             	add    $0x1,%eax
    23b1:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 23b7 <mathparse+0x317>
			23b3: R_X86_64_PC32	.data-0x4
    23b7:	48 8b 34 24          	mov    (%rsp),%rsi
    23bb:	48 98                	cltq
    23bd:	48 c1 e0 05          	shl    $0x5,%rax
    23c1:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 23c8 <mathparse+0x328>
			23c4: R_X86_64_PC32	.bss+0x4c
    23c8:	4c 89 70 10          	mov    %r14,0x10(%rax)
    23cc:	4c 89 78 18          	mov    %r15,0x18(%rax)
    23d0:	48 89 30             	mov    %rsi,(%rax)
    23d3:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
    23da:	00 
    23db:	48 8b 2d 00 00 00 00 	mov    0x0(%rip),%rbp        # 23e2 <mathparse+0x342>
			23de: R_X86_64_PC32	.bss+0x8c
    23e2:	e8 49 e3 ff ff       	call   730 <zzlex>
    23e7:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 23ed <mathparse+0x34d>
			23e9: R_X86_64_PC32	.data
    23ed:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 23f3 <mathparse+0x353>
			23ef: R_X86_64_PC32	.bss+0x54
    23f3:	41 89 c6             	mov    %eax,%r14d
    23f6:	48 98                	cltq
    23f8:	44 8b 3c 85 00 00 00 	mov    0x0(,%rax,4),%r15d
    23ff:	00 
			23fc: R_X86_64_32S	.rodata+0x900
    2400:	41 f6 c7 fc          	test   $0xfc,%r15b
    2404:	0f 84 b6 03 00 00    	je     27c0 <mathparse+0x720>
    240a:	85 d2                	test   %edx,%edx
    240c:	0f 84 86 00 00 00    	je     2498 <mathparse+0x3f8>
    2412:	41 be 00 00 00 00    	mov    $0x0,%r14d
			2414: R_X86_64_32	.rodata.str1.1+0x73
    2418:	0f b6 45 00          	movzbl 0x0(%rbp),%eax
    241c:	f6 84 00 00 00 00 00 	testb  $0x8,0x0(%rax,%rax,1)
    2423:	08 
			241f: R_X86_64_32S	typtab
    2424:	74 2c                	je     2452 <mathparse+0x3b2>
    2426:	0f 1f 40 00          	nopl   0x0(%rax)
    242a:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    2431:	00 00 00 00 
    2435:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    243c:	00 00 00 00 
    2440:	0f b6 45 01          	movzbl 0x1(%rbp),%eax
    2444:	48 83 c5 01          	add    $0x1,%rbp
    2448:	f6 84 00 00 00 00 00 	testb  $0x8,0x0(%rax,%rax,1)
    244f:	08 
			244b: R_X86_64_32S	typtab
    2450:	75 ee                	jne    2440 <mathparse+0x3a0>
    2452:	48 89 ef             	mov    %rbp,%rdi
    2455:	e8 00 00 00 00       	call   245a <mathparse+0x3ba>
			2456: R_X86_64_PLT32	ztrlen-0x4
    245a:	89 c1                	mov    %eax,%ecx
    245c:	0f b6 45 00          	movzbl 0x0(%rbp),%eax
    2460:	83 f9 0a             	cmp    $0xa,%ecx
    2463:	0f 8e 6f 03 00 00    	jle    27d8 <mathparse+0x738>
    2469:	84 c0                	test   %al,%al
    246b:	0f 84 75 03 00 00    	je     27e6 <mathparse+0x746>
    2471:	b9 0a 00 00 00       	mov    $0xa,%ecx
    2476:	41 b8 00 00 00 00    	mov    $0x0,%r8d
			2478: R_X86_64_32	.rodata.str1.1+0x7b
    247c:	4c 89 f6             	mov    %r14,%rsi
    247f:	31 c0                	xor    %eax,%eax
    2481:	48 89 ea             	mov    %rbp,%rdx
    2484:	bf 00 00 00 00       	mov    $0x0,%edi
			2485: R_X86_64_32	.rodata.str1.8+0x1b0
    2489:	e8 00 00 00 00       	call   248e <mathparse+0x3ee>
			248a: R_X86_64_PLT32	zerr-0x4
    248e:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2495 <mathparse+0x3f5>
			2491: R_X86_64_PC32	.bss+0x54
    2495:	49 89 c6             	mov    %rax,%r14
    2498:	41 c1 ef 08          	shr    $0x8,%r15d
    249c:	41 83 e7 01          	and    $0x1,%r15d
    24a0:	41 83 f7 01          	xor    $0x1,%r15d
    24a4:	44 89 3d 00 00 00 00 	mov    %r15d,0x0(%rip)        # 24ab <mathparse+0x40b>
			24a7: R_X86_64_PC32	.data
    24ab:	e9 20 fd ff ff       	jmp    21d0 <mathparse+0x130>
    24b0:	8b 0d 00 00 00 00    	mov    0x0(%rip),%ecx        # 24b6 <mathparse+0x416>
			24b2: R_X86_64_PC32	noeval-0x4
    24b6:	4c 8b 3d 00 00 00 00 	mov    0x0(%rip),%r15        # 24bd <mathparse+0x41d>
			24b9: R_X86_64_PC32	.bss+0x74
    24bd:	85 c9                	test   %ecx,%ecx
    24bf:	0f 84 eb 05 00 00    	je     2ab0 <mathparse+0xa10>
    24c5:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 24cc <mathparse+0x42c>
			24c8: R_X86_64_PC32	zero_mnumber-0x4
    24cc:	4c 8b 2d 00 00 00 00 	mov    0x0(%rip),%r13        # 24d3 <mathparse+0x433>
			24cf: R_X86_64_PC32	zero_mnumber+0x4
    24d3:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 24d9 <mathparse+0x439>
			24d5: R_X86_64_PC32	zero_mnumber+0x4
    24d9:	48 89 04 24          	mov    %rax,(%rsp)
    24dd:	4c 89 e8             	mov    %r13,%rax
    24e0:	4c 8b 24 24          	mov    (%rsp),%r12
    24e4:	48 b9 00 00 00 00 ff 	movabs $0xffffffff00000000,%rcx
    24eb:	ff ff ff 
    24ee:	48 21 c8             	and    %rcx,%rax
    24f1:	48 09 d0             	or     %rdx,%rax
    24f4:	49 89 c5             	mov    %rax,%r13
    24f7:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 24fd <mathparse+0x45d>
			24f9: R_X86_64_PC32	.data-0x4
    24fd:	83 f8 63             	cmp    $0x63,%eax
    2500:	0f 84 1f 0b 00 00    	je     3025 <mathparse+0xf85>
    2506:	83 c0 01             	add    $0x1,%eax
    2509:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 250f <mathparse+0x46f>
			250b: R_X86_64_PC32	.data-0x4
    250f:	48 98                	cltq
    2511:	48 c1 e0 05          	shl    $0x5,%rax
    2515:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 251c <mathparse+0x47c>
			2518: R_X86_64_PC32	.bss+0x4c
    251c:	4c 89 60 10          	mov    %r12,0x10(%rax)
    2520:	4c 89 68 18          	mov    %r13,0x18(%rax)
    2524:	4c 89 38             	mov    %r15,(%rax)
    2527:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
    252e:	00 
    252f:	e9 a7 fe ff ff       	jmp    23db <mathparse+0x33b>
    2534:	0f 1f 40 00          	nopl   0x0(%rax)
    2538:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 253e <mathparse+0x49e>
			253a: R_X86_64_PC32	.data-0x4
    253e:	8b 2d 00 00 00 00    	mov    0x0(%rip),%ebp        # 2544 <mathparse+0x4a4>
			2540: R_X86_64_PC32	noeval-0x4
    2544:	4c 8b 35 00 00 00 00 	mov    0x0(%rip),%r14        # 254b <mathparse+0x4ab>
			2547: R_X86_64_PC32	.bss+0x74
    254b:	66 0f 6f 05 00 00 00 	movdqa 0x0(%rip),%xmm0        # 2553 <mathparse+0x4b3>
    2552:	00 
			254f: R_X86_64_PC32	zero_mnumber-0x4
    2553:	83 f8 63             	cmp    $0x63,%eax
    2556:	0f 84 58 0a 00 00    	je     2fb4 <mathparse+0xf14>
    255c:	83 c0 01             	add    $0x1,%eax
    255f:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 2565 <mathparse+0x4c5>
			2561: R_X86_64_PC32	.data-0x4
    2565:	48 98                	cltq
    2567:	48 c1 e0 05          	shl    $0x5,%rax
    256b:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 2572 <mathparse+0x4d2>
			256e: R_X86_64_PC32	.bss+0x4c
    2572:	4c 89 30             	mov    %r14,(%rax)
    2575:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
    257c:	00 
    257d:	0f 11 40 10          	movups %xmm0,0x10(%rax)
    2581:	85 ed                	test   %ebp,%ebp
    2583:	0f 85 52 fe ff ff    	jne    23db <mathparse+0x33b>
    2589:	c7 40 18 04 00 00 00 	movl   $0x4,0x18(%rax)
    2590:	e9 46 fe ff ff       	jmp    23db <mathparse+0x33b>
    2595:	0f 1f 00             	nopl   (%rax)
    2598:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 259e <mathparse+0x4fe>
			259a: R_X86_64_PC32	.data-0x4
    259e:	66 0f 6f 05 00 00 00 	movdqa 0x0(%rip),%xmm0        # 25a6 <mathparse+0x506>
    25a5:	00 
			25a2: R_X86_64_PC32	.bss+0x7c
    25a6:	83 f8 63             	cmp    $0x63,%eax
    25a9:	0f 84 56 0a 00 00    	je     3005 <mathparse+0xf65>
    25af:	83 c0 01             	add    $0x1,%eax
    25b2:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 25b8 <mathparse+0x518>
			25b4: R_X86_64_PC32	.data-0x4
    25b8:	48 98                	cltq
    25ba:	48 c1 e0 05          	shl    $0x5,%rax
    25be:	48 03 05 00 00 00 00 	add    0x0(%rip),%rax        # 25c5 <mathparse+0x525>
			25c1: R_X86_64_PC32	.bss+0x4c
    25c5:	0f 11 40 10          	movups %xmm0,0x10(%rax)
    25c9:	66 0f ef c0          	pxor   %xmm0,%xmm0
    25cd:	0f 11 00             	movups %xmm0,(%rax)
    25d0:	e9 06 fe ff ff       	jmp    23db <mathparse+0x33b>
    25d5:	0f 1f 00             	nopl   (%rax)
    25d8:	48 63 2d 00 00 00 00 	movslq 0x0(%rip),%rbp        # 25df <mathparse+0x53f>
			25db: R_X86_64_PC32	.data-0x4
    25df:	48 c1 e5 05          	shl    $0x5,%rbp
    25e3:	48 03 2d 00 00 00 00 	add    0x0(%rip),%rbp        # 25ea <mathparse+0x54a>
			25e6: R_X86_64_PC32	.bss+0x4c
    25ea:	8b 45 18             	mov    0x18(%rbp),%eax
    25ed:	83 f8 04             	cmp    $0x4,%eax
    25f0:	0f 84 de 09 00 00    	je     2fd4 <mathparse+0xf34>
    25f6:	48 8b 55 10          	mov    0x10(%rbp),%rdx
    25fa:	83 f8 02             	cmp    $0x2,%eax
    25fd:	0f 84 45 04 00 00    	je     2a48 <mathparse+0x9a8>
    2603:	48 85 d2             	test   %rdx,%rdx
    2606:	0f 85 51 04 00 00    	jne    2a5d <mathparse+0x9bd>
    260c:	8b 79 70             	mov    0x70(%rcx),%edi
    260f:	83 05 00 00 00 00 01 	addl   $0x1,0x0(%rip)        # 2616 <mathparse+0x576>
			2611: R_X86_64_PC32	noeval-0x5
    2616:	83 ef 01             	sub    $0x1,%edi
    2619:	e8 82 fa ff ff       	call   20a0 <mathparse>
    261e:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 2625 <mathparse+0x585>
			2620: R_X86_64_PC32	noeval-0x5
    2625:	83 3d 00 00 00 00 1c 	cmpl   $0x1c,0x0(%rip)        # 262c <mathparse+0x58c>
			2627: R_X86_64_PC32	.bss+0x53
    262c:	0f 84 62 0f 00 00    	je     3594 <mathparse+0x14f4>
    2632:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2638 <mathparse+0x598>
			2634: R_X86_64_PC32	errflag-0x4
    2638:	85 c0                	test   %eax,%eax
    263a:	0f 84 e3 08 00 00    	je     2f23 <mathparse+0xe83>
    2640:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 2647 <mathparse+0x5a7>
			2642: R_X86_64_PC32	queueing_enabled-0x5
    2647:	0f 85 15 fd ff ff    	jne    2362 <mathparse+0x2c2>
    264d:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2653 <mathparse+0x5b3>
			264f: R_X86_64_PC32	queue_front-0x4
    2653:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 2659 <mathparse+0x5b9>
			2655: R_X86_64_PC32	queue_rear-0x4
    2659:	39 c2                	cmp    %eax,%edx
    265b:	0f 84 01 fd ff ff    	je     2362 <mathparse+0x2c2>
    2661:	48 8d ac 24 c0 00 00 	lea    0xc0(%rsp),%rbp
    2668:	00 
    2669:	4c 8d 74 24 30       	lea    0x30(%rsp),%r14
    266e:	66 90                	xchg   %ax,%ax
    2670:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2676 <mathparse+0x5d6>
			2672: R_X86_64_PC32	queue_front-0x4
    2676:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    267a:	48 89 ef             	mov    %rbp,%rdi
    267d:	83 c0 01             	add    $0x1,%eax
    2680:	99                   	cltd
    2681:	c1 ea 19             	shr    $0x19,%edx
    2684:	01 d0                	add    %edx,%eax
    2686:	83 e0 7f             	and    $0x7f,%eax
    2689:	29 d0                	sub    %edx,%eax
    268b:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 2691 <mathparse+0x5f1>
			268d: R_X86_64_PC32	queue_front-0x4
    2691:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2698 <mathparse+0x5f8>
			2694: R_X86_64_PC32	queue_front-0x4
    2698:	48 c1 e0 07          	shl    $0x7,%rax
    269c:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    26a3:	00 
			26a0: R_X86_64_32S	signal_mask_queue
    26a4:	0f 11 04 24          	movups %xmm0,(%rsp)
    26a8:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    26af:	00 
			26ac: R_X86_64_32S	signal_mask_queue+0x10
    26b0:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    26b5:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    26bc:	00 
			26b9: R_X86_64_32S	signal_mask_queue+0x20
    26bd:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    26c2:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    26c9:	00 
			26c6: R_X86_64_32S	signal_mask_queue+0x30
    26ca:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    26cf:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    26d6:	00 
			26d3: R_X86_64_32S	signal_mask_queue+0x40
    26d7:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    26dc:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    26e3:	00 
			26e0: R_X86_64_32S	signal_mask_queue+0x50
    26e4:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    26e9:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    26f0:	00 
			26ed: R_X86_64_32S	signal_mask_queue+0x60
    26f1:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    26f6:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    26fd:	00 
			26fa: R_X86_64_32S	signal_mask_queue+0x70
    26fe:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    2703:	e8 00 00 00 00       	call   2708 <mathparse+0x668>
			2704: R_X86_64_PLT32	signal_setmask-0x4
    2708:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 270f <mathparse+0x66f>
			270b: R_X86_64_PC32	queue_front-0x4
    270f:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    2713:	8b 3c 85 00 00 00 00 	mov    0x0(,%rax,4),%edi
			2716: R_X86_64_32S	signal_queue
    271a:	e8 00 00 00 00       	call   271f <mathparse+0x67f>
			271b: R_X86_64_PLT32	zhandler-0x4
    271f:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    2723:	4c 89 f7             	mov    %r14,%rdi
    2726:	66 0f 6f 84 24 40 01 	movdqa 0x140(%rsp),%xmm0
    272d:	00 00 
    272f:	0f 11 04 24          	movups %xmm0,(%rsp)
    2733:	66 0f 6f 84 24 50 01 	movdqa 0x150(%rsp),%xmm0
    273a:	00 00 
    273c:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    2741:	66 0f 6f 84 24 60 01 	movdqa 0x160(%rsp),%xmm0
    2748:	00 00 
    274a:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    274f:	66 0f 6f 84 24 70 01 	movdqa 0x170(%rsp),%xmm0
    2756:	00 00 
    2758:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    275d:	66 0f 6f 84 24 80 01 	movdqa 0x180(%rsp),%xmm0
    2764:	00 00 
    2766:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    276b:	66 0f 6f 84 24 90 01 	movdqa 0x190(%rsp),%xmm0
    2772:	00 00 
    2774:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    2779:	66 0f 6f 84 24 a0 01 	movdqa 0x1a0(%rsp),%xmm0
    2780:	00 00 
    2782:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    2787:	66 0f 6f 84 24 b0 01 	movdqa 0x1b0(%rsp),%xmm0
    278e:	00 00 
    2790:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    2795:	e8 00 00 00 00       	call   279a <mathparse+0x6fa>
			2796: R_X86_64_PLT32	signal_setmask-0x4
    279a:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 27a0 <mathparse+0x700>
			279c: R_X86_64_PC32	queue_front-0x4
    27a0:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    27a4:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 27aa <mathparse+0x70a>
			27a6: R_X86_64_PC32	queue_rear-0x4
    27aa:	39 c2                	cmp    %eax,%edx
    27ac:	0f 85 be fe ff ff    	jne    2670 <mathparse+0x5d0>
    27b2:	e9 ab fb ff ff       	jmp    2362 <mathparse+0x2c2>
    27b7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    27be:	00 00 
    27c0:	85 d2                	test   %edx,%edx
    27c2:	0f 85 d0 fc ff ff    	jne    2498 <mathparse+0x3f8>
    27c8:	41 be 00 00 00 00    	mov    $0x0,%r14d
			27ca: R_X86_64_32	.rodata.str1.1+0x6a
    27ce:	e9 45 fc ff ff       	jmp    2418 <mathparse+0x378>
    27d3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    27d8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
			27da: R_X86_64_32	.rodata.str1.1+0x7f
    27de:	84 c0                	test   %al,%al
    27e0:	0f 85 96 fc ff ff    	jne    247c <mathparse+0x3dc>
    27e6:	4c 89 f6             	mov    %r14,%rsi
    27e9:	31 c0                	xor    %eax,%eax
    27eb:	bf 00 00 00 00       	mov    $0x0,%edi
			27ec: R_X86_64_32	.rodata.str1.8+0x178
    27f0:	e8 00 00 00 00       	call   27f5 <mathparse+0x755>
			27f1: R_X86_64_PLT32	zerr-0x4
    27f5:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 27fc <mathparse+0x75c>
			27f8: R_X86_64_PC32	.bss+0x54
    27fc:	49 89 c6             	mov    %rax,%r14
    27ff:	e9 94 fc ff ff       	jmp    2498 <mathparse+0x3f8>
    2804:	0f 1f 40 00          	nopl   0x0(%rax)
    2808:	8b b9 ac 00 00 00    	mov    0xac(%rcx),%edi
    280e:	83 c7 01             	add    $0x1,%edi
    2811:	e8 8a f8 ff ff       	call   20a0 <mathparse>
    2816:	83 3d 00 00 00 00 01 	cmpl   $0x1,0x0(%rip)        # 281d <mathparse+0x77d>
			2818: R_X86_64_PC32	.bss+0x53
    281d:	0f 84 b8 fb ff ff    	je     23db <mathparse+0x33b>
    2823:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2829 <mathparse+0x789>
			2825: R_X86_64_PC32	errflag-0x4
    2829:	85 c0                	test   %eax,%eax
    282b:	0f 84 15 0e 00 00    	je     3646 <mathparse+0x15a6>
    2831:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 2838 <mathparse+0x798>
			2833: R_X86_64_PC32	queueing_enabled-0x5
    2838:	0f 85 24 fb ff ff    	jne    2362 <mathparse+0x2c2>
    283e:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2844 <mathparse+0x7a4>
			2840: R_X86_64_PC32	queue_front-0x4
    2844:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 284a <mathparse+0x7aa>
			2846: R_X86_64_PC32	queue_rear-0x4
    284a:	39 c2                	cmp    %eax,%edx
    284c:	0f 84 10 fb ff ff    	je     2362 <mathparse+0x2c2>
    2852:	48 8d ac 24 c0 00 00 	lea    0xc0(%rsp),%rbp
    2859:	00 
    285a:	4c 8d 74 24 30       	lea    0x30(%rsp),%r14
    285f:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2865 <mathparse+0x7c5>
			2861: R_X86_64_PC32	queue_front-0x4
    2865:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    2869:	48 89 ef             	mov    %rbp,%rdi
    286c:	83 c0 01             	add    $0x1,%eax
    286f:	99                   	cltd
    2870:	c1 ea 19             	shr    $0x19,%edx
    2873:	01 d0                	add    %edx,%eax
    2875:	83 e0 7f             	and    $0x7f,%eax
    2878:	29 d0                	sub    %edx,%eax
    287a:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 2880 <mathparse+0x7e0>
			287c: R_X86_64_PC32	queue_front-0x4
    2880:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2887 <mathparse+0x7e7>
			2883: R_X86_64_PC32	queue_front-0x4
    2887:	48 c1 e0 07          	shl    $0x7,%rax
    288b:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2892:	00 
			288f: R_X86_64_32S	signal_mask_queue
    2893:	0f 11 04 24          	movups %xmm0,(%rsp)
    2897:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    289e:	00 
			289b: R_X86_64_32S	signal_mask_queue+0x10
    289f:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    28a4:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    28ab:	00 
			28a8: R_X86_64_32S	signal_mask_queue+0x20
    28ac:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    28b1:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    28b8:	00 
			28b5: R_X86_64_32S	signal_mask_queue+0x30
    28b9:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    28be:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    28c5:	00 
			28c2: R_X86_64_32S	signal_mask_queue+0x40
    28c6:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    28cb:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    28d2:	00 
			28cf: R_X86_64_32S	signal_mask_queue+0x50
    28d3:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    28d8:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    28df:	00 
			28dc: R_X86_64_32S	signal_mask_queue+0x60
    28e0:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    28e5:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    28ec:	00 
			28e9: R_X86_64_32S	signal_mask_queue+0x70
    28ed:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    28f2:	e8 00 00 00 00       	call   28f7 <mathparse+0x857>
			28f3: R_X86_64_PLT32	signal_setmask-0x4
    28f7:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 28fe <mathparse+0x85e>
			28fa: R_X86_64_PC32	queue_front-0x4
    28fe:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    2902:	8b 3c 85 00 00 00 00 	mov    0x0(,%rax,4),%edi
			2905: R_X86_64_32S	signal_queue
    2909:	e8 00 00 00 00       	call   290e <mathparse+0x86e>
			290a: R_X86_64_PLT32	zhandler-0x4
    290e:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    2912:	4c 89 f7             	mov    %r14,%rdi
    2915:	66 0f 6f 84 24 40 01 	movdqa 0x140(%rsp),%xmm0
    291c:	00 00 
    291e:	0f 11 04 24          	movups %xmm0,(%rsp)
    2922:	66 0f 6f 84 24 50 01 	movdqa 0x150(%rsp),%xmm0
    2929:	00 00 
    292b:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    2930:	66 0f 6f 84 24 60 01 	movdqa 0x160(%rsp),%xmm0
    2937:	00 00 
    2939:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    293e:	66 0f 6f 84 24 70 01 	movdqa 0x170(%rsp),%xmm0
    2945:	00 00 
    2947:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    294c:	66 0f 6f 84 24 80 01 	movdqa 0x180(%rsp),%xmm0
    2953:	00 00 
    2955:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    295a:	66 0f 6f 84 24 90 01 	movdqa 0x190(%rsp),%xmm0
    2961:	00 00 
    2963:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    2968:	66 0f 6f 84 24 a0 01 	movdqa 0x1a0(%rsp),%xmm0
    296f:	00 00 
    2971:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    2976:	66 0f 6f 84 24 b0 01 	movdqa 0x1b0(%rsp),%xmm0
    297d:	00 00 
    297f:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    2984:	e8 00 00 00 00       	call   2989 <mathparse+0x8e9>
			2985: R_X86_64_PLT32	signal_setmask-0x4
    2989:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 298f <mathparse+0x8ef>
			298b: R_X86_64_PC32	queue_front-0x4
    298f:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    2993:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2999 <mathparse+0x8f9>
			2995: R_X86_64_PC32	queue_rear-0x4
    2999:	39 c2                	cmp    %eax,%edx
    299b:	0f 85 be fe ff ff    	jne    285f <mathparse+0x7bf>
    29a1:	e9 bc f9 ff ff       	jmp    2362 <mathparse+0x2c2>
    29a6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    29ad:	00 00 00 
    29b0:	85 d2                	test   %edx,%edx
    29b2:	0f 85 70 f7 ff ff    	jne    2128 <mathparse+0x88>
    29b8:	41 be 00 00 00 00    	mov    $0x0,%r14d
			29ba: R_X86_64_32	.rodata.str1.1+0x6a
    29be:	eb 06                	jmp    29c6 <mathparse+0x926>
    29c0:	41 be 00 00 00 00    	mov    $0x0,%r14d
			29c2: R_X86_64_32	.rodata.str1.1+0x73
    29c6:	0f b6 45 00          	movzbl 0x0(%rbp),%eax
    29ca:	f6 84 00 00 00 00 00 	testb  $0x8,0x0(%rax,%rax,1)
    29d1:	08 
			29cd: R_X86_64_32S	typtab
    29d2:	74 1e                	je     29f2 <mathparse+0x952>
    29d4:	90                   	nop
    29d5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    29dc:	00 00 00 00 
    29e0:	0f b6 45 01          	movzbl 0x1(%rbp),%eax
    29e4:	48 83 c5 01          	add    $0x1,%rbp
    29e8:	f6 84 00 00 00 00 00 	testb  $0x8,0x0(%rax,%rax,1)
    29ef:	08 
			29eb: R_X86_64_32S	typtab
    29f0:	75 ee                	jne    29e0 <mathparse+0x940>
    29f2:	48 89 ef             	mov    %rbp,%rdi
    29f5:	e8 00 00 00 00       	call   29fa <mathparse+0x95a>
			29f6: R_X86_64_PLT32	ztrlen-0x4
    29fa:	89 c1                	mov    %eax,%ecx
    29fc:	0f b6 45 00          	movzbl 0x0(%rbp),%eax
    2a00:	83 f9 0a             	cmp    $0xa,%ecx
    2a03:	0f 8e e7 04 00 00    	jle    2ef0 <mathparse+0xe50>
    2a09:	84 c0                	test   %al,%al
    2a0b:	0f 84 ed 04 00 00    	je     2efe <mathparse+0xe5e>
    2a11:	b9 0a 00 00 00       	mov    $0xa,%ecx
    2a16:	41 b8 00 00 00 00    	mov    $0x0,%r8d
			2a18: R_X86_64_32	.rodata.str1.1+0x7b
    2a1c:	4c 89 f6             	mov    %r14,%rsi
    2a1f:	31 c0                	xor    %eax,%eax
    2a21:	48 89 ea             	mov    %rbp,%rdx
    2a24:	bf 00 00 00 00       	mov    $0x0,%edi
			2a25: R_X86_64_32	.rodata.str1.8+0x1b0
    2a29:	e8 00 00 00 00       	call   2a2e <mathparse+0x98e>
			2a2a: R_X86_64_PLT32	zerr-0x4
    2a2e:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2a35 <mathparse+0x995>
			2a31: R_X86_64_PC32	.bss+0x54
    2a35:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 2a3c <mathparse+0x99c>
			2a38: R_X86_64_PC32	.bss+0x5c
    2a3c:	49 89 c6             	mov    %rax,%r14
    2a3f:	e9 e4 f6 ff ff       	jmp    2128 <mathparse+0x88>
    2a44:	0f 1f 40 00          	nopl   0x0(%rax)
    2a48:	66 0f ef c0          	pxor   %xmm0,%xmm0
    2a4c:	66 48 0f 6e ca       	movq   %rdx,%xmm1
    2a51:	66 0f 2e c8          	ucomisd %xmm0,%xmm1
    2a55:	7a 06                	jp     2a5d <mathparse+0x9bd>
    2a57:	0f 84 af fb ff ff    	je     260c <mathparse+0x56c>
    2a5d:	8b 79 70             	mov    0x70(%rcx),%edi
    2a60:	83 ef 01             	sub    $0x1,%edi
    2a63:	e8 38 f6 ff ff       	call   20a0 <mathparse>
    2a68:	83 3d 00 00 00 00 1c 	cmpl   $0x1c,0x0(%rip)        # 2a6f <mathparse+0x9cf>
			2a6a: R_X86_64_PC32	.bss+0x53
    2a6f:	0f 85 bd fb ff ff    	jne    2632 <mathparse+0x592>
    2a75:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 2a7c <mathparse+0x9dc>
			2a78: R_X86_64_PC32	.bss+0x5c
    2a7c:	83 05 00 00 00 00 01 	addl   $0x1,0x0(%rip)        # 2a83 <mathparse+0x9e3>
			2a7e: R_X86_64_PC32	noeval-0x5
    2a83:	8b 78 6c             	mov    0x6c(%rax),%edi
    2a86:	e8 15 f6 ff ff       	call   20a0 <mathparse>
    2a8b:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 2a92 <mathparse+0x9f2>
			2a8d: R_X86_64_PC32	noeval-0x5
    2a92:	bf 1b 00 00 00       	mov    $0x1b,%edi
    2a97:	e8 c4 e7 ff ff       	call   1260 <op>
    2a9c:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2aa3 <mathparse+0xa03>
			2a9f: R_X86_64_PC32	.bss+0x54
    2aa3:	49 89 c6             	mov    %rax,%r14
    2aa6:	e9 25 f7 ff ff       	jmp    21d0 <mathparse+0x130>
    2aab:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    2ab0:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2ab6 <mathparse+0xa16>
			2ab2: R_X86_64_PC32	queueing_enabled-0x4
    2ab6:	4c 89 ff             	mov    %r15,%rdi
    2ab9:	83 c0 01             	add    $0x1,%eax
    2abc:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 2ac2 <mathparse+0xa22>
			2abe: R_X86_64_PC32	queueing_enabled-0x4
    2ac2:	e8 00 00 00 00       	call   2ac7 <mathparse+0xa27>
			2ac3: R_X86_64_PLT32	getsparam-0x4
    2ac7:	48 89 c5             	mov    %rax,%rbp
    2aca:	48 85 c0             	test   %rax,%rax
    2acd:	0f 84 d5 0a 00 00    	je     35a8 <mathparse+0x1508>
    2ad3:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 2ada <mathparse+0xa3a>
			2ad5: R_X86_64_PC32	opts+0x74
    2ada:	0f 85 98 07 00 00    	jne    3278 <mathparse+0x11d8>
    2ae0:	0f b6 75 00          	movzbl 0x0(%rbp),%esi
    2ae4:	48 89 34 24          	mov    %rsi,(%rsp)
    2ae8:	40 80 fe 83          	cmp    $0x83,%sil
    2aec:	0f 84 1f 09 00 00    	je     3411 <mathparse+0x1371>
    2af2:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 2af9 <mathparse+0xa59>
			2af4: R_X86_64_PC32	queueing_enabled-0x5
    2af9:	0f 85 63 01 00 00    	jne    2c62 <mathparse+0xbc2>
    2aff:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2b05 <mathparse+0xa65>
			2b01: R_X86_64_PC32	queue_front-0x4
    2b05:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 2b0b <mathparse+0xa6b>
			2b07: R_X86_64_PC32	queue_rear-0x4
    2b0b:	39 c2                	cmp    %eax,%edx
    2b0d:	0f 84 4f 01 00 00    	je     2c62 <mathparse+0xbc2>
    2b13:	48 8d ac 24 c0 00 00 	lea    0xc0(%rsp),%rbp
    2b1a:	00 
    2b1b:	4c 8d 74 24 30       	lea    0x30(%rsp),%r14
    2b20:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2b26 <mathparse+0xa86>
			2b22: R_X86_64_PC32	queue_front-0x4
    2b26:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    2b2a:	48 89 ef             	mov    %rbp,%rdi
    2b2d:	83 c0 01             	add    $0x1,%eax
    2b30:	99                   	cltd
    2b31:	c1 ea 19             	shr    $0x19,%edx
    2b34:	01 d0                	add    %edx,%eax
    2b36:	83 e0 7f             	and    $0x7f,%eax
    2b39:	29 d0                	sub    %edx,%eax
    2b3b:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 2b41 <mathparse+0xaa1>
			2b3d: R_X86_64_PC32	queue_front-0x4
    2b41:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2b48 <mathparse+0xaa8>
			2b44: R_X86_64_PC32	queue_front-0x4
    2b48:	48 c1 e0 07          	shl    $0x7,%rax
    2b4c:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2b53:	00 
			2b50: R_X86_64_32S	signal_mask_queue
    2b54:	0f 11 04 24          	movups %xmm0,(%rsp)
    2b58:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2b5f:	00 
			2b5c: R_X86_64_32S	signal_mask_queue+0x10
    2b60:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    2b65:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2b6c:	00 
			2b69: R_X86_64_32S	signal_mask_queue+0x20
    2b6d:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    2b72:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2b79:	00 
			2b76: R_X86_64_32S	signal_mask_queue+0x30
    2b7a:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    2b7f:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2b86:	00 
			2b83: R_X86_64_32S	signal_mask_queue+0x40
    2b87:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    2b8c:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2b93:	00 
			2b90: R_X86_64_32S	signal_mask_queue+0x50
    2b94:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    2b99:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2ba0:	00 
			2b9d: R_X86_64_32S	signal_mask_queue+0x60
    2ba1:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    2ba6:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2bad:	00 
			2baa: R_X86_64_32S	signal_mask_queue+0x70
    2bae:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    2bb3:	e8 00 00 00 00       	call   2bb8 <mathparse+0xb18>
			2bb4: R_X86_64_PLT32	signal_setmask-0x4
    2bb8:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2bbf <mathparse+0xb1f>
			2bbb: R_X86_64_PC32	queue_front-0x4
    2bbf:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    2bc3:	8b 3c 85 00 00 00 00 	mov    0x0(,%rax,4),%edi
			2bc6: R_X86_64_32S	signal_queue
    2bca:	e8 00 00 00 00       	call   2bcf <mathparse+0xb2f>
			2bcb: R_X86_64_PLT32	zhandler-0x4
    2bcf:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    2bd3:	4c 89 f7             	mov    %r14,%rdi
    2bd6:	66 0f 6f 84 24 40 01 	movdqa 0x140(%rsp),%xmm0
    2bdd:	00 00 
    2bdf:	0f 11 04 24          	movups %xmm0,(%rsp)
    2be3:	66 0f 6f 84 24 50 01 	movdqa 0x150(%rsp),%xmm0
    2bea:	00 00 
    2bec:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    2bf1:	66 0f 6f 84 24 60 01 	movdqa 0x160(%rsp),%xmm0
    2bf8:	00 00 
    2bfa:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    2bff:	66 0f 6f 84 24 70 01 	movdqa 0x170(%rsp),%xmm0
    2c06:	00 00 
    2c08:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    2c0d:	66 0f 6f 84 24 80 01 	movdqa 0x180(%rsp),%xmm0
    2c14:	00 00 
    2c16:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    2c1b:	66 0f 6f 84 24 90 01 	movdqa 0x190(%rsp),%xmm0
    2c22:	00 00 
    2c24:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    2c29:	66 0f 6f 84 24 a0 01 	movdqa 0x1a0(%rsp),%xmm0
    2c30:	00 00 
    2c32:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    2c37:	66 0f 6f 84 24 b0 01 	movdqa 0x1b0(%rsp),%xmm0
    2c3e:	00 00 
    2c40:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    2c45:	e8 00 00 00 00       	call   2c4a <mathparse+0xbaa>
			2c46: R_X86_64_PLT32	signal_setmask-0x4
    2c4a:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 2c50 <mathparse+0xbb0>
			2c4c: R_X86_64_PC32	queue_front-0x4
    2c50:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    2c54:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2c5a <mathparse+0xbba>
			2c56: R_X86_64_PC32	queue_rear-0x4
    2c5a:	39 c2                	cmp    %eax,%edx
    2c5c:	0f 85 be fe ff ff    	jne    2b20 <mathparse+0xa80>
    2c62:	ba 01 00 00 00       	mov    $0x1,%edx
    2c67:	e9 71 f8 ff ff       	jmp    24dd <mathparse+0x43d>
    2c6c:	0f 1f 40 00          	nopl   0x0(%rax)
    2c70:	48 89 c7             	mov    %rax,%rdi
    2c73:	e8 00 00 00 00       	call   2c78 <mathparse+0xbd8>
			2c74: R_X86_64_PLT32	dupstring-0x4
    2c78:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    2c7d:	48 89 84 24 b8 00 00 	mov    %rax,0xb8(%rsp)
    2c84:	00 
    2c85:	80 38 28             	cmpb   $0x28,(%rax)
    2c88:	0f 84 84 09 00 00    	je     3612 <mathparse+0x1572>
    2c8e:	48 83 c0 01          	add    $0x1,%rax
    2c92:	0f 1f 00             	nopl   (%rax)
    2c95:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    2c9c:	00 00 00 00 
    2ca0:	48 89 84 24 b8 00 00 	mov    %rax,0xb8(%rsp)
    2ca7:	00 
    2ca8:	48 89 c5             	mov    %rax,%rbp
    2cab:	48 83 c0 01          	add    $0x1,%rax
    2caf:	80 78 ff 28          	cmpb   $0x28,-0x1(%rax)
    2cb3:	75 eb                	jne    2ca0 <mathparse+0xc00>
    2cb5:	4c 8d 75 01          	lea    0x1(%rbp),%r14
    2cb9:	4c 89 b4 24 b8 00 00 	mov    %r14,0xb8(%rsp)
    2cc0:	00 
    2cc1:	4c 89 f7             	mov    %r14,%rdi
    2cc4:	c6 45 00 00          	movb   $0x0,0x0(%rbp)
    2cc8:	e8 00 00 00 00       	call   2ccd <mathparse+0xc2d>
			2cc9: R_X86_64_PLT32	strlen-0x4
    2ccd:	48 8b 7c 24 28       	mov    0x28(%rsp),%rdi
    2cd2:	be 01 00 00 00       	mov    $0x1,%esi
    2cd7:	c6 44 05 00 00       	movb   $0x0,0x0(%rbp,%rax,1)
    2cdc:	e8 00 00 00 00       	call   2ce1 <mathparse+0xc41>
			2cdd: R_X86_64_PLT32	getmathfunc-0x4
    2ce1:	49 89 c7             	mov    %rax,%r15
    2ce4:	48 85 c0             	test   %rax,%rax
    2ce7:	0f 84 6e 08 00 00    	je     355b <mathparse+0x14bb>
    2ced:	8b 40 10             	mov    0x10(%rax),%eax
    2cf0:	83 e0 05             	and    $0x5,%eax
    2cf3:	83 f8 01             	cmp    $0x1,%eax
    2cf6:	0f 84 61 05 00 00    	je     325d <mathparse+0x11bd>
    2cfc:	e8 00 00 00 00       	call   2d01 <mathparse+0xc61>
			2cfd: R_X86_64_PLT32	newlinklist-0x4
    2d01:	49 89 c6             	mov    %rax,%r14
    2d04:	41 8b 47 10          	mov    0x10(%r15),%eax
    2d08:	a8 04                	test   $0x4,%al
    2d0a:	0f 85 d3 08 00 00    	jne    35e3 <mathparse+0x1543>
    2d10:	83 e0 01             	and    $0x1,%eax
    2d13:	89 44 24 1c          	mov    %eax,0x1c(%rsp)
    2d17:	0f 85 98 08 00 00    	jne    35b5 <mathparse+0x1515>
    2d1d:	48 8b ac 24 b8 00 00 	mov    0xb8(%rsp),%rbp
    2d24:	00 
    2d25:	0f b6 4d 00          	movzbl 0x0(%rbp),%ecx
    2d29:	48 8d 55 01          	lea    0x1(%rbp),%rdx
    2d2d:	48 89 c8             	mov    %rcx,%rax
    2d30:	f6 84 09 00 00 00 00 	testb  $0x4,0x0(%rcx,%rcx,1)
    2d37:	04 
			2d33: R_X86_64_32S	typtab
    2d38:	0f 84 cc 04 00 00    	je     320a <mathparse+0x116a>
    2d3e:	66 90                	xchg   %ax,%ax
    2d40:	48 89 94 24 b8 00 00 	mov    %rdx,0xb8(%rsp)
    2d47:	00 
    2d48:	0f b6 0a             	movzbl (%rdx),%ecx
    2d4b:	48 89 d5             	mov    %rdx,%rbp
    2d4e:	48 83 c2 01          	add    $0x1,%rdx
    2d52:	48 89 c8             	mov    %rcx,%rax
    2d55:	f6 84 09 00 00 00 00 	testb  $0x4,0x0(%rcx,%rcx,1)
    2d5c:	04 
			2d58: R_X86_64_32S	typtab
    2d5d:	75 e1                	jne    2d40 <mathparse+0xca0>
    2d5f:	e9 a6 04 00 00       	jmp    320a <mathparse+0x116a>
    2d64:	0f 1f 40 00          	nopl   0x0(%rax)
    2d68:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 2d6f <mathparse+0xccf>
			2d6a: R_X86_64_PC32	queueing_enabled-0x5
    2d6f:	0f 85 ed f5 ff ff    	jne    2362 <mathparse+0x2c2>
    2d75:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 2d7b <mathparse+0xcdb>
			2d77: R_X86_64_PC32	queue_front-0x4
    2d7b:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2d81 <mathparse+0xce1>
			2d7d: R_X86_64_PC32	queue_rear-0x4
    2d81:	39 c2                	cmp    %eax,%edx
    2d83:	0f 84 d9 f5 ff ff    	je     2362 <mathparse+0x2c2>
    2d89:	48 8d ac 24 c0 00 00 	lea    0xc0(%rsp),%rbp
    2d90:	00 
    2d91:	4c 8d 74 24 30       	lea    0x30(%rsp),%r14
    2d96:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    2d9d:	00 00 00 
    2da0:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2da6 <mathparse+0xd06>
			2da2: R_X86_64_PC32	queue_front-0x4
    2da6:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    2daa:	48 89 ef             	mov    %rbp,%rdi
    2dad:	83 c0 01             	add    $0x1,%eax
    2db0:	99                   	cltd
    2db1:	c1 ea 19             	shr    $0x19,%edx
    2db4:	01 d0                	add    %edx,%eax
    2db6:	83 e0 7f             	and    $0x7f,%eax
    2db9:	29 d0                	sub    %edx,%eax
    2dbb:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 2dc1 <mathparse+0xd21>
			2dbd: R_X86_64_PC32	queue_front-0x4
    2dc1:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2dc8 <mathparse+0xd28>
			2dc4: R_X86_64_PC32	queue_front-0x4
    2dc8:	48 c1 e0 07          	shl    $0x7,%rax
    2dcc:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2dd3:	00 
			2dd0: R_X86_64_32S	signal_mask_queue
    2dd4:	0f 11 04 24          	movups %xmm0,(%rsp)
    2dd8:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2ddf:	00 
			2ddc: R_X86_64_32S	signal_mask_queue+0x10
    2de0:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    2de5:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2dec:	00 
			2de9: R_X86_64_32S	signal_mask_queue+0x20
    2ded:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    2df2:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2df9:	00 
			2df6: R_X86_64_32S	signal_mask_queue+0x30
    2dfa:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    2dff:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2e06:	00 
			2e03: R_X86_64_32S	signal_mask_queue+0x40
    2e07:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    2e0c:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2e13:	00 
			2e10: R_X86_64_32S	signal_mask_queue+0x50
    2e14:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    2e19:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2e20:	00 
			2e1d: R_X86_64_32S	signal_mask_queue+0x60
    2e21:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    2e26:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    2e2d:	00 
			2e2a: R_X86_64_32S	signal_mask_queue+0x70
    2e2e:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    2e33:	e8 00 00 00 00       	call   2e38 <mathparse+0xd98>
			2e34: R_X86_64_PLT32	signal_setmask-0x4
    2e38:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2e3f <mathparse+0xd9f>
			2e3b: R_X86_64_PC32	queue_front-0x4
    2e3f:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    2e43:	8b 3c 85 00 00 00 00 	mov    0x0(,%rax,4),%edi
			2e46: R_X86_64_32S	signal_queue
    2e4a:	e8 00 00 00 00       	call   2e4f <mathparse+0xdaf>
			2e4b: R_X86_64_PLT32	zhandler-0x4
    2e4f:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    2e53:	4c 89 f7             	mov    %r14,%rdi
    2e56:	66 0f 6f 84 24 40 01 	movdqa 0x140(%rsp),%xmm0
    2e5d:	00 00 
    2e5f:	0f 11 04 24          	movups %xmm0,(%rsp)
    2e63:	66 0f 6f 84 24 50 01 	movdqa 0x150(%rsp),%xmm0
    2e6a:	00 00 
    2e6c:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    2e71:	66 0f 6f 84 24 60 01 	movdqa 0x160(%rsp),%xmm0
    2e78:	00 00 
    2e7a:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    2e7f:	66 0f 6f 84 24 70 01 	movdqa 0x170(%rsp),%xmm0
    2e86:	00 00 
    2e88:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    2e8d:	66 0f 6f 84 24 80 01 	movdqa 0x180(%rsp),%xmm0
    2e94:	00 00 
    2e96:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    2e9b:	66 0f 6f 84 24 90 01 	movdqa 0x190(%rsp),%xmm0
    2ea2:	00 00 
    2ea4:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    2ea9:	66 0f 6f 84 24 a0 01 	movdqa 0x1a0(%rsp),%xmm0
    2eb0:	00 00 
    2eb2:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    2eb7:	66 0f 6f 84 24 b0 01 	movdqa 0x1b0(%rsp),%xmm0
    2ebe:	00 00 
    2ec0:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    2ec5:	e8 00 00 00 00       	call   2eca <mathparse+0xe2a>
			2ec6: R_X86_64_PLT32	signal_setmask-0x4
    2eca:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 2ed0 <mathparse+0xe30>
			2ecc: R_X86_64_PC32	queue_front-0x4
    2ed0:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    2ed4:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2eda <mathparse+0xe3a>
			2ed6: R_X86_64_PC32	queue_rear-0x4
    2eda:	39 c2                	cmp    %eax,%edx
    2edc:	0f 85 be fe ff ff    	jne    2da0 <mathparse+0xd00>
    2ee2:	e9 7b f4 ff ff       	jmp    2362 <mathparse+0x2c2>
    2ee7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    2eee:	00 00 
    2ef0:	41 b8 00 00 00 00    	mov    $0x0,%r8d
			2ef2: R_X86_64_32	.rodata.str1.1+0x7f
    2ef6:	84 c0                	test   %al,%al
    2ef8:	0f 85 1e fb ff ff    	jne    2a1c <mathparse+0x97c>
    2efe:	4c 89 f6             	mov    %r14,%rsi
    2f01:	31 c0                	xor    %eax,%eax
    2f03:	bf 00 00 00 00       	mov    $0x0,%edi
			2f04: R_X86_64_32	.rodata.str1.8+0x178
    2f08:	e8 00 00 00 00       	call   2f0d <mathparse+0xe6d>
			2f09: R_X86_64_PLT32	zerr-0x4
    2f0d:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 2f14 <mathparse+0xe74>
			2f10: R_X86_64_PC32	.bss+0x54
    2f14:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 2f1b <mathparse+0xe7b>
			2f17: R_X86_64_PC32	.bss+0x5c
    2f1b:	49 89 c6             	mov    %rax,%r14
    2f1e:	e9 05 f2 ff ff       	jmp    2128 <mathparse+0x88>
    2f23:	bf 00 00 00 00       	mov    $0x0,%edi
			2f24: R_X86_64_32	.rodata.str1.8+0x238
    2f28:	31 c0                	xor    %eax,%eax
    2f2a:	e8 00 00 00 00       	call   2f2f <mathparse+0xe8f>
			2f2b: R_X86_64_PLT32	zerr-0x4
    2f2f:	e9 0c f7 ff ff       	jmp    2640 <mathparse+0x5a0>
    2f34:	48 63 3d 00 00 00 00 	movslq 0x0(%rip),%rdi        # 2f3b <mathparse+0xe9b>
			2f37: R_X86_64_PC32	.data-0x4
    2f3b:	48 c1 e7 05          	shl    $0x5,%rdi
    2f3f:	48 03 3d 00 00 00 00 	add    0x0(%rip),%rdi        # 2f46 <mathparse+0xea6>
			2f42: R_X86_64_PC32	.bss+0x4c
    2f46:	8b 57 18             	mov    0x18(%rdi),%edx
    2f49:	83 fa 04             	cmp    $0x4,%edx
    2f4c:	0f 84 d2 04 00 00    	je     3424 <mathparse+0x1384>
    2f52:	83 e2 02             	and    $0x2,%edx
    2f55:	48 8b 47 10          	mov    0x10(%rdi),%rax
    2f59:	74 0a                	je     2f65 <mathparse+0xec5>
    2f5b:	66 48 0f 6e d0       	movq   %rax,%xmm2
    2f60:	f2 48 0f 2c c2       	cvttsd2si %xmm2,%rax
    2f65:	41 83 fe 28          	cmp    $0x28,%r14d
    2f69:	0f 84 e1 04 00 00    	je     3450 <mathparse+0x13b0>
    2f6f:	0f 8f 5f 06 00 00    	jg     35d4 <mathparse+0x1534>
    2f75:	41 83 fe 18          	cmp    $0x18,%r14d
    2f79:	0f 84 d1 04 00 00    	je     3450 <mathparse+0x13b0>
    2f7f:	41 83 fe 19          	cmp    $0x19,%r14d
    2f83:	0f 85 10 f2 ff ff    	jne    2199 <mathparse+0xf9>
    2f89:	85 c0                	test   %eax,%eax
    2f8b:	0f 84 08 f2 ff ff    	je     2199 <mathparse+0xf9>
    2f91:	83 05 00 00 00 00 01 	addl   $0x1,0x0(%rip)        # 2f98 <mathparse+0xef8>
			2f93: R_X86_64_PC32	noeval-0x5
    2f98:	e9 fc f1 ff ff       	jmp    2199 <mathparse+0xf9>
    2f9d:	31 c0                	xor    %eax,%eax
    2f9f:	bf 00 00 00 00       	mov    $0x0,%edi
			2fa0: R_X86_64_32	.rodata.str1.1+0x5b
    2fa4:	e8 00 00 00 00       	call   2fa9 <mathparse+0xf09>
			2fa5: R_X86_64_PLT32	zerr-0x4
    2fa9:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2faf <mathparse+0xf0f>
			2fab: R_X86_64_PC32	.data-0x4
    2faf:	e9 03 f4 ff ff       	jmp    23b7 <mathparse+0x317>
    2fb4:	31 c0                	xor    %eax,%eax
    2fb6:	bf 00 00 00 00       	mov    $0x0,%edi
			2fb7: R_X86_64_32	.rodata.str1.1+0x5b
    2fbb:	0f 29 04 24          	movaps %xmm0,(%rsp)
    2fbf:	e8 00 00 00 00       	call   2fc4 <mathparse+0xf24>
			2fc0: R_X86_64_PLT32	zerr-0x4
    2fc4:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 2fca <mathparse+0xf2a>
			2fc6: R_X86_64_PC32	.data-0x4
    2fca:	66 0f 6f 04 24       	movdqa (%rsp),%xmm0
    2fcf:	e9 91 f5 ff ff       	jmp    2565 <mathparse+0x4c5>
    2fd4:	48 89 ef             	mov    %rbp,%rdi
    2fd7:	e8 84 e1 ff ff       	call   1160 <getmathparam>
    2fdc:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 2fe3 <mathparse+0xf43>
			2fdf: R_X86_64_PC32	.bss+0x5c
    2fe3:	48 89 45 10          	mov    %rax,0x10(%rbp)
    2fe7:	48 89 55 18          	mov    %rdx,0x18(%rbp)
    2feb:	48 63 2d 00 00 00 00 	movslq 0x0(%rip),%rbp        # 2ff2 <mathparse+0xf52>
			2fee: R_X86_64_PC32	.data-0x4
    2ff2:	48 c1 e5 05          	shl    $0x5,%rbp
    2ff6:	48 03 2d 00 00 00 00 	add    0x0(%rip),%rbp        # 2ffd <mathparse+0xf5d>
			2ff9: R_X86_64_PC32	.bss+0x4c
    2ffd:	8b 45 18             	mov    0x18(%rbp),%eax
    3000:	e9 f1 f5 ff ff       	jmp    25f6 <mathparse+0x556>
    3005:	31 c0                	xor    %eax,%eax
    3007:	bf 00 00 00 00       	mov    $0x0,%edi
			3008: R_X86_64_32	.rodata.str1.1+0x5b
    300c:	0f 29 04 24          	movaps %xmm0,(%rsp)
    3010:	e8 00 00 00 00       	call   3015 <mathparse+0xf75>
			3011: R_X86_64_PLT32	zerr-0x4
    3015:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 301b <mathparse+0xf7b>
			3017: R_X86_64_PC32	.data-0x4
    301b:	66 0f 6f 04 24       	movdqa (%rsp),%xmm0
    3020:	e9 93 f5 ff ff       	jmp    25b8 <mathparse+0x518>
    3025:	31 c0                	xor    %eax,%eax
    3027:	bf 00 00 00 00       	mov    $0x0,%edi
			3028: R_X86_64_32	.rodata.str1.1+0x5b
    302c:	e8 00 00 00 00       	call   3031 <mathparse+0xf91>
			302d: R_X86_64_PLT32	zerr-0x4
    3031:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 3037 <mathparse+0xf97>
			3033: R_X86_64_PC32	.data-0x4
    3037:	e9 d3 f4 ff ff       	jmp    250f <mathparse+0x46f>
    303c:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 3043 <mathparse+0xfa3>
			303e: R_X86_64_PC32	queueing_enabled-0x5
    3043:	0f 85 19 f3 ff ff    	jne    2362 <mathparse+0x2c2>
    3049:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 304f <mathparse+0xfaf>
			304b: R_X86_64_PC32	queue_front-0x4
    304f:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 3055 <mathparse+0xfb5>
			3051: R_X86_64_PC32	queue_rear-0x4
    3055:	39 c2                	cmp    %eax,%edx
    3057:	0f 84 05 f3 ff ff    	je     2362 <mathparse+0x2c2>
    305d:	48 8d ac 24 c0 00 00 	lea    0xc0(%rsp),%rbp
    3064:	00 
    3065:	4c 8d 74 24 30       	lea    0x30(%rsp),%r14
    306a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    3070:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 3076 <mathparse+0xfd6>
			3072: R_X86_64_PC32	queue_front-0x4
    3076:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    307a:	48 89 ef             	mov    %rbp,%rdi
    307d:	83 c0 01             	add    $0x1,%eax
    3080:	99                   	cltd
    3081:	c1 ea 19             	shr    $0x19,%edx
    3084:	01 d0                	add    %edx,%eax
    3086:	83 e0 7f             	and    $0x7f,%eax
    3089:	29 d0                	sub    %edx,%eax
    308b:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 3091 <mathparse+0xff1>
			308d: R_X86_64_PC32	queue_front-0x4
    3091:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 3098 <mathparse+0xff8>
			3094: R_X86_64_PC32	queue_front-0x4
    3098:	48 c1 e0 07          	shl    $0x7,%rax
    309c:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    30a3:	00 
			30a0: R_X86_64_32S	signal_mask_queue
    30a4:	0f 11 04 24          	movups %xmm0,(%rsp)
    30a8:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    30af:	00 
			30ac: R_X86_64_32S	signal_mask_queue+0x10
    30b0:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    30b5:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    30bc:	00 
			30b9: R_X86_64_32S	signal_mask_queue+0x20
    30bd:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    30c2:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    30c9:	00 
			30c6: R_X86_64_32S	signal_mask_queue+0x30
    30ca:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    30cf:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    30d6:	00 
			30d3: R_X86_64_32S	signal_mask_queue+0x40
    30d7:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    30dc:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    30e3:	00 
			30e0: R_X86_64_32S	signal_mask_queue+0x50
    30e4:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    30e9:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    30f0:	00 
			30ed: R_X86_64_32S	signal_mask_queue+0x60
    30f1:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    30f6:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    30fd:	00 
			30fa: R_X86_64_32S	signal_mask_queue+0x70
    30fe:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    3103:	e8 00 00 00 00       	call   3108 <mathparse+0x1068>
			3104: R_X86_64_PLT32	signal_setmask-0x4
    3108:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 310f <mathparse+0x106f>
			310b: R_X86_64_PC32	queue_front-0x4
    310f:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    3113:	8b 3c 85 00 00 00 00 	mov    0x0(,%rax,4),%edi
			3116: R_X86_64_32S	signal_queue
    311a:	e8 00 00 00 00       	call   311f <mathparse+0x107f>
			311b: R_X86_64_PLT32	zhandler-0x4
    311f:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    3123:	4c 89 f7             	mov    %r14,%rdi
    3126:	66 0f 6f 84 24 40 01 	movdqa 0x140(%rsp),%xmm0
    312d:	00 00 
    312f:	0f 11 04 24          	movups %xmm0,(%rsp)
    3133:	66 0f 6f 84 24 50 01 	movdqa 0x150(%rsp),%xmm0
    313a:	00 00 
    313c:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    3141:	66 0f 6f 84 24 60 01 	movdqa 0x160(%rsp),%xmm0
    3148:	00 00 
    314a:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    314f:	66 0f 6f 84 24 70 01 	movdqa 0x170(%rsp),%xmm0
    3156:	00 00 
    3158:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    315d:	66 0f 6f 84 24 80 01 	movdqa 0x180(%rsp),%xmm0
    3164:	00 00 
    3166:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    316b:	66 0f 6f 84 24 90 01 	movdqa 0x190(%rsp),%xmm0
    3172:	00 00 
    3174:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    3179:	66 0f 6f 84 24 a0 01 	movdqa 0x1a0(%rsp),%xmm0
    3180:	00 00 
    3182:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    3187:	66 0f 6f 84 24 b0 01 	movdqa 0x1b0(%rsp),%xmm0
    318e:	00 00 
    3190:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    3195:	e8 00 00 00 00       	call   319a <mathparse+0x10fa>
			3196: R_X86_64_PLT32	signal_setmask-0x4
    319a:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 31a0 <mathparse+0x1100>
			319c: R_X86_64_PC32	queue_front-0x4
    31a0:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    31a4:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 31aa <mathparse+0x110a>
			31a6: R_X86_64_PC32	queue_rear-0x4
    31aa:	39 c2                	cmp    %eax,%edx
    31ac:	0f 85 be fe ff ff    	jne    3070 <mathparse+0xfd0>
    31b2:	e9 ab f1 ff ff       	jmp    2362 <mathparse+0x2c2>
    31b7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    31be:	00 00 
    31c0:	48 89 ef             	mov    %rbp,%rdi
    31c3:	e8 00 00 00 00       	call   31c8 <mathparse+0x1128>
			31c4: R_X86_64_PLT32	dupstring-0x4
    31c8:	48 c7 84 24 b8 00 00 	movq   $0x0,0xb8(%rsp)
    31cf:	00 00 00 00 00 
			31d0: R_X86_64_32S	.rodata.str1.1+0x7f
    31d4:	48 89 c2             	mov    %rax,%rdx
    31d7:	49 8b 76 08          	mov    0x8(%r14),%rsi
    31db:	4c 89 f7             	mov    %r14,%rdi
    31de:	e8 00 00 00 00       	call   31e3 <mathparse+0x1143>
			31df: R_X86_64_PLT32	insertlinknode-0x4
    31e3:	48 8b ac 24 b8 00 00 	mov    0xb8(%rsp),%rbp
    31ea:	00 
    31eb:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 31f1 <mathparse+0x1151>
			31ed: R_X86_64_PC32	errflag-0x4
    31f1:	0f b6 45 00          	movzbl 0x0(%rbp),%eax
    31f5:	85 d2                	test   %edx,%edx
    31f7:	0f 85 d3 02 00 00    	jne    34d0 <mathparse+0x1430>
    31fd:	83 3d 00 00 00 00 2b 	cmpl   $0x2b,0x0(%rip)        # 3204 <mathparse+0x1164>
			31ff: R_X86_64_PC32	.bss+0x53
    3204:	0f 85 c6 02 00 00    	jne    34d0 <mathparse+0x1430>
    320a:	84 c0                	test   %al,%al
    320c:	0f 84 db 02 00 00    	je     34ed <mathparse+0x144d>
    3212:	41 8b 47 10          	mov    0x10(%r15),%eax
    3216:	83 44 24 1c 01       	addl   $0x1,0x1c(%rsp)
    321b:	a8 04                	test   $0x4,%al
    321d:	0f 84 3d 02 00 00    	je     3460 <mathparse+0x13c0>
    3223:	a8 01                	test   $0x1,%al
    3225:	75 99                	jne    31c0 <mathparse+0x1120>
    3227:	48 8d 94 24 b8 00 00 	lea    0xb8(%rsp),%rdx
    322e:	00 
    322f:	be 01 00 00 00       	mov    $0x1,%esi
    3234:	48 89 ef             	mov    %rbp,%rdi
    3237:	e8 94 04 00 00       	call   36d0 <mathevall>
    323c:	83 e2 02             	and    $0x2,%edx
    323f:	0f 84 63 02 00 00    	je     34a8 <mathparse+0x1408>
    3245:	31 d2                	xor    %edx,%edx
    3247:	31 f6                	xor    %esi,%esi
    3249:	66 48 0f 6e c0       	movq   %rax,%xmm0
    324e:	31 ff                	xor    %edi,%edi
    3250:	e8 00 00 00 00       	call   3255 <mathparse+0x11b5>
			3251: R_X86_64_PLT32	convfloat-0x4
    3255:	48 89 c2             	mov    %rax,%rdx
    3258:	e9 7a ff ff ff       	jmp    31d7 <mathparse+0x1137>
    325d:	41 8b 57 38          	mov    0x38(%r15),%edx
    3261:	4c 89 f6             	mov    %r14,%rsi
    3264:	48 8b 7c 24 28       	mov    0x28(%rsp),%rdi
    3269:	41 ff 57 20          	call   *0x20(%r15)
    326d:	49 89 c6             	mov    %rax,%r14
    3270:	49 89 d7             	mov    %rdx,%r15
    3273:	e9 27 f1 ff ff       	jmp    239f <mathparse+0x2ff>
    3278:	48 8d b4 24 b8 00 00 	lea    0xb8(%rsp),%rsi
    327f:	00 
    3280:	48 89 c7             	mov    %rax,%rdi
    3283:	e8 00 00 00 00       	call   3288 <mathparse+0x11e8>
			3284: R_X86_64_PLT32	mb_metacharlenconv-0x4
    3288:	8b 84 24 b8 00 00 00 	mov    0xb8(%rsp),%eax
    328f:	83 f8 ff             	cmp    $0xffffffff,%eax
    3292:	0f 84 48 f8 ff ff    	je     2ae0 <mathparse+0xa40>
    3298:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 329f <mathparse+0x11ff>
			329a: R_X86_64_PC32	queueing_enabled-0x5
    329f:	48 89 04 24          	mov    %rax,(%rsp)
    32a3:	0f 85 b9 f9 ff ff    	jne    2c62 <mathparse+0xbc2>
    32a9:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 32af <mathparse+0x120f>
			32ab: R_X86_64_PC32	queue_front-0x4
    32af:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 32b5 <mathparse+0x1215>
			32b1: R_X86_64_PC32	queue_rear-0x4
    32b5:	39 c2                	cmp    %eax,%edx
    32b7:	0f 84 a5 f9 ff ff    	je     2c62 <mathparse+0xbc2>
    32bd:	48 8d ac 24 c0 00 00 	lea    0xc0(%rsp),%rbp
    32c4:	00 
    32c5:	4c 8d 74 24 30       	lea    0x30(%rsp),%r14
    32ca:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 32d0 <mathparse+0x1230>
			32cc: R_X86_64_PC32	queue_front-0x4
    32d0:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    32d4:	48 89 ef             	mov    %rbp,%rdi
    32d7:	83 c0 01             	add    $0x1,%eax
    32da:	99                   	cltd
    32db:	c1 ea 19             	shr    $0x19,%edx
    32de:	01 d0                	add    %edx,%eax
    32e0:	83 e0 7f             	and    $0x7f,%eax
    32e3:	29 d0                	sub    %edx,%eax
    32e5:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 32eb <mathparse+0x124b>
			32e7: R_X86_64_PC32	queue_front-0x4
    32eb:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 32f2 <mathparse+0x1252>
			32ee: R_X86_64_PC32	queue_front-0x4
    32f2:	48 c1 e0 07          	shl    $0x7,%rax
    32f6:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    32fd:	00 
			32fa: R_X86_64_32S	signal_mask_queue
    32fe:	0f 11 04 24          	movups %xmm0,(%rsp)
    3302:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    3309:	00 
			3306: R_X86_64_32S	signal_mask_queue+0x10
    330a:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    330f:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    3316:	00 
			3313: R_X86_64_32S	signal_mask_queue+0x20
    3317:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    331c:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    3323:	00 
			3320: R_X86_64_32S	signal_mask_queue+0x30
    3324:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    3329:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    3330:	00 
			332d: R_X86_64_32S	signal_mask_queue+0x40
    3331:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    3336:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    333d:	00 
			333a: R_X86_64_32S	signal_mask_queue+0x50
    333e:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    3343:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    334a:	00 
			3347: R_X86_64_32S	signal_mask_queue+0x60
    334b:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    3350:	f3 0f 6f 80 00 00 00 	movdqu 0x0(%rax),%xmm0
    3357:	00 
			3354: R_X86_64_32S	signal_mask_queue+0x70
    3358:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    335d:	e8 00 00 00 00       	call   3362 <mathparse+0x12c2>
			335e: R_X86_64_PLT32	signal_setmask-0x4
    3362:	48 63 05 00 00 00 00 	movslq 0x0(%rip),%rax        # 3369 <mathparse+0x12c9>
			3365: R_X86_64_PC32	queue_front-0x4
    3369:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    336d:	8b 3c 85 00 00 00 00 	mov    0x0(,%rax,4),%edi
			3370: R_X86_64_32S	signal_queue
    3374:	e8 00 00 00 00       	call   3379 <mathparse+0x12d9>
			3375: R_X86_64_PLT32	zhandler-0x4
    3379:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    337d:	4c 89 f7             	mov    %r14,%rdi
    3380:	66 0f 6f 84 24 40 01 	movdqa 0x140(%rsp),%xmm0
    3387:	00 00 
    3389:	0f 11 04 24          	movups %xmm0,(%rsp)
    338d:	66 0f 6f 84 24 50 01 	movdqa 0x150(%rsp),%xmm0
    3394:	00 00 
    3396:	0f 11 44 24 10       	movups %xmm0,0x10(%rsp)
    339b:	66 0f 6f 84 24 60 01 	movdqa 0x160(%rsp),%xmm0
    33a2:	00 00 
    33a4:	0f 11 44 24 20       	movups %xmm0,0x20(%rsp)
    33a9:	66 0f 6f 84 24 70 01 	movdqa 0x170(%rsp),%xmm0
    33b0:	00 00 
    33b2:	0f 11 44 24 30       	movups %xmm0,0x30(%rsp)
    33b7:	66 0f 6f 84 24 80 01 	movdqa 0x180(%rsp),%xmm0
    33be:	00 00 
    33c0:	0f 11 44 24 40       	movups %xmm0,0x40(%rsp)
    33c5:	66 0f 6f 84 24 90 01 	movdqa 0x190(%rsp),%xmm0
    33cc:	00 00 
    33ce:	0f 11 44 24 50       	movups %xmm0,0x50(%rsp)
    33d3:	66 0f 6f 84 24 a0 01 	movdqa 0x1a0(%rsp),%xmm0
    33da:	00 00 
    33dc:	0f 11 44 24 60       	movups %xmm0,0x60(%rsp)
    33e1:	66 0f 6f 84 24 b0 01 	movdqa 0x1b0(%rsp),%xmm0
    33e8:	00 00 
    33ea:	0f 11 44 24 70       	movups %xmm0,0x70(%rsp)
    33ef:	e8 00 00 00 00       	call   33f4 <mathparse+0x1354>
			33f0: R_X86_64_PLT32	signal_setmask-0x4
    33f4:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 33fa <mathparse+0x135a>
			33f6: R_X86_64_PC32	queue_front-0x4
    33fa:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    33fe:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 3404 <mathparse+0x1364>
			3400: R_X86_64_PC32	queue_rear-0x4
    3404:	39 c2                	cmp    %eax,%edx
    3406:	0f 85 be fe ff ff    	jne    32ca <mathparse+0x122a>
    340c:	e9 51 f8 ff ff       	jmp    2c62 <mathparse+0xbc2>
    3411:	0f b6 45 01          	movzbl 0x1(%rbp),%eax
    3415:	83 f0 20             	xor    $0x20,%eax
    3418:	0f b6 c0             	movzbl %al,%eax
    341b:	48 89 04 24          	mov    %rax,(%rsp)
    341f:	e9 ce f6 ff ff       	jmp    2af2 <mathparse+0xa52>
    3424:	89 74 24 1c          	mov    %esi,0x1c(%rsp)
    3428:	48 89 3c 24          	mov    %rdi,(%rsp)
    342c:	e8 2f dd ff ff       	call   1160 <getmathparam>
    3431:	48 8b 3c 24          	mov    (%rsp),%rdi
    3435:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 343c <mathparse+0x139c>
			3438: R_X86_64_PC32	.bss+0x5c
    343c:	8b 74 24 1c          	mov    0x1c(%rsp),%esi
    3440:	48 89 57 18          	mov    %rdx,0x18(%rdi)
    3444:	8b 57 18             	mov    0x18(%rdi),%edx
    3447:	48 89 47 10          	mov    %rax,0x10(%rdi)
    344b:	e9 02 fb ff ff       	jmp    2f52 <mathparse+0xeb2>
    3450:	85 c0                	test   %eax,%eax
    3452:	0f 85 41 ed ff ff    	jne    2199 <mathparse+0xf9>
    3458:	e9 34 fb ff ff       	jmp    2f91 <mathparse+0xef1>
    345d:	0f 1f 00             	nopl   (%rax)
    3460:	bf 10 00 00 00       	mov    $0x10,%edi
    3465:	e8 00 00 00 00       	call   346a <mathparse+0x13ca>
			3466: R_X86_64_PLT32	zhalloc-0x4
    346a:	48 89 ef             	mov    %rbp,%rdi
    346d:	be 01 00 00 00       	mov    $0x1,%esi
    3472:	48 8d 94 24 b8 00 00 	lea    0xb8(%rsp),%rdx
    3479:	00 
    347a:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
    347f:	e8 4c 02 00 00       	call   36d0 <mathevall>
    3484:	48 8b 4c 24 20       	mov    0x20(%rsp),%rcx
    3489:	49 8b 76 08          	mov    0x8(%r14),%rsi
    348d:	4c 89 f7             	mov    %r14,%rdi
    3490:	48 89 51 08          	mov    %rdx,0x8(%rcx)
    3494:	48 89 ca             	mov    %rcx,%rdx
    3497:	48 89 01             	mov    %rax,(%rcx)
    349a:	e8 00 00 00 00       	call   349f <mathparse+0x13ff>
			349b: R_X86_64_PLT32	insertlinknode-0x4
    349f:	e9 3f fd ff ff       	jmp    31e3 <mathparse+0x1143>
    34a4:	0f 1f 40 00          	nopl   0x0(%rax)
    34a8:	48 8d ac 24 c0 00 00 	lea    0xc0(%rsp),%rbp
    34af:	00 
    34b0:	ba 0a 00 00 00       	mov    $0xa,%edx
    34b5:	48 89 c6             	mov    %rax,%rsi
    34b8:	48 89 ef             	mov    %rbp,%rdi
    34bb:	e8 00 00 00 00       	call   34c0 <mathparse+0x1420>
			34bc: R_X86_64_PLT32	convbase-0x4
    34c0:	48 89 ef             	mov    %rbp,%rdi
    34c3:	e8 00 00 00 00       	call   34c8 <mathparse+0x1428>
			34c4: R_X86_64_PLT32	dupstring-0x4
    34c8:	48 89 c2             	mov    %rax,%rdx
    34cb:	e9 07 fd ff ff       	jmp    31d7 <mathparse+0x1137>
    34d0:	84 c0                	test   %al,%al
    34d2:	74 19                	je     34ed <mathparse+0x144d>
    34d4:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 34da <mathparse+0x143a>
			34d6: R_X86_64_PC32	errflag-0x4
    34da:	85 d2                	test   %edx,%edx
    34dc:	75 0f                	jne    34ed <mathparse+0x144d>
    34de:	0f be f0             	movsbl %al,%esi
    34e1:	bf 00 00 00 00       	mov    $0x0,%edi
			34e2: R_X86_64_32	.rodata.str1.8+0x1e0
    34e6:	31 c0                	xor    %eax,%eax
    34e8:	e8 00 00 00 00       	call   34ed <mathparse+0x144d>
			34e9: R_X86_64_PLT32	zerr-0x4
    34ed:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 34f3 <mathparse+0x1453>
			34ef: R_X86_64_PC32	errflag-0x4
    34f3:	85 c0                	test   %eax,%eax
    34f5:	75 75                	jne    356c <mathparse+0x14cc>
    34f7:	8b 44 24 1c          	mov    0x1c(%rsp),%eax
    34fb:	41 39 47 30          	cmp    %eax,0x30(%r15)
    34ff:	0f 8f f8 00 00 00    	jg     35fd <mathparse+0x155d>
    3505:	41 39 47 34          	cmp    %eax,0x34(%r15)
    3509:	0f 82 ee 00 00 00    	jb     35fd <mathparse+0x155d>
    350f:	41 f6 47 10 04       	testb  $0x4,0x10(%r15)
    3514:	0f 84 3b 01 00 00    	je     3655 <mathparse+0x15b5>
    351a:	49 8b 6f 28          	mov    0x28(%r15),%rbp
    351e:	48 85 ed             	test   %rbp,%rbp
    3521:	48 0f 44 6c 24 28    	cmove  0x28(%rsp),%rbp
    3527:	48 89 ef             	mov    %rbp,%rdi
    352a:	e8 00 00 00 00       	call   352f <mathparse+0x148f>
			352b: R_X86_64_PLT32	getshfunc-0x4
    352f:	48 85 c0             	test   %rax,%rax
    3532:	0f 84 43 01 00 00    	je     367b <mathparse+0x15db>
    3538:	4c 89 f6             	mov    %r14,%rsi
    353b:	ba 01 00 00 00       	mov    $0x1,%edx
    3540:	48 89 c7             	mov    %rax,%rdi
    3543:	e8 00 00 00 00       	call   3548 <mathparse+0x14a8>
			3544: R_X86_64_PLT32	doshfunc-0x4
    3548:	4c 8b 35 00 00 00 00 	mov    0x0(%rip),%r14        # 354f <mathparse+0x14af>
			354b: R_X86_64_PC32	lastmathval-0x4
    354f:	4c 8b 3d 00 00 00 00 	mov    0x0(%rip),%r15        # 3556 <mathparse+0x14b6>
			3552: R_X86_64_PC32	lastmathval+0x4
    3556:	e9 44 ee ff ff       	jmp    239f <mathparse+0x2ff>
    355b:	48 8b 74 24 28       	mov    0x28(%rsp),%rsi
    3560:	bf 00 00 00 00       	mov    $0x0,%edi
			3561: R_X86_64_32	.rodata.str1.1+0xb3
    3565:	31 c0                	xor    %eax,%eax
    3567:	e8 00 00 00 00       	call   356c <mathparse+0x14cc>
			3568: R_X86_64_PLT32	zerr-0x4
    356c:	c7 05 00 00 00 00 01 	movl   $0x1,0x0(%rip)        # 3576 <mathparse+0x14d6>
    3573:	00 00 00 
			356e: R_X86_64_PC32	.bss+0x40
    3576:	4c 8b 3d 00 00 00 00 	mov    0x0(%rip),%r15        # 357d <mathparse+0x14dd>
			3579: R_X86_64_PC32	.bss+0x44
    357d:	48 c7 05 00 00 00 00 	movq   $0x0,0x0(%rip)        # 3588 <mathparse+0x14e8>
    3584:	00 00 00 00 
			3580: R_X86_64_PC32	.bss+0x38
    3588:	4c 8b 35 00 00 00 00 	mov    0x0(%rip),%r14        # 358f <mathparse+0x14ef>
			358b: R_X86_64_PC32	.bss+0x3c
    358f:	e9 0b ee ff ff       	jmp    239f <mathparse+0x2ff>
    3594:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 359b <mathparse+0x14fb>
			3597: R_X86_64_PC32	.bss+0x5c
    359b:	8b 78 6c             	mov    0x6c(%rax),%edi
    359e:	e8 fd ea ff ff       	call   20a0 <mathparse>
    35a3:	e9 ea f4 ff ff       	jmp    2a92 <mathparse+0x9f2>
    35a8:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
    35af:	00 
    35b0:	e9 3d f5 ff ff       	jmp    2af2 <mathparse+0xa52>
    35b5:	80 7d 01 00          	cmpb   $0x0,0x1(%rbp)
    35b9:	74 61                	je     361c <mathparse+0x157c>
    35bb:	48 8b ac 24 b8 00 00 	mov    0xb8(%rsp),%rbp
    35c2:	00 
    35c3:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%rsp)
    35ca:	00 
    35cb:	0f b6 45 00          	movzbl 0x0(%rbp),%eax
    35cf:	e9 36 fc ff ff       	jmp    320a <mathparse+0x116a>
    35d4:	41 83 fe 29          	cmp    $0x29,%r14d
    35d8:	0f 84 ab f9 ff ff    	je     2f89 <mathparse+0xee9>
    35de:	e9 b6 eb ff ff       	jmp    2199 <mathparse+0xf9>
    35e3:	49 8b 76 08          	mov    0x8(%r14),%rsi
    35e7:	48 8b 54 24 28       	mov    0x28(%rsp),%rdx
    35ec:	4c 89 f7             	mov    %r14,%rdi
    35ef:	e8 00 00 00 00       	call   35f4 <mathparse+0x1554>
			35f0: R_X86_64_PLT32	insertlinknode-0x4
    35f4:	41 8b 47 10          	mov    0x10(%r15),%eax
    35f8:	e9 13 f7 ff ff       	jmp    2d10 <mathparse+0xc70>
    35fd:	48 8b 34 24          	mov    (%rsp),%rsi
    3601:	bf 00 00 00 00       	mov    $0x0,%edi
			3602: R_X86_64_32	.rodata.str1.1+0x95
    3606:	31 c0                	xor    %eax,%eax
    3608:	e8 00 00 00 00       	call   360d <mathparse+0x156d>
			3609: R_X86_64_PLT32	zerr-0x4
    360d:	e9 5a ff ff ff       	jmp    356c <mathparse+0x14cc>
    3612:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
    3617:	e9 99 f6 ff ff       	jmp    2cb5 <mathparse+0xc15>
    361c:	bf 00 00 00 00       	mov    $0x0,%edi
			361d: R_X86_64_32	.rodata.str1.1+0x7f
    3621:	e8 00 00 00 00       	call   3626 <mathparse+0x1586>
			3622: R_X86_64_PLT32	dupstring-0x4
    3626:	49 8b 76 08          	mov    0x8(%r14),%rsi
    362a:	4c 89 f7             	mov    %r14,%rdi
    362d:	48 89 c2             	mov    %rax,%rdx
    3630:	e8 00 00 00 00       	call   3635 <mathparse+0x1595>
			3631: R_X86_64_PLT32	insertlinknode-0x4
    3635:	48 8b ac 24 b8 00 00 	mov    0xb8(%rsp),%rbp
    363c:	00 
    363d:	0f b6 45 00          	movzbl 0x0(%rbp),%eax
    3641:	e9 c4 fb ff ff       	jmp    320a <mathparse+0x116a>
    3646:	bf 00 00 00 00       	mov    $0x0,%edi
			3647: R_X86_64_32	.rodata.str1.8+0x210
    364b:	e8 00 00 00 00       	call   3650 <mathparse+0x15b0>
			364c: R_X86_64_PLT32	zerr-0x4
    3650:	e9 dc f1 ff ff       	jmp    2831 <mathparse+0x791>
    3655:	8b 44 24 1c          	mov    0x1c(%rsp),%eax
    3659:	31 d2                	xor    %edx,%edx
    365b:	85 c0                	test   %eax,%eax
    365d:	75 2e                	jne    368d <mathparse+0x15ed>
    365f:	41 8b 4f 38          	mov    0x38(%r15),%ecx
    3663:	8b 74 24 1c          	mov    0x1c(%rsp),%esi
    3667:	48 8b 7c 24 28       	mov    0x28(%rsp),%rdi
    366c:	41 ff 57 18          	call   *0x18(%r15)
    3670:	49 89 c6             	mov    %rax,%r14
    3673:	49 89 d7             	mov    %rdx,%r15
    3676:	e9 24 ed ff ff       	jmp    239f <mathparse+0x2ff>
    367b:	48 89 ee             	mov    %rbp,%rsi
    367e:	bf 00 00 00 00       	mov    $0x0,%edi
			367f: R_X86_64_32	.rodata.str1.1+0x80
    3683:	e8 00 00 00 00       	call   3688 <mathparse+0x15e8>
			3684: R_X86_64_PLT32	zerr-0x4
    3688:	e9 df fe ff ff       	jmp    356c <mathparse+0x14cc>
    368d:	48 63 7c 24 1c       	movslq 0x1c(%rsp),%rdi
    3692:	48 c1 e7 04          	shl    $0x4,%rdi
    3696:	e8 00 00 00 00       	call   369b <mathparse+0x15fb>
			3697: R_X86_64_PLT32	zhalloc-0x4
    369b:	48 89 c2             	mov    %rax,%rdx
    369e:	49 8b 06             	mov    (%r14),%rax
    36a1:	48 85 c0             	test   %rax,%rax
    36a4:	74 b9                	je     365f <mathparse+0x15bf>
    36a6:	48 89 d1             	mov    %rdx,%rcx
    36a9:	48 8b 70 10          	mov    0x10(%rax),%rsi
    36ad:	48 8b 00             	mov    (%rax),%rax
    36b0:	48 83 c1 10          	add    $0x10,%rcx
    36b4:	f3 0f 6f 06          	movdqu (%rsi),%xmm0
    36b8:	0f 11 41 f0          	movups %xmm0,-0x10(%rcx)
    36bc:	48 85 c0             	test   %rax,%rax
    36bf:	75 e8                	jne    36a9 <mathparse+0x1609>
    36c1:	eb 9c                	jmp    365f <mathparse+0x15bf>
    36c3:	66 90                	xchg   %ax,%ax
    36c5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    36cc:	00 00 00 00 

00000000000036d0 <mathevall>:
    36d0:	41 57                	push   %r15
    36d2:	48 89 f8             	mov    %rdi,%rax
    36d5:	41 56                	push   %r14
    36d7:	41 55                	push   %r13
    36d9:	41 54                	push   %r12
    36db:	55                   	push   %rbp
    36dc:	48 89 d5             	mov    %rdx,%rbp
    36df:	53                   	push   %rbx
    36e0:	48 81 ec c8 0c 00 00 	sub    $0xcc8,%rsp
    36e7:	8b 1d 00 00 00 00    	mov    0x0(%rip),%ebx        # 36ed <mathevall+0x1d>
			36e9: R_X86_64_PC32	.bss+0x6c
    36ed:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
    36f3:	0f 8f 97 02 00 00    	jg     3990 <mathevall+0x2c0>
    36f9:	8d 7b 01             	lea    0x1(%rbx),%edi
    36fc:	89 3d 00 00 00 00    	mov    %edi,0x0(%rip)        # 3702 <mathevall+0x32>
			36fe: R_X86_64_PC32	.bss+0x6c
    3702:	85 db                	test   %ebx,%ebx
    3704:	0f 85 c6 01 00 00    	jne    38d0 <mathevall+0x200>
    370a:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 3711 <mathevall+0x41>
			370c: R_X86_64_PC32	opts+0x28
    3711:	c7 44 24 34 00 00 00 	movl   $0x0,0x34(%rsp)
    3718:	00 
    3719:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%rsp)
    3720:	00 
    3721:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%rsp)
    3728:	00 
    3729:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%rsp)
    3730:	00 
    3731:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
    3738:	00 00 
    373a:	48 c7 44 24 38 00 00 	movq   $0x0,0x38(%rsp)
    3741:	00 00 
    3743:	48 c7 44 24 28 00 00 	movq   $0x0,0x28(%rsp)
    374a:	00 00 
    374c:	48 c7 44 24 20 00 00 	movq   $0x0,0x20(%rsp)
    3753:	00 00 
    3755:	48 c7 44 24 18 00 00 	movq   $0x0,0x18(%rsp)
    375c:	00 00 
    375e:	0f 84 ea 01 00 00    	je     394e <mathevall+0x27e>
    3764:	bf 12 00 00 00       	mov    $0x12,%edi
    3769:	41 ba 00 00 00 00    	mov    $0x0,%r10d
			376b: R_X86_64_32	.rodata+0xac0
    376f:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 3776 <mathevall+0xa6>
			3772: R_X86_64_PC32	.bss+0x8c
    3776:	8d 47 01             	lea    0x1(%rdi),%eax
    3779:	83 ef 01             	sub    $0x1,%edi
    377c:	85 f6                	test   %esi,%esi
    377e:	0f 44 f8             	cmove  %eax,%edi
    3781:	4c 89 15 00 00 00 00 	mov    %r10,0x0(%rip)        # 3788 <mathevall+0xb8>
			3784: R_X86_64_PC32	.bss+0x5c
    3788:	4c 8d 54 24 40       	lea    0x40(%rsp),%r10
    378d:	4c 89 15 00 00 00 00 	mov    %r10,0x0(%rip)        # 3794 <mathevall+0xc4>
			3790: R_X86_64_PC32	.bss+0x4c
    3794:	c7 05 00 00 00 00 ff 	movl   $0xffffffff,0x0(%rip)        # 379e <mathevall+0xce>
    379b:	ff ff ff 
			3796: R_X86_64_PC32	lastbase-0x8
    379e:	c7 05 00 00 00 00 ff 	movl   $0xffffffff,0x0(%rip)        # 37a8 <mathevall+0xd8>
    37a5:	ff ff ff 
			37a0: R_X86_64_PC32	.data-0x8
    37a8:	c7 05 00 00 00 00 01 	movl   $0x1,0x0(%rip)        # 37b2 <mathevall+0xe2>
    37af:	00 00 00 
			37aa: R_X86_64_PC32	.data-0x4
    37b2:	c7 44 24 58 01 00 00 	movl   $0x1,0x58(%rsp)
    37b9:	00 
    37ba:	48 c7 44 24 50 00 00 	movq   $0x0,0x50(%rsp)
    37c1:	00 00 
    37c3:	e8 d8 e8 ff ff       	call   20a0 <mathparse>
    37c8:	83 3d 00 00 00 00 01 	cmpl   $0x1,0x0(%rip)        # 37cf <mathevall+0xff>
			37ca: R_X86_64_PC32	.bss+0x53
    37cf:	0f 84 9b 01 00 00    	je     3970 <mathevall+0x2a0>
    37d5:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 37dc <mathevall+0x10c>
			37d8: R_X86_64_PC32	.bss+0x8c
    37dc:	48 89 45 00          	mov    %rax,0x0(%rbp)
    37e0:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 37e6 <mathevall+0x116>
			37e2: R_X86_64_PC32	errflag-0x4
    37e6:	85 c0                	test   %eax,%eax
    37e8:	0f 85 72 01 00 00    	jne    3960 <mathevall+0x290>
    37ee:	48 8b 3d 00 00 00 00 	mov    0x0(%rip),%rdi        # 37f5 <mathevall+0x125>
			37f1: R_X86_64_PC32	.bss+0x4c
    37f5:	8b 57 18             	mov    0x18(%rdi),%edx
    37f8:	83 fa 04             	cmp    $0x4,%edx
    37fb:	0f 84 af 01 00 00    	je     39b0 <mathevall+0x2e0>
    3801:	4c 8b 6f 18          	mov    0x18(%rdi),%r13
    3805:	48 8b 77 10          	mov    0x10(%rdi),%rsi
    3809:	83 2d 00 00 00 00 01 	subl   $0x1,0x0(%rip)        # 3810 <mathevall+0x140>
			380b: R_X86_64_PC32	.bss+0x6b
    3810:	74 7e                	je     3890 <mathevall+0x1c0>
    3812:	8b 44 24 14          	mov    0x14(%rsp),%eax
    3816:	8b 4c 24 10          	mov    0x10(%rsp),%ecx
    381a:	48 bf 00 00 00 00 ff 	movabs $0xffffffff00000000,%rdi
    3821:	ff ff ff 
    3824:	89 1d 00 00 00 00    	mov    %ebx,0x0(%rip)        # 382a <mathevall+0x15a>
			3826: R_X86_64_PC32	lastbase-0x4
    382a:	4c 8b 74 24 08       	mov    0x8(%rsp),%r14
    382f:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 3835 <mathevall+0x165>
			3831: R_X86_64_PC32	noeval-0x4
    3835:	8b 44 24 30          	mov    0x30(%rsp),%eax
    3839:	4c 89 35 00 00 00 00 	mov    %r14,0x0(%rip)        # 3840 <mathevall+0x170>
			383c: R_X86_64_PC32	.bss+0x7c
    3840:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 3846 <mathevall+0x176>
			3842: R_X86_64_PC32	.data
    3846:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
    384b:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 3852 <mathevall+0x182>
			384e: R_X86_64_PC32	.bss+0x8c
    3852:	4c 89 f8             	mov    %r15,%rax
    3855:	48 21 f8             	and    %rdi,%rax
    3858:	48 09 c8             	or     %rcx,%rax
    385b:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 3862 <mathevall+0x192>
			385e: R_X86_64_PC32	.bss+0x84
    3862:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    3867:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 386e <mathevall+0x19e>
			386a: R_X86_64_PC32	.bss+0x74
    386e:	8b 44 24 34          	mov    0x34(%rsp),%eax
    3872:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 3878 <mathevall+0x1a8>
			3874: R_X86_64_PC32	.data-0x4
    3878:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    387d:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 3884 <mathevall+0x1b4>
			3880: R_X86_64_PC32	.bss+0x4c
    3884:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    3889:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 3890 <mathevall+0x1c0>
			388c: R_X86_64_PC32	.bss+0x5c
    3890:	4c 89 e8             	mov    %r13,%rax
    3893:	48 89 35 00 00 00 00 	mov    %rsi,0x0(%rip)        # 389a <mathevall+0x1ca>
			3896: R_X86_64_PC32	lastmathval-0x4
    389a:	48 b9 00 00 00 00 ff 	movabs $0xffffffff00000000,%rcx
    38a1:	ff ff ff 
    38a4:	48 21 c8             	and    %rcx,%rax
    38a7:	48 09 d0             	or     %rdx,%rax
    38aa:	49 89 c5             	mov    %rax,%r13
    38ad:	48 89 05 00 00 00 00 	mov    %rax,0x0(%rip)        # 38b4 <mathevall+0x1e4>
			38b0: R_X86_64_PC32	lastmathval+0x4
    38b4:	48 89 f0             	mov    %rsi,%rax
    38b7:	4c 89 ea             	mov    %r13,%rdx
    38ba:	48 81 c4 c8 0c 00 00 	add    $0xcc8,%rsp
    38c1:	5b                   	pop    %rbx
    38c2:	5d                   	pop    %rbp
    38c3:	41 5c                	pop    %r12
    38c5:	41 5d                	pop    %r13
    38c7:	41 5e                	pop    %r14
    38c9:	41 5f                	pop    %r15
    38cb:	c3                   	ret
    38cc:	0f 1f 40 00          	nopl   0x0(%rax)
    38d0:	8b 0d 00 00 00 00    	mov    0x0(%rip),%ecx        # 38d6 <mathevall+0x206>
			38d2: R_X86_64_PC32	noeval-0x4
    38d6:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 38dd <mathevall+0x20d>
			38d9: R_X86_64_PC32	.bss+0x7c
    38dd:	80 3d 00 00 00 00 00 	cmpb   $0x0,0x0(%rip)        # 38e4 <mathevall+0x214>
			38df: R_X86_64_PC32	opts+0x28
    38e4:	8b 1d 00 00 00 00    	mov    0x0(%rip),%ebx        # 38ea <mathevall+0x21a>
			38e6: R_X86_64_PC32	lastbase-0x4
    38ea:	89 4c 24 14          	mov    %ecx,0x14(%rsp)
    38ee:	8b 0d 00 00 00 00    	mov    0x0(%rip),%ecx        # 38f4 <mathevall+0x224>
			38f0: R_X86_64_PC32	.data
    38f4:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
    38f9:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 3900 <mathevall+0x230>
			38fc: R_X86_64_PC32	.bss+0x74
    3900:	89 4c 24 30          	mov    %ecx,0x30(%rsp)
    3904:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 390b <mathevall+0x23b>
			3907: R_X86_64_PC32	.bss+0x8c
    390b:	48 89 54 24 28       	mov    %rdx,0x28(%rsp)
    3910:	48 8b 15 00 00 00 00 	mov    0x0(%rip),%rdx        # 3917 <mathevall+0x247>
			3913: R_X86_64_PC32	.bss+0x4c
    3917:	48 89 4c 24 20       	mov    %rcx,0x20(%rsp)
    391c:	8b 0d 00 00 00 00    	mov    0x0(%rip),%ecx        # 3922 <mathevall+0x252>
			391e: R_X86_64_PC32	.bss+0x84
    3922:	48 89 54 24 38       	mov    %rdx,0x38(%rsp)
    3927:	4c 8b 3d 00 00 00 00 	mov    0x0(%rip),%r15        # 392e <mathevall+0x25e>
			392a: R_X86_64_PC32	.bss+0x84
    392e:	89 4c 24 10          	mov    %ecx,0x10(%rsp)
    3932:	8b 0d 00 00 00 00    	mov    0x0(%rip),%ecx        # 3938 <mathevall+0x268>
			3934: R_X86_64_PC32	.data-0x4
    3938:	89 4c 24 34          	mov    %ecx,0x34(%rsp)
    393c:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 3943 <mathevall+0x273>
			393f: R_X86_64_PC32	.bss+0x5c
    3943:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
    3948:	0f 85 16 fe ff ff    	jne    3764 <mathevall+0x94>
    394e:	bf 11 00 00 00       	mov    $0x11,%edi
    3953:	41 ba 00 00 00 00    	mov    $0x0,%r10d
			3955: R_X86_64_32	.rodata+0x9e0
    3959:	e9 11 fe ff ff       	jmp    376f <mathevall+0x9f>
    395e:	66 90                	xchg   %ax,%ax
    3960:	ba 01 00 00 00       	mov    $0x1,%edx
    3965:	31 f6                	xor    %esi,%esi
    3967:	e9 9d fe ff ff       	jmp    3809 <mathevall+0x139>
    396c:	0f 1f 40 00          	nopl   0x0(%rax)
    3970:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 3976 <mathevall+0x2a6>
			3972: R_X86_64_PC32	errflag-0x4
    3976:	85 c0                	test   %eax,%eax
    3978:	0f 85 57 fe ff ff    	jne    37d5 <mathevall+0x105>
    397e:	bf 00 00 00 00       	mov    $0x0,%edi
			397f: R_X86_64_32	.rodata.str1.8+0x288
    3983:	e8 00 00 00 00       	call   3988 <mathevall+0x2b8>
			3984: R_X86_64_PLT32	zerr-0x4
    3988:	e9 48 fe ff ff       	jmp    37d5 <mathevall+0x105>
    398d:	0f 1f 00             	nopl   (%rax)
    3990:	48 89 7d 00          	mov    %rdi,0x0(%rbp)
    3994:	48 89 fe             	mov    %rdi,%rsi
    3997:	31 c0                	xor    %eax,%eax
    3999:	bf 00 00 00 00       	mov    $0x0,%edi
			399a: R_X86_64_32	.rodata.str1.8+0x260
    399e:	e8 00 00 00 00       	call   39a3 <mathevall+0x2d3>
			399f: R_X86_64_PLT32	zerr-0x4
    39a3:	31 c0                	xor    %eax,%eax
    39a5:	ba 01 00 00 00       	mov    $0x1,%edx
    39aa:	e9 0b ff ff ff       	jmp    38ba <mathevall+0x1ea>
    39af:	90                   	nop
    39b0:	e8 ab d7 ff ff       	call   1160 <getmathparam>
    39b5:	49 89 d5             	mov    %rdx,%r13
    39b8:	48 89 c6             	mov    %rax,%rsi
    39bb:	89 d2                	mov    %edx,%edx
    39bd:	e9 47 fe ff ff       	jmp    3809 <mathevall+0x139>
    39c2:	0f 1f 00             	nopl   (%rax)
    39c5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    39cc:	00 00 00 00 

00000000000039d0 <matheval>:
    39d0:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 39d6 <matheval+0x6>
			39d2: R_X86_64_PC32	.bss+0x6c
    39d6:	44 8b 05 00 00 00 00 	mov    0x0(%rip),%r8d        # 39dd <matheval+0xd>
			39d9: R_X86_64_PC32	.bss+0x54
    39dd:	85 c0                	test   %eax,%eax
    39df:	75 14                	jne    39f5 <matheval+0x25>
    39e1:	c7 05 00 00 00 00 00 	movl   $0x0,0x0(%rip)        # 39eb <matheval+0x1b>
    39e8:	00 00 00 
			39e3: R_X86_64_PC32	outputunderscore-0x8
    39eb:	c7 05 00 00 00 00 00 	movl   $0x0,0x0(%rip)        # 39f5 <matheval+0x25>
    39f2:	00 00 00 
			39ed: R_X86_64_PC32	outputradix-0x8
    39f5:	0f b6 07             	movzbl (%rdi),%eax
    39f8:	3c a1                	cmp    $0xa1,%al
    39fa:	75 08                	jne    3a04 <matheval+0x34>
    39fc:	0f b6 47 01          	movzbl 0x1(%rdi),%eax
    3a00:	48 83 c7 01          	add    $0x1,%rdi
    3a04:	84 c0                	test   %al,%al
    3a06:	75 18                	jne    3a20 <matheval+0x50>
    3a08:	31 d2                	xor    %edx,%edx
    3a0a:	b9 01 00 00 00       	mov    $0x1,%ecx
    3a0f:	48 89 d0             	mov    %rdx,%rax
    3a12:	48 89 ca             	mov    %rcx,%rdx
    3a15:	c3                   	ret
    3a16:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    3a1d:	00 00 00 
    3a20:	48 83 ec 28          	sub    $0x28,%rsp
    3a24:	31 f6                	xor    %esi,%esi
    3a26:	48 8d 54 24 18       	lea    0x18(%rsp),%rdx
    3a2b:	44 89 04 24          	mov    %r8d,(%rsp)
    3a2f:	e8 9c fc ff ff       	call   36d0 <mathevall>
    3a34:	44 8b 04 24          	mov    (%rsp),%r8d
    3a38:	48 89 d1             	mov    %rdx,%rcx
    3a3b:	48 89 c2             	mov    %rax,%rdx
    3a3e:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    3a43:	44 89 05 00 00 00 00 	mov    %r8d,0x0(%rip)        # 3a4a <matheval+0x7a>
			3a46: R_X86_64_PC32	.bss+0x54
    3a4a:	0f be 30             	movsbl (%rax),%esi
    3a4d:	40 84 f6             	test   %sil,%sil
    3a50:	75 0e                	jne    3a60 <matheval+0x90>
    3a52:	48 89 d0             	mov    %rdx,%rax
    3a55:	48 83 c4 28          	add    $0x28,%rsp
    3a59:	48 89 ca             	mov    %rcx,%rdx
    3a5c:	c3                   	ret
    3a5d:	0f 1f 00             	nopl   (%rax)
    3a60:	31 c0                	xor    %eax,%eax
    3a62:	bf 00 00 00 00       	mov    $0x0,%edi
			3a63: R_X86_64_32	.rodata.str1.8+0x1e0
    3a67:	48 89 14 24          	mov    %rdx,(%rsp)
    3a6b:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
    3a70:	e8 00 00 00 00       	call   3a75 <matheval+0xa5>
			3a71: R_X86_64_PLT32	zerr-0x4
    3a75:	48 8b 14 24          	mov    (%rsp),%rdx
    3a79:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
    3a7e:	48 83 c4 28          	add    $0x28,%rsp
    3a82:	48 89 d0             	mov    %rdx,%rax
    3a85:	48 89 ca             	mov    %rcx,%rdx
    3a88:	c3                   	ret
    3a89:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000003a90 <mathevali>:
    3a90:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 3a96 <mathevali+0x6>
			3a92: R_X86_64_PC32	.bss+0x6c
    3a96:	8b 0d 00 00 00 00    	mov    0x0(%rip),%ecx        # 3a9c <mathevali+0xc>
			3a98: R_X86_64_PC32	.bss+0x54
    3a9c:	85 c0                	test   %eax,%eax
    3a9e:	75 14                	jne    3ab4 <mathevali+0x24>
    3aa0:	c7 05 00 00 00 00 00 	movl   $0x0,0x0(%rip)        # 3aaa <mathevali+0x1a>
    3aa7:	00 00 00 
			3aa2: R_X86_64_PC32	outputunderscore-0x8
    3aaa:	c7 05 00 00 00 00 00 	movl   $0x0,0x0(%rip)        # 3ab4 <mathevali+0x24>
    3ab1:	00 00 00 
			3aac: R_X86_64_PC32	outputradix-0x8
    3ab4:	0f b6 07             	movzbl (%rdi),%eax
    3ab7:	3c a1                	cmp    $0xa1,%al
    3ab9:	75 08                	jne    3ac3 <mathevali+0x33>
    3abb:	0f b6 47 01          	movzbl 0x1(%rdi),%eax
    3abf:	48 83 c7 01          	add    $0x1,%rdi
    3ac3:	31 d2                	xor    %edx,%edx
    3ac5:	84 c0                	test   %al,%al
    3ac7:	75 07                	jne    3ad0 <mathevali+0x40>
    3ac9:	48 89 d0             	mov    %rdx,%rax
    3acc:	c3                   	ret
    3acd:	0f 1f 00             	nopl   (%rax)
    3ad0:	53                   	push   %rbx
    3ad1:	31 f6                	xor    %esi,%esi
    3ad3:	48 83 ec 20          	sub    $0x20,%rsp
    3ad7:	48 8d 54 24 18       	lea    0x18(%rsp),%rdx
    3adc:	89 0c 24             	mov    %ecx,(%rsp)
    3adf:	e8 ec fb ff ff       	call   36d0 <mathevall>
    3ae4:	8b 0c 24             	mov    (%rsp),%ecx
    3ae7:	48 89 c3             	mov    %rax,%rbx
    3aea:	49 89 d0             	mov    %rdx,%r8
    3aed:	48 89 c2             	mov    %rax,%rdx
    3af0:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    3af5:	89 0d 00 00 00 00    	mov    %ecx,0x0(%rip)        # 3afb <mathevali+0x6b>
			3af7: R_X86_64_PC32	.bss+0x54
    3afb:	0f be 30             	movsbl (%rax),%esi
    3afe:	40 84 f6             	test   %sil,%sil
    3b01:	75 1d                	jne    3b20 <mathevali+0x90>
    3b03:	41 83 e0 02          	and    $0x2,%r8d
    3b07:	74 0a                	je     3b13 <mathevali+0x83>
    3b09:	66 48 0f 6e c3       	movq   %rbx,%xmm0
    3b0e:	f2 48 0f 2c d0       	cvttsd2si %xmm0,%rdx
    3b13:	48 83 c4 20          	add    $0x20,%rsp
    3b17:	48 89 d0             	mov    %rdx,%rax
    3b1a:	5b                   	pop    %rbx
    3b1b:	c3                   	ret
    3b1c:	0f 1f 40 00          	nopl   0x0(%rax)
    3b20:	bf 00 00 00 00       	mov    $0x0,%edi
			3b21: R_X86_64_32	.rodata.str1.8+0x1e0
    3b25:	31 c0                	xor    %eax,%eax
    3b27:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
    3b2c:	48 89 14 24          	mov    %rdx,(%rsp)
    3b30:	e8 00 00 00 00       	call   3b35 <mathevali+0xa5>
			3b31: R_X86_64_PLT32	zerr-0x4
    3b35:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
    3b3a:	48 8b 14 24          	mov    (%rsp),%rdx
    3b3e:	eb c3                	jmp    3b03 <mathevali+0x73>

0000000000003b40 <mathevalarg>:
    3b40:	55                   	push   %rbp
    3b41:	53                   	push   %rbx
    3b42:	48 89 f3             	mov    %rsi,%rbx
    3b45:	48 83 ec 08          	sub    $0x8,%rsp
    3b49:	0f b6 07             	movzbl (%rdi),%eax
    3b4c:	3c a1                	cmp    $0xa1,%al
    3b4e:	75 08                	jne    3b58 <mathevalarg+0x18>
    3b50:	0f b6 47 01          	movzbl 0x1(%rdi),%eax
    3b54:	48 83 c7 01          	add    $0x1,%rdi
    3b58:	84 c0                	test   %al,%al
    3b5a:	74 5c                	je     3bb8 <mathevalarg+0x78>
    3b5c:	48 89 da             	mov    %rbx,%rdx
    3b5f:	be 01 00 00 00       	mov    $0x1,%esi
    3b64:	8b 2d 00 00 00 00    	mov    0x0(%rip),%ebp        # 3b6a <mathevalarg+0x2a>
			3b66: R_X86_64_PC32	.bss+0x54
    3b6a:	e8 61 fb ff ff       	call   36d0 <mathevall>
    3b6f:	83 3d 00 00 00 00 2b 	cmpl   $0x2b,0x0(%rip)        # 3b76 <mathevalarg+0x36>
			3b71: R_X86_64_PC32	.bss+0x53
    3b76:	48 89 c1             	mov    %rax,%rcx
    3b79:	74 25                	je     3ba0 <mathevalarg+0x60>
    3b7b:	83 e2 02             	and    $0x2,%edx
    3b7e:	89 2d 00 00 00 00    	mov    %ebp,0x0(%rip)        # 3b84 <mathevalarg+0x44>
			3b80: R_X86_64_PC32	.bss+0x54
    3b84:	74 0a                	je     3b90 <mathevalarg+0x50>
    3b86:	66 48 0f 6e c1       	movq   %rcx,%xmm0
    3b8b:	f2 48 0f 2c c0       	cvttsd2si %xmm0,%rax
    3b90:	48 83 c4 08          	add    $0x8,%rsp
    3b94:	5b                   	pop    %rbx
    3b95:	5d                   	pop    %rbp
    3b96:	c3                   	ret
    3b97:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    3b9e:	00 00 
    3ba0:	48 83 2b 01          	subq   $0x1,(%rbx)
    3ba4:	83 e2 02             	and    $0x2,%edx
    3ba7:	89 2d 00 00 00 00    	mov    %ebp,0x0(%rip)        # 3bad <mathevalarg+0x6d>
			3ba9: R_X86_64_PC32	.bss+0x54
    3bad:	74 e1                	je     3b90 <mathevalarg+0x50>
    3baf:	eb d5                	jmp    3b86 <mathevalarg+0x46>
    3bb1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    3bb8:	bf 00 00 00 00       	mov    $0x0,%edi
			3bb9: R_X86_64_32	.rodata.str1.8+0x2b0
    3bbd:	e8 00 00 00 00       	call   3bc2 <mathevalarg+0x82>
			3bbe: R_X86_64_PLT32	zerr-0x4
    3bc2:	48 83 c4 08          	add    $0x8,%rsp
    3bc6:	31 c0                	xor    %eax,%eax
    3bc8:	5b                   	pop    %rbx
    3bc9:	5d                   	pop    %rbp
    3bca:	c3                   	ret
