
user/_printhell:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <alarm_handler>:
#include "kernel/types.h"
#include "user/user.h"
int jk=0;
void
alarm_handler()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
  printf("_____________!Alarm!_______________\n");
   8:	00001517          	auipc	a0,0x1
   c:	8f850513          	addi	a0,a0,-1800 # 900 <malloc+0xfc>
  10:	73c000ef          	jal	74c <printf>
  for(int i=0;i<jk;i++){
  14:	00001797          	auipc	a5,0x1
  18:	fec7a783          	lw	a5,-20(a5) # 1000 <jk>
  1c:	02f05a63          	blez	a5,50 <alarm_handler+0x50>
  20:	ec26                	sd	s1,24(sp)
  22:	e84a                	sd	s2,16(sp)
  24:	e44e                	sd	s3,8(sp)
  26:	4481                	li	s1,0
    printf("%d\n",i);
  28:	00001997          	auipc	s3,0x1
  2c:	90098993          	addi	s3,s3,-1792 # 928 <malloc+0x124>
  for(int i=0;i<jk;i++){
  30:	00001917          	auipc	s2,0x1
  34:	fd090913          	addi	s2,s2,-48 # 1000 <jk>
    printf("%d\n",i);
  38:	85a6                	mv	a1,s1
  3a:	854e                	mv	a0,s3
  3c:	710000ef          	jal	74c <printf>
  for(int i=0;i<jk;i++){
  40:	2485                	addiw	s1,s1,1
  42:	00092783          	lw	a5,0(s2)
  46:	fef4c9e3          	blt	s1,a5,38 <alarm_handler+0x38>
  4a:	64e2                	ld	s1,24(sp)
  4c:	6942                	ld	s2,16(sp)
  4e:	69a2                	ld	s3,8(sp)
  }
  jk++;
  50:	2785                	addiw	a5,a5,1
  52:	00001717          	auipc	a4,0x1
  56:	faf72723          	sw	a5,-82(a4) # 1000 <jk>
  sigreturn();
  5a:	388000ef          	jal	3e2 <sigreturn>
}
  5e:	70a2                	ld	ra,40(sp)
  60:	7402                	ld	s0,32(sp)
  62:	6145                	addi	sp,sp,48
  64:	8082                	ret

0000000000000066 <main>:

int
main(int argc, char *argv[])
{
  66:	1101                	addi	sp,sp,-32
  68:	ec06                	sd	ra,24(sp)
  6a:	e822                	sd	s0,16(sp)
  6c:	e426                	sd	s1,8(sp)
  6e:	1000                	addi	s0,sp,32
  sigalarm(1, &alarm_handler);  // Set alarm for every 3 ticks
  70:	00000597          	auipc	a1,0x0
  74:	f9058593          	addi	a1,a1,-112 # 0 <alarm_handler>
  78:	4505                	li	a0,1
  7a:	360000ef          	jal	3da <sigalarm>
  while(1){
    printf("%d\n",getpid());
  7e:	00001497          	auipc	s1,0x1
  82:	8aa48493          	addi	s1,s1,-1878 # 928 <malloc+0x124>
  86:	32c000ef          	jal	3b2 <getpid>
  8a:	85aa                	mv	a1,a0
  8c:	8526                	mv	a0,s1
  8e:	6be000ef          	jal	74c <printf>
  while(1){
  92:	bfd5                	j	86 <main+0x20>

0000000000000094 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  94:	1141                	addi	sp,sp,-16
  96:	e406                	sd	ra,8(sp)
  98:	e022                	sd	s0,0(sp)
  9a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  9c:	fcbff0ef          	jal	66 <main>
  exit(0);
  a0:	4501                	li	a0,0
  a2:	290000ef          	jal	332 <exit>

00000000000000a6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e406                	sd	ra,8(sp)
  aa:	e022                	sd	s0,0(sp)
  ac:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ae:	87aa                	mv	a5,a0
  b0:	0585                	addi	a1,a1,1
  b2:	0785                	addi	a5,a5,1
  b4:	fff5c703          	lbu	a4,-1(a1)
  b8:	fee78fa3          	sb	a4,-1(a5)
  bc:	fb75                	bnez	a4,b0 <strcpy+0xa>
    ;
  return os;
}
  be:	60a2                	ld	ra,8(sp)
  c0:	6402                	ld	s0,0(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e406                	sd	ra,8(sp)
  ca:	e022                	sd	s0,0(sp)
  cc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	cb91                	beqz	a5,e6 <strcmp+0x20>
  d4:	0005c703          	lbu	a4,0(a1)
  d8:	00f71763          	bne	a4,a5,e6 <strcmp+0x20>
    p++, q++;
  dc:	0505                	addi	a0,a0,1
  de:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	fbe5                	bnez	a5,d4 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  e6:	0005c503          	lbu	a0,0(a1)
}
  ea:	40a7853b          	subw	a0,a5,a0
  ee:	60a2                	ld	ra,8(sp)
  f0:	6402                	ld	s0,0(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret

00000000000000f6 <strlen>:

uint
strlen(const char *s)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e406                	sd	ra,8(sp)
  fa:	e022                	sd	s0,0(sp)
  fc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cf99                	beqz	a5,120 <strlen+0x2a>
 104:	0505                	addi	a0,a0,1
 106:	87aa                	mv	a5,a0
 108:	86be                	mv	a3,a5
 10a:	0785                	addi	a5,a5,1
 10c:	fff7c703          	lbu	a4,-1(a5)
 110:	ff65                	bnez	a4,108 <strlen+0x12>
 112:	40a6853b          	subw	a0,a3,a0
 116:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 118:	60a2                	ld	ra,8(sp)
 11a:	6402                	ld	s0,0(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret
  for(n = 0; s[n]; n++)
 120:	4501                	li	a0,0
 122:	bfdd                	j	118 <strlen+0x22>

0000000000000124 <memset>:

void*
memset(void *dst, int c, uint n)
{
 124:	1141                	addi	sp,sp,-16
 126:	e406                	sd	ra,8(sp)
 128:	e022                	sd	s0,0(sp)
 12a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 12c:	ca19                	beqz	a2,142 <memset+0x1e>
 12e:	87aa                	mv	a5,a0
 130:	1602                	slli	a2,a2,0x20
 132:	9201                	srli	a2,a2,0x20
 134:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 138:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 13c:	0785                	addi	a5,a5,1
 13e:	fee79de3          	bne	a5,a4,138 <memset+0x14>
  }
  return dst;
}
 142:	60a2                	ld	ra,8(sp)
 144:	6402                	ld	s0,0(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strchr>:

char*
strchr(const char *s, char c)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e406                	sd	ra,8(sp)
 14e:	e022                	sd	s0,0(sp)
 150:	0800                	addi	s0,sp,16
  for(; *s; s++)
 152:	00054783          	lbu	a5,0(a0)
 156:	cf81                	beqz	a5,16e <strchr+0x24>
    if(*s == c)
 158:	00f58763          	beq	a1,a5,166 <strchr+0x1c>
  for(; *s; s++)
 15c:	0505                	addi	a0,a0,1
 15e:	00054783          	lbu	a5,0(a0)
 162:	fbfd                	bnez	a5,158 <strchr+0xe>
      return (char*)s;
  return 0;
 164:	4501                	li	a0,0
}
 166:	60a2                	ld	ra,8(sp)
 168:	6402                	ld	s0,0(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret
  return 0;
 16e:	4501                	li	a0,0
 170:	bfdd                	j	166 <strchr+0x1c>

0000000000000172 <gets>:

char*
gets(char *buf, int max)
{
 172:	7159                	addi	sp,sp,-112
 174:	f486                	sd	ra,104(sp)
 176:	f0a2                	sd	s0,96(sp)
 178:	eca6                	sd	s1,88(sp)
 17a:	e8ca                	sd	s2,80(sp)
 17c:	e4ce                	sd	s3,72(sp)
 17e:	e0d2                	sd	s4,64(sp)
 180:	fc56                	sd	s5,56(sp)
 182:	f85a                	sd	s6,48(sp)
 184:	f45e                	sd	s7,40(sp)
 186:	f062                	sd	s8,32(sp)
 188:	ec66                	sd	s9,24(sp)
 18a:	e86a                	sd	s10,16(sp)
 18c:	1880                	addi	s0,sp,112
 18e:	8caa                	mv	s9,a0
 190:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 192:	892a                	mv	s2,a0
 194:	4481                	li	s1,0
    cc = read(0, &c, 1);
 196:	f9f40b13          	addi	s6,s0,-97
 19a:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 19c:	4ba9                	li	s7,10
 19e:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 1a0:	8d26                	mv	s10,s1
 1a2:	0014899b          	addiw	s3,s1,1
 1a6:	84ce                	mv	s1,s3
 1a8:	0349d563          	bge	s3,s4,1d2 <gets+0x60>
    cc = read(0, &c, 1);
 1ac:	8656                	mv	a2,s5
 1ae:	85da                	mv	a1,s6
 1b0:	4501                	li	a0,0
 1b2:	198000ef          	jal	34a <read>
    if(cc < 1)
 1b6:	00a05e63          	blez	a0,1d2 <gets+0x60>
    buf[i++] = c;
 1ba:	f9f44783          	lbu	a5,-97(s0)
 1be:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c2:	01778763          	beq	a5,s7,1d0 <gets+0x5e>
 1c6:	0905                	addi	s2,s2,1
 1c8:	fd879ce3          	bne	a5,s8,1a0 <gets+0x2e>
    buf[i++] = c;
 1cc:	8d4e                	mv	s10,s3
 1ce:	a011                	j	1d2 <gets+0x60>
 1d0:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 1d2:	9d66                	add	s10,s10,s9
 1d4:	000d0023          	sb	zero,0(s10)
  return buf;
}
 1d8:	8566                	mv	a0,s9
 1da:	70a6                	ld	ra,104(sp)
 1dc:	7406                	ld	s0,96(sp)
 1de:	64e6                	ld	s1,88(sp)
 1e0:	6946                	ld	s2,80(sp)
 1e2:	69a6                	ld	s3,72(sp)
 1e4:	6a06                	ld	s4,64(sp)
 1e6:	7ae2                	ld	s5,56(sp)
 1e8:	7b42                	ld	s6,48(sp)
 1ea:	7ba2                	ld	s7,40(sp)
 1ec:	7c02                	ld	s8,32(sp)
 1ee:	6ce2                	ld	s9,24(sp)
 1f0:	6d42                	ld	s10,16(sp)
 1f2:	6165                	addi	sp,sp,112
 1f4:	8082                	ret

00000000000001f6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f6:	1101                	addi	sp,sp,-32
 1f8:	ec06                	sd	ra,24(sp)
 1fa:	e822                	sd	s0,16(sp)
 1fc:	e04a                	sd	s2,0(sp)
 1fe:	1000                	addi	s0,sp,32
 200:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 202:	4581                	li	a1,0
 204:	16e000ef          	jal	372 <open>
  if(fd < 0)
 208:	02054263          	bltz	a0,22c <stat+0x36>
 20c:	e426                	sd	s1,8(sp)
 20e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 210:	85ca                	mv	a1,s2
 212:	178000ef          	jal	38a <fstat>
 216:	892a                	mv	s2,a0
  close(fd);
 218:	8526                	mv	a0,s1
 21a:	140000ef          	jal	35a <close>
  return r;
 21e:	64a2                	ld	s1,8(sp)
}
 220:	854a                	mv	a0,s2
 222:	60e2                	ld	ra,24(sp)
 224:	6442                	ld	s0,16(sp)
 226:	6902                	ld	s2,0(sp)
 228:	6105                	addi	sp,sp,32
 22a:	8082                	ret
    return -1;
 22c:	597d                	li	s2,-1
 22e:	bfcd                	j	220 <stat+0x2a>

0000000000000230 <atoi>:

int
atoi(const char *s)
{
 230:	1141                	addi	sp,sp,-16
 232:	e406                	sd	ra,8(sp)
 234:	e022                	sd	s0,0(sp)
 236:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 238:	00054683          	lbu	a3,0(a0)
 23c:	fd06879b          	addiw	a5,a3,-48
 240:	0ff7f793          	zext.b	a5,a5
 244:	4625                	li	a2,9
 246:	02f66963          	bltu	a2,a5,278 <atoi+0x48>
 24a:	872a                	mv	a4,a0
  n = 0;
 24c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 24e:	0705                	addi	a4,a4,1
 250:	0025179b          	slliw	a5,a0,0x2
 254:	9fa9                	addw	a5,a5,a0
 256:	0017979b          	slliw	a5,a5,0x1
 25a:	9fb5                	addw	a5,a5,a3
 25c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 260:	00074683          	lbu	a3,0(a4)
 264:	fd06879b          	addiw	a5,a3,-48
 268:	0ff7f793          	zext.b	a5,a5
 26c:	fef671e3          	bgeu	a2,a5,24e <atoi+0x1e>
  return n;
}
 270:	60a2                	ld	ra,8(sp)
 272:	6402                	ld	s0,0(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  n = 0;
 278:	4501                	li	a0,0
 27a:	bfdd                	j	270 <atoi+0x40>

000000000000027c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e406                	sd	ra,8(sp)
 280:	e022                	sd	s0,0(sp)
 282:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 284:	02b57563          	bgeu	a0,a1,2ae <memmove+0x32>
    while(n-- > 0)
 288:	00c05f63          	blez	a2,2a6 <memmove+0x2a>
 28c:	1602                	slli	a2,a2,0x20
 28e:	9201                	srli	a2,a2,0x20
 290:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 294:	872a                	mv	a4,a0
      *dst++ = *src++;
 296:	0585                	addi	a1,a1,1
 298:	0705                	addi	a4,a4,1
 29a:	fff5c683          	lbu	a3,-1(a1)
 29e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a2:	fee79ae3          	bne	a5,a4,296 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a6:	60a2                	ld	ra,8(sp)
 2a8:	6402                	ld	s0,0(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
    dst += n;
 2ae:	00c50733          	add	a4,a0,a2
    src += n;
 2b2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b4:	fec059e3          	blez	a2,2a6 <memmove+0x2a>
 2b8:	fff6079b          	addiw	a5,a2,-1
 2bc:	1782                	slli	a5,a5,0x20
 2be:	9381                	srli	a5,a5,0x20
 2c0:	fff7c793          	not	a5,a5
 2c4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c6:	15fd                	addi	a1,a1,-1
 2c8:	177d                	addi	a4,a4,-1
 2ca:	0005c683          	lbu	a3,0(a1)
 2ce:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d2:	fef71ae3          	bne	a4,a5,2c6 <memmove+0x4a>
 2d6:	bfc1                	j	2a6 <memmove+0x2a>

00000000000002d8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e0:	ca0d                	beqz	a2,312 <memcmp+0x3a>
 2e2:	fff6069b          	addiw	a3,a2,-1
 2e6:	1682                	slli	a3,a3,0x20
 2e8:	9281                	srli	a3,a3,0x20
 2ea:	0685                	addi	a3,a3,1
 2ec:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ee:	00054783          	lbu	a5,0(a0)
 2f2:	0005c703          	lbu	a4,0(a1)
 2f6:	00e79863          	bne	a5,a4,306 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 2fa:	0505                	addi	a0,a0,1
    p2++;
 2fc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fe:	fed518e3          	bne	a0,a3,2ee <memcmp+0x16>
  }
  return 0;
 302:	4501                	li	a0,0
 304:	a019                	j	30a <memcmp+0x32>
      return *p1 - *p2;
 306:	40e7853b          	subw	a0,a5,a4
}
 30a:	60a2                	ld	ra,8(sp)
 30c:	6402                	ld	s0,0(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  return 0;
 312:	4501                	li	a0,0
 314:	bfdd                	j	30a <memcmp+0x32>

0000000000000316 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e406                	sd	ra,8(sp)
 31a:	e022                	sd	s0,0(sp)
 31c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31e:	f5fff0ef          	jal	27c <memmove>
}
 322:	60a2                	ld	ra,8(sp)
 324:	6402                	ld	s0,0(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret

000000000000032a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 32a:	4885                	li	a7,1
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <exit>:
.global exit
exit:
 li a7, SYS_exit
 332:	4889                	li	a7,2
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <wait>:
.global wait
wait:
 li a7, SYS_wait
 33a:	488d                	li	a7,3
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 342:	4891                	li	a7,4
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <read>:
.global read
read:
 li a7, SYS_read
 34a:	4895                	li	a7,5
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <write>:
.global write
write:
 li a7, SYS_write
 352:	48c1                	li	a7,16
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <close>:
.global close
close:
 li a7, SYS_close
 35a:	48d5                	li	a7,21
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <kill>:
.global kill
kill:
 li a7, SYS_kill
 362:	4899                	li	a7,6
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <exec>:
.global exec
exec:
 li a7, SYS_exec
 36a:	489d                	li	a7,7
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <open>:
.global open
open:
 li a7, SYS_open
 372:	48bd                	li	a7,15
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 37a:	48c5                	li	a7,17
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 382:	48c9                	li	a7,18
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 38a:	48a1                	li	a7,8
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <link>:
.global link
link:
 li a7, SYS_link
 392:	48cd                	li	a7,19
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 39a:	48d1                	li	a7,20
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a2:	48a5                	li	a7,9
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <dup>:
.global dup
dup:
 li a7, SYS_dup
 3aa:	48a9                	li	a7,10
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b2:	48ad                	li	a7,11
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ba:	48b1                	li	a7,12
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c2:	48b5                	li	a7,13
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ca:	48b9                	li	a7,14
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <getSyscount>:
.global getSyscount
getSyscount:
 li a7, SYS_getSyscount
 3d2:	48d9                	li	a7,22
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 3da:	48dd                	li	a7,23
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 3e2:	48e1                	li	a7,24
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ea:	1101                	addi	sp,sp,-32
 3ec:	ec06                	sd	ra,24(sp)
 3ee:	e822                	sd	s0,16(sp)
 3f0:	1000                	addi	s0,sp,32
 3f2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f6:	4605                	li	a2,1
 3f8:	fef40593          	addi	a1,s0,-17
 3fc:	f57ff0ef          	jal	352 <write>
}
 400:	60e2                	ld	ra,24(sp)
 402:	6442                	ld	s0,16(sp)
 404:	6105                	addi	sp,sp,32
 406:	8082                	ret

0000000000000408 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 408:	7139                	addi	sp,sp,-64
 40a:	fc06                	sd	ra,56(sp)
 40c:	f822                	sd	s0,48(sp)
 40e:	f426                	sd	s1,40(sp)
 410:	f04a                	sd	s2,32(sp)
 412:	ec4e                	sd	s3,24(sp)
 414:	0080                	addi	s0,sp,64
 416:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 418:	c299                	beqz	a3,41e <printint+0x16>
 41a:	0605ce63          	bltz	a1,496 <printint+0x8e>
  neg = 0;
 41e:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 420:	fc040313          	addi	t1,s0,-64
  neg = 0;
 424:	869a                	mv	a3,t1
  i = 0;
 426:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 428:	00000817          	auipc	a6,0x0
 42c:	51080813          	addi	a6,a6,1296 # 938 <digits>
 430:	88be                	mv	a7,a5
 432:	0017851b          	addiw	a0,a5,1
 436:	87aa                	mv	a5,a0
 438:	02c5f73b          	remuw	a4,a1,a2
 43c:	1702                	slli	a4,a4,0x20
 43e:	9301                	srli	a4,a4,0x20
 440:	9742                	add	a4,a4,a6
 442:	00074703          	lbu	a4,0(a4)
 446:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 44a:	872e                	mv	a4,a1
 44c:	02c5d5bb          	divuw	a1,a1,a2
 450:	0685                	addi	a3,a3,1
 452:	fcc77fe3          	bgeu	a4,a2,430 <printint+0x28>
  if(neg)
 456:	000e0c63          	beqz	t3,46e <printint+0x66>
    buf[i++] = '-';
 45a:	fd050793          	addi	a5,a0,-48
 45e:	00878533          	add	a0,a5,s0
 462:	02d00793          	li	a5,45
 466:	fef50823          	sb	a5,-16(a0)
 46a:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 46e:	fff7899b          	addiw	s3,a5,-1
 472:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 476:	fff4c583          	lbu	a1,-1(s1)
 47a:	854a                	mv	a0,s2
 47c:	f6fff0ef          	jal	3ea <putc>
  while(--i >= 0)
 480:	39fd                	addiw	s3,s3,-1
 482:	14fd                	addi	s1,s1,-1
 484:	fe09d9e3          	bgez	s3,476 <printint+0x6e>
}
 488:	70e2                	ld	ra,56(sp)
 48a:	7442                	ld	s0,48(sp)
 48c:	74a2                	ld	s1,40(sp)
 48e:	7902                	ld	s2,32(sp)
 490:	69e2                	ld	s3,24(sp)
 492:	6121                	addi	sp,sp,64
 494:	8082                	ret
    x = -xx;
 496:	40b005bb          	negw	a1,a1
    neg = 1;
 49a:	4e05                	li	t3,1
    x = -xx;
 49c:	b751                	j	420 <printint+0x18>

000000000000049e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 49e:	711d                	addi	sp,sp,-96
 4a0:	ec86                	sd	ra,88(sp)
 4a2:	e8a2                	sd	s0,80(sp)
 4a4:	e4a6                	sd	s1,72(sp)
 4a6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a8:	0005c483          	lbu	s1,0(a1)
 4ac:	26048663          	beqz	s1,718 <vprintf+0x27a>
 4b0:	e0ca                	sd	s2,64(sp)
 4b2:	fc4e                	sd	s3,56(sp)
 4b4:	f852                	sd	s4,48(sp)
 4b6:	f456                	sd	s5,40(sp)
 4b8:	f05a                	sd	s6,32(sp)
 4ba:	ec5e                	sd	s7,24(sp)
 4bc:	e862                	sd	s8,16(sp)
 4be:	e466                	sd	s9,8(sp)
 4c0:	8b2a                	mv	s6,a0
 4c2:	8a2e                	mv	s4,a1
 4c4:	8bb2                	mv	s7,a2
  state = 0;
 4c6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4c8:	4901                	li	s2,0
 4ca:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4cc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4d0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4d4:	06c00c93          	li	s9,108
 4d8:	a00d                	j	4fa <vprintf+0x5c>
        putc(fd, c0);
 4da:	85a6                	mv	a1,s1
 4dc:	855a                	mv	a0,s6
 4de:	f0dff0ef          	jal	3ea <putc>
 4e2:	a019                	j	4e8 <vprintf+0x4a>
    } else if(state == '%'){
 4e4:	03598363          	beq	s3,s5,50a <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 4e8:	0019079b          	addiw	a5,s2,1
 4ec:	893e                	mv	s2,a5
 4ee:	873e                	mv	a4,a5
 4f0:	97d2                	add	a5,a5,s4
 4f2:	0007c483          	lbu	s1,0(a5)
 4f6:	20048963          	beqz	s1,708 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 4fa:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4fe:	fe0993e3          	bnez	s3,4e4 <vprintf+0x46>
      if(c0 == '%'){
 502:	fd579ce3          	bne	a5,s5,4da <vprintf+0x3c>
        state = '%';
 506:	89be                	mv	s3,a5
 508:	b7c5                	j	4e8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 50a:	00ea06b3          	add	a3,s4,a4
 50e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 512:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 514:	c681                	beqz	a3,51c <vprintf+0x7e>
 516:	9752                	add	a4,a4,s4
 518:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 51c:	03878e63          	beq	a5,s8,558 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 520:	05978863          	beq	a5,s9,570 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 524:	07500713          	li	a4,117
 528:	0ee78263          	beq	a5,a4,60c <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 52c:	07800713          	li	a4,120
 530:	12e78463          	beq	a5,a4,658 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 534:	07000713          	li	a4,112
 538:	14e78963          	beq	a5,a4,68a <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 53c:	07300713          	li	a4,115
 540:	18e78863          	beq	a5,a4,6d0 <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 544:	02500713          	li	a4,37
 548:	04e79463          	bne	a5,a4,590 <vprintf+0xf2>
        putc(fd, '%');
 54c:	85ba                	mv	a1,a4
 54e:	855a                	mv	a0,s6
 550:	e9bff0ef          	jal	3ea <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 554:	4981                	li	s3,0
 556:	bf49                	j	4e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 558:	008b8493          	addi	s1,s7,8
 55c:	4685                	li	a3,1
 55e:	4629                	li	a2,10
 560:	000ba583          	lw	a1,0(s7)
 564:	855a                	mv	a0,s6
 566:	ea3ff0ef          	jal	408 <printint>
 56a:	8ba6                	mv	s7,s1
      state = 0;
 56c:	4981                	li	s3,0
 56e:	bfad                	j	4e8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 570:	06400793          	li	a5,100
 574:	02f68963          	beq	a3,a5,5a6 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 578:	06c00793          	li	a5,108
 57c:	04f68263          	beq	a3,a5,5c0 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 580:	07500793          	li	a5,117
 584:	0af68063          	beq	a3,a5,624 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 588:	07800793          	li	a5,120
 58c:	0ef68263          	beq	a3,a5,670 <vprintf+0x1d2>
        putc(fd, '%');
 590:	02500593          	li	a1,37
 594:	855a                	mv	a0,s6
 596:	e55ff0ef          	jal	3ea <putc>
        putc(fd, c0);
 59a:	85a6                	mv	a1,s1
 59c:	855a                	mv	a0,s6
 59e:	e4dff0ef          	jal	3ea <putc>
      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	b791                	j	4e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a6:	008b8493          	addi	s1,s7,8
 5aa:	4685                	li	a3,1
 5ac:	4629                	li	a2,10
 5ae:	000ba583          	lw	a1,0(s7)
 5b2:	855a                	mv	a0,s6
 5b4:	e55ff0ef          	jal	408 <printint>
        i += 1;
 5b8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ba:	8ba6                	mv	s7,s1
      state = 0;
 5bc:	4981                	li	s3,0
        i += 1;
 5be:	b72d                	j	4e8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5c0:	06400793          	li	a5,100
 5c4:	02f60763          	beq	a2,a5,5f2 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5c8:	07500793          	li	a5,117
 5cc:	06f60963          	beq	a2,a5,63e <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5d0:	07800793          	li	a5,120
 5d4:	faf61ee3          	bne	a2,a5,590 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d8:	008b8493          	addi	s1,s7,8
 5dc:	4681                	li	a3,0
 5de:	4641                	li	a2,16
 5e0:	000ba583          	lw	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	e23ff0ef          	jal	408 <printint>
        i += 2;
 5ea:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ec:	8ba6                	mv	s7,s1
      state = 0;
 5ee:	4981                	li	s3,0
        i += 2;
 5f0:	bde5                	j	4e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f2:	008b8493          	addi	s1,s7,8
 5f6:	4685                	li	a3,1
 5f8:	4629                	li	a2,10
 5fa:	000ba583          	lw	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	e09ff0ef          	jal	408 <printint>
        i += 2;
 604:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 606:	8ba6                	mv	s7,s1
      state = 0;
 608:	4981                	li	s3,0
        i += 2;
 60a:	bdf9                	j	4e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 60c:	008b8493          	addi	s1,s7,8
 610:	4681                	li	a3,0
 612:	4629                	li	a2,10
 614:	000ba583          	lw	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	defff0ef          	jal	408 <printint>
 61e:	8ba6                	mv	s7,s1
      state = 0;
 620:	4981                	li	s3,0
 622:	b5d9                	j	4e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 624:	008b8493          	addi	s1,s7,8
 628:	4681                	li	a3,0
 62a:	4629                	li	a2,10
 62c:	000ba583          	lw	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	dd7ff0ef          	jal	408 <printint>
        i += 1;
 636:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 638:	8ba6                	mv	s7,s1
      state = 0;
 63a:	4981                	li	s3,0
        i += 1;
 63c:	b575                	j	4e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63e:	008b8493          	addi	s1,s7,8
 642:	4681                	li	a3,0
 644:	4629                	li	a2,10
 646:	000ba583          	lw	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	dbdff0ef          	jal	408 <printint>
        i += 2;
 650:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 652:	8ba6                	mv	s7,s1
      state = 0;
 654:	4981                	li	s3,0
        i += 2;
 656:	bd49                	j	4e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 658:	008b8493          	addi	s1,s7,8
 65c:	4681                	li	a3,0
 65e:	4641                	li	a2,16
 660:	000ba583          	lw	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	da3ff0ef          	jal	408 <printint>
 66a:	8ba6                	mv	s7,s1
      state = 0;
 66c:	4981                	li	s3,0
 66e:	bdad                	j	4e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 670:	008b8493          	addi	s1,s7,8
 674:	4681                	li	a3,0
 676:	4641                	li	a2,16
 678:	000ba583          	lw	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	d8bff0ef          	jal	408 <printint>
        i += 1;
 682:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 684:	8ba6                	mv	s7,s1
      state = 0;
 686:	4981                	li	s3,0
        i += 1;
 688:	b585                	j	4e8 <vprintf+0x4a>
 68a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 68c:	008b8d13          	addi	s10,s7,8
 690:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 694:	03000593          	li	a1,48
 698:	855a                	mv	a0,s6
 69a:	d51ff0ef          	jal	3ea <putc>
  putc(fd, 'x');
 69e:	07800593          	li	a1,120
 6a2:	855a                	mv	a0,s6
 6a4:	d47ff0ef          	jal	3ea <putc>
 6a8:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6aa:	00000b97          	auipc	s7,0x0
 6ae:	28eb8b93          	addi	s7,s7,654 # 938 <digits>
 6b2:	03c9d793          	srli	a5,s3,0x3c
 6b6:	97de                	add	a5,a5,s7
 6b8:	0007c583          	lbu	a1,0(a5)
 6bc:	855a                	mv	a0,s6
 6be:	d2dff0ef          	jal	3ea <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c2:	0992                	slli	s3,s3,0x4
 6c4:	34fd                	addiw	s1,s1,-1
 6c6:	f4f5                	bnez	s1,6b2 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 6c8:	8bea                	mv	s7,s10
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	6d02                	ld	s10,0(sp)
 6ce:	bd29                	j	4e8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6d0:	008b8993          	addi	s3,s7,8
 6d4:	000bb483          	ld	s1,0(s7)
 6d8:	cc91                	beqz	s1,6f4 <vprintf+0x256>
        for(; *s; s++)
 6da:	0004c583          	lbu	a1,0(s1)
 6de:	c195                	beqz	a1,702 <vprintf+0x264>
          putc(fd, *s);
 6e0:	855a                	mv	a0,s6
 6e2:	d09ff0ef          	jal	3ea <putc>
        for(; *s; s++)
 6e6:	0485                	addi	s1,s1,1
 6e8:	0004c583          	lbu	a1,0(s1)
 6ec:	f9f5                	bnez	a1,6e0 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6ee:	8bce                	mv	s7,s3
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	bbdd                	j	4e8 <vprintf+0x4a>
          s = "(null)";
 6f4:	00000497          	auipc	s1,0x0
 6f8:	23c48493          	addi	s1,s1,572 # 930 <malloc+0x12c>
        for(; *s; s++)
 6fc:	02800593          	li	a1,40
 700:	b7c5                	j	6e0 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 702:	8bce                	mv	s7,s3
      state = 0;
 704:	4981                	li	s3,0
 706:	b3cd                	j	4e8 <vprintf+0x4a>
 708:	6906                	ld	s2,64(sp)
 70a:	79e2                	ld	s3,56(sp)
 70c:	7a42                	ld	s4,48(sp)
 70e:	7aa2                	ld	s5,40(sp)
 710:	7b02                	ld	s6,32(sp)
 712:	6be2                	ld	s7,24(sp)
 714:	6c42                	ld	s8,16(sp)
 716:	6ca2                	ld	s9,8(sp)
    }
  }
}
 718:	60e6                	ld	ra,88(sp)
 71a:	6446                	ld	s0,80(sp)
 71c:	64a6                	ld	s1,72(sp)
 71e:	6125                	addi	sp,sp,96
 720:	8082                	ret

0000000000000722 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 722:	715d                	addi	sp,sp,-80
 724:	ec06                	sd	ra,24(sp)
 726:	e822                	sd	s0,16(sp)
 728:	1000                	addi	s0,sp,32
 72a:	e010                	sd	a2,0(s0)
 72c:	e414                	sd	a3,8(s0)
 72e:	e818                	sd	a4,16(s0)
 730:	ec1c                	sd	a5,24(s0)
 732:	03043023          	sd	a6,32(s0)
 736:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 73a:	8622                	mv	a2,s0
 73c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 740:	d5fff0ef          	jal	49e <vprintf>
}
 744:	60e2                	ld	ra,24(sp)
 746:	6442                	ld	s0,16(sp)
 748:	6161                	addi	sp,sp,80
 74a:	8082                	ret

