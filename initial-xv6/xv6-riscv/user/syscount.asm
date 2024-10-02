
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <printsyscall>:
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/number_syscall.h"


void printsyscall(int sid){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  switch(sid) {
   8:	6785                	lui	a5,0x1
   a:	18f50863          	beq	a0,a5,19a <printsyscall+0x19a>
   e:	06a7ce63          	blt	a5,a0,8a <printsyscall+0x8a>
  12:	04000793          	li	a5,64
  16:	14f50663          	beq	a0,a5,162 <printsyscall+0x162>
  1a:	02a7d763          	bge	a5,a0,48 <printsyscall+0x48>
  1e:	20000793          	li	a5,512
  22:	14f50e63          	beq	a0,a5,17e <printsyscall+0x17e>
  26:	04a7d363          	bge	a5,a0,6c <printsyscall+0x6c>
  2a:	40000793          	li	a5,1024
  2e:	14f50f63          	beq	a0,a5,18c <printsyscall+0x18c>
  32:	8005051b          	addiw	a0,a0,-2048
  36:	1c051363          	bnez	a0,1fc <printsyscall+0x1fc>
      break;
    case 1<<10:
      printf("dup");
      break;
    case 1<<11:
      printf("getpid");
  3a:	00001517          	auipc	a0,0x1
  3e:	b3e50513          	addi	a0,a0,-1218 # b78 <malloc+0x14a>
  42:	135000ef          	jal	976 <printf>
      break;
  46:	a8f1                	j	122 <printsyscall+0x122>
  switch(sid) {
  48:	ffe5079b          	addiw	a5,a0,-2
  4c:	4779                	li	a4,30
  4e:	1af76763          	bltu	a4,a5,1fc <printsyscall+0x1fc>
  52:	02000793          	li	a5,32
  56:	1aa7e363          	bltu	a5,a0,1fc <printsyscall+0x1fc>
  5a:	050a                	slli	a0,a0,0x2
  5c:	00001717          	auipc	a4,0x1
  60:	c0c70713          	addi	a4,a4,-1012 # c68 <malloc+0x23a>
  64:	953a                	add	a0,a0,a4
  66:	411c                	lw	a5,0(a0)
  68:	97ba                	add	a5,a5,a4
  6a:	8782                	jr	a5
  6c:	08000793          	li	a5,128
  70:	10f50063          	beq	a0,a5,170 <printsyscall+0x170>
  74:	10000793          	li	a5,256
  78:	18f51263          	bne	a0,a5,1fc <printsyscall+0x1fc>
      printf("fstat");
  7c:	00001517          	auipc	a0,0x1
  80:	ae450513          	addi	a0,a0,-1308 # b60 <malloc+0x132>
  84:	0f3000ef          	jal	976 <printf>
      break;
  88:	a869                	j	122 <printsyscall+0x122>
  switch(sid) {
  8a:	000407b7          	lui	a5,0x40
  8e:	14f50263          	beq	a0,a5,1d2 <printsyscall+0x1d2>
  92:	04a7c263          	blt	a5,a0,d6 <printsyscall+0xd6>
  96:	67a1                	lui	a5,0x8
  98:	10f50f63          	beq	a0,a5,1b6 <printsyscall+0x1b6>
  9c:	02a7d063          	bge	a5,a0,bc <printsyscall+0xbc>
  a0:	67c1                	lui	a5,0x10
  a2:	12f50163          	beq	a0,a5,1c4 <printsyscall+0x1c4>
  a6:	000207b7          	lui	a5,0x20
  aa:	14f51963          	bne	a0,a5,1fc <printsyscall+0x1fc>
      break;
    case 1<<16:
      printf("write");
      break;
    case 1<<17:
      printf("mknod");
  ae:	00001517          	auipc	a0,0x1
  b2:	afa50513          	addi	a0,a0,-1286 # ba8 <malloc+0x17a>
  b6:	0c1000ef          	jal	976 <printf>
      break;
  ba:	a0a5                	j	122 <printsyscall+0x122>
  switch(sid) {
  bc:	6789                	lui	a5,0x2
  be:	0ef50563          	beq	a0,a5,1a8 <printsyscall+0x1a8>
  c2:	6791                	lui	a5,0x4
  c4:	12f51c63          	bne	a0,a5,1fc <printsyscall+0x1fc>
      printf("uptime");
  c8:	00001517          	auipc	a0,0x1
  cc:	ac850513          	addi	a0,a0,-1336 # b90 <malloc+0x162>
  d0:	0a7000ef          	jal	976 <printf>
      break;
  d4:	a0b9                	j	122 <printsyscall+0x122>
  switch(sid) {
  d6:	002007b7          	lui	a5,0x200
  da:	10f50a63          	beq	a0,a5,1ee <printsyscall+0x1ee>
  de:	02a7c163          	blt	a5,a0,100 <printsyscall+0x100>
  e2:	000807b7          	lui	a5,0x80
  e6:	0ef50d63          	beq	a0,a5,1e0 <printsyscall+0x1e0>
  ea:	001007b7          	lui	a5,0x100
  ee:	10f51763          	bne	a0,a5,1fc <printsyscall+0x1fc>
      break;
    case 1<<19:
      printf("link");
      break;
    case 1<<20:
      printf("mkdir");
  f2:	00001517          	auipc	a0,0x1
  f6:	ace50513          	addi	a0,a0,-1330 # bc0 <malloc+0x192>
  fa:	07d000ef          	jal	976 <printf>
      break;
  fe:	a015                	j	122 <printsyscall+0x122>
  switch(sid) {
 100:	004007b7          	lui	a5,0x400
 104:	0ef51c63          	bne	a0,a5,1fc <printsyscall+0x1fc>
    case 1<<21:
      printf("close");
      break;
    case 1<<22:
      printf("getSyscount");
 108:	00001517          	auipc	a0,0x1
 10c:	ac850513          	addi	a0,a0,-1336 # bd0 <malloc+0x1a2>
 110:	067000ef          	jal	976 <printf>
      break;
 114:	a039                	j	122 <printsyscall+0x122>
      printf("fork");
 116:	00001517          	auipc	a0,0x1
 11a:	a0a50513          	addi	a0,a0,-1526 # b20 <malloc+0xf2>
 11e:	059000ef          	jal	976 <printf>
    default:
      printf("Invalid system call");
      break;
  }
}
 122:	60a2                	ld	ra,8(sp)
 124:	6402                	ld	s0,0(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret
      printf("exit");
 12a:	00001517          	auipc	a0,0x1
 12e:	a0650513          	addi	a0,a0,-1530 # b30 <malloc+0x102>
 132:	045000ef          	jal	976 <printf>
      break;
 136:	b7f5                	j	122 <printsyscall+0x122>
      printf("wait");
 138:	00001517          	auipc	a0,0x1
 13c:	a0050513          	addi	a0,a0,-1536 # b38 <malloc+0x10a>
 140:	037000ef          	jal	976 <printf>
      break;
 144:	bff9                	j	122 <printsyscall+0x122>
      printf("pipe");
 146:	00001517          	auipc	a0,0x1
 14a:	9fa50513          	addi	a0,a0,-1542 # b40 <malloc+0x112>
 14e:	029000ef          	jal	976 <printf>
      break;
 152:	bfc1                	j	122 <printsyscall+0x122>
      printf("read");
 154:	00001517          	auipc	a0,0x1
 158:	9f450513          	addi	a0,a0,-1548 # b48 <malloc+0x11a>
 15c:	01b000ef          	jal	976 <printf>
      break;
 160:	b7c9                	j	122 <printsyscall+0x122>
      printf("kill");
 162:	00001517          	auipc	a0,0x1
 166:	9ee50513          	addi	a0,a0,-1554 # b50 <malloc+0x122>
 16a:	00d000ef          	jal	976 <printf>
      break;
 16e:	bf55                	j	122 <printsyscall+0x122>
      printf("exec");
 170:	00001517          	auipc	a0,0x1
 174:	9e850513          	addi	a0,a0,-1560 # b58 <malloc+0x12a>
 178:	7fe000ef          	jal	976 <printf>
      break;
 17c:	b75d                	j	122 <printsyscall+0x122>
      printf("chdir");
 17e:	00001517          	auipc	a0,0x1
 182:	9ea50513          	addi	a0,a0,-1558 # b68 <malloc+0x13a>
 186:	7f0000ef          	jal	976 <printf>
      break;
 18a:	bf61                	j	122 <printsyscall+0x122>
      printf("dup");
 18c:	00001517          	auipc	a0,0x1
 190:	9e450513          	addi	a0,a0,-1564 # b70 <malloc+0x142>
 194:	7e2000ef          	jal	976 <printf>
      break;
 198:	b769                	j	122 <printsyscall+0x122>
      printf("sbrk");
 19a:	00001517          	auipc	a0,0x1
 19e:	9e650513          	addi	a0,a0,-1562 # b80 <malloc+0x152>
 1a2:	7d4000ef          	jal	976 <printf>
      break;
 1a6:	bfb5                	j	122 <printsyscall+0x122>
      printf("sleep");
 1a8:	00001517          	auipc	a0,0x1
 1ac:	9e050513          	addi	a0,a0,-1568 # b88 <malloc+0x15a>
 1b0:	7c6000ef          	jal	976 <printf>
      break;
 1b4:	b7bd                	j	122 <printsyscall+0x122>
      printf("open");
 1b6:	00001517          	auipc	a0,0x1
 1ba:	9e250513          	addi	a0,a0,-1566 # b98 <malloc+0x16a>
 1be:	7b8000ef          	jal	976 <printf>
      break;
 1c2:	b785                	j	122 <printsyscall+0x122>
      printf("write");
 1c4:	00001517          	auipc	a0,0x1
 1c8:	9dc50513          	addi	a0,a0,-1572 # ba0 <malloc+0x172>
 1cc:	7aa000ef          	jal	976 <printf>
      break;
 1d0:	bf89                	j	122 <printsyscall+0x122>
      printf("unlink");
 1d2:	00001517          	auipc	a0,0x1
 1d6:	9de50513          	addi	a0,a0,-1570 # bb0 <malloc+0x182>
 1da:	79c000ef          	jal	976 <printf>
      break;
 1de:	b791                	j	122 <printsyscall+0x122>
      printf("link");
 1e0:	00001517          	auipc	a0,0x1
 1e4:	9d850513          	addi	a0,a0,-1576 # bb8 <malloc+0x18a>
 1e8:	78e000ef          	jal	976 <printf>
      break;
 1ec:	bf1d                	j	122 <printsyscall+0x122>
      printf("close");
 1ee:	00001517          	auipc	a0,0x1
 1f2:	9da50513          	addi	a0,a0,-1574 # bc8 <malloc+0x19a>
 1f6:	780000ef          	jal	976 <printf>
      break;
 1fa:	b725                	j	122 <printsyscall+0x122>
      printf("Invalid system call");
 1fc:	00001517          	auipc	a0,0x1
 200:	9e450513          	addi	a0,a0,-1564 # be0 <malloc+0x1b2>
 204:	772000ef          	jal	976 <printf>
}
 208:	bf29                	j	122 <printsyscall+0x122>

000000000000020a <main>:

int
main(int argc, char *argv[])
{
 20a:	7139                	addi	sp,sp,-64
 20c:	fc06                	sd	ra,56(sp)
 20e:	f822                	sd	s0,48(sp)
 210:	0080                	addi	s0,sp,64
  if(argc < 3){
 212:	4789                	li	a5,2
 214:	00a7cf63          	blt	a5,a0,232 <main+0x28>
 218:	f426                	sd	s1,40(sp)
 21a:	f04a                	sd	s2,32(sp)
 21c:	ec4e                	sd	s3,24(sp)
    fprintf(2, "Usage: syscount <mask> command [args]\n");
 21e:	00001597          	auipc	a1,0x1
 222:	9da58593          	addi	a1,a1,-1574 # bf8 <malloc+0x1ca>
 226:	853e                	mv	a0,a5
 228:	724000ef          	jal	94c <fprintf>
    exit(1);
 22c:	4505                	li	a0,1
 22e:	32e000ef          	jal	55c <exit>
 232:	f426                	sd	s1,40(sp)
 234:	f04a                	sd	s2,32(sp)
 236:	ec4e                	sd	s3,24(sp)
 238:	84ae                	mv	s1,a1
  }

  int mask = atoi(argv[1]);
 23a:	6588                	ld	a0,8(a1)
 23c:	21e000ef          	jal	45a <atoi>
 240:	89aa                	mv	s3,a0
  getSyscount(mask);
 242:	3ba000ef          	jal	5fc <getSyscount>
  int pid = fork();
 246:	30e000ef          	jal	554 <fork>
 24a:	892a                	mv	s2,a0
  if(pid < 0){
 24c:	02054363          	bltz	a0,272 <main+0x68>
    fprintf(2, "fork failed\n");
    exit(1);
  }
  
  if(pid == 0){
 250:	e91d                	bnez	a0,286 <main+0x7c>
    // Child process
    exec(argv[2], &argv[2]);
 252:	01048593          	addi	a1,s1,16
 256:	6888                	ld	a0,16(s1)
 258:	33c000ef          	jal	594 <exec>
    fprintf(2, "exec %s failed\n", argv[2]);
 25c:	6890                	ld	a2,16(s1)
 25e:	00001597          	auipc	a1,0x1
 262:	9d258593          	addi	a1,a1,-1582 # c30 <malloc+0x202>
 266:	4509                	li	a0,2
 268:	6e4000ef          	jal	94c <fprintf>
    exit(1);
 26c:	4505                	li	a0,1
 26e:	2ee000ef          	jal	55c <exit>
    fprintf(2, "fork failed\n");
 272:	00001597          	auipc	a1,0x1
 276:	9ae58593          	addi	a1,a1,-1618 # c20 <malloc+0x1f2>
 27a:	4509                	li	a0,2
 27c:	6d0000ef          	jal	94c <fprintf>
    exit(1);
 280:	4505                	li	a0,1
 282:	2da000ef          	jal	55c <exit>
  } else {
    // Parent process
    int status;
    wait(&status);
 286:	fcc40513          	addi	a0,s0,-52
 28a:	2da000ef          	jal	564 <wait>
    int count = getSyscount(mask);
 28e:	854e                	mv	a0,s3
 290:	36c000ef          	jal	5fc <getSyscount>
 294:	84aa                	mv	s1,a0
    
    printf("PID %d called ", pid);
 296:	85ca                	mv	a1,s2
 298:	00001517          	auipc	a0,0x1
 29c:	9a850513          	addi	a0,a0,-1624 # c40 <malloc+0x212>
 2a0:	6d6000ef          	jal	976 <printf>
    //printf("%d",mask);
    printsyscall(mask);
 2a4:	854e                	mv	a0,s3
 2a6:	d5bff0ef          	jal	0 <printsyscall>
    printf(" %d times\n", count);
 2aa:	85a6                	mv	a1,s1
 2ac:	00001517          	auipc	a0,0x1
 2b0:	9a450513          	addi	a0,a0,-1628 # c50 <malloc+0x222>
 2b4:	6c2000ef          	jal	976 <printf>
    exit(0);
 2b8:	4501                	li	a0,0
 2ba:	2a2000ef          	jal	55c <exit>

00000000000002be <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e406                	sd	ra,8(sp)
 2c2:	e022                	sd	s0,0(sp)
 2c4:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2c6:	f45ff0ef          	jal	20a <main>
  exit(0);
 2ca:	4501                	li	a0,0
 2cc:	290000ef          	jal	55c <exit>

00000000000002d0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e406                	sd	ra,8(sp)
 2d4:	e022                	sd	s0,0(sp)
 2d6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2d8:	87aa                	mv	a5,a0
 2da:	0585                	addi	a1,a1,1
 2dc:	0785                	addi	a5,a5,1 # 400001 <base+0x3fdff1>
 2de:	fff5c703          	lbu	a4,-1(a1)
 2e2:	fee78fa3          	sb	a4,-1(a5)
 2e6:	fb75                	bnez	a4,2da <strcpy+0xa>
    ;
  return os;
}
 2e8:	60a2                	ld	ra,8(sp)
 2ea:	6402                	ld	s0,0(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	cb91                	beqz	a5,310 <strcmp+0x20>
 2fe:	0005c703          	lbu	a4,0(a1)
 302:	00f71763          	bne	a4,a5,310 <strcmp+0x20>
    p++, q++;
 306:	0505                	addi	a0,a0,1
 308:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 30a:	00054783          	lbu	a5,0(a0)
 30e:	fbe5                	bnez	a5,2fe <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 310:	0005c503          	lbu	a0,0(a1)
}
 314:	40a7853b          	subw	a0,a5,a0
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret

0000000000000320 <strlen>:

uint
strlen(const char *s)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 328:	00054783          	lbu	a5,0(a0)
 32c:	cf99                	beqz	a5,34a <strlen+0x2a>
 32e:	0505                	addi	a0,a0,1
 330:	87aa                	mv	a5,a0
 332:	86be                	mv	a3,a5
 334:	0785                	addi	a5,a5,1
 336:	fff7c703          	lbu	a4,-1(a5)
 33a:	ff65                	bnez	a4,332 <strlen+0x12>
 33c:	40a6853b          	subw	a0,a3,a0
 340:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 342:	60a2                	ld	ra,8(sp)
 344:	6402                	ld	s0,0(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret
  for(n = 0; s[n]; n++)
 34a:	4501                	li	a0,0
 34c:	bfdd                	j	342 <strlen+0x22>

000000000000034e <memset>:

void*
memset(void *dst, int c, uint n)
{
 34e:	1141                	addi	sp,sp,-16
 350:	e406                	sd	ra,8(sp)
 352:	e022                	sd	s0,0(sp)
 354:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 356:	ca19                	beqz	a2,36c <memset+0x1e>
 358:	87aa                	mv	a5,a0
 35a:	1602                	slli	a2,a2,0x20
 35c:	9201                	srli	a2,a2,0x20
 35e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 362:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 366:	0785                	addi	a5,a5,1
 368:	fee79de3          	bne	a5,a4,362 <memset+0x14>
  }
  return dst;
}
 36c:	60a2                	ld	ra,8(sp)
 36e:	6402                	ld	s0,0(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret

0000000000000374 <strchr>:

char*
strchr(const char *s, char c)
{
 374:	1141                	addi	sp,sp,-16
 376:	e406                	sd	ra,8(sp)
 378:	e022                	sd	s0,0(sp)
 37a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 37c:	00054783          	lbu	a5,0(a0)
 380:	cf81                	beqz	a5,398 <strchr+0x24>
    if(*s == c)
 382:	00f58763          	beq	a1,a5,390 <strchr+0x1c>
  for(; *s; s++)
 386:	0505                	addi	a0,a0,1
 388:	00054783          	lbu	a5,0(a0)
 38c:	fbfd                	bnez	a5,382 <strchr+0xe>
      return (char*)s;
  return 0;
 38e:	4501                	li	a0,0
}
 390:	60a2                	ld	ra,8(sp)
 392:	6402                	ld	s0,0(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  return 0;
 398:	4501                	li	a0,0
 39a:	bfdd                	j	390 <strchr+0x1c>

000000000000039c <gets>:

char*
gets(char *buf, int max)
{
 39c:	7159                	addi	sp,sp,-112
 39e:	f486                	sd	ra,104(sp)
 3a0:	f0a2                	sd	s0,96(sp)
 3a2:	eca6                	sd	s1,88(sp)
 3a4:	e8ca                	sd	s2,80(sp)
 3a6:	e4ce                	sd	s3,72(sp)
 3a8:	e0d2                	sd	s4,64(sp)
 3aa:	fc56                	sd	s5,56(sp)
 3ac:	f85a                	sd	s6,48(sp)
 3ae:	f45e                	sd	s7,40(sp)
 3b0:	f062                	sd	s8,32(sp)
 3b2:	ec66                	sd	s9,24(sp)
 3b4:	e86a                	sd	s10,16(sp)
 3b6:	1880                	addi	s0,sp,112
 3b8:	8caa                	mv	s9,a0
 3ba:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3bc:	892a                	mv	s2,a0
 3be:	4481                	li	s1,0
    cc = read(0, &c, 1);
 3c0:	f9f40b13          	addi	s6,s0,-97
 3c4:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3c6:	4ba9                	li	s7,10
 3c8:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 3ca:	8d26                	mv	s10,s1
 3cc:	0014899b          	addiw	s3,s1,1
 3d0:	84ce                	mv	s1,s3
 3d2:	0349d563          	bge	s3,s4,3fc <gets+0x60>
    cc = read(0, &c, 1);
 3d6:	8656                	mv	a2,s5
 3d8:	85da                	mv	a1,s6
 3da:	4501                	li	a0,0
 3dc:	198000ef          	jal	574 <read>
    if(cc < 1)
 3e0:	00a05e63          	blez	a0,3fc <gets+0x60>
    buf[i++] = c;
 3e4:	f9f44783          	lbu	a5,-97(s0)
 3e8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3ec:	01778763          	beq	a5,s7,3fa <gets+0x5e>
 3f0:	0905                	addi	s2,s2,1
 3f2:	fd879ce3          	bne	a5,s8,3ca <gets+0x2e>
    buf[i++] = c;
 3f6:	8d4e                	mv	s10,s3
 3f8:	a011                	j	3fc <gets+0x60>
 3fa:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 3fc:	9d66                	add	s10,s10,s9
 3fe:	000d0023          	sb	zero,0(s10)
  return buf;
}
 402:	8566                	mv	a0,s9
 404:	70a6                	ld	ra,104(sp)
 406:	7406                	ld	s0,96(sp)
 408:	64e6                	ld	s1,88(sp)
 40a:	6946                	ld	s2,80(sp)
 40c:	69a6                	ld	s3,72(sp)
 40e:	6a06                	ld	s4,64(sp)
 410:	7ae2                	ld	s5,56(sp)
 412:	7b42                	ld	s6,48(sp)
 414:	7ba2                	ld	s7,40(sp)
 416:	7c02                	ld	s8,32(sp)
 418:	6ce2                	ld	s9,24(sp)
 41a:	6d42                	ld	s10,16(sp)
 41c:	6165                	addi	sp,sp,112
 41e:	8082                	ret

0000000000000420 <stat>:

int
stat(const char *n, struct stat *st)
{
 420:	1101                	addi	sp,sp,-32
 422:	ec06                	sd	ra,24(sp)
 424:	e822                	sd	s0,16(sp)
 426:	e04a                	sd	s2,0(sp)
 428:	1000                	addi	s0,sp,32
 42a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 42c:	4581                	li	a1,0
 42e:	16e000ef          	jal	59c <open>
  if(fd < 0)
 432:	02054263          	bltz	a0,456 <stat+0x36>
 436:	e426                	sd	s1,8(sp)
 438:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 43a:	85ca                	mv	a1,s2
 43c:	178000ef          	jal	5b4 <fstat>
 440:	892a                	mv	s2,a0
  close(fd);
 442:	8526                	mv	a0,s1
 444:	140000ef          	jal	584 <close>
  return r;
 448:	64a2                	ld	s1,8(sp)
}
 44a:	854a                	mv	a0,s2
 44c:	60e2                	ld	ra,24(sp)
 44e:	6442                	ld	s0,16(sp)
 450:	6902                	ld	s2,0(sp)
 452:	6105                	addi	sp,sp,32
 454:	8082                	ret
    return -1;
 456:	597d                	li	s2,-1
 458:	bfcd                	j	44a <stat+0x2a>

000000000000045a <atoi>:

int
atoi(const char *s)
{
 45a:	1141                	addi	sp,sp,-16
 45c:	e406                	sd	ra,8(sp)
 45e:	e022                	sd	s0,0(sp)
 460:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 462:	00054683          	lbu	a3,0(a0)
 466:	fd06879b          	addiw	a5,a3,-48
 46a:	0ff7f793          	zext.b	a5,a5
 46e:	4625                	li	a2,9
 470:	02f66963          	bltu	a2,a5,4a2 <atoi+0x48>
 474:	872a                	mv	a4,a0
  n = 0;
 476:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 478:	0705                	addi	a4,a4,1
 47a:	0025179b          	slliw	a5,a0,0x2
 47e:	9fa9                	addw	a5,a5,a0
 480:	0017979b          	slliw	a5,a5,0x1
 484:	9fb5                	addw	a5,a5,a3
 486:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 48a:	00074683          	lbu	a3,0(a4)
 48e:	fd06879b          	addiw	a5,a3,-48
 492:	0ff7f793          	zext.b	a5,a5
 496:	fef671e3          	bgeu	a2,a5,478 <atoi+0x1e>
  return n;
}
 49a:	60a2                	ld	ra,8(sp)
 49c:	6402                	ld	s0,0(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret
  n = 0;
 4a2:	4501                	li	a0,0
 4a4:	bfdd                	j	49a <atoi+0x40>

00000000000004a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4a6:	1141                	addi	sp,sp,-16
 4a8:	e406                	sd	ra,8(sp)
 4aa:	e022                	sd	s0,0(sp)
 4ac:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4ae:	02b57563          	bgeu	a0,a1,4d8 <memmove+0x32>
    while(n-- > 0)
 4b2:	00c05f63          	blez	a2,4d0 <memmove+0x2a>
 4b6:	1602                	slli	a2,a2,0x20
 4b8:	9201                	srli	a2,a2,0x20
 4ba:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4be:	872a                	mv	a4,a0
      *dst++ = *src++;
 4c0:	0585                	addi	a1,a1,1
 4c2:	0705                	addi	a4,a4,1
 4c4:	fff5c683          	lbu	a3,-1(a1)
 4c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4cc:	fee79ae3          	bne	a5,a4,4c0 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4d0:	60a2                	ld	ra,8(sp)
 4d2:	6402                	ld	s0,0(sp)
 4d4:	0141                	addi	sp,sp,16
 4d6:	8082                	ret
    dst += n;
 4d8:	00c50733          	add	a4,a0,a2
    src += n;
 4dc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4de:	fec059e3          	blez	a2,4d0 <memmove+0x2a>
 4e2:	fff6079b          	addiw	a5,a2,-1
 4e6:	1782                	slli	a5,a5,0x20
 4e8:	9381                	srli	a5,a5,0x20
 4ea:	fff7c793          	not	a5,a5
 4ee:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4f0:	15fd                	addi	a1,a1,-1
 4f2:	177d                	addi	a4,a4,-1
 4f4:	0005c683          	lbu	a3,0(a1)
 4f8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4fc:	fef71ae3          	bne	a4,a5,4f0 <memmove+0x4a>
 500:	bfc1                	j	4d0 <memmove+0x2a>

0000000000000502 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 502:	1141                	addi	sp,sp,-16
 504:	e406                	sd	ra,8(sp)
 506:	e022                	sd	s0,0(sp)
 508:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 50a:	ca0d                	beqz	a2,53c <memcmp+0x3a>
 50c:	fff6069b          	addiw	a3,a2,-1
 510:	1682                	slli	a3,a3,0x20
 512:	9281                	srli	a3,a3,0x20
 514:	0685                	addi	a3,a3,1
 516:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 518:	00054783          	lbu	a5,0(a0)
 51c:	0005c703          	lbu	a4,0(a1)
 520:	00e79863          	bne	a5,a4,530 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 524:	0505                	addi	a0,a0,1
    p2++;
 526:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 528:	fed518e3          	bne	a0,a3,518 <memcmp+0x16>
  }
  return 0;
 52c:	4501                	li	a0,0
 52e:	a019                	j	534 <memcmp+0x32>
      return *p1 - *p2;
 530:	40e7853b          	subw	a0,a5,a4
}
 534:	60a2                	ld	ra,8(sp)
 536:	6402                	ld	s0,0(sp)
 538:	0141                	addi	sp,sp,16
 53a:	8082                	ret
  return 0;
 53c:	4501                	li	a0,0
 53e:	bfdd                	j	534 <memcmp+0x32>

0000000000000540 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 540:	1141                	addi	sp,sp,-16
 542:	e406                	sd	ra,8(sp)
 544:	e022                	sd	s0,0(sp)
 546:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 548:	f5fff0ef          	jal	4a6 <memmove>
}
 54c:	60a2                	ld	ra,8(sp)
 54e:	6402                	ld	s0,0(sp)
 550:	0141                	addi	sp,sp,16
 552:	8082                	ret

0000000000000554 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 554:	4885                	li	a7,1
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <exit>:
.global exit
exit:
 li a7, SYS_exit
 55c:	4889                	li	a7,2
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <wait>:
.global wait
wait:
 li a7, SYS_wait
 564:	488d                	li	a7,3
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 56c:	4891                	li	a7,4
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <read>:
.global read
read:
 li a7, SYS_read
 574:	4895                	li	a7,5
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <write>:
.global write
write:
 li a7, SYS_write
 57c:	48c1                	li	a7,16
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <close>:
.global close
close:
 li a7, SYS_close
 584:	48d5                	li	a7,21
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <kill>:
.global kill
kill:
 li a7, SYS_kill
 58c:	4899                	li	a7,6
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <exec>:
.global exec
exec:
 li a7, SYS_exec
 594:	489d                	li	a7,7
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <open>:
.global open
open:
 li a7, SYS_open
 59c:	48bd                	li	a7,15
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5a4:	48c5                	li	a7,17
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5ac:	48c9                	li	a7,18
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5b4:	48a1                	li	a7,8
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <link>:
.global link
link:
 li a7, SYS_link
 5bc:	48cd                	li	a7,19
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5c4:	48d1                	li	a7,20
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5cc:	48a5                	li	a7,9
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5d4:	48a9                	li	a7,10
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5dc:	48ad                	li	a7,11
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5e4:	48b1                	li	a7,12
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5ec:	48b5                	li	a7,13
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5f4:	48b9                	li	a7,14
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <getSyscount>:
.global getSyscount
getSyscount:
 li a7, SYS_getSyscount
 5fc:	48d9                	li	a7,22
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 604:	48dd                	li	a7,23
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 60c:	48e1                	li	a7,24
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 614:	1101                	addi	sp,sp,-32
 616:	ec06                	sd	ra,24(sp)
 618:	e822                	sd	s0,16(sp)
 61a:	1000                	addi	s0,sp,32
 61c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 620:	4605                	li	a2,1
 622:	fef40593          	addi	a1,s0,-17
 626:	f57ff0ef          	jal	57c <write>
}
 62a:	60e2                	ld	ra,24(sp)
 62c:	6442                	ld	s0,16(sp)
 62e:	6105                	addi	sp,sp,32
 630:	8082                	ret

0000000000000632 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 632:	7139                	addi	sp,sp,-64
 634:	fc06                	sd	ra,56(sp)
 636:	f822                	sd	s0,48(sp)
 638:	f426                	sd	s1,40(sp)
 63a:	f04a                	sd	s2,32(sp)
 63c:	ec4e                	sd	s3,24(sp)
 63e:	0080                	addi	s0,sp,64
 640:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 642:	c299                	beqz	a3,648 <printint+0x16>
 644:	0605ce63          	bltz	a1,6c0 <printint+0x8e>
  neg = 0;
 648:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 64a:	fc040313          	addi	t1,s0,-64
  neg = 0;
 64e:	869a                	mv	a3,t1
  i = 0;
 650:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 652:	00000817          	auipc	a6,0x0
 656:	69e80813          	addi	a6,a6,1694 # cf0 <digits>
 65a:	88be                	mv	a7,a5
 65c:	0017851b          	addiw	a0,a5,1
 660:	87aa                	mv	a5,a0
 662:	02c5f73b          	remuw	a4,a1,a2
 666:	1702                	slli	a4,a4,0x20
 668:	9301                	srli	a4,a4,0x20
 66a:	9742                	add	a4,a4,a6
 66c:	00074703          	lbu	a4,0(a4)
 670:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 674:	872e                	mv	a4,a1
 676:	02c5d5bb          	divuw	a1,a1,a2
 67a:	0685                	addi	a3,a3,1
 67c:	fcc77fe3          	bgeu	a4,a2,65a <printint+0x28>
  if(neg)
 680:	000e0c63          	beqz	t3,698 <printint+0x66>
    buf[i++] = '-';
 684:	fd050793          	addi	a5,a0,-48
 688:	00878533          	add	a0,a5,s0
 68c:	02d00793          	li	a5,45
 690:	fef50823          	sb	a5,-16(a0)
 694:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 698:	fff7899b          	addiw	s3,a5,-1
 69c:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 6a0:	fff4c583          	lbu	a1,-1(s1)
 6a4:	854a                	mv	a0,s2
 6a6:	f6fff0ef          	jal	614 <putc>
  while(--i >= 0)
 6aa:	39fd                	addiw	s3,s3,-1
 6ac:	14fd                	addi	s1,s1,-1
 6ae:	fe09d9e3          	bgez	s3,6a0 <printint+0x6e>
}
 6b2:	70e2                	ld	ra,56(sp)
 6b4:	7442                	ld	s0,48(sp)
 6b6:	74a2                	ld	s1,40(sp)
 6b8:	7902                	ld	s2,32(sp)
 6ba:	69e2                	ld	s3,24(sp)
 6bc:	6121                	addi	sp,sp,64
 6be:	8082                	ret
    x = -xx;
 6c0:	40b005bb          	negw	a1,a1
    neg = 1;
 6c4:	4e05                	li	t3,1
    x = -xx;
 6c6:	b751                	j	64a <printint+0x18>

00000000000006c8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6c8:	711d                	addi	sp,sp,-96
 6ca:	ec86                	sd	ra,88(sp)
 6cc:	e8a2                	sd	s0,80(sp)
 6ce:	e4a6                	sd	s1,72(sp)
 6d0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6d2:	0005c483          	lbu	s1,0(a1)
 6d6:	26048663          	beqz	s1,942 <vprintf+0x27a>
 6da:	e0ca                	sd	s2,64(sp)
 6dc:	fc4e                	sd	s3,56(sp)
 6de:	f852                	sd	s4,48(sp)
 6e0:	f456                	sd	s5,40(sp)
 6e2:	f05a                	sd	s6,32(sp)
 6e4:	ec5e                	sd	s7,24(sp)
 6e6:	e862                	sd	s8,16(sp)
 6e8:	e466                	sd	s9,8(sp)
 6ea:	8b2a                	mv	s6,a0
 6ec:	8a2e                	mv	s4,a1
 6ee:	8bb2                	mv	s7,a2
  state = 0;
 6f0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6f2:	4901                	li	s2,0
 6f4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6f6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6fa:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6fe:	06c00c93          	li	s9,108
 702:	a00d                	j	724 <vprintf+0x5c>
        putc(fd, c0);
 704:	85a6                	mv	a1,s1
 706:	855a                	mv	a0,s6
 708:	f0dff0ef          	jal	614 <putc>
 70c:	a019                	j	712 <vprintf+0x4a>
    } else if(state == '%'){
 70e:	03598363          	beq	s3,s5,734 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 712:	0019079b          	addiw	a5,s2,1
 716:	893e                	mv	s2,a5
 718:	873e                	mv	a4,a5
 71a:	97d2                	add	a5,a5,s4
 71c:	0007c483          	lbu	s1,0(a5)
 720:	20048963          	beqz	s1,932 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 724:	0004879b          	sext.w	a5,s1
    if(state == 0){
 728:	fe0993e3          	bnez	s3,70e <vprintf+0x46>
      if(c0 == '%'){
 72c:	fd579ce3          	bne	a5,s5,704 <vprintf+0x3c>
        state = '%';
 730:	89be                	mv	s3,a5
 732:	b7c5                	j	712 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 734:	00ea06b3          	add	a3,s4,a4
 738:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 73c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 73e:	c681                	beqz	a3,746 <vprintf+0x7e>
 740:	9752                	add	a4,a4,s4
 742:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 746:	03878e63          	beq	a5,s8,782 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 74a:	05978863          	beq	a5,s9,79a <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 74e:	07500713          	li	a4,117
 752:	0ee78263          	beq	a5,a4,836 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 756:	07800713          	li	a4,120
 75a:	12e78463          	beq	a5,a4,882 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 75e:	07000713          	li	a4,112
 762:	14e78963          	beq	a5,a4,8b4 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 766:	07300713          	li	a4,115
 76a:	18e78863          	beq	a5,a4,8fa <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 76e:	02500713          	li	a4,37
 772:	04e79463          	bne	a5,a4,7ba <vprintf+0xf2>
        putc(fd, '%');
 776:	85ba                	mv	a1,a4
 778:	855a                	mv	a0,s6
 77a:	e9bff0ef          	jal	614 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 77e:	4981                	li	s3,0
 780:	bf49                	j	712 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 782:	008b8493          	addi	s1,s7,8
 786:	4685                	li	a3,1
 788:	4629                	li	a2,10
 78a:	000ba583          	lw	a1,0(s7)
 78e:	855a                	mv	a0,s6
 790:	ea3ff0ef          	jal	632 <printint>
 794:	8ba6                	mv	s7,s1
      state = 0;
 796:	4981                	li	s3,0
 798:	bfad                	j	712 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 79a:	06400793          	li	a5,100
 79e:	02f68963          	beq	a3,a5,7d0 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7a2:	06c00793          	li	a5,108
 7a6:	04f68263          	beq	a3,a5,7ea <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 7aa:	07500793          	li	a5,117
 7ae:	0af68063          	beq	a3,a5,84e <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 7b2:	07800793          	li	a5,120
 7b6:	0ef68263          	beq	a3,a5,89a <vprintf+0x1d2>
        putc(fd, '%');
 7ba:	02500593          	li	a1,37
 7be:	855a                	mv	a0,s6
 7c0:	e55ff0ef          	jal	614 <putc>
        putc(fd, c0);
 7c4:	85a6                	mv	a1,s1
 7c6:	855a                	mv	a0,s6
 7c8:	e4dff0ef          	jal	614 <putc>
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	b791                	j	712 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d0:	008b8493          	addi	s1,s7,8
 7d4:	4685                	li	a3,1
 7d6:	4629                	li	a2,10
 7d8:	000ba583          	lw	a1,0(s7)
 7dc:	855a                	mv	a0,s6
 7de:	e55ff0ef          	jal	632 <printint>
        i += 1;
 7e2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7e4:	8ba6                	mv	s7,s1
      state = 0;
 7e6:	4981                	li	s3,0
        i += 1;
 7e8:	b72d                	j	712 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7ea:	06400793          	li	a5,100
 7ee:	02f60763          	beq	a2,a5,81c <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7f2:	07500793          	li	a5,117
 7f6:	06f60963          	beq	a2,a5,868 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7fa:	07800793          	li	a5,120
 7fe:	faf61ee3          	bne	a2,a5,7ba <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 802:	008b8493          	addi	s1,s7,8
 806:	4681                	li	a3,0
 808:	4641                	li	a2,16
 80a:	000ba583          	lw	a1,0(s7)
 80e:	855a                	mv	a0,s6
 810:	e23ff0ef          	jal	632 <printint>
        i += 2;
 814:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 816:	8ba6                	mv	s7,s1
      state = 0;
 818:	4981                	li	s3,0
        i += 2;
 81a:	bde5                	j	712 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 81c:	008b8493          	addi	s1,s7,8
 820:	4685                	li	a3,1
 822:	4629                	li	a2,10
 824:	000ba583          	lw	a1,0(s7)
 828:	855a                	mv	a0,s6
 82a:	e09ff0ef          	jal	632 <printint>
        i += 2;
 82e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 830:	8ba6                	mv	s7,s1
      state = 0;
 832:	4981                	li	s3,0
        i += 2;
 834:	bdf9                	j	712 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 836:	008b8493          	addi	s1,s7,8
 83a:	4681                	li	a3,0
 83c:	4629                	li	a2,10
 83e:	000ba583          	lw	a1,0(s7)
 842:	855a                	mv	a0,s6
 844:	defff0ef          	jal	632 <printint>
 848:	8ba6                	mv	s7,s1
      state = 0;
 84a:	4981                	li	s3,0
 84c:	b5d9                	j	712 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 84e:	008b8493          	addi	s1,s7,8
 852:	4681                	li	a3,0
 854:	4629                	li	a2,10
 856:	000ba583          	lw	a1,0(s7)
 85a:	855a                	mv	a0,s6
 85c:	dd7ff0ef          	jal	632 <printint>
        i += 1;
 860:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 862:	8ba6                	mv	s7,s1
      state = 0;
 864:	4981                	li	s3,0
        i += 1;
 866:	b575                	j	712 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 868:	008b8493          	addi	s1,s7,8
 86c:	4681                	li	a3,0
 86e:	4629                	li	a2,10
 870:	000ba583          	lw	a1,0(s7)
 874:	855a                	mv	a0,s6
 876:	dbdff0ef          	jal	632 <printint>
        i += 2;
 87a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 87c:	8ba6                	mv	s7,s1
      state = 0;
 87e:	4981                	li	s3,0
        i += 2;
 880:	bd49                	j	712 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 882:	008b8493          	addi	s1,s7,8
 886:	4681                	li	a3,0
 888:	4641                	li	a2,16
 88a:	000ba583          	lw	a1,0(s7)
 88e:	855a                	mv	a0,s6
 890:	da3ff0ef          	jal	632 <printint>
 894:	8ba6                	mv	s7,s1
      state = 0;
 896:	4981                	li	s3,0
 898:	bdad                	j	712 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 89a:	008b8493          	addi	s1,s7,8
 89e:	4681                	li	a3,0
 8a0:	4641                	li	a2,16
 8a2:	000ba583          	lw	a1,0(s7)
 8a6:	855a                	mv	a0,s6
 8a8:	d8bff0ef          	jal	632 <printint>
        i += 1;
 8ac:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 8ae:	8ba6                	mv	s7,s1
      state = 0;
 8b0:	4981                	li	s3,0
        i += 1;
 8b2:	b585                	j	712 <vprintf+0x4a>
 8b4:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 8b6:	008b8d13          	addi	s10,s7,8
 8ba:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8be:	03000593          	li	a1,48
 8c2:	855a                	mv	a0,s6
 8c4:	d51ff0ef          	jal	614 <putc>
  putc(fd, 'x');
 8c8:	07800593          	li	a1,120
 8cc:	855a                	mv	a0,s6
 8ce:	d47ff0ef          	jal	614 <putc>
 8d2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8d4:	00000b97          	auipc	s7,0x0
 8d8:	41cb8b93          	addi	s7,s7,1052 # cf0 <digits>
 8dc:	03c9d793          	srli	a5,s3,0x3c
 8e0:	97de                	add	a5,a5,s7
 8e2:	0007c583          	lbu	a1,0(a5)
 8e6:	855a                	mv	a0,s6
 8e8:	d2dff0ef          	jal	614 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8ec:	0992                	slli	s3,s3,0x4
 8ee:	34fd                	addiw	s1,s1,-1
 8f0:	f4f5                	bnez	s1,8dc <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 8f2:	8bea                	mv	s7,s10
      state = 0;
 8f4:	4981                	li	s3,0
 8f6:	6d02                	ld	s10,0(sp)
 8f8:	bd29                	j	712 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8fa:	008b8993          	addi	s3,s7,8
 8fe:	000bb483          	ld	s1,0(s7)
 902:	cc91                	beqz	s1,91e <vprintf+0x256>
        for(; *s; s++)
 904:	0004c583          	lbu	a1,0(s1)
 908:	c195                	beqz	a1,92c <vprintf+0x264>
          putc(fd, *s);
 90a:	855a                	mv	a0,s6
 90c:	d09ff0ef          	jal	614 <putc>
        for(; *s; s++)
 910:	0485                	addi	s1,s1,1
 912:	0004c583          	lbu	a1,0(s1)
 916:	f9f5                	bnez	a1,90a <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 918:	8bce                	mv	s7,s3
      state = 0;
 91a:	4981                	li	s3,0
 91c:	bbdd                	j	712 <vprintf+0x4a>
          s = "(null)";
 91e:	00000497          	auipc	s1,0x0
 922:	34248493          	addi	s1,s1,834 # c60 <malloc+0x232>
        for(; *s; s++)
 926:	02800593          	li	a1,40
 92a:	b7c5                	j	90a <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 92c:	8bce                	mv	s7,s3
      state = 0;
 92e:	4981                	li	s3,0
 930:	b3cd                	j	712 <vprintf+0x4a>
 932:	6906                	ld	s2,64(sp)
 934:	79e2                	ld	s3,56(sp)
 936:	7a42                	ld	s4,48(sp)
 938:	7aa2                	ld	s5,40(sp)
 93a:	7b02                	ld	s6,32(sp)
 93c:	6be2                	ld	s7,24(sp)
 93e:	6c42                	ld	s8,16(sp)
 940:	6ca2                	ld	s9,8(sp)
    }
  }
}
 942:	60e6                	ld	ra,88(sp)
 944:	6446                	ld	s0,80(sp)
 946:	64a6                	ld	s1,72(sp)
 948:	6125                	addi	sp,sp,96
 94a:	8082                	ret

000000000000094c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 94c:	715d                	addi	sp,sp,-80
 94e:	ec06                	sd	ra,24(sp)
 950:	e822                	sd	s0,16(sp)
 952:	1000                	addi	s0,sp,32
 954:	e010                	sd	a2,0(s0)
 956:	e414                	sd	a3,8(s0)
 958:	e818                	sd	a4,16(s0)
 95a:	ec1c                	sd	a5,24(s0)
 95c:	03043023          	sd	a6,32(s0)
 960:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 964:	8622                	mv	a2,s0
 966:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 96a:	d5fff0ef          	jal	6c8 <vprintf>
}
 96e:	60e2                	ld	ra,24(sp)
 970:	6442                	ld	s0,16(sp)
 972:	6161                	addi	sp,sp,80
 974:	8082                	ret

0000000000000976 <printf>:

void
printf(const char *fmt, ...)
{
 976:	711d                	addi	sp,sp,-96
 978:	ec06                	sd	ra,24(sp)
 97a:	e822                	sd	s0,16(sp)
 97c:	1000                	addi	s0,sp,32
 97e:	e40c                	sd	a1,8(s0)
 980:	e810                	sd	a2,16(s0)
 982:	ec14                	sd	a3,24(s0)
 984:	f018                	sd	a4,32(s0)
 986:	f41c                	sd	a5,40(s0)
 988:	03043823          	sd	a6,48(s0)
 98c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 990:	00840613          	addi	a2,s0,8
 994:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 998:	85aa                	mv	a1,a0
 99a:	4505                	li	a0,1
 99c:	d2dff0ef          	jal	6c8 <vprintf>
}
 9a0:	60e2                	ld	ra,24(sp)
 9a2:	6442                	ld	s0,16(sp)
 9a4:	6125                	addi	sp,sp,96
 9a6:	8082                	ret

00000000000009a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9a8:	1141                	addi	sp,sp,-16
 9aa:	e406                	sd	ra,8(sp)
 9ac:	e022                	sd	s0,0(sp)
 9ae:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9b0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b4:	00001797          	auipc	a5,0x1
 9b8:	64c7b783          	ld	a5,1612(a5) # 2000 <freep>
 9bc:	a02d                	j	9e6 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9be:	4618                	lw	a4,8(a2)
 9c0:	9f2d                	addw	a4,a4,a1
 9c2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9c6:	6398                	ld	a4,0(a5)
 9c8:	6310                	ld	a2,0(a4)
 9ca:	a83d                	j	a08 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9cc:	ff852703          	lw	a4,-8(a0)
 9d0:	9f31                	addw	a4,a4,a2
 9d2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9d4:	ff053683          	ld	a3,-16(a0)
 9d8:	a091                	j	a1c <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9da:	6398                	ld	a4,0(a5)
 9dc:	00e7e463          	bltu	a5,a4,9e4 <free+0x3c>
 9e0:	00e6ea63          	bltu	a3,a4,9f4 <free+0x4c>
{
 9e4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9e6:	fed7fae3          	bgeu	a5,a3,9da <free+0x32>
 9ea:	6398                	ld	a4,0(a5)
 9ec:	00e6e463          	bltu	a3,a4,9f4 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9f0:	fee7eae3          	bltu	a5,a4,9e4 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 9f4:	ff852583          	lw	a1,-8(a0)
 9f8:	6390                	ld	a2,0(a5)
 9fa:	02059813          	slli	a6,a1,0x20
 9fe:	01c85713          	srli	a4,a6,0x1c
 a02:	9736                	add	a4,a4,a3
 a04:	fae60de3          	beq	a2,a4,9be <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 a08:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a0c:	4790                	lw	a2,8(a5)
 a0e:	02061593          	slli	a1,a2,0x20
 a12:	01c5d713          	srli	a4,a1,0x1c
 a16:	973e                	add	a4,a4,a5
 a18:	fae68ae3          	beq	a3,a4,9cc <free+0x24>
    p->s.ptr = bp->s.ptr;
 a1c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a1e:	00001717          	auipc	a4,0x1
 a22:	5ef73123          	sd	a5,1506(a4) # 2000 <freep>
}
 a26:	60a2                	ld	ra,8(sp)
 a28:	6402                	ld	s0,0(sp)
 a2a:	0141                	addi	sp,sp,16
 a2c:	8082                	ret

0000000000000a2e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a2e:	7139                	addi	sp,sp,-64
 a30:	fc06                	sd	ra,56(sp)
 a32:	f822                	sd	s0,48(sp)
 a34:	f04a                	sd	s2,32(sp)
 a36:	ec4e                	sd	s3,24(sp)
 a38:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a3a:	02051993          	slli	s3,a0,0x20
 a3e:	0209d993          	srli	s3,s3,0x20
 a42:	09bd                	addi	s3,s3,15
 a44:	0049d993          	srli	s3,s3,0x4
 a48:	2985                	addiw	s3,s3,1
 a4a:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 a4c:	00001517          	auipc	a0,0x1
 a50:	5b453503          	ld	a0,1460(a0) # 2000 <freep>
 a54:	c905                	beqz	a0,a84 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a56:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a58:	4798                	lw	a4,8(a5)
 a5a:	09377663          	bgeu	a4,s3,ae6 <malloc+0xb8>
 a5e:	f426                	sd	s1,40(sp)
 a60:	e852                	sd	s4,16(sp)
 a62:	e456                	sd	s5,8(sp)
 a64:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a66:	8a4e                	mv	s4,s3
 a68:	6705                	lui	a4,0x1
 a6a:	00e9f363          	bgeu	s3,a4,a70 <malloc+0x42>
 a6e:	6a05                	lui	s4,0x1
 a70:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a74:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a78:	00001497          	auipc	s1,0x1
 a7c:	58848493          	addi	s1,s1,1416 # 2000 <freep>
  if(p == (char*)-1)
 a80:	5afd                	li	s5,-1
 a82:	a83d                	j	ac0 <malloc+0x92>
 a84:	f426                	sd	s1,40(sp)
 a86:	e852                	sd	s4,16(sp)
 a88:	e456                	sd	s5,8(sp)
 a8a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a8c:	00001797          	auipc	a5,0x1
 a90:	58478793          	addi	a5,a5,1412 # 2010 <base>
 a94:	00001717          	auipc	a4,0x1
 a98:	56f73623          	sd	a5,1388(a4) # 2000 <freep>
 a9c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a9e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 aa2:	b7d1                	j	a66 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 aa4:	6398                	ld	a4,0(a5)
 aa6:	e118                	sd	a4,0(a0)
 aa8:	a899                	j	afe <malloc+0xd0>
  hp->s.size = nu;
 aaa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 aae:	0541                	addi	a0,a0,16
 ab0:	ef9ff0ef          	jal	9a8 <free>
  return freep;
 ab4:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 ab6:	c125                	beqz	a0,b16 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aba:	4798                	lw	a4,8(a5)
 abc:	03277163          	bgeu	a4,s2,ade <malloc+0xb0>
    if(p == freep)
 ac0:	6098                	ld	a4,0(s1)
 ac2:	853e                	mv	a0,a5
 ac4:	fef71ae3          	bne	a4,a5,ab8 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 ac8:	8552                	mv	a0,s4
 aca:	b1bff0ef          	jal	5e4 <sbrk>
  if(p == (char*)-1)
 ace:	fd551ee3          	bne	a0,s5,aaa <malloc+0x7c>
        return 0;
 ad2:	4501                	li	a0,0
 ad4:	74a2                	ld	s1,40(sp)
 ad6:	6a42                	ld	s4,16(sp)
 ad8:	6aa2                	ld	s5,8(sp)
 ada:	6b02                	ld	s6,0(sp)
 adc:	a03d                	j	b0a <malloc+0xdc>
 ade:	74a2                	ld	s1,40(sp)
 ae0:	6a42                	ld	s4,16(sp)
 ae2:	6aa2                	ld	s5,8(sp)
 ae4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ae6:	fae90fe3          	beq	s2,a4,aa4 <malloc+0x76>
        p->s.size -= nunits;
 aea:	4137073b          	subw	a4,a4,s3
 aee:	c798                	sw	a4,8(a5)
        p += p->s.size;
 af0:	02071693          	slli	a3,a4,0x20
 af4:	01c6d713          	srli	a4,a3,0x1c
 af8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 afa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 afe:	00001717          	auipc	a4,0x1
 b02:	50a73123          	sd	a0,1282(a4) # 2000 <freep>
      return (void*)(p + 1);
 b06:	01078513          	addi	a0,a5,16
  }
}
 b0a:	70e2                	ld	ra,56(sp)
 b0c:	7442                	ld	s0,48(sp)
 b0e:	7902                	ld	s2,32(sp)
 b10:	69e2                	ld	s3,24(sp)
 b12:	6121                	addi	sp,sp,64
 b14:	8082                	ret
 b16:	74a2                	ld	s1,40(sp)
 b18:	6a42                	ld	s4,16(sp)
 b1a:	6aa2                	ld	s5,8(sp)
 b1c:	6b02                	ld	s6,0(sp)
 b1e:	b7f5                	j	b0a <malloc+0xdc>
