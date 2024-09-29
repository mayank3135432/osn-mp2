
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <printsyscall>:
#include "user/user.h"
#include "kernel/fcntl.h"



void printsyscall(int sid){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  switch(sid) {
   8:	6785                	lui	a5,0x1
   a:	18f50d63          	beq	a0,a5,1a4 <printsyscall+0x1a4>
   e:	06a7cd63          	blt	a5,a0,88 <printsyscall+0x88>
  12:	04000793          	li	a5,64
  16:	14f50b63          	beq	a0,a5,16c <printsyscall+0x16c>
  1a:	02a7d663          	bge	a5,a0,46 <printsyscall+0x46>
  1e:	20000793          	li	a5,512
  22:	16f50363          	beq	a0,a5,188 <printsyscall+0x188>
  26:	04a7d263          	bge	a5,a0,6a <printsyscall+0x6a>
  2a:	40000793          	li	a5,1024
  2e:	16f50463          	beq	a0,a5,196 <printsyscall+0x196>
  32:	8005051b          	addiw	a0,a0,-2048
  36:	ed71                	bnez	a0,112 <printsyscall+0x112>
      break;
    case 1<<10:
      printf("dup");
      break;
    case 1<<11:
      printf("getpid");
  38:	00001517          	auipc	a0,0x1
  3c:	b3050513          	addi	a0,a0,-1232 # b68 <malloc+0x152>
  40:	11f000ef          	jal	95e <printf>
      break;
  44:	a8e9                	j	11e <printsyscall+0x11e>
  switch(sid) {
  46:	ffe5079b          	addiw	a5,a0,-2
  4a:	4779                	li	a4,30
  4c:	0cf76363          	bltu	a4,a5,112 <printsyscall+0x112>
  50:	02000793          	li	a5,32
  54:	0aa7ef63          	bltu	a5,a0,112 <printsyscall+0x112>
  58:	050a                	slli	a0,a0,0x2
  5a:	00001717          	auipc	a4,0x1
  5e:	bfe70713          	addi	a4,a4,-1026 # c58 <malloc+0x242>
  62:	953a                	add	a0,a0,a4
  64:	411c                	lw	a5,0(a0)
  66:	97ba                	add	a5,a5,a4
  68:	8782                	jr	a5
  6a:	08000793          	li	a5,128
  6e:	10f50663          	beq	a0,a5,17a <printsyscall+0x17a>
  72:	10000793          	li	a5,256
  76:	08f51e63          	bne	a0,a5,112 <printsyscall+0x112>
      printf("fstat");
  7a:	00001517          	auipc	a0,0x1
  7e:	ad650513          	addi	a0,a0,-1322 # b50 <malloc+0x13a>
  82:	0dd000ef          	jal	95e <printf>
      break;
  86:	a861                	j	11e <printsyscall+0x11e>
  switch(sid) {
  88:	000407b7          	lui	a5,0x40
  8c:	14f50863          	beq	a0,a5,1dc <printsyscall+0x1dc>
  90:	04a7c263          	blt	a5,a0,d4 <printsyscall+0xd4>
  94:	67a1                	lui	a5,0x8
  96:	12f50563          	beq	a0,a5,1c0 <printsyscall+0x1c0>
  9a:	02a7d063          	bge	a5,a0,ba <printsyscall+0xba>
  9e:	67c1                	lui	a5,0x10
  a0:	12f50763          	beq	a0,a5,1ce <printsyscall+0x1ce>
  a4:	000207b7          	lui	a5,0x20
  a8:	06f51563          	bne	a0,a5,112 <printsyscall+0x112>
      break;
    case 1<<16:
      printf("write");
      break;
    case 1<<17:
      printf("mknod");
  ac:	00001517          	auipc	a0,0x1
  b0:	aec50513          	addi	a0,a0,-1300 # b98 <malloc+0x182>
  b4:	0ab000ef          	jal	95e <printf>
      break;
  b8:	a09d                	j	11e <printsyscall+0x11e>
  switch(sid) {
  ba:	6789                	lui	a5,0x2
  bc:	0ef50b63          	beq	a0,a5,1b2 <printsyscall+0x1b2>
  c0:	6791                	lui	a5,0x4
  c2:	04f51863          	bne	a0,a5,112 <printsyscall+0x112>
      printf("uptime");
  c6:	00001517          	auipc	a0,0x1
  ca:	aba50513          	addi	a0,a0,-1350 # b80 <malloc+0x16a>
  ce:	091000ef          	jal	95e <printf>
      break;
  d2:	a0b1                	j	11e <printsyscall+0x11e>
  switch(sid) {
  d4:	002007b7          	lui	a5,0x200
  d8:	12f50063          	beq	a0,a5,1f8 <printsyscall+0x1f8>
  dc:	02a7c163          	blt	a5,a0,fe <printsyscall+0xfe>
  e0:	000807b7          	lui	a5,0x80
  e4:	10f50363          	beq	a0,a5,1ea <printsyscall+0x1ea>
  e8:	001007b7          	lui	a5,0x100
  ec:	02f51363          	bne	a0,a5,112 <printsyscall+0x112>
      break;
    case 1<<19:
      printf("link");
      break;
    case 1<<20:
      printf("mkdir");
  f0:	00001517          	auipc	a0,0x1
  f4:	ac050513          	addi	a0,a0,-1344 # bb0 <malloc+0x19a>
  f8:	067000ef          	jal	95e <printf>
      break;
  fc:	a00d                	j	11e <printsyscall+0x11e>
  switch(sid) {
  fe:	004007b7          	lui	a5,0x400
 102:	00f51863          	bne	a0,a5,112 <printsyscall+0x112>
    case 1<<21:
      printf("close");
      break;
    case 1<<22:
      printf("getSyscount");
 106:	00001517          	auipc	a0,0x1
 10a:	aba50513          	addi	a0,a0,-1350 # bc0 <malloc+0x1aa>
 10e:	051000ef          	jal	95e <printf>
    default:
      printf("Invalid system call");
 112:	00001517          	auipc	a0,0x1
 116:	abe50513          	addi	a0,a0,-1346 # bd0 <malloc+0x1ba>
 11a:	045000ef          	jal	95e <printf>
      break;
  }
}
 11e:	60a2                	ld	ra,8(sp)
 120:	6402                	ld	s0,0(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret
      printf("fork");
 126:	00001517          	auipc	a0,0x1
 12a:	9ea50513          	addi	a0,a0,-1558 # b10 <malloc+0xfa>
 12e:	031000ef          	jal	95e <printf>
      break;
 132:	b7f5                	j	11e <printsyscall+0x11e>
      printf("exit");
 134:	00001517          	auipc	a0,0x1
 138:	9ec50513          	addi	a0,a0,-1556 # b20 <malloc+0x10a>
 13c:	023000ef          	jal	95e <printf>
      break;
 140:	bff9                	j	11e <printsyscall+0x11e>
      printf("wait");
 142:	00001517          	auipc	a0,0x1
 146:	9e650513          	addi	a0,a0,-1562 # b28 <malloc+0x112>
 14a:	015000ef          	jal	95e <printf>
      break;
 14e:	bfc1                	j	11e <printsyscall+0x11e>
      printf("pipe");
 150:	00001517          	auipc	a0,0x1
 154:	9e050513          	addi	a0,a0,-1568 # b30 <malloc+0x11a>
 158:	007000ef          	jal	95e <printf>
      break;
 15c:	b7c9                	j	11e <printsyscall+0x11e>
      printf("read");
 15e:	00001517          	auipc	a0,0x1
 162:	9da50513          	addi	a0,a0,-1574 # b38 <malloc+0x122>
 166:	7f8000ef          	jal	95e <printf>
      break;
 16a:	bf55                	j	11e <printsyscall+0x11e>
      printf("kill");
 16c:	00001517          	auipc	a0,0x1
 170:	9d450513          	addi	a0,a0,-1580 # b40 <malloc+0x12a>
 174:	7ea000ef          	jal	95e <printf>
      break;
 178:	b75d                	j	11e <printsyscall+0x11e>
      printf("exec");
 17a:	00001517          	auipc	a0,0x1
 17e:	9ce50513          	addi	a0,a0,-1586 # b48 <malloc+0x132>
 182:	7dc000ef          	jal	95e <printf>
      break;
 186:	bf61                	j	11e <printsyscall+0x11e>
      printf("chdir");
 188:	00001517          	auipc	a0,0x1
 18c:	9d050513          	addi	a0,a0,-1584 # b58 <malloc+0x142>
 190:	7ce000ef          	jal	95e <printf>
      break;
 194:	b769                	j	11e <printsyscall+0x11e>
      printf("dup");
 196:	00001517          	auipc	a0,0x1
 19a:	9ca50513          	addi	a0,a0,-1590 # b60 <malloc+0x14a>
 19e:	7c0000ef          	jal	95e <printf>
      break;
 1a2:	bfb5                	j	11e <printsyscall+0x11e>
      printf("sbrk");
 1a4:	00001517          	auipc	a0,0x1
 1a8:	9cc50513          	addi	a0,a0,-1588 # b70 <malloc+0x15a>
 1ac:	7b2000ef          	jal	95e <printf>
      break;
 1b0:	b7bd                	j	11e <printsyscall+0x11e>
      printf("sleep");
 1b2:	00001517          	auipc	a0,0x1
 1b6:	9c650513          	addi	a0,a0,-1594 # b78 <malloc+0x162>
 1ba:	7a4000ef          	jal	95e <printf>
      break;
 1be:	b785                	j	11e <printsyscall+0x11e>
      printf("open");
 1c0:	00001517          	auipc	a0,0x1
 1c4:	9c850513          	addi	a0,a0,-1592 # b88 <malloc+0x172>
 1c8:	796000ef          	jal	95e <printf>
      break;
 1cc:	bf89                	j	11e <printsyscall+0x11e>
      printf("write");
 1ce:	00001517          	auipc	a0,0x1
 1d2:	9c250513          	addi	a0,a0,-1598 # b90 <malloc+0x17a>
 1d6:	788000ef          	jal	95e <printf>
      break;
 1da:	b791                	j	11e <printsyscall+0x11e>
      printf("unlink");
 1dc:	00001517          	auipc	a0,0x1
 1e0:	9c450513          	addi	a0,a0,-1596 # ba0 <malloc+0x18a>
 1e4:	77a000ef          	jal	95e <printf>
      break;
 1e8:	bf1d                	j	11e <printsyscall+0x11e>
      printf("link");
 1ea:	00001517          	auipc	a0,0x1
 1ee:	9be50513          	addi	a0,a0,-1602 # ba8 <malloc+0x192>
 1f2:	76c000ef          	jal	95e <printf>
      break;
 1f6:	b725                	j	11e <printsyscall+0x11e>
      printf("close");
 1f8:	00001517          	auipc	a0,0x1
 1fc:	9c050513          	addi	a0,a0,-1600 # bb8 <malloc+0x1a2>
 200:	75e000ef          	jal	95e <printf>
      break;
 204:	bf29                	j	11e <printsyscall+0x11e>

0000000000000206 <main>:

int
main(int argc, char *argv[])
{
 206:	7139                	addi	sp,sp,-64
 208:	fc06                	sd	ra,56(sp)
 20a:	f822                	sd	s0,48(sp)
 20c:	0080                	addi	s0,sp,64
  if(argc < 3){
 20e:	4789                	li	a5,2
 210:	00a7cf63          	blt	a5,a0,22e <main+0x28>
 214:	f426                	sd	s1,40(sp)
 216:	f04a                	sd	s2,32(sp)
 218:	ec4e                	sd	s3,24(sp)
    fprintf(2, "Usage: syscount <mask> command [args]\n");
 21a:	00001597          	auipc	a1,0x1
 21e:	9ce58593          	addi	a1,a1,-1586 # be8 <malloc+0x1d2>
 222:	853e                	mv	a0,a5
 224:	710000ef          	jal	934 <fprintf>
    exit(1);
 228:	4505                	li	a0,1
 22a:	32a000ef          	jal	554 <exit>
 22e:	f426                	sd	s1,40(sp)
 230:	f04a                	sd	s2,32(sp)
 232:	ec4e                	sd	s3,24(sp)
 234:	84ae                	mv	s1,a1
  }

  int mask = atoi(argv[1]);
 236:	6588                	ld	a0,8(a1)
 238:	21a000ef          	jal	452 <atoi>
 23c:	89aa                	mv	s3,a0
  
  int pid = fork();
 23e:	30e000ef          	jal	54c <fork>
 242:	892a                	mv	s2,a0
  if(pid < 0){
 244:	02054363          	bltz	a0,26a <main+0x64>
    fprintf(2, "fork failed\n");
    exit(1);
  }
  
  if(pid == 0){
 248:	e91d                	bnez	a0,27e <main+0x78>
    // Child process
    exec(argv[2], &argv[2]);
 24a:	01048593          	addi	a1,s1,16
 24e:	6888                	ld	a0,16(s1)
 250:	33c000ef          	jal	58c <exec>
    fprintf(2, "exec %s failed\n", argv[2]);
 254:	6890                	ld	a2,16(s1)
 256:	00001597          	auipc	a1,0x1
 25a:	9ca58593          	addi	a1,a1,-1590 # c20 <malloc+0x20a>
 25e:	4509                	li	a0,2
 260:	6d4000ef          	jal	934 <fprintf>
    exit(1);
 264:	4505                	li	a0,1
 266:	2ee000ef          	jal	554 <exit>
    fprintf(2, "fork failed\n");
 26a:	00001597          	auipc	a1,0x1
 26e:	9a658593          	addi	a1,a1,-1626 # c10 <malloc+0x1fa>
 272:	4509                	li	a0,2
 274:	6c0000ef          	jal	934 <fprintf>
    exit(1);
 278:	4505                	li	a0,1
 27a:	2da000ef          	jal	554 <exit>
  } else {
    // Parent process
    int status;
    wait(&status);
 27e:	fcc40513          	addi	a0,s0,-52
 282:	2da000ef          	jal	55c <wait>
    int count = getsyscount(mask);
 286:	854e                	mv	a0,s3
 288:	36c000ef          	jal	5f4 <getsyscount>
 28c:	84aa                	mv	s1,a0
    
    printf("PID %d called ", pid);
 28e:	85ca                	mv	a1,s2
 290:	00001517          	auipc	a0,0x1
 294:	9a050513          	addi	a0,a0,-1632 # c30 <malloc+0x21a>
 298:	6c6000ef          	jal	95e <printf>
    //printf("%d",mask);
    printsyscall(mask);
 29c:	854e                	mv	a0,s3
 29e:	d63ff0ef          	jal	0 <printsyscall>
    printf(" %d times\n", count);
 2a2:	85a6                	mv	a1,s1
 2a4:	00001517          	auipc	a0,0x1
 2a8:	99c50513          	addi	a0,a0,-1636 # c40 <malloc+0x22a>
 2ac:	6b2000ef          	jal	95e <printf>
    exit(0);
 2b0:	4501                	li	a0,0
 2b2:	2a2000ef          	jal	554 <exit>

00000000000002b6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e406                	sd	ra,8(sp)
 2ba:	e022                	sd	s0,0(sp)
 2bc:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2be:	f49ff0ef          	jal	206 <main>
  exit(0);
 2c2:	4501                	li	a0,0
 2c4:	290000ef          	jal	554 <exit>

00000000000002c8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2d0:	87aa                	mv	a5,a0
 2d2:	0585                	addi	a1,a1,1
 2d4:	0785                	addi	a5,a5,1 # 400001 <base+0x3fdff1>
 2d6:	fff5c703          	lbu	a4,-1(a1)
 2da:	fee78fa3          	sb	a4,-1(a5)
 2de:	fb75                	bnez	a4,2d2 <strcpy+0xa>
    ;
  return os;
}
 2e0:	60a2                	ld	ra,8(sp)
 2e2:	6402                	ld	s0,0(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret

00000000000002e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	cb91                	beqz	a5,308 <strcmp+0x20>
 2f6:	0005c703          	lbu	a4,0(a1)
 2fa:	00f71763          	bne	a4,a5,308 <strcmp+0x20>
    p++, q++;
 2fe:	0505                	addi	a0,a0,1
 300:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 302:	00054783          	lbu	a5,0(a0)
 306:	fbe5                	bnez	a5,2f6 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 308:	0005c503          	lbu	a0,0(a1)
}
 30c:	40a7853b          	subw	a0,a5,a0
 310:	60a2                	ld	ra,8(sp)
 312:	6402                	ld	s0,0(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret

0000000000000318 <strlen>:

uint
strlen(const char *s)
{
 318:	1141                	addi	sp,sp,-16
 31a:	e406                	sd	ra,8(sp)
 31c:	e022                	sd	s0,0(sp)
 31e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 320:	00054783          	lbu	a5,0(a0)
 324:	cf99                	beqz	a5,342 <strlen+0x2a>
 326:	0505                	addi	a0,a0,1
 328:	87aa                	mv	a5,a0
 32a:	86be                	mv	a3,a5
 32c:	0785                	addi	a5,a5,1
 32e:	fff7c703          	lbu	a4,-1(a5)
 332:	ff65                	bnez	a4,32a <strlen+0x12>
 334:	40a6853b          	subw	a0,a3,a0
 338:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 33a:	60a2                	ld	ra,8(sp)
 33c:	6402                	ld	s0,0(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  for(n = 0; s[n]; n++)
 342:	4501                	li	a0,0
 344:	bfdd                	j	33a <strlen+0x22>

0000000000000346 <memset>:

void*
memset(void *dst, int c, uint n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 34e:	ca19                	beqz	a2,364 <memset+0x1e>
 350:	87aa                	mv	a5,a0
 352:	1602                	slli	a2,a2,0x20
 354:	9201                	srli	a2,a2,0x20
 356:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 35a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 35e:	0785                	addi	a5,a5,1
 360:	fee79de3          	bne	a5,a4,35a <memset+0x14>
  }
  return dst;
}
 364:	60a2                	ld	ra,8(sp)
 366:	6402                	ld	s0,0(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <strchr>:

char*
strchr(const char *s, char c)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e406                	sd	ra,8(sp)
 370:	e022                	sd	s0,0(sp)
 372:	0800                	addi	s0,sp,16
  for(; *s; s++)
 374:	00054783          	lbu	a5,0(a0)
 378:	cf81                	beqz	a5,390 <strchr+0x24>
    if(*s == c)
 37a:	00f58763          	beq	a1,a5,388 <strchr+0x1c>
  for(; *s; s++)
 37e:	0505                	addi	a0,a0,1
 380:	00054783          	lbu	a5,0(a0)
 384:	fbfd                	bnez	a5,37a <strchr+0xe>
      return (char*)s;
  return 0;
 386:	4501                	li	a0,0
}
 388:	60a2                	ld	ra,8(sp)
 38a:	6402                	ld	s0,0(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret
  return 0;
 390:	4501                	li	a0,0
 392:	bfdd                	j	388 <strchr+0x1c>

0000000000000394 <gets>:

char*
gets(char *buf, int max)
{
 394:	7159                	addi	sp,sp,-112
 396:	f486                	sd	ra,104(sp)
 398:	f0a2                	sd	s0,96(sp)
 39a:	eca6                	sd	s1,88(sp)
 39c:	e8ca                	sd	s2,80(sp)
 39e:	e4ce                	sd	s3,72(sp)
 3a0:	e0d2                	sd	s4,64(sp)
 3a2:	fc56                	sd	s5,56(sp)
 3a4:	f85a                	sd	s6,48(sp)
 3a6:	f45e                	sd	s7,40(sp)
 3a8:	f062                	sd	s8,32(sp)
 3aa:	ec66                	sd	s9,24(sp)
 3ac:	e86a                	sd	s10,16(sp)
 3ae:	1880                	addi	s0,sp,112
 3b0:	8caa                	mv	s9,a0
 3b2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b4:	892a                	mv	s2,a0
 3b6:	4481                	li	s1,0
    cc = read(0, &c, 1);
 3b8:	f9f40b13          	addi	s6,s0,-97
 3bc:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3be:	4ba9                	li	s7,10
 3c0:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 3c2:	8d26                	mv	s10,s1
 3c4:	0014899b          	addiw	s3,s1,1
 3c8:	84ce                	mv	s1,s3
 3ca:	0349d563          	bge	s3,s4,3f4 <gets+0x60>
    cc = read(0, &c, 1);
 3ce:	8656                	mv	a2,s5
 3d0:	85da                	mv	a1,s6
 3d2:	4501                	li	a0,0
 3d4:	198000ef          	jal	56c <read>
    if(cc < 1)
 3d8:	00a05e63          	blez	a0,3f4 <gets+0x60>
    buf[i++] = c;
 3dc:	f9f44783          	lbu	a5,-97(s0)
 3e0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3e4:	01778763          	beq	a5,s7,3f2 <gets+0x5e>
 3e8:	0905                	addi	s2,s2,1
 3ea:	fd879ce3          	bne	a5,s8,3c2 <gets+0x2e>
    buf[i++] = c;
 3ee:	8d4e                	mv	s10,s3
 3f0:	a011                	j	3f4 <gets+0x60>
 3f2:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 3f4:	9d66                	add	s10,s10,s9
 3f6:	000d0023          	sb	zero,0(s10)
  return buf;
}
 3fa:	8566                	mv	a0,s9
 3fc:	70a6                	ld	ra,104(sp)
 3fe:	7406                	ld	s0,96(sp)
 400:	64e6                	ld	s1,88(sp)
 402:	6946                	ld	s2,80(sp)
 404:	69a6                	ld	s3,72(sp)
 406:	6a06                	ld	s4,64(sp)
 408:	7ae2                	ld	s5,56(sp)
 40a:	7b42                	ld	s6,48(sp)
 40c:	7ba2                	ld	s7,40(sp)
 40e:	7c02                	ld	s8,32(sp)
 410:	6ce2                	ld	s9,24(sp)
 412:	6d42                	ld	s10,16(sp)
 414:	6165                	addi	sp,sp,112
 416:	8082                	ret

0000000000000418 <stat>:

int
stat(const char *n, struct stat *st)
{
 418:	1101                	addi	sp,sp,-32
 41a:	ec06                	sd	ra,24(sp)
 41c:	e822                	sd	s0,16(sp)
 41e:	e04a                	sd	s2,0(sp)
 420:	1000                	addi	s0,sp,32
 422:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 424:	4581                	li	a1,0
 426:	16e000ef          	jal	594 <open>
  if(fd < 0)
 42a:	02054263          	bltz	a0,44e <stat+0x36>
 42e:	e426                	sd	s1,8(sp)
 430:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 432:	85ca                	mv	a1,s2
 434:	178000ef          	jal	5ac <fstat>
 438:	892a                	mv	s2,a0
  close(fd);
 43a:	8526                	mv	a0,s1
 43c:	140000ef          	jal	57c <close>
  return r;
 440:	64a2                	ld	s1,8(sp)
}
 442:	854a                	mv	a0,s2
 444:	60e2                	ld	ra,24(sp)
 446:	6442                	ld	s0,16(sp)
 448:	6902                	ld	s2,0(sp)
 44a:	6105                	addi	sp,sp,32
 44c:	8082                	ret
    return -1;
 44e:	597d                	li	s2,-1
 450:	bfcd                	j	442 <stat+0x2a>

0000000000000452 <atoi>:

int
atoi(const char *s)
{
 452:	1141                	addi	sp,sp,-16
 454:	e406                	sd	ra,8(sp)
 456:	e022                	sd	s0,0(sp)
 458:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 45a:	00054683          	lbu	a3,0(a0)
 45e:	fd06879b          	addiw	a5,a3,-48
 462:	0ff7f793          	zext.b	a5,a5
 466:	4625                	li	a2,9
 468:	02f66963          	bltu	a2,a5,49a <atoi+0x48>
 46c:	872a                	mv	a4,a0
  n = 0;
 46e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 470:	0705                	addi	a4,a4,1
 472:	0025179b          	slliw	a5,a0,0x2
 476:	9fa9                	addw	a5,a5,a0
 478:	0017979b          	slliw	a5,a5,0x1
 47c:	9fb5                	addw	a5,a5,a3
 47e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 482:	00074683          	lbu	a3,0(a4)
 486:	fd06879b          	addiw	a5,a3,-48
 48a:	0ff7f793          	zext.b	a5,a5
 48e:	fef671e3          	bgeu	a2,a5,470 <atoi+0x1e>
  return n;
}
 492:	60a2                	ld	ra,8(sp)
 494:	6402                	ld	s0,0(sp)
 496:	0141                	addi	sp,sp,16
 498:	8082                	ret
  n = 0;
 49a:	4501                	li	a0,0
 49c:	bfdd                	j	492 <atoi+0x40>

000000000000049e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 49e:	1141                	addi	sp,sp,-16
 4a0:	e406                	sd	ra,8(sp)
 4a2:	e022                	sd	s0,0(sp)
 4a4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4a6:	02b57563          	bgeu	a0,a1,4d0 <memmove+0x32>
    while(n-- > 0)
 4aa:	00c05f63          	blez	a2,4c8 <memmove+0x2a>
 4ae:	1602                	slli	a2,a2,0x20
 4b0:	9201                	srli	a2,a2,0x20
 4b2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4b6:	872a                	mv	a4,a0
      *dst++ = *src++;
 4b8:	0585                	addi	a1,a1,1
 4ba:	0705                	addi	a4,a4,1
 4bc:	fff5c683          	lbu	a3,-1(a1)
 4c0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4c4:	fee79ae3          	bne	a5,a4,4b8 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4c8:	60a2                	ld	ra,8(sp)
 4ca:	6402                	ld	s0,0(sp)
 4cc:	0141                	addi	sp,sp,16
 4ce:	8082                	ret
    dst += n;
 4d0:	00c50733          	add	a4,a0,a2
    src += n;
 4d4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4d6:	fec059e3          	blez	a2,4c8 <memmove+0x2a>
 4da:	fff6079b          	addiw	a5,a2,-1
 4de:	1782                	slli	a5,a5,0x20
 4e0:	9381                	srli	a5,a5,0x20
 4e2:	fff7c793          	not	a5,a5
 4e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4e8:	15fd                	addi	a1,a1,-1
 4ea:	177d                	addi	a4,a4,-1
 4ec:	0005c683          	lbu	a3,0(a1)
 4f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4f4:	fef71ae3          	bne	a4,a5,4e8 <memmove+0x4a>
 4f8:	bfc1                	j	4c8 <memmove+0x2a>

00000000000004fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4fa:	1141                	addi	sp,sp,-16
 4fc:	e406                	sd	ra,8(sp)
 4fe:	e022                	sd	s0,0(sp)
 500:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 502:	ca0d                	beqz	a2,534 <memcmp+0x3a>
 504:	fff6069b          	addiw	a3,a2,-1
 508:	1682                	slli	a3,a3,0x20
 50a:	9281                	srli	a3,a3,0x20
 50c:	0685                	addi	a3,a3,1
 50e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 510:	00054783          	lbu	a5,0(a0)
 514:	0005c703          	lbu	a4,0(a1)
 518:	00e79863          	bne	a5,a4,528 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 51c:	0505                	addi	a0,a0,1
    p2++;
 51e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 520:	fed518e3          	bne	a0,a3,510 <memcmp+0x16>
  }
  return 0;
 524:	4501                	li	a0,0
 526:	a019                	j	52c <memcmp+0x32>
      return *p1 - *p2;
 528:	40e7853b          	subw	a0,a5,a4
}
 52c:	60a2                	ld	ra,8(sp)
 52e:	6402                	ld	s0,0(sp)
 530:	0141                	addi	sp,sp,16
 532:	8082                	ret
  return 0;
 534:	4501                	li	a0,0
 536:	bfdd                	j	52c <memcmp+0x32>

0000000000000538 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 538:	1141                	addi	sp,sp,-16
 53a:	e406                	sd	ra,8(sp)
 53c:	e022                	sd	s0,0(sp)
 53e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 540:	f5fff0ef          	jal	49e <memmove>
}
 544:	60a2                	ld	ra,8(sp)
 546:	6402                	ld	s0,0(sp)
 548:	0141                	addi	sp,sp,16
 54a:	8082                	ret

000000000000054c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 54c:	4885                	li	a7,1
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <exit>:
.global exit
exit:
 li a7, SYS_exit
 554:	4889                	li	a7,2
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <wait>:
.global wait
wait:
 li a7, SYS_wait
 55c:	488d                	li	a7,3
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 564:	4891                	li	a7,4
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <read>:
.global read
read:
 li a7, SYS_read
 56c:	4895                	li	a7,5
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <write>:
.global write
write:
 li a7, SYS_write
 574:	48c1                	li	a7,16
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <close>:
.global close
close:
 li a7, SYS_close
 57c:	48d5                	li	a7,21
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <kill>:
.global kill
kill:
 li a7, SYS_kill
 584:	4899                	li	a7,6
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <exec>:
.global exec
exec:
 li a7, SYS_exec
 58c:	489d                	li	a7,7
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <open>:
.global open
open:
 li a7, SYS_open
 594:	48bd                	li	a7,15
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 59c:	48c5                	li	a7,17
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5a4:	48c9                	li	a7,18
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5ac:	48a1                	li	a7,8
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <link>:
.global link
link:
 li a7, SYS_link
 5b4:	48cd                	li	a7,19
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5bc:	48d1                	li	a7,20
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5c4:	48a5                	li	a7,9
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <dup>:
.global dup
dup:
 li a7, SYS_dup
 5cc:	48a9                	li	a7,10
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5d4:	48ad                	li	a7,11
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5dc:	48b1                	li	a7,12
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5e4:	48b5                	li	a7,13
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5ec:	48b9                	li	a7,14
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 5f4:	48d9                	li	a7,22
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5fc:	1101                	addi	sp,sp,-32
 5fe:	ec06                	sd	ra,24(sp)
 600:	e822                	sd	s0,16(sp)
 602:	1000                	addi	s0,sp,32
 604:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 608:	4605                	li	a2,1
 60a:	fef40593          	addi	a1,s0,-17
 60e:	f67ff0ef          	jal	574 <write>
}
 612:	60e2                	ld	ra,24(sp)
 614:	6442                	ld	s0,16(sp)
 616:	6105                	addi	sp,sp,32
 618:	8082                	ret

000000000000061a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 61a:	7139                	addi	sp,sp,-64
 61c:	fc06                	sd	ra,56(sp)
 61e:	f822                	sd	s0,48(sp)
 620:	f426                	sd	s1,40(sp)
 622:	f04a                	sd	s2,32(sp)
 624:	ec4e                	sd	s3,24(sp)
 626:	0080                	addi	s0,sp,64
 628:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 62a:	c299                	beqz	a3,630 <printint+0x16>
 62c:	0605ce63          	bltz	a1,6a8 <printint+0x8e>
  neg = 0;
 630:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 632:	fc040313          	addi	t1,s0,-64
  neg = 0;
 636:	869a                	mv	a3,t1
  i = 0;
 638:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 63a:	00000817          	auipc	a6,0x0
 63e:	6a680813          	addi	a6,a6,1702 # ce0 <digits>
 642:	88be                	mv	a7,a5
 644:	0017851b          	addiw	a0,a5,1
 648:	87aa                	mv	a5,a0
 64a:	02c5f73b          	remuw	a4,a1,a2
 64e:	1702                	slli	a4,a4,0x20
 650:	9301                	srli	a4,a4,0x20
 652:	9742                	add	a4,a4,a6
 654:	00074703          	lbu	a4,0(a4)
 658:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 65c:	872e                	mv	a4,a1
 65e:	02c5d5bb          	divuw	a1,a1,a2
 662:	0685                	addi	a3,a3,1
 664:	fcc77fe3          	bgeu	a4,a2,642 <printint+0x28>
  if(neg)
 668:	000e0c63          	beqz	t3,680 <printint+0x66>
    buf[i++] = '-';
 66c:	fd050793          	addi	a5,a0,-48
 670:	00878533          	add	a0,a5,s0
 674:	02d00793          	li	a5,45
 678:	fef50823          	sb	a5,-16(a0)
 67c:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 680:	fff7899b          	addiw	s3,a5,-1
 684:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 688:	fff4c583          	lbu	a1,-1(s1)
 68c:	854a                	mv	a0,s2
 68e:	f6fff0ef          	jal	5fc <putc>
  while(--i >= 0)
 692:	39fd                	addiw	s3,s3,-1
 694:	14fd                	addi	s1,s1,-1
 696:	fe09d9e3          	bgez	s3,688 <printint+0x6e>
}
 69a:	70e2                	ld	ra,56(sp)
 69c:	7442                	ld	s0,48(sp)
 69e:	74a2                	ld	s1,40(sp)
 6a0:	7902                	ld	s2,32(sp)
 6a2:	69e2                	ld	s3,24(sp)
 6a4:	6121                	addi	sp,sp,64
 6a6:	8082                	ret
    x = -xx;
 6a8:	40b005bb          	negw	a1,a1
    neg = 1;
 6ac:	4e05                	li	t3,1
    x = -xx;
 6ae:	b751                	j	632 <printint+0x18>

00000000000006b0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6b0:	711d                	addi	sp,sp,-96
 6b2:	ec86                	sd	ra,88(sp)
 6b4:	e8a2                	sd	s0,80(sp)
 6b6:	e4a6                	sd	s1,72(sp)
 6b8:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6ba:	0005c483          	lbu	s1,0(a1)
 6be:	26048663          	beqz	s1,92a <vprintf+0x27a>
 6c2:	e0ca                	sd	s2,64(sp)
 6c4:	fc4e                	sd	s3,56(sp)
 6c6:	f852                	sd	s4,48(sp)
 6c8:	f456                	sd	s5,40(sp)
 6ca:	f05a                	sd	s6,32(sp)
 6cc:	ec5e                	sd	s7,24(sp)
 6ce:	e862                	sd	s8,16(sp)
 6d0:	e466                	sd	s9,8(sp)
 6d2:	8b2a                	mv	s6,a0
 6d4:	8a2e                	mv	s4,a1
 6d6:	8bb2                	mv	s7,a2
  state = 0;
 6d8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6da:	4901                	li	s2,0
 6dc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6de:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6e2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6e6:	06c00c93          	li	s9,108
 6ea:	a00d                	j	70c <vprintf+0x5c>
        putc(fd, c0);
 6ec:	85a6                	mv	a1,s1
 6ee:	855a                	mv	a0,s6
 6f0:	f0dff0ef          	jal	5fc <putc>
 6f4:	a019                	j	6fa <vprintf+0x4a>
    } else if(state == '%'){
 6f6:	03598363          	beq	s3,s5,71c <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 6fa:	0019079b          	addiw	a5,s2,1
 6fe:	893e                	mv	s2,a5
 700:	873e                	mv	a4,a5
 702:	97d2                	add	a5,a5,s4
 704:	0007c483          	lbu	s1,0(a5)
 708:	20048963          	beqz	s1,91a <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 70c:	0004879b          	sext.w	a5,s1
    if(state == 0){
 710:	fe0993e3          	bnez	s3,6f6 <vprintf+0x46>
      if(c0 == '%'){
 714:	fd579ce3          	bne	a5,s5,6ec <vprintf+0x3c>
        state = '%';
 718:	89be                	mv	s3,a5
 71a:	b7c5                	j	6fa <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 71c:	00ea06b3          	add	a3,s4,a4
 720:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 724:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 726:	c681                	beqz	a3,72e <vprintf+0x7e>
 728:	9752                	add	a4,a4,s4
 72a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 72e:	03878e63          	beq	a5,s8,76a <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 732:	05978863          	beq	a5,s9,782 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 736:	07500713          	li	a4,117
 73a:	0ee78263          	beq	a5,a4,81e <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 73e:	07800713          	li	a4,120
 742:	12e78463          	beq	a5,a4,86a <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 746:	07000713          	li	a4,112
 74a:	14e78963          	beq	a5,a4,89c <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 74e:	07300713          	li	a4,115
 752:	18e78863          	beq	a5,a4,8e2 <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 756:	02500713          	li	a4,37
 75a:	04e79463          	bne	a5,a4,7a2 <vprintf+0xf2>
        putc(fd, '%');
 75e:	85ba                	mv	a1,a4
 760:	855a                	mv	a0,s6
 762:	e9bff0ef          	jal	5fc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 766:	4981                	li	s3,0
 768:	bf49                	j	6fa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 76a:	008b8493          	addi	s1,s7,8
 76e:	4685                	li	a3,1
 770:	4629                	li	a2,10
 772:	000ba583          	lw	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	ea3ff0ef          	jal	61a <printint>
 77c:	8ba6                	mv	s7,s1
      state = 0;
 77e:	4981                	li	s3,0
 780:	bfad                	j	6fa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 782:	06400793          	li	a5,100
 786:	02f68963          	beq	a3,a5,7b8 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 78a:	06c00793          	li	a5,108
 78e:	04f68263          	beq	a3,a5,7d2 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 792:	07500793          	li	a5,117
 796:	0af68063          	beq	a3,a5,836 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 79a:	07800793          	li	a5,120
 79e:	0ef68263          	beq	a3,a5,882 <vprintf+0x1d2>
        putc(fd, '%');
 7a2:	02500593          	li	a1,37
 7a6:	855a                	mv	a0,s6
 7a8:	e55ff0ef          	jal	5fc <putc>
        putc(fd, c0);
 7ac:	85a6                	mv	a1,s1
 7ae:	855a                	mv	a0,s6
 7b0:	e4dff0ef          	jal	5fc <putc>
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	b791                	j	6fa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7b8:	008b8493          	addi	s1,s7,8
 7bc:	4685                	li	a3,1
 7be:	4629                	li	a2,10
 7c0:	000ba583          	lw	a1,0(s7)
 7c4:	855a                	mv	a0,s6
 7c6:	e55ff0ef          	jal	61a <printint>
        i += 1;
 7ca:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7cc:	8ba6                	mv	s7,s1
      state = 0;
 7ce:	4981                	li	s3,0
        i += 1;
 7d0:	b72d                	j	6fa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7d2:	06400793          	li	a5,100
 7d6:	02f60763          	beq	a2,a5,804 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7da:	07500793          	li	a5,117
 7de:	06f60963          	beq	a2,a5,850 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7e2:	07800793          	li	a5,120
 7e6:	faf61ee3          	bne	a2,a5,7a2 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ea:	008b8493          	addi	s1,s7,8
 7ee:	4681                	li	a3,0
 7f0:	4641                	li	a2,16
 7f2:	000ba583          	lw	a1,0(s7)
 7f6:	855a                	mv	a0,s6
 7f8:	e23ff0ef          	jal	61a <printint>
        i += 2;
 7fc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7fe:	8ba6                	mv	s7,s1
      state = 0;
 800:	4981                	li	s3,0
        i += 2;
 802:	bde5                	j	6fa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 804:	008b8493          	addi	s1,s7,8
 808:	4685                	li	a3,1
 80a:	4629                	li	a2,10
 80c:	000ba583          	lw	a1,0(s7)
 810:	855a                	mv	a0,s6
 812:	e09ff0ef          	jal	61a <printint>
        i += 2;
 816:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 818:	8ba6                	mv	s7,s1
      state = 0;
 81a:	4981                	li	s3,0
        i += 2;
 81c:	bdf9                	j	6fa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 81e:	008b8493          	addi	s1,s7,8
 822:	4681                	li	a3,0
 824:	4629                	li	a2,10
 826:	000ba583          	lw	a1,0(s7)
 82a:	855a                	mv	a0,s6
 82c:	defff0ef          	jal	61a <printint>
 830:	8ba6                	mv	s7,s1
      state = 0;
 832:	4981                	li	s3,0
 834:	b5d9                	j	6fa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 836:	008b8493          	addi	s1,s7,8
 83a:	4681                	li	a3,0
 83c:	4629                	li	a2,10
 83e:	000ba583          	lw	a1,0(s7)
 842:	855a                	mv	a0,s6
 844:	dd7ff0ef          	jal	61a <printint>
        i += 1;
 848:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 84a:	8ba6                	mv	s7,s1
      state = 0;
 84c:	4981                	li	s3,0
        i += 1;
 84e:	b575                	j	6fa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 850:	008b8493          	addi	s1,s7,8
 854:	4681                	li	a3,0
 856:	4629                	li	a2,10
 858:	000ba583          	lw	a1,0(s7)
 85c:	855a                	mv	a0,s6
 85e:	dbdff0ef          	jal	61a <printint>
        i += 2;
 862:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 864:	8ba6                	mv	s7,s1
      state = 0;
 866:	4981                	li	s3,0
        i += 2;
 868:	bd49                	j	6fa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 86a:	008b8493          	addi	s1,s7,8
 86e:	4681                	li	a3,0
 870:	4641                	li	a2,16
 872:	000ba583          	lw	a1,0(s7)
 876:	855a                	mv	a0,s6
 878:	da3ff0ef          	jal	61a <printint>
 87c:	8ba6                	mv	s7,s1
      state = 0;
 87e:	4981                	li	s3,0
 880:	bdad                	j	6fa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 882:	008b8493          	addi	s1,s7,8
 886:	4681                	li	a3,0
 888:	4641                	li	a2,16
 88a:	000ba583          	lw	a1,0(s7)
 88e:	855a                	mv	a0,s6
 890:	d8bff0ef          	jal	61a <printint>
        i += 1;
 894:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 896:	8ba6                	mv	s7,s1
      state = 0;
 898:	4981                	li	s3,0
        i += 1;
 89a:	b585                	j	6fa <vprintf+0x4a>
 89c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 89e:	008b8d13          	addi	s10,s7,8
 8a2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8a6:	03000593          	li	a1,48
 8aa:	855a                	mv	a0,s6
 8ac:	d51ff0ef          	jal	5fc <putc>
  putc(fd, 'x');
 8b0:	07800593          	li	a1,120
 8b4:	855a                	mv	a0,s6
 8b6:	d47ff0ef          	jal	5fc <putc>
 8ba:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8bc:	00000b97          	auipc	s7,0x0
 8c0:	424b8b93          	addi	s7,s7,1060 # ce0 <digits>
 8c4:	03c9d793          	srli	a5,s3,0x3c
 8c8:	97de                	add	a5,a5,s7
 8ca:	0007c583          	lbu	a1,0(a5)
 8ce:	855a                	mv	a0,s6
 8d0:	d2dff0ef          	jal	5fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8d4:	0992                	slli	s3,s3,0x4
 8d6:	34fd                	addiw	s1,s1,-1
 8d8:	f4f5                	bnez	s1,8c4 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 8da:	8bea                	mv	s7,s10
      state = 0;
 8dc:	4981                	li	s3,0
 8de:	6d02                	ld	s10,0(sp)
 8e0:	bd29                	j	6fa <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8e2:	008b8993          	addi	s3,s7,8
 8e6:	000bb483          	ld	s1,0(s7)
 8ea:	cc91                	beqz	s1,906 <vprintf+0x256>
        for(; *s; s++)
 8ec:	0004c583          	lbu	a1,0(s1)
 8f0:	c195                	beqz	a1,914 <vprintf+0x264>
          putc(fd, *s);
 8f2:	855a                	mv	a0,s6
 8f4:	d09ff0ef          	jal	5fc <putc>
        for(; *s; s++)
 8f8:	0485                	addi	s1,s1,1
 8fa:	0004c583          	lbu	a1,0(s1)
 8fe:	f9f5                	bnez	a1,8f2 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 900:	8bce                	mv	s7,s3
      state = 0;
 902:	4981                	li	s3,0
 904:	bbdd                	j	6fa <vprintf+0x4a>
          s = "(null)";
 906:	00000497          	auipc	s1,0x0
 90a:	34a48493          	addi	s1,s1,842 # c50 <malloc+0x23a>
        for(; *s; s++)
 90e:	02800593          	li	a1,40
 912:	b7c5                	j	8f2 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 914:	8bce                	mv	s7,s3
      state = 0;
 916:	4981                	li	s3,0
 918:	b3cd                	j	6fa <vprintf+0x4a>
 91a:	6906                	ld	s2,64(sp)
 91c:	79e2                	ld	s3,56(sp)
 91e:	7a42                	ld	s4,48(sp)
 920:	7aa2                	ld	s5,40(sp)
 922:	7b02                	ld	s6,32(sp)
 924:	6be2                	ld	s7,24(sp)
 926:	6c42                	ld	s8,16(sp)
 928:	6ca2                	ld	s9,8(sp)
    }
  }
}
 92a:	60e6                	ld	ra,88(sp)
 92c:	6446                	ld	s0,80(sp)
 92e:	64a6                	ld	s1,72(sp)
 930:	6125                	addi	sp,sp,96
 932:	8082                	ret

0000000000000934 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 934:	715d                	addi	sp,sp,-80
 936:	ec06                	sd	ra,24(sp)
 938:	e822                	sd	s0,16(sp)
 93a:	1000                	addi	s0,sp,32
 93c:	e010                	sd	a2,0(s0)
 93e:	e414                	sd	a3,8(s0)
 940:	e818                	sd	a4,16(s0)
 942:	ec1c                	sd	a5,24(s0)
 944:	03043023          	sd	a6,32(s0)
 948:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 94c:	8622                	mv	a2,s0
 94e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 952:	d5fff0ef          	jal	6b0 <vprintf>
}
 956:	60e2                	ld	ra,24(sp)
 958:	6442                	ld	s0,16(sp)
 95a:	6161                	addi	sp,sp,80
 95c:	8082                	ret

000000000000095e <printf>:

void
printf(const char *fmt, ...)
{
 95e:	711d                	addi	sp,sp,-96
 960:	ec06                	sd	ra,24(sp)
 962:	e822                	sd	s0,16(sp)
 964:	1000                	addi	s0,sp,32
 966:	e40c                	sd	a1,8(s0)
 968:	e810                	sd	a2,16(s0)
 96a:	ec14                	sd	a3,24(s0)
 96c:	f018                	sd	a4,32(s0)
 96e:	f41c                	sd	a5,40(s0)
 970:	03043823          	sd	a6,48(s0)
 974:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 978:	00840613          	addi	a2,s0,8
 97c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 980:	85aa                	mv	a1,a0
 982:	4505                	li	a0,1
 984:	d2dff0ef          	jal	6b0 <vprintf>
}
 988:	60e2                	ld	ra,24(sp)
 98a:	6442                	ld	s0,16(sp)
 98c:	6125                	addi	sp,sp,96
 98e:	8082                	ret

0000000000000990 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 990:	1141                	addi	sp,sp,-16
 992:	e406                	sd	ra,8(sp)
 994:	e022                	sd	s0,0(sp)
 996:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 998:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99c:	00001797          	auipc	a5,0x1
 9a0:	6647b783          	ld	a5,1636(a5) # 2000 <freep>
 9a4:	a02d                	j	9ce <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9a6:	4618                	lw	a4,8(a2)
 9a8:	9f2d                	addw	a4,a4,a1
 9aa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ae:	6398                	ld	a4,0(a5)
 9b0:	6310                	ld	a2,0(a4)
 9b2:	a83d                	j	9f0 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9b4:	ff852703          	lw	a4,-8(a0)
 9b8:	9f31                	addw	a4,a4,a2
 9ba:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9bc:	ff053683          	ld	a3,-16(a0)
 9c0:	a091                	j	a04 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c2:	6398                	ld	a4,0(a5)
 9c4:	00e7e463          	bltu	a5,a4,9cc <free+0x3c>
 9c8:	00e6ea63          	bltu	a3,a4,9dc <free+0x4c>
{
 9cc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ce:	fed7fae3          	bgeu	a5,a3,9c2 <free+0x32>
 9d2:	6398                	ld	a4,0(a5)
 9d4:	00e6e463          	bltu	a3,a4,9dc <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9d8:	fee7eae3          	bltu	a5,a4,9cc <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 9dc:	ff852583          	lw	a1,-8(a0)
 9e0:	6390                	ld	a2,0(a5)
 9e2:	02059813          	slli	a6,a1,0x20
 9e6:	01c85713          	srli	a4,a6,0x1c
 9ea:	9736                	add	a4,a4,a3
 9ec:	fae60de3          	beq	a2,a4,9a6 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 9f0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9f4:	4790                	lw	a2,8(a5)
 9f6:	02061593          	slli	a1,a2,0x20
 9fa:	01c5d713          	srli	a4,a1,0x1c
 9fe:	973e                	add	a4,a4,a5
 a00:	fae68ae3          	beq	a3,a4,9b4 <free+0x24>
    p->s.ptr = bp->s.ptr;
 a04:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a06:	00001717          	auipc	a4,0x1
 a0a:	5ef73d23          	sd	a5,1530(a4) # 2000 <freep>
}
 a0e:	60a2                	ld	ra,8(sp)
 a10:	6402                	ld	s0,0(sp)
 a12:	0141                	addi	sp,sp,16
 a14:	8082                	ret

0000000000000a16 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a16:	7139                	addi	sp,sp,-64
 a18:	fc06                	sd	ra,56(sp)
 a1a:	f822                	sd	s0,48(sp)
 a1c:	f04a                	sd	s2,32(sp)
 a1e:	ec4e                	sd	s3,24(sp)
 a20:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a22:	02051993          	slli	s3,a0,0x20
 a26:	0209d993          	srli	s3,s3,0x20
 a2a:	09bd                	addi	s3,s3,15
 a2c:	0049d993          	srli	s3,s3,0x4
 a30:	2985                	addiw	s3,s3,1
 a32:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 a34:	00001517          	auipc	a0,0x1
 a38:	5cc53503          	ld	a0,1484(a0) # 2000 <freep>
 a3c:	c905                	beqz	a0,a6c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a40:	4798                	lw	a4,8(a5)
 a42:	09377663          	bgeu	a4,s3,ace <malloc+0xb8>
 a46:	f426                	sd	s1,40(sp)
 a48:	e852                	sd	s4,16(sp)
 a4a:	e456                	sd	s5,8(sp)
 a4c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a4e:	8a4e                	mv	s4,s3
 a50:	6705                	lui	a4,0x1
 a52:	00e9f363          	bgeu	s3,a4,a58 <malloc+0x42>
 a56:	6a05                	lui	s4,0x1
 a58:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a5c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a60:	00001497          	auipc	s1,0x1
 a64:	5a048493          	addi	s1,s1,1440 # 2000 <freep>
  if(p == (char*)-1)
 a68:	5afd                	li	s5,-1
 a6a:	a83d                	j	aa8 <malloc+0x92>
 a6c:	f426                	sd	s1,40(sp)
 a6e:	e852                	sd	s4,16(sp)
 a70:	e456                	sd	s5,8(sp)
 a72:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a74:	00001797          	auipc	a5,0x1
 a78:	59c78793          	addi	a5,a5,1436 # 2010 <base>
 a7c:	00001717          	auipc	a4,0x1
 a80:	58f73223          	sd	a5,1412(a4) # 2000 <freep>
 a84:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a86:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a8a:	b7d1                	j	a4e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a8c:	6398                	ld	a4,0(a5)
 a8e:	e118                	sd	a4,0(a0)
 a90:	a899                	j	ae6 <malloc+0xd0>
  hp->s.size = nu;
 a92:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a96:	0541                	addi	a0,a0,16
 a98:	ef9ff0ef          	jal	990 <free>
  return freep;
 a9c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a9e:	c125                	beqz	a0,afe <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aa2:	4798                	lw	a4,8(a5)
 aa4:	03277163          	bgeu	a4,s2,ac6 <malloc+0xb0>
    if(p == freep)
 aa8:	6098                	ld	a4,0(s1)
 aaa:	853e                	mv	a0,a5
 aac:	fef71ae3          	bne	a4,a5,aa0 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 ab0:	8552                	mv	a0,s4
 ab2:	b2bff0ef          	jal	5dc <sbrk>
  if(p == (char*)-1)
 ab6:	fd551ee3          	bne	a0,s5,a92 <malloc+0x7c>
        return 0;
 aba:	4501                	li	a0,0
 abc:	74a2                	ld	s1,40(sp)
 abe:	6a42                	ld	s4,16(sp)
 ac0:	6aa2                	ld	s5,8(sp)
 ac2:	6b02                	ld	s6,0(sp)
 ac4:	a03d                	j	af2 <malloc+0xdc>
 ac6:	74a2                	ld	s1,40(sp)
 ac8:	6a42                	ld	s4,16(sp)
 aca:	6aa2                	ld	s5,8(sp)
 acc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ace:	fae90fe3          	beq	s2,a4,a8c <malloc+0x76>
        p->s.size -= nunits;
 ad2:	4137073b          	subw	a4,a4,s3
 ad6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ad8:	02071693          	slli	a3,a4,0x20
 adc:	01c6d713          	srli	a4,a3,0x1c
 ae0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ae2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ae6:	00001717          	auipc	a4,0x1
 aea:	50a73d23          	sd	a0,1306(a4) # 2000 <freep>
      return (void*)(p + 1);
 aee:	01078513          	addi	a0,a5,16
  }
}
 af2:	70e2                	ld	ra,56(sp)
 af4:	7442                	ld	s0,48(sp)
 af6:	7902                	ld	s2,32(sp)
 af8:	69e2                	ld	s3,24(sp)
 afa:	6121                	addi	sp,sp,64
 afc:	8082                	ret
 afe:	74a2                	ld	s1,40(sp)
 b00:	6a42                	ld	s4,16(sp)
 b02:	6aa2                	ld	s5,8(sp)
 b04:	6b02                	ld	s6,0(sp)
 b06:	b7f5                	j	af2 <malloc+0xdc>
