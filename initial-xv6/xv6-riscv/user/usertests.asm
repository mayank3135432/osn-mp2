
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	711d                	addi	sp,sp,-96
       2:	ec86                	sd	ra,88(sp)
       4:	e8a2                	sd	s0,80(sp)
       6:	e4a6                	sd	s1,72(sp)
       8:	e0ca                	sd	s2,64(sp)
       a:	fc4e                	sd	s3,56(sp)
       c:	f852                	sd	s4,48(sp)
       e:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
      10:	00007797          	auipc	a5,0x7
      14:	72878793          	addi	a5,a5,1832 # 7738 <malloc+0x2574>
      18:	638c                	ld	a1,0(a5)
      1a:	6790                	ld	a2,8(a5)
      1c:	6b94                	ld	a3,16(a5)
      1e:	6f98                	ld	a4,24(a5)
      20:	739c                	ld	a5,32(a5)
      22:	fab43423          	sd	a1,-88(s0)
      26:	fac43823          	sd	a2,-80(s0)
      2a:	fad43c23          	sd	a3,-72(s0)
      2e:	fce43023          	sd	a4,-64(s0)
      32:	fcf43423          	sd	a5,-56(s0)
                     0xffffffffffffffff };

  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      36:	fa840493          	addi	s1,s0,-88
      3a:	fd040a13          	addi	s4,s0,-48
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      3e:	20100993          	li	s3,513
      42:	0004b903          	ld	s2,0(s1)
      46:	85ce                	mv	a1,s3
      48:	854a                	mv	a0,s2
      4a:	4e9040ef          	jal	4d32 <open>
    if(fd >= 0){
      4e:	00055d63          	bgez	a0,68 <copyinstr1+0x68>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      52:	04a1                	addi	s1,s1,8
      54:	ff4497e3          	bne	s1,s4,42 <copyinstr1+0x42>
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      exit(1);
    }
  }
}
      58:	60e6                	ld	ra,88(sp)
      5a:	6446                	ld	s0,80(sp)
      5c:	64a6                	ld	s1,72(sp)
      5e:	6906                	ld	s2,64(sp)
      60:	79e2                	ld	s3,56(sp)
      62:	7a42                	ld	s4,48(sp)
      64:	6125                	addi	sp,sp,96
      66:	8082                	ret
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      68:	862a                	mv	a2,a0
      6a:	85ca                	mv	a1,s2
      6c:	00005517          	auipc	a0,0x5
      70:	25450513          	addi	a0,a0,596 # 52c0 <malloc+0xfc>
      74:	098050ef          	jal	510c <printf>
      exit(1);
      78:	4505                	li	a0,1
      7a:	479040ef          	jal	4cf2 <exit>

000000000000007e <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      7e:	0000a797          	auipc	a5,0xa
      82:	4ea78793          	addi	a5,a5,1258 # a568 <uninit>
      86:	0000d697          	auipc	a3,0xd
      8a:	bf268693          	addi	a3,a3,-1038 # cc78 <buf>
    if(uninit[i] != '\0'){
      8e:	0007c703          	lbu	a4,0(a5)
      92:	e709                	bnez	a4,9c <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      94:	0785                	addi	a5,a5,1
      96:	fed79ce3          	bne	a5,a3,8e <bsstest+0x10>
      9a:	8082                	ret
{
      9c:	1141                	addi	sp,sp,-16
      9e:	e406                	sd	ra,8(sp)
      a0:	e022                	sd	s0,0(sp)
      a2:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      a4:	85aa                	mv	a1,a0
      a6:	00005517          	auipc	a0,0x5
      aa:	23a50513          	addi	a0,a0,570 # 52e0 <malloc+0x11c>
      ae:	05e050ef          	jal	510c <printf>
      exit(1);
      b2:	4505                	li	a0,1
      b4:	43f040ef          	jal	4cf2 <exit>

00000000000000b8 <opentest>:
{
      b8:	1101                	addi	sp,sp,-32
      ba:	ec06                	sd	ra,24(sp)
      bc:	e822                	sd	s0,16(sp)
      be:	e426                	sd	s1,8(sp)
      c0:	1000                	addi	s0,sp,32
      c2:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      c4:	4581                	li	a1,0
      c6:	00005517          	auipc	a0,0x5
      ca:	23250513          	addi	a0,a0,562 # 52f8 <malloc+0x134>
      ce:	465040ef          	jal	4d32 <open>
  if(fd < 0){
      d2:	02054263          	bltz	a0,f6 <opentest+0x3e>
  close(fd);
      d6:	445040ef          	jal	4d1a <close>
  fd = open("doesnotexist", 0);
      da:	4581                	li	a1,0
      dc:	00005517          	auipc	a0,0x5
      e0:	23c50513          	addi	a0,a0,572 # 5318 <malloc+0x154>
      e4:	44f040ef          	jal	4d32 <open>
  if(fd >= 0){
      e8:	02055163          	bgez	a0,10a <opentest+0x52>
}
      ec:	60e2                	ld	ra,24(sp)
      ee:	6442                	ld	s0,16(sp)
      f0:	64a2                	ld	s1,8(sp)
      f2:	6105                	addi	sp,sp,32
      f4:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f6:	85a6                	mv	a1,s1
      f8:	00005517          	auipc	a0,0x5
      fc:	20850513          	addi	a0,a0,520 # 5300 <malloc+0x13c>
     100:	00c050ef          	jal	510c <printf>
    exit(1);
     104:	4505                	li	a0,1
     106:	3ed040ef          	jal	4cf2 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     10a:	85a6                	mv	a1,s1
     10c:	00005517          	auipc	a0,0x5
     110:	21c50513          	addi	a0,a0,540 # 5328 <malloc+0x164>
     114:	7f9040ef          	jal	510c <printf>
    exit(1);
     118:	4505                	li	a0,1
     11a:	3d9040ef          	jal	4cf2 <exit>

000000000000011e <truncate2>:
{
     11e:	7179                	addi	sp,sp,-48
     120:	f406                	sd	ra,40(sp)
     122:	f022                	sd	s0,32(sp)
     124:	ec26                	sd	s1,24(sp)
     126:	e84a                	sd	s2,16(sp)
     128:	e44e                	sd	s3,8(sp)
     12a:	1800                	addi	s0,sp,48
     12c:	89aa                	mv	s3,a0
  unlink("truncfile");
     12e:	00005517          	auipc	a0,0x5
     132:	22250513          	addi	a0,a0,546 # 5350 <malloc+0x18c>
     136:	40d040ef          	jal	4d42 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13a:	60100593          	li	a1,1537
     13e:	00005517          	auipc	a0,0x5
     142:	21250513          	addi	a0,a0,530 # 5350 <malloc+0x18c>
     146:	3ed040ef          	jal	4d32 <open>
     14a:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     14c:	4611                	li	a2,4
     14e:	00005597          	auipc	a1,0x5
     152:	21258593          	addi	a1,a1,530 # 5360 <malloc+0x19c>
     156:	3bd040ef          	jal	4d12 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     15a:	40100593          	li	a1,1025
     15e:	00005517          	auipc	a0,0x5
     162:	1f250513          	addi	a0,a0,498 # 5350 <malloc+0x18c>
     166:	3cd040ef          	jal	4d32 <open>
     16a:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     16c:	4605                	li	a2,1
     16e:	00005597          	auipc	a1,0x5
     172:	1fa58593          	addi	a1,a1,506 # 5368 <malloc+0x1a4>
     176:	8526                	mv	a0,s1
     178:	39b040ef          	jal	4d12 <write>
  if(n != -1){
     17c:	57fd                	li	a5,-1
     17e:	02f51563          	bne	a0,a5,1a8 <truncate2+0x8a>
  unlink("truncfile");
     182:	00005517          	auipc	a0,0x5
     186:	1ce50513          	addi	a0,a0,462 # 5350 <malloc+0x18c>
     18a:	3b9040ef          	jal	4d42 <unlink>
  close(fd1);
     18e:	8526                	mv	a0,s1
     190:	38b040ef          	jal	4d1a <close>
  close(fd2);
     194:	854a                	mv	a0,s2
     196:	385040ef          	jal	4d1a <close>
}
     19a:	70a2                	ld	ra,40(sp)
     19c:	7402                	ld	s0,32(sp)
     19e:	64e2                	ld	s1,24(sp)
     1a0:	6942                	ld	s2,16(sp)
     1a2:	69a2                	ld	s3,8(sp)
     1a4:	6145                	addi	sp,sp,48
     1a6:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1a8:	862a                	mv	a2,a0
     1aa:	85ce                	mv	a1,s3
     1ac:	00005517          	auipc	a0,0x5
     1b0:	1c450513          	addi	a0,a0,452 # 5370 <malloc+0x1ac>
     1b4:	759040ef          	jal	510c <printf>
    exit(1);
     1b8:	4505                	li	a0,1
     1ba:	339040ef          	jal	4cf2 <exit>

00000000000001be <createtest>:
{
     1be:	7139                	addi	sp,sp,-64
     1c0:	fc06                	sd	ra,56(sp)
     1c2:	f822                	sd	s0,48(sp)
     1c4:	f426                	sd	s1,40(sp)
     1c6:	f04a                	sd	s2,32(sp)
     1c8:	ec4e                	sd	s3,24(sp)
     1ca:	e852                	sd	s4,16(sp)
     1cc:	0080                	addi	s0,sp,64
  name[0] = 'a';
     1ce:	06100793          	li	a5,97
     1d2:	fcf40423          	sb	a5,-56(s0)
  name[2] = '\0';
     1d6:	fc040523          	sb	zero,-54(s0)
     1da:	03000493          	li	s1,48
    fd = open(name, O_CREATE|O_RDWR);
     1de:	fc840a13          	addi	s4,s0,-56
     1e2:	20200993          	li	s3,514
  for(i = 0; i < N; i++){
     1e6:	06400913          	li	s2,100
    name[1] = '0' + i;
     1ea:	fc9404a3          	sb	s1,-55(s0)
    fd = open(name, O_CREATE|O_RDWR);
     1ee:	85ce                	mv	a1,s3
     1f0:	8552                	mv	a0,s4
     1f2:	341040ef          	jal	4d32 <open>
    close(fd);
     1f6:	325040ef          	jal	4d1a <close>
  for(i = 0; i < N; i++){
     1fa:	2485                	addiw	s1,s1,1
     1fc:	0ff4f493          	zext.b	s1,s1
     200:	ff2495e3          	bne	s1,s2,1ea <createtest+0x2c>
  name[0] = 'a';
     204:	06100793          	li	a5,97
     208:	fcf40423          	sb	a5,-56(s0)
  name[2] = '\0';
     20c:	fc040523          	sb	zero,-54(s0)
     210:	03000493          	li	s1,48
    unlink(name);
     214:	fc840993          	addi	s3,s0,-56
  for(i = 0; i < N; i++){
     218:	06400913          	li	s2,100
    name[1] = '0' + i;
     21c:	fc9404a3          	sb	s1,-55(s0)
    unlink(name);
     220:	854e                	mv	a0,s3
     222:	321040ef          	jal	4d42 <unlink>
  for(i = 0; i < N; i++){
     226:	2485                	addiw	s1,s1,1
     228:	0ff4f493          	zext.b	s1,s1
     22c:	ff2498e3          	bne	s1,s2,21c <createtest+0x5e>
}
     230:	70e2                	ld	ra,56(sp)
     232:	7442                	ld	s0,48(sp)
     234:	74a2                	ld	s1,40(sp)
     236:	7902                	ld	s2,32(sp)
     238:	69e2                	ld	s3,24(sp)
     23a:	6a42                	ld	s4,16(sp)
     23c:	6121                	addi	sp,sp,64
     23e:	8082                	ret

0000000000000240 <bigwrite>:
{
     240:	715d                	addi	sp,sp,-80
     242:	e486                	sd	ra,72(sp)
     244:	e0a2                	sd	s0,64(sp)
     246:	fc26                	sd	s1,56(sp)
     248:	f84a                	sd	s2,48(sp)
     24a:	f44e                	sd	s3,40(sp)
     24c:	f052                	sd	s4,32(sp)
     24e:	ec56                	sd	s5,24(sp)
     250:	e85a                	sd	s6,16(sp)
     252:	e45e                	sd	s7,8(sp)
     254:	e062                	sd	s8,0(sp)
     256:	0880                	addi	s0,sp,80
     258:	8c2a                	mv	s8,a0
  unlink("bigwrite");
     25a:	00005517          	auipc	a0,0x5
     25e:	13e50513          	addi	a0,a0,318 # 5398 <malloc+0x1d4>
     262:	2e1040ef          	jal	4d42 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     266:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     26a:	20200b93          	li	s7,514
     26e:	00005a97          	auipc	s5,0x5
     272:	12aa8a93          	addi	s5,s5,298 # 5398 <malloc+0x1d4>
      int cc = write(fd, buf, sz);
     276:	0000da17          	auipc	s4,0xd
     27a:	a02a0a13          	addi	s4,s4,-1534 # cc78 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     27e:	6b0d                	lui	s6,0x3
     280:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x3ff>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     284:	85de                	mv	a1,s7
     286:	8556                	mv	a0,s5
     288:	2ab040ef          	jal	4d32 <open>
     28c:	892a                	mv	s2,a0
    if(fd < 0){
     28e:	04054663          	bltz	a0,2da <bigwrite+0x9a>
      int cc = write(fd, buf, sz);
     292:	8626                	mv	a2,s1
     294:	85d2                	mv	a1,s4
     296:	27d040ef          	jal	4d12 <write>
     29a:	89aa                	mv	s3,a0
      if(cc != sz){
     29c:	04a49963          	bne	s1,a0,2ee <bigwrite+0xae>
      int cc = write(fd, buf, sz);
     2a0:	8626                	mv	a2,s1
     2a2:	85d2                	mv	a1,s4
     2a4:	854a                	mv	a0,s2
     2a6:	26d040ef          	jal	4d12 <write>
      if(cc != sz){
     2aa:	04951363          	bne	a0,s1,2f0 <bigwrite+0xb0>
    close(fd);
     2ae:	854a                	mv	a0,s2
     2b0:	26b040ef          	jal	4d1a <close>
    unlink("bigwrite");
     2b4:	8556                	mv	a0,s5
     2b6:	28d040ef          	jal	4d42 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2ba:	1d74849b          	addiw	s1,s1,471
     2be:	fd6493e3          	bne	s1,s6,284 <bigwrite+0x44>
}
     2c2:	60a6                	ld	ra,72(sp)
     2c4:	6406                	ld	s0,64(sp)
     2c6:	74e2                	ld	s1,56(sp)
     2c8:	7942                	ld	s2,48(sp)
     2ca:	79a2                	ld	s3,40(sp)
     2cc:	7a02                	ld	s4,32(sp)
     2ce:	6ae2                	ld	s5,24(sp)
     2d0:	6b42                	ld	s6,16(sp)
     2d2:	6ba2                	ld	s7,8(sp)
     2d4:	6c02                	ld	s8,0(sp)
     2d6:	6161                	addi	sp,sp,80
     2d8:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     2da:	85e2                	mv	a1,s8
     2dc:	00005517          	auipc	a0,0x5
     2e0:	0cc50513          	addi	a0,a0,204 # 53a8 <malloc+0x1e4>
     2e4:	629040ef          	jal	510c <printf>
      exit(1);
     2e8:	4505                	li	a0,1
     2ea:	209040ef          	jal	4cf2 <exit>
      if(cc != sz){
     2ee:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     2f0:	86aa                	mv	a3,a0
     2f2:	864e                	mv	a2,s3
     2f4:	85e2                	mv	a1,s8
     2f6:	00005517          	auipc	a0,0x5
     2fa:	0d250513          	addi	a0,a0,210 # 53c8 <malloc+0x204>
     2fe:	60f040ef          	jal	510c <printf>
        exit(1);
     302:	4505                	li	a0,1
     304:	1ef040ef          	jal	4cf2 <exit>

0000000000000308 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     308:	7139                	addi	sp,sp,-64
     30a:	fc06                	sd	ra,56(sp)
     30c:	f822                	sd	s0,48(sp)
     30e:	f426                	sd	s1,40(sp)
     310:	f04a                	sd	s2,32(sp)
     312:	ec4e                	sd	s3,24(sp)
     314:	e852                	sd	s4,16(sp)
     316:	e456                	sd	s5,8(sp)
     318:	e05a                	sd	s6,0(sp)
     31a:	0080                	addi	s0,sp,64
  int assumed_free = 600;
  
  unlink("junk");
     31c:	00005517          	auipc	a0,0x5
     320:	0c450513          	addi	a0,a0,196 # 53e0 <malloc+0x21c>
     324:	21f040ef          	jal	4d42 <unlink>
     328:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     32c:	20100a93          	li	s5,513
     330:	00005997          	auipc	s3,0x5
     334:	0b098993          	addi	s3,s3,176 # 53e0 <malloc+0x21c>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     338:	4b05                	li	s6,1
     33a:	5a7d                	li	s4,-1
     33c:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     340:	85d6                	mv	a1,s5
     342:	854e                	mv	a0,s3
     344:	1ef040ef          	jal	4d32 <open>
     348:	84aa                	mv	s1,a0
    if(fd < 0){
     34a:	04054d63          	bltz	a0,3a4 <badwrite+0x9c>
    write(fd, (char*)0xffffffffffL, 1);
     34e:	865a                	mv	a2,s6
     350:	85d2                	mv	a1,s4
     352:	1c1040ef          	jal	4d12 <write>
    close(fd);
     356:	8526                	mv	a0,s1
     358:	1c3040ef          	jal	4d1a <close>
    unlink("junk");
     35c:	854e                	mv	a0,s3
     35e:	1e5040ef          	jal	4d42 <unlink>
  for(int i = 0; i < assumed_free; i++){
     362:	397d                	addiw	s2,s2,-1
     364:	fc091ee3          	bnez	s2,340 <badwrite+0x38>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     368:	20100593          	li	a1,513
     36c:	00005517          	auipc	a0,0x5
     370:	07450513          	addi	a0,a0,116 # 53e0 <malloc+0x21c>
     374:	1bf040ef          	jal	4d32 <open>
     378:	84aa                	mv	s1,a0
  if(fd < 0){
     37a:	02054e63          	bltz	a0,3b6 <badwrite+0xae>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     37e:	4605                	li	a2,1
     380:	00005597          	auipc	a1,0x5
     384:	fe858593          	addi	a1,a1,-24 # 5368 <malloc+0x1a4>
     388:	18b040ef          	jal	4d12 <write>
     38c:	4785                	li	a5,1
     38e:	02f50d63          	beq	a0,a5,3c8 <badwrite+0xc0>
    printf("write failed\n");
     392:	00005517          	auipc	a0,0x5
     396:	06e50513          	addi	a0,a0,110 # 5400 <malloc+0x23c>
     39a:	573040ef          	jal	510c <printf>
    exit(1);
     39e:	4505                	li	a0,1
     3a0:	153040ef          	jal	4cf2 <exit>
      printf("open junk failed\n");
     3a4:	00005517          	auipc	a0,0x5
     3a8:	04450513          	addi	a0,a0,68 # 53e8 <malloc+0x224>
     3ac:	561040ef          	jal	510c <printf>
      exit(1);
     3b0:	4505                	li	a0,1
     3b2:	141040ef          	jal	4cf2 <exit>
    printf("open junk failed\n");
     3b6:	00005517          	auipc	a0,0x5
     3ba:	03250513          	addi	a0,a0,50 # 53e8 <malloc+0x224>
     3be:	54f040ef          	jal	510c <printf>
    exit(1);
     3c2:	4505                	li	a0,1
     3c4:	12f040ef          	jal	4cf2 <exit>
  }
  close(fd);
     3c8:	8526                	mv	a0,s1
     3ca:	151040ef          	jal	4d1a <close>
  unlink("junk");
     3ce:	00005517          	auipc	a0,0x5
     3d2:	01250513          	addi	a0,a0,18 # 53e0 <malloc+0x21c>
     3d6:	16d040ef          	jal	4d42 <unlink>

  exit(0);
     3da:	4501                	li	a0,0
     3dc:	117040ef          	jal	4cf2 <exit>

00000000000003e0 <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     3e0:	711d                	addi	sp,sp,-96
     3e2:	ec86                	sd	ra,88(sp)
     3e4:	e8a2                	sd	s0,80(sp)
     3e6:	e4a6                	sd	s1,72(sp)
     3e8:	e0ca                	sd	s2,64(sp)
     3ea:	fc4e                	sd	s3,56(sp)
     3ec:	f852                	sd	s4,48(sp)
     3ee:	f456                	sd	s5,40(sp)
     3f0:	1080                	addi	s0,sp,96
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     3f2:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     3f4:	07a00993          	li	s3,122
    name[1] = 'z';
    name[2] = '0' + (i / 32);
    name[3] = '0' + (i % 32);
    name[4] = '\0';
    unlink(name);
     3f8:	fa040913          	addi	s2,s0,-96
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     3fc:	60200a13          	li	s4,1538
  for(int i = 0; i < nzz; i++){
     400:	40000a93          	li	s5,1024
    name[0] = 'z';
     404:	fb340023          	sb	s3,-96(s0)
    name[1] = 'z';
     408:	fb3400a3          	sb	s3,-95(s0)
    name[2] = '0' + (i / 32);
     40c:	41f4d71b          	sraiw	a4,s1,0x1f
     410:	01b7571b          	srliw	a4,a4,0x1b
     414:	009707bb          	addw	a5,a4,s1
     418:	4057d69b          	sraiw	a3,a5,0x5
     41c:	0306869b          	addiw	a3,a3,48
     420:	fad40123          	sb	a3,-94(s0)
    name[3] = '0' + (i % 32);
     424:	8bfd                	andi	a5,a5,31
     426:	9f99                	subw	a5,a5,a4
     428:	0307879b          	addiw	a5,a5,48
     42c:	faf401a3          	sb	a5,-93(s0)
    name[4] = '\0';
     430:	fa040223          	sb	zero,-92(s0)
    unlink(name);
     434:	854a                	mv	a0,s2
     436:	10d040ef          	jal	4d42 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     43a:	85d2                	mv	a1,s4
     43c:	854a                	mv	a0,s2
     43e:	0f5040ef          	jal	4d32 <open>
    if(fd < 0){
     442:	00054763          	bltz	a0,450 <outofinodes+0x70>
      // failure is eventually expected.
      break;
    }
    close(fd);
     446:	0d5040ef          	jal	4d1a <close>
  for(int i = 0; i < nzz; i++){
     44a:	2485                	addiw	s1,s1,1
     44c:	fb549ce3          	bne	s1,s5,404 <outofinodes+0x24>
     450:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     452:	07a00913          	li	s2,122
    name[1] = 'z';
    name[2] = '0' + (i / 32);
    name[3] = '0' + (i % 32);
    name[4] = '\0';
    unlink(name);
     456:	fa040a13          	addi	s4,s0,-96
  for(int i = 0; i < nzz; i++){
     45a:	40000993          	li	s3,1024
    name[0] = 'z';
     45e:	fb240023          	sb	s2,-96(s0)
    name[1] = 'z';
     462:	fb2400a3          	sb	s2,-95(s0)
    name[2] = '0' + (i / 32);
     466:	41f4d71b          	sraiw	a4,s1,0x1f
     46a:	01b7571b          	srliw	a4,a4,0x1b
     46e:	009707bb          	addw	a5,a4,s1
     472:	4057d69b          	sraiw	a3,a5,0x5
     476:	0306869b          	addiw	a3,a3,48
     47a:	fad40123          	sb	a3,-94(s0)
    name[3] = '0' + (i % 32);
     47e:	8bfd                	andi	a5,a5,31
     480:	9f99                	subw	a5,a5,a4
     482:	0307879b          	addiw	a5,a5,48
     486:	faf401a3          	sb	a5,-93(s0)
    name[4] = '\0';
     48a:	fa040223          	sb	zero,-92(s0)
    unlink(name);
     48e:	8552                	mv	a0,s4
     490:	0b3040ef          	jal	4d42 <unlink>
  for(int i = 0; i < nzz; i++){
     494:	2485                	addiw	s1,s1,1
     496:	fd3494e3          	bne	s1,s3,45e <outofinodes+0x7e>
  }
}
     49a:	60e6                	ld	ra,88(sp)
     49c:	6446                	ld	s0,80(sp)
     49e:	64a6                	ld	s1,72(sp)
     4a0:	6906                	ld	s2,64(sp)
     4a2:	79e2                	ld	s3,56(sp)
     4a4:	7a42                	ld	s4,48(sp)
     4a6:	7aa2                	ld	s5,40(sp)
     4a8:	6125                	addi	sp,sp,96
     4aa:	8082                	ret

00000000000004ac <copyin>:
{
     4ac:	7175                	addi	sp,sp,-144
     4ae:	e506                	sd	ra,136(sp)
     4b0:	e122                	sd	s0,128(sp)
     4b2:	fca6                	sd	s1,120(sp)
     4b4:	f8ca                	sd	s2,112(sp)
     4b6:	f4ce                	sd	s3,104(sp)
     4b8:	f0d2                	sd	s4,96(sp)
     4ba:	ecd6                	sd	s5,88(sp)
     4bc:	e8da                	sd	s6,80(sp)
     4be:	e4de                	sd	s7,72(sp)
     4c0:	e0e2                	sd	s8,64(sp)
     4c2:	fc66                	sd	s9,56(sp)
     4c4:	0900                	addi	s0,sp,144
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     4c6:	00007797          	auipc	a5,0x7
     4ca:	27278793          	addi	a5,a5,626 # 7738 <malloc+0x2574>
     4ce:	638c                	ld	a1,0(a5)
     4d0:	6790                	ld	a2,8(a5)
     4d2:	6b94                	ld	a3,16(a5)
     4d4:	6f98                	ld	a4,24(a5)
     4d6:	739c                	ld	a5,32(a5)
     4d8:	f6b43c23          	sd	a1,-136(s0)
     4dc:	f8c43023          	sd	a2,-128(s0)
     4e0:	f8d43423          	sd	a3,-120(s0)
     4e4:	f8e43823          	sd	a4,-112(s0)
     4e8:	f8f43c23          	sd	a5,-104(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     4ec:	f7840913          	addi	s2,s0,-136
     4f0:	fa040c93          	addi	s9,s0,-96
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4f4:	20100b13          	li	s6,513
     4f8:	00005a97          	auipc	s5,0x5
     4fc:	f18a8a93          	addi	s5,s5,-232 # 5410 <malloc+0x24c>
    int n = write(fd, (void*)addr, 8192);
     500:	6a09                	lui	s4,0x2
    n = write(1, (char*)addr, 8192);
     502:	4c05                	li	s8,1
    if(pipe(fds) < 0){
     504:	f7040b93          	addi	s7,s0,-144
    uint64 addr = addrs[ai];
     508:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     50c:	85da                	mv	a1,s6
     50e:	8556                	mv	a0,s5
     510:	023040ef          	jal	4d32 <open>
     514:	84aa                	mv	s1,a0
    if(fd < 0){
     516:	06054a63          	bltz	a0,58a <copyin+0xde>
    int n = write(fd, (void*)addr, 8192);
     51a:	8652                	mv	a2,s4
     51c:	85ce                	mv	a1,s3
     51e:	7f4040ef          	jal	4d12 <write>
    if(n >= 0){
     522:	06055d63          	bgez	a0,59c <copyin+0xf0>
    close(fd);
     526:	8526                	mv	a0,s1
     528:	7f2040ef          	jal	4d1a <close>
    unlink("copyin1");
     52c:	8556                	mv	a0,s5
     52e:	015040ef          	jal	4d42 <unlink>
    n = write(1, (char*)addr, 8192);
     532:	8652                	mv	a2,s4
     534:	85ce                	mv	a1,s3
     536:	8562                	mv	a0,s8
     538:	7da040ef          	jal	4d12 <write>
    if(n > 0){
     53c:	06a04b63          	bgtz	a0,5b2 <copyin+0x106>
    if(pipe(fds) < 0){
     540:	855e                	mv	a0,s7
     542:	7c0040ef          	jal	4d02 <pipe>
     546:	08054163          	bltz	a0,5c8 <copyin+0x11c>
    n = write(fds[1], (char*)addr, 8192);
     54a:	8652                	mv	a2,s4
     54c:	85ce                	mv	a1,s3
     54e:	f7442503          	lw	a0,-140(s0)
     552:	7c0040ef          	jal	4d12 <write>
    if(n > 0){
     556:	08a04263          	bgtz	a0,5da <copyin+0x12e>
    close(fds[0]);
     55a:	f7042503          	lw	a0,-144(s0)
     55e:	7bc040ef          	jal	4d1a <close>
    close(fds[1]);
     562:	f7442503          	lw	a0,-140(s0)
     566:	7b4040ef          	jal	4d1a <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     56a:	0921                	addi	s2,s2,8
     56c:	f9991ee3          	bne	s2,s9,508 <copyin+0x5c>
}
     570:	60aa                	ld	ra,136(sp)
     572:	640a                	ld	s0,128(sp)
     574:	74e6                	ld	s1,120(sp)
     576:	7946                	ld	s2,112(sp)
     578:	79a6                	ld	s3,104(sp)
     57a:	7a06                	ld	s4,96(sp)
     57c:	6ae6                	ld	s5,88(sp)
     57e:	6b46                	ld	s6,80(sp)
     580:	6ba6                	ld	s7,72(sp)
     582:	6c06                	ld	s8,64(sp)
     584:	7ce2                	ld	s9,56(sp)
     586:	6149                	addi	sp,sp,144
     588:	8082                	ret
      printf("open(copyin1) failed\n");
     58a:	00005517          	auipc	a0,0x5
     58e:	e8e50513          	addi	a0,a0,-370 # 5418 <malloc+0x254>
     592:	37b040ef          	jal	510c <printf>
      exit(1);
     596:	4505                	li	a0,1
     598:	75a040ef          	jal	4cf2 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", (void*)addr, n);
     59c:	862a                	mv	a2,a0
     59e:	85ce                	mv	a1,s3
     5a0:	00005517          	auipc	a0,0x5
     5a4:	e9050513          	addi	a0,a0,-368 # 5430 <malloc+0x26c>
     5a8:	365040ef          	jal	510c <printf>
      exit(1);
     5ac:	4505                	li	a0,1
     5ae:	744040ef          	jal	4cf2 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     5b2:	862a                	mv	a2,a0
     5b4:	85ce                	mv	a1,s3
     5b6:	00005517          	auipc	a0,0x5
     5ba:	eaa50513          	addi	a0,a0,-342 # 5460 <malloc+0x29c>
     5be:	34f040ef          	jal	510c <printf>
      exit(1);
     5c2:	4505                	li	a0,1
     5c4:	72e040ef          	jal	4cf2 <exit>
      printf("pipe() failed\n");
     5c8:	00005517          	auipc	a0,0x5
     5cc:	ec850513          	addi	a0,a0,-312 # 5490 <malloc+0x2cc>
     5d0:	33d040ef          	jal	510c <printf>
      exit(1);
     5d4:	4505                	li	a0,1
     5d6:	71c040ef          	jal	4cf2 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     5da:	862a                	mv	a2,a0
     5dc:	85ce                	mv	a1,s3
     5de:	00005517          	auipc	a0,0x5
     5e2:	ec250513          	addi	a0,a0,-318 # 54a0 <malloc+0x2dc>
     5e6:	327040ef          	jal	510c <printf>
      exit(1);
     5ea:	4505                	li	a0,1
     5ec:	706040ef          	jal	4cf2 <exit>

00000000000005f0 <copyout>:
{
     5f0:	7135                	addi	sp,sp,-160
     5f2:	ed06                	sd	ra,152(sp)
     5f4:	e922                	sd	s0,144(sp)
     5f6:	e526                	sd	s1,136(sp)
     5f8:	e14a                	sd	s2,128(sp)
     5fa:	fcce                	sd	s3,120(sp)
     5fc:	f8d2                	sd	s4,112(sp)
     5fe:	f4d6                	sd	s5,104(sp)
     600:	f0da                	sd	s6,96(sp)
     602:	ecde                	sd	s7,88(sp)
     604:	e8e2                	sd	s8,80(sp)
     606:	e4e6                	sd	s9,72(sp)
     608:	1100                	addi	s0,sp,160
  uint64 addrs[] = { 0LL, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     60a:	00007797          	auipc	a5,0x7
     60e:	12e78793          	addi	a5,a5,302 # 7738 <malloc+0x2574>
     612:	7788                	ld	a0,40(a5)
     614:	7b8c                	ld	a1,48(a5)
     616:	7f90                	ld	a2,56(a5)
     618:	63b4                	ld	a3,64(a5)
     61a:	67b8                	ld	a4,72(a5)
     61c:	6bbc                	ld	a5,80(a5)
     61e:	f6a43823          	sd	a0,-144(s0)
     622:	f6b43c23          	sd	a1,-136(s0)
     626:	f8c43023          	sd	a2,-128(s0)
     62a:	f8d43423          	sd	a3,-120(s0)
     62e:	f8e43823          	sd	a4,-112(s0)
     632:	f8f43c23          	sd	a5,-104(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     636:	f7040913          	addi	s2,s0,-144
     63a:	fa040c93          	addi	s9,s0,-96
    int fd = open("README", 0);
     63e:	00005b17          	auipc	s6,0x5
     642:	e92b0b13          	addi	s6,s6,-366 # 54d0 <malloc+0x30c>
    int n = read(fd, (void*)addr, 8192);
     646:	6a89                	lui	s5,0x2
    if(pipe(fds) < 0){
     648:	f6840c13          	addi	s8,s0,-152
    n = write(fds[1], "x", 1);
     64c:	4a05                	li	s4,1
     64e:	00005b97          	auipc	s7,0x5
     652:	d1ab8b93          	addi	s7,s7,-742 # 5368 <malloc+0x1a4>
    uint64 addr = addrs[ai];
     656:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     65a:	4581                	li	a1,0
     65c:	855a                	mv	a0,s6
     65e:	6d4040ef          	jal	4d32 <open>
     662:	84aa                	mv	s1,a0
    if(fd < 0){
     664:	06054863          	bltz	a0,6d4 <copyout+0xe4>
    int n = read(fd, (void*)addr, 8192);
     668:	8656                	mv	a2,s5
     66a:	85ce                	mv	a1,s3
     66c:	69e040ef          	jal	4d0a <read>
    if(n > 0){
     670:	06a04b63          	bgtz	a0,6e6 <copyout+0xf6>
    close(fd);
     674:	8526                	mv	a0,s1
     676:	6a4040ef          	jal	4d1a <close>
    if(pipe(fds) < 0){
     67a:	8562                	mv	a0,s8
     67c:	686040ef          	jal	4d02 <pipe>
     680:	06054e63          	bltz	a0,6fc <copyout+0x10c>
    n = write(fds[1], "x", 1);
     684:	8652                	mv	a2,s4
     686:	85de                	mv	a1,s7
     688:	f6c42503          	lw	a0,-148(s0)
     68c:	686040ef          	jal	4d12 <write>
    if(n != 1){
     690:	07451f63          	bne	a0,s4,70e <copyout+0x11e>
    n = read(fds[0], (void*)addr, 8192);
     694:	8656                	mv	a2,s5
     696:	85ce                	mv	a1,s3
     698:	f6842503          	lw	a0,-152(s0)
     69c:	66e040ef          	jal	4d0a <read>
    if(n > 0){
     6a0:	08a04063          	bgtz	a0,720 <copyout+0x130>
    close(fds[0]);
     6a4:	f6842503          	lw	a0,-152(s0)
     6a8:	672040ef          	jal	4d1a <close>
    close(fds[1]);
     6ac:	f6c42503          	lw	a0,-148(s0)
     6b0:	66a040ef          	jal	4d1a <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     6b4:	0921                	addi	s2,s2,8
     6b6:	fb9910e3          	bne	s2,s9,656 <copyout+0x66>
}
     6ba:	60ea                	ld	ra,152(sp)
     6bc:	644a                	ld	s0,144(sp)
     6be:	64aa                	ld	s1,136(sp)
     6c0:	690a                	ld	s2,128(sp)
     6c2:	79e6                	ld	s3,120(sp)
     6c4:	7a46                	ld	s4,112(sp)
     6c6:	7aa6                	ld	s5,104(sp)
     6c8:	7b06                	ld	s6,96(sp)
     6ca:	6be6                	ld	s7,88(sp)
     6cc:	6c46                	ld	s8,80(sp)
     6ce:	6ca6                	ld	s9,72(sp)
     6d0:	610d                	addi	sp,sp,160
     6d2:	8082                	ret
      printf("open(README) failed\n");
     6d4:	00005517          	auipc	a0,0x5
     6d8:	e0450513          	addi	a0,a0,-508 # 54d8 <malloc+0x314>
     6dc:	231040ef          	jal	510c <printf>
      exit(1);
     6e0:	4505                	li	a0,1
     6e2:	610040ef          	jal	4cf2 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     6e6:	862a                	mv	a2,a0
     6e8:	85ce                	mv	a1,s3
     6ea:	00005517          	auipc	a0,0x5
     6ee:	e0650513          	addi	a0,a0,-506 # 54f0 <malloc+0x32c>
     6f2:	21b040ef          	jal	510c <printf>
      exit(1);
     6f6:	4505                	li	a0,1
     6f8:	5fa040ef          	jal	4cf2 <exit>
      printf("pipe() failed\n");
     6fc:	00005517          	auipc	a0,0x5
     700:	d9450513          	addi	a0,a0,-620 # 5490 <malloc+0x2cc>
     704:	209040ef          	jal	510c <printf>
      exit(1);
     708:	4505                	li	a0,1
     70a:	5e8040ef          	jal	4cf2 <exit>
      printf("pipe write failed\n");
     70e:	00005517          	auipc	a0,0x5
     712:	e1250513          	addi	a0,a0,-494 # 5520 <malloc+0x35c>
     716:	1f7040ef          	jal	510c <printf>
      exit(1);
     71a:	4505                	li	a0,1
     71c:	5d6040ef          	jal	4cf2 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     720:	862a                	mv	a2,a0
     722:	85ce                	mv	a1,s3
     724:	00005517          	auipc	a0,0x5
     728:	e1450513          	addi	a0,a0,-492 # 5538 <malloc+0x374>
     72c:	1e1040ef          	jal	510c <printf>
      exit(1);
     730:	4505                	li	a0,1
     732:	5c0040ef          	jal	4cf2 <exit>

0000000000000736 <truncate1>:
{
     736:	711d                	addi	sp,sp,-96
     738:	ec86                	sd	ra,88(sp)
     73a:	e8a2                	sd	s0,80(sp)
     73c:	e4a6                	sd	s1,72(sp)
     73e:	e0ca                	sd	s2,64(sp)
     740:	fc4e                	sd	s3,56(sp)
     742:	f852                	sd	s4,48(sp)
     744:	f456                	sd	s5,40(sp)
     746:	1080                	addi	s0,sp,96
     748:	8aaa                	mv	s5,a0
  unlink("truncfile");
     74a:	00005517          	auipc	a0,0x5
     74e:	c0650513          	addi	a0,a0,-1018 # 5350 <malloc+0x18c>
     752:	5f0040ef          	jal	4d42 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     756:	60100593          	li	a1,1537
     75a:	00005517          	auipc	a0,0x5
     75e:	bf650513          	addi	a0,a0,-1034 # 5350 <malloc+0x18c>
     762:	5d0040ef          	jal	4d32 <open>
     766:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     768:	4611                	li	a2,4
     76a:	00005597          	auipc	a1,0x5
     76e:	bf658593          	addi	a1,a1,-1034 # 5360 <malloc+0x19c>
     772:	5a0040ef          	jal	4d12 <write>
  close(fd1);
     776:	8526                	mv	a0,s1
     778:	5a2040ef          	jal	4d1a <close>
  int fd2 = open("truncfile", O_RDONLY);
     77c:	4581                	li	a1,0
     77e:	00005517          	auipc	a0,0x5
     782:	bd250513          	addi	a0,a0,-1070 # 5350 <malloc+0x18c>
     786:	5ac040ef          	jal	4d32 <open>
     78a:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     78c:	02000613          	li	a2,32
     790:	fa040593          	addi	a1,s0,-96
     794:	576040ef          	jal	4d0a <read>
  if(n != 4){
     798:	4791                	li	a5,4
     79a:	0af51863          	bne	a0,a5,84a <truncate1+0x114>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     79e:	40100593          	li	a1,1025
     7a2:	00005517          	auipc	a0,0x5
     7a6:	bae50513          	addi	a0,a0,-1106 # 5350 <malloc+0x18c>
     7aa:	588040ef          	jal	4d32 <open>
     7ae:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     7b0:	4581                	li	a1,0
     7b2:	00005517          	auipc	a0,0x5
     7b6:	b9e50513          	addi	a0,a0,-1122 # 5350 <malloc+0x18c>
     7ba:	578040ef          	jal	4d32 <open>
     7be:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     7c0:	02000613          	li	a2,32
     7c4:	fa040593          	addi	a1,s0,-96
     7c8:	542040ef          	jal	4d0a <read>
     7cc:	8a2a                	mv	s4,a0
  if(n != 0){
     7ce:	e949                	bnez	a0,860 <truncate1+0x12a>
  n = read(fd2, buf, sizeof(buf));
     7d0:	02000613          	li	a2,32
     7d4:	fa040593          	addi	a1,s0,-96
     7d8:	8526                	mv	a0,s1
     7da:	530040ef          	jal	4d0a <read>
     7de:	8a2a                	mv	s4,a0
  if(n != 0){
     7e0:	e155                	bnez	a0,884 <truncate1+0x14e>
  write(fd1, "abcdef", 6);
     7e2:	4619                	li	a2,6
     7e4:	00005597          	auipc	a1,0x5
     7e8:	de458593          	addi	a1,a1,-540 # 55c8 <malloc+0x404>
     7ec:	854e                	mv	a0,s3
     7ee:	524040ef          	jal	4d12 <write>
  n = read(fd3, buf, sizeof(buf));
     7f2:	02000613          	li	a2,32
     7f6:	fa040593          	addi	a1,s0,-96
     7fa:	854a                	mv	a0,s2
     7fc:	50e040ef          	jal	4d0a <read>
  if(n != 6){
     800:	4799                	li	a5,6
     802:	0af51363          	bne	a0,a5,8a8 <truncate1+0x172>
  n = read(fd2, buf, sizeof(buf));
     806:	02000613          	li	a2,32
     80a:	fa040593          	addi	a1,s0,-96
     80e:	8526                	mv	a0,s1
     810:	4fa040ef          	jal	4d0a <read>
  if(n != 2){
     814:	4789                	li	a5,2
     816:	0af51463          	bne	a0,a5,8be <truncate1+0x188>
  unlink("truncfile");
     81a:	00005517          	auipc	a0,0x5
     81e:	b3650513          	addi	a0,a0,-1226 # 5350 <malloc+0x18c>
     822:	520040ef          	jal	4d42 <unlink>
  close(fd1);
     826:	854e                	mv	a0,s3
     828:	4f2040ef          	jal	4d1a <close>
  close(fd2);
     82c:	8526                	mv	a0,s1
     82e:	4ec040ef          	jal	4d1a <close>
  close(fd3);
     832:	854a                	mv	a0,s2
     834:	4e6040ef          	jal	4d1a <close>
}
     838:	60e6                	ld	ra,88(sp)
     83a:	6446                	ld	s0,80(sp)
     83c:	64a6                	ld	s1,72(sp)
     83e:	6906                	ld	s2,64(sp)
     840:	79e2                	ld	s3,56(sp)
     842:	7a42                	ld	s4,48(sp)
     844:	7aa2                	ld	s5,40(sp)
     846:	6125                	addi	sp,sp,96
     848:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     84a:	862a                	mv	a2,a0
     84c:	85d6                	mv	a1,s5
     84e:	00005517          	auipc	a0,0x5
     852:	d1a50513          	addi	a0,a0,-742 # 5568 <malloc+0x3a4>
     856:	0b7040ef          	jal	510c <printf>
    exit(1);
     85a:	4505                	li	a0,1
     85c:	496040ef          	jal	4cf2 <exit>
    printf("aaa fd3=%d\n", fd3);
     860:	85ca                	mv	a1,s2
     862:	00005517          	auipc	a0,0x5
     866:	d2650513          	addi	a0,a0,-730 # 5588 <malloc+0x3c4>
     86a:	0a3040ef          	jal	510c <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     86e:	8652                	mv	a2,s4
     870:	85d6                	mv	a1,s5
     872:	00005517          	auipc	a0,0x5
     876:	d2650513          	addi	a0,a0,-730 # 5598 <malloc+0x3d4>
     87a:	093040ef          	jal	510c <printf>
    exit(1);
     87e:	4505                	li	a0,1
     880:	472040ef          	jal	4cf2 <exit>
    printf("bbb fd2=%d\n", fd2);
     884:	85a6                	mv	a1,s1
     886:	00005517          	auipc	a0,0x5
     88a:	d3250513          	addi	a0,a0,-718 # 55b8 <malloc+0x3f4>
     88e:	07f040ef          	jal	510c <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     892:	8652                	mv	a2,s4
     894:	85d6                	mv	a1,s5
     896:	00005517          	auipc	a0,0x5
     89a:	d0250513          	addi	a0,a0,-766 # 5598 <malloc+0x3d4>
     89e:	06f040ef          	jal	510c <printf>
    exit(1);
     8a2:	4505                	li	a0,1
     8a4:	44e040ef          	jal	4cf2 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     8a8:	862a                	mv	a2,a0
     8aa:	85d6                	mv	a1,s5
     8ac:	00005517          	auipc	a0,0x5
     8b0:	d2450513          	addi	a0,a0,-732 # 55d0 <malloc+0x40c>
     8b4:	059040ef          	jal	510c <printf>
    exit(1);
     8b8:	4505                	li	a0,1
     8ba:	438040ef          	jal	4cf2 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     8be:	862a                	mv	a2,a0
     8c0:	85d6                	mv	a1,s5
     8c2:	00005517          	auipc	a0,0x5
     8c6:	d2e50513          	addi	a0,a0,-722 # 55f0 <malloc+0x42c>
     8ca:	043040ef          	jal	510c <printf>
    exit(1);
     8ce:	4505                	li	a0,1
     8d0:	422040ef          	jal	4cf2 <exit>

00000000000008d4 <writetest>:
{
     8d4:	715d                	addi	sp,sp,-80
     8d6:	e486                	sd	ra,72(sp)
     8d8:	e0a2                	sd	s0,64(sp)
     8da:	fc26                	sd	s1,56(sp)
     8dc:	f84a                	sd	s2,48(sp)
     8de:	f44e                	sd	s3,40(sp)
     8e0:	f052                	sd	s4,32(sp)
     8e2:	ec56                	sd	s5,24(sp)
     8e4:	e85a                	sd	s6,16(sp)
     8e6:	e45e                	sd	s7,8(sp)
     8e8:	0880                	addi	s0,sp,80
     8ea:	8baa                	mv	s7,a0
  fd = open("small", O_CREATE|O_RDWR);
     8ec:	20200593          	li	a1,514
     8f0:	00005517          	auipc	a0,0x5
     8f4:	d2050513          	addi	a0,a0,-736 # 5610 <malloc+0x44c>
     8f8:	43a040ef          	jal	4d32 <open>
  if(fd < 0){
     8fc:	08054f63          	bltz	a0,99a <writetest+0xc6>
     900:	89aa                	mv	s3,a0
     902:	4901                	li	s2,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     904:	44a9                	li	s1,10
     906:	00005a17          	auipc	s4,0x5
     90a:	d32a0a13          	addi	s4,s4,-718 # 5638 <malloc+0x474>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     90e:	00005b17          	auipc	s6,0x5
     912:	d62b0b13          	addi	s6,s6,-670 # 5670 <malloc+0x4ac>
  for(i = 0; i < N; i++){
     916:	06400a93          	li	s5,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     91a:	8626                	mv	a2,s1
     91c:	85d2                	mv	a1,s4
     91e:	854e                	mv	a0,s3
     920:	3f2040ef          	jal	4d12 <write>
     924:	08951563          	bne	a0,s1,9ae <writetest+0xda>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     928:	8626                	mv	a2,s1
     92a:	85da                	mv	a1,s6
     92c:	854e                	mv	a0,s3
     92e:	3e4040ef          	jal	4d12 <write>
     932:	08951963          	bne	a0,s1,9c4 <writetest+0xf0>
  for(i = 0; i < N; i++){
     936:	2905                	addiw	s2,s2,1
     938:	ff5911e3          	bne	s2,s5,91a <writetest+0x46>
  close(fd);
     93c:	854e                	mv	a0,s3
     93e:	3dc040ef          	jal	4d1a <close>
  fd = open("small", O_RDONLY);
     942:	4581                	li	a1,0
     944:	00005517          	auipc	a0,0x5
     948:	ccc50513          	addi	a0,a0,-820 # 5610 <malloc+0x44c>
     94c:	3e6040ef          	jal	4d32 <open>
     950:	84aa                	mv	s1,a0
  if(fd < 0){
     952:	08054463          	bltz	a0,9da <writetest+0x106>
  i = read(fd, buf, N*SZ*2);
     956:	7d000613          	li	a2,2000
     95a:	0000c597          	auipc	a1,0xc
     95e:	31e58593          	addi	a1,a1,798 # cc78 <buf>
     962:	3a8040ef          	jal	4d0a <read>
  if(i != N*SZ*2){
     966:	7d000793          	li	a5,2000
     96a:	08f51263          	bne	a0,a5,9ee <writetest+0x11a>
  close(fd);
     96e:	8526                	mv	a0,s1
     970:	3aa040ef          	jal	4d1a <close>
  if(unlink("small") < 0){
     974:	00005517          	auipc	a0,0x5
     978:	c9c50513          	addi	a0,a0,-868 # 5610 <malloc+0x44c>
     97c:	3c6040ef          	jal	4d42 <unlink>
     980:	08054163          	bltz	a0,a02 <writetest+0x12e>
}
     984:	60a6                	ld	ra,72(sp)
     986:	6406                	ld	s0,64(sp)
     988:	74e2                	ld	s1,56(sp)
     98a:	7942                	ld	s2,48(sp)
     98c:	79a2                	ld	s3,40(sp)
     98e:	7a02                	ld	s4,32(sp)
     990:	6ae2                	ld	s5,24(sp)
     992:	6b42                	ld	s6,16(sp)
     994:	6ba2                	ld	s7,8(sp)
     996:	6161                	addi	sp,sp,80
     998:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     99a:	85de                	mv	a1,s7
     99c:	00005517          	auipc	a0,0x5
     9a0:	c7c50513          	addi	a0,a0,-900 # 5618 <malloc+0x454>
     9a4:	768040ef          	jal	510c <printf>
    exit(1);
     9a8:	4505                	li	a0,1
     9aa:	348040ef          	jal	4cf2 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     9ae:	864a                	mv	a2,s2
     9b0:	85de                	mv	a1,s7
     9b2:	00005517          	auipc	a0,0x5
     9b6:	c9650513          	addi	a0,a0,-874 # 5648 <malloc+0x484>
     9ba:	752040ef          	jal	510c <printf>
      exit(1);
     9be:	4505                	li	a0,1
     9c0:	332040ef          	jal	4cf2 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     9c4:	864a                	mv	a2,s2
     9c6:	85de                	mv	a1,s7
     9c8:	00005517          	auipc	a0,0x5
     9cc:	cb850513          	addi	a0,a0,-840 # 5680 <malloc+0x4bc>
     9d0:	73c040ef          	jal	510c <printf>
      exit(1);
     9d4:	4505                	li	a0,1
     9d6:	31c040ef          	jal	4cf2 <exit>
    printf("%s: error: open small failed!\n", s);
     9da:	85de                	mv	a1,s7
     9dc:	00005517          	auipc	a0,0x5
     9e0:	ccc50513          	addi	a0,a0,-820 # 56a8 <malloc+0x4e4>
     9e4:	728040ef          	jal	510c <printf>
    exit(1);
     9e8:	4505                	li	a0,1
     9ea:	308040ef          	jal	4cf2 <exit>
    printf("%s: read failed\n", s);
     9ee:	85de                	mv	a1,s7
     9f0:	00005517          	auipc	a0,0x5
     9f4:	cd850513          	addi	a0,a0,-808 # 56c8 <malloc+0x504>
     9f8:	714040ef          	jal	510c <printf>
    exit(1);
     9fc:	4505                	li	a0,1
     9fe:	2f4040ef          	jal	4cf2 <exit>
    printf("%s: unlink small failed\n", s);
     a02:	85de                	mv	a1,s7
     a04:	00005517          	auipc	a0,0x5
     a08:	cdc50513          	addi	a0,a0,-804 # 56e0 <malloc+0x51c>
     a0c:	700040ef          	jal	510c <printf>
    exit(1);
     a10:	4505                	li	a0,1
     a12:	2e0040ef          	jal	4cf2 <exit>

0000000000000a16 <writebig>:
{
     a16:	7139                	addi	sp,sp,-64
     a18:	fc06                	sd	ra,56(sp)
     a1a:	f822                	sd	s0,48(sp)
     a1c:	f426                	sd	s1,40(sp)
     a1e:	f04a                	sd	s2,32(sp)
     a20:	ec4e                	sd	s3,24(sp)
     a22:	e852                	sd	s4,16(sp)
     a24:	e456                	sd	s5,8(sp)
     a26:	e05a                	sd	s6,0(sp)
     a28:	0080                	addi	s0,sp,64
     a2a:	8b2a                	mv	s6,a0
  fd = open("big", O_CREATE|O_RDWR);
     a2c:	20200593          	li	a1,514
     a30:	00005517          	auipc	a0,0x5
     a34:	cd050513          	addi	a0,a0,-816 # 5700 <malloc+0x53c>
     a38:	2fa040ef          	jal	4d32 <open>
  if(fd < 0){
     a3c:	06054a63          	bltz	a0,ab0 <writebig+0x9a>
     a40:	8a2a                	mv	s4,a0
     a42:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     a44:	0000c997          	auipc	s3,0xc
     a48:	23498993          	addi	s3,s3,564 # cc78 <buf>
    if(write(fd, buf, BSIZE) != BSIZE){
     a4c:	40000913          	li	s2,1024
  for(i = 0; i < MAXFILE; i++){
     a50:	10c00a93          	li	s5,268
    ((int*)buf)[0] = i;
     a54:	0099a023          	sw	s1,0(s3)
    if(write(fd, buf, BSIZE) != BSIZE){
     a58:	864a                	mv	a2,s2
     a5a:	85ce                	mv	a1,s3
     a5c:	8552                	mv	a0,s4
     a5e:	2b4040ef          	jal	4d12 <write>
     a62:	07251163          	bne	a0,s2,ac4 <writebig+0xae>
  for(i = 0; i < MAXFILE; i++){
     a66:	2485                	addiw	s1,s1,1
     a68:	ff5496e3          	bne	s1,s5,a54 <writebig+0x3e>
  close(fd);
     a6c:	8552                	mv	a0,s4
     a6e:	2ac040ef          	jal	4d1a <close>
  fd = open("big", O_RDONLY);
     a72:	4581                	li	a1,0
     a74:	00005517          	auipc	a0,0x5
     a78:	c8c50513          	addi	a0,a0,-884 # 5700 <malloc+0x53c>
     a7c:	2b6040ef          	jal	4d32 <open>
     a80:	8a2a                	mv	s4,a0
  n = 0;
     a82:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a84:	40000993          	li	s3,1024
     a88:	0000c917          	auipc	s2,0xc
     a8c:	1f090913          	addi	s2,s2,496 # cc78 <buf>
  if(fd < 0){
     a90:	04054563          	bltz	a0,ada <writebig+0xc4>
    i = read(fd, buf, BSIZE);
     a94:	864e                	mv	a2,s3
     a96:	85ca                	mv	a1,s2
     a98:	8552                	mv	a0,s4
     a9a:	270040ef          	jal	4d0a <read>
    if(i == 0){
     a9e:	c921                	beqz	a0,aee <writebig+0xd8>
    } else if(i != BSIZE){
     aa0:	09351b63          	bne	a0,s3,b36 <writebig+0x120>
    if(((int*)buf)[0] != n){
     aa4:	00092683          	lw	a3,0(s2)
     aa8:	0a969263          	bne	a3,s1,b4c <writebig+0x136>
    n++;
     aac:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     aae:	b7dd                	j	a94 <writebig+0x7e>
    printf("%s: error: creat big failed!\n", s);
     ab0:	85da                	mv	a1,s6
     ab2:	00005517          	auipc	a0,0x5
     ab6:	c5650513          	addi	a0,a0,-938 # 5708 <malloc+0x544>
     aba:	652040ef          	jal	510c <printf>
    exit(1);
     abe:	4505                	li	a0,1
     ac0:	232040ef          	jal	4cf2 <exit>
      printf("%s: error: write big file failed i=%d\n", s, i);
     ac4:	8626                	mv	a2,s1
     ac6:	85da                	mv	a1,s6
     ac8:	00005517          	auipc	a0,0x5
     acc:	c6050513          	addi	a0,a0,-928 # 5728 <malloc+0x564>
     ad0:	63c040ef          	jal	510c <printf>
      exit(1);
     ad4:	4505                	li	a0,1
     ad6:	21c040ef          	jal	4cf2 <exit>
    printf("%s: error: open big failed!\n", s);
     ada:	85da                	mv	a1,s6
     adc:	00005517          	auipc	a0,0x5
     ae0:	c7450513          	addi	a0,a0,-908 # 5750 <malloc+0x58c>
     ae4:	628040ef          	jal	510c <printf>
    exit(1);
     ae8:	4505                	li	a0,1
     aea:	208040ef          	jal	4cf2 <exit>
      if(n != MAXFILE){
     aee:	10c00793          	li	a5,268
     af2:	02f49763          	bne	s1,a5,b20 <writebig+0x10a>
  close(fd);
     af6:	8552                	mv	a0,s4
     af8:	222040ef          	jal	4d1a <close>
  if(unlink("big") < 0){
     afc:	00005517          	auipc	a0,0x5
     b00:	c0450513          	addi	a0,a0,-1020 # 5700 <malloc+0x53c>
     b04:	23e040ef          	jal	4d42 <unlink>
     b08:	04054d63          	bltz	a0,b62 <writebig+0x14c>
}
     b0c:	70e2                	ld	ra,56(sp)
     b0e:	7442                	ld	s0,48(sp)
     b10:	74a2                	ld	s1,40(sp)
     b12:	7902                	ld	s2,32(sp)
     b14:	69e2                	ld	s3,24(sp)
     b16:	6a42                	ld	s4,16(sp)
     b18:	6aa2                	ld	s5,8(sp)
     b1a:	6b02                	ld	s6,0(sp)
     b1c:	6121                	addi	sp,sp,64
     b1e:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     b20:	8626                	mv	a2,s1
     b22:	85da                	mv	a1,s6
     b24:	00005517          	auipc	a0,0x5
     b28:	c4c50513          	addi	a0,a0,-948 # 5770 <malloc+0x5ac>
     b2c:	5e0040ef          	jal	510c <printf>
        exit(1);
     b30:	4505                	li	a0,1
     b32:	1c0040ef          	jal	4cf2 <exit>
      printf("%s: read failed %d\n", s, i);
     b36:	862a                	mv	a2,a0
     b38:	85da                	mv	a1,s6
     b3a:	00005517          	auipc	a0,0x5
     b3e:	c5e50513          	addi	a0,a0,-930 # 5798 <malloc+0x5d4>
     b42:	5ca040ef          	jal	510c <printf>
      exit(1);
     b46:	4505                	li	a0,1
     b48:	1aa040ef          	jal	4cf2 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b4c:	8626                	mv	a2,s1
     b4e:	85da                	mv	a1,s6
     b50:	00005517          	auipc	a0,0x5
     b54:	c6050513          	addi	a0,a0,-928 # 57b0 <malloc+0x5ec>
     b58:	5b4040ef          	jal	510c <printf>
      exit(1);
     b5c:	4505                	li	a0,1
     b5e:	194040ef          	jal	4cf2 <exit>
    printf("%s: unlink big failed\n", s);
     b62:	85da                	mv	a1,s6
     b64:	00005517          	auipc	a0,0x5
     b68:	c7450513          	addi	a0,a0,-908 # 57d8 <malloc+0x614>
     b6c:	5a0040ef          	jal	510c <printf>
    exit(1);
     b70:	4505                	li	a0,1
     b72:	180040ef          	jal	4cf2 <exit>

0000000000000b76 <unlinkread>:
{
     b76:	7179                	addi	sp,sp,-48
     b78:	f406                	sd	ra,40(sp)
     b7a:	f022                	sd	s0,32(sp)
     b7c:	ec26                	sd	s1,24(sp)
     b7e:	e84a                	sd	s2,16(sp)
     b80:	e44e                	sd	s3,8(sp)
     b82:	1800                	addi	s0,sp,48
     b84:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b86:	20200593          	li	a1,514
     b8a:	00005517          	auipc	a0,0x5
     b8e:	c6650513          	addi	a0,a0,-922 # 57f0 <malloc+0x62c>
     b92:	1a0040ef          	jal	4d32 <open>
  if(fd < 0){
     b96:	0a054f63          	bltz	a0,c54 <unlinkread+0xde>
     b9a:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b9c:	4615                	li	a2,5
     b9e:	00005597          	auipc	a1,0x5
     ba2:	c8258593          	addi	a1,a1,-894 # 5820 <malloc+0x65c>
     ba6:	16c040ef          	jal	4d12 <write>
  close(fd);
     baa:	8526                	mv	a0,s1
     bac:	16e040ef          	jal	4d1a <close>
  fd = open("unlinkread", O_RDWR);
     bb0:	4589                	li	a1,2
     bb2:	00005517          	auipc	a0,0x5
     bb6:	c3e50513          	addi	a0,a0,-962 # 57f0 <malloc+0x62c>
     bba:	178040ef          	jal	4d32 <open>
     bbe:	84aa                	mv	s1,a0
  if(fd < 0){
     bc0:	0a054463          	bltz	a0,c68 <unlinkread+0xf2>
  if(unlink("unlinkread") != 0){
     bc4:	00005517          	auipc	a0,0x5
     bc8:	c2c50513          	addi	a0,a0,-980 # 57f0 <malloc+0x62c>
     bcc:	176040ef          	jal	4d42 <unlink>
     bd0:	e555                	bnez	a0,c7c <unlinkread+0x106>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd2:	20200593          	li	a1,514
     bd6:	00005517          	auipc	a0,0x5
     bda:	c1a50513          	addi	a0,a0,-998 # 57f0 <malloc+0x62c>
     bde:	154040ef          	jal	4d32 <open>
     be2:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     be4:	460d                	li	a2,3
     be6:	00005597          	auipc	a1,0x5
     bea:	c8258593          	addi	a1,a1,-894 # 5868 <malloc+0x6a4>
     bee:	124040ef          	jal	4d12 <write>
  close(fd1);
     bf2:	854a                	mv	a0,s2
     bf4:	126040ef          	jal	4d1a <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     bf8:	660d                	lui	a2,0x3
     bfa:	0000c597          	auipc	a1,0xc
     bfe:	07e58593          	addi	a1,a1,126 # cc78 <buf>
     c02:	8526                	mv	a0,s1
     c04:	106040ef          	jal	4d0a <read>
     c08:	4795                	li	a5,5
     c0a:	08f51363          	bne	a0,a5,c90 <unlinkread+0x11a>
  if(buf[0] != 'h'){
     c0e:	0000c717          	auipc	a4,0xc
     c12:	06a74703          	lbu	a4,106(a4) # cc78 <buf>
     c16:	06800793          	li	a5,104
     c1a:	08f71563          	bne	a4,a5,ca4 <unlinkread+0x12e>
  if(write(fd, buf, 10) != 10){
     c1e:	4629                	li	a2,10
     c20:	0000c597          	auipc	a1,0xc
     c24:	05858593          	addi	a1,a1,88 # cc78 <buf>
     c28:	8526                	mv	a0,s1
     c2a:	0e8040ef          	jal	4d12 <write>
     c2e:	47a9                	li	a5,10
     c30:	08f51463          	bne	a0,a5,cb8 <unlinkread+0x142>
  close(fd);
     c34:	8526                	mv	a0,s1
     c36:	0e4040ef          	jal	4d1a <close>
  unlink("unlinkread");
     c3a:	00005517          	auipc	a0,0x5
     c3e:	bb650513          	addi	a0,a0,-1098 # 57f0 <malloc+0x62c>
     c42:	100040ef          	jal	4d42 <unlink>
}
     c46:	70a2                	ld	ra,40(sp)
     c48:	7402                	ld	s0,32(sp)
     c4a:	64e2                	ld	s1,24(sp)
     c4c:	6942                	ld	s2,16(sp)
     c4e:	69a2                	ld	s3,8(sp)
     c50:	6145                	addi	sp,sp,48
     c52:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c54:	85ce                	mv	a1,s3
     c56:	00005517          	auipc	a0,0x5
     c5a:	baa50513          	addi	a0,a0,-1110 # 5800 <malloc+0x63c>
     c5e:	4ae040ef          	jal	510c <printf>
    exit(1);
     c62:	4505                	li	a0,1
     c64:	08e040ef          	jal	4cf2 <exit>
    printf("%s: open unlinkread failed\n", s);
     c68:	85ce                	mv	a1,s3
     c6a:	00005517          	auipc	a0,0x5
     c6e:	bbe50513          	addi	a0,a0,-1090 # 5828 <malloc+0x664>
     c72:	49a040ef          	jal	510c <printf>
    exit(1);
     c76:	4505                	li	a0,1
     c78:	07a040ef          	jal	4cf2 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     c7c:	85ce                	mv	a1,s3
     c7e:	00005517          	auipc	a0,0x5
     c82:	bca50513          	addi	a0,a0,-1078 # 5848 <malloc+0x684>
     c86:	486040ef          	jal	510c <printf>
    exit(1);
     c8a:	4505                	li	a0,1
     c8c:	066040ef          	jal	4cf2 <exit>
    printf("%s: unlinkread read failed", s);
     c90:	85ce                	mv	a1,s3
     c92:	00005517          	auipc	a0,0x5
     c96:	bde50513          	addi	a0,a0,-1058 # 5870 <malloc+0x6ac>
     c9a:	472040ef          	jal	510c <printf>
    exit(1);
     c9e:	4505                	li	a0,1
     ca0:	052040ef          	jal	4cf2 <exit>
    printf("%s: unlinkread wrong data\n", s);
     ca4:	85ce                	mv	a1,s3
     ca6:	00005517          	auipc	a0,0x5
     caa:	bea50513          	addi	a0,a0,-1046 # 5890 <malloc+0x6cc>
     cae:	45e040ef          	jal	510c <printf>
    exit(1);
     cb2:	4505                	li	a0,1
     cb4:	03e040ef          	jal	4cf2 <exit>
    printf("%s: unlinkread write failed\n", s);
     cb8:	85ce                	mv	a1,s3
     cba:	00005517          	auipc	a0,0x5
     cbe:	bf650513          	addi	a0,a0,-1034 # 58b0 <malloc+0x6ec>
     cc2:	44a040ef          	jal	510c <printf>
    exit(1);
     cc6:	4505                	li	a0,1
     cc8:	02a040ef          	jal	4cf2 <exit>

0000000000000ccc <linktest>:
{
     ccc:	1101                	addi	sp,sp,-32
     cce:	ec06                	sd	ra,24(sp)
     cd0:	e822                	sd	s0,16(sp)
     cd2:	e426                	sd	s1,8(sp)
     cd4:	e04a                	sd	s2,0(sp)
     cd6:	1000                	addi	s0,sp,32
     cd8:	892a                	mv	s2,a0
  unlink("lf1");
     cda:	00005517          	auipc	a0,0x5
     cde:	bf650513          	addi	a0,a0,-1034 # 58d0 <malloc+0x70c>
     ce2:	060040ef          	jal	4d42 <unlink>
  unlink("lf2");
     ce6:	00005517          	auipc	a0,0x5
     cea:	bf250513          	addi	a0,a0,-1038 # 58d8 <malloc+0x714>
     cee:	054040ef          	jal	4d42 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     cf2:	20200593          	li	a1,514
     cf6:	00005517          	auipc	a0,0x5
     cfa:	bda50513          	addi	a0,a0,-1062 # 58d0 <malloc+0x70c>
     cfe:	034040ef          	jal	4d32 <open>
  if(fd < 0){
     d02:	0c054f63          	bltz	a0,de0 <linktest+0x114>
     d06:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d08:	4615                	li	a2,5
     d0a:	00005597          	auipc	a1,0x5
     d0e:	b1658593          	addi	a1,a1,-1258 # 5820 <malloc+0x65c>
     d12:	000040ef          	jal	4d12 <write>
     d16:	4795                	li	a5,5
     d18:	0cf51e63          	bne	a0,a5,df4 <linktest+0x128>
  close(fd);
     d1c:	8526                	mv	a0,s1
     d1e:	7fd030ef          	jal	4d1a <close>
  if(link("lf1", "lf2") < 0){
     d22:	00005597          	auipc	a1,0x5
     d26:	bb658593          	addi	a1,a1,-1098 # 58d8 <malloc+0x714>
     d2a:	00005517          	auipc	a0,0x5
     d2e:	ba650513          	addi	a0,a0,-1114 # 58d0 <malloc+0x70c>
     d32:	020040ef          	jal	4d52 <link>
     d36:	0c054963          	bltz	a0,e08 <linktest+0x13c>
  unlink("lf1");
     d3a:	00005517          	auipc	a0,0x5
     d3e:	b9650513          	addi	a0,a0,-1130 # 58d0 <malloc+0x70c>
     d42:	000040ef          	jal	4d42 <unlink>
  if(open("lf1", 0) >= 0){
     d46:	4581                	li	a1,0
     d48:	00005517          	auipc	a0,0x5
     d4c:	b8850513          	addi	a0,a0,-1144 # 58d0 <malloc+0x70c>
     d50:	7e3030ef          	jal	4d32 <open>
     d54:	0c055463          	bgez	a0,e1c <linktest+0x150>
  fd = open("lf2", 0);
     d58:	4581                	li	a1,0
     d5a:	00005517          	auipc	a0,0x5
     d5e:	b7e50513          	addi	a0,a0,-1154 # 58d8 <malloc+0x714>
     d62:	7d1030ef          	jal	4d32 <open>
     d66:	84aa                	mv	s1,a0
  if(fd < 0){
     d68:	0c054463          	bltz	a0,e30 <linktest+0x164>
  if(read(fd, buf, sizeof(buf)) != SZ){
     d6c:	660d                	lui	a2,0x3
     d6e:	0000c597          	auipc	a1,0xc
     d72:	f0a58593          	addi	a1,a1,-246 # cc78 <buf>
     d76:	795030ef          	jal	4d0a <read>
     d7a:	4795                	li	a5,5
     d7c:	0cf51463          	bne	a0,a5,e44 <linktest+0x178>
  close(fd);
     d80:	8526                	mv	a0,s1
     d82:	799030ef          	jal	4d1a <close>
  if(link("lf2", "lf2") >= 0){
     d86:	00005597          	auipc	a1,0x5
     d8a:	b5258593          	addi	a1,a1,-1198 # 58d8 <malloc+0x714>
     d8e:	852e                	mv	a0,a1
     d90:	7c3030ef          	jal	4d52 <link>
     d94:	0c055263          	bgez	a0,e58 <linktest+0x18c>
  unlink("lf2");
     d98:	00005517          	auipc	a0,0x5
     d9c:	b4050513          	addi	a0,a0,-1216 # 58d8 <malloc+0x714>
     da0:	7a3030ef          	jal	4d42 <unlink>
  if(link("lf2", "lf1") >= 0){
     da4:	00005597          	auipc	a1,0x5
     da8:	b2c58593          	addi	a1,a1,-1236 # 58d0 <malloc+0x70c>
     dac:	00005517          	auipc	a0,0x5
     db0:	b2c50513          	addi	a0,a0,-1236 # 58d8 <malloc+0x714>
     db4:	79f030ef          	jal	4d52 <link>
     db8:	0a055a63          	bgez	a0,e6c <linktest+0x1a0>
  if(link(".", "lf1") >= 0){
     dbc:	00005597          	auipc	a1,0x5
     dc0:	b1458593          	addi	a1,a1,-1260 # 58d0 <malloc+0x70c>
     dc4:	00005517          	auipc	a0,0x5
     dc8:	c1c50513          	addi	a0,a0,-996 # 59e0 <malloc+0x81c>
     dcc:	787030ef          	jal	4d52 <link>
     dd0:	0a055863          	bgez	a0,e80 <linktest+0x1b4>
}
     dd4:	60e2                	ld	ra,24(sp)
     dd6:	6442                	ld	s0,16(sp)
     dd8:	64a2                	ld	s1,8(sp)
     dda:	6902                	ld	s2,0(sp)
     ddc:	6105                	addi	sp,sp,32
     dde:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     de0:	85ca                	mv	a1,s2
     de2:	00005517          	auipc	a0,0x5
     de6:	afe50513          	addi	a0,a0,-1282 # 58e0 <malloc+0x71c>
     dea:	322040ef          	jal	510c <printf>
    exit(1);
     dee:	4505                	li	a0,1
     df0:	703030ef          	jal	4cf2 <exit>
    printf("%s: write lf1 failed\n", s);
     df4:	85ca                	mv	a1,s2
     df6:	00005517          	auipc	a0,0x5
     dfa:	b0250513          	addi	a0,a0,-1278 # 58f8 <malloc+0x734>
     dfe:	30e040ef          	jal	510c <printf>
    exit(1);
     e02:	4505                	li	a0,1
     e04:	6ef030ef          	jal	4cf2 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     e08:	85ca                	mv	a1,s2
     e0a:	00005517          	auipc	a0,0x5
     e0e:	b0650513          	addi	a0,a0,-1274 # 5910 <malloc+0x74c>
     e12:	2fa040ef          	jal	510c <printf>
    exit(1);
     e16:	4505                	li	a0,1
     e18:	6db030ef          	jal	4cf2 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     e1c:	85ca                	mv	a1,s2
     e1e:	00005517          	auipc	a0,0x5
     e22:	b1250513          	addi	a0,a0,-1262 # 5930 <malloc+0x76c>
     e26:	2e6040ef          	jal	510c <printf>
    exit(1);
     e2a:	4505                	li	a0,1
     e2c:	6c7030ef          	jal	4cf2 <exit>
    printf("%s: open lf2 failed\n", s);
     e30:	85ca                	mv	a1,s2
     e32:	00005517          	auipc	a0,0x5
     e36:	b2e50513          	addi	a0,a0,-1234 # 5960 <malloc+0x79c>
     e3a:	2d2040ef          	jal	510c <printf>
    exit(1);
     e3e:	4505                	li	a0,1
     e40:	6b3030ef          	jal	4cf2 <exit>
    printf("%s: read lf2 failed\n", s);
     e44:	85ca                	mv	a1,s2
     e46:	00005517          	auipc	a0,0x5
     e4a:	b3250513          	addi	a0,a0,-1230 # 5978 <malloc+0x7b4>
     e4e:	2be040ef          	jal	510c <printf>
    exit(1);
     e52:	4505                	li	a0,1
     e54:	69f030ef          	jal	4cf2 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     e58:	85ca                	mv	a1,s2
     e5a:	00005517          	auipc	a0,0x5
     e5e:	b3650513          	addi	a0,a0,-1226 # 5990 <malloc+0x7cc>
     e62:	2aa040ef          	jal	510c <printf>
    exit(1);
     e66:	4505                	li	a0,1
     e68:	68b030ef          	jal	4cf2 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
     e6c:	85ca                	mv	a1,s2
     e6e:	00005517          	auipc	a0,0x5
     e72:	b4a50513          	addi	a0,a0,-1206 # 59b8 <malloc+0x7f4>
     e76:	296040ef          	jal	510c <printf>
    exit(1);
     e7a:	4505                	li	a0,1
     e7c:	677030ef          	jal	4cf2 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     e80:	85ca                	mv	a1,s2
     e82:	00005517          	auipc	a0,0x5
     e86:	b6650513          	addi	a0,a0,-1178 # 59e8 <malloc+0x824>
     e8a:	282040ef          	jal	510c <printf>
    exit(1);
     e8e:	4505                	li	a0,1
     e90:	663030ef          	jal	4cf2 <exit>

0000000000000e94 <validatetest>:
{
     e94:	7139                	addi	sp,sp,-64
     e96:	fc06                	sd	ra,56(sp)
     e98:	f822                	sd	s0,48(sp)
     e9a:	f426                	sd	s1,40(sp)
     e9c:	f04a                	sd	s2,32(sp)
     e9e:	ec4e                	sd	s3,24(sp)
     ea0:	e852                	sd	s4,16(sp)
     ea2:	e456                	sd	s5,8(sp)
     ea4:	e05a                	sd	s6,0(sp)
     ea6:	0080                	addi	s0,sp,64
     ea8:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     eaa:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
     eac:	00005997          	auipc	s3,0x5
     eb0:	b5c98993          	addi	s3,s3,-1188 # 5a08 <malloc+0x844>
     eb4:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     eb6:	6a85                	lui	s5,0x1
     eb8:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
     ebc:	85a6                	mv	a1,s1
     ebe:	854e                	mv	a0,s3
     ec0:	693030ef          	jal	4d52 <link>
     ec4:	01251f63          	bne	a0,s2,ee2 <validatetest+0x4e>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     ec8:	94d6                	add	s1,s1,s5
     eca:	ff4499e3          	bne	s1,s4,ebc <validatetest+0x28>
}
     ece:	70e2                	ld	ra,56(sp)
     ed0:	7442                	ld	s0,48(sp)
     ed2:	74a2                	ld	s1,40(sp)
     ed4:	7902                	ld	s2,32(sp)
     ed6:	69e2                	ld	s3,24(sp)
     ed8:	6a42                	ld	s4,16(sp)
     eda:	6aa2                	ld	s5,8(sp)
     edc:	6b02                	ld	s6,0(sp)
     ede:	6121                	addi	sp,sp,64
     ee0:	8082                	ret
      printf("%s: link should not succeed\n", s);
     ee2:	85da                	mv	a1,s6
     ee4:	00005517          	auipc	a0,0x5
     ee8:	b3450513          	addi	a0,a0,-1228 # 5a18 <malloc+0x854>
     eec:	220040ef          	jal	510c <printf>
      exit(1);
     ef0:	4505                	li	a0,1
     ef2:	601030ef          	jal	4cf2 <exit>

0000000000000ef6 <bigdir>:
{
     ef6:	711d                	addi	sp,sp,-96
     ef8:	ec86                	sd	ra,88(sp)
     efa:	e8a2                	sd	s0,80(sp)
     efc:	e4a6                	sd	s1,72(sp)
     efe:	e0ca                	sd	s2,64(sp)
     f00:	fc4e                	sd	s3,56(sp)
     f02:	f852                	sd	s4,48(sp)
     f04:	f456                	sd	s5,40(sp)
     f06:	f05a                	sd	s6,32(sp)
     f08:	ec5e                	sd	s7,24(sp)
     f0a:	1080                	addi	s0,sp,96
     f0c:	89aa                	mv	s3,a0
  unlink("bd");
     f0e:	00005517          	auipc	a0,0x5
     f12:	b2a50513          	addi	a0,a0,-1238 # 5a38 <malloc+0x874>
     f16:	62d030ef          	jal	4d42 <unlink>
  fd = open("bd", O_CREATE);
     f1a:	20000593          	li	a1,512
     f1e:	00005517          	auipc	a0,0x5
     f22:	b1a50513          	addi	a0,a0,-1254 # 5a38 <malloc+0x874>
     f26:	60d030ef          	jal	4d32 <open>
  if(fd < 0){
     f2a:	0c054463          	bltz	a0,ff2 <bigdir+0xfc>
  close(fd);
     f2e:	5ed030ef          	jal	4d1a <close>
  for(i = 0; i < N; i++){
     f32:	4901                	li	s2,0
    name[0] = 'x';
     f34:	07800b13          	li	s6,120
    if(link("bd", name) != 0){
     f38:	fa040a93          	addi	s5,s0,-96
     f3c:	00005a17          	auipc	s4,0x5
     f40:	afca0a13          	addi	s4,s4,-1284 # 5a38 <malloc+0x874>
  for(i = 0; i < N; i++){
     f44:	1f400b93          	li	s7,500
    name[0] = 'x';
     f48:	fb640023          	sb	s6,-96(s0)
    name[1] = '0' + (i / 64);
     f4c:	41f9571b          	sraiw	a4,s2,0x1f
     f50:	01a7571b          	srliw	a4,a4,0x1a
     f54:	012707bb          	addw	a5,a4,s2
     f58:	4067d69b          	sraiw	a3,a5,0x6
     f5c:	0306869b          	addiw	a3,a3,48
     f60:	fad400a3          	sb	a3,-95(s0)
    name[2] = '0' + (i % 64);
     f64:	03f7f793          	andi	a5,a5,63
     f68:	9f99                	subw	a5,a5,a4
     f6a:	0307879b          	addiw	a5,a5,48
     f6e:	faf40123          	sb	a5,-94(s0)
    name[3] = '\0';
     f72:	fa0401a3          	sb	zero,-93(s0)
    if(link("bd", name) != 0){
     f76:	85d6                	mv	a1,s5
     f78:	8552                	mv	a0,s4
     f7a:	5d9030ef          	jal	4d52 <link>
     f7e:	84aa                	mv	s1,a0
     f80:	e159                	bnez	a0,1006 <bigdir+0x110>
  for(i = 0; i < N; i++){
     f82:	2905                	addiw	s2,s2,1
     f84:	fd7912e3          	bne	s2,s7,f48 <bigdir+0x52>
  unlink("bd");
     f88:	00005517          	auipc	a0,0x5
     f8c:	ab050513          	addi	a0,a0,-1360 # 5a38 <malloc+0x874>
     f90:	5b3030ef          	jal	4d42 <unlink>
    name[0] = 'x';
     f94:	07800a13          	li	s4,120
    if(unlink(name) != 0){
     f98:	fa040913          	addi	s2,s0,-96
  for(i = 0; i < N; i++){
     f9c:	1f400a93          	li	s5,500
    name[0] = 'x';
     fa0:	fb440023          	sb	s4,-96(s0)
    name[1] = '0' + (i / 64);
     fa4:	41f4d71b          	sraiw	a4,s1,0x1f
     fa8:	01a7571b          	srliw	a4,a4,0x1a
     fac:	009707bb          	addw	a5,a4,s1
     fb0:	4067d69b          	sraiw	a3,a5,0x6
     fb4:	0306869b          	addiw	a3,a3,48
     fb8:	fad400a3          	sb	a3,-95(s0)
    name[2] = '0' + (i % 64);
     fbc:	03f7f793          	andi	a5,a5,63
     fc0:	9f99                	subw	a5,a5,a4
     fc2:	0307879b          	addiw	a5,a5,48
     fc6:	faf40123          	sb	a5,-94(s0)
    name[3] = '\0';
     fca:	fa0401a3          	sb	zero,-93(s0)
    if(unlink(name) != 0){
     fce:	854a                	mv	a0,s2
     fd0:	573030ef          	jal	4d42 <unlink>
     fd4:	e531                	bnez	a0,1020 <bigdir+0x12a>
  for(i = 0; i < N; i++){
     fd6:	2485                	addiw	s1,s1,1
     fd8:	fd5494e3          	bne	s1,s5,fa0 <bigdir+0xaa>
}
     fdc:	60e6                	ld	ra,88(sp)
     fde:	6446                	ld	s0,80(sp)
     fe0:	64a6                	ld	s1,72(sp)
     fe2:	6906                	ld	s2,64(sp)
     fe4:	79e2                	ld	s3,56(sp)
     fe6:	7a42                	ld	s4,48(sp)
     fe8:	7aa2                	ld	s5,40(sp)
     fea:	7b02                	ld	s6,32(sp)
     fec:	6be2                	ld	s7,24(sp)
     fee:	6125                	addi	sp,sp,96
     ff0:	8082                	ret
    printf("%s: bigdir create failed\n", s);
     ff2:	85ce                	mv	a1,s3
     ff4:	00005517          	auipc	a0,0x5
     ff8:	a4c50513          	addi	a0,a0,-1460 # 5a40 <malloc+0x87c>
     ffc:	110040ef          	jal	510c <printf>
    exit(1);
    1000:	4505                	li	a0,1
    1002:	4f1030ef          	jal	4cf2 <exit>
      printf("%s: bigdir i=%d link(bd, %s) failed\n", s, i, name);
    1006:	fa040693          	addi	a3,s0,-96
    100a:	864a                	mv	a2,s2
    100c:	85ce                	mv	a1,s3
    100e:	00005517          	auipc	a0,0x5
    1012:	a5250513          	addi	a0,a0,-1454 # 5a60 <malloc+0x89c>
    1016:	0f6040ef          	jal	510c <printf>
      exit(1);
    101a:	4505                	li	a0,1
    101c:	4d7030ef          	jal	4cf2 <exit>
      printf("%s: bigdir unlink failed", s);
    1020:	85ce                	mv	a1,s3
    1022:	00005517          	auipc	a0,0x5
    1026:	a6650513          	addi	a0,a0,-1434 # 5a88 <malloc+0x8c4>
    102a:	0e2040ef          	jal	510c <printf>
      exit(1);
    102e:	4505                	li	a0,1
    1030:	4c3030ef          	jal	4cf2 <exit>

0000000000001034 <pgbug>:
{
    1034:	7179                	addi	sp,sp,-48
    1036:	f406                	sd	ra,40(sp)
    1038:	f022                	sd	s0,32(sp)
    103a:	ec26                	sd	s1,24(sp)
    103c:	1800                	addi	s0,sp,48
  argv[0] = 0;
    103e:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1042:	00008497          	auipc	s1,0x8
    1046:	fbe48493          	addi	s1,s1,-66 # 9000 <big>
    104a:	fd840593          	addi	a1,s0,-40
    104e:	6088                	ld	a0,0(s1)
    1050:	4db030ef          	jal	4d2a <exec>
  pipe(big);
    1054:	6088                	ld	a0,0(s1)
    1056:	4ad030ef          	jal	4d02 <pipe>
  exit(0);
    105a:	4501                	li	a0,0
    105c:	497030ef          	jal	4cf2 <exit>

0000000000001060 <badarg>:
{
    1060:	7139                	addi	sp,sp,-64
    1062:	fc06                	sd	ra,56(sp)
    1064:	f822                	sd	s0,48(sp)
    1066:	f426                	sd	s1,40(sp)
    1068:	f04a                	sd	s2,32(sp)
    106a:	ec4e                	sd	s3,24(sp)
    106c:	e852                	sd	s4,16(sp)
    106e:	0080                	addi	s0,sp,64
    1070:	64b1                	lui	s1,0xc
    1072:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1de8>
    argv[0] = (char*)0xffffffff;
    1076:	597d                	li	s2,-1
    1078:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    107c:	fc040a13          	addi	s4,s0,-64
    1080:	00004997          	auipc	s3,0x4
    1084:	27898993          	addi	s3,s3,632 # 52f8 <malloc+0x134>
    argv[0] = (char*)0xffffffff;
    1088:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    108c:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1090:	85d2                	mv	a1,s4
    1092:	854e                	mv	a0,s3
    1094:	497030ef          	jal	4d2a <exec>
  for(int i = 0; i < 50000; i++){
    1098:	34fd                	addiw	s1,s1,-1
    109a:	f4fd                	bnez	s1,1088 <badarg+0x28>
  exit(0);
    109c:	4501                	li	a0,0
    109e:	455030ef          	jal	4cf2 <exit>

00000000000010a2 <copyinstr2>:
{
    10a2:	7155                	addi	sp,sp,-208
    10a4:	e586                	sd	ra,200(sp)
    10a6:	e1a2                	sd	s0,192(sp)
    10a8:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    10aa:	f6840793          	addi	a5,s0,-152
    10ae:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    10b2:	07800713          	li	a4,120
    10b6:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    10ba:	0785                	addi	a5,a5,1
    10bc:	fed79de3          	bne	a5,a3,10b6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    10c0:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    10c4:	f6840513          	addi	a0,s0,-152
    10c8:	47b030ef          	jal	4d42 <unlink>
  if(ret != -1){
    10cc:	57fd                	li	a5,-1
    10ce:	0cf51263          	bne	a0,a5,1192 <copyinstr2+0xf0>
  int fd = open(b, O_CREATE | O_WRONLY);
    10d2:	20100593          	li	a1,513
    10d6:	f6840513          	addi	a0,s0,-152
    10da:	459030ef          	jal	4d32 <open>
  if(fd != -1){
    10de:	57fd                	li	a5,-1
    10e0:	0cf51563          	bne	a0,a5,11aa <copyinstr2+0x108>
  ret = link(b, b);
    10e4:	f6840513          	addi	a0,s0,-152
    10e8:	85aa                	mv	a1,a0
    10ea:	469030ef          	jal	4d52 <link>
  if(ret != -1){
    10ee:	57fd                	li	a5,-1
    10f0:	0cf51963          	bne	a0,a5,11c2 <copyinstr2+0x120>
  char *args[] = { "xx", 0 };
    10f4:	00006797          	auipc	a5,0x6
    10f8:	c1478793          	addi	a5,a5,-1004 # 6d08 <malloc+0x1b44>
    10fc:	f4f43c23          	sd	a5,-168(s0)
    1100:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1104:	f5840593          	addi	a1,s0,-168
    1108:	f6840513          	addi	a0,s0,-152
    110c:	41f030ef          	jal	4d2a <exec>
  if(ret != -1){
    1110:	57fd                	li	a5,-1
    1112:	0cf51563          	bne	a0,a5,11dc <copyinstr2+0x13a>
  int pid = fork();
    1116:	3d5030ef          	jal	4cea <fork>
  if(pid < 0){
    111a:	0c054d63          	bltz	a0,11f4 <copyinstr2+0x152>
  if(pid == 0){
    111e:	0e051863          	bnez	a0,120e <copyinstr2+0x16c>
    1122:	00008797          	auipc	a5,0x8
    1126:	43e78793          	addi	a5,a5,1086 # 9560 <big.0>
    112a:	00009697          	auipc	a3,0x9
    112e:	43668693          	addi	a3,a3,1078 # a560 <big.0+0x1000>
      big[i] = 'x';
    1132:	07800713          	li	a4,120
    1136:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    113a:	0785                	addi	a5,a5,1
    113c:	fed79de3          	bne	a5,a3,1136 <copyinstr2+0x94>
    big[PGSIZE] = '\0';
    1140:	00009797          	auipc	a5,0x9
    1144:	42078023          	sb	zero,1056(a5) # a560 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    1148:	00006797          	auipc	a5,0x6
    114c:	5f078793          	addi	a5,a5,1520 # 7738 <malloc+0x2574>
    1150:	6fb0                	ld	a2,88(a5)
    1152:	73b4                	ld	a3,96(a5)
    1154:	77b8                	ld	a4,104(a5)
    1156:	7bbc                	ld	a5,112(a5)
    1158:	f2c43823          	sd	a2,-208(s0)
    115c:	f2d43c23          	sd	a3,-200(s0)
    1160:	f4e43023          	sd	a4,-192(s0)
    1164:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1168:	f3040593          	addi	a1,s0,-208
    116c:	00004517          	auipc	a0,0x4
    1170:	18c50513          	addi	a0,a0,396 # 52f8 <malloc+0x134>
    1174:	3b7030ef          	jal	4d2a <exec>
    if(ret != -1){
    1178:	57fd                	li	a5,-1
    117a:	08f50663          	beq	a0,a5,1206 <copyinstr2+0x164>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    117e:	85be                	mv	a1,a5
    1180:	00005517          	auipc	a0,0x5
    1184:	9b050513          	addi	a0,a0,-1616 # 5b30 <malloc+0x96c>
    1188:	785030ef          	jal	510c <printf>
      exit(1);
    118c:	4505                	li	a0,1
    118e:	365030ef          	jal	4cf2 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1192:	862a                	mv	a2,a0
    1194:	f6840593          	addi	a1,s0,-152
    1198:	00005517          	auipc	a0,0x5
    119c:	91050513          	addi	a0,a0,-1776 # 5aa8 <malloc+0x8e4>
    11a0:	76d030ef          	jal	510c <printf>
    exit(1);
    11a4:	4505                	li	a0,1
    11a6:	34d030ef          	jal	4cf2 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    11aa:	862a                	mv	a2,a0
    11ac:	f6840593          	addi	a1,s0,-152
    11b0:	00005517          	auipc	a0,0x5
    11b4:	91850513          	addi	a0,a0,-1768 # 5ac8 <malloc+0x904>
    11b8:	755030ef          	jal	510c <printf>
    exit(1);
    11bc:	4505                	li	a0,1
    11be:	335030ef          	jal	4cf2 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    11c2:	f6840593          	addi	a1,s0,-152
    11c6:	86aa                	mv	a3,a0
    11c8:	862e                	mv	a2,a1
    11ca:	00005517          	auipc	a0,0x5
    11ce:	91e50513          	addi	a0,a0,-1762 # 5ae8 <malloc+0x924>
    11d2:	73b030ef          	jal	510c <printf>
    exit(1);
    11d6:	4505                	li	a0,1
    11d8:	31b030ef          	jal	4cf2 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    11dc:	863e                	mv	a2,a5
    11de:	f6840593          	addi	a1,s0,-152
    11e2:	00005517          	auipc	a0,0x5
    11e6:	92e50513          	addi	a0,a0,-1746 # 5b10 <malloc+0x94c>
    11ea:	723030ef          	jal	510c <printf>
    exit(1);
    11ee:	4505                	li	a0,1
    11f0:	303030ef          	jal	4cf2 <exit>
    printf("fork failed\n");
    11f4:	00005517          	auipc	a0,0x5
    11f8:	d9c50513          	addi	a0,a0,-612 # 5f90 <malloc+0xdcc>
    11fc:	711030ef          	jal	510c <printf>
    exit(1);
    1200:	4505                	li	a0,1
    1202:	2f1030ef          	jal	4cf2 <exit>
    exit(747); // OK
    1206:	2eb00513          	li	a0,747
    120a:	2e9030ef          	jal	4cf2 <exit>
  int st = 0;
    120e:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1212:	f5440513          	addi	a0,s0,-172
    1216:	2e5030ef          	jal	4cfa <wait>
  if(st != 747){
    121a:	f5442703          	lw	a4,-172(s0)
    121e:	2eb00793          	li	a5,747
    1222:	00f71663          	bne	a4,a5,122e <copyinstr2+0x18c>
}
    1226:	60ae                	ld	ra,200(sp)
    1228:	640e                	ld	s0,192(sp)
    122a:	6169                	addi	sp,sp,208
    122c:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    122e:	00005517          	auipc	a0,0x5
    1232:	92a50513          	addi	a0,a0,-1750 # 5b58 <malloc+0x994>
    1236:	6d7030ef          	jal	510c <printf>
    exit(1);
    123a:	4505                	li	a0,1
    123c:	2b7030ef          	jal	4cf2 <exit>

0000000000001240 <truncate3>:
{
    1240:	7175                	addi	sp,sp,-144
    1242:	e506                	sd	ra,136(sp)
    1244:	e122                	sd	s0,128(sp)
    1246:	ecd6                	sd	s5,88(sp)
    1248:	0900                	addi	s0,sp,144
    124a:	8aaa                	mv	s5,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    124c:	60100593          	li	a1,1537
    1250:	00004517          	auipc	a0,0x4
    1254:	10050513          	addi	a0,a0,256 # 5350 <malloc+0x18c>
    1258:	2db030ef          	jal	4d32 <open>
    125c:	2bf030ef          	jal	4d1a <close>
  pid = fork();
    1260:	28b030ef          	jal	4cea <fork>
  if(pid < 0){
    1264:	06054d63          	bltz	a0,12de <truncate3+0x9e>
  if(pid == 0){
    1268:	e171                	bnez	a0,132c <truncate3+0xec>
    126a:	fca6                	sd	s1,120(sp)
    126c:	f8ca                	sd	s2,112(sp)
    126e:	f4ce                	sd	s3,104(sp)
    1270:	f0d2                	sd	s4,96(sp)
    1272:	e8da                	sd	s6,80(sp)
    1274:	e4de                	sd	s7,72(sp)
    1276:	e0e2                	sd	s8,64(sp)
    1278:	fc66                	sd	s9,56(sp)
    127a:	06400913          	li	s2,100
      int fd = open("truncfile", O_WRONLY);
    127e:	4b05                	li	s6,1
    1280:	00004997          	auipc	s3,0x4
    1284:	0d098993          	addi	s3,s3,208 # 5350 <malloc+0x18c>
      int n = write(fd, "1234567890", 10);
    1288:	4a29                	li	s4,10
    128a:	00005b97          	auipc	s7,0x5
    128e:	92eb8b93          	addi	s7,s7,-1746 # 5bb8 <malloc+0x9f4>
      read(fd, buf, sizeof(buf));
    1292:	f7840c93          	addi	s9,s0,-136
    1296:	02000c13          	li	s8,32
      int fd = open("truncfile", O_WRONLY);
    129a:	85da                	mv	a1,s6
    129c:	854e                	mv	a0,s3
    129e:	295030ef          	jal	4d32 <open>
    12a2:	84aa                	mv	s1,a0
      if(fd < 0){
    12a4:	04054f63          	bltz	a0,1302 <truncate3+0xc2>
      int n = write(fd, "1234567890", 10);
    12a8:	8652                	mv	a2,s4
    12aa:	85de                	mv	a1,s7
    12ac:	267030ef          	jal	4d12 <write>
      if(n != 10){
    12b0:	07451363          	bne	a0,s4,1316 <truncate3+0xd6>
      close(fd);
    12b4:	8526                	mv	a0,s1
    12b6:	265030ef          	jal	4d1a <close>
      fd = open("truncfile", O_RDONLY);
    12ba:	4581                	li	a1,0
    12bc:	854e                	mv	a0,s3
    12be:	275030ef          	jal	4d32 <open>
    12c2:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    12c4:	8662                	mv	a2,s8
    12c6:	85e6                	mv	a1,s9
    12c8:	243030ef          	jal	4d0a <read>
      close(fd);
    12cc:	8526                	mv	a0,s1
    12ce:	24d030ef          	jal	4d1a <close>
    for(int i = 0; i < 100; i++){
    12d2:	397d                	addiw	s2,s2,-1
    12d4:	fc0913e3          	bnez	s2,129a <truncate3+0x5a>
    exit(0);
    12d8:	4501                	li	a0,0
    12da:	219030ef          	jal	4cf2 <exit>
    12de:	fca6                	sd	s1,120(sp)
    12e0:	f8ca                	sd	s2,112(sp)
    12e2:	f4ce                	sd	s3,104(sp)
    12e4:	f0d2                	sd	s4,96(sp)
    12e6:	e8da                	sd	s6,80(sp)
    12e8:	e4de                	sd	s7,72(sp)
    12ea:	e0e2                	sd	s8,64(sp)
    12ec:	fc66                	sd	s9,56(sp)
    printf("%s: fork failed\n", s);
    12ee:	85d6                	mv	a1,s5
    12f0:	00005517          	auipc	a0,0x5
    12f4:	89850513          	addi	a0,a0,-1896 # 5b88 <malloc+0x9c4>
    12f8:	615030ef          	jal	510c <printf>
    exit(1);
    12fc:	4505                	li	a0,1
    12fe:	1f5030ef          	jal	4cf2 <exit>
        printf("%s: open failed\n", s);
    1302:	85d6                	mv	a1,s5
    1304:	00005517          	auipc	a0,0x5
    1308:	89c50513          	addi	a0,a0,-1892 # 5ba0 <malloc+0x9dc>
    130c:	601030ef          	jal	510c <printf>
        exit(1);
    1310:	4505                	li	a0,1
    1312:	1e1030ef          	jal	4cf2 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1316:	862a                	mv	a2,a0
    1318:	85d6                	mv	a1,s5
    131a:	00005517          	auipc	a0,0x5
    131e:	8ae50513          	addi	a0,a0,-1874 # 5bc8 <malloc+0xa04>
    1322:	5eb030ef          	jal	510c <printf>
        exit(1);
    1326:	4505                	li	a0,1
    1328:	1cb030ef          	jal	4cf2 <exit>
    132c:	fca6                	sd	s1,120(sp)
    132e:	f8ca                	sd	s2,112(sp)
    1330:	f4ce                	sd	s3,104(sp)
    1332:	f0d2                	sd	s4,96(sp)
    1334:	e8da                	sd	s6,80(sp)
    1336:	e4de                	sd	s7,72(sp)
    1338:	09600913          	li	s2,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    133c:	60100b13          	li	s6,1537
    1340:	00004a17          	auipc	s4,0x4
    1344:	010a0a13          	addi	s4,s4,16 # 5350 <malloc+0x18c>
    int n = write(fd, "xxx", 3);
    1348:	498d                	li	s3,3
    134a:	00005b97          	auipc	s7,0x5
    134e:	89eb8b93          	addi	s7,s7,-1890 # 5be8 <malloc+0xa24>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    1352:	85da                	mv	a1,s6
    1354:	8552                	mv	a0,s4
    1356:	1dd030ef          	jal	4d32 <open>
    135a:	84aa                	mv	s1,a0
    if(fd < 0){
    135c:	02054e63          	bltz	a0,1398 <truncate3+0x158>
    int n = write(fd, "xxx", 3);
    1360:	864e                	mv	a2,s3
    1362:	85de                	mv	a1,s7
    1364:	1af030ef          	jal	4d12 <write>
    if(n != 3){
    1368:	05351463          	bne	a0,s3,13b0 <truncate3+0x170>
    close(fd);
    136c:	8526                	mv	a0,s1
    136e:	1ad030ef          	jal	4d1a <close>
  for(int i = 0; i < 150; i++){
    1372:	397d                	addiw	s2,s2,-1
    1374:	fc091fe3          	bnez	s2,1352 <truncate3+0x112>
    1378:	e0e2                	sd	s8,64(sp)
    137a:	fc66                	sd	s9,56(sp)
  wait(&xstatus);
    137c:	f9c40513          	addi	a0,s0,-100
    1380:	17b030ef          	jal	4cfa <wait>
  unlink("truncfile");
    1384:	00004517          	auipc	a0,0x4
    1388:	fcc50513          	addi	a0,a0,-52 # 5350 <malloc+0x18c>
    138c:	1b7030ef          	jal	4d42 <unlink>
  exit(xstatus);
    1390:	f9c42503          	lw	a0,-100(s0)
    1394:	15f030ef          	jal	4cf2 <exit>
    1398:	e0e2                	sd	s8,64(sp)
    139a:	fc66                	sd	s9,56(sp)
      printf("%s: open failed\n", s);
    139c:	85d6                	mv	a1,s5
    139e:	00005517          	auipc	a0,0x5
    13a2:	80250513          	addi	a0,a0,-2046 # 5ba0 <malloc+0x9dc>
    13a6:	567030ef          	jal	510c <printf>
      exit(1);
    13aa:	4505                	li	a0,1
    13ac:	147030ef          	jal	4cf2 <exit>
    13b0:	e0e2                	sd	s8,64(sp)
    13b2:	fc66                	sd	s9,56(sp)
      printf("%s: write got %d, expected 3\n", s, n);
    13b4:	862a                	mv	a2,a0
    13b6:	85d6                	mv	a1,s5
    13b8:	00005517          	auipc	a0,0x5
    13bc:	83850513          	addi	a0,a0,-1992 # 5bf0 <malloc+0xa2c>
    13c0:	54d030ef          	jal	510c <printf>
      exit(1);
    13c4:	4505                	li	a0,1
    13c6:	12d030ef          	jal	4cf2 <exit>

00000000000013ca <exectest>:
{
    13ca:	715d                	addi	sp,sp,-80
    13cc:	e486                	sd	ra,72(sp)
    13ce:	e0a2                	sd	s0,64(sp)
    13d0:	f84a                	sd	s2,48(sp)
    13d2:	0880                	addi	s0,sp,80
    13d4:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    13d6:	00004797          	auipc	a5,0x4
    13da:	f2278793          	addi	a5,a5,-222 # 52f8 <malloc+0x134>
    13de:	fcf43023          	sd	a5,-64(s0)
    13e2:	00005797          	auipc	a5,0x5
    13e6:	82e78793          	addi	a5,a5,-2002 # 5c10 <malloc+0xa4c>
    13ea:	fcf43423          	sd	a5,-56(s0)
    13ee:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    13f2:	00005517          	auipc	a0,0x5
    13f6:	82650513          	addi	a0,a0,-2010 # 5c18 <malloc+0xa54>
    13fa:	149030ef          	jal	4d42 <unlink>
  pid = fork();
    13fe:	0ed030ef          	jal	4cea <fork>
  if(pid < 0) {
    1402:	02054f63          	bltz	a0,1440 <exectest+0x76>
    1406:	fc26                	sd	s1,56(sp)
    1408:	84aa                	mv	s1,a0
  if(pid == 0) {
    140a:	e935                	bnez	a0,147e <exectest+0xb4>
    close(1);
    140c:	4505                	li	a0,1
    140e:	10d030ef          	jal	4d1a <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1412:	20100593          	li	a1,513
    1416:	00005517          	auipc	a0,0x5
    141a:	80250513          	addi	a0,a0,-2046 # 5c18 <malloc+0xa54>
    141e:	115030ef          	jal	4d32 <open>
    if(fd < 0) {
    1422:	02054a63          	bltz	a0,1456 <exectest+0x8c>
    if(fd != 1) {
    1426:	4785                	li	a5,1
    1428:	04f50163          	beq	a0,a5,146a <exectest+0xa0>
      printf("%s: wrong fd\n", s);
    142c:	85ca                	mv	a1,s2
    142e:	00005517          	auipc	a0,0x5
    1432:	80a50513          	addi	a0,a0,-2038 # 5c38 <malloc+0xa74>
    1436:	4d7030ef          	jal	510c <printf>
      exit(1);
    143a:	4505                	li	a0,1
    143c:	0b7030ef          	jal	4cf2 <exit>
    1440:	fc26                	sd	s1,56(sp)
     printf("%s: fork failed\n", s);
    1442:	85ca                	mv	a1,s2
    1444:	00004517          	auipc	a0,0x4
    1448:	74450513          	addi	a0,a0,1860 # 5b88 <malloc+0x9c4>
    144c:	4c1030ef          	jal	510c <printf>
     exit(1);
    1450:	4505                	li	a0,1
    1452:	0a1030ef          	jal	4cf2 <exit>
      printf("%s: create failed\n", s);
    1456:	85ca                	mv	a1,s2
    1458:	00004517          	auipc	a0,0x4
    145c:	7c850513          	addi	a0,a0,1992 # 5c20 <malloc+0xa5c>
    1460:	4ad030ef          	jal	510c <printf>
      exit(1);
    1464:	4505                	li	a0,1
    1466:	08d030ef          	jal	4cf2 <exit>
    if(exec("echo", echoargv) < 0){
    146a:	fc040593          	addi	a1,s0,-64
    146e:	00004517          	auipc	a0,0x4
    1472:	e8a50513          	addi	a0,a0,-374 # 52f8 <malloc+0x134>
    1476:	0b5030ef          	jal	4d2a <exec>
    147a:	00054d63          	bltz	a0,1494 <exectest+0xca>
  if (wait(&xstatus) != pid) {
    147e:	fdc40513          	addi	a0,s0,-36
    1482:	079030ef          	jal	4cfa <wait>
    1486:	02951163          	bne	a0,s1,14a8 <exectest+0xde>
  if(xstatus != 0)
    148a:	fdc42503          	lw	a0,-36(s0)
    148e:	c50d                	beqz	a0,14b8 <exectest+0xee>
    exit(xstatus);
    1490:	063030ef          	jal	4cf2 <exit>
      printf("%s: exec echo failed\n", s);
    1494:	85ca                	mv	a1,s2
    1496:	00004517          	auipc	a0,0x4
    149a:	7b250513          	addi	a0,a0,1970 # 5c48 <malloc+0xa84>
    149e:	46f030ef          	jal	510c <printf>
      exit(1);
    14a2:	4505                	li	a0,1
    14a4:	04f030ef          	jal	4cf2 <exit>
    printf("%s: wait failed!\n", s);
    14a8:	85ca                	mv	a1,s2
    14aa:	00004517          	auipc	a0,0x4
    14ae:	7b650513          	addi	a0,a0,1974 # 5c60 <malloc+0xa9c>
    14b2:	45b030ef          	jal	510c <printf>
    14b6:	bfd1                	j	148a <exectest+0xc0>
  fd = open("echo-ok", O_RDONLY);
    14b8:	4581                	li	a1,0
    14ba:	00004517          	auipc	a0,0x4
    14be:	75e50513          	addi	a0,a0,1886 # 5c18 <malloc+0xa54>
    14c2:	071030ef          	jal	4d32 <open>
  if(fd < 0) {
    14c6:	02054463          	bltz	a0,14ee <exectest+0x124>
  if (read(fd, buf, 2) != 2) {
    14ca:	4609                	li	a2,2
    14cc:	fb840593          	addi	a1,s0,-72
    14d0:	03b030ef          	jal	4d0a <read>
    14d4:	4789                	li	a5,2
    14d6:	02f50663          	beq	a0,a5,1502 <exectest+0x138>
    printf("%s: read failed\n", s);
    14da:	85ca                	mv	a1,s2
    14dc:	00004517          	auipc	a0,0x4
    14e0:	1ec50513          	addi	a0,a0,492 # 56c8 <malloc+0x504>
    14e4:	429030ef          	jal	510c <printf>
    exit(1);
    14e8:	4505                	li	a0,1
    14ea:	009030ef          	jal	4cf2 <exit>
    printf("%s: open failed\n", s);
    14ee:	85ca                	mv	a1,s2
    14f0:	00004517          	auipc	a0,0x4
    14f4:	6b050513          	addi	a0,a0,1712 # 5ba0 <malloc+0x9dc>
    14f8:	415030ef          	jal	510c <printf>
    exit(1);
    14fc:	4505                	li	a0,1
    14fe:	7f4030ef          	jal	4cf2 <exit>
  unlink("echo-ok");
    1502:	00004517          	auipc	a0,0x4
    1506:	71650513          	addi	a0,a0,1814 # 5c18 <malloc+0xa54>
    150a:	039030ef          	jal	4d42 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    150e:	fb844703          	lbu	a4,-72(s0)
    1512:	04f00793          	li	a5,79
    1516:	00f71863          	bne	a4,a5,1526 <exectest+0x15c>
    151a:	fb944703          	lbu	a4,-71(s0)
    151e:	04b00793          	li	a5,75
    1522:	00f70c63          	beq	a4,a5,153a <exectest+0x170>
    printf("%s: wrong output\n", s);
    1526:	85ca                	mv	a1,s2
    1528:	00004517          	auipc	a0,0x4
    152c:	75050513          	addi	a0,a0,1872 # 5c78 <malloc+0xab4>
    1530:	3dd030ef          	jal	510c <printf>
    exit(1);
    1534:	4505                	li	a0,1
    1536:	7bc030ef          	jal	4cf2 <exit>
    exit(0);
    153a:	4501                	li	a0,0
    153c:	7b6030ef          	jal	4cf2 <exit>

0000000000001540 <pipe1>:
{
    1540:	711d                	addi	sp,sp,-96
    1542:	ec86                	sd	ra,88(sp)
    1544:	e8a2                	sd	s0,80(sp)
    1546:	e0ca                	sd	s2,64(sp)
    1548:	1080                	addi	s0,sp,96
    154a:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    154c:	fa840513          	addi	a0,s0,-88
    1550:	7b2030ef          	jal	4d02 <pipe>
    1554:	e53d                	bnez	a0,15c2 <pipe1+0x82>
    1556:	e4a6                	sd	s1,72(sp)
    1558:	f852                	sd	s4,48(sp)
    155a:	84aa                	mv	s1,a0
  pid = fork();
    155c:	78e030ef          	jal	4cea <fork>
    1560:	8a2a                	mv	s4,a0
  if(pid == 0){
    1562:	c149                	beqz	a0,15e4 <pipe1+0xa4>
  } else if(pid > 0){
    1564:	14a05f63          	blez	a0,16c2 <pipe1+0x182>
    1568:	fc4e                	sd	s3,56(sp)
    156a:	f456                	sd	s5,40(sp)
    close(fds[1]);
    156c:	fac42503          	lw	a0,-84(s0)
    1570:	7aa030ef          	jal	4d1a <close>
    total = 0;
    1574:	8a26                	mv	s4,s1
    cc = 1;
    1576:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1578:	0000ba97          	auipc	s5,0xb
    157c:	700a8a93          	addi	s5,s5,1792 # cc78 <buf>
    1580:	864e                	mv	a2,s3
    1582:	85d6                	mv	a1,s5
    1584:	fa842503          	lw	a0,-88(s0)
    1588:	782030ef          	jal	4d0a <read>
    158c:	0ea05963          	blez	a0,167e <pipe1+0x13e>
    1590:	0000b717          	auipc	a4,0xb
    1594:	6e870713          	addi	a4,a4,1768 # cc78 <buf>
    1598:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    159c:	00074683          	lbu	a3,0(a4)
    15a0:	0ff4f793          	zext.b	a5,s1
    15a4:	2485                	addiw	s1,s1,1
    15a6:	0af69c63          	bne	a3,a5,165e <pipe1+0x11e>
      for(i = 0; i < n; i++){
    15aa:	0705                	addi	a4,a4,1
    15ac:	fec498e3          	bne	s1,a2,159c <pipe1+0x5c>
      total += n;
    15b0:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    15b4:	0019999b          	slliw	s3,s3,0x1
      if(cc > sizeof(buf))
    15b8:	678d                	lui	a5,0x3
    15ba:	fd37f3e3          	bgeu	a5,s3,1580 <pipe1+0x40>
        cc = sizeof(buf);
    15be:	89be                	mv	s3,a5
    15c0:	b7c1                	j	1580 <pipe1+0x40>
    15c2:	e4a6                	sd	s1,72(sp)
    15c4:	fc4e                	sd	s3,56(sp)
    15c6:	f852                	sd	s4,48(sp)
    15c8:	f456                	sd	s5,40(sp)
    15ca:	f05a                	sd	s6,32(sp)
    15cc:	ec5e                	sd	s7,24(sp)
    15ce:	e862                	sd	s8,16(sp)
    printf("%s: pipe() failed\n", s);
    15d0:	85ca                	mv	a1,s2
    15d2:	00004517          	auipc	a0,0x4
    15d6:	6be50513          	addi	a0,a0,1726 # 5c90 <malloc+0xacc>
    15da:	333030ef          	jal	510c <printf>
    exit(1);
    15de:	4505                	li	a0,1
    15e0:	712030ef          	jal	4cf2 <exit>
    15e4:	fc4e                	sd	s3,56(sp)
    15e6:	f456                	sd	s5,40(sp)
    15e8:	f05a                	sd	s6,32(sp)
    15ea:	ec5e                	sd	s7,24(sp)
    15ec:	e862                	sd	s8,16(sp)
    close(fds[0]);
    15ee:	fa842503          	lw	a0,-88(s0)
    15f2:	728030ef          	jal	4d1a <close>
    for(n = 0; n < N; n++){
    15f6:	0000bb97          	auipc	s7,0xb
    15fa:	682b8b93          	addi	s7,s7,1666 # cc78 <buf>
    15fe:	417004bb          	negw	s1,s7
    1602:	0ff4f493          	zext.b	s1,s1
    1606:	409b8993          	addi	s3,s7,1033
      if(write(fds[1], buf, SZ) != SZ){
    160a:	40900a93          	li	s5,1033
    160e:	8c5e                	mv	s8,s7
    for(n = 0; n < N; n++){
    1610:	6b05                	lui	s6,0x1
    1612:	42db0b13          	addi	s6,s6,1069 # 142d <exectest+0x63>
{
    1616:	87de                	mv	a5,s7
        buf[i] = seq++;
    1618:	0097873b          	addw	a4,a5,s1
    161c:	00e78023          	sb	a4,0(a5) # 3000 <subdir+0x236>
      for(i = 0; i < SZ; i++)
    1620:	0785                	addi	a5,a5,1
    1622:	ff379be3          	bne	a5,s3,1618 <pipe1+0xd8>
    1626:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    162a:	8656                	mv	a2,s5
    162c:	85e2                	mv	a1,s8
    162e:	fac42503          	lw	a0,-84(s0)
    1632:	6e0030ef          	jal	4d12 <write>
    1636:	01551a63          	bne	a0,s5,164a <pipe1+0x10a>
    for(n = 0; n < N; n++){
    163a:	24a5                	addiw	s1,s1,9
    163c:	0ff4f493          	zext.b	s1,s1
    1640:	fd6a1be3          	bne	s4,s6,1616 <pipe1+0xd6>
    exit(0);
    1644:	4501                	li	a0,0
    1646:	6ac030ef          	jal	4cf2 <exit>
        printf("%s: pipe1 oops 1\n", s);
    164a:	85ca                	mv	a1,s2
    164c:	00004517          	auipc	a0,0x4
    1650:	65c50513          	addi	a0,a0,1628 # 5ca8 <malloc+0xae4>
    1654:	2b9030ef          	jal	510c <printf>
        exit(1);
    1658:	4505                	li	a0,1
    165a:	698030ef          	jal	4cf2 <exit>
          printf("%s: pipe1 oops 2\n", s);
    165e:	85ca                	mv	a1,s2
    1660:	00004517          	auipc	a0,0x4
    1664:	66050513          	addi	a0,a0,1632 # 5cc0 <malloc+0xafc>
    1668:	2a5030ef          	jal	510c <printf>
          return;
    166c:	64a6                	ld	s1,72(sp)
    166e:	79e2                	ld	s3,56(sp)
    1670:	7a42                	ld	s4,48(sp)
    1672:	7aa2                	ld	s5,40(sp)
}
    1674:	60e6                	ld	ra,88(sp)
    1676:	6446                	ld	s0,80(sp)
    1678:	6906                	ld	s2,64(sp)
    167a:	6125                	addi	sp,sp,96
    167c:	8082                	ret
    if(total != N * SZ){
    167e:	6785                	lui	a5,0x1
    1680:	42d78793          	addi	a5,a5,1069 # 142d <exectest+0x63>
    1684:	02fa0063          	beq	s4,a5,16a4 <pipe1+0x164>
    1688:	f05a                	sd	s6,32(sp)
    168a:	ec5e                	sd	s7,24(sp)
    168c:	e862                	sd	s8,16(sp)
      printf("%s: pipe1 oops 3 total %d\n", s, total);
    168e:	8652                	mv	a2,s4
    1690:	85ca                	mv	a1,s2
    1692:	00004517          	auipc	a0,0x4
    1696:	64650513          	addi	a0,a0,1606 # 5cd8 <malloc+0xb14>
    169a:	273030ef          	jal	510c <printf>
      exit(1);
    169e:	4505                	li	a0,1
    16a0:	652030ef          	jal	4cf2 <exit>
    16a4:	f05a                	sd	s6,32(sp)
    16a6:	ec5e                	sd	s7,24(sp)
    16a8:	e862                	sd	s8,16(sp)
    close(fds[0]);
    16aa:	fa842503          	lw	a0,-88(s0)
    16ae:	66c030ef          	jal	4d1a <close>
    wait(&xstatus);
    16b2:	fa440513          	addi	a0,s0,-92
    16b6:	644030ef          	jal	4cfa <wait>
    exit(xstatus);
    16ba:	fa442503          	lw	a0,-92(s0)
    16be:	634030ef          	jal	4cf2 <exit>
    16c2:	fc4e                	sd	s3,56(sp)
    16c4:	f456                	sd	s5,40(sp)
    16c6:	f05a                	sd	s6,32(sp)
    16c8:	ec5e                	sd	s7,24(sp)
    16ca:	e862                	sd	s8,16(sp)
    printf("%s: fork() failed\n", s);
    16cc:	85ca                	mv	a1,s2
    16ce:	00004517          	auipc	a0,0x4
    16d2:	62a50513          	addi	a0,a0,1578 # 5cf8 <malloc+0xb34>
    16d6:	237030ef          	jal	510c <printf>
    exit(1);
    16da:	4505                	li	a0,1
    16dc:	616030ef          	jal	4cf2 <exit>

00000000000016e0 <exitwait>:
{
    16e0:	715d                	addi	sp,sp,-80
    16e2:	e486                	sd	ra,72(sp)
    16e4:	e0a2                	sd	s0,64(sp)
    16e6:	fc26                	sd	s1,56(sp)
    16e8:	f84a                	sd	s2,48(sp)
    16ea:	f44e                	sd	s3,40(sp)
    16ec:	f052                	sd	s4,32(sp)
    16ee:	ec56                	sd	s5,24(sp)
    16f0:	0880                	addi	s0,sp,80
    16f2:	8aaa                	mv	s5,a0
  for(i = 0; i < 100; i++){
    16f4:	4901                	li	s2,0
      if(wait(&xstate) != pid){
    16f6:	fbc40993          	addi	s3,s0,-68
  for(i = 0; i < 100; i++){
    16fa:	06400a13          	li	s4,100
    pid = fork();
    16fe:	5ec030ef          	jal	4cea <fork>
    1702:	84aa                	mv	s1,a0
    if(pid < 0){
    1704:	02054863          	bltz	a0,1734 <exitwait+0x54>
    if(pid){
    1708:	c525                	beqz	a0,1770 <exitwait+0x90>
      if(wait(&xstate) != pid){
    170a:	854e                	mv	a0,s3
    170c:	5ee030ef          	jal	4cfa <wait>
    1710:	02951c63          	bne	a0,s1,1748 <exitwait+0x68>
      if(i != xstate) {
    1714:	fbc42783          	lw	a5,-68(s0)
    1718:	05279263          	bne	a5,s2,175c <exitwait+0x7c>
  for(i = 0; i < 100; i++){
    171c:	2905                	addiw	s2,s2,1
    171e:	ff4910e3          	bne	s2,s4,16fe <exitwait+0x1e>
}
    1722:	60a6                	ld	ra,72(sp)
    1724:	6406                	ld	s0,64(sp)
    1726:	74e2                	ld	s1,56(sp)
    1728:	7942                	ld	s2,48(sp)
    172a:	79a2                	ld	s3,40(sp)
    172c:	7a02                	ld	s4,32(sp)
    172e:	6ae2                	ld	s5,24(sp)
    1730:	6161                	addi	sp,sp,80
    1732:	8082                	ret
      printf("%s: fork failed\n", s);
    1734:	85d6                	mv	a1,s5
    1736:	00004517          	auipc	a0,0x4
    173a:	45250513          	addi	a0,a0,1106 # 5b88 <malloc+0x9c4>
    173e:	1cf030ef          	jal	510c <printf>
      exit(1);
    1742:	4505                	li	a0,1
    1744:	5ae030ef          	jal	4cf2 <exit>
        printf("%s: wait wrong pid\n", s);
    1748:	85d6                	mv	a1,s5
    174a:	00004517          	auipc	a0,0x4
    174e:	5c650513          	addi	a0,a0,1478 # 5d10 <malloc+0xb4c>
    1752:	1bb030ef          	jal	510c <printf>
        exit(1);
    1756:	4505                	li	a0,1
    1758:	59a030ef          	jal	4cf2 <exit>
        printf("%s: wait wrong exit status\n", s);
    175c:	85d6                	mv	a1,s5
    175e:	00004517          	auipc	a0,0x4
    1762:	5ca50513          	addi	a0,a0,1482 # 5d28 <malloc+0xb64>
    1766:	1a7030ef          	jal	510c <printf>
        exit(1);
    176a:	4505                	li	a0,1
    176c:	586030ef          	jal	4cf2 <exit>
      exit(i);
    1770:	854a                	mv	a0,s2
    1772:	580030ef          	jal	4cf2 <exit>

0000000000001776 <twochildren>:
{
    1776:	1101                	addi	sp,sp,-32
    1778:	ec06                	sd	ra,24(sp)
    177a:	e822                	sd	s0,16(sp)
    177c:	e426                	sd	s1,8(sp)
    177e:	e04a                	sd	s2,0(sp)
    1780:	1000                	addi	s0,sp,32
    1782:	892a                	mv	s2,a0
    1784:	3e800493          	li	s1,1000
    int pid1 = fork();
    1788:	562030ef          	jal	4cea <fork>
    if(pid1 < 0){
    178c:	02054663          	bltz	a0,17b8 <twochildren+0x42>
    if(pid1 == 0){
    1790:	cd15                	beqz	a0,17cc <twochildren+0x56>
      int pid2 = fork();
    1792:	558030ef          	jal	4cea <fork>
      if(pid2 < 0){
    1796:	02054d63          	bltz	a0,17d0 <twochildren+0x5a>
      if(pid2 == 0){
    179a:	c529                	beqz	a0,17e4 <twochildren+0x6e>
        wait(0);
    179c:	4501                	li	a0,0
    179e:	55c030ef          	jal	4cfa <wait>
        wait(0);
    17a2:	4501                	li	a0,0
    17a4:	556030ef          	jal	4cfa <wait>
  for(int i = 0; i < 1000; i++){
    17a8:	34fd                	addiw	s1,s1,-1
    17aa:	fcf9                	bnez	s1,1788 <twochildren+0x12>
}
    17ac:	60e2                	ld	ra,24(sp)
    17ae:	6442                	ld	s0,16(sp)
    17b0:	64a2                	ld	s1,8(sp)
    17b2:	6902                	ld	s2,0(sp)
    17b4:	6105                	addi	sp,sp,32
    17b6:	8082                	ret
      printf("%s: fork failed\n", s);
    17b8:	85ca                	mv	a1,s2
    17ba:	00004517          	auipc	a0,0x4
    17be:	3ce50513          	addi	a0,a0,974 # 5b88 <malloc+0x9c4>
    17c2:	14b030ef          	jal	510c <printf>
      exit(1);
    17c6:	4505                	li	a0,1
    17c8:	52a030ef          	jal	4cf2 <exit>
      exit(0);
    17cc:	526030ef          	jal	4cf2 <exit>
        printf("%s: fork failed\n", s);
    17d0:	85ca                	mv	a1,s2
    17d2:	00004517          	auipc	a0,0x4
    17d6:	3b650513          	addi	a0,a0,950 # 5b88 <malloc+0x9c4>
    17da:	133030ef          	jal	510c <printf>
        exit(1);
    17de:	4505                	li	a0,1
    17e0:	512030ef          	jal	4cf2 <exit>
        exit(0);
    17e4:	50e030ef          	jal	4cf2 <exit>

00000000000017e8 <forkfork>:
{
    17e8:	7179                	addi	sp,sp,-48
    17ea:	f406                	sd	ra,40(sp)
    17ec:	f022                	sd	s0,32(sp)
    17ee:	ec26                	sd	s1,24(sp)
    17f0:	1800                	addi	s0,sp,48
    17f2:	84aa                	mv	s1,a0
    int pid = fork();
    17f4:	4f6030ef          	jal	4cea <fork>
    if(pid < 0){
    17f8:	02054b63          	bltz	a0,182e <forkfork+0x46>
    if(pid == 0){
    17fc:	c139                	beqz	a0,1842 <forkfork+0x5a>
    int pid = fork();
    17fe:	4ec030ef          	jal	4cea <fork>
    if(pid < 0){
    1802:	02054663          	bltz	a0,182e <forkfork+0x46>
    if(pid == 0){
    1806:	cd15                	beqz	a0,1842 <forkfork+0x5a>
    wait(&xstatus);
    1808:	fdc40513          	addi	a0,s0,-36
    180c:	4ee030ef          	jal	4cfa <wait>
    if(xstatus != 0) {
    1810:	fdc42783          	lw	a5,-36(s0)
    1814:	ebb9                	bnez	a5,186a <forkfork+0x82>
    wait(&xstatus);
    1816:	fdc40513          	addi	a0,s0,-36
    181a:	4e0030ef          	jal	4cfa <wait>
    if(xstatus != 0) {
    181e:	fdc42783          	lw	a5,-36(s0)
    1822:	e7a1                	bnez	a5,186a <forkfork+0x82>
}
    1824:	70a2                	ld	ra,40(sp)
    1826:	7402                	ld	s0,32(sp)
    1828:	64e2                	ld	s1,24(sp)
    182a:	6145                	addi	sp,sp,48
    182c:	8082                	ret
      printf("%s: fork failed", s);
    182e:	85a6                	mv	a1,s1
    1830:	00004517          	auipc	a0,0x4
    1834:	51850513          	addi	a0,a0,1304 # 5d48 <malloc+0xb84>
    1838:	0d5030ef          	jal	510c <printf>
      exit(1);
    183c:	4505                	li	a0,1
    183e:	4b4030ef          	jal	4cf2 <exit>
{
    1842:	0c800493          	li	s1,200
        int pid1 = fork();
    1846:	4a4030ef          	jal	4cea <fork>
        if(pid1 < 0){
    184a:	00054b63          	bltz	a0,1860 <forkfork+0x78>
        if(pid1 == 0){
    184e:	cd01                	beqz	a0,1866 <forkfork+0x7e>
        wait(0);
    1850:	4501                	li	a0,0
    1852:	4a8030ef          	jal	4cfa <wait>
      for(int j = 0; j < 200; j++){
    1856:	34fd                	addiw	s1,s1,-1
    1858:	f4fd                	bnez	s1,1846 <forkfork+0x5e>
      exit(0);
    185a:	4501                	li	a0,0
    185c:	496030ef          	jal	4cf2 <exit>
          exit(1);
    1860:	4505                	li	a0,1
    1862:	490030ef          	jal	4cf2 <exit>
          exit(0);
    1866:	48c030ef          	jal	4cf2 <exit>
      printf("%s: fork in child failed", s);
    186a:	85a6                	mv	a1,s1
    186c:	00004517          	auipc	a0,0x4
    1870:	4ec50513          	addi	a0,a0,1260 # 5d58 <malloc+0xb94>
    1874:	099030ef          	jal	510c <printf>
      exit(1);
    1878:	4505                	li	a0,1
    187a:	478030ef          	jal	4cf2 <exit>

000000000000187e <reparent2>:
{
    187e:	1101                	addi	sp,sp,-32
    1880:	ec06                	sd	ra,24(sp)
    1882:	e822                	sd	s0,16(sp)
    1884:	e426                	sd	s1,8(sp)
    1886:	1000                	addi	s0,sp,32
    1888:	32000493          	li	s1,800
    int pid1 = fork();
    188c:	45e030ef          	jal	4cea <fork>
    if(pid1 < 0){
    1890:	00054b63          	bltz	a0,18a6 <reparent2+0x28>
    if(pid1 == 0){
    1894:	c115                	beqz	a0,18b8 <reparent2+0x3a>
    wait(0);
    1896:	4501                	li	a0,0
    1898:	462030ef          	jal	4cfa <wait>
  for(int i = 0; i < 800; i++){
    189c:	34fd                	addiw	s1,s1,-1
    189e:	f4fd                	bnez	s1,188c <reparent2+0xe>
  exit(0);
    18a0:	4501                	li	a0,0
    18a2:	450030ef          	jal	4cf2 <exit>
      printf("fork failed\n");
    18a6:	00004517          	auipc	a0,0x4
    18aa:	6ea50513          	addi	a0,a0,1770 # 5f90 <malloc+0xdcc>
    18ae:	05f030ef          	jal	510c <printf>
      exit(1);
    18b2:	4505                	li	a0,1
    18b4:	43e030ef          	jal	4cf2 <exit>
      fork();
    18b8:	432030ef          	jal	4cea <fork>
      fork();
    18bc:	42e030ef          	jal	4cea <fork>
      exit(0);
    18c0:	4501                	li	a0,0
    18c2:	430030ef          	jal	4cf2 <exit>

00000000000018c6 <createdelete>:
{
    18c6:	7175                	addi	sp,sp,-144
    18c8:	e506                	sd	ra,136(sp)
    18ca:	e122                	sd	s0,128(sp)
    18cc:	fca6                	sd	s1,120(sp)
    18ce:	f8ca                	sd	s2,112(sp)
    18d0:	f4ce                	sd	s3,104(sp)
    18d2:	f0d2                	sd	s4,96(sp)
    18d4:	ecd6                	sd	s5,88(sp)
    18d6:	e8da                	sd	s6,80(sp)
    18d8:	e4de                	sd	s7,72(sp)
    18da:	e0e2                	sd	s8,64(sp)
    18dc:	fc66                	sd	s9,56(sp)
    18de:	f86a                	sd	s10,48(sp)
    18e0:	0900                	addi	s0,sp,144
    18e2:	8d2a                	mv	s10,a0
  for(pi = 0; pi < NCHILD; pi++){
    18e4:	4901                	li	s2,0
    18e6:	4991                	li	s3,4
    pid = fork();
    18e8:	402030ef          	jal	4cea <fork>
    18ec:	84aa                	mv	s1,a0
    if(pid < 0){
    18ee:	02054e63          	bltz	a0,192a <createdelete+0x64>
    if(pid == 0){
    18f2:	c531                	beqz	a0,193e <createdelete+0x78>
  for(pi = 0; pi < NCHILD; pi++){
    18f4:	2905                	addiw	s2,s2,1
    18f6:	ff3919e3          	bne	s2,s3,18e8 <createdelete+0x22>
    18fa:	4491                	li	s1,4
    wait(&xstatus);
    18fc:	f7c40993          	addi	s3,s0,-132
    1900:	854e                	mv	a0,s3
    1902:	3f8030ef          	jal	4cfa <wait>
    if(xstatus != 0)
    1906:	f7c42903          	lw	s2,-132(s0)
    190a:	0c091063          	bnez	s2,19ca <createdelete+0x104>
  for(pi = 0; pi < NCHILD; pi++){
    190e:	34fd                	addiw	s1,s1,-1
    1910:	f8e5                	bnez	s1,1900 <createdelete+0x3a>
  name[0] = name[1] = name[2] = 0;
    1912:	f8040123          	sb	zero,-126(s0)
    1916:	03000993          	li	s3,48
    191a:	5afd                	li	s5,-1
    191c:	07000c93          	li	s9,112
      if((i == 0 || i >= N/2) && fd < 0){
    1920:	4ba5                	li	s7,9
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1922:	4c21                	li	s8,8
    for(pi = 0; pi < NCHILD; pi++){
    1924:	07400b13          	li	s6,116
    1928:	a205                	j	1a48 <createdelete+0x182>
      printf("%s: fork failed\n", s);
    192a:	85ea                	mv	a1,s10
    192c:	00004517          	auipc	a0,0x4
    1930:	25c50513          	addi	a0,a0,604 # 5b88 <malloc+0x9c4>
    1934:	7d8030ef          	jal	510c <printf>
      exit(1);
    1938:	4505                	li	a0,1
    193a:	3b8030ef          	jal	4cf2 <exit>
      name[0] = 'p' + pi;
    193e:	0709091b          	addiw	s2,s2,112
    1942:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1946:	f8040123          	sb	zero,-126(s0)
        fd = open(name, O_CREATE | O_RDWR);
    194a:	f8040913          	addi	s2,s0,-128
    194e:	20200993          	li	s3,514
      for(i = 0; i < N; i++){
    1952:	4a51                	li	s4,20
    1954:	a815                	j	1988 <createdelete+0xc2>
          printf("%s: create failed\n", s);
    1956:	85ea                	mv	a1,s10
    1958:	00004517          	auipc	a0,0x4
    195c:	2c850513          	addi	a0,a0,712 # 5c20 <malloc+0xa5c>
    1960:	7ac030ef          	jal	510c <printf>
          exit(1);
    1964:	4505                	li	a0,1
    1966:	38c030ef          	jal	4cf2 <exit>
          name[1] = '0' + (i / 2);
    196a:	01f4d79b          	srliw	a5,s1,0x1f
    196e:	9fa5                	addw	a5,a5,s1
    1970:	4017d79b          	sraiw	a5,a5,0x1
    1974:	0307879b          	addiw	a5,a5,48
    1978:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    197c:	854a                	mv	a0,s2
    197e:	3c4030ef          	jal	4d42 <unlink>
    1982:	02054a63          	bltz	a0,19b6 <createdelete+0xf0>
      for(i = 0; i < N; i++){
    1986:	2485                	addiw	s1,s1,1
        name[1] = '0' + i;
    1988:	0304879b          	addiw	a5,s1,48
    198c:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1990:	85ce                	mv	a1,s3
    1992:	854a                	mv	a0,s2
    1994:	39e030ef          	jal	4d32 <open>
        if(fd < 0){
    1998:	fa054fe3          	bltz	a0,1956 <createdelete+0x90>
        close(fd);
    199c:	37e030ef          	jal	4d1a <close>
        if(i > 0 && (i % 2 ) == 0){
    19a0:	fe9053e3          	blez	s1,1986 <createdelete+0xc0>
    19a4:	0014f793          	andi	a5,s1,1
    19a8:	d3e9                	beqz	a5,196a <createdelete+0xa4>
      for(i = 0; i < N; i++){
    19aa:	2485                	addiw	s1,s1,1
    19ac:	fd449ee3          	bne	s1,s4,1988 <createdelete+0xc2>
      exit(0);
    19b0:	4501                	li	a0,0
    19b2:	340030ef          	jal	4cf2 <exit>
            printf("%s: unlink failed\n", s);
    19b6:	85ea                	mv	a1,s10
    19b8:	00004517          	auipc	a0,0x4
    19bc:	3c050513          	addi	a0,a0,960 # 5d78 <malloc+0xbb4>
    19c0:	74c030ef          	jal	510c <printf>
            exit(1);
    19c4:	4505                	li	a0,1
    19c6:	32c030ef          	jal	4cf2 <exit>
      exit(1);
    19ca:	4505                	li	a0,1
    19cc:	326030ef          	jal	4cf2 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    19d0:	f8040613          	addi	a2,s0,-128
    19d4:	85ea                	mv	a1,s10
    19d6:	00004517          	auipc	a0,0x4
    19da:	3ba50513          	addi	a0,a0,954 # 5d90 <malloc+0xbcc>
    19de:	72e030ef          	jal	510c <printf>
        exit(1);
    19e2:	4505                	li	a0,1
    19e4:	30e030ef          	jal	4cf2 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    19e8:	035c7a63          	bgeu	s8,s5,1a1c <createdelete+0x156>
      if(fd >= 0)
    19ec:	02055563          	bgez	a0,1a16 <createdelete+0x150>
    for(pi = 0; pi < NCHILD; pi++){
    19f0:	2485                	addiw	s1,s1,1
    19f2:	0ff4f493          	zext.b	s1,s1
    19f6:	05648163          	beq	s1,s6,1a38 <createdelete+0x172>
      name[0] = 'p' + pi;
    19fa:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    19fe:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1a02:	4581                	li	a1,0
    1a04:	8552                	mv	a0,s4
    1a06:	32c030ef          	jal	4d32 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1a0a:	00090463          	beqz	s2,1a12 <createdelete+0x14c>
    1a0e:	fd2bdde3          	bge	s7,s2,19e8 <createdelete+0x122>
    1a12:	fa054fe3          	bltz	a0,19d0 <createdelete+0x10a>
        close(fd);
    1a16:	304030ef          	jal	4d1a <close>
    1a1a:	bfd9                	j	19f0 <createdelete+0x12a>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1a1c:	fc054ae3          	bltz	a0,19f0 <createdelete+0x12a>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1a20:	f8040613          	addi	a2,s0,-128
    1a24:	85ea                	mv	a1,s10
    1a26:	00004517          	auipc	a0,0x4
    1a2a:	39250513          	addi	a0,a0,914 # 5db8 <malloc+0xbf4>
    1a2e:	6de030ef          	jal	510c <printf>
        exit(1);
    1a32:	4505                	li	a0,1
    1a34:	2be030ef          	jal	4cf2 <exit>
  for(i = 0; i < N; i++){
    1a38:	2905                	addiw	s2,s2,1
    1a3a:	2a85                	addiw	s5,s5,1
    1a3c:	2985                	addiw	s3,s3,1
    1a3e:	0ff9f993          	zext.b	s3,s3
    1a42:	47d1                	li	a5,20
    1a44:	00f90663          	beq	s2,a5,1a50 <createdelete+0x18a>
    for(pi = 0; pi < NCHILD; pi++){
    1a48:	84e6                	mv	s1,s9
      fd = open(name, 0);
    1a4a:	f8040a13          	addi	s4,s0,-128
    1a4e:	b775                	j	19fa <createdelete+0x134>
    1a50:	03000913          	li	s2,48
  name[0] = name[1] = name[2] = 0;
    1a54:	07000b13          	li	s6,112
      unlink(name);
    1a58:	f8040a13          	addi	s4,s0,-128
    for(pi = 0; pi < NCHILD; pi++){
    1a5c:	07400993          	li	s3,116
  for(i = 0; i < N; i++){
    1a60:	04400a93          	li	s5,68
  name[0] = name[1] = name[2] = 0;
    1a64:	84da                	mv	s1,s6
      name[0] = 'p' + pi;
    1a66:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1a6a:	f92400a3          	sb	s2,-127(s0)
      unlink(name);
    1a6e:	8552                	mv	a0,s4
    1a70:	2d2030ef          	jal	4d42 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1a74:	2485                	addiw	s1,s1,1
    1a76:	0ff4f493          	zext.b	s1,s1
    1a7a:	ff3496e3          	bne	s1,s3,1a66 <createdelete+0x1a0>
  for(i = 0; i < N; i++){
    1a7e:	2905                	addiw	s2,s2,1
    1a80:	0ff97913          	zext.b	s2,s2
    1a84:	ff5910e3          	bne	s2,s5,1a64 <createdelete+0x19e>
}
    1a88:	60aa                	ld	ra,136(sp)
    1a8a:	640a                	ld	s0,128(sp)
    1a8c:	74e6                	ld	s1,120(sp)
    1a8e:	7946                	ld	s2,112(sp)
    1a90:	79a6                	ld	s3,104(sp)
    1a92:	7a06                	ld	s4,96(sp)
    1a94:	6ae6                	ld	s5,88(sp)
    1a96:	6b46                	ld	s6,80(sp)
    1a98:	6ba6                	ld	s7,72(sp)
    1a9a:	6c06                	ld	s8,64(sp)
    1a9c:	7ce2                	ld	s9,56(sp)
    1a9e:	7d42                	ld	s10,48(sp)
    1aa0:	6149                	addi	sp,sp,144
    1aa2:	8082                	ret

0000000000001aa4 <linkunlink>:
{
    1aa4:	711d                	addi	sp,sp,-96
    1aa6:	ec86                	sd	ra,88(sp)
    1aa8:	e8a2                	sd	s0,80(sp)
    1aaa:	e4a6                	sd	s1,72(sp)
    1aac:	e0ca                	sd	s2,64(sp)
    1aae:	fc4e                	sd	s3,56(sp)
    1ab0:	f852                	sd	s4,48(sp)
    1ab2:	f456                	sd	s5,40(sp)
    1ab4:	f05a                	sd	s6,32(sp)
    1ab6:	ec5e                	sd	s7,24(sp)
    1ab8:	e862                	sd	s8,16(sp)
    1aba:	e466                	sd	s9,8(sp)
    1abc:	e06a                	sd	s10,0(sp)
    1abe:	1080                	addi	s0,sp,96
    1ac0:	84aa                	mv	s1,a0
  unlink("x");
    1ac2:	00004517          	auipc	a0,0x4
    1ac6:	8a650513          	addi	a0,a0,-1882 # 5368 <malloc+0x1a4>
    1aca:	278030ef          	jal	4d42 <unlink>
  pid = fork();
    1ace:	21c030ef          	jal	4cea <fork>
  if(pid < 0){
    1ad2:	04054363          	bltz	a0,1b18 <linkunlink+0x74>
    1ad6:	8d2a                	mv	s10,a0
  unsigned int x = (pid ? 1 : 97);
    1ad8:	06100913          	li	s2,97
    1adc:	c111                	beqz	a0,1ae0 <linkunlink+0x3c>
    1ade:	4905                	li	s2,1
    1ae0:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1ae4:	41c65ab7          	lui	s5,0x41c65
    1ae8:	e6da8a9b          	addiw	s5,s5,-403 # 41c64e6d <base+0x41c551f5>
    1aec:	6a0d                	lui	s4,0x3
    1aee:	039a0a1b          	addiw	s4,s4,57 # 3039 <subdir+0x26f>
    if((x % 3) == 0){
    1af2:	000ab9b7          	lui	s3,0xab
    1af6:	aab98993          	addi	s3,s3,-1365 # aaaab <base+0x9ae33>
    1afa:	09b2                	slli	s3,s3,0xc
    1afc:	aab98993          	addi	s3,s3,-1365
    } else if((x % 3) == 1){
    1b00:	4b85                	li	s7,1
      unlink("x");
    1b02:	00004b17          	auipc	s6,0x4
    1b06:	866b0b13          	addi	s6,s6,-1946 # 5368 <malloc+0x1a4>
      link("cat", "x");
    1b0a:	00004c97          	auipc	s9,0x4
    1b0e:	2d6c8c93          	addi	s9,s9,726 # 5de0 <malloc+0xc1c>
      close(open("x", O_RDWR | O_CREATE));
    1b12:	20200c13          	li	s8,514
    1b16:	a03d                	j	1b44 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1b18:	85a6                	mv	a1,s1
    1b1a:	00004517          	auipc	a0,0x4
    1b1e:	06e50513          	addi	a0,a0,110 # 5b88 <malloc+0x9c4>
    1b22:	5ea030ef          	jal	510c <printf>
    exit(1);
    1b26:	4505                	li	a0,1
    1b28:	1ca030ef          	jal	4cf2 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1b2c:	85e2                	mv	a1,s8
    1b2e:	855a                	mv	a0,s6
    1b30:	202030ef          	jal	4d32 <open>
    1b34:	1e6030ef          	jal	4d1a <close>
    1b38:	a021                	j	1b40 <linkunlink+0x9c>
      unlink("x");
    1b3a:	855a                	mv	a0,s6
    1b3c:	206030ef          	jal	4d42 <unlink>
  for(i = 0; i < 100; i++){
    1b40:	34fd                	addiw	s1,s1,-1
    1b42:	c885                	beqz	s1,1b72 <linkunlink+0xce>
    x = x * 1103515245 + 12345;
    1b44:	035907bb          	mulw	a5,s2,s5
    1b48:	00fa07bb          	addw	a5,s4,a5
    1b4c:	893e                	mv	s2,a5
    if((x % 3) == 0){
    1b4e:	02079713          	slli	a4,a5,0x20
    1b52:	9301                	srli	a4,a4,0x20
    1b54:	03370733          	mul	a4,a4,s3
    1b58:	9305                	srli	a4,a4,0x21
    1b5a:	0017169b          	slliw	a3,a4,0x1
    1b5e:	9f35                	addw	a4,a4,a3
    1b60:	9f99                	subw	a5,a5,a4
    1b62:	d7e9                	beqz	a5,1b2c <linkunlink+0x88>
    } else if((x % 3) == 1){
    1b64:	fd779be3          	bne	a5,s7,1b3a <linkunlink+0x96>
      link("cat", "x");
    1b68:	85da                	mv	a1,s6
    1b6a:	8566                	mv	a0,s9
    1b6c:	1e6030ef          	jal	4d52 <link>
    1b70:	bfc1                	j	1b40 <linkunlink+0x9c>
  if(pid)
    1b72:	020d0363          	beqz	s10,1b98 <linkunlink+0xf4>
    wait(0);
    1b76:	4501                	li	a0,0
    1b78:	182030ef          	jal	4cfa <wait>
}
    1b7c:	60e6                	ld	ra,88(sp)
    1b7e:	6446                	ld	s0,80(sp)
    1b80:	64a6                	ld	s1,72(sp)
    1b82:	6906                	ld	s2,64(sp)
    1b84:	79e2                	ld	s3,56(sp)
    1b86:	7a42                	ld	s4,48(sp)
    1b88:	7aa2                	ld	s5,40(sp)
    1b8a:	7b02                	ld	s6,32(sp)
    1b8c:	6be2                	ld	s7,24(sp)
    1b8e:	6c42                	ld	s8,16(sp)
    1b90:	6ca2                	ld	s9,8(sp)
    1b92:	6d02                	ld	s10,0(sp)
    1b94:	6125                	addi	sp,sp,96
    1b96:	8082                	ret
    exit(0);
    1b98:	4501                	li	a0,0
    1b9a:	158030ef          	jal	4cf2 <exit>

0000000000001b9e <forktest>:
{
    1b9e:	7179                	addi	sp,sp,-48
    1ba0:	f406                	sd	ra,40(sp)
    1ba2:	f022                	sd	s0,32(sp)
    1ba4:	ec26                	sd	s1,24(sp)
    1ba6:	e84a                	sd	s2,16(sp)
    1ba8:	e44e                	sd	s3,8(sp)
    1baa:	1800                	addi	s0,sp,48
    1bac:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1bae:	4481                	li	s1,0
    1bb0:	3e800913          	li	s2,1000
    pid = fork();
    1bb4:	136030ef          	jal	4cea <fork>
    if(pid < 0)
    1bb8:	06054063          	bltz	a0,1c18 <forktest+0x7a>
    if(pid == 0)
    1bbc:	cd11                	beqz	a0,1bd8 <forktest+0x3a>
  for(n=0; n<N; n++){
    1bbe:	2485                	addiw	s1,s1,1
    1bc0:	ff249ae3          	bne	s1,s2,1bb4 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1bc4:	85ce                	mv	a1,s3
    1bc6:	00004517          	auipc	a0,0x4
    1bca:	26a50513          	addi	a0,a0,618 # 5e30 <malloc+0xc6c>
    1bce:	53e030ef          	jal	510c <printf>
    exit(1);
    1bd2:	4505                	li	a0,1
    1bd4:	11e030ef          	jal	4cf2 <exit>
      exit(0);
    1bd8:	11a030ef          	jal	4cf2 <exit>
    printf("%s: no fork at all!\n", s);
    1bdc:	85ce                	mv	a1,s3
    1bde:	00004517          	auipc	a0,0x4
    1be2:	20a50513          	addi	a0,a0,522 # 5de8 <malloc+0xc24>
    1be6:	526030ef          	jal	510c <printf>
    exit(1);
    1bea:	4505                	li	a0,1
    1bec:	106030ef          	jal	4cf2 <exit>
      printf("%s: wait stopped early\n", s);
    1bf0:	85ce                	mv	a1,s3
    1bf2:	00004517          	auipc	a0,0x4
    1bf6:	20e50513          	addi	a0,a0,526 # 5e00 <malloc+0xc3c>
    1bfa:	512030ef          	jal	510c <printf>
      exit(1);
    1bfe:	4505                	li	a0,1
    1c00:	0f2030ef          	jal	4cf2 <exit>
    printf("%s: wait got too many\n", s);
    1c04:	85ce                	mv	a1,s3
    1c06:	00004517          	auipc	a0,0x4
    1c0a:	21250513          	addi	a0,a0,530 # 5e18 <malloc+0xc54>
    1c0e:	4fe030ef          	jal	510c <printf>
    exit(1);
    1c12:	4505                	li	a0,1
    1c14:	0de030ef          	jal	4cf2 <exit>
  if (n == 0) {
    1c18:	d0f1                	beqz	s1,1bdc <forktest+0x3e>
    if(wait(0) < 0){
    1c1a:	4501                	li	a0,0
    1c1c:	0de030ef          	jal	4cfa <wait>
    1c20:	fc0548e3          	bltz	a0,1bf0 <forktest+0x52>
  for(; n > 0; n--){
    1c24:	34fd                	addiw	s1,s1,-1
    1c26:	fe904ae3          	bgtz	s1,1c1a <forktest+0x7c>
  if(wait(0) != -1){
    1c2a:	4501                	li	a0,0
    1c2c:	0ce030ef          	jal	4cfa <wait>
    1c30:	57fd                	li	a5,-1
    1c32:	fcf519e3          	bne	a0,a5,1c04 <forktest+0x66>
}
    1c36:	70a2                	ld	ra,40(sp)
    1c38:	7402                	ld	s0,32(sp)
    1c3a:	64e2                	ld	s1,24(sp)
    1c3c:	6942                	ld	s2,16(sp)
    1c3e:	69a2                	ld	s3,8(sp)
    1c40:	6145                	addi	sp,sp,48
    1c42:	8082                	ret

0000000000001c44 <kernmem>:
{
    1c44:	715d                	addi	sp,sp,-80
    1c46:	e486                	sd	ra,72(sp)
    1c48:	e0a2                	sd	s0,64(sp)
    1c4a:	fc26                	sd	s1,56(sp)
    1c4c:	f84a                	sd	s2,48(sp)
    1c4e:	f44e                	sd	s3,40(sp)
    1c50:	f052                	sd	s4,32(sp)
    1c52:	ec56                	sd	s5,24(sp)
    1c54:	e85a                	sd	s6,16(sp)
    1c56:	0880                	addi	s0,sp,80
    1c58:	8b2a                	mv	s6,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1c5a:	4485                	li	s1,1
    1c5c:	04fe                	slli	s1,s1,0x1f
    wait(&xstatus);
    1c5e:	fbc40a93          	addi	s5,s0,-68
    if(xstatus != -1)  // did kernel kill child?
    1c62:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1c64:	69b1                	lui	s3,0xc
    1c66:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1de8>
    1c6a:	1003d937          	lui	s2,0x1003d
    1c6e:	090e                	slli	s2,s2,0x3
    1c70:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d808>
    pid = fork();
    1c74:	076030ef          	jal	4cea <fork>
    if(pid < 0){
    1c78:	02054763          	bltz	a0,1ca6 <kernmem+0x62>
    if(pid == 0){
    1c7c:	cd1d                	beqz	a0,1cba <kernmem+0x76>
    wait(&xstatus);
    1c7e:	8556                	mv	a0,s5
    1c80:	07a030ef          	jal	4cfa <wait>
    if(xstatus != -1)  // did kernel kill child?
    1c84:	fbc42783          	lw	a5,-68(s0)
    1c88:	05479663          	bne	a5,s4,1cd4 <kernmem+0x90>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1c8c:	94ce                	add	s1,s1,s3
    1c8e:	ff2493e3          	bne	s1,s2,1c74 <kernmem+0x30>
}
    1c92:	60a6                	ld	ra,72(sp)
    1c94:	6406                	ld	s0,64(sp)
    1c96:	74e2                	ld	s1,56(sp)
    1c98:	7942                	ld	s2,48(sp)
    1c9a:	79a2                	ld	s3,40(sp)
    1c9c:	7a02                	ld	s4,32(sp)
    1c9e:	6ae2                	ld	s5,24(sp)
    1ca0:	6b42                	ld	s6,16(sp)
    1ca2:	6161                	addi	sp,sp,80
    1ca4:	8082                	ret
      printf("%s: fork failed\n", s);
    1ca6:	85da                	mv	a1,s6
    1ca8:	00004517          	auipc	a0,0x4
    1cac:	ee050513          	addi	a0,a0,-288 # 5b88 <malloc+0x9c4>
    1cb0:	45c030ef          	jal	510c <printf>
      exit(1);
    1cb4:	4505                	li	a0,1
    1cb6:	03c030ef          	jal	4cf2 <exit>
      printf("%s: oops could read %p = %x\n", s, a, *a);
    1cba:	0004c683          	lbu	a3,0(s1)
    1cbe:	8626                	mv	a2,s1
    1cc0:	85da                	mv	a1,s6
    1cc2:	00004517          	auipc	a0,0x4
    1cc6:	19650513          	addi	a0,a0,406 # 5e58 <malloc+0xc94>
    1cca:	442030ef          	jal	510c <printf>
      exit(1);
    1cce:	4505                	li	a0,1
    1cd0:	022030ef          	jal	4cf2 <exit>
      exit(1);
    1cd4:	4505                	li	a0,1
    1cd6:	01c030ef          	jal	4cf2 <exit>

0000000000001cda <MAXVAplus>:
{
    1cda:	7139                	addi	sp,sp,-64
    1cdc:	fc06                	sd	ra,56(sp)
    1cde:	f822                	sd	s0,48(sp)
    1ce0:	0080                	addi	s0,sp,64
  volatile uint64 a = MAXVA;
    1ce2:	4785                	li	a5,1
    1ce4:	179a                	slli	a5,a5,0x26
    1ce6:	fcf43423          	sd	a5,-56(s0)
  for( ; a != 0; a <<= 1){
    1cea:	fc843783          	ld	a5,-56(s0)
    1cee:	cf9d                	beqz	a5,1d2c <MAXVAplus+0x52>
    1cf0:	f426                	sd	s1,40(sp)
    1cf2:	f04a                	sd	s2,32(sp)
    1cf4:	ec4e                	sd	s3,24(sp)
    1cf6:	89aa                	mv	s3,a0
    wait(&xstatus);
    1cf8:	fc440913          	addi	s2,s0,-60
    if(xstatus != -1)  // did kernel kill child?
    1cfc:	54fd                	li	s1,-1
    pid = fork();
    1cfe:	7ed020ef          	jal	4cea <fork>
    if(pid < 0){
    1d02:	02054963          	bltz	a0,1d34 <MAXVAplus+0x5a>
    if(pid == 0){
    1d06:	c129                	beqz	a0,1d48 <MAXVAplus+0x6e>
    wait(&xstatus);
    1d08:	854a                	mv	a0,s2
    1d0a:	7f1020ef          	jal	4cfa <wait>
    if(xstatus != -1)  // did kernel kill child?
    1d0e:	fc442783          	lw	a5,-60(s0)
    1d12:	04979d63          	bne	a5,s1,1d6c <MAXVAplus+0x92>
  for( ; a != 0; a <<= 1){
    1d16:	fc843783          	ld	a5,-56(s0)
    1d1a:	0786                	slli	a5,a5,0x1
    1d1c:	fcf43423          	sd	a5,-56(s0)
    1d20:	fc843783          	ld	a5,-56(s0)
    1d24:	ffe9                	bnez	a5,1cfe <MAXVAplus+0x24>
    1d26:	74a2                	ld	s1,40(sp)
    1d28:	7902                	ld	s2,32(sp)
    1d2a:	69e2                	ld	s3,24(sp)
}
    1d2c:	70e2                	ld	ra,56(sp)
    1d2e:	7442                	ld	s0,48(sp)
    1d30:	6121                	addi	sp,sp,64
    1d32:	8082                	ret
      printf("%s: fork failed\n", s);
    1d34:	85ce                	mv	a1,s3
    1d36:	00004517          	auipc	a0,0x4
    1d3a:	e5250513          	addi	a0,a0,-430 # 5b88 <malloc+0x9c4>
    1d3e:	3ce030ef          	jal	510c <printf>
      exit(1);
    1d42:	4505                	li	a0,1
    1d44:	7af020ef          	jal	4cf2 <exit>
      *(char*)a = 99;
    1d48:	fc843783          	ld	a5,-56(s0)
    1d4c:	06300713          	li	a4,99
    1d50:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %p\n", s, (void*)a);
    1d54:	fc843603          	ld	a2,-56(s0)
    1d58:	85ce                	mv	a1,s3
    1d5a:	00004517          	auipc	a0,0x4
    1d5e:	11e50513          	addi	a0,a0,286 # 5e78 <malloc+0xcb4>
    1d62:	3aa030ef          	jal	510c <printf>
      exit(1);
    1d66:	4505                	li	a0,1
    1d68:	78b020ef          	jal	4cf2 <exit>
      exit(1);
    1d6c:	4505                	li	a0,1
    1d6e:	785020ef          	jal	4cf2 <exit>

0000000000001d72 <bigargtest>:
{
    1d72:	7179                	addi	sp,sp,-48
    1d74:	f406                	sd	ra,40(sp)
    1d76:	f022                	sd	s0,32(sp)
    1d78:	ec26                	sd	s1,24(sp)
    1d7a:	1800                	addi	s0,sp,48
    1d7c:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    1d7e:	00004517          	auipc	a0,0x4
    1d82:	11250513          	addi	a0,a0,274 # 5e90 <malloc+0xccc>
    1d86:	7bd020ef          	jal	4d42 <unlink>
  pid = fork();
    1d8a:	761020ef          	jal	4cea <fork>
  if(pid == 0){
    1d8e:	c915                	beqz	a0,1dc2 <bigargtest+0x50>
  } else if(pid < 0){
    1d90:	08054263          	bltz	a0,1e14 <bigargtest+0xa2>
  wait(&xstatus);
    1d94:	fdc40513          	addi	a0,s0,-36
    1d98:	763020ef          	jal	4cfa <wait>
  if(xstatus != 0)
    1d9c:	fdc42503          	lw	a0,-36(s0)
    1da0:	e541                	bnez	a0,1e28 <bigargtest+0xb6>
  fd = open("bigarg-ok", 0);
    1da2:	4581                	li	a1,0
    1da4:	00004517          	auipc	a0,0x4
    1da8:	0ec50513          	addi	a0,a0,236 # 5e90 <malloc+0xccc>
    1dac:	787020ef          	jal	4d32 <open>
  if(fd < 0){
    1db0:	06054e63          	bltz	a0,1e2c <bigargtest+0xba>
  close(fd);
    1db4:	767020ef          	jal	4d1a <close>
}
    1db8:	70a2                	ld	ra,40(sp)
    1dba:	7402                	ld	s0,32(sp)
    1dbc:	64e2                	ld	s1,24(sp)
    1dbe:	6145                	addi	sp,sp,48
    1dc0:	8082                	ret
    1dc2:	00007797          	auipc	a5,0x7
    1dc6:	69e78793          	addi	a5,a5,1694 # 9460 <args.1>
    1dca:	00007697          	auipc	a3,0x7
    1dce:	78e68693          	addi	a3,a3,1934 # 9558 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    1dd2:	00004717          	auipc	a4,0x4
    1dd6:	0ce70713          	addi	a4,a4,206 # 5ea0 <malloc+0xcdc>
    1dda:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    1ddc:	07a1                	addi	a5,a5,8
    1dde:	fed79ee3          	bne	a5,a3,1dda <bigargtest+0x68>
    args[MAXARG-1] = 0;
    1de2:	00007597          	auipc	a1,0x7
    1de6:	67e58593          	addi	a1,a1,1662 # 9460 <args.1>
    1dea:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    1dee:	00003517          	auipc	a0,0x3
    1df2:	50a50513          	addi	a0,a0,1290 # 52f8 <malloc+0x134>
    1df6:	735020ef          	jal	4d2a <exec>
    fd = open("bigarg-ok", O_CREATE);
    1dfa:	20000593          	li	a1,512
    1dfe:	00004517          	auipc	a0,0x4
    1e02:	09250513          	addi	a0,a0,146 # 5e90 <malloc+0xccc>
    1e06:	72d020ef          	jal	4d32 <open>
    close(fd);
    1e0a:	711020ef          	jal	4d1a <close>
    exit(0);
    1e0e:	4501                	li	a0,0
    1e10:	6e3020ef          	jal	4cf2 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    1e14:	85a6                	mv	a1,s1
    1e16:	00004517          	auipc	a0,0x4
    1e1a:	16a50513          	addi	a0,a0,362 # 5f80 <malloc+0xdbc>
    1e1e:	2ee030ef          	jal	510c <printf>
    exit(1);
    1e22:	4505                	li	a0,1
    1e24:	6cf020ef          	jal	4cf2 <exit>
    exit(xstatus);
    1e28:	6cb020ef          	jal	4cf2 <exit>
    printf("%s: bigarg test failed!\n", s);
    1e2c:	85a6                	mv	a1,s1
    1e2e:	00004517          	auipc	a0,0x4
    1e32:	17250513          	addi	a0,a0,370 # 5fa0 <malloc+0xddc>
    1e36:	2d6030ef          	jal	510c <printf>
    exit(1);
    1e3a:	4505                	li	a0,1
    1e3c:	6b7020ef          	jal	4cf2 <exit>

0000000000001e40 <stacktest>:
{
    1e40:	7179                	addi	sp,sp,-48
    1e42:	f406                	sd	ra,40(sp)
    1e44:	f022                	sd	s0,32(sp)
    1e46:	ec26                	sd	s1,24(sp)
    1e48:	1800                	addi	s0,sp,48
    1e4a:	84aa                	mv	s1,a0
  pid = fork();
    1e4c:	69f020ef          	jal	4cea <fork>
  if(pid == 0) {
    1e50:	cd11                	beqz	a0,1e6c <stacktest+0x2c>
  } else if(pid < 0){
    1e52:	02054c63          	bltz	a0,1e8a <stacktest+0x4a>
  wait(&xstatus);
    1e56:	fdc40513          	addi	a0,s0,-36
    1e5a:	6a1020ef          	jal	4cfa <wait>
  if(xstatus == -1)  // kernel killed child?
    1e5e:	fdc42503          	lw	a0,-36(s0)
    1e62:	57fd                	li	a5,-1
    1e64:	02f50d63          	beq	a0,a5,1e9e <stacktest+0x5e>
    exit(xstatus);
    1e68:	68b020ef          	jal	4cf2 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    1e6c:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %d\n", s, *sp);
    1e6e:	77fd                	lui	a5,0xfffff
    1e70:	97ba                	add	a5,a5,a4
    1e72:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    1e76:	85a6                	mv	a1,s1
    1e78:	00004517          	auipc	a0,0x4
    1e7c:	14850513          	addi	a0,a0,328 # 5fc0 <malloc+0xdfc>
    1e80:	28c030ef          	jal	510c <printf>
    exit(1);
    1e84:	4505                	li	a0,1
    1e86:	66d020ef          	jal	4cf2 <exit>
    printf("%s: fork failed\n", s);
    1e8a:	85a6                	mv	a1,s1
    1e8c:	00004517          	auipc	a0,0x4
    1e90:	cfc50513          	addi	a0,a0,-772 # 5b88 <malloc+0x9c4>
    1e94:	278030ef          	jal	510c <printf>
    exit(1);
    1e98:	4505                	li	a0,1
    1e9a:	659020ef          	jal	4cf2 <exit>
    exit(0);
    1e9e:	4501                	li	a0,0
    1ea0:	653020ef          	jal	4cf2 <exit>

0000000000001ea4 <nowrite>:
{
    1ea4:	7159                	addi	sp,sp,-112
    1ea6:	f486                	sd	ra,104(sp)
    1ea8:	f0a2                	sd	s0,96(sp)
    1eaa:	eca6                	sd	s1,88(sp)
    1eac:	e8ca                	sd	s2,80(sp)
    1eae:	e4ce                	sd	s3,72(sp)
    1eb0:	e0d2                	sd	s4,64(sp)
    1eb2:	1880                	addi	s0,sp,112
    1eb4:	8a2a                	mv	s4,a0
  uint64 addrs[] = { 0, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
    1eb6:	00006797          	auipc	a5,0x6
    1eba:	88278793          	addi	a5,a5,-1918 # 7738 <malloc+0x2574>
    1ebe:	7788                	ld	a0,40(a5)
    1ec0:	7b8c                	ld	a1,48(a5)
    1ec2:	7f90                	ld	a2,56(a5)
    1ec4:	63b4                	ld	a3,64(a5)
    1ec6:	67b8                	ld	a4,72(a5)
    1ec8:	6bbc                	ld	a5,80(a5)
    1eca:	f8a43c23          	sd	a0,-104(s0)
    1ece:	fab43023          	sd	a1,-96(s0)
    1ed2:	fac43423          	sd	a2,-88(s0)
    1ed6:	fad43823          	sd	a3,-80(s0)
    1eda:	fae43c23          	sd	a4,-72(s0)
    1ede:	fcf43023          	sd	a5,-64(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1ee2:	4481                	li	s1,0
    wait(&xstatus);
    1ee4:	fcc40913          	addi	s2,s0,-52
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1ee8:	4999                	li	s3,6
    pid = fork();
    1eea:	601020ef          	jal	4cea <fork>
    if(pid == 0) {
    1eee:	cd19                	beqz	a0,1f0c <nowrite+0x68>
    } else if(pid < 0){
    1ef0:	04054163          	bltz	a0,1f32 <nowrite+0x8e>
    wait(&xstatus);
    1ef4:	854a                	mv	a0,s2
    1ef6:	605020ef          	jal	4cfa <wait>
    if(xstatus == 0){
    1efa:	fcc42783          	lw	a5,-52(s0)
    1efe:	c7a1                	beqz	a5,1f46 <nowrite+0xa2>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1f00:	2485                	addiw	s1,s1,1
    1f02:	ff3494e3          	bne	s1,s3,1eea <nowrite+0x46>
  exit(0);
    1f06:	4501                	li	a0,0
    1f08:	5eb020ef          	jal	4cf2 <exit>
      volatile int *addr = (int *) addrs[ai];
    1f0c:	048e                	slli	s1,s1,0x3
    1f0e:	fd048793          	addi	a5,s1,-48
    1f12:	008784b3          	add	s1,a5,s0
    1f16:	fc84b603          	ld	a2,-56(s1)
      *addr = 10;
    1f1a:	47a9                	li	a5,10
    1f1c:	c21c                	sw	a5,0(a2)
      printf("%s: write to %p did not fail!\n", s, addr);
    1f1e:	85d2                	mv	a1,s4
    1f20:	00004517          	auipc	a0,0x4
    1f24:	0c850513          	addi	a0,a0,200 # 5fe8 <malloc+0xe24>
    1f28:	1e4030ef          	jal	510c <printf>
      exit(0);
    1f2c:	4501                	li	a0,0
    1f2e:	5c5020ef          	jal	4cf2 <exit>
      printf("%s: fork failed\n", s);
    1f32:	85d2                	mv	a1,s4
    1f34:	00004517          	auipc	a0,0x4
    1f38:	c5450513          	addi	a0,a0,-940 # 5b88 <malloc+0x9c4>
    1f3c:	1d0030ef          	jal	510c <printf>
      exit(1);
    1f40:	4505                	li	a0,1
    1f42:	5b1020ef          	jal	4cf2 <exit>
      exit(1);
    1f46:	4505                	li	a0,1
    1f48:	5ab020ef          	jal	4cf2 <exit>

0000000000001f4c <manywrites>:
{
    1f4c:	7159                	addi	sp,sp,-112
    1f4e:	f486                	sd	ra,104(sp)
    1f50:	f0a2                	sd	s0,96(sp)
    1f52:	eca6                	sd	s1,88(sp)
    1f54:	e8ca                	sd	s2,80(sp)
    1f56:	e4ce                	sd	s3,72(sp)
    1f58:	fc56                	sd	s5,56(sp)
    1f5a:	1880                	addi	s0,sp,112
    1f5c:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1f5e:	4901                	li	s2,0
    1f60:	4991                	li	s3,4
    int pid = fork();
    1f62:	589020ef          	jal	4cea <fork>
    1f66:	84aa                	mv	s1,a0
    if(pid < 0){
    1f68:	02054d63          	bltz	a0,1fa2 <manywrites+0x56>
    if(pid == 0){
    1f6c:	c931                	beqz	a0,1fc0 <manywrites+0x74>
  for(int ci = 0; ci < nchildren; ci++){
    1f6e:	2905                	addiw	s2,s2,1
    1f70:	ff3919e3          	bne	s2,s3,1f62 <manywrites+0x16>
    1f74:	4491                	li	s1,4
    wait(&st);
    1f76:	f9840913          	addi	s2,s0,-104
    int st = 0;
    1f7a:	f8042c23          	sw	zero,-104(s0)
    wait(&st);
    1f7e:	854a                	mv	a0,s2
    1f80:	57b020ef          	jal	4cfa <wait>
    if(st != 0)
    1f84:	f9842503          	lw	a0,-104(s0)
    1f88:	0e051463          	bnez	a0,2070 <manywrites+0x124>
  for(int ci = 0; ci < nchildren; ci++){
    1f8c:	34fd                	addiw	s1,s1,-1
    1f8e:	f4f5                	bnez	s1,1f7a <manywrites+0x2e>
    1f90:	e0d2                	sd	s4,64(sp)
    1f92:	f85a                	sd	s6,48(sp)
    1f94:	f45e                	sd	s7,40(sp)
    1f96:	f062                	sd	s8,32(sp)
    1f98:	ec66                	sd	s9,24(sp)
    1f9a:	e86a                	sd	s10,16(sp)
  exit(0);
    1f9c:	4501                	li	a0,0
    1f9e:	555020ef          	jal	4cf2 <exit>
    1fa2:	e0d2                	sd	s4,64(sp)
    1fa4:	f85a                	sd	s6,48(sp)
    1fa6:	f45e                	sd	s7,40(sp)
    1fa8:	f062                	sd	s8,32(sp)
    1faa:	ec66                	sd	s9,24(sp)
    1fac:	e86a                	sd	s10,16(sp)
      printf("fork failed\n");
    1fae:	00004517          	auipc	a0,0x4
    1fb2:	fe250513          	addi	a0,a0,-30 # 5f90 <malloc+0xdcc>
    1fb6:	156030ef          	jal	510c <printf>
      exit(1);
    1fba:	4505                	li	a0,1
    1fbc:	537020ef          	jal	4cf2 <exit>
    1fc0:	e0d2                	sd	s4,64(sp)
    1fc2:	f85a                	sd	s6,48(sp)
    1fc4:	f45e                	sd	s7,40(sp)
    1fc6:	f062                	sd	s8,32(sp)
    1fc8:	ec66                	sd	s9,24(sp)
    1fca:	e86a                	sd	s10,16(sp)
      name[0] = 'b';
    1fcc:	06200793          	li	a5,98
    1fd0:	f8f40c23          	sb	a5,-104(s0)
      name[1] = 'a' + ci;
    1fd4:	0619079b          	addiw	a5,s2,97
    1fd8:	f8f40ca3          	sb	a5,-103(s0)
      name[2] = '\0';
    1fdc:	f8040d23          	sb	zero,-102(s0)
      unlink(name);
    1fe0:	f9840513          	addi	a0,s0,-104
    1fe4:	55f020ef          	jal	4d42 <unlink>
    1fe8:	4d79                	li	s10,30
          int fd = open(name, O_CREATE | O_RDWR);
    1fea:	f9840c13          	addi	s8,s0,-104
    1fee:	20200b93          	li	s7,514
          int cc = write(fd, buf, sz);
    1ff2:	6b0d                	lui	s6,0x3
    1ff4:	0000bc97          	auipc	s9,0xb
    1ff8:	c84c8c93          	addi	s9,s9,-892 # cc78 <buf>
        for(int i = 0; i < ci+1; i++){
    1ffc:	8a26                	mv	s4,s1
          int fd = open(name, O_CREATE | O_RDWR);
    1ffe:	85de                	mv	a1,s7
    2000:	8562                	mv	a0,s8
    2002:	531020ef          	jal	4d32 <open>
    2006:	89aa                	mv	s3,a0
          if(fd < 0){
    2008:	02054c63          	bltz	a0,2040 <manywrites+0xf4>
          int cc = write(fd, buf, sz);
    200c:	865a                	mv	a2,s6
    200e:	85e6                	mv	a1,s9
    2010:	503020ef          	jal	4d12 <write>
          if(cc != sz){
    2014:	05651263          	bne	a0,s6,2058 <manywrites+0x10c>
          close(fd);
    2018:	854e                	mv	a0,s3
    201a:	501020ef          	jal	4d1a <close>
        for(int i = 0; i < ci+1; i++){
    201e:	2a05                	addiw	s4,s4,1
    2020:	fd495fe3          	bge	s2,s4,1ffe <manywrites+0xb2>
        unlink(name);
    2024:	f9840513          	addi	a0,s0,-104
    2028:	51b020ef          	jal	4d42 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    202c:	3d7d                	addiw	s10,s10,-1
    202e:	fc0d17e3          	bnez	s10,1ffc <manywrites+0xb0>
      unlink(name);
    2032:	f9840513          	addi	a0,s0,-104
    2036:	50d020ef          	jal	4d42 <unlink>
      exit(0);
    203a:	4501                	li	a0,0
    203c:	4b7020ef          	jal	4cf2 <exit>
            printf("%s: cannot create %s\n", s, name);
    2040:	f9840613          	addi	a2,s0,-104
    2044:	85d6                	mv	a1,s5
    2046:	00004517          	auipc	a0,0x4
    204a:	fc250513          	addi	a0,a0,-62 # 6008 <malloc+0xe44>
    204e:	0be030ef          	jal	510c <printf>
            exit(1);
    2052:	4505                	li	a0,1
    2054:	49f020ef          	jal	4cf2 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    2058:	86aa                	mv	a3,a0
    205a:	660d                	lui	a2,0x3
    205c:	85d6                	mv	a1,s5
    205e:	00003517          	auipc	a0,0x3
    2062:	36a50513          	addi	a0,a0,874 # 53c8 <malloc+0x204>
    2066:	0a6030ef          	jal	510c <printf>
            exit(1);
    206a:	4505                	li	a0,1
    206c:	487020ef          	jal	4cf2 <exit>
    2070:	e0d2                	sd	s4,64(sp)
    2072:	f85a                	sd	s6,48(sp)
    2074:	f45e                	sd	s7,40(sp)
    2076:	f062                	sd	s8,32(sp)
    2078:	ec66                	sd	s9,24(sp)
    207a:	e86a                	sd	s10,16(sp)
      exit(st);
    207c:	477020ef          	jal	4cf2 <exit>

0000000000002080 <copyinstr3>:
{
    2080:	7179                	addi	sp,sp,-48
    2082:	f406                	sd	ra,40(sp)
    2084:	f022                	sd	s0,32(sp)
    2086:	ec26                	sd	s1,24(sp)
    2088:	1800                	addi	s0,sp,48
  sbrk(8192);
    208a:	6509                	lui	a0,0x2
    208c:	4ef020ef          	jal	4d7a <sbrk>
  uint64 top = (uint64) sbrk(0);
    2090:	4501                	li	a0,0
    2092:	4e9020ef          	jal	4d7a <sbrk>
  if((top % PGSIZE) != 0){
    2096:	03451793          	slli	a5,a0,0x34
    209a:	e7bd                	bnez	a5,2108 <copyinstr3+0x88>
  top = (uint64) sbrk(0);
    209c:	4501                	li	a0,0
    209e:	4dd020ef          	jal	4d7a <sbrk>
  if(top % PGSIZE){
    20a2:	03451793          	slli	a5,a0,0x34
    20a6:	ebb5                	bnez	a5,211a <copyinstr3+0x9a>
  char *b = (char *) (top - 1);
    20a8:	fff50493          	addi	s1,a0,-1 # 1fff <manywrites+0xb3>
  *b = 'x';
    20ac:	07800793          	li	a5,120
    20b0:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    20b4:	8526                	mv	a0,s1
    20b6:	48d020ef          	jal	4d42 <unlink>
  if(ret != -1){
    20ba:	57fd                	li	a5,-1
    20bc:	06f51863          	bne	a0,a5,212c <copyinstr3+0xac>
  int fd = open(b, O_CREATE | O_WRONLY);
    20c0:	20100593          	li	a1,513
    20c4:	8526                	mv	a0,s1
    20c6:	46d020ef          	jal	4d32 <open>
  if(fd != -1){
    20ca:	57fd                	li	a5,-1
    20cc:	06f51b63          	bne	a0,a5,2142 <copyinstr3+0xc2>
  ret = link(b, b);
    20d0:	85a6                	mv	a1,s1
    20d2:	8526                	mv	a0,s1
    20d4:	47f020ef          	jal	4d52 <link>
  if(ret != -1){
    20d8:	57fd                	li	a5,-1
    20da:	06f51f63          	bne	a0,a5,2158 <copyinstr3+0xd8>
  char *args[] = { "xx", 0 };
    20de:	00005797          	auipc	a5,0x5
    20e2:	c2a78793          	addi	a5,a5,-982 # 6d08 <malloc+0x1b44>
    20e6:	fcf43823          	sd	a5,-48(s0)
    20ea:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    20ee:	fd040593          	addi	a1,s0,-48
    20f2:	8526                	mv	a0,s1
    20f4:	437020ef          	jal	4d2a <exec>
  if(ret != -1){
    20f8:	57fd                	li	a5,-1
    20fa:	06f51b63          	bne	a0,a5,2170 <copyinstr3+0xf0>
}
    20fe:	70a2                	ld	ra,40(sp)
    2100:	7402                	ld	s0,32(sp)
    2102:	64e2                	ld	s1,24(sp)
    2104:	6145                	addi	sp,sp,48
    2106:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2108:	6785                	lui	a5,0x1
    210a:	fff78713          	addi	a4,a5,-1 # fff <bigdir+0x109>
    210e:	8d79                	and	a0,a0,a4
    2110:	40a7853b          	subw	a0,a5,a0
    2114:	467020ef          	jal	4d7a <sbrk>
    2118:	b751                	j	209c <copyinstr3+0x1c>
    printf("oops\n");
    211a:	00004517          	auipc	a0,0x4
    211e:	f0650513          	addi	a0,a0,-250 # 6020 <malloc+0xe5c>
    2122:	7eb020ef          	jal	510c <printf>
    exit(1);
    2126:	4505                	li	a0,1
    2128:	3cb020ef          	jal	4cf2 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    212c:	862a                	mv	a2,a0
    212e:	85a6                	mv	a1,s1
    2130:	00004517          	auipc	a0,0x4
    2134:	97850513          	addi	a0,a0,-1672 # 5aa8 <malloc+0x8e4>
    2138:	7d5020ef          	jal	510c <printf>
    exit(1);
    213c:	4505                	li	a0,1
    213e:	3b5020ef          	jal	4cf2 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2142:	862a                	mv	a2,a0
    2144:	85a6                	mv	a1,s1
    2146:	00004517          	auipc	a0,0x4
    214a:	98250513          	addi	a0,a0,-1662 # 5ac8 <malloc+0x904>
    214e:	7bf020ef          	jal	510c <printf>
    exit(1);
    2152:	4505                	li	a0,1
    2154:	39f020ef          	jal	4cf2 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2158:	86aa                	mv	a3,a0
    215a:	8626                	mv	a2,s1
    215c:	85a6                	mv	a1,s1
    215e:	00004517          	auipc	a0,0x4
    2162:	98a50513          	addi	a0,a0,-1654 # 5ae8 <malloc+0x924>
    2166:	7a7020ef          	jal	510c <printf>
    exit(1);
    216a:	4505                	li	a0,1
    216c:	387020ef          	jal	4cf2 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2170:	863e                	mv	a2,a5
    2172:	85a6                	mv	a1,s1
    2174:	00004517          	auipc	a0,0x4
    2178:	99c50513          	addi	a0,a0,-1636 # 5b10 <malloc+0x94c>
    217c:	791020ef          	jal	510c <printf>
    exit(1);
    2180:	4505                	li	a0,1
    2182:	371020ef          	jal	4cf2 <exit>

0000000000002186 <rwsbrk>:
{
    2186:	1101                	addi	sp,sp,-32
    2188:	ec06                	sd	ra,24(sp)
    218a:	e822                	sd	s0,16(sp)
    218c:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    218e:	6509                	lui	a0,0x2
    2190:	3eb020ef          	jal	4d7a <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2194:	57fd                	li	a5,-1
    2196:	04f50a63          	beq	a0,a5,21ea <rwsbrk+0x64>
    219a:	e426                	sd	s1,8(sp)
    219c:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    219e:	7579                	lui	a0,0xffffe
    21a0:	3db020ef          	jal	4d7a <sbrk>
    21a4:	57fd                	li	a5,-1
    21a6:	04f50d63          	beq	a0,a5,2200 <rwsbrk+0x7a>
    21aa:	e04a                	sd	s2,0(sp)
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    21ac:	20100593          	li	a1,513
    21b0:	00004517          	auipc	a0,0x4
    21b4:	eb050513          	addi	a0,a0,-336 # 6060 <malloc+0xe9c>
    21b8:	37b020ef          	jal	4d32 <open>
    21bc:	892a                	mv	s2,a0
  if(fd < 0){
    21be:	04054b63          	bltz	a0,2214 <rwsbrk+0x8e>
  n = write(fd, (void*)(a+4096), 1024);
    21c2:	6785                	lui	a5,0x1
    21c4:	94be                	add	s1,s1,a5
    21c6:	40000613          	li	a2,1024
    21ca:	85a6                	mv	a1,s1
    21cc:	347020ef          	jal	4d12 <write>
    21d0:	862a                	mv	a2,a0
  if(n >= 0){
    21d2:	04054a63          	bltz	a0,2226 <rwsbrk+0xa0>
    printf("write(fd, %p, 1024) returned %d, not -1\n", (void*)a+4096, n);
    21d6:	85a6                	mv	a1,s1
    21d8:	00004517          	auipc	a0,0x4
    21dc:	ea850513          	addi	a0,a0,-344 # 6080 <malloc+0xebc>
    21e0:	72d020ef          	jal	510c <printf>
    exit(1);
    21e4:	4505                	li	a0,1
    21e6:	30d020ef          	jal	4cf2 <exit>
    21ea:	e426                	sd	s1,8(sp)
    21ec:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) failed\n");
    21ee:	00004517          	auipc	a0,0x4
    21f2:	e3a50513          	addi	a0,a0,-454 # 6028 <malloc+0xe64>
    21f6:	717020ef          	jal	510c <printf>
    exit(1);
    21fa:	4505                	li	a0,1
    21fc:	2f7020ef          	jal	4cf2 <exit>
    2200:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) shrink failed\n");
    2202:	00004517          	auipc	a0,0x4
    2206:	e3e50513          	addi	a0,a0,-450 # 6040 <malloc+0xe7c>
    220a:	703020ef          	jal	510c <printf>
    exit(1);
    220e:	4505                	li	a0,1
    2210:	2e3020ef          	jal	4cf2 <exit>
    printf("open(rwsbrk) failed\n");
    2214:	00004517          	auipc	a0,0x4
    2218:	e5450513          	addi	a0,a0,-428 # 6068 <malloc+0xea4>
    221c:	6f1020ef          	jal	510c <printf>
    exit(1);
    2220:	4505                	li	a0,1
    2222:	2d1020ef          	jal	4cf2 <exit>
  close(fd);
    2226:	854a                	mv	a0,s2
    2228:	2f3020ef          	jal	4d1a <close>
  unlink("rwsbrk");
    222c:	00004517          	auipc	a0,0x4
    2230:	e3450513          	addi	a0,a0,-460 # 6060 <malloc+0xe9c>
    2234:	30f020ef          	jal	4d42 <unlink>
  fd = open("README", O_RDONLY);
    2238:	4581                	li	a1,0
    223a:	00003517          	auipc	a0,0x3
    223e:	29650513          	addi	a0,a0,662 # 54d0 <malloc+0x30c>
    2242:	2f1020ef          	jal	4d32 <open>
    2246:	892a                	mv	s2,a0
  if(fd < 0){
    2248:	02054363          	bltz	a0,226e <rwsbrk+0xe8>
  n = read(fd, (void*)(a+4096), 10);
    224c:	4629                	li	a2,10
    224e:	85a6                	mv	a1,s1
    2250:	2bb020ef          	jal	4d0a <read>
    2254:	862a                	mv	a2,a0
  if(n >= 0){
    2256:	02054563          	bltz	a0,2280 <rwsbrk+0xfa>
    printf("read(fd, %p, 10) returned %d, not -1\n", (void*)a+4096, n);
    225a:	85a6                	mv	a1,s1
    225c:	00004517          	auipc	a0,0x4
    2260:	e5450513          	addi	a0,a0,-428 # 60b0 <malloc+0xeec>
    2264:	6a9020ef          	jal	510c <printf>
    exit(1);
    2268:	4505                	li	a0,1
    226a:	289020ef          	jal	4cf2 <exit>
    printf("open(rwsbrk) failed\n");
    226e:	00004517          	auipc	a0,0x4
    2272:	dfa50513          	addi	a0,a0,-518 # 6068 <malloc+0xea4>
    2276:	697020ef          	jal	510c <printf>
    exit(1);
    227a:	4505                	li	a0,1
    227c:	277020ef          	jal	4cf2 <exit>
  close(fd);
    2280:	854a                	mv	a0,s2
    2282:	299020ef          	jal	4d1a <close>
  exit(0);
    2286:	4501                	li	a0,0
    2288:	26b020ef          	jal	4cf2 <exit>

000000000000228c <sbrkbasic>:
{
    228c:	715d                	addi	sp,sp,-80
    228e:	e486                	sd	ra,72(sp)
    2290:	e0a2                	sd	s0,64(sp)
    2292:	ec56                	sd	s5,24(sp)
    2294:	0880                	addi	s0,sp,80
    2296:	8aaa                	mv	s5,a0
  pid = fork();
    2298:	253020ef          	jal	4cea <fork>
  if(pid < 0){
    229c:	02054c63          	bltz	a0,22d4 <sbrkbasic+0x48>
  if(pid == 0){
    22a0:	ed31                	bnez	a0,22fc <sbrkbasic+0x70>
    a = sbrk(TOOMUCH);
    22a2:	40000537          	lui	a0,0x40000
    22a6:	2d5020ef          	jal	4d7a <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    22aa:	57fd                	li	a5,-1
    22ac:	04f50163          	beq	a0,a5,22ee <sbrkbasic+0x62>
    22b0:	fc26                	sd	s1,56(sp)
    22b2:	f84a                	sd	s2,48(sp)
    22b4:	f44e                	sd	s3,40(sp)
    22b6:	f052                	sd	s4,32(sp)
    for(b = a; b < a+TOOMUCH; b += 4096){
    22b8:	400007b7          	lui	a5,0x40000
    22bc:	97aa                	add	a5,a5,a0
      *b = 99;
    22be:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    22c2:	6705                	lui	a4,0x1
      *b = 99;
    22c4:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0388>
    for(b = a; b < a+TOOMUCH; b += 4096){
    22c8:	953a                	add	a0,a0,a4
    22ca:	fef51de3          	bne	a0,a5,22c4 <sbrkbasic+0x38>
    exit(1);
    22ce:	4505                	li	a0,1
    22d0:	223020ef          	jal	4cf2 <exit>
    22d4:	fc26                	sd	s1,56(sp)
    22d6:	f84a                	sd	s2,48(sp)
    22d8:	f44e                	sd	s3,40(sp)
    22da:	f052                	sd	s4,32(sp)
    printf("fork failed in sbrkbasic\n");
    22dc:	00004517          	auipc	a0,0x4
    22e0:	dfc50513          	addi	a0,a0,-516 # 60d8 <malloc+0xf14>
    22e4:	629020ef          	jal	510c <printf>
    exit(1);
    22e8:	4505                	li	a0,1
    22ea:	209020ef          	jal	4cf2 <exit>
    22ee:	fc26                	sd	s1,56(sp)
    22f0:	f84a                	sd	s2,48(sp)
    22f2:	f44e                	sd	s3,40(sp)
    22f4:	f052                	sd	s4,32(sp)
      exit(0);
    22f6:	4501                	li	a0,0
    22f8:	1fb020ef          	jal	4cf2 <exit>
  wait(&xstatus);
    22fc:	fbc40513          	addi	a0,s0,-68
    2300:	1fb020ef          	jal	4cfa <wait>
  if(xstatus == 1){
    2304:	fbc42703          	lw	a4,-68(s0)
    2308:	4785                	li	a5,1
    230a:	02f70063          	beq	a4,a5,232a <sbrkbasic+0x9e>
    230e:	fc26                	sd	s1,56(sp)
    2310:	f84a                	sd	s2,48(sp)
    2312:	f44e                	sd	s3,40(sp)
    2314:	f052                	sd	s4,32(sp)
  a = sbrk(0);
    2316:	4501                	li	a0,0
    2318:	263020ef          	jal	4d7a <sbrk>
    231c:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    231e:	4901                	li	s2,0
    b = sbrk(1);
    2320:	4985                	li	s3,1
  for(i = 0; i < 5000; i++){
    2322:	6a05                	lui	s4,0x1
    2324:	388a0a13          	addi	s4,s4,904 # 1388 <truncate3+0x148>
    2328:	a005                	j	2348 <sbrkbasic+0xbc>
    232a:	fc26                	sd	s1,56(sp)
    232c:	f84a                	sd	s2,48(sp)
    232e:	f44e                	sd	s3,40(sp)
    2330:	f052                	sd	s4,32(sp)
    printf("%s: too much memory allocated!\n", s);
    2332:	85d6                	mv	a1,s5
    2334:	00004517          	auipc	a0,0x4
    2338:	dc450513          	addi	a0,a0,-572 # 60f8 <malloc+0xf34>
    233c:	5d1020ef          	jal	510c <printf>
    exit(1);
    2340:	4505                	li	a0,1
    2342:	1b1020ef          	jal	4cf2 <exit>
    2346:	84be                	mv	s1,a5
    b = sbrk(1);
    2348:	854e                	mv	a0,s3
    234a:	231020ef          	jal	4d7a <sbrk>
    if(b != a){
    234e:	04951163          	bne	a0,s1,2390 <sbrkbasic+0x104>
    *b = 1;
    2352:	01348023          	sb	s3,0(s1)
    a = b + 1;
    2356:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    235a:	2905                	addiw	s2,s2,1
    235c:	ff4915e3          	bne	s2,s4,2346 <sbrkbasic+0xba>
  pid = fork();
    2360:	18b020ef          	jal	4cea <fork>
    2364:	892a                	mv	s2,a0
  if(pid < 0){
    2366:	04054263          	bltz	a0,23aa <sbrkbasic+0x11e>
  c = sbrk(1);
    236a:	4505                	li	a0,1
    236c:	20f020ef          	jal	4d7a <sbrk>
  c = sbrk(1);
    2370:	4505                	li	a0,1
    2372:	209020ef          	jal	4d7a <sbrk>
  if(c != a + 1){
    2376:	0489                	addi	s1,s1,2
    2378:	04a48363          	beq	s1,a0,23be <sbrkbasic+0x132>
    printf("%s: sbrk test failed post-fork\n", s);
    237c:	85d6                	mv	a1,s5
    237e:	00004517          	auipc	a0,0x4
    2382:	dda50513          	addi	a0,a0,-550 # 6158 <malloc+0xf94>
    2386:	587020ef          	jal	510c <printf>
    exit(1);
    238a:	4505                	li	a0,1
    238c:	167020ef          	jal	4cf2 <exit>
      printf("%s: sbrk test failed %d %p %p\n", s, i, a, b);
    2390:	872a                	mv	a4,a0
    2392:	86a6                	mv	a3,s1
    2394:	864a                	mv	a2,s2
    2396:	85d6                	mv	a1,s5
    2398:	00004517          	auipc	a0,0x4
    239c:	d8050513          	addi	a0,a0,-640 # 6118 <malloc+0xf54>
    23a0:	56d020ef          	jal	510c <printf>
      exit(1);
    23a4:	4505                	li	a0,1
    23a6:	14d020ef          	jal	4cf2 <exit>
    printf("%s: sbrk test fork failed\n", s);
    23aa:	85d6                	mv	a1,s5
    23ac:	00004517          	auipc	a0,0x4
    23b0:	d8c50513          	addi	a0,a0,-628 # 6138 <malloc+0xf74>
    23b4:	559020ef          	jal	510c <printf>
    exit(1);
    23b8:	4505                	li	a0,1
    23ba:	139020ef          	jal	4cf2 <exit>
  if(pid == 0)
    23be:	00091563          	bnez	s2,23c8 <sbrkbasic+0x13c>
    exit(0);
    23c2:	4501                	li	a0,0
    23c4:	12f020ef          	jal	4cf2 <exit>
  wait(&xstatus);
    23c8:	fbc40513          	addi	a0,s0,-68
    23cc:	12f020ef          	jal	4cfa <wait>
  exit(xstatus);
    23d0:	fbc42503          	lw	a0,-68(s0)
    23d4:	11f020ef          	jal	4cf2 <exit>

00000000000023d8 <sbrkmuch>:
{
    23d8:	7179                	addi	sp,sp,-48
    23da:	f406                	sd	ra,40(sp)
    23dc:	f022                	sd	s0,32(sp)
    23de:	ec26                	sd	s1,24(sp)
    23e0:	e84a                	sd	s2,16(sp)
    23e2:	e44e                	sd	s3,8(sp)
    23e4:	e052                	sd	s4,0(sp)
    23e6:	1800                	addi	s0,sp,48
    23e8:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    23ea:	4501                	li	a0,0
    23ec:	18f020ef          	jal	4d7a <sbrk>
    23f0:	892a                	mv	s2,a0
  a = sbrk(0);
    23f2:	4501                	li	a0,0
    23f4:	187020ef          	jal	4d7a <sbrk>
    23f8:	84aa                	mv	s1,a0
  p = sbrk(amt);
    23fa:	06400537          	lui	a0,0x6400
    23fe:	9d05                	subw	a0,a0,s1
    2400:	17b020ef          	jal	4d7a <sbrk>
  if (p != a) {
    2404:	0aa49463          	bne	s1,a0,24ac <sbrkmuch+0xd4>
  char *eee = sbrk(0);
    2408:	4501                	li	a0,0
    240a:	171020ef          	jal	4d7a <sbrk>
    240e:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2410:	00a4f963          	bgeu	s1,a0,2422 <sbrkmuch+0x4a>
    *pp = 1;
    2414:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2416:	6705                	lui	a4,0x1
    *pp = 1;
    2418:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    241c:	94ba                	add	s1,s1,a4
    241e:	fef4ede3          	bltu	s1,a5,2418 <sbrkmuch+0x40>
  *lastaddr = 99;
    2422:	064007b7          	lui	a5,0x6400
    2426:	06300713          	li	a4,99
    242a:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0387>
  a = sbrk(0);
    242e:	4501                	li	a0,0
    2430:	14b020ef          	jal	4d7a <sbrk>
    2434:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2436:	757d                	lui	a0,0xfffff
    2438:	143020ef          	jal	4d7a <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    243c:	57fd                	li	a5,-1
    243e:	08f50163          	beq	a0,a5,24c0 <sbrkmuch+0xe8>
  c = sbrk(0);
    2442:	4501                	li	a0,0
    2444:	137020ef          	jal	4d7a <sbrk>
  if(c != a - PGSIZE){
    2448:	77fd                	lui	a5,0xfffff
    244a:	97a6                	add	a5,a5,s1
    244c:	08f51463          	bne	a0,a5,24d4 <sbrkmuch+0xfc>
  a = sbrk(0);
    2450:	4501                	li	a0,0
    2452:	129020ef          	jal	4d7a <sbrk>
    2456:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2458:	6505                	lui	a0,0x1
    245a:	121020ef          	jal	4d7a <sbrk>
    245e:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2460:	08a49663          	bne	s1,a0,24ec <sbrkmuch+0x114>
    2464:	4501                	li	a0,0
    2466:	115020ef          	jal	4d7a <sbrk>
    246a:	6785                	lui	a5,0x1
    246c:	97a6                	add	a5,a5,s1
    246e:	06f51f63          	bne	a0,a5,24ec <sbrkmuch+0x114>
  if(*lastaddr == 99){
    2472:	064007b7          	lui	a5,0x6400
    2476:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0387>
    247a:	06300793          	li	a5,99
    247e:	08f70363          	beq	a4,a5,2504 <sbrkmuch+0x12c>
  a = sbrk(0);
    2482:	4501                	li	a0,0
    2484:	0f7020ef          	jal	4d7a <sbrk>
    2488:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    248a:	4501                	li	a0,0
    248c:	0ef020ef          	jal	4d7a <sbrk>
    2490:	40a9053b          	subw	a0,s2,a0
    2494:	0e7020ef          	jal	4d7a <sbrk>
  if(c != a){
    2498:	08a49063          	bne	s1,a0,2518 <sbrkmuch+0x140>
}
    249c:	70a2                	ld	ra,40(sp)
    249e:	7402                	ld	s0,32(sp)
    24a0:	64e2                	ld	s1,24(sp)
    24a2:	6942                	ld	s2,16(sp)
    24a4:	69a2                	ld	s3,8(sp)
    24a6:	6a02                	ld	s4,0(sp)
    24a8:	6145                	addi	sp,sp,48
    24aa:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    24ac:	85ce                	mv	a1,s3
    24ae:	00004517          	auipc	a0,0x4
    24b2:	cca50513          	addi	a0,a0,-822 # 6178 <malloc+0xfb4>
    24b6:	457020ef          	jal	510c <printf>
    exit(1);
    24ba:	4505                	li	a0,1
    24bc:	037020ef          	jal	4cf2 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    24c0:	85ce                	mv	a1,s3
    24c2:	00004517          	auipc	a0,0x4
    24c6:	cfe50513          	addi	a0,a0,-770 # 61c0 <malloc+0xffc>
    24ca:	443020ef          	jal	510c <printf>
    exit(1);
    24ce:	4505                	li	a0,1
    24d0:	023020ef          	jal	4cf2 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %p c %p\n", s, a, c);
    24d4:	86aa                	mv	a3,a0
    24d6:	8626                	mv	a2,s1
    24d8:	85ce                	mv	a1,s3
    24da:	00004517          	auipc	a0,0x4
    24de:	d0650513          	addi	a0,a0,-762 # 61e0 <malloc+0x101c>
    24e2:	42b020ef          	jal	510c <printf>
    exit(1);
    24e6:	4505                	li	a0,1
    24e8:	00b020ef          	jal	4cf2 <exit>
    printf("%s: sbrk re-allocation failed, a %p c %p\n", s, a, c);
    24ec:	86d2                	mv	a3,s4
    24ee:	8626                	mv	a2,s1
    24f0:	85ce                	mv	a1,s3
    24f2:	00004517          	auipc	a0,0x4
    24f6:	d2e50513          	addi	a0,a0,-722 # 6220 <malloc+0x105c>
    24fa:	413020ef          	jal	510c <printf>
    exit(1);
    24fe:	4505                	li	a0,1
    2500:	7f2020ef          	jal	4cf2 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2504:	85ce                	mv	a1,s3
    2506:	00004517          	auipc	a0,0x4
    250a:	d4a50513          	addi	a0,a0,-694 # 6250 <malloc+0x108c>
    250e:	3ff020ef          	jal	510c <printf>
    exit(1);
    2512:	4505                	li	a0,1
    2514:	7de020ef          	jal	4cf2 <exit>
    printf("%s: sbrk downsize failed, a %p c %p\n", s, a, c);
    2518:	86aa                	mv	a3,a0
    251a:	8626                	mv	a2,s1
    251c:	85ce                	mv	a1,s3
    251e:	00004517          	auipc	a0,0x4
    2522:	d6a50513          	addi	a0,a0,-662 # 6288 <malloc+0x10c4>
    2526:	3e7020ef          	jal	510c <printf>
    exit(1);
    252a:	4505                	li	a0,1
    252c:	7c6020ef          	jal	4cf2 <exit>

0000000000002530 <sbrkarg>:
{
    2530:	7179                	addi	sp,sp,-48
    2532:	f406                	sd	ra,40(sp)
    2534:	f022                	sd	s0,32(sp)
    2536:	ec26                	sd	s1,24(sp)
    2538:	e84a                	sd	s2,16(sp)
    253a:	e44e                	sd	s3,8(sp)
    253c:	1800                	addi	s0,sp,48
    253e:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2540:	6505                	lui	a0,0x1
    2542:	039020ef          	jal	4d7a <sbrk>
    2546:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2548:	20100593          	li	a1,513
    254c:	00004517          	auipc	a0,0x4
    2550:	d6450513          	addi	a0,a0,-668 # 62b0 <malloc+0x10ec>
    2554:	7de020ef          	jal	4d32 <open>
    2558:	84aa                	mv	s1,a0
  unlink("sbrk");
    255a:	00004517          	auipc	a0,0x4
    255e:	d5650513          	addi	a0,a0,-682 # 62b0 <malloc+0x10ec>
    2562:	7e0020ef          	jal	4d42 <unlink>
  if(fd < 0)  {
    2566:	0204c963          	bltz	s1,2598 <sbrkarg+0x68>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    256a:	6605                	lui	a2,0x1
    256c:	85ca                	mv	a1,s2
    256e:	8526                	mv	a0,s1
    2570:	7a2020ef          	jal	4d12 <write>
    2574:	02054c63          	bltz	a0,25ac <sbrkarg+0x7c>
  close(fd);
    2578:	8526                	mv	a0,s1
    257a:	7a0020ef          	jal	4d1a <close>
  a = sbrk(PGSIZE);
    257e:	6505                	lui	a0,0x1
    2580:	7fa020ef          	jal	4d7a <sbrk>
  if(pipe((int *) a) != 0){
    2584:	77e020ef          	jal	4d02 <pipe>
    2588:	ed05                	bnez	a0,25c0 <sbrkarg+0x90>
}
    258a:	70a2                	ld	ra,40(sp)
    258c:	7402                	ld	s0,32(sp)
    258e:	64e2                	ld	s1,24(sp)
    2590:	6942                	ld	s2,16(sp)
    2592:	69a2                	ld	s3,8(sp)
    2594:	6145                	addi	sp,sp,48
    2596:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2598:	85ce                	mv	a1,s3
    259a:	00004517          	auipc	a0,0x4
    259e:	d1e50513          	addi	a0,a0,-738 # 62b8 <malloc+0x10f4>
    25a2:	36b020ef          	jal	510c <printf>
    exit(1);
    25a6:	4505                	li	a0,1
    25a8:	74a020ef          	jal	4cf2 <exit>
    printf("%s: write sbrk failed\n", s);
    25ac:	85ce                	mv	a1,s3
    25ae:	00004517          	auipc	a0,0x4
    25b2:	d2250513          	addi	a0,a0,-734 # 62d0 <malloc+0x110c>
    25b6:	357020ef          	jal	510c <printf>
    exit(1);
    25ba:	4505                	li	a0,1
    25bc:	736020ef          	jal	4cf2 <exit>
    printf("%s: pipe() failed\n", s);
    25c0:	85ce                	mv	a1,s3
    25c2:	00003517          	auipc	a0,0x3
    25c6:	6ce50513          	addi	a0,a0,1742 # 5c90 <malloc+0xacc>
    25ca:	343020ef          	jal	510c <printf>
    exit(1);
    25ce:	4505                	li	a0,1
    25d0:	722020ef          	jal	4cf2 <exit>

00000000000025d4 <argptest>:
{
    25d4:	1101                	addi	sp,sp,-32
    25d6:	ec06                	sd	ra,24(sp)
    25d8:	e822                	sd	s0,16(sp)
    25da:	e426                	sd	s1,8(sp)
    25dc:	e04a                	sd	s2,0(sp)
    25de:	1000                	addi	s0,sp,32
    25e0:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    25e2:	4581                	li	a1,0
    25e4:	00004517          	auipc	a0,0x4
    25e8:	d0450513          	addi	a0,a0,-764 # 62e8 <malloc+0x1124>
    25ec:	746020ef          	jal	4d32 <open>
  if (fd < 0) {
    25f0:	02054563          	bltz	a0,261a <argptest+0x46>
    25f4:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    25f6:	4501                	li	a0,0
    25f8:	782020ef          	jal	4d7a <sbrk>
    25fc:	567d                	li	a2,-1
    25fe:	00c505b3          	add	a1,a0,a2
    2602:	8526                	mv	a0,s1
    2604:	706020ef          	jal	4d0a <read>
  close(fd);
    2608:	8526                	mv	a0,s1
    260a:	710020ef          	jal	4d1a <close>
}
    260e:	60e2                	ld	ra,24(sp)
    2610:	6442                	ld	s0,16(sp)
    2612:	64a2                	ld	s1,8(sp)
    2614:	6902                	ld	s2,0(sp)
    2616:	6105                	addi	sp,sp,32
    2618:	8082                	ret
    printf("%s: open failed\n", s);
    261a:	85ca                	mv	a1,s2
    261c:	00003517          	auipc	a0,0x3
    2620:	58450513          	addi	a0,a0,1412 # 5ba0 <malloc+0x9dc>
    2624:	2e9020ef          	jal	510c <printf>
    exit(1);
    2628:	4505                	li	a0,1
    262a:	6c8020ef          	jal	4cf2 <exit>

000000000000262e <sbrkbugs>:
{
    262e:	1141                	addi	sp,sp,-16
    2630:	e406                	sd	ra,8(sp)
    2632:	e022                	sd	s0,0(sp)
    2634:	0800                	addi	s0,sp,16
  int pid = fork();
    2636:	6b4020ef          	jal	4cea <fork>
  if(pid < 0){
    263a:	00054c63          	bltz	a0,2652 <sbrkbugs+0x24>
  if(pid == 0){
    263e:	e11d                	bnez	a0,2664 <sbrkbugs+0x36>
    int sz = (uint64) sbrk(0);
    2640:	73a020ef          	jal	4d7a <sbrk>
    sbrk(-sz);
    2644:	40a0053b          	negw	a0,a0
    2648:	732020ef          	jal	4d7a <sbrk>
    exit(0);
    264c:	4501                	li	a0,0
    264e:	6a4020ef          	jal	4cf2 <exit>
    printf("fork failed\n");
    2652:	00004517          	auipc	a0,0x4
    2656:	93e50513          	addi	a0,a0,-1730 # 5f90 <malloc+0xdcc>
    265a:	2b3020ef          	jal	510c <printf>
    exit(1);
    265e:	4505                	li	a0,1
    2660:	692020ef          	jal	4cf2 <exit>
  wait(0);
    2664:	4501                	li	a0,0
    2666:	694020ef          	jal	4cfa <wait>
  pid = fork();
    266a:	680020ef          	jal	4cea <fork>
  if(pid < 0){
    266e:	00054f63          	bltz	a0,268c <sbrkbugs+0x5e>
  if(pid == 0){
    2672:	e515                	bnez	a0,269e <sbrkbugs+0x70>
    int sz = (uint64) sbrk(0);
    2674:	706020ef          	jal	4d7a <sbrk>
    sbrk(-(sz - 3500));
    2678:	6785                	lui	a5,0x1
    267a:	dac7879b          	addiw	a5,a5,-596 # dac <linktest+0xe0>
    267e:	40a7853b          	subw	a0,a5,a0
    2682:	6f8020ef          	jal	4d7a <sbrk>
    exit(0);
    2686:	4501                	li	a0,0
    2688:	66a020ef          	jal	4cf2 <exit>
    printf("fork failed\n");
    268c:	00004517          	auipc	a0,0x4
    2690:	90450513          	addi	a0,a0,-1788 # 5f90 <malloc+0xdcc>
    2694:	279020ef          	jal	510c <printf>
    exit(1);
    2698:	4505                	li	a0,1
    269a:	658020ef          	jal	4cf2 <exit>
  wait(0);
    269e:	4501                	li	a0,0
    26a0:	65a020ef          	jal	4cfa <wait>
  pid = fork();
    26a4:	646020ef          	jal	4cea <fork>
  if(pid < 0){
    26a8:	02054263          	bltz	a0,26cc <sbrkbugs+0x9e>
  if(pid == 0){
    26ac:	e90d                	bnez	a0,26de <sbrkbugs+0xb0>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    26ae:	6cc020ef          	jal	4d7a <sbrk>
    26b2:	67ad                	lui	a5,0xb
    26b4:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x298>
    26b8:	40a7853b          	subw	a0,a5,a0
    26bc:	6be020ef          	jal	4d7a <sbrk>
    sbrk(-10);
    26c0:	5559                	li	a0,-10
    26c2:	6b8020ef          	jal	4d7a <sbrk>
    exit(0);
    26c6:	4501                	li	a0,0
    26c8:	62a020ef          	jal	4cf2 <exit>
    printf("fork failed\n");
    26cc:	00004517          	auipc	a0,0x4
    26d0:	8c450513          	addi	a0,a0,-1852 # 5f90 <malloc+0xdcc>
    26d4:	239020ef          	jal	510c <printf>
    exit(1);
    26d8:	4505                	li	a0,1
    26da:	618020ef          	jal	4cf2 <exit>
  wait(0);
    26de:	4501                	li	a0,0
    26e0:	61a020ef          	jal	4cfa <wait>
  exit(0);
    26e4:	4501                	li	a0,0
    26e6:	60c020ef          	jal	4cf2 <exit>

00000000000026ea <sbrklast>:
{
    26ea:	7179                	addi	sp,sp,-48
    26ec:	f406                	sd	ra,40(sp)
    26ee:	f022                	sd	s0,32(sp)
    26f0:	ec26                	sd	s1,24(sp)
    26f2:	e84a                	sd	s2,16(sp)
    26f4:	e44e                	sd	s3,8(sp)
    26f6:	e052                	sd	s4,0(sp)
    26f8:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    26fa:	4501                	li	a0,0
    26fc:	67e020ef          	jal	4d7a <sbrk>
  if((top % 4096) != 0)
    2700:	03451793          	slli	a5,a0,0x34
    2704:	ebad                	bnez	a5,2776 <sbrklast+0x8c>
  sbrk(4096);
    2706:	6505                	lui	a0,0x1
    2708:	672020ef          	jal	4d7a <sbrk>
  sbrk(10);
    270c:	4529                	li	a0,10
    270e:	66c020ef          	jal	4d7a <sbrk>
  sbrk(-20);
    2712:	5531                	li	a0,-20
    2714:	666020ef          	jal	4d7a <sbrk>
  top = (uint64) sbrk(0);
    2718:	4501                	li	a0,0
    271a:	660020ef          	jal	4d7a <sbrk>
    271e:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2720:	fc050913          	addi	s2,a0,-64 # fc0 <bigdir+0xca>
  p[0] = 'x';
    2724:	07800a13          	li	s4,120
    2728:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    272c:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2730:	20200593          	li	a1,514
    2734:	854a                	mv	a0,s2
    2736:	5fc020ef          	jal	4d32 <open>
    273a:	89aa                	mv	s3,a0
  write(fd, p, 1);
    273c:	4605                	li	a2,1
    273e:	85ca                	mv	a1,s2
    2740:	5d2020ef          	jal	4d12 <write>
  close(fd);
    2744:	854e                	mv	a0,s3
    2746:	5d4020ef          	jal	4d1a <close>
  fd = open(p, O_RDWR);
    274a:	4589                	li	a1,2
    274c:	854a                	mv	a0,s2
    274e:	5e4020ef          	jal	4d32 <open>
  p[0] = '\0';
    2752:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2756:	4605                	li	a2,1
    2758:	85ca                	mv	a1,s2
    275a:	5b0020ef          	jal	4d0a <read>
  if(p[0] != 'x')
    275e:	fc04c783          	lbu	a5,-64(s1)
    2762:	03479363          	bne	a5,s4,2788 <sbrklast+0x9e>
}
    2766:	70a2                	ld	ra,40(sp)
    2768:	7402                	ld	s0,32(sp)
    276a:	64e2                	ld	s1,24(sp)
    276c:	6942                	ld	s2,16(sp)
    276e:	69a2                	ld	s3,8(sp)
    2770:	6a02                	ld	s4,0(sp)
    2772:	6145                	addi	sp,sp,48
    2774:	8082                	ret
    sbrk(4096 - (top % 4096));
    2776:	6785                	lui	a5,0x1
    2778:	fff78713          	addi	a4,a5,-1 # fff <bigdir+0x109>
    277c:	8d79                	and	a0,a0,a4
    277e:	40a7853b          	subw	a0,a5,a0
    2782:	5f8020ef          	jal	4d7a <sbrk>
    2786:	b741                	j	2706 <sbrklast+0x1c>
    exit(1);
    2788:	4505                	li	a0,1
    278a:	568020ef          	jal	4cf2 <exit>

000000000000278e <sbrk8000>:
{
    278e:	1141                	addi	sp,sp,-16
    2790:	e406                	sd	ra,8(sp)
    2792:	e022                	sd	s0,0(sp)
    2794:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2796:	80000537          	lui	a0,0x80000
    279a:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff038c>
    279c:	5de020ef          	jal	4d7a <sbrk>
  volatile char *top = sbrk(0);
    27a0:	4501                	li	a0,0
    27a2:	5d8020ef          	jal	4d7a <sbrk>
  *(top-1) = *(top-1) + 1;
    27a6:	fff54783          	lbu	a5,-1(a0)
    27aa:	0785                	addi	a5,a5,1
    27ac:	0ff7f793          	zext.b	a5,a5
    27b0:	fef50fa3          	sb	a5,-1(a0)
}
    27b4:	60a2                	ld	ra,8(sp)
    27b6:	6402                	ld	s0,0(sp)
    27b8:	0141                	addi	sp,sp,16
    27ba:	8082                	ret

00000000000027bc <execout>:
{
    27bc:	711d                	addi	sp,sp,-96
    27be:	ec86                	sd	ra,88(sp)
    27c0:	e8a2                	sd	s0,80(sp)
    27c2:	e4a6                	sd	s1,72(sp)
    27c4:	e0ca                	sd	s2,64(sp)
    27c6:	fc4e                	sd	s3,56(sp)
    27c8:	1080                	addi	s0,sp,96
  for(int avail = 0; avail < 15; avail++){
    27ca:	4901                	li	s2,0
    27cc:	49bd                	li	s3,15
    int pid = fork();
    27ce:	51c020ef          	jal	4cea <fork>
    27d2:	84aa                	mv	s1,a0
    if(pid < 0){
    27d4:	00054e63          	bltz	a0,27f0 <execout+0x34>
    } else if(pid == 0){
    27d8:	c51d                	beqz	a0,2806 <execout+0x4a>
      wait((int*)0);
    27da:	4501                	li	a0,0
    27dc:	51e020ef          	jal	4cfa <wait>
  for(int avail = 0; avail < 15; avail++){
    27e0:	2905                	addiw	s2,s2,1
    27e2:	ff3916e3          	bne	s2,s3,27ce <execout+0x12>
    27e6:	f852                	sd	s4,48(sp)
    27e8:	f456                	sd	s5,40(sp)
  exit(0);
    27ea:	4501                	li	a0,0
    27ec:	506020ef          	jal	4cf2 <exit>
    27f0:	f852                	sd	s4,48(sp)
    27f2:	f456                	sd	s5,40(sp)
      printf("fork failed\n");
    27f4:	00003517          	auipc	a0,0x3
    27f8:	79c50513          	addi	a0,a0,1948 # 5f90 <malloc+0xdcc>
    27fc:	111020ef          	jal	510c <printf>
      exit(1);
    2800:	4505                	li	a0,1
    2802:	4f0020ef          	jal	4cf2 <exit>
    2806:	f852                	sd	s4,48(sp)
    2808:	f456                	sd	s5,40(sp)
        uint64 a = (uint64) sbrk(4096);
    280a:	6985                	lui	s3,0x1
        if(a == 0xffffffffffffffffLL)
    280c:	5a7d                	li	s4,-1
        *(char*)(a + 4096 - 1) = 1;
    280e:	4a85                	li	s5,1
        uint64 a = (uint64) sbrk(4096);
    2810:	854e                	mv	a0,s3
    2812:	568020ef          	jal	4d7a <sbrk>
        if(a == 0xffffffffffffffffLL)
    2816:	01450663          	beq	a0,s4,2822 <execout+0x66>
        *(char*)(a + 4096 - 1) = 1;
    281a:	954e                	add	a0,a0,s3
    281c:	ff550fa3          	sb	s5,-1(a0)
      while(1){
    2820:	bfc5                	j	2810 <execout+0x54>
        sbrk(-4096);
    2822:	79fd                	lui	s3,0xfffff
      for(int i = 0; i < avail; i++)
    2824:	01205863          	blez	s2,2834 <execout+0x78>
        sbrk(-4096);
    2828:	854e                	mv	a0,s3
    282a:	550020ef          	jal	4d7a <sbrk>
      for(int i = 0; i < avail; i++)
    282e:	2485                	addiw	s1,s1,1
    2830:	ff249ce3          	bne	s1,s2,2828 <execout+0x6c>
      close(1);
    2834:	4505                	li	a0,1
    2836:	4e4020ef          	jal	4d1a <close>
      char *args[] = { "echo", "x", 0 };
    283a:	00003517          	auipc	a0,0x3
    283e:	abe50513          	addi	a0,a0,-1346 # 52f8 <malloc+0x134>
    2842:	faa43423          	sd	a0,-88(s0)
    2846:	00003797          	auipc	a5,0x3
    284a:	b2278793          	addi	a5,a5,-1246 # 5368 <malloc+0x1a4>
    284e:	faf43823          	sd	a5,-80(s0)
    2852:	fa043c23          	sd	zero,-72(s0)
      exec("echo", args);
    2856:	fa840593          	addi	a1,s0,-88
    285a:	4d0020ef          	jal	4d2a <exec>
      exit(0);
    285e:	4501                	li	a0,0
    2860:	492020ef          	jal	4cf2 <exit>

0000000000002864 <fourteen>:
{
    2864:	1101                	addi	sp,sp,-32
    2866:	ec06                	sd	ra,24(sp)
    2868:	e822                	sd	s0,16(sp)
    286a:	e426                	sd	s1,8(sp)
    286c:	1000                	addi	s0,sp,32
    286e:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2870:	00004517          	auipc	a0,0x4
    2874:	c5050513          	addi	a0,a0,-944 # 64c0 <malloc+0x12fc>
    2878:	4e2020ef          	jal	4d5a <mkdir>
    287c:	e555                	bnez	a0,2928 <fourteen+0xc4>
  if(mkdir("12345678901234/123456789012345") != 0){
    287e:	00004517          	auipc	a0,0x4
    2882:	a9a50513          	addi	a0,a0,-1382 # 6318 <malloc+0x1154>
    2886:	4d4020ef          	jal	4d5a <mkdir>
    288a:	e94d                	bnez	a0,293c <fourteen+0xd8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    288c:	20000593          	li	a1,512
    2890:	00004517          	auipc	a0,0x4
    2894:	ae050513          	addi	a0,a0,-1312 # 6370 <malloc+0x11ac>
    2898:	49a020ef          	jal	4d32 <open>
  if(fd < 0){
    289c:	0a054a63          	bltz	a0,2950 <fourteen+0xec>
  close(fd);
    28a0:	47a020ef          	jal	4d1a <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    28a4:	4581                	li	a1,0
    28a6:	00004517          	auipc	a0,0x4
    28aa:	b4250513          	addi	a0,a0,-1214 # 63e8 <malloc+0x1224>
    28ae:	484020ef          	jal	4d32 <open>
  if(fd < 0){
    28b2:	0a054963          	bltz	a0,2964 <fourteen+0x100>
  close(fd);
    28b6:	464020ef          	jal	4d1a <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    28ba:	00004517          	auipc	a0,0x4
    28be:	b9e50513          	addi	a0,a0,-1122 # 6458 <malloc+0x1294>
    28c2:	498020ef          	jal	4d5a <mkdir>
    28c6:	c94d                	beqz	a0,2978 <fourteen+0x114>
  if(mkdir("123456789012345/12345678901234") == 0){
    28c8:	00004517          	auipc	a0,0x4
    28cc:	be850513          	addi	a0,a0,-1048 # 64b0 <malloc+0x12ec>
    28d0:	48a020ef          	jal	4d5a <mkdir>
    28d4:	cd45                	beqz	a0,298c <fourteen+0x128>
  unlink("123456789012345/12345678901234");
    28d6:	00004517          	auipc	a0,0x4
    28da:	bda50513          	addi	a0,a0,-1062 # 64b0 <malloc+0x12ec>
    28de:	464020ef          	jal	4d42 <unlink>
  unlink("12345678901234/12345678901234");
    28e2:	00004517          	auipc	a0,0x4
    28e6:	b7650513          	addi	a0,a0,-1162 # 6458 <malloc+0x1294>
    28ea:	458020ef          	jal	4d42 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    28ee:	00004517          	auipc	a0,0x4
    28f2:	afa50513          	addi	a0,a0,-1286 # 63e8 <malloc+0x1224>
    28f6:	44c020ef          	jal	4d42 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    28fa:	00004517          	auipc	a0,0x4
    28fe:	a7650513          	addi	a0,a0,-1418 # 6370 <malloc+0x11ac>
    2902:	440020ef          	jal	4d42 <unlink>
  unlink("12345678901234/123456789012345");
    2906:	00004517          	auipc	a0,0x4
    290a:	a1250513          	addi	a0,a0,-1518 # 6318 <malloc+0x1154>
    290e:	434020ef          	jal	4d42 <unlink>
  unlink("12345678901234");
    2912:	00004517          	auipc	a0,0x4
    2916:	bae50513          	addi	a0,a0,-1106 # 64c0 <malloc+0x12fc>
    291a:	428020ef          	jal	4d42 <unlink>
}
    291e:	60e2                	ld	ra,24(sp)
    2920:	6442                	ld	s0,16(sp)
    2922:	64a2                	ld	s1,8(sp)
    2924:	6105                	addi	sp,sp,32
    2926:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2928:	85a6                	mv	a1,s1
    292a:	00004517          	auipc	a0,0x4
    292e:	9c650513          	addi	a0,a0,-1594 # 62f0 <malloc+0x112c>
    2932:	7da020ef          	jal	510c <printf>
    exit(1);
    2936:	4505                	li	a0,1
    2938:	3ba020ef          	jal	4cf2 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    293c:	85a6                	mv	a1,s1
    293e:	00004517          	auipc	a0,0x4
    2942:	9fa50513          	addi	a0,a0,-1542 # 6338 <malloc+0x1174>
    2946:	7c6020ef          	jal	510c <printf>
    exit(1);
    294a:	4505                	li	a0,1
    294c:	3a6020ef          	jal	4cf2 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2950:	85a6                	mv	a1,s1
    2952:	00004517          	auipc	a0,0x4
    2956:	a4e50513          	addi	a0,a0,-1458 # 63a0 <malloc+0x11dc>
    295a:	7b2020ef          	jal	510c <printf>
    exit(1);
    295e:	4505                	li	a0,1
    2960:	392020ef          	jal	4cf2 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2964:	85a6                	mv	a1,s1
    2966:	00004517          	auipc	a0,0x4
    296a:	ab250513          	addi	a0,a0,-1358 # 6418 <malloc+0x1254>
    296e:	79e020ef          	jal	510c <printf>
    exit(1);
    2972:	4505                	li	a0,1
    2974:	37e020ef          	jal	4cf2 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2978:	85a6                	mv	a1,s1
    297a:	00004517          	auipc	a0,0x4
    297e:	afe50513          	addi	a0,a0,-1282 # 6478 <malloc+0x12b4>
    2982:	78a020ef          	jal	510c <printf>
    exit(1);
    2986:	4505                	li	a0,1
    2988:	36a020ef          	jal	4cf2 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    298c:	85a6                	mv	a1,s1
    298e:	00004517          	auipc	a0,0x4
    2992:	b4250513          	addi	a0,a0,-1214 # 64d0 <malloc+0x130c>
    2996:	776020ef          	jal	510c <printf>
    exit(1);
    299a:	4505                	li	a0,1
    299c:	356020ef          	jal	4cf2 <exit>

00000000000029a0 <diskfull>:
{
    29a0:	b6010113          	addi	sp,sp,-1184
    29a4:	48113c23          	sd	ra,1176(sp)
    29a8:	48813823          	sd	s0,1168(sp)
    29ac:	48913423          	sd	s1,1160(sp)
    29b0:	49213023          	sd	s2,1152(sp)
    29b4:	47313c23          	sd	s3,1144(sp)
    29b8:	47413823          	sd	s4,1136(sp)
    29bc:	47513423          	sd	s5,1128(sp)
    29c0:	47613023          	sd	s6,1120(sp)
    29c4:	45713c23          	sd	s7,1112(sp)
    29c8:	45813823          	sd	s8,1104(sp)
    29cc:	45913423          	sd	s9,1096(sp)
    29d0:	45a13023          	sd	s10,1088(sp)
    29d4:	43b13c23          	sd	s11,1080(sp)
    29d8:	4a010413          	addi	s0,sp,1184
    29dc:	b6a43423          	sd	a0,-1176(s0)
  unlink("diskfulldir");
    29e0:	00004517          	auipc	a0,0x4
    29e4:	b2850513          	addi	a0,a0,-1240 # 6508 <malloc+0x1344>
    29e8:	35a020ef          	jal	4d42 <unlink>
    29ec:	03000a93          	li	s5,48
    name[0] = 'b';
    29f0:	06200d13          	li	s10,98
    name[1] = 'i';
    29f4:	06900c93          	li	s9,105
    name[2] = 'g';
    29f8:	06700c13          	li	s8,103
    unlink(name);
    29fc:	b7040b13          	addi	s6,s0,-1168
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    2a00:	60200b93          	li	s7,1538
    2a04:	10c00d93          	li	s11,268
      if(write(fd, buf, BSIZE) != BSIZE){
    2a08:	b9040a13          	addi	s4,s0,-1136
    2a0c:	aa8d                	j	2b7e <diskfull+0x1de>
      printf("%s: could not create file %s\n", s, name);
    2a0e:	b7040613          	addi	a2,s0,-1168
    2a12:	b6843583          	ld	a1,-1176(s0)
    2a16:	00004517          	auipc	a0,0x4
    2a1a:	b0250513          	addi	a0,a0,-1278 # 6518 <malloc+0x1354>
    2a1e:	6ee020ef          	jal	510c <printf>
      break;
    2a22:	a039                	j	2a30 <diskfull+0x90>
        close(fd);
    2a24:	854e                	mv	a0,s3
    2a26:	2f4020ef          	jal	4d1a <close>
    close(fd);
    2a2a:	854e                	mv	a0,s3
    2a2c:	2ee020ef          	jal	4d1a <close>
  for(int i = 0; i < nzz; i++){
    2a30:	4481                	li	s1,0
    name[0] = 'z';
    2a32:	07a00993          	li	s3,122
    unlink(name);
    2a36:	b9040913          	addi	s2,s0,-1136
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    2a3a:	60200a13          	li	s4,1538
  for(int i = 0; i < nzz; i++){
    2a3e:	08000a93          	li	s5,128
    name[0] = 'z';
    2a42:	b9340823          	sb	s3,-1136(s0)
    name[1] = 'z';
    2a46:	b93408a3          	sb	s3,-1135(s0)
    name[2] = '0' + (i / 32);
    2a4a:	41f4d71b          	sraiw	a4,s1,0x1f
    2a4e:	01b7571b          	srliw	a4,a4,0x1b
    2a52:	009707bb          	addw	a5,a4,s1
    2a56:	4057d69b          	sraiw	a3,a5,0x5
    2a5a:	0306869b          	addiw	a3,a3,48
    2a5e:	b8d40923          	sb	a3,-1134(s0)
    name[3] = '0' + (i % 32);
    2a62:	8bfd                	andi	a5,a5,31
    2a64:	9f99                	subw	a5,a5,a4
    2a66:	0307879b          	addiw	a5,a5,48
    2a6a:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    2a6e:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    2a72:	854a                	mv	a0,s2
    2a74:	2ce020ef          	jal	4d42 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    2a78:	85d2                	mv	a1,s4
    2a7a:	854a                	mv	a0,s2
    2a7c:	2b6020ef          	jal	4d32 <open>
    if(fd < 0)
    2a80:	00054763          	bltz	a0,2a8e <diskfull+0xee>
    close(fd);
    2a84:	296020ef          	jal	4d1a <close>
  for(int i = 0; i < nzz; i++){
    2a88:	2485                	addiw	s1,s1,1
    2a8a:	fb549ce3          	bne	s1,s5,2a42 <diskfull+0xa2>
  if(mkdir("diskfulldir") == 0)
    2a8e:	00004517          	auipc	a0,0x4
    2a92:	a7a50513          	addi	a0,a0,-1414 # 6508 <malloc+0x1344>
    2a96:	2c4020ef          	jal	4d5a <mkdir>
    2a9a:	12050363          	beqz	a0,2bc0 <diskfull+0x220>
  unlink("diskfulldir");
    2a9e:	00004517          	auipc	a0,0x4
    2aa2:	a6a50513          	addi	a0,a0,-1430 # 6508 <malloc+0x1344>
    2aa6:	29c020ef          	jal	4d42 <unlink>
  for(int i = 0; i < nzz; i++){
    2aaa:	4481                	li	s1,0
    name[0] = 'z';
    2aac:	07a00913          	li	s2,122
    unlink(name);
    2ab0:	b9040a13          	addi	s4,s0,-1136
  for(int i = 0; i < nzz; i++){
    2ab4:	08000993          	li	s3,128
    name[0] = 'z';
    2ab8:	b9240823          	sb	s2,-1136(s0)
    name[1] = 'z';
    2abc:	b92408a3          	sb	s2,-1135(s0)
    name[2] = '0' + (i / 32);
    2ac0:	41f4d71b          	sraiw	a4,s1,0x1f
    2ac4:	01b7571b          	srliw	a4,a4,0x1b
    2ac8:	009707bb          	addw	a5,a4,s1
    2acc:	4057d69b          	sraiw	a3,a5,0x5
    2ad0:	0306869b          	addiw	a3,a3,48
    2ad4:	b8d40923          	sb	a3,-1134(s0)
    name[3] = '0' + (i % 32);
    2ad8:	8bfd                	andi	a5,a5,31
    2ada:	9f99                	subw	a5,a5,a4
    2adc:	0307879b          	addiw	a5,a5,48
    2ae0:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    2ae4:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    2ae8:	8552                	mv	a0,s4
    2aea:	258020ef          	jal	4d42 <unlink>
  for(int i = 0; i < nzz; i++){
    2aee:	2485                	addiw	s1,s1,1
    2af0:	fd3494e3          	bne	s1,s3,2ab8 <diskfull+0x118>
    2af4:	03000493          	li	s1,48
    name[0] = 'b';
    2af8:	06200b13          	li	s6,98
    name[1] = 'i';
    2afc:	06900a93          	li	s5,105
    name[2] = 'g';
    2b00:	06700a13          	li	s4,103
    unlink(name);
    2b04:	b9040993          	addi	s3,s0,-1136
  for(int i = 0; '0' + i < 0177; i++){
    2b08:	07f00913          	li	s2,127
    name[0] = 'b';
    2b0c:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    2b10:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    2b14:	b9440923          	sb	s4,-1134(s0)
    name[3] = '0' + i;
    2b18:	b89409a3          	sb	s1,-1133(s0)
    name[4] = '\0';
    2b1c:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    2b20:	854e                	mv	a0,s3
    2b22:	220020ef          	jal	4d42 <unlink>
  for(int i = 0; '0' + i < 0177; i++){
    2b26:	2485                	addiw	s1,s1,1
    2b28:	0ff4f493          	zext.b	s1,s1
    2b2c:	ff2490e3          	bne	s1,s2,2b0c <diskfull+0x16c>
}
    2b30:	49813083          	ld	ra,1176(sp)
    2b34:	49013403          	ld	s0,1168(sp)
    2b38:	48813483          	ld	s1,1160(sp)
    2b3c:	48013903          	ld	s2,1152(sp)
    2b40:	47813983          	ld	s3,1144(sp)
    2b44:	47013a03          	ld	s4,1136(sp)
    2b48:	46813a83          	ld	s5,1128(sp)
    2b4c:	46013b03          	ld	s6,1120(sp)
    2b50:	45813b83          	ld	s7,1112(sp)
    2b54:	45013c03          	ld	s8,1104(sp)
    2b58:	44813c83          	ld	s9,1096(sp)
    2b5c:	44013d03          	ld	s10,1088(sp)
    2b60:	43813d83          	ld	s11,1080(sp)
    2b64:	4a010113          	addi	sp,sp,1184
    2b68:	8082                	ret
    close(fd);
    2b6a:	854e                	mv	a0,s3
    2b6c:	1ae020ef          	jal	4d1a <close>
  for(fi = 0; done == 0 && '0' + fi < 0177; fi++){
    2b70:	2a85                	addiw	s5,s5,1
    2b72:	0ffafa93          	zext.b	s5,s5
    2b76:	07f00793          	li	a5,127
    2b7a:	eafa8be3          	beq	s5,a5,2a30 <diskfull+0x90>
    name[0] = 'b';
    2b7e:	b7a40823          	sb	s10,-1168(s0)
    name[1] = 'i';
    2b82:	b79408a3          	sb	s9,-1167(s0)
    name[2] = 'g';
    2b86:	b7840923          	sb	s8,-1166(s0)
    name[3] = '0' + fi;
    2b8a:	b75409a3          	sb	s5,-1165(s0)
    name[4] = '\0';
    2b8e:	b6040a23          	sb	zero,-1164(s0)
    unlink(name);
    2b92:	855a                	mv	a0,s6
    2b94:	1ae020ef          	jal	4d42 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    2b98:	85de                	mv	a1,s7
    2b9a:	855a                	mv	a0,s6
    2b9c:	196020ef          	jal	4d32 <open>
    2ba0:	89aa                	mv	s3,a0
    if(fd < 0){
    2ba2:	e60546e3          	bltz	a0,2a0e <diskfull+0x6e>
    2ba6:	84ee                	mv	s1,s11
      if(write(fd, buf, BSIZE) != BSIZE){
    2ba8:	40000913          	li	s2,1024
    2bac:	864a                	mv	a2,s2
    2bae:	85d2                	mv	a1,s4
    2bb0:	854e                	mv	a0,s3
    2bb2:	160020ef          	jal	4d12 <write>
    2bb6:	e72517e3          	bne	a0,s2,2a24 <diskfull+0x84>
    for(int i = 0; i < MAXFILE; i++){
    2bba:	34fd                	addiw	s1,s1,-1
    2bbc:	f8e5                	bnez	s1,2bac <diskfull+0x20c>
    2bbe:	b775                	j	2b6a <diskfull+0x1ca>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n", s);
    2bc0:	b6843583          	ld	a1,-1176(s0)
    2bc4:	00004517          	auipc	a0,0x4
    2bc8:	97450513          	addi	a0,a0,-1676 # 6538 <malloc+0x1374>
    2bcc:	540020ef          	jal	510c <printf>
    2bd0:	b5f9                	j	2a9e <diskfull+0xfe>

0000000000002bd2 <iputtest>:
{
    2bd2:	1101                	addi	sp,sp,-32
    2bd4:	ec06                	sd	ra,24(sp)
    2bd6:	e822                	sd	s0,16(sp)
    2bd8:	e426                	sd	s1,8(sp)
    2bda:	1000                	addi	s0,sp,32
    2bdc:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2bde:	00004517          	auipc	a0,0x4
    2be2:	98a50513          	addi	a0,a0,-1654 # 6568 <malloc+0x13a4>
    2be6:	174020ef          	jal	4d5a <mkdir>
    2bea:	02054f63          	bltz	a0,2c28 <iputtest+0x56>
  if(chdir("iputdir") < 0){
    2bee:	00004517          	auipc	a0,0x4
    2bf2:	97a50513          	addi	a0,a0,-1670 # 6568 <malloc+0x13a4>
    2bf6:	16c020ef          	jal	4d62 <chdir>
    2bfa:	04054163          	bltz	a0,2c3c <iputtest+0x6a>
  if(unlink("../iputdir") < 0){
    2bfe:	00004517          	auipc	a0,0x4
    2c02:	9aa50513          	addi	a0,a0,-1622 # 65a8 <malloc+0x13e4>
    2c06:	13c020ef          	jal	4d42 <unlink>
    2c0a:	04054363          	bltz	a0,2c50 <iputtest+0x7e>
  if(chdir("/") < 0){
    2c0e:	00004517          	auipc	a0,0x4
    2c12:	9ca50513          	addi	a0,a0,-1590 # 65d8 <malloc+0x1414>
    2c16:	14c020ef          	jal	4d62 <chdir>
    2c1a:	04054563          	bltz	a0,2c64 <iputtest+0x92>
}
    2c1e:	60e2                	ld	ra,24(sp)
    2c20:	6442                	ld	s0,16(sp)
    2c22:	64a2                	ld	s1,8(sp)
    2c24:	6105                	addi	sp,sp,32
    2c26:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2c28:	85a6                	mv	a1,s1
    2c2a:	00004517          	auipc	a0,0x4
    2c2e:	94650513          	addi	a0,a0,-1722 # 6570 <malloc+0x13ac>
    2c32:	4da020ef          	jal	510c <printf>
    exit(1);
    2c36:	4505                	li	a0,1
    2c38:	0ba020ef          	jal	4cf2 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2c3c:	85a6                	mv	a1,s1
    2c3e:	00004517          	auipc	a0,0x4
    2c42:	94a50513          	addi	a0,a0,-1718 # 6588 <malloc+0x13c4>
    2c46:	4c6020ef          	jal	510c <printf>
    exit(1);
    2c4a:	4505                	li	a0,1
    2c4c:	0a6020ef          	jal	4cf2 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2c50:	85a6                	mv	a1,s1
    2c52:	00004517          	auipc	a0,0x4
    2c56:	96650513          	addi	a0,a0,-1690 # 65b8 <malloc+0x13f4>
    2c5a:	4b2020ef          	jal	510c <printf>
    exit(1);
    2c5e:	4505                	li	a0,1
    2c60:	092020ef          	jal	4cf2 <exit>
    printf("%s: chdir / failed\n", s);
    2c64:	85a6                	mv	a1,s1
    2c66:	00004517          	auipc	a0,0x4
    2c6a:	97a50513          	addi	a0,a0,-1670 # 65e0 <malloc+0x141c>
    2c6e:	49e020ef          	jal	510c <printf>
    exit(1);
    2c72:	4505                	li	a0,1
    2c74:	07e020ef          	jal	4cf2 <exit>

0000000000002c78 <exitiputtest>:
{
    2c78:	7179                	addi	sp,sp,-48
    2c7a:	f406                	sd	ra,40(sp)
    2c7c:	f022                	sd	s0,32(sp)
    2c7e:	ec26                	sd	s1,24(sp)
    2c80:	1800                	addi	s0,sp,48
    2c82:	84aa                	mv	s1,a0
  pid = fork();
    2c84:	066020ef          	jal	4cea <fork>
  if(pid < 0){
    2c88:	02054e63          	bltz	a0,2cc4 <exitiputtest+0x4c>
  if(pid == 0){
    2c8c:	e541                	bnez	a0,2d14 <exitiputtest+0x9c>
    if(mkdir("iputdir") < 0){
    2c8e:	00004517          	auipc	a0,0x4
    2c92:	8da50513          	addi	a0,a0,-1830 # 6568 <malloc+0x13a4>
    2c96:	0c4020ef          	jal	4d5a <mkdir>
    2c9a:	02054f63          	bltz	a0,2cd8 <exitiputtest+0x60>
    if(chdir("iputdir") < 0){
    2c9e:	00004517          	auipc	a0,0x4
    2ca2:	8ca50513          	addi	a0,a0,-1846 # 6568 <malloc+0x13a4>
    2ca6:	0bc020ef          	jal	4d62 <chdir>
    2caa:	04054163          	bltz	a0,2cec <exitiputtest+0x74>
    if(unlink("../iputdir") < 0){
    2cae:	00004517          	auipc	a0,0x4
    2cb2:	8fa50513          	addi	a0,a0,-1798 # 65a8 <malloc+0x13e4>
    2cb6:	08c020ef          	jal	4d42 <unlink>
    2cba:	04054363          	bltz	a0,2d00 <exitiputtest+0x88>
    exit(0);
    2cbe:	4501                	li	a0,0
    2cc0:	032020ef          	jal	4cf2 <exit>
    printf("%s: fork failed\n", s);
    2cc4:	85a6                	mv	a1,s1
    2cc6:	00003517          	auipc	a0,0x3
    2cca:	ec250513          	addi	a0,a0,-318 # 5b88 <malloc+0x9c4>
    2cce:	43e020ef          	jal	510c <printf>
    exit(1);
    2cd2:	4505                	li	a0,1
    2cd4:	01e020ef          	jal	4cf2 <exit>
      printf("%s: mkdir failed\n", s);
    2cd8:	85a6                	mv	a1,s1
    2cda:	00004517          	auipc	a0,0x4
    2cde:	89650513          	addi	a0,a0,-1898 # 6570 <malloc+0x13ac>
    2ce2:	42a020ef          	jal	510c <printf>
      exit(1);
    2ce6:	4505                	li	a0,1
    2ce8:	00a020ef          	jal	4cf2 <exit>
      printf("%s: child chdir failed\n", s);
    2cec:	85a6                	mv	a1,s1
    2cee:	00004517          	auipc	a0,0x4
    2cf2:	90a50513          	addi	a0,a0,-1782 # 65f8 <malloc+0x1434>
    2cf6:	416020ef          	jal	510c <printf>
      exit(1);
    2cfa:	4505                	li	a0,1
    2cfc:	7f7010ef          	jal	4cf2 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2d00:	85a6                	mv	a1,s1
    2d02:	00004517          	auipc	a0,0x4
    2d06:	8b650513          	addi	a0,a0,-1866 # 65b8 <malloc+0x13f4>
    2d0a:	402020ef          	jal	510c <printf>
      exit(1);
    2d0e:	4505                	li	a0,1
    2d10:	7e3010ef          	jal	4cf2 <exit>
  wait(&xstatus);
    2d14:	fdc40513          	addi	a0,s0,-36
    2d18:	7e3010ef          	jal	4cfa <wait>
  exit(xstatus);
    2d1c:	fdc42503          	lw	a0,-36(s0)
    2d20:	7d3010ef          	jal	4cf2 <exit>

0000000000002d24 <dirtest>:
{
    2d24:	1101                	addi	sp,sp,-32
    2d26:	ec06                	sd	ra,24(sp)
    2d28:	e822                	sd	s0,16(sp)
    2d2a:	e426                	sd	s1,8(sp)
    2d2c:	1000                	addi	s0,sp,32
    2d2e:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2d30:	00004517          	auipc	a0,0x4
    2d34:	8e050513          	addi	a0,a0,-1824 # 6610 <malloc+0x144c>
    2d38:	022020ef          	jal	4d5a <mkdir>
    2d3c:	02054f63          	bltz	a0,2d7a <dirtest+0x56>
  if(chdir("dir0") < 0){
    2d40:	00004517          	auipc	a0,0x4
    2d44:	8d050513          	addi	a0,a0,-1840 # 6610 <malloc+0x144c>
    2d48:	01a020ef          	jal	4d62 <chdir>
    2d4c:	04054163          	bltz	a0,2d8e <dirtest+0x6a>
  if(chdir("..") < 0){
    2d50:	00004517          	auipc	a0,0x4
    2d54:	8e050513          	addi	a0,a0,-1824 # 6630 <malloc+0x146c>
    2d58:	00a020ef          	jal	4d62 <chdir>
    2d5c:	04054363          	bltz	a0,2da2 <dirtest+0x7e>
  if(unlink("dir0") < 0){
    2d60:	00004517          	auipc	a0,0x4
    2d64:	8b050513          	addi	a0,a0,-1872 # 6610 <malloc+0x144c>
    2d68:	7db010ef          	jal	4d42 <unlink>
    2d6c:	04054563          	bltz	a0,2db6 <dirtest+0x92>
}
    2d70:	60e2                	ld	ra,24(sp)
    2d72:	6442                	ld	s0,16(sp)
    2d74:	64a2                	ld	s1,8(sp)
    2d76:	6105                	addi	sp,sp,32
    2d78:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2d7a:	85a6                	mv	a1,s1
    2d7c:	00003517          	auipc	a0,0x3
    2d80:	7f450513          	addi	a0,a0,2036 # 6570 <malloc+0x13ac>
    2d84:	388020ef          	jal	510c <printf>
    exit(1);
    2d88:	4505                	li	a0,1
    2d8a:	769010ef          	jal	4cf2 <exit>
    printf("%s: chdir dir0 failed\n", s);
    2d8e:	85a6                	mv	a1,s1
    2d90:	00004517          	auipc	a0,0x4
    2d94:	88850513          	addi	a0,a0,-1912 # 6618 <malloc+0x1454>
    2d98:	374020ef          	jal	510c <printf>
    exit(1);
    2d9c:	4505                	li	a0,1
    2d9e:	755010ef          	jal	4cf2 <exit>
    printf("%s: chdir .. failed\n", s);
    2da2:	85a6                	mv	a1,s1
    2da4:	00004517          	auipc	a0,0x4
    2da8:	89450513          	addi	a0,a0,-1900 # 6638 <malloc+0x1474>
    2dac:	360020ef          	jal	510c <printf>
    exit(1);
    2db0:	4505                	li	a0,1
    2db2:	741010ef          	jal	4cf2 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2db6:	85a6                	mv	a1,s1
    2db8:	00004517          	auipc	a0,0x4
    2dbc:	89850513          	addi	a0,a0,-1896 # 6650 <malloc+0x148c>
    2dc0:	34c020ef          	jal	510c <printf>
    exit(1);
    2dc4:	4505                	li	a0,1
    2dc6:	72d010ef          	jal	4cf2 <exit>

0000000000002dca <subdir>:
{
    2dca:	1101                	addi	sp,sp,-32
    2dcc:	ec06                	sd	ra,24(sp)
    2dce:	e822                	sd	s0,16(sp)
    2dd0:	e426                	sd	s1,8(sp)
    2dd2:	e04a                	sd	s2,0(sp)
    2dd4:	1000                	addi	s0,sp,32
    2dd6:	892a                	mv	s2,a0
  unlink("ff");
    2dd8:	00004517          	auipc	a0,0x4
    2ddc:	9c050513          	addi	a0,a0,-1600 # 6798 <malloc+0x15d4>
    2de0:	763010ef          	jal	4d42 <unlink>
  if(mkdir("dd") != 0){
    2de4:	00004517          	auipc	a0,0x4
    2de8:	88450513          	addi	a0,a0,-1916 # 6668 <malloc+0x14a4>
    2dec:	76f010ef          	jal	4d5a <mkdir>
    2df0:	2e051263          	bnez	a0,30d4 <subdir+0x30a>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2df4:	20200593          	li	a1,514
    2df8:	00004517          	auipc	a0,0x4
    2dfc:	89050513          	addi	a0,a0,-1904 # 6688 <malloc+0x14c4>
    2e00:	733010ef          	jal	4d32 <open>
    2e04:	84aa                	mv	s1,a0
  if(fd < 0){
    2e06:	2e054163          	bltz	a0,30e8 <subdir+0x31e>
  write(fd, "ff", 2);
    2e0a:	4609                	li	a2,2
    2e0c:	00004597          	auipc	a1,0x4
    2e10:	98c58593          	addi	a1,a1,-1652 # 6798 <malloc+0x15d4>
    2e14:	6ff010ef          	jal	4d12 <write>
  close(fd);
    2e18:	8526                	mv	a0,s1
    2e1a:	701010ef          	jal	4d1a <close>
  if(unlink("dd") >= 0){
    2e1e:	00004517          	auipc	a0,0x4
    2e22:	84a50513          	addi	a0,a0,-1974 # 6668 <malloc+0x14a4>
    2e26:	71d010ef          	jal	4d42 <unlink>
    2e2a:	2c055963          	bgez	a0,30fc <subdir+0x332>
  if(mkdir("/dd/dd") != 0){
    2e2e:	00004517          	auipc	a0,0x4
    2e32:	8b250513          	addi	a0,a0,-1870 # 66e0 <malloc+0x151c>
    2e36:	725010ef          	jal	4d5a <mkdir>
    2e3a:	2c051b63          	bnez	a0,3110 <subdir+0x346>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2e3e:	20200593          	li	a1,514
    2e42:	00004517          	auipc	a0,0x4
    2e46:	8c650513          	addi	a0,a0,-1850 # 6708 <malloc+0x1544>
    2e4a:	6e9010ef          	jal	4d32 <open>
    2e4e:	84aa                	mv	s1,a0
  if(fd < 0){
    2e50:	2c054a63          	bltz	a0,3124 <subdir+0x35a>
  write(fd, "FF", 2);
    2e54:	4609                	li	a2,2
    2e56:	00004597          	auipc	a1,0x4
    2e5a:	8e258593          	addi	a1,a1,-1822 # 6738 <malloc+0x1574>
    2e5e:	6b5010ef          	jal	4d12 <write>
  close(fd);
    2e62:	8526                	mv	a0,s1
    2e64:	6b7010ef          	jal	4d1a <close>
  fd = open("dd/dd/../ff", 0);
    2e68:	4581                	li	a1,0
    2e6a:	00004517          	auipc	a0,0x4
    2e6e:	8d650513          	addi	a0,a0,-1834 # 6740 <malloc+0x157c>
    2e72:	6c1010ef          	jal	4d32 <open>
    2e76:	84aa                	mv	s1,a0
  if(fd < 0){
    2e78:	2c054063          	bltz	a0,3138 <subdir+0x36e>
  cc = read(fd, buf, sizeof(buf));
    2e7c:	660d                	lui	a2,0x3
    2e7e:	0000a597          	auipc	a1,0xa
    2e82:	dfa58593          	addi	a1,a1,-518 # cc78 <buf>
    2e86:	685010ef          	jal	4d0a <read>
  if(cc != 2 || buf[0] != 'f'){
    2e8a:	4789                	li	a5,2
    2e8c:	2cf51063          	bne	a0,a5,314c <subdir+0x382>
    2e90:	0000a717          	auipc	a4,0xa
    2e94:	de874703          	lbu	a4,-536(a4) # cc78 <buf>
    2e98:	06600793          	li	a5,102
    2e9c:	2af71863          	bne	a4,a5,314c <subdir+0x382>
  close(fd);
    2ea0:	8526                	mv	a0,s1
    2ea2:	679010ef          	jal	4d1a <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2ea6:	00004597          	auipc	a1,0x4
    2eaa:	8ea58593          	addi	a1,a1,-1814 # 6790 <malloc+0x15cc>
    2eae:	00004517          	auipc	a0,0x4
    2eb2:	85a50513          	addi	a0,a0,-1958 # 6708 <malloc+0x1544>
    2eb6:	69d010ef          	jal	4d52 <link>
    2eba:	2a051363          	bnez	a0,3160 <subdir+0x396>
  if(unlink("dd/dd/ff") != 0){
    2ebe:	00004517          	auipc	a0,0x4
    2ec2:	84a50513          	addi	a0,a0,-1974 # 6708 <malloc+0x1544>
    2ec6:	67d010ef          	jal	4d42 <unlink>
    2eca:	2a051563          	bnez	a0,3174 <subdir+0x3aa>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2ece:	4581                	li	a1,0
    2ed0:	00004517          	auipc	a0,0x4
    2ed4:	83850513          	addi	a0,a0,-1992 # 6708 <malloc+0x1544>
    2ed8:	65b010ef          	jal	4d32 <open>
    2edc:	2a055663          	bgez	a0,3188 <subdir+0x3be>
  if(chdir("dd") != 0){
    2ee0:	00003517          	auipc	a0,0x3
    2ee4:	78850513          	addi	a0,a0,1928 # 6668 <malloc+0x14a4>
    2ee8:	67b010ef          	jal	4d62 <chdir>
    2eec:	2a051863          	bnez	a0,319c <subdir+0x3d2>
  if(chdir("dd/../../dd") != 0){
    2ef0:	00004517          	auipc	a0,0x4
    2ef4:	93850513          	addi	a0,a0,-1736 # 6828 <malloc+0x1664>
    2ef8:	66b010ef          	jal	4d62 <chdir>
    2efc:	2a051a63          	bnez	a0,31b0 <subdir+0x3e6>
  if(chdir("dd/../../../dd") != 0){
    2f00:	00004517          	auipc	a0,0x4
    2f04:	95850513          	addi	a0,a0,-1704 # 6858 <malloc+0x1694>
    2f08:	65b010ef          	jal	4d62 <chdir>
    2f0c:	2a051c63          	bnez	a0,31c4 <subdir+0x3fa>
  if(chdir("./..") != 0){
    2f10:	00004517          	auipc	a0,0x4
    2f14:	98050513          	addi	a0,a0,-1664 # 6890 <malloc+0x16cc>
    2f18:	64b010ef          	jal	4d62 <chdir>
    2f1c:	2a051e63          	bnez	a0,31d8 <subdir+0x40e>
  fd = open("dd/dd/ffff", 0);
    2f20:	4581                	li	a1,0
    2f22:	00004517          	auipc	a0,0x4
    2f26:	86e50513          	addi	a0,a0,-1938 # 6790 <malloc+0x15cc>
    2f2a:	609010ef          	jal	4d32 <open>
    2f2e:	84aa                	mv	s1,a0
  if(fd < 0){
    2f30:	2a054e63          	bltz	a0,31ec <subdir+0x422>
  if(read(fd, buf, sizeof(buf)) != 2){
    2f34:	660d                	lui	a2,0x3
    2f36:	0000a597          	auipc	a1,0xa
    2f3a:	d4258593          	addi	a1,a1,-702 # cc78 <buf>
    2f3e:	5cd010ef          	jal	4d0a <read>
    2f42:	4789                	li	a5,2
    2f44:	2af51e63          	bne	a0,a5,3200 <subdir+0x436>
  close(fd);
    2f48:	8526                	mv	a0,s1
    2f4a:	5d1010ef          	jal	4d1a <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2f4e:	4581                	li	a1,0
    2f50:	00003517          	auipc	a0,0x3
    2f54:	7b850513          	addi	a0,a0,1976 # 6708 <malloc+0x1544>
    2f58:	5db010ef          	jal	4d32 <open>
    2f5c:	2a055c63          	bgez	a0,3214 <subdir+0x44a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2f60:	20200593          	li	a1,514
    2f64:	00004517          	auipc	a0,0x4
    2f68:	9bc50513          	addi	a0,a0,-1604 # 6920 <malloc+0x175c>
    2f6c:	5c7010ef          	jal	4d32 <open>
    2f70:	2a055c63          	bgez	a0,3228 <subdir+0x45e>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2f74:	20200593          	li	a1,514
    2f78:	00004517          	auipc	a0,0x4
    2f7c:	9d850513          	addi	a0,a0,-1576 # 6950 <malloc+0x178c>
    2f80:	5b3010ef          	jal	4d32 <open>
    2f84:	2a055c63          	bgez	a0,323c <subdir+0x472>
  if(open("dd", O_CREATE) >= 0){
    2f88:	20000593          	li	a1,512
    2f8c:	00003517          	auipc	a0,0x3
    2f90:	6dc50513          	addi	a0,a0,1756 # 6668 <malloc+0x14a4>
    2f94:	59f010ef          	jal	4d32 <open>
    2f98:	2a055c63          	bgez	a0,3250 <subdir+0x486>
  if(open("dd", O_RDWR) >= 0){
    2f9c:	4589                	li	a1,2
    2f9e:	00003517          	auipc	a0,0x3
    2fa2:	6ca50513          	addi	a0,a0,1738 # 6668 <malloc+0x14a4>
    2fa6:	58d010ef          	jal	4d32 <open>
    2faa:	2a055d63          	bgez	a0,3264 <subdir+0x49a>
  if(open("dd", O_WRONLY) >= 0){
    2fae:	4585                	li	a1,1
    2fb0:	00003517          	auipc	a0,0x3
    2fb4:	6b850513          	addi	a0,a0,1720 # 6668 <malloc+0x14a4>
    2fb8:	57b010ef          	jal	4d32 <open>
    2fbc:	2a055e63          	bgez	a0,3278 <subdir+0x4ae>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2fc0:	00004597          	auipc	a1,0x4
    2fc4:	a2058593          	addi	a1,a1,-1504 # 69e0 <malloc+0x181c>
    2fc8:	00004517          	auipc	a0,0x4
    2fcc:	95850513          	addi	a0,a0,-1704 # 6920 <malloc+0x175c>
    2fd0:	583010ef          	jal	4d52 <link>
    2fd4:	2a050c63          	beqz	a0,328c <subdir+0x4c2>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2fd8:	00004597          	auipc	a1,0x4
    2fdc:	a0858593          	addi	a1,a1,-1528 # 69e0 <malloc+0x181c>
    2fe0:	00004517          	auipc	a0,0x4
    2fe4:	97050513          	addi	a0,a0,-1680 # 6950 <malloc+0x178c>
    2fe8:	56b010ef          	jal	4d52 <link>
    2fec:	2a050a63          	beqz	a0,32a0 <subdir+0x4d6>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2ff0:	00003597          	auipc	a1,0x3
    2ff4:	7a058593          	addi	a1,a1,1952 # 6790 <malloc+0x15cc>
    2ff8:	00003517          	auipc	a0,0x3
    2ffc:	69050513          	addi	a0,a0,1680 # 6688 <malloc+0x14c4>
    3000:	553010ef          	jal	4d52 <link>
    3004:	2a050863          	beqz	a0,32b4 <subdir+0x4ea>
  if(mkdir("dd/ff/ff") == 0){
    3008:	00004517          	auipc	a0,0x4
    300c:	91850513          	addi	a0,a0,-1768 # 6920 <malloc+0x175c>
    3010:	54b010ef          	jal	4d5a <mkdir>
    3014:	2a050a63          	beqz	a0,32c8 <subdir+0x4fe>
  if(mkdir("dd/xx/ff") == 0){
    3018:	00004517          	auipc	a0,0x4
    301c:	93850513          	addi	a0,a0,-1736 # 6950 <malloc+0x178c>
    3020:	53b010ef          	jal	4d5a <mkdir>
    3024:	2a050c63          	beqz	a0,32dc <subdir+0x512>
  if(mkdir("dd/dd/ffff") == 0){
    3028:	00003517          	auipc	a0,0x3
    302c:	76850513          	addi	a0,a0,1896 # 6790 <malloc+0x15cc>
    3030:	52b010ef          	jal	4d5a <mkdir>
    3034:	2a050e63          	beqz	a0,32f0 <subdir+0x526>
  if(unlink("dd/xx/ff") == 0){
    3038:	00004517          	auipc	a0,0x4
    303c:	91850513          	addi	a0,a0,-1768 # 6950 <malloc+0x178c>
    3040:	503010ef          	jal	4d42 <unlink>
    3044:	2c050063          	beqz	a0,3304 <subdir+0x53a>
  if(unlink("dd/ff/ff") == 0){
    3048:	00004517          	auipc	a0,0x4
    304c:	8d850513          	addi	a0,a0,-1832 # 6920 <malloc+0x175c>
    3050:	4f3010ef          	jal	4d42 <unlink>
    3054:	2c050263          	beqz	a0,3318 <subdir+0x54e>
  if(chdir("dd/ff") == 0){
    3058:	00003517          	auipc	a0,0x3
    305c:	63050513          	addi	a0,a0,1584 # 6688 <malloc+0x14c4>
    3060:	503010ef          	jal	4d62 <chdir>
    3064:	2c050463          	beqz	a0,332c <subdir+0x562>
  if(chdir("dd/xx") == 0){
    3068:	00004517          	auipc	a0,0x4
    306c:	ac850513          	addi	a0,a0,-1336 # 6b30 <malloc+0x196c>
    3070:	4f3010ef          	jal	4d62 <chdir>
    3074:	2c050663          	beqz	a0,3340 <subdir+0x576>
  if(unlink("dd/dd/ffff") != 0){
    3078:	00003517          	auipc	a0,0x3
    307c:	71850513          	addi	a0,a0,1816 # 6790 <malloc+0x15cc>
    3080:	4c3010ef          	jal	4d42 <unlink>
    3084:	2c051863          	bnez	a0,3354 <subdir+0x58a>
  if(unlink("dd/ff") != 0){
    3088:	00003517          	auipc	a0,0x3
    308c:	60050513          	addi	a0,a0,1536 # 6688 <malloc+0x14c4>
    3090:	4b3010ef          	jal	4d42 <unlink>
    3094:	2c051a63          	bnez	a0,3368 <subdir+0x59e>
  if(unlink("dd") == 0){
    3098:	00003517          	auipc	a0,0x3
    309c:	5d050513          	addi	a0,a0,1488 # 6668 <malloc+0x14a4>
    30a0:	4a3010ef          	jal	4d42 <unlink>
    30a4:	2c050c63          	beqz	a0,337c <subdir+0x5b2>
  if(unlink("dd/dd") < 0){
    30a8:	00004517          	auipc	a0,0x4
    30ac:	af850513          	addi	a0,a0,-1288 # 6ba0 <malloc+0x19dc>
    30b0:	493010ef          	jal	4d42 <unlink>
    30b4:	2c054e63          	bltz	a0,3390 <subdir+0x5c6>
  if(unlink("dd") < 0){
    30b8:	00003517          	auipc	a0,0x3
    30bc:	5b050513          	addi	a0,a0,1456 # 6668 <malloc+0x14a4>
    30c0:	483010ef          	jal	4d42 <unlink>
    30c4:	2e054063          	bltz	a0,33a4 <subdir+0x5da>
}
    30c8:	60e2                	ld	ra,24(sp)
    30ca:	6442                	ld	s0,16(sp)
    30cc:	64a2                	ld	s1,8(sp)
    30ce:	6902                	ld	s2,0(sp)
    30d0:	6105                	addi	sp,sp,32
    30d2:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    30d4:	85ca                	mv	a1,s2
    30d6:	00003517          	auipc	a0,0x3
    30da:	59a50513          	addi	a0,a0,1434 # 6670 <malloc+0x14ac>
    30de:	02e020ef          	jal	510c <printf>
    exit(1);
    30e2:	4505                	li	a0,1
    30e4:	40f010ef          	jal	4cf2 <exit>
    printf("%s: create dd/ff failed\n", s);
    30e8:	85ca                	mv	a1,s2
    30ea:	00003517          	auipc	a0,0x3
    30ee:	5a650513          	addi	a0,a0,1446 # 6690 <malloc+0x14cc>
    30f2:	01a020ef          	jal	510c <printf>
    exit(1);
    30f6:	4505                	li	a0,1
    30f8:	3fb010ef          	jal	4cf2 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    30fc:	85ca                	mv	a1,s2
    30fe:	00003517          	auipc	a0,0x3
    3102:	5b250513          	addi	a0,a0,1458 # 66b0 <malloc+0x14ec>
    3106:	006020ef          	jal	510c <printf>
    exit(1);
    310a:	4505                	li	a0,1
    310c:	3e7010ef          	jal	4cf2 <exit>
    printf("%s: subdir mkdir dd/dd failed\n", s);
    3110:	85ca                	mv	a1,s2
    3112:	00003517          	auipc	a0,0x3
    3116:	5d650513          	addi	a0,a0,1494 # 66e8 <malloc+0x1524>
    311a:	7f3010ef          	jal	510c <printf>
    exit(1);
    311e:	4505                	li	a0,1
    3120:	3d3010ef          	jal	4cf2 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3124:	85ca                	mv	a1,s2
    3126:	00003517          	auipc	a0,0x3
    312a:	5f250513          	addi	a0,a0,1522 # 6718 <malloc+0x1554>
    312e:	7df010ef          	jal	510c <printf>
    exit(1);
    3132:	4505                	li	a0,1
    3134:	3bf010ef          	jal	4cf2 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3138:	85ca                	mv	a1,s2
    313a:	00003517          	auipc	a0,0x3
    313e:	61650513          	addi	a0,a0,1558 # 6750 <malloc+0x158c>
    3142:	7cb010ef          	jal	510c <printf>
    exit(1);
    3146:	4505                	li	a0,1
    3148:	3ab010ef          	jal	4cf2 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    314c:	85ca                	mv	a1,s2
    314e:	00003517          	auipc	a0,0x3
    3152:	62250513          	addi	a0,a0,1570 # 6770 <malloc+0x15ac>
    3156:	7b7010ef          	jal	510c <printf>
    exit(1);
    315a:	4505                	li	a0,1
    315c:	397010ef          	jal	4cf2 <exit>
    printf("%s: link dd/dd/ff dd/dd/ffff failed\n", s);
    3160:	85ca                	mv	a1,s2
    3162:	00003517          	auipc	a0,0x3
    3166:	63e50513          	addi	a0,a0,1598 # 67a0 <malloc+0x15dc>
    316a:	7a3010ef          	jal	510c <printf>
    exit(1);
    316e:	4505                	li	a0,1
    3170:	383010ef          	jal	4cf2 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3174:	85ca                	mv	a1,s2
    3176:	00003517          	auipc	a0,0x3
    317a:	65250513          	addi	a0,a0,1618 # 67c8 <malloc+0x1604>
    317e:	78f010ef          	jal	510c <printf>
    exit(1);
    3182:	4505                	li	a0,1
    3184:	36f010ef          	jal	4cf2 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3188:	85ca                	mv	a1,s2
    318a:	00003517          	auipc	a0,0x3
    318e:	65e50513          	addi	a0,a0,1630 # 67e8 <malloc+0x1624>
    3192:	77b010ef          	jal	510c <printf>
    exit(1);
    3196:	4505                	li	a0,1
    3198:	35b010ef          	jal	4cf2 <exit>
    printf("%s: chdir dd failed\n", s);
    319c:	85ca                	mv	a1,s2
    319e:	00003517          	auipc	a0,0x3
    31a2:	67250513          	addi	a0,a0,1650 # 6810 <malloc+0x164c>
    31a6:	767010ef          	jal	510c <printf>
    exit(1);
    31aa:	4505                	li	a0,1
    31ac:	347010ef          	jal	4cf2 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    31b0:	85ca                	mv	a1,s2
    31b2:	00003517          	auipc	a0,0x3
    31b6:	68650513          	addi	a0,a0,1670 # 6838 <malloc+0x1674>
    31ba:	753010ef          	jal	510c <printf>
    exit(1);
    31be:	4505                	li	a0,1
    31c0:	333010ef          	jal	4cf2 <exit>
    printf("%s: chdir dd/../../../dd failed\n", s);
    31c4:	85ca                	mv	a1,s2
    31c6:	00003517          	auipc	a0,0x3
    31ca:	6a250513          	addi	a0,a0,1698 # 6868 <malloc+0x16a4>
    31ce:	73f010ef          	jal	510c <printf>
    exit(1);
    31d2:	4505                	li	a0,1
    31d4:	31f010ef          	jal	4cf2 <exit>
    printf("%s: chdir ./.. failed\n", s);
    31d8:	85ca                	mv	a1,s2
    31da:	00003517          	auipc	a0,0x3
    31de:	6be50513          	addi	a0,a0,1726 # 6898 <malloc+0x16d4>
    31e2:	72b010ef          	jal	510c <printf>
    exit(1);
    31e6:	4505                	li	a0,1
    31e8:	30b010ef          	jal	4cf2 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    31ec:	85ca                	mv	a1,s2
    31ee:	00003517          	auipc	a0,0x3
    31f2:	6c250513          	addi	a0,a0,1730 # 68b0 <malloc+0x16ec>
    31f6:	717010ef          	jal	510c <printf>
    exit(1);
    31fa:	4505                	li	a0,1
    31fc:	2f7010ef          	jal	4cf2 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3200:	85ca                	mv	a1,s2
    3202:	00003517          	auipc	a0,0x3
    3206:	6ce50513          	addi	a0,a0,1742 # 68d0 <malloc+0x170c>
    320a:	703010ef          	jal	510c <printf>
    exit(1);
    320e:	4505                	li	a0,1
    3210:	2e3010ef          	jal	4cf2 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3214:	85ca                	mv	a1,s2
    3216:	00003517          	auipc	a0,0x3
    321a:	6da50513          	addi	a0,a0,1754 # 68f0 <malloc+0x172c>
    321e:	6ef010ef          	jal	510c <printf>
    exit(1);
    3222:	4505                	li	a0,1
    3224:	2cf010ef          	jal	4cf2 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3228:	85ca                	mv	a1,s2
    322a:	00003517          	auipc	a0,0x3
    322e:	70650513          	addi	a0,a0,1798 # 6930 <malloc+0x176c>
    3232:	6db010ef          	jal	510c <printf>
    exit(1);
    3236:	4505                	li	a0,1
    3238:	2bb010ef          	jal	4cf2 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    323c:	85ca                	mv	a1,s2
    323e:	00003517          	auipc	a0,0x3
    3242:	72250513          	addi	a0,a0,1826 # 6960 <malloc+0x179c>
    3246:	6c7010ef          	jal	510c <printf>
    exit(1);
    324a:	4505                	li	a0,1
    324c:	2a7010ef          	jal	4cf2 <exit>
    printf("%s: create dd succeeded!\n", s);
    3250:	85ca                	mv	a1,s2
    3252:	00003517          	auipc	a0,0x3
    3256:	72e50513          	addi	a0,a0,1838 # 6980 <malloc+0x17bc>
    325a:	6b3010ef          	jal	510c <printf>
    exit(1);
    325e:	4505                	li	a0,1
    3260:	293010ef          	jal	4cf2 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3264:	85ca                	mv	a1,s2
    3266:	00003517          	auipc	a0,0x3
    326a:	73a50513          	addi	a0,a0,1850 # 69a0 <malloc+0x17dc>
    326e:	69f010ef          	jal	510c <printf>
    exit(1);
    3272:	4505                	li	a0,1
    3274:	27f010ef          	jal	4cf2 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3278:	85ca                	mv	a1,s2
    327a:	00003517          	auipc	a0,0x3
    327e:	74650513          	addi	a0,a0,1862 # 69c0 <malloc+0x17fc>
    3282:	68b010ef          	jal	510c <printf>
    exit(1);
    3286:	4505                	li	a0,1
    3288:	26b010ef          	jal	4cf2 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    328c:	85ca                	mv	a1,s2
    328e:	00003517          	auipc	a0,0x3
    3292:	76250513          	addi	a0,a0,1890 # 69f0 <malloc+0x182c>
    3296:	677010ef          	jal	510c <printf>
    exit(1);
    329a:	4505                	li	a0,1
    329c:	257010ef          	jal	4cf2 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    32a0:	85ca                	mv	a1,s2
    32a2:	00003517          	auipc	a0,0x3
    32a6:	77650513          	addi	a0,a0,1910 # 6a18 <malloc+0x1854>
    32aa:	663010ef          	jal	510c <printf>
    exit(1);
    32ae:	4505                	li	a0,1
    32b0:	243010ef          	jal	4cf2 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    32b4:	85ca                	mv	a1,s2
    32b6:	00003517          	auipc	a0,0x3
    32ba:	78a50513          	addi	a0,a0,1930 # 6a40 <malloc+0x187c>
    32be:	64f010ef          	jal	510c <printf>
    exit(1);
    32c2:	4505                	li	a0,1
    32c4:	22f010ef          	jal	4cf2 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    32c8:	85ca                	mv	a1,s2
    32ca:	00003517          	auipc	a0,0x3
    32ce:	79e50513          	addi	a0,a0,1950 # 6a68 <malloc+0x18a4>
    32d2:	63b010ef          	jal	510c <printf>
    exit(1);
    32d6:	4505                	li	a0,1
    32d8:	21b010ef          	jal	4cf2 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    32dc:	85ca                	mv	a1,s2
    32de:	00003517          	auipc	a0,0x3
    32e2:	7aa50513          	addi	a0,a0,1962 # 6a88 <malloc+0x18c4>
    32e6:	627010ef          	jal	510c <printf>
    exit(1);
    32ea:	4505                	li	a0,1
    32ec:	207010ef          	jal	4cf2 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    32f0:	85ca                	mv	a1,s2
    32f2:	00003517          	auipc	a0,0x3
    32f6:	7b650513          	addi	a0,a0,1974 # 6aa8 <malloc+0x18e4>
    32fa:	613010ef          	jal	510c <printf>
    exit(1);
    32fe:	4505                	li	a0,1
    3300:	1f3010ef          	jal	4cf2 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3304:	85ca                	mv	a1,s2
    3306:	00003517          	auipc	a0,0x3
    330a:	7ca50513          	addi	a0,a0,1994 # 6ad0 <malloc+0x190c>
    330e:	5ff010ef          	jal	510c <printf>
    exit(1);
    3312:	4505                	li	a0,1
    3314:	1df010ef          	jal	4cf2 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3318:	85ca                	mv	a1,s2
    331a:	00003517          	auipc	a0,0x3
    331e:	7d650513          	addi	a0,a0,2006 # 6af0 <malloc+0x192c>
    3322:	5eb010ef          	jal	510c <printf>
    exit(1);
    3326:	4505                	li	a0,1
    3328:	1cb010ef          	jal	4cf2 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    332c:	85ca                	mv	a1,s2
    332e:	00003517          	auipc	a0,0x3
    3332:	7e250513          	addi	a0,a0,2018 # 6b10 <malloc+0x194c>
    3336:	5d7010ef          	jal	510c <printf>
    exit(1);
    333a:	4505                	li	a0,1
    333c:	1b7010ef          	jal	4cf2 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3340:	85ca                	mv	a1,s2
    3342:	00003517          	auipc	a0,0x3
    3346:	7f650513          	addi	a0,a0,2038 # 6b38 <malloc+0x1974>
    334a:	5c3010ef          	jal	510c <printf>
    exit(1);
    334e:	4505                	li	a0,1
    3350:	1a3010ef          	jal	4cf2 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3354:	85ca                	mv	a1,s2
    3356:	00003517          	auipc	a0,0x3
    335a:	47250513          	addi	a0,a0,1138 # 67c8 <malloc+0x1604>
    335e:	5af010ef          	jal	510c <printf>
    exit(1);
    3362:	4505                	li	a0,1
    3364:	18f010ef          	jal	4cf2 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3368:	85ca                	mv	a1,s2
    336a:	00003517          	auipc	a0,0x3
    336e:	7ee50513          	addi	a0,a0,2030 # 6b58 <malloc+0x1994>
    3372:	59b010ef          	jal	510c <printf>
    exit(1);
    3376:	4505                	li	a0,1
    3378:	17b010ef          	jal	4cf2 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    337c:	85ca                	mv	a1,s2
    337e:	00003517          	auipc	a0,0x3
    3382:	7fa50513          	addi	a0,a0,2042 # 6b78 <malloc+0x19b4>
    3386:	587010ef          	jal	510c <printf>
    exit(1);
    338a:	4505                	li	a0,1
    338c:	167010ef          	jal	4cf2 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3390:	85ca                	mv	a1,s2
    3392:	00004517          	auipc	a0,0x4
    3396:	81650513          	addi	a0,a0,-2026 # 6ba8 <malloc+0x19e4>
    339a:	573010ef          	jal	510c <printf>
    exit(1);
    339e:	4505                	li	a0,1
    33a0:	153010ef          	jal	4cf2 <exit>
    printf("%s: unlink dd failed\n", s);
    33a4:	85ca                	mv	a1,s2
    33a6:	00004517          	auipc	a0,0x4
    33aa:	82250513          	addi	a0,a0,-2014 # 6bc8 <malloc+0x1a04>
    33ae:	55f010ef          	jal	510c <printf>
    exit(1);
    33b2:	4505                	li	a0,1
    33b4:	13f010ef          	jal	4cf2 <exit>

00000000000033b8 <rmdot>:
{
    33b8:	1101                	addi	sp,sp,-32
    33ba:	ec06                	sd	ra,24(sp)
    33bc:	e822                	sd	s0,16(sp)
    33be:	e426                	sd	s1,8(sp)
    33c0:	1000                	addi	s0,sp,32
    33c2:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    33c4:	00004517          	auipc	a0,0x4
    33c8:	81c50513          	addi	a0,a0,-2020 # 6be0 <malloc+0x1a1c>
    33cc:	18f010ef          	jal	4d5a <mkdir>
    33d0:	e53d                	bnez	a0,343e <rmdot+0x86>
  if(chdir("dots") != 0){
    33d2:	00004517          	auipc	a0,0x4
    33d6:	80e50513          	addi	a0,a0,-2034 # 6be0 <malloc+0x1a1c>
    33da:	189010ef          	jal	4d62 <chdir>
    33de:	e935                	bnez	a0,3452 <rmdot+0x9a>
  if(unlink(".") == 0){
    33e0:	00002517          	auipc	a0,0x2
    33e4:	60050513          	addi	a0,a0,1536 # 59e0 <malloc+0x81c>
    33e8:	15b010ef          	jal	4d42 <unlink>
    33ec:	cd2d                	beqz	a0,3466 <rmdot+0xae>
  if(unlink("..") == 0){
    33ee:	00003517          	auipc	a0,0x3
    33f2:	24250513          	addi	a0,a0,578 # 6630 <malloc+0x146c>
    33f6:	14d010ef          	jal	4d42 <unlink>
    33fa:	c141                	beqz	a0,347a <rmdot+0xc2>
  if(chdir("/") != 0){
    33fc:	00003517          	auipc	a0,0x3
    3400:	1dc50513          	addi	a0,a0,476 # 65d8 <malloc+0x1414>
    3404:	15f010ef          	jal	4d62 <chdir>
    3408:	e159                	bnez	a0,348e <rmdot+0xd6>
  if(unlink("dots/.") == 0){
    340a:	00004517          	auipc	a0,0x4
    340e:	83e50513          	addi	a0,a0,-1986 # 6c48 <malloc+0x1a84>
    3412:	131010ef          	jal	4d42 <unlink>
    3416:	c551                	beqz	a0,34a2 <rmdot+0xea>
  if(unlink("dots/..") == 0){
    3418:	00004517          	auipc	a0,0x4
    341c:	85850513          	addi	a0,a0,-1960 # 6c70 <malloc+0x1aac>
    3420:	123010ef          	jal	4d42 <unlink>
    3424:	c949                	beqz	a0,34b6 <rmdot+0xfe>
  if(unlink("dots") != 0){
    3426:	00003517          	auipc	a0,0x3
    342a:	7ba50513          	addi	a0,a0,1978 # 6be0 <malloc+0x1a1c>
    342e:	115010ef          	jal	4d42 <unlink>
    3432:	ed41                	bnez	a0,34ca <rmdot+0x112>
}
    3434:	60e2                	ld	ra,24(sp)
    3436:	6442                	ld	s0,16(sp)
    3438:	64a2                	ld	s1,8(sp)
    343a:	6105                	addi	sp,sp,32
    343c:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    343e:	85a6                	mv	a1,s1
    3440:	00003517          	auipc	a0,0x3
    3444:	7a850513          	addi	a0,a0,1960 # 6be8 <malloc+0x1a24>
    3448:	4c5010ef          	jal	510c <printf>
    exit(1);
    344c:	4505                	li	a0,1
    344e:	0a5010ef          	jal	4cf2 <exit>
    printf("%s: chdir dots failed\n", s);
    3452:	85a6                	mv	a1,s1
    3454:	00003517          	auipc	a0,0x3
    3458:	7ac50513          	addi	a0,a0,1964 # 6c00 <malloc+0x1a3c>
    345c:	4b1010ef          	jal	510c <printf>
    exit(1);
    3460:	4505                	li	a0,1
    3462:	091010ef          	jal	4cf2 <exit>
    printf("%s: rm . worked!\n", s);
    3466:	85a6                	mv	a1,s1
    3468:	00003517          	auipc	a0,0x3
    346c:	7b050513          	addi	a0,a0,1968 # 6c18 <malloc+0x1a54>
    3470:	49d010ef          	jal	510c <printf>
    exit(1);
    3474:	4505                	li	a0,1
    3476:	07d010ef          	jal	4cf2 <exit>
    printf("%s: rm .. worked!\n", s);
    347a:	85a6                	mv	a1,s1
    347c:	00003517          	auipc	a0,0x3
    3480:	7b450513          	addi	a0,a0,1972 # 6c30 <malloc+0x1a6c>
    3484:	489010ef          	jal	510c <printf>
    exit(1);
    3488:	4505                	li	a0,1
    348a:	069010ef          	jal	4cf2 <exit>
    printf("%s: chdir / failed\n", s);
    348e:	85a6                	mv	a1,s1
    3490:	00003517          	auipc	a0,0x3
    3494:	15050513          	addi	a0,a0,336 # 65e0 <malloc+0x141c>
    3498:	475010ef          	jal	510c <printf>
    exit(1);
    349c:	4505                	li	a0,1
    349e:	055010ef          	jal	4cf2 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    34a2:	85a6                	mv	a1,s1
    34a4:	00003517          	auipc	a0,0x3
    34a8:	7ac50513          	addi	a0,a0,1964 # 6c50 <malloc+0x1a8c>
    34ac:	461010ef          	jal	510c <printf>
    exit(1);
    34b0:	4505                	li	a0,1
    34b2:	041010ef          	jal	4cf2 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    34b6:	85a6                	mv	a1,s1
    34b8:	00003517          	auipc	a0,0x3
    34bc:	7c050513          	addi	a0,a0,1984 # 6c78 <malloc+0x1ab4>
    34c0:	44d010ef          	jal	510c <printf>
    exit(1);
    34c4:	4505                	li	a0,1
    34c6:	02d010ef          	jal	4cf2 <exit>
    printf("%s: unlink dots failed!\n", s);
    34ca:	85a6                	mv	a1,s1
    34cc:	00003517          	auipc	a0,0x3
    34d0:	7cc50513          	addi	a0,a0,1996 # 6c98 <malloc+0x1ad4>
    34d4:	439010ef          	jal	510c <printf>
    exit(1);
    34d8:	4505                	li	a0,1
    34da:	019010ef          	jal	4cf2 <exit>

00000000000034de <dirfile>:
{
    34de:	1101                	addi	sp,sp,-32
    34e0:	ec06                	sd	ra,24(sp)
    34e2:	e822                	sd	s0,16(sp)
    34e4:	e426                	sd	s1,8(sp)
    34e6:	e04a                	sd	s2,0(sp)
    34e8:	1000                	addi	s0,sp,32
    34ea:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    34ec:	20000593          	li	a1,512
    34f0:	00003517          	auipc	a0,0x3
    34f4:	7c850513          	addi	a0,a0,1992 # 6cb8 <malloc+0x1af4>
    34f8:	03b010ef          	jal	4d32 <open>
  if(fd < 0){
    34fc:	0c054563          	bltz	a0,35c6 <dirfile+0xe8>
  close(fd);
    3500:	01b010ef          	jal	4d1a <close>
  if(chdir("dirfile") == 0){
    3504:	00003517          	auipc	a0,0x3
    3508:	7b450513          	addi	a0,a0,1972 # 6cb8 <malloc+0x1af4>
    350c:	057010ef          	jal	4d62 <chdir>
    3510:	c569                	beqz	a0,35da <dirfile+0xfc>
  fd = open("dirfile/xx", 0);
    3512:	4581                	li	a1,0
    3514:	00003517          	auipc	a0,0x3
    3518:	7ec50513          	addi	a0,a0,2028 # 6d00 <malloc+0x1b3c>
    351c:	017010ef          	jal	4d32 <open>
  if(fd >= 0){
    3520:	0c055763          	bgez	a0,35ee <dirfile+0x110>
  fd = open("dirfile/xx", O_CREATE);
    3524:	20000593          	li	a1,512
    3528:	00003517          	auipc	a0,0x3
    352c:	7d850513          	addi	a0,a0,2008 # 6d00 <malloc+0x1b3c>
    3530:	003010ef          	jal	4d32 <open>
  if(fd >= 0){
    3534:	0c055763          	bgez	a0,3602 <dirfile+0x124>
  if(mkdir("dirfile/xx") == 0){
    3538:	00003517          	auipc	a0,0x3
    353c:	7c850513          	addi	a0,a0,1992 # 6d00 <malloc+0x1b3c>
    3540:	01b010ef          	jal	4d5a <mkdir>
    3544:	0c050963          	beqz	a0,3616 <dirfile+0x138>
  if(unlink("dirfile/xx") == 0){
    3548:	00003517          	auipc	a0,0x3
    354c:	7b850513          	addi	a0,a0,1976 # 6d00 <malloc+0x1b3c>
    3550:	7f2010ef          	jal	4d42 <unlink>
    3554:	0c050b63          	beqz	a0,362a <dirfile+0x14c>
  if(link("README", "dirfile/xx") == 0){
    3558:	00003597          	auipc	a1,0x3
    355c:	7a858593          	addi	a1,a1,1960 # 6d00 <malloc+0x1b3c>
    3560:	00002517          	auipc	a0,0x2
    3564:	f7050513          	addi	a0,a0,-144 # 54d0 <malloc+0x30c>
    3568:	7ea010ef          	jal	4d52 <link>
    356c:	0c050963          	beqz	a0,363e <dirfile+0x160>
  if(unlink("dirfile") != 0){
    3570:	00003517          	auipc	a0,0x3
    3574:	74850513          	addi	a0,a0,1864 # 6cb8 <malloc+0x1af4>
    3578:	7ca010ef          	jal	4d42 <unlink>
    357c:	0c051b63          	bnez	a0,3652 <dirfile+0x174>
  fd = open(".", O_RDWR);
    3580:	4589                	li	a1,2
    3582:	00002517          	auipc	a0,0x2
    3586:	45e50513          	addi	a0,a0,1118 # 59e0 <malloc+0x81c>
    358a:	7a8010ef          	jal	4d32 <open>
  if(fd >= 0){
    358e:	0c055c63          	bgez	a0,3666 <dirfile+0x188>
  fd = open(".", 0);
    3592:	4581                	li	a1,0
    3594:	00002517          	auipc	a0,0x2
    3598:	44c50513          	addi	a0,a0,1100 # 59e0 <malloc+0x81c>
    359c:	796010ef          	jal	4d32 <open>
    35a0:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    35a2:	4605                	li	a2,1
    35a4:	00002597          	auipc	a1,0x2
    35a8:	dc458593          	addi	a1,a1,-572 # 5368 <malloc+0x1a4>
    35ac:	766010ef          	jal	4d12 <write>
    35b0:	0ca04563          	bgtz	a0,367a <dirfile+0x19c>
  close(fd);
    35b4:	8526                	mv	a0,s1
    35b6:	764010ef          	jal	4d1a <close>
}
    35ba:	60e2                	ld	ra,24(sp)
    35bc:	6442                	ld	s0,16(sp)
    35be:	64a2                	ld	s1,8(sp)
    35c0:	6902                	ld	s2,0(sp)
    35c2:	6105                	addi	sp,sp,32
    35c4:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    35c6:	85ca                	mv	a1,s2
    35c8:	00003517          	auipc	a0,0x3
    35cc:	6f850513          	addi	a0,a0,1784 # 6cc0 <malloc+0x1afc>
    35d0:	33d010ef          	jal	510c <printf>
    exit(1);
    35d4:	4505                	li	a0,1
    35d6:	71c010ef          	jal	4cf2 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    35da:	85ca                	mv	a1,s2
    35dc:	00003517          	auipc	a0,0x3
    35e0:	70450513          	addi	a0,a0,1796 # 6ce0 <malloc+0x1b1c>
    35e4:	329010ef          	jal	510c <printf>
    exit(1);
    35e8:	4505                	li	a0,1
    35ea:	708010ef          	jal	4cf2 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    35ee:	85ca                	mv	a1,s2
    35f0:	00003517          	auipc	a0,0x3
    35f4:	72050513          	addi	a0,a0,1824 # 6d10 <malloc+0x1b4c>
    35f8:	315010ef          	jal	510c <printf>
    exit(1);
    35fc:	4505                	li	a0,1
    35fe:	6f4010ef          	jal	4cf2 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3602:	85ca                	mv	a1,s2
    3604:	00003517          	auipc	a0,0x3
    3608:	70c50513          	addi	a0,a0,1804 # 6d10 <malloc+0x1b4c>
    360c:	301010ef          	jal	510c <printf>
    exit(1);
    3610:	4505                	li	a0,1
    3612:	6e0010ef          	jal	4cf2 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3616:	85ca                	mv	a1,s2
    3618:	00003517          	auipc	a0,0x3
    361c:	72050513          	addi	a0,a0,1824 # 6d38 <malloc+0x1b74>
    3620:	2ed010ef          	jal	510c <printf>
    exit(1);
    3624:	4505                	li	a0,1
    3626:	6cc010ef          	jal	4cf2 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    362a:	85ca                	mv	a1,s2
    362c:	00003517          	auipc	a0,0x3
    3630:	73450513          	addi	a0,a0,1844 # 6d60 <malloc+0x1b9c>
    3634:	2d9010ef          	jal	510c <printf>
    exit(1);
    3638:	4505                	li	a0,1
    363a:	6b8010ef          	jal	4cf2 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    363e:	85ca                	mv	a1,s2
    3640:	00003517          	auipc	a0,0x3
    3644:	74850513          	addi	a0,a0,1864 # 6d88 <malloc+0x1bc4>
    3648:	2c5010ef          	jal	510c <printf>
    exit(1);
    364c:	4505                	li	a0,1
    364e:	6a4010ef          	jal	4cf2 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3652:	85ca                	mv	a1,s2
    3654:	00003517          	auipc	a0,0x3
    3658:	75c50513          	addi	a0,a0,1884 # 6db0 <malloc+0x1bec>
    365c:	2b1010ef          	jal	510c <printf>
    exit(1);
    3660:	4505                	li	a0,1
    3662:	690010ef          	jal	4cf2 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3666:	85ca                	mv	a1,s2
    3668:	00003517          	auipc	a0,0x3
    366c:	76850513          	addi	a0,a0,1896 # 6dd0 <malloc+0x1c0c>
    3670:	29d010ef          	jal	510c <printf>
    exit(1);
    3674:	4505                	li	a0,1
    3676:	67c010ef          	jal	4cf2 <exit>
    printf("%s: write . succeeded!\n", s);
    367a:	85ca                	mv	a1,s2
    367c:	00003517          	auipc	a0,0x3
    3680:	77c50513          	addi	a0,a0,1916 # 6df8 <malloc+0x1c34>
    3684:	289010ef          	jal	510c <printf>
    exit(1);
    3688:	4505                	li	a0,1
    368a:	668010ef          	jal	4cf2 <exit>

000000000000368e <iref>:
{
    368e:	715d                	addi	sp,sp,-80
    3690:	e486                	sd	ra,72(sp)
    3692:	e0a2                	sd	s0,64(sp)
    3694:	fc26                	sd	s1,56(sp)
    3696:	f84a                	sd	s2,48(sp)
    3698:	f44e                	sd	s3,40(sp)
    369a:	f052                	sd	s4,32(sp)
    369c:	ec56                	sd	s5,24(sp)
    369e:	e85a                	sd	s6,16(sp)
    36a0:	e45e                	sd	s7,8(sp)
    36a2:	0880                	addi	s0,sp,80
    36a4:	8baa                	mv	s7,a0
    36a6:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    36aa:	00003a97          	auipc	s5,0x3
    36ae:	766a8a93          	addi	s5,s5,1894 # 6e10 <malloc+0x1c4c>
    mkdir("");
    36b2:	00003497          	auipc	s1,0x3
    36b6:	26648493          	addi	s1,s1,614 # 6918 <malloc+0x1754>
    link("README", "");
    36ba:	00002b17          	auipc	s6,0x2
    36be:	e16b0b13          	addi	s6,s6,-490 # 54d0 <malloc+0x30c>
    fd = open("", O_CREATE);
    36c2:	20000a13          	li	s4,512
    fd = open("xx", O_CREATE);
    36c6:	00003997          	auipc	s3,0x3
    36ca:	64298993          	addi	s3,s3,1602 # 6d08 <malloc+0x1b44>
    36ce:	a835                	j	370a <iref+0x7c>
      printf("%s: mkdir irefd failed\n", s);
    36d0:	85de                	mv	a1,s7
    36d2:	00003517          	auipc	a0,0x3
    36d6:	74650513          	addi	a0,a0,1862 # 6e18 <malloc+0x1c54>
    36da:	233010ef          	jal	510c <printf>
      exit(1);
    36de:	4505                	li	a0,1
    36e0:	612010ef          	jal	4cf2 <exit>
      printf("%s: chdir irefd failed\n", s);
    36e4:	85de                	mv	a1,s7
    36e6:	00003517          	auipc	a0,0x3
    36ea:	74a50513          	addi	a0,a0,1866 # 6e30 <malloc+0x1c6c>
    36ee:	21f010ef          	jal	510c <printf>
      exit(1);
    36f2:	4505                	li	a0,1
    36f4:	5fe010ef          	jal	4cf2 <exit>
      close(fd);
    36f8:	622010ef          	jal	4d1a <close>
    36fc:	a825                	j	3734 <iref+0xa6>
    unlink("xx");
    36fe:	854e                	mv	a0,s3
    3700:	642010ef          	jal	4d42 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3704:	397d                	addiw	s2,s2,-1
    3706:	04090063          	beqz	s2,3746 <iref+0xb8>
    if(mkdir("irefd") != 0){
    370a:	8556                	mv	a0,s5
    370c:	64e010ef          	jal	4d5a <mkdir>
    3710:	f161                	bnez	a0,36d0 <iref+0x42>
    if(chdir("irefd") != 0){
    3712:	8556                	mv	a0,s5
    3714:	64e010ef          	jal	4d62 <chdir>
    3718:	f571                	bnez	a0,36e4 <iref+0x56>
    mkdir("");
    371a:	8526                	mv	a0,s1
    371c:	63e010ef          	jal	4d5a <mkdir>
    link("README", "");
    3720:	85a6                	mv	a1,s1
    3722:	855a                	mv	a0,s6
    3724:	62e010ef          	jal	4d52 <link>
    fd = open("", O_CREATE);
    3728:	85d2                	mv	a1,s4
    372a:	8526                	mv	a0,s1
    372c:	606010ef          	jal	4d32 <open>
    if(fd >= 0)
    3730:	fc0554e3          	bgez	a0,36f8 <iref+0x6a>
    fd = open("xx", O_CREATE);
    3734:	85d2                	mv	a1,s4
    3736:	854e                	mv	a0,s3
    3738:	5fa010ef          	jal	4d32 <open>
    if(fd >= 0)
    373c:	fc0541e3          	bltz	a0,36fe <iref+0x70>
      close(fd);
    3740:	5da010ef          	jal	4d1a <close>
    3744:	bf6d                	j	36fe <iref+0x70>
    3746:	03300493          	li	s1,51
    chdir("..");
    374a:	00003997          	auipc	s3,0x3
    374e:	ee698993          	addi	s3,s3,-282 # 6630 <malloc+0x146c>
    unlink("irefd");
    3752:	00003917          	auipc	s2,0x3
    3756:	6be90913          	addi	s2,s2,1726 # 6e10 <malloc+0x1c4c>
    chdir("..");
    375a:	854e                	mv	a0,s3
    375c:	606010ef          	jal	4d62 <chdir>
    unlink("irefd");
    3760:	854a                	mv	a0,s2
    3762:	5e0010ef          	jal	4d42 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3766:	34fd                	addiw	s1,s1,-1
    3768:	f8ed                	bnez	s1,375a <iref+0xcc>
  chdir("/");
    376a:	00003517          	auipc	a0,0x3
    376e:	e6e50513          	addi	a0,a0,-402 # 65d8 <malloc+0x1414>
    3772:	5f0010ef          	jal	4d62 <chdir>
}
    3776:	60a6                	ld	ra,72(sp)
    3778:	6406                	ld	s0,64(sp)
    377a:	74e2                	ld	s1,56(sp)
    377c:	7942                	ld	s2,48(sp)
    377e:	79a2                	ld	s3,40(sp)
    3780:	7a02                	ld	s4,32(sp)
    3782:	6ae2                	ld	s5,24(sp)
    3784:	6b42                	ld	s6,16(sp)
    3786:	6ba2                	ld	s7,8(sp)
    3788:	6161                	addi	sp,sp,80
    378a:	8082                	ret

000000000000378c <openiputtest>:
{
    378c:	7179                	addi	sp,sp,-48
    378e:	f406                	sd	ra,40(sp)
    3790:	f022                	sd	s0,32(sp)
    3792:	ec26                	sd	s1,24(sp)
    3794:	1800                	addi	s0,sp,48
    3796:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3798:	00003517          	auipc	a0,0x3
    379c:	6b050513          	addi	a0,a0,1712 # 6e48 <malloc+0x1c84>
    37a0:	5ba010ef          	jal	4d5a <mkdir>
    37a4:	02054a63          	bltz	a0,37d8 <openiputtest+0x4c>
  pid = fork();
    37a8:	542010ef          	jal	4cea <fork>
  if(pid < 0){
    37ac:	04054063          	bltz	a0,37ec <openiputtest+0x60>
  if(pid == 0){
    37b0:	e939                	bnez	a0,3806 <openiputtest+0x7a>
    int fd = open("oidir", O_RDWR);
    37b2:	4589                	li	a1,2
    37b4:	00003517          	auipc	a0,0x3
    37b8:	69450513          	addi	a0,a0,1684 # 6e48 <malloc+0x1c84>
    37bc:	576010ef          	jal	4d32 <open>
    if(fd >= 0){
    37c0:	04054063          	bltz	a0,3800 <openiputtest+0x74>
      printf("%s: open directory for write succeeded\n", s);
    37c4:	85a6                	mv	a1,s1
    37c6:	00003517          	auipc	a0,0x3
    37ca:	6a250513          	addi	a0,a0,1698 # 6e68 <malloc+0x1ca4>
    37ce:	13f010ef          	jal	510c <printf>
      exit(1);
    37d2:	4505                	li	a0,1
    37d4:	51e010ef          	jal	4cf2 <exit>
    printf("%s: mkdir oidir failed\n", s);
    37d8:	85a6                	mv	a1,s1
    37da:	00003517          	auipc	a0,0x3
    37de:	67650513          	addi	a0,a0,1654 # 6e50 <malloc+0x1c8c>
    37e2:	12b010ef          	jal	510c <printf>
    exit(1);
    37e6:	4505                	li	a0,1
    37e8:	50a010ef          	jal	4cf2 <exit>
    printf("%s: fork failed\n", s);
    37ec:	85a6                	mv	a1,s1
    37ee:	00002517          	auipc	a0,0x2
    37f2:	39a50513          	addi	a0,a0,922 # 5b88 <malloc+0x9c4>
    37f6:	117010ef          	jal	510c <printf>
    exit(1);
    37fa:	4505                	li	a0,1
    37fc:	4f6010ef          	jal	4cf2 <exit>
    exit(0);
    3800:	4501                	li	a0,0
    3802:	4f0010ef          	jal	4cf2 <exit>
  sleep(1);
    3806:	4505                	li	a0,1
    3808:	57a010ef          	jal	4d82 <sleep>
  if(unlink("oidir") != 0){
    380c:	00003517          	auipc	a0,0x3
    3810:	63c50513          	addi	a0,a0,1596 # 6e48 <malloc+0x1c84>
    3814:	52e010ef          	jal	4d42 <unlink>
    3818:	c919                	beqz	a0,382e <openiputtest+0xa2>
    printf("%s: unlink failed\n", s);
    381a:	85a6                	mv	a1,s1
    381c:	00002517          	auipc	a0,0x2
    3820:	55c50513          	addi	a0,a0,1372 # 5d78 <malloc+0xbb4>
    3824:	0e9010ef          	jal	510c <printf>
    exit(1);
    3828:	4505                	li	a0,1
    382a:	4c8010ef          	jal	4cf2 <exit>
  wait(&xstatus);
    382e:	fdc40513          	addi	a0,s0,-36
    3832:	4c8010ef          	jal	4cfa <wait>
  exit(xstatus);
    3836:	fdc42503          	lw	a0,-36(s0)
    383a:	4b8010ef          	jal	4cf2 <exit>

000000000000383e <forkforkfork>:
{
    383e:	1101                	addi	sp,sp,-32
    3840:	ec06                	sd	ra,24(sp)
    3842:	e822                	sd	s0,16(sp)
    3844:	e426                	sd	s1,8(sp)
    3846:	1000                	addi	s0,sp,32
    3848:	84aa                	mv	s1,a0
  unlink("stopforking");
    384a:	00003517          	auipc	a0,0x3
    384e:	64650513          	addi	a0,a0,1606 # 6e90 <malloc+0x1ccc>
    3852:	4f0010ef          	jal	4d42 <unlink>
  int pid = fork();
    3856:	494010ef          	jal	4cea <fork>
  if(pid < 0){
    385a:	02054b63          	bltz	a0,3890 <forkforkfork+0x52>
  if(pid == 0){
    385e:	c139                	beqz	a0,38a4 <forkforkfork+0x66>
  sleep(20); // two seconds
    3860:	4551                	li	a0,20
    3862:	520010ef          	jal	4d82 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3866:	20200593          	li	a1,514
    386a:	00003517          	auipc	a0,0x3
    386e:	62650513          	addi	a0,a0,1574 # 6e90 <malloc+0x1ccc>
    3872:	4c0010ef          	jal	4d32 <open>
    3876:	4a4010ef          	jal	4d1a <close>
  wait(0);
    387a:	4501                	li	a0,0
    387c:	47e010ef          	jal	4cfa <wait>
  sleep(10); // one second
    3880:	4529                	li	a0,10
    3882:	500010ef          	jal	4d82 <sleep>
}
    3886:	60e2                	ld	ra,24(sp)
    3888:	6442                	ld	s0,16(sp)
    388a:	64a2                	ld	s1,8(sp)
    388c:	6105                	addi	sp,sp,32
    388e:	8082                	ret
    printf("%s: fork failed", s);
    3890:	85a6                	mv	a1,s1
    3892:	00002517          	auipc	a0,0x2
    3896:	4b650513          	addi	a0,a0,1206 # 5d48 <malloc+0xb84>
    389a:	073010ef          	jal	510c <printf>
    exit(1);
    389e:	4505                	li	a0,1
    38a0:	452010ef          	jal	4cf2 <exit>
      int fd = open("stopforking", 0);
    38a4:	00003497          	auipc	s1,0x3
    38a8:	5ec48493          	addi	s1,s1,1516 # 6e90 <malloc+0x1ccc>
    38ac:	4581                	li	a1,0
    38ae:	8526                	mv	a0,s1
    38b0:	482010ef          	jal	4d32 <open>
      if(fd >= 0){
    38b4:	02055163          	bgez	a0,38d6 <forkforkfork+0x98>
      if(fork() < 0){
    38b8:	432010ef          	jal	4cea <fork>
    38bc:	fe0558e3          	bgez	a0,38ac <forkforkfork+0x6e>
        close(open("stopforking", O_CREATE|O_RDWR));
    38c0:	20200593          	li	a1,514
    38c4:	00003517          	auipc	a0,0x3
    38c8:	5cc50513          	addi	a0,a0,1484 # 6e90 <malloc+0x1ccc>
    38cc:	466010ef          	jal	4d32 <open>
    38d0:	44a010ef          	jal	4d1a <close>
    38d4:	bfe1                	j	38ac <forkforkfork+0x6e>
        exit(0);
    38d6:	4501                	li	a0,0
    38d8:	41a010ef          	jal	4cf2 <exit>

00000000000038dc <killstatus>:
{
    38dc:	715d                	addi	sp,sp,-80
    38de:	e486                	sd	ra,72(sp)
    38e0:	e0a2                	sd	s0,64(sp)
    38e2:	fc26                	sd	s1,56(sp)
    38e4:	f84a                	sd	s2,48(sp)
    38e6:	f44e                	sd	s3,40(sp)
    38e8:	f052                	sd	s4,32(sp)
    38ea:	ec56                	sd	s5,24(sp)
    38ec:	e85a                	sd	s6,16(sp)
    38ee:	0880                	addi	s0,sp,80
    38f0:	8b2a                	mv	s6,a0
    38f2:	06400913          	li	s2,100
    sleep(1);
    38f6:	4a85                	li	s5,1
    wait(&xst);
    38f8:	fbc40a13          	addi	s4,s0,-68
    if(xst != -1) {
    38fc:	59fd                	li	s3,-1
    int pid1 = fork();
    38fe:	3ec010ef          	jal	4cea <fork>
    3902:	84aa                	mv	s1,a0
    if(pid1 < 0){
    3904:	02054663          	bltz	a0,3930 <killstatus+0x54>
    if(pid1 == 0){
    3908:	cd15                	beqz	a0,3944 <killstatus+0x68>
    sleep(1);
    390a:	8556                	mv	a0,s5
    390c:	476010ef          	jal	4d82 <sleep>
    kill(pid1);
    3910:	8526                	mv	a0,s1
    3912:	410010ef          	jal	4d22 <kill>
    wait(&xst);
    3916:	8552                	mv	a0,s4
    3918:	3e2010ef          	jal	4cfa <wait>
    if(xst != -1) {
    391c:	fbc42783          	lw	a5,-68(s0)
    3920:	03379563          	bne	a5,s3,394a <killstatus+0x6e>
  for(int i = 0; i < 100; i++){
    3924:	397d                	addiw	s2,s2,-1
    3926:	fc091ce3          	bnez	s2,38fe <killstatus+0x22>
  exit(0);
    392a:	4501                	li	a0,0
    392c:	3c6010ef          	jal	4cf2 <exit>
      printf("%s: fork failed\n", s);
    3930:	85da                	mv	a1,s6
    3932:	00002517          	auipc	a0,0x2
    3936:	25650513          	addi	a0,a0,598 # 5b88 <malloc+0x9c4>
    393a:	7d2010ef          	jal	510c <printf>
      exit(1);
    393e:	4505                	li	a0,1
    3940:	3b2010ef          	jal	4cf2 <exit>
        getpid();
    3944:	42e010ef          	jal	4d72 <getpid>
      while(1) {
    3948:	bff5                	j	3944 <killstatus+0x68>
       printf("%s: status should be -1\n", s);
    394a:	85da                	mv	a1,s6
    394c:	00003517          	auipc	a0,0x3
    3950:	55450513          	addi	a0,a0,1364 # 6ea0 <malloc+0x1cdc>
    3954:	7b8010ef          	jal	510c <printf>
       exit(1);
    3958:	4505                	li	a0,1
    395a:	398010ef          	jal	4cf2 <exit>

000000000000395e <preempt>:
{
    395e:	7139                	addi	sp,sp,-64
    3960:	fc06                	sd	ra,56(sp)
    3962:	f822                	sd	s0,48(sp)
    3964:	f426                	sd	s1,40(sp)
    3966:	f04a                	sd	s2,32(sp)
    3968:	ec4e                	sd	s3,24(sp)
    396a:	e852                	sd	s4,16(sp)
    396c:	0080                	addi	s0,sp,64
    396e:	892a                	mv	s2,a0
  pid1 = fork();
    3970:	37a010ef          	jal	4cea <fork>
  if(pid1 < 0) {
    3974:	00054563          	bltz	a0,397e <preempt+0x20>
    3978:	84aa                	mv	s1,a0
  if(pid1 == 0)
    397a:	ed01                	bnez	a0,3992 <preempt+0x34>
    for(;;)
    397c:	a001                	j	397c <preempt+0x1e>
    printf("%s: fork failed", s);
    397e:	85ca                	mv	a1,s2
    3980:	00002517          	auipc	a0,0x2
    3984:	3c850513          	addi	a0,a0,968 # 5d48 <malloc+0xb84>
    3988:	784010ef          	jal	510c <printf>
    exit(1);
    398c:	4505                	li	a0,1
    398e:	364010ef          	jal	4cf2 <exit>
  pid2 = fork();
    3992:	358010ef          	jal	4cea <fork>
    3996:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3998:	00054463          	bltz	a0,39a0 <preempt+0x42>
  if(pid2 == 0)
    399c:	ed01                	bnez	a0,39b4 <preempt+0x56>
    for(;;)
    399e:	a001                	j	399e <preempt+0x40>
    printf("%s: fork failed\n", s);
    39a0:	85ca                	mv	a1,s2
    39a2:	00002517          	auipc	a0,0x2
    39a6:	1e650513          	addi	a0,a0,486 # 5b88 <malloc+0x9c4>
    39aa:	762010ef          	jal	510c <printf>
    exit(1);
    39ae:	4505                	li	a0,1
    39b0:	342010ef          	jal	4cf2 <exit>
  pipe(pfds);
    39b4:	fc840513          	addi	a0,s0,-56
    39b8:	34a010ef          	jal	4d02 <pipe>
  pid3 = fork();
    39bc:	32e010ef          	jal	4cea <fork>
    39c0:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    39c2:	02054863          	bltz	a0,39f2 <preempt+0x94>
  if(pid3 == 0){
    39c6:	e921                	bnez	a0,3a16 <preempt+0xb8>
    close(pfds[0]);
    39c8:	fc842503          	lw	a0,-56(s0)
    39cc:	34e010ef          	jal	4d1a <close>
    if(write(pfds[1], "x", 1) != 1)
    39d0:	4605                	li	a2,1
    39d2:	00002597          	auipc	a1,0x2
    39d6:	99658593          	addi	a1,a1,-1642 # 5368 <malloc+0x1a4>
    39da:	fcc42503          	lw	a0,-52(s0)
    39de:	334010ef          	jal	4d12 <write>
    39e2:	4785                	li	a5,1
    39e4:	02f51163          	bne	a0,a5,3a06 <preempt+0xa8>
    close(pfds[1]);
    39e8:	fcc42503          	lw	a0,-52(s0)
    39ec:	32e010ef          	jal	4d1a <close>
    for(;;)
    39f0:	a001                	j	39f0 <preempt+0x92>
     printf("%s: fork failed\n", s);
    39f2:	85ca                	mv	a1,s2
    39f4:	00002517          	auipc	a0,0x2
    39f8:	19450513          	addi	a0,a0,404 # 5b88 <malloc+0x9c4>
    39fc:	710010ef          	jal	510c <printf>
     exit(1);
    3a00:	4505                	li	a0,1
    3a02:	2f0010ef          	jal	4cf2 <exit>
      printf("%s: preempt write error", s);
    3a06:	85ca                	mv	a1,s2
    3a08:	00003517          	auipc	a0,0x3
    3a0c:	4b850513          	addi	a0,a0,1208 # 6ec0 <malloc+0x1cfc>
    3a10:	6fc010ef          	jal	510c <printf>
    3a14:	bfd1                	j	39e8 <preempt+0x8a>
  close(pfds[1]);
    3a16:	fcc42503          	lw	a0,-52(s0)
    3a1a:	300010ef          	jal	4d1a <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3a1e:	660d                	lui	a2,0x3
    3a20:	00009597          	auipc	a1,0x9
    3a24:	25858593          	addi	a1,a1,600 # cc78 <buf>
    3a28:	fc842503          	lw	a0,-56(s0)
    3a2c:	2de010ef          	jal	4d0a <read>
    3a30:	4785                	li	a5,1
    3a32:	02f50163          	beq	a0,a5,3a54 <preempt+0xf6>
    printf("%s: preempt read error", s);
    3a36:	85ca                	mv	a1,s2
    3a38:	00003517          	auipc	a0,0x3
    3a3c:	4a050513          	addi	a0,a0,1184 # 6ed8 <malloc+0x1d14>
    3a40:	6cc010ef          	jal	510c <printf>
}
    3a44:	70e2                	ld	ra,56(sp)
    3a46:	7442                	ld	s0,48(sp)
    3a48:	74a2                	ld	s1,40(sp)
    3a4a:	7902                	ld	s2,32(sp)
    3a4c:	69e2                	ld	s3,24(sp)
    3a4e:	6a42                	ld	s4,16(sp)
    3a50:	6121                	addi	sp,sp,64
    3a52:	8082                	ret
  close(pfds[0]);
    3a54:	fc842503          	lw	a0,-56(s0)
    3a58:	2c2010ef          	jal	4d1a <close>
  printf("kill... ");
    3a5c:	00003517          	auipc	a0,0x3
    3a60:	49450513          	addi	a0,a0,1172 # 6ef0 <malloc+0x1d2c>
    3a64:	6a8010ef          	jal	510c <printf>
  kill(pid1);
    3a68:	8526                	mv	a0,s1
    3a6a:	2b8010ef          	jal	4d22 <kill>
  kill(pid2);
    3a6e:	854e                	mv	a0,s3
    3a70:	2b2010ef          	jal	4d22 <kill>
  kill(pid3);
    3a74:	8552                	mv	a0,s4
    3a76:	2ac010ef          	jal	4d22 <kill>
  printf("wait... ");
    3a7a:	00003517          	auipc	a0,0x3
    3a7e:	48650513          	addi	a0,a0,1158 # 6f00 <malloc+0x1d3c>
    3a82:	68a010ef          	jal	510c <printf>
  wait(0);
    3a86:	4501                	li	a0,0
    3a88:	272010ef          	jal	4cfa <wait>
  wait(0);
    3a8c:	4501                	li	a0,0
    3a8e:	26c010ef          	jal	4cfa <wait>
  wait(0);
    3a92:	4501                	li	a0,0
    3a94:	266010ef          	jal	4cfa <wait>
    3a98:	b775                	j	3a44 <preempt+0xe6>

0000000000003a9a <reparent>:
{
    3a9a:	7179                	addi	sp,sp,-48
    3a9c:	f406                	sd	ra,40(sp)
    3a9e:	f022                	sd	s0,32(sp)
    3aa0:	ec26                	sd	s1,24(sp)
    3aa2:	e84a                	sd	s2,16(sp)
    3aa4:	e44e                	sd	s3,8(sp)
    3aa6:	e052                	sd	s4,0(sp)
    3aa8:	1800                	addi	s0,sp,48
    3aaa:	89aa                	mv	s3,a0
  int master_pid = getpid();
    3aac:	2c6010ef          	jal	4d72 <getpid>
    3ab0:	8a2a                	mv	s4,a0
    3ab2:	0c800913          	li	s2,200
    int pid = fork();
    3ab6:	234010ef          	jal	4cea <fork>
    3aba:	84aa                	mv	s1,a0
    if(pid < 0){
    3abc:	00054e63          	bltz	a0,3ad8 <reparent+0x3e>
    if(pid){
    3ac0:	c121                	beqz	a0,3b00 <reparent+0x66>
      if(wait(0) != pid){
    3ac2:	4501                	li	a0,0
    3ac4:	236010ef          	jal	4cfa <wait>
    3ac8:	02951263          	bne	a0,s1,3aec <reparent+0x52>
  for(int i = 0; i < 200; i++){
    3acc:	397d                	addiw	s2,s2,-1
    3ace:	fe0914e3          	bnez	s2,3ab6 <reparent+0x1c>
  exit(0);
    3ad2:	4501                	li	a0,0
    3ad4:	21e010ef          	jal	4cf2 <exit>
      printf("%s: fork failed\n", s);
    3ad8:	85ce                	mv	a1,s3
    3ada:	00002517          	auipc	a0,0x2
    3ade:	0ae50513          	addi	a0,a0,174 # 5b88 <malloc+0x9c4>
    3ae2:	62a010ef          	jal	510c <printf>
      exit(1);
    3ae6:	4505                	li	a0,1
    3ae8:	20a010ef          	jal	4cf2 <exit>
        printf("%s: wait wrong pid\n", s);
    3aec:	85ce                	mv	a1,s3
    3aee:	00002517          	auipc	a0,0x2
    3af2:	22250513          	addi	a0,a0,546 # 5d10 <malloc+0xb4c>
    3af6:	616010ef          	jal	510c <printf>
        exit(1);
    3afa:	4505                	li	a0,1
    3afc:	1f6010ef          	jal	4cf2 <exit>
      int pid2 = fork();
    3b00:	1ea010ef          	jal	4cea <fork>
      if(pid2 < 0){
    3b04:	00054563          	bltz	a0,3b0e <reparent+0x74>
      exit(0);
    3b08:	4501                	li	a0,0
    3b0a:	1e8010ef          	jal	4cf2 <exit>
        kill(master_pid);
    3b0e:	8552                	mv	a0,s4
    3b10:	212010ef          	jal	4d22 <kill>
        exit(1);
    3b14:	4505                	li	a0,1
    3b16:	1dc010ef          	jal	4cf2 <exit>

0000000000003b1a <sbrkfail>:
{
    3b1a:	7175                	addi	sp,sp,-144
    3b1c:	e506                	sd	ra,136(sp)
    3b1e:	e122                	sd	s0,128(sp)
    3b20:	fca6                	sd	s1,120(sp)
    3b22:	f8ca                	sd	s2,112(sp)
    3b24:	f4ce                	sd	s3,104(sp)
    3b26:	f0d2                	sd	s4,96(sp)
    3b28:	ecd6                	sd	s5,88(sp)
    3b2a:	e8da                	sd	s6,80(sp)
    3b2c:	e4de                	sd	s7,72(sp)
    3b2e:	0900                	addi	s0,sp,144
    3b30:	8baa                	mv	s7,a0
  if(pipe(fds) != 0){
    3b32:	fa040513          	addi	a0,s0,-96
    3b36:	1cc010ef          	jal	4d02 <pipe>
    3b3a:	e919                	bnez	a0,3b50 <sbrkfail+0x36>
    3b3c:	f7040493          	addi	s1,s0,-144
    3b40:	f9840993          	addi	s3,s0,-104
    3b44:	8926                	mv	s2,s1
    if(pids[i] != -1)
    3b46:	5a7d                	li	s4,-1
      read(fds[0], &scratch, 1);
    3b48:	f9f40b13          	addi	s6,s0,-97
    3b4c:	4a85                	li	s5,1
    3b4e:	a0a9                	j	3b98 <sbrkfail+0x7e>
    printf("%s: pipe() failed\n", s);
    3b50:	85de                	mv	a1,s7
    3b52:	00002517          	auipc	a0,0x2
    3b56:	13e50513          	addi	a0,a0,318 # 5c90 <malloc+0xacc>
    3b5a:	5b2010ef          	jal	510c <printf>
    exit(1);
    3b5e:	4505                	li	a0,1
    3b60:	192010ef          	jal	4cf2 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3b64:	216010ef          	jal	4d7a <sbrk>
    3b68:	064007b7          	lui	a5,0x6400
    3b6c:	40a7853b          	subw	a0,a5,a0
    3b70:	20a010ef          	jal	4d7a <sbrk>
      write(fds[1], "x", 1);
    3b74:	4605                	li	a2,1
    3b76:	00001597          	auipc	a1,0x1
    3b7a:	7f258593          	addi	a1,a1,2034 # 5368 <malloc+0x1a4>
    3b7e:	fa442503          	lw	a0,-92(s0)
    3b82:	190010ef          	jal	4d12 <write>
      for(;;) sleep(1000);
    3b86:	3e800493          	li	s1,1000
    3b8a:	8526                	mv	a0,s1
    3b8c:	1f6010ef          	jal	4d82 <sleep>
    3b90:	bfed                	j	3b8a <sbrkfail+0x70>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3b92:	0911                	addi	s2,s2,4
    3b94:	03390063          	beq	s2,s3,3bb4 <sbrkfail+0x9a>
    if((pids[i] = fork()) == 0){
    3b98:	152010ef          	jal	4cea <fork>
    3b9c:	00a92023          	sw	a0,0(s2)
    3ba0:	d171                	beqz	a0,3b64 <sbrkfail+0x4a>
    if(pids[i] != -1)
    3ba2:	ff4508e3          	beq	a0,s4,3b92 <sbrkfail+0x78>
      read(fds[0], &scratch, 1);
    3ba6:	8656                	mv	a2,s5
    3ba8:	85da                	mv	a1,s6
    3baa:	fa042503          	lw	a0,-96(s0)
    3bae:	15c010ef          	jal	4d0a <read>
    3bb2:	b7c5                	j	3b92 <sbrkfail+0x78>
  c = sbrk(PGSIZE);
    3bb4:	6505                	lui	a0,0x1
    3bb6:	1c4010ef          	jal	4d7a <sbrk>
    3bba:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    3bbc:	597d                	li	s2,-1
    3bbe:	a021                	j	3bc6 <sbrkfail+0xac>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3bc0:	0491                	addi	s1,s1,4
    3bc2:	01348b63          	beq	s1,s3,3bd8 <sbrkfail+0xbe>
    if(pids[i] == -1)
    3bc6:	4088                	lw	a0,0(s1)
    3bc8:	ff250ce3          	beq	a0,s2,3bc0 <sbrkfail+0xa6>
    kill(pids[i]);
    3bcc:	156010ef          	jal	4d22 <kill>
    wait(0);
    3bd0:	4501                	li	a0,0
    3bd2:	128010ef          	jal	4cfa <wait>
    3bd6:	b7ed                	j	3bc0 <sbrkfail+0xa6>
  if(c == (char*)0xffffffffffffffffL){
    3bd8:	57fd                	li	a5,-1
    3bda:	02fa0f63          	beq	s4,a5,3c18 <sbrkfail+0xfe>
  pid = fork();
    3bde:	10c010ef          	jal	4cea <fork>
    3be2:	84aa                	mv	s1,a0
  if(pid < 0){
    3be4:	04054463          	bltz	a0,3c2c <sbrkfail+0x112>
  if(pid == 0){
    3be8:	cd21                	beqz	a0,3c40 <sbrkfail+0x126>
  wait(&xstatus);
    3bea:	fac40513          	addi	a0,s0,-84
    3bee:	10c010ef          	jal	4cfa <wait>
  if(xstatus != -1 && xstatus != 2)
    3bf2:	fac42783          	lw	a5,-84(s0)
    3bf6:	577d                	li	a4,-1
    3bf8:	00e78563          	beq	a5,a4,3c02 <sbrkfail+0xe8>
    3bfc:	4709                	li	a4,2
    3bfe:	06e79f63          	bne	a5,a4,3c7c <sbrkfail+0x162>
}
    3c02:	60aa                	ld	ra,136(sp)
    3c04:	640a                	ld	s0,128(sp)
    3c06:	74e6                	ld	s1,120(sp)
    3c08:	7946                	ld	s2,112(sp)
    3c0a:	79a6                	ld	s3,104(sp)
    3c0c:	7a06                	ld	s4,96(sp)
    3c0e:	6ae6                	ld	s5,88(sp)
    3c10:	6b46                	ld	s6,80(sp)
    3c12:	6ba6                	ld	s7,72(sp)
    3c14:	6149                	addi	sp,sp,144
    3c16:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    3c18:	85de                	mv	a1,s7
    3c1a:	00003517          	auipc	a0,0x3
    3c1e:	2f650513          	addi	a0,a0,758 # 6f10 <malloc+0x1d4c>
    3c22:	4ea010ef          	jal	510c <printf>
    exit(1);
    3c26:	4505                	li	a0,1
    3c28:	0ca010ef          	jal	4cf2 <exit>
    printf("%s: fork failed\n", s);
    3c2c:	85de                	mv	a1,s7
    3c2e:	00002517          	auipc	a0,0x2
    3c32:	f5a50513          	addi	a0,a0,-166 # 5b88 <malloc+0x9c4>
    3c36:	4d6010ef          	jal	510c <printf>
    exit(1);
    3c3a:	4505                	li	a0,1
    3c3c:	0b6010ef          	jal	4cf2 <exit>
    a = sbrk(0);
    3c40:	4501                	li	a0,0
    3c42:	138010ef          	jal	4d7a <sbrk>
    3c46:	892a                	mv	s2,a0
    sbrk(10*BIG);
    3c48:	3e800537          	lui	a0,0x3e800
    3c4c:	12e010ef          	jal	4d7a <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3c50:	87ca                	mv	a5,s2
    3c52:	3e800737          	lui	a4,0x3e800
    3c56:	993a                	add	s2,s2,a4
    3c58:	6705                	lui	a4,0x1
      n += *(a+i);
    3c5a:	0007c603          	lbu	a2,0(a5) # 6400000 <base+0x63f0388>
    3c5e:	9e25                	addw	a2,a2,s1
    3c60:	84b2                	mv	s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3c62:	97ba                	add	a5,a5,a4
    3c64:	fef91be3          	bne	s2,a5,3c5a <sbrkfail+0x140>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    3c68:	85de                	mv	a1,s7
    3c6a:	00003517          	auipc	a0,0x3
    3c6e:	2c650513          	addi	a0,a0,710 # 6f30 <malloc+0x1d6c>
    3c72:	49a010ef          	jal	510c <printf>
    exit(1);
    3c76:	4505                	li	a0,1
    3c78:	07a010ef          	jal	4cf2 <exit>
    exit(1);
    3c7c:	4505                	li	a0,1
    3c7e:	074010ef          	jal	4cf2 <exit>

0000000000003c82 <mem>:
{
    3c82:	7139                	addi	sp,sp,-64
    3c84:	fc06                	sd	ra,56(sp)
    3c86:	f822                	sd	s0,48(sp)
    3c88:	f426                	sd	s1,40(sp)
    3c8a:	f04a                	sd	s2,32(sp)
    3c8c:	ec4e                	sd	s3,24(sp)
    3c8e:	0080                	addi	s0,sp,64
    3c90:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3c92:	058010ef          	jal	4cea <fork>
    m1 = 0;
    3c96:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3c98:	6909                	lui	s2,0x2
    3c9a:	71190913          	addi	s2,s2,1809 # 2711 <sbrklast+0x27>
  if((pid = fork()) == 0){
    3c9e:	cd11                	beqz	a0,3cba <mem+0x38>
    wait(&xstatus);
    3ca0:	fcc40513          	addi	a0,s0,-52
    3ca4:	056010ef          	jal	4cfa <wait>
    if(xstatus == -1){
    3ca8:	fcc42503          	lw	a0,-52(s0)
    3cac:	57fd                	li	a5,-1
    3cae:	04f50363          	beq	a0,a5,3cf4 <mem+0x72>
    exit(xstatus);
    3cb2:	040010ef          	jal	4cf2 <exit>
      *(char**)m2 = m1;
    3cb6:	e104                	sd	s1,0(a0)
      m1 = m2;
    3cb8:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    3cba:	854a                	mv	a0,s2
    3cbc:	508010ef          	jal	51c4 <malloc>
    3cc0:	f97d                	bnez	a0,3cb6 <mem+0x34>
    while(m1){
    3cc2:	c491                	beqz	s1,3cce <mem+0x4c>
      m2 = *(char**)m1;
    3cc4:	8526                	mv	a0,s1
    3cc6:	6084                	ld	s1,0(s1)
      free(m1);
    3cc8:	476010ef          	jal	513e <free>
    while(m1){
    3ccc:	fce5                	bnez	s1,3cc4 <mem+0x42>
    m1 = malloc(1024*20);
    3cce:	6515                	lui	a0,0x5
    3cd0:	4f4010ef          	jal	51c4 <malloc>
    if(m1 == 0){
    3cd4:	c511                	beqz	a0,3ce0 <mem+0x5e>
    free(m1);
    3cd6:	468010ef          	jal	513e <free>
    exit(0);
    3cda:	4501                	li	a0,0
    3cdc:	016010ef          	jal	4cf2 <exit>
      printf("%s: couldn't allocate mem?!!\n", s);
    3ce0:	85ce                	mv	a1,s3
    3ce2:	00003517          	auipc	a0,0x3
    3ce6:	27e50513          	addi	a0,a0,638 # 6f60 <malloc+0x1d9c>
    3cea:	422010ef          	jal	510c <printf>
      exit(1);
    3cee:	4505                	li	a0,1
    3cf0:	002010ef          	jal	4cf2 <exit>
      exit(0);
    3cf4:	4501                	li	a0,0
    3cf6:	7fd000ef          	jal	4cf2 <exit>

0000000000003cfa <sharedfd>:
{
    3cfa:	7119                	addi	sp,sp,-128
    3cfc:	fc86                	sd	ra,120(sp)
    3cfe:	f8a2                	sd	s0,112(sp)
    3d00:	e0da                	sd	s6,64(sp)
    3d02:	0100                	addi	s0,sp,128
    3d04:	8b2a                	mv	s6,a0
  unlink("sharedfd");
    3d06:	00003517          	auipc	a0,0x3
    3d0a:	27a50513          	addi	a0,a0,634 # 6f80 <malloc+0x1dbc>
    3d0e:	034010ef          	jal	4d42 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    3d12:	20200593          	li	a1,514
    3d16:	00003517          	auipc	a0,0x3
    3d1a:	26a50513          	addi	a0,a0,618 # 6f80 <malloc+0x1dbc>
    3d1e:	014010ef          	jal	4d32 <open>
  if(fd < 0){
    3d22:	04054b63          	bltz	a0,3d78 <sharedfd+0x7e>
    3d26:	f4a6                	sd	s1,104(sp)
    3d28:	f0ca                	sd	s2,96(sp)
    3d2a:	ecce                	sd	s3,88(sp)
    3d2c:	e8d2                	sd	s4,80(sp)
    3d2e:	e4d6                	sd	s5,72(sp)
    3d30:	89aa                	mv	s3,a0
  pid = fork();
    3d32:	7b9000ef          	jal	4cea <fork>
    3d36:	8aaa                	mv	s5,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    3d38:	07000593          	li	a1,112
    3d3c:	e119                	bnez	a0,3d42 <sharedfd+0x48>
    3d3e:	06300593          	li	a1,99
    3d42:	4629                	li	a2,10
    3d44:	f9040513          	addi	a0,s0,-112
    3d48:	59d000ef          	jal	4ae4 <memset>
    3d4c:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    3d50:	f9040a13          	addi	s4,s0,-112
    3d54:	4929                	li	s2,10
    3d56:	864a                	mv	a2,s2
    3d58:	85d2                	mv	a1,s4
    3d5a:	854e                	mv	a0,s3
    3d5c:	7b7000ef          	jal	4d12 <write>
    3d60:	03251e63          	bne	a0,s2,3d9c <sharedfd+0xa2>
  for(i = 0; i < N; i++){
    3d64:	34fd                	addiw	s1,s1,-1
    3d66:	f8e5                	bnez	s1,3d56 <sharedfd+0x5c>
  if(pid == 0) {
    3d68:	040a9763          	bnez	s5,3db6 <sharedfd+0xbc>
    3d6c:	fc5e                	sd	s7,56(sp)
    3d6e:	f862                	sd	s8,48(sp)
    3d70:	f466                	sd	s9,40(sp)
    exit(0);
    3d72:	4501                	li	a0,0
    3d74:	77f000ef          	jal	4cf2 <exit>
    3d78:	f4a6                	sd	s1,104(sp)
    3d7a:	f0ca                	sd	s2,96(sp)
    3d7c:	ecce                	sd	s3,88(sp)
    3d7e:	e8d2                	sd	s4,80(sp)
    3d80:	e4d6                	sd	s5,72(sp)
    3d82:	fc5e                	sd	s7,56(sp)
    3d84:	f862                	sd	s8,48(sp)
    3d86:	f466                	sd	s9,40(sp)
    printf("%s: cannot open sharedfd for writing", s);
    3d88:	85da                	mv	a1,s6
    3d8a:	00003517          	auipc	a0,0x3
    3d8e:	20650513          	addi	a0,a0,518 # 6f90 <malloc+0x1dcc>
    3d92:	37a010ef          	jal	510c <printf>
    exit(1);
    3d96:	4505                	li	a0,1
    3d98:	75b000ef          	jal	4cf2 <exit>
    3d9c:	fc5e                	sd	s7,56(sp)
    3d9e:	f862                	sd	s8,48(sp)
    3da0:	f466                	sd	s9,40(sp)
      printf("%s: write sharedfd failed\n", s);
    3da2:	85da                	mv	a1,s6
    3da4:	00003517          	auipc	a0,0x3
    3da8:	21450513          	addi	a0,a0,532 # 6fb8 <malloc+0x1df4>
    3dac:	360010ef          	jal	510c <printf>
      exit(1);
    3db0:	4505                	li	a0,1
    3db2:	741000ef          	jal	4cf2 <exit>
    wait(&xstatus);
    3db6:	f8c40513          	addi	a0,s0,-116
    3dba:	741000ef          	jal	4cfa <wait>
    if(xstatus != 0)
    3dbe:	f8c42a03          	lw	s4,-116(s0)
    3dc2:	000a0863          	beqz	s4,3dd2 <sharedfd+0xd8>
    3dc6:	fc5e                	sd	s7,56(sp)
    3dc8:	f862                	sd	s8,48(sp)
    3dca:	f466                	sd	s9,40(sp)
      exit(xstatus);
    3dcc:	8552                	mv	a0,s4
    3dce:	725000ef          	jal	4cf2 <exit>
    3dd2:	fc5e                	sd	s7,56(sp)
  close(fd);
    3dd4:	854e                	mv	a0,s3
    3dd6:	745000ef          	jal	4d1a <close>
  fd = open("sharedfd", 0);
    3dda:	4581                	li	a1,0
    3ddc:	00003517          	auipc	a0,0x3
    3de0:	1a450513          	addi	a0,a0,420 # 6f80 <malloc+0x1dbc>
    3de4:	74f000ef          	jal	4d32 <open>
    3de8:	8baa                	mv	s7,a0
  nc = np = 0;
    3dea:	89d2                	mv	s3,s4
  if(fd < 0){
    3dec:	02054763          	bltz	a0,3e1a <sharedfd+0x120>
    3df0:	f862                	sd	s8,48(sp)
    3df2:	f466                	sd	s9,40(sp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
    3df4:	f9040c93          	addi	s9,s0,-112
    3df8:	4c29                	li	s8,10
    3dfa:	f9a40913          	addi	s2,s0,-102
      if(buf[i] == 'c')
    3dfe:	06300493          	li	s1,99
      if(buf[i] == 'p')
    3e02:	07000a93          	li	s5,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    3e06:	8662                	mv	a2,s8
    3e08:	85e6                	mv	a1,s9
    3e0a:	855e                	mv	a0,s7
    3e0c:	6ff000ef          	jal	4d0a <read>
    3e10:	02a05d63          	blez	a0,3e4a <sharedfd+0x150>
    3e14:	f9040793          	addi	a5,s0,-112
    3e18:	a00d                	j	3e3a <sharedfd+0x140>
    3e1a:	f862                	sd	s8,48(sp)
    3e1c:	f466                	sd	s9,40(sp)
    printf("%s: cannot open sharedfd for reading\n", s);
    3e1e:	85da                	mv	a1,s6
    3e20:	00003517          	auipc	a0,0x3
    3e24:	1b850513          	addi	a0,a0,440 # 6fd8 <malloc+0x1e14>
    3e28:	2e4010ef          	jal	510c <printf>
    exit(1);
    3e2c:	4505                	li	a0,1
    3e2e:	6c5000ef          	jal	4cf2 <exit>
        nc++;
    3e32:	2a05                	addiw	s4,s4,1
    for(i = 0; i < sizeof(buf); i++){
    3e34:	0785                	addi	a5,a5,1
    3e36:	fd2788e3          	beq	a5,s2,3e06 <sharedfd+0x10c>
      if(buf[i] == 'c')
    3e3a:	0007c703          	lbu	a4,0(a5)
    3e3e:	fe970ae3          	beq	a4,s1,3e32 <sharedfd+0x138>
      if(buf[i] == 'p')
    3e42:	ff5719e3          	bne	a4,s5,3e34 <sharedfd+0x13a>
        np++;
    3e46:	2985                	addiw	s3,s3,1
    3e48:	b7f5                	j	3e34 <sharedfd+0x13a>
  close(fd);
    3e4a:	855e                	mv	a0,s7
    3e4c:	6cf000ef          	jal	4d1a <close>
  unlink("sharedfd");
    3e50:	00003517          	auipc	a0,0x3
    3e54:	13050513          	addi	a0,a0,304 # 6f80 <malloc+0x1dbc>
    3e58:	6eb000ef          	jal	4d42 <unlink>
  if(nc == N*SZ && np == N*SZ){
    3e5c:	6789                	lui	a5,0x2
    3e5e:	71078793          	addi	a5,a5,1808 # 2710 <sbrklast+0x26>
    3e62:	00fa1763          	bne	s4,a5,3e70 <sharedfd+0x176>
    3e66:	6789                	lui	a5,0x2
    3e68:	71078793          	addi	a5,a5,1808 # 2710 <sbrklast+0x26>
    3e6c:	00f98c63          	beq	s3,a5,3e84 <sharedfd+0x18a>
    printf("%s: nc/np test fails\n", s);
    3e70:	85da                	mv	a1,s6
    3e72:	00003517          	auipc	a0,0x3
    3e76:	18e50513          	addi	a0,a0,398 # 7000 <malloc+0x1e3c>
    3e7a:	292010ef          	jal	510c <printf>
    exit(1);
    3e7e:	4505                	li	a0,1
    3e80:	673000ef          	jal	4cf2 <exit>
    exit(0);
    3e84:	4501                	li	a0,0
    3e86:	66d000ef          	jal	4cf2 <exit>

0000000000003e8a <fourfiles>:
{
    3e8a:	7135                	addi	sp,sp,-160
    3e8c:	ed06                	sd	ra,152(sp)
    3e8e:	e922                	sd	s0,144(sp)
    3e90:	e526                	sd	s1,136(sp)
    3e92:	e14a                	sd	s2,128(sp)
    3e94:	fcce                	sd	s3,120(sp)
    3e96:	f8d2                	sd	s4,112(sp)
    3e98:	f4d6                	sd	s5,104(sp)
    3e9a:	f0da                	sd	s6,96(sp)
    3e9c:	ecde                	sd	s7,88(sp)
    3e9e:	e8e2                	sd	s8,80(sp)
    3ea0:	e4e6                	sd	s9,72(sp)
    3ea2:	e0ea                	sd	s10,64(sp)
    3ea4:	fc6e                	sd	s11,56(sp)
    3ea6:	1100                	addi	s0,sp,160
    3ea8:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    3eaa:	00003797          	auipc	a5,0x3
    3eae:	16e78793          	addi	a5,a5,366 # 7018 <malloc+0x1e54>
    3eb2:	f6f43823          	sd	a5,-144(s0)
    3eb6:	00003797          	auipc	a5,0x3
    3eba:	16a78793          	addi	a5,a5,362 # 7020 <malloc+0x1e5c>
    3ebe:	f6f43c23          	sd	a5,-136(s0)
    3ec2:	00003797          	auipc	a5,0x3
    3ec6:	16678793          	addi	a5,a5,358 # 7028 <malloc+0x1e64>
    3eca:	f8f43023          	sd	a5,-128(s0)
    3ece:	00003797          	auipc	a5,0x3
    3ed2:	16278793          	addi	a5,a5,354 # 7030 <malloc+0x1e6c>
    3ed6:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    3eda:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    3ede:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    3ee0:	4481                	li	s1,0
    3ee2:	4a11                	li	s4,4
    fname = names[pi];
    3ee4:	00093983          	ld	s3,0(s2)
    unlink(fname);
    3ee8:	854e                	mv	a0,s3
    3eea:	659000ef          	jal	4d42 <unlink>
    pid = fork();
    3eee:	5fd000ef          	jal	4cea <fork>
    if(pid < 0){
    3ef2:	04054063          	bltz	a0,3f32 <fourfiles+0xa8>
    if(pid == 0){
    3ef6:	c921                	beqz	a0,3f46 <fourfiles+0xbc>
  for(pi = 0; pi < NCHILD; pi++){
    3ef8:	2485                	addiw	s1,s1,1
    3efa:	0921                	addi	s2,s2,8
    3efc:	ff4494e3          	bne	s1,s4,3ee4 <fourfiles+0x5a>
    3f00:	4491                	li	s1,4
    wait(&xstatus);
    3f02:	f6c40913          	addi	s2,s0,-148
    3f06:	854a                	mv	a0,s2
    3f08:	5f3000ef          	jal	4cfa <wait>
    if(xstatus != 0)
    3f0c:	f6c42b03          	lw	s6,-148(s0)
    3f10:	0a0b1463          	bnez	s6,3fb8 <fourfiles+0x12e>
  for(pi = 0; pi < NCHILD; pi++){
    3f14:	34fd                	addiw	s1,s1,-1
    3f16:	f8e5                	bnez	s1,3f06 <fourfiles+0x7c>
    3f18:	03000493          	li	s1,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3f1c:	6a8d                	lui	s5,0x3
    3f1e:	00009a17          	auipc	s4,0x9
    3f22:	d5aa0a13          	addi	s4,s4,-678 # cc78 <buf>
    if(total != N*SZ){
    3f26:	6d05                	lui	s10,0x1
    3f28:	770d0d13          	addi	s10,s10,1904 # 1770 <exitwait+0x90>
  for(i = 0; i < NCHILD; i++){
    3f2c:	03400d93          	li	s11,52
    3f30:	a86d                	j	3fea <fourfiles+0x160>
      printf("%s: fork failed\n", s);
    3f32:	85e6                	mv	a1,s9
    3f34:	00002517          	auipc	a0,0x2
    3f38:	c5450513          	addi	a0,a0,-940 # 5b88 <malloc+0x9c4>
    3f3c:	1d0010ef          	jal	510c <printf>
      exit(1);
    3f40:	4505                	li	a0,1
    3f42:	5b1000ef          	jal	4cf2 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    3f46:	20200593          	li	a1,514
    3f4a:	854e                	mv	a0,s3
    3f4c:	5e7000ef          	jal	4d32 <open>
    3f50:	892a                	mv	s2,a0
      if(fd < 0){
    3f52:	04054063          	bltz	a0,3f92 <fourfiles+0x108>
      memset(buf, '0'+pi, SZ);
    3f56:	1f400613          	li	a2,500
    3f5a:	0304859b          	addiw	a1,s1,48
    3f5e:	00009517          	auipc	a0,0x9
    3f62:	d1a50513          	addi	a0,a0,-742 # cc78 <buf>
    3f66:	37f000ef          	jal	4ae4 <memset>
    3f6a:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    3f6c:	1f400993          	li	s3,500
    3f70:	00009a17          	auipc	s4,0x9
    3f74:	d08a0a13          	addi	s4,s4,-760 # cc78 <buf>
    3f78:	864e                	mv	a2,s3
    3f7a:	85d2                	mv	a1,s4
    3f7c:	854a                	mv	a0,s2
    3f7e:	595000ef          	jal	4d12 <write>
    3f82:	85aa                	mv	a1,a0
    3f84:	03351163          	bne	a0,s3,3fa6 <fourfiles+0x11c>
      for(i = 0; i < N; i++){
    3f88:	34fd                	addiw	s1,s1,-1
    3f8a:	f4fd                	bnez	s1,3f78 <fourfiles+0xee>
      exit(0);
    3f8c:	4501                	li	a0,0
    3f8e:	565000ef          	jal	4cf2 <exit>
        printf("%s: create failed\n", s);
    3f92:	85e6                	mv	a1,s9
    3f94:	00002517          	auipc	a0,0x2
    3f98:	c8c50513          	addi	a0,a0,-884 # 5c20 <malloc+0xa5c>
    3f9c:	170010ef          	jal	510c <printf>
        exit(1);
    3fa0:	4505                	li	a0,1
    3fa2:	551000ef          	jal	4cf2 <exit>
          printf("write failed %d\n", n);
    3fa6:	00003517          	auipc	a0,0x3
    3faa:	09250513          	addi	a0,a0,146 # 7038 <malloc+0x1e74>
    3fae:	15e010ef          	jal	510c <printf>
          exit(1);
    3fb2:	4505                	li	a0,1
    3fb4:	53f000ef          	jal	4cf2 <exit>
      exit(xstatus);
    3fb8:	855a                	mv	a0,s6
    3fba:	539000ef          	jal	4cf2 <exit>
          printf("%s: wrong char\n", s);
    3fbe:	85e6                	mv	a1,s9
    3fc0:	00003517          	auipc	a0,0x3
    3fc4:	09050513          	addi	a0,a0,144 # 7050 <malloc+0x1e8c>
    3fc8:	144010ef          	jal	510c <printf>
          exit(1);
    3fcc:	4505                	li	a0,1
    3fce:	525000ef          	jal	4cf2 <exit>
    close(fd);
    3fd2:	854e                	mv	a0,s3
    3fd4:	547000ef          	jal	4d1a <close>
    if(total != N*SZ){
    3fd8:	05a91863          	bne	s2,s10,4028 <fourfiles+0x19e>
    unlink(fname);
    3fdc:	8562                	mv	a0,s8
    3fde:	565000ef          	jal	4d42 <unlink>
  for(i = 0; i < NCHILD; i++){
    3fe2:	0ba1                	addi	s7,s7,8
    3fe4:	2485                	addiw	s1,s1,1
    3fe6:	05b48b63          	beq	s1,s11,403c <fourfiles+0x1b2>
    fname = names[i];
    3fea:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    3fee:	4581                	li	a1,0
    3ff0:	8562                	mv	a0,s8
    3ff2:	541000ef          	jal	4d32 <open>
    3ff6:	89aa                	mv	s3,a0
    total = 0;
    3ff8:	895a                	mv	s2,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3ffa:	8656                	mv	a2,s5
    3ffc:	85d2                	mv	a1,s4
    3ffe:	854e                	mv	a0,s3
    4000:	50b000ef          	jal	4d0a <read>
    4004:	fca057e3          	blez	a0,3fd2 <fourfiles+0x148>
    4008:	00009797          	auipc	a5,0x9
    400c:	c7078793          	addi	a5,a5,-912 # cc78 <buf>
    4010:	00f506b3          	add	a3,a0,a5
        if(buf[j] != '0'+i){
    4014:	0007c703          	lbu	a4,0(a5)
    4018:	fa9713e3          	bne	a4,s1,3fbe <fourfiles+0x134>
      for(j = 0; j < n; j++){
    401c:	0785                	addi	a5,a5,1
    401e:	fed79be3          	bne	a5,a3,4014 <fourfiles+0x18a>
      total += n;
    4022:	00a9093b          	addw	s2,s2,a0
    4026:	bfd1                	j	3ffa <fourfiles+0x170>
      printf("wrong length %d\n", total);
    4028:	85ca                	mv	a1,s2
    402a:	00003517          	auipc	a0,0x3
    402e:	03650513          	addi	a0,a0,54 # 7060 <malloc+0x1e9c>
    4032:	0da010ef          	jal	510c <printf>
      exit(1);
    4036:	4505                	li	a0,1
    4038:	4bb000ef          	jal	4cf2 <exit>
}
    403c:	60ea                	ld	ra,152(sp)
    403e:	644a                	ld	s0,144(sp)
    4040:	64aa                	ld	s1,136(sp)
    4042:	690a                	ld	s2,128(sp)
    4044:	79e6                	ld	s3,120(sp)
    4046:	7a46                	ld	s4,112(sp)
    4048:	7aa6                	ld	s5,104(sp)
    404a:	7b06                	ld	s6,96(sp)
    404c:	6be6                	ld	s7,88(sp)
    404e:	6c46                	ld	s8,80(sp)
    4050:	6ca6                	ld	s9,72(sp)
    4052:	6d06                	ld	s10,64(sp)
    4054:	7de2                	ld	s11,56(sp)
    4056:	610d                	addi	sp,sp,160
    4058:	8082                	ret

000000000000405a <concreate>:
{
    405a:	7171                	addi	sp,sp,-176
    405c:	f506                	sd	ra,168(sp)
    405e:	f122                	sd	s0,160(sp)
    4060:	ed26                	sd	s1,152(sp)
    4062:	e94a                	sd	s2,144(sp)
    4064:	e54e                	sd	s3,136(sp)
    4066:	e152                	sd	s4,128(sp)
    4068:	fcd6                	sd	s5,120(sp)
    406a:	f8da                	sd	s6,112(sp)
    406c:	f4de                	sd	s7,104(sp)
    406e:	f0e2                	sd	s8,96(sp)
    4070:	ece6                	sd	s9,88(sp)
    4072:	e8ea                	sd	s10,80(sp)
    4074:	1900                	addi	s0,sp,176
    4076:	8baa                	mv	s7,a0
  file[0] = 'C';
    4078:	04300793          	li	a5,67
    407c:	f8f40c23          	sb	a5,-104(s0)
  file[2] = '\0';
    4080:	f8040d23          	sb	zero,-102(s0)
  for(i = 0; i < N; i++){
    4084:	4901                	li	s2,0
    unlink(file);
    4086:	f9840993          	addi	s3,s0,-104
    if(pid && (i % 3) == 1){
    408a:	55555b37          	lui	s6,0x55555
    408e:	556b0b13          	addi	s6,s6,1366 # 55555556 <base+0x555458de>
    4092:	4c05                	li	s8,1
      fd = open(file, O_CREATE | O_RDWR);
    4094:	20200c93          	li	s9,514
      link("C0", file);
    4098:	00003d17          	auipc	s10,0x3
    409c:	fe0d0d13          	addi	s10,s10,-32 # 7078 <malloc+0x1eb4>
      wait(&xstatus);
    40a0:	f5c40a93          	addi	s5,s0,-164
  for(i = 0; i < N; i++){
    40a4:	02800a13          	li	s4,40
    40a8:	ac2d                	j	42e2 <concreate+0x288>
      link("C0", file);
    40aa:	85ce                	mv	a1,s3
    40ac:	856a                	mv	a0,s10
    40ae:	4a5000ef          	jal	4d52 <link>
    if(pid == 0) {
    40b2:	ac31                	j	42ce <concreate+0x274>
    } else if(pid == 0 && (i % 5) == 1){
    40b4:	666667b7          	lui	a5,0x66666
    40b8:	66778793          	addi	a5,a5,1639 # 66666667 <base+0x666569ef>
    40bc:	02f907b3          	mul	a5,s2,a5
    40c0:	9785                	srai	a5,a5,0x21
    40c2:	41f9571b          	sraiw	a4,s2,0x1f
    40c6:	9f99                	subw	a5,a5,a4
    40c8:	0027971b          	slliw	a4,a5,0x2
    40cc:	9fb9                	addw	a5,a5,a4
    40ce:	40f9093b          	subw	s2,s2,a5
    40d2:	4785                	li	a5,1
    40d4:	02f90563          	beq	s2,a5,40fe <concreate+0xa4>
      fd = open(file, O_CREATE | O_RDWR);
    40d8:	20200593          	li	a1,514
    40dc:	f9840513          	addi	a0,s0,-104
    40e0:	453000ef          	jal	4d32 <open>
      if(fd < 0){
    40e4:	1e055063          	bgez	a0,42c4 <concreate+0x26a>
        printf("concreate create %s failed\n", file);
    40e8:	f9840593          	addi	a1,s0,-104
    40ec:	00003517          	auipc	a0,0x3
    40f0:	f9450513          	addi	a0,a0,-108 # 7080 <malloc+0x1ebc>
    40f4:	018010ef          	jal	510c <printf>
        exit(1);
    40f8:	4505                	li	a0,1
    40fa:	3f9000ef          	jal	4cf2 <exit>
      link("C0", file);
    40fe:	f9840593          	addi	a1,s0,-104
    4102:	00003517          	auipc	a0,0x3
    4106:	f7650513          	addi	a0,a0,-138 # 7078 <malloc+0x1eb4>
    410a:	449000ef          	jal	4d52 <link>
      exit(0);
    410e:	4501                	li	a0,0
    4110:	3e3000ef          	jal	4cf2 <exit>
        exit(1);
    4114:	4505                	li	a0,1
    4116:	3dd000ef          	jal	4cf2 <exit>
  memset(fa, 0, sizeof(fa));
    411a:	02800613          	li	a2,40
    411e:	4581                	li	a1,0
    4120:	f7040513          	addi	a0,s0,-144
    4124:	1c1000ef          	jal	4ae4 <memset>
  fd = open(".", 0);
    4128:	4581                	li	a1,0
    412a:	00002517          	auipc	a0,0x2
    412e:	8b650513          	addi	a0,a0,-1866 # 59e0 <malloc+0x81c>
    4132:	401000ef          	jal	4d32 <open>
    4136:	892a                	mv	s2,a0
  n = 0;
    4138:	8b26                	mv	s6,s1
  while(read(fd, &de, sizeof(de)) > 0){
    413a:	f6040a13          	addi	s4,s0,-160
    413e:	49c1                	li	s3,16
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4140:	04300a93          	li	s5,67
      if(i < 0 || i >= sizeof(fa)){
    4144:	02700c13          	li	s8,39
      fa[i] = 1;
    4148:	4c85                	li	s9,1
  while(read(fd, &de, sizeof(de)) > 0){
    414a:	864e                	mv	a2,s3
    414c:	85d2                	mv	a1,s4
    414e:	854a                	mv	a0,s2
    4150:	3bb000ef          	jal	4d0a <read>
    4154:	06a05763          	blez	a0,41c2 <concreate+0x168>
    if(de.inum == 0)
    4158:	f6045783          	lhu	a5,-160(s0)
    415c:	d7fd                	beqz	a5,414a <concreate+0xf0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    415e:	f6244783          	lbu	a5,-158(s0)
    4162:	ff5794e3          	bne	a5,s5,414a <concreate+0xf0>
    4166:	f6444783          	lbu	a5,-156(s0)
    416a:	f3e5                	bnez	a5,414a <concreate+0xf0>
      i = de.name[1] - '0';
    416c:	f6344783          	lbu	a5,-157(s0)
    4170:	fd07879b          	addiw	a5,a5,-48
      if(i < 0 || i >= sizeof(fa)){
    4174:	00fc6f63          	bltu	s8,a5,4192 <concreate+0x138>
      if(fa[i]){
    4178:	fa078713          	addi	a4,a5,-96
    417c:	9722                	add	a4,a4,s0
    417e:	fd074703          	lbu	a4,-48(a4) # fd0 <bigdir+0xda>
    4182:	e705                	bnez	a4,41aa <concreate+0x150>
      fa[i] = 1;
    4184:	fa078793          	addi	a5,a5,-96
    4188:	97a2                	add	a5,a5,s0
    418a:	fd978823          	sb	s9,-48(a5)
      n++;
    418e:	2b05                	addiw	s6,s6,1
    4190:	bf6d                	j	414a <concreate+0xf0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4192:	f6240613          	addi	a2,s0,-158
    4196:	85de                	mv	a1,s7
    4198:	00003517          	auipc	a0,0x3
    419c:	f0850513          	addi	a0,a0,-248 # 70a0 <malloc+0x1edc>
    41a0:	76d000ef          	jal	510c <printf>
        exit(1);
    41a4:	4505                	li	a0,1
    41a6:	34d000ef          	jal	4cf2 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    41aa:	f6240613          	addi	a2,s0,-158
    41ae:	85de                	mv	a1,s7
    41b0:	00003517          	auipc	a0,0x3
    41b4:	f1050513          	addi	a0,a0,-240 # 70c0 <malloc+0x1efc>
    41b8:	755000ef          	jal	510c <printf>
        exit(1);
    41bc:	4505                	li	a0,1
    41be:	335000ef          	jal	4cf2 <exit>
  close(fd);
    41c2:	854a                	mv	a0,s2
    41c4:	357000ef          	jal	4d1a <close>
  if(n != N){
    41c8:	02800793          	li	a5,40
    41cc:	00fb1b63          	bne	s6,a5,41e2 <concreate+0x188>
    if(((i % 3) == 0 && pid == 0) ||
    41d0:	55555a37          	lui	s4,0x55555
    41d4:	556a0a13          	addi	s4,s4,1366 # 55555556 <base+0x555458de>
      close(open(file, 0));
    41d8:	f9840993          	addi	s3,s0,-104
    if(((i % 3) == 0 && pid == 0) ||
    41dc:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    41de:	8abe                	mv	s5,a5
    41e0:	a049                	j	4262 <concreate+0x208>
    printf("%s: concreate not enough files in directory listing\n", s);
    41e2:	85de                	mv	a1,s7
    41e4:	00003517          	auipc	a0,0x3
    41e8:	f0450513          	addi	a0,a0,-252 # 70e8 <malloc+0x1f24>
    41ec:	721000ef          	jal	510c <printf>
    exit(1);
    41f0:	4505                	li	a0,1
    41f2:	301000ef          	jal	4cf2 <exit>
      printf("%s: fork failed\n", s);
    41f6:	85de                	mv	a1,s7
    41f8:	00002517          	auipc	a0,0x2
    41fc:	99050513          	addi	a0,a0,-1648 # 5b88 <malloc+0x9c4>
    4200:	70d000ef          	jal	510c <printf>
      exit(1);
    4204:	4505                	li	a0,1
    4206:	2ed000ef          	jal	4cf2 <exit>
      close(open(file, 0));
    420a:	4581                	li	a1,0
    420c:	854e                	mv	a0,s3
    420e:	325000ef          	jal	4d32 <open>
    4212:	309000ef          	jal	4d1a <close>
      close(open(file, 0));
    4216:	4581                	li	a1,0
    4218:	854e                	mv	a0,s3
    421a:	319000ef          	jal	4d32 <open>
    421e:	2fd000ef          	jal	4d1a <close>
      close(open(file, 0));
    4222:	4581                	li	a1,0
    4224:	854e                	mv	a0,s3
    4226:	30d000ef          	jal	4d32 <open>
    422a:	2f1000ef          	jal	4d1a <close>
      close(open(file, 0));
    422e:	4581                	li	a1,0
    4230:	854e                	mv	a0,s3
    4232:	301000ef          	jal	4d32 <open>
    4236:	2e5000ef          	jal	4d1a <close>
      close(open(file, 0));
    423a:	4581                	li	a1,0
    423c:	854e                	mv	a0,s3
    423e:	2f5000ef          	jal	4d32 <open>
    4242:	2d9000ef          	jal	4d1a <close>
      close(open(file, 0));
    4246:	4581                	li	a1,0
    4248:	854e                	mv	a0,s3
    424a:	2e9000ef          	jal	4d32 <open>
    424e:	2cd000ef          	jal	4d1a <close>
    if(pid == 0)
    4252:	06090663          	beqz	s2,42be <concreate+0x264>
      wait(0);
    4256:	4501                	li	a0,0
    4258:	2a3000ef          	jal	4cfa <wait>
  for(i = 0; i < N; i++){
    425c:	2485                	addiw	s1,s1,1
    425e:	0d548163          	beq	s1,s5,4320 <concreate+0x2c6>
    file[1] = '0' + i;
    4262:	0304879b          	addiw	a5,s1,48
    4266:	f8f40ca3          	sb	a5,-103(s0)
    pid = fork();
    426a:	281000ef          	jal	4cea <fork>
    426e:	892a                	mv	s2,a0
    if(pid < 0){
    4270:	f80543e3          	bltz	a0,41f6 <concreate+0x19c>
    if(((i % 3) == 0 && pid == 0) ||
    4274:	03448733          	mul	a4,s1,s4
    4278:	9301                	srli	a4,a4,0x20
    427a:	41f4d79b          	sraiw	a5,s1,0x1f
    427e:	9f1d                	subw	a4,a4,a5
    4280:	0017179b          	slliw	a5,a4,0x1
    4284:	9fb9                	addw	a5,a5,a4
    4286:	40f487bb          	subw	a5,s1,a5
    428a:	873e                	mv	a4,a5
    428c:	8fc9                	or	a5,a5,a0
    428e:	2781                	sext.w	a5,a5
    4290:	dfad                	beqz	a5,420a <concreate+0x1b0>
    4292:	01671363          	bne	a4,s6,4298 <concreate+0x23e>
       ((i % 3) == 1 && pid != 0)){
    4296:	f935                	bnez	a0,420a <concreate+0x1b0>
      unlink(file);
    4298:	854e                	mv	a0,s3
    429a:	2a9000ef          	jal	4d42 <unlink>
      unlink(file);
    429e:	854e                	mv	a0,s3
    42a0:	2a3000ef          	jal	4d42 <unlink>
      unlink(file);
    42a4:	854e                	mv	a0,s3
    42a6:	29d000ef          	jal	4d42 <unlink>
      unlink(file);
    42aa:	854e                	mv	a0,s3
    42ac:	297000ef          	jal	4d42 <unlink>
      unlink(file);
    42b0:	854e                	mv	a0,s3
    42b2:	291000ef          	jal	4d42 <unlink>
      unlink(file);
    42b6:	854e                	mv	a0,s3
    42b8:	28b000ef          	jal	4d42 <unlink>
    42bc:	bf59                	j	4252 <concreate+0x1f8>
      exit(0);
    42be:	4501                	li	a0,0
    42c0:	233000ef          	jal	4cf2 <exit>
      close(fd);
    42c4:	257000ef          	jal	4d1a <close>
    if(pid == 0) {
    42c8:	b599                	j	410e <concreate+0xb4>
      close(fd);
    42ca:	251000ef          	jal	4d1a <close>
      wait(&xstatus);
    42ce:	8556                	mv	a0,s5
    42d0:	22b000ef          	jal	4cfa <wait>
      if(xstatus != 0)
    42d4:	f5c42483          	lw	s1,-164(s0)
    42d8:	e2049ee3          	bnez	s1,4114 <concreate+0xba>
  for(i = 0; i < N; i++){
    42dc:	2905                	addiw	s2,s2,1
    42de:	e3490ee3          	beq	s2,s4,411a <concreate+0xc0>
    file[1] = '0' + i;
    42e2:	0309079b          	addiw	a5,s2,48
    42e6:	f8f40ca3          	sb	a5,-103(s0)
    unlink(file);
    42ea:	854e                	mv	a0,s3
    42ec:	257000ef          	jal	4d42 <unlink>
    pid = fork();
    42f0:	1fb000ef          	jal	4cea <fork>
    if(pid && (i % 3) == 1){
    42f4:	dc0500e3          	beqz	a0,40b4 <concreate+0x5a>
    42f8:	036907b3          	mul	a5,s2,s6
    42fc:	9381                	srli	a5,a5,0x20
    42fe:	41f9571b          	sraiw	a4,s2,0x1f
    4302:	9f99                	subw	a5,a5,a4
    4304:	0017971b          	slliw	a4,a5,0x1
    4308:	9fb9                	addw	a5,a5,a4
    430a:	40f907bb          	subw	a5,s2,a5
    430e:	d9878ee3          	beq	a5,s8,40aa <concreate+0x50>
      fd = open(file, O_CREATE | O_RDWR);
    4312:	85e6                	mv	a1,s9
    4314:	854e                	mv	a0,s3
    4316:	21d000ef          	jal	4d32 <open>
      if(fd < 0){
    431a:	fa0558e3          	bgez	a0,42ca <concreate+0x270>
    431e:	b3e9                	j	40e8 <concreate+0x8e>
}
    4320:	70aa                	ld	ra,168(sp)
    4322:	740a                	ld	s0,160(sp)
    4324:	64ea                	ld	s1,152(sp)
    4326:	694a                	ld	s2,144(sp)
    4328:	69aa                	ld	s3,136(sp)
    432a:	6a0a                	ld	s4,128(sp)
    432c:	7ae6                	ld	s5,120(sp)
    432e:	7b46                	ld	s6,112(sp)
    4330:	7ba6                	ld	s7,104(sp)
    4332:	7c06                	ld	s8,96(sp)
    4334:	6ce6                	ld	s9,88(sp)
    4336:	6d46                	ld	s10,80(sp)
    4338:	614d                	addi	sp,sp,176
    433a:	8082                	ret

000000000000433c <bigfile>:
{
    433c:	7139                	addi	sp,sp,-64
    433e:	fc06                	sd	ra,56(sp)
    4340:	f822                	sd	s0,48(sp)
    4342:	f426                	sd	s1,40(sp)
    4344:	f04a                	sd	s2,32(sp)
    4346:	ec4e                	sd	s3,24(sp)
    4348:	e852                	sd	s4,16(sp)
    434a:	e456                	sd	s5,8(sp)
    434c:	e05a                	sd	s6,0(sp)
    434e:	0080                	addi	s0,sp,64
    4350:	8b2a                	mv	s6,a0
  unlink("bigfile.dat");
    4352:	00003517          	auipc	a0,0x3
    4356:	dce50513          	addi	a0,a0,-562 # 7120 <malloc+0x1f5c>
    435a:	1e9000ef          	jal	4d42 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    435e:	20200593          	li	a1,514
    4362:	00003517          	auipc	a0,0x3
    4366:	dbe50513          	addi	a0,a0,-578 # 7120 <malloc+0x1f5c>
    436a:	1c9000ef          	jal	4d32 <open>
  if(fd < 0){
    436e:	08054a63          	bltz	a0,4402 <bigfile+0xc6>
    4372:	8a2a                	mv	s4,a0
    4374:	4481                	li	s1,0
    memset(buf, i, SZ);
    4376:	25800913          	li	s2,600
    437a:	00009997          	auipc	s3,0x9
    437e:	8fe98993          	addi	s3,s3,-1794 # cc78 <buf>
  for(i = 0; i < N; i++){
    4382:	4ad1                	li	s5,20
    memset(buf, i, SZ);
    4384:	864a                	mv	a2,s2
    4386:	85a6                	mv	a1,s1
    4388:	854e                	mv	a0,s3
    438a:	75a000ef          	jal	4ae4 <memset>
    if(write(fd, buf, SZ) != SZ){
    438e:	864a                	mv	a2,s2
    4390:	85ce                	mv	a1,s3
    4392:	8552                	mv	a0,s4
    4394:	17f000ef          	jal	4d12 <write>
    4398:	07251f63          	bne	a0,s2,4416 <bigfile+0xda>
  for(i = 0; i < N; i++){
    439c:	2485                	addiw	s1,s1,1
    439e:	ff5493e3          	bne	s1,s5,4384 <bigfile+0x48>
  close(fd);
    43a2:	8552                	mv	a0,s4
    43a4:	177000ef          	jal	4d1a <close>
  fd = open("bigfile.dat", 0);
    43a8:	4581                	li	a1,0
    43aa:	00003517          	auipc	a0,0x3
    43ae:	d7650513          	addi	a0,a0,-650 # 7120 <malloc+0x1f5c>
    43b2:	181000ef          	jal	4d32 <open>
    43b6:	8aaa                	mv	s5,a0
  total = 0;
    43b8:	4a01                	li	s4,0
  for(i = 0; ; i++){
    43ba:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    43bc:	12c00993          	li	s3,300
    43c0:	00009917          	auipc	s2,0x9
    43c4:	8b890913          	addi	s2,s2,-1864 # cc78 <buf>
  if(fd < 0){
    43c8:	06054163          	bltz	a0,442a <bigfile+0xee>
    cc = read(fd, buf, SZ/2);
    43cc:	864e                	mv	a2,s3
    43ce:	85ca                	mv	a1,s2
    43d0:	8556                	mv	a0,s5
    43d2:	139000ef          	jal	4d0a <read>
    if(cc < 0){
    43d6:	06054463          	bltz	a0,443e <bigfile+0x102>
    if(cc == 0)
    43da:	c145                	beqz	a0,447a <bigfile+0x13e>
    if(cc != SZ/2){
    43dc:	07351b63          	bne	a0,s3,4452 <bigfile+0x116>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    43e0:	01f4d79b          	srliw	a5,s1,0x1f
    43e4:	9fa5                	addw	a5,a5,s1
    43e6:	4017d79b          	sraiw	a5,a5,0x1
    43ea:	00094703          	lbu	a4,0(s2)
    43ee:	06f71c63          	bne	a4,a5,4466 <bigfile+0x12a>
    43f2:	12b94703          	lbu	a4,299(s2)
    43f6:	06f71863          	bne	a4,a5,4466 <bigfile+0x12a>
    total += cc;
    43fa:	12ca0a1b          	addiw	s4,s4,300
  for(i = 0; ; i++){
    43fe:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4400:	b7f1                	j	43cc <bigfile+0x90>
    printf("%s: cannot create bigfile", s);
    4402:	85da                	mv	a1,s6
    4404:	00003517          	auipc	a0,0x3
    4408:	d2c50513          	addi	a0,a0,-724 # 7130 <malloc+0x1f6c>
    440c:	501000ef          	jal	510c <printf>
    exit(1);
    4410:	4505                	li	a0,1
    4412:	0e1000ef          	jal	4cf2 <exit>
      printf("%s: write bigfile failed\n", s);
    4416:	85da                	mv	a1,s6
    4418:	00003517          	auipc	a0,0x3
    441c:	d3850513          	addi	a0,a0,-712 # 7150 <malloc+0x1f8c>
    4420:	4ed000ef          	jal	510c <printf>
      exit(1);
    4424:	4505                	li	a0,1
    4426:	0cd000ef          	jal	4cf2 <exit>
    printf("%s: cannot open bigfile\n", s);
    442a:	85da                	mv	a1,s6
    442c:	00003517          	auipc	a0,0x3
    4430:	d4450513          	addi	a0,a0,-700 # 7170 <malloc+0x1fac>
    4434:	4d9000ef          	jal	510c <printf>
    exit(1);
    4438:	4505                	li	a0,1
    443a:	0b9000ef          	jal	4cf2 <exit>
      printf("%s: read bigfile failed\n", s);
    443e:	85da                	mv	a1,s6
    4440:	00003517          	auipc	a0,0x3
    4444:	d5050513          	addi	a0,a0,-688 # 7190 <malloc+0x1fcc>
    4448:	4c5000ef          	jal	510c <printf>
      exit(1);
    444c:	4505                	li	a0,1
    444e:	0a5000ef          	jal	4cf2 <exit>
      printf("%s: short read bigfile\n", s);
    4452:	85da                	mv	a1,s6
    4454:	00003517          	auipc	a0,0x3
    4458:	d5c50513          	addi	a0,a0,-676 # 71b0 <malloc+0x1fec>
    445c:	4b1000ef          	jal	510c <printf>
      exit(1);
    4460:	4505                	li	a0,1
    4462:	091000ef          	jal	4cf2 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4466:	85da                	mv	a1,s6
    4468:	00003517          	auipc	a0,0x3
    446c:	d6050513          	addi	a0,a0,-672 # 71c8 <malloc+0x2004>
    4470:	49d000ef          	jal	510c <printf>
      exit(1);
    4474:	4505                	li	a0,1
    4476:	07d000ef          	jal	4cf2 <exit>
  close(fd);
    447a:	8556                	mv	a0,s5
    447c:	09f000ef          	jal	4d1a <close>
  if(total != N*SZ){
    4480:	678d                	lui	a5,0x3
    4482:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x116>
    4486:	02fa1263          	bne	s4,a5,44aa <bigfile+0x16e>
  unlink("bigfile.dat");
    448a:	00003517          	auipc	a0,0x3
    448e:	c9650513          	addi	a0,a0,-874 # 7120 <malloc+0x1f5c>
    4492:	0b1000ef          	jal	4d42 <unlink>
}
    4496:	70e2                	ld	ra,56(sp)
    4498:	7442                	ld	s0,48(sp)
    449a:	74a2                	ld	s1,40(sp)
    449c:	7902                	ld	s2,32(sp)
    449e:	69e2                	ld	s3,24(sp)
    44a0:	6a42                	ld	s4,16(sp)
    44a2:	6aa2                	ld	s5,8(sp)
    44a4:	6b02                	ld	s6,0(sp)
    44a6:	6121                	addi	sp,sp,64
    44a8:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    44aa:	85da                	mv	a1,s6
    44ac:	00003517          	auipc	a0,0x3
    44b0:	d3c50513          	addi	a0,a0,-708 # 71e8 <malloc+0x2024>
    44b4:	459000ef          	jal	510c <printf>
    exit(1);
    44b8:	4505                	li	a0,1
    44ba:	039000ef          	jal	4cf2 <exit>

00000000000044be <fsfull>:
{
    44be:	7171                	addi	sp,sp,-176
    44c0:	f506                	sd	ra,168(sp)
    44c2:	f122                	sd	s0,160(sp)
    44c4:	ed26                	sd	s1,152(sp)
    44c6:	e94a                	sd	s2,144(sp)
    44c8:	e54e                	sd	s3,136(sp)
    44ca:	e152                	sd	s4,128(sp)
    44cc:	fcd6                	sd	s5,120(sp)
    44ce:	f8da                	sd	s6,112(sp)
    44d0:	f4de                	sd	s7,104(sp)
    44d2:	f0e2                	sd	s8,96(sp)
    44d4:	ece6                	sd	s9,88(sp)
    44d6:	e8ea                	sd	s10,80(sp)
    44d8:	e4ee                	sd	s11,72(sp)
    44da:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    44dc:	00003517          	auipc	a0,0x3
    44e0:	d2c50513          	addi	a0,a0,-724 # 7208 <malloc+0x2044>
    44e4:	429000ef          	jal	510c <printf>
  for(nfiles = 0; ; nfiles++){
    44e8:	4481                	li	s1,0
    name[0] = 'f';
    44ea:	06600d93          	li	s11,102
    name[1] = '0' + nfiles / 1000;
    44ee:	10625cb7          	lui	s9,0x10625
    44f2:	dd3c8c93          	addi	s9,s9,-557 # 10624dd3 <base+0x1061515b>
    name[2] = '0' + (nfiles % 1000) / 100;
    44f6:	51eb8ab7          	lui	s5,0x51eb8
    44fa:	51fa8a93          	addi	s5,s5,1311 # 51eb851f <base+0x51ea88a7>
    name[3] = '0' + (nfiles % 100) / 10;
    44fe:	66666a37          	lui	s4,0x66666
    4502:	667a0a13          	addi	s4,s4,1639 # 66666667 <base+0x666569ef>
    printf("writing %s\n", name);
    4506:	f5040d13          	addi	s10,s0,-176
    name[0] = 'f';
    450a:	f5b40823          	sb	s11,-176(s0)
    name[1] = '0' + nfiles / 1000;
    450e:	039487b3          	mul	a5,s1,s9
    4512:	9799                	srai	a5,a5,0x26
    4514:	41f4d69b          	sraiw	a3,s1,0x1f
    4518:	9f95                	subw	a5,a5,a3
    451a:	0307871b          	addiw	a4,a5,48
    451e:	f4e408a3          	sb	a4,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4522:	3e800713          	li	a4,1000
    4526:	02f707bb          	mulw	a5,a4,a5
    452a:	40f487bb          	subw	a5,s1,a5
    452e:	03578733          	mul	a4,a5,s5
    4532:	9715                	srai	a4,a4,0x25
    4534:	41f7d79b          	sraiw	a5,a5,0x1f
    4538:	40f707bb          	subw	a5,a4,a5
    453c:	0307879b          	addiw	a5,a5,48
    4540:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4544:	035487b3          	mul	a5,s1,s5
    4548:	9795                	srai	a5,a5,0x25
    454a:	9f95                	subw	a5,a5,a3
    454c:	06400713          	li	a4,100
    4550:	02f707bb          	mulw	a5,a4,a5
    4554:	40f487bb          	subw	a5,s1,a5
    4558:	03478733          	mul	a4,a5,s4
    455c:	9709                	srai	a4,a4,0x22
    455e:	41f7d79b          	sraiw	a5,a5,0x1f
    4562:	40f707bb          	subw	a5,a4,a5
    4566:	0307879b          	addiw	a5,a5,48
    456a:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    456e:	03448733          	mul	a4,s1,s4
    4572:	9709                	srai	a4,a4,0x22
    4574:	9f15                	subw	a4,a4,a3
    4576:	0027179b          	slliw	a5,a4,0x2
    457a:	9fb9                	addw	a5,a5,a4
    457c:	0017979b          	slliw	a5,a5,0x1
    4580:	40f487bb          	subw	a5,s1,a5
    4584:	0307879b          	addiw	a5,a5,48
    4588:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    458c:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4590:	85ea                	mv	a1,s10
    4592:	00003517          	auipc	a0,0x3
    4596:	c8650513          	addi	a0,a0,-890 # 7218 <malloc+0x2054>
    459a:	373000ef          	jal	510c <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    459e:	20200593          	li	a1,514
    45a2:	856a                	mv	a0,s10
    45a4:	78e000ef          	jal	4d32 <open>
    45a8:	892a                	mv	s2,a0
    if(fd < 0){
    45aa:	0e055863          	bgez	a0,469a <fsfull+0x1dc>
      printf("open %s failed\n", name);
    45ae:	f5040593          	addi	a1,s0,-176
    45b2:	00003517          	auipc	a0,0x3
    45b6:	c7650513          	addi	a0,a0,-906 # 7228 <malloc+0x2064>
    45ba:	353000ef          	jal	510c <printf>
    name[0] = 'f';
    45be:	06600c13          	li	s8,102
    name[1] = '0' + nfiles / 1000;
    45c2:	10625a37          	lui	s4,0x10625
    45c6:	dd3a0a13          	addi	s4,s4,-557 # 10624dd3 <base+0x1061515b>
    name[2] = '0' + (nfiles % 1000) / 100;
    45ca:	3e800b93          	li	s7,1000
    45ce:	51eb89b7          	lui	s3,0x51eb8
    45d2:	51f98993          	addi	s3,s3,1311 # 51eb851f <base+0x51ea88a7>
    name[3] = '0' + (nfiles % 100) / 10;
    45d6:	06400b13          	li	s6,100
    45da:	66666937          	lui	s2,0x66666
    45de:	66790913          	addi	s2,s2,1639 # 66666667 <base+0x666569ef>
    unlink(name);
    45e2:	f5040a93          	addi	s5,s0,-176
    name[0] = 'f';
    45e6:	f5840823          	sb	s8,-176(s0)
    name[1] = '0' + nfiles / 1000;
    45ea:	034487b3          	mul	a5,s1,s4
    45ee:	9799                	srai	a5,a5,0x26
    45f0:	41f4d69b          	sraiw	a3,s1,0x1f
    45f4:	9f95                	subw	a5,a5,a3
    45f6:	0307871b          	addiw	a4,a5,48
    45fa:	f4e408a3          	sb	a4,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    45fe:	02fb87bb          	mulw	a5,s7,a5
    4602:	40f487bb          	subw	a5,s1,a5
    4606:	03378733          	mul	a4,a5,s3
    460a:	9715                	srai	a4,a4,0x25
    460c:	41f7d79b          	sraiw	a5,a5,0x1f
    4610:	40f707bb          	subw	a5,a4,a5
    4614:	0307879b          	addiw	a5,a5,48
    4618:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    461c:	033487b3          	mul	a5,s1,s3
    4620:	9795                	srai	a5,a5,0x25
    4622:	9f95                	subw	a5,a5,a3
    4624:	02fb07bb          	mulw	a5,s6,a5
    4628:	40f487bb          	subw	a5,s1,a5
    462c:	03278733          	mul	a4,a5,s2
    4630:	9709                	srai	a4,a4,0x22
    4632:	41f7d79b          	sraiw	a5,a5,0x1f
    4636:	40f707bb          	subw	a5,a4,a5
    463a:	0307879b          	addiw	a5,a5,48
    463e:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4642:	03248733          	mul	a4,s1,s2
    4646:	9709                	srai	a4,a4,0x22
    4648:	9f15                	subw	a4,a4,a3
    464a:	0027179b          	slliw	a5,a4,0x2
    464e:	9fb9                	addw	a5,a5,a4
    4650:	0017979b          	slliw	a5,a5,0x1
    4654:	40f487bb          	subw	a5,s1,a5
    4658:	0307879b          	addiw	a5,a5,48
    465c:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4660:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4664:	8556                	mv	a0,s5
    4666:	6dc000ef          	jal	4d42 <unlink>
    nfiles--;
    466a:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    466c:	f604dde3          	bgez	s1,45e6 <fsfull+0x128>
  printf("fsfull test finished\n");
    4670:	00003517          	auipc	a0,0x3
    4674:	bd850513          	addi	a0,a0,-1064 # 7248 <malloc+0x2084>
    4678:	295000ef          	jal	510c <printf>
}
    467c:	70aa                	ld	ra,168(sp)
    467e:	740a                	ld	s0,160(sp)
    4680:	64ea                	ld	s1,152(sp)
    4682:	694a                	ld	s2,144(sp)
    4684:	69aa                	ld	s3,136(sp)
    4686:	6a0a                	ld	s4,128(sp)
    4688:	7ae6                	ld	s5,120(sp)
    468a:	7b46                	ld	s6,112(sp)
    468c:	7ba6                	ld	s7,104(sp)
    468e:	7c06                	ld	s8,96(sp)
    4690:	6ce6                	ld	s9,88(sp)
    4692:	6d46                	ld	s10,80(sp)
    4694:	6da6                	ld	s11,72(sp)
    4696:	614d                	addi	sp,sp,176
    4698:	8082                	ret
    int total = 0;
    469a:	4981                	li	s3,0
      int cc = write(fd, buf, BSIZE);
    469c:	40000c13          	li	s8,1024
    46a0:	00008b97          	auipc	s7,0x8
    46a4:	5d8b8b93          	addi	s7,s7,1496 # cc78 <buf>
      if(cc < BSIZE)
    46a8:	3ff00b13          	li	s6,1023
      int cc = write(fd, buf, BSIZE);
    46ac:	8662                	mv	a2,s8
    46ae:	85de                	mv	a1,s7
    46b0:	854a                	mv	a0,s2
    46b2:	660000ef          	jal	4d12 <write>
      if(cc < BSIZE)
    46b6:	00ab5563          	bge	s6,a0,46c0 <fsfull+0x202>
      total += cc;
    46ba:	00a989bb          	addw	s3,s3,a0
    while(1){
    46be:	b7fd                	j	46ac <fsfull+0x1ee>
    printf("wrote %d bytes\n", total);
    46c0:	85ce                	mv	a1,s3
    46c2:	00003517          	auipc	a0,0x3
    46c6:	b7650513          	addi	a0,a0,-1162 # 7238 <malloc+0x2074>
    46ca:	243000ef          	jal	510c <printf>
    close(fd);
    46ce:	854a                	mv	a0,s2
    46d0:	64a000ef          	jal	4d1a <close>
    if(total == 0)
    46d4:	ee0985e3          	beqz	s3,45be <fsfull+0x100>
  for(nfiles = 0; ; nfiles++){
    46d8:	2485                	addiw	s1,s1,1
    46da:	bd05                	j	450a <fsfull+0x4c>

00000000000046dc <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    46dc:	7179                	addi	sp,sp,-48
    46de:	f406                	sd	ra,40(sp)
    46e0:	f022                	sd	s0,32(sp)
    46e2:	ec26                	sd	s1,24(sp)
    46e4:	e84a                	sd	s2,16(sp)
    46e6:	1800                	addi	s0,sp,48
    46e8:	84aa                	mv	s1,a0
    46ea:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    46ec:	00003517          	auipc	a0,0x3
    46f0:	b7450513          	addi	a0,a0,-1164 # 7260 <malloc+0x209c>
    46f4:	219000ef          	jal	510c <printf>
  if((pid = fork()) < 0) {
    46f8:	5f2000ef          	jal	4cea <fork>
    46fc:	02054a63          	bltz	a0,4730 <run+0x54>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4700:	c129                	beqz	a0,4742 <run+0x66>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4702:	fdc40513          	addi	a0,s0,-36
    4706:	5f4000ef          	jal	4cfa <wait>
    if(xstatus != 0) 
    470a:	fdc42783          	lw	a5,-36(s0)
    470e:	cf9d                	beqz	a5,474c <run+0x70>
      printf("FAILED\n");
    4710:	00003517          	auipc	a0,0x3
    4714:	b7850513          	addi	a0,a0,-1160 # 7288 <malloc+0x20c4>
    4718:	1f5000ef          	jal	510c <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    471c:	fdc42503          	lw	a0,-36(s0)
  }
}
    4720:	00153513          	seqz	a0,a0
    4724:	70a2                	ld	ra,40(sp)
    4726:	7402                	ld	s0,32(sp)
    4728:	64e2                	ld	s1,24(sp)
    472a:	6942                	ld	s2,16(sp)
    472c:	6145                	addi	sp,sp,48
    472e:	8082                	ret
    printf("runtest: fork error\n");
    4730:	00003517          	auipc	a0,0x3
    4734:	b4050513          	addi	a0,a0,-1216 # 7270 <malloc+0x20ac>
    4738:	1d5000ef          	jal	510c <printf>
    exit(1);
    473c:	4505                	li	a0,1
    473e:	5b4000ef          	jal	4cf2 <exit>
    f(s);
    4742:	854a                	mv	a0,s2
    4744:	9482                	jalr	s1
    exit(0);
    4746:	4501                	li	a0,0
    4748:	5aa000ef          	jal	4cf2 <exit>
      printf("OK\n");
    474c:	00003517          	auipc	a0,0x3
    4750:	b4450513          	addi	a0,a0,-1212 # 7290 <malloc+0x20cc>
    4754:	1b9000ef          	jal	510c <printf>
    4758:	b7d1                	j	471c <run+0x40>

000000000000475a <runtests>:

int
runtests(struct test *tests, char *justone, int continuous) {
    475a:	7139                	addi	sp,sp,-64
    475c:	fc06                	sd	ra,56(sp)
    475e:	f822                	sd	s0,48(sp)
    4760:	f04a                	sd	s2,32(sp)
    4762:	0080                	addi	s0,sp,64
  for (struct test *t = tests; t->s != 0; t++) {
    4764:	00853903          	ld	s2,8(a0)
    4768:	06090463          	beqz	s2,47d0 <runtests+0x76>
    476c:	f426                	sd	s1,40(sp)
    476e:	ec4e                	sd	s3,24(sp)
    4770:	e852                	sd	s4,16(sp)
    4772:	e456                	sd	s5,8(sp)
    4774:	84aa                	mv	s1,a0
    4776:	89ae                	mv	s3,a1
    4778:	8a32                	mv	s4,a2
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s)){
        if(continuous != 2){
    477a:	4a89                	li	s5,2
    477c:	a031                	j	4788 <runtests+0x2e>
  for (struct test *t = tests; t->s != 0; t++) {
    477e:	04c1                	addi	s1,s1,16
    4780:	0084b903          	ld	s2,8(s1)
    4784:	02090c63          	beqz	s2,47bc <runtests+0x62>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    4788:	00098763          	beqz	s3,4796 <runtests+0x3c>
    478c:	85ce                	mv	a1,s3
    478e:	854a                	mv	a0,s2
    4790:	2f6000ef          	jal	4a86 <strcmp>
    4794:	f56d                	bnez	a0,477e <runtests+0x24>
      if(!run(t->f, t->s)){
    4796:	85ca                	mv	a1,s2
    4798:	6088                	ld	a0,0(s1)
    479a:	f43ff0ef          	jal	46dc <run>
    479e:	f165                	bnez	a0,477e <runtests+0x24>
        if(continuous != 2){
    47a0:	fd5a0fe3          	beq	s4,s5,477e <runtests+0x24>
          printf("SOME TESTS FAILED\n");
    47a4:	00003517          	auipc	a0,0x3
    47a8:	af450513          	addi	a0,a0,-1292 # 7298 <malloc+0x20d4>
    47ac:	161000ef          	jal	510c <printf>
          return 1;
    47b0:	4505                	li	a0,1
    47b2:	74a2                	ld	s1,40(sp)
    47b4:	69e2                	ld	s3,24(sp)
    47b6:	6a42                	ld	s4,16(sp)
    47b8:	6aa2                	ld	s5,8(sp)
    47ba:	a031                	j	47c6 <runtests+0x6c>
        }
      }
    }
  }
  return 0;
    47bc:	4501                	li	a0,0
    47be:	74a2                	ld	s1,40(sp)
    47c0:	69e2                	ld	s3,24(sp)
    47c2:	6a42                	ld	s4,16(sp)
    47c4:	6aa2                	ld	s5,8(sp)
}
    47c6:	70e2                	ld	ra,56(sp)
    47c8:	7442                	ld	s0,48(sp)
    47ca:	7902                	ld	s2,32(sp)
    47cc:	6121                	addi	sp,sp,64
    47ce:	8082                	ret
  return 0;
    47d0:	4501                	li	a0,0
    47d2:	bfd5                	j	47c6 <runtests+0x6c>

00000000000047d4 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    47d4:	7139                	addi	sp,sp,-64
    47d6:	fc06                	sd	ra,56(sp)
    47d8:	f822                	sd	s0,48(sp)
    47da:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    47dc:	fc840513          	addi	a0,s0,-56
    47e0:	522000ef          	jal	4d02 <pipe>
    47e4:	04054f63          	bltz	a0,4842 <countfree+0x6e>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    47e8:	502000ef          	jal	4cea <fork>

  if(pid < 0){
    47ec:	06054863          	bltz	a0,485c <countfree+0x88>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    47f0:	e551                	bnez	a0,487c <countfree+0xa8>
    47f2:	f426                	sd	s1,40(sp)
    47f4:	f04a                	sd	s2,32(sp)
    47f6:	ec4e                	sd	s3,24(sp)
    47f8:	e852                	sd	s4,16(sp)
    close(fds[0]);
    47fa:	fc842503          	lw	a0,-56(s0)
    47fe:	51c000ef          	jal	4d1a <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
    4802:	6905                	lui	s2,0x1
      if(a == 0xffffffffffffffff){
    4804:	59fd                	li	s3,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4806:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4808:	00001a17          	auipc	s4,0x1
    480c:	b60a0a13          	addi	s4,s4,-1184 # 5368 <malloc+0x1a4>
      uint64 a = (uint64) sbrk(4096);
    4810:	854a                	mv	a0,s2
    4812:	568000ef          	jal	4d7a <sbrk>
      if(a == 0xffffffffffffffff){
    4816:	07350063          	beq	a0,s3,4876 <countfree+0xa2>
      *(char *)(a + 4096 - 1) = 1;
    481a:	954a                	add	a0,a0,s2
    481c:	fe950fa3          	sb	s1,-1(a0)
      if(write(fds[1], "x", 1) != 1){
    4820:	8626                	mv	a2,s1
    4822:	85d2                	mv	a1,s4
    4824:	fcc42503          	lw	a0,-52(s0)
    4828:	4ea000ef          	jal	4d12 <write>
    482c:	fe9502e3          	beq	a0,s1,4810 <countfree+0x3c>
        printf("write() failed in countfree()\n");
    4830:	00003517          	auipc	a0,0x3
    4834:	ac050513          	addi	a0,a0,-1344 # 72f0 <malloc+0x212c>
    4838:	0d5000ef          	jal	510c <printf>
        exit(1);
    483c:	4505                	li	a0,1
    483e:	4b4000ef          	jal	4cf2 <exit>
    4842:	f426                	sd	s1,40(sp)
    4844:	f04a                	sd	s2,32(sp)
    4846:	ec4e                	sd	s3,24(sp)
    4848:	e852                	sd	s4,16(sp)
    printf("pipe() failed in countfree()\n");
    484a:	00003517          	auipc	a0,0x3
    484e:	a6650513          	addi	a0,a0,-1434 # 72b0 <malloc+0x20ec>
    4852:	0bb000ef          	jal	510c <printf>
    exit(1);
    4856:	4505                	li	a0,1
    4858:	49a000ef          	jal	4cf2 <exit>
    485c:	f426                	sd	s1,40(sp)
    485e:	f04a                	sd	s2,32(sp)
    4860:	ec4e                	sd	s3,24(sp)
    4862:	e852                	sd	s4,16(sp)
    printf("fork failed in countfree()\n");
    4864:	00003517          	auipc	a0,0x3
    4868:	a6c50513          	addi	a0,a0,-1428 # 72d0 <malloc+0x210c>
    486c:	0a1000ef          	jal	510c <printf>
    exit(1);
    4870:	4505                	li	a0,1
    4872:	480000ef          	jal	4cf2 <exit>
      }
    }

    exit(0);
    4876:	4501                	li	a0,0
    4878:	47a000ef          	jal	4cf2 <exit>
    487c:	f426                	sd	s1,40(sp)
    487e:	f04a                	sd	s2,32(sp)
    4880:	ec4e                	sd	s3,24(sp)
  }

  close(fds[1]);
    4882:	fcc42503          	lw	a0,-52(s0)
    4886:	494000ef          	jal	4d1a <close>

  int n = 0;
    488a:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    488c:	fc740993          	addi	s3,s0,-57
    4890:	4905                	li	s2,1
    4892:	864a                	mv	a2,s2
    4894:	85ce                	mv	a1,s3
    4896:	fc842503          	lw	a0,-56(s0)
    489a:	470000ef          	jal	4d0a <read>
    if(cc < 0){
    489e:	00054563          	bltz	a0,48a8 <countfree+0xd4>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    48a2:	cd09                	beqz	a0,48bc <countfree+0xe8>
      break;
    n += 1;
    48a4:	2485                	addiw	s1,s1,1
  while(1){
    48a6:	b7f5                	j	4892 <countfree+0xbe>
    48a8:	e852                	sd	s4,16(sp)
      printf("read() failed in countfree()\n");
    48aa:	00003517          	auipc	a0,0x3
    48ae:	a6650513          	addi	a0,a0,-1434 # 7310 <malloc+0x214c>
    48b2:	05b000ef          	jal	510c <printf>
      exit(1);
    48b6:	4505                	li	a0,1
    48b8:	43a000ef          	jal	4cf2 <exit>
  }

  close(fds[0]);
    48bc:	fc842503          	lw	a0,-56(s0)
    48c0:	45a000ef          	jal	4d1a <close>
  wait((int*)0);
    48c4:	4501                	li	a0,0
    48c6:	434000ef          	jal	4cfa <wait>
  
  return n;
}
    48ca:	8526                	mv	a0,s1
    48cc:	74a2                	ld	s1,40(sp)
    48ce:	7902                	ld	s2,32(sp)
    48d0:	69e2                	ld	s3,24(sp)
    48d2:	70e2                	ld	ra,56(sp)
    48d4:	7442                	ld	s0,48(sp)
    48d6:	6121                	addi	sp,sp,64
    48d8:	8082                	ret

00000000000048da <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    48da:	711d                	addi	sp,sp,-96
    48dc:	ec86                	sd	ra,88(sp)
    48de:	e8a2                	sd	s0,80(sp)
    48e0:	e4a6                	sd	s1,72(sp)
    48e2:	e0ca                	sd	s2,64(sp)
    48e4:	fc4e                	sd	s3,56(sp)
    48e6:	f852                	sd	s4,48(sp)
    48e8:	f456                	sd	s5,40(sp)
    48ea:	f05a                	sd	s6,32(sp)
    48ec:	ec5e                	sd	s7,24(sp)
    48ee:	e862                	sd	s8,16(sp)
    48f0:	e466                	sd	s9,8(sp)
    48f2:	e06a                	sd	s10,0(sp)
    48f4:	1080                	addi	s0,sp,96
    48f6:	8aaa                	mv	s5,a0
    48f8:	892e                	mv	s2,a1
    48fa:	89b2                	mv	s3,a2
  do {
    printf("usertests starting\n");
    48fc:	00003b97          	auipc	s7,0x3
    4900:	a34b8b93          	addi	s7,s7,-1484 # 7330 <malloc+0x216c>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone, continuous)) {
    4904:	00004b17          	auipc	s6,0x4
    4908:	70cb0b13          	addi	s6,s6,1804 # 9010 <quicktests>
      if(continuous != 2) {
    490c:	4a09                	li	s4,2
      }
    }
    if(!quick) {
      if (justone == 0)
        printf("usertests slow tests starting\n");
      if (runtests(slowtests, justone, continuous)) {
    490e:	00005c17          	auipc	s8,0x5
    4912:	ad2c0c13          	addi	s8,s8,-1326 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    4916:	00003d17          	auipc	s10,0x3
    491a:	a32d0d13          	addi	s10,s10,-1486 # 7348 <malloc+0x2184>
          return 1;
        }
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    491e:	00003c97          	auipc	s9,0x3
    4922:	a4ac8c93          	addi	s9,s9,-1462 # 7368 <malloc+0x21a4>
    4926:	a819                	j	493c <drivetests+0x62>
        printf("usertests slow tests starting\n");
    4928:	856a                	mv	a0,s10
    492a:	7e2000ef          	jal	510c <printf>
    492e:	a80d                	j	4960 <drivetests+0x86>
    if((free1 = countfree()) < free0) {
    4930:	ea5ff0ef          	jal	47d4 <countfree>
    4934:	04954063          	blt	a0,s1,4974 <drivetests+0x9a>
      if(continuous != 2) {
        return 1;
      }
    }
  } while(continuous);
    4938:	04090963          	beqz	s2,498a <drivetests+0xb0>
    printf("usertests starting\n");
    493c:	855e                	mv	a0,s7
    493e:	7ce000ef          	jal	510c <printf>
    int free0 = countfree();
    4942:	e93ff0ef          	jal	47d4 <countfree>
    4946:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone, continuous)) {
    4948:	864a                	mv	a2,s2
    494a:	85ce                	mv	a1,s3
    494c:	855a                	mv	a0,s6
    494e:	e0dff0ef          	jal	475a <runtests>
    4952:	c119                	beqz	a0,4958 <drivetests+0x7e>
      if(continuous != 2) {
    4954:	03491963          	bne	s2,s4,4986 <drivetests+0xac>
    if(!quick) {
    4958:	fc0a9ce3          	bnez	s5,4930 <drivetests+0x56>
      if (justone == 0)
    495c:	fc0986e3          	beqz	s3,4928 <drivetests+0x4e>
      if (runtests(slowtests, justone, continuous)) {
    4960:	864a                	mv	a2,s2
    4962:	85ce                	mv	a1,s3
    4964:	8562                	mv	a0,s8
    4966:	df5ff0ef          	jal	475a <runtests>
    496a:	d179                	beqz	a0,4930 <drivetests+0x56>
        if(continuous != 2) {
    496c:	fd4902e3          	beq	s2,s4,4930 <drivetests+0x56>
          return 1;
    4970:	4505                	li	a0,1
    4972:	a829                	j	498c <drivetests+0xb2>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    4974:	8626                	mv	a2,s1
    4976:	85aa                	mv	a1,a0
    4978:	8566                	mv	a0,s9
    497a:	792000ef          	jal	510c <printf>
      if(continuous != 2) {
    497e:	fb490fe3          	beq	s2,s4,493c <drivetests+0x62>
        return 1;
    4982:	4505                	li	a0,1
    4984:	a021                	j	498c <drivetests+0xb2>
        return 1;
    4986:	4505                	li	a0,1
    4988:	a011                	j	498c <drivetests+0xb2>
  return 0;
    498a:	854a                	mv	a0,s2
}
    498c:	60e6                	ld	ra,88(sp)
    498e:	6446                	ld	s0,80(sp)
    4990:	64a6                	ld	s1,72(sp)
    4992:	6906                	ld	s2,64(sp)
    4994:	79e2                	ld	s3,56(sp)
    4996:	7a42                	ld	s4,48(sp)
    4998:	7aa2                	ld	s5,40(sp)
    499a:	7b02                	ld	s6,32(sp)
    499c:	6be2                	ld	s7,24(sp)
    499e:	6c42                	ld	s8,16(sp)
    49a0:	6ca2                	ld	s9,8(sp)
    49a2:	6d02                	ld	s10,0(sp)
    49a4:	6125                	addi	sp,sp,96
    49a6:	8082                	ret

00000000000049a8 <main>:

int
main(int argc, char *argv[])
{
    49a8:	1101                	addi	sp,sp,-32
    49aa:	ec06                	sd	ra,24(sp)
    49ac:	e822                	sd	s0,16(sp)
    49ae:	e426                	sd	s1,8(sp)
    49b0:	e04a                	sd	s2,0(sp)
    49b2:	1000                	addi	s0,sp,32
    49b4:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    49b6:	4789                	li	a5,2
    49b8:	00f50f63          	beq	a0,a5,49d6 <main+0x2e>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    49bc:	4785                	li	a5,1
    49be:	06a7c063          	blt	a5,a0,4a1e <main+0x76>
  char *justone = 0;
    49c2:	4901                	li	s2,0
  int quick = 0;
    49c4:	4501                	li	a0,0
  int continuous = 0;
    49c6:	4581                	li	a1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    49c8:	864a                	mv	a2,s2
    49ca:	f11ff0ef          	jal	48da <drivetests>
    49ce:	c935                	beqz	a0,4a42 <main+0x9a>
    exit(1);
    49d0:	4505                	li	a0,1
    49d2:	320000ef          	jal	4cf2 <exit>
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    49d6:	0085b903          	ld	s2,8(a1)
    49da:	00003597          	auipc	a1,0x3
    49de:	9be58593          	addi	a1,a1,-1602 # 7398 <malloc+0x21d4>
    49e2:	854a                	mv	a0,s2
    49e4:	0a2000ef          	jal	4a86 <strcmp>
    49e8:	85aa                	mv	a1,a0
    49ea:	c139                	beqz	a0,4a30 <main+0x88>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    49ec:	00003597          	auipc	a1,0x3
    49f0:	9b458593          	addi	a1,a1,-1612 # 73a0 <malloc+0x21dc>
    49f4:	854a                	mv	a0,s2
    49f6:	090000ef          	jal	4a86 <strcmp>
    49fa:	cd15                	beqz	a0,4a36 <main+0x8e>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    49fc:	00003597          	auipc	a1,0x3
    4a00:	9ac58593          	addi	a1,a1,-1620 # 73a8 <malloc+0x21e4>
    4a04:	854a                	mv	a0,s2
    4a06:	080000ef          	jal	4a86 <strcmp>
    4a0a:	c90d                	beqz	a0,4a3c <main+0x94>
  } else if(argc == 2 && argv[1][0] != '-'){
    4a0c:	00094703          	lbu	a4,0(s2) # 1000 <bigdir+0x10a>
    4a10:	02d00793          	li	a5,45
    4a14:	00f70563          	beq	a4,a5,4a1e <main+0x76>
  int quick = 0;
    4a18:	4501                	li	a0,0
  int continuous = 0;
    4a1a:	4581                	li	a1,0
    4a1c:	b775                	j	49c8 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    4a1e:	00003517          	auipc	a0,0x3
    4a22:	99250513          	addi	a0,a0,-1646 # 73b0 <malloc+0x21ec>
    4a26:	6e6000ef          	jal	510c <printf>
    exit(1);
    4a2a:	4505                	li	a0,1
    4a2c:	2c6000ef          	jal	4cf2 <exit>
  char *justone = 0;
    4a30:	4901                	li	s2,0
    quick = 1;
    4a32:	4505                	li	a0,1
    4a34:	bf51                	j	49c8 <main+0x20>
  char *justone = 0;
    4a36:	4901                	li	s2,0
    continuous = 1;
    4a38:	4585                	li	a1,1
    4a3a:	b779                	j	49c8 <main+0x20>
    continuous = 2;
    4a3c:	85a6                	mv	a1,s1
  char *justone = 0;
    4a3e:	4901                	li	s2,0
    4a40:	b761                	j	49c8 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    4a42:	00003517          	auipc	a0,0x3
    4a46:	99e50513          	addi	a0,a0,-1634 # 73e0 <malloc+0x221c>
    4a4a:	6c2000ef          	jal	510c <printf>
  exit(0);
    4a4e:	4501                	li	a0,0
    4a50:	2a2000ef          	jal	4cf2 <exit>

0000000000004a54 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
    4a54:	1141                	addi	sp,sp,-16
    4a56:	e406                	sd	ra,8(sp)
    4a58:	e022                	sd	s0,0(sp)
    4a5a:	0800                	addi	s0,sp,16
  extern int main();
  main();
    4a5c:	f4dff0ef          	jal	49a8 <main>
  exit(0);
    4a60:	4501                	li	a0,0
    4a62:	290000ef          	jal	4cf2 <exit>

0000000000004a66 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    4a66:	1141                	addi	sp,sp,-16
    4a68:	e406                	sd	ra,8(sp)
    4a6a:	e022                	sd	s0,0(sp)
    4a6c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    4a6e:	87aa                	mv	a5,a0
    4a70:	0585                	addi	a1,a1,1
    4a72:	0785                	addi	a5,a5,1
    4a74:	fff5c703          	lbu	a4,-1(a1)
    4a78:	fee78fa3          	sb	a4,-1(a5)
    4a7c:	fb75                	bnez	a4,4a70 <strcpy+0xa>
    ;
  return os;
}
    4a7e:	60a2                	ld	ra,8(sp)
    4a80:	6402                	ld	s0,0(sp)
    4a82:	0141                	addi	sp,sp,16
    4a84:	8082                	ret

0000000000004a86 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    4a86:	1141                	addi	sp,sp,-16
    4a88:	e406                	sd	ra,8(sp)
    4a8a:	e022                	sd	s0,0(sp)
    4a8c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    4a8e:	00054783          	lbu	a5,0(a0)
    4a92:	cb91                	beqz	a5,4aa6 <strcmp+0x20>
    4a94:	0005c703          	lbu	a4,0(a1)
    4a98:	00f71763          	bne	a4,a5,4aa6 <strcmp+0x20>
    p++, q++;
    4a9c:	0505                	addi	a0,a0,1
    4a9e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    4aa0:	00054783          	lbu	a5,0(a0)
    4aa4:	fbe5                	bnez	a5,4a94 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
    4aa6:	0005c503          	lbu	a0,0(a1)
}
    4aaa:	40a7853b          	subw	a0,a5,a0
    4aae:	60a2                	ld	ra,8(sp)
    4ab0:	6402                	ld	s0,0(sp)
    4ab2:	0141                	addi	sp,sp,16
    4ab4:	8082                	ret

0000000000004ab6 <strlen>:

uint
strlen(const char *s)
{
    4ab6:	1141                	addi	sp,sp,-16
    4ab8:	e406                	sd	ra,8(sp)
    4aba:	e022                	sd	s0,0(sp)
    4abc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    4abe:	00054783          	lbu	a5,0(a0)
    4ac2:	cf99                	beqz	a5,4ae0 <strlen+0x2a>
    4ac4:	0505                	addi	a0,a0,1
    4ac6:	87aa                	mv	a5,a0
    4ac8:	86be                	mv	a3,a5
    4aca:	0785                	addi	a5,a5,1
    4acc:	fff7c703          	lbu	a4,-1(a5)
    4ad0:	ff65                	bnez	a4,4ac8 <strlen+0x12>
    4ad2:	40a6853b          	subw	a0,a3,a0
    4ad6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    4ad8:	60a2                	ld	ra,8(sp)
    4ada:	6402                	ld	s0,0(sp)
    4adc:	0141                	addi	sp,sp,16
    4ade:	8082                	ret
  for(n = 0; s[n]; n++)
    4ae0:	4501                	li	a0,0
    4ae2:	bfdd                	j	4ad8 <strlen+0x22>

0000000000004ae4 <memset>:

void*
memset(void *dst, int c, uint n)
{
    4ae4:	1141                	addi	sp,sp,-16
    4ae6:	e406                	sd	ra,8(sp)
    4ae8:	e022                	sd	s0,0(sp)
    4aea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    4aec:	ca19                	beqz	a2,4b02 <memset+0x1e>
    4aee:	87aa                	mv	a5,a0
    4af0:	1602                	slli	a2,a2,0x20
    4af2:	9201                	srli	a2,a2,0x20
    4af4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    4af8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    4afc:	0785                	addi	a5,a5,1
    4afe:	fee79de3          	bne	a5,a4,4af8 <memset+0x14>
  }
  return dst;
}
    4b02:	60a2                	ld	ra,8(sp)
    4b04:	6402                	ld	s0,0(sp)
    4b06:	0141                	addi	sp,sp,16
    4b08:	8082                	ret

0000000000004b0a <strchr>:

char*
strchr(const char *s, char c)
{
    4b0a:	1141                	addi	sp,sp,-16
    4b0c:	e406                	sd	ra,8(sp)
    4b0e:	e022                	sd	s0,0(sp)
    4b10:	0800                	addi	s0,sp,16
  for(; *s; s++)
    4b12:	00054783          	lbu	a5,0(a0)
    4b16:	cf81                	beqz	a5,4b2e <strchr+0x24>
    if(*s == c)
    4b18:	00f58763          	beq	a1,a5,4b26 <strchr+0x1c>
  for(; *s; s++)
    4b1c:	0505                	addi	a0,a0,1
    4b1e:	00054783          	lbu	a5,0(a0)
    4b22:	fbfd                	bnez	a5,4b18 <strchr+0xe>
      return (char*)s;
  return 0;
    4b24:	4501                	li	a0,0
}
    4b26:	60a2                	ld	ra,8(sp)
    4b28:	6402                	ld	s0,0(sp)
    4b2a:	0141                	addi	sp,sp,16
    4b2c:	8082                	ret
  return 0;
    4b2e:	4501                	li	a0,0
    4b30:	bfdd                	j	4b26 <strchr+0x1c>

0000000000004b32 <gets>:

char*
gets(char *buf, int max)
{
    4b32:	7159                	addi	sp,sp,-112
    4b34:	f486                	sd	ra,104(sp)
    4b36:	f0a2                	sd	s0,96(sp)
    4b38:	eca6                	sd	s1,88(sp)
    4b3a:	e8ca                	sd	s2,80(sp)
    4b3c:	e4ce                	sd	s3,72(sp)
    4b3e:	e0d2                	sd	s4,64(sp)
    4b40:	fc56                	sd	s5,56(sp)
    4b42:	f85a                	sd	s6,48(sp)
    4b44:	f45e                	sd	s7,40(sp)
    4b46:	f062                	sd	s8,32(sp)
    4b48:	ec66                	sd	s9,24(sp)
    4b4a:	e86a                	sd	s10,16(sp)
    4b4c:	1880                	addi	s0,sp,112
    4b4e:	8caa                	mv	s9,a0
    4b50:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4b52:	892a                	mv	s2,a0
    4b54:	4481                	li	s1,0
    cc = read(0, &c, 1);
    4b56:	f9f40b13          	addi	s6,s0,-97
    4b5a:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    4b5c:	4ba9                	li	s7,10
    4b5e:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
    4b60:	8d26                	mv	s10,s1
    4b62:	0014899b          	addiw	s3,s1,1
    4b66:	84ce                	mv	s1,s3
    4b68:	0349d563          	bge	s3,s4,4b92 <gets+0x60>
    cc = read(0, &c, 1);
    4b6c:	8656                	mv	a2,s5
    4b6e:	85da                	mv	a1,s6
    4b70:	4501                	li	a0,0
    4b72:	198000ef          	jal	4d0a <read>
    if(cc < 1)
    4b76:	00a05e63          	blez	a0,4b92 <gets+0x60>
    buf[i++] = c;
    4b7a:	f9f44783          	lbu	a5,-97(s0)
    4b7e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    4b82:	01778763          	beq	a5,s7,4b90 <gets+0x5e>
    4b86:	0905                	addi	s2,s2,1
    4b88:	fd879ce3          	bne	a5,s8,4b60 <gets+0x2e>
    buf[i++] = c;
    4b8c:	8d4e                	mv	s10,s3
    4b8e:	a011                	j	4b92 <gets+0x60>
    4b90:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
    4b92:	9d66                	add	s10,s10,s9
    4b94:	000d0023          	sb	zero,0(s10)
  return buf;
}
    4b98:	8566                	mv	a0,s9
    4b9a:	70a6                	ld	ra,104(sp)
    4b9c:	7406                	ld	s0,96(sp)
    4b9e:	64e6                	ld	s1,88(sp)
    4ba0:	6946                	ld	s2,80(sp)
    4ba2:	69a6                	ld	s3,72(sp)
    4ba4:	6a06                	ld	s4,64(sp)
    4ba6:	7ae2                	ld	s5,56(sp)
    4ba8:	7b42                	ld	s6,48(sp)
    4baa:	7ba2                	ld	s7,40(sp)
    4bac:	7c02                	ld	s8,32(sp)
    4bae:	6ce2                	ld	s9,24(sp)
    4bb0:	6d42                	ld	s10,16(sp)
    4bb2:	6165                	addi	sp,sp,112
    4bb4:	8082                	ret

0000000000004bb6 <stat>:

int
stat(const char *n, struct stat *st)
{
    4bb6:	1101                	addi	sp,sp,-32
    4bb8:	ec06                	sd	ra,24(sp)
    4bba:	e822                	sd	s0,16(sp)
    4bbc:	e04a                	sd	s2,0(sp)
    4bbe:	1000                	addi	s0,sp,32
    4bc0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    4bc2:	4581                	li	a1,0
    4bc4:	16e000ef          	jal	4d32 <open>
  if(fd < 0)
    4bc8:	02054263          	bltz	a0,4bec <stat+0x36>
    4bcc:	e426                	sd	s1,8(sp)
    4bce:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    4bd0:	85ca                	mv	a1,s2
    4bd2:	178000ef          	jal	4d4a <fstat>
    4bd6:	892a                	mv	s2,a0
  close(fd);
    4bd8:	8526                	mv	a0,s1
    4bda:	140000ef          	jal	4d1a <close>
  return r;
    4bde:	64a2                	ld	s1,8(sp)
}
    4be0:	854a                	mv	a0,s2
    4be2:	60e2                	ld	ra,24(sp)
    4be4:	6442                	ld	s0,16(sp)
    4be6:	6902                	ld	s2,0(sp)
    4be8:	6105                	addi	sp,sp,32
    4bea:	8082                	ret
    return -1;
    4bec:	597d                	li	s2,-1
    4bee:	bfcd                	j	4be0 <stat+0x2a>

0000000000004bf0 <atoi>:

int
atoi(const char *s)
{
    4bf0:	1141                	addi	sp,sp,-16
    4bf2:	e406                	sd	ra,8(sp)
    4bf4:	e022                	sd	s0,0(sp)
    4bf6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    4bf8:	00054683          	lbu	a3,0(a0)
    4bfc:	fd06879b          	addiw	a5,a3,-48
    4c00:	0ff7f793          	zext.b	a5,a5
    4c04:	4625                	li	a2,9
    4c06:	02f66963          	bltu	a2,a5,4c38 <atoi+0x48>
    4c0a:	872a                	mv	a4,a0
  n = 0;
    4c0c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    4c0e:	0705                	addi	a4,a4,1
    4c10:	0025179b          	slliw	a5,a0,0x2
    4c14:	9fa9                	addw	a5,a5,a0
    4c16:	0017979b          	slliw	a5,a5,0x1
    4c1a:	9fb5                	addw	a5,a5,a3
    4c1c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    4c20:	00074683          	lbu	a3,0(a4)
    4c24:	fd06879b          	addiw	a5,a3,-48
    4c28:	0ff7f793          	zext.b	a5,a5
    4c2c:	fef671e3          	bgeu	a2,a5,4c0e <atoi+0x1e>
  return n;
}
    4c30:	60a2                	ld	ra,8(sp)
    4c32:	6402                	ld	s0,0(sp)
    4c34:	0141                	addi	sp,sp,16
    4c36:	8082                	ret
  n = 0;
    4c38:	4501                	li	a0,0
    4c3a:	bfdd                	j	4c30 <atoi+0x40>

0000000000004c3c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    4c3c:	1141                	addi	sp,sp,-16
    4c3e:	e406                	sd	ra,8(sp)
    4c40:	e022                	sd	s0,0(sp)
    4c42:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    4c44:	02b57563          	bgeu	a0,a1,4c6e <memmove+0x32>
    while(n-- > 0)
    4c48:	00c05f63          	blez	a2,4c66 <memmove+0x2a>
    4c4c:	1602                	slli	a2,a2,0x20
    4c4e:	9201                	srli	a2,a2,0x20
    4c50:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    4c54:	872a                	mv	a4,a0
      *dst++ = *src++;
    4c56:	0585                	addi	a1,a1,1
    4c58:	0705                	addi	a4,a4,1
    4c5a:	fff5c683          	lbu	a3,-1(a1)
    4c5e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    4c62:	fee79ae3          	bne	a5,a4,4c56 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    4c66:	60a2                	ld	ra,8(sp)
    4c68:	6402                	ld	s0,0(sp)
    4c6a:	0141                	addi	sp,sp,16
    4c6c:	8082                	ret
    dst += n;
    4c6e:	00c50733          	add	a4,a0,a2
    src += n;
    4c72:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    4c74:	fec059e3          	blez	a2,4c66 <memmove+0x2a>
    4c78:	fff6079b          	addiw	a5,a2,-1 # 2fff <subdir+0x235>
    4c7c:	1782                	slli	a5,a5,0x20
    4c7e:	9381                	srli	a5,a5,0x20
    4c80:	fff7c793          	not	a5,a5
    4c84:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    4c86:	15fd                	addi	a1,a1,-1
    4c88:	177d                	addi	a4,a4,-1
    4c8a:	0005c683          	lbu	a3,0(a1)
    4c8e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    4c92:	fef71ae3          	bne	a4,a5,4c86 <memmove+0x4a>
    4c96:	bfc1                	j	4c66 <memmove+0x2a>

0000000000004c98 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    4c98:	1141                	addi	sp,sp,-16
    4c9a:	e406                	sd	ra,8(sp)
    4c9c:	e022                	sd	s0,0(sp)
    4c9e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    4ca0:	ca0d                	beqz	a2,4cd2 <memcmp+0x3a>
    4ca2:	fff6069b          	addiw	a3,a2,-1
    4ca6:	1682                	slli	a3,a3,0x20
    4ca8:	9281                	srli	a3,a3,0x20
    4caa:	0685                	addi	a3,a3,1
    4cac:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    4cae:	00054783          	lbu	a5,0(a0)
    4cb2:	0005c703          	lbu	a4,0(a1)
    4cb6:	00e79863          	bne	a5,a4,4cc6 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
    4cba:	0505                	addi	a0,a0,1
    p2++;
    4cbc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    4cbe:	fed518e3          	bne	a0,a3,4cae <memcmp+0x16>
  }
  return 0;
    4cc2:	4501                	li	a0,0
    4cc4:	a019                	j	4cca <memcmp+0x32>
      return *p1 - *p2;
    4cc6:	40e7853b          	subw	a0,a5,a4
}
    4cca:	60a2                	ld	ra,8(sp)
    4ccc:	6402                	ld	s0,0(sp)
    4cce:	0141                	addi	sp,sp,16
    4cd0:	8082                	ret
  return 0;
    4cd2:	4501                	li	a0,0
    4cd4:	bfdd                	j	4cca <memcmp+0x32>

0000000000004cd6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    4cd6:	1141                	addi	sp,sp,-16
    4cd8:	e406                	sd	ra,8(sp)
    4cda:	e022                	sd	s0,0(sp)
    4cdc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    4cde:	f5fff0ef          	jal	4c3c <memmove>
}
    4ce2:	60a2                	ld	ra,8(sp)
    4ce4:	6402                	ld	s0,0(sp)
    4ce6:	0141                	addi	sp,sp,16
    4ce8:	8082                	ret

0000000000004cea <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    4cea:	4885                	li	a7,1
 ecall
    4cec:	00000073          	ecall
 ret
    4cf0:	8082                	ret

0000000000004cf2 <exit>:
.global exit
exit:
 li a7, SYS_exit
    4cf2:	4889                	li	a7,2
 ecall
    4cf4:	00000073          	ecall
 ret
    4cf8:	8082                	ret

0000000000004cfa <wait>:
.global wait
wait:
 li a7, SYS_wait
    4cfa:	488d                	li	a7,3
 ecall
    4cfc:	00000073          	ecall
 ret
    4d00:	8082                	ret

0000000000004d02 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    4d02:	4891                	li	a7,4
 ecall
    4d04:	00000073          	ecall
 ret
    4d08:	8082                	ret

0000000000004d0a <read>:
.global read
read:
 li a7, SYS_read
    4d0a:	4895                	li	a7,5
 ecall
    4d0c:	00000073          	ecall
 ret
    4d10:	8082                	ret

0000000000004d12 <write>:
.global write
write:
 li a7, SYS_write
    4d12:	48c1                	li	a7,16
 ecall
    4d14:	00000073          	ecall
 ret
    4d18:	8082                	ret

0000000000004d1a <close>:
.global close
close:
 li a7, SYS_close
    4d1a:	48d5                	li	a7,21
 ecall
    4d1c:	00000073          	ecall
 ret
    4d20:	8082                	ret

0000000000004d22 <kill>:
.global kill
kill:
 li a7, SYS_kill
    4d22:	4899                	li	a7,6
 ecall
    4d24:	00000073          	ecall
 ret
    4d28:	8082                	ret

0000000000004d2a <exec>:
.global exec
exec:
 li a7, SYS_exec
    4d2a:	489d                	li	a7,7
 ecall
    4d2c:	00000073          	ecall
 ret
    4d30:	8082                	ret

0000000000004d32 <open>:
.global open
open:
 li a7, SYS_open
    4d32:	48bd                	li	a7,15
 ecall
    4d34:	00000073          	ecall
 ret
    4d38:	8082                	ret

0000000000004d3a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    4d3a:	48c5                	li	a7,17
 ecall
    4d3c:	00000073          	ecall
 ret
    4d40:	8082                	ret

0000000000004d42 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    4d42:	48c9                	li	a7,18
 ecall
    4d44:	00000073          	ecall
 ret
    4d48:	8082                	ret

0000000000004d4a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    4d4a:	48a1                	li	a7,8
 ecall
    4d4c:	00000073          	ecall
 ret
    4d50:	8082                	ret

0000000000004d52 <link>:
.global link
link:
 li a7, SYS_link
    4d52:	48cd                	li	a7,19
 ecall
    4d54:	00000073          	ecall
 ret
    4d58:	8082                	ret

0000000000004d5a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    4d5a:	48d1                	li	a7,20
 ecall
    4d5c:	00000073          	ecall
 ret
    4d60:	8082                	ret

0000000000004d62 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4d62:	48a5                	li	a7,9
 ecall
    4d64:	00000073          	ecall
 ret
    4d68:	8082                	ret

0000000000004d6a <dup>:
.global dup
dup:
 li a7, SYS_dup
    4d6a:	48a9                	li	a7,10
 ecall
    4d6c:	00000073          	ecall
 ret
    4d70:	8082                	ret

0000000000004d72 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    4d72:	48ad                	li	a7,11
 ecall
    4d74:	00000073          	ecall
 ret
    4d78:	8082                	ret

0000000000004d7a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    4d7a:	48b1                	li	a7,12
 ecall
    4d7c:	00000073          	ecall
 ret
    4d80:	8082                	ret

0000000000004d82 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    4d82:	48b5                	li	a7,13
 ecall
    4d84:	00000073          	ecall
 ret
    4d88:	8082                	ret

0000000000004d8a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    4d8a:	48b9                	li	a7,14
 ecall
    4d8c:	00000073          	ecall
 ret
    4d90:	8082                	ret

0000000000004d92 <getSyscount>:
.global getSyscount
getSyscount:
 li a7, SYS_getSyscount
    4d92:	48d9                	li	a7,22
 ecall
    4d94:	00000073          	ecall
 ret
    4d98:	8082                	ret

0000000000004d9a <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
    4d9a:	48dd                	li	a7,23
 ecall
    4d9c:	00000073          	ecall
 ret
    4da0:	8082                	ret

0000000000004da2 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
    4da2:	48e1                	li	a7,24
 ecall
    4da4:	00000073          	ecall
 ret
    4da8:	8082                	ret

0000000000004daa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    4daa:	1101                	addi	sp,sp,-32
    4dac:	ec06                	sd	ra,24(sp)
    4dae:	e822                	sd	s0,16(sp)
    4db0:	1000                	addi	s0,sp,32
    4db2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    4db6:	4605                	li	a2,1
    4db8:	fef40593          	addi	a1,s0,-17
    4dbc:	f57ff0ef          	jal	4d12 <write>
}
    4dc0:	60e2                	ld	ra,24(sp)
    4dc2:	6442                	ld	s0,16(sp)
    4dc4:	6105                	addi	sp,sp,32
    4dc6:	8082                	ret

0000000000004dc8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    4dc8:	7139                	addi	sp,sp,-64
    4dca:	fc06                	sd	ra,56(sp)
    4dcc:	f822                	sd	s0,48(sp)
    4dce:	f426                	sd	s1,40(sp)
    4dd0:	f04a                	sd	s2,32(sp)
    4dd2:	ec4e                	sd	s3,24(sp)
    4dd4:	0080                	addi	s0,sp,64
    4dd6:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    4dd8:	c299                	beqz	a3,4dde <printint+0x16>
    4dda:	0605ce63          	bltz	a1,4e56 <printint+0x8e>
  neg = 0;
    4dde:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    4de0:	fc040313          	addi	t1,s0,-64
  neg = 0;
    4de4:	869a                	mv	a3,t1
  i = 0;
    4de6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    4de8:	00003817          	auipc	a6,0x3
    4dec:	9c880813          	addi	a6,a6,-1592 # 77b0 <digits>
    4df0:	88be                	mv	a7,a5
    4df2:	0017851b          	addiw	a0,a5,1
    4df6:	87aa                	mv	a5,a0
    4df8:	02c5f73b          	remuw	a4,a1,a2
    4dfc:	1702                	slli	a4,a4,0x20
    4dfe:	9301                	srli	a4,a4,0x20
    4e00:	9742                	add	a4,a4,a6
    4e02:	00074703          	lbu	a4,0(a4)
    4e06:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    4e0a:	872e                	mv	a4,a1
    4e0c:	02c5d5bb          	divuw	a1,a1,a2
    4e10:	0685                	addi	a3,a3,1
    4e12:	fcc77fe3          	bgeu	a4,a2,4df0 <printint+0x28>
  if(neg)
    4e16:	000e0c63          	beqz	t3,4e2e <printint+0x66>
    buf[i++] = '-';
    4e1a:	fd050793          	addi	a5,a0,-48
    4e1e:	00878533          	add	a0,a5,s0
    4e22:	02d00793          	li	a5,45
    4e26:	fef50823          	sb	a5,-16(a0)
    4e2a:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    4e2e:	fff7899b          	addiw	s3,a5,-1
    4e32:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
    4e36:	fff4c583          	lbu	a1,-1(s1)
    4e3a:	854a                	mv	a0,s2
    4e3c:	f6fff0ef          	jal	4daa <putc>
  while(--i >= 0)
    4e40:	39fd                	addiw	s3,s3,-1
    4e42:	14fd                	addi	s1,s1,-1
    4e44:	fe09d9e3          	bgez	s3,4e36 <printint+0x6e>
}
    4e48:	70e2                	ld	ra,56(sp)
    4e4a:	7442                	ld	s0,48(sp)
    4e4c:	74a2                	ld	s1,40(sp)
    4e4e:	7902                	ld	s2,32(sp)
    4e50:	69e2                	ld	s3,24(sp)
    4e52:	6121                	addi	sp,sp,64
    4e54:	8082                	ret
    x = -xx;
    4e56:	40b005bb          	negw	a1,a1
    neg = 1;
    4e5a:	4e05                	li	t3,1
    x = -xx;
    4e5c:	b751                	j	4de0 <printint+0x18>

0000000000004e5e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    4e5e:	711d                	addi	sp,sp,-96
    4e60:	ec86                	sd	ra,88(sp)
    4e62:	e8a2                	sd	s0,80(sp)
    4e64:	e4a6                	sd	s1,72(sp)
    4e66:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    4e68:	0005c483          	lbu	s1,0(a1)
    4e6c:	26048663          	beqz	s1,50d8 <vprintf+0x27a>
    4e70:	e0ca                	sd	s2,64(sp)
    4e72:	fc4e                	sd	s3,56(sp)
    4e74:	f852                	sd	s4,48(sp)
    4e76:	f456                	sd	s5,40(sp)
    4e78:	f05a                	sd	s6,32(sp)
    4e7a:	ec5e                	sd	s7,24(sp)
    4e7c:	e862                	sd	s8,16(sp)
    4e7e:	e466                	sd	s9,8(sp)
    4e80:	8b2a                	mv	s6,a0
    4e82:	8a2e                	mv	s4,a1
    4e84:	8bb2                	mv	s7,a2
  state = 0;
    4e86:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    4e88:	4901                	li	s2,0
    4e8a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    4e8c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    4e90:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    4e94:	06c00c93          	li	s9,108
    4e98:	a00d                	j	4eba <vprintf+0x5c>
        putc(fd, c0);
    4e9a:	85a6                	mv	a1,s1
    4e9c:	855a                	mv	a0,s6
    4e9e:	f0dff0ef          	jal	4daa <putc>
    4ea2:	a019                	j	4ea8 <vprintf+0x4a>
    } else if(state == '%'){
    4ea4:	03598363          	beq	s3,s5,4eca <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
    4ea8:	0019079b          	addiw	a5,s2,1
    4eac:	893e                	mv	s2,a5
    4eae:	873e                	mv	a4,a5
    4eb0:	97d2                	add	a5,a5,s4
    4eb2:	0007c483          	lbu	s1,0(a5)
    4eb6:	20048963          	beqz	s1,50c8 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
    4eba:	0004879b          	sext.w	a5,s1
    if(state == 0){
    4ebe:	fe0993e3          	bnez	s3,4ea4 <vprintf+0x46>
      if(c0 == '%'){
    4ec2:	fd579ce3          	bne	a5,s5,4e9a <vprintf+0x3c>
        state = '%';
    4ec6:	89be                	mv	s3,a5
    4ec8:	b7c5                	j	4ea8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    4eca:	00ea06b3          	add	a3,s4,a4
    4ece:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    4ed2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    4ed4:	c681                	beqz	a3,4edc <vprintf+0x7e>
    4ed6:	9752                	add	a4,a4,s4
    4ed8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    4edc:	03878e63          	beq	a5,s8,4f18 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
    4ee0:	05978863          	beq	a5,s9,4f30 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    4ee4:	07500713          	li	a4,117
    4ee8:	0ee78263          	beq	a5,a4,4fcc <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    4eec:	07800713          	li	a4,120
    4ef0:	12e78463          	beq	a5,a4,5018 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    4ef4:	07000713          	li	a4,112
    4ef8:	14e78963          	beq	a5,a4,504a <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
    4efc:	07300713          	li	a4,115
    4f00:	18e78863          	beq	a5,a4,5090 <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    4f04:	02500713          	li	a4,37
    4f08:	04e79463          	bne	a5,a4,4f50 <vprintf+0xf2>
        putc(fd, '%');
    4f0c:	85ba                	mv	a1,a4
    4f0e:	855a                	mv	a0,s6
    4f10:	e9bff0ef          	jal	4daa <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
    4f14:	4981                	li	s3,0
    4f16:	bf49                	j	4ea8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    4f18:	008b8493          	addi	s1,s7,8
    4f1c:	4685                	li	a3,1
    4f1e:	4629                	li	a2,10
    4f20:	000ba583          	lw	a1,0(s7)
    4f24:	855a                	mv	a0,s6
    4f26:	ea3ff0ef          	jal	4dc8 <printint>
    4f2a:	8ba6                	mv	s7,s1
      state = 0;
    4f2c:	4981                	li	s3,0
    4f2e:	bfad                	j	4ea8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    4f30:	06400793          	li	a5,100
    4f34:	02f68963          	beq	a3,a5,4f66 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    4f38:	06c00793          	li	a5,108
    4f3c:	04f68263          	beq	a3,a5,4f80 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
    4f40:	07500793          	li	a5,117
    4f44:	0af68063          	beq	a3,a5,4fe4 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
    4f48:	07800793          	li	a5,120
    4f4c:	0ef68263          	beq	a3,a5,5030 <vprintf+0x1d2>
        putc(fd, '%');
    4f50:	02500593          	li	a1,37
    4f54:	855a                	mv	a0,s6
    4f56:	e55ff0ef          	jal	4daa <putc>
        putc(fd, c0);
    4f5a:	85a6                	mv	a1,s1
    4f5c:	855a                	mv	a0,s6
    4f5e:	e4dff0ef          	jal	4daa <putc>
      state = 0;
    4f62:	4981                	li	s3,0
    4f64:	b791                	j	4ea8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    4f66:	008b8493          	addi	s1,s7,8
    4f6a:	4685                	li	a3,1
    4f6c:	4629                	li	a2,10
    4f6e:	000ba583          	lw	a1,0(s7)
    4f72:	855a                	mv	a0,s6
    4f74:	e55ff0ef          	jal	4dc8 <printint>
        i += 1;
    4f78:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    4f7a:	8ba6                	mv	s7,s1
      state = 0;
    4f7c:	4981                	li	s3,0
        i += 1;
    4f7e:	b72d                	j	4ea8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    4f80:	06400793          	li	a5,100
    4f84:	02f60763          	beq	a2,a5,4fb2 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    4f88:	07500793          	li	a5,117
    4f8c:	06f60963          	beq	a2,a5,4ffe <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    4f90:	07800793          	li	a5,120
    4f94:	faf61ee3          	bne	a2,a5,4f50 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
    4f98:	008b8493          	addi	s1,s7,8
    4f9c:	4681                	li	a3,0
    4f9e:	4641                	li	a2,16
    4fa0:	000ba583          	lw	a1,0(s7)
    4fa4:	855a                	mv	a0,s6
    4fa6:	e23ff0ef          	jal	4dc8 <printint>
        i += 2;
    4faa:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    4fac:	8ba6                	mv	s7,s1
      state = 0;
    4fae:	4981                	li	s3,0
        i += 2;
    4fb0:	bde5                	j	4ea8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    4fb2:	008b8493          	addi	s1,s7,8
    4fb6:	4685                	li	a3,1
    4fb8:	4629                	li	a2,10
    4fba:	000ba583          	lw	a1,0(s7)
    4fbe:	855a                	mv	a0,s6
    4fc0:	e09ff0ef          	jal	4dc8 <printint>
        i += 2;
    4fc4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    4fc6:	8ba6                	mv	s7,s1
      state = 0;
    4fc8:	4981                	li	s3,0
        i += 2;
    4fca:	bdf9                	j	4ea8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
    4fcc:	008b8493          	addi	s1,s7,8
    4fd0:	4681                	li	a3,0
    4fd2:	4629                	li	a2,10
    4fd4:	000ba583          	lw	a1,0(s7)
    4fd8:	855a                	mv	a0,s6
    4fda:	defff0ef          	jal	4dc8 <printint>
    4fde:	8ba6                	mv	s7,s1
      state = 0;
    4fe0:	4981                	li	s3,0
    4fe2:	b5d9                	j	4ea8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    4fe4:	008b8493          	addi	s1,s7,8
    4fe8:	4681                	li	a3,0
    4fea:	4629                	li	a2,10
    4fec:	000ba583          	lw	a1,0(s7)
    4ff0:	855a                	mv	a0,s6
    4ff2:	dd7ff0ef          	jal	4dc8 <printint>
        i += 1;
    4ff6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    4ff8:	8ba6                	mv	s7,s1
      state = 0;
    4ffa:	4981                	li	s3,0
        i += 1;
    4ffc:	b575                	j	4ea8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    4ffe:	008b8493          	addi	s1,s7,8
    5002:	4681                	li	a3,0
    5004:	4629                	li	a2,10
    5006:	000ba583          	lw	a1,0(s7)
    500a:	855a                	mv	a0,s6
    500c:	dbdff0ef          	jal	4dc8 <printint>
        i += 2;
    5010:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    5012:	8ba6                	mv	s7,s1
      state = 0;
    5014:	4981                	li	s3,0
        i += 2;
    5016:	bd49                	j	4ea8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
    5018:	008b8493          	addi	s1,s7,8
    501c:	4681                	li	a3,0
    501e:	4641                	li	a2,16
    5020:	000ba583          	lw	a1,0(s7)
    5024:	855a                	mv	a0,s6
    5026:	da3ff0ef          	jal	4dc8 <printint>
    502a:	8ba6                	mv	s7,s1
      state = 0;
    502c:	4981                	li	s3,0
    502e:	bdad                	j	4ea8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    5030:	008b8493          	addi	s1,s7,8
    5034:	4681                	li	a3,0
    5036:	4641                	li	a2,16
    5038:	000ba583          	lw	a1,0(s7)
    503c:	855a                	mv	a0,s6
    503e:	d8bff0ef          	jal	4dc8 <printint>
        i += 1;
    5042:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    5044:	8ba6                	mv	s7,s1
      state = 0;
    5046:	4981                	li	s3,0
        i += 1;
    5048:	b585                	j	4ea8 <vprintf+0x4a>
    504a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    504c:	008b8d13          	addi	s10,s7,8
    5050:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    5054:	03000593          	li	a1,48
    5058:	855a                	mv	a0,s6
    505a:	d51ff0ef          	jal	4daa <putc>
  putc(fd, 'x');
    505e:	07800593          	li	a1,120
    5062:	855a                	mv	a0,s6
    5064:	d47ff0ef          	jal	4daa <putc>
    5068:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    506a:	00002b97          	auipc	s7,0x2
    506e:	746b8b93          	addi	s7,s7,1862 # 77b0 <digits>
    5072:	03c9d793          	srli	a5,s3,0x3c
    5076:	97de                	add	a5,a5,s7
    5078:	0007c583          	lbu	a1,0(a5)
    507c:	855a                	mv	a0,s6
    507e:	d2dff0ef          	jal	4daa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5082:	0992                	slli	s3,s3,0x4
    5084:	34fd                	addiw	s1,s1,-1
    5086:	f4f5                	bnez	s1,5072 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
    5088:	8bea                	mv	s7,s10
      state = 0;
    508a:	4981                	li	s3,0
    508c:	6d02                	ld	s10,0(sp)
    508e:	bd29                	j	4ea8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    5090:	008b8993          	addi	s3,s7,8
    5094:	000bb483          	ld	s1,0(s7)
    5098:	cc91                	beqz	s1,50b4 <vprintf+0x256>
        for(; *s; s++)
    509a:	0004c583          	lbu	a1,0(s1)
    509e:	c195                	beqz	a1,50c2 <vprintf+0x264>
          putc(fd, *s);
    50a0:	855a                	mv	a0,s6
    50a2:	d09ff0ef          	jal	4daa <putc>
        for(; *s; s++)
    50a6:	0485                	addi	s1,s1,1
    50a8:	0004c583          	lbu	a1,0(s1)
    50ac:	f9f5                	bnez	a1,50a0 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
    50ae:	8bce                	mv	s7,s3
      state = 0;
    50b0:	4981                	li	s3,0
    50b2:	bbdd                	j	4ea8 <vprintf+0x4a>
          s = "(null)";
    50b4:	00002497          	auipc	s1,0x2
    50b8:	67c48493          	addi	s1,s1,1660 # 7730 <malloc+0x256c>
        for(; *s; s++)
    50bc:	02800593          	li	a1,40
    50c0:	b7c5                	j	50a0 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
    50c2:	8bce                	mv	s7,s3
      state = 0;
    50c4:	4981                	li	s3,0
    50c6:	b3cd                	j	4ea8 <vprintf+0x4a>
    50c8:	6906                	ld	s2,64(sp)
    50ca:	79e2                	ld	s3,56(sp)
    50cc:	7a42                	ld	s4,48(sp)
    50ce:	7aa2                	ld	s5,40(sp)
    50d0:	7b02                	ld	s6,32(sp)
    50d2:	6be2                	ld	s7,24(sp)
    50d4:	6c42                	ld	s8,16(sp)
    50d6:	6ca2                	ld	s9,8(sp)
    }
  }
}
    50d8:	60e6                	ld	ra,88(sp)
    50da:	6446                	ld	s0,80(sp)
    50dc:	64a6                	ld	s1,72(sp)
    50de:	6125                	addi	sp,sp,96
    50e0:	8082                	ret

00000000000050e2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    50e2:	715d                	addi	sp,sp,-80
    50e4:	ec06                	sd	ra,24(sp)
    50e6:	e822                	sd	s0,16(sp)
    50e8:	1000                	addi	s0,sp,32
    50ea:	e010                	sd	a2,0(s0)
    50ec:	e414                	sd	a3,8(s0)
    50ee:	e818                	sd	a4,16(s0)
    50f0:	ec1c                	sd	a5,24(s0)
    50f2:	03043023          	sd	a6,32(s0)
    50f6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    50fa:	8622                	mv	a2,s0
    50fc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5100:	d5fff0ef          	jal	4e5e <vprintf>
}
    5104:	60e2                	ld	ra,24(sp)
    5106:	6442                	ld	s0,16(sp)
    5108:	6161                	addi	sp,sp,80
    510a:	8082                	ret

000000000000510c <printf>:

void
printf(const char *fmt, ...)
{
    510c:	711d                	addi	sp,sp,-96
    510e:	ec06                	sd	ra,24(sp)
    5110:	e822                	sd	s0,16(sp)
    5112:	1000                	addi	s0,sp,32
    5114:	e40c                	sd	a1,8(s0)
    5116:	e810                	sd	a2,16(s0)
    5118:	ec14                	sd	a3,24(s0)
    511a:	f018                	sd	a4,32(s0)
    511c:	f41c                	sd	a5,40(s0)
    511e:	03043823          	sd	a6,48(s0)
    5122:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5126:	00840613          	addi	a2,s0,8
    512a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    512e:	85aa                	mv	a1,a0
    5130:	4505                	li	a0,1
    5132:	d2dff0ef          	jal	4e5e <vprintf>
}
    5136:	60e2                	ld	ra,24(sp)
    5138:	6442                	ld	s0,16(sp)
    513a:	6125                	addi	sp,sp,96
    513c:	8082                	ret

000000000000513e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    513e:	1141                	addi	sp,sp,-16
    5140:	e406                	sd	ra,8(sp)
    5142:	e022                	sd	s0,0(sp)
    5144:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5146:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    514a:	00004797          	auipc	a5,0x4
    514e:	3067b783          	ld	a5,774(a5) # 9450 <freep>
    5152:	a02d                	j	517c <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5154:	4618                	lw	a4,8(a2)
    5156:	9f2d                	addw	a4,a4,a1
    5158:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    515c:	6398                	ld	a4,0(a5)
    515e:	6310                	ld	a2,0(a4)
    5160:	a83d                	j	519e <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5162:	ff852703          	lw	a4,-8(a0)
    5166:	9f31                	addw	a4,a4,a2
    5168:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    516a:	ff053683          	ld	a3,-16(a0)
    516e:	a091                	j	51b2 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5170:	6398                	ld	a4,0(a5)
    5172:	00e7e463          	bltu	a5,a4,517a <free+0x3c>
    5176:	00e6ea63          	bltu	a3,a4,518a <free+0x4c>
{
    517a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    517c:	fed7fae3          	bgeu	a5,a3,5170 <free+0x32>
    5180:	6398                	ld	a4,0(a5)
    5182:	00e6e463          	bltu	a3,a4,518a <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5186:	fee7eae3          	bltu	a5,a4,517a <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
    518a:	ff852583          	lw	a1,-8(a0)
    518e:	6390                	ld	a2,0(a5)
    5190:	02059813          	slli	a6,a1,0x20
    5194:	01c85713          	srli	a4,a6,0x1c
    5198:	9736                	add	a4,a4,a3
    519a:	fae60de3          	beq	a2,a4,5154 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
    519e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    51a2:	4790                	lw	a2,8(a5)
    51a4:	02061593          	slli	a1,a2,0x20
    51a8:	01c5d713          	srli	a4,a1,0x1c
    51ac:	973e                	add	a4,a4,a5
    51ae:	fae68ae3          	beq	a3,a4,5162 <free+0x24>
    p->s.ptr = bp->s.ptr;
    51b2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    51b4:	00004717          	auipc	a4,0x4
    51b8:	28f73e23          	sd	a5,668(a4) # 9450 <freep>
}
    51bc:	60a2                	ld	ra,8(sp)
    51be:	6402                	ld	s0,0(sp)
    51c0:	0141                	addi	sp,sp,16
    51c2:	8082                	ret

00000000000051c4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    51c4:	7139                	addi	sp,sp,-64
    51c6:	fc06                	sd	ra,56(sp)
    51c8:	f822                	sd	s0,48(sp)
    51ca:	f04a                	sd	s2,32(sp)
    51cc:	ec4e                	sd	s3,24(sp)
    51ce:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    51d0:	02051993          	slli	s3,a0,0x20
    51d4:	0209d993          	srli	s3,s3,0x20
    51d8:	09bd                	addi	s3,s3,15
    51da:	0049d993          	srli	s3,s3,0x4
    51de:	2985                	addiw	s3,s3,1
    51e0:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
    51e2:	00004517          	auipc	a0,0x4
    51e6:	26e53503          	ld	a0,622(a0) # 9450 <freep>
    51ea:	c905                	beqz	a0,521a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    51ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    51ee:	4798                	lw	a4,8(a5)
    51f0:	09377663          	bgeu	a4,s3,527c <malloc+0xb8>
    51f4:	f426                	sd	s1,40(sp)
    51f6:	e852                	sd	s4,16(sp)
    51f8:	e456                	sd	s5,8(sp)
    51fa:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    51fc:	8a4e                	mv	s4,s3
    51fe:	6705                	lui	a4,0x1
    5200:	00e9f363          	bgeu	s3,a4,5206 <malloc+0x42>
    5204:	6a05                	lui	s4,0x1
    5206:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    520a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    520e:	00004497          	auipc	s1,0x4
    5212:	24248493          	addi	s1,s1,578 # 9450 <freep>
  if(p == (char*)-1)
    5216:	5afd                	li	s5,-1
    5218:	a83d                	j	5256 <malloc+0x92>
    521a:	f426                	sd	s1,40(sp)
    521c:	e852                	sd	s4,16(sp)
    521e:	e456                	sd	s5,8(sp)
    5220:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    5222:	0000b797          	auipc	a5,0xb
    5226:	a5678793          	addi	a5,a5,-1450 # fc78 <base>
    522a:	00004717          	auipc	a4,0x4
    522e:	22f73323          	sd	a5,550(a4) # 9450 <freep>
    5232:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5234:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5238:	b7d1                	j	51fc <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    523a:	6398                	ld	a4,0(a5)
    523c:	e118                	sd	a4,0(a0)
    523e:	a899                	j	5294 <malloc+0xd0>
  hp->s.size = nu;
    5240:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5244:	0541                	addi	a0,a0,16
    5246:	ef9ff0ef          	jal	513e <free>
  return freep;
    524a:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    524c:	c125                	beqz	a0,52ac <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    524e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5250:	4798                	lw	a4,8(a5)
    5252:	03277163          	bgeu	a4,s2,5274 <malloc+0xb0>
    if(p == freep)
    5256:	6098                	ld	a4,0(s1)
    5258:	853e                	mv	a0,a5
    525a:	fef71ae3          	bne	a4,a5,524e <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
    525e:	8552                	mv	a0,s4
    5260:	b1bff0ef          	jal	4d7a <sbrk>
  if(p == (char*)-1)
    5264:	fd551ee3          	bne	a0,s5,5240 <malloc+0x7c>
        return 0;
    5268:	4501                	li	a0,0
    526a:	74a2                	ld	s1,40(sp)
    526c:	6a42                	ld	s4,16(sp)
    526e:	6aa2                	ld	s5,8(sp)
    5270:	6b02                	ld	s6,0(sp)
    5272:	a03d                	j	52a0 <malloc+0xdc>
    5274:	74a2                	ld	s1,40(sp)
    5276:	6a42                	ld	s4,16(sp)
    5278:	6aa2                	ld	s5,8(sp)
    527a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    527c:	fae90fe3          	beq	s2,a4,523a <malloc+0x76>
        p->s.size -= nunits;
    5280:	4137073b          	subw	a4,a4,s3
    5284:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5286:	02071693          	slli	a3,a4,0x20
    528a:	01c6d713          	srli	a4,a3,0x1c
    528e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5290:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5294:	00004717          	auipc	a4,0x4
    5298:	1aa73e23          	sd	a0,444(a4) # 9450 <freep>
      return (void*)(p + 1);
    529c:	01078513          	addi	a0,a5,16
  }
}
    52a0:	70e2                	ld	ra,56(sp)
    52a2:	7442                	ld	s0,48(sp)
    52a4:	7902                	ld	s2,32(sp)
    52a6:	69e2                	ld	s3,24(sp)
    52a8:	6121                	addi	sp,sp,64
    52aa:	8082                	ret
    52ac:	74a2                	ld	s1,40(sp)
    52ae:	6a42                	ld	s4,16(sp)
    52b0:	6aa2                	ld	s5,8(sp)
    52b2:	6b02                	ld	s6,0(sp)
    52b4:	b7f5                	j	52a0 <malloc+0xdc>
