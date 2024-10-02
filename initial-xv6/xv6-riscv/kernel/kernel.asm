
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	33013103          	ld	sp,816(sp) # 8000a330 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
// Machine Environment Configuration Register
static inline uint64
r_menvcfg()
{
  uint64 x;
  asm volatile("csrr %0, menvcfg" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4
}

static inline void 
w_menvcfg(uint64 x)
{
  asm volatile("csrw menvcfg, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw stimecmp, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda487>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e0078793          	addi	a5,a5,-512 # 80000e84 <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a6:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	711d                	addi	sp,sp,-96
    800000d6:	ec86                	sd	ra,88(sp)
    800000d8:	e8a2                	sd	s0,80(sp)
    800000da:	e0ca                	sd	s2,64(sp)
    800000dc:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    800000de:	04c05863          	blez	a2,8000012e <consolewrite+0x5a>
    800000e2:	e4a6                	sd	s1,72(sp)
    800000e4:	fc4e                	sd	s3,56(sp)
    800000e6:	f852                	sd	s4,48(sp)
    800000e8:	f456                	sd	s5,40(sp)
    800000ea:	f05a                	sd	s6,32(sp)
    800000ec:	ec5e                	sd	s7,24(sp)
    800000ee:	8a2a                	mv	s4,a0
    800000f0:	84ae                	mv	s1,a1
    800000f2:	89b2                	mv	s3,a2
    800000f4:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000f6:	faf40b93          	addi	s7,s0,-81
    800000fa:	4b05                	li	s6,1
    800000fc:	5afd                	li	s5,-1
    800000fe:	86da                	mv	a3,s6
    80000100:	8626                	mv	a2,s1
    80000102:	85d2                	mv	a1,s4
    80000104:	855e                	mv	a0,s7
    80000106:	150020ef          	jal	80002256 <either_copyin>
    8000010a:	03550463          	beq	a0,s5,80000132 <consolewrite+0x5e>
      break;
    uartputc(c);
    8000010e:	faf44503          	lbu	a0,-81(s0)
    80000112:	02d000ef          	jal	8000093e <uartputc>
  for(i = 0; i < n; i++){
    80000116:	2905                	addiw	s2,s2,1
    80000118:	0485                	addi	s1,s1,1
    8000011a:	ff2992e3          	bne	s3,s2,800000fe <consolewrite+0x2a>
    8000011e:	894e                	mv	s2,s3
    80000120:	64a6                	ld	s1,72(sp)
    80000122:	79e2                	ld	s3,56(sp)
    80000124:	7a42                	ld	s4,48(sp)
    80000126:	7aa2                	ld	s5,40(sp)
    80000128:	7b02                	ld	s6,32(sp)
    8000012a:	6be2                	ld	s7,24(sp)
    8000012c:	a809                	j	8000013e <consolewrite+0x6a>
    8000012e:	4901                	li	s2,0
    80000130:	a039                	j	8000013e <consolewrite+0x6a>
    80000132:	64a6                	ld	s1,72(sp)
    80000134:	79e2                	ld	s3,56(sp)
    80000136:	7a42                	ld	s4,48(sp)
    80000138:	7aa2                	ld	s5,40(sp)
    8000013a:	7b02                	ld	s6,32(sp)
    8000013c:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60e6                	ld	ra,88(sp)
    80000142:	6446                	ld	s0,80(sp)
    80000144:	6906                	ld	s2,64(sp)
    80000146:	6125                	addi	sp,sp,96
    80000148:	8082                	ret

000000008000014a <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014a:	711d                	addi	sp,sp,-96
    8000014c:	ec86                	sd	ra,88(sp)
    8000014e:	e8a2                	sd	s0,80(sp)
    80000150:	e4a6                	sd	s1,72(sp)
    80000152:	e0ca                	sd	s2,64(sp)
    80000154:	fc4e                	sd	s3,56(sp)
    80000156:	f852                	sd	s4,48(sp)
    80000158:	f456                	sd	s5,40(sp)
    8000015a:	f05a                	sd	s6,32(sp)
    8000015c:	1080                	addi	s0,sp,96
    8000015e:	8aaa                	mv	s5,a0
    80000160:	8a2e                	mv	s4,a1
    80000162:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000164:	8b32                	mv	s6,a2
  acquire(&cons.lock);
    80000166:	00012517          	auipc	a0,0x12
    8000016a:	22a50513          	addi	a0,a0,554 # 80012390 <cons>
    8000016e:	291000ef          	jal	80000bfe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000172:	00012497          	auipc	s1,0x12
    80000176:	21e48493          	addi	s1,s1,542 # 80012390 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000017a:	00012917          	auipc	s2,0x12
    8000017e:	2ae90913          	addi	s2,s2,686 # 80012428 <cons+0x98>
  while(n > 0){
    80000182:	0b305b63          	blez	s3,80000238 <consoleread+0xee>
    while(cons.r == cons.w){
    80000186:	0984a783          	lw	a5,152(s1)
    8000018a:	09c4a703          	lw	a4,156(s1)
    8000018e:	0af71063          	bne	a4,a5,8000022e <consoleread+0xe4>
      if(killed(myproc())){
    80000192:	73e010ef          	jal	800018d0 <myproc>
    80000196:	759010ef          	jal	800020ee <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	517010ef          	jal	80001eb6 <sleep>
    while(cons.r == cons.w){
    800001a4:	0984a783          	lw	a5,152(s1)
    800001a8:	09c4a703          	lw	a4,156(s1)
    800001ac:	fef703e3          	beq	a4,a5,80000192 <consoleread+0x48>
    800001b0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001b2:	00012717          	auipc	a4,0x12
    800001b6:	1de70713          	addi	a4,a4,478 # 80012390 <cons>
    800001ba:	0017869b          	addiw	a3,a5,1
    800001be:	08d72c23          	sw	a3,152(a4)
    800001c2:	07f7f693          	andi	a3,a5,127
    800001c6:	9736                	add	a4,a4,a3
    800001c8:	01874703          	lbu	a4,24(a4)
    800001cc:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001d0:	4691                	li	a3,4
    800001d2:	04db8663          	beq	s7,a3,8000021e <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001d6:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001da:	4685                	li	a3,1
    800001dc:	faf40613          	addi	a2,s0,-81
    800001e0:	85d2                	mv	a1,s4
    800001e2:	8556                	mv	a0,s5
    800001e4:	028020ef          	jal	8000220c <either_copyout>
    800001e8:	57fd                	li	a5,-1
    800001ea:	04f50663          	beq	a0,a5,80000236 <consoleread+0xec>
      break;

    dst++;
    800001ee:	0a05                	addi	s4,s4,1
    --n;
    800001f0:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001f2:	47a9                	li	a5,10
    800001f4:	04fb8b63          	beq	s7,a5,8000024a <consoleread+0x100>
    800001f8:	6be2                	ld	s7,24(sp)
    800001fa:	b761                	j	80000182 <consoleread+0x38>
        release(&cons.lock);
    800001fc:	00012517          	auipc	a0,0x12
    80000200:	19450513          	addi	a0,a0,404 # 80012390 <cons>
    80000204:	28f000ef          	jal	80000c92 <release>
        return -1;
    80000208:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000020a:	60e6                	ld	ra,88(sp)
    8000020c:	6446                	ld	s0,80(sp)
    8000020e:	64a6                	ld	s1,72(sp)
    80000210:	6906                	ld	s2,64(sp)
    80000212:	79e2                	ld	s3,56(sp)
    80000214:	7a42                	ld	s4,48(sp)
    80000216:	7aa2                	ld	s5,40(sp)
    80000218:	7b02                	ld	s6,32(sp)
    8000021a:	6125                	addi	sp,sp,96
    8000021c:	8082                	ret
      if(n < target){
    8000021e:	0169fa63          	bgeu	s3,s6,80000232 <consoleread+0xe8>
        cons.r--;
    80000222:	00012717          	auipc	a4,0x12
    80000226:	20f72323          	sw	a5,518(a4) # 80012428 <cons+0x98>
    8000022a:	6be2                	ld	s7,24(sp)
    8000022c:	a031                	j	80000238 <consoleread+0xee>
    8000022e:	ec5e                	sd	s7,24(sp)
    80000230:	b749                	j	800001b2 <consoleread+0x68>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	a011                	j	80000238 <consoleread+0xee>
    80000236:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	15850513          	addi	a0,a0,344 # 80012390 <cons>
    80000240:	253000ef          	jal	80000c92 <release>
  return target - n;
    80000244:	413b053b          	subw	a0,s6,s3
    80000248:	b7c9                	j	8000020a <consoleread+0xc0>
    8000024a:	6be2                	ld	s7,24(sp)
    8000024c:	b7f5                	j	80000238 <consoleread+0xee>

000000008000024e <consputc>:
{
    8000024e:	1141                	addi	sp,sp,-16
    80000250:	e406                	sd	ra,8(sp)
    80000252:	e022                	sd	s0,0(sp)
    80000254:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000256:	10000793          	li	a5,256
    8000025a:	00f50863          	beq	a0,a5,8000026a <consputc+0x1c>
    uartputc_sync(c);
    8000025e:	5fe000ef          	jal	8000085c <uartputc_sync>
}
    80000262:	60a2                	ld	ra,8(sp)
    80000264:	6402                	ld	s0,0(sp)
    80000266:	0141                	addi	sp,sp,16
    80000268:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000026a:	4521                	li	a0,8
    8000026c:	5f0000ef          	jal	8000085c <uartputc_sync>
    80000270:	02000513          	li	a0,32
    80000274:	5e8000ef          	jal	8000085c <uartputc_sync>
    80000278:	4521                	li	a0,8
    8000027a:	5e2000ef          	jal	8000085c <uartputc_sync>
    8000027e:	b7d5                	j	80000262 <consputc+0x14>

0000000080000280 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000280:	7179                	addi	sp,sp,-48
    80000282:	f406                	sd	ra,40(sp)
    80000284:	f022                	sd	s0,32(sp)
    80000286:	ec26                	sd	s1,24(sp)
    80000288:	1800                	addi	s0,sp,48
    8000028a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000028c:	00012517          	auipc	a0,0x12
    80000290:	10450513          	addi	a0,a0,260 # 80012390 <cons>
    80000294:	16b000ef          	jal	80000bfe <acquire>

  switch(c){
    80000298:	47d5                	li	a5,21
    8000029a:	08f48e63          	beq	s1,a5,80000336 <consoleintr+0xb6>
    8000029e:	0297c563          	blt	a5,s1,800002c8 <consoleintr+0x48>
    800002a2:	47a1                	li	a5,8
    800002a4:	0ef48863          	beq	s1,a5,80000394 <consoleintr+0x114>
    800002a8:	47c1                	li	a5,16
    800002aa:	10f49963          	bne	s1,a5,800003bc <consoleintr+0x13c>
  case C('P'):  // Print process list.
    procdump();
    800002ae:	7f3010ef          	jal	800022a0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002b2:	00012517          	auipc	a0,0x12
    800002b6:	0de50513          	addi	a0,a0,222 # 80012390 <cons>
    800002ba:	1d9000ef          	jal	80000c92 <release>
}
    800002be:	70a2                	ld	ra,40(sp)
    800002c0:	7402                	ld	s0,32(sp)
    800002c2:	64e2                	ld	s1,24(sp)
    800002c4:	6145                	addi	sp,sp,48
    800002c6:	8082                	ret
  switch(c){
    800002c8:	07f00793          	li	a5,127
    800002cc:	0cf48463          	beq	s1,a5,80000394 <consoleintr+0x114>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002d0:	00012717          	auipc	a4,0x12
    800002d4:	0c070713          	addi	a4,a4,192 # 80012390 <cons>
    800002d8:	0a072783          	lw	a5,160(a4)
    800002dc:	09872703          	lw	a4,152(a4)
    800002e0:	9f99                	subw	a5,a5,a4
    800002e2:	07f00713          	li	a4,127
    800002e6:	fcf766e3          	bltu	a4,a5,800002b2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002ea:	47b5                	li	a5,13
    800002ec:	0cf48b63          	beq	s1,a5,800003c2 <consoleintr+0x142>
      consputc(c);
    800002f0:	8526                	mv	a0,s1
    800002f2:	f5dff0ef          	jal	8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002f6:	00012797          	auipc	a5,0x12
    800002fa:	09a78793          	addi	a5,a5,154 # 80012390 <cons>
    800002fe:	0a07a683          	lw	a3,160(a5)
    80000302:	0016871b          	addiw	a4,a3,1
    80000306:	863a                	mv	a2,a4
    80000308:	0ae7a023          	sw	a4,160(a5)
    8000030c:	07f6f693          	andi	a3,a3,127
    80000310:	97b6                	add	a5,a5,a3
    80000312:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000316:	47a9                	li	a5,10
    80000318:	0cf48963          	beq	s1,a5,800003ea <consoleintr+0x16a>
    8000031c:	4791                	li	a5,4
    8000031e:	0cf48663          	beq	s1,a5,800003ea <consoleintr+0x16a>
    80000322:	00012797          	auipc	a5,0x12
    80000326:	1067a783          	lw	a5,262(a5) # 80012428 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f8f711e3          	bne	a4,a5,800002b2 <consoleintr+0x32>
    80000334:	a85d                	j	800003ea <consoleintr+0x16a>
    80000336:	e84a                	sd	s2,16(sp)
    80000338:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    8000033a:	00012717          	auipc	a4,0x12
    8000033e:	05670713          	addi	a4,a4,86 # 80012390 <cons>
    80000342:	0a072783          	lw	a5,160(a4)
    80000346:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	00012497          	auipc	s1,0x12
    8000034e:	04648493          	addi	s1,s1,70 # 80012390 <cons>
    while(cons.e != cons.w &&
    80000352:	4929                	li	s2,10
      consputc(BACKSPACE);
    80000354:	10000993          	li	s3,256
    while(cons.e != cons.w &&
    80000358:	02f70863          	beq	a4,a5,80000388 <consoleintr+0x108>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000035c:	37fd                	addiw	a5,a5,-1
    8000035e:	07f7f713          	andi	a4,a5,127
    80000362:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000364:	01874703          	lbu	a4,24(a4)
    80000368:	03270363          	beq	a4,s2,8000038e <consoleintr+0x10e>
      cons.e--;
    8000036c:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000370:	854e                	mv	a0,s3
    80000372:	eddff0ef          	jal	8000024e <consputc>
    while(cons.e != cons.w &&
    80000376:	0a04a783          	lw	a5,160(s1)
    8000037a:	09c4a703          	lw	a4,156(s1)
    8000037e:	fcf71fe3          	bne	a4,a5,8000035c <consoleintr+0xdc>
    80000382:	6942                	ld	s2,16(sp)
    80000384:	69a2                	ld	s3,8(sp)
    80000386:	b735                	j	800002b2 <consoleintr+0x32>
    80000388:	6942                	ld	s2,16(sp)
    8000038a:	69a2                	ld	s3,8(sp)
    8000038c:	b71d                	j	800002b2 <consoleintr+0x32>
    8000038e:	6942                	ld	s2,16(sp)
    80000390:	69a2                	ld	s3,8(sp)
    80000392:	b705                	j	800002b2 <consoleintr+0x32>
    if(cons.e != cons.w){
    80000394:	00012717          	auipc	a4,0x12
    80000398:	ffc70713          	addi	a4,a4,-4 # 80012390 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
    800003a4:	f0f707e3          	beq	a4,a5,800002b2 <consoleintr+0x32>
      cons.e--;
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	00012717          	auipc	a4,0x12
    800003ae:	08f72323          	sw	a5,134(a4) # 80012430 <cons+0xa0>
      consputc(BACKSPACE);
    800003b2:	10000513          	li	a0,256
    800003b6:	e99ff0ef          	jal	8000024e <consputc>
    800003ba:	bde5                	j	800002b2 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003bc:	ee048be3          	beqz	s1,800002b2 <consoleintr+0x32>
    800003c0:	bf01                	j	800002d0 <consoleintr+0x50>
      consputc(c);
    800003c2:	4529                	li	a0,10
    800003c4:	e8bff0ef          	jal	8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003c8:	00012797          	auipc	a5,0x12
    800003cc:	fc878793          	addi	a5,a5,-56 # 80012390 <cons>
    800003d0:	0a07a703          	lw	a4,160(a5)
    800003d4:	0017069b          	addiw	a3,a4,1
    800003d8:	8636                	mv	a2,a3
    800003da:	0ad7a023          	sw	a3,160(a5)
    800003de:	07f77713          	andi	a4,a4,127
    800003e2:	97ba                	add	a5,a5,a4
    800003e4:	4729                	li	a4,10
    800003e6:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003ea:	00012797          	auipc	a5,0x12
    800003ee:	04c7a123          	sw	a2,66(a5) # 8001242c <cons+0x9c>
        wakeup(&cons.r);
    800003f2:	00012517          	auipc	a0,0x12
    800003f6:	03650513          	addi	a0,a0,54 # 80012428 <cons+0x98>
    800003fa:	309010ef          	jal	80001f02 <wakeup>
    800003fe:	bd55                	j	800002b2 <consoleintr+0x32>

0000000080000400 <consoleinit>:

void
consoleinit(void)
{
    80000400:	1141                	addi	sp,sp,-16
    80000402:	e406                	sd	ra,8(sp)
    80000404:	e022                	sd	s0,0(sp)
    80000406:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000408:	00007597          	auipc	a1,0x7
    8000040c:	bf858593          	addi	a1,a1,-1032 # 80007000 <etext>
    80000410:	00012517          	auipc	a0,0x12
    80000414:	f8050513          	addi	a0,a0,-128 # 80012390 <cons>
    80000418:	762000ef          	jal	80000b7a <initlock>

  uartinit();
    8000041c:	3ea000ef          	jal	80000806 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000420:	00023797          	auipc	a5,0x23
    80000424:	dc078793          	addi	a5,a5,-576 # 800231e0 <devsw>
    80000428:	00000717          	auipc	a4,0x0
    8000042c:	d2270713          	addi	a4,a4,-734 # 8000014a <consoleread>
    80000430:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000432:	00000717          	auipc	a4,0x0
    80000436:	ca270713          	addi	a4,a4,-862 # 800000d4 <consolewrite>
    8000043a:	ef98                	sd	a4,24(a5)
}
    8000043c:	60a2                	ld	ra,8(sp)
    8000043e:	6402                	ld	s0,0(sp)
    80000440:	0141                	addi	sp,sp,16
    80000442:	8082                	ret

0000000080000444 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000444:	7179                	addi	sp,sp,-48
    80000446:	f406                	sd	ra,40(sp)
    80000448:	f022                	sd	s0,32(sp)
    8000044a:	ec26                	sd	s1,24(sp)
    8000044c:	e84a                	sd	s2,16(sp)
    8000044e:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000450:	c219                	beqz	a2,80000456 <printint+0x12>
    80000452:	06054a63          	bltz	a0,800004c6 <printint+0x82>
    x = -xx;
  else
    x = xx;
    80000456:	4e01                	li	t3,0

  i = 0;
    80000458:	fd040313          	addi	t1,s0,-48
    x = xx;
    8000045c:	869a                	mv	a3,t1
  i = 0;
    8000045e:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000460:	00007817          	auipc	a6,0x7
    80000464:	31880813          	addi	a6,a6,792 # 80007778 <digits>
    80000468:	88be                	mv	a7,a5
    8000046a:	0017861b          	addiw	a2,a5,1
    8000046e:	87b2                	mv	a5,a2
    80000470:	02b57733          	remu	a4,a0,a1
    80000474:	9742                	add	a4,a4,a6
    80000476:	00074703          	lbu	a4,0(a4)
    8000047a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000047e:	872a                	mv	a4,a0
    80000480:	02b55533          	divu	a0,a0,a1
    80000484:	0685                	addi	a3,a3,1
    80000486:	feb771e3          	bgeu	a4,a1,80000468 <printint+0x24>

  if(sign)
    8000048a:	000e0c63          	beqz	t3,800004a2 <printint+0x5e>
    buf[i++] = '-';
    8000048e:	fe060793          	addi	a5,a2,-32
    80000492:	00878633          	add	a2,a5,s0
    80000496:	02d00793          	li	a5,45
    8000049a:	fef60823          	sb	a5,-16(a2)
    8000049e:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    800004a2:	fff7891b          	addiw	s2,a5,-1
    800004a6:	006784b3          	add	s1,a5,t1
    consputc(buf[i]);
    800004aa:	fff4c503          	lbu	a0,-1(s1)
    800004ae:	da1ff0ef          	jal	8000024e <consputc>
  while(--i >= 0)
    800004b2:	397d                	addiw	s2,s2,-1
    800004b4:	14fd                	addi	s1,s1,-1
    800004b6:	fe095ae3          	bgez	s2,800004aa <printint+0x66>
}
    800004ba:	70a2                	ld	ra,40(sp)
    800004bc:	7402                	ld	s0,32(sp)
    800004be:	64e2                	ld	s1,24(sp)
    800004c0:	6942                	ld	s2,16(sp)
    800004c2:	6145                	addi	sp,sp,48
    800004c4:	8082                	ret
    x = -xx;
    800004c6:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004ca:	4e05                	li	t3,1
    x = -xx;
    800004cc:	b771                	j	80000458 <printint+0x14>

00000000800004ce <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004ce:	7155                	addi	sp,sp,-208
    800004d0:	e506                	sd	ra,136(sp)
    800004d2:	e122                	sd	s0,128(sp)
    800004d4:	f0d2                	sd	s4,96(sp)
    800004d6:	0900                	addi	s0,sp,144
    800004d8:	8a2a                	mv	s4,a0
    800004da:	e40c                	sd	a1,8(s0)
    800004dc:	e810                	sd	a2,16(s0)
    800004de:	ec14                	sd	a3,24(s0)
    800004e0:	f018                	sd	a4,32(s0)
    800004e2:	f41c                	sd	a5,40(s0)
    800004e4:	03043823          	sd	a6,48(s0)
    800004e8:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004ec:	00012797          	auipc	a5,0x12
    800004f0:	f647a783          	lw	a5,-156(a5) # 80012450 <pr+0x18>
    800004f4:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004f8:	e3a1                	bnez	a5,80000538 <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004fa:	00840793          	addi	a5,s0,8
    800004fe:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000502:	00054503          	lbu	a0,0(a0)
    80000506:	26050663          	beqz	a0,80000772 <printf+0x2a4>
    8000050a:	fca6                	sd	s1,120(sp)
    8000050c:	f8ca                	sd	s2,112(sp)
    8000050e:	f4ce                	sd	s3,104(sp)
    80000510:	ecd6                	sd	s5,88(sp)
    80000512:	e8da                	sd	s6,80(sp)
    80000514:	e0e2                	sd	s8,64(sp)
    80000516:	fc66                	sd	s9,56(sp)
    80000518:	f86a                	sd	s10,48(sp)
    8000051a:	f46e                	sd	s11,40(sp)
    8000051c:	4981                	li	s3,0
    if(cx != '%'){
    8000051e:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000522:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000526:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000052a:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000052e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000532:	07000d93          	li	s11,112
    80000536:	a80d                	j	80000568 <printf+0x9a>
    acquire(&pr.lock);
    80000538:	00012517          	auipc	a0,0x12
    8000053c:	f0050513          	addi	a0,a0,-256 # 80012438 <pr>
    80000540:	6be000ef          	jal	80000bfe <acquire>
  va_start(ap, fmt);
    80000544:	00840793          	addi	a5,s0,8
    80000548:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054c:	000a4503          	lbu	a0,0(s4)
    80000550:	fd4d                	bnez	a0,8000050a <printf+0x3c>
    80000552:	ac3d                	j	80000790 <printf+0x2c2>
      consputc(cx);
    80000554:	cfbff0ef          	jal	8000024e <consputc>
      continue;
    80000558:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000055a:	2485                	addiw	s1,s1,1
    8000055c:	89a6                	mv	s3,s1
    8000055e:	94d2                	add	s1,s1,s4
    80000560:	0004c503          	lbu	a0,0(s1)
    80000564:	1e050b63          	beqz	a0,8000075a <printf+0x28c>
    if(cx != '%'){
    80000568:	ff5516e3          	bne	a0,s5,80000554 <printf+0x86>
    i++;
    8000056c:	0019879b          	addiw	a5,s3,1
    80000570:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    80000572:	00fa0733          	add	a4,s4,a5
    80000576:	00074903          	lbu	s2,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000057a:	1e090063          	beqz	s2,8000075a <printf+0x28c>
    8000057e:	00174703          	lbu	a4,1(a4)
    c1 = c2 = 0;
    80000582:	86ba                	mv	a3,a4
    if(c1) c2 = fmt[i+2] & 0xff;
    80000584:	c701                	beqz	a4,8000058c <printf+0xbe>
    80000586:	97d2                	add	a5,a5,s4
    80000588:	0027c683          	lbu	a3,2(a5)
    if(c0 == 'd'){
    8000058c:	03690763          	beq	s2,s6,800005ba <printf+0xec>
    } else if(c0 == 'l' && c1 == 'd'){
    80000590:	05890163          	beq	s2,s8,800005d2 <printf+0x104>
    } else if(c0 == 'u'){
    80000594:	0d990b63          	beq	s2,s9,8000066a <printf+0x19c>
    } else if(c0 == 'x'){
    80000598:	13a90163          	beq	s2,s10,800006ba <printf+0x1ec>
    } else if(c0 == 'p'){
    8000059c:	13b90b63          	beq	s2,s11,800006d2 <printf+0x204>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800005a0:	07300793          	li	a5,115
    800005a4:	16f90a63          	beq	s2,a5,80000718 <printf+0x24a>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005a8:	1b590463          	beq	s2,s5,80000750 <printf+0x282>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005ac:	8556                	mv	a0,s5
    800005ae:	ca1ff0ef          	jal	8000024e <consputc>
      consputc(c0);
    800005b2:	854a                	mv	a0,s2
    800005b4:	c9bff0ef          	jal	8000024e <consputc>
    800005b8:	b74d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005ba:	f8843783          	ld	a5,-120(s0)
    800005be:	00878713          	addi	a4,a5,8
    800005c2:	f8e43423          	sd	a4,-120(s0)
    800005c6:	4605                	li	a2,1
    800005c8:	45a9                	li	a1,10
    800005ca:	4388                	lw	a0,0(a5)
    800005cc:	e79ff0ef          	jal	80000444 <printint>
    800005d0:	b769                	j	8000055a <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005d2:	03670663          	beq	a4,s6,800005fe <printf+0x130>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005d6:	05870263          	beq	a4,s8,8000061a <printf+0x14c>
    } else if(c0 == 'l' && c1 == 'u'){
    800005da:	0b970463          	beq	a4,s9,80000682 <printf+0x1b4>
    } else if(c0 == 'l' && c1 == 'x'){
    800005de:	fda717e3          	bne	a4,s10,800005ac <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    800005e2:	f8843783          	ld	a5,-120(s0)
    800005e6:	00878713          	addi	a4,a5,8
    800005ea:	f8e43423          	sd	a4,-120(s0)
    800005ee:	4601                	li	a2,0
    800005f0:	45c1                	li	a1,16
    800005f2:	6388                	ld	a0,0(a5)
    800005f4:	e51ff0ef          	jal	80000444 <printint>
      i += 1;
    800005f8:	0029849b          	addiw	s1,s3,2
    800005fc:	bfb9                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005fe:	f8843783          	ld	a5,-120(s0)
    80000602:	00878713          	addi	a4,a5,8
    80000606:	f8e43423          	sd	a4,-120(s0)
    8000060a:	4605                	li	a2,1
    8000060c:	45a9                	li	a1,10
    8000060e:	6388                	ld	a0,0(a5)
    80000610:	e35ff0ef          	jal	80000444 <printint>
      i += 1;
    80000614:	0029849b          	addiw	s1,s3,2
    80000618:	b789                	j	8000055a <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000061a:	06400793          	li	a5,100
    8000061e:	02f68863          	beq	a3,a5,8000064e <printf+0x180>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000622:	07500793          	li	a5,117
    80000626:	06f68c63          	beq	a3,a5,8000069e <printf+0x1d0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000062a:	07800793          	li	a5,120
    8000062e:	f6f69fe3          	bne	a3,a5,800005ac <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    80000632:	f8843783          	ld	a5,-120(s0)
    80000636:	00878713          	addi	a4,a5,8
    8000063a:	f8e43423          	sd	a4,-120(s0)
    8000063e:	4601                	li	a2,0
    80000640:	45c1                	li	a1,16
    80000642:	6388                	ld	a0,0(a5)
    80000644:	e01ff0ef          	jal	80000444 <printint>
      i += 2;
    80000648:	0039849b          	addiw	s1,s3,3
    8000064c:	b739                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    8000064e:	f8843783          	ld	a5,-120(s0)
    80000652:	00878713          	addi	a4,a5,8
    80000656:	f8e43423          	sd	a4,-120(s0)
    8000065a:	4605                	li	a2,1
    8000065c:	45a9                	li	a1,10
    8000065e:	6388                	ld	a0,0(a5)
    80000660:	de5ff0ef          	jal	80000444 <printint>
      i += 2;
    80000664:	0039849b          	addiw	s1,s3,3
    80000668:	bdcd                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000066a:	f8843783          	ld	a5,-120(s0)
    8000066e:	00878713          	addi	a4,a5,8
    80000672:	f8e43423          	sd	a4,-120(s0)
    80000676:	4601                	li	a2,0
    80000678:	45a9                	li	a1,10
    8000067a:	4388                	lw	a0,0(a5)
    8000067c:	dc9ff0ef          	jal	80000444 <printint>
    80000680:	bde9                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4601                	li	a2,0
    80000690:	45a9                	li	a1,10
    80000692:	6388                	ld	a0,0(a5)
    80000694:	db1ff0ef          	jal	80000444 <printint>
      i += 1;
    80000698:	0029849b          	addiw	s1,s3,2
    8000069c:	bd7d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	4601                	li	a2,0
    800006ac:	45a9                	li	a1,10
    800006ae:	6388                	ld	a0,0(a5)
    800006b0:	d95ff0ef          	jal	80000444 <printint>
      i += 2;
    800006b4:	0039849b          	addiw	s1,s3,3
    800006b8:	b54d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006ba:	f8843783          	ld	a5,-120(s0)
    800006be:	00878713          	addi	a4,a5,8
    800006c2:	f8e43423          	sd	a4,-120(s0)
    800006c6:	4601                	li	a2,0
    800006c8:	45c1                	li	a1,16
    800006ca:	4388                	lw	a0,0(a5)
    800006cc:	d79ff0ef          	jal	80000444 <printint>
    800006d0:	b569                	j	8000055a <printf+0x8c>
    800006d2:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006d4:	f8843783          	ld	a5,-120(s0)
    800006d8:	00878713          	addi	a4,a5,8
    800006dc:	f8e43423          	sd	a4,-120(s0)
    800006e0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006e4:	03000513          	li	a0,48
    800006e8:	b67ff0ef          	jal	8000024e <consputc>
  consputc('x');
    800006ec:	07800513          	li	a0,120
    800006f0:	b5fff0ef          	jal	8000024e <consputc>
    800006f4:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f6:	00007b97          	auipc	s7,0x7
    800006fa:	082b8b93          	addi	s7,s7,130 # 80007778 <digits>
    800006fe:	03c9d793          	srli	a5,s3,0x3c
    80000702:	97de                	add	a5,a5,s7
    80000704:	0007c503          	lbu	a0,0(a5)
    80000708:	b47ff0ef          	jal	8000024e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070c:	0992                	slli	s3,s3,0x4
    8000070e:	397d                	addiw	s2,s2,-1
    80000710:	fe0917e3          	bnez	s2,800006fe <printf+0x230>
    80000714:	6ba6                	ld	s7,72(sp)
    80000716:	b591                	j	8000055a <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007b903          	ld	s2,0(a5)
    80000728:	00090d63          	beqz	s2,80000742 <printf+0x274>
      for(; *s; s++)
    8000072c:	00094503          	lbu	a0,0(s2)
    80000730:	e20505e3          	beqz	a0,8000055a <printf+0x8c>
        consputc(*s);
    80000734:	b1bff0ef          	jal	8000024e <consputc>
      for(; *s; s++)
    80000738:	0905                	addi	s2,s2,1
    8000073a:	00094503          	lbu	a0,0(s2)
    8000073e:	f97d                	bnez	a0,80000734 <printf+0x266>
    80000740:	bd29                	j	8000055a <printf+0x8c>
        s = "(null)";
    80000742:	00007917          	auipc	s2,0x7
    80000746:	8c690913          	addi	s2,s2,-1850 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printf+0x266>
      consputc('%');
    80000750:	02500513          	li	a0,37
    80000754:	afbff0ef          	jal	8000024e <consputc>
    80000758:	b509                	j	8000055a <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000075a:	f7843783          	ld	a5,-136(s0)
    8000075e:	e385                	bnez	a5,8000077e <printf+0x2b0>
    80000760:	74e6                	ld	s1,120(sp)
    80000762:	7946                	ld	s2,112(sp)
    80000764:	79a6                	ld	s3,104(sp)
    80000766:	6ae6                	ld	s5,88(sp)
    80000768:	6b46                	ld	s6,80(sp)
    8000076a:	6c06                	ld	s8,64(sp)
    8000076c:	7ce2                	ld	s9,56(sp)
    8000076e:	7d42                	ld	s10,48(sp)
    80000770:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000772:	4501                	li	a0,0
    80000774:	60aa                	ld	ra,136(sp)
    80000776:	640a                	ld	s0,128(sp)
    80000778:	7a06                	ld	s4,96(sp)
    8000077a:	6169                	addi	sp,sp,208
    8000077c:	8082                	ret
    8000077e:	74e6                	ld	s1,120(sp)
    80000780:	7946                	ld	s2,112(sp)
    80000782:	79a6                	ld	s3,104(sp)
    80000784:	6ae6                	ld	s5,88(sp)
    80000786:	6b46                	ld	s6,80(sp)
    80000788:	6c06                	ld	s8,64(sp)
    8000078a:	7ce2                	ld	s9,56(sp)
    8000078c:	7d42                	ld	s10,48(sp)
    8000078e:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000790:	00012517          	auipc	a0,0x12
    80000794:	ca850513          	addi	a0,a0,-856 # 80012438 <pr>
    80000798:	4fa000ef          	jal	80000c92 <release>
    8000079c:	bfd9                	j	80000772 <printf+0x2a4>

000000008000079e <panic>:

void
panic(char *s)
{
    8000079e:	1101                	addi	sp,sp,-32
    800007a0:	ec06                	sd	ra,24(sp)
    800007a2:	e822                	sd	s0,16(sp)
    800007a4:	e426                	sd	s1,8(sp)
    800007a6:	1000                	addi	s0,sp,32
    800007a8:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007aa:	00012797          	auipc	a5,0x12
    800007ae:	ca07a323          	sw	zero,-858(a5) # 80012450 <pr+0x18>
  printf("panic: ");
    800007b2:	00007517          	auipc	a0,0x7
    800007b6:	86650513          	addi	a0,a0,-1946 # 80007018 <etext+0x18>
    800007ba:	d15ff0ef          	jal	800004ce <printf>
  printf("%s\n", s);
    800007be:	85a6                	mv	a1,s1
    800007c0:	00007517          	auipc	a0,0x7
    800007c4:	86050513          	addi	a0,a0,-1952 # 80007020 <etext+0x20>
    800007c8:	d07ff0ef          	jal	800004ce <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007cc:	4785                	li	a5,1
    800007ce:	0000a717          	auipc	a4,0xa
    800007d2:	b8f72123          	sw	a5,-1150(a4) # 8000a350 <panicked>
  for(;;)
    800007d6:	a001                	j	800007d6 <panic+0x38>

00000000800007d8 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007d8:	1101                	addi	sp,sp,-32
    800007da:	ec06                	sd	ra,24(sp)
    800007dc:	e822                	sd	s0,16(sp)
    800007de:	e426                	sd	s1,8(sp)
    800007e0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007e2:	00012497          	auipc	s1,0x12
    800007e6:	c5648493          	addi	s1,s1,-938 # 80012438 <pr>
    800007ea:	00007597          	auipc	a1,0x7
    800007ee:	83e58593          	addi	a1,a1,-1986 # 80007028 <etext+0x28>
    800007f2:	8526                	mv	a0,s1
    800007f4:	386000ef          	jal	80000b7a <initlock>
  pr.locking = 1;
    800007f8:	4785                	li	a5,1
    800007fa:	cc9c                	sw	a5,24(s1)
}
    800007fc:	60e2                	ld	ra,24(sp)
    800007fe:	6442                	ld	s0,16(sp)
    80000800:	64a2                	ld	s1,8(sp)
    80000802:	6105                	addi	sp,sp,32
    80000804:	8082                	ret

0000000080000806 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000806:	1141                	addi	sp,sp,-16
    80000808:	e406                	sd	ra,8(sp)
    8000080a:	e022                	sd	s0,0(sp)
    8000080c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000080e:	100007b7          	lui	a5,0x10000
    80000812:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000816:	10000737          	lui	a4,0x10000
    8000081a:	f8000693          	li	a3,-128
    8000081e:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000822:	468d                	li	a3,3
    80000824:	10000637          	lui	a2,0x10000
    80000828:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000082c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000830:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000834:	8732                	mv	a4,a2
    80000836:	461d                	li	a2,7
    80000838:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000083c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000840:	00006597          	auipc	a1,0x6
    80000844:	7f058593          	addi	a1,a1,2032 # 80007030 <etext+0x30>
    80000848:	00012517          	auipc	a0,0x12
    8000084c:	c1050513          	addi	a0,a0,-1008 # 80012458 <uart_tx_lock>
    80000850:	32a000ef          	jal	80000b7a <initlock>
}
    80000854:	60a2                	ld	ra,8(sp)
    80000856:	6402                	ld	s0,0(sp)
    80000858:	0141                	addi	sp,sp,16
    8000085a:	8082                	ret

000000008000085c <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000085c:	1101                	addi	sp,sp,-32
    8000085e:	ec06                	sd	ra,24(sp)
    80000860:	e822                	sd	s0,16(sp)
    80000862:	e426                	sd	s1,8(sp)
    80000864:	1000                	addi	s0,sp,32
    80000866:	84aa                	mv	s1,a0
  push_off();
    80000868:	356000ef          	jal	80000bbe <push_off>

  if(panicked){
    8000086c:	0000a797          	auipc	a5,0xa
    80000870:	ae47a783          	lw	a5,-1308(a5) # 8000a350 <panicked>
    80000874:	e795                	bnez	a5,800008a0 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000876:	10000737          	lui	a4,0x10000
    8000087a:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000087c:	00074783          	lbu	a5,0(a4)
    80000880:	0207f793          	andi	a5,a5,32
    80000884:	dfe5                	beqz	a5,8000087c <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80000886:	0ff4f513          	zext.b	a0,s1
    8000088a:	100007b7          	lui	a5,0x10000
    8000088e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000892:	3b0000ef          	jal	80000c42 <pop_off>
}
    80000896:	60e2                	ld	ra,24(sp)
    80000898:	6442                	ld	s0,16(sp)
    8000089a:	64a2                	ld	s1,8(sp)
    8000089c:	6105                	addi	sp,sp,32
    8000089e:	8082                	ret
    for(;;)
    800008a0:	a001                	j	800008a0 <uartputc_sync+0x44>

00000000800008a2 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008a2:	0000a797          	auipc	a5,0xa
    800008a6:	ab67b783          	ld	a5,-1354(a5) # 8000a358 <uart_tx_r>
    800008aa:	0000a717          	auipc	a4,0xa
    800008ae:	ab673703          	ld	a4,-1354(a4) # 8000a360 <uart_tx_w>
    800008b2:	08f70163          	beq	a4,a5,80000934 <uartstart+0x92>
{
    800008b6:	7139                	addi	sp,sp,-64
    800008b8:	fc06                	sd	ra,56(sp)
    800008ba:	f822                	sd	s0,48(sp)
    800008bc:	f426                	sd	s1,40(sp)
    800008be:	f04a                	sd	s2,32(sp)
    800008c0:	ec4e                	sd	s3,24(sp)
    800008c2:	e852                	sd	s4,16(sp)
    800008c4:	e456                	sd	s5,8(sp)
    800008c6:	e05a                	sd	s6,0(sp)
    800008c8:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ca:	10000937          	lui	s2,0x10000
    800008ce:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008d0:	00012a97          	auipc	s5,0x12
    800008d4:	b88a8a93          	addi	s5,s5,-1144 # 80012458 <uart_tx_lock>
    uart_tx_r += 1;
    800008d8:	0000a497          	auipc	s1,0xa
    800008dc:	a8048493          	addi	s1,s1,-1408 # 8000a358 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008e0:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e4:	0000a997          	auipc	s3,0xa
    800008e8:	a7c98993          	addi	s3,s3,-1412 # 8000a360 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ec:	00094703          	lbu	a4,0(s2)
    800008f0:	02077713          	andi	a4,a4,32
    800008f4:	c715                	beqz	a4,80000920 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008f6:	01f7f713          	andi	a4,a5,31
    800008fa:	9756                	add	a4,a4,s5
    800008fc:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    80000900:	0785                	addi	a5,a5,1
    80000902:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    80000904:	8526                	mv	a0,s1
    80000906:	5fc010ef          	jal	80001f02 <wakeup>
    WriteReg(THR, c);
    8000090a:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    8000090e:	609c                	ld	a5,0(s1)
    80000910:	0009b703          	ld	a4,0(s3)
    80000914:	fcf71ce3          	bne	a4,a5,800008ec <uartstart+0x4a>
      ReadReg(ISR);
    80000918:	100007b7          	lui	a5,0x10000
    8000091c:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80000920:	70e2                	ld	ra,56(sp)
    80000922:	7442                	ld	s0,48(sp)
    80000924:	74a2                	ld	s1,40(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	69e2                	ld	s3,24(sp)
    8000092a:	6a42                	ld	s4,16(sp)
    8000092c:	6aa2                	ld	s5,8(sp)
    8000092e:	6b02                	ld	s6,0(sp)
    80000930:	6121                	addi	sp,sp,64
    80000932:	8082                	ret
      ReadReg(ISR);
    80000934:	100007b7          	lui	a5,0x10000
    80000938:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    8000093c:	8082                	ret

000000008000093e <uartputc>:
{
    8000093e:	7179                	addi	sp,sp,-48
    80000940:	f406                	sd	ra,40(sp)
    80000942:	f022                	sd	s0,32(sp)
    80000944:	ec26                	sd	s1,24(sp)
    80000946:	e84a                	sd	s2,16(sp)
    80000948:	e44e                	sd	s3,8(sp)
    8000094a:	e052                	sd	s4,0(sp)
    8000094c:	1800                	addi	s0,sp,48
    8000094e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000950:	00012517          	auipc	a0,0x12
    80000954:	b0850513          	addi	a0,a0,-1272 # 80012458 <uart_tx_lock>
    80000958:	2a6000ef          	jal	80000bfe <acquire>
  if(panicked){
    8000095c:	0000a797          	auipc	a5,0xa
    80000960:	9f47a783          	lw	a5,-1548(a5) # 8000a350 <panicked>
    80000964:	efbd                	bnez	a5,800009e2 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000966:	0000a717          	auipc	a4,0xa
    8000096a:	9fa73703          	ld	a4,-1542(a4) # 8000a360 <uart_tx_w>
    8000096e:	0000a797          	auipc	a5,0xa
    80000972:	9ea7b783          	ld	a5,-1558(a5) # 8000a358 <uart_tx_r>
    80000976:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	00012997          	auipc	s3,0x12
    8000097e:	ade98993          	addi	s3,s3,-1314 # 80012458 <uart_tx_lock>
    80000982:	0000a497          	auipc	s1,0xa
    80000986:	9d648493          	addi	s1,s1,-1578 # 8000a358 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000098a:	0000a917          	auipc	s2,0xa
    8000098e:	9d690913          	addi	s2,s2,-1578 # 8000a360 <uart_tx_w>
    80000992:	00e79d63          	bne	a5,a4,800009ac <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000996:	85ce                	mv	a1,s3
    80000998:	8526                	mv	a0,s1
    8000099a:	51c010ef          	jal	80001eb6 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099e:	00093703          	ld	a4,0(s2)
    800009a2:	609c                	ld	a5,0(s1)
    800009a4:	02078793          	addi	a5,a5,32
    800009a8:	fee787e3          	beq	a5,a4,80000996 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009ac:	00012497          	auipc	s1,0x12
    800009b0:	aac48493          	addi	s1,s1,-1364 # 80012458 <uart_tx_lock>
    800009b4:	01f77793          	andi	a5,a4,31
    800009b8:	97a6                	add	a5,a5,s1
    800009ba:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009be:	0705                	addi	a4,a4,1
    800009c0:	0000a797          	auipc	a5,0xa
    800009c4:	9ae7b023          	sd	a4,-1632(a5) # 8000a360 <uart_tx_w>
  uartstart();
    800009c8:	edbff0ef          	jal	800008a2 <uartstart>
  release(&uart_tx_lock);
    800009cc:	8526                	mv	a0,s1
    800009ce:	2c4000ef          	jal	80000c92 <release>
}
    800009d2:	70a2                	ld	ra,40(sp)
    800009d4:	7402                	ld	s0,32(sp)
    800009d6:	64e2                	ld	s1,24(sp)
    800009d8:	6942                	ld	s2,16(sp)
    800009da:	69a2                	ld	s3,8(sp)
    800009dc:	6a02                	ld	s4,0(sp)
    800009de:	6145                	addi	sp,sp,48
    800009e0:	8082                	ret
    for(;;)
    800009e2:	a001                	j	800009e2 <uartputc+0xa4>

00000000800009e4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e4:	1141                	addi	sp,sp,-16
    800009e6:	e406                	sd	ra,8(sp)
    800009e8:	e022                	sd	s0,0(sp)
    800009ea:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009f4:	8b85                	andi	a5,a5,1
    800009f6:	cb89                	beqz	a5,80000a08 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009f8:	100007b7          	lui	a5,0x10000
    800009fc:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a00:	60a2                	ld	ra,8(sp)
    80000a02:	6402                	ld	s0,0(sp)
    80000a04:	0141                	addi	sp,sp,16
    80000a06:	8082                	ret
    return -1;
    80000a08:	557d                	li	a0,-1
    80000a0a:	bfdd                	j	80000a00 <uartgetc+0x1c>

0000000080000a0c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a0c:	1101                	addi	sp,sp,-32
    80000a0e:	ec06                	sd	ra,24(sp)
    80000a10:	e822                	sd	s0,16(sp)
    80000a12:	e426                	sd	s1,8(sp)
    80000a14:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a16:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a18:	fcdff0ef          	jal	800009e4 <uartgetc>
    if(c == -1)
    80000a1c:	00950563          	beq	a0,s1,80000a26 <uartintr+0x1a>
      break;
    consoleintr(c);
    80000a20:	861ff0ef          	jal	80000280 <consoleintr>
  while(1){
    80000a24:	bfd5                	j	80000a18 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a26:	00012497          	auipc	s1,0x12
    80000a2a:	a3248493          	addi	s1,s1,-1486 # 80012458 <uart_tx_lock>
    80000a2e:	8526                	mv	a0,s1
    80000a30:	1ce000ef          	jal	80000bfe <acquire>
  uartstart();
    80000a34:	e6fff0ef          	jal	800008a2 <uartstart>
  release(&uart_tx_lock);
    80000a38:	8526                	mv	a0,s1
    80000a3a:	258000ef          	jal	80000c92 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret

0000000080000a48 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a48:	1101                	addi	sp,sp,-32
    80000a4a:	ec06                	sd	ra,24(sp)
    80000a4c:	e822                	sd	s0,16(sp)
    80000a4e:	e426                	sd	s1,8(sp)
    80000a50:	e04a                	sd	s2,0(sp)
    80000a52:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a54:	03451793          	slli	a5,a0,0x34
    80000a58:	e7a9                	bnez	a5,80000aa2 <kfree+0x5a>
    80000a5a:	84aa                	mv	s1,a0
    80000a5c:	00024797          	auipc	a5,0x24
    80000a60:	91c78793          	addi	a5,a5,-1764 # 80024378 <end>
    80000a64:	02f56f63          	bltu	a0,a5,80000aa2 <kfree+0x5a>
    80000a68:	47c5                	li	a5,17
    80000a6a:	07ee                	slli	a5,a5,0x1b
    80000a6c:	02f57b63          	bgeu	a0,a5,80000aa2 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a70:	6605                	lui	a2,0x1
    80000a72:	4585                	li	a1,1
    80000a74:	25a000ef          	jal	80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a78:	00012917          	auipc	s2,0x12
    80000a7c:	a1890913          	addi	s2,s2,-1512 # 80012490 <kmem>
    80000a80:	854a                	mv	a0,s2
    80000a82:	17c000ef          	jal	80000bfe <acquire>
  r->next = kmem.freelist;
    80000a86:	01893783          	ld	a5,24(s2)
    80000a8a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a8c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a90:	854a                	mv	a0,s2
    80000a92:	200000ef          	jal	80000c92 <release>
}
    80000a96:	60e2                	ld	ra,24(sp)
    80000a98:	6442                	ld	s0,16(sp)
    80000a9a:	64a2                	ld	s1,8(sp)
    80000a9c:	6902                	ld	s2,0(sp)
    80000a9e:	6105                	addi	sp,sp,32
    80000aa0:	8082                	ret
    panic("kfree");
    80000aa2:	00006517          	auipc	a0,0x6
    80000aa6:	59650513          	addi	a0,a0,1430 # 80007038 <etext+0x38>
    80000aaa:	cf5ff0ef          	jal	8000079e <panic>

0000000080000aae <freerange>:
{
    80000aae:	7179                	addi	sp,sp,-48
    80000ab0:	f406                	sd	ra,40(sp)
    80000ab2:	f022                	sd	s0,32(sp)
    80000ab4:	ec26                	sd	s1,24(sp)
    80000ab6:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab8:	6785                	lui	a5,0x1
    80000aba:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000abe:	00e504b3          	add	s1,a0,a4
    80000ac2:	777d                	lui	a4,0xfffff
    80000ac4:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac6:	94be                	add	s1,s1,a5
    80000ac8:	0295e263          	bltu	a1,s1,80000aec <freerange+0x3e>
    80000acc:	e84a                	sd	s2,16(sp)
    80000ace:	e44e                	sd	s3,8(sp)
    80000ad0:	e052                	sd	s4,0(sp)
    80000ad2:	892e                	mv	s2,a1
    kfree(p);
    80000ad4:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad6:	89be                	mv	s3,a5
    kfree(p);
    80000ad8:	01448533          	add	a0,s1,s4
    80000adc:	f6dff0ef          	jal	80000a48 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94ce                	add	s1,s1,s3
    80000ae2:	fe997be3          	bgeu	s2,s1,80000ad8 <freerange+0x2a>
    80000ae6:	6942                	ld	s2,16(sp)
    80000ae8:	69a2                	ld	s3,8(sp)
    80000aea:	6a02                	ld	s4,0(sp)
}
    80000aec:	70a2                	ld	ra,40(sp)
    80000aee:	7402                	ld	s0,32(sp)
    80000af0:	64e2                	ld	s1,24(sp)
    80000af2:	6145                	addi	sp,sp,48
    80000af4:	8082                	ret

0000000080000af6 <kinit>:
{
    80000af6:	1141                	addi	sp,sp,-16
    80000af8:	e406                	sd	ra,8(sp)
    80000afa:	e022                	sd	s0,0(sp)
    80000afc:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000afe:	00006597          	auipc	a1,0x6
    80000b02:	54258593          	addi	a1,a1,1346 # 80007040 <etext+0x40>
    80000b06:	00012517          	auipc	a0,0x12
    80000b0a:	98a50513          	addi	a0,a0,-1654 # 80012490 <kmem>
    80000b0e:	06c000ef          	jal	80000b7a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b12:	45c5                	li	a1,17
    80000b14:	05ee                	slli	a1,a1,0x1b
    80000b16:	00024517          	auipc	a0,0x24
    80000b1a:	86250513          	addi	a0,a0,-1950 # 80024378 <end>
    80000b1e:	f91ff0ef          	jal	80000aae <freerange>
}
    80000b22:	60a2                	ld	ra,8(sp)
    80000b24:	6402                	ld	s0,0(sp)
    80000b26:	0141                	addi	sp,sp,16
    80000b28:	8082                	ret

0000000080000b2a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b2a:	1101                	addi	sp,sp,-32
    80000b2c:	ec06                	sd	ra,24(sp)
    80000b2e:	e822                	sd	s0,16(sp)
    80000b30:	e426                	sd	s1,8(sp)
    80000b32:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b34:	00012497          	auipc	s1,0x12
    80000b38:	95c48493          	addi	s1,s1,-1700 # 80012490 <kmem>
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	0c0000ef          	jal	80000bfe <acquire>
  r = kmem.freelist;
    80000b42:	6c84                	ld	s1,24(s1)
  if(r)
    80000b44:	c485                	beqz	s1,80000b6c <kalloc+0x42>
    kmem.freelist = r->next;
    80000b46:	609c                	ld	a5,0(s1)
    80000b48:	00012517          	auipc	a0,0x12
    80000b4c:	94850513          	addi	a0,a0,-1720 # 80012490 <kmem>
    80000b50:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b52:	140000ef          	jal	80000c92 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b56:	6605                	lui	a2,0x1
    80000b58:	4595                	li	a1,5
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	172000ef          	jal	80000cce <memset>
  return (void*)r;
}
    80000b60:	8526                	mv	a0,s1
    80000b62:	60e2                	ld	ra,24(sp)
    80000b64:	6442                	ld	s0,16(sp)
    80000b66:	64a2                	ld	s1,8(sp)
    80000b68:	6105                	addi	sp,sp,32
    80000b6a:	8082                	ret
  release(&kmem.lock);
    80000b6c:	00012517          	auipc	a0,0x12
    80000b70:	92450513          	addi	a0,a0,-1756 # 80012490 <kmem>
    80000b74:	11e000ef          	jal	80000c92 <release>
  if(r)
    80000b78:	b7e5                	j	80000b60 <kalloc+0x36>

0000000080000b7a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b7a:	1141                	addi	sp,sp,-16
    80000b7c:	e406                	sd	ra,8(sp)
    80000b7e:	e022                	sd	s0,0(sp)
    80000b80:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b82:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b84:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b88:	00053823          	sd	zero,16(a0)
}
    80000b8c:	60a2                	ld	ra,8(sp)
    80000b8e:	6402                	ld	s0,0(sp)
    80000b90:	0141                	addi	sp,sp,16
    80000b92:	8082                	ret

0000000080000b94 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b94:	411c                	lw	a5,0(a0)
    80000b96:	e399                	bnez	a5,80000b9c <holding+0x8>
    80000b98:	4501                	li	a0,0
  return r;
}
    80000b9a:	8082                	ret
{
    80000b9c:	1101                	addi	sp,sp,-32
    80000b9e:	ec06                	sd	ra,24(sp)
    80000ba0:	e822                	sd	s0,16(sp)
    80000ba2:	e426                	sd	s1,8(sp)
    80000ba4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba6:	6904                	ld	s1,16(a0)
    80000ba8:	509000ef          	jal	800018b0 <mycpu>
    80000bac:	40a48533          	sub	a0,s1,a0
    80000bb0:	00153513          	seqz	a0,a0
}
    80000bb4:	60e2                	ld	ra,24(sp)
    80000bb6:	6442                	ld	s0,16(sp)
    80000bb8:	64a2                	ld	s1,8(sp)
    80000bba:	6105                	addi	sp,sp,32
    80000bbc:	8082                	ret

0000000080000bbe <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bbe:	1101                	addi	sp,sp,-32
    80000bc0:	ec06                	sd	ra,24(sp)
    80000bc2:	e822                	sd	s0,16(sp)
    80000bc4:	e426                	sd	s1,8(sp)
    80000bc6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bc8:	100024f3          	csrr	s1,sstatus
    80000bcc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bd6:	4db000ef          	jal	800018b0 <mycpu>
    80000bda:	5d3c                	lw	a5,120(a0)
    80000bdc:	cb99                	beqz	a5,80000bf2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bde:	4d3000ef          	jal	800018b0 <mycpu>
    80000be2:	5d3c                	lw	a5,120(a0)
    80000be4:	2785                	addiw	a5,a5,1
    80000be6:	dd3c                	sw	a5,120(a0)
}
    80000be8:	60e2                	ld	ra,24(sp)
    80000bea:	6442                	ld	s0,16(sp)
    80000bec:	64a2                	ld	s1,8(sp)
    80000bee:	6105                	addi	sp,sp,32
    80000bf0:	8082                	ret
    mycpu()->intena = old;
    80000bf2:	4bf000ef          	jal	800018b0 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bf6:	8085                	srli	s1,s1,0x1
    80000bf8:	8885                	andi	s1,s1,1
    80000bfa:	dd64                	sw	s1,124(a0)
    80000bfc:	b7cd                	j	80000bde <push_off+0x20>

0000000080000bfe <acquire>:
{
    80000bfe:	1101                	addi	sp,sp,-32
    80000c00:	ec06                	sd	ra,24(sp)
    80000c02:	e822                	sd	s0,16(sp)
    80000c04:	e426                	sd	s1,8(sp)
    80000c06:	1000                	addi	s0,sp,32
    80000c08:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c0a:	fb5ff0ef          	jal	80000bbe <push_off>
  if(holding(lk))
    80000c0e:	8526                	mv	a0,s1
    80000c10:	f85ff0ef          	jal	80000b94 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c14:	4705                	li	a4,1
  if(holding(lk))
    80000c16:	e105                	bnez	a0,80000c36 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c18:	87ba                	mv	a5,a4
    80000c1a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c1e:	2781                	sext.w	a5,a5
    80000c20:	ffe5                	bnez	a5,80000c18 <acquire+0x1a>
  __sync_synchronize();
    80000c22:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c26:	48b000ef          	jal	800018b0 <mycpu>
    80000c2a:	e888                	sd	a0,16(s1)
}
    80000c2c:	60e2                	ld	ra,24(sp)
    80000c2e:	6442                	ld	s0,16(sp)
    80000c30:	64a2                	ld	s1,8(sp)
    80000c32:	6105                	addi	sp,sp,32
    80000c34:	8082                	ret
    panic("acquire");
    80000c36:	00006517          	auipc	a0,0x6
    80000c3a:	41250513          	addi	a0,a0,1042 # 80007048 <etext+0x48>
    80000c3e:	b61ff0ef          	jal	8000079e <panic>

0000000080000c42 <pop_off>:

void
pop_off(void)
{
    80000c42:	1141                	addi	sp,sp,-16
    80000c44:	e406                	sd	ra,8(sp)
    80000c46:	e022                	sd	s0,0(sp)
    80000c48:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c4a:	467000ef          	jal	800018b0 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	e39d                	bnez	a5,80000c7a <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	5d3c                	lw	a5,120(a0)
    80000c58:	02f05763          	blez	a5,80000c86 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c5c:	37fd                	addiw	a5,a5,-1
    80000c5e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c60:	eb89                	bnez	a5,80000c72 <pop_off+0x30>
    80000c62:	5d7c                	lw	a5,124(a0)
    80000c64:	c799                	beqz	a5,80000c72 <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c72:	60a2                	ld	ra,8(sp)
    80000c74:	6402                	ld	s0,0(sp)
    80000c76:	0141                	addi	sp,sp,16
    80000c78:	8082                	ret
    panic("pop_off - interruptible");
    80000c7a:	00006517          	auipc	a0,0x6
    80000c7e:	3d650513          	addi	a0,a0,982 # 80007050 <etext+0x50>
    80000c82:	b1dff0ef          	jal	8000079e <panic>
    panic("pop_off");
    80000c86:	00006517          	auipc	a0,0x6
    80000c8a:	3e250513          	addi	a0,a0,994 # 80007068 <etext+0x68>
    80000c8e:	b11ff0ef          	jal	8000079e <panic>

0000000080000c92 <release>:
{
    80000c92:	1101                	addi	sp,sp,-32
    80000c94:	ec06                	sd	ra,24(sp)
    80000c96:	e822                	sd	s0,16(sp)
    80000c98:	e426                	sd	s1,8(sp)
    80000c9a:	1000                	addi	s0,sp,32
    80000c9c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c9e:	ef7ff0ef          	jal	80000b94 <holding>
    80000ca2:	c105                	beqz	a0,80000cc2 <release+0x30>
  lk->cpu = 0;
    80000ca4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca8:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cac:	0310000f          	fence	rw,w
    80000cb0:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cb4:	f8fff0ef          	jal	80000c42 <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00006517          	auipc	a0,0x6
    80000cc6:	3ae50513          	addi	a0,a0,942 # 80007070 <etext+0x70>
    80000cca:	ad5ff0ef          	jal	8000079e <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e406                	sd	ra,8(sp)
    80000cd2:	e022                	sd	s0,0(sp)
    80000cd4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd6:	ca19                	beqz	a2,80000cec <memset+0x1e>
    80000cd8:	87aa                	mv	a5,a0
    80000cda:	1602                	slli	a2,a2,0x20
    80000cdc:	9201                	srli	a2,a2,0x20
    80000cde:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce6:	0785                	addi	a5,a5,1
    80000ce8:	fee79de3          	bne	a5,a4,80000ce2 <memset+0x14>
  }
  return dst;
}
    80000cec:	60a2                	ld	ra,8(sp)
    80000cee:	6402                	ld	s0,0(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e406                	sd	ra,8(sp)
    80000cf8:	e022                	sd	s0,0(sp)
    80000cfa:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfc:	ca0d                	beqz	a2,80000d2e <memcmp+0x3a>
    80000cfe:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d02:	1682                	slli	a3,a3,0x20
    80000d04:	9281                	srli	a3,a3,0x20
    80000d06:	0685                	addi	a3,a3,1
    80000d08:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d0a:	00054783          	lbu	a5,0(a0)
    80000d0e:	0005c703          	lbu	a4,0(a1)
    80000d12:	00e79863          	bne	a5,a4,80000d22 <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000d16:	0505                	addi	a0,a0,1
    80000d18:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d1a:	fed518e3          	bne	a0,a3,80000d0a <memcmp+0x16>
  }

  return 0;
    80000d1e:	4501                	li	a0,0
    80000d20:	a019                	j	80000d26 <memcmp+0x32>
      return *s1 - *s2;
    80000d22:	40e7853b          	subw	a0,a5,a4
}
    80000d26:	60a2                	ld	ra,8(sp)
    80000d28:	6402                	ld	s0,0(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret
  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	bfdd                	j	80000d26 <memcmp+0x32>

0000000080000d32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e406                	sd	ra,8(sp)
    80000d36:	e022                	sd	s0,0(sp)
    80000d38:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d3a:	c205                	beqz	a2,80000d5a <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d3c:	02a5e363          	bltu	a1,a0,80000d62 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d40:	1602                	slli	a2,a2,0x20
    80000d42:	9201                	srli	a2,a2,0x20
    80000d44:	00c587b3          	add	a5,a1,a2
{
    80000d48:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d4a:	0585                	addi	a1,a1,1
    80000d4c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdac89>
    80000d4e:	fff5c683          	lbu	a3,-1(a1)
    80000d52:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d56:	feb79ae3          	bne	a5,a1,80000d4a <memmove+0x18>

  return dst;
}
    80000d5a:	60a2                	ld	ra,8(sp)
    80000d5c:	6402                	ld	s0,0(sp)
    80000d5e:	0141                	addi	sp,sp,16
    80000d60:	8082                	ret
  if(s < d && s + n > d){
    80000d62:	02061693          	slli	a3,a2,0x20
    80000d66:	9281                	srli	a3,a3,0x20
    80000d68:	00d58733          	add	a4,a1,a3
    80000d6c:	fce57ae3          	bgeu	a0,a4,80000d40 <memmove+0xe>
    d += n;
    80000d70:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d72:	fff6079b          	addiw	a5,a2,-1
    80000d76:	1782                	slli	a5,a5,0x20
    80000d78:	9381                	srli	a5,a5,0x20
    80000d7a:	fff7c793          	not	a5,a5
    80000d7e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d80:	177d                	addi	a4,a4,-1
    80000d82:	16fd                	addi	a3,a3,-1
    80000d84:	00074603          	lbu	a2,0(a4)
    80000d88:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d8c:	fee79ae3          	bne	a5,a4,80000d80 <memmove+0x4e>
    80000d90:	b7e9                	j	80000d5a <memmove+0x28>

0000000080000d92 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e406                	sd	ra,8(sp)
    80000d96:	e022                	sd	s0,0(sp)
    80000d98:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d9a:	f99ff0ef          	jal	80000d32 <memmove>
}
    80000d9e:	60a2                	ld	ra,8(sp)
    80000da0:	6402                	ld	s0,0(sp)
    80000da2:	0141                	addi	sp,sp,16
    80000da4:	8082                	ret

0000000080000da6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dae:	ce11                	beqz	a2,80000dca <strncmp+0x24>
    80000db0:	00054783          	lbu	a5,0(a0)
    80000db4:	cf89                	beqz	a5,80000dce <strncmp+0x28>
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	00f71a63          	bne	a4,a5,80000dce <strncmp+0x28>
    n--, p++, q++;
    80000dbe:	367d                	addiw	a2,a2,-1
    80000dc0:	0505                	addi	a0,a0,1
    80000dc2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dc4:	f675                	bnez	a2,80000db0 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dc6:	4501                	li	a0,0
    80000dc8:	a801                	j	80000dd8 <strncmp+0x32>
    80000dca:	4501                	li	a0,0
    80000dcc:	a031                	j	80000dd8 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000dce:	00054503          	lbu	a0,0(a0)
    80000dd2:	0005c783          	lbu	a5,0(a1)
    80000dd6:	9d1d                	subw	a0,a0,a5
}
    80000dd8:	60a2                	ld	ra,8(sp)
    80000dda:	6402                	ld	s0,0(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e406                	sd	ra,8(sp)
    80000de4:	e022                	sd	s0,0(sp)
    80000de6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de8:	87aa                	mv	a5,a0
    80000dea:	86b2                	mv	a3,a2
    80000dec:	367d                	addiw	a2,a2,-1
    80000dee:	02d05563          	blez	a3,80000e18 <strncpy+0x38>
    80000df2:	0785                	addi	a5,a5,1
    80000df4:	0005c703          	lbu	a4,0(a1)
    80000df8:	fee78fa3          	sb	a4,-1(a5)
    80000dfc:	0585                	addi	a1,a1,1
    80000dfe:	f775                	bnez	a4,80000dea <strncpy+0xa>
    ;
  while(n-- > 0)
    80000e00:	873e                	mv	a4,a5
    80000e02:	00c05b63          	blez	a2,80000e18 <strncpy+0x38>
    80000e06:	9fb5                	addw	a5,a5,a3
    80000e08:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e10:	40e786bb          	subw	a3,a5,a4
    80000e14:	fed04be3          	bgtz	a3,80000e0a <strncpy+0x2a>
  return os;
}
    80000e18:	60a2                	ld	ra,8(sp)
    80000e1a:	6402                	ld	s0,0(sp)
    80000e1c:	0141                	addi	sp,sp,16
    80000e1e:	8082                	ret

0000000080000e20 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e20:	1141                	addi	sp,sp,-16
    80000e22:	e406                	sd	ra,8(sp)
    80000e24:	e022                	sd	s0,0(sp)
    80000e26:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e28:	02c05363          	blez	a2,80000e4e <safestrcpy+0x2e>
    80000e2c:	fff6069b          	addiw	a3,a2,-1
    80000e30:	1682                	slli	a3,a3,0x20
    80000e32:	9281                	srli	a3,a3,0x20
    80000e34:	96ae                	add	a3,a3,a1
    80000e36:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e38:	00d58963          	beq	a1,a3,80000e4a <safestrcpy+0x2a>
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	0785                	addi	a5,a5,1
    80000e40:	fff5c703          	lbu	a4,-1(a1)
    80000e44:	fee78fa3          	sb	a4,-1(a5)
    80000e48:	fb65                	bnez	a4,80000e38 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e4a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e4e:	60a2                	ld	ra,8(sp)
    80000e50:	6402                	ld	s0,0(sp)
    80000e52:	0141                	addi	sp,sp,16
    80000e54:	8082                	ret

0000000080000e56 <strlen>:

int
strlen(const char *s)
{
    80000e56:	1141                	addi	sp,sp,-16
    80000e58:	e406                	sd	ra,8(sp)
    80000e5a:	e022                	sd	s0,0(sp)
    80000e5c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e5e:	00054783          	lbu	a5,0(a0)
    80000e62:	cf99                	beqz	a5,80000e80 <strlen+0x2a>
    80000e64:	0505                	addi	a0,a0,1
    80000e66:	87aa                	mv	a5,a0
    80000e68:	86be                	mv	a3,a5
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff7c703          	lbu	a4,-1(a5)
    80000e70:	ff65                	bnez	a4,80000e68 <strlen+0x12>
    80000e72:	40a6853b          	subw	a0,a3,a0
    80000e76:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e78:	60a2                	ld	ra,8(sp)
    80000e7a:	6402                	ld	s0,0(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e80:	4501                	li	a0,0
    80000e82:	bfdd                	j	80000e78 <strlen+0x22>

0000000080000e84 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e84:	1141                	addi	sp,sp,-16
    80000e86:	e406                	sd	ra,8(sp)
    80000e88:	e022                	sd	s0,0(sp)
    80000e8a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e8c:	211000ef          	jal	8000189c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e90:	00009717          	auipc	a4,0x9
    80000e94:	4d870713          	addi	a4,a4,1240 # 8000a368 <started>
  if(cpuid() == 0){
    80000e98:	c51d                	beqz	a0,80000ec6 <main+0x42>
    while(started == 0)
    80000e9a:	431c                	lw	a5,0(a4)
    80000e9c:	2781                	sext.w	a5,a5
    80000e9e:	dff5                	beqz	a5,80000e9a <main+0x16>
      ;
    __sync_synchronize();
    80000ea0:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ea4:	1f9000ef          	jal	8000189c <cpuid>
    80000ea8:	85aa                	mv	a1,a0
    80000eaa:	00006517          	auipc	a0,0x6
    80000eae:	1ee50513          	addi	a0,a0,494 # 80007098 <etext+0x98>
    80000eb2:	e1cff0ef          	jal	800004ce <printf>
    kvminithart();    // turn on paging
    80000eb6:	080000ef          	jal	80000f36 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eba:	518010ef          	jal	800023d2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	54a040ef          	jal	80005408 <plicinithart>
  }

  scheduler();        
    80000ec2:	67b000ef          	jal	80001d3c <scheduler>
    consoleinit();
    80000ec6:	d3aff0ef          	jal	80000400 <consoleinit>
    printfinit();
    80000eca:	90fff0ef          	jal	800007d8 <printfinit>
    printf("\n");
    80000ece:	00006517          	auipc	a0,0x6
    80000ed2:	1aa50513          	addi	a0,a0,426 # 80007078 <etext+0x78>
    80000ed6:	df8ff0ef          	jal	800004ce <printf>
    printf("xv6 kernel is booting\n");
    80000eda:	00006517          	auipc	a0,0x6
    80000ede:	1a650513          	addi	a0,a0,422 # 80007080 <etext+0x80>
    80000ee2:	decff0ef          	jal	800004ce <printf>
    printf("\n");
    80000ee6:	00006517          	auipc	a0,0x6
    80000eea:	19250513          	addi	a0,a0,402 # 80007078 <etext+0x78>
    80000eee:	de0ff0ef          	jal	800004ce <printf>
    kinit();         // physical page allocator
    80000ef2:	c05ff0ef          	jal	80000af6 <kinit>
    kvminit();       // create kernel page table
    80000ef6:	2ce000ef          	jal	800011c4 <kvminit>
    kvminithart();   // turn on paging
    80000efa:	03c000ef          	jal	80000f36 <kvminithart>
    procinit();      // process table
    80000efe:	0f5000ef          	jal	800017f2 <procinit>
    trapinit();      // trap vectors
    80000f02:	4ac010ef          	jal	800023ae <trapinit>
    trapinithart();  // install kernel trap vector
    80000f06:	4cc010ef          	jal	800023d2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f0a:	4e4040ef          	jal	800053ee <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f0e:	4fa040ef          	jal	80005408 <plicinithart>
    binit();         // buffer cache
    80000f12:	469010ef          	jal	80002b7a <binit>
    iinit();         // inode table
    80000f16:	234020ef          	jal	8000314a <iinit>
    fileinit();      // file table
    80000f1a:	002030ef          	jal	80003f1c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1e:	5da040ef          	jal	800054f8 <virtio_disk_init>
    userinit();      // first user process
    80000f22:	427000ef          	jal	80001b48 <userinit>
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    started = 1;
    80000f2a:	4785                	li	a5,1
    80000f2c:	00009717          	auipc	a4,0x9
    80000f30:	42f72e23          	sw	a5,1084(a4) # 8000a368 <started>
    80000f34:	b779                	j	80000ec2 <main+0x3e>

0000000080000f36 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f36:	1141                	addi	sp,sp,-16
    80000f38:	e406                	sd	ra,8(sp)
    80000f3a:	e022                	sd	s0,0(sp)
    80000f3c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f3e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f42:	00009797          	auipc	a5,0x9
    80000f46:	42e7b783          	ld	a5,1070(a5) # 8000a370 <kernel_pagetable>
    80000f4a:	83b1                	srli	a5,a5,0xc
    80000f4c:	577d                	li	a4,-1
    80000f4e:	177e                	slli	a4,a4,0x3f
    80000f50:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f52:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f56:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f5a:	60a2                	ld	ra,8(sp)
    80000f5c:	6402                	ld	s0,0(sp)
    80000f5e:	0141                	addi	sp,sp,16
    80000f60:	8082                	ret

0000000080000f62 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f62:	7139                	addi	sp,sp,-64
    80000f64:	fc06                	sd	ra,56(sp)
    80000f66:	f822                	sd	s0,48(sp)
    80000f68:	f426                	sd	s1,40(sp)
    80000f6a:	f04a                	sd	s2,32(sp)
    80000f6c:	ec4e                	sd	s3,24(sp)
    80000f6e:	e852                	sd	s4,16(sp)
    80000f70:	e456                	sd	s5,8(sp)
    80000f72:	e05a                	sd	s6,0(sp)
    80000f74:	0080                	addi	s0,sp,64
    80000f76:	84aa                	mv	s1,a0
    80000f78:	89ae                	mv	s3,a1
    80000f7a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f7c:	57fd                	li	a5,-1
    80000f7e:	83e9                	srli	a5,a5,0x1a
    80000f80:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f82:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f84:	04b7e263          	bltu	a5,a1,80000fc8 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f88:	0149d933          	srl	s2,s3,s4
    80000f8c:	1ff97913          	andi	s2,s2,511
    80000f90:	090e                	slli	s2,s2,0x3
    80000f92:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f94:	00093483          	ld	s1,0(s2)
    80000f98:	0014f793          	andi	a5,s1,1
    80000f9c:	cf85                	beqz	a5,80000fd4 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f9e:	80a9                	srli	s1,s1,0xa
    80000fa0:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fa2:	3a5d                	addiw	s4,s4,-9
    80000fa4:	ff6a12e3          	bne	s4,s6,80000f88 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fa8:	00c9d513          	srli	a0,s3,0xc
    80000fac:	1ff57513          	andi	a0,a0,511
    80000fb0:	050e                	slli	a0,a0,0x3
    80000fb2:	9526                	add	a0,a0,s1
}
    80000fb4:	70e2                	ld	ra,56(sp)
    80000fb6:	7442                	ld	s0,48(sp)
    80000fb8:	74a2                	ld	s1,40(sp)
    80000fba:	7902                	ld	s2,32(sp)
    80000fbc:	69e2                	ld	s3,24(sp)
    80000fbe:	6a42                	ld	s4,16(sp)
    80000fc0:	6aa2                	ld	s5,8(sp)
    80000fc2:	6b02                	ld	s6,0(sp)
    80000fc4:	6121                	addi	sp,sp,64
    80000fc6:	8082                	ret
    panic("walk");
    80000fc8:	00006517          	auipc	a0,0x6
    80000fcc:	0e850513          	addi	a0,a0,232 # 800070b0 <etext+0xb0>
    80000fd0:	fceff0ef          	jal	8000079e <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fd4:	020a8263          	beqz	s5,80000ff8 <walk+0x96>
    80000fd8:	b53ff0ef          	jal	80000b2a <kalloc>
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	d979                	beqz	a0,80000fb4 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000fe0:	6605                	lui	a2,0x1
    80000fe2:	4581                	li	a1,0
    80000fe4:	cebff0ef          	jal	80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fe8:	00c4d793          	srli	a5,s1,0xc
    80000fec:	07aa                	slli	a5,a5,0xa
    80000fee:	0017e793          	ori	a5,a5,1
    80000ff2:	00f93023          	sd	a5,0(s2)
    80000ff6:	b775                	j	80000fa2 <walk+0x40>
        return 0;
    80000ff8:	4501                	li	a0,0
    80000ffa:	bf6d                	j	80000fb4 <walk+0x52>

0000000080000ffc <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000ffc:	57fd                	li	a5,-1
    80000ffe:	83e9                	srli	a5,a5,0x1a
    80001000:	00b7f463          	bgeu	a5,a1,80001008 <walkaddr+0xc>
    return 0;
    80001004:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001006:	8082                	ret
{
    80001008:	1141                	addi	sp,sp,-16
    8000100a:	e406                	sd	ra,8(sp)
    8000100c:	e022                	sd	s0,0(sp)
    8000100e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001010:	4601                	li	a2,0
    80001012:	f51ff0ef          	jal	80000f62 <walk>
  if(pte == 0)
    80001016:	c105                	beqz	a0,80001036 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001018:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000101a:	0117f693          	andi	a3,a5,17
    8000101e:	4745                	li	a4,17
    return 0;
    80001020:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001022:	00e68663          	beq	a3,a4,8000102e <walkaddr+0x32>
}
    80001026:	60a2                	ld	ra,8(sp)
    80001028:	6402                	ld	s0,0(sp)
    8000102a:	0141                	addi	sp,sp,16
    8000102c:	8082                	ret
  pa = PTE2PA(*pte);
    8000102e:	83a9                	srli	a5,a5,0xa
    80001030:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001034:	bfcd                	j	80001026 <walkaddr+0x2a>
    return 0;
    80001036:	4501                	li	a0,0
    80001038:	b7fd                	j	80001026 <walkaddr+0x2a>

000000008000103a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000103a:	715d                	addi	sp,sp,-80
    8000103c:	e486                	sd	ra,72(sp)
    8000103e:	e0a2                	sd	s0,64(sp)
    80001040:	fc26                	sd	s1,56(sp)
    80001042:	f84a                	sd	s2,48(sp)
    80001044:	f44e                	sd	s3,40(sp)
    80001046:	f052                	sd	s4,32(sp)
    80001048:	ec56                	sd	s5,24(sp)
    8000104a:	e85a                	sd	s6,16(sp)
    8000104c:	e45e                	sd	s7,8(sp)
    8000104e:	e062                	sd	s8,0(sp)
    80001050:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001052:	03459793          	slli	a5,a1,0x34
    80001056:	e7b1                	bnez	a5,800010a2 <mappages+0x68>
    80001058:	8aaa                	mv	s5,a0
    8000105a:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000105c:	03461793          	slli	a5,a2,0x34
    80001060:	e7b9                	bnez	a5,800010ae <mappages+0x74>
    panic("mappages: size not aligned");

  if(size == 0)
    80001062:	ce21                	beqz	a2,800010ba <mappages+0x80>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001064:	77fd                	lui	a5,0xfffff
    80001066:	963e                	add	a2,a2,a5
    80001068:	00b609b3          	add	s3,a2,a1
  a = va;
    8000106c:	892e                	mv	s2,a1
    8000106e:	40b68a33          	sub	s4,a3,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001072:	4b85                	li	s7,1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001074:	6c05                	lui	s8,0x1
    80001076:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000107a:	865e                	mv	a2,s7
    8000107c:	85ca                	mv	a1,s2
    8000107e:	8556                	mv	a0,s5
    80001080:	ee3ff0ef          	jal	80000f62 <walk>
    80001084:	c539                	beqz	a0,800010d2 <mappages+0x98>
    if(*pte & PTE_V)
    80001086:	611c                	ld	a5,0(a0)
    80001088:	8b85                	andi	a5,a5,1
    8000108a:	ef95                	bnez	a5,800010c6 <mappages+0x8c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000108c:	80b1                	srli	s1,s1,0xc
    8000108e:	04aa                	slli	s1,s1,0xa
    80001090:	0164e4b3          	or	s1,s1,s6
    80001094:	0014e493          	ori	s1,s1,1
    80001098:	e104                	sd	s1,0(a0)
    if(a == last)
    8000109a:	05390963          	beq	s2,s3,800010ec <mappages+0xb2>
    a += PGSIZE;
    8000109e:	9962                	add	s2,s2,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    800010a0:	bfd9                	j	80001076 <mappages+0x3c>
    panic("mappages: va not aligned");
    800010a2:	00006517          	auipc	a0,0x6
    800010a6:	01650513          	addi	a0,a0,22 # 800070b8 <etext+0xb8>
    800010aa:	ef4ff0ef          	jal	8000079e <panic>
    panic("mappages: size not aligned");
    800010ae:	00006517          	auipc	a0,0x6
    800010b2:	02a50513          	addi	a0,a0,42 # 800070d8 <etext+0xd8>
    800010b6:	ee8ff0ef          	jal	8000079e <panic>
    panic("mappages: size");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	03e50513          	addi	a0,a0,62 # 800070f8 <etext+0xf8>
    800010c2:	edcff0ef          	jal	8000079e <panic>
      panic("mappages: remap");
    800010c6:	00006517          	auipc	a0,0x6
    800010ca:	04250513          	addi	a0,a0,66 # 80007108 <etext+0x108>
    800010ce:	ed0ff0ef          	jal	8000079e <panic>
      return -1;
    800010d2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010d4:	60a6                	ld	ra,72(sp)
    800010d6:	6406                	ld	s0,64(sp)
    800010d8:	74e2                	ld	s1,56(sp)
    800010da:	7942                	ld	s2,48(sp)
    800010dc:	79a2                	ld	s3,40(sp)
    800010de:	7a02                	ld	s4,32(sp)
    800010e0:	6ae2                	ld	s5,24(sp)
    800010e2:	6b42                	ld	s6,16(sp)
    800010e4:	6ba2                	ld	s7,8(sp)
    800010e6:	6c02                	ld	s8,0(sp)
    800010e8:	6161                	addi	sp,sp,80
    800010ea:	8082                	ret
  return 0;
    800010ec:	4501                	li	a0,0
    800010ee:	b7dd                	j	800010d4 <mappages+0x9a>

00000000800010f0 <kvmmap>:
{
    800010f0:	1141                	addi	sp,sp,-16
    800010f2:	e406                	sd	ra,8(sp)
    800010f4:	e022                	sd	s0,0(sp)
    800010f6:	0800                	addi	s0,sp,16
    800010f8:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010fa:	86b2                	mv	a3,a2
    800010fc:	863e                	mv	a2,a5
    800010fe:	f3dff0ef          	jal	8000103a <mappages>
    80001102:	e509                	bnez	a0,8000110c <kvmmap+0x1c>
}
    80001104:	60a2                	ld	ra,8(sp)
    80001106:	6402                	ld	s0,0(sp)
    80001108:	0141                	addi	sp,sp,16
    8000110a:	8082                	ret
    panic("kvmmap");
    8000110c:	00006517          	auipc	a0,0x6
    80001110:	00c50513          	addi	a0,a0,12 # 80007118 <etext+0x118>
    80001114:	e8aff0ef          	jal	8000079e <panic>

0000000080001118 <kvmmake>:
{
    80001118:	1101                	addi	sp,sp,-32
    8000111a:	ec06                	sd	ra,24(sp)
    8000111c:	e822                	sd	s0,16(sp)
    8000111e:	e426                	sd	s1,8(sp)
    80001120:	e04a                	sd	s2,0(sp)
    80001122:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001124:	a07ff0ef          	jal	80000b2a <kalloc>
    80001128:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000112a:	6605                	lui	a2,0x1
    8000112c:	4581                	li	a1,0
    8000112e:	ba1ff0ef          	jal	80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001132:	4719                	li	a4,6
    80001134:	6685                	lui	a3,0x1
    80001136:	10000637          	lui	a2,0x10000
    8000113a:	85b2                	mv	a1,a2
    8000113c:	8526                	mv	a0,s1
    8000113e:	fb3ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001142:	4719                	li	a4,6
    80001144:	6685                	lui	a3,0x1
    80001146:	10001637          	lui	a2,0x10001
    8000114a:	85b2                	mv	a1,a2
    8000114c:	8526                	mv	a0,s1
    8000114e:	fa3ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001152:	4719                	li	a4,6
    80001154:	040006b7          	lui	a3,0x4000
    80001158:	0c000637          	lui	a2,0xc000
    8000115c:	85b2                	mv	a1,a2
    8000115e:	8526                	mv	a0,s1
    80001160:	f91ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001164:	00006917          	auipc	s2,0x6
    80001168:	e9c90913          	addi	s2,s2,-356 # 80007000 <etext>
    8000116c:	4729                	li	a4,10
    8000116e:	80006697          	auipc	a3,0x80006
    80001172:	e9268693          	addi	a3,a3,-366 # 7000 <_entry-0x7fff9000>
    80001176:	4605                	li	a2,1
    80001178:	067e                	slli	a2,a2,0x1f
    8000117a:	85b2                	mv	a1,a2
    8000117c:	8526                	mv	a0,s1
    8000117e:	f73ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001182:	4719                	li	a4,6
    80001184:	46c5                	li	a3,17
    80001186:	06ee                	slli	a3,a3,0x1b
    80001188:	412686b3          	sub	a3,a3,s2
    8000118c:	864a                	mv	a2,s2
    8000118e:	85ca                	mv	a1,s2
    80001190:	8526                	mv	a0,s1
    80001192:	f5fff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001196:	4729                	li	a4,10
    80001198:	6685                	lui	a3,0x1
    8000119a:	00005617          	auipc	a2,0x5
    8000119e:	e6660613          	addi	a2,a2,-410 # 80006000 <_trampoline>
    800011a2:	040005b7          	lui	a1,0x4000
    800011a6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011a8:	05b2                	slli	a1,a1,0xc
    800011aa:	8526                	mv	a0,s1
    800011ac:	f45ff0ef          	jal	800010f0 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011b0:	8526                	mv	a0,s1
    800011b2:	5a8000ef          	jal	8000175a <proc_mapstacks>
}
    800011b6:	8526                	mv	a0,s1
    800011b8:	60e2                	ld	ra,24(sp)
    800011ba:	6442                	ld	s0,16(sp)
    800011bc:	64a2                	ld	s1,8(sp)
    800011be:	6902                	ld	s2,0(sp)
    800011c0:	6105                	addi	sp,sp,32
    800011c2:	8082                	ret

00000000800011c4 <kvminit>:
{
    800011c4:	1141                	addi	sp,sp,-16
    800011c6:	e406                	sd	ra,8(sp)
    800011c8:	e022                	sd	s0,0(sp)
    800011ca:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011cc:	f4dff0ef          	jal	80001118 <kvmmake>
    800011d0:	00009797          	auipc	a5,0x9
    800011d4:	1aa7b023          	sd	a0,416(a5) # 8000a370 <kernel_pagetable>
}
    800011d8:	60a2                	ld	ra,8(sp)
    800011da:	6402                	ld	s0,0(sp)
    800011dc:	0141                	addi	sp,sp,16
    800011de:	8082                	ret

00000000800011e0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011e0:	715d                	addi	sp,sp,-80
    800011e2:	e486                	sd	ra,72(sp)
    800011e4:	e0a2                	sd	s0,64(sp)
    800011e6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011e8:	03459793          	slli	a5,a1,0x34
    800011ec:	e39d                	bnez	a5,80001212 <uvmunmap+0x32>
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    800011fa:	8a2a                	mv	s4,a0
    800011fc:	892e                	mv	s2,a1
    800011fe:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001200:	0632                	slli	a2,a2,0xc
    80001202:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001206:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001208:	6b05                	lui	s6,0x1
    8000120a:	0735ff63          	bgeu	a1,s3,80001288 <uvmunmap+0xa8>
    8000120e:	fc26                	sd	s1,56(sp)
    80001210:	a0a9                	j	8000125a <uvmunmap+0x7a>
    80001212:	fc26                	sd	s1,56(sp)
    80001214:	f84a                	sd	s2,48(sp)
    80001216:	f44e                	sd	s3,40(sp)
    80001218:	f052                	sd	s4,32(sp)
    8000121a:	ec56                	sd	s5,24(sp)
    8000121c:	e85a                	sd	s6,16(sp)
    8000121e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001220:	00006517          	auipc	a0,0x6
    80001224:	f0050513          	addi	a0,a0,-256 # 80007120 <etext+0x120>
    80001228:	d76ff0ef          	jal	8000079e <panic>
      panic("uvmunmap: walk");
    8000122c:	00006517          	auipc	a0,0x6
    80001230:	f0c50513          	addi	a0,a0,-244 # 80007138 <etext+0x138>
    80001234:	d6aff0ef          	jal	8000079e <panic>
      panic("uvmunmap: not mapped");
    80001238:	00006517          	auipc	a0,0x6
    8000123c:	f1050513          	addi	a0,a0,-240 # 80007148 <etext+0x148>
    80001240:	d5eff0ef          	jal	8000079e <panic>
      panic("uvmunmap: not a leaf");
    80001244:	00006517          	auipc	a0,0x6
    80001248:	f1c50513          	addi	a0,a0,-228 # 80007160 <etext+0x160>
    8000124c:	d52ff0ef          	jal	8000079e <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001250:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001254:	995a                	add	s2,s2,s6
    80001256:	03397863          	bgeu	s2,s3,80001286 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000125a:	4601                	li	a2,0
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8552                	mv	a0,s4
    80001260:	d03ff0ef          	jal	80000f62 <walk>
    80001264:	84aa                	mv	s1,a0
    80001266:	d179                	beqz	a0,8000122c <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001268:	6108                	ld	a0,0(a0)
    8000126a:	00157793          	andi	a5,a0,1
    8000126e:	d7e9                	beqz	a5,80001238 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001270:	3ff57793          	andi	a5,a0,1023
    80001274:	fd7788e3          	beq	a5,s7,80001244 <uvmunmap+0x64>
    if(do_free){
    80001278:	fc0a8ce3          	beqz	s5,80001250 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    8000127c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000127e:	0532                	slli	a0,a0,0xc
    80001280:	fc8ff0ef          	jal	80000a48 <kfree>
    80001284:	b7f1                	j	80001250 <uvmunmap+0x70>
    80001286:	74e2                	ld	s1,56(sp)
    80001288:	7942                	ld	s2,48(sp)
    8000128a:	79a2                	ld	s3,40(sp)
    8000128c:	7a02                	ld	s4,32(sp)
    8000128e:	6ae2                	ld	s5,24(sp)
    80001290:	6b42                	ld	s6,16(sp)
    80001292:	6ba2                	ld	s7,8(sp)
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	6161                	addi	sp,sp,80
    8000129a:	8082                	ret

000000008000129c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000129c:	1101                	addi	sp,sp,-32
    8000129e:	ec06                	sd	ra,24(sp)
    800012a0:	e822                	sd	s0,16(sp)
    800012a2:	e426                	sd	s1,8(sp)
    800012a4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012a6:	885ff0ef          	jal	80000b2a <kalloc>
    800012aa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012ac:	c509                	beqz	a0,800012b6 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012ae:	6605                	lui	a2,0x1
    800012b0:	4581                	li	a1,0
    800012b2:	a1dff0ef          	jal	80000cce <memset>
  return pagetable;
}
    800012b6:	8526                	mv	a0,s1
    800012b8:	60e2                	ld	ra,24(sp)
    800012ba:	6442                	ld	s0,16(sp)
    800012bc:	64a2                	ld	s1,8(sp)
    800012be:	6105                	addi	sp,sp,32
    800012c0:	8082                	ret

00000000800012c2 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800012c2:	7179                	addi	sp,sp,-48
    800012c4:	f406                	sd	ra,40(sp)
    800012c6:	f022                	sd	s0,32(sp)
    800012c8:	ec26                	sd	s1,24(sp)
    800012ca:	e84a                	sd	s2,16(sp)
    800012cc:	e44e                	sd	s3,8(sp)
    800012ce:	e052                	sd	s4,0(sp)
    800012d0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012d2:	6785                	lui	a5,0x1
    800012d4:	04f67063          	bgeu	a2,a5,80001314 <uvmfirst+0x52>
    800012d8:	8a2a                	mv	s4,a0
    800012da:	89ae                	mv	s3,a1
    800012dc:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012de:	84dff0ef          	jal	80000b2a <kalloc>
    800012e2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012e4:	6605                	lui	a2,0x1
    800012e6:	4581                	li	a1,0
    800012e8:	9e7ff0ef          	jal	80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012ec:	4779                	li	a4,30
    800012ee:	86ca                	mv	a3,s2
    800012f0:	6605                	lui	a2,0x1
    800012f2:	4581                	li	a1,0
    800012f4:	8552                	mv	a0,s4
    800012f6:	d45ff0ef          	jal	8000103a <mappages>
  memmove(mem, src, sz);
    800012fa:	8626                	mv	a2,s1
    800012fc:	85ce                	mv	a1,s3
    800012fe:	854a                	mv	a0,s2
    80001300:	a33ff0ef          	jal	80000d32 <memmove>
}
    80001304:	70a2                	ld	ra,40(sp)
    80001306:	7402                	ld	s0,32(sp)
    80001308:	64e2                	ld	s1,24(sp)
    8000130a:	6942                	ld	s2,16(sp)
    8000130c:	69a2                	ld	s3,8(sp)
    8000130e:	6a02                	ld	s4,0(sp)
    80001310:	6145                	addi	sp,sp,48
    80001312:	8082                	ret
    panic("uvmfirst: more than a page");
    80001314:	00006517          	auipc	a0,0x6
    80001318:	e6450513          	addi	a0,a0,-412 # 80007178 <etext+0x178>
    8000131c:	c82ff0ef          	jal	8000079e <panic>

0000000080001320 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001320:	1101                	addi	sp,sp,-32
    80001322:	ec06                	sd	ra,24(sp)
    80001324:	e822                	sd	s0,16(sp)
    80001326:	e426                	sd	s1,8(sp)
    80001328:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000132a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000132c:	00b67d63          	bgeu	a2,a1,80001346 <uvmdealloc+0x26>
    80001330:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001332:	6785                	lui	a5,0x1
    80001334:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001336:	00f60733          	add	a4,a2,a5
    8000133a:	76fd                	lui	a3,0xfffff
    8000133c:	8f75                	and	a4,a4,a3
    8000133e:	97ae                	add	a5,a5,a1
    80001340:	8ff5                	and	a5,a5,a3
    80001342:	00f76863          	bltu	a4,a5,80001352 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001346:	8526                	mv	a0,s1
    80001348:	60e2                	ld	ra,24(sp)
    8000134a:	6442                	ld	s0,16(sp)
    8000134c:	64a2                	ld	s1,8(sp)
    8000134e:	6105                	addi	sp,sp,32
    80001350:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001352:	8f99                	sub	a5,a5,a4
    80001354:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001356:	4685                	li	a3,1
    80001358:	0007861b          	sext.w	a2,a5
    8000135c:	85ba                	mv	a1,a4
    8000135e:	e83ff0ef          	jal	800011e0 <uvmunmap>
    80001362:	b7d5                	j	80001346 <uvmdealloc+0x26>

0000000080001364 <uvmalloc>:
  if(newsz < oldsz)
    80001364:	0ab66363          	bltu	a2,a1,8000140a <uvmalloc+0xa6>
{
    80001368:	715d                	addi	sp,sp,-80
    8000136a:	e486                	sd	ra,72(sp)
    8000136c:	e0a2                	sd	s0,64(sp)
    8000136e:	f052                	sd	s4,32(sp)
    80001370:	ec56                	sd	s5,24(sp)
    80001372:	e85a                	sd	s6,16(sp)
    80001374:	0880                	addi	s0,sp,80
    80001376:	8b2a                	mv	s6,a0
    80001378:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    8000137a:	6785                	lui	a5,0x1
    8000137c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000137e:	95be                	add	a1,a1,a5
    80001380:	77fd                	lui	a5,0xfffff
    80001382:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001386:	08ca7463          	bgeu	s4,a2,8000140e <uvmalloc+0xaa>
    8000138a:	fc26                	sd	s1,56(sp)
    8000138c:	f84a                	sd	s2,48(sp)
    8000138e:	f44e                	sd	s3,40(sp)
    80001390:	e45e                	sd	s7,8(sp)
    80001392:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    80001394:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001396:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    8000139a:	f90ff0ef          	jal	80000b2a <kalloc>
    8000139e:	84aa                	mv	s1,a0
    if(mem == 0){
    800013a0:	c515                	beqz	a0,800013cc <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    800013a2:	864e                	mv	a2,s3
    800013a4:	4581                	li	a1,0
    800013a6:	929ff0ef          	jal	80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013aa:	875e                	mv	a4,s7
    800013ac:	86a6                	mv	a3,s1
    800013ae:	864e                	mv	a2,s3
    800013b0:	85ca                	mv	a1,s2
    800013b2:	855a                	mv	a0,s6
    800013b4:	c87ff0ef          	jal	8000103a <mappages>
    800013b8:	e91d                	bnez	a0,800013ee <uvmalloc+0x8a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013ba:	994e                	add	s2,s2,s3
    800013bc:	fd596fe3          	bltu	s2,s5,8000139a <uvmalloc+0x36>
  return newsz;
    800013c0:	8556                	mv	a0,s5
    800013c2:	74e2                	ld	s1,56(sp)
    800013c4:	7942                	ld	s2,48(sp)
    800013c6:	79a2                	ld	s3,40(sp)
    800013c8:	6ba2                	ld	s7,8(sp)
    800013ca:	a819                	j	800013e0 <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    800013cc:	8652                	mv	a2,s4
    800013ce:	85ca                	mv	a1,s2
    800013d0:	855a                	mv	a0,s6
    800013d2:	f4fff0ef          	jal	80001320 <uvmdealloc>
      return 0;
    800013d6:	4501                	li	a0,0
    800013d8:	74e2                	ld	s1,56(sp)
    800013da:	7942                	ld	s2,48(sp)
    800013dc:	79a2                	ld	s3,40(sp)
    800013de:	6ba2                	ld	s7,8(sp)
}
    800013e0:	60a6                	ld	ra,72(sp)
    800013e2:	6406                	ld	s0,64(sp)
    800013e4:	7a02                	ld	s4,32(sp)
    800013e6:	6ae2                	ld	s5,24(sp)
    800013e8:	6b42                	ld	s6,16(sp)
    800013ea:	6161                	addi	sp,sp,80
    800013ec:	8082                	ret
      kfree(mem);
    800013ee:	8526                	mv	a0,s1
    800013f0:	e58ff0ef          	jal	80000a48 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013f4:	8652                	mv	a2,s4
    800013f6:	85ca                	mv	a1,s2
    800013f8:	855a                	mv	a0,s6
    800013fa:	f27ff0ef          	jal	80001320 <uvmdealloc>
      return 0;
    800013fe:	4501                	li	a0,0
    80001400:	74e2                	ld	s1,56(sp)
    80001402:	7942                	ld	s2,48(sp)
    80001404:	79a2                	ld	s3,40(sp)
    80001406:	6ba2                	ld	s7,8(sp)
    80001408:	bfe1                	j	800013e0 <uvmalloc+0x7c>
    return oldsz;
    8000140a:	852e                	mv	a0,a1
}
    8000140c:	8082                	ret
  return newsz;
    8000140e:	8532                	mv	a0,a2
    80001410:	bfc1                	j	800013e0 <uvmalloc+0x7c>

0000000080001412 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001412:	7179                	addi	sp,sp,-48
    80001414:	f406                	sd	ra,40(sp)
    80001416:	f022                	sd	s0,32(sp)
    80001418:	ec26                	sd	s1,24(sp)
    8000141a:	e84a                	sd	s2,16(sp)
    8000141c:	e44e                	sd	s3,8(sp)
    8000141e:	e052                	sd	s4,0(sp)
    80001420:	1800                	addi	s0,sp,48
    80001422:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001424:	84aa                	mv	s1,a0
    80001426:	6905                	lui	s2,0x1
    80001428:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000142a:	4985                	li	s3,1
    8000142c:	a819                	j	80001442 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000142e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001430:	00c79513          	slli	a0,a5,0xc
    80001434:	fdfff0ef          	jal	80001412 <freewalk>
      pagetable[i] = 0;
    80001438:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000143c:	04a1                	addi	s1,s1,8
    8000143e:	01248f63          	beq	s1,s2,8000145c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001442:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001444:	00f7f713          	andi	a4,a5,15
    80001448:	ff3703e3          	beq	a4,s3,8000142e <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000144c:	8b85                	andi	a5,a5,1
    8000144e:	d7fd                	beqz	a5,8000143c <freewalk+0x2a>
      panic("freewalk: leaf");
    80001450:	00006517          	auipc	a0,0x6
    80001454:	d4850513          	addi	a0,a0,-696 # 80007198 <etext+0x198>
    80001458:	b46ff0ef          	jal	8000079e <panic>
    }
  }
  kfree((void*)pagetable);
    8000145c:	8552                	mv	a0,s4
    8000145e:	deaff0ef          	jal	80000a48 <kfree>
}
    80001462:	70a2                	ld	ra,40(sp)
    80001464:	7402                	ld	s0,32(sp)
    80001466:	64e2                	ld	s1,24(sp)
    80001468:	6942                	ld	s2,16(sp)
    8000146a:	69a2                	ld	s3,8(sp)
    8000146c:	6a02                	ld	s4,0(sp)
    8000146e:	6145                	addi	sp,sp,48
    80001470:	8082                	ret

0000000080001472 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001472:	1101                	addi	sp,sp,-32
    80001474:	ec06                	sd	ra,24(sp)
    80001476:	e822                	sd	s0,16(sp)
    80001478:	e426                	sd	s1,8(sp)
    8000147a:	1000                	addi	s0,sp,32
    8000147c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000147e:	e989                	bnez	a1,80001490 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001480:	8526                	mv	a0,s1
    80001482:	f91ff0ef          	jal	80001412 <freewalk>
}
    80001486:	60e2                	ld	ra,24(sp)
    80001488:	6442                	ld	s0,16(sp)
    8000148a:	64a2                	ld	s1,8(sp)
    8000148c:	6105                	addi	sp,sp,32
    8000148e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	4685                	li	a3,1
    80001498:	00c5d613          	srli	a2,a1,0xc
    8000149c:	4581                	li	a1,0
    8000149e:	d43ff0ef          	jal	800011e0 <uvmunmap>
    800014a2:	bff9                	j	80001480 <uvmfree+0xe>

00000000800014a4 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800014a4:	ca4d                	beqz	a2,80001556 <uvmcopy+0xb2>
{
    800014a6:	715d                	addi	sp,sp,-80
    800014a8:	e486                	sd	ra,72(sp)
    800014aa:	e0a2                	sd	s0,64(sp)
    800014ac:	fc26                	sd	s1,56(sp)
    800014ae:	f84a                	sd	s2,48(sp)
    800014b0:	f44e                	sd	s3,40(sp)
    800014b2:	f052                	sd	s4,32(sp)
    800014b4:	ec56                	sd	s5,24(sp)
    800014b6:	e85a                	sd	s6,16(sp)
    800014b8:	e45e                	sd	s7,8(sp)
    800014ba:	e062                	sd	s8,0(sp)
    800014bc:	0880                	addi	s0,sp,80
    800014be:	8baa                	mv	s7,a0
    800014c0:	8b2e                	mv	s6,a1
    800014c2:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014c4:	4981                	li	s3,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014c6:	6a05                	lui	s4,0x1
    if((pte = walk(old, i, 0)) == 0)
    800014c8:	4601                	li	a2,0
    800014ca:	85ce                	mv	a1,s3
    800014cc:	855e                	mv	a0,s7
    800014ce:	a95ff0ef          	jal	80000f62 <walk>
    800014d2:	cd1d                	beqz	a0,80001510 <uvmcopy+0x6c>
    if((*pte & PTE_V) == 0)
    800014d4:	6118                	ld	a4,0(a0)
    800014d6:	00177793          	andi	a5,a4,1
    800014da:	c3a9                	beqz	a5,8000151c <uvmcopy+0x78>
    pa = PTE2PA(*pte);
    800014dc:	00a75593          	srli	a1,a4,0xa
    800014e0:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014e4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014e8:	e42ff0ef          	jal	80000b2a <kalloc>
    800014ec:	892a                	mv	s2,a0
    800014ee:	c121                	beqz	a0,8000152e <uvmcopy+0x8a>
    memmove(mem, (char*)pa, PGSIZE);
    800014f0:	8652                	mv	a2,s4
    800014f2:	85e2                	mv	a1,s8
    800014f4:	83fff0ef          	jal	80000d32 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014f8:	8726                	mv	a4,s1
    800014fa:	86ca                	mv	a3,s2
    800014fc:	8652                	mv	a2,s4
    800014fe:	85ce                	mv	a1,s3
    80001500:	855a                	mv	a0,s6
    80001502:	b39ff0ef          	jal	8000103a <mappages>
    80001506:	e10d                	bnez	a0,80001528 <uvmcopy+0x84>
  for(i = 0; i < sz; i += PGSIZE){
    80001508:	99d2                	add	s3,s3,s4
    8000150a:	fb59efe3          	bltu	s3,s5,800014c8 <uvmcopy+0x24>
    8000150e:	a805                	j	8000153e <uvmcopy+0x9a>
      panic("uvmcopy: pte should exist");
    80001510:	00006517          	auipc	a0,0x6
    80001514:	c9850513          	addi	a0,a0,-872 # 800071a8 <etext+0x1a8>
    80001518:	a86ff0ef          	jal	8000079e <panic>
      panic("uvmcopy: page not present");
    8000151c:	00006517          	auipc	a0,0x6
    80001520:	cac50513          	addi	a0,a0,-852 # 800071c8 <etext+0x1c8>
    80001524:	a7aff0ef          	jal	8000079e <panic>
      kfree(mem);
    80001528:	854a                	mv	a0,s2
    8000152a:	d1eff0ef          	jal	80000a48 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000152e:	4685                	li	a3,1
    80001530:	00c9d613          	srli	a2,s3,0xc
    80001534:	4581                	li	a1,0
    80001536:	855a                	mv	a0,s6
    80001538:	ca9ff0ef          	jal	800011e0 <uvmunmap>
  return -1;
    8000153c:	557d                	li	a0,-1
}
    8000153e:	60a6                	ld	ra,72(sp)
    80001540:	6406                	ld	s0,64(sp)
    80001542:	74e2                	ld	s1,56(sp)
    80001544:	7942                	ld	s2,48(sp)
    80001546:	79a2                	ld	s3,40(sp)
    80001548:	7a02                	ld	s4,32(sp)
    8000154a:	6ae2                	ld	s5,24(sp)
    8000154c:	6b42                	ld	s6,16(sp)
    8000154e:	6ba2                	ld	s7,8(sp)
    80001550:	6c02                	ld	s8,0(sp)
    80001552:	6161                	addi	sp,sp,80
    80001554:	8082                	ret
  return 0;
    80001556:	4501                	li	a0,0
}
    80001558:	8082                	ret

000000008000155a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000155a:	1141                	addi	sp,sp,-16
    8000155c:	e406                	sd	ra,8(sp)
    8000155e:	e022                	sd	s0,0(sp)
    80001560:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001562:	4601                	li	a2,0
    80001564:	9ffff0ef          	jal	80000f62 <walk>
  if(pte == 0)
    80001568:	c901                	beqz	a0,80001578 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000156a:	611c                	ld	a5,0(a0)
    8000156c:	9bbd                	andi	a5,a5,-17
    8000156e:	e11c                	sd	a5,0(a0)
}
    80001570:	60a2                	ld	ra,8(sp)
    80001572:	6402                	ld	s0,0(sp)
    80001574:	0141                	addi	sp,sp,16
    80001576:	8082                	ret
    panic("uvmclear");
    80001578:	00006517          	auipc	a0,0x6
    8000157c:	c7050513          	addi	a0,a0,-912 # 800071e8 <etext+0x1e8>
    80001580:	a1eff0ef          	jal	8000079e <panic>

0000000080001584 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001584:	c2d9                	beqz	a3,8000160a <copyout+0x86>
{
    80001586:	711d                	addi	sp,sp,-96
    80001588:	ec86                	sd	ra,88(sp)
    8000158a:	e8a2                	sd	s0,80(sp)
    8000158c:	e4a6                	sd	s1,72(sp)
    8000158e:	e0ca                	sd	s2,64(sp)
    80001590:	fc4e                	sd	s3,56(sp)
    80001592:	f852                	sd	s4,48(sp)
    80001594:	f456                	sd	s5,40(sp)
    80001596:	f05a                	sd	s6,32(sp)
    80001598:	ec5e                	sd	s7,24(sp)
    8000159a:	e862                	sd	s8,16(sp)
    8000159c:	e466                	sd	s9,8(sp)
    8000159e:	e06a                	sd	s10,0(sp)
    800015a0:	1080                	addi	s0,sp,96
    800015a2:	8c2a                	mv	s8,a0
    800015a4:	892e                	mv	s2,a1
    800015a6:	8ab2                	mv	s5,a2
    800015a8:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015aa:	7cfd                	lui	s9,0xfffff
    if(va0 >= MAXVA)
    800015ac:	5bfd                	li	s7,-1
    800015ae:	01abdb93          	srli	s7,s7,0x1a
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015b2:	4d55                	li	s10,21
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    n = PGSIZE - (dstva - va0);
    800015b4:	6b05                	lui	s6,0x1
    800015b6:	a015                	j	800015da <copyout+0x56>
    pa0 = PTE2PA(*pte);
    800015b8:	83a9                	srli	a5,a5,0xa
    800015ba:	07b2                	slli	a5,a5,0xc
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015bc:	41390533          	sub	a0,s2,s3
    800015c0:	0004861b          	sext.w	a2,s1
    800015c4:	85d6                	mv	a1,s5
    800015c6:	953e                	add	a0,a0,a5
    800015c8:	f6aff0ef          	jal	80000d32 <memmove>

    len -= n;
    800015cc:	409a0a33          	sub	s4,s4,s1
    src += n;
    800015d0:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    800015d2:	01698933          	add	s2,s3,s6
  while(len > 0){
    800015d6:	020a0863          	beqz	s4,80001606 <copyout+0x82>
    va0 = PGROUNDDOWN(dstva);
    800015da:	019979b3          	and	s3,s2,s9
    if(va0 >= MAXVA)
    800015de:	033be863          	bltu	s7,s3,8000160e <copyout+0x8a>
    pte = walk(pagetable, va0, 0);
    800015e2:	4601                	li	a2,0
    800015e4:	85ce                	mv	a1,s3
    800015e6:	8562                	mv	a0,s8
    800015e8:	97bff0ef          	jal	80000f62 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015ec:	c121                	beqz	a0,8000162c <copyout+0xa8>
    800015ee:	611c                	ld	a5,0(a0)
    800015f0:	0157f713          	andi	a4,a5,21
    800015f4:	03a71e63          	bne	a4,s10,80001630 <copyout+0xac>
    n = PGSIZE - (dstva - va0);
    800015f8:	412984b3          	sub	s1,s3,s2
    800015fc:	94da                	add	s1,s1,s6
    if(n > len)
    800015fe:	fa9a7de3          	bgeu	s4,s1,800015b8 <copyout+0x34>
    80001602:	84d2                	mv	s1,s4
    80001604:	bf55                	j	800015b8 <copyout+0x34>
  }
  return 0;
    80001606:	4501                	li	a0,0
    80001608:	a021                	j	80001610 <copyout+0x8c>
    8000160a:	4501                	li	a0,0
}
    8000160c:	8082                	ret
      return -1;
    8000160e:	557d                	li	a0,-1
}
    80001610:	60e6                	ld	ra,88(sp)
    80001612:	6446                	ld	s0,80(sp)
    80001614:	64a6                	ld	s1,72(sp)
    80001616:	6906                	ld	s2,64(sp)
    80001618:	79e2                	ld	s3,56(sp)
    8000161a:	7a42                	ld	s4,48(sp)
    8000161c:	7aa2                	ld	s5,40(sp)
    8000161e:	7b02                	ld	s6,32(sp)
    80001620:	6be2                	ld	s7,24(sp)
    80001622:	6c42                	ld	s8,16(sp)
    80001624:	6ca2                	ld	s9,8(sp)
    80001626:	6d02                	ld	s10,0(sp)
    80001628:	6125                	addi	sp,sp,96
    8000162a:	8082                	ret
      return -1;
    8000162c:	557d                	li	a0,-1
    8000162e:	b7cd                	j	80001610 <copyout+0x8c>
    80001630:	557d                	li	a0,-1
    80001632:	bff9                	j	80001610 <copyout+0x8c>

0000000080001634 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001634:	c6a5                	beqz	a3,8000169c <copyin+0x68>
{
    80001636:	715d                	addi	sp,sp,-80
    80001638:	e486                	sd	ra,72(sp)
    8000163a:	e0a2                	sd	s0,64(sp)
    8000163c:	fc26                	sd	s1,56(sp)
    8000163e:	f84a                	sd	s2,48(sp)
    80001640:	f44e                	sd	s3,40(sp)
    80001642:	f052                	sd	s4,32(sp)
    80001644:	ec56                	sd	s5,24(sp)
    80001646:	e85a                	sd	s6,16(sp)
    80001648:	e45e                	sd	s7,8(sp)
    8000164a:	e062                	sd	s8,0(sp)
    8000164c:	0880                	addi	s0,sp,80
    8000164e:	8b2a                	mv	s6,a0
    80001650:	8a2e                	mv	s4,a1
    80001652:	8c32                	mv	s8,a2
    80001654:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001656:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001658:	6a85                	lui	s5,0x1
    8000165a:	a00d                	j	8000167c <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000165c:	018505b3          	add	a1,a0,s8
    80001660:	0004861b          	sext.w	a2,s1
    80001664:	412585b3          	sub	a1,a1,s2
    80001668:	8552                	mv	a0,s4
    8000166a:	ec8ff0ef          	jal	80000d32 <memmove>

    len -= n;
    8000166e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001672:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001674:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001678:	02098063          	beqz	s3,80001698 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    8000167c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001680:	85ca                	mv	a1,s2
    80001682:	855a                	mv	a0,s6
    80001684:	979ff0ef          	jal	80000ffc <walkaddr>
    if(pa0 == 0)
    80001688:	cd01                	beqz	a0,800016a0 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000168a:	418904b3          	sub	s1,s2,s8
    8000168e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001690:	fc99f6e3          	bgeu	s3,s1,8000165c <copyin+0x28>
    80001694:	84ce                	mv	s1,s3
    80001696:	b7d9                	j	8000165c <copyin+0x28>
  }
  return 0;
    80001698:	4501                	li	a0,0
    8000169a:	a021                	j	800016a2 <copyin+0x6e>
    8000169c:	4501                	li	a0,0
}
    8000169e:	8082                	ret
      return -1;
    800016a0:	557d                	li	a0,-1
}
    800016a2:	60a6                	ld	ra,72(sp)
    800016a4:	6406                	ld	s0,64(sp)
    800016a6:	74e2                	ld	s1,56(sp)
    800016a8:	7942                	ld	s2,48(sp)
    800016aa:	79a2                	ld	s3,40(sp)
    800016ac:	7a02                	ld	s4,32(sp)
    800016ae:	6ae2                	ld	s5,24(sp)
    800016b0:	6b42                	ld	s6,16(sp)
    800016b2:	6ba2                	ld	s7,8(sp)
    800016b4:	6c02                	ld	s8,0(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret

00000000800016ba <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800016ba:	715d                	addi	sp,sp,-80
    800016bc:	e486                	sd	ra,72(sp)
    800016be:	e0a2                	sd	s0,64(sp)
    800016c0:	fc26                	sd	s1,56(sp)
    800016c2:	f84a                	sd	s2,48(sp)
    800016c4:	f44e                	sd	s3,40(sp)
    800016c6:	f052                	sd	s4,32(sp)
    800016c8:	ec56                	sd	s5,24(sp)
    800016ca:	e85a                	sd	s6,16(sp)
    800016cc:	e45e                	sd	s7,8(sp)
    800016ce:	0880                	addi	s0,sp,80
    800016d0:	8aaa                	mv	s5,a0
    800016d2:	89ae                	mv	s3,a1
    800016d4:	8bb2                	mv	s7,a2
    800016d6:	84b6                	mv	s1,a3
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    800016d8:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016da:	6a05                	lui	s4,0x1
    800016dc:	a02d                	j	80001706 <copyinstr+0x4c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016de:	00078023          	sb	zero,0(a5)
    800016e2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016e4:	0017c793          	xori	a5,a5,1
    800016e8:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016ec:	60a6                	ld	ra,72(sp)
    800016ee:	6406                	ld	s0,64(sp)
    800016f0:	74e2                	ld	s1,56(sp)
    800016f2:	7942                	ld	s2,48(sp)
    800016f4:	79a2                	ld	s3,40(sp)
    800016f6:	7a02                	ld	s4,32(sp)
    800016f8:	6ae2                	ld	s5,24(sp)
    800016fa:	6b42                	ld	s6,16(sp)
    800016fc:	6ba2                	ld	s7,8(sp)
    800016fe:	6161                	addi	sp,sp,80
    80001700:	8082                	ret
    srcva = va0 + PGSIZE;
    80001702:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001706:	c4b1                	beqz	s1,80001752 <copyinstr+0x98>
    va0 = PGROUNDDOWN(srcva);
    80001708:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000170c:	85ca                	mv	a1,s2
    8000170e:	8556                	mv	a0,s5
    80001710:	8edff0ef          	jal	80000ffc <walkaddr>
    if(pa0 == 0)
    80001714:	c129                	beqz	a0,80001756 <copyinstr+0x9c>
    n = PGSIZE - (srcva - va0);
    80001716:	41790633          	sub	a2,s2,s7
    8000171a:	9652                	add	a2,a2,s4
    if(n > max)
    8000171c:	00c4f363          	bgeu	s1,a2,80001722 <copyinstr+0x68>
    80001720:	8626                	mv	a2,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001722:	412b8bb3          	sub	s7,s7,s2
    80001726:	9baa                	add	s7,s7,a0
    while(n > 0){
    80001728:	de69                	beqz	a2,80001702 <copyinstr+0x48>
    8000172a:	87ce                	mv	a5,s3
      if(*p == '\0'){
    8000172c:	413b86b3          	sub	a3,s7,s3
    while(n > 0){
    80001730:	964e                	add	a2,a2,s3
    80001732:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001734:	00f68733          	add	a4,a3,a5
    80001738:	00074703          	lbu	a4,0(a4)
    8000173c:	d34d                	beqz	a4,800016de <copyinstr+0x24>
        *dst = *p;
    8000173e:	00e78023          	sb	a4,0(a5)
      dst++;
    80001742:	0785                	addi	a5,a5,1
    while(n > 0){
    80001744:	fec797e3          	bne	a5,a2,80001732 <copyinstr+0x78>
    80001748:	14fd                	addi	s1,s1,-1
    8000174a:	94ce                	add	s1,s1,s3
      --max;
    8000174c:	8c8d                	sub	s1,s1,a1
    8000174e:	89be                	mv	s3,a5
    80001750:	bf4d                	j	80001702 <copyinstr+0x48>
    80001752:	4781                	li	a5,0
    80001754:	bf41                	j	800016e4 <copyinstr+0x2a>
      return -1;
    80001756:	557d                	li	a0,-1
    80001758:	bf51                	j	800016ec <copyinstr+0x32>

000000008000175a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	e062                	sd	s8,0(sp)
    80001770:	0880                	addi	s0,sp,80
    80001772:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001774:	00011497          	auipc	s1,0x11
    80001778:	16c48493          	addi	s1,s1,364 # 800128e0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000177c:	8c26                	mv	s8,s1
    8000177e:	fafb07b7          	lui	a5,0xfafb0
    80001782:	afb78793          	addi	a5,a5,-1285 # fffffffffafafafb <end+0xffffffff7af8b783>
    80001786:	02079993          	slli	s3,a5,0x20
    8000178a:	99be                	add	s3,s3,a5
    8000178c:	04000937          	lui	s2,0x4000
    80001790:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001792:	0932                	slli	s2,s2,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001794:	4b99                	li	s7,6
    80001796:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001798:	00017a97          	auipc	s5,0x17
    8000179c:	748a8a93          	addi	s5,s5,1864 # 80018ee0 <tickslock>
    char *pa = kalloc();
    800017a0:	b8aff0ef          	jal	80000b2a <kalloc>
    800017a4:	862a                	mv	a2,a0
    if(pa == 0)
    800017a6:	c121                	beqz	a0,800017e6 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017a8:	418485b3          	sub	a1,s1,s8
    800017ac:	858d                	srai	a1,a1,0x3
    800017ae:	033585b3          	mul	a1,a1,s3
    800017b2:	2585                	addiw	a1,a1,1
    800017b4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017b8:	875e                	mv	a4,s7
    800017ba:	86da                	mv	a3,s6
    800017bc:	40b905b3          	sub	a1,s2,a1
    800017c0:	8552                	mv	a0,s4
    800017c2:	92fff0ef          	jal	800010f0 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c6:	19848493          	addi	s1,s1,408
    800017ca:	fd549be3          	bne	s1,s5,800017a0 <proc_mapstacks+0x46>
  }
}
    800017ce:	60a6                	ld	ra,72(sp)
    800017d0:	6406                	ld	s0,64(sp)
    800017d2:	74e2                	ld	s1,56(sp)
    800017d4:	7942                	ld	s2,48(sp)
    800017d6:	79a2                	ld	s3,40(sp)
    800017d8:	7a02                	ld	s4,32(sp)
    800017da:	6ae2                	ld	s5,24(sp)
    800017dc:	6b42                	ld	s6,16(sp)
    800017de:	6ba2                	ld	s7,8(sp)
    800017e0:	6c02                	ld	s8,0(sp)
    800017e2:	6161                	addi	sp,sp,80
    800017e4:	8082                	ret
      panic("kalloc");
    800017e6:	00006517          	auipc	a0,0x6
    800017ea:	a1250513          	addi	a0,a0,-1518 # 800071f8 <etext+0x1f8>
    800017ee:	fb1fe0ef          	jal	8000079e <panic>

00000000800017f2 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017f2:	7139                	addi	sp,sp,-64
    800017f4:	fc06                	sd	ra,56(sp)
    800017f6:	f822                	sd	s0,48(sp)
    800017f8:	f426                	sd	s1,40(sp)
    800017fa:	f04a                	sd	s2,32(sp)
    800017fc:	ec4e                	sd	s3,24(sp)
    800017fe:	e852                	sd	s4,16(sp)
    80001800:	e456                	sd	s5,8(sp)
    80001802:	e05a                	sd	s6,0(sp)
    80001804:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001806:	00006597          	auipc	a1,0x6
    8000180a:	9fa58593          	addi	a1,a1,-1542 # 80007200 <etext+0x200>
    8000180e:	00011517          	auipc	a0,0x11
    80001812:	ca250513          	addi	a0,a0,-862 # 800124b0 <pid_lock>
    80001816:	b64ff0ef          	jal	80000b7a <initlock>
  initlock(&wait_lock, "wait_lock");
    8000181a:	00006597          	auipc	a1,0x6
    8000181e:	9ee58593          	addi	a1,a1,-1554 # 80007208 <etext+0x208>
    80001822:	00011517          	auipc	a0,0x11
    80001826:	ca650513          	addi	a0,a0,-858 # 800124c8 <wait_lock>
    8000182a:	b50ff0ef          	jal	80000b7a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000182e:	00011497          	auipc	s1,0x11
    80001832:	0b248493          	addi	s1,s1,178 # 800128e0 <proc>
      initlock(&p->lock, "proc");
    80001836:	00006b17          	auipc	s6,0x6
    8000183a:	9e2b0b13          	addi	s6,s6,-1566 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000183e:	8aa6                	mv	s5,s1
    80001840:	fafb07b7          	lui	a5,0xfafb0
    80001844:	afb78793          	addi	a5,a5,-1285 # fffffffffafafafb <end+0xffffffff7af8b783>
    80001848:	02079993          	slli	s3,a5,0x20
    8000184c:	99be                	add	s3,s3,a5
    8000184e:	04000937          	lui	s2,0x4000
    80001852:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001854:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001856:	00017a17          	auipc	s4,0x17
    8000185a:	68aa0a13          	addi	s4,s4,1674 # 80018ee0 <tickslock>
      initlock(&p->lock, "proc");
    8000185e:	85da                	mv	a1,s6
    80001860:	8526                	mv	a0,s1
    80001862:	b18ff0ef          	jal	80000b7a <initlock>
      p->state = UNUSED;
    80001866:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000186a:	415487b3          	sub	a5,s1,s5
    8000186e:	878d                	srai	a5,a5,0x3
    80001870:	033787b3          	mul	a5,a5,s3
    80001874:	2785                	addiw	a5,a5,1
    80001876:	00d7979b          	slliw	a5,a5,0xd
    8000187a:	40f907b3          	sub	a5,s2,a5
    8000187e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001880:	19848493          	addi	s1,s1,408
    80001884:	fd449de3          	bne	s1,s4,8000185e <procinit+0x6c>
  }
}
    80001888:	70e2                	ld	ra,56(sp)
    8000188a:	7442                	ld	s0,48(sp)
    8000188c:	74a2                	ld	s1,40(sp)
    8000188e:	7902                	ld	s2,32(sp)
    80001890:	69e2                	ld	s3,24(sp)
    80001892:	6a42                	ld	s4,16(sp)
    80001894:	6aa2                	ld	s5,8(sp)
    80001896:	6b02                	ld	s6,0(sp)
    80001898:	6121                	addi	sp,sp,64
    8000189a:	8082                	ret

000000008000189c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000189c:	1141                	addi	sp,sp,-16
    8000189e:	e406                	sd	ra,8(sp)
    800018a0:	e022                	sd	s0,0(sp)
    800018a2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018a4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018a6:	2501                	sext.w	a0,a0
    800018a8:	60a2                	ld	ra,8(sp)
    800018aa:	6402                	ld	s0,0(sp)
    800018ac:	0141                	addi	sp,sp,16
    800018ae:	8082                	ret

00000000800018b0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018b0:	1141                	addi	sp,sp,-16
    800018b2:	e406                	sd	ra,8(sp)
    800018b4:	e022                	sd	s0,0(sp)
    800018b6:	0800                	addi	s0,sp,16
    800018b8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ba:	2781                	sext.w	a5,a5
    800018bc:	079e                	slli	a5,a5,0x7
  return c;
}
    800018be:	00011517          	auipc	a0,0x11
    800018c2:	c2250513          	addi	a0,a0,-990 # 800124e0 <cpus>
    800018c6:	953e                	add	a0,a0,a5
    800018c8:	60a2                	ld	ra,8(sp)
    800018ca:	6402                	ld	s0,0(sp)
    800018cc:	0141                	addi	sp,sp,16
    800018ce:	8082                	ret

00000000800018d0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018d0:	1101                	addi	sp,sp,-32
    800018d2:	ec06                	sd	ra,24(sp)
    800018d4:	e822                	sd	s0,16(sp)
    800018d6:	e426                	sd	s1,8(sp)
    800018d8:	1000                	addi	s0,sp,32
  push_off();
    800018da:	ae4ff0ef          	jal	80000bbe <push_off>
    800018de:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018e0:	2781                	sext.w	a5,a5
    800018e2:	079e                	slli	a5,a5,0x7
    800018e4:	00011717          	auipc	a4,0x11
    800018e8:	bcc70713          	addi	a4,a4,-1076 # 800124b0 <pid_lock>
    800018ec:	97ba                	add	a5,a5,a4
    800018ee:	7b84                	ld	s1,48(a5)
  pop_off();
    800018f0:	b52ff0ef          	jal	80000c42 <pop_off>
  return p;
}
    800018f4:	8526                	mv	a0,s1
    800018f6:	60e2                	ld	ra,24(sp)
    800018f8:	6442                	ld	s0,16(sp)
    800018fa:	64a2                	ld	s1,8(sp)
    800018fc:	6105                	addi	sp,sp,32
    800018fe:	8082                	ret

0000000080001900 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001900:	1141                	addi	sp,sp,-16
    80001902:	e406                	sd	ra,8(sp)
    80001904:	e022                	sd	s0,0(sp)
    80001906:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001908:	fc9ff0ef          	jal	800018d0 <myproc>
    8000190c:	b86ff0ef          	jal	80000c92 <release>

  if (first) {
    80001910:	00009797          	auipc	a5,0x9
    80001914:	9d07a783          	lw	a5,-1584(a5) # 8000a2e0 <first.1>
    80001918:	e799                	bnez	a5,80001926 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000191a:	2d5000ef          	jal	800023ee <usertrapret>
}
    8000191e:	60a2                	ld	ra,8(sp)
    80001920:	6402                	ld	s0,0(sp)
    80001922:	0141                	addi	sp,sp,16
    80001924:	8082                	ret
    fsinit(ROOTDEV);
    80001926:	4505                	li	a0,1
    80001928:	7b6010ef          	jal	800030de <fsinit>
    first = 0;
    8000192c:	00009797          	auipc	a5,0x9
    80001930:	9a07aa23          	sw	zero,-1612(a5) # 8000a2e0 <first.1>
    __sync_synchronize();
    80001934:	0330000f          	fence	rw,rw
    80001938:	b7cd                	j	8000191a <forkret+0x1a>

000000008000193a <allocpid>:
{
    8000193a:	1101                	addi	sp,sp,-32
    8000193c:	ec06                	sd	ra,24(sp)
    8000193e:	e822                	sd	s0,16(sp)
    80001940:	e426                	sd	s1,8(sp)
    80001942:	e04a                	sd	s2,0(sp)
    80001944:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001946:	00011917          	auipc	s2,0x11
    8000194a:	b6a90913          	addi	s2,s2,-1174 # 800124b0 <pid_lock>
    8000194e:	854a                	mv	a0,s2
    80001950:	aaeff0ef          	jal	80000bfe <acquire>
  pid = nextpid;
    80001954:	00009797          	auipc	a5,0x9
    80001958:	99078793          	addi	a5,a5,-1648 # 8000a2e4 <nextpid>
    8000195c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000195e:	0014871b          	addiw	a4,s1,1
    80001962:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001964:	854a                	mv	a0,s2
    80001966:	b2cff0ef          	jal	80000c92 <release>
}
    8000196a:	8526                	mv	a0,s1
    8000196c:	60e2                	ld	ra,24(sp)
    8000196e:	6442                	ld	s0,16(sp)
    80001970:	64a2                	ld	s1,8(sp)
    80001972:	6902                	ld	s2,0(sp)
    80001974:	6105                	addi	sp,sp,32
    80001976:	8082                	ret

0000000080001978 <proc_pagetable>:
{
    80001978:	1101                	addi	sp,sp,-32
    8000197a:	ec06                	sd	ra,24(sp)
    8000197c:	e822                	sd	s0,16(sp)
    8000197e:	e426                	sd	s1,8(sp)
    80001980:	e04a                	sd	s2,0(sp)
    80001982:	1000                	addi	s0,sp,32
    80001984:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001986:	917ff0ef          	jal	8000129c <uvmcreate>
    8000198a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000198c:	cd05                	beqz	a0,800019c4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000198e:	4729                	li	a4,10
    80001990:	00004697          	auipc	a3,0x4
    80001994:	67068693          	addi	a3,a3,1648 # 80006000 <_trampoline>
    80001998:	6605                	lui	a2,0x1
    8000199a:	040005b7          	lui	a1,0x4000
    8000199e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019a0:	05b2                	slli	a1,a1,0xc
    800019a2:	e98ff0ef          	jal	8000103a <mappages>
    800019a6:	02054663          	bltz	a0,800019d2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019aa:	4719                	li	a4,6
    800019ac:	05893683          	ld	a3,88(s2)
    800019b0:	6605                	lui	a2,0x1
    800019b2:	020005b7          	lui	a1,0x2000
    800019b6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019b8:	05b6                	slli	a1,a1,0xd
    800019ba:	8526                	mv	a0,s1
    800019bc:	e7eff0ef          	jal	8000103a <mappages>
    800019c0:	00054f63          	bltz	a0,800019de <proc_pagetable+0x66>
}
    800019c4:	8526                	mv	a0,s1
    800019c6:	60e2                	ld	ra,24(sp)
    800019c8:	6442                	ld	s0,16(sp)
    800019ca:	64a2                	ld	s1,8(sp)
    800019cc:	6902                	ld	s2,0(sp)
    800019ce:	6105                	addi	sp,sp,32
    800019d0:	8082                	ret
    uvmfree(pagetable, 0);
    800019d2:	4581                	li	a1,0
    800019d4:	8526                	mv	a0,s1
    800019d6:	a9dff0ef          	jal	80001472 <uvmfree>
    return 0;
    800019da:	4481                	li	s1,0
    800019dc:	b7e5                	j	800019c4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019de:	4681                	li	a3,0
    800019e0:	4605                	li	a2,1
    800019e2:	040005b7          	lui	a1,0x4000
    800019e6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019e8:	05b2                	slli	a1,a1,0xc
    800019ea:	8526                	mv	a0,s1
    800019ec:	ff4ff0ef          	jal	800011e0 <uvmunmap>
    uvmfree(pagetable, 0);
    800019f0:	4581                	li	a1,0
    800019f2:	8526                	mv	a0,s1
    800019f4:	a7fff0ef          	jal	80001472 <uvmfree>
    return 0;
    800019f8:	4481                	li	s1,0
    800019fa:	b7e9                	j	800019c4 <proc_pagetable+0x4c>

00000000800019fc <proc_freepagetable>:
{
    800019fc:	1101                	addi	sp,sp,-32
    800019fe:	ec06                	sd	ra,24(sp)
    80001a00:	e822                	sd	s0,16(sp)
    80001a02:	e426                	sd	s1,8(sp)
    80001a04:	e04a                	sd	s2,0(sp)
    80001a06:	1000                	addi	s0,sp,32
    80001a08:	84aa                	mv	s1,a0
    80001a0a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a0c:	4681                	li	a3,0
    80001a0e:	4605                	li	a2,1
    80001a10:	040005b7          	lui	a1,0x4000
    80001a14:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a16:	05b2                	slli	a1,a1,0xc
    80001a18:	fc8ff0ef          	jal	800011e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	020005b7          	lui	a1,0x2000
    80001a24:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a26:	05b6                	slli	a1,a1,0xd
    80001a28:	8526                	mv	a0,s1
    80001a2a:	fb6ff0ef          	jal	800011e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a2e:	85ca                	mv	a1,s2
    80001a30:	8526                	mv	a0,s1
    80001a32:	a41ff0ef          	jal	80001472 <uvmfree>
}
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6902                	ld	s2,0(sp)
    80001a3e:	6105                	addi	sp,sp,32
    80001a40:	8082                	ret

0000000080001a42 <freeproc>:
{
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	1000                	addi	s0,sp,32
    80001a4c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a4e:	6d28                	ld	a0,88(a0)
    80001a50:	c119                	beqz	a0,80001a56 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a52:	ff7fe0ef          	jal	80000a48 <kfree>
  p->trapframe = 0;
    80001a56:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a5a:	68a8                	ld	a0,80(s1)
    80001a5c:	c501                	beqz	a0,80001a64 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a5e:	64ac                	ld	a1,72(s1)
    80001a60:	f9dff0ef          	jal	800019fc <proc_freepagetable>
  p->pagetable = 0;
    80001a64:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a68:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a6c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a70:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a74:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a78:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a7c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a80:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a84:	0004ac23          	sw	zero,24(s1)
}
    80001a88:	60e2                	ld	ra,24(sp)
    80001a8a:	6442                	ld	s0,16(sp)
    80001a8c:	64a2                	ld	s1,8(sp)
    80001a8e:	6105                	addi	sp,sp,32
    80001a90:	8082                	ret

0000000080001a92 <allocproc>:
{
    80001a92:	1101                	addi	sp,sp,-32
    80001a94:	ec06                	sd	ra,24(sp)
    80001a96:	e822                	sd	s0,16(sp)
    80001a98:	e426                	sd	s1,8(sp)
    80001a9a:	e04a                	sd	s2,0(sp)
    80001a9c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a9e:	00011497          	auipc	s1,0x11
    80001aa2:	e4248493          	addi	s1,s1,-446 # 800128e0 <proc>
    80001aa6:	00017917          	auipc	s2,0x17
    80001aaa:	43a90913          	addi	s2,s2,1082 # 80018ee0 <tickslock>
    acquire(&p->lock);
    80001aae:	8526                	mv	a0,s1
    80001ab0:	94eff0ef          	jal	80000bfe <acquire>
    if(p->state == UNUSED) {
    80001ab4:	4c9c                	lw	a5,24(s1)
    80001ab6:	cb91                	beqz	a5,80001aca <allocproc+0x38>
      release(&p->lock);
    80001ab8:	8526                	mv	a0,s1
    80001aba:	9d8ff0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001abe:	19848493          	addi	s1,s1,408
    80001ac2:	ff2496e3          	bne	s1,s2,80001aae <allocproc+0x1c>
  return 0;
    80001ac6:	4481                	li	s1,0
    80001ac8:	a889                	j	80001b1a <allocproc+0x88>
  p->pid = allocpid();
    80001aca:	e71ff0ef          	jal	8000193a <allocpid>
    80001ace:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ad0:	4785                	li	a5,1
    80001ad2:	cc9c                	sw	a5,24(s1)
  p->tickets = 1;  // Default to 1 ticket
    80001ad4:	18f4a423          	sw	a5,392(s1)
  p->arrival_time = ticks;  // Current system time
    80001ad8:	00009797          	auipc	a5,0x9
    80001adc:	8a87e783          	lwu	a5,-1880(a5) # 8000a380 <ticks>
    80001ae0:	18f4b823          	sd	a5,400(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae4:	846ff0ef          	jal	80000b2a <kalloc>
    80001ae8:	892a                	mv	s2,a0
    80001aea:	eca8                	sd	a0,88(s1)
    80001aec:	cd15                	beqz	a0,80001b28 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001aee:	8526                	mv	a0,s1
    80001af0:	e89ff0ef          	jal	80001978 <proc_pagetable>
    80001af4:	892a                	mv	s2,a0
    80001af6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af8:	c121                	beqz	a0,80001b38 <allocproc+0xa6>
  memset(&p->context, 0, sizeof(p->context));
    80001afa:	07000613          	li	a2,112
    80001afe:	4581                	li	a1,0
    80001b00:	06048513          	addi	a0,s1,96
    80001b04:	9caff0ef          	jal	80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001b08:	00000797          	auipc	a5,0x0
    80001b0c:	df878793          	addi	a5,a5,-520 # 80001900 <forkret>
    80001b10:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b12:	60bc                	ld	a5,64(s1)
    80001b14:	6705                	lui	a4,0x1
    80001b16:	97ba                	add	a5,a5,a4
    80001b18:	f4bc                	sd	a5,104(s1)
}
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6902                	ld	s2,0(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret
    freeproc(p);
    80001b28:	8526                	mv	a0,s1
    80001b2a:	f19ff0ef          	jal	80001a42 <freeproc>
    release(&p->lock);
    80001b2e:	8526                	mv	a0,s1
    80001b30:	962ff0ef          	jal	80000c92 <release>
    return 0;
    80001b34:	84ca                	mv	s1,s2
    80001b36:	b7d5                	j	80001b1a <allocproc+0x88>
    freeproc(p);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	f09ff0ef          	jal	80001a42 <freeproc>
    release(&p->lock);
    80001b3e:	8526                	mv	a0,s1
    80001b40:	952ff0ef          	jal	80000c92 <release>
    return 0;
    80001b44:	84ca                	mv	s1,s2
    80001b46:	bfd1                	j	80001b1a <allocproc+0x88>

0000000080001b48 <userinit>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b52:	f41ff0ef          	jal	80001a92 <allocproc>
    80001b56:	84aa                	mv	s1,a0
  initproc = p;
    80001b58:	00009797          	auipc	a5,0x9
    80001b5c:	82a7b023          	sd	a0,-2016(a5) # 8000a378 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b60:	03400613          	li	a2,52
    80001b64:	00008597          	auipc	a1,0x8
    80001b68:	78c58593          	addi	a1,a1,1932 # 8000a2f0 <initcode>
    80001b6c:	6928                	ld	a0,80(a0)
    80001b6e:	f54ff0ef          	jal	800012c2 <uvmfirst>
  p->sz = PGSIZE;
    80001b72:	6785                	lui	a5,0x1
    80001b74:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b76:	6cb8                	ld	a4,88(s1)
    80001b78:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b7c:	6cb8                	ld	a4,88(s1)
    80001b7e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b80:	4641                	li	a2,16
    80001b82:	00005597          	auipc	a1,0x5
    80001b86:	69e58593          	addi	a1,a1,1694 # 80007220 <etext+0x220>
    80001b8a:	15848513          	addi	a0,s1,344
    80001b8e:	a92ff0ef          	jal	80000e20 <safestrcpy>
  p->cwd = namei("/");
    80001b92:	00005517          	auipc	a0,0x5
    80001b96:	69e50513          	addi	a0,a0,1694 # 80007230 <etext+0x230>
    80001b9a:	669010ef          	jal	80003a02 <namei>
    80001b9e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ba2:	478d                	li	a5,3
    80001ba4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	8eaff0ef          	jal	80000c92 <release>
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <growproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
    80001bc2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bc4:	d0dff0ef          	jal	800018d0 <myproc>
    80001bc8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bca:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bcc:	01204c63          	bgtz	s2,80001be4 <growproc+0x2e>
  } else if(n < 0){
    80001bd0:	02094463          	bltz	s2,80001bf8 <growproc+0x42>
  p->sz = sz;
    80001bd4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bd6:	4501                	li	a0,0
}
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6902                	ld	s2,0(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001be4:	4691                	li	a3,4
    80001be6:	00b90633          	add	a2,s2,a1
    80001bea:	6928                	ld	a0,80(a0)
    80001bec:	f78ff0ef          	jal	80001364 <uvmalloc>
    80001bf0:	85aa                	mv	a1,a0
    80001bf2:	f16d                	bnez	a0,80001bd4 <growproc+0x1e>
      return -1;
    80001bf4:	557d                	li	a0,-1
    80001bf6:	b7cd                	j	80001bd8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf8:	00b90633          	add	a2,s2,a1
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	f22ff0ef          	jal	80001320 <uvmdealloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	bfc1                	j	80001bd4 <growproc+0x1e>

0000000080001c06 <fork>:
{
    80001c06:	7139                	addi	sp,sp,-64
    80001c08:	fc06                	sd	ra,56(sp)
    80001c0a:	f822                	sd	s0,48(sp)
    80001c0c:	f04a                	sd	s2,32(sp)
    80001c0e:	e456                	sd	s5,8(sp)
    80001c10:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c12:	cbfff0ef          	jal	800018d0 <myproc>
    80001c16:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c18:	e7bff0ef          	jal	80001a92 <allocproc>
    80001c1c:	10050e63          	beqz	a0,80001d38 <fork+0x132>
    80001c20:	ec4e                	sd	s3,24(sp)
    80001c22:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c24:	048ab603          	ld	a2,72(s5)
    80001c28:	692c                	ld	a1,80(a0)
    80001c2a:	050ab503          	ld	a0,80(s5)
    80001c2e:	877ff0ef          	jal	800014a4 <uvmcopy>
    80001c32:	06054e63          	bltz	a0,80001cae <fork+0xa8>
    80001c36:	f426                	sd	s1,40(sp)
    80001c38:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c3a:	048ab783          	ld	a5,72(s5)
    80001c3e:	04f9b423          	sd	a5,72(s3) # 1048 <_entry-0x7fffefb8>
  np->tickets = p->tickets;
    80001c42:	188aa783          	lw	a5,392(s5)
    80001c46:	18f9a423          	sw	a5,392(s3)
  np->alarm_interval = p->alarm_interval;
    80001c4a:	168aa783          	lw	a5,360(s5)
    80001c4e:	16f9a423          	sw	a5,360(s3)
  np->alarm_handler = p->alarm_handler;
    80001c52:	170ab783          	ld	a5,368(s5)
    80001c56:	16f9b823          	sd	a5,368(s3)
  np->ticks_count = 0;
    80001c5a:	1609ac23          	sw	zero,376(s3)
  np->alarm_on = p->alarm_on;
    80001c5e:	17caa783          	lw	a5,380(s5)
    80001c62:	16f9ae23          	sw	a5,380(s3)
  np->alarm_trapframe = 0;
    80001c66:	1809b023          	sd	zero,384(s3)
  *(np->trapframe) = *(p->trapframe);
    80001c6a:	058ab683          	ld	a3,88(s5)
    80001c6e:	87b6                	mv	a5,a3
    80001c70:	0589b703          	ld	a4,88(s3)
    80001c74:	12068693          	addi	a3,a3,288
    80001c78:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c7c:	6788                	ld	a0,8(a5)
    80001c7e:	6b8c                	ld	a1,16(a5)
    80001c80:	6f90                	ld	a2,24(a5)
    80001c82:	01073023          	sd	a6,0(a4)
    80001c86:	e708                	sd	a0,8(a4)
    80001c88:	eb0c                	sd	a1,16(a4)
    80001c8a:	ef10                	sd	a2,24(a4)
    80001c8c:	02078793          	addi	a5,a5,32
    80001c90:	02070713          	addi	a4,a4,32
    80001c94:	fed792e3          	bne	a5,a3,80001c78 <fork+0x72>
  np->trapframe->a0 = 0;
    80001c98:	0589b783          	ld	a5,88(s3)
    80001c9c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ca0:	0d0a8493          	addi	s1,s5,208
    80001ca4:	0d098913          	addi	s2,s3,208
    80001ca8:	150a8a13          	addi	s4,s5,336
    80001cac:	a831                	j	80001cc8 <fork+0xc2>
    freeproc(np);
    80001cae:	854e                	mv	a0,s3
    80001cb0:	d93ff0ef          	jal	80001a42 <freeproc>
    release(&np->lock);
    80001cb4:	854e                	mv	a0,s3
    80001cb6:	fddfe0ef          	jal	80000c92 <release>
    return -1;
    80001cba:	597d                	li	s2,-1
    80001cbc:	69e2                	ld	s3,24(sp)
    80001cbe:	a0b5                	j	80001d2a <fork+0x124>
  for(i = 0; i < NOFILE; i++)
    80001cc0:	04a1                	addi	s1,s1,8
    80001cc2:	0921                	addi	s2,s2,8
    80001cc4:	01448963          	beq	s1,s4,80001cd6 <fork+0xd0>
    if(p->ofile[i])
    80001cc8:	6088                	ld	a0,0(s1)
    80001cca:	d97d                	beqz	a0,80001cc0 <fork+0xba>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ccc:	2d2020ef          	jal	80003f9e <filedup>
    80001cd0:	00a93023          	sd	a0,0(s2)
    80001cd4:	b7f5                	j	80001cc0 <fork+0xba>
  np->cwd = idup(p->cwd);
    80001cd6:	150ab503          	ld	a0,336(s5)
    80001cda:	602010ef          	jal	800032dc <idup>
    80001cde:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ce2:	4641                	li	a2,16
    80001ce4:	158a8593          	addi	a1,s5,344
    80001ce8:	15898513          	addi	a0,s3,344
    80001cec:	934ff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001cf0:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001cf4:	854e                	mv	a0,s3
    80001cf6:	f9dfe0ef          	jal	80000c92 <release>
  acquire(&wait_lock);
    80001cfa:	00010497          	auipc	s1,0x10
    80001cfe:	7ce48493          	addi	s1,s1,1998 # 800124c8 <wait_lock>
    80001d02:	8526                	mv	a0,s1
    80001d04:	efbfe0ef          	jal	80000bfe <acquire>
  np->parent = p;
    80001d08:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	f85fe0ef          	jal	80000c92 <release>
  acquire(&np->lock);
    80001d12:	854e                	mv	a0,s3
    80001d14:	eebfe0ef          	jal	80000bfe <acquire>
  np->state = RUNNABLE;
    80001d18:	478d                	li	a5,3
    80001d1a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d1e:	854e                	mv	a0,s3
    80001d20:	f73fe0ef          	jal	80000c92 <release>
  return pid;
    80001d24:	74a2                	ld	s1,40(sp)
    80001d26:	69e2                	ld	s3,24(sp)
    80001d28:	6a42                	ld	s4,16(sp)
}
    80001d2a:	854a                	mv	a0,s2
    80001d2c:	70e2                	ld	ra,56(sp)
    80001d2e:	7442                	ld	s0,48(sp)
    80001d30:	7902                	ld	s2,32(sp)
    80001d32:	6aa2                	ld	s5,8(sp)
    80001d34:	6121                	addi	sp,sp,64
    80001d36:	8082                	ret
    return -1;
    80001d38:	597d                	li	s2,-1
    80001d3a:	bfc5                	j	80001d2a <fork+0x124>

0000000080001d3c <scheduler>:
{
    80001d3c:	7139                	addi	sp,sp,-64
    80001d3e:	fc06                	sd	ra,56(sp)
    80001d40:	f822                	sd	s0,48(sp)
    80001d42:	f426                	sd	s1,40(sp)
    80001d44:	f04a                	sd	s2,32(sp)
    80001d46:	ec4e                	sd	s3,24(sp)
    80001d48:	e852                	sd	s4,16(sp)
    80001d4a:	e456                	sd	s5,8(sp)
    80001d4c:	e05a                	sd	s6,0(sp)
    80001d4e:	0080                	addi	s0,sp,64
    80001d50:	8792                	mv	a5,tp
  int id = r_tp();
    80001d52:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d54:	00779a93          	slli	s5,a5,0x7
    80001d58:	00010717          	auipc	a4,0x10
    80001d5c:	75870713          	addi	a4,a4,1880 # 800124b0 <pid_lock>
    80001d60:	9756                	add	a4,a4,s5
    80001d62:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d66:	00010717          	auipc	a4,0x10
    80001d6a:	78270713          	addi	a4,a4,1922 # 800124e8 <cpus+0x8>
    80001d6e:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001d70:	498d                	li	s3,3
        p->state = RUNNING;
    80001d72:	4b11                	li	s6,4
        c->proc = p;
    80001d74:	079e                	slli	a5,a5,0x7
    80001d76:	00010a17          	auipc	s4,0x10
    80001d7a:	73aa0a13          	addi	s4,s4,1850 # 800124b0 <pid_lock>
    80001d7e:	9a3e                	add	s4,s4,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d80:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d84:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d88:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d8c:	00011497          	auipc	s1,0x11
    80001d90:	b5448493          	addi	s1,s1,-1196 # 800128e0 <proc>
    80001d94:	00017917          	auipc	s2,0x17
    80001d98:	14c90913          	addi	s2,s2,332 # 80018ee0 <tickslock>
    80001d9c:	a801                	j	80001dac <scheduler+0x70>
      release(&p->lock);
    80001d9e:	8526                	mv	a0,s1
    80001da0:	ef3fe0ef          	jal	80000c92 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001da4:	19848493          	addi	s1,s1,408
    80001da8:	fd248ce3          	beq	s1,s2,80001d80 <scheduler+0x44>
      acquire(&p->lock);
    80001dac:	8526                	mv	a0,s1
    80001dae:	e51fe0ef          	jal	80000bfe <acquire>
      if(p->state == RUNNABLE) {
    80001db2:	4c9c                	lw	a5,24(s1)
    80001db4:	ff3795e3          	bne	a5,s3,80001d9e <scheduler+0x62>
        p->state = RUNNING;
    80001db8:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001dbc:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001dc0:	06048593          	addi	a1,s1,96
    80001dc4:	8556                	mv	a0,s5
    80001dc6:	57e000ef          	jal	80002344 <swtch>
        c->proc = 0;
    80001dca:	020a3823          	sd	zero,48(s4)
    80001dce:	bfc1                	j	80001d9e <scheduler+0x62>

0000000080001dd0 <sched>:
{
    80001dd0:	7179                	addi	sp,sp,-48
    80001dd2:	f406                	sd	ra,40(sp)
    80001dd4:	f022                	sd	s0,32(sp)
    80001dd6:	ec26                	sd	s1,24(sp)
    80001dd8:	e84a                	sd	s2,16(sp)
    80001dda:	e44e                	sd	s3,8(sp)
    80001ddc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dde:	af3ff0ef          	jal	800018d0 <myproc>
    80001de2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001de4:	db1fe0ef          	jal	80000b94 <holding>
    80001de8:	c92d                	beqz	a0,80001e5a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dea:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001dec:	2781                	sext.w	a5,a5
    80001dee:	079e                	slli	a5,a5,0x7
    80001df0:	00010717          	auipc	a4,0x10
    80001df4:	6c070713          	addi	a4,a4,1728 # 800124b0 <pid_lock>
    80001df8:	97ba                	add	a5,a5,a4
    80001dfa:	0a87a703          	lw	a4,168(a5)
    80001dfe:	4785                	li	a5,1
    80001e00:	06f71363          	bne	a4,a5,80001e66 <sched+0x96>
  if(p->state == RUNNING)
    80001e04:	4c98                	lw	a4,24(s1)
    80001e06:	4791                	li	a5,4
    80001e08:	06f70563          	beq	a4,a5,80001e72 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e0c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e10:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e12:	e7b5                	bnez	a5,80001e7e <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e14:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e16:	00010917          	auipc	s2,0x10
    80001e1a:	69a90913          	addi	s2,s2,1690 # 800124b0 <pid_lock>
    80001e1e:	2781                	sext.w	a5,a5
    80001e20:	079e                	slli	a5,a5,0x7
    80001e22:	97ca                	add	a5,a5,s2
    80001e24:	0ac7a983          	lw	s3,172(a5)
    80001e28:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e2a:	2781                	sext.w	a5,a5
    80001e2c:	079e                	slli	a5,a5,0x7
    80001e2e:	00010597          	auipc	a1,0x10
    80001e32:	6ba58593          	addi	a1,a1,1722 # 800124e8 <cpus+0x8>
    80001e36:	95be                	add	a1,a1,a5
    80001e38:	06048513          	addi	a0,s1,96
    80001e3c:	508000ef          	jal	80002344 <swtch>
    80001e40:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e42:	2781                	sext.w	a5,a5
    80001e44:	079e                	slli	a5,a5,0x7
    80001e46:	993e                	add	s2,s2,a5
    80001e48:	0b392623          	sw	s3,172(s2)
}
    80001e4c:	70a2                	ld	ra,40(sp)
    80001e4e:	7402                	ld	s0,32(sp)
    80001e50:	64e2                	ld	s1,24(sp)
    80001e52:	6942                	ld	s2,16(sp)
    80001e54:	69a2                	ld	s3,8(sp)
    80001e56:	6145                	addi	sp,sp,48
    80001e58:	8082                	ret
    panic("sched p->lock");
    80001e5a:	00005517          	auipc	a0,0x5
    80001e5e:	3de50513          	addi	a0,a0,990 # 80007238 <etext+0x238>
    80001e62:	93dfe0ef          	jal	8000079e <panic>
    panic("sched locks");
    80001e66:	00005517          	auipc	a0,0x5
    80001e6a:	3e250513          	addi	a0,a0,994 # 80007248 <etext+0x248>
    80001e6e:	931fe0ef          	jal	8000079e <panic>
    panic("sched running");
    80001e72:	00005517          	auipc	a0,0x5
    80001e76:	3e650513          	addi	a0,a0,998 # 80007258 <etext+0x258>
    80001e7a:	925fe0ef          	jal	8000079e <panic>
    panic("sched interruptible");
    80001e7e:	00005517          	auipc	a0,0x5
    80001e82:	3ea50513          	addi	a0,a0,1002 # 80007268 <etext+0x268>
    80001e86:	919fe0ef          	jal	8000079e <panic>

0000000080001e8a <yield>:
{
    80001e8a:	1101                	addi	sp,sp,-32
    80001e8c:	ec06                	sd	ra,24(sp)
    80001e8e:	e822                	sd	s0,16(sp)
    80001e90:	e426                	sd	s1,8(sp)
    80001e92:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e94:	a3dff0ef          	jal	800018d0 <myproc>
    80001e98:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e9a:	d65fe0ef          	jal	80000bfe <acquire>
  p->state = RUNNABLE;
    80001e9e:	478d                	li	a5,3
    80001ea0:	cc9c                	sw	a5,24(s1)
  sched();
    80001ea2:	f2fff0ef          	jal	80001dd0 <sched>
  release(&p->lock);
    80001ea6:	8526                	mv	a0,s1
    80001ea8:	debfe0ef          	jal	80000c92 <release>
}
    80001eac:	60e2                	ld	ra,24(sp)
    80001eae:	6442                	ld	s0,16(sp)
    80001eb0:	64a2                	ld	s1,8(sp)
    80001eb2:	6105                	addi	sp,sp,32
    80001eb4:	8082                	ret

0000000080001eb6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eb6:	7179                	addi	sp,sp,-48
    80001eb8:	f406                	sd	ra,40(sp)
    80001eba:	f022                	sd	s0,32(sp)
    80001ebc:	ec26                	sd	s1,24(sp)
    80001ebe:	e84a                	sd	s2,16(sp)
    80001ec0:	e44e                	sd	s3,8(sp)
    80001ec2:	1800                	addi	s0,sp,48
    80001ec4:	89aa                	mv	s3,a0
    80001ec6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ec8:	a09ff0ef          	jal	800018d0 <myproc>
    80001ecc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ece:	d31fe0ef          	jal	80000bfe <acquire>
  release(lk);
    80001ed2:	854a                	mv	a0,s2
    80001ed4:	dbffe0ef          	jal	80000c92 <release>

  // Go to sleep.
  p->chan = chan;
    80001ed8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001edc:	4789                	li	a5,2
    80001ede:	cc9c                	sw	a5,24(s1)

  sched();
    80001ee0:	ef1ff0ef          	jal	80001dd0 <sched>

  // Tidy up.
  p->chan = 0;
    80001ee4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	da9fe0ef          	jal	80000c92 <release>
  acquire(lk);
    80001eee:	854a                	mv	a0,s2
    80001ef0:	d0ffe0ef          	jal	80000bfe <acquire>
}
    80001ef4:	70a2                	ld	ra,40(sp)
    80001ef6:	7402                	ld	s0,32(sp)
    80001ef8:	64e2                	ld	s1,24(sp)
    80001efa:	6942                	ld	s2,16(sp)
    80001efc:	69a2                	ld	s3,8(sp)
    80001efe:	6145                	addi	sp,sp,48
    80001f00:	8082                	ret

0000000080001f02 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f02:	7139                	addi	sp,sp,-64
    80001f04:	fc06                	sd	ra,56(sp)
    80001f06:	f822                	sd	s0,48(sp)
    80001f08:	f426                	sd	s1,40(sp)
    80001f0a:	f04a                	sd	s2,32(sp)
    80001f0c:	ec4e                	sd	s3,24(sp)
    80001f0e:	e852                	sd	s4,16(sp)
    80001f10:	e456                	sd	s5,8(sp)
    80001f12:	0080                	addi	s0,sp,64
    80001f14:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f16:	00011497          	auipc	s1,0x11
    80001f1a:	9ca48493          	addi	s1,s1,-1590 # 800128e0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f1e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f20:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f22:	00017917          	auipc	s2,0x17
    80001f26:	fbe90913          	addi	s2,s2,-66 # 80018ee0 <tickslock>
    80001f2a:	a801                	j	80001f3a <wakeup+0x38>
      }
      release(&p->lock);
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	d65fe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f32:	19848493          	addi	s1,s1,408
    80001f36:	03248263          	beq	s1,s2,80001f5a <wakeup+0x58>
    if(p != myproc()){
    80001f3a:	997ff0ef          	jal	800018d0 <myproc>
    80001f3e:	fea48ae3          	beq	s1,a0,80001f32 <wakeup+0x30>
      acquire(&p->lock);
    80001f42:	8526                	mv	a0,s1
    80001f44:	cbbfe0ef          	jal	80000bfe <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f48:	4c9c                	lw	a5,24(s1)
    80001f4a:	ff3791e3          	bne	a5,s3,80001f2c <wakeup+0x2a>
    80001f4e:	709c                	ld	a5,32(s1)
    80001f50:	fd479ee3          	bne	a5,s4,80001f2c <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f54:	0154ac23          	sw	s5,24(s1)
    80001f58:	bfd1                	j	80001f2c <wakeup+0x2a>
    }
  }
}
    80001f5a:	70e2                	ld	ra,56(sp)
    80001f5c:	7442                	ld	s0,48(sp)
    80001f5e:	74a2                	ld	s1,40(sp)
    80001f60:	7902                	ld	s2,32(sp)
    80001f62:	69e2                	ld	s3,24(sp)
    80001f64:	6a42                	ld	s4,16(sp)
    80001f66:	6aa2                	ld	s5,8(sp)
    80001f68:	6121                	addi	sp,sp,64
    80001f6a:	8082                	ret

0000000080001f6c <reparent>:
{
    80001f6c:	7179                	addi	sp,sp,-48
    80001f6e:	f406                	sd	ra,40(sp)
    80001f70:	f022                	sd	s0,32(sp)
    80001f72:	ec26                	sd	s1,24(sp)
    80001f74:	e84a                	sd	s2,16(sp)
    80001f76:	e44e                	sd	s3,8(sp)
    80001f78:	e052                	sd	s4,0(sp)
    80001f7a:	1800                	addi	s0,sp,48
    80001f7c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f7e:	00011497          	auipc	s1,0x11
    80001f82:	96248493          	addi	s1,s1,-1694 # 800128e0 <proc>
      pp->parent = initproc;
    80001f86:	00008a17          	auipc	s4,0x8
    80001f8a:	3f2a0a13          	addi	s4,s4,1010 # 8000a378 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f8e:	00017997          	auipc	s3,0x17
    80001f92:	f5298993          	addi	s3,s3,-174 # 80018ee0 <tickslock>
    80001f96:	a029                	j	80001fa0 <reparent+0x34>
    80001f98:	19848493          	addi	s1,s1,408
    80001f9c:	01348b63          	beq	s1,s3,80001fb2 <reparent+0x46>
    if(pp->parent == p){
    80001fa0:	7c9c                	ld	a5,56(s1)
    80001fa2:	ff279be3          	bne	a5,s2,80001f98 <reparent+0x2c>
      pp->parent = initproc;
    80001fa6:	000a3503          	ld	a0,0(s4)
    80001faa:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fac:	f57ff0ef          	jal	80001f02 <wakeup>
    80001fb0:	b7e5                	j	80001f98 <reparent+0x2c>
}
    80001fb2:	70a2                	ld	ra,40(sp)
    80001fb4:	7402                	ld	s0,32(sp)
    80001fb6:	64e2                	ld	s1,24(sp)
    80001fb8:	6942                	ld	s2,16(sp)
    80001fba:	69a2                	ld	s3,8(sp)
    80001fbc:	6a02                	ld	s4,0(sp)
    80001fbe:	6145                	addi	sp,sp,48
    80001fc0:	8082                	ret

0000000080001fc2 <exit>:
{
    80001fc2:	7179                	addi	sp,sp,-48
    80001fc4:	f406                	sd	ra,40(sp)
    80001fc6:	f022                	sd	s0,32(sp)
    80001fc8:	ec26                	sd	s1,24(sp)
    80001fca:	e84a                	sd	s2,16(sp)
    80001fcc:	e44e                	sd	s3,8(sp)
    80001fce:	e052                	sd	s4,0(sp)
    80001fd0:	1800                	addi	s0,sp,48
    80001fd2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fd4:	8fdff0ef          	jal	800018d0 <myproc>
    80001fd8:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fda:	00008797          	auipc	a5,0x8
    80001fde:	39e7b783          	ld	a5,926(a5) # 8000a378 <initproc>
    80001fe2:	0d050493          	addi	s1,a0,208
    80001fe6:	15050913          	addi	s2,a0,336
    80001fea:	00a79b63          	bne	a5,a0,80002000 <exit+0x3e>
    panic("init exiting");
    80001fee:	00005517          	auipc	a0,0x5
    80001ff2:	29250513          	addi	a0,a0,658 # 80007280 <etext+0x280>
    80001ff6:	fa8fe0ef          	jal	8000079e <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80001ffa:	04a1                	addi	s1,s1,8
    80001ffc:	01248963          	beq	s1,s2,8000200e <exit+0x4c>
    if(p->ofile[fd]){
    80002000:	6088                	ld	a0,0(s1)
    80002002:	dd65                	beqz	a0,80001ffa <exit+0x38>
      fileclose(f);
    80002004:	7e1010ef          	jal	80003fe4 <fileclose>
      p->ofile[fd] = 0;
    80002008:	0004b023          	sd	zero,0(s1)
    8000200c:	b7fd                	j	80001ffa <exit+0x38>
  begin_op();
    8000200e:	3b7010ef          	jal	80003bc4 <begin_op>
  iput(p->cwd);
    80002012:	1509b503          	ld	a0,336(s3)
    80002016:	47e010ef          	jal	80003494 <iput>
  end_op();
    8000201a:	415010ef          	jal	80003c2e <end_op>
  p->cwd = 0;
    8000201e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002022:	00010497          	auipc	s1,0x10
    80002026:	4a648493          	addi	s1,s1,1190 # 800124c8 <wait_lock>
    8000202a:	8526                	mv	a0,s1
    8000202c:	bd3fe0ef          	jal	80000bfe <acquire>
  reparent(p);
    80002030:	854e                	mv	a0,s3
    80002032:	f3bff0ef          	jal	80001f6c <reparent>
  wakeup(p->parent);
    80002036:	0389b503          	ld	a0,56(s3)
    8000203a:	ec9ff0ef          	jal	80001f02 <wakeup>
  acquire(&p->lock);
    8000203e:	854e                	mv	a0,s3
    80002040:	bbffe0ef          	jal	80000bfe <acquire>
  p->xstate = status;
    80002044:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002048:	4795                	li	a5,5
    8000204a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	c43fe0ef          	jal	80000c92 <release>
  sched();
    80002054:	d7dff0ef          	jal	80001dd0 <sched>
  panic("zombie exit");
    80002058:	00005517          	auipc	a0,0x5
    8000205c:	23850513          	addi	a0,a0,568 # 80007290 <etext+0x290>
    80002060:	f3efe0ef          	jal	8000079e <panic>

0000000080002064 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002064:	7179                	addi	sp,sp,-48
    80002066:	f406                	sd	ra,40(sp)
    80002068:	f022                	sd	s0,32(sp)
    8000206a:	ec26                	sd	s1,24(sp)
    8000206c:	e84a                	sd	s2,16(sp)
    8000206e:	e44e                	sd	s3,8(sp)
    80002070:	1800                	addi	s0,sp,48
    80002072:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002074:	00011497          	auipc	s1,0x11
    80002078:	86c48493          	addi	s1,s1,-1940 # 800128e0 <proc>
    8000207c:	00017997          	auipc	s3,0x17
    80002080:	e6498993          	addi	s3,s3,-412 # 80018ee0 <tickslock>
    acquire(&p->lock);
    80002084:	8526                	mv	a0,s1
    80002086:	b79fe0ef          	jal	80000bfe <acquire>
    if(p->pid == pid){
    8000208a:	589c                	lw	a5,48(s1)
    8000208c:	01278b63          	beq	a5,s2,800020a2 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002090:	8526                	mv	a0,s1
    80002092:	c01fe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002096:	19848493          	addi	s1,s1,408
    8000209a:	ff3495e3          	bne	s1,s3,80002084 <kill+0x20>
  }
  return -1;
    8000209e:	557d                	li	a0,-1
    800020a0:	a819                	j	800020b6 <kill+0x52>
      p->killed = 1;
    800020a2:	4785                	li	a5,1
    800020a4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020a6:	4c98                	lw	a4,24(s1)
    800020a8:	4789                	li	a5,2
    800020aa:	00f70d63          	beq	a4,a5,800020c4 <kill+0x60>
      release(&p->lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	be3fe0ef          	jal	80000c92 <release>
      return 0;
    800020b4:	4501                	li	a0,0
}
    800020b6:	70a2                	ld	ra,40(sp)
    800020b8:	7402                	ld	s0,32(sp)
    800020ba:	64e2                	ld	s1,24(sp)
    800020bc:	6942                	ld	s2,16(sp)
    800020be:	69a2                	ld	s3,8(sp)
    800020c0:	6145                	addi	sp,sp,48
    800020c2:	8082                	ret
        p->state = RUNNABLE;
    800020c4:	478d                	li	a5,3
    800020c6:	cc9c                	sw	a5,24(s1)
    800020c8:	b7dd                	j	800020ae <kill+0x4a>

00000000800020ca <setkilled>:

void
setkilled(struct proc *p)
{
    800020ca:	1101                	addi	sp,sp,-32
    800020cc:	ec06                	sd	ra,24(sp)
    800020ce:	e822                	sd	s0,16(sp)
    800020d0:	e426                	sd	s1,8(sp)
    800020d2:	1000                	addi	s0,sp,32
    800020d4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020d6:	b29fe0ef          	jal	80000bfe <acquire>
  p->killed = 1;
    800020da:	4785                	li	a5,1
    800020dc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020de:	8526                	mv	a0,s1
    800020e0:	bb3fe0ef          	jal	80000c92 <release>
}
    800020e4:	60e2                	ld	ra,24(sp)
    800020e6:	6442                	ld	s0,16(sp)
    800020e8:	64a2                	ld	s1,8(sp)
    800020ea:	6105                	addi	sp,sp,32
    800020ec:	8082                	ret

00000000800020ee <killed>:

int
killed(struct proc *p)
{
    800020ee:	1101                	addi	sp,sp,-32
    800020f0:	ec06                	sd	ra,24(sp)
    800020f2:	e822                	sd	s0,16(sp)
    800020f4:	e426                	sd	s1,8(sp)
    800020f6:	e04a                	sd	s2,0(sp)
    800020f8:	1000                	addi	s0,sp,32
    800020fa:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020fc:	b03fe0ef          	jal	80000bfe <acquire>
  k = p->killed;
    80002100:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002104:	8526                	mv	a0,s1
    80002106:	b8dfe0ef          	jal	80000c92 <release>
  return k;
}
    8000210a:	854a                	mv	a0,s2
    8000210c:	60e2                	ld	ra,24(sp)
    8000210e:	6442                	ld	s0,16(sp)
    80002110:	64a2                	ld	s1,8(sp)
    80002112:	6902                	ld	s2,0(sp)
    80002114:	6105                	addi	sp,sp,32
    80002116:	8082                	ret

0000000080002118 <wait>:
{
    80002118:	715d                	addi	sp,sp,-80
    8000211a:	e486                	sd	ra,72(sp)
    8000211c:	e0a2                	sd	s0,64(sp)
    8000211e:	fc26                	sd	s1,56(sp)
    80002120:	f84a                	sd	s2,48(sp)
    80002122:	f44e                	sd	s3,40(sp)
    80002124:	f052                	sd	s4,32(sp)
    80002126:	ec56                	sd	s5,24(sp)
    80002128:	e85a                	sd	s6,16(sp)
    8000212a:	e45e                	sd	s7,8(sp)
    8000212c:	0880                	addi	s0,sp,80
    8000212e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002130:	fa0ff0ef          	jal	800018d0 <myproc>
    80002134:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002136:	00010517          	auipc	a0,0x10
    8000213a:	39250513          	addi	a0,a0,914 # 800124c8 <wait_lock>
    8000213e:	ac1fe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    80002142:	4a15                	li	s4,5
        havekids = 1;
    80002144:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002146:	00017997          	auipc	s3,0x17
    8000214a:	d9a98993          	addi	s3,s3,-614 # 80018ee0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000214e:	00010b97          	auipc	s7,0x10
    80002152:	37ab8b93          	addi	s7,s7,890 # 800124c8 <wait_lock>
    80002156:	a869                	j	800021f0 <wait+0xd8>
          pid = pp->pid;
    80002158:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000215c:	000b0c63          	beqz	s6,80002174 <wait+0x5c>
    80002160:	4691                	li	a3,4
    80002162:	02c48613          	addi	a2,s1,44
    80002166:	85da                	mv	a1,s6
    80002168:	05093503          	ld	a0,80(s2)
    8000216c:	c18ff0ef          	jal	80001584 <copyout>
    80002170:	02054a63          	bltz	a0,800021a4 <wait+0x8c>
          freeproc(pp);
    80002174:	8526                	mv	a0,s1
    80002176:	8cdff0ef          	jal	80001a42 <freeproc>
          release(&pp->lock);
    8000217a:	8526                	mv	a0,s1
    8000217c:	b17fe0ef          	jal	80000c92 <release>
          release(&wait_lock);
    80002180:	00010517          	auipc	a0,0x10
    80002184:	34850513          	addi	a0,a0,840 # 800124c8 <wait_lock>
    80002188:	b0bfe0ef          	jal	80000c92 <release>
}
    8000218c:	854e                	mv	a0,s3
    8000218e:	60a6                	ld	ra,72(sp)
    80002190:	6406                	ld	s0,64(sp)
    80002192:	74e2                	ld	s1,56(sp)
    80002194:	7942                	ld	s2,48(sp)
    80002196:	79a2                	ld	s3,40(sp)
    80002198:	7a02                	ld	s4,32(sp)
    8000219a:	6ae2                	ld	s5,24(sp)
    8000219c:	6b42                	ld	s6,16(sp)
    8000219e:	6ba2                	ld	s7,8(sp)
    800021a0:	6161                	addi	sp,sp,80
    800021a2:	8082                	ret
            release(&pp->lock);
    800021a4:	8526                	mv	a0,s1
    800021a6:	aedfe0ef          	jal	80000c92 <release>
            release(&wait_lock);
    800021aa:	00010517          	auipc	a0,0x10
    800021ae:	31e50513          	addi	a0,a0,798 # 800124c8 <wait_lock>
    800021b2:	ae1fe0ef          	jal	80000c92 <release>
            return -1;
    800021b6:	59fd                	li	s3,-1
    800021b8:	bfd1                	j	8000218c <wait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ba:	19848493          	addi	s1,s1,408
    800021be:	03348063          	beq	s1,s3,800021de <wait+0xc6>
      if(pp->parent == p){
    800021c2:	7c9c                	ld	a5,56(s1)
    800021c4:	ff279be3          	bne	a5,s2,800021ba <wait+0xa2>
        acquire(&pp->lock);
    800021c8:	8526                	mv	a0,s1
    800021ca:	a35fe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    800021ce:	4c9c                	lw	a5,24(s1)
    800021d0:	f94784e3          	beq	a5,s4,80002158 <wait+0x40>
        release(&pp->lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	abdfe0ef          	jal	80000c92 <release>
        havekids = 1;
    800021da:	8756                	mv	a4,s5
    800021dc:	bff9                	j	800021ba <wait+0xa2>
    if(!havekids || killed(p)){
    800021de:	cf19                	beqz	a4,800021fc <wait+0xe4>
    800021e0:	854a                	mv	a0,s2
    800021e2:	f0dff0ef          	jal	800020ee <killed>
    800021e6:	e919                	bnez	a0,800021fc <wait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021e8:	85de                	mv	a1,s7
    800021ea:	854a                	mv	a0,s2
    800021ec:	ccbff0ef          	jal	80001eb6 <sleep>
    havekids = 0;
    800021f0:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f2:	00010497          	auipc	s1,0x10
    800021f6:	6ee48493          	addi	s1,s1,1774 # 800128e0 <proc>
    800021fa:	b7e1                	j	800021c2 <wait+0xaa>
      release(&wait_lock);
    800021fc:	00010517          	auipc	a0,0x10
    80002200:	2cc50513          	addi	a0,a0,716 # 800124c8 <wait_lock>
    80002204:	a8ffe0ef          	jal	80000c92 <release>
      return -1;
    80002208:	59fd                	li	s3,-1
    8000220a:	b749                	j	8000218c <wait+0x74>

000000008000220c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000220c:	7179                	addi	sp,sp,-48
    8000220e:	f406                	sd	ra,40(sp)
    80002210:	f022                	sd	s0,32(sp)
    80002212:	ec26                	sd	s1,24(sp)
    80002214:	e84a                	sd	s2,16(sp)
    80002216:	e44e                	sd	s3,8(sp)
    80002218:	e052                	sd	s4,0(sp)
    8000221a:	1800                	addi	s0,sp,48
    8000221c:	84aa                	mv	s1,a0
    8000221e:	892e                	mv	s2,a1
    80002220:	89b2                	mv	s3,a2
    80002222:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002224:	eacff0ef          	jal	800018d0 <myproc>
  if(user_dst){
    80002228:	cc99                	beqz	s1,80002246 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000222a:	86d2                	mv	a3,s4
    8000222c:	864e                	mv	a2,s3
    8000222e:	85ca                	mv	a1,s2
    80002230:	6928                	ld	a0,80(a0)
    80002232:	b52ff0ef          	jal	80001584 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002236:	70a2                	ld	ra,40(sp)
    80002238:	7402                	ld	s0,32(sp)
    8000223a:	64e2                	ld	s1,24(sp)
    8000223c:	6942                	ld	s2,16(sp)
    8000223e:	69a2                	ld	s3,8(sp)
    80002240:	6a02                	ld	s4,0(sp)
    80002242:	6145                	addi	sp,sp,48
    80002244:	8082                	ret
    memmove((char *)dst, src, len);
    80002246:	000a061b          	sext.w	a2,s4
    8000224a:	85ce                	mv	a1,s3
    8000224c:	854a                	mv	a0,s2
    8000224e:	ae5fe0ef          	jal	80000d32 <memmove>
    return 0;
    80002252:	8526                	mv	a0,s1
    80002254:	b7cd                	j	80002236 <either_copyout+0x2a>

0000000080002256 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002256:	7179                	addi	sp,sp,-48
    80002258:	f406                	sd	ra,40(sp)
    8000225a:	f022                	sd	s0,32(sp)
    8000225c:	ec26                	sd	s1,24(sp)
    8000225e:	e84a                	sd	s2,16(sp)
    80002260:	e44e                	sd	s3,8(sp)
    80002262:	e052                	sd	s4,0(sp)
    80002264:	1800                	addi	s0,sp,48
    80002266:	892a                	mv	s2,a0
    80002268:	84ae                	mv	s1,a1
    8000226a:	89b2                	mv	s3,a2
    8000226c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226e:	e62ff0ef          	jal	800018d0 <myproc>
  if(user_src){
    80002272:	cc99                	beqz	s1,80002290 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002274:	86d2                	mv	a3,s4
    80002276:	864e                	mv	a2,s3
    80002278:	85ca                	mv	a1,s2
    8000227a:	6928                	ld	a0,80(a0)
    8000227c:	bb8ff0ef          	jal	80001634 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002280:	70a2                	ld	ra,40(sp)
    80002282:	7402                	ld	s0,32(sp)
    80002284:	64e2                	ld	s1,24(sp)
    80002286:	6942                	ld	s2,16(sp)
    80002288:	69a2                	ld	s3,8(sp)
    8000228a:	6a02                	ld	s4,0(sp)
    8000228c:	6145                	addi	sp,sp,48
    8000228e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002290:	000a061b          	sext.w	a2,s4
    80002294:	85ce                	mv	a1,s3
    80002296:	854a                	mv	a0,s2
    80002298:	a9bfe0ef          	jal	80000d32 <memmove>
    return 0;
    8000229c:	8526                	mv	a0,s1
    8000229e:	b7cd                	j	80002280 <either_copyin+0x2a>

00000000800022a0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022a0:	715d                	addi	sp,sp,-80
    800022a2:	e486                	sd	ra,72(sp)
    800022a4:	e0a2                	sd	s0,64(sp)
    800022a6:	fc26                	sd	s1,56(sp)
    800022a8:	f84a                	sd	s2,48(sp)
    800022aa:	f44e                	sd	s3,40(sp)
    800022ac:	f052                	sd	s4,32(sp)
    800022ae:	ec56                	sd	s5,24(sp)
    800022b0:	e85a                	sd	s6,16(sp)
    800022b2:	e45e                	sd	s7,8(sp)
    800022b4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022b6:	00005517          	auipc	a0,0x5
    800022ba:	dc250513          	addi	a0,a0,-574 # 80007078 <etext+0x78>
    800022be:	a10fe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022c2:	00010497          	auipc	s1,0x10
    800022c6:	77648493          	addi	s1,s1,1910 # 80012a38 <proc+0x158>
    800022ca:	00017917          	auipc	s2,0x17
    800022ce:	d6e90913          	addi	s2,s2,-658 # 80019038 <bcache+0x88>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022d2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022d4:	00005997          	auipc	s3,0x5
    800022d8:	fcc98993          	addi	s3,s3,-52 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022dc:	00005a97          	auipc	s5,0x5
    800022e0:	fcca8a93          	addi	s5,s5,-52 # 800072a8 <etext+0x2a8>
    printf("\n");
    800022e4:	00005a17          	auipc	s4,0x5
    800022e8:	d94a0a13          	addi	s4,s4,-620 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022ec:	00005b97          	auipc	s7,0x5
    800022f0:	4a4b8b93          	addi	s7,s7,1188 # 80007790 <states.0>
    800022f4:	a829                	j	8000230e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022f6:	ed86a583          	lw	a1,-296(a3)
    800022fa:	8556                	mv	a0,s5
    800022fc:	9d2fe0ef          	jal	800004ce <printf>
    printf("\n");
    80002300:	8552                	mv	a0,s4
    80002302:	9ccfe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002306:	19848493          	addi	s1,s1,408
    8000230a:	03248263          	beq	s1,s2,8000232e <procdump+0x8e>
    if(p->state == UNUSED)
    8000230e:	86a6                	mv	a3,s1
    80002310:	ec04a783          	lw	a5,-320(s1)
    80002314:	dbed                	beqz	a5,80002306 <procdump+0x66>
      state = "???";
    80002316:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002318:	fcfb6fe3          	bltu	s6,a5,800022f6 <procdump+0x56>
    8000231c:	02079713          	slli	a4,a5,0x20
    80002320:	01d75793          	srli	a5,a4,0x1d
    80002324:	97de                	add	a5,a5,s7
    80002326:	6390                	ld	a2,0(a5)
    80002328:	f679                	bnez	a2,800022f6 <procdump+0x56>
      state = "???";
    8000232a:	864e                	mv	a2,s3
    8000232c:	b7e9                	j	800022f6 <procdump+0x56>
  }
}
    8000232e:	60a6                	ld	ra,72(sp)
    80002330:	6406                	ld	s0,64(sp)
    80002332:	74e2                	ld	s1,56(sp)
    80002334:	7942                	ld	s2,48(sp)
    80002336:	79a2                	ld	s3,40(sp)
    80002338:	7a02                	ld	s4,32(sp)
    8000233a:	6ae2                	ld	s5,24(sp)
    8000233c:	6b42                	ld	s6,16(sp)
    8000233e:	6ba2                	ld	s7,8(sp)
    80002340:	6161                	addi	sp,sp,80
    80002342:	8082                	ret

0000000080002344 <swtch>:
    80002344:	00153023          	sd	ra,0(a0)
    80002348:	00253423          	sd	sp,8(a0)
    8000234c:	e900                	sd	s0,16(a0)
    8000234e:	ed04                	sd	s1,24(a0)
    80002350:	03253023          	sd	s2,32(a0)
    80002354:	03353423          	sd	s3,40(a0)
    80002358:	03453823          	sd	s4,48(a0)
    8000235c:	03553c23          	sd	s5,56(a0)
    80002360:	05653023          	sd	s6,64(a0)
    80002364:	05753423          	sd	s7,72(a0)
    80002368:	05853823          	sd	s8,80(a0)
    8000236c:	05953c23          	sd	s9,88(a0)
    80002370:	07a53023          	sd	s10,96(a0)
    80002374:	07b53423          	sd	s11,104(a0)
    80002378:	0005b083          	ld	ra,0(a1)
    8000237c:	0085b103          	ld	sp,8(a1)
    80002380:	6980                	ld	s0,16(a1)
    80002382:	6d84                	ld	s1,24(a1)
    80002384:	0205b903          	ld	s2,32(a1)
    80002388:	0285b983          	ld	s3,40(a1)
    8000238c:	0305ba03          	ld	s4,48(a1)
    80002390:	0385ba83          	ld	s5,56(a1)
    80002394:	0405bb03          	ld	s6,64(a1)
    80002398:	0485bb83          	ld	s7,72(a1)
    8000239c:	0505bc03          	ld	s8,80(a1)
    800023a0:	0585bc83          	ld	s9,88(a1)
    800023a4:	0605bd03          	ld	s10,96(a1)
    800023a8:	0685bd83          	ld	s11,104(a1)
    800023ac:	8082                	ret

00000000800023ae <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023ae:	1141                	addi	sp,sp,-16
    800023b0:	e406                	sd	ra,8(sp)
    800023b2:	e022                	sd	s0,0(sp)
    800023b4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023b6:	00005597          	auipc	a1,0x5
    800023ba:	f3258593          	addi	a1,a1,-206 # 800072e8 <etext+0x2e8>
    800023be:	00017517          	auipc	a0,0x17
    800023c2:	b2250513          	addi	a0,a0,-1246 # 80018ee0 <tickslock>
    800023c6:	fb4fe0ef          	jal	80000b7a <initlock>
}
    800023ca:	60a2                	ld	ra,8(sp)
    800023cc:	6402                	ld	s0,0(sp)
    800023ce:	0141                	addi	sp,sp,16
    800023d0:	8082                	ret

00000000800023d2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023d2:	1141                	addi	sp,sp,-16
    800023d4:	e406                	sd	ra,8(sp)
    800023d6:	e022                	sd	s0,0(sp)
    800023d8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023da:	00003797          	auipc	a5,0x3
    800023de:	fb678793          	addi	a5,a5,-74 # 80005390 <kernelvec>
    800023e2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023e6:	60a2                	ld	ra,8(sp)
    800023e8:	6402                	ld	s0,0(sp)
    800023ea:	0141                	addi	sp,sp,16
    800023ec:	8082                	ret

00000000800023ee <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800023ee:	1141                	addi	sp,sp,-16
    800023f0:	e406                	sd	ra,8(sp)
    800023f2:	e022                	sd	s0,0(sp)
    800023f4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023f6:	cdaff0ef          	jal	800018d0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023fe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002400:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002404:	00004697          	auipc	a3,0x4
    80002408:	bfc68693          	addi	a3,a3,-1028 # 80006000 <_trampoline>
    8000240c:	00004717          	auipc	a4,0x4
    80002410:	bf470713          	addi	a4,a4,-1036 # 80006000 <_trampoline>
    80002414:	8f15                	sub	a4,a4,a3
    80002416:	040007b7          	lui	a5,0x4000
    8000241a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000241c:	07b2                	slli	a5,a5,0xc
    8000241e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002420:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002424:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002426:	18002673          	csrr	a2,satp
    8000242a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000242c:	6d30                	ld	a2,88(a0)
    8000242e:	6138                	ld	a4,64(a0)
    80002430:	6585                	lui	a1,0x1
    80002432:	972e                	add	a4,a4,a1
    80002434:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002436:	6d38                	ld	a4,88(a0)
    80002438:	00000617          	auipc	a2,0x0
    8000243c:	11060613          	addi	a2,a2,272 # 80002548 <usertrap>
    80002440:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002442:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002444:	8612                	mv	a2,tp
    80002446:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002448:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000244c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002450:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002454:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002458:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000245a:	6f18                	ld	a4,24(a4)
    8000245c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002460:	6928                	ld	a0,80(a0)
    80002462:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002464:	00004717          	auipc	a4,0x4
    80002468:	c3870713          	addi	a4,a4,-968 # 8000609c <userret>
    8000246c:	8f15                	sub	a4,a4,a3
    8000246e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002470:	577d                	li	a4,-1
    80002472:	177e                	slli	a4,a4,0x3f
    80002474:	8d59                	or	a0,a0,a4
    80002476:	9782                	jalr	a5
}
    80002478:	60a2                	ld	ra,8(sp)
    8000247a:	6402                	ld	s0,0(sp)
    8000247c:	0141                	addi	sp,sp,16
    8000247e:	8082                	ret

0000000080002480 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002480:	1101                	addi	sp,sp,-32
    80002482:	ec06                	sd	ra,24(sp)
    80002484:	e822                	sd	s0,16(sp)
    80002486:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002488:	c14ff0ef          	jal	8000189c <cpuid>
    8000248c:	cd11                	beqz	a0,800024a8 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000248e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002492:	000f4737          	lui	a4,0xf4
    80002496:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000249a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stimecmp, %0" : : "r" (x));
    8000249c:	14d79073          	csrw	stimecmp,a5
}
    800024a0:	60e2                	ld	ra,24(sp)
    800024a2:	6442                	ld	s0,16(sp)
    800024a4:	6105                	addi	sp,sp,32
    800024a6:	8082                	ret
    800024a8:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024aa:	00017497          	auipc	s1,0x17
    800024ae:	a3648493          	addi	s1,s1,-1482 # 80018ee0 <tickslock>
    800024b2:	8526                	mv	a0,s1
    800024b4:	f4afe0ef          	jal	80000bfe <acquire>
    ticks++;
    800024b8:	00008517          	auipc	a0,0x8
    800024bc:	ec850513          	addi	a0,a0,-312 # 8000a380 <ticks>
    800024c0:	411c                	lw	a5,0(a0)
    800024c2:	2785                	addiw	a5,a5,1
    800024c4:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024c6:	a3dff0ef          	jal	80001f02 <wakeup>
    release(&tickslock);
    800024ca:	8526                	mv	a0,s1
    800024cc:	fc6fe0ef          	jal	80000c92 <release>
    800024d0:	64a2                	ld	s1,8(sp)
    800024d2:	bf75                	j	8000248e <clockintr+0xe>

00000000800024d4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024d4:	1101                	addi	sp,sp,-32
    800024d6:	ec06                	sd	ra,24(sp)
    800024d8:	e822                	sd	s0,16(sp)
    800024da:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024dc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024e0:	57fd                	li	a5,-1
    800024e2:	17fe                	slli	a5,a5,0x3f
    800024e4:	07a5                	addi	a5,a5,9
    800024e6:	00f70c63          	beq	a4,a5,800024fe <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024ea:	57fd                	li	a5,-1
    800024ec:	17fe                	slli	a5,a5,0x3f
    800024ee:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024f0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024f2:	04f70763          	beq	a4,a5,80002540 <devintr+0x6c>
  }
}
    800024f6:	60e2                	ld	ra,24(sp)
    800024f8:	6442                	ld	s0,16(sp)
    800024fa:	6105                	addi	sp,sp,32
    800024fc:	8082                	ret
    800024fe:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002500:	73d020ef          	jal	8000543c <plic_claim>
    80002504:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002506:	47a9                	li	a5,10
    80002508:	00f50963          	beq	a0,a5,8000251a <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    8000250c:	4785                	li	a5,1
    8000250e:	00f50963          	beq	a0,a5,80002520 <devintr+0x4c>
    return 1;
    80002512:	4505                	li	a0,1
    } else if(irq){
    80002514:	e889                	bnez	s1,80002526 <devintr+0x52>
    80002516:	64a2                	ld	s1,8(sp)
    80002518:	bff9                	j	800024f6 <devintr+0x22>
      uartintr();
    8000251a:	cf2fe0ef          	jal	80000a0c <uartintr>
    if(irq)
    8000251e:	a819                	j	80002534 <devintr+0x60>
      virtio_disk_intr();
    80002520:	3ac030ef          	jal	800058cc <virtio_disk_intr>
    if(irq)
    80002524:	a801                	j	80002534 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002526:	85a6                	mv	a1,s1
    80002528:	00005517          	auipc	a0,0x5
    8000252c:	dc850513          	addi	a0,a0,-568 # 800072f0 <etext+0x2f0>
    80002530:	f9ffd0ef          	jal	800004ce <printf>
      plic_complete(irq);
    80002534:	8526                	mv	a0,s1
    80002536:	727020ef          	jal	8000545c <plic_complete>
    return 1;
    8000253a:	4505                	li	a0,1
    8000253c:	64a2                	ld	s1,8(sp)
    8000253e:	bf65                	j	800024f6 <devintr+0x22>
    clockintr();
    80002540:	f41ff0ef          	jal	80002480 <clockintr>
    return 2;
    80002544:	4509                	li	a0,2
    80002546:	bf45                	j	800024f6 <devintr+0x22>

0000000080002548 <usertrap>:
{
    80002548:	1101                	addi	sp,sp,-32
    8000254a:	ec06                	sd	ra,24(sp)
    8000254c:	e822                	sd	s0,16(sp)
    8000254e:	e426                	sd	s1,8(sp)
    80002550:	e04a                	sd	s2,0(sp)
    80002552:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002554:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002558:	1007f793          	andi	a5,a5,256
    8000255c:	ef85                	bnez	a5,80002594 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000255e:	00003797          	auipc	a5,0x3
    80002562:	e3278793          	addi	a5,a5,-462 # 80005390 <kernelvec>
    80002566:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000256a:	b66ff0ef          	jal	800018d0 <myproc>
    8000256e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002570:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002572:	14102773          	csrr	a4,sepc
    80002576:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002578:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000257c:	47a1                	li	a5,8
    8000257e:	02f70163          	beq	a4,a5,800025a0 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002582:	f53ff0ef          	jal	800024d4 <devintr>
    80002586:	892a                	mv	s2,a0
    80002588:	c135                	beqz	a0,800025ec <usertrap+0xa4>
  if(killed(p))
    8000258a:	8526                	mv	a0,s1
    8000258c:	b63ff0ef          	jal	800020ee <killed>
    80002590:	cd1d                	beqz	a0,800025ce <usertrap+0x86>
    80002592:	a81d                	j	800025c8 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002594:	00005517          	auipc	a0,0x5
    80002598:	d7c50513          	addi	a0,a0,-644 # 80007310 <etext+0x310>
    8000259c:	a02fe0ef          	jal	8000079e <panic>
    if(killed(p))
    800025a0:	b4fff0ef          	jal	800020ee <killed>
    800025a4:	e121                	bnez	a0,800025e4 <usertrap+0x9c>
    p->trapframe->epc += 4;
    800025a6:	6cb8                	ld	a4,88(s1)
    800025a8:	6f1c                	ld	a5,24(a4)
    800025aa:	0791                	addi	a5,a5,4
    800025ac:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025ae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025b2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025b6:	10079073          	csrw	sstatus,a5
    syscall();
    800025ba:	280000ef          	jal	8000283a <syscall>
  if(killed(p))
    800025be:	8526                	mv	a0,s1
    800025c0:	b2fff0ef          	jal	800020ee <killed>
    800025c4:	c901                	beqz	a0,800025d4 <usertrap+0x8c>
    800025c6:	4901                	li	s2,0
    exit(-1);
    800025c8:	557d                	li	a0,-1
    800025ca:	9f9ff0ef          	jal	80001fc2 <exit>
  if(which_dev == 2) {
    800025ce:	4789                	li	a5,2
    800025d0:	04f90563          	beq	s2,a5,8000261a <usertrap+0xd2>
  usertrapret();
    800025d4:	e1bff0ef          	jal	800023ee <usertrapret>
}
    800025d8:	60e2                	ld	ra,24(sp)
    800025da:	6442                	ld	s0,16(sp)
    800025dc:	64a2                	ld	s1,8(sp)
    800025de:	6902                	ld	s2,0(sp)
    800025e0:	6105                	addi	sp,sp,32
    800025e2:	8082                	ret
      exit(-1);
    800025e4:	557d                	li	a0,-1
    800025e6:	9ddff0ef          	jal	80001fc2 <exit>
    800025ea:	bf75                	j	800025a6 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025ec:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025f0:	5890                	lw	a2,48(s1)
    800025f2:	00005517          	auipc	a0,0x5
    800025f6:	d3e50513          	addi	a0,a0,-706 # 80007330 <etext+0x330>
    800025fa:	ed5fd0ef          	jal	800004ce <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025fe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002602:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002606:	00005517          	auipc	a0,0x5
    8000260a:	d5a50513          	addi	a0,a0,-678 # 80007360 <etext+0x360>
    8000260e:	ec1fd0ef          	jal	800004ce <printf>
    setkilled(p);
    80002612:	8526                	mv	a0,s1
    80002614:	ab7ff0ef          	jal	800020ca <setkilled>
    80002618:	b75d                	j	800025be <usertrap+0x76>
    struct proc *p = myproc();
    8000261a:	ab6ff0ef          	jal	800018d0 <myproc>
    8000261e:	84aa                	mv	s1,a0
    if(p != 0 && p->alarm_on) {
    80002620:	d955                	beqz	a0,800025d4 <usertrap+0x8c>
    80002622:	17c52783          	lw	a5,380(a0)
    80002626:	d7dd                	beqz	a5,800025d4 <usertrap+0x8c>
      p->ticks_count++;
    80002628:	17852783          	lw	a5,376(a0)
    8000262c:	2785                	addiw	a5,a5,1
    8000262e:	16f52c23          	sw	a5,376(a0)
      if(p->ticks_count >= p->alarm_interval) {
    80002632:	16852703          	lw	a4,360(a0)
    80002636:	f8e7cfe3          	blt	a5,a4,800025d4 <usertrap+0x8c>
        p->ticks_count = 0;
    8000263a:	16052c23          	sw	zero,376(a0)
        if(p->alarm_trapframe == 0) {
    8000263e:	18053783          	ld	a5,384(a0)
    80002642:	fbc9                	bnez	a5,800025d4 <usertrap+0x8c>
          p->alarm_trapframe = kalloc();
    80002644:	ce6fe0ef          	jal	80000b2a <kalloc>
    80002648:	18a4b023          	sd	a0,384(s1)
          memmove(p->alarm_trapframe, p->trapframe, sizeof(struct trapframe));
    8000264c:	12000613          	li	a2,288
    80002650:	6cac                	ld	a1,88(s1)
    80002652:	ee0fe0ef          	jal	80000d32 <memmove>
          p->trapframe->epc = (uint64)p->alarm_handler;
    80002656:	6cbc                	ld	a5,88(s1)
    80002658:	1704b703          	ld	a4,368(s1)
    8000265c:	ef98                	sd	a4,24(a5)
    8000265e:	bf9d                	j	800025d4 <usertrap+0x8c>

0000000080002660 <kerneltrap>:
{
    80002660:	7179                	addi	sp,sp,-48
    80002662:	f406                	sd	ra,40(sp)
    80002664:	f022                	sd	s0,32(sp)
    80002666:	ec26                	sd	s1,24(sp)
    80002668:	e84a                	sd	s2,16(sp)
    8000266a:	e44e                	sd	s3,8(sp)
    8000266c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000266e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002672:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002676:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000267a:	1004f793          	andi	a5,s1,256
    8000267e:	c795                	beqz	a5,800026aa <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002680:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002684:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002686:	eb85                	bnez	a5,800026b6 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002688:	e4dff0ef          	jal	800024d4 <devintr>
    8000268c:	c91d                	beqz	a0,800026c2 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000268e:	4789                	li	a5,2
    80002690:	04f50a63          	beq	a0,a5,800026e4 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002694:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002698:	10049073          	csrw	sstatus,s1
}
    8000269c:	70a2                	ld	ra,40(sp)
    8000269e:	7402                	ld	s0,32(sp)
    800026a0:	64e2                	ld	s1,24(sp)
    800026a2:	6942                	ld	s2,16(sp)
    800026a4:	69a2                	ld	s3,8(sp)
    800026a6:	6145                	addi	sp,sp,48
    800026a8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026aa:	00005517          	auipc	a0,0x5
    800026ae:	cde50513          	addi	a0,a0,-802 # 80007388 <etext+0x388>
    800026b2:	8ecfe0ef          	jal	8000079e <panic>
    panic("kerneltrap: interrupts enabled");
    800026b6:	00005517          	auipc	a0,0x5
    800026ba:	cfa50513          	addi	a0,a0,-774 # 800073b0 <etext+0x3b0>
    800026be:	8e0fe0ef          	jal	8000079e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026c2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026c6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026ca:	85ce                	mv	a1,s3
    800026cc:	00005517          	auipc	a0,0x5
    800026d0:	d0450513          	addi	a0,a0,-764 # 800073d0 <etext+0x3d0>
    800026d4:	dfbfd0ef          	jal	800004ce <printf>
    panic("kerneltrap");
    800026d8:	00005517          	auipc	a0,0x5
    800026dc:	d2050513          	addi	a0,a0,-736 # 800073f8 <etext+0x3f8>
    800026e0:	8befe0ef          	jal	8000079e <panic>
  if(which_dev == 2 && myproc() != 0)
    800026e4:	9ecff0ef          	jal	800018d0 <myproc>
    800026e8:	d555                	beqz	a0,80002694 <kerneltrap+0x34>
    yield();
    800026ea:	fa0ff0ef          	jal	80001e8a <yield>
    800026ee:	b75d                	j	80002694 <kerneltrap+0x34>

00000000800026f0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026f0:	1101                	addi	sp,sp,-32
    800026f2:	ec06                	sd	ra,24(sp)
    800026f4:	e822                	sd	s0,16(sp)
    800026f6:	e426                	sd	s1,8(sp)
    800026f8:	1000                	addi	s0,sp,32
    800026fa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026fc:	9d4ff0ef          	jal	800018d0 <myproc>
  switch (n) {
    80002700:	4795                	li	a5,5
    80002702:	0497e163          	bltu	a5,s1,80002744 <argraw+0x54>
    80002706:	048a                	slli	s1,s1,0x2
    80002708:	00005717          	auipc	a4,0x5
    8000270c:	0b870713          	addi	a4,a4,184 # 800077c0 <states.0+0x30>
    80002710:	94ba                	add	s1,s1,a4
    80002712:	409c                	lw	a5,0(s1)
    80002714:	97ba                	add	a5,a5,a4
    80002716:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002718:	6d3c                	ld	a5,88(a0)
    8000271a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000271c:	60e2                	ld	ra,24(sp)
    8000271e:	6442                	ld	s0,16(sp)
    80002720:	64a2                	ld	s1,8(sp)
    80002722:	6105                	addi	sp,sp,32
    80002724:	8082                	ret
    return p->trapframe->a1;
    80002726:	6d3c                	ld	a5,88(a0)
    80002728:	7fa8                	ld	a0,120(a5)
    8000272a:	bfcd                	j	8000271c <argraw+0x2c>
    return p->trapframe->a2;
    8000272c:	6d3c                	ld	a5,88(a0)
    8000272e:	63c8                	ld	a0,128(a5)
    80002730:	b7f5                	j	8000271c <argraw+0x2c>
    return p->trapframe->a3;
    80002732:	6d3c                	ld	a5,88(a0)
    80002734:	67c8                	ld	a0,136(a5)
    80002736:	b7dd                	j	8000271c <argraw+0x2c>
    return p->trapframe->a4;
    80002738:	6d3c                	ld	a5,88(a0)
    8000273a:	6bc8                	ld	a0,144(a5)
    8000273c:	b7c5                	j	8000271c <argraw+0x2c>
    return p->trapframe->a5;
    8000273e:	6d3c                	ld	a5,88(a0)
    80002740:	6fc8                	ld	a0,152(a5)
    80002742:	bfe9                	j	8000271c <argraw+0x2c>
  panic("argraw");
    80002744:	00005517          	auipc	a0,0x5
    80002748:	cc450513          	addi	a0,a0,-828 # 80007408 <etext+0x408>
    8000274c:	852fe0ef          	jal	8000079e <panic>

0000000080002750 <fetchaddr>:
{
    80002750:	1101                	addi	sp,sp,-32
    80002752:	ec06                	sd	ra,24(sp)
    80002754:	e822                	sd	s0,16(sp)
    80002756:	e426                	sd	s1,8(sp)
    80002758:	e04a                	sd	s2,0(sp)
    8000275a:	1000                	addi	s0,sp,32
    8000275c:	84aa                	mv	s1,a0
    8000275e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002760:	970ff0ef          	jal	800018d0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002764:	653c                	ld	a5,72(a0)
    80002766:	02f4f663          	bgeu	s1,a5,80002792 <fetchaddr+0x42>
    8000276a:	00848713          	addi	a4,s1,8
    8000276e:	02e7e463          	bltu	a5,a4,80002796 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002772:	46a1                	li	a3,8
    80002774:	8626                	mv	a2,s1
    80002776:	85ca                	mv	a1,s2
    80002778:	6928                	ld	a0,80(a0)
    8000277a:	ebbfe0ef          	jal	80001634 <copyin>
    8000277e:	00a03533          	snez	a0,a0
    80002782:	40a0053b          	negw	a0,a0
}
    80002786:	60e2                	ld	ra,24(sp)
    80002788:	6442                	ld	s0,16(sp)
    8000278a:	64a2                	ld	s1,8(sp)
    8000278c:	6902                	ld	s2,0(sp)
    8000278e:	6105                	addi	sp,sp,32
    80002790:	8082                	ret
    return -1;
    80002792:	557d                	li	a0,-1
    80002794:	bfcd                	j	80002786 <fetchaddr+0x36>
    80002796:	557d                	li	a0,-1
    80002798:	b7fd                	j	80002786 <fetchaddr+0x36>

000000008000279a <fetchstr>:
{
    8000279a:	7179                	addi	sp,sp,-48
    8000279c:	f406                	sd	ra,40(sp)
    8000279e:	f022                	sd	s0,32(sp)
    800027a0:	ec26                	sd	s1,24(sp)
    800027a2:	e84a                	sd	s2,16(sp)
    800027a4:	e44e                	sd	s3,8(sp)
    800027a6:	1800                	addi	s0,sp,48
    800027a8:	892a                	mv	s2,a0
    800027aa:	84ae                	mv	s1,a1
    800027ac:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027ae:	922ff0ef          	jal	800018d0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027b2:	86ce                	mv	a3,s3
    800027b4:	864a                	mv	a2,s2
    800027b6:	85a6                	mv	a1,s1
    800027b8:	6928                	ld	a0,80(a0)
    800027ba:	f01fe0ef          	jal	800016ba <copyinstr>
    800027be:	00054c63          	bltz	a0,800027d6 <fetchstr+0x3c>
  return strlen(buf);
    800027c2:	8526                	mv	a0,s1
    800027c4:	e92fe0ef          	jal	80000e56 <strlen>
}
    800027c8:	70a2                	ld	ra,40(sp)
    800027ca:	7402                	ld	s0,32(sp)
    800027cc:	64e2                	ld	s1,24(sp)
    800027ce:	6942                	ld	s2,16(sp)
    800027d0:	69a2                	ld	s3,8(sp)
    800027d2:	6145                	addi	sp,sp,48
    800027d4:	8082                	ret
    return -1;
    800027d6:	557d                	li	a0,-1
    800027d8:	bfc5                	j	800027c8 <fetchstr+0x2e>

00000000800027da <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027da:	1101                	addi	sp,sp,-32
    800027dc:	ec06                	sd	ra,24(sp)
    800027de:	e822                	sd	s0,16(sp)
    800027e0:	e426                	sd	s1,8(sp)
    800027e2:	1000                	addi	s0,sp,32
    800027e4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027e6:	f0bff0ef          	jal	800026f0 <argraw>
    800027ea:	c088                	sw	a0,0(s1)
}
    800027ec:	60e2                	ld	ra,24(sp)
    800027ee:	6442                	ld	s0,16(sp)
    800027f0:	64a2                	ld	s1,8(sp)
    800027f2:	6105                	addi	sp,sp,32
    800027f4:	8082                	ret

00000000800027f6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027f6:	1101                	addi	sp,sp,-32
    800027f8:	ec06                	sd	ra,24(sp)
    800027fa:	e822                	sd	s0,16(sp)
    800027fc:	e426                	sd	s1,8(sp)
    800027fe:	1000                	addi	s0,sp,32
    80002800:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002802:	eefff0ef          	jal	800026f0 <argraw>
    80002806:	e088                	sd	a0,0(s1)
}
    80002808:	60e2                	ld	ra,24(sp)
    8000280a:	6442                	ld	s0,16(sp)
    8000280c:	64a2                	ld	s1,8(sp)
    8000280e:	6105                	addi	sp,sp,32
    80002810:	8082                	ret

0000000080002812 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002812:	1101                	addi	sp,sp,-32
    80002814:	ec06                	sd	ra,24(sp)
    80002816:	e822                	sd	s0,16(sp)
    80002818:	e426                	sd	s1,8(sp)
    8000281a:	e04a                	sd	s2,0(sp)
    8000281c:	1000                	addi	s0,sp,32
    8000281e:	84ae                	mv	s1,a1
    80002820:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002822:	ecfff0ef          	jal	800026f0 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002826:	864a                	mv	a2,s2
    80002828:	85a6                	mv	a1,s1
    8000282a:	f71ff0ef          	jal	8000279a <fetchstr>
}
    8000282e:	60e2                	ld	ra,24(sp)
    80002830:	6442                	ld	s0,16(sp)
    80002832:	64a2                	ld	s1,8(sp)
    80002834:	6902                	ld	s2,0(sp)
    80002836:	6105                	addi	sp,sp,32
    80002838:	8082                	ret

000000008000283a <syscall>:
};


void
syscall(void)
{
    8000283a:	1101                	addi	sp,sp,-32
    8000283c:	ec06                	sd	ra,24(sp)
    8000283e:	e822                	sd	s0,16(sp)
    80002840:	e426                	sd	s1,8(sp)
    80002842:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002844:	88cff0ef          	jal	800018d0 <myproc>
    80002848:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000284a:	6d3c                	ld	a5,88(a0)
    8000284c:	77dc                	ld	a5,168(a5)
    8000284e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002852:	37fd                	addiw	a5,a5,-1
    80002854:	475d                	li	a4,23
    80002856:	02f76763          	bltu	a4,a5,80002884 <syscall+0x4a>
    8000285a:	00369713          	slli	a4,a3,0x3
    8000285e:	00005797          	auipc	a5,0x5
    80002862:	f7a78793          	addi	a5,a5,-134 # 800077d8 <syscalls>
    80002866:	97ba                	add	a5,a5,a4
    80002868:	6390                	ld	a2,0(a5)
    8000286a:	ce09                	beqz	a2,80002884 <syscall+0x4a>
    // increment count of syscall
    syscall_counts[num]++;
    8000286c:	00016797          	auipc	a5,0x16
    80002870:	68c78793          	addi	a5,a5,1676 # 80018ef8 <syscall_counts>
    80002874:	97ba                	add	a5,a5,a4
    80002876:	6398                	ld	a4,0(a5)
    80002878:	0705                	addi	a4,a4,1
    8000287a:	e398                	sd	a4,0(a5)
        //printsyscall(num);
        //printf(" [syscall %d is run %ld times]\n", num, p->syscall_counts[num]);
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000287c:	6d24                	ld	s1,88(a0)
    8000287e:	9602                	jalr	a2
    80002880:	f8a8                	sd	a0,112(s1)
    80002882:	a829                	j	8000289c <syscall+0x62>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002884:	15848613          	addi	a2,s1,344
    80002888:	588c                	lw	a1,48(s1)
    8000288a:	00005517          	auipc	a0,0x5
    8000288e:	b8650513          	addi	a0,a0,-1146 # 80007410 <etext+0x410>
    80002892:	c3dfd0ef          	jal	800004ce <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002896:	6cbc                	ld	a5,88(s1)
    80002898:	577d                	li	a4,-1
    8000289a:	fbb8                	sd	a4,112(a5)
  }
}
    8000289c:	60e2                	ld	ra,24(sp)
    8000289e:	6442                	ld	s0,16(sp)
    800028a0:	64a2                	ld	s1,8(sp)
    800028a2:	6105                	addi	sp,sp,32
    800028a4:	8082                	ret

00000000800028a6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800028a6:	1101                	addi	sp,sp,-32
    800028a8:	ec06                	sd	ra,24(sp)
    800028aa:	e822                	sd	s0,16(sp)
    800028ac:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028ae:	fec40593          	addi	a1,s0,-20
    800028b2:	4501                	li	a0,0
    800028b4:	f27ff0ef          	jal	800027da <argint>
  exit(n);
    800028b8:	fec42503          	lw	a0,-20(s0)
    800028bc:	f06ff0ef          	jal	80001fc2 <exit>
  return 0;  // not reached
}
    800028c0:	4501                	li	a0,0
    800028c2:	60e2                	ld	ra,24(sp)
    800028c4:	6442                	ld	s0,16(sp)
    800028c6:	6105                	addi	sp,sp,32
    800028c8:	8082                	ret

00000000800028ca <sys_getpid>:

uint64
sys_getpid(void)
{
    800028ca:	1141                	addi	sp,sp,-16
    800028cc:	e406                	sd	ra,8(sp)
    800028ce:	e022                	sd	s0,0(sp)
    800028d0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028d2:	ffffe0ef          	jal	800018d0 <myproc>
}
    800028d6:	5908                	lw	a0,48(a0)
    800028d8:	60a2                	ld	ra,8(sp)
    800028da:	6402                	ld	s0,0(sp)
    800028dc:	0141                	addi	sp,sp,16
    800028de:	8082                	ret

00000000800028e0 <sys_fork>:

uint64
sys_fork(void)
{
    800028e0:	1141                	addi	sp,sp,-16
    800028e2:	e406                	sd	ra,8(sp)
    800028e4:	e022                	sd	s0,0(sp)
    800028e6:	0800                	addi	s0,sp,16
  return fork();
    800028e8:	b1eff0ef          	jal	80001c06 <fork>
}
    800028ec:	60a2                	ld	ra,8(sp)
    800028ee:	6402                	ld	s0,0(sp)
    800028f0:	0141                	addi	sp,sp,16
    800028f2:	8082                	ret

00000000800028f4 <sys_wait>:

uint64
sys_wait(void)
{
    800028f4:	1101                	addi	sp,sp,-32
    800028f6:	ec06                	sd	ra,24(sp)
    800028f8:	e822                	sd	s0,16(sp)
    800028fa:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028fc:	fe840593          	addi	a1,s0,-24
    80002900:	4501                	li	a0,0
    80002902:	ef5ff0ef          	jal	800027f6 <argaddr>
  return wait(p);
    80002906:	fe843503          	ld	a0,-24(s0)
    8000290a:	80fff0ef          	jal	80002118 <wait>
}
    8000290e:	60e2                	ld	ra,24(sp)
    80002910:	6442                	ld	s0,16(sp)
    80002912:	6105                	addi	sp,sp,32
    80002914:	8082                	ret

0000000080002916 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002916:	7179                	addi	sp,sp,-48
    80002918:	f406                	sd	ra,40(sp)
    8000291a:	f022                	sd	s0,32(sp)
    8000291c:	ec26                	sd	s1,24(sp)
    8000291e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002920:	fdc40593          	addi	a1,s0,-36
    80002924:	4501                	li	a0,0
    80002926:	eb5ff0ef          	jal	800027da <argint>
  addr = myproc()->sz;
    8000292a:	fa7fe0ef          	jal	800018d0 <myproc>
    8000292e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002930:	fdc42503          	lw	a0,-36(s0)
    80002934:	a82ff0ef          	jal	80001bb6 <growproc>
    80002938:	00054863          	bltz	a0,80002948 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    8000293c:	8526                	mv	a0,s1
    8000293e:	70a2                	ld	ra,40(sp)
    80002940:	7402                	ld	s0,32(sp)
    80002942:	64e2                	ld	s1,24(sp)
    80002944:	6145                	addi	sp,sp,48
    80002946:	8082                	ret
    return -1;
    80002948:	54fd                	li	s1,-1
    8000294a:	bfcd                	j	8000293c <sys_sbrk+0x26>

000000008000294c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000294c:	7139                	addi	sp,sp,-64
    8000294e:	fc06                	sd	ra,56(sp)
    80002950:	f822                	sd	s0,48(sp)
    80002952:	f04a                	sd	s2,32(sp)
    80002954:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002956:	fcc40593          	addi	a1,s0,-52
    8000295a:	4501                	li	a0,0
    8000295c:	e7fff0ef          	jal	800027da <argint>
  if(n < 0)
    80002960:	fcc42783          	lw	a5,-52(s0)
    80002964:	0607c763          	bltz	a5,800029d2 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002968:	00016517          	auipc	a0,0x16
    8000296c:	57850513          	addi	a0,a0,1400 # 80018ee0 <tickslock>
    80002970:	a8efe0ef          	jal	80000bfe <acquire>
  ticks0 = ticks;
    80002974:	00008917          	auipc	s2,0x8
    80002978:	a0c92903          	lw	s2,-1524(s2) # 8000a380 <ticks>
  while(ticks - ticks0 < n){
    8000297c:	fcc42783          	lw	a5,-52(s0)
    80002980:	cf8d                	beqz	a5,800029ba <sys_sleep+0x6e>
    80002982:	f426                	sd	s1,40(sp)
    80002984:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002986:	00016997          	auipc	s3,0x16
    8000298a:	55a98993          	addi	s3,s3,1370 # 80018ee0 <tickslock>
    8000298e:	00008497          	auipc	s1,0x8
    80002992:	9f248493          	addi	s1,s1,-1550 # 8000a380 <ticks>
    if(killed(myproc())){
    80002996:	f3bfe0ef          	jal	800018d0 <myproc>
    8000299a:	f54ff0ef          	jal	800020ee <killed>
    8000299e:	ed0d                	bnez	a0,800029d8 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800029a0:	85ce                	mv	a1,s3
    800029a2:	8526                	mv	a0,s1
    800029a4:	d12ff0ef          	jal	80001eb6 <sleep>
  while(ticks - ticks0 < n){
    800029a8:	409c                	lw	a5,0(s1)
    800029aa:	412787bb          	subw	a5,a5,s2
    800029ae:	fcc42703          	lw	a4,-52(s0)
    800029b2:	fee7e2e3          	bltu	a5,a4,80002996 <sys_sleep+0x4a>
    800029b6:	74a2                	ld	s1,40(sp)
    800029b8:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029ba:	00016517          	auipc	a0,0x16
    800029be:	52650513          	addi	a0,a0,1318 # 80018ee0 <tickslock>
    800029c2:	ad0fe0ef          	jal	80000c92 <release>
  return 0;
    800029c6:	4501                	li	a0,0
}
    800029c8:	70e2                	ld	ra,56(sp)
    800029ca:	7442                	ld	s0,48(sp)
    800029cc:	7902                	ld	s2,32(sp)
    800029ce:	6121                	addi	sp,sp,64
    800029d0:	8082                	ret
    n = 0;
    800029d2:	fc042623          	sw	zero,-52(s0)
    800029d6:	bf49                	j	80002968 <sys_sleep+0x1c>
      release(&tickslock);
    800029d8:	00016517          	auipc	a0,0x16
    800029dc:	50850513          	addi	a0,a0,1288 # 80018ee0 <tickslock>
    800029e0:	ab2fe0ef          	jal	80000c92 <release>
      return -1;
    800029e4:	557d                	li	a0,-1
    800029e6:	74a2                	ld	s1,40(sp)
    800029e8:	69e2                	ld	s3,24(sp)
    800029ea:	bff9                	j	800029c8 <sys_sleep+0x7c>

00000000800029ec <sys_kill>:

uint64
sys_kill(void)
{
    800029ec:	1101                	addi	sp,sp,-32
    800029ee:	ec06                	sd	ra,24(sp)
    800029f0:	e822                	sd	s0,16(sp)
    800029f2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800029f4:	fec40593          	addi	a1,s0,-20
    800029f8:	4501                	li	a0,0
    800029fa:	de1ff0ef          	jal	800027da <argint>
  return kill(pid);
    800029fe:	fec42503          	lw	a0,-20(s0)
    80002a02:	e62ff0ef          	jal	80002064 <kill>
}
    80002a06:	60e2                	ld	ra,24(sp)
    80002a08:	6442                	ld	s0,16(sp)
    80002a0a:	6105                	addi	sp,sp,32
    80002a0c:	8082                	ret

0000000080002a0e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a0e:	1101                	addi	sp,sp,-32
    80002a10:	ec06                	sd	ra,24(sp)
    80002a12:	e822                	sd	s0,16(sp)
    80002a14:	e426                	sd	s1,8(sp)
    80002a16:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a18:	00016517          	auipc	a0,0x16
    80002a1c:	4c850513          	addi	a0,a0,1224 # 80018ee0 <tickslock>
    80002a20:	9defe0ef          	jal	80000bfe <acquire>
  xticks = ticks;
    80002a24:	00008497          	auipc	s1,0x8
    80002a28:	95c4a483          	lw	s1,-1700(s1) # 8000a380 <ticks>
  release(&tickslock);
    80002a2c:	00016517          	auipc	a0,0x16
    80002a30:	4b450513          	addi	a0,a0,1204 # 80018ee0 <tickslock>
    80002a34:	a5efe0ef          	jal	80000c92 <release>
  return xticks;
}
    80002a38:	02049513          	slli	a0,s1,0x20
    80002a3c:	9101                	srli	a0,a0,0x20
    80002a3e:	60e2                	ld	ra,24(sp)
    80002a40:	6442                	ld	s0,16(sp)
    80002a42:	64a2                	ld	s1,8(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret

0000000080002a48 <sys_getSyscount>:

uint64
sys_getSyscount(void)
{
    80002a48:	1101                	addi	sp,sp,-32
    80002a4a:	ec06                	sd	ra,24(sp)
    80002a4c:	e822                	sd	s0,16(sp)
    80002a4e:	1000                	addi	s0,sp,32
  int mask;
  argint(0, &mask);
    80002a50:	fec40593          	addi	a1,s0,-20
    80002a54:	4501                	li	a0,0
    80002a56:	d85ff0ef          	jal	800027da <argint>
  if(mask < 0)
    80002a5a:	fec42683          	lw	a3,-20(s0)
    80002a5e:	0406c663          	bltz	a3,80002aaa <sys_getSyscount+0x62>
    return -1;
  
  // Find the syscall number from the mask
  int syscall_num = -1;
  for(int i = 0; i < 32; i++) {
    80002a62:	4701                	li	a4,0
    if(mask == (1 << i)) {
    80002a64:	4605                	li	a2,1
  for(int i = 0; i < 32; i++) {
    80002a66:	02000593          	li	a1,32
    if(mask == (1 << i)) {
    80002a6a:	00e617bb          	sllw	a5,a2,a4
    80002a6e:	00d78763          	beq	a5,a3,80002a7c <sys_getSyscount+0x34>
  for(int i = 0; i < 32; i++) {
    80002a72:	2705                	addiw	a4,a4,1
    80002a74:	feb71be3          	bne	a4,a1,80002a6a <sys_getSyscount+0x22>
      break;
    }
  }
  
  if(syscall_num == -1)
    return -1;
    80002a78:	557d                	li	a0,-1
    80002a7a:	a025                	j	80002aa2 <sys_getSyscount+0x5a>
  if(syscall_num == -1)
    80002a7c:	57fd                	li	a5,-1
    80002a7e:	02f70863          	beq	a4,a5,80002aae <sys_getSyscount+0x66>
  //struct proc *p = myproc();

  int RETVALL = syscall_counts[syscall_num];
    80002a82:	00016797          	auipc	a5,0x16
    80002a86:	47678793          	addi	a5,a5,1142 # 80018ef8 <syscall_counts>
    80002a8a:	070e                	slli	a4,a4,0x3
    80002a8c:	973e                	add	a4,a4,a5
    80002a8e:	4308                	lw	a0,0(a4)

  // reset count
  for(int i=0; i<=NUMBER_OF_SYSCALLS; i++){
    80002a90:	00016717          	auipc	a4,0x16
    80002a94:	52070713          	addi	a4,a4,1312 # 80018fb0 <bcache>
    syscall_counts[i] = 0;
    80002a98:	0007b023          	sd	zero,0(a5)
  for(int i=0; i<=NUMBER_OF_SYSCALLS; i++){
    80002a9c:	07a1                	addi	a5,a5,8
    80002a9e:	fee79de3          	bne	a5,a4,80002a98 <sys_getSyscount+0x50>
  }
  return RETVALL;
}
    80002aa2:	60e2                	ld	ra,24(sp)
    80002aa4:	6442                	ld	s0,16(sp)
    80002aa6:	6105                	addi	sp,sp,32
    80002aa8:	8082                	ret
    return -1;
    80002aaa:	557d                	li	a0,-1
    80002aac:	bfdd                	j	80002aa2 <sys_getSyscount+0x5a>
    return -1;
    80002aae:	557d                	li	a0,-1
    80002ab0:	bfcd                	j	80002aa2 <sys_getSyscount+0x5a>

0000000080002ab2 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80002ab2:	7179                	addi	sp,sp,-48
    80002ab4:	f406                	sd	ra,40(sp)
    80002ab6:	f022                	sd	s0,32(sp)
    80002ab8:	ec26                	sd	s1,24(sp)
    80002aba:	1800                	addi	s0,sp,48
  int interval;
  uint64 handler;
  argint(0, &interval);
    80002abc:	fdc40593          	addi	a1,s0,-36
    80002ac0:	4501                	li	a0,0
    80002ac2:	d19ff0ef          	jal	800027da <argint>
  argaddr(1, &handler);
    80002ac6:	fd040493          	addi	s1,s0,-48
    80002aca:	85a6                	mv	a1,s1
    80002acc:	4505                	li	a0,1
    80002ace:	d29ff0ef          	jal	800027f6 <argaddr>
  printf("%p\n", &handler);
    80002ad2:	85a6                	mv	a1,s1
    80002ad4:	00005517          	auipc	a0,0x5
    80002ad8:	95c50513          	addi	a0,a0,-1700 # 80007430 <etext+0x430>
    80002adc:	9f3fd0ef          	jal	800004ce <printf>
  struct proc *p = myproc();
    80002ae0:	df1fe0ef          	jal	800018d0 <myproc>
  p->alarm_interval = interval;
    80002ae4:	fdc42783          	lw	a5,-36(s0)
    80002ae8:	16f52423          	sw	a5,360(a0)
  p->alarm_handler = (void(*)())handler;
    80002aec:	fd043703          	ld	a4,-48(s0)
    80002af0:	16e53823          	sd	a4,368(a0)
  p->ticks_count = 0;
    80002af4:	16052c23          	sw	zero,376(a0)
  p->alarm_on = (interval > 0);
    80002af8:	00f027b3          	sgtz	a5,a5
    80002afc:	16f52e23          	sw	a5,380(a0)
  
  return 0;
}
    80002b00:	4501                	li	a0,0
    80002b02:	70a2                	ld	ra,40(sp)
    80002b04:	7402                	ld	s0,32(sp)
    80002b06:	64e2                	ld	s1,24(sp)
    80002b08:	6145                	addi	sp,sp,48
    80002b0a:	8082                	ret

0000000080002b0c <sys_sigreturn>:


uint64
sys_sigreturn(void)
{
    80002b0c:	1101                	addi	sp,sp,-32
    80002b0e:	ec06                	sd	ra,24(sp)
    80002b10:	e822                	sd	s0,16(sp)
    80002b12:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002b14:	dbdfe0ef          	jal	800018d0 <myproc>
  if(p->alarm_trapframe == 0)
    80002b18:	18053583          	ld	a1,384(a0)
    80002b1c:	c585                	beqz	a1,80002b44 <sys_sigreturn+0x38>
    80002b1e:	e426                	sd	s1,8(sp)
    80002b20:	84aa                	mv	s1,a0
    return -1;
  
  memmove(p->trapframe, p->alarm_trapframe, sizeof(struct trapframe));
    80002b22:	12000613          	li	a2,288
    80002b26:	6d28                	ld	a0,88(a0)
    80002b28:	a0afe0ef          	jal	80000d32 <memmove>
  kfree(p->alarm_trapframe);
    80002b2c:	1804b503          	ld	a0,384(s1)
    80002b30:	f19fd0ef          	jal	80000a48 <kfree>
  p->alarm_trapframe = 0;
    80002b34:	1804b023          	sd	zero,384(s1)
  
  return 0;
    80002b38:	4501                	li	a0,0
    80002b3a:	64a2                	ld	s1,8(sp)
}
    80002b3c:	60e2                	ld	ra,24(sp)
    80002b3e:	6442                	ld	s0,16(sp)
    80002b40:	6105                	addi	sp,sp,32
    80002b42:	8082                	ret
    return -1;
    80002b44:	557d                	li	a0,-1
    80002b46:	bfdd                	j	80002b3c <sys_sigreturn+0x30>

0000000080002b48 <sys_settickets>:

uint64
sys_settickets(void)
{
    80002b48:	1101                	addi	sp,sp,-32
    80002b4a:	ec06                	sd	ra,24(sp)
    80002b4c:	e822                	sd	s0,16(sp)
    80002b4e:	1000                	addi	s0,sp,32
  int number;
  argint(0, &number);
    80002b50:	fec40593          	addi	a1,s0,-20
    80002b54:	4501                	li	a0,0
    80002b56:	c85ff0ef          	jal	800027da <argint>
  if(number <= 0)
    80002b5a:	fec42783          	lw	a5,-20(s0)
    return -1;
    80002b5e:	557d                	li	a0,-1
  if(number <= 0)
    80002b60:	00f05963          	blez	a5,80002b72 <sys_settickets+0x2a>
  myproc()->tickets = number;
    80002b64:	d6dfe0ef          	jal	800018d0 <myproc>
    80002b68:	fec42783          	lw	a5,-20(s0)
    80002b6c:	18f52423          	sw	a5,392(a0)
  return number;
    80002b70:	853e                	mv	a0,a5
}
    80002b72:	60e2                	ld	ra,24(sp)
    80002b74:	6442                	ld	s0,16(sp)
    80002b76:	6105                	addi	sp,sp,32
    80002b78:	8082                	ret

0000000080002b7a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b7a:	7179                	addi	sp,sp,-48
    80002b7c:	f406                	sd	ra,40(sp)
    80002b7e:	f022                	sd	s0,32(sp)
    80002b80:	ec26                	sd	s1,24(sp)
    80002b82:	e84a                	sd	s2,16(sp)
    80002b84:	e44e                	sd	s3,8(sp)
    80002b86:	e052                	sd	s4,0(sp)
    80002b88:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b8a:	00005597          	auipc	a1,0x5
    80002b8e:	8ae58593          	addi	a1,a1,-1874 # 80007438 <etext+0x438>
    80002b92:	00016517          	auipc	a0,0x16
    80002b96:	41e50513          	addi	a0,a0,1054 # 80018fb0 <bcache>
    80002b9a:	fe1fd0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b9e:	0001e797          	auipc	a5,0x1e
    80002ba2:	41278793          	addi	a5,a5,1042 # 80020fb0 <bcache+0x8000>
    80002ba6:	0001e717          	auipc	a4,0x1e
    80002baa:	67270713          	addi	a4,a4,1650 # 80021218 <bcache+0x8268>
    80002bae:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002bb2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bb6:	00016497          	auipc	s1,0x16
    80002bba:	41248493          	addi	s1,s1,1042 # 80018fc8 <bcache+0x18>
    b->next = bcache.head.next;
    80002bbe:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bc0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bc2:	00005a17          	auipc	s4,0x5
    80002bc6:	87ea0a13          	addi	s4,s4,-1922 # 80007440 <etext+0x440>
    b->next = bcache.head.next;
    80002bca:	2b893783          	ld	a5,696(s2)
    80002bce:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bd0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bd4:	85d2                	mv	a1,s4
    80002bd6:	01048513          	addi	a0,s1,16
    80002bda:	244010ef          	jal	80003e1e <initsleeplock>
    bcache.head.next->prev = b;
    80002bde:	2b893783          	ld	a5,696(s2)
    80002be2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002be4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002be8:	45848493          	addi	s1,s1,1112
    80002bec:	fd349fe3          	bne	s1,s3,80002bca <binit+0x50>
  }
}
    80002bf0:	70a2                	ld	ra,40(sp)
    80002bf2:	7402                	ld	s0,32(sp)
    80002bf4:	64e2                	ld	s1,24(sp)
    80002bf6:	6942                	ld	s2,16(sp)
    80002bf8:	69a2                	ld	s3,8(sp)
    80002bfa:	6a02                	ld	s4,0(sp)
    80002bfc:	6145                	addi	sp,sp,48
    80002bfe:	8082                	ret

0000000080002c00 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002c00:	7179                	addi	sp,sp,-48
    80002c02:	f406                	sd	ra,40(sp)
    80002c04:	f022                	sd	s0,32(sp)
    80002c06:	ec26                	sd	s1,24(sp)
    80002c08:	e84a                	sd	s2,16(sp)
    80002c0a:	e44e                	sd	s3,8(sp)
    80002c0c:	1800                	addi	s0,sp,48
    80002c0e:	892a                	mv	s2,a0
    80002c10:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c12:	00016517          	auipc	a0,0x16
    80002c16:	39e50513          	addi	a0,a0,926 # 80018fb0 <bcache>
    80002c1a:	fe5fd0ef          	jal	80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c1e:	0001e497          	auipc	s1,0x1e
    80002c22:	64a4b483          	ld	s1,1610(s1) # 80021268 <bcache+0x82b8>
    80002c26:	0001e797          	auipc	a5,0x1e
    80002c2a:	5f278793          	addi	a5,a5,1522 # 80021218 <bcache+0x8268>
    80002c2e:	02f48b63          	beq	s1,a5,80002c64 <bread+0x64>
    80002c32:	873e                	mv	a4,a5
    80002c34:	a021                	j	80002c3c <bread+0x3c>
    80002c36:	68a4                	ld	s1,80(s1)
    80002c38:	02e48663          	beq	s1,a4,80002c64 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c3c:	449c                	lw	a5,8(s1)
    80002c3e:	ff279ce3          	bne	a5,s2,80002c36 <bread+0x36>
    80002c42:	44dc                	lw	a5,12(s1)
    80002c44:	ff3799e3          	bne	a5,s3,80002c36 <bread+0x36>
      b->refcnt++;
    80002c48:	40bc                	lw	a5,64(s1)
    80002c4a:	2785                	addiw	a5,a5,1
    80002c4c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c4e:	00016517          	auipc	a0,0x16
    80002c52:	36250513          	addi	a0,a0,866 # 80018fb0 <bcache>
    80002c56:	83cfe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002c5a:	01048513          	addi	a0,s1,16
    80002c5e:	1f6010ef          	jal	80003e54 <acquiresleep>
      return b;
    80002c62:	a889                	j	80002cb4 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c64:	0001e497          	auipc	s1,0x1e
    80002c68:	5fc4b483          	ld	s1,1532(s1) # 80021260 <bcache+0x82b0>
    80002c6c:	0001e797          	auipc	a5,0x1e
    80002c70:	5ac78793          	addi	a5,a5,1452 # 80021218 <bcache+0x8268>
    80002c74:	00f48863          	beq	s1,a5,80002c84 <bread+0x84>
    80002c78:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c7a:	40bc                	lw	a5,64(s1)
    80002c7c:	cb91                	beqz	a5,80002c90 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c7e:	64a4                	ld	s1,72(s1)
    80002c80:	fee49de3          	bne	s1,a4,80002c7a <bread+0x7a>
  panic("bget: no buffers");
    80002c84:	00004517          	auipc	a0,0x4
    80002c88:	7c450513          	addi	a0,a0,1988 # 80007448 <etext+0x448>
    80002c8c:	b13fd0ef          	jal	8000079e <panic>
      b->dev = dev;
    80002c90:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c94:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c98:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c9c:	4785                	li	a5,1
    80002c9e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ca0:	00016517          	auipc	a0,0x16
    80002ca4:	31050513          	addi	a0,a0,784 # 80018fb0 <bcache>
    80002ca8:	febfd0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002cac:	01048513          	addi	a0,s1,16
    80002cb0:	1a4010ef          	jal	80003e54 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002cb4:	409c                	lw	a5,0(s1)
    80002cb6:	cb89                	beqz	a5,80002cc8 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002cb8:	8526                	mv	a0,s1
    80002cba:	70a2                	ld	ra,40(sp)
    80002cbc:	7402                	ld	s0,32(sp)
    80002cbe:	64e2                	ld	s1,24(sp)
    80002cc0:	6942                	ld	s2,16(sp)
    80002cc2:	69a2                	ld	s3,8(sp)
    80002cc4:	6145                	addi	sp,sp,48
    80002cc6:	8082                	ret
    virtio_disk_rw(b, 0);
    80002cc8:	4581                	li	a1,0
    80002cca:	8526                	mv	a0,s1
    80002ccc:	1f5020ef          	jal	800056c0 <virtio_disk_rw>
    b->valid = 1;
    80002cd0:	4785                	li	a5,1
    80002cd2:	c09c                	sw	a5,0(s1)
  return b;
    80002cd4:	b7d5                	j	80002cb8 <bread+0xb8>

0000000080002cd6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cd6:	1101                	addi	sp,sp,-32
    80002cd8:	ec06                	sd	ra,24(sp)
    80002cda:	e822                	sd	s0,16(sp)
    80002cdc:	e426                	sd	s1,8(sp)
    80002cde:	1000                	addi	s0,sp,32
    80002ce0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ce2:	0541                	addi	a0,a0,16
    80002ce4:	1ee010ef          	jal	80003ed2 <holdingsleep>
    80002ce8:	c911                	beqz	a0,80002cfc <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cea:	4585                	li	a1,1
    80002cec:	8526                	mv	a0,s1
    80002cee:	1d3020ef          	jal	800056c0 <virtio_disk_rw>
}
    80002cf2:	60e2                	ld	ra,24(sp)
    80002cf4:	6442                	ld	s0,16(sp)
    80002cf6:	64a2                	ld	s1,8(sp)
    80002cf8:	6105                	addi	sp,sp,32
    80002cfa:	8082                	ret
    panic("bwrite");
    80002cfc:	00004517          	auipc	a0,0x4
    80002d00:	76450513          	addi	a0,a0,1892 # 80007460 <etext+0x460>
    80002d04:	a9bfd0ef          	jal	8000079e <panic>

0000000080002d08 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d08:	1101                	addi	sp,sp,-32
    80002d0a:	ec06                	sd	ra,24(sp)
    80002d0c:	e822                	sd	s0,16(sp)
    80002d0e:	e426                	sd	s1,8(sp)
    80002d10:	e04a                	sd	s2,0(sp)
    80002d12:	1000                	addi	s0,sp,32
    80002d14:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d16:	01050913          	addi	s2,a0,16
    80002d1a:	854a                	mv	a0,s2
    80002d1c:	1b6010ef          	jal	80003ed2 <holdingsleep>
    80002d20:	c125                	beqz	a0,80002d80 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002d22:	854a                	mv	a0,s2
    80002d24:	176010ef          	jal	80003e9a <releasesleep>

  acquire(&bcache.lock);
    80002d28:	00016517          	auipc	a0,0x16
    80002d2c:	28850513          	addi	a0,a0,648 # 80018fb0 <bcache>
    80002d30:	ecffd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002d34:	40bc                	lw	a5,64(s1)
    80002d36:	37fd                	addiw	a5,a5,-1
    80002d38:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d3a:	e79d                	bnez	a5,80002d68 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d3c:	68b8                	ld	a4,80(s1)
    80002d3e:	64bc                	ld	a5,72(s1)
    80002d40:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d42:	68b8                	ld	a4,80(s1)
    80002d44:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d46:	0001e797          	auipc	a5,0x1e
    80002d4a:	26a78793          	addi	a5,a5,618 # 80020fb0 <bcache+0x8000>
    80002d4e:	2b87b703          	ld	a4,696(a5)
    80002d52:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d54:	0001e717          	auipc	a4,0x1e
    80002d58:	4c470713          	addi	a4,a4,1220 # 80021218 <bcache+0x8268>
    80002d5c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d5e:	2b87b703          	ld	a4,696(a5)
    80002d62:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d64:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d68:	00016517          	auipc	a0,0x16
    80002d6c:	24850513          	addi	a0,a0,584 # 80018fb0 <bcache>
    80002d70:	f23fd0ef          	jal	80000c92 <release>
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	64a2                	ld	s1,8(sp)
    80002d7a:	6902                	ld	s2,0(sp)
    80002d7c:	6105                	addi	sp,sp,32
    80002d7e:	8082                	ret
    panic("brelse");
    80002d80:	00004517          	auipc	a0,0x4
    80002d84:	6e850513          	addi	a0,a0,1768 # 80007468 <etext+0x468>
    80002d88:	a17fd0ef          	jal	8000079e <panic>

0000000080002d8c <bpin>:

void
bpin(struct buf *b) {
    80002d8c:	1101                	addi	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	e426                	sd	s1,8(sp)
    80002d94:	1000                	addi	s0,sp,32
    80002d96:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d98:	00016517          	auipc	a0,0x16
    80002d9c:	21850513          	addi	a0,a0,536 # 80018fb0 <bcache>
    80002da0:	e5ffd0ef          	jal	80000bfe <acquire>
  b->refcnt++;
    80002da4:	40bc                	lw	a5,64(s1)
    80002da6:	2785                	addiw	a5,a5,1
    80002da8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002daa:	00016517          	auipc	a0,0x16
    80002dae:	20650513          	addi	a0,a0,518 # 80018fb0 <bcache>
    80002db2:	ee1fd0ef          	jal	80000c92 <release>
}
    80002db6:	60e2                	ld	ra,24(sp)
    80002db8:	6442                	ld	s0,16(sp)
    80002dba:	64a2                	ld	s1,8(sp)
    80002dbc:	6105                	addi	sp,sp,32
    80002dbe:	8082                	ret

0000000080002dc0 <bunpin>:

void
bunpin(struct buf *b) {
    80002dc0:	1101                	addi	sp,sp,-32
    80002dc2:	ec06                	sd	ra,24(sp)
    80002dc4:	e822                	sd	s0,16(sp)
    80002dc6:	e426                	sd	s1,8(sp)
    80002dc8:	1000                	addi	s0,sp,32
    80002dca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dcc:	00016517          	auipc	a0,0x16
    80002dd0:	1e450513          	addi	a0,a0,484 # 80018fb0 <bcache>
    80002dd4:	e2bfd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002dd8:	40bc                	lw	a5,64(s1)
    80002dda:	37fd                	addiw	a5,a5,-1
    80002ddc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dde:	00016517          	auipc	a0,0x16
    80002de2:	1d250513          	addi	a0,a0,466 # 80018fb0 <bcache>
    80002de6:	eadfd0ef          	jal	80000c92 <release>
}
    80002dea:	60e2                	ld	ra,24(sp)
    80002dec:	6442                	ld	s0,16(sp)
    80002dee:	64a2                	ld	s1,8(sp)
    80002df0:	6105                	addi	sp,sp,32
    80002df2:	8082                	ret

0000000080002df4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002df4:	1101                	addi	sp,sp,-32
    80002df6:	ec06                	sd	ra,24(sp)
    80002df8:	e822                	sd	s0,16(sp)
    80002dfa:	e426                	sd	s1,8(sp)
    80002dfc:	e04a                	sd	s2,0(sp)
    80002dfe:	1000                	addi	s0,sp,32
    80002e00:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e02:	00d5d79b          	srliw	a5,a1,0xd
    80002e06:	0001f597          	auipc	a1,0x1f
    80002e0a:	8865a583          	lw	a1,-1914(a1) # 8002168c <sb+0x1c>
    80002e0e:	9dbd                	addw	a1,a1,a5
    80002e10:	df1ff0ef          	jal	80002c00 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e14:	0074f713          	andi	a4,s1,7
    80002e18:	4785                	li	a5,1
    80002e1a:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e1e:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002e20:	90d9                	srli	s1,s1,0x36
    80002e22:	00950733          	add	a4,a0,s1
    80002e26:	05874703          	lbu	a4,88(a4)
    80002e2a:	00e7f6b3          	and	a3,a5,a4
    80002e2e:	c29d                	beqz	a3,80002e54 <bfree+0x60>
    80002e30:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e32:	94aa                	add	s1,s1,a0
    80002e34:	fff7c793          	not	a5,a5
    80002e38:	8f7d                	and	a4,a4,a5
    80002e3a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e3e:	711000ef          	jal	80003d4e <log_write>
  brelse(bp);
    80002e42:	854a                	mv	a0,s2
    80002e44:	ec5ff0ef          	jal	80002d08 <brelse>
}
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	64a2                	ld	s1,8(sp)
    80002e4e:	6902                	ld	s2,0(sp)
    80002e50:	6105                	addi	sp,sp,32
    80002e52:	8082                	ret
    panic("freeing free block");
    80002e54:	00004517          	auipc	a0,0x4
    80002e58:	61c50513          	addi	a0,a0,1564 # 80007470 <etext+0x470>
    80002e5c:	943fd0ef          	jal	8000079e <panic>

0000000080002e60 <balloc>:
{
    80002e60:	715d                	addi	sp,sp,-80
    80002e62:	e486                	sd	ra,72(sp)
    80002e64:	e0a2                	sd	s0,64(sp)
    80002e66:	fc26                	sd	s1,56(sp)
    80002e68:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002e6a:	0001f797          	auipc	a5,0x1f
    80002e6e:	80a7a783          	lw	a5,-2038(a5) # 80021674 <sb+0x4>
    80002e72:	0e078863          	beqz	a5,80002f62 <balloc+0x102>
    80002e76:	f84a                	sd	s2,48(sp)
    80002e78:	f44e                	sd	s3,40(sp)
    80002e7a:	f052                	sd	s4,32(sp)
    80002e7c:	ec56                	sd	s5,24(sp)
    80002e7e:	e85a                	sd	s6,16(sp)
    80002e80:	e45e                	sd	s7,8(sp)
    80002e82:	e062                	sd	s8,0(sp)
    80002e84:	8baa                	mv	s7,a0
    80002e86:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e88:	0001eb17          	auipc	s6,0x1e
    80002e8c:	7e8b0b13          	addi	s6,s6,2024 # 80021670 <sb>
      m = 1 << (bi % 8);
    80002e90:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e92:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e94:	6c09                	lui	s8,0x2
    80002e96:	a09d                	j	80002efc <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e98:	97ca                	add	a5,a5,s2
    80002e9a:	8e55                	or	a2,a2,a3
    80002e9c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ea0:	854a                	mv	a0,s2
    80002ea2:	6ad000ef          	jal	80003d4e <log_write>
        brelse(bp);
    80002ea6:	854a                	mv	a0,s2
    80002ea8:	e61ff0ef          	jal	80002d08 <brelse>
  bp = bread(dev, bno);
    80002eac:	85a6                	mv	a1,s1
    80002eae:	855e                	mv	a0,s7
    80002eb0:	d51ff0ef          	jal	80002c00 <bread>
    80002eb4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002eb6:	40000613          	li	a2,1024
    80002eba:	4581                	li	a1,0
    80002ebc:	05850513          	addi	a0,a0,88
    80002ec0:	e0ffd0ef          	jal	80000cce <memset>
  log_write(bp);
    80002ec4:	854a                	mv	a0,s2
    80002ec6:	689000ef          	jal	80003d4e <log_write>
  brelse(bp);
    80002eca:	854a                	mv	a0,s2
    80002ecc:	e3dff0ef          	jal	80002d08 <brelse>
}
    80002ed0:	7942                	ld	s2,48(sp)
    80002ed2:	79a2                	ld	s3,40(sp)
    80002ed4:	7a02                	ld	s4,32(sp)
    80002ed6:	6ae2                	ld	s5,24(sp)
    80002ed8:	6b42                	ld	s6,16(sp)
    80002eda:	6ba2                	ld	s7,8(sp)
    80002edc:	6c02                	ld	s8,0(sp)
}
    80002ede:	8526                	mv	a0,s1
    80002ee0:	60a6                	ld	ra,72(sp)
    80002ee2:	6406                	ld	s0,64(sp)
    80002ee4:	74e2                	ld	s1,56(sp)
    80002ee6:	6161                	addi	sp,sp,80
    80002ee8:	8082                	ret
    brelse(bp);
    80002eea:	854a                	mv	a0,s2
    80002eec:	e1dff0ef          	jal	80002d08 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ef0:	015c0abb          	addw	s5,s8,s5
    80002ef4:	004b2783          	lw	a5,4(s6)
    80002ef8:	04fafe63          	bgeu	s5,a5,80002f54 <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    80002efc:	41fad79b          	sraiw	a5,s5,0x1f
    80002f00:	0137d79b          	srliw	a5,a5,0x13
    80002f04:	015787bb          	addw	a5,a5,s5
    80002f08:	40d7d79b          	sraiw	a5,a5,0xd
    80002f0c:	01cb2583          	lw	a1,28(s6)
    80002f10:	9dbd                	addw	a1,a1,a5
    80002f12:	855e                	mv	a0,s7
    80002f14:	cedff0ef          	jal	80002c00 <bread>
    80002f18:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f1a:	004b2503          	lw	a0,4(s6)
    80002f1e:	84d6                	mv	s1,s5
    80002f20:	4701                	li	a4,0
    80002f22:	fca4f4e3          	bgeu	s1,a0,80002eea <balloc+0x8a>
      m = 1 << (bi % 8);
    80002f26:	00777693          	andi	a3,a4,7
    80002f2a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f2e:	41f7579b          	sraiw	a5,a4,0x1f
    80002f32:	01d7d79b          	srliw	a5,a5,0x1d
    80002f36:	9fb9                	addw	a5,a5,a4
    80002f38:	4037d79b          	sraiw	a5,a5,0x3
    80002f3c:	00f90633          	add	a2,s2,a5
    80002f40:	05864603          	lbu	a2,88(a2)
    80002f44:	00c6f5b3          	and	a1,a3,a2
    80002f48:	d9a1                	beqz	a1,80002e98 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f4a:	2705                	addiw	a4,a4,1
    80002f4c:	2485                	addiw	s1,s1,1
    80002f4e:	fd471ae3          	bne	a4,s4,80002f22 <balloc+0xc2>
    80002f52:	bf61                	j	80002eea <balloc+0x8a>
    80002f54:	7942                	ld	s2,48(sp)
    80002f56:	79a2                	ld	s3,40(sp)
    80002f58:	7a02                	ld	s4,32(sp)
    80002f5a:	6ae2                	ld	s5,24(sp)
    80002f5c:	6b42                	ld	s6,16(sp)
    80002f5e:	6ba2                	ld	s7,8(sp)
    80002f60:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002f62:	00004517          	auipc	a0,0x4
    80002f66:	52650513          	addi	a0,a0,1318 # 80007488 <etext+0x488>
    80002f6a:	d64fd0ef          	jal	800004ce <printf>
  return 0;
    80002f6e:	4481                	li	s1,0
    80002f70:	b7bd                	j	80002ede <balloc+0x7e>

0000000080002f72 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f72:	7179                	addi	sp,sp,-48
    80002f74:	f406                	sd	ra,40(sp)
    80002f76:	f022                	sd	s0,32(sp)
    80002f78:	ec26                	sd	s1,24(sp)
    80002f7a:	e84a                	sd	s2,16(sp)
    80002f7c:	e44e                	sd	s3,8(sp)
    80002f7e:	1800                	addi	s0,sp,48
    80002f80:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f82:	47ad                	li	a5,11
    80002f84:	02b7e363          	bltu	a5,a1,80002faa <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002f88:	02059793          	slli	a5,a1,0x20
    80002f8c:	01e7d593          	srli	a1,a5,0x1e
    80002f90:	00b504b3          	add	s1,a0,a1
    80002f94:	0504a903          	lw	s2,80(s1)
    80002f98:	06091363          	bnez	s2,80002ffe <bmap+0x8c>
      addr = balloc(ip->dev);
    80002f9c:	4108                	lw	a0,0(a0)
    80002f9e:	ec3ff0ef          	jal	80002e60 <balloc>
    80002fa2:	892a                	mv	s2,a0
      if(addr == 0)
    80002fa4:	cd29                	beqz	a0,80002ffe <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80002fa6:	c8a8                	sw	a0,80(s1)
    80002fa8:	a899                	j	80002ffe <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002faa:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80002fae:	0ff00793          	li	a5,255
    80002fb2:	0697e963          	bltu	a5,s1,80003024 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002fb6:	08052903          	lw	s2,128(a0)
    80002fba:	00091b63          	bnez	s2,80002fd0 <bmap+0x5e>
      addr = balloc(ip->dev);
    80002fbe:	4108                	lw	a0,0(a0)
    80002fc0:	ea1ff0ef          	jal	80002e60 <balloc>
    80002fc4:	892a                	mv	s2,a0
      if(addr == 0)
    80002fc6:	cd05                	beqz	a0,80002ffe <bmap+0x8c>
    80002fc8:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fca:	08a9a023          	sw	a0,128(s3)
    80002fce:	a011                	j	80002fd2 <bmap+0x60>
    80002fd0:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fd2:	85ca                	mv	a1,s2
    80002fd4:	0009a503          	lw	a0,0(s3)
    80002fd8:	c29ff0ef          	jal	80002c00 <bread>
    80002fdc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fde:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fe2:	02049713          	slli	a4,s1,0x20
    80002fe6:	01e75593          	srli	a1,a4,0x1e
    80002fea:	00b784b3          	add	s1,a5,a1
    80002fee:	0004a903          	lw	s2,0(s1)
    80002ff2:	00090e63          	beqz	s2,8000300e <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002ff6:	8552                	mv	a0,s4
    80002ff8:	d11ff0ef          	jal	80002d08 <brelse>
    return addr;
    80002ffc:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002ffe:	854a                	mv	a0,s2
    80003000:	70a2                	ld	ra,40(sp)
    80003002:	7402                	ld	s0,32(sp)
    80003004:	64e2                	ld	s1,24(sp)
    80003006:	6942                	ld	s2,16(sp)
    80003008:	69a2                	ld	s3,8(sp)
    8000300a:	6145                	addi	sp,sp,48
    8000300c:	8082                	ret
      addr = balloc(ip->dev);
    8000300e:	0009a503          	lw	a0,0(s3)
    80003012:	e4fff0ef          	jal	80002e60 <balloc>
    80003016:	892a                	mv	s2,a0
      if(addr){
    80003018:	dd79                	beqz	a0,80002ff6 <bmap+0x84>
        a[bn] = addr;
    8000301a:	c088                	sw	a0,0(s1)
        log_write(bp);
    8000301c:	8552                	mv	a0,s4
    8000301e:	531000ef          	jal	80003d4e <log_write>
    80003022:	bfd1                	j	80002ff6 <bmap+0x84>
    80003024:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003026:	00004517          	auipc	a0,0x4
    8000302a:	47a50513          	addi	a0,a0,1146 # 800074a0 <etext+0x4a0>
    8000302e:	f70fd0ef          	jal	8000079e <panic>

0000000080003032 <iget>:
{
    80003032:	7179                	addi	sp,sp,-48
    80003034:	f406                	sd	ra,40(sp)
    80003036:	f022                	sd	s0,32(sp)
    80003038:	ec26                	sd	s1,24(sp)
    8000303a:	e84a                	sd	s2,16(sp)
    8000303c:	e44e                	sd	s3,8(sp)
    8000303e:	e052                	sd	s4,0(sp)
    80003040:	1800                	addi	s0,sp,48
    80003042:	89aa                	mv	s3,a0
    80003044:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003046:	0001e517          	auipc	a0,0x1e
    8000304a:	64a50513          	addi	a0,a0,1610 # 80021690 <itable>
    8000304e:	bb1fd0ef          	jal	80000bfe <acquire>
  empty = 0;
    80003052:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003054:	0001e497          	auipc	s1,0x1e
    80003058:	65448493          	addi	s1,s1,1620 # 800216a8 <itable+0x18>
    8000305c:	00020697          	auipc	a3,0x20
    80003060:	0dc68693          	addi	a3,a3,220 # 80023138 <log>
    80003064:	a039                	j	80003072 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003066:	02090963          	beqz	s2,80003098 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000306a:	08848493          	addi	s1,s1,136
    8000306e:	02d48863          	beq	s1,a3,8000309e <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003072:	449c                	lw	a5,8(s1)
    80003074:	fef059e3          	blez	a5,80003066 <iget+0x34>
    80003078:	4098                	lw	a4,0(s1)
    8000307a:	ff3716e3          	bne	a4,s3,80003066 <iget+0x34>
    8000307e:	40d8                	lw	a4,4(s1)
    80003080:	ff4713e3          	bne	a4,s4,80003066 <iget+0x34>
      ip->ref++;
    80003084:	2785                	addiw	a5,a5,1
    80003086:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003088:	0001e517          	auipc	a0,0x1e
    8000308c:	60850513          	addi	a0,a0,1544 # 80021690 <itable>
    80003090:	c03fd0ef          	jal	80000c92 <release>
      return ip;
    80003094:	8926                	mv	s2,s1
    80003096:	a02d                	j	800030c0 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003098:	fbe9                	bnez	a5,8000306a <iget+0x38>
      empty = ip;
    8000309a:	8926                	mv	s2,s1
    8000309c:	b7f9                	j	8000306a <iget+0x38>
  if(empty == 0)
    8000309e:	02090a63          	beqz	s2,800030d2 <iget+0xa0>
  ip->dev = dev;
    800030a2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800030a6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800030aa:	4785                	li	a5,1
    800030ac:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800030b0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800030b4:	0001e517          	auipc	a0,0x1e
    800030b8:	5dc50513          	addi	a0,a0,1500 # 80021690 <itable>
    800030bc:	bd7fd0ef          	jal	80000c92 <release>
}
    800030c0:	854a                	mv	a0,s2
    800030c2:	70a2                	ld	ra,40(sp)
    800030c4:	7402                	ld	s0,32(sp)
    800030c6:	64e2                	ld	s1,24(sp)
    800030c8:	6942                	ld	s2,16(sp)
    800030ca:	69a2                	ld	s3,8(sp)
    800030cc:	6a02                	ld	s4,0(sp)
    800030ce:	6145                	addi	sp,sp,48
    800030d0:	8082                	ret
    panic("iget: no inodes");
    800030d2:	00004517          	auipc	a0,0x4
    800030d6:	3e650513          	addi	a0,a0,998 # 800074b8 <etext+0x4b8>
    800030da:	ec4fd0ef          	jal	8000079e <panic>

00000000800030de <fsinit>:
fsinit(int dev) {
    800030de:	7179                	addi	sp,sp,-48
    800030e0:	f406                	sd	ra,40(sp)
    800030e2:	f022                	sd	s0,32(sp)
    800030e4:	ec26                	sd	s1,24(sp)
    800030e6:	e84a                	sd	s2,16(sp)
    800030e8:	e44e                	sd	s3,8(sp)
    800030ea:	1800                	addi	s0,sp,48
    800030ec:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800030ee:	4585                	li	a1,1
    800030f0:	b11ff0ef          	jal	80002c00 <bread>
    800030f4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800030f6:	0001e997          	auipc	s3,0x1e
    800030fa:	57a98993          	addi	s3,s3,1402 # 80021670 <sb>
    800030fe:	02000613          	li	a2,32
    80003102:	05850593          	addi	a1,a0,88
    80003106:	854e                	mv	a0,s3
    80003108:	c2bfd0ef          	jal	80000d32 <memmove>
  brelse(bp);
    8000310c:	8526                	mv	a0,s1
    8000310e:	bfbff0ef          	jal	80002d08 <brelse>
  if(sb.magic != FSMAGIC)
    80003112:	0009a703          	lw	a4,0(s3)
    80003116:	102037b7          	lui	a5,0x10203
    8000311a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000311e:	02f71063          	bne	a4,a5,8000313e <fsinit+0x60>
  initlog(dev, &sb);
    80003122:	0001e597          	auipc	a1,0x1e
    80003126:	54e58593          	addi	a1,a1,1358 # 80021670 <sb>
    8000312a:	854a                	mv	a0,s2
    8000312c:	215000ef          	jal	80003b40 <initlog>
}
    80003130:	70a2                	ld	ra,40(sp)
    80003132:	7402                	ld	s0,32(sp)
    80003134:	64e2                	ld	s1,24(sp)
    80003136:	6942                	ld	s2,16(sp)
    80003138:	69a2                	ld	s3,8(sp)
    8000313a:	6145                	addi	sp,sp,48
    8000313c:	8082                	ret
    panic("invalid file system");
    8000313e:	00004517          	auipc	a0,0x4
    80003142:	38a50513          	addi	a0,a0,906 # 800074c8 <etext+0x4c8>
    80003146:	e58fd0ef          	jal	8000079e <panic>

000000008000314a <iinit>:
{
    8000314a:	7179                	addi	sp,sp,-48
    8000314c:	f406                	sd	ra,40(sp)
    8000314e:	f022                	sd	s0,32(sp)
    80003150:	ec26                	sd	s1,24(sp)
    80003152:	e84a                	sd	s2,16(sp)
    80003154:	e44e                	sd	s3,8(sp)
    80003156:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003158:	00004597          	auipc	a1,0x4
    8000315c:	38858593          	addi	a1,a1,904 # 800074e0 <etext+0x4e0>
    80003160:	0001e517          	auipc	a0,0x1e
    80003164:	53050513          	addi	a0,a0,1328 # 80021690 <itable>
    80003168:	a13fd0ef          	jal	80000b7a <initlock>
  for(i = 0; i < NINODE; i++) {
    8000316c:	0001e497          	auipc	s1,0x1e
    80003170:	54c48493          	addi	s1,s1,1356 # 800216b8 <itable+0x28>
    80003174:	00020997          	auipc	s3,0x20
    80003178:	fd498993          	addi	s3,s3,-44 # 80023148 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000317c:	00004917          	auipc	s2,0x4
    80003180:	36c90913          	addi	s2,s2,876 # 800074e8 <etext+0x4e8>
    80003184:	85ca                	mv	a1,s2
    80003186:	8526                	mv	a0,s1
    80003188:	497000ef          	jal	80003e1e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000318c:	08848493          	addi	s1,s1,136
    80003190:	ff349ae3          	bne	s1,s3,80003184 <iinit+0x3a>
}
    80003194:	70a2                	ld	ra,40(sp)
    80003196:	7402                	ld	s0,32(sp)
    80003198:	64e2                	ld	s1,24(sp)
    8000319a:	6942                	ld	s2,16(sp)
    8000319c:	69a2                	ld	s3,8(sp)
    8000319e:	6145                	addi	sp,sp,48
    800031a0:	8082                	ret

00000000800031a2 <ialloc>:
{
    800031a2:	7139                	addi	sp,sp,-64
    800031a4:	fc06                	sd	ra,56(sp)
    800031a6:	f822                	sd	s0,48(sp)
    800031a8:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800031aa:	0001e717          	auipc	a4,0x1e
    800031ae:	4d272703          	lw	a4,1234(a4) # 8002167c <sb+0xc>
    800031b2:	4785                	li	a5,1
    800031b4:	06e7f063          	bgeu	a5,a4,80003214 <ialloc+0x72>
    800031b8:	f426                	sd	s1,40(sp)
    800031ba:	f04a                	sd	s2,32(sp)
    800031bc:	ec4e                	sd	s3,24(sp)
    800031be:	e852                	sd	s4,16(sp)
    800031c0:	e456                	sd	s5,8(sp)
    800031c2:	e05a                	sd	s6,0(sp)
    800031c4:	8aaa                	mv	s5,a0
    800031c6:	8b2e                	mv	s6,a1
    800031c8:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800031ca:	0001ea17          	auipc	s4,0x1e
    800031ce:	4a6a0a13          	addi	s4,s4,1190 # 80021670 <sb>
    800031d2:	00495593          	srli	a1,s2,0x4
    800031d6:	018a2783          	lw	a5,24(s4)
    800031da:	9dbd                	addw	a1,a1,a5
    800031dc:	8556                	mv	a0,s5
    800031de:	a23ff0ef          	jal	80002c00 <bread>
    800031e2:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031e4:	05850993          	addi	s3,a0,88
    800031e8:	00f97793          	andi	a5,s2,15
    800031ec:	079a                	slli	a5,a5,0x6
    800031ee:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800031f0:	00099783          	lh	a5,0(s3)
    800031f4:	cb9d                	beqz	a5,8000322a <ialloc+0x88>
    brelse(bp);
    800031f6:	b13ff0ef          	jal	80002d08 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031fa:	0905                	addi	s2,s2,1
    800031fc:	00ca2703          	lw	a4,12(s4)
    80003200:	0009079b          	sext.w	a5,s2
    80003204:	fce7e7e3          	bltu	a5,a4,800031d2 <ialloc+0x30>
    80003208:	74a2                	ld	s1,40(sp)
    8000320a:	7902                	ld	s2,32(sp)
    8000320c:	69e2                	ld	s3,24(sp)
    8000320e:	6a42                	ld	s4,16(sp)
    80003210:	6aa2                	ld	s5,8(sp)
    80003212:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003214:	00004517          	auipc	a0,0x4
    80003218:	2dc50513          	addi	a0,a0,732 # 800074f0 <etext+0x4f0>
    8000321c:	ab2fd0ef          	jal	800004ce <printf>
  return 0;
    80003220:	4501                	li	a0,0
}
    80003222:	70e2                	ld	ra,56(sp)
    80003224:	7442                	ld	s0,48(sp)
    80003226:	6121                	addi	sp,sp,64
    80003228:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000322a:	04000613          	li	a2,64
    8000322e:	4581                	li	a1,0
    80003230:	854e                	mv	a0,s3
    80003232:	a9dfd0ef          	jal	80000cce <memset>
      dip->type = type;
    80003236:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000323a:	8526                	mv	a0,s1
    8000323c:	313000ef          	jal	80003d4e <log_write>
      brelse(bp);
    80003240:	8526                	mv	a0,s1
    80003242:	ac7ff0ef          	jal	80002d08 <brelse>
      return iget(dev, inum);
    80003246:	0009059b          	sext.w	a1,s2
    8000324a:	8556                	mv	a0,s5
    8000324c:	de7ff0ef          	jal	80003032 <iget>
    80003250:	74a2                	ld	s1,40(sp)
    80003252:	7902                	ld	s2,32(sp)
    80003254:	69e2                	ld	s3,24(sp)
    80003256:	6a42                	ld	s4,16(sp)
    80003258:	6aa2                	ld	s5,8(sp)
    8000325a:	6b02                	ld	s6,0(sp)
    8000325c:	b7d9                	j	80003222 <ialloc+0x80>

000000008000325e <iupdate>:
{
    8000325e:	1101                	addi	sp,sp,-32
    80003260:	ec06                	sd	ra,24(sp)
    80003262:	e822                	sd	s0,16(sp)
    80003264:	e426                	sd	s1,8(sp)
    80003266:	e04a                	sd	s2,0(sp)
    80003268:	1000                	addi	s0,sp,32
    8000326a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000326c:	415c                	lw	a5,4(a0)
    8000326e:	0047d79b          	srliw	a5,a5,0x4
    80003272:	0001e597          	auipc	a1,0x1e
    80003276:	4165a583          	lw	a1,1046(a1) # 80021688 <sb+0x18>
    8000327a:	9dbd                	addw	a1,a1,a5
    8000327c:	4108                	lw	a0,0(a0)
    8000327e:	983ff0ef          	jal	80002c00 <bread>
    80003282:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003284:	05850793          	addi	a5,a0,88
    80003288:	40d8                	lw	a4,4(s1)
    8000328a:	8b3d                	andi	a4,a4,15
    8000328c:	071a                	slli	a4,a4,0x6
    8000328e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003290:	04449703          	lh	a4,68(s1)
    80003294:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003298:	04649703          	lh	a4,70(s1)
    8000329c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800032a0:	04849703          	lh	a4,72(s1)
    800032a4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800032a8:	04a49703          	lh	a4,74(s1)
    800032ac:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800032b0:	44f8                	lw	a4,76(s1)
    800032b2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800032b4:	03400613          	li	a2,52
    800032b8:	05048593          	addi	a1,s1,80
    800032bc:	00c78513          	addi	a0,a5,12
    800032c0:	a73fd0ef          	jal	80000d32 <memmove>
  log_write(bp);
    800032c4:	854a                	mv	a0,s2
    800032c6:	289000ef          	jal	80003d4e <log_write>
  brelse(bp);
    800032ca:	854a                	mv	a0,s2
    800032cc:	a3dff0ef          	jal	80002d08 <brelse>
}
    800032d0:	60e2                	ld	ra,24(sp)
    800032d2:	6442                	ld	s0,16(sp)
    800032d4:	64a2                	ld	s1,8(sp)
    800032d6:	6902                	ld	s2,0(sp)
    800032d8:	6105                	addi	sp,sp,32
    800032da:	8082                	ret

00000000800032dc <idup>:
{
    800032dc:	1101                	addi	sp,sp,-32
    800032de:	ec06                	sd	ra,24(sp)
    800032e0:	e822                	sd	s0,16(sp)
    800032e2:	e426                	sd	s1,8(sp)
    800032e4:	1000                	addi	s0,sp,32
    800032e6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032e8:	0001e517          	auipc	a0,0x1e
    800032ec:	3a850513          	addi	a0,a0,936 # 80021690 <itable>
    800032f0:	90ffd0ef          	jal	80000bfe <acquire>
  ip->ref++;
    800032f4:	449c                	lw	a5,8(s1)
    800032f6:	2785                	addiw	a5,a5,1
    800032f8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032fa:	0001e517          	auipc	a0,0x1e
    800032fe:	39650513          	addi	a0,a0,918 # 80021690 <itable>
    80003302:	991fd0ef          	jal	80000c92 <release>
}
    80003306:	8526                	mv	a0,s1
    80003308:	60e2                	ld	ra,24(sp)
    8000330a:	6442                	ld	s0,16(sp)
    8000330c:	64a2                	ld	s1,8(sp)
    8000330e:	6105                	addi	sp,sp,32
    80003310:	8082                	ret

0000000080003312 <ilock>:
{
    80003312:	1101                	addi	sp,sp,-32
    80003314:	ec06                	sd	ra,24(sp)
    80003316:	e822                	sd	s0,16(sp)
    80003318:	e426                	sd	s1,8(sp)
    8000331a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000331c:	cd19                	beqz	a0,8000333a <ilock+0x28>
    8000331e:	84aa                	mv	s1,a0
    80003320:	451c                	lw	a5,8(a0)
    80003322:	00f05c63          	blez	a5,8000333a <ilock+0x28>
  acquiresleep(&ip->lock);
    80003326:	0541                	addi	a0,a0,16
    80003328:	32d000ef          	jal	80003e54 <acquiresleep>
  if(ip->valid == 0){
    8000332c:	40bc                	lw	a5,64(s1)
    8000332e:	cf89                	beqz	a5,80003348 <ilock+0x36>
}
    80003330:	60e2                	ld	ra,24(sp)
    80003332:	6442                	ld	s0,16(sp)
    80003334:	64a2                	ld	s1,8(sp)
    80003336:	6105                	addi	sp,sp,32
    80003338:	8082                	ret
    8000333a:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000333c:	00004517          	auipc	a0,0x4
    80003340:	1cc50513          	addi	a0,a0,460 # 80007508 <etext+0x508>
    80003344:	c5afd0ef          	jal	8000079e <panic>
    80003348:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000334a:	40dc                	lw	a5,4(s1)
    8000334c:	0047d79b          	srliw	a5,a5,0x4
    80003350:	0001e597          	auipc	a1,0x1e
    80003354:	3385a583          	lw	a1,824(a1) # 80021688 <sb+0x18>
    80003358:	9dbd                	addw	a1,a1,a5
    8000335a:	4088                	lw	a0,0(s1)
    8000335c:	8a5ff0ef          	jal	80002c00 <bread>
    80003360:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003362:	05850593          	addi	a1,a0,88
    80003366:	40dc                	lw	a5,4(s1)
    80003368:	8bbd                	andi	a5,a5,15
    8000336a:	079a                	slli	a5,a5,0x6
    8000336c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000336e:	00059783          	lh	a5,0(a1)
    80003372:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003376:	00259783          	lh	a5,2(a1)
    8000337a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000337e:	00459783          	lh	a5,4(a1)
    80003382:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003386:	00659783          	lh	a5,6(a1)
    8000338a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000338e:	459c                	lw	a5,8(a1)
    80003390:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003392:	03400613          	li	a2,52
    80003396:	05b1                	addi	a1,a1,12
    80003398:	05048513          	addi	a0,s1,80
    8000339c:	997fd0ef          	jal	80000d32 <memmove>
    brelse(bp);
    800033a0:	854a                	mv	a0,s2
    800033a2:	967ff0ef          	jal	80002d08 <brelse>
    ip->valid = 1;
    800033a6:	4785                	li	a5,1
    800033a8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800033aa:	04449783          	lh	a5,68(s1)
    800033ae:	c399                	beqz	a5,800033b4 <ilock+0xa2>
    800033b0:	6902                	ld	s2,0(sp)
    800033b2:	bfbd                	j	80003330 <ilock+0x1e>
      panic("ilock: no type");
    800033b4:	00004517          	auipc	a0,0x4
    800033b8:	15c50513          	addi	a0,a0,348 # 80007510 <etext+0x510>
    800033bc:	be2fd0ef          	jal	8000079e <panic>

00000000800033c0 <iunlock>:
{
    800033c0:	1101                	addi	sp,sp,-32
    800033c2:	ec06                	sd	ra,24(sp)
    800033c4:	e822                	sd	s0,16(sp)
    800033c6:	e426                	sd	s1,8(sp)
    800033c8:	e04a                	sd	s2,0(sp)
    800033ca:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800033cc:	c505                	beqz	a0,800033f4 <iunlock+0x34>
    800033ce:	84aa                	mv	s1,a0
    800033d0:	01050913          	addi	s2,a0,16
    800033d4:	854a                	mv	a0,s2
    800033d6:	2fd000ef          	jal	80003ed2 <holdingsleep>
    800033da:	cd09                	beqz	a0,800033f4 <iunlock+0x34>
    800033dc:	449c                	lw	a5,8(s1)
    800033de:	00f05b63          	blez	a5,800033f4 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033e2:	854a                	mv	a0,s2
    800033e4:	2b7000ef          	jal	80003e9a <releasesleep>
}
    800033e8:	60e2                	ld	ra,24(sp)
    800033ea:	6442                	ld	s0,16(sp)
    800033ec:	64a2                	ld	s1,8(sp)
    800033ee:	6902                	ld	s2,0(sp)
    800033f0:	6105                	addi	sp,sp,32
    800033f2:	8082                	ret
    panic("iunlock");
    800033f4:	00004517          	auipc	a0,0x4
    800033f8:	12c50513          	addi	a0,a0,300 # 80007520 <etext+0x520>
    800033fc:	ba2fd0ef          	jal	8000079e <panic>

0000000080003400 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003400:	7179                	addi	sp,sp,-48
    80003402:	f406                	sd	ra,40(sp)
    80003404:	f022                	sd	s0,32(sp)
    80003406:	ec26                	sd	s1,24(sp)
    80003408:	e84a                	sd	s2,16(sp)
    8000340a:	e44e                	sd	s3,8(sp)
    8000340c:	1800                	addi	s0,sp,48
    8000340e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003410:	05050493          	addi	s1,a0,80
    80003414:	08050913          	addi	s2,a0,128
    80003418:	a021                	j	80003420 <itrunc+0x20>
    8000341a:	0491                	addi	s1,s1,4
    8000341c:	01248b63          	beq	s1,s2,80003432 <itrunc+0x32>
    if(ip->addrs[i]){
    80003420:	408c                	lw	a1,0(s1)
    80003422:	dde5                	beqz	a1,8000341a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003424:	0009a503          	lw	a0,0(s3)
    80003428:	9cdff0ef          	jal	80002df4 <bfree>
      ip->addrs[i] = 0;
    8000342c:	0004a023          	sw	zero,0(s1)
    80003430:	b7ed                	j	8000341a <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003432:	0809a583          	lw	a1,128(s3)
    80003436:	ed89                	bnez	a1,80003450 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003438:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000343c:	854e                	mv	a0,s3
    8000343e:	e21ff0ef          	jal	8000325e <iupdate>
}
    80003442:	70a2                	ld	ra,40(sp)
    80003444:	7402                	ld	s0,32(sp)
    80003446:	64e2                	ld	s1,24(sp)
    80003448:	6942                	ld	s2,16(sp)
    8000344a:	69a2                	ld	s3,8(sp)
    8000344c:	6145                	addi	sp,sp,48
    8000344e:	8082                	ret
    80003450:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003452:	0009a503          	lw	a0,0(s3)
    80003456:	faaff0ef          	jal	80002c00 <bread>
    8000345a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000345c:	05850493          	addi	s1,a0,88
    80003460:	45850913          	addi	s2,a0,1112
    80003464:	a021                	j	8000346c <itrunc+0x6c>
    80003466:	0491                	addi	s1,s1,4
    80003468:	01248963          	beq	s1,s2,8000347a <itrunc+0x7a>
      if(a[j])
    8000346c:	408c                	lw	a1,0(s1)
    8000346e:	dde5                	beqz	a1,80003466 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003470:	0009a503          	lw	a0,0(s3)
    80003474:	981ff0ef          	jal	80002df4 <bfree>
    80003478:	b7fd                	j	80003466 <itrunc+0x66>
    brelse(bp);
    8000347a:	8552                	mv	a0,s4
    8000347c:	88dff0ef          	jal	80002d08 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003480:	0809a583          	lw	a1,128(s3)
    80003484:	0009a503          	lw	a0,0(s3)
    80003488:	96dff0ef          	jal	80002df4 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000348c:	0809a023          	sw	zero,128(s3)
    80003490:	6a02                	ld	s4,0(sp)
    80003492:	b75d                	j	80003438 <itrunc+0x38>

0000000080003494 <iput>:
{
    80003494:	1101                	addi	sp,sp,-32
    80003496:	ec06                	sd	ra,24(sp)
    80003498:	e822                	sd	s0,16(sp)
    8000349a:	e426                	sd	s1,8(sp)
    8000349c:	1000                	addi	s0,sp,32
    8000349e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034a0:	0001e517          	auipc	a0,0x1e
    800034a4:	1f050513          	addi	a0,a0,496 # 80021690 <itable>
    800034a8:	f56fd0ef          	jal	80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034ac:	4498                	lw	a4,8(s1)
    800034ae:	4785                	li	a5,1
    800034b0:	02f70063          	beq	a4,a5,800034d0 <iput+0x3c>
  ip->ref--;
    800034b4:	449c                	lw	a5,8(s1)
    800034b6:	37fd                	addiw	a5,a5,-1
    800034b8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034ba:	0001e517          	auipc	a0,0x1e
    800034be:	1d650513          	addi	a0,a0,470 # 80021690 <itable>
    800034c2:	fd0fd0ef          	jal	80000c92 <release>
}
    800034c6:	60e2                	ld	ra,24(sp)
    800034c8:	6442                	ld	s0,16(sp)
    800034ca:	64a2                	ld	s1,8(sp)
    800034cc:	6105                	addi	sp,sp,32
    800034ce:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034d0:	40bc                	lw	a5,64(s1)
    800034d2:	d3ed                	beqz	a5,800034b4 <iput+0x20>
    800034d4:	04a49783          	lh	a5,74(s1)
    800034d8:	fff1                	bnez	a5,800034b4 <iput+0x20>
    800034da:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800034dc:	01048913          	addi	s2,s1,16
    800034e0:	854a                	mv	a0,s2
    800034e2:	173000ef          	jal	80003e54 <acquiresleep>
    release(&itable.lock);
    800034e6:	0001e517          	auipc	a0,0x1e
    800034ea:	1aa50513          	addi	a0,a0,426 # 80021690 <itable>
    800034ee:	fa4fd0ef          	jal	80000c92 <release>
    itrunc(ip);
    800034f2:	8526                	mv	a0,s1
    800034f4:	f0dff0ef          	jal	80003400 <itrunc>
    ip->type = 0;
    800034f8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034fc:	8526                	mv	a0,s1
    800034fe:	d61ff0ef          	jal	8000325e <iupdate>
    ip->valid = 0;
    80003502:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003506:	854a                	mv	a0,s2
    80003508:	193000ef          	jal	80003e9a <releasesleep>
    acquire(&itable.lock);
    8000350c:	0001e517          	auipc	a0,0x1e
    80003510:	18450513          	addi	a0,a0,388 # 80021690 <itable>
    80003514:	eeafd0ef          	jal	80000bfe <acquire>
    80003518:	6902                	ld	s2,0(sp)
    8000351a:	bf69                	j	800034b4 <iput+0x20>

000000008000351c <iunlockput>:
{
    8000351c:	1101                	addi	sp,sp,-32
    8000351e:	ec06                	sd	ra,24(sp)
    80003520:	e822                	sd	s0,16(sp)
    80003522:	e426                	sd	s1,8(sp)
    80003524:	1000                	addi	s0,sp,32
    80003526:	84aa                	mv	s1,a0
  iunlock(ip);
    80003528:	e99ff0ef          	jal	800033c0 <iunlock>
  iput(ip);
    8000352c:	8526                	mv	a0,s1
    8000352e:	f67ff0ef          	jal	80003494 <iput>
}
    80003532:	60e2                	ld	ra,24(sp)
    80003534:	6442                	ld	s0,16(sp)
    80003536:	64a2                	ld	s1,8(sp)
    80003538:	6105                	addi	sp,sp,32
    8000353a:	8082                	ret

000000008000353c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000353c:	1141                	addi	sp,sp,-16
    8000353e:	e406                	sd	ra,8(sp)
    80003540:	e022                	sd	s0,0(sp)
    80003542:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003544:	411c                	lw	a5,0(a0)
    80003546:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003548:	415c                	lw	a5,4(a0)
    8000354a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000354c:	04451783          	lh	a5,68(a0)
    80003550:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003554:	04a51783          	lh	a5,74(a0)
    80003558:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000355c:	04c56783          	lwu	a5,76(a0)
    80003560:	e99c                	sd	a5,16(a1)
}
    80003562:	60a2                	ld	ra,8(sp)
    80003564:	6402                	ld	s0,0(sp)
    80003566:	0141                	addi	sp,sp,16
    80003568:	8082                	ret

000000008000356a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000356a:	457c                	lw	a5,76(a0)
    8000356c:	0ed7e663          	bltu	a5,a3,80003658 <readi+0xee>
{
    80003570:	7159                	addi	sp,sp,-112
    80003572:	f486                	sd	ra,104(sp)
    80003574:	f0a2                	sd	s0,96(sp)
    80003576:	eca6                	sd	s1,88(sp)
    80003578:	e0d2                	sd	s4,64(sp)
    8000357a:	fc56                	sd	s5,56(sp)
    8000357c:	f85a                	sd	s6,48(sp)
    8000357e:	f45e                	sd	s7,40(sp)
    80003580:	1880                	addi	s0,sp,112
    80003582:	8b2a                	mv	s6,a0
    80003584:	8bae                	mv	s7,a1
    80003586:	8a32                	mv	s4,a2
    80003588:	84b6                	mv	s1,a3
    8000358a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000358c:	9f35                	addw	a4,a4,a3
    return 0;
    8000358e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003590:	0ad76b63          	bltu	a4,a3,80003646 <readi+0xdc>
    80003594:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003596:	00e7f463          	bgeu	a5,a4,8000359e <readi+0x34>
    n = ip->size - off;
    8000359a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000359e:	080a8b63          	beqz	s5,80003634 <readi+0xca>
    800035a2:	e8ca                	sd	s2,80(sp)
    800035a4:	f062                	sd	s8,32(sp)
    800035a6:	ec66                	sd	s9,24(sp)
    800035a8:	e86a                	sd	s10,16(sp)
    800035aa:	e46e                	sd	s11,8(sp)
    800035ac:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035ae:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800035b2:	5c7d                	li	s8,-1
    800035b4:	a80d                	j	800035e6 <readi+0x7c>
    800035b6:	020d1d93          	slli	s11,s10,0x20
    800035ba:	020ddd93          	srli	s11,s11,0x20
    800035be:	05890613          	addi	a2,s2,88
    800035c2:	86ee                	mv	a3,s11
    800035c4:	963e                	add	a2,a2,a5
    800035c6:	85d2                	mv	a1,s4
    800035c8:	855e                	mv	a0,s7
    800035ca:	c43fe0ef          	jal	8000220c <either_copyout>
    800035ce:	05850363          	beq	a0,s8,80003614 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800035d2:	854a                	mv	a0,s2
    800035d4:	f34ff0ef          	jal	80002d08 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035d8:	013d09bb          	addw	s3,s10,s3
    800035dc:	009d04bb          	addw	s1,s10,s1
    800035e0:	9a6e                	add	s4,s4,s11
    800035e2:	0559f363          	bgeu	s3,s5,80003628 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800035e6:	00a4d59b          	srliw	a1,s1,0xa
    800035ea:	855a                	mv	a0,s6
    800035ec:	987ff0ef          	jal	80002f72 <bmap>
    800035f0:	85aa                	mv	a1,a0
    if(addr == 0)
    800035f2:	c139                	beqz	a0,80003638 <readi+0xce>
    bp = bread(ip->dev, addr);
    800035f4:	000b2503          	lw	a0,0(s6)
    800035f8:	e08ff0ef          	jal	80002c00 <bread>
    800035fc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035fe:	3ff4f793          	andi	a5,s1,1023
    80003602:	40fc873b          	subw	a4,s9,a5
    80003606:	413a86bb          	subw	a3,s5,s3
    8000360a:	8d3a                	mv	s10,a4
    8000360c:	fae6f5e3          	bgeu	a3,a4,800035b6 <readi+0x4c>
    80003610:	8d36                	mv	s10,a3
    80003612:	b755                	j	800035b6 <readi+0x4c>
      brelse(bp);
    80003614:	854a                	mv	a0,s2
    80003616:	ef2ff0ef          	jal	80002d08 <brelse>
      tot = -1;
    8000361a:	59fd                	li	s3,-1
      break;
    8000361c:	6946                	ld	s2,80(sp)
    8000361e:	7c02                	ld	s8,32(sp)
    80003620:	6ce2                	ld	s9,24(sp)
    80003622:	6d42                	ld	s10,16(sp)
    80003624:	6da2                	ld	s11,8(sp)
    80003626:	a831                	j	80003642 <readi+0xd8>
    80003628:	6946                	ld	s2,80(sp)
    8000362a:	7c02                	ld	s8,32(sp)
    8000362c:	6ce2                	ld	s9,24(sp)
    8000362e:	6d42                	ld	s10,16(sp)
    80003630:	6da2                	ld	s11,8(sp)
    80003632:	a801                	j	80003642 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003634:	89d6                	mv	s3,s5
    80003636:	a031                	j	80003642 <readi+0xd8>
    80003638:	6946                	ld	s2,80(sp)
    8000363a:	7c02                	ld	s8,32(sp)
    8000363c:	6ce2                	ld	s9,24(sp)
    8000363e:	6d42                	ld	s10,16(sp)
    80003640:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003642:	854e                	mv	a0,s3
    80003644:	69a6                	ld	s3,72(sp)
}
    80003646:	70a6                	ld	ra,104(sp)
    80003648:	7406                	ld	s0,96(sp)
    8000364a:	64e6                	ld	s1,88(sp)
    8000364c:	6a06                	ld	s4,64(sp)
    8000364e:	7ae2                	ld	s5,56(sp)
    80003650:	7b42                	ld	s6,48(sp)
    80003652:	7ba2                	ld	s7,40(sp)
    80003654:	6165                	addi	sp,sp,112
    80003656:	8082                	ret
    return 0;
    80003658:	4501                	li	a0,0
}
    8000365a:	8082                	ret

000000008000365c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000365c:	457c                	lw	a5,76(a0)
    8000365e:	0ed7eb63          	bltu	a5,a3,80003754 <writei+0xf8>
{
    80003662:	7159                	addi	sp,sp,-112
    80003664:	f486                	sd	ra,104(sp)
    80003666:	f0a2                	sd	s0,96(sp)
    80003668:	e8ca                	sd	s2,80(sp)
    8000366a:	e0d2                	sd	s4,64(sp)
    8000366c:	fc56                	sd	s5,56(sp)
    8000366e:	f85a                	sd	s6,48(sp)
    80003670:	f45e                	sd	s7,40(sp)
    80003672:	1880                	addi	s0,sp,112
    80003674:	8aaa                	mv	s5,a0
    80003676:	8bae                	mv	s7,a1
    80003678:	8a32                	mv	s4,a2
    8000367a:	8936                	mv	s2,a3
    8000367c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000367e:	00e687bb          	addw	a5,a3,a4
    80003682:	0cd7eb63          	bltu	a5,a3,80003758 <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003686:	00043737          	lui	a4,0x43
    8000368a:	0cf76963          	bltu	a4,a5,8000375c <writei+0x100>
    8000368e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003690:	0a0b0a63          	beqz	s6,80003744 <writei+0xe8>
    80003694:	eca6                	sd	s1,88(sp)
    80003696:	f062                	sd	s8,32(sp)
    80003698:	ec66                	sd	s9,24(sp)
    8000369a:	e86a                	sd	s10,16(sp)
    8000369c:	e46e                	sd	s11,8(sp)
    8000369e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036a0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800036a4:	5c7d                	li	s8,-1
    800036a6:	a825                	j	800036de <writei+0x82>
    800036a8:	020d1d93          	slli	s11,s10,0x20
    800036ac:	020ddd93          	srli	s11,s11,0x20
    800036b0:	05848513          	addi	a0,s1,88
    800036b4:	86ee                	mv	a3,s11
    800036b6:	8652                	mv	a2,s4
    800036b8:	85de                	mv	a1,s7
    800036ba:	953e                	add	a0,a0,a5
    800036bc:	b9bfe0ef          	jal	80002256 <either_copyin>
    800036c0:	05850663          	beq	a0,s8,8000370c <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800036c4:	8526                	mv	a0,s1
    800036c6:	688000ef          	jal	80003d4e <log_write>
    brelse(bp);
    800036ca:	8526                	mv	a0,s1
    800036cc:	e3cff0ef          	jal	80002d08 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036d0:	013d09bb          	addw	s3,s10,s3
    800036d4:	012d093b          	addw	s2,s10,s2
    800036d8:	9a6e                	add	s4,s4,s11
    800036da:	0369fc63          	bgeu	s3,s6,80003712 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800036de:	00a9559b          	srliw	a1,s2,0xa
    800036e2:	8556                	mv	a0,s5
    800036e4:	88fff0ef          	jal	80002f72 <bmap>
    800036e8:	85aa                	mv	a1,a0
    if(addr == 0)
    800036ea:	c505                	beqz	a0,80003712 <writei+0xb6>
    bp = bread(ip->dev, addr);
    800036ec:	000aa503          	lw	a0,0(s5)
    800036f0:	d10ff0ef          	jal	80002c00 <bread>
    800036f4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036f6:	3ff97793          	andi	a5,s2,1023
    800036fa:	40fc873b          	subw	a4,s9,a5
    800036fe:	413b06bb          	subw	a3,s6,s3
    80003702:	8d3a                	mv	s10,a4
    80003704:	fae6f2e3          	bgeu	a3,a4,800036a8 <writei+0x4c>
    80003708:	8d36                	mv	s10,a3
    8000370a:	bf79                	j	800036a8 <writei+0x4c>
      brelse(bp);
    8000370c:	8526                	mv	a0,s1
    8000370e:	dfaff0ef          	jal	80002d08 <brelse>
  }

  if(off > ip->size)
    80003712:	04caa783          	lw	a5,76(s5)
    80003716:	0327f963          	bgeu	a5,s2,80003748 <writei+0xec>
    ip->size = off;
    8000371a:	052aa623          	sw	s2,76(s5)
    8000371e:	64e6                	ld	s1,88(sp)
    80003720:	7c02                	ld	s8,32(sp)
    80003722:	6ce2                	ld	s9,24(sp)
    80003724:	6d42                	ld	s10,16(sp)
    80003726:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003728:	8556                	mv	a0,s5
    8000372a:	b35ff0ef          	jal	8000325e <iupdate>

  return tot;
    8000372e:	854e                	mv	a0,s3
    80003730:	69a6                	ld	s3,72(sp)
}
    80003732:	70a6                	ld	ra,104(sp)
    80003734:	7406                	ld	s0,96(sp)
    80003736:	6946                	ld	s2,80(sp)
    80003738:	6a06                	ld	s4,64(sp)
    8000373a:	7ae2                	ld	s5,56(sp)
    8000373c:	7b42                	ld	s6,48(sp)
    8000373e:	7ba2                	ld	s7,40(sp)
    80003740:	6165                	addi	sp,sp,112
    80003742:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003744:	89da                	mv	s3,s6
    80003746:	b7cd                	j	80003728 <writei+0xcc>
    80003748:	64e6                	ld	s1,88(sp)
    8000374a:	7c02                	ld	s8,32(sp)
    8000374c:	6ce2                	ld	s9,24(sp)
    8000374e:	6d42                	ld	s10,16(sp)
    80003750:	6da2                	ld	s11,8(sp)
    80003752:	bfd9                	j	80003728 <writei+0xcc>
    return -1;
    80003754:	557d                	li	a0,-1
}
    80003756:	8082                	ret
    return -1;
    80003758:	557d                	li	a0,-1
    8000375a:	bfe1                	j	80003732 <writei+0xd6>
    return -1;
    8000375c:	557d                	li	a0,-1
    8000375e:	bfd1                	j	80003732 <writei+0xd6>

0000000080003760 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003760:	1141                	addi	sp,sp,-16
    80003762:	e406                	sd	ra,8(sp)
    80003764:	e022                	sd	s0,0(sp)
    80003766:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003768:	4639                	li	a2,14
    8000376a:	e3cfd0ef          	jal	80000da6 <strncmp>
}
    8000376e:	60a2                	ld	ra,8(sp)
    80003770:	6402                	ld	s0,0(sp)
    80003772:	0141                	addi	sp,sp,16
    80003774:	8082                	ret

0000000080003776 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003776:	711d                	addi	sp,sp,-96
    80003778:	ec86                	sd	ra,88(sp)
    8000377a:	e8a2                	sd	s0,80(sp)
    8000377c:	e4a6                	sd	s1,72(sp)
    8000377e:	e0ca                	sd	s2,64(sp)
    80003780:	fc4e                	sd	s3,56(sp)
    80003782:	f852                	sd	s4,48(sp)
    80003784:	f456                	sd	s5,40(sp)
    80003786:	f05a                	sd	s6,32(sp)
    80003788:	ec5e                	sd	s7,24(sp)
    8000378a:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000378c:	04451703          	lh	a4,68(a0)
    80003790:	4785                	li	a5,1
    80003792:	00f71f63          	bne	a4,a5,800037b0 <dirlookup+0x3a>
    80003796:	892a                	mv	s2,a0
    80003798:	8aae                	mv	s5,a1
    8000379a:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000379c:	457c                	lw	a5,76(a0)
    8000379e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037a0:	fa040a13          	addi	s4,s0,-96
    800037a4:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800037a6:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800037aa:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037ac:	e39d                	bnez	a5,800037d2 <dirlookup+0x5c>
    800037ae:	a8b9                	j	8000380c <dirlookup+0x96>
    panic("dirlookup not DIR");
    800037b0:	00004517          	auipc	a0,0x4
    800037b4:	d7850513          	addi	a0,a0,-648 # 80007528 <etext+0x528>
    800037b8:	fe7fc0ef          	jal	8000079e <panic>
      panic("dirlookup read");
    800037bc:	00004517          	auipc	a0,0x4
    800037c0:	d8450513          	addi	a0,a0,-636 # 80007540 <etext+0x540>
    800037c4:	fdbfc0ef          	jal	8000079e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037c8:	24c1                	addiw	s1,s1,16
    800037ca:	04c92783          	lw	a5,76(s2)
    800037ce:	02f4fe63          	bgeu	s1,a5,8000380a <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037d2:	874e                	mv	a4,s3
    800037d4:	86a6                	mv	a3,s1
    800037d6:	8652                	mv	a2,s4
    800037d8:	4581                	li	a1,0
    800037da:	854a                	mv	a0,s2
    800037dc:	d8fff0ef          	jal	8000356a <readi>
    800037e0:	fd351ee3          	bne	a0,s3,800037bc <dirlookup+0x46>
    if(de.inum == 0)
    800037e4:	fa045783          	lhu	a5,-96(s0)
    800037e8:	d3e5                	beqz	a5,800037c8 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800037ea:	85da                	mv	a1,s6
    800037ec:	8556                	mv	a0,s5
    800037ee:	f73ff0ef          	jal	80003760 <namecmp>
    800037f2:	f979                	bnez	a0,800037c8 <dirlookup+0x52>
      if(poff)
    800037f4:	000b8463          	beqz	s7,800037fc <dirlookup+0x86>
        *poff = off;
    800037f8:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800037fc:	fa045583          	lhu	a1,-96(s0)
    80003800:	00092503          	lw	a0,0(s2)
    80003804:	82fff0ef          	jal	80003032 <iget>
    80003808:	a011                	j	8000380c <dirlookup+0x96>
  return 0;
    8000380a:	4501                	li	a0,0
}
    8000380c:	60e6                	ld	ra,88(sp)
    8000380e:	6446                	ld	s0,80(sp)
    80003810:	64a6                	ld	s1,72(sp)
    80003812:	6906                	ld	s2,64(sp)
    80003814:	79e2                	ld	s3,56(sp)
    80003816:	7a42                	ld	s4,48(sp)
    80003818:	7aa2                	ld	s5,40(sp)
    8000381a:	7b02                	ld	s6,32(sp)
    8000381c:	6be2                	ld	s7,24(sp)
    8000381e:	6125                	addi	sp,sp,96
    80003820:	8082                	ret

0000000080003822 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003822:	711d                	addi	sp,sp,-96
    80003824:	ec86                	sd	ra,88(sp)
    80003826:	e8a2                	sd	s0,80(sp)
    80003828:	e4a6                	sd	s1,72(sp)
    8000382a:	e0ca                	sd	s2,64(sp)
    8000382c:	fc4e                	sd	s3,56(sp)
    8000382e:	f852                	sd	s4,48(sp)
    80003830:	f456                	sd	s5,40(sp)
    80003832:	f05a                	sd	s6,32(sp)
    80003834:	ec5e                	sd	s7,24(sp)
    80003836:	e862                	sd	s8,16(sp)
    80003838:	e466                	sd	s9,8(sp)
    8000383a:	e06a                	sd	s10,0(sp)
    8000383c:	1080                	addi	s0,sp,96
    8000383e:	84aa                	mv	s1,a0
    80003840:	8b2e                	mv	s6,a1
    80003842:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003844:	00054703          	lbu	a4,0(a0)
    80003848:	02f00793          	li	a5,47
    8000384c:	00f70f63          	beq	a4,a5,8000386a <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003850:	880fe0ef          	jal	800018d0 <myproc>
    80003854:	15053503          	ld	a0,336(a0)
    80003858:	a85ff0ef          	jal	800032dc <idup>
    8000385c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000385e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003862:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003864:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003866:	4b85                	li	s7,1
    80003868:	a879                	j	80003906 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000386a:	4585                	li	a1,1
    8000386c:	852e                	mv	a0,a1
    8000386e:	fc4ff0ef          	jal	80003032 <iget>
    80003872:	8a2a                	mv	s4,a0
    80003874:	b7ed                	j	8000385e <namex+0x3c>
      iunlockput(ip);
    80003876:	8552                	mv	a0,s4
    80003878:	ca5ff0ef          	jal	8000351c <iunlockput>
      return 0;
    8000387c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000387e:	8552                	mv	a0,s4
    80003880:	60e6                	ld	ra,88(sp)
    80003882:	6446                	ld	s0,80(sp)
    80003884:	64a6                	ld	s1,72(sp)
    80003886:	6906                	ld	s2,64(sp)
    80003888:	79e2                	ld	s3,56(sp)
    8000388a:	7a42                	ld	s4,48(sp)
    8000388c:	7aa2                	ld	s5,40(sp)
    8000388e:	7b02                	ld	s6,32(sp)
    80003890:	6be2                	ld	s7,24(sp)
    80003892:	6c42                	ld	s8,16(sp)
    80003894:	6ca2                	ld	s9,8(sp)
    80003896:	6d02                	ld	s10,0(sp)
    80003898:	6125                	addi	sp,sp,96
    8000389a:	8082                	ret
      iunlock(ip);
    8000389c:	8552                	mv	a0,s4
    8000389e:	b23ff0ef          	jal	800033c0 <iunlock>
      return ip;
    800038a2:	bff1                	j	8000387e <namex+0x5c>
      iunlockput(ip);
    800038a4:	8552                	mv	a0,s4
    800038a6:	c77ff0ef          	jal	8000351c <iunlockput>
      return 0;
    800038aa:	8a4e                	mv	s4,s3
    800038ac:	bfc9                	j	8000387e <namex+0x5c>
  len = path - s;
    800038ae:	40998633          	sub	a2,s3,s1
    800038b2:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800038b6:	09ac5063          	bge	s8,s10,80003936 <namex+0x114>
    memmove(name, s, DIRSIZ);
    800038ba:	8666                	mv	a2,s9
    800038bc:	85a6                	mv	a1,s1
    800038be:	8556                	mv	a0,s5
    800038c0:	c72fd0ef          	jal	80000d32 <memmove>
    800038c4:	84ce                	mv	s1,s3
  while(*path == '/')
    800038c6:	0004c783          	lbu	a5,0(s1)
    800038ca:	01279763          	bne	a5,s2,800038d8 <namex+0xb6>
    path++;
    800038ce:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038d0:	0004c783          	lbu	a5,0(s1)
    800038d4:	ff278de3          	beq	a5,s2,800038ce <namex+0xac>
    ilock(ip);
    800038d8:	8552                	mv	a0,s4
    800038da:	a39ff0ef          	jal	80003312 <ilock>
    if(ip->type != T_DIR){
    800038de:	044a1783          	lh	a5,68(s4)
    800038e2:	f9779ae3          	bne	a5,s7,80003876 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800038e6:	000b0563          	beqz	s6,800038f0 <namex+0xce>
    800038ea:	0004c783          	lbu	a5,0(s1)
    800038ee:	d7dd                	beqz	a5,8000389c <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800038f0:	4601                	li	a2,0
    800038f2:	85d6                	mv	a1,s5
    800038f4:	8552                	mv	a0,s4
    800038f6:	e81ff0ef          	jal	80003776 <dirlookup>
    800038fa:	89aa                	mv	s3,a0
    800038fc:	d545                	beqz	a0,800038a4 <namex+0x82>
    iunlockput(ip);
    800038fe:	8552                	mv	a0,s4
    80003900:	c1dff0ef          	jal	8000351c <iunlockput>
    ip = next;
    80003904:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003906:	0004c783          	lbu	a5,0(s1)
    8000390a:	01279763          	bne	a5,s2,80003918 <namex+0xf6>
    path++;
    8000390e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003910:	0004c783          	lbu	a5,0(s1)
    80003914:	ff278de3          	beq	a5,s2,8000390e <namex+0xec>
  if(*path == 0)
    80003918:	cb8d                	beqz	a5,8000394a <namex+0x128>
  while(*path != '/' && *path != 0)
    8000391a:	0004c783          	lbu	a5,0(s1)
    8000391e:	89a6                	mv	s3,s1
  len = path - s;
    80003920:	4d01                	li	s10,0
    80003922:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003924:	01278963          	beq	a5,s2,80003936 <namex+0x114>
    80003928:	d3d9                	beqz	a5,800038ae <namex+0x8c>
    path++;
    8000392a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000392c:	0009c783          	lbu	a5,0(s3)
    80003930:	ff279ce3          	bne	a5,s2,80003928 <namex+0x106>
    80003934:	bfad                	j	800038ae <namex+0x8c>
    memmove(name, s, len);
    80003936:	2601                	sext.w	a2,a2
    80003938:	85a6                	mv	a1,s1
    8000393a:	8556                	mv	a0,s5
    8000393c:	bf6fd0ef          	jal	80000d32 <memmove>
    name[len] = 0;
    80003940:	9d56                	add	s10,s10,s5
    80003942:	000d0023          	sb	zero,0(s10)
    80003946:	84ce                	mv	s1,s3
    80003948:	bfbd                	j	800038c6 <namex+0xa4>
  if(nameiparent){
    8000394a:	f20b0ae3          	beqz	s6,8000387e <namex+0x5c>
    iput(ip);
    8000394e:	8552                	mv	a0,s4
    80003950:	b45ff0ef          	jal	80003494 <iput>
    return 0;
    80003954:	4a01                	li	s4,0
    80003956:	b725                	j	8000387e <namex+0x5c>

0000000080003958 <dirlink>:
{
    80003958:	715d                	addi	sp,sp,-80
    8000395a:	e486                	sd	ra,72(sp)
    8000395c:	e0a2                	sd	s0,64(sp)
    8000395e:	f84a                	sd	s2,48(sp)
    80003960:	ec56                	sd	s5,24(sp)
    80003962:	e85a                	sd	s6,16(sp)
    80003964:	0880                	addi	s0,sp,80
    80003966:	892a                	mv	s2,a0
    80003968:	8aae                	mv	s5,a1
    8000396a:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000396c:	4601                	li	a2,0
    8000396e:	e09ff0ef          	jal	80003776 <dirlookup>
    80003972:	ed1d                	bnez	a0,800039b0 <dirlink+0x58>
    80003974:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003976:	04c92483          	lw	s1,76(s2)
    8000397a:	c4b9                	beqz	s1,800039c8 <dirlink+0x70>
    8000397c:	f44e                	sd	s3,40(sp)
    8000397e:	f052                	sd	s4,32(sp)
    80003980:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003982:	fb040a13          	addi	s4,s0,-80
    80003986:	49c1                	li	s3,16
    80003988:	874e                	mv	a4,s3
    8000398a:	86a6                	mv	a3,s1
    8000398c:	8652                	mv	a2,s4
    8000398e:	4581                	li	a1,0
    80003990:	854a                	mv	a0,s2
    80003992:	bd9ff0ef          	jal	8000356a <readi>
    80003996:	03351163          	bne	a0,s3,800039b8 <dirlink+0x60>
    if(de.inum == 0)
    8000399a:	fb045783          	lhu	a5,-80(s0)
    8000399e:	c39d                	beqz	a5,800039c4 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039a0:	24c1                	addiw	s1,s1,16
    800039a2:	04c92783          	lw	a5,76(s2)
    800039a6:	fef4e1e3          	bltu	s1,a5,80003988 <dirlink+0x30>
    800039aa:	79a2                	ld	s3,40(sp)
    800039ac:	7a02                	ld	s4,32(sp)
    800039ae:	a829                	j	800039c8 <dirlink+0x70>
    iput(ip);
    800039b0:	ae5ff0ef          	jal	80003494 <iput>
    return -1;
    800039b4:	557d                	li	a0,-1
    800039b6:	a83d                	j	800039f4 <dirlink+0x9c>
      panic("dirlink read");
    800039b8:	00004517          	auipc	a0,0x4
    800039bc:	b9850513          	addi	a0,a0,-1128 # 80007550 <etext+0x550>
    800039c0:	ddffc0ef          	jal	8000079e <panic>
    800039c4:	79a2                	ld	s3,40(sp)
    800039c6:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    800039c8:	4639                	li	a2,14
    800039ca:	85d6                	mv	a1,s5
    800039cc:	fb240513          	addi	a0,s0,-78
    800039d0:	c10fd0ef          	jal	80000de0 <strncpy>
  de.inum = inum;
    800039d4:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039d8:	4741                	li	a4,16
    800039da:	86a6                	mv	a3,s1
    800039dc:	fb040613          	addi	a2,s0,-80
    800039e0:	4581                	li	a1,0
    800039e2:	854a                	mv	a0,s2
    800039e4:	c79ff0ef          	jal	8000365c <writei>
    800039e8:	1541                	addi	a0,a0,-16
    800039ea:	00a03533          	snez	a0,a0
    800039ee:	40a0053b          	negw	a0,a0
    800039f2:	74e2                	ld	s1,56(sp)
}
    800039f4:	60a6                	ld	ra,72(sp)
    800039f6:	6406                	ld	s0,64(sp)
    800039f8:	7942                	ld	s2,48(sp)
    800039fa:	6ae2                	ld	s5,24(sp)
    800039fc:	6b42                	ld	s6,16(sp)
    800039fe:	6161                	addi	sp,sp,80
    80003a00:	8082                	ret

0000000080003a02 <namei>:

struct inode*
namei(char *path)
{
    80003a02:	1101                	addi	sp,sp,-32
    80003a04:	ec06                	sd	ra,24(sp)
    80003a06:	e822                	sd	s0,16(sp)
    80003a08:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a0a:	fe040613          	addi	a2,s0,-32
    80003a0e:	4581                	li	a1,0
    80003a10:	e13ff0ef          	jal	80003822 <namex>
}
    80003a14:	60e2                	ld	ra,24(sp)
    80003a16:	6442                	ld	s0,16(sp)
    80003a18:	6105                	addi	sp,sp,32
    80003a1a:	8082                	ret

0000000080003a1c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003a1c:	1141                	addi	sp,sp,-16
    80003a1e:	e406                	sd	ra,8(sp)
    80003a20:	e022                	sd	s0,0(sp)
    80003a22:	0800                	addi	s0,sp,16
    80003a24:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a26:	4585                	li	a1,1
    80003a28:	dfbff0ef          	jal	80003822 <namex>
}
    80003a2c:	60a2                	ld	ra,8(sp)
    80003a2e:	6402                	ld	s0,0(sp)
    80003a30:	0141                	addi	sp,sp,16
    80003a32:	8082                	ret

0000000080003a34 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a34:	1101                	addi	sp,sp,-32
    80003a36:	ec06                	sd	ra,24(sp)
    80003a38:	e822                	sd	s0,16(sp)
    80003a3a:	e426                	sd	s1,8(sp)
    80003a3c:	e04a                	sd	s2,0(sp)
    80003a3e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a40:	0001f917          	auipc	s2,0x1f
    80003a44:	6f890913          	addi	s2,s2,1784 # 80023138 <log>
    80003a48:	01892583          	lw	a1,24(s2)
    80003a4c:	02892503          	lw	a0,40(s2)
    80003a50:	9b0ff0ef          	jal	80002c00 <bread>
    80003a54:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a56:	02c92603          	lw	a2,44(s2)
    80003a5a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a5c:	00c05f63          	blez	a2,80003a7a <write_head+0x46>
    80003a60:	0001f717          	auipc	a4,0x1f
    80003a64:	70870713          	addi	a4,a4,1800 # 80023168 <log+0x30>
    80003a68:	87aa                	mv	a5,a0
    80003a6a:	060a                	slli	a2,a2,0x2
    80003a6c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a6e:	4314                	lw	a3,0(a4)
    80003a70:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a72:	0711                	addi	a4,a4,4
    80003a74:	0791                	addi	a5,a5,4
    80003a76:	fec79ce3          	bne	a5,a2,80003a6e <write_head+0x3a>
  }
  bwrite(buf);
    80003a7a:	8526                	mv	a0,s1
    80003a7c:	a5aff0ef          	jal	80002cd6 <bwrite>
  brelse(buf);
    80003a80:	8526                	mv	a0,s1
    80003a82:	a86ff0ef          	jal	80002d08 <brelse>
}
    80003a86:	60e2                	ld	ra,24(sp)
    80003a88:	6442                	ld	s0,16(sp)
    80003a8a:	64a2                	ld	s1,8(sp)
    80003a8c:	6902                	ld	s2,0(sp)
    80003a8e:	6105                	addi	sp,sp,32
    80003a90:	8082                	ret

0000000080003a92 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a92:	0001f797          	auipc	a5,0x1f
    80003a96:	6d27a783          	lw	a5,1746(a5) # 80023164 <log+0x2c>
    80003a9a:	0af05263          	blez	a5,80003b3e <install_trans+0xac>
{
    80003a9e:	715d                	addi	sp,sp,-80
    80003aa0:	e486                	sd	ra,72(sp)
    80003aa2:	e0a2                	sd	s0,64(sp)
    80003aa4:	fc26                	sd	s1,56(sp)
    80003aa6:	f84a                	sd	s2,48(sp)
    80003aa8:	f44e                	sd	s3,40(sp)
    80003aaa:	f052                	sd	s4,32(sp)
    80003aac:	ec56                	sd	s5,24(sp)
    80003aae:	e85a                	sd	s6,16(sp)
    80003ab0:	e45e                	sd	s7,8(sp)
    80003ab2:	0880                	addi	s0,sp,80
    80003ab4:	8b2a                	mv	s6,a0
    80003ab6:	0001fa97          	auipc	s5,0x1f
    80003aba:	6b2a8a93          	addi	s5,s5,1714 # 80023168 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003abe:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ac0:	0001f997          	auipc	s3,0x1f
    80003ac4:	67898993          	addi	s3,s3,1656 # 80023138 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ac8:	40000b93          	li	s7,1024
    80003acc:	a829                	j	80003ae6 <install_trans+0x54>
    brelse(lbuf);
    80003ace:	854a                	mv	a0,s2
    80003ad0:	a38ff0ef          	jal	80002d08 <brelse>
    brelse(dbuf);
    80003ad4:	8526                	mv	a0,s1
    80003ad6:	a32ff0ef          	jal	80002d08 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ada:	2a05                	addiw	s4,s4,1
    80003adc:	0a91                	addi	s5,s5,4
    80003ade:	02c9a783          	lw	a5,44(s3)
    80003ae2:	04fa5363          	bge	s4,a5,80003b28 <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ae6:	0189a583          	lw	a1,24(s3)
    80003aea:	014585bb          	addw	a1,a1,s4
    80003aee:	2585                	addiw	a1,a1,1
    80003af0:	0289a503          	lw	a0,40(s3)
    80003af4:	90cff0ef          	jal	80002c00 <bread>
    80003af8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003afa:	000aa583          	lw	a1,0(s5)
    80003afe:	0289a503          	lw	a0,40(s3)
    80003b02:	8feff0ef          	jal	80002c00 <bread>
    80003b06:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b08:	865e                	mv	a2,s7
    80003b0a:	05890593          	addi	a1,s2,88
    80003b0e:	05850513          	addi	a0,a0,88
    80003b12:	a20fd0ef          	jal	80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003b16:	8526                	mv	a0,s1
    80003b18:	9beff0ef          	jal	80002cd6 <bwrite>
    if(recovering == 0)
    80003b1c:	fa0b19e3          	bnez	s6,80003ace <install_trans+0x3c>
      bunpin(dbuf);
    80003b20:	8526                	mv	a0,s1
    80003b22:	a9eff0ef          	jal	80002dc0 <bunpin>
    80003b26:	b765                	j	80003ace <install_trans+0x3c>
}
    80003b28:	60a6                	ld	ra,72(sp)
    80003b2a:	6406                	ld	s0,64(sp)
    80003b2c:	74e2                	ld	s1,56(sp)
    80003b2e:	7942                	ld	s2,48(sp)
    80003b30:	79a2                	ld	s3,40(sp)
    80003b32:	7a02                	ld	s4,32(sp)
    80003b34:	6ae2                	ld	s5,24(sp)
    80003b36:	6b42                	ld	s6,16(sp)
    80003b38:	6ba2                	ld	s7,8(sp)
    80003b3a:	6161                	addi	sp,sp,80
    80003b3c:	8082                	ret
    80003b3e:	8082                	ret

0000000080003b40 <initlog>:
{
    80003b40:	7179                	addi	sp,sp,-48
    80003b42:	f406                	sd	ra,40(sp)
    80003b44:	f022                	sd	s0,32(sp)
    80003b46:	ec26                	sd	s1,24(sp)
    80003b48:	e84a                	sd	s2,16(sp)
    80003b4a:	e44e                	sd	s3,8(sp)
    80003b4c:	1800                	addi	s0,sp,48
    80003b4e:	892a                	mv	s2,a0
    80003b50:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b52:	0001f497          	auipc	s1,0x1f
    80003b56:	5e648493          	addi	s1,s1,1510 # 80023138 <log>
    80003b5a:	00004597          	auipc	a1,0x4
    80003b5e:	a0658593          	addi	a1,a1,-1530 # 80007560 <etext+0x560>
    80003b62:	8526                	mv	a0,s1
    80003b64:	816fd0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    80003b68:	0149a583          	lw	a1,20(s3)
    80003b6c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003b6e:	0109a783          	lw	a5,16(s3)
    80003b72:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003b74:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003b78:	854a                	mv	a0,s2
    80003b7a:	886ff0ef          	jal	80002c00 <bread>
  log.lh.n = lh->n;
    80003b7e:	4d30                	lw	a2,88(a0)
    80003b80:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003b82:	00c05f63          	blez	a2,80003ba0 <initlog+0x60>
    80003b86:	87aa                	mv	a5,a0
    80003b88:	0001f717          	auipc	a4,0x1f
    80003b8c:	5e070713          	addi	a4,a4,1504 # 80023168 <log+0x30>
    80003b90:	060a                	slli	a2,a2,0x2
    80003b92:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b94:	4ff4                	lw	a3,92(a5)
    80003b96:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b98:	0791                	addi	a5,a5,4
    80003b9a:	0711                	addi	a4,a4,4
    80003b9c:	fec79ce3          	bne	a5,a2,80003b94 <initlog+0x54>
  brelse(buf);
    80003ba0:	968ff0ef          	jal	80002d08 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ba4:	4505                	li	a0,1
    80003ba6:	eedff0ef          	jal	80003a92 <install_trans>
  log.lh.n = 0;
    80003baa:	0001f797          	auipc	a5,0x1f
    80003bae:	5a07ad23          	sw	zero,1466(a5) # 80023164 <log+0x2c>
  write_head(); // clear the log
    80003bb2:	e83ff0ef          	jal	80003a34 <write_head>
}
    80003bb6:	70a2                	ld	ra,40(sp)
    80003bb8:	7402                	ld	s0,32(sp)
    80003bba:	64e2                	ld	s1,24(sp)
    80003bbc:	6942                	ld	s2,16(sp)
    80003bbe:	69a2                	ld	s3,8(sp)
    80003bc0:	6145                	addi	sp,sp,48
    80003bc2:	8082                	ret

0000000080003bc4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003bc4:	1101                	addi	sp,sp,-32
    80003bc6:	ec06                	sd	ra,24(sp)
    80003bc8:	e822                	sd	s0,16(sp)
    80003bca:	e426                	sd	s1,8(sp)
    80003bcc:	e04a                	sd	s2,0(sp)
    80003bce:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003bd0:	0001f517          	auipc	a0,0x1f
    80003bd4:	56850513          	addi	a0,a0,1384 # 80023138 <log>
    80003bd8:	826fd0ef          	jal	80000bfe <acquire>
  while(1){
    if(log.committing){
    80003bdc:	0001f497          	auipc	s1,0x1f
    80003be0:	55c48493          	addi	s1,s1,1372 # 80023138 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003be4:	4979                	li	s2,30
    80003be6:	a029                	j	80003bf0 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003be8:	85a6                	mv	a1,s1
    80003bea:	8526                	mv	a0,s1
    80003bec:	acafe0ef          	jal	80001eb6 <sleep>
    if(log.committing){
    80003bf0:	50dc                	lw	a5,36(s1)
    80003bf2:	fbfd                	bnez	a5,80003be8 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003bf4:	5098                	lw	a4,32(s1)
    80003bf6:	2705                	addiw	a4,a4,1
    80003bf8:	0027179b          	slliw	a5,a4,0x2
    80003bfc:	9fb9                	addw	a5,a5,a4
    80003bfe:	0017979b          	slliw	a5,a5,0x1
    80003c02:	54d4                	lw	a3,44(s1)
    80003c04:	9fb5                	addw	a5,a5,a3
    80003c06:	00f95763          	bge	s2,a5,80003c14 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003c0a:	85a6                	mv	a1,s1
    80003c0c:	8526                	mv	a0,s1
    80003c0e:	aa8fe0ef          	jal	80001eb6 <sleep>
    80003c12:	bff9                	j	80003bf0 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c14:	0001f517          	auipc	a0,0x1f
    80003c18:	52450513          	addi	a0,a0,1316 # 80023138 <log>
    80003c1c:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003c1e:	874fd0ef          	jal	80000c92 <release>
      break;
    }
  }
}
    80003c22:	60e2                	ld	ra,24(sp)
    80003c24:	6442                	ld	s0,16(sp)
    80003c26:	64a2                	ld	s1,8(sp)
    80003c28:	6902                	ld	s2,0(sp)
    80003c2a:	6105                	addi	sp,sp,32
    80003c2c:	8082                	ret

0000000080003c2e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c2e:	7139                	addi	sp,sp,-64
    80003c30:	fc06                	sd	ra,56(sp)
    80003c32:	f822                	sd	s0,48(sp)
    80003c34:	f426                	sd	s1,40(sp)
    80003c36:	f04a                	sd	s2,32(sp)
    80003c38:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c3a:	0001f497          	auipc	s1,0x1f
    80003c3e:	4fe48493          	addi	s1,s1,1278 # 80023138 <log>
    80003c42:	8526                	mv	a0,s1
    80003c44:	fbbfc0ef          	jal	80000bfe <acquire>
  log.outstanding -= 1;
    80003c48:	509c                	lw	a5,32(s1)
    80003c4a:	37fd                	addiw	a5,a5,-1
    80003c4c:	893e                	mv	s2,a5
    80003c4e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003c50:	50dc                	lw	a5,36(s1)
    80003c52:	ef9d                	bnez	a5,80003c90 <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c54:	04091863          	bnez	s2,80003ca4 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003c58:	0001f497          	auipc	s1,0x1f
    80003c5c:	4e048493          	addi	s1,s1,1248 # 80023138 <log>
    80003c60:	4785                	li	a5,1
    80003c62:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c64:	8526                	mv	a0,s1
    80003c66:	82cfd0ef          	jal	80000c92 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c6a:	54dc                	lw	a5,44(s1)
    80003c6c:	04f04c63          	bgtz	a5,80003cc4 <end_op+0x96>
    acquire(&log.lock);
    80003c70:	0001f497          	auipc	s1,0x1f
    80003c74:	4c848493          	addi	s1,s1,1224 # 80023138 <log>
    80003c78:	8526                	mv	a0,s1
    80003c7a:	f85fc0ef          	jal	80000bfe <acquire>
    log.committing = 0;
    80003c7e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003c82:	8526                	mv	a0,s1
    80003c84:	a7efe0ef          	jal	80001f02 <wakeup>
    release(&log.lock);
    80003c88:	8526                	mv	a0,s1
    80003c8a:	808fd0ef          	jal	80000c92 <release>
}
    80003c8e:	a02d                	j	80003cb8 <end_op+0x8a>
    80003c90:	ec4e                	sd	s3,24(sp)
    80003c92:	e852                	sd	s4,16(sp)
    80003c94:	e456                	sd	s5,8(sp)
    80003c96:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003c98:	00004517          	auipc	a0,0x4
    80003c9c:	8d050513          	addi	a0,a0,-1840 # 80007568 <etext+0x568>
    80003ca0:	afffc0ef          	jal	8000079e <panic>
    wakeup(&log);
    80003ca4:	0001f497          	auipc	s1,0x1f
    80003ca8:	49448493          	addi	s1,s1,1172 # 80023138 <log>
    80003cac:	8526                	mv	a0,s1
    80003cae:	a54fe0ef          	jal	80001f02 <wakeup>
  release(&log.lock);
    80003cb2:	8526                	mv	a0,s1
    80003cb4:	fdffc0ef          	jal	80000c92 <release>
}
    80003cb8:	70e2                	ld	ra,56(sp)
    80003cba:	7442                	ld	s0,48(sp)
    80003cbc:	74a2                	ld	s1,40(sp)
    80003cbe:	7902                	ld	s2,32(sp)
    80003cc0:	6121                	addi	sp,sp,64
    80003cc2:	8082                	ret
    80003cc4:	ec4e                	sd	s3,24(sp)
    80003cc6:	e852                	sd	s4,16(sp)
    80003cc8:	e456                	sd	s5,8(sp)
    80003cca:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ccc:	0001fa97          	auipc	s5,0x1f
    80003cd0:	49ca8a93          	addi	s5,s5,1180 # 80023168 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003cd4:	0001fa17          	auipc	s4,0x1f
    80003cd8:	464a0a13          	addi	s4,s4,1124 # 80023138 <log>
    memmove(to->data, from->data, BSIZE);
    80003cdc:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003ce0:	018a2583          	lw	a1,24(s4)
    80003ce4:	012585bb          	addw	a1,a1,s2
    80003ce8:	2585                	addiw	a1,a1,1
    80003cea:	028a2503          	lw	a0,40(s4)
    80003cee:	f13fe0ef          	jal	80002c00 <bread>
    80003cf2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003cf4:	000aa583          	lw	a1,0(s5)
    80003cf8:	028a2503          	lw	a0,40(s4)
    80003cfc:	f05fe0ef          	jal	80002c00 <bread>
    80003d00:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003d02:	865a                	mv	a2,s6
    80003d04:	05850593          	addi	a1,a0,88
    80003d08:	05848513          	addi	a0,s1,88
    80003d0c:	826fd0ef          	jal	80000d32 <memmove>
    bwrite(to);  // write the log
    80003d10:	8526                	mv	a0,s1
    80003d12:	fc5fe0ef          	jal	80002cd6 <bwrite>
    brelse(from);
    80003d16:	854e                	mv	a0,s3
    80003d18:	ff1fe0ef          	jal	80002d08 <brelse>
    brelse(to);
    80003d1c:	8526                	mv	a0,s1
    80003d1e:	febfe0ef          	jal	80002d08 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d22:	2905                	addiw	s2,s2,1
    80003d24:	0a91                	addi	s5,s5,4
    80003d26:	02ca2783          	lw	a5,44(s4)
    80003d2a:	faf94be3          	blt	s2,a5,80003ce0 <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003d2e:	d07ff0ef          	jal	80003a34 <write_head>
    install_trans(0); // Now install writes to home locations
    80003d32:	4501                	li	a0,0
    80003d34:	d5fff0ef          	jal	80003a92 <install_trans>
    log.lh.n = 0;
    80003d38:	0001f797          	auipc	a5,0x1f
    80003d3c:	4207a623          	sw	zero,1068(a5) # 80023164 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003d40:	cf5ff0ef          	jal	80003a34 <write_head>
    80003d44:	69e2                	ld	s3,24(sp)
    80003d46:	6a42                	ld	s4,16(sp)
    80003d48:	6aa2                	ld	s5,8(sp)
    80003d4a:	6b02                	ld	s6,0(sp)
    80003d4c:	b715                	j	80003c70 <end_op+0x42>

0000000080003d4e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d4e:	1101                	addi	sp,sp,-32
    80003d50:	ec06                	sd	ra,24(sp)
    80003d52:	e822                	sd	s0,16(sp)
    80003d54:	e426                	sd	s1,8(sp)
    80003d56:	e04a                	sd	s2,0(sp)
    80003d58:	1000                	addi	s0,sp,32
    80003d5a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d5c:	0001f917          	auipc	s2,0x1f
    80003d60:	3dc90913          	addi	s2,s2,988 # 80023138 <log>
    80003d64:	854a                	mv	a0,s2
    80003d66:	e99fc0ef          	jal	80000bfe <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003d6a:	02c92603          	lw	a2,44(s2)
    80003d6e:	47f5                	li	a5,29
    80003d70:	06c7c363          	blt	a5,a2,80003dd6 <log_write+0x88>
    80003d74:	0001f797          	auipc	a5,0x1f
    80003d78:	3e07a783          	lw	a5,992(a5) # 80023154 <log+0x1c>
    80003d7c:	37fd                	addiw	a5,a5,-1
    80003d7e:	04f65c63          	bge	a2,a5,80003dd6 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d82:	0001f797          	auipc	a5,0x1f
    80003d86:	3d67a783          	lw	a5,982(a5) # 80023158 <log+0x20>
    80003d8a:	04f05c63          	blez	a5,80003de2 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d8e:	4781                	li	a5,0
    80003d90:	04c05f63          	blez	a2,80003dee <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d94:	44cc                	lw	a1,12(s1)
    80003d96:	0001f717          	auipc	a4,0x1f
    80003d9a:	3d270713          	addi	a4,a4,978 # 80023168 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d9e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003da0:	4314                	lw	a3,0(a4)
    80003da2:	04b68663          	beq	a3,a1,80003dee <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003da6:	2785                	addiw	a5,a5,1
    80003da8:	0711                	addi	a4,a4,4
    80003daa:	fef61be3          	bne	a2,a5,80003da0 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003dae:	0621                	addi	a2,a2,8
    80003db0:	060a                	slli	a2,a2,0x2
    80003db2:	0001f797          	auipc	a5,0x1f
    80003db6:	38678793          	addi	a5,a5,902 # 80023138 <log>
    80003dba:	97b2                	add	a5,a5,a2
    80003dbc:	44d8                	lw	a4,12(s1)
    80003dbe:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003dc0:	8526                	mv	a0,s1
    80003dc2:	fcbfe0ef          	jal	80002d8c <bpin>
    log.lh.n++;
    80003dc6:	0001f717          	auipc	a4,0x1f
    80003dca:	37270713          	addi	a4,a4,882 # 80023138 <log>
    80003dce:	575c                	lw	a5,44(a4)
    80003dd0:	2785                	addiw	a5,a5,1
    80003dd2:	d75c                	sw	a5,44(a4)
    80003dd4:	a80d                	j	80003e06 <log_write+0xb8>
    panic("too big a transaction");
    80003dd6:	00003517          	auipc	a0,0x3
    80003dda:	7a250513          	addi	a0,a0,1954 # 80007578 <etext+0x578>
    80003dde:	9c1fc0ef          	jal	8000079e <panic>
    panic("log_write outside of trans");
    80003de2:	00003517          	auipc	a0,0x3
    80003de6:	7ae50513          	addi	a0,a0,1966 # 80007590 <etext+0x590>
    80003dea:	9b5fc0ef          	jal	8000079e <panic>
  log.lh.block[i] = b->blockno;
    80003dee:	00878693          	addi	a3,a5,8
    80003df2:	068a                	slli	a3,a3,0x2
    80003df4:	0001f717          	auipc	a4,0x1f
    80003df8:	34470713          	addi	a4,a4,836 # 80023138 <log>
    80003dfc:	9736                	add	a4,a4,a3
    80003dfe:	44d4                	lw	a3,12(s1)
    80003e00:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003e02:	faf60fe3          	beq	a2,a5,80003dc0 <log_write+0x72>
  }
  release(&log.lock);
    80003e06:	0001f517          	auipc	a0,0x1f
    80003e0a:	33250513          	addi	a0,a0,818 # 80023138 <log>
    80003e0e:	e85fc0ef          	jal	80000c92 <release>
}
    80003e12:	60e2                	ld	ra,24(sp)
    80003e14:	6442                	ld	s0,16(sp)
    80003e16:	64a2                	ld	s1,8(sp)
    80003e18:	6902                	ld	s2,0(sp)
    80003e1a:	6105                	addi	sp,sp,32
    80003e1c:	8082                	ret

0000000080003e1e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e1e:	1101                	addi	sp,sp,-32
    80003e20:	ec06                	sd	ra,24(sp)
    80003e22:	e822                	sd	s0,16(sp)
    80003e24:	e426                	sd	s1,8(sp)
    80003e26:	e04a                	sd	s2,0(sp)
    80003e28:	1000                	addi	s0,sp,32
    80003e2a:	84aa                	mv	s1,a0
    80003e2c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e2e:	00003597          	auipc	a1,0x3
    80003e32:	78258593          	addi	a1,a1,1922 # 800075b0 <etext+0x5b0>
    80003e36:	0521                	addi	a0,a0,8
    80003e38:	d43fc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80003e3c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e40:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e44:	0204a423          	sw	zero,40(s1)
}
    80003e48:	60e2                	ld	ra,24(sp)
    80003e4a:	6442                	ld	s0,16(sp)
    80003e4c:	64a2                	ld	s1,8(sp)
    80003e4e:	6902                	ld	s2,0(sp)
    80003e50:	6105                	addi	sp,sp,32
    80003e52:	8082                	ret

0000000080003e54 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e54:	1101                	addi	sp,sp,-32
    80003e56:	ec06                	sd	ra,24(sp)
    80003e58:	e822                	sd	s0,16(sp)
    80003e5a:	e426                	sd	s1,8(sp)
    80003e5c:	e04a                	sd	s2,0(sp)
    80003e5e:	1000                	addi	s0,sp,32
    80003e60:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e62:	00850913          	addi	s2,a0,8
    80003e66:	854a                	mv	a0,s2
    80003e68:	d97fc0ef          	jal	80000bfe <acquire>
  while (lk->locked) {
    80003e6c:	409c                	lw	a5,0(s1)
    80003e6e:	c799                	beqz	a5,80003e7c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e70:	85ca                	mv	a1,s2
    80003e72:	8526                	mv	a0,s1
    80003e74:	842fe0ef          	jal	80001eb6 <sleep>
  while (lk->locked) {
    80003e78:	409c                	lw	a5,0(s1)
    80003e7a:	fbfd                	bnez	a5,80003e70 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003e7c:	4785                	li	a5,1
    80003e7e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003e80:	a51fd0ef          	jal	800018d0 <myproc>
    80003e84:	591c                	lw	a5,48(a0)
    80003e86:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003e88:	854a                	mv	a0,s2
    80003e8a:	e09fc0ef          	jal	80000c92 <release>
}
    80003e8e:	60e2                	ld	ra,24(sp)
    80003e90:	6442                	ld	s0,16(sp)
    80003e92:	64a2                	ld	s1,8(sp)
    80003e94:	6902                	ld	s2,0(sp)
    80003e96:	6105                	addi	sp,sp,32
    80003e98:	8082                	ret

0000000080003e9a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003e9a:	1101                	addi	sp,sp,-32
    80003e9c:	ec06                	sd	ra,24(sp)
    80003e9e:	e822                	sd	s0,16(sp)
    80003ea0:	e426                	sd	s1,8(sp)
    80003ea2:	e04a                	sd	s2,0(sp)
    80003ea4:	1000                	addi	s0,sp,32
    80003ea6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003ea8:	00850913          	addi	s2,a0,8
    80003eac:	854a                	mv	a0,s2
    80003eae:	d51fc0ef          	jal	80000bfe <acquire>
  lk->locked = 0;
    80003eb2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003eb6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003eba:	8526                	mv	a0,s1
    80003ebc:	846fe0ef          	jal	80001f02 <wakeup>
  release(&lk->lk);
    80003ec0:	854a                	mv	a0,s2
    80003ec2:	dd1fc0ef          	jal	80000c92 <release>
}
    80003ec6:	60e2                	ld	ra,24(sp)
    80003ec8:	6442                	ld	s0,16(sp)
    80003eca:	64a2                	ld	s1,8(sp)
    80003ecc:	6902                	ld	s2,0(sp)
    80003ece:	6105                	addi	sp,sp,32
    80003ed0:	8082                	ret

0000000080003ed2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003ed2:	7179                	addi	sp,sp,-48
    80003ed4:	f406                	sd	ra,40(sp)
    80003ed6:	f022                	sd	s0,32(sp)
    80003ed8:	ec26                	sd	s1,24(sp)
    80003eda:	e84a                	sd	s2,16(sp)
    80003edc:	1800                	addi	s0,sp,48
    80003ede:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003ee0:	00850913          	addi	s2,a0,8
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	d19fc0ef          	jal	80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003eea:	409c                	lw	a5,0(s1)
    80003eec:	ef81                	bnez	a5,80003f04 <holdingsleep+0x32>
    80003eee:	4481                	li	s1,0
  release(&lk->lk);
    80003ef0:	854a                	mv	a0,s2
    80003ef2:	da1fc0ef          	jal	80000c92 <release>
  return r;
}
    80003ef6:	8526                	mv	a0,s1
    80003ef8:	70a2                	ld	ra,40(sp)
    80003efa:	7402                	ld	s0,32(sp)
    80003efc:	64e2                	ld	s1,24(sp)
    80003efe:	6942                	ld	s2,16(sp)
    80003f00:	6145                	addi	sp,sp,48
    80003f02:	8082                	ret
    80003f04:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f06:	0284a983          	lw	s3,40(s1)
    80003f0a:	9c7fd0ef          	jal	800018d0 <myproc>
    80003f0e:	5904                	lw	s1,48(a0)
    80003f10:	413484b3          	sub	s1,s1,s3
    80003f14:	0014b493          	seqz	s1,s1
    80003f18:	69a2                	ld	s3,8(sp)
    80003f1a:	bfd9                	j	80003ef0 <holdingsleep+0x1e>

0000000080003f1c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f1c:	1141                	addi	sp,sp,-16
    80003f1e:	e406                	sd	ra,8(sp)
    80003f20:	e022                	sd	s0,0(sp)
    80003f22:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f24:	00003597          	auipc	a1,0x3
    80003f28:	69c58593          	addi	a1,a1,1692 # 800075c0 <etext+0x5c0>
    80003f2c:	0001f517          	auipc	a0,0x1f
    80003f30:	35450513          	addi	a0,a0,852 # 80023280 <ftable>
    80003f34:	c47fc0ef          	jal	80000b7a <initlock>
}
    80003f38:	60a2                	ld	ra,8(sp)
    80003f3a:	6402                	ld	s0,0(sp)
    80003f3c:	0141                	addi	sp,sp,16
    80003f3e:	8082                	ret

0000000080003f40 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003f40:	1101                	addi	sp,sp,-32
    80003f42:	ec06                	sd	ra,24(sp)
    80003f44:	e822                	sd	s0,16(sp)
    80003f46:	e426                	sd	s1,8(sp)
    80003f48:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f4a:	0001f517          	auipc	a0,0x1f
    80003f4e:	33650513          	addi	a0,a0,822 # 80023280 <ftable>
    80003f52:	cadfc0ef          	jal	80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f56:	0001f497          	auipc	s1,0x1f
    80003f5a:	34248493          	addi	s1,s1,834 # 80023298 <ftable+0x18>
    80003f5e:	00020717          	auipc	a4,0x20
    80003f62:	2da70713          	addi	a4,a4,730 # 80024238 <disk>
    if(f->ref == 0){
    80003f66:	40dc                	lw	a5,4(s1)
    80003f68:	cf89                	beqz	a5,80003f82 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f6a:	02848493          	addi	s1,s1,40
    80003f6e:	fee49ce3          	bne	s1,a4,80003f66 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f72:	0001f517          	auipc	a0,0x1f
    80003f76:	30e50513          	addi	a0,a0,782 # 80023280 <ftable>
    80003f7a:	d19fc0ef          	jal	80000c92 <release>
  return 0;
    80003f7e:	4481                	li	s1,0
    80003f80:	a809                	j	80003f92 <filealloc+0x52>
      f->ref = 1;
    80003f82:	4785                	li	a5,1
    80003f84:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003f86:	0001f517          	auipc	a0,0x1f
    80003f8a:	2fa50513          	addi	a0,a0,762 # 80023280 <ftable>
    80003f8e:	d05fc0ef          	jal	80000c92 <release>
}
    80003f92:	8526                	mv	a0,s1
    80003f94:	60e2                	ld	ra,24(sp)
    80003f96:	6442                	ld	s0,16(sp)
    80003f98:	64a2                	ld	s1,8(sp)
    80003f9a:	6105                	addi	sp,sp,32
    80003f9c:	8082                	ret

0000000080003f9e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003f9e:	1101                	addi	sp,sp,-32
    80003fa0:	ec06                	sd	ra,24(sp)
    80003fa2:	e822                	sd	s0,16(sp)
    80003fa4:	e426                	sd	s1,8(sp)
    80003fa6:	1000                	addi	s0,sp,32
    80003fa8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003faa:	0001f517          	auipc	a0,0x1f
    80003fae:	2d650513          	addi	a0,a0,726 # 80023280 <ftable>
    80003fb2:	c4dfc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003fb6:	40dc                	lw	a5,4(s1)
    80003fb8:	02f05063          	blez	a5,80003fd8 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003fbc:	2785                	addiw	a5,a5,1
    80003fbe:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003fc0:	0001f517          	auipc	a0,0x1f
    80003fc4:	2c050513          	addi	a0,a0,704 # 80023280 <ftable>
    80003fc8:	ccbfc0ef          	jal	80000c92 <release>
  return f;
}
    80003fcc:	8526                	mv	a0,s1
    80003fce:	60e2                	ld	ra,24(sp)
    80003fd0:	6442                	ld	s0,16(sp)
    80003fd2:	64a2                	ld	s1,8(sp)
    80003fd4:	6105                	addi	sp,sp,32
    80003fd6:	8082                	ret
    panic("filedup");
    80003fd8:	00003517          	auipc	a0,0x3
    80003fdc:	5f050513          	addi	a0,a0,1520 # 800075c8 <etext+0x5c8>
    80003fe0:	fbefc0ef          	jal	8000079e <panic>

0000000080003fe4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003fe4:	7139                	addi	sp,sp,-64
    80003fe6:	fc06                	sd	ra,56(sp)
    80003fe8:	f822                	sd	s0,48(sp)
    80003fea:	f426                	sd	s1,40(sp)
    80003fec:	0080                	addi	s0,sp,64
    80003fee:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003ff0:	0001f517          	auipc	a0,0x1f
    80003ff4:	29050513          	addi	a0,a0,656 # 80023280 <ftable>
    80003ff8:	c07fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003ffc:	40dc                	lw	a5,4(s1)
    80003ffe:	04f05863          	blez	a5,8000404e <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    80004002:	37fd                	addiw	a5,a5,-1
    80004004:	c0dc                	sw	a5,4(s1)
    80004006:	04f04e63          	bgtz	a5,80004062 <fileclose+0x7e>
    8000400a:	f04a                	sd	s2,32(sp)
    8000400c:	ec4e                	sd	s3,24(sp)
    8000400e:	e852                	sd	s4,16(sp)
    80004010:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004012:	0004a903          	lw	s2,0(s1)
    80004016:	0094ca83          	lbu	s5,9(s1)
    8000401a:	0104ba03          	ld	s4,16(s1)
    8000401e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004022:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004026:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000402a:	0001f517          	auipc	a0,0x1f
    8000402e:	25650513          	addi	a0,a0,598 # 80023280 <ftable>
    80004032:	c61fc0ef          	jal	80000c92 <release>

  if(ff.type == FD_PIPE){
    80004036:	4785                	li	a5,1
    80004038:	04f90063          	beq	s2,a5,80004078 <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000403c:	3979                	addiw	s2,s2,-2
    8000403e:	4785                	li	a5,1
    80004040:	0527f563          	bgeu	a5,s2,8000408a <fileclose+0xa6>
    80004044:	7902                	ld	s2,32(sp)
    80004046:	69e2                	ld	s3,24(sp)
    80004048:	6a42                	ld	s4,16(sp)
    8000404a:	6aa2                	ld	s5,8(sp)
    8000404c:	a00d                	j	8000406e <fileclose+0x8a>
    8000404e:	f04a                	sd	s2,32(sp)
    80004050:	ec4e                	sd	s3,24(sp)
    80004052:	e852                	sd	s4,16(sp)
    80004054:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004056:	00003517          	auipc	a0,0x3
    8000405a:	57a50513          	addi	a0,a0,1402 # 800075d0 <etext+0x5d0>
    8000405e:	f40fc0ef          	jal	8000079e <panic>
    release(&ftable.lock);
    80004062:	0001f517          	auipc	a0,0x1f
    80004066:	21e50513          	addi	a0,a0,542 # 80023280 <ftable>
    8000406a:	c29fc0ef          	jal	80000c92 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000406e:	70e2                	ld	ra,56(sp)
    80004070:	7442                	ld	s0,48(sp)
    80004072:	74a2                	ld	s1,40(sp)
    80004074:	6121                	addi	sp,sp,64
    80004076:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004078:	85d6                	mv	a1,s5
    8000407a:	8552                	mv	a0,s4
    8000407c:	340000ef          	jal	800043bc <pipeclose>
    80004080:	7902                	ld	s2,32(sp)
    80004082:	69e2                	ld	s3,24(sp)
    80004084:	6a42                	ld	s4,16(sp)
    80004086:	6aa2                	ld	s5,8(sp)
    80004088:	b7dd                	j	8000406e <fileclose+0x8a>
    begin_op();
    8000408a:	b3bff0ef          	jal	80003bc4 <begin_op>
    iput(ff.ip);
    8000408e:	854e                	mv	a0,s3
    80004090:	c04ff0ef          	jal	80003494 <iput>
    end_op();
    80004094:	b9bff0ef          	jal	80003c2e <end_op>
    80004098:	7902                	ld	s2,32(sp)
    8000409a:	69e2                	ld	s3,24(sp)
    8000409c:	6a42                	ld	s4,16(sp)
    8000409e:	6aa2                	ld	s5,8(sp)
    800040a0:	b7f9                	j	8000406e <fileclose+0x8a>

00000000800040a2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800040a2:	715d                	addi	sp,sp,-80
    800040a4:	e486                	sd	ra,72(sp)
    800040a6:	e0a2                	sd	s0,64(sp)
    800040a8:	fc26                	sd	s1,56(sp)
    800040aa:	f44e                	sd	s3,40(sp)
    800040ac:	0880                	addi	s0,sp,80
    800040ae:	84aa                	mv	s1,a0
    800040b0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800040b2:	81ffd0ef          	jal	800018d0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800040b6:	409c                	lw	a5,0(s1)
    800040b8:	37f9                	addiw	a5,a5,-2
    800040ba:	4705                	li	a4,1
    800040bc:	04f76263          	bltu	a4,a5,80004100 <filestat+0x5e>
    800040c0:	f84a                	sd	s2,48(sp)
    800040c2:	f052                	sd	s4,32(sp)
    800040c4:	892a                	mv	s2,a0
    ilock(f->ip);
    800040c6:	6c88                	ld	a0,24(s1)
    800040c8:	a4aff0ef          	jal	80003312 <ilock>
    stati(f->ip, &st);
    800040cc:	fb840a13          	addi	s4,s0,-72
    800040d0:	85d2                	mv	a1,s4
    800040d2:	6c88                	ld	a0,24(s1)
    800040d4:	c68ff0ef          	jal	8000353c <stati>
    iunlock(f->ip);
    800040d8:	6c88                	ld	a0,24(s1)
    800040da:	ae6ff0ef          	jal	800033c0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800040de:	46e1                	li	a3,24
    800040e0:	8652                	mv	a2,s4
    800040e2:	85ce                	mv	a1,s3
    800040e4:	05093503          	ld	a0,80(s2)
    800040e8:	c9cfd0ef          	jal	80001584 <copyout>
    800040ec:	41f5551b          	sraiw	a0,a0,0x1f
    800040f0:	7942                	ld	s2,48(sp)
    800040f2:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800040f4:	60a6                	ld	ra,72(sp)
    800040f6:	6406                	ld	s0,64(sp)
    800040f8:	74e2                	ld	s1,56(sp)
    800040fa:	79a2                	ld	s3,40(sp)
    800040fc:	6161                	addi	sp,sp,80
    800040fe:	8082                	ret
  return -1;
    80004100:	557d                	li	a0,-1
    80004102:	bfcd                	j	800040f4 <filestat+0x52>

0000000080004104 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004104:	7179                	addi	sp,sp,-48
    80004106:	f406                	sd	ra,40(sp)
    80004108:	f022                	sd	s0,32(sp)
    8000410a:	e84a                	sd	s2,16(sp)
    8000410c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000410e:	00854783          	lbu	a5,8(a0)
    80004112:	cfd1                	beqz	a5,800041ae <fileread+0xaa>
    80004114:	ec26                	sd	s1,24(sp)
    80004116:	e44e                	sd	s3,8(sp)
    80004118:	84aa                	mv	s1,a0
    8000411a:	89ae                	mv	s3,a1
    8000411c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000411e:	411c                	lw	a5,0(a0)
    80004120:	4705                	li	a4,1
    80004122:	04e78363          	beq	a5,a4,80004168 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004126:	470d                	li	a4,3
    80004128:	04e78763          	beq	a5,a4,80004176 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000412c:	4709                	li	a4,2
    8000412e:	06e79a63          	bne	a5,a4,800041a2 <fileread+0x9e>
    ilock(f->ip);
    80004132:	6d08                	ld	a0,24(a0)
    80004134:	9deff0ef          	jal	80003312 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004138:	874a                	mv	a4,s2
    8000413a:	5094                	lw	a3,32(s1)
    8000413c:	864e                	mv	a2,s3
    8000413e:	4585                	li	a1,1
    80004140:	6c88                	ld	a0,24(s1)
    80004142:	c28ff0ef          	jal	8000356a <readi>
    80004146:	892a                	mv	s2,a0
    80004148:	00a05563          	blez	a0,80004152 <fileread+0x4e>
      f->off += r;
    8000414c:	509c                	lw	a5,32(s1)
    8000414e:	9fa9                	addw	a5,a5,a0
    80004150:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004152:	6c88                	ld	a0,24(s1)
    80004154:	a6cff0ef          	jal	800033c0 <iunlock>
    80004158:	64e2                	ld	s1,24(sp)
    8000415a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000415c:	854a                	mv	a0,s2
    8000415e:	70a2                	ld	ra,40(sp)
    80004160:	7402                	ld	s0,32(sp)
    80004162:	6942                	ld	s2,16(sp)
    80004164:	6145                	addi	sp,sp,48
    80004166:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004168:	6908                	ld	a0,16(a0)
    8000416a:	3a2000ef          	jal	8000450c <piperead>
    8000416e:	892a                	mv	s2,a0
    80004170:	64e2                	ld	s1,24(sp)
    80004172:	69a2                	ld	s3,8(sp)
    80004174:	b7e5                	j	8000415c <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004176:	02451783          	lh	a5,36(a0)
    8000417a:	03079693          	slli	a3,a5,0x30
    8000417e:	92c1                	srli	a3,a3,0x30
    80004180:	4725                	li	a4,9
    80004182:	02d76863          	bltu	a4,a3,800041b2 <fileread+0xae>
    80004186:	0792                	slli	a5,a5,0x4
    80004188:	0001f717          	auipc	a4,0x1f
    8000418c:	05870713          	addi	a4,a4,88 # 800231e0 <devsw>
    80004190:	97ba                	add	a5,a5,a4
    80004192:	639c                	ld	a5,0(a5)
    80004194:	c39d                	beqz	a5,800041ba <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004196:	4505                	li	a0,1
    80004198:	9782                	jalr	a5
    8000419a:	892a                	mv	s2,a0
    8000419c:	64e2                	ld	s1,24(sp)
    8000419e:	69a2                	ld	s3,8(sp)
    800041a0:	bf75                	j	8000415c <fileread+0x58>
    panic("fileread");
    800041a2:	00003517          	auipc	a0,0x3
    800041a6:	43e50513          	addi	a0,a0,1086 # 800075e0 <etext+0x5e0>
    800041aa:	df4fc0ef          	jal	8000079e <panic>
    return -1;
    800041ae:	597d                	li	s2,-1
    800041b0:	b775                	j	8000415c <fileread+0x58>
      return -1;
    800041b2:	597d                	li	s2,-1
    800041b4:	64e2                	ld	s1,24(sp)
    800041b6:	69a2                	ld	s3,8(sp)
    800041b8:	b755                	j	8000415c <fileread+0x58>
    800041ba:	597d                	li	s2,-1
    800041bc:	64e2                	ld	s1,24(sp)
    800041be:	69a2                	ld	s3,8(sp)
    800041c0:	bf71                	j	8000415c <fileread+0x58>

00000000800041c2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800041c2:	00954783          	lbu	a5,9(a0)
    800041c6:	10078e63          	beqz	a5,800042e2 <filewrite+0x120>
{
    800041ca:	711d                	addi	sp,sp,-96
    800041cc:	ec86                	sd	ra,88(sp)
    800041ce:	e8a2                	sd	s0,80(sp)
    800041d0:	e0ca                	sd	s2,64(sp)
    800041d2:	f456                	sd	s5,40(sp)
    800041d4:	f05a                	sd	s6,32(sp)
    800041d6:	1080                	addi	s0,sp,96
    800041d8:	892a                	mv	s2,a0
    800041da:	8b2e                	mv	s6,a1
    800041dc:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800041de:	411c                	lw	a5,0(a0)
    800041e0:	4705                	li	a4,1
    800041e2:	02e78963          	beq	a5,a4,80004214 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041e6:	470d                	li	a4,3
    800041e8:	02e78a63          	beq	a5,a4,8000421c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800041ec:	4709                	li	a4,2
    800041ee:	0ce79e63          	bne	a5,a4,800042ca <filewrite+0x108>
    800041f2:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800041f4:	0ac05963          	blez	a2,800042a6 <filewrite+0xe4>
    800041f8:	e4a6                	sd	s1,72(sp)
    800041fa:	fc4e                	sd	s3,56(sp)
    800041fc:	ec5e                	sd	s7,24(sp)
    800041fe:	e862                	sd	s8,16(sp)
    80004200:	e466                	sd	s9,8(sp)
    int i = 0;
    80004202:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004204:	6b85                	lui	s7,0x1
    80004206:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000420a:	6c85                	lui	s9,0x1
    8000420c:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004210:	4c05                	li	s8,1
    80004212:	a8ad                	j	8000428c <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    80004214:	6908                	ld	a0,16(a0)
    80004216:	1fe000ef          	jal	80004414 <pipewrite>
    8000421a:	a04d                	j	800042bc <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000421c:	02451783          	lh	a5,36(a0)
    80004220:	03079693          	slli	a3,a5,0x30
    80004224:	92c1                	srli	a3,a3,0x30
    80004226:	4725                	li	a4,9
    80004228:	0ad76f63          	bltu	a4,a3,800042e6 <filewrite+0x124>
    8000422c:	0792                	slli	a5,a5,0x4
    8000422e:	0001f717          	auipc	a4,0x1f
    80004232:	fb270713          	addi	a4,a4,-78 # 800231e0 <devsw>
    80004236:	97ba                	add	a5,a5,a4
    80004238:	679c                	ld	a5,8(a5)
    8000423a:	cbc5                	beqz	a5,800042ea <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000423c:	4505                	li	a0,1
    8000423e:	9782                	jalr	a5
    80004240:	a8b5                	j	800042bc <filewrite+0xfa>
      if(n1 > max)
    80004242:	2981                	sext.w	s3,s3
      begin_op();
    80004244:	981ff0ef          	jal	80003bc4 <begin_op>
      ilock(f->ip);
    80004248:	01893503          	ld	a0,24(s2)
    8000424c:	8c6ff0ef          	jal	80003312 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004250:	874e                	mv	a4,s3
    80004252:	02092683          	lw	a3,32(s2)
    80004256:	016a0633          	add	a2,s4,s6
    8000425a:	85e2                	mv	a1,s8
    8000425c:	01893503          	ld	a0,24(s2)
    80004260:	bfcff0ef          	jal	8000365c <writei>
    80004264:	84aa                	mv	s1,a0
    80004266:	00a05763          	blez	a0,80004274 <filewrite+0xb2>
        f->off += r;
    8000426a:	02092783          	lw	a5,32(s2)
    8000426e:	9fa9                	addw	a5,a5,a0
    80004270:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004274:	01893503          	ld	a0,24(s2)
    80004278:	948ff0ef          	jal	800033c0 <iunlock>
      end_op();
    8000427c:	9b3ff0ef          	jal	80003c2e <end_op>

      if(r != n1){
    80004280:	02999563          	bne	s3,s1,800042aa <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    80004284:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004288:	015a5963          	bge	s4,s5,8000429a <filewrite+0xd8>
      int n1 = n - i;
    8000428c:	414a87bb          	subw	a5,s5,s4
    80004290:	89be                	mv	s3,a5
      if(n1 > max)
    80004292:	fafbd8e3          	bge	s7,a5,80004242 <filewrite+0x80>
    80004296:	89e6                	mv	s3,s9
    80004298:	b76d                	j	80004242 <filewrite+0x80>
    8000429a:	64a6                	ld	s1,72(sp)
    8000429c:	79e2                	ld	s3,56(sp)
    8000429e:	6be2                	ld	s7,24(sp)
    800042a0:	6c42                	ld	s8,16(sp)
    800042a2:	6ca2                	ld	s9,8(sp)
    800042a4:	a801                	j	800042b4 <filewrite+0xf2>
    int i = 0;
    800042a6:	4a01                	li	s4,0
    800042a8:	a031                	j	800042b4 <filewrite+0xf2>
    800042aa:	64a6                	ld	s1,72(sp)
    800042ac:	79e2                	ld	s3,56(sp)
    800042ae:	6be2                	ld	s7,24(sp)
    800042b0:	6c42                	ld	s8,16(sp)
    800042b2:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800042b4:	034a9d63          	bne	s5,s4,800042ee <filewrite+0x12c>
    800042b8:	8556                	mv	a0,s5
    800042ba:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800042bc:	60e6                	ld	ra,88(sp)
    800042be:	6446                	ld	s0,80(sp)
    800042c0:	6906                	ld	s2,64(sp)
    800042c2:	7aa2                	ld	s5,40(sp)
    800042c4:	7b02                	ld	s6,32(sp)
    800042c6:	6125                	addi	sp,sp,96
    800042c8:	8082                	ret
    800042ca:	e4a6                	sd	s1,72(sp)
    800042cc:	fc4e                	sd	s3,56(sp)
    800042ce:	f852                	sd	s4,48(sp)
    800042d0:	ec5e                	sd	s7,24(sp)
    800042d2:	e862                	sd	s8,16(sp)
    800042d4:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800042d6:	00003517          	auipc	a0,0x3
    800042da:	31a50513          	addi	a0,a0,794 # 800075f0 <etext+0x5f0>
    800042de:	cc0fc0ef          	jal	8000079e <panic>
    return -1;
    800042e2:	557d                	li	a0,-1
}
    800042e4:	8082                	ret
      return -1;
    800042e6:	557d                	li	a0,-1
    800042e8:	bfd1                	j	800042bc <filewrite+0xfa>
    800042ea:	557d                	li	a0,-1
    800042ec:	bfc1                	j	800042bc <filewrite+0xfa>
    ret = (i == n ? n : -1);
    800042ee:	557d                	li	a0,-1
    800042f0:	7a42                	ld	s4,48(sp)
    800042f2:	b7e9                	j	800042bc <filewrite+0xfa>

00000000800042f4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800042f4:	7179                	addi	sp,sp,-48
    800042f6:	f406                	sd	ra,40(sp)
    800042f8:	f022                	sd	s0,32(sp)
    800042fa:	ec26                	sd	s1,24(sp)
    800042fc:	e052                	sd	s4,0(sp)
    800042fe:	1800                	addi	s0,sp,48
    80004300:	84aa                	mv	s1,a0
    80004302:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004304:	0005b023          	sd	zero,0(a1)
    80004308:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000430c:	c35ff0ef          	jal	80003f40 <filealloc>
    80004310:	e088                	sd	a0,0(s1)
    80004312:	c549                	beqz	a0,8000439c <pipealloc+0xa8>
    80004314:	c2dff0ef          	jal	80003f40 <filealloc>
    80004318:	00aa3023          	sd	a0,0(s4)
    8000431c:	cd25                	beqz	a0,80004394 <pipealloc+0xa0>
    8000431e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004320:	80bfc0ef          	jal	80000b2a <kalloc>
    80004324:	892a                	mv	s2,a0
    80004326:	c12d                	beqz	a0,80004388 <pipealloc+0x94>
    80004328:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000432a:	4985                	li	s3,1
    8000432c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004330:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004334:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004338:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000433c:	00003597          	auipc	a1,0x3
    80004340:	2c458593          	addi	a1,a1,708 # 80007600 <etext+0x600>
    80004344:	837fc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    80004348:	609c                	ld	a5,0(s1)
    8000434a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000434e:	609c                	ld	a5,0(s1)
    80004350:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004354:	609c                	ld	a5,0(s1)
    80004356:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000435a:	609c                	ld	a5,0(s1)
    8000435c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004360:	000a3783          	ld	a5,0(s4)
    80004364:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004368:	000a3783          	ld	a5,0(s4)
    8000436c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004370:	000a3783          	ld	a5,0(s4)
    80004374:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004378:	000a3783          	ld	a5,0(s4)
    8000437c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004380:	4501                	li	a0,0
    80004382:	6942                	ld	s2,16(sp)
    80004384:	69a2                	ld	s3,8(sp)
    80004386:	a01d                	j	800043ac <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004388:	6088                	ld	a0,0(s1)
    8000438a:	c119                	beqz	a0,80004390 <pipealloc+0x9c>
    8000438c:	6942                	ld	s2,16(sp)
    8000438e:	a029                	j	80004398 <pipealloc+0xa4>
    80004390:	6942                	ld	s2,16(sp)
    80004392:	a029                	j	8000439c <pipealloc+0xa8>
    80004394:	6088                	ld	a0,0(s1)
    80004396:	c10d                	beqz	a0,800043b8 <pipealloc+0xc4>
    fileclose(*f0);
    80004398:	c4dff0ef          	jal	80003fe4 <fileclose>
  if(*f1)
    8000439c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800043a0:	557d                	li	a0,-1
  if(*f1)
    800043a2:	c789                	beqz	a5,800043ac <pipealloc+0xb8>
    fileclose(*f1);
    800043a4:	853e                	mv	a0,a5
    800043a6:	c3fff0ef          	jal	80003fe4 <fileclose>
  return -1;
    800043aa:	557d                	li	a0,-1
}
    800043ac:	70a2                	ld	ra,40(sp)
    800043ae:	7402                	ld	s0,32(sp)
    800043b0:	64e2                	ld	s1,24(sp)
    800043b2:	6a02                	ld	s4,0(sp)
    800043b4:	6145                	addi	sp,sp,48
    800043b6:	8082                	ret
  return -1;
    800043b8:	557d                	li	a0,-1
    800043ba:	bfcd                	j	800043ac <pipealloc+0xb8>

00000000800043bc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800043bc:	1101                	addi	sp,sp,-32
    800043be:	ec06                	sd	ra,24(sp)
    800043c0:	e822                	sd	s0,16(sp)
    800043c2:	e426                	sd	s1,8(sp)
    800043c4:	e04a                	sd	s2,0(sp)
    800043c6:	1000                	addi	s0,sp,32
    800043c8:	84aa                	mv	s1,a0
    800043ca:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800043cc:	833fc0ef          	jal	80000bfe <acquire>
  if(writable){
    800043d0:	02090763          	beqz	s2,800043fe <pipeclose+0x42>
    pi->writeopen = 0;
    800043d4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800043d8:	21848513          	addi	a0,s1,536
    800043dc:	b27fd0ef          	jal	80001f02 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800043e0:	2204b783          	ld	a5,544(s1)
    800043e4:	e785                	bnez	a5,8000440c <pipeclose+0x50>
    release(&pi->lock);
    800043e6:	8526                	mv	a0,s1
    800043e8:	8abfc0ef          	jal	80000c92 <release>
    kfree((char*)pi);
    800043ec:	8526                	mv	a0,s1
    800043ee:	e5afc0ef          	jal	80000a48 <kfree>
  } else
    release(&pi->lock);
}
    800043f2:	60e2                	ld	ra,24(sp)
    800043f4:	6442                	ld	s0,16(sp)
    800043f6:	64a2                	ld	s1,8(sp)
    800043f8:	6902                	ld	s2,0(sp)
    800043fa:	6105                	addi	sp,sp,32
    800043fc:	8082                	ret
    pi->readopen = 0;
    800043fe:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004402:	21c48513          	addi	a0,s1,540
    80004406:	afdfd0ef          	jal	80001f02 <wakeup>
    8000440a:	bfd9                	j	800043e0 <pipeclose+0x24>
    release(&pi->lock);
    8000440c:	8526                	mv	a0,s1
    8000440e:	885fc0ef          	jal	80000c92 <release>
}
    80004412:	b7c5                	j	800043f2 <pipeclose+0x36>

0000000080004414 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004414:	7159                	addi	sp,sp,-112
    80004416:	f486                	sd	ra,104(sp)
    80004418:	f0a2                	sd	s0,96(sp)
    8000441a:	eca6                	sd	s1,88(sp)
    8000441c:	e8ca                	sd	s2,80(sp)
    8000441e:	e4ce                	sd	s3,72(sp)
    80004420:	e0d2                	sd	s4,64(sp)
    80004422:	fc56                	sd	s5,56(sp)
    80004424:	1880                	addi	s0,sp,112
    80004426:	84aa                	mv	s1,a0
    80004428:	8aae                	mv	s5,a1
    8000442a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000442c:	ca4fd0ef          	jal	800018d0 <myproc>
    80004430:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004432:	8526                	mv	a0,s1
    80004434:	fcafc0ef          	jal	80000bfe <acquire>
  while(i < n){
    80004438:	0d405263          	blez	s4,800044fc <pipewrite+0xe8>
    8000443c:	f85a                	sd	s6,48(sp)
    8000443e:	f45e                	sd	s7,40(sp)
    80004440:	f062                	sd	s8,32(sp)
    80004442:	ec66                	sd	s9,24(sp)
    80004444:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004446:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004448:	f9f40c13          	addi	s8,s0,-97
    8000444c:	4b85                	li	s7,1
    8000444e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004450:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004454:	21c48c93          	addi	s9,s1,540
    80004458:	a82d                	j	80004492 <pipewrite+0x7e>
      release(&pi->lock);
    8000445a:	8526                	mv	a0,s1
    8000445c:	837fc0ef          	jal	80000c92 <release>
      return -1;
    80004460:	597d                	li	s2,-1
    80004462:	7b42                	ld	s6,48(sp)
    80004464:	7ba2                	ld	s7,40(sp)
    80004466:	7c02                	ld	s8,32(sp)
    80004468:	6ce2                	ld	s9,24(sp)
    8000446a:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000446c:	854a                	mv	a0,s2
    8000446e:	70a6                	ld	ra,104(sp)
    80004470:	7406                	ld	s0,96(sp)
    80004472:	64e6                	ld	s1,88(sp)
    80004474:	6946                	ld	s2,80(sp)
    80004476:	69a6                	ld	s3,72(sp)
    80004478:	6a06                	ld	s4,64(sp)
    8000447a:	7ae2                	ld	s5,56(sp)
    8000447c:	6165                	addi	sp,sp,112
    8000447e:	8082                	ret
      wakeup(&pi->nread);
    80004480:	856a                	mv	a0,s10
    80004482:	a81fd0ef          	jal	80001f02 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004486:	85a6                	mv	a1,s1
    80004488:	8566                	mv	a0,s9
    8000448a:	a2dfd0ef          	jal	80001eb6 <sleep>
  while(i < n){
    8000448e:	05495a63          	bge	s2,s4,800044e2 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004492:	2204a783          	lw	a5,544(s1)
    80004496:	d3f1                	beqz	a5,8000445a <pipewrite+0x46>
    80004498:	854e                	mv	a0,s3
    8000449a:	c55fd0ef          	jal	800020ee <killed>
    8000449e:	fd55                	bnez	a0,8000445a <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800044a0:	2184a783          	lw	a5,536(s1)
    800044a4:	21c4a703          	lw	a4,540(s1)
    800044a8:	2007879b          	addiw	a5,a5,512
    800044ac:	fcf70ae3          	beq	a4,a5,80004480 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044b0:	86de                	mv	a3,s7
    800044b2:	01590633          	add	a2,s2,s5
    800044b6:	85e2                	mv	a1,s8
    800044b8:	0509b503          	ld	a0,80(s3)
    800044bc:	978fd0ef          	jal	80001634 <copyin>
    800044c0:	05650063          	beq	a0,s6,80004500 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800044c4:	21c4a783          	lw	a5,540(s1)
    800044c8:	0017871b          	addiw	a4,a5,1
    800044cc:	20e4ae23          	sw	a4,540(s1)
    800044d0:	1ff7f793          	andi	a5,a5,511
    800044d4:	97a6                	add	a5,a5,s1
    800044d6:	f9f44703          	lbu	a4,-97(s0)
    800044da:	00e78c23          	sb	a4,24(a5)
      i++;
    800044de:	2905                	addiw	s2,s2,1
    800044e0:	b77d                	j	8000448e <pipewrite+0x7a>
    800044e2:	7b42                	ld	s6,48(sp)
    800044e4:	7ba2                	ld	s7,40(sp)
    800044e6:	7c02                	ld	s8,32(sp)
    800044e8:	6ce2                	ld	s9,24(sp)
    800044ea:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800044ec:	21848513          	addi	a0,s1,536
    800044f0:	a13fd0ef          	jal	80001f02 <wakeup>
  release(&pi->lock);
    800044f4:	8526                	mv	a0,s1
    800044f6:	f9cfc0ef          	jal	80000c92 <release>
  return i;
    800044fa:	bf8d                	j	8000446c <pipewrite+0x58>
  int i = 0;
    800044fc:	4901                	li	s2,0
    800044fe:	b7fd                	j	800044ec <pipewrite+0xd8>
    80004500:	7b42                	ld	s6,48(sp)
    80004502:	7ba2                	ld	s7,40(sp)
    80004504:	7c02                	ld	s8,32(sp)
    80004506:	6ce2                	ld	s9,24(sp)
    80004508:	6d42                	ld	s10,16(sp)
    8000450a:	b7cd                	j	800044ec <pipewrite+0xd8>

000000008000450c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000450c:	711d                	addi	sp,sp,-96
    8000450e:	ec86                	sd	ra,88(sp)
    80004510:	e8a2                	sd	s0,80(sp)
    80004512:	e4a6                	sd	s1,72(sp)
    80004514:	e0ca                	sd	s2,64(sp)
    80004516:	fc4e                	sd	s3,56(sp)
    80004518:	f852                	sd	s4,48(sp)
    8000451a:	f456                	sd	s5,40(sp)
    8000451c:	1080                	addi	s0,sp,96
    8000451e:	84aa                	mv	s1,a0
    80004520:	892e                	mv	s2,a1
    80004522:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004524:	bacfd0ef          	jal	800018d0 <myproc>
    80004528:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000452a:	8526                	mv	a0,s1
    8000452c:	ed2fc0ef          	jal	80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004530:	2184a703          	lw	a4,536(s1)
    80004534:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004538:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000453c:	02f71763          	bne	a4,a5,8000456a <piperead+0x5e>
    80004540:	2244a783          	lw	a5,548(s1)
    80004544:	cf85                	beqz	a5,8000457c <piperead+0x70>
    if(killed(pr)){
    80004546:	8552                	mv	a0,s4
    80004548:	ba7fd0ef          	jal	800020ee <killed>
    8000454c:	e11d                	bnez	a0,80004572 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000454e:	85a6                	mv	a1,s1
    80004550:	854e                	mv	a0,s3
    80004552:	965fd0ef          	jal	80001eb6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004556:	2184a703          	lw	a4,536(s1)
    8000455a:	21c4a783          	lw	a5,540(s1)
    8000455e:	fef701e3          	beq	a4,a5,80004540 <piperead+0x34>
    80004562:	f05a                	sd	s6,32(sp)
    80004564:	ec5e                	sd	s7,24(sp)
    80004566:	e862                	sd	s8,16(sp)
    80004568:	a829                	j	80004582 <piperead+0x76>
    8000456a:	f05a                	sd	s6,32(sp)
    8000456c:	ec5e                	sd	s7,24(sp)
    8000456e:	e862                	sd	s8,16(sp)
    80004570:	a809                	j	80004582 <piperead+0x76>
      release(&pi->lock);
    80004572:	8526                	mv	a0,s1
    80004574:	f1efc0ef          	jal	80000c92 <release>
      return -1;
    80004578:	59fd                	li	s3,-1
    8000457a:	a0a5                	j	800045e2 <piperead+0xd6>
    8000457c:	f05a                	sd	s6,32(sp)
    8000457e:	ec5e                	sd	s7,24(sp)
    80004580:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004582:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004584:	faf40c13          	addi	s8,s0,-81
    80004588:	4b85                	li	s7,1
    8000458a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000458c:	05505163          	blez	s5,800045ce <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004590:	2184a783          	lw	a5,536(s1)
    80004594:	21c4a703          	lw	a4,540(s1)
    80004598:	02f70b63          	beq	a4,a5,800045ce <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000459c:	0017871b          	addiw	a4,a5,1
    800045a0:	20e4ac23          	sw	a4,536(s1)
    800045a4:	1ff7f793          	andi	a5,a5,511
    800045a8:	97a6                	add	a5,a5,s1
    800045aa:	0187c783          	lbu	a5,24(a5)
    800045ae:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800045b2:	86de                	mv	a3,s7
    800045b4:	8662                	mv	a2,s8
    800045b6:	85ca                	mv	a1,s2
    800045b8:	050a3503          	ld	a0,80(s4)
    800045bc:	fc9fc0ef          	jal	80001584 <copyout>
    800045c0:	01650763          	beq	a0,s6,800045ce <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045c4:	2985                	addiw	s3,s3,1
    800045c6:	0905                	addi	s2,s2,1
    800045c8:	fd3a94e3          	bne	s5,s3,80004590 <piperead+0x84>
    800045cc:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800045ce:	21c48513          	addi	a0,s1,540
    800045d2:	931fd0ef          	jal	80001f02 <wakeup>
  release(&pi->lock);
    800045d6:	8526                	mv	a0,s1
    800045d8:	ebafc0ef          	jal	80000c92 <release>
    800045dc:	7b02                	ld	s6,32(sp)
    800045de:	6be2                	ld	s7,24(sp)
    800045e0:	6c42                	ld	s8,16(sp)
  return i;
}
    800045e2:	854e                	mv	a0,s3
    800045e4:	60e6                	ld	ra,88(sp)
    800045e6:	6446                	ld	s0,80(sp)
    800045e8:	64a6                	ld	s1,72(sp)
    800045ea:	6906                	ld	s2,64(sp)
    800045ec:	79e2                	ld	s3,56(sp)
    800045ee:	7a42                	ld	s4,48(sp)
    800045f0:	7aa2                	ld	s5,40(sp)
    800045f2:	6125                	addi	sp,sp,96
    800045f4:	8082                	ret

00000000800045f6 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800045f6:	1141                	addi	sp,sp,-16
    800045f8:	e406                	sd	ra,8(sp)
    800045fa:	e022                	sd	s0,0(sp)
    800045fc:	0800                	addi	s0,sp,16
    800045fe:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004600:	0035151b          	slliw	a0,a0,0x3
    80004604:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004606:	8b89                	andi	a5,a5,2
    80004608:	c399                	beqz	a5,8000460e <flags2perm+0x18>
      perm |= PTE_W;
    8000460a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000460e:	60a2                	ld	ra,8(sp)
    80004610:	6402                	ld	s0,0(sp)
    80004612:	0141                	addi	sp,sp,16
    80004614:	8082                	ret

0000000080004616 <exec>:

int
exec(char *path, char **argv)
{
    80004616:	de010113          	addi	sp,sp,-544
    8000461a:	20113c23          	sd	ra,536(sp)
    8000461e:	20813823          	sd	s0,528(sp)
    80004622:	20913423          	sd	s1,520(sp)
    80004626:	21213023          	sd	s2,512(sp)
    8000462a:	1400                	addi	s0,sp,544
    8000462c:	892a                	mv	s2,a0
    8000462e:	dea43823          	sd	a0,-528(s0)
    80004632:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004636:	a9afd0ef          	jal	800018d0 <myproc>
    8000463a:	84aa                	mv	s1,a0

  begin_op();
    8000463c:	d88ff0ef          	jal	80003bc4 <begin_op>

  if((ip = namei(path)) == 0){
    80004640:	854a                	mv	a0,s2
    80004642:	bc0ff0ef          	jal	80003a02 <namei>
    80004646:	cd21                	beqz	a0,8000469e <exec+0x88>
    80004648:	fbd2                	sd	s4,496(sp)
    8000464a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000464c:	cc7fe0ef          	jal	80003312 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004650:	04000713          	li	a4,64
    80004654:	4681                	li	a3,0
    80004656:	e5040613          	addi	a2,s0,-432
    8000465a:	4581                	li	a1,0
    8000465c:	8552                	mv	a0,s4
    8000465e:	f0dfe0ef          	jal	8000356a <readi>
    80004662:	04000793          	li	a5,64
    80004666:	00f51a63          	bne	a0,a5,8000467a <exec+0x64>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000466a:	e5042703          	lw	a4,-432(s0)
    8000466e:	464c47b7          	lui	a5,0x464c4
    80004672:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004676:	02f70863          	beq	a4,a5,800046a6 <exec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000467a:	8552                	mv	a0,s4
    8000467c:	ea1fe0ef          	jal	8000351c <iunlockput>
    end_op();
    80004680:	daeff0ef          	jal	80003c2e <end_op>
  }
  return -1;
    80004684:	557d                	li	a0,-1
    80004686:	7a5e                	ld	s4,496(sp)
}
    80004688:	21813083          	ld	ra,536(sp)
    8000468c:	21013403          	ld	s0,528(sp)
    80004690:	20813483          	ld	s1,520(sp)
    80004694:	20013903          	ld	s2,512(sp)
    80004698:	22010113          	addi	sp,sp,544
    8000469c:	8082                	ret
    end_op();
    8000469e:	d90ff0ef          	jal	80003c2e <end_op>
    return -1;
    800046a2:	557d                	li	a0,-1
    800046a4:	b7d5                	j	80004688 <exec+0x72>
    800046a6:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800046a8:	8526                	mv	a0,s1
    800046aa:	acefd0ef          	jal	80001978 <proc_pagetable>
    800046ae:	8b2a                	mv	s6,a0
    800046b0:	26050d63          	beqz	a0,8000492a <exec+0x314>
    800046b4:	ffce                	sd	s3,504(sp)
    800046b6:	f7d6                	sd	s5,488(sp)
    800046b8:	efde                	sd	s7,472(sp)
    800046ba:	ebe2                	sd	s8,464(sp)
    800046bc:	e7e6                	sd	s9,456(sp)
    800046be:	e3ea                	sd	s10,448(sp)
    800046c0:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046c2:	e7042683          	lw	a3,-400(s0)
    800046c6:	e8845783          	lhu	a5,-376(s0)
    800046ca:	0e078763          	beqz	a5,800047b8 <exec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046ce:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046d0:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800046d2:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800046d6:	6c85                	lui	s9,0x1
    800046d8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800046dc:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800046e0:	6a85                	lui	s5,0x1
    800046e2:	a085                	j	80004742 <exec+0x12c>
      panic("loadseg: address should exist");
    800046e4:	00003517          	auipc	a0,0x3
    800046e8:	f2450513          	addi	a0,a0,-220 # 80007608 <etext+0x608>
    800046ec:	8b2fc0ef          	jal	8000079e <panic>
    if(sz - i < PGSIZE)
    800046f0:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800046f2:	874a                	mv	a4,s2
    800046f4:	009c06bb          	addw	a3,s8,s1
    800046f8:	4581                	li	a1,0
    800046fa:	8552                	mv	a0,s4
    800046fc:	e6ffe0ef          	jal	8000356a <readi>
    80004700:	22a91963          	bne	s2,a0,80004932 <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    80004704:	009a84bb          	addw	s1,s5,s1
    80004708:	0334f263          	bgeu	s1,s3,8000472c <exec+0x116>
    pa = walkaddr(pagetable, va + i);
    8000470c:	02049593          	slli	a1,s1,0x20
    80004710:	9181                	srli	a1,a1,0x20
    80004712:	95de                	add	a1,a1,s7
    80004714:	855a                	mv	a0,s6
    80004716:	8e7fc0ef          	jal	80000ffc <walkaddr>
    8000471a:	862a                	mv	a2,a0
    if(pa == 0)
    8000471c:	d561                	beqz	a0,800046e4 <exec+0xce>
    if(sz - i < PGSIZE)
    8000471e:	409987bb          	subw	a5,s3,s1
    80004722:	893e                	mv	s2,a5
    80004724:	fcfcf6e3          	bgeu	s9,a5,800046f0 <exec+0xda>
    80004728:	8956                	mv	s2,s5
    8000472a:	b7d9                	j	800046f0 <exec+0xda>
    sz = sz1;
    8000472c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004730:	2d05                	addiw	s10,s10,1
    80004732:	e0843783          	ld	a5,-504(s0)
    80004736:	0387869b          	addiw	a3,a5,56
    8000473a:	e8845783          	lhu	a5,-376(s0)
    8000473e:	06fd5e63          	bge	s10,a5,800047ba <exec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004742:	e0d43423          	sd	a3,-504(s0)
    80004746:	876e                	mv	a4,s11
    80004748:	e1840613          	addi	a2,s0,-488
    8000474c:	4581                	li	a1,0
    8000474e:	8552                	mv	a0,s4
    80004750:	e1bfe0ef          	jal	8000356a <readi>
    80004754:	1db51d63          	bne	a0,s11,8000492e <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    80004758:	e1842783          	lw	a5,-488(s0)
    8000475c:	4705                	li	a4,1
    8000475e:	fce799e3          	bne	a5,a4,80004730 <exec+0x11a>
    if(ph.memsz < ph.filesz)
    80004762:	e4043483          	ld	s1,-448(s0)
    80004766:	e3843783          	ld	a5,-456(s0)
    8000476a:	1ef4e263          	bltu	s1,a5,8000494e <exec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000476e:	e2843783          	ld	a5,-472(s0)
    80004772:	94be                	add	s1,s1,a5
    80004774:	1ef4e063          	bltu	s1,a5,80004954 <exec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    80004778:	de843703          	ld	a4,-536(s0)
    8000477c:	8ff9                	and	a5,a5,a4
    8000477e:	1c079e63          	bnez	a5,8000495a <exec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004782:	e1c42503          	lw	a0,-484(s0)
    80004786:	e71ff0ef          	jal	800045f6 <flags2perm>
    8000478a:	86aa                	mv	a3,a0
    8000478c:	8626                	mv	a2,s1
    8000478e:	85ca                	mv	a1,s2
    80004790:	855a                	mv	a0,s6
    80004792:	bd3fc0ef          	jal	80001364 <uvmalloc>
    80004796:	dea43c23          	sd	a0,-520(s0)
    8000479a:	1c050363          	beqz	a0,80004960 <exec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000479e:	e2843b83          	ld	s7,-472(s0)
    800047a2:	e2042c03          	lw	s8,-480(s0)
    800047a6:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800047aa:	00098463          	beqz	s3,800047b2 <exec+0x19c>
    800047ae:	4481                	li	s1,0
    800047b0:	bfb1                	j	8000470c <exec+0xf6>
    sz = sz1;
    800047b2:	df843903          	ld	s2,-520(s0)
    800047b6:	bfad                	j	80004730 <exec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047b8:	4901                	li	s2,0
  iunlockput(ip);
    800047ba:	8552                	mv	a0,s4
    800047bc:	d61fe0ef          	jal	8000351c <iunlockput>
  end_op();
    800047c0:	c6eff0ef          	jal	80003c2e <end_op>
  p = myproc();
    800047c4:	90cfd0ef          	jal	800018d0 <myproc>
    800047c8:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800047ca:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800047ce:	6985                	lui	s3,0x1
    800047d0:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800047d2:	99ca                	add	s3,s3,s2
    800047d4:	77fd                	lui	a5,0xfffff
    800047d6:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800047da:	4691                	li	a3,4
    800047dc:	6609                	lui	a2,0x2
    800047de:	964e                	add	a2,a2,s3
    800047e0:	85ce                	mv	a1,s3
    800047e2:	855a                	mv	a0,s6
    800047e4:	b81fc0ef          	jal	80001364 <uvmalloc>
    800047e8:	8a2a                	mv	s4,a0
    800047ea:	e105                	bnez	a0,8000480a <exec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800047ec:	85ce                	mv	a1,s3
    800047ee:	855a                	mv	a0,s6
    800047f0:	a0cfd0ef          	jal	800019fc <proc_freepagetable>
  return -1;
    800047f4:	557d                	li	a0,-1
    800047f6:	79fe                	ld	s3,504(sp)
    800047f8:	7a5e                	ld	s4,496(sp)
    800047fa:	7abe                	ld	s5,488(sp)
    800047fc:	7b1e                	ld	s6,480(sp)
    800047fe:	6bfe                	ld	s7,472(sp)
    80004800:	6c5e                	ld	s8,464(sp)
    80004802:	6cbe                	ld	s9,456(sp)
    80004804:	6d1e                	ld	s10,448(sp)
    80004806:	7dfa                	ld	s11,440(sp)
    80004808:	b541                	j	80004688 <exec+0x72>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000480a:	75f9                	lui	a1,0xffffe
    8000480c:	95aa                	add	a1,a1,a0
    8000480e:	855a                	mv	a0,s6
    80004810:	d4bfc0ef          	jal	8000155a <uvmclear>
  stackbase = sp - PGSIZE;
    80004814:	7bfd                	lui	s7,0xfffff
    80004816:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    80004818:	e0043783          	ld	a5,-512(s0)
    8000481c:	6388                	ld	a0,0(a5)
  sp = sz;
    8000481e:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004820:	4481                	li	s1,0
    ustack[argc] = sp;
    80004822:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004826:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000482a:	cd21                	beqz	a0,80004882 <exec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    8000482c:	e2afc0ef          	jal	80000e56 <strlen>
    80004830:	0015079b          	addiw	a5,a0,1
    80004834:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004838:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000483c:	13796563          	bltu	s2,s7,80004966 <exec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004840:	e0043d83          	ld	s11,-512(s0)
    80004844:	000db983          	ld	s3,0(s11)
    80004848:	854e                	mv	a0,s3
    8000484a:	e0cfc0ef          	jal	80000e56 <strlen>
    8000484e:	0015069b          	addiw	a3,a0,1
    80004852:	864e                	mv	a2,s3
    80004854:	85ca                	mv	a1,s2
    80004856:	855a                	mv	a0,s6
    80004858:	d2dfc0ef          	jal	80001584 <copyout>
    8000485c:	10054763          	bltz	a0,8000496a <exec+0x354>
    ustack[argc] = sp;
    80004860:	00349793          	slli	a5,s1,0x3
    80004864:	97e6                	add	a5,a5,s9
    80004866:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdac88>
  for(argc = 0; argv[argc]; argc++) {
    8000486a:	0485                	addi	s1,s1,1
    8000486c:	008d8793          	addi	a5,s11,8
    80004870:	e0f43023          	sd	a5,-512(s0)
    80004874:	008db503          	ld	a0,8(s11)
    80004878:	c509                	beqz	a0,80004882 <exec+0x26c>
    if(argc >= MAXARG)
    8000487a:	fb8499e3          	bne	s1,s8,8000482c <exec+0x216>
  sz = sz1;
    8000487e:	89d2                	mv	s3,s4
    80004880:	b7b5                	j	800047ec <exec+0x1d6>
  ustack[argc] = 0;
    80004882:	00349793          	slli	a5,s1,0x3
    80004886:	f9078793          	addi	a5,a5,-112
    8000488a:	97a2                	add	a5,a5,s0
    8000488c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004890:	00148693          	addi	a3,s1,1
    80004894:	068e                	slli	a3,a3,0x3
    80004896:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000489a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000489e:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800048a0:	f57966e3          	bltu	s2,s7,800047ec <exec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800048a4:	e9040613          	addi	a2,s0,-368
    800048a8:	85ca                	mv	a1,s2
    800048aa:	855a                	mv	a0,s6
    800048ac:	cd9fc0ef          	jal	80001584 <copyout>
    800048b0:	f2054ee3          	bltz	a0,800047ec <exec+0x1d6>
  p->trapframe->a1 = sp;
    800048b4:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800048b8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800048bc:	df043783          	ld	a5,-528(s0)
    800048c0:	0007c703          	lbu	a4,0(a5)
    800048c4:	cf11                	beqz	a4,800048e0 <exec+0x2ca>
    800048c6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800048c8:	02f00693          	li	a3,47
    800048cc:	a029                	j	800048d6 <exec+0x2c0>
  for(last=s=path; *s; s++)
    800048ce:	0785                	addi	a5,a5,1
    800048d0:	fff7c703          	lbu	a4,-1(a5)
    800048d4:	c711                	beqz	a4,800048e0 <exec+0x2ca>
    if(*s == '/')
    800048d6:	fed71ce3          	bne	a4,a3,800048ce <exec+0x2b8>
      last = s+1;
    800048da:	def43823          	sd	a5,-528(s0)
    800048de:	bfc5                	j	800048ce <exec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    800048e0:	4641                	li	a2,16
    800048e2:	df043583          	ld	a1,-528(s0)
    800048e6:	158a8513          	addi	a0,s5,344
    800048ea:	d36fc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    800048ee:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800048f2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800048f6:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800048fa:	058ab783          	ld	a5,88(s5)
    800048fe:	e6843703          	ld	a4,-408(s0)
    80004902:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004904:	058ab783          	ld	a5,88(s5)
    80004908:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000490c:	85ea                	mv	a1,s10
    8000490e:	8eefd0ef          	jal	800019fc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004912:	0004851b          	sext.w	a0,s1
    80004916:	79fe                	ld	s3,504(sp)
    80004918:	7a5e                	ld	s4,496(sp)
    8000491a:	7abe                	ld	s5,488(sp)
    8000491c:	7b1e                	ld	s6,480(sp)
    8000491e:	6bfe                	ld	s7,472(sp)
    80004920:	6c5e                	ld	s8,464(sp)
    80004922:	6cbe                	ld	s9,456(sp)
    80004924:	6d1e                	ld	s10,448(sp)
    80004926:	7dfa                	ld	s11,440(sp)
    80004928:	b385                	j	80004688 <exec+0x72>
    8000492a:	7b1e                	ld	s6,480(sp)
    8000492c:	b3b9                	j	8000467a <exec+0x64>
    8000492e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004932:	df843583          	ld	a1,-520(s0)
    80004936:	855a                	mv	a0,s6
    80004938:	8c4fd0ef          	jal	800019fc <proc_freepagetable>
  if(ip){
    8000493c:	79fe                	ld	s3,504(sp)
    8000493e:	7abe                	ld	s5,488(sp)
    80004940:	7b1e                	ld	s6,480(sp)
    80004942:	6bfe                	ld	s7,472(sp)
    80004944:	6c5e                	ld	s8,464(sp)
    80004946:	6cbe                	ld	s9,456(sp)
    80004948:	6d1e                	ld	s10,448(sp)
    8000494a:	7dfa                	ld	s11,440(sp)
    8000494c:	b33d                	j	8000467a <exec+0x64>
    8000494e:	df243c23          	sd	s2,-520(s0)
    80004952:	b7c5                	j	80004932 <exec+0x31c>
    80004954:	df243c23          	sd	s2,-520(s0)
    80004958:	bfe9                	j	80004932 <exec+0x31c>
    8000495a:	df243c23          	sd	s2,-520(s0)
    8000495e:	bfd1                	j	80004932 <exec+0x31c>
    80004960:	df243c23          	sd	s2,-520(s0)
    80004964:	b7f9                	j	80004932 <exec+0x31c>
  sz = sz1;
    80004966:	89d2                	mv	s3,s4
    80004968:	b551                	j	800047ec <exec+0x1d6>
    8000496a:	89d2                	mv	s3,s4
    8000496c:	b541                	j	800047ec <exec+0x1d6>

000000008000496e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000496e:	7179                	addi	sp,sp,-48
    80004970:	f406                	sd	ra,40(sp)
    80004972:	f022                	sd	s0,32(sp)
    80004974:	ec26                	sd	s1,24(sp)
    80004976:	e84a                	sd	s2,16(sp)
    80004978:	1800                	addi	s0,sp,48
    8000497a:	892e                	mv	s2,a1
    8000497c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000497e:	fdc40593          	addi	a1,s0,-36
    80004982:	e59fd0ef          	jal	800027da <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004986:	fdc42703          	lw	a4,-36(s0)
    8000498a:	47bd                	li	a5,15
    8000498c:	02e7e963          	bltu	a5,a4,800049be <argfd+0x50>
    80004990:	f41fc0ef          	jal	800018d0 <myproc>
    80004994:	fdc42703          	lw	a4,-36(s0)
    80004998:	01a70793          	addi	a5,a4,26
    8000499c:	078e                	slli	a5,a5,0x3
    8000499e:	953e                	add	a0,a0,a5
    800049a0:	611c                	ld	a5,0(a0)
    800049a2:	c385                	beqz	a5,800049c2 <argfd+0x54>
    return -1;
  if(pfd)
    800049a4:	00090463          	beqz	s2,800049ac <argfd+0x3e>
    *pfd = fd;
    800049a8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800049ac:	4501                	li	a0,0
  if(pf)
    800049ae:	c091                	beqz	s1,800049b2 <argfd+0x44>
    *pf = f;
    800049b0:	e09c                	sd	a5,0(s1)
}
    800049b2:	70a2                	ld	ra,40(sp)
    800049b4:	7402                	ld	s0,32(sp)
    800049b6:	64e2                	ld	s1,24(sp)
    800049b8:	6942                	ld	s2,16(sp)
    800049ba:	6145                	addi	sp,sp,48
    800049bc:	8082                	ret
    return -1;
    800049be:	557d                	li	a0,-1
    800049c0:	bfcd                	j	800049b2 <argfd+0x44>
    800049c2:	557d                	li	a0,-1
    800049c4:	b7fd                	j	800049b2 <argfd+0x44>

00000000800049c6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800049c6:	1101                	addi	sp,sp,-32
    800049c8:	ec06                	sd	ra,24(sp)
    800049ca:	e822                	sd	s0,16(sp)
    800049cc:	e426                	sd	s1,8(sp)
    800049ce:	1000                	addi	s0,sp,32
    800049d0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800049d2:	efffc0ef          	jal	800018d0 <myproc>
    800049d6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800049d8:	0d050793          	addi	a5,a0,208
    800049dc:	4501                	li	a0,0
    800049de:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800049e0:	6398                	ld	a4,0(a5)
    800049e2:	cb19                	beqz	a4,800049f8 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800049e4:	2505                	addiw	a0,a0,1
    800049e6:	07a1                	addi	a5,a5,8
    800049e8:	fed51ce3          	bne	a0,a3,800049e0 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800049ec:	557d                	li	a0,-1
}
    800049ee:	60e2                	ld	ra,24(sp)
    800049f0:	6442                	ld	s0,16(sp)
    800049f2:	64a2                	ld	s1,8(sp)
    800049f4:	6105                	addi	sp,sp,32
    800049f6:	8082                	ret
      p->ofile[fd] = f;
    800049f8:	01a50793          	addi	a5,a0,26
    800049fc:	078e                	slli	a5,a5,0x3
    800049fe:	963e                	add	a2,a2,a5
    80004a00:	e204                	sd	s1,0(a2)
      return fd;
    80004a02:	b7f5                	j	800049ee <fdalloc+0x28>

0000000080004a04 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004a04:	715d                	addi	sp,sp,-80
    80004a06:	e486                	sd	ra,72(sp)
    80004a08:	e0a2                	sd	s0,64(sp)
    80004a0a:	fc26                	sd	s1,56(sp)
    80004a0c:	f84a                	sd	s2,48(sp)
    80004a0e:	f44e                	sd	s3,40(sp)
    80004a10:	ec56                	sd	s5,24(sp)
    80004a12:	e85a                	sd	s6,16(sp)
    80004a14:	0880                	addi	s0,sp,80
    80004a16:	8b2e                	mv	s6,a1
    80004a18:	89b2                	mv	s3,a2
    80004a1a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004a1c:	fb040593          	addi	a1,s0,-80
    80004a20:	ffdfe0ef          	jal	80003a1c <nameiparent>
    80004a24:	84aa                	mv	s1,a0
    80004a26:	10050a63          	beqz	a0,80004b3a <create+0x136>
    return 0;

  ilock(dp);
    80004a2a:	8e9fe0ef          	jal	80003312 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a2e:	4601                	li	a2,0
    80004a30:	fb040593          	addi	a1,s0,-80
    80004a34:	8526                	mv	a0,s1
    80004a36:	d41fe0ef          	jal	80003776 <dirlookup>
    80004a3a:	8aaa                	mv	s5,a0
    80004a3c:	c129                	beqz	a0,80004a7e <create+0x7a>
    iunlockput(dp);
    80004a3e:	8526                	mv	a0,s1
    80004a40:	addfe0ef          	jal	8000351c <iunlockput>
    ilock(ip);
    80004a44:	8556                	mv	a0,s5
    80004a46:	8cdfe0ef          	jal	80003312 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a4a:	4789                	li	a5,2
    80004a4c:	02fb1463          	bne	s6,a5,80004a74 <create+0x70>
    80004a50:	044ad783          	lhu	a5,68(s5)
    80004a54:	37f9                	addiw	a5,a5,-2
    80004a56:	17c2                	slli	a5,a5,0x30
    80004a58:	93c1                	srli	a5,a5,0x30
    80004a5a:	4705                	li	a4,1
    80004a5c:	00f76c63          	bltu	a4,a5,80004a74 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a60:	8556                	mv	a0,s5
    80004a62:	60a6                	ld	ra,72(sp)
    80004a64:	6406                	ld	s0,64(sp)
    80004a66:	74e2                	ld	s1,56(sp)
    80004a68:	7942                	ld	s2,48(sp)
    80004a6a:	79a2                	ld	s3,40(sp)
    80004a6c:	6ae2                	ld	s5,24(sp)
    80004a6e:	6b42                	ld	s6,16(sp)
    80004a70:	6161                	addi	sp,sp,80
    80004a72:	8082                	ret
    iunlockput(ip);
    80004a74:	8556                	mv	a0,s5
    80004a76:	aa7fe0ef          	jal	8000351c <iunlockput>
    return 0;
    80004a7a:	4a81                	li	s5,0
    80004a7c:	b7d5                	j	80004a60 <create+0x5c>
    80004a7e:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a80:	85da                	mv	a1,s6
    80004a82:	4088                	lw	a0,0(s1)
    80004a84:	f1efe0ef          	jal	800031a2 <ialloc>
    80004a88:	8a2a                	mv	s4,a0
    80004a8a:	cd15                	beqz	a0,80004ac6 <create+0xc2>
  ilock(ip);
    80004a8c:	887fe0ef          	jal	80003312 <ilock>
  ip->major = major;
    80004a90:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004a94:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004a98:	4905                	li	s2,1
    80004a9a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004a9e:	8552                	mv	a0,s4
    80004aa0:	fbefe0ef          	jal	8000325e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004aa4:	032b0763          	beq	s6,s2,80004ad2 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004aa8:	004a2603          	lw	a2,4(s4)
    80004aac:	fb040593          	addi	a1,s0,-80
    80004ab0:	8526                	mv	a0,s1
    80004ab2:	ea7fe0ef          	jal	80003958 <dirlink>
    80004ab6:	06054563          	bltz	a0,80004b20 <create+0x11c>
  iunlockput(dp);
    80004aba:	8526                	mv	a0,s1
    80004abc:	a61fe0ef          	jal	8000351c <iunlockput>
  return ip;
    80004ac0:	8ad2                	mv	s5,s4
    80004ac2:	7a02                	ld	s4,32(sp)
    80004ac4:	bf71                	j	80004a60 <create+0x5c>
    iunlockput(dp);
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	a55fe0ef          	jal	8000351c <iunlockput>
    return 0;
    80004acc:	8ad2                	mv	s5,s4
    80004ace:	7a02                	ld	s4,32(sp)
    80004ad0:	bf41                	j	80004a60 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ad2:	004a2603          	lw	a2,4(s4)
    80004ad6:	00003597          	auipc	a1,0x3
    80004ada:	b5258593          	addi	a1,a1,-1198 # 80007628 <etext+0x628>
    80004ade:	8552                	mv	a0,s4
    80004ae0:	e79fe0ef          	jal	80003958 <dirlink>
    80004ae4:	02054e63          	bltz	a0,80004b20 <create+0x11c>
    80004ae8:	40d0                	lw	a2,4(s1)
    80004aea:	00003597          	auipc	a1,0x3
    80004aee:	b4658593          	addi	a1,a1,-1210 # 80007630 <etext+0x630>
    80004af2:	8552                	mv	a0,s4
    80004af4:	e65fe0ef          	jal	80003958 <dirlink>
    80004af8:	02054463          	bltz	a0,80004b20 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004afc:	004a2603          	lw	a2,4(s4)
    80004b00:	fb040593          	addi	a1,s0,-80
    80004b04:	8526                	mv	a0,s1
    80004b06:	e53fe0ef          	jal	80003958 <dirlink>
    80004b0a:	00054b63          	bltz	a0,80004b20 <create+0x11c>
    dp->nlink++;  // for ".."
    80004b0e:	04a4d783          	lhu	a5,74(s1)
    80004b12:	2785                	addiw	a5,a5,1
    80004b14:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b18:	8526                	mv	a0,s1
    80004b1a:	f44fe0ef          	jal	8000325e <iupdate>
    80004b1e:	bf71                	j	80004aba <create+0xb6>
  ip->nlink = 0;
    80004b20:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004b24:	8552                	mv	a0,s4
    80004b26:	f38fe0ef          	jal	8000325e <iupdate>
  iunlockput(ip);
    80004b2a:	8552                	mv	a0,s4
    80004b2c:	9f1fe0ef          	jal	8000351c <iunlockput>
  iunlockput(dp);
    80004b30:	8526                	mv	a0,s1
    80004b32:	9ebfe0ef          	jal	8000351c <iunlockput>
  return 0;
    80004b36:	7a02                	ld	s4,32(sp)
    80004b38:	b725                	j	80004a60 <create+0x5c>
    return 0;
    80004b3a:	8aaa                	mv	s5,a0
    80004b3c:	b715                	j	80004a60 <create+0x5c>

0000000080004b3e <sys_dup>:
{
    80004b3e:	7179                	addi	sp,sp,-48
    80004b40:	f406                	sd	ra,40(sp)
    80004b42:	f022                	sd	s0,32(sp)
    80004b44:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004b46:	fd840613          	addi	a2,s0,-40
    80004b4a:	4581                	li	a1,0
    80004b4c:	4501                	li	a0,0
    80004b4e:	e21ff0ef          	jal	8000496e <argfd>
    return -1;
    80004b52:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004b54:	02054363          	bltz	a0,80004b7a <sys_dup+0x3c>
    80004b58:	ec26                	sd	s1,24(sp)
    80004b5a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004b5c:	fd843903          	ld	s2,-40(s0)
    80004b60:	854a                	mv	a0,s2
    80004b62:	e65ff0ef          	jal	800049c6 <fdalloc>
    80004b66:	84aa                	mv	s1,a0
    return -1;
    80004b68:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004b6a:	00054d63          	bltz	a0,80004b84 <sys_dup+0x46>
  filedup(f);
    80004b6e:	854a                	mv	a0,s2
    80004b70:	c2eff0ef          	jal	80003f9e <filedup>
  return fd;
    80004b74:	87a6                	mv	a5,s1
    80004b76:	64e2                	ld	s1,24(sp)
    80004b78:	6942                	ld	s2,16(sp)
}
    80004b7a:	853e                	mv	a0,a5
    80004b7c:	70a2                	ld	ra,40(sp)
    80004b7e:	7402                	ld	s0,32(sp)
    80004b80:	6145                	addi	sp,sp,48
    80004b82:	8082                	ret
    80004b84:	64e2                	ld	s1,24(sp)
    80004b86:	6942                	ld	s2,16(sp)
    80004b88:	bfcd                	j	80004b7a <sys_dup+0x3c>

0000000080004b8a <sys_read>:
{
    80004b8a:	7179                	addi	sp,sp,-48
    80004b8c:	f406                	sd	ra,40(sp)
    80004b8e:	f022                	sd	s0,32(sp)
    80004b90:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b92:	fd840593          	addi	a1,s0,-40
    80004b96:	4505                	li	a0,1
    80004b98:	c5ffd0ef          	jal	800027f6 <argaddr>
  argint(2, &n);
    80004b9c:	fe440593          	addi	a1,s0,-28
    80004ba0:	4509                	li	a0,2
    80004ba2:	c39fd0ef          	jal	800027da <argint>
  if(argfd(0, 0, &f) < 0)
    80004ba6:	fe840613          	addi	a2,s0,-24
    80004baa:	4581                	li	a1,0
    80004bac:	4501                	li	a0,0
    80004bae:	dc1ff0ef          	jal	8000496e <argfd>
    80004bb2:	87aa                	mv	a5,a0
    return -1;
    80004bb4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bb6:	0007ca63          	bltz	a5,80004bca <sys_read+0x40>
  return fileread(f, p, n);
    80004bba:	fe442603          	lw	a2,-28(s0)
    80004bbe:	fd843583          	ld	a1,-40(s0)
    80004bc2:	fe843503          	ld	a0,-24(s0)
    80004bc6:	d3eff0ef          	jal	80004104 <fileread>
}
    80004bca:	70a2                	ld	ra,40(sp)
    80004bcc:	7402                	ld	s0,32(sp)
    80004bce:	6145                	addi	sp,sp,48
    80004bd0:	8082                	ret

0000000080004bd2 <sys_write>:
{
    80004bd2:	7179                	addi	sp,sp,-48
    80004bd4:	f406                	sd	ra,40(sp)
    80004bd6:	f022                	sd	s0,32(sp)
    80004bd8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bda:	fd840593          	addi	a1,s0,-40
    80004bde:	4505                	li	a0,1
    80004be0:	c17fd0ef          	jal	800027f6 <argaddr>
  argint(2, &n);
    80004be4:	fe440593          	addi	a1,s0,-28
    80004be8:	4509                	li	a0,2
    80004bea:	bf1fd0ef          	jal	800027da <argint>
  if(argfd(0, 0, &f) < 0)
    80004bee:	fe840613          	addi	a2,s0,-24
    80004bf2:	4581                	li	a1,0
    80004bf4:	4501                	li	a0,0
    80004bf6:	d79ff0ef          	jal	8000496e <argfd>
    80004bfa:	87aa                	mv	a5,a0
    return -1;
    80004bfc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bfe:	0007ca63          	bltz	a5,80004c12 <sys_write+0x40>
  return filewrite(f, p, n);
    80004c02:	fe442603          	lw	a2,-28(s0)
    80004c06:	fd843583          	ld	a1,-40(s0)
    80004c0a:	fe843503          	ld	a0,-24(s0)
    80004c0e:	db4ff0ef          	jal	800041c2 <filewrite>
}
    80004c12:	70a2                	ld	ra,40(sp)
    80004c14:	7402                	ld	s0,32(sp)
    80004c16:	6145                	addi	sp,sp,48
    80004c18:	8082                	ret

0000000080004c1a <sys_close>:
{
    80004c1a:	1101                	addi	sp,sp,-32
    80004c1c:	ec06                	sd	ra,24(sp)
    80004c1e:	e822                	sd	s0,16(sp)
    80004c20:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004c22:	fe040613          	addi	a2,s0,-32
    80004c26:	fec40593          	addi	a1,s0,-20
    80004c2a:	4501                	li	a0,0
    80004c2c:	d43ff0ef          	jal	8000496e <argfd>
    return -1;
    80004c30:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c32:	02054063          	bltz	a0,80004c52 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c36:	c9bfc0ef          	jal	800018d0 <myproc>
    80004c3a:	fec42783          	lw	a5,-20(s0)
    80004c3e:	07e9                	addi	a5,a5,26
    80004c40:	078e                	slli	a5,a5,0x3
    80004c42:	953e                	add	a0,a0,a5
    80004c44:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c48:	fe043503          	ld	a0,-32(s0)
    80004c4c:	b98ff0ef          	jal	80003fe4 <fileclose>
  return 0;
    80004c50:	4781                	li	a5,0
}
    80004c52:	853e                	mv	a0,a5
    80004c54:	60e2                	ld	ra,24(sp)
    80004c56:	6442                	ld	s0,16(sp)
    80004c58:	6105                	addi	sp,sp,32
    80004c5a:	8082                	ret

0000000080004c5c <sys_fstat>:
{
    80004c5c:	1101                	addi	sp,sp,-32
    80004c5e:	ec06                	sd	ra,24(sp)
    80004c60:	e822                	sd	s0,16(sp)
    80004c62:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c64:	fe040593          	addi	a1,s0,-32
    80004c68:	4505                	li	a0,1
    80004c6a:	b8dfd0ef          	jal	800027f6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c6e:	fe840613          	addi	a2,s0,-24
    80004c72:	4581                	li	a1,0
    80004c74:	4501                	li	a0,0
    80004c76:	cf9ff0ef          	jal	8000496e <argfd>
    80004c7a:	87aa                	mv	a5,a0
    return -1;
    80004c7c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c7e:	0007c863          	bltz	a5,80004c8e <sys_fstat+0x32>
  return filestat(f, st);
    80004c82:	fe043583          	ld	a1,-32(s0)
    80004c86:	fe843503          	ld	a0,-24(s0)
    80004c8a:	c18ff0ef          	jal	800040a2 <filestat>
}
    80004c8e:	60e2                	ld	ra,24(sp)
    80004c90:	6442                	ld	s0,16(sp)
    80004c92:	6105                	addi	sp,sp,32
    80004c94:	8082                	ret

0000000080004c96 <sys_link>:
{
    80004c96:	7169                	addi	sp,sp,-304
    80004c98:	f606                	sd	ra,296(sp)
    80004c9a:	f222                	sd	s0,288(sp)
    80004c9c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c9e:	08000613          	li	a2,128
    80004ca2:	ed040593          	addi	a1,s0,-304
    80004ca6:	4501                	li	a0,0
    80004ca8:	b6bfd0ef          	jal	80002812 <argstr>
    return -1;
    80004cac:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cae:	0c054e63          	bltz	a0,80004d8a <sys_link+0xf4>
    80004cb2:	08000613          	li	a2,128
    80004cb6:	f5040593          	addi	a1,s0,-176
    80004cba:	4505                	li	a0,1
    80004cbc:	b57fd0ef          	jal	80002812 <argstr>
    return -1;
    80004cc0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cc2:	0c054463          	bltz	a0,80004d8a <sys_link+0xf4>
    80004cc6:	ee26                	sd	s1,280(sp)
  begin_op();
    80004cc8:	efdfe0ef          	jal	80003bc4 <begin_op>
  if((ip = namei(old)) == 0){
    80004ccc:	ed040513          	addi	a0,s0,-304
    80004cd0:	d33fe0ef          	jal	80003a02 <namei>
    80004cd4:	84aa                	mv	s1,a0
    80004cd6:	c53d                	beqz	a0,80004d44 <sys_link+0xae>
  ilock(ip);
    80004cd8:	e3afe0ef          	jal	80003312 <ilock>
  if(ip->type == T_DIR){
    80004cdc:	04449703          	lh	a4,68(s1)
    80004ce0:	4785                	li	a5,1
    80004ce2:	06f70663          	beq	a4,a5,80004d4e <sys_link+0xb8>
    80004ce6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004ce8:	04a4d783          	lhu	a5,74(s1)
    80004cec:	2785                	addiw	a5,a5,1
    80004cee:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	d6afe0ef          	jal	8000325e <iupdate>
  iunlock(ip);
    80004cf8:	8526                	mv	a0,s1
    80004cfa:	ec6fe0ef          	jal	800033c0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004cfe:	fd040593          	addi	a1,s0,-48
    80004d02:	f5040513          	addi	a0,s0,-176
    80004d06:	d17fe0ef          	jal	80003a1c <nameiparent>
    80004d0a:	892a                	mv	s2,a0
    80004d0c:	cd21                	beqz	a0,80004d64 <sys_link+0xce>
  ilock(dp);
    80004d0e:	e04fe0ef          	jal	80003312 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004d12:	00092703          	lw	a4,0(s2)
    80004d16:	409c                	lw	a5,0(s1)
    80004d18:	04f71363          	bne	a4,a5,80004d5e <sys_link+0xc8>
    80004d1c:	40d0                	lw	a2,4(s1)
    80004d1e:	fd040593          	addi	a1,s0,-48
    80004d22:	854a                	mv	a0,s2
    80004d24:	c35fe0ef          	jal	80003958 <dirlink>
    80004d28:	02054b63          	bltz	a0,80004d5e <sys_link+0xc8>
  iunlockput(dp);
    80004d2c:	854a                	mv	a0,s2
    80004d2e:	feefe0ef          	jal	8000351c <iunlockput>
  iput(ip);
    80004d32:	8526                	mv	a0,s1
    80004d34:	f60fe0ef          	jal	80003494 <iput>
  end_op();
    80004d38:	ef7fe0ef          	jal	80003c2e <end_op>
  return 0;
    80004d3c:	4781                	li	a5,0
    80004d3e:	64f2                	ld	s1,280(sp)
    80004d40:	6952                	ld	s2,272(sp)
    80004d42:	a0a1                	j	80004d8a <sys_link+0xf4>
    end_op();
    80004d44:	eebfe0ef          	jal	80003c2e <end_op>
    return -1;
    80004d48:	57fd                	li	a5,-1
    80004d4a:	64f2                	ld	s1,280(sp)
    80004d4c:	a83d                	j	80004d8a <sys_link+0xf4>
    iunlockput(ip);
    80004d4e:	8526                	mv	a0,s1
    80004d50:	fccfe0ef          	jal	8000351c <iunlockput>
    end_op();
    80004d54:	edbfe0ef          	jal	80003c2e <end_op>
    return -1;
    80004d58:	57fd                	li	a5,-1
    80004d5a:	64f2                	ld	s1,280(sp)
    80004d5c:	a03d                	j	80004d8a <sys_link+0xf4>
    iunlockput(dp);
    80004d5e:	854a                	mv	a0,s2
    80004d60:	fbcfe0ef          	jal	8000351c <iunlockput>
  ilock(ip);
    80004d64:	8526                	mv	a0,s1
    80004d66:	dacfe0ef          	jal	80003312 <ilock>
  ip->nlink--;
    80004d6a:	04a4d783          	lhu	a5,74(s1)
    80004d6e:	37fd                	addiw	a5,a5,-1
    80004d70:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d74:	8526                	mv	a0,s1
    80004d76:	ce8fe0ef          	jal	8000325e <iupdate>
  iunlockput(ip);
    80004d7a:	8526                	mv	a0,s1
    80004d7c:	fa0fe0ef          	jal	8000351c <iunlockput>
  end_op();
    80004d80:	eaffe0ef          	jal	80003c2e <end_op>
  return -1;
    80004d84:	57fd                	li	a5,-1
    80004d86:	64f2                	ld	s1,280(sp)
    80004d88:	6952                	ld	s2,272(sp)
}
    80004d8a:	853e                	mv	a0,a5
    80004d8c:	70b2                	ld	ra,296(sp)
    80004d8e:	7412                	ld	s0,288(sp)
    80004d90:	6155                	addi	sp,sp,304
    80004d92:	8082                	ret

0000000080004d94 <sys_unlink>:
{
    80004d94:	7111                	addi	sp,sp,-256
    80004d96:	fd86                	sd	ra,248(sp)
    80004d98:	f9a2                	sd	s0,240(sp)
    80004d9a:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80004d9c:	08000613          	li	a2,128
    80004da0:	f2040593          	addi	a1,s0,-224
    80004da4:	4501                	li	a0,0
    80004da6:	a6dfd0ef          	jal	80002812 <argstr>
    80004daa:	16054663          	bltz	a0,80004f16 <sys_unlink+0x182>
    80004dae:	f5a6                	sd	s1,232(sp)
  begin_op();
    80004db0:	e15fe0ef          	jal	80003bc4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004db4:	fa040593          	addi	a1,s0,-96
    80004db8:	f2040513          	addi	a0,s0,-224
    80004dbc:	c61fe0ef          	jal	80003a1c <nameiparent>
    80004dc0:	84aa                	mv	s1,a0
    80004dc2:	c955                	beqz	a0,80004e76 <sys_unlink+0xe2>
  ilock(dp);
    80004dc4:	d4efe0ef          	jal	80003312 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004dc8:	00003597          	auipc	a1,0x3
    80004dcc:	86058593          	addi	a1,a1,-1952 # 80007628 <etext+0x628>
    80004dd0:	fa040513          	addi	a0,s0,-96
    80004dd4:	98dfe0ef          	jal	80003760 <namecmp>
    80004dd8:	12050463          	beqz	a0,80004f00 <sys_unlink+0x16c>
    80004ddc:	00003597          	auipc	a1,0x3
    80004de0:	85458593          	addi	a1,a1,-1964 # 80007630 <etext+0x630>
    80004de4:	fa040513          	addi	a0,s0,-96
    80004de8:	979fe0ef          	jal	80003760 <namecmp>
    80004dec:	10050a63          	beqz	a0,80004f00 <sys_unlink+0x16c>
    80004df0:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004df2:	f1c40613          	addi	a2,s0,-228
    80004df6:	fa040593          	addi	a1,s0,-96
    80004dfa:	8526                	mv	a0,s1
    80004dfc:	97bfe0ef          	jal	80003776 <dirlookup>
    80004e00:	892a                	mv	s2,a0
    80004e02:	0e050e63          	beqz	a0,80004efe <sys_unlink+0x16a>
    80004e06:	edce                	sd	s3,216(sp)
  ilock(ip);
    80004e08:	d0afe0ef          	jal	80003312 <ilock>
  if(ip->nlink < 1)
    80004e0c:	04a91783          	lh	a5,74(s2)
    80004e10:	06f05863          	blez	a5,80004e80 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004e14:	04491703          	lh	a4,68(s2)
    80004e18:	4785                	li	a5,1
    80004e1a:	06f70b63          	beq	a4,a5,80004e90 <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80004e1e:	fb040993          	addi	s3,s0,-80
    80004e22:	4641                	li	a2,16
    80004e24:	4581                	li	a1,0
    80004e26:	854e                	mv	a0,s3
    80004e28:	ea7fb0ef          	jal	80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e2c:	4741                	li	a4,16
    80004e2e:	f1c42683          	lw	a3,-228(s0)
    80004e32:	864e                	mv	a2,s3
    80004e34:	4581                	li	a1,0
    80004e36:	8526                	mv	a0,s1
    80004e38:	825fe0ef          	jal	8000365c <writei>
    80004e3c:	47c1                	li	a5,16
    80004e3e:	08f51f63          	bne	a0,a5,80004edc <sys_unlink+0x148>
  if(ip->type == T_DIR){
    80004e42:	04491703          	lh	a4,68(s2)
    80004e46:	4785                	li	a5,1
    80004e48:	0af70263          	beq	a4,a5,80004eec <sys_unlink+0x158>
  iunlockput(dp);
    80004e4c:	8526                	mv	a0,s1
    80004e4e:	ecefe0ef          	jal	8000351c <iunlockput>
  ip->nlink--;
    80004e52:	04a95783          	lhu	a5,74(s2)
    80004e56:	37fd                	addiw	a5,a5,-1
    80004e58:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e5c:	854a                	mv	a0,s2
    80004e5e:	c00fe0ef          	jal	8000325e <iupdate>
  iunlockput(ip);
    80004e62:	854a                	mv	a0,s2
    80004e64:	eb8fe0ef          	jal	8000351c <iunlockput>
  end_op();
    80004e68:	dc7fe0ef          	jal	80003c2e <end_op>
  return 0;
    80004e6c:	4501                	li	a0,0
    80004e6e:	74ae                	ld	s1,232(sp)
    80004e70:	790e                	ld	s2,224(sp)
    80004e72:	69ee                	ld	s3,216(sp)
    80004e74:	a869                	j	80004f0e <sys_unlink+0x17a>
    end_op();
    80004e76:	db9fe0ef          	jal	80003c2e <end_op>
    return -1;
    80004e7a:	557d                	li	a0,-1
    80004e7c:	74ae                	ld	s1,232(sp)
    80004e7e:	a841                	j	80004f0e <sys_unlink+0x17a>
    80004e80:	e9d2                	sd	s4,208(sp)
    80004e82:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80004e84:	00002517          	auipc	a0,0x2
    80004e88:	7b450513          	addi	a0,a0,1972 # 80007638 <etext+0x638>
    80004e8c:	913fb0ef          	jal	8000079e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e90:	04c92703          	lw	a4,76(s2)
    80004e94:	02000793          	li	a5,32
    80004e98:	f8e7f3e3          	bgeu	a5,a4,80004e1e <sys_unlink+0x8a>
    80004e9c:	e9d2                	sd	s4,208(sp)
    80004e9e:	e5d6                	sd	s5,200(sp)
    80004ea0:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ea2:	f0840a93          	addi	s5,s0,-248
    80004ea6:	4a41                	li	s4,16
    80004ea8:	8752                	mv	a4,s4
    80004eaa:	86ce                	mv	a3,s3
    80004eac:	8656                	mv	a2,s5
    80004eae:	4581                	li	a1,0
    80004eb0:	854a                	mv	a0,s2
    80004eb2:	eb8fe0ef          	jal	8000356a <readi>
    80004eb6:	01451d63          	bne	a0,s4,80004ed0 <sys_unlink+0x13c>
    if(de.inum != 0)
    80004eba:	f0845783          	lhu	a5,-248(s0)
    80004ebe:	efb1                	bnez	a5,80004f1a <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ec0:	29c1                	addiw	s3,s3,16
    80004ec2:	04c92783          	lw	a5,76(s2)
    80004ec6:	fef9e1e3          	bltu	s3,a5,80004ea8 <sys_unlink+0x114>
    80004eca:	6a4e                	ld	s4,208(sp)
    80004ecc:	6aae                	ld	s5,200(sp)
    80004ece:	bf81                	j	80004e1e <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004ed0:	00002517          	auipc	a0,0x2
    80004ed4:	78050513          	addi	a0,a0,1920 # 80007650 <etext+0x650>
    80004ed8:	8c7fb0ef          	jal	8000079e <panic>
    80004edc:	e9d2                	sd	s4,208(sp)
    80004ede:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80004ee0:	00002517          	auipc	a0,0x2
    80004ee4:	78850513          	addi	a0,a0,1928 # 80007668 <etext+0x668>
    80004ee8:	8b7fb0ef          	jal	8000079e <panic>
    dp->nlink--;
    80004eec:	04a4d783          	lhu	a5,74(s1)
    80004ef0:	37fd                	addiw	a5,a5,-1
    80004ef2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ef6:	8526                	mv	a0,s1
    80004ef8:	b66fe0ef          	jal	8000325e <iupdate>
    80004efc:	bf81                	j	80004e4c <sys_unlink+0xb8>
    80004efe:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80004f00:	8526                	mv	a0,s1
    80004f02:	e1afe0ef          	jal	8000351c <iunlockput>
  end_op();
    80004f06:	d29fe0ef          	jal	80003c2e <end_op>
  return -1;
    80004f0a:	557d                	li	a0,-1
    80004f0c:	74ae                	ld	s1,232(sp)
}
    80004f0e:	70ee                	ld	ra,248(sp)
    80004f10:	744e                	ld	s0,240(sp)
    80004f12:	6111                	addi	sp,sp,256
    80004f14:	8082                	ret
    return -1;
    80004f16:	557d                	li	a0,-1
    80004f18:	bfdd                	j	80004f0e <sys_unlink+0x17a>
    iunlockput(ip);
    80004f1a:	854a                	mv	a0,s2
    80004f1c:	e00fe0ef          	jal	8000351c <iunlockput>
    goto bad;
    80004f20:	790e                	ld	s2,224(sp)
    80004f22:	69ee                	ld	s3,216(sp)
    80004f24:	6a4e                	ld	s4,208(sp)
    80004f26:	6aae                	ld	s5,200(sp)
    80004f28:	bfe1                	j	80004f00 <sys_unlink+0x16c>

0000000080004f2a <sys_open>:

uint64
sys_open(void)
{
    80004f2a:	7131                	addi	sp,sp,-192
    80004f2c:	fd06                	sd	ra,184(sp)
    80004f2e:	f922                	sd	s0,176(sp)
    80004f30:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f32:	f4c40593          	addi	a1,s0,-180
    80004f36:	4505                	li	a0,1
    80004f38:	8a3fd0ef          	jal	800027da <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f3c:	08000613          	li	a2,128
    80004f40:	f5040593          	addi	a1,s0,-176
    80004f44:	4501                	li	a0,0
    80004f46:	8cdfd0ef          	jal	80002812 <argstr>
    80004f4a:	87aa                	mv	a5,a0
    return -1;
    80004f4c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f4e:	0a07c363          	bltz	a5,80004ff4 <sys_open+0xca>
    80004f52:	f526                	sd	s1,168(sp)

  begin_op();
    80004f54:	c71fe0ef          	jal	80003bc4 <begin_op>

  if(omode & O_CREATE){
    80004f58:	f4c42783          	lw	a5,-180(s0)
    80004f5c:	2007f793          	andi	a5,a5,512
    80004f60:	c3dd                	beqz	a5,80005006 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80004f62:	4681                	li	a3,0
    80004f64:	4601                	li	a2,0
    80004f66:	4589                	li	a1,2
    80004f68:	f5040513          	addi	a0,s0,-176
    80004f6c:	a99ff0ef          	jal	80004a04 <create>
    80004f70:	84aa                	mv	s1,a0
    if(ip == 0){
    80004f72:	c549                	beqz	a0,80004ffc <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004f74:	04449703          	lh	a4,68(s1)
    80004f78:	478d                	li	a5,3
    80004f7a:	00f71763          	bne	a4,a5,80004f88 <sys_open+0x5e>
    80004f7e:	0464d703          	lhu	a4,70(s1)
    80004f82:	47a5                	li	a5,9
    80004f84:	0ae7ee63          	bltu	a5,a4,80005040 <sys_open+0x116>
    80004f88:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f8a:	fb7fe0ef          	jal	80003f40 <filealloc>
    80004f8e:	892a                	mv	s2,a0
    80004f90:	c561                	beqz	a0,80005058 <sys_open+0x12e>
    80004f92:	ed4e                	sd	s3,152(sp)
    80004f94:	a33ff0ef          	jal	800049c6 <fdalloc>
    80004f98:	89aa                	mv	s3,a0
    80004f9a:	0a054b63          	bltz	a0,80005050 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f9e:	04449703          	lh	a4,68(s1)
    80004fa2:	478d                	li	a5,3
    80004fa4:	0cf70363          	beq	a4,a5,8000506a <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004fa8:	4789                	li	a5,2
    80004faa:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004fae:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004fb2:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004fb6:	f4c42783          	lw	a5,-180(s0)
    80004fba:	0017f713          	andi	a4,a5,1
    80004fbe:	00174713          	xori	a4,a4,1
    80004fc2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004fc6:	0037f713          	andi	a4,a5,3
    80004fca:	00e03733          	snez	a4,a4
    80004fce:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004fd2:	4007f793          	andi	a5,a5,1024
    80004fd6:	c791                	beqz	a5,80004fe2 <sys_open+0xb8>
    80004fd8:	04449703          	lh	a4,68(s1)
    80004fdc:	4789                	li	a5,2
    80004fde:	08f70d63          	beq	a4,a5,80005078 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80004fe2:	8526                	mv	a0,s1
    80004fe4:	bdcfe0ef          	jal	800033c0 <iunlock>
  end_op();
    80004fe8:	c47fe0ef          	jal	80003c2e <end_op>

  return fd;
    80004fec:	854e                	mv	a0,s3
    80004fee:	74aa                	ld	s1,168(sp)
    80004ff0:	790a                	ld	s2,160(sp)
    80004ff2:	69ea                	ld	s3,152(sp)
}
    80004ff4:	70ea                	ld	ra,184(sp)
    80004ff6:	744a                	ld	s0,176(sp)
    80004ff8:	6129                	addi	sp,sp,192
    80004ffa:	8082                	ret
      end_op();
    80004ffc:	c33fe0ef          	jal	80003c2e <end_op>
      return -1;
    80005000:	557d                	li	a0,-1
    80005002:	74aa                	ld	s1,168(sp)
    80005004:	bfc5                	j	80004ff4 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005006:	f5040513          	addi	a0,s0,-176
    8000500a:	9f9fe0ef          	jal	80003a02 <namei>
    8000500e:	84aa                	mv	s1,a0
    80005010:	c11d                	beqz	a0,80005036 <sys_open+0x10c>
    ilock(ip);
    80005012:	b00fe0ef          	jal	80003312 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005016:	04449703          	lh	a4,68(s1)
    8000501a:	4785                	li	a5,1
    8000501c:	f4f71ce3          	bne	a4,a5,80004f74 <sys_open+0x4a>
    80005020:	f4c42783          	lw	a5,-180(s0)
    80005024:	d3b5                	beqz	a5,80004f88 <sys_open+0x5e>
      iunlockput(ip);
    80005026:	8526                	mv	a0,s1
    80005028:	cf4fe0ef          	jal	8000351c <iunlockput>
      end_op();
    8000502c:	c03fe0ef          	jal	80003c2e <end_op>
      return -1;
    80005030:	557d                	li	a0,-1
    80005032:	74aa                	ld	s1,168(sp)
    80005034:	b7c1                	j	80004ff4 <sys_open+0xca>
      end_op();
    80005036:	bf9fe0ef          	jal	80003c2e <end_op>
      return -1;
    8000503a:	557d                	li	a0,-1
    8000503c:	74aa                	ld	s1,168(sp)
    8000503e:	bf5d                	j	80004ff4 <sys_open+0xca>
    iunlockput(ip);
    80005040:	8526                	mv	a0,s1
    80005042:	cdafe0ef          	jal	8000351c <iunlockput>
    end_op();
    80005046:	be9fe0ef          	jal	80003c2e <end_op>
    return -1;
    8000504a:	557d                	li	a0,-1
    8000504c:	74aa                	ld	s1,168(sp)
    8000504e:	b75d                	j	80004ff4 <sys_open+0xca>
      fileclose(f);
    80005050:	854a                	mv	a0,s2
    80005052:	f93fe0ef          	jal	80003fe4 <fileclose>
    80005056:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005058:	8526                	mv	a0,s1
    8000505a:	cc2fe0ef          	jal	8000351c <iunlockput>
    end_op();
    8000505e:	bd1fe0ef          	jal	80003c2e <end_op>
    return -1;
    80005062:	557d                	li	a0,-1
    80005064:	74aa                	ld	s1,168(sp)
    80005066:	790a                	ld	s2,160(sp)
    80005068:	b771                	j	80004ff4 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000506a:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000506e:	04649783          	lh	a5,70(s1)
    80005072:	02f91223          	sh	a5,36(s2)
    80005076:	bf35                	j	80004fb2 <sys_open+0x88>
    itrunc(ip);
    80005078:	8526                	mv	a0,s1
    8000507a:	b86fe0ef          	jal	80003400 <itrunc>
    8000507e:	b795                	j	80004fe2 <sys_open+0xb8>

0000000080005080 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005080:	7175                	addi	sp,sp,-144
    80005082:	e506                	sd	ra,136(sp)
    80005084:	e122                	sd	s0,128(sp)
    80005086:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005088:	b3dfe0ef          	jal	80003bc4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000508c:	08000613          	li	a2,128
    80005090:	f7040593          	addi	a1,s0,-144
    80005094:	4501                	li	a0,0
    80005096:	f7cfd0ef          	jal	80002812 <argstr>
    8000509a:	02054363          	bltz	a0,800050c0 <sys_mkdir+0x40>
    8000509e:	4681                	li	a3,0
    800050a0:	4601                	li	a2,0
    800050a2:	4585                	li	a1,1
    800050a4:	f7040513          	addi	a0,s0,-144
    800050a8:	95dff0ef          	jal	80004a04 <create>
    800050ac:	c911                	beqz	a0,800050c0 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050ae:	c6efe0ef          	jal	8000351c <iunlockput>
  end_op();
    800050b2:	b7dfe0ef          	jal	80003c2e <end_op>
  return 0;
    800050b6:	4501                	li	a0,0
}
    800050b8:	60aa                	ld	ra,136(sp)
    800050ba:	640a                	ld	s0,128(sp)
    800050bc:	6149                	addi	sp,sp,144
    800050be:	8082                	ret
    end_op();
    800050c0:	b6ffe0ef          	jal	80003c2e <end_op>
    return -1;
    800050c4:	557d                	li	a0,-1
    800050c6:	bfcd                	j	800050b8 <sys_mkdir+0x38>

00000000800050c8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800050c8:	7135                	addi	sp,sp,-160
    800050ca:	ed06                	sd	ra,152(sp)
    800050cc:	e922                	sd	s0,144(sp)
    800050ce:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800050d0:	af5fe0ef          	jal	80003bc4 <begin_op>
  argint(1, &major);
    800050d4:	f6c40593          	addi	a1,s0,-148
    800050d8:	4505                	li	a0,1
    800050da:	f00fd0ef          	jal	800027da <argint>
  argint(2, &minor);
    800050de:	f6840593          	addi	a1,s0,-152
    800050e2:	4509                	li	a0,2
    800050e4:	ef6fd0ef          	jal	800027da <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050e8:	08000613          	li	a2,128
    800050ec:	f7040593          	addi	a1,s0,-144
    800050f0:	4501                	li	a0,0
    800050f2:	f20fd0ef          	jal	80002812 <argstr>
    800050f6:	02054563          	bltz	a0,80005120 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800050fa:	f6841683          	lh	a3,-152(s0)
    800050fe:	f6c41603          	lh	a2,-148(s0)
    80005102:	458d                	li	a1,3
    80005104:	f7040513          	addi	a0,s0,-144
    80005108:	8fdff0ef          	jal	80004a04 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000510c:	c911                	beqz	a0,80005120 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000510e:	c0efe0ef          	jal	8000351c <iunlockput>
  end_op();
    80005112:	b1dfe0ef          	jal	80003c2e <end_op>
  return 0;
    80005116:	4501                	li	a0,0
}
    80005118:	60ea                	ld	ra,152(sp)
    8000511a:	644a                	ld	s0,144(sp)
    8000511c:	610d                	addi	sp,sp,160
    8000511e:	8082                	ret
    end_op();
    80005120:	b0ffe0ef          	jal	80003c2e <end_op>
    return -1;
    80005124:	557d                	li	a0,-1
    80005126:	bfcd                	j	80005118 <sys_mknod+0x50>

0000000080005128 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005128:	7135                	addi	sp,sp,-160
    8000512a:	ed06                	sd	ra,152(sp)
    8000512c:	e922                	sd	s0,144(sp)
    8000512e:	e14a                	sd	s2,128(sp)
    80005130:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005132:	f9efc0ef          	jal	800018d0 <myproc>
    80005136:	892a                	mv	s2,a0
  
  begin_op();
    80005138:	a8dfe0ef          	jal	80003bc4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000513c:	08000613          	li	a2,128
    80005140:	f6040593          	addi	a1,s0,-160
    80005144:	4501                	li	a0,0
    80005146:	eccfd0ef          	jal	80002812 <argstr>
    8000514a:	04054363          	bltz	a0,80005190 <sys_chdir+0x68>
    8000514e:	e526                	sd	s1,136(sp)
    80005150:	f6040513          	addi	a0,s0,-160
    80005154:	8affe0ef          	jal	80003a02 <namei>
    80005158:	84aa                	mv	s1,a0
    8000515a:	c915                	beqz	a0,8000518e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000515c:	9b6fe0ef          	jal	80003312 <ilock>
  if(ip->type != T_DIR){
    80005160:	04449703          	lh	a4,68(s1)
    80005164:	4785                	li	a5,1
    80005166:	02f71963          	bne	a4,a5,80005198 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000516a:	8526                	mv	a0,s1
    8000516c:	a54fe0ef          	jal	800033c0 <iunlock>
  iput(p->cwd);
    80005170:	15093503          	ld	a0,336(s2)
    80005174:	b20fe0ef          	jal	80003494 <iput>
  end_op();
    80005178:	ab7fe0ef          	jal	80003c2e <end_op>
  p->cwd = ip;
    8000517c:	14993823          	sd	s1,336(s2)
  return 0;
    80005180:	4501                	li	a0,0
    80005182:	64aa                	ld	s1,136(sp)
}
    80005184:	60ea                	ld	ra,152(sp)
    80005186:	644a                	ld	s0,144(sp)
    80005188:	690a                	ld	s2,128(sp)
    8000518a:	610d                	addi	sp,sp,160
    8000518c:	8082                	ret
    8000518e:	64aa                	ld	s1,136(sp)
    end_op();
    80005190:	a9ffe0ef          	jal	80003c2e <end_op>
    return -1;
    80005194:	557d                	li	a0,-1
    80005196:	b7fd                	j	80005184 <sys_chdir+0x5c>
    iunlockput(ip);
    80005198:	8526                	mv	a0,s1
    8000519a:	b82fe0ef          	jal	8000351c <iunlockput>
    end_op();
    8000519e:	a91fe0ef          	jal	80003c2e <end_op>
    return -1;
    800051a2:	557d                	li	a0,-1
    800051a4:	64aa                	ld	s1,136(sp)
    800051a6:	bff9                	j	80005184 <sys_chdir+0x5c>

00000000800051a8 <sys_exec>:

uint64
sys_exec(void)
{
    800051a8:	7105                	addi	sp,sp,-480
    800051aa:	ef86                	sd	ra,472(sp)
    800051ac:	eba2                	sd	s0,464(sp)
    800051ae:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800051b0:	e2840593          	addi	a1,s0,-472
    800051b4:	4505                	li	a0,1
    800051b6:	e40fd0ef          	jal	800027f6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800051ba:	08000613          	li	a2,128
    800051be:	f3040593          	addi	a1,s0,-208
    800051c2:	4501                	li	a0,0
    800051c4:	e4efd0ef          	jal	80002812 <argstr>
    800051c8:	87aa                	mv	a5,a0
    return -1;
    800051ca:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800051cc:	0e07c063          	bltz	a5,800052ac <sys_exec+0x104>
    800051d0:	e7a6                	sd	s1,456(sp)
    800051d2:	e3ca                	sd	s2,448(sp)
    800051d4:	ff4e                	sd	s3,440(sp)
    800051d6:	fb52                	sd	s4,432(sp)
    800051d8:	f756                	sd	s5,424(sp)
    800051da:	f35a                	sd	s6,416(sp)
    800051dc:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800051de:	e3040a13          	addi	s4,s0,-464
    800051e2:	10000613          	li	a2,256
    800051e6:	4581                	li	a1,0
    800051e8:	8552                	mv	a0,s4
    800051ea:	ae5fb0ef          	jal	80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800051ee:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800051f0:	89d2                	mv	s3,s4
    800051f2:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051f4:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051f8:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800051fa:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051fe:	00391513          	slli	a0,s2,0x3
    80005202:	85d6                	mv	a1,s5
    80005204:	e2843783          	ld	a5,-472(s0)
    80005208:	953e                	add	a0,a0,a5
    8000520a:	d46fd0ef          	jal	80002750 <fetchaddr>
    8000520e:	02054663          	bltz	a0,8000523a <sys_exec+0x92>
    if(uarg == 0){
    80005212:	e2043783          	ld	a5,-480(s0)
    80005216:	c7a1                	beqz	a5,8000525e <sys_exec+0xb6>
    argv[i] = kalloc();
    80005218:	913fb0ef          	jal	80000b2a <kalloc>
    8000521c:	85aa                	mv	a1,a0
    8000521e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005222:	cd01                	beqz	a0,8000523a <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005224:	865a                	mv	a2,s6
    80005226:	e2043503          	ld	a0,-480(s0)
    8000522a:	d70fd0ef          	jal	8000279a <fetchstr>
    8000522e:	00054663          	bltz	a0,8000523a <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005232:	0905                	addi	s2,s2,1
    80005234:	09a1                	addi	s3,s3,8
    80005236:	fd7914e3          	bne	s2,s7,800051fe <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000523a:	100a0a13          	addi	s4,s4,256
    8000523e:	6088                	ld	a0,0(s1)
    80005240:	cd31                	beqz	a0,8000529c <sys_exec+0xf4>
    kfree(argv[i]);
    80005242:	807fb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005246:	04a1                	addi	s1,s1,8
    80005248:	ff449be3          	bne	s1,s4,8000523e <sys_exec+0x96>
  return -1;
    8000524c:	557d                	li	a0,-1
    8000524e:	64be                	ld	s1,456(sp)
    80005250:	691e                	ld	s2,448(sp)
    80005252:	79fa                	ld	s3,440(sp)
    80005254:	7a5a                	ld	s4,432(sp)
    80005256:	7aba                	ld	s5,424(sp)
    80005258:	7b1a                	ld	s6,416(sp)
    8000525a:	6bfa                	ld	s7,408(sp)
    8000525c:	a881                	j	800052ac <sys_exec+0x104>
      argv[i] = 0;
    8000525e:	0009079b          	sext.w	a5,s2
    80005262:	e3040593          	addi	a1,s0,-464
    80005266:	078e                	slli	a5,a5,0x3
    80005268:	97ae                	add	a5,a5,a1
    8000526a:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    8000526e:	f3040513          	addi	a0,s0,-208
    80005272:	ba4ff0ef          	jal	80004616 <exec>
    80005276:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005278:	100a0a13          	addi	s4,s4,256
    8000527c:	6088                	ld	a0,0(s1)
    8000527e:	c511                	beqz	a0,8000528a <sys_exec+0xe2>
    kfree(argv[i]);
    80005280:	fc8fb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005284:	04a1                	addi	s1,s1,8
    80005286:	ff449be3          	bne	s1,s4,8000527c <sys_exec+0xd4>
  return ret;
    8000528a:	854a                	mv	a0,s2
    8000528c:	64be                	ld	s1,456(sp)
    8000528e:	691e                	ld	s2,448(sp)
    80005290:	79fa                	ld	s3,440(sp)
    80005292:	7a5a                	ld	s4,432(sp)
    80005294:	7aba                	ld	s5,424(sp)
    80005296:	7b1a                	ld	s6,416(sp)
    80005298:	6bfa                	ld	s7,408(sp)
    8000529a:	a809                	j	800052ac <sys_exec+0x104>
  return -1;
    8000529c:	557d                	li	a0,-1
    8000529e:	64be                	ld	s1,456(sp)
    800052a0:	691e                	ld	s2,448(sp)
    800052a2:	79fa                	ld	s3,440(sp)
    800052a4:	7a5a                	ld	s4,432(sp)
    800052a6:	7aba                	ld	s5,424(sp)
    800052a8:	7b1a                	ld	s6,416(sp)
    800052aa:	6bfa                	ld	s7,408(sp)
}
    800052ac:	60fe                	ld	ra,472(sp)
    800052ae:	645e                	ld	s0,464(sp)
    800052b0:	613d                	addi	sp,sp,480
    800052b2:	8082                	ret

00000000800052b4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800052b4:	7139                	addi	sp,sp,-64
    800052b6:	fc06                	sd	ra,56(sp)
    800052b8:	f822                	sd	s0,48(sp)
    800052ba:	f426                	sd	s1,40(sp)
    800052bc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800052be:	e12fc0ef          	jal	800018d0 <myproc>
    800052c2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800052c4:	fd840593          	addi	a1,s0,-40
    800052c8:	4501                	li	a0,0
    800052ca:	d2cfd0ef          	jal	800027f6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800052ce:	fc840593          	addi	a1,s0,-56
    800052d2:	fd040513          	addi	a0,s0,-48
    800052d6:	81eff0ef          	jal	800042f4 <pipealloc>
    return -1;
    800052da:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800052dc:	0a054463          	bltz	a0,80005384 <sys_pipe+0xd0>
  fd0 = -1;
    800052e0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800052e4:	fd043503          	ld	a0,-48(s0)
    800052e8:	edeff0ef          	jal	800049c6 <fdalloc>
    800052ec:	fca42223          	sw	a0,-60(s0)
    800052f0:	08054163          	bltz	a0,80005372 <sys_pipe+0xbe>
    800052f4:	fc843503          	ld	a0,-56(s0)
    800052f8:	eceff0ef          	jal	800049c6 <fdalloc>
    800052fc:	fca42023          	sw	a0,-64(s0)
    80005300:	06054063          	bltz	a0,80005360 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005304:	4691                	li	a3,4
    80005306:	fc440613          	addi	a2,s0,-60
    8000530a:	fd843583          	ld	a1,-40(s0)
    8000530e:	68a8                	ld	a0,80(s1)
    80005310:	a74fc0ef          	jal	80001584 <copyout>
    80005314:	00054e63          	bltz	a0,80005330 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005318:	4691                	li	a3,4
    8000531a:	fc040613          	addi	a2,s0,-64
    8000531e:	fd843583          	ld	a1,-40(s0)
    80005322:	95b6                	add	a1,a1,a3
    80005324:	68a8                	ld	a0,80(s1)
    80005326:	a5efc0ef          	jal	80001584 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000532a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000532c:	04055c63          	bgez	a0,80005384 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005330:	fc442783          	lw	a5,-60(s0)
    80005334:	07e9                	addi	a5,a5,26
    80005336:	078e                	slli	a5,a5,0x3
    80005338:	97a6                	add	a5,a5,s1
    8000533a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000533e:	fc042783          	lw	a5,-64(s0)
    80005342:	07e9                	addi	a5,a5,26
    80005344:	078e                	slli	a5,a5,0x3
    80005346:	94be                	add	s1,s1,a5
    80005348:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000534c:	fd043503          	ld	a0,-48(s0)
    80005350:	c95fe0ef          	jal	80003fe4 <fileclose>
    fileclose(wf);
    80005354:	fc843503          	ld	a0,-56(s0)
    80005358:	c8dfe0ef          	jal	80003fe4 <fileclose>
    return -1;
    8000535c:	57fd                	li	a5,-1
    8000535e:	a01d                	j	80005384 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005360:	fc442783          	lw	a5,-60(s0)
    80005364:	0007c763          	bltz	a5,80005372 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005368:	07e9                	addi	a5,a5,26
    8000536a:	078e                	slli	a5,a5,0x3
    8000536c:	97a6                	add	a5,a5,s1
    8000536e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005372:	fd043503          	ld	a0,-48(s0)
    80005376:	c6ffe0ef          	jal	80003fe4 <fileclose>
    fileclose(wf);
    8000537a:	fc843503          	ld	a0,-56(s0)
    8000537e:	c67fe0ef          	jal	80003fe4 <fileclose>
    return -1;
    80005382:	57fd                	li	a5,-1
}
    80005384:	853e                	mv	a0,a5
    80005386:	70e2                	ld	ra,56(sp)
    80005388:	7442                	ld	s0,48(sp)
    8000538a:	74a2                	ld	s1,40(sp)
    8000538c:	6121                	addi	sp,sp,64
    8000538e:	8082                	ret

0000000080005390 <kernelvec>:
    80005390:	7111                	addi	sp,sp,-256
    80005392:	e006                	sd	ra,0(sp)
    80005394:	e40a                	sd	sp,8(sp)
    80005396:	e80e                	sd	gp,16(sp)
    80005398:	ec12                	sd	tp,24(sp)
    8000539a:	f016                	sd	t0,32(sp)
    8000539c:	f41a                	sd	t1,40(sp)
    8000539e:	f81e                	sd	t2,48(sp)
    800053a0:	e4aa                	sd	a0,72(sp)
    800053a2:	e8ae                	sd	a1,80(sp)
    800053a4:	ecb2                	sd	a2,88(sp)
    800053a6:	f0b6                	sd	a3,96(sp)
    800053a8:	f4ba                	sd	a4,104(sp)
    800053aa:	f8be                	sd	a5,112(sp)
    800053ac:	fcc2                	sd	a6,120(sp)
    800053ae:	e146                	sd	a7,128(sp)
    800053b0:	edf2                	sd	t3,216(sp)
    800053b2:	f1f6                	sd	t4,224(sp)
    800053b4:	f5fa                	sd	t5,232(sp)
    800053b6:	f9fe                	sd	t6,240(sp)
    800053b8:	aa8fd0ef          	jal	80002660 <kerneltrap>
    800053bc:	6082                	ld	ra,0(sp)
    800053be:	6122                	ld	sp,8(sp)
    800053c0:	61c2                	ld	gp,16(sp)
    800053c2:	7282                	ld	t0,32(sp)
    800053c4:	7322                	ld	t1,40(sp)
    800053c6:	73c2                	ld	t2,48(sp)
    800053c8:	6526                	ld	a0,72(sp)
    800053ca:	65c6                	ld	a1,80(sp)
    800053cc:	6666                	ld	a2,88(sp)
    800053ce:	7686                	ld	a3,96(sp)
    800053d0:	7726                	ld	a4,104(sp)
    800053d2:	77c6                	ld	a5,112(sp)
    800053d4:	7866                	ld	a6,120(sp)
    800053d6:	688a                	ld	a7,128(sp)
    800053d8:	6e6e                	ld	t3,216(sp)
    800053da:	7e8e                	ld	t4,224(sp)
    800053dc:	7f2e                	ld	t5,232(sp)
    800053de:	7fce                	ld	t6,240(sp)
    800053e0:	6111                	addi	sp,sp,256
    800053e2:	10200073          	sret
	...

00000000800053ee <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053ee:	1141                	addi	sp,sp,-16
    800053f0:	e406                	sd	ra,8(sp)
    800053f2:	e022                	sd	s0,0(sp)
    800053f4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800053f6:	0c000737          	lui	a4,0xc000
    800053fa:	4785                	li	a5,1
    800053fc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800053fe:	c35c                	sw	a5,4(a4)
}
    80005400:	60a2                	ld	ra,8(sp)
    80005402:	6402                	ld	s0,0(sp)
    80005404:	0141                	addi	sp,sp,16
    80005406:	8082                	ret

0000000080005408 <plicinithart>:

void
plicinithart(void)
{
    80005408:	1141                	addi	sp,sp,-16
    8000540a:	e406                	sd	ra,8(sp)
    8000540c:	e022                	sd	s0,0(sp)
    8000540e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005410:	c8cfc0ef          	jal	8000189c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005414:	0085171b          	slliw	a4,a0,0x8
    80005418:	0c0027b7          	lui	a5,0xc002
    8000541c:	97ba                	add	a5,a5,a4
    8000541e:	40200713          	li	a4,1026
    80005422:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005426:	00d5151b          	slliw	a0,a0,0xd
    8000542a:	0c2017b7          	lui	a5,0xc201
    8000542e:	97aa                	add	a5,a5,a0
    80005430:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005434:	60a2                	ld	ra,8(sp)
    80005436:	6402                	ld	s0,0(sp)
    80005438:	0141                	addi	sp,sp,16
    8000543a:	8082                	ret

000000008000543c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000543c:	1141                	addi	sp,sp,-16
    8000543e:	e406                	sd	ra,8(sp)
    80005440:	e022                	sd	s0,0(sp)
    80005442:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005444:	c58fc0ef          	jal	8000189c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005448:	00d5151b          	slliw	a0,a0,0xd
    8000544c:	0c2017b7          	lui	a5,0xc201
    80005450:	97aa                	add	a5,a5,a0
  return irq;
}
    80005452:	43c8                	lw	a0,4(a5)
    80005454:	60a2                	ld	ra,8(sp)
    80005456:	6402                	ld	s0,0(sp)
    80005458:	0141                	addi	sp,sp,16
    8000545a:	8082                	ret

000000008000545c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000545c:	1101                	addi	sp,sp,-32
    8000545e:	ec06                	sd	ra,24(sp)
    80005460:	e822                	sd	s0,16(sp)
    80005462:	e426                	sd	s1,8(sp)
    80005464:	1000                	addi	s0,sp,32
    80005466:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005468:	c34fc0ef          	jal	8000189c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000546c:	00d5179b          	slliw	a5,a0,0xd
    80005470:	0c201737          	lui	a4,0xc201
    80005474:	97ba                	add	a5,a5,a4
    80005476:	c3c4                	sw	s1,4(a5)
}
    80005478:	60e2                	ld	ra,24(sp)
    8000547a:	6442                	ld	s0,16(sp)
    8000547c:	64a2                	ld	s1,8(sp)
    8000547e:	6105                	addi	sp,sp,32
    80005480:	8082                	ret

0000000080005482 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005482:	1141                	addi	sp,sp,-16
    80005484:	e406                	sd	ra,8(sp)
    80005486:	e022                	sd	s0,0(sp)
    80005488:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000548a:	479d                	li	a5,7
    8000548c:	04a7ca63          	blt	a5,a0,800054e0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005490:	0001f797          	auipc	a5,0x1f
    80005494:	da878793          	addi	a5,a5,-600 # 80024238 <disk>
    80005498:	97aa                	add	a5,a5,a0
    8000549a:	0187c783          	lbu	a5,24(a5)
    8000549e:	e7b9                	bnez	a5,800054ec <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800054a0:	00451693          	slli	a3,a0,0x4
    800054a4:	0001f797          	auipc	a5,0x1f
    800054a8:	d9478793          	addi	a5,a5,-620 # 80024238 <disk>
    800054ac:	6398                	ld	a4,0(a5)
    800054ae:	9736                	add	a4,a4,a3
    800054b0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800054b4:	6398                	ld	a4,0(a5)
    800054b6:	9736                	add	a4,a4,a3
    800054b8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800054bc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800054c0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800054c4:	97aa                	add	a5,a5,a0
    800054c6:	4705                	li	a4,1
    800054c8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800054cc:	0001f517          	auipc	a0,0x1f
    800054d0:	d8450513          	addi	a0,a0,-636 # 80024250 <disk+0x18>
    800054d4:	a2ffc0ef          	jal	80001f02 <wakeup>
}
    800054d8:	60a2                	ld	ra,8(sp)
    800054da:	6402                	ld	s0,0(sp)
    800054dc:	0141                	addi	sp,sp,16
    800054de:	8082                	ret
    panic("free_desc 1");
    800054e0:	00002517          	auipc	a0,0x2
    800054e4:	19850513          	addi	a0,a0,408 # 80007678 <etext+0x678>
    800054e8:	ab6fb0ef          	jal	8000079e <panic>
    panic("free_desc 2");
    800054ec:	00002517          	auipc	a0,0x2
    800054f0:	19c50513          	addi	a0,a0,412 # 80007688 <etext+0x688>
    800054f4:	aaafb0ef          	jal	8000079e <panic>

00000000800054f8 <virtio_disk_init>:
{
    800054f8:	1101                	addi	sp,sp,-32
    800054fa:	ec06                	sd	ra,24(sp)
    800054fc:	e822                	sd	s0,16(sp)
    800054fe:	e426                	sd	s1,8(sp)
    80005500:	e04a                	sd	s2,0(sp)
    80005502:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005504:	00002597          	auipc	a1,0x2
    80005508:	19458593          	addi	a1,a1,404 # 80007698 <etext+0x698>
    8000550c:	0001f517          	auipc	a0,0x1f
    80005510:	e5450513          	addi	a0,a0,-428 # 80024360 <disk+0x128>
    80005514:	e66fb0ef          	jal	80000b7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005518:	100017b7          	lui	a5,0x10001
    8000551c:	4398                	lw	a4,0(a5)
    8000551e:	2701                	sext.w	a4,a4
    80005520:	747277b7          	lui	a5,0x74727
    80005524:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005528:	14f71863          	bne	a4,a5,80005678 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000552c:	100017b7          	lui	a5,0x10001
    80005530:	43dc                	lw	a5,4(a5)
    80005532:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005534:	4709                	li	a4,2
    80005536:	14e79163          	bne	a5,a4,80005678 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000553a:	100017b7          	lui	a5,0x10001
    8000553e:	479c                	lw	a5,8(a5)
    80005540:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005542:	12e79b63          	bne	a5,a4,80005678 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005546:	100017b7          	lui	a5,0x10001
    8000554a:	47d8                	lw	a4,12(a5)
    8000554c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000554e:	554d47b7          	lui	a5,0x554d4
    80005552:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005556:	12f71163          	bne	a4,a5,80005678 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000555a:	100017b7          	lui	a5,0x10001
    8000555e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005562:	4705                	li	a4,1
    80005564:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005566:	470d                	li	a4,3
    80005568:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000556a:	10001737          	lui	a4,0x10001
    8000556e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005570:	c7ffe6b7          	lui	a3,0xc7ffe
    80005574:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fda3e7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005578:	8f75                	and	a4,a4,a3
    8000557a:	100016b7          	lui	a3,0x10001
    8000557e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005580:	472d                	li	a4,11
    80005582:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005584:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005588:	439c                	lw	a5,0(a5)
    8000558a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000558e:	8ba1                	andi	a5,a5,8
    80005590:	0e078a63          	beqz	a5,80005684 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005594:	100017b7          	lui	a5,0x10001
    80005598:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000559c:	43fc                	lw	a5,68(a5)
    8000559e:	2781                	sext.w	a5,a5
    800055a0:	0e079863          	bnez	a5,80005690 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800055a4:	100017b7          	lui	a5,0x10001
    800055a8:	5bdc                	lw	a5,52(a5)
    800055aa:	2781                	sext.w	a5,a5
  if(max == 0)
    800055ac:	0e078863          	beqz	a5,8000569c <virtio_disk_init+0x1a4>
  if(max < NUM)
    800055b0:	471d                	li	a4,7
    800055b2:	0ef77b63          	bgeu	a4,a5,800056a8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800055b6:	d74fb0ef          	jal	80000b2a <kalloc>
    800055ba:	0001f497          	auipc	s1,0x1f
    800055be:	c7e48493          	addi	s1,s1,-898 # 80024238 <disk>
    800055c2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800055c4:	d66fb0ef          	jal	80000b2a <kalloc>
    800055c8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800055ca:	d60fb0ef          	jal	80000b2a <kalloc>
    800055ce:	87aa                	mv	a5,a0
    800055d0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800055d2:	6088                	ld	a0,0(s1)
    800055d4:	0e050063          	beqz	a0,800056b4 <virtio_disk_init+0x1bc>
    800055d8:	0001f717          	auipc	a4,0x1f
    800055dc:	c6873703          	ld	a4,-920(a4) # 80024240 <disk+0x8>
    800055e0:	cb71                	beqz	a4,800056b4 <virtio_disk_init+0x1bc>
    800055e2:	cbe9                	beqz	a5,800056b4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800055e4:	6605                	lui	a2,0x1
    800055e6:	4581                	li	a1,0
    800055e8:	ee6fb0ef          	jal	80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    800055ec:	0001f497          	auipc	s1,0x1f
    800055f0:	c4c48493          	addi	s1,s1,-948 # 80024238 <disk>
    800055f4:	6605                	lui	a2,0x1
    800055f6:	4581                	li	a1,0
    800055f8:	6488                	ld	a0,8(s1)
    800055fa:	ed4fb0ef          	jal	80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    800055fe:	6605                	lui	a2,0x1
    80005600:	4581                	li	a1,0
    80005602:	6888                	ld	a0,16(s1)
    80005604:	ecafb0ef          	jal	80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005608:	100017b7          	lui	a5,0x10001
    8000560c:	4721                	li	a4,8
    8000560e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005610:	4098                	lw	a4,0(s1)
    80005612:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005616:	40d8                	lw	a4,4(s1)
    80005618:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000561c:	649c                	ld	a5,8(s1)
    8000561e:	0007869b          	sext.w	a3,a5
    80005622:	10001737          	lui	a4,0x10001
    80005626:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000562a:	9781                	srai	a5,a5,0x20
    8000562c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005630:	689c                	ld	a5,16(s1)
    80005632:	0007869b          	sext.w	a3,a5
    80005636:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000563a:	9781                	srai	a5,a5,0x20
    8000563c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005640:	4785                	li	a5,1
    80005642:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005644:	00f48c23          	sb	a5,24(s1)
    80005648:	00f48ca3          	sb	a5,25(s1)
    8000564c:	00f48d23          	sb	a5,26(s1)
    80005650:	00f48da3          	sb	a5,27(s1)
    80005654:	00f48e23          	sb	a5,28(s1)
    80005658:	00f48ea3          	sb	a5,29(s1)
    8000565c:	00f48f23          	sb	a5,30(s1)
    80005660:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005664:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005668:	07272823          	sw	s2,112(a4)
}
    8000566c:	60e2                	ld	ra,24(sp)
    8000566e:	6442                	ld	s0,16(sp)
    80005670:	64a2                	ld	s1,8(sp)
    80005672:	6902                	ld	s2,0(sp)
    80005674:	6105                	addi	sp,sp,32
    80005676:	8082                	ret
    panic("could not find virtio disk");
    80005678:	00002517          	auipc	a0,0x2
    8000567c:	03050513          	addi	a0,a0,48 # 800076a8 <etext+0x6a8>
    80005680:	91efb0ef          	jal	8000079e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005684:	00002517          	auipc	a0,0x2
    80005688:	04450513          	addi	a0,a0,68 # 800076c8 <etext+0x6c8>
    8000568c:	912fb0ef          	jal	8000079e <panic>
    panic("virtio disk should not be ready");
    80005690:	00002517          	auipc	a0,0x2
    80005694:	05850513          	addi	a0,a0,88 # 800076e8 <etext+0x6e8>
    80005698:	906fb0ef          	jal	8000079e <panic>
    panic("virtio disk has no queue 0");
    8000569c:	00002517          	auipc	a0,0x2
    800056a0:	06c50513          	addi	a0,a0,108 # 80007708 <etext+0x708>
    800056a4:	8fafb0ef          	jal	8000079e <panic>
    panic("virtio disk max queue too short");
    800056a8:	00002517          	auipc	a0,0x2
    800056ac:	08050513          	addi	a0,a0,128 # 80007728 <etext+0x728>
    800056b0:	8eefb0ef          	jal	8000079e <panic>
    panic("virtio disk kalloc");
    800056b4:	00002517          	auipc	a0,0x2
    800056b8:	09450513          	addi	a0,a0,148 # 80007748 <etext+0x748>
    800056bc:	8e2fb0ef          	jal	8000079e <panic>

00000000800056c0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800056c0:	711d                	addi	sp,sp,-96
    800056c2:	ec86                	sd	ra,88(sp)
    800056c4:	e8a2                	sd	s0,80(sp)
    800056c6:	e4a6                	sd	s1,72(sp)
    800056c8:	e0ca                	sd	s2,64(sp)
    800056ca:	fc4e                	sd	s3,56(sp)
    800056cc:	f852                	sd	s4,48(sp)
    800056ce:	f456                	sd	s5,40(sp)
    800056d0:	f05a                	sd	s6,32(sp)
    800056d2:	ec5e                	sd	s7,24(sp)
    800056d4:	e862                	sd	s8,16(sp)
    800056d6:	1080                	addi	s0,sp,96
    800056d8:	89aa                	mv	s3,a0
    800056da:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800056dc:	00c52b83          	lw	s7,12(a0)
    800056e0:	001b9b9b          	slliw	s7,s7,0x1
    800056e4:	1b82                	slli	s7,s7,0x20
    800056e6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800056ea:	0001f517          	auipc	a0,0x1f
    800056ee:	c7650513          	addi	a0,a0,-906 # 80024360 <disk+0x128>
    800056f2:	d0cfb0ef          	jal	80000bfe <acquire>
  for(int i = 0; i < NUM; i++){
    800056f6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056f8:	0001fa97          	auipc	s5,0x1f
    800056fc:	b40a8a93          	addi	s5,s5,-1216 # 80024238 <disk>
  for(int i = 0; i < 3; i++){
    80005700:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005702:	5c7d                	li	s8,-1
    80005704:	a095                	j	80005768 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005706:	00fa8733          	add	a4,s5,a5
    8000570a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000570e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005710:	0207c563          	bltz	a5,8000573a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005714:	2905                	addiw	s2,s2,1
    80005716:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005718:	05490c63          	beq	s2,s4,80005770 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000571c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000571e:	0001f717          	auipc	a4,0x1f
    80005722:	b1a70713          	addi	a4,a4,-1254 # 80024238 <disk>
    80005726:	4781                	li	a5,0
    if(disk.free[i]){
    80005728:	01874683          	lbu	a3,24(a4)
    8000572c:	fee9                	bnez	a3,80005706 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000572e:	2785                	addiw	a5,a5,1
    80005730:	0705                	addi	a4,a4,1
    80005732:	fe979be3          	bne	a5,s1,80005728 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005736:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000573a:	01205d63          	blez	s2,80005754 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000573e:	fa042503          	lw	a0,-96(s0)
    80005742:	d41ff0ef          	jal	80005482 <free_desc>
      for(int j = 0; j < i; j++)
    80005746:	4785                	li	a5,1
    80005748:	0127d663          	bge	a5,s2,80005754 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000574c:	fa442503          	lw	a0,-92(s0)
    80005750:	d33ff0ef          	jal	80005482 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005754:	0001f597          	auipc	a1,0x1f
    80005758:	c0c58593          	addi	a1,a1,-1012 # 80024360 <disk+0x128>
    8000575c:	0001f517          	auipc	a0,0x1f
    80005760:	af450513          	addi	a0,a0,-1292 # 80024250 <disk+0x18>
    80005764:	f52fc0ef          	jal	80001eb6 <sleep>
  for(int i = 0; i < 3; i++){
    80005768:	fa040613          	addi	a2,s0,-96
    8000576c:	4901                	li	s2,0
    8000576e:	b77d                	j	8000571c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005770:	fa042503          	lw	a0,-96(s0)
    80005774:	00451693          	slli	a3,a0,0x4

  if(write)
    80005778:	0001f797          	auipc	a5,0x1f
    8000577c:	ac078793          	addi	a5,a5,-1344 # 80024238 <disk>
    80005780:	00a50713          	addi	a4,a0,10
    80005784:	0712                	slli	a4,a4,0x4
    80005786:	973e                	add	a4,a4,a5
    80005788:	01603633          	snez	a2,s6
    8000578c:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000578e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005792:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005796:	6398                	ld	a4,0(a5)
    80005798:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000579a:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    8000579e:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800057a0:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800057a2:	6390                	ld	a2,0(a5)
    800057a4:	00d605b3          	add	a1,a2,a3
    800057a8:	4741                	li	a4,16
    800057aa:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800057ac:	4805                	li	a6,1
    800057ae:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800057b2:	fa442703          	lw	a4,-92(s0)
    800057b6:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800057ba:	0712                	slli	a4,a4,0x4
    800057bc:	963a                	add	a2,a2,a4
    800057be:	05898593          	addi	a1,s3,88
    800057c2:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800057c4:	0007b883          	ld	a7,0(a5)
    800057c8:	9746                	add	a4,a4,a7
    800057ca:	40000613          	li	a2,1024
    800057ce:	c710                	sw	a2,8(a4)
  if(write)
    800057d0:	001b3613          	seqz	a2,s6
    800057d4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800057d8:	01066633          	or	a2,a2,a6
    800057dc:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800057e0:	fa842583          	lw	a1,-88(s0)
    800057e4:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800057e8:	00250613          	addi	a2,a0,2
    800057ec:	0612                	slli	a2,a2,0x4
    800057ee:	963e                	add	a2,a2,a5
    800057f0:	577d                	li	a4,-1
    800057f2:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057f6:	0592                	slli	a1,a1,0x4
    800057f8:	98ae                	add	a7,a7,a1
    800057fa:	03068713          	addi	a4,a3,48
    800057fe:	973e                	add	a4,a4,a5
    80005800:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005804:	6398                	ld	a4,0(a5)
    80005806:	972e                	add	a4,a4,a1
    80005808:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000580c:	4689                	li	a3,2
    8000580e:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005812:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005816:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    8000581a:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000581e:	6794                	ld	a3,8(a5)
    80005820:	0026d703          	lhu	a4,2(a3)
    80005824:	8b1d                	andi	a4,a4,7
    80005826:	0706                	slli	a4,a4,0x1
    80005828:	96ba                	add	a3,a3,a4
    8000582a:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000582e:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005832:	6798                	ld	a4,8(a5)
    80005834:	00275783          	lhu	a5,2(a4)
    80005838:	2785                	addiw	a5,a5,1
    8000583a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000583e:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005842:	100017b7          	lui	a5,0x10001
    80005846:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000584a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    8000584e:	0001f917          	auipc	s2,0x1f
    80005852:	b1290913          	addi	s2,s2,-1262 # 80024360 <disk+0x128>
  while(b->disk == 1) {
    80005856:	84c2                	mv	s1,a6
    80005858:	01079a63          	bne	a5,a6,8000586c <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    8000585c:	85ca                	mv	a1,s2
    8000585e:	854e                	mv	a0,s3
    80005860:	e56fc0ef          	jal	80001eb6 <sleep>
  while(b->disk == 1) {
    80005864:	0049a783          	lw	a5,4(s3)
    80005868:	fe978ae3          	beq	a5,s1,8000585c <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    8000586c:	fa042903          	lw	s2,-96(s0)
    80005870:	00290713          	addi	a4,s2,2
    80005874:	0712                	slli	a4,a4,0x4
    80005876:	0001f797          	auipc	a5,0x1f
    8000587a:	9c278793          	addi	a5,a5,-1598 # 80024238 <disk>
    8000587e:	97ba                	add	a5,a5,a4
    80005880:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005884:	0001f997          	auipc	s3,0x1f
    80005888:	9b498993          	addi	s3,s3,-1612 # 80024238 <disk>
    8000588c:	00491713          	slli	a4,s2,0x4
    80005890:	0009b783          	ld	a5,0(s3)
    80005894:	97ba                	add	a5,a5,a4
    80005896:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000589a:	854a                	mv	a0,s2
    8000589c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800058a0:	be3ff0ef          	jal	80005482 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800058a4:	8885                	andi	s1,s1,1
    800058a6:	f0fd                	bnez	s1,8000588c <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800058a8:	0001f517          	auipc	a0,0x1f
    800058ac:	ab850513          	addi	a0,a0,-1352 # 80024360 <disk+0x128>
    800058b0:	be2fb0ef          	jal	80000c92 <release>
}
    800058b4:	60e6                	ld	ra,88(sp)
    800058b6:	6446                	ld	s0,80(sp)
    800058b8:	64a6                	ld	s1,72(sp)
    800058ba:	6906                	ld	s2,64(sp)
    800058bc:	79e2                	ld	s3,56(sp)
    800058be:	7a42                	ld	s4,48(sp)
    800058c0:	7aa2                	ld	s5,40(sp)
    800058c2:	7b02                	ld	s6,32(sp)
    800058c4:	6be2                	ld	s7,24(sp)
    800058c6:	6c42                	ld	s8,16(sp)
    800058c8:	6125                	addi	sp,sp,96
    800058ca:	8082                	ret

00000000800058cc <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800058cc:	1101                	addi	sp,sp,-32
    800058ce:	ec06                	sd	ra,24(sp)
    800058d0:	e822                	sd	s0,16(sp)
    800058d2:	e426                	sd	s1,8(sp)
    800058d4:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800058d6:	0001f497          	auipc	s1,0x1f
    800058da:	96248493          	addi	s1,s1,-1694 # 80024238 <disk>
    800058de:	0001f517          	auipc	a0,0x1f
    800058e2:	a8250513          	addi	a0,a0,-1406 # 80024360 <disk+0x128>
    800058e6:	b18fb0ef          	jal	80000bfe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058ea:	100017b7          	lui	a5,0x10001
    800058ee:	53bc                	lw	a5,96(a5)
    800058f0:	8b8d                	andi	a5,a5,3
    800058f2:	10001737          	lui	a4,0x10001
    800058f6:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800058f8:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058fc:	689c                	ld	a5,16(s1)
    800058fe:	0204d703          	lhu	a4,32(s1)
    80005902:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005906:	04f70663          	beq	a4,a5,80005952 <virtio_disk_intr+0x86>
    __sync_synchronize();
    8000590a:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000590e:	6898                	ld	a4,16(s1)
    80005910:	0204d783          	lhu	a5,32(s1)
    80005914:	8b9d                	andi	a5,a5,7
    80005916:	078e                	slli	a5,a5,0x3
    80005918:	97ba                	add	a5,a5,a4
    8000591a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000591c:	00278713          	addi	a4,a5,2
    80005920:	0712                	slli	a4,a4,0x4
    80005922:	9726                	add	a4,a4,s1
    80005924:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005928:	e321                	bnez	a4,80005968 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000592a:	0789                	addi	a5,a5,2
    8000592c:	0792                	slli	a5,a5,0x4
    8000592e:	97a6                	add	a5,a5,s1
    80005930:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005932:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005936:	dccfc0ef          	jal	80001f02 <wakeup>

    disk.used_idx += 1;
    8000593a:	0204d783          	lhu	a5,32(s1)
    8000593e:	2785                	addiw	a5,a5,1
    80005940:	17c2                	slli	a5,a5,0x30
    80005942:	93c1                	srli	a5,a5,0x30
    80005944:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005948:	6898                	ld	a4,16(s1)
    8000594a:	00275703          	lhu	a4,2(a4)
    8000594e:	faf71ee3          	bne	a4,a5,8000590a <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005952:	0001f517          	auipc	a0,0x1f
    80005956:	a0e50513          	addi	a0,a0,-1522 # 80024360 <disk+0x128>
    8000595a:	b38fb0ef          	jal	80000c92 <release>
}
    8000595e:	60e2                	ld	ra,24(sp)
    80005960:	6442                	ld	s0,16(sp)
    80005962:	64a2                	ld	s1,8(sp)
    80005964:	6105                	addi	sp,sp,32
    80005966:	8082                	ret
      panic("virtio_disk_intr status");
    80005968:	00002517          	auipc	a0,0x2
    8000596c:	df850513          	addi	a0,a0,-520 # 80007760 <etext+0x760>
    80005970:	e2ffa0ef          	jal	8000079e <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