000000000000074c <printf>:

void
printf(const char *fmt, ...)
{
 74c:	711d                	addi	sp,sp,-96
 74e:	ec06                	sd	ra,24(sp)
 750:	e822                	sd	s0,16(sp)
 752:	1000                	addi	s0,sp,32
 754:	e40c                	sd	a1,8(s0)
 756:	e810                	sd	a2,16(s0)
 758:	ec14                	sd	a3,24(s0)
 75a:	f018                	sd	a4,32(s0)
 75c:	f41c                	sd	a5,40(s0)
 75e:	03043823          	sd	a6,48(s0)
 762:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 766:	00840613          	addi	a2,s0,8
 76a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 76e:	85aa                	mv	a1,a0
 770:	4505                	li	a0,1
 772:	d2dff0ef          	jal	49e <vprintf>
}
 776:	60e2                	ld	ra,24(sp)
 778:	6442                	ld	s0,16(sp)
 77a:	6125                	addi	sp,sp,96
 77c:	8082                	ret

000000000000077e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77e:	1141                	addi	sp,sp,-16
 780:	e406                	sd	ra,8(sp)
 782:	e022                	sd	s0,0(sp)
 784:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 786:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78a:	00001797          	auipc	a5,0x1
 78e:	87e7b783          	ld	a5,-1922(a5) # 1008 <freep>
 792:	a02d                	j	7bc <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 794:	4618                	lw	a4,8(a2)
 796:	9f2d                	addw	a4,a4,a1
 798:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 79c:	6398                	ld	a4,0(a5)
 79e:	6310                	ld	a2,0(a4)
 7a0:	a83d                	j	7de <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a2:	ff852703          	lw	a4,-8(a0)
 7a6:	9f31                	addw	a4,a4,a2
 7a8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7aa:	ff053683          	ld	a3,-16(a0)
 7ae:	a091                	j	7f2 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b0:	6398                	ld	a4,0(a5)
 7b2:	00e7e463          	bltu	a5,a4,7ba <free+0x3c>
 7b6:	00e6ea63          	bltu	a3,a4,7ca <free+0x4c>
{
 7ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bc:	fed7fae3          	bgeu	a5,a3,7b0 <free+0x32>
 7c0:	6398                	ld	a4,0(a5)
 7c2:	00e6e463          	bltu	a3,a4,7ca <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c6:	fee7eae3          	bltu	a5,a4,7ba <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7ca:	ff852583          	lw	a1,-8(a0)
 7ce:	6390                	ld	a2,0(a5)
 7d0:	02059813          	slli	a6,a1,0x20
 7d4:	01c85713          	srli	a4,a6,0x1c
 7d8:	9736                	add	a4,a4,a3
 7da:	fae60de3          	beq	a2,a4,794 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 7de:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e2:	4790                	lw	a2,8(a5)
 7e4:	02061593          	slli	a1,a2,0x20
 7e8:	01c5d713          	srli	a4,a1,0x1c
 7ec:	973e                	add	a4,a4,a5
 7ee:	fae68ae3          	beq	a3,a4,7a2 <free+0x24>
    p->s.ptr = bp->s.ptr;
 7f2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f4:	00001717          	auipc	a4,0x1
 7f8:	80f73a23          	sd	a5,-2028(a4) # 1008 <freep>
}
 7fc:	60a2                	ld	ra,8(sp)
 7fe:	6402                	ld	s0,0(sp)
 800:	0141                	addi	sp,sp,16
 802:	8082                	ret

0000000000000804 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 804:	7139                	addi	sp,sp,-64
 806:	fc06                	sd	ra,56(sp)
 808:	f822                	sd	s0,48(sp)
 80a:	f04a                	sd	s2,32(sp)
 80c:	ec4e                	sd	s3,24(sp)
 80e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 810:	02051993          	slli	s3,a0,0x20
 814:	0209d993          	srli	s3,s3,0x20
 818:	09bd                	addi	s3,s3,15
 81a:	0049d993          	srli	s3,s3,0x4
 81e:	2985                	addiw	s3,s3,1
 820:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 822:	00000517          	auipc	a0,0x0
 826:	7e653503          	ld	a0,2022(a0) # 1008 <freep>
 82a:	c905                	beqz	a0,85a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82e:	4798                	lw	a4,8(a5)
 830:	09377663          	bgeu	a4,s3,8bc <malloc+0xb8>
 834:	f426                	sd	s1,40(sp)
 836:	e852                	sd	s4,16(sp)
 838:	e456                	sd	s5,8(sp)
 83a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 83c:	8a4e                	mv	s4,s3
 83e:	6705                	lui	a4,0x1
 840:	00e9f363          	bgeu	s3,a4,846 <malloc+0x42>
 844:	6a05                	lui	s4,0x1
 846:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 84a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84e:	00000497          	auipc	s1,0x0
 852:	7ba48493          	addi	s1,s1,1978 # 1008 <freep>
  if(p == (char*)-1)
 856:	5afd                	li	s5,-1
 858:	a83d                	j	896 <malloc+0x92>
 85a:	f426                	sd	s1,40(sp)
 85c:	e852                	sd	s4,16(sp)
 85e:	e456                	sd	s5,8(sp)
 860:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 862:	00000797          	auipc	a5,0x0
 866:	7ae78793          	addi	a5,a5,1966 # 1010 <base>
 86a:	00000717          	auipc	a4,0x0
 86e:	78f73f23          	sd	a5,1950(a4) # 1008 <freep>
 872:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 874:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 878:	b7d1                	j	83c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 87a:	6398                	ld	a4,0(a5)
 87c:	e118                	sd	a4,0(a0)
 87e:	a899                	j	8d4 <malloc+0xd0>
  hp->s.size = nu;
 880:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 884:	0541                	addi	a0,a0,16
 886:	ef9ff0ef          	jal	77e <free>
  return freep;
 88a:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 88c:	c125                	beqz	a0,8ec <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 890:	4798                	lw	a4,8(a5)
 892:	03277163          	bgeu	a4,s2,8b4 <malloc+0xb0>
    if(p == freep)
 896:	6098                	ld	a4,0(s1)
 898:	853e                	mv	a0,a5
 89a:	fef71ae3          	bne	a4,a5,88e <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 89e:	8552                	mv	a0,s4
 8a0:	b1bff0ef          	jal	3ba <sbrk>
  if(p == (char*)-1)
 8a4:	fd551ee3          	bne	a0,s5,880 <malloc+0x7c>
        return 0;
 8a8:	4501                	li	a0,0
 8aa:	74a2                	ld	s1,40(sp)
 8ac:	6a42                	ld	s4,16(sp)
 8ae:	6aa2                	ld	s5,8(sp)
 8b0:	6b02                	ld	s6,0(sp)
 8b2:	a03d                	j	8e0 <malloc+0xdc>
 8b4:	74a2                	ld	s1,40(sp)
 8b6:	6a42                	ld	s4,16(sp)
 8b8:	6aa2                	ld	s5,8(sp)
 8ba:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8bc:	fae90fe3          	beq	s2,a4,87a <malloc+0x76>
        p->s.size -= nunits;
 8c0:	4137073b          	subw	a4,a4,s3
 8c4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c6:	02071693          	slli	a3,a4,0x20
 8ca:	01c6d713          	srli	a4,a3,0x1c
 8ce:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d4:	00000717          	auipc	a4,0x0
 8d8:	72a73a23          	sd	a0,1844(a4) # 1008 <freep>
      return (void*)(p + 1);
 8dc:	01078513          	addi	a0,a5,16
  }
}
 8e0:	70e2                	ld	ra,56(sp)
 8e2:	7442                	ld	s0,48(sp)
 8e4:	7902                	ld	s2,32(sp)
 8e6:	69e2                	ld	s3,24(sp)
 8e8:	6121                	addi	sp,sp,64
 8ea:	8082                	ret
 8ec:	74a2                	ld	s1,40(sp)
 8ee:	6a42                	ld	s4,16(sp)
 8f0:	6aa2                	ld	s5,8(sp)
 8f2:	6b02                	ld	s6,0(sp)
 8f4:	b7f5                	j	8e0 <malloc+0xdc>
