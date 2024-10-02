
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	31013103          	ld	sp,784(sp) # 8000a310 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda8a7>
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
    80000106:	164020ef          	jal	8000226a <either_copyin>
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
    8000016a:	20a50513          	addi	a0,a0,522 # 80012370 <cons>
    8000016e:	291000ef          	jal	80000bfe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000172:	00012497          	auipc	s1,0x12
    80000176:	1fe48493          	addi	s1,s1,510 # 80012370 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000017a:	00012917          	auipc	s2,0x12
    8000017e:	28e90913          	addi	s2,s2,654 # 80012408 <cons+0x98>
  while(n > 0){
    80000182:	0b305b63          	blez	s3,80000238 <consoleread+0xee>
    while(cons.r == cons.w){
    80000186:	0984a783          	lw	a5,152(s1)
    8000018a:	09c4a703          	lw	a4,156(s1)
    8000018e:	0af71063          	bne	a4,a5,8000022e <consoleread+0xe4>
      if(killed(myproc())){
    80000192:	74a010ef          	jal	800018dc <myproc>
    80000196:	76d010ef          	jal	80002102 <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	52b010ef          	jal	80001eca <sleep>
    while(cons.r == cons.w){
    800001a4:	0984a783          	lw	a5,152(s1)
    800001a8:	09c4a703          	lw	a4,156(s1)
    800001ac:	fef703e3          	beq	a4,a5,80000192 <consoleread+0x48>
    800001b0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001b2:	00012717          	auipc	a4,0x12
    800001b6:	1be70713          	addi	a4,a4,446 # 80012370 <cons>
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
    800001e4:	03c020ef          	jal	80002220 <either_copyout>
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
    80000200:	17450513          	addi	a0,a0,372 # 80012370 <cons>
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
    80000226:	1ef72323          	sw	a5,486(a4) # 80012408 <cons+0x98>
    8000022a:	6be2                	ld	s7,24(sp)
    8000022c:	a031                	j	80000238 <consoleread+0xee>
    8000022e:	ec5e                	sd	s7,24(sp)
    80000230:	b749                	j	800001b2 <consoleread+0x68>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	a011                	j	80000238 <consoleread+0xee>
    80000236:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	13850513          	addi	a0,a0,312 # 80012370 <cons>
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
    80000290:	0e450513          	addi	a0,a0,228 # 80012370 <cons>
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
    800002ae:	006020ef          	jal	800022b4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002b2:	00012517          	auipc	a0,0x12
    800002b6:	0be50513          	addi	a0,a0,190 # 80012370 <cons>
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
    800002d4:	0a070713          	addi	a4,a4,160 # 80012370 <cons>
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
    800002fa:	07a78793          	addi	a5,a5,122 # 80012370 <cons>
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
    80000326:	0e67a783          	lw	a5,230(a5) # 80012408 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f8f711e3          	bne	a4,a5,800002b2 <consoleintr+0x32>
    80000334:	a85d                	j	800003ea <consoleintr+0x16a>
    80000336:	e84a                	sd	s2,16(sp)
    80000338:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    8000033a:	00012717          	auipc	a4,0x12
    8000033e:	03670713          	addi	a4,a4,54 # 80012370 <cons>
    80000342:	0a072783          	lw	a5,160(a4)
    80000346:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	00012497          	auipc	s1,0x12
    8000034e:	02648493          	addi	s1,s1,38 # 80012370 <cons>
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
    80000398:	fdc70713          	addi	a4,a4,-36 # 80012370 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
    800003a4:	f0f707e3          	beq	a4,a5,800002b2 <consoleintr+0x32>
      cons.e--;
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	00012717          	auipc	a4,0x12
    800003ae:	06f72323          	sw	a5,102(a4) # 80012410 <cons+0xa0>
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
    800003cc:	fa878793          	addi	a5,a5,-88 # 80012370 <cons>
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
    800003ee:	02c7a123          	sw	a2,34(a5) # 8001240c <cons+0x9c>
        wakeup(&cons.r);
    800003f2:	00012517          	auipc	a0,0x12
    800003f6:	01650513          	addi	a0,a0,22 # 80012408 <cons+0x98>
    800003fa:	31d010ef          	jal	80001f16 <wakeup>
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
    80000414:	f6050513          	addi	a0,a0,-160 # 80012370 <cons>
    80000418:	762000ef          	jal	80000b7a <initlock>

  uartinit();
    8000041c:	3ea000ef          	jal	80000806 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000420:	00023797          	auipc	a5,0x23
    80000424:	9a078793          	addi	a5,a5,-1632 # 80022dc0 <devsw>
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
    800004f0:	f447a783          	lw	a5,-188(a5) # 80012430 <pr+0x18>
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
    8000053c:	ee050513          	addi	a0,a0,-288 # 80012418 <pr>
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
    80000794:	c8850513          	addi	a0,a0,-888 # 80012418 <pr>
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
    800007ae:	c807a323          	sw	zero,-890(a5) # 80012430 <pr+0x18>
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
    800007d2:	b6f72123          	sw	a5,-1182(a4) # 8000a330 <panicked>
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
    800007e6:	c3648493          	addi	s1,s1,-970 # 80012418 <pr>
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
    8000084c:	bf050513          	addi	a0,a0,-1040 # 80012438 <uart_tx_lock>
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
    80000870:	ac47a783          	lw	a5,-1340(a5) # 8000a330 <panicked>
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
    800008a6:	a967b783          	ld	a5,-1386(a5) # 8000a338 <uart_tx_r>
    800008aa:	0000a717          	auipc	a4,0xa
    800008ae:	a9673703          	ld	a4,-1386(a4) # 8000a340 <uart_tx_w>
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
    800008d4:	b68a8a93          	addi	s5,s5,-1176 # 80012438 <uart_tx_lock>
    uart_tx_r += 1;
    800008d8:	0000a497          	auipc	s1,0xa
    800008dc:	a6048493          	addi	s1,s1,-1440 # 8000a338 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008e0:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e4:	0000a997          	auipc	s3,0xa
    800008e8:	a5c98993          	addi	s3,s3,-1444 # 8000a340 <uart_tx_w>
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
    80000906:	610010ef          	jal	80001f16 <wakeup>
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
    80000954:	ae850513          	addi	a0,a0,-1304 # 80012438 <uart_tx_lock>
    80000958:	2a6000ef          	jal	80000bfe <acquire>
  if(panicked){
    8000095c:	0000a797          	auipc	a5,0xa
    80000960:	9d47a783          	lw	a5,-1580(a5) # 8000a330 <panicked>
    80000964:	efbd                	bnez	a5,800009e2 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000966:	0000a717          	auipc	a4,0xa
    8000096a:	9da73703          	ld	a4,-1574(a4) # 8000a340 <uart_tx_w>
    8000096e:	0000a797          	auipc	a5,0xa
    80000972:	9ca7b783          	ld	a5,-1590(a5) # 8000a338 <uart_tx_r>
    80000976:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	00012997          	auipc	s3,0x12
    8000097e:	abe98993          	addi	s3,s3,-1346 # 80012438 <uart_tx_lock>
    80000982:	0000a497          	auipc	s1,0xa
    80000986:	9b648493          	addi	s1,s1,-1610 # 8000a338 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000098a:	0000a917          	auipc	s2,0xa
    8000098e:	9b690913          	addi	s2,s2,-1610 # 8000a340 <uart_tx_w>
    80000992:	00e79d63          	bne	a5,a4,800009ac <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000996:	85ce                	mv	a1,s3
    80000998:	8526                	mv	a0,s1
    8000099a:	530010ef          	jal	80001eca <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099e:	00093703          	ld	a4,0(s2)
    800009a2:	609c                	ld	a5,0(s1)
    800009a4:	02078793          	addi	a5,a5,32
    800009a8:	fee787e3          	beq	a5,a4,80000996 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009ac:	00012497          	auipc	s1,0x12
    800009b0:	a8c48493          	addi	s1,s1,-1396 # 80012438 <uart_tx_lock>
    800009b4:	01f77793          	andi	a5,a4,31
    800009b8:	97a6                	add	a5,a5,s1
    800009ba:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009be:	0705                	addi	a4,a4,1
    800009c0:	0000a797          	auipc	a5,0xa
    800009c4:	98e7b023          	sd	a4,-1664(a5) # 8000a340 <uart_tx_w>
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
    80000a2a:	a1248493          	addi	s1,s1,-1518 # 80012438 <uart_tx_lock>
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
    80000a5c:	00023797          	auipc	a5,0x23
    80000a60:	4fc78793          	addi	a5,a5,1276 # 80023f58 <end>
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
    80000a7c:	9f890913          	addi	s2,s2,-1544 # 80012470 <kmem>
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
    80000b0a:	96a50513          	addi	a0,a0,-1686 # 80012470 <kmem>
    80000b0e:	06c000ef          	jal	80000b7a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b12:	45c5                	li	a1,17
    80000b14:	05ee                	slli	a1,a1,0x1b
    80000b16:	00023517          	auipc	a0,0x23
    80000b1a:	44250513          	addi	a0,a0,1090 # 80023f58 <end>
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
    80000b38:	93c48493          	addi	s1,s1,-1732 # 80012470 <kmem>
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	0c0000ef          	jal	80000bfe <acquire>
  r = kmem.freelist;
    80000b42:	6c84                	ld	s1,24(s1)
  if(r)
    80000b44:	c485                	beqz	s1,80000b6c <kalloc+0x42>
    kmem.freelist = r->next;
    80000b46:	609c                	ld	a5,0(s1)
    80000b48:	00012517          	auipc	a0,0x12
    80000b4c:	92850513          	addi	a0,a0,-1752 # 80012470 <kmem>
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
    80000b70:	90450513          	addi	a0,a0,-1788 # 80012470 <kmem>
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
    80000ba8:	515000ef          	jal	800018bc <mycpu>
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
    80000bd6:	4e7000ef          	jal	800018bc <mycpu>
    80000bda:	5d3c                	lw	a5,120(a0)
    80000bdc:	cb99                	beqz	a5,80000bf2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bde:	4df000ef          	jal	800018bc <mycpu>
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
    80000bf2:	4cb000ef          	jal	800018bc <mycpu>
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
    80000c26:	497000ef          	jal	800018bc <mycpu>
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
    80000c4a:	473000ef          	jal	800018bc <mycpu>
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
    80000d4c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb0a9>
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
    80000e8c:	21d000ef          	jal	800018a8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e90:	00009717          	auipc	a4,0x9
    80000e94:	4b870713          	addi	a4,a4,1208 # 8000a348 <started>
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
    80000ea4:	205000ef          	jal	800018a8 <cpuid>
    80000ea8:	85aa                	mv	a1,a0
    80000eaa:	00006517          	auipc	a0,0x6
    80000eae:	1ee50513          	addi	a0,a0,494 # 80007098 <etext+0x98>
    80000eb2:	e1cff0ef          	jal	800004ce <printf>
    kvminithart();    // turn on paging
    80000eb6:	080000ef          	jal	80000f36 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eba:	52c010ef          	jal	800023e6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	53a040ef          	jal	800053f8 <plicinithart>
  }

  scheduler();        
    80000ec2:	66f000ef          	jal	80001d30 <scheduler>
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
    80000efe:	0fb000ef          	jal	800017f8 <procinit>
    trapinit();      // trap vectors
    80000f02:	4c0010ef          	jal	800023c2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f06:	4e0010ef          	jal	800023e6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f0a:	4d4040ef          	jal	800053de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f0e:	4ea040ef          	jal	800053f8 <plicinithart>
    binit();         // buffer cache
    80000f12:	44b010ef          	jal	80002b5c <binit>
    iinit();         // inode table
    80000f16:	216020ef          	jal	8000312c <iinit>
    fileinit();      // file table
    80000f1a:	7e5020ef          	jal	80003efe <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1e:	5ca040ef          	jal	800054e8 <virtio_disk_init>
    userinit();      // first user process
    80000f22:	423000ef          	jal	80001b44 <userinit>
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    started = 1;
    80000f2a:	4785                	li	a5,1
    80000f2c:	00009717          	auipc	a4,0x9
    80000f30:	40f72e23          	sw	a5,1052(a4) # 8000a348 <started>
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
    80000f46:	40e7b783          	ld	a5,1038(a5) # 8000a350 <kernel_pagetable>
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
    800011d4:	18a7b023          	sd	a0,384(a5) # 8000a350 <kernel_pagetable>
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
    80001778:	14c48493          	addi	s1,s1,332 # 800128c0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000177c:	8c26                	mv	s8,s1
    8000177e:	1a1f67b7          	lui	a5,0x1a1f6
    80001782:	8d178793          	addi	a5,a5,-1839 # 1a1f58d1 <_entry-0x65e0a72f>
    80001786:	7d634937          	lui	s2,0x7d634
    8000178a:	3eb90913          	addi	s2,s2,1003 # 7d6343eb <_entry-0x29cbc15>
    8000178e:	1902                	slli	s2,s2,0x20
    80001790:	993e                	add	s2,s2,a5
    80001792:	040009b7          	lui	s3,0x4000
    80001796:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001798:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000179a:	4b99                	li	s7,6
    8000179c:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    8000179e:	00017a97          	auipc	s5,0x17
    800017a2:	322a8a93          	addi	s5,s5,802 # 80018ac0 <tickslock>
    char *pa = kalloc();
    800017a6:	b84ff0ef          	jal	80000b2a <kalloc>
    800017aa:	862a                	mv	a2,a0
    if(pa == 0)
    800017ac:	c121                	beqz	a0,800017ec <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    800017ae:	418485b3          	sub	a1,s1,s8
    800017b2:	858d                	srai	a1,a1,0x3
    800017b4:	032585b3          	mul	a1,a1,s2
    800017b8:	2585                	addiw	a1,a1,1
    800017ba:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017be:	875e                	mv	a4,s7
    800017c0:	86da                	mv	a3,s6
    800017c2:	40b985b3          	sub	a1,s3,a1
    800017c6:	8552                	mv	a0,s4
    800017c8:	929ff0ef          	jal	800010f0 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017cc:	18848493          	addi	s1,s1,392
    800017d0:	fd549be3          	bne	s1,s5,800017a6 <proc_mapstacks+0x4c>
  }
}
    800017d4:	60a6                	ld	ra,72(sp)
    800017d6:	6406                	ld	s0,64(sp)
    800017d8:	74e2                	ld	s1,56(sp)
    800017da:	7942                	ld	s2,48(sp)
    800017dc:	79a2                	ld	s3,40(sp)
    800017de:	7a02                	ld	s4,32(sp)
    800017e0:	6ae2                	ld	s5,24(sp)
    800017e2:	6b42                	ld	s6,16(sp)
    800017e4:	6ba2                	ld	s7,8(sp)
    800017e6:	6c02                	ld	s8,0(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
      panic("kalloc");
    800017ec:	00006517          	auipc	a0,0x6
    800017f0:	a0c50513          	addi	a0,a0,-1524 # 800071f8 <etext+0x1f8>
    800017f4:	fabfe0ef          	jal	8000079e <panic>

00000000800017f8 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017f8:	7139                	addi	sp,sp,-64
    800017fa:	fc06                	sd	ra,56(sp)
    800017fc:	f822                	sd	s0,48(sp)
    800017fe:	f426                	sd	s1,40(sp)
    80001800:	f04a                	sd	s2,32(sp)
    80001802:	ec4e                	sd	s3,24(sp)
    80001804:	e852                	sd	s4,16(sp)
    80001806:	e456                	sd	s5,8(sp)
    80001808:	e05a                	sd	s6,0(sp)
    8000180a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000180c:	00006597          	auipc	a1,0x6
    80001810:	9f458593          	addi	a1,a1,-1548 # 80007200 <etext+0x200>
    80001814:	00011517          	auipc	a0,0x11
    80001818:	c7c50513          	addi	a0,a0,-900 # 80012490 <pid_lock>
    8000181c:	b5eff0ef          	jal	80000b7a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001820:	00006597          	auipc	a1,0x6
    80001824:	9e858593          	addi	a1,a1,-1560 # 80007208 <etext+0x208>
    80001828:	00011517          	auipc	a0,0x11
    8000182c:	c8050513          	addi	a0,a0,-896 # 800124a8 <wait_lock>
    80001830:	b4aff0ef          	jal	80000b7a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001834:	00011497          	auipc	s1,0x11
    80001838:	08c48493          	addi	s1,s1,140 # 800128c0 <proc>
      initlock(&p->lock, "proc");
    8000183c:	00006b17          	auipc	s6,0x6
    80001840:	9dcb0b13          	addi	s6,s6,-1572 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001844:	8aa6                	mv	s5,s1
    80001846:	1a1f67b7          	lui	a5,0x1a1f6
    8000184a:	8d178793          	addi	a5,a5,-1839 # 1a1f58d1 <_entry-0x65e0a72f>
    8000184e:	7d634937          	lui	s2,0x7d634
    80001852:	3eb90913          	addi	s2,s2,1003 # 7d6343eb <_entry-0x29cbc15>
    80001856:	1902                	slli	s2,s2,0x20
    80001858:	993e                	add	s2,s2,a5
    8000185a:	040009b7          	lui	s3,0x4000
    8000185e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001862:	00017a17          	auipc	s4,0x17
    80001866:	25ea0a13          	addi	s4,s4,606 # 80018ac0 <tickslock>
      initlock(&p->lock, "proc");
    8000186a:	85da                	mv	a1,s6
    8000186c:	8526                	mv	a0,s1
    8000186e:	b0cff0ef          	jal	80000b7a <initlock>
      p->state = UNUSED;
    80001872:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001876:	415487b3          	sub	a5,s1,s5
    8000187a:	878d                	srai	a5,a5,0x3
    8000187c:	032787b3          	mul	a5,a5,s2
    80001880:	2785                	addiw	a5,a5,1
    80001882:	00d7979b          	slliw	a5,a5,0xd
    80001886:	40f987b3          	sub	a5,s3,a5
    8000188a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188c:	18848493          	addi	s1,s1,392
    80001890:	fd449de3          	bne	s1,s4,8000186a <procinit+0x72>
  }
}
    80001894:	70e2                	ld	ra,56(sp)
    80001896:	7442                	ld	s0,48(sp)
    80001898:	74a2                	ld	s1,40(sp)
    8000189a:	7902                	ld	s2,32(sp)
    8000189c:	69e2                	ld	s3,24(sp)
    8000189e:	6a42                	ld	s4,16(sp)
    800018a0:	6aa2                	ld	s5,8(sp)
    800018a2:	6b02                	ld	s6,0(sp)
    800018a4:	6121                	addi	sp,sp,64
    800018a6:	8082                	ret

00000000800018a8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a8:	1141                	addi	sp,sp,-16
    800018aa:	e406                	sd	ra,8(sp)
    800018ac:	e022                	sd	s0,0(sp)
    800018ae:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018b0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018b2:	2501                	sext.w	a0,a0
    800018b4:	60a2                	ld	ra,8(sp)
    800018b6:	6402                	ld	s0,0(sp)
    800018b8:	0141                	addi	sp,sp,16
    800018ba:	8082                	ret

00000000800018bc <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018bc:	1141                	addi	sp,sp,-16
    800018be:	e406                	sd	ra,8(sp)
    800018c0:	e022                	sd	s0,0(sp)
    800018c2:	0800                	addi	s0,sp,16
    800018c4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018c6:	2781                	sext.w	a5,a5
    800018c8:	079e                	slli	a5,a5,0x7
  return c;
}
    800018ca:	00011517          	auipc	a0,0x11
    800018ce:	bf650513          	addi	a0,a0,-1034 # 800124c0 <cpus>
    800018d2:	953e                	add	a0,a0,a5
    800018d4:	60a2                	ld	ra,8(sp)
    800018d6:	6402                	ld	s0,0(sp)
    800018d8:	0141                	addi	sp,sp,16
    800018da:	8082                	ret

00000000800018dc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018dc:	1101                	addi	sp,sp,-32
    800018de:	ec06                	sd	ra,24(sp)
    800018e0:	e822                	sd	s0,16(sp)
    800018e2:	e426                	sd	s1,8(sp)
    800018e4:	1000                	addi	s0,sp,32
  push_off();
    800018e6:	ad8ff0ef          	jal	80000bbe <push_off>
    800018ea:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018ec:	2781                	sext.w	a5,a5
    800018ee:	079e                	slli	a5,a5,0x7
    800018f0:	00011717          	auipc	a4,0x11
    800018f4:	ba070713          	addi	a4,a4,-1120 # 80012490 <pid_lock>
    800018f8:	97ba                	add	a5,a5,a4
    800018fa:	7b84                	ld	s1,48(a5)
  pop_off();
    800018fc:	b46ff0ef          	jal	80000c42 <pop_off>
  return p;
}
    80001900:	8526                	mv	a0,s1
    80001902:	60e2                	ld	ra,24(sp)
    80001904:	6442                	ld	s0,16(sp)
    80001906:	64a2                	ld	s1,8(sp)
    80001908:	6105                	addi	sp,sp,32
    8000190a:	8082                	ret

000000008000190c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000190c:	1141                	addi	sp,sp,-16
    8000190e:	e406                	sd	ra,8(sp)
    80001910:	e022                	sd	s0,0(sp)
    80001912:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001914:	fc9ff0ef          	jal	800018dc <myproc>
    80001918:	b7aff0ef          	jal	80000c92 <release>

  if (first) {
    8000191c:	00009797          	auipc	a5,0x9
    80001920:	9a47a783          	lw	a5,-1628(a5) # 8000a2c0 <first.1>
    80001924:	e799                	bnez	a5,80001932 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001926:	2dd000ef          	jal	80002402 <usertrapret>
}
    8000192a:	60a2                	ld	ra,8(sp)
    8000192c:	6402                	ld	s0,0(sp)
    8000192e:	0141                	addi	sp,sp,16
    80001930:	8082                	ret
    fsinit(ROOTDEV);
    80001932:	4505                	li	a0,1
    80001934:	78c010ef          	jal	800030c0 <fsinit>
    first = 0;
    80001938:	00009797          	auipc	a5,0x9
    8000193c:	9807a423          	sw	zero,-1656(a5) # 8000a2c0 <first.1>
    __sync_synchronize();
    80001940:	0330000f          	fence	rw,rw
    80001944:	b7cd                	j	80001926 <forkret+0x1a>

0000000080001946 <allocpid>:
{
    80001946:	1101                	addi	sp,sp,-32
    80001948:	ec06                	sd	ra,24(sp)
    8000194a:	e822                	sd	s0,16(sp)
    8000194c:	e426                	sd	s1,8(sp)
    8000194e:	e04a                	sd	s2,0(sp)
    80001950:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001952:	00011917          	auipc	s2,0x11
    80001956:	b3e90913          	addi	s2,s2,-1218 # 80012490 <pid_lock>
    8000195a:	854a                	mv	a0,s2
    8000195c:	aa2ff0ef          	jal	80000bfe <acquire>
  pid = nextpid;
    80001960:	00009797          	auipc	a5,0x9
    80001964:	96478793          	addi	a5,a5,-1692 # 8000a2c4 <nextpid>
    80001968:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196a:	0014871b          	addiw	a4,s1,1
    8000196e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001970:	854a                	mv	a0,s2
    80001972:	b20ff0ef          	jal	80000c92 <release>
}
    80001976:	8526                	mv	a0,s1
    80001978:	60e2                	ld	ra,24(sp)
    8000197a:	6442                	ld	s0,16(sp)
    8000197c:	64a2                	ld	s1,8(sp)
    8000197e:	6902                	ld	s2,0(sp)
    80001980:	6105                	addi	sp,sp,32
    80001982:	8082                	ret

0000000080001984 <proc_pagetable>:
{
    80001984:	1101                	addi	sp,sp,-32
    80001986:	ec06                	sd	ra,24(sp)
    80001988:	e822                	sd	s0,16(sp)
    8000198a:	e426                	sd	s1,8(sp)
    8000198c:	e04a                	sd	s2,0(sp)
    8000198e:	1000                	addi	s0,sp,32
    80001990:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001992:	90bff0ef          	jal	8000129c <uvmcreate>
    80001996:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001998:	cd05                	beqz	a0,800019d0 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199a:	4729                	li	a4,10
    8000199c:	00004697          	auipc	a3,0x4
    800019a0:	66468693          	addi	a3,a3,1636 # 80006000 <_trampoline>
    800019a4:	6605                	lui	a2,0x1
    800019a6:	040005b7          	lui	a1,0x4000
    800019aa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019ac:	05b2                	slli	a1,a1,0xc
    800019ae:	e8cff0ef          	jal	8000103a <mappages>
    800019b2:	02054663          	bltz	a0,800019de <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019b6:	4719                	li	a4,6
    800019b8:	05893683          	ld	a3,88(s2)
    800019bc:	6605                	lui	a2,0x1
    800019be:	020005b7          	lui	a1,0x2000
    800019c2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c4:	05b6                	slli	a1,a1,0xd
    800019c6:	8526                	mv	a0,s1
    800019c8:	e72ff0ef          	jal	8000103a <mappages>
    800019cc:	00054f63          	bltz	a0,800019ea <proc_pagetable+0x66>
}
    800019d0:	8526                	mv	a0,s1
    800019d2:	60e2                	ld	ra,24(sp)
    800019d4:	6442                	ld	s0,16(sp)
    800019d6:	64a2                	ld	s1,8(sp)
    800019d8:	6902                	ld	s2,0(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret
    uvmfree(pagetable, 0);
    800019de:	4581                	li	a1,0
    800019e0:	8526                	mv	a0,s1
    800019e2:	a91ff0ef          	jal	80001472 <uvmfree>
    return 0;
    800019e6:	4481                	li	s1,0
    800019e8:	b7e5                	j	800019d0 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ea:	4681                	li	a3,0
    800019ec:	4605                	li	a2,1
    800019ee:	040005b7          	lui	a1,0x4000
    800019f2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f4:	05b2                	slli	a1,a1,0xc
    800019f6:	8526                	mv	a0,s1
    800019f8:	fe8ff0ef          	jal	800011e0 <uvmunmap>
    uvmfree(pagetable, 0);
    800019fc:	4581                	li	a1,0
    800019fe:	8526                	mv	a0,s1
    80001a00:	a73ff0ef          	jal	80001472 <uvmfree>
    return 0;
    80001a04:	4481                	li	s1,0
    80001a06:	b7e9                	j	800019d0 <proc_pagetable+0x4c>

0000000080001a08 <proc_freepagetable>:
{
    80001a08:	1101                	addi	sp,sp,-32
    80001a0a:	ec06                	sd	ra,24(sp)
    80001a0c:	e822                	sd	s0,16(sp)
    80001a0e:	e426                	sd	s1,8(sp)
    80001a10:	e04a                	sd	s2,0(sp)
    80001a12:	1000                	addi	s0,sp,32
    80001a14:	84aa                	mv	s1,a0
    80001a16:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a18:	4681                	li	a3,0
    80001a1a:	4605                	li	a2,1
    80001a1c:	040005b7          	lui	a1,0x4000
    80001a20:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a22:	05b2                	slli	a1,a1,0xc
    80001a24:	fbcff0ef          	jal	800011e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a28:	4681                	li	a3,0
    80001a2a:	4605                	li	a2,1
    80001a2c:	020005b7          	lui	a1,0x2000
    80001a30:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a32:	05b6                	slli	a1,a1,0xd
    80001a34:	8526                	mv	a0,s1
    80001a36:	faaff0ef          	jal	800011e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3a:	85ca                	mv	a1,s2
    80001a3c:	8526                	mv	a0,s1
    80001a3e:	a35ff0ef          	jal	80001472 <uvmfree>
}
    80001a42:	60e2                	ld	ra,24(sp)
    80001a44:	6442                	ld	s0,16(sp)
    80001a46:	64a2                	ld	s1,8(sp)
    80001a48:	6902                	ld	s2,0(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret

0000000080001a4e <freeproc>:
{
    80001a4e:	1101                	addi	sp,sp,-32
    80001a50:	ec06                	sd	ra,24(sp)
    80001a52:	e822                	sd	s0,16(sp)
    80001a54:	e426                	sd	s1,8(sp)
    80001a56:	1000                	addi	s0,sp,32
    80001a58:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5a:	6d28                	ld	a0,88(a0)
    80001a5c:	c119                	beqz	a0,80001a62 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a5e:	febfe0ef          	jal	80000a48 <kfree>
  p->trapframe = 0;
    80001a62:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a66:	68a8                	ld	a0,80(s1)
    80001a68:	c501                	beqz	a0,80001a70 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6a:	64ac                	ld	a1,72(s1)
    80001a6c:	f9dff0ef          	jal	80001a08 <proc_freepagetable>
  p->pagetable = 0;
    80001a70:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a74:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a78:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a7c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a80:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a84:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a88:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a8c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a90:	0004ac23          	sw	zero,24(s1)
}
    80001a94:	60e2                	ld	ra,24(sp)
    80001a96:	6442                	ld	s0,16(sp)
    80001a98:	64a2                	ld	s1,8(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <allocproc>:
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	e04a                	sd	s2,0(sp)
    80001aa8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aaa:	00011497          	auipc	s1,0x11
    80001aae:	e1648493          	addi	s1,s1,-490 # 800128c0 <proc>
    80001ab2:	00017917          	auipc	s2,0x17
    80001ab6:	00e90913          	addi	s2,s2,14 # 80018ac0 <tickslock>
    acquire(&p->lock);
    80001aba:	8526                	mv	a0,s1
    80001abc:	942ff0ef          	jal	80000bfe <acquire>
    if(p->state == UNUSED) {
    80001ac0:	4c9c                	lw	a5,24(s1)
    80001ac2:	cb91                	beqz	a5,80001ad6 <allocproc+0x38>
      release(&p->lock);
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	9ccff0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aca:	18848493          	addi	s1,s1,392
    80001ace:	ff2496e3          	bne	s1,s2,80001aba <allocproc+0x1c>
  return 0;
    80001ad2:	4481                	li	s1,0
    80001ad4:	a089                	j	80001b16 <allocproc+0x78>
  p->pid = allocpid();
    80001ad6:	e71ff0ef          	jal	80001946 <allocpid>
    80001ada:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001adc:	4785                	li	a5,1
    80001ade:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae0:	84aff0ef          	jal	80000b2a <kalloc>
    80001ae4:	892a                	mv	s2,a0
    80001ae6:	eca8                	sd	a0,88(s1)
    80001ae8:	cd15                	beqz	a0,80001b24 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001aea:	8526                	mv	a0,s1
    80001aec:	e99ff0ef          	jal	80001984 <proc_pagetable>
    80001af0:	892a                	mv	s2,a0
    80001af2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af4:	c121                	beqz	a0,80001b34 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001af6:	07000613          	li	a2,112
    80001afa:	4581                	li	a1,0
    80001afc:	06048513          	addi	a0,s1,96
    80001b00:	9ceff0ef          	jal	80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001b04:	00000797          	auipc	a5,0x0
    80001b08:	e0878793          	addi	a5,a5,-504 # 8000190c <forkret>
    80001b0c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b0e:	60bc                	ld	a5,64(s1)
    80001b10:	6705                	lui	a4,0x1
    80001b12:	97ba                	add	a5,a5,a4
    80001b14:	f4bc                	sd	a5,104(s1)
}
    80001b16:	8526                	mv	a0,s1
    80001b18:	60e2                	ld	ra,24(sp)
    80001b1a:	6442                	ld	s0,16(sp)
    80001b1c:	64a2                	ld	s1,8(sp)
    80001b1e:	6902                	ld	s2,0(sp)
    80001b20:	6105                	addi	sp,sp,32
    80001b22:	8082                	ret
    freeproc(p);
    80001b24:	8526                	mv	a0,s1
    80001b26:	f29ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	966ff0ef          	jal	80000c92 <release>
    return 0;
    80001b30:	84ca                	mv	s1,s2
    80001b32:	b7d5                	j	80001b16 <allocproc+0x78>
    freeproc(p);
    80001b34:	8526                	mv	a0,s1
    80001b36:	f19ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	956ff0ef          	jal	80000c92 <release>
    return 0;
    80001b40:	84ca                	mv	s1,s2
    80001b42:	bfd1                	j	80001b16 <allocproc+0x78>

0000000080001b44 <userinit>:
{
    80001b44:	1101                	addi	sp,sp,-32
    80001b46:	ec06                	sd	ra,24(sp)
    80001b48:	e822                	sd	s0,16(sp)
    80001b4a:	e426                	sd	s1,8(sp)
    80001b4c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b4e:	f51ff0ef          	jal	80001a9e <allocproc>
    80001b52:	84aa                	mv	s1,a0
  initproc = p;
    80001b54:	00009797          	auipc	a5,0x9
    80001b58:	80a7b223          	sd	a0,-2044(a5) # 8000a358 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b5c:	03400613          	li	a2,52
    80001b60:	00008597          	auipc	a1,0x8
    80001b64:	77058593          	addi	a1,a1,1904 # 8000a2d0 <initcode>
    80001b68:	6928                	ld	a0,80(a0)
    80001b6a:	f58ff0ef          	jal	800012c2 <uvmfirst>
  p->sz = PGSIZE;
    80001b6e:	6785                	lui	a5,0x1
    80001b70:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b72:	6cb8                	ld	a4,88(s1)
    80001b74:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b78:	6cb8                	ld	a4,88(s1)
    80001b7a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b7c:	4641                	li	a2,16
    80001b7e:	00005597          	auipc	a1,0x5
    80001b82:	6a258593          	addi	a1,a1,1698 # 80007220 <etext+0x220>
    80001b86:	15848513          	addi	a0,s1,344
    80001b8a:	a96ff0ef          	jal	80000e20 <safestrcpy>
  p->cwd = namei("/");
    80001b8e:	00005517          	auipc	a0,0x5
    80001b92:	6a250513          	addi	a0,a0,1698 # 80007230 <etext+0x230>
    80001b96:	64f010ef          	jal	800039e4 <namei>
    80001b9a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b9e:	478d                	li	a5,3
    80001ba0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	8eeff0ef          	jal	80000c92 <release>
}
    80001ba8:	60e2                	ld	ra,24(sp)
    80001baa:	6442                	ld	s0,16(sp)
    80001bac:	64a2                	ld	s1,8(sp)
    80001bae:	6105                	addi	sp,sp,32
    80001bb0:	8082                	ret

0000000080001bb2 <growproc>:
{
    80001bb2:	1101                	addi	sp,sp,-32
    80001bb4:	ec06                	sd	ra,24(sp)
    80001bb6:	e822                	sd	s0,16(sp)
    80001bb8:	e426                	sd	s1,8(sp)
    80001bba:	e04a                	sd	s2,0(sp)
    80001bbc:	1000                	addi	s0,sp,32
    80001bbe:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bc0:	d1dff0ef          	jal	800018dc <myproc>
    80001bc4:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bc6:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bc8:	01204c63          	bgtz	s2,80001be0 <growproc+0x2e>
  } else if(n < 0){
    80001bcc:	02094463          	bltz	s2,80001bf4 <growproc+0x42>
  p->sz = sz;
    80001bd0:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bd2:	4501                	li	a0,0
}
    80001bd4:	60e2                	ld	ra,24(sp)
    80001bd6:	6442                	ld	s0,16(sp)
    80001bd8:	64a2                	ld	s1,8(sp)
    80001bda:	6902                	ld	s2,0(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001be0:	4691                	li	a3,4
    80001be2:	00b90633          	add	a2,s2,a1
    80001be6:	6928                	ld	a0,80(a0)
    80001be8:	f7cff0ef          	jal	80001364 <uvmalloc>
    80001bec:	85aa                	mv	a1,a0
    80001bee:	f16d                	bnez	a0,80001bd0 <growproc+0x1e>
      return -1;
    80001bf0:	557d                	li	a0,-1
    80001bf2:	b7cd                	j	80001bd4 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf4:	00b90633          	add	a2,s2,a1
    80001bf8:	6928                	ld	a0,80(a0)
    80001bfa:	f26ff0ef          	jal	80001320 <uvmdealloc>
    80001bfe:	85aa                	mv	a1,a0
    80001c00:	bfc1                	j	80001bd0 <growproc+0x1e>

0000000080001c02 <fork>:
{
    80001c02:	7139                	addi	sp,sp,-64
    80001c04:	fc06                	sd	ra,56(sp)
    80001c06:	f822                	sd	s0,48(sp)
    80001c08:	f04a                	sd	s2,32(sp)
    80001c0a:	e456                	sd	s5,8(sp)
    80001c0c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c0e:	ccfff0ef          	jal	800018dc <myproc>
    80001c12:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c14:	e8bff0ef          	jal	80001a9e <allocproc>
    80001c18:	10050a63          	beqz	a0,80001d2c <fork+0x12a>
    80001c1c:	ec4e                	sd	s3,24(sp)
    80001c1e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c20:	048ab603          	ld	a2,72(s5)
    80001c24:	692c                	ld	a1,80(a0)
    80001c26:	050ab503          	ld	a0,80(s5)
    80001c2a:	87bff0ef          	jal	800014a4 <uvmcopy>
    80001c2e:	06054a63          	bltz	a0,80001ca2 <fork+0xa0>
    80001c32:	f426                	sd	s1,40(sp)
    80001c34:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c36:	048ab783          	ld	a5,72(s5)
    80001c3a:	04f9b423          	sd	a5,72(s3)
  np->alarm_interval = p->alarm_interval;
    80001c3e:	168aa783          	lw	a5,360(s5)
    80001c42:	16f9a423          	sw	a5,360(s3)
  np->alarm_handler = p->alarm_handler;
    80001c46:	170ab783          	ld	a5,368(s5)
    80001c4a:	16f9b823          	sd	a5,368(s3)
  np->ticks_count = 0;
    80001c4e:	1609ac23          	sw	zero,376(s3)
  np->alarm_on = p->alarm_on;
    80001c52:	17caa783          	lw	a5,380(s5)
    80001c56:	16f9ae23          	sw	a5,380(s3)
  np->alarm_trapframe = 0;
    80001c5a:	1809b023          	sd	zero,384(s3)
  *(np->trapframe) = *(p->trapframe);
    80001c5e:	058ab683          	ld	a3,88(s5)
    80001c62:	87b6                	mv	a5,a3
    80001c64:	0589b703          	ld	a4,88(s3)
    80001c68:	12068693          	addi	a3,a3,288
    80001c6c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c70:	6788                	ld	a0,8(a5)
    80001c72:	6b8c                	ld	a1,16(a5)
    80001c74:	6f90                	ld	a2,24(a5)
    80001c76:	01073023          	sd	a6,0(a4)
    80001c7a:	e708                	sd	a0,8(a4)
    80001c7c:	eb0c                	sd	a1,16(a4)
    80001c7e:	ef10                	sd	a2,24(a4)
    80001c80:	02078793          	addi	a5,a5,32
    80001c84:	02070713          	addi	a4,a4,32
    80001c88:	fed792e3          	bne	a5,a3,80001c6c <fork+0x6a>
  np->trapframe->a0 = 0;
    80001c8c:	0589b783          	ld	a5,88(s3)
    80001c90:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c94:	0d0a8493          	addi	s1,s5,208
    80001c98:	0d098913          	addi	s2,s3,208
    80001c9c:	150a8a13          	addi	s4,s5,336
    80001ca0:	a831                	j	80001cbc <fork+0xba>
    freeproc(np);
    80001ca2:	854e                	mv	a0,s3
    80001ca4:	dabff0ef          	jal	80001a4e <freeproc>
    release(&np->lock);
    80001ca8:	854e                	mv	a0,s3
    80001caa:	fe9fe0ef          	jal	80000c92 <release>
    return -1;
    80001cae:	597d                	li	s2,-1
    80001cb0:	69e2                	ld	s3,24(sp)
    80001cb2:	a0b5                	j	80001d1e <fork+0x11c>
  for(i = 0; i < NOFILE; i++)
    80001cb4:	04a1                	addi	s1,s1,8
    80001cb6:	0921                	addi	s2,s2,8
    80001cb8:	01448963          	beq	s1,s4,80001cca <fork+0xc8>
    if(p->ofile[i])
    80001cbc:	6088                	ld	a0,0(s1)
    80001cbe:	d97d                	beqz	a0,80001cb4 <fork+0xb2>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cc0:	2c0020ef          	jal	80003f80 <filedup>
    80001cc4:	00a93023          	sd	a0,0(s2)
    80001cc8:	b7f5                	j	80001cb4 <fork+0xb2>
  np->cwd = idup(p->cwd);
    80001cca:	150ab503          	ld	a0,336(s5)
    80001cce:	5f0010ef          	jal	800032be <idup>
    80001cd2:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cd6:	4641                	li	a2,16
    80001cd8:	158a8593          	addi	a1,s5,344
    80001cdc:	15898513          	addi	a0,s3,344
    80001ce0:	940ff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001ce4:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ce8:	854e                	mv	a0,s3
    80001cea:	fa9fe0ef          	jal	80000c92 <release>
  acquire(&wait_lock);
    80001cee:	00010497          	auipc	s1,0x10
    80001cf2:	7ba48493          	addi	s1,s1,1978 # 800124a8 <wait_lock>
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	f07fe0ef          	jal	80000bfe <acquire>
  np->parent = p;
    80001cfc:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d00:	8526                	mv	a0,s1
    80001d02:	f91fe0ef          	jal	80000c92 <release>
  acquire(&np->lock);
    80001d06:	854e                	mv	a0,s3
    80001d08:	ef7fe0ef          	jal	80000bfe <acquire>
  np->state = RUNNABLE;
    80001d0c:	478d                	li	a5,3
    80001d0e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d12:	854e                	mv	a0,s3
    80001d14:	f7ffe0ef          	jal	80000c92 <release>
  return pid;
    80001d18:	74a2                	ld	s1,40(sp)
    80001d1a:	69e2                	ld	s3,24(sp)
    80001d1c:	6a42                	ld	s4,16(sp)
}
    80001d1e:	854a                	mv	a0,s2
    80001d20:	70e2                	ld	ra,56(sp)
    80001d22:	7442                	ld	s0,48(sp)
    80001d24:	7902                	ld	s2,32(sp)
    80001d26:	6aa2                	ld	s5,8(sp)
    80001d28:	6121                	addi	sp,sp,64
    80001d2a:	8082                	ret
    return -1;
    80001d2c:	597d                	li	s2,-1
    80001d2e:	bfc5                	j	80001d1e <fork+0x11c>

0000000080001d30 <scheduler>:
{
    80001d30:	715d                	addi	sp,sp,-80
    80001d32:	e486                	sd	ra,72(sp)
    80001d34:	e0a2                	sd	s0,64(sp)
    80001d36:	fc26                	sd	s1,56(sp)
    80001d38:	f84a                	sd	s2,48(sp)
    80001d3a:	f44e                	sd	s3,40(sp)
    80001d3c:	f052                	sd	s4,32(sp)
    80001d3e:	ec56                	sd	s5,24(sp)
    80001d40:	e85a                	sd	s6,16(sp)
    80001d42:	e45e                	sd	s7,8(sp)
    80001d44:	e062                	sd	s8,0(sp)
    80001d46:	0880                	addi	s0,sp,80
    80001d48:	8792                	mv	a5,tp
  int id = r_tp();
    80001d4a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d4c:	00779b13          	slli	s6,a5,0x7
    80001d50:	00010717          	auipc	a4,0x10
    80001d54:	74070713          	addi	a4,a4,1856 # 80012490 <pid_lock>
    80001d58:	975a                	add	a4,a4,s6
    80001d5a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d5e:	00010717          	auipc	a4,0x10
    80001d62:	76a70713          	addi	a4,a4,1898 # 800124c8 <cpus+0x8>
    80001d66:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d68:	4c11                	li	s8,4
        c->proc = p;
    80001d6a:	079e                	slli	a5,a5,0x7
    80001d6c:	00010a17          	auipc	s4,0x10
    80001d70:	724a0a13          	addi	s4,s4,1828 # 80012490 <pid_lock>
    80001d74:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d76:	4b85                	li	s7,1
    80001d78:	a0a9                	j	80001dc2 <scheduler+0x92>
      release(&p->lock);
    80001d7a:	8526                	mv	a0,s1
    80001d7c:	f17fe0ef          	jal	80000c92 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d80:	18848493          	addi	s1,s1,392
    80001d84:	03248563          	beq	s1,s2,80001dae <scheduler+0x7e>
      acquire(&p->lock);
    80001d88:	8526                	mv	a0,s1
    80001d8a:	e75fe0ef          	jal	80000bfe <acquire>
      if(p->state == RUNNABLE) {
    80001d8e:	4c9c                	lw	a5,24(s1)
    80001d90:	ff3795e3          	bne	a5,s3,80001d7a <scheduler+0x4a>
        p->state = RUNNING;
    80001d94:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d98:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d9c:	06048593          	addi	a1,s1,96
    80001da0:	855a                	mv	a0,s6
    80001da2:	5b6000ef          	jal	80002358 <swtch>
        c->proc = 0;
    80001da6:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001daa:	8ade                	mv	s5,s7
    80001dac:	b7f9                	j	80001d7a <scheduler+0x4a>
    if(found == 0) {
    80001dae:	000a9a63          	bnez	s5,80001dc2 <scheduler+0x92>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001db2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001db6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dba:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001dbe:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dc6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dca:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dce:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dd0:	00011497          	auipc	s1,0x11
    80001dd4:	af048493          	addi	s1,s1,-1296 # 800128c0 <proc>
      if(p->state == RUNNABLE) {
    80001dd8:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dda:	00017917          	auipc	s2,0x17
    80001dde:	ce690913          	addi	s2,s2,-794 # 80018ac0 <tickslock>
    80001de2:	b75d                	j	80001d88 <scheduler+0x58>

0000000080001de4 <sched>:
{
    80001de4:	7179                	addi	sp,sp,-48
    80001de6:	f406                	sd	ra,40(sp)
    80001de8:	f022                	sd	s0,32(sp)
    80001dea:	ec26                	sd	s1,24(sp)
    80001dec:	e84a                	sd	s2,16(sp)
    80001dee:	e44e                	sd	s3,8(sp)
    80001df0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001df2:	aebff0ef          	jal	800018dc <myproc>
    80001df6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001df8:	d9dfe0ef          	jal	80000b94 <holding>
    80001dfc:	c92d                	beqz	a0,80001e6e <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dfe:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e00:	2781                	sext.w	a5,a5
    80001e02:	079e                	slli	a5,a5,0x7
    80001e04:	00010717          	auipc	a4,0x10
    80001e08:	68c70713          	addi	a4,a4,1676 # 80012490 <pid_lock>
    80001e0c:	97ba                	add	a5,a5,a4
    80001e0e:	0a87a703          	lw	a4,168(a5)
    80001e12:	4785                	li	a5,1
    80001e14:	06f71363          	bne	a4,a5,80001e7a <sched+0x96>
  if(p->state == RUNNING)
    80001e18:	4c98                	lw	a4,24(s1)
    80001e1a:	4791                	li	a5,4
    80001e1c:	06f70563          	beq	a4,a5,80001e86 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e20:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e24:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e26:	e7b5                	bnez	a5,80001e92 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e28:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e2a:	00010917          	auipc	s2,0x10
    80001e2e:	66690913          	addi	s2,s2,1638 # 80012490 <pid_lock>
    80001e32:	2781                	sext.w	a5,a5
    80001e34:	079e                	slli	a5,a5,0x7
    80001e36:	97ca                	add	a5,a5,s2
    80001e38:	0ac7a983          	lw	s3,172(a5)
    80001e3c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e3e:	2781                	sext.w	a5,a5
    80001e40:	079e                	slli	a5,a5,0x7
    80001e42:	00010597          	auipc	a1,0x10
    80001e46:	68658593          	addi	a1,a1,1670 # 800124c8 <cpus+0x8>
    80001e4a:	95be                	add	a1,a1,a5
    80001e4c:	06048513          	addi	a0,s1,96
    80001e50:	508000ef          	jal	80002358 <swtch>
    80001e54:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e56:	2781                	sext.w	a5,a5
    80001e58:	079e                	slli	a5,a5,0x7
    80001e5a:	993e                	add	s2,s2,a5
    80001e5c:	0b392623          	sw	s3,172(s2)
}
    80001e60:	70a2                	ld	ra,40(sp)
    80001e62:	7402                	ld	s0,32(sp)
    80001e64:	64e2                	ld	s1,24(sp)
    80001e66:	6942                	ld	s2,16(sp)
    80001e68:	69a2                	ld	s3,8(sp)
    80001e6a:	6145                	addi	sp,sp,48
    80001e6c:	8082                	ret
    panic("sched p->lock");
    80001e6e:	00005517          	auipc	a0,0x5
    80001e72:	3ca50513          	addi	a0,a0,970 # 80007238 <etext+0x238>
    80001e76:	929fe0ef          	jal	8000079e <panic>
    panic("sched locks");
    80001e7a:	00005517          	auipc	a0,0x5
    80001e7e:	3ce50513          	addi	a0,a0,974 # 80007248 <etext+0x248>
    80001e82:	91dfe0ef          	jal	8000079e <panic>
    panic("sched running");
    80001e86:	00005517          	auipc	a0,0x5
    80001e8a:	3d250513          	addi	a0,a0,978 # 80007258 <etext+0x258>
    80001e8e:	911fe0ef          	jal	8000079e <panic>
    panic("sched interruptible");
    80001e92:	00005517          	auipc	a0,0x5
    80001e96:	3d650513          	addi	a0,a0,982 # 80007268 <etext+0x268>
    80001e9a:	905fe0ef          	jal	8000079e <panic>

0000000080001e9e <yield>:
{
    80001e9e:	1101                	addi	sp,sp,-32
    80001ea0:	ec06                	sd	ra,24(sp)
    80001ea2:	e822                	sd	s0,16(sp)
    80001ea4:	e426                	sd	s1,8(sp)
    80001ea6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ea8:	a35ff0ef          	jal	800018dc <myproc>
    80001eac:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001eae:	d51fe0ef          	jal	80000bfe <acquire>
  p->state = RUNNABLE;
    80001eb2:	478d                	li	a5,3
    80001eb4:	cc9c                	sw	a5,24(s1)
  sched();
    80001eb6:	f2fff0ef          	jal	80001de4 <sched>
  release(&p->lock);
    80001eba:	8526                	mv	a0,s1
    80001ebc:	dd7fe0ef          	jal	80000c92 <release>
}
    80001ec0:	60e2                	ld	ra,24(sp)
    80001ec2:	6442                	ld	s0,16(sp)
    80001ec4:	64a2                	ld	s1,8(sp)
    80001ec6:	6105                	addi	sp,sp,32
    80001ec8:	8082                	ret

0000000080001eca <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eca:	7179                	addi	sp,sp,-48
    80001ecc:	f406                	sd	ra,40(sp)
    80001ece:	f022                	sd	s0,32(sp)
    80001ed0:	ec26                	sd	s1,24(sp)
    80001ed2:	e84a                	sd	s2,16(sp)
    80001ed4:	e44e                	sd	s3,8(sp)
    80001ed6:	1800                	addi	s0,sp,48
    80001ed8:	89aa                	mv	s3,a0
    80001eda:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001edc:	a01ff0ef          	jal	800018dc <myproc>
    80001ee0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ee2:	d1dfe0ef          	jal	80000bfe <acquire>
  release(lk);
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	dabfe0ef          	jal	80000c92 <release>

  // Go to sleep.
  p->chan = chan;
    80001eec:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ef0:	4789                	li	a5,2
    80001ef2:	cc9c                	sw	a5,24(s1)

  sched();
    80001ef4:	ef1ff0ef          	jal	80001de4 <sched>

  // Tidy up.
  p->chan = 0;
    80001ef8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001efc:	8526                	mv	a0,s1
    80001efe:	d95fe0ef          	jal	80000c92 <release>
  acquire(lk);
    80001f02:	854a                	mv	a0,s2
    80001f04:	cfbfe0ef          	jal	80000bfe <acquire>
}
    80001f08:	70a2                	ld	ra,40(sp)
    80001f0a:	7402                	ld	s0,32(sp)
    80001f0c:	64e2                	ld	s1,24(sp)
    80001f0e:	6942                	ld	s2,16(sp)
    80001f10:	69a2                	ld	s3,8(sp)
    80001f12:	6145                	addi	sp,sp,48
    80001f14:	8082                	ret

0000000080001f16 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f16:	7139                	addi	sp,sp,-64
    80001f18:	fc06                	sd	ra,56(sp)
    80001f1a:	f822                	sd	s0,48(sp)
    80001f1c:	f426                	sd	s1,40(sp)
    80001f1e:	f04a                	sd	s2,32(sp)
    80001f20:	ec4e                	sd	s3,24(sp)
    80001f22:	e852                	sd	s4,16(sp)
    80001f24:	e456                	sd	s5,8(sp)
    80001f26:	0080                	addi	s0,sp,64
    80001f28:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f2a:	00011497          	auipc	s1,0x11
    80001f2e:	99648493          	addi	s1,s1,-1642 # 800128c0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f32:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f34:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f36:	00017917          	auipc	s2,0x17
    80001f3a:	b8a90913          	addi	s2,s2,-1142 # 80018ac0 <tickslock>
    80001f3e:	a801                	j	80001f4e <wakeup+0x38>
      }
      release(&p->lock);
    80001f40:	8526                	mv	a0,s1
    80001f42:	d51fe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f46:	18848493          	addi	s1,s1,392
    80001f4a:	03248263          	beq	s1,s2,80001f6e <wakeup+0x58>
    if(p != myproc()){
    80001f4e:	98fff0ef          	jal	800018dc <myproc>
    80001f52:	fea48ae3          	beq	s1,a0,80001f46 <wakeup+0x30>
      acquire(&p->lock);
    80001f56:	8526                	mv	a0,s1
    80001f58:	ca7fe0ef          	jal	80000bfe <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f5c:	4c9c                	lw	a5,24(s1)
    80001f5e:	ff3791e3          	bne	a5,s3,80001f40 <wakeup+0x2a>
    80001f62:	709c                	ld	a5,32(s1)
    80001f64:	fd479ee3          	bne	a5,s4,80001f40 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f68:	0154ac23          	sw	s5,24(s1)
    80001f6c:	bfd1                	j	80001f40 <wakeup+0x2a>
    }
  }
}
    80001f6e:	70e2                	ld	ra,56(sp)
    80001f70:	7442                	ld	s0,48(sp)
    80001f72:	74a2                	ld	s1,40(sp)
    80001f74:	7902                	ld	s2,32(sp)
    80001f76:	69e2                	ld	s3,24(sp)
    80001f78:	6a42                	ld	s4,16(sp)
    80001f7a:	6aa2                	ld	s5,8(sp)
    80001f7c:	6121                	addi	sp,sp,64
    80001f7e:	8082                	ret

0000000080001f80 <reparent>:
{
    80001f80:	7179                	addi	sp,sp,-48
    80001f82:	f406                	sd	ra,40(sp)
    80001f84:	f022                	sd	s0,32(sp)
    80001f86:	ec26                	sd	s1,24(sp)
    80001f88:	e84a                	sd	s2,16(sp)
    80001f8a:	e44e                	sd	s3,8(sp)
    80001f8c:	e052                	sd	s4,0(sp)
    80001f8e:	1800                	addi	s0,sp,48
    80001f90:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f92:	00011497          	auipc	s1,0x11
    80001f96:	92e48493          	addi	s1,s1,-1746 # 800128c0 <proc>
      pp->parent = initproc;
    80001f9a:	00008a17          	auipc	s4,0x8
    80001f9e:	3bea0a13          	addi	s4,s4,958 # 8000a358 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fa2:	00017997          	auipc	s3,0x17
    80001fa6:	b1e98993          	addi	s3,s3,-1250 # 80018ac0 <tickslock>
    80001faa:	a029                	j	80001fb4 <reparent+0x34>
    80001fac:	18848493          	addi	s1,s1,392
    80001fb0:	01348b63          	beq	s1,s3,80001fc6 <reparent+0x46>
    if(pp->parent == p){
    80001fb4:	7c9c                	ld	a5,56(s1)
    80001fb6:	ff279be3          	bne	a5,s2,80001fac <reparent+0x2c>
      pp->parent = initproc;
    80001fba:	000a3503          	ld	a0,0(s4)
    80001fbe:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fc0:	f57ff0ef          	jal	80001f16 <wakeup>
    80001fc4:	b7e5                	j	80001fac <reparent+0x2c>
}
    80001fc6:	70a2                	ld	ra,40(sp)
    80001fc8:	7402                	ld	s0,32(sp)
    80001fca:	64e2                	ld	s1,24(sp)
    80001fcc:	6942                	ld	s2,16(sp)
    80001fce:	69a2                	ld	s3,8(sp)
    80001fd0:	6a02                	ld	s4,0(sp)
    80001fd2:	6145                	addi	sp,sp,48
    80001fd4:	8082                	ret

0000000080001fd6 <exit>:
{
    80001fd6:	7179                	addi	sp,sp,-48
    80001fd8:	f406                	sd	ra,40(sp)
    80001fda:	f022                	sd	s0,32(sp)
    80001fdc:	ec26                	sd	s1,24(sp)
    80001fde:	e84a                	sd	s2,16(sp)
    80001fe0:	e44e                	sd	s3,8(sp)
    80001fe2:	e052                	sd	s4,0(sp)
    80001fe4:	1800                	addi	s0,sp,48
    80001fe6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fe8:	8f5ff0ef          	jal	800018dc <myproc>
    80001fec:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fee:	00008797          	auipc	a5,0x8
    80001ff2:	36a7b783          	ld	a5,874(a5) # 8000a358 <initproc>
    80001ff6:	0d050493          	addi	s1,a0,208
    80001ffa:	15050913          	addi	s2,a0,336
    80001ffe:	00a79b63          	bne	a5,a0,80002014 <exit+0x3e>
    panic("init exiting");
    80002002:	00005517          	auipc	a0,0x5
    80002006:	27e50513          	addi	a0,a0,638 # 80007280 <etext+0x280>
    8000200a:	f94fe0ef          	jal	8000079e <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    8000200e:	04a1                	addi	s1,s1,8
    80002010:	01248963          	beq	s1,s2,80002022 <exit+0x4c>
    if(p->ofile[fd]){
    80002014:	6088                	ld	a0,0(s1)
    80002016:	dd65                	beqz	a0,8000200e <exit+0x38>
      fileclose(f);
    80002018:	7af010ef          	jal	80003fc6 <fileclose>
      p->ofile[fd] = 0;
    8000201c:	0004b023          	sd	zero,0(s1)
    80002020:	b7fd                	j	8000200e <exit+0x38>
  begin_op();
    80002022:	385010ef          	jal	80003ba6 <begin_op>
  iput(p->cwd);
    80002026:	1509b503          	ld	a0,336(s3)
    8000202a:	44c010ef          	jal	80003476 <iput>
  end_op();
    8000202e:	3e3010ef          	jal	80003c10 <end_op>
  p->cwd = 0;
    80002032:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002036:	00010497          	auipc	s1,0x10
    8000203a:	47248493          	addi	s1,s1,1138 # 800124a8 <wait_lock>
    8000203e:	8526                	mv	a0,s1
    80002040:	bbffe0ef          	jal	80000bfe <acquire>
  reparent(p);
    80002044:	854e                	mv	a0,s3
    80002046:	f3bff0ef          	jal	80001f80 <reparent>
  wakeup(p->parent);
    8000204a:	0389b503          	ld	a0,56(s3)
    8000204e:	ec9ff0ef          	jal	80001f16 <wakeup>
  acquire(&p->lock);
    80002052:	854e                	mv	a0,s3
    80002054:	babfe0ef          	jal	80000bfe <acquire>
  p->xstate = status;
    80002058:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000205c:	4795                	li	a5,5
    8000205e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002062:	8526                	mv	a0,s1
    80002064:	c2ffe0ef          	jal	80000c92 <release>
  sched();
    80002068:	d7dff0ef          	jal	80001de4 <sched>
  panic("zombie exit");
    8000206c:	00005517          	auipc	a0,0x5
    80002070:	22450513          	addi	a0,a0,548 # 80007290 <etext+0x290>
    80002074:	f2afe0ef          	jal	8000079e <panic>

0000000080002078 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002078:	7179                	addi	sp,sp,-48
    8000207a:	f406                	sd	ra,40(sp)
    8000207c:	f022                	sd	s0,32(sp)
    8000207e:	ec26                	sd	s1,24(sp)
    80002080:	e84a                	sd	s2,16(sp)
    80002082:	e44e                	sd	s3,8(sp)
    80002084:	1800                	addi	s0,sp,48
    80002086:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002088:	00011497          	auipc	s1,0x11
    8000208c:	83848493          	addi	s1,s1,-1992 # 800128c0 <proc>
    80002090:	00017997          	auipc	s3,0x17
    80002094:	a3098993          	addi	s3,s3,-1488 # 80018ac0 <tickslock>
    acquire(&p->lock);
    80002098:	8526                	mv	a0,s1
    8000209a:	b65fe0ef          	jal	80000bfe <acquire>
    if(p->pid == pid){
    8000209e:	589c                	lw	a5,48(s1)
    800020a0:	01278b63          	beq	a5,s2,800020b6 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020a4:	8526                	mv	a0,s1
    800020a6:	bedfe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020aa:	18848493          	addi	s1,s1,392
    800020ae:	ff3495e3          	bne	s1,s3,80002098 <kill+0x20>
  }
  return -1;
    800020b2:	557d                	li	a0,-1
    800020b4:	a819                	j	800020ca <kill+0x52>
      p->killed = 1;
    800020b6:	4785                	li	a5,1
    800020b8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020ba:	4c98                	lw	a4,24(s1)
    800020bc:	4789                	li	a5,2
    800020be:	00f70d63          	beq	a4,a5,800020d8 <kill+0x60>
      release(&p->lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	bcffe0ef          	jal	80000c92 <release>
      return 0;
    800020c8:	4501                	li	a0,0
}
    800020ca:	70a2                	ld	ra,40(sp)
    800020cc:	7402                	ld	s0,32(sp)
    800020ce:	64e2                	ld	s1,24(sp)
    800020d0:	6942                	ld	s2,16(sp)
    800020d2:	69a2                	ld	s3,8(sp)
    800020d4:	6145                	addi	sp,sp,48
    800020d6:	8082                	ret
        p->state = RUNNABLE;
    800020d8:	478d                	li	a5,3
    800020da:	cc9c                	sw	a5,24(s1)
    800020dc:	b7dd                	j	800020c2 <kill+0x4a>

00000000800020de <setkilled>:

void
setkilled(struct proc *p)
{
    800020de:	1101                	addi	sp,sp,-32
    800020e0:	ec06                	sd	ra,24(sp)
    800020e2:	e822                	sd	s0,16(sp)
    800020e4:	e426                	sd	s1,8(sp)
    800020e6:	1000                	addi	s0,sp,32
    800020e8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ea:	b15fe0ef          	jal	80000bfe <acquire>
  p->killed = 1;
    800020ee:	4785                	li	a5,1
    800020f0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020f2:	8526                	mv	a0,s1
    800020f4:	b9ffe0ef          	jal	80000c92 <release>
}
    800020f8:	60e2                	ld	ra,24(sp)
    800020fa:	6442                	ld	s0,16(sp)
    800020fc:	64a2                	ld	s1,8(sp)
    800020fe:	6105                	addi	sp,sp,32
    80002100:	8082                	ret

0000000080002102 <killed>:

int
killed(struct proc *p)
{
    80002102:	1101                	addi	sp,sp,-32
    80002104:	ec06                	sd	ra,24(sp)
    80002106:	e822                	sd	s0,16(sp)
    80002108:	e426                	sd	s1,8(sp)
    8000210a:	e04a                	sd	s2,0(sp)
    8000210c:	1000                	addi	s0,sp,32
    8000210e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002110:	aeffe0ef          	jal	80000bfe <acquire>
  k = p->killed;
    80002114:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002118:	8526                	mv	a0,s1
    8000211a:	b79fe0ef          	jal	80000c92 <release>
  return k;
}
    8000211e:	854a                	mv	a0,s2
    80002120:	60e2                	ld	ra,24(sp)
    80002122:	6442                	ld	s0,16(sp)
    80002124:	64a2                	ld	s1,8(sp)
    80002126:	6902                	ld	s2,0(sp)
    80002128:	6105                	addi	sp,sp,32
    8000212a:	8082                	ret

000000008000212c <wait>:
{
    8000212c:	715d                	addi	sp,sp,-80
    8000212e:	e486                	sd	ra,72(sp)
    80002130:	e0a2                	sd	s0,64(sp)
    80002132:	fc26                	sd	s1,56(sp)
    80002134:	f84a                	sd	s2,48(sp)
    80002136:	f44e                	sd	s3,40(sp)
    80002138:	f052                	sd	s4,32(sp)
    8000213a:	ec56                	sd	s5,24(sp)
    8000213c:	e85a                	sd	s6,16(sp)
    8000213e:	e45e                	sd	s7,8(sp)
    80002140:	0880                	addi	s0,sp,80
    80002142:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002144:	f98ff0ef          	jal	800018dc <myproc>
    80002148:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000214a:	00010517          	auipc	a0,0x10
    8000214e:	35e50513          	addi	a0,a0,862 # 800124a8 <wait_lock>
    80002152:	aadfe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    80002156:	4a15                	li	s4,5
        havekids = 1;
    80002158:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000215a:	00017997          	auipc	s3,0x17
    8000215e:	96698993          	addi	s3,s3,-1690 # 80018ac0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002162:	00010b97          	auipc	s7,0x10
    80002166:	346b8b93          	addi	s7,s7,838 # 800124a8 <wait_lock>
    8000216a:	a869                	j	80002204 <wait+0xd8>
          pid = pp->pid;
    8000216c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002170:	000b0c63          	beqz	s6,80002188 <wait+0x5c>
    80002174:	4691                	li	a3,4
    80002176:	02c48613          	addi	a2,s1,44
    8000217a:	85da                	mv	a1,s6
    8000217c:	05093503          	ld	a0,80(s2)
    80002180:	c04ff0ef          	jal	80001584 <copyout>
    80002184:	02054a63          	bltz	a0,800021b8 <wait+0x8c>
          freeproc(pp);
    80002188:	8526                	mv	a0,s1
    8000218a:	8c5ff0ef          	jal	80001a4e <freeproc>
          release(&pp->lock);
    8000218e:	8526                	mv	a0,s1
    80002190:	b03fe0ef          	jal	80000c92 <release>
          release(&wait_lock);
    80002194:	00010517          	auipc	a0,0x10
    80002198:	31450513          	addi	a0,a0,788 # 800124a8 <wait_lock>
    8000219c:	af7fe0ef          	jal	80000c92 <release>
}
    800021a0:	854e                	mv	a0,s3
    800021a2:	60a6                	ld	ra,72(sp)
    800021a4:	6406                	ld	s0,64(sp)
    800021a6:	74e2                	ld	s1,56(sp)
    800021a8:	7942                	ld	s2,48(sp)
    800021aa:	79a2                	ld	s3,40(sp)
    800021ac:	7a02                	ld	s4,32(sp)
    800021ae:	6ae2                	ld	s5,24(sp)
    800021b0:	6b42                	ld	s6,16(sp)
    800021b2:	6ba2                	ld	s7,8(sp)
    800021b4:	6161                	addi	sp,sp,80
    800021b6:	8082                	ret
            release(&pp->lock);
    800021b8:	8526                	mv	a0,s1
    800021ba:	ad9fe0ef          	jal	80000c92 <release>
            release(&wait_lock);
    800021be:	00010517          	auipc	a0,0x10
    800021c2:	2ea50513          	addi	a0,a0,746 # 800124a8 <wait_lock>
    800021c6:	acdfe0ef          	jal	80000c92 <release>
            return -1;
    800021ca:	59fd                	li	s3,-1
    800021cc:	bfd1                	j	800021a0 <wait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ce:	18848493          	addi	s1,s1,392
    800021d2:	03348063          	beq	s1,s3,800021f2 <wait+0xc6>
      if(pp->parent == p){
    800021d6:	7c9c                	ld	a5,56(s1)
    800021d8:	ff279be3          	bne	a5,s2,800021ce <wait+0xa2>
        acquire(&pp->lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	a21fe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    800021e2:	4c9c                	lw	a5,24(s1)
    800021e4:	f94784e3          	beq	a5,s4,8000216c <wait+0x40>
        release(&pp->lock);
    800021e8:	8526                	mv	a0,s1
    800021ea:	aa9fe0ef          	jal	80000c92 <release>
        havekids = 1;
    800021ee:	8756                	mv	a4,s5
    800021f0:	bff9                	j	800021ce <wait+0xa2>
    if(!havekids || killed(p)){
    800021f2:	cf19                	beqz	a4,80002210 <wait+0xe4>
    800021f4:	854a                	mv	a0,s2
    800021f6:	f0dff0ef          	jal	80002102 <killed>
    800021fa:	e919                	bnez	a0,80002210 <wait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021fc:	85de                	mv	a1,s7
    800021fe:	854a                	mv	a0,s2
    80002200:	ccbff0ef          	jal	80001eca <sleep>
    havekids = 0;
    80002204:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002206:	00010497          	auipc	s1,0x10
    8000220a:	6ba48493          	addi	s1,s1,1722 # 800128c0 <proc>
    8000220e:	b7e1                	j	800021d6 <wait+0xaa>
      release(&wait_lock);
    80002210:	00010517          	auipc	a0,0x10
    80002214:	29850513          	addi	a0,a0,664 # 800124a8 <wait_lock>
    80002218:	a7bfe0ef          	jal	80000c92 <release>
      return -1;
    8000221c:	59fd                	li	s3,-1
    8000221e:	b749                	j	800021a0 <wait+0x74>

0000000080002220 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002220:	7179                	addi	sp,sp,-48
    80002222:	f406                	sd	ra,40(sp)
    80002224:	f022                	sd	s0,32(sp)
    80002226:	ec26                	sd	s1,24(sp)
    80002228:	e84a                	sd	s2,16(sp)
    8000222a:	e44e                	sd	s3,8(sp)
    8000222c:	e052                	sd	s4,0(sp)
    8000222e:	1800                	addi	s0,sp,48
    80002230:	84aa                	mv	s1,a0
    80002232:	892e                	mv	s2,a1
    80002234:	89b2                	mv	s3,a2
    80002236:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002238:	ea4ff0ef          	jal	800018dc <myproc>
  if(user_dst){
    8000223c:	cc99                	beqz	s1,8000225a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000223e:	86d2                	mv	a3,s4
    80002240:	864e                	mv	a2,s3
    80002242:	85ca                	mv	a1,s2
    80002244:	6928                	ld	a0,80(a0)
    80002246:	b3eff0ef          	jal	80001584 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000224a:	70a2                	ld	ra,40(sp)
    8000224c:	7402                	ld	s0,32(sp)
    8000224e:	64e2                	ld	s1,24(sp)
    80002250:	6942                	ld	s2,16(sp)
    80002252:	69a2                	ld	s3,8(sp)
    80002254:	6a02                	ld	s4,0(sp)
    80002256:	6145                	addi	sp,sp,48
    80002258:	8082                	ret
    memmove((char *)dst, src, len);
    8000225a:	000a061b          	sext.w	a2,s4
    8000225e:	85ce                	mv	a1,s3
    80002260:	854a                	mv	a0,s2
    80002262:	ad1fe0ef          	jal	80000d32 <memmove>
    return 0;
    80002266:	8526                	mv	a0,s1
    80002268:	b7cd                	j	8000224a <either_copyout+0x2a>

000000008000226a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000226a:	7179                	addi	sp,sp,-48
    8000226c:	f406                	sd	ra,40(sp)
    8000226e:	f022                	sd	s0,32(sp)
    80002270:	ec26                	sd	s1,24(sp)
    80002272:	e84a                	sd	s2,16(sp)
    80002274:	e44e                	sd	s3,8(sp)
    80002276:	e052                	sd	s4,0(sp)
    80002278:	1800                	addi	s0,sp,48
    8000227a:	892a                	mv	s2,a0
    8000227c:	84ae                	mv	s1,a1
    8000227e:	89b2                	mv	s3,a2
    80002280:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002282:	e5aff0ef          	jal	800018dc <myproc>
  if(user_src){
    80002286:	cc99                	beqz	s1,800022a4 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002288:	86d2                	mv	a3,s4
    8000228a:	864e                	mv	a2,s3
    8000228c:	85ca                	mv	a1,s2
    8000228e:	6928                	ld	a0,80(a0)
    80002290:	ba4ff0ef          	jal	80001634 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002294:	70a2                	ld	ra,40(sp)
    80002296:	7402                	ld	s0,32(sp)
    80002298:	64e2                	ld	s1,24(sp)
    8000229a:	6942                	ld	s2,16(sp)
    8000229c:	69a2                	ld	s3,8(sp)
    8000229e:	6a02                	ld	s4,0(sp)
    800022a0:	6145                	addi	sp,sp,48
    800022a2:	8082                	ret
    memmove(dst, (char*)src, len);
    800022a4:	000a061b          	sext.w	a2,s4
    800022a8:	85ce                	mv	a1,s3
    800022aa:	854a                	mv	a0,s2
    800022ac:	a87fe0ef          	jal	80000d32 <memmove>
    return 0;
    800022b0:	8526                	mv	a0,s1
    800022b2:	b7cd                	j	80002294 <either_copyin+0x2a>

00000000800022b4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022b4:	715d                	addi	sp,sp,-80
    800022b6:	e486                	sd	ra,72(sp)
    800022b8:	e0a2                	sd	s0,64(sp)
    800022ba:	fc26                	sd	s1,56(sp)
    800022bc:	f84a                	sd	s2,48(sp)
    800022be:	f44e                	sd	s3,40(sp)
    800022c0:	f052                	sd	s4,32(sp)
    800022c2:	ec56                	sd	s5,24(sp)
    800022c4:	e85a                	sd	s6,16(sp)
    800022c6:	e45e                	sd	s7,8(sp)
    800022c8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022ca:	00005517          	auipc	a0,0x5
    800022ce:	dae50513          	addi	a0,a0,-594 # 80007078 <etext+0x78>
    800022d2:	9fcfe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022d6:	00010497          	auipc	s1,0x10
    800022da:	74248493          	addi	s1,s1,1858 # 80012a18 <proc+0x158>
    800022de:	00017917          	auipc	s2,0x17
    800022e2:	93a90913          	addi	s2,s2,-1734 # 80018c18 <bcache+0x88>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022e6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022e8:	00005997          	auipc	s3,0x5
    800022ec:	fb898993          	addi	s3,s3,-72 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022f0:	00005a97          	auipc	s5,0x5
    800022f4:	fb8a8a93          	addi	s5,s5,-72 # 800072a8 <etext+0x2a8>
    printf("\n");
    800022f8:	00005a17          	auipc	s4,0x5
    800022fc:	d80a0a13          	addi	s4,s4,-640 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002300:	00005b97          	auipc	s7,0x5
    80002304:	490b8b93          	addi	s7,s7,1168 # 80007790 <states.0>
    80002308:	a829                	j	80002322 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000230a:	ed86a583          	lw	a1,-296(a3)
    8000230e:	8556                	mv	a0,s5
    80002310:	9befe0ef          	jal	800004ce <printf>
    printf("\n");
    80002314:	8552                	mv	a0,s4
    80002316:	9b8fe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000231a:	18848493          	addi	s1,s1,392
    8000231e:	03248263          	beq	s1,s2,80002342 <procdump+0x8e>
    if(p->state == UNUSED)
    80002322:	86a6                	mv	a3,s1
    80002324:	ec04a783          	lw	a5,-320(s1)
    80002328:	dbed                	beqz	a5,8000231a <procdump+0x66>
      state = "???";
    8000232a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000232c:	fcfb6fe3          	bltu	s6,a5,8000230a <procdump+0x56>
    80002330:	02079713          	slli	a4,a5,0x20
    80002334:	01d75793          	srli	a5,a4,0x1d
    80002338:	97de                	add	a5,a5,s7
    8000233a:	6390                	ld	a2,0(a5)
    8000233c:	f679                	bnez	a2,8000230a <procdump+0x56>
      state = "???";
    8000233e:	864e                	mv	a2,s3
    80002340:	b7e9                	j	8000230a <procdump+0x56>
  }
}
    80002342:	60a6                	ld	ra,72(sp)
    80002344:	6406                	ld	s0,64(sp)
    80002346:	74e2                	ld	s1,56(sp)
    80002348:	7942                	ld	s2,48(sp)
    8000234a:	79a2                	ld	s3,40(sp)
    8000234c:	7a02                	ld	s4,32(sp)
    8000234e:	6ae2                	ld	s5,24(sp)
    80002350:	6b42                	ld	s6,16(sp)
    80002352:	6ba2                	ld	s7,8(sp)
    80002354:	6161                	addi	sp,sp,80
    80002356:	8082                	ret

0000000080002358 <swtch>:
    80002358:	00153023          	sd	ra,0(a0)
    8000235c:	00253423          	sd	sp,8(a0)
    80002360:	e900                	sd	s0,16(a0)
    80002362:	ed04                	sd	s1,24(a0)
    80002364:	03253023          	sd	s2,32(a0)
    80002368:	03353423          	sd	s3,40(a0)
    8000236c:	03453823          	sd	s4,48(a0)
    80002370:	03553c23          	sd	s5,56(a0)
    80002374:	05653023          	sd	s6,64(a0)
    80002378:	05753423          	sd	s7,72(a0)
    8000237c:	05853823          	sd	s8,80(a0)
    80002380:	05953c23          	sd	s9,88(a0)
    80002384:	07a53023          	sd	s10,96(a0)
    80002388:	07b53423          	sd	s11,104(a0)
    8000238c:	0005b083          	ld	ra,0(a1)
    80002390:	0085b103          	ld	sp,8(a1)
    80002394:	6980                	ld	s0,16(a1)
    80002396:	6d84                	ld	s1,24(a1)
    80002398:	0205b903          	ld	s2,32(a1)
    8000239c:	0285b983          	ld	s3,40(a1)
    800023a0:	0305ba03          	ld	s4,48(a1)
    800023a4:	0385ba83          	ld	s5,56(a1)
    800023a8:	0405bb03          	ld	s6,64(a1)
    800023ac:	0485bb83          	ld	s7,72(a1)
    800023b0:	0505bc03          	ld	s8,80(a1)
    800023b4:	0585bc83          	ld	s9,88(a1)
    800023b8:	0605bd03          	ld	s10,96(a1)
    800023bc:	0685bd83          	ld	s11,104(a1)
    800023c0:	8082                	ret

00000000800023c2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023c2:	1141                	addi	sp,sp,-16
    800023c4:	e406                	sd	ra,8(sp)
    800023c6:	e022                	sd	s0,0(sp)
    800023c8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023ca:	00005597          	auipc	a1,0x5
    800023ce:	f1e58593          	addi	a1,a1,-226 # 800072e8 <etext+0x2e8>
    800023d2:	00016517          	auipc	a0,0x16
    800023d6:	6ee50513          	addi	a0,a0,1774 # 80018ac0 <tickslock>
    800023da:	fa0fe0ef          	jal	80000b7a <initlock>
}
    800023de:	60a2                	ld	ra,8(sp)
    800023e0:	6402                	ld	s0,0(sp)
    800023e2:	0141                	addi	sp,sp,16
    800023e4:	8082                	ret

00000000800023e6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023e6:	1141                	addi	sp,sp,-16
    800023e8:	e406                	sd	ra,8(sp)
    800023ea:	e022                	sd	s0,0(sp)
    800023ec:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023ee:	00003797          	auipc	a5,0x3
    800023f2:	f9278793          	addi	a5,a5,-110 # 80005380 <kernelvec>
    800023f6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023fa:	60a2                	ld	ra,8(sp)
    800023fc:	6402                	ld	s0,0(sp)
    800023fe:	0141                	addi	sp,sp,16
    80002400:	8082                	ret

0000000080002402 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002402:	1141                	addi	sp,sp,-16
    80002404:	e406                	sd	ra,8(sp)
    80002406:	e022                	sd	s0,0(sp)
    80002408:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000240a:	cd2ff0ef          	jal	800018dc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000240e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002412:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002414:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002418:	00004697          	auipc	a3,0x4
    8000241c:	be868693          	addi	a3,a3,-1048 # 80006000 <_trampoline>
    80002420:	00004717          	auipc	a4,0x4
    80002424:	be070713          	addi	a4,a4,-1056 # 80006000 <_trampoline>
    80002428:	8f15                	sub	a4,a4,a3
    8000242a:	040007b7          	lui	a5,0x4000
    8000242e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002430:	07b2                	slli	a5,a5,0xc
    80002432:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002434:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002438:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000243a:	18002673          	csrr	a2,satp
    8000243e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002440:	6d30                	ld	a2,88(a0)
    80002442:	6138                	ld	a4,64(a0)
    80002444:	6585                	lui	a1,0x1
    80002446:	972e                	add	a4,a4,a1
    80002448:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000244a:	6d38                	ld	a4,88(a0)
    8000244c:	00000617          	auipc	a2,0x0
    80002450:	11060613          	addi	a2,a2,272 # 8000255c <usertrap>
    80002454:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002456:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002458:	8612                	mv	a2,tp
    8000245a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000245c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002460:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002464:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002468:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000246c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000246e:	6f18                	ld	a4,24(a4)
    80002470:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002474:	6928                	ld	a0,80(a0)
    80002476:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002478:	00004717          	auipc	a4,0x4
    8000247c:	c2470713          	addi	a4,a4,-988 # 8000609c <userret>
    80002480:	8f15                	sub	a4,a4,a3
    80002482:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002484:	577d                	li	a4,-1
    80002486:	177e                	slli	a4,a4,0x3f
    80002488:	8d59                	or	a0,a0,a4
    8000248a:	9782                	jalr	a5
}
    8000248c:	60a2                	ld	ra,8(sp)
    8000248e:	6402                	ld	s0,0(sp)
    80002490:	0141                	addi	sp,sp,16
    80002492:	8082                	ret

0000000080002494 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002494:	1101                	addi	sp,sp,-32
    80002496:	ec06                	sd	ra,24(sp)
    80002498:	e822                	sd	s0,16(sp)
    8000249a:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000249c:	c0cff0ef          	jal	800018a8 <cpuid>
    800024a0:	cd11                	beqz	a0,800024bc <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024a2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024a6:	000f4737          	lui	a4,0xf4
    800024aa:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024ae:	97ba                	add	a5,a5,a4
  asm volatile("csrw stimecmp, %0" : : "r" (x));
    800024b0:	14d79073          	csrw	stimecmp,a5
}
    800024b4:	60e2                	ld	ra,24(sp)
    800024b6:	6442                	ld	s0,16(sp)
    800024b8:	6105                	addi	sp,sp,32
    800024ba:	8082                	ret
    800024bc:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024be:	00016497          	auipc	s1,0x16
    800024c2:	60248493          	addi	s1,s1,1538 # 80018ac0 <tickslock>
    800024c6:	8526                	mv	a0,s1
    800024c8:	f36fe0ef          	jal	80000bfe <acquire>
    ticks++;
    800024cc:	00008517          	auipc	a0,0x8
    800024d0:	e9450513          	addi	a0,a0,-364 # 8000a360 <ticks>
    800024d4:	411c                	lw	a5,0(a0)
    800024d6:	2785                	addiw	a5,a5,1
    800024d8:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024da:	a3dff0ef          	jal	80001f16 <wakeup>
    release(&tickslock);
    800024de:	8526                	mv	a0,s1
    800024e0:	fb2fe0ef          	jal	80000c92 <release>
    800024e4:	64a2                	ld	s1,8(sp)
    800024e6:	bf75                	j	800024a2 <clockintr+0xe>

00000000800024e8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024e8:	1101                	addi	sp,sp,-32
    800024ea:	ec06                	sd	ra,24(sp)
    800024ec:	e822                	sd	s0,16(sp)
    800024ee:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024f0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024f4:	57fd                	li	a5,-1
    800024f6:	17fe                	slli	a5,a5,0x3f
    800024f8:	07a5                	addi	a5,a5,9
    800024fa:	00f70c63          	beq	a4,a5,80002512 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024fe:	57fd                	li	a5,-1
    80002500:	17fe                	slli	a5,a5,0x3f
    80002502:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002504:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002506:	04f70763          	beq	a4,a5,80002554 <devintr+0x6c>
  }
}
    8000250a:	60e2                	ld	ra,24(sp)
    8000250c:	6442                	ld	s0,16(sp)
    8000250e:	6105                	addi	sp,sp,32
    80002510:	8082                	ret
    80002512:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002514:	719020ef          	jal	8000542c <plic_claim>
    80002518:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000251a:	47a9                	li	a5,10
    8000251c:	00f50963          	beq	a0,a5,8000252e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002520:	4785                	li	a5,1
    80002522:	00f50963          	beq	a0,a5,80002534 <devintr+0x4c>
    return 1;
    80002526:	4505                	li	a0,1
    } else if(irq){
    80002528:	e889                	bnez	s1,8000253a <devintr+0x52>
    8000252a:	64a2                	ld	s1,8(sp)
    8000252c:	bff9                	j	8000250a <devintr+0x22>
      uartintr();
    8000252e:	cdefe0ef          	jal	80000a0c <uartintr>
    if(irq)
    80002532:	a819                	j	80002548 <devintr+0x60>
      virtio_disk_intr();
    80002534:	388030ef          	jal	800058bc <virtio_disk_intr>
    if(irq)
    80002538:	a801                	j	80002548 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000253a:	85a6                	mv	a1,s1
    8000253c:	00005517          	auipc	a0,0x5
    80002540:	db450513          	addi	a0,a0,-588 # 800072f0 <etext+0x2f0>
    80002544:	f8bfd0ef          	jal	800004ce <printf>
      plic_complete(irq);
    80002548:	8526                	mv	a0,s1
    8000254a:	703020ef          	jal	8000544c <plic_complete>
    return 1;
    8000254e:	4505                	li	a0,1
    80002550:	64a2                	ld	s1,8(sp)
    80002552:	bf65                	j	8000250a <devintr+0x22>
    clockintr();
    80002554:	f41ff0ef          	jal	80002494 <clockintr>
    return 2;
    80002558:	4509                	li	a0,2
    8000255a:	bf45                	j	8000250a <devintr+0x22>

000000008000255c <usertrap>:
{
    8000255c:	1101                	addi	sp,sp,-32
    8000255e:	ec06                	sd	ra,24(sp)
    80002560:	e822                	sd	s0,16(sp)
    80002562:	e426                	sd	s1,8(sp)
    80002564:	e04a                	sd	s2,0(sp)
    80002566:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002568:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000256c:	1007f793          	andi	a5,a5,256
    80002570:	ef85                	bnez	a5,800025a8 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002572:	00003797          	auipc	a5,0x3
    80002576:	e0e78793          	addi	a5,a5,-498 # 80005380 <kernelvec>
    8000257a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000257e:	b5eff0ef          	jal	800018dc <myproc>
    80002582:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002584:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002586:	14102773          	csrr	a4,sepc
    8000258a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000258c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002590:	47a1                	li	a5,8
    80002592:	02f70163          	beq	a4,a5,800025b4 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002596:	f53ff0ef          	jal	800024e8 <devintr>
    8000259a:	892a                	mv	s2,a0
    8000259c:	c135                	beqz	a0,80002600 <usertrap+0xa4>
  if(killed(p))
    8000259e:	8526                	mv	a0,s1
    800025a0:	b63ff0ef          	jal	80002102 <killed>
    800025a4:	cd1d                	beqz	a0,800025e2 <usertrap+0x86>
    800025a6:	a81d                	j	800025dc <usertrap+0x80>
    panic("usertrap: not from user mode");
    800025a8:	00005517          	auipc	a0,0x5
    800025ac:	d6850513          	addi	a0,a0,-664 # 80007310 <etext+0x310>
    800025b0:	9eefe0ef          	jal	8000079e <panic>
    if(killed(p))
    800025b4:	b4fff0ef          	jal	80002102 <killed>
    800025b8:	e121                	bnez	a0,800025f8 <usertrap+0x9c>
    p->trapframe->epc += 4;
    800025ba:	6cb8                	ld	a4,88(s1)
    800025bc:	6f1c                	ld	a5,24(a4)
    800025be:	0791                	addi	a5,a5,4
    800025c0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025c6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025ca:	10079073          	csrw	sstatus,a5
    syscall();
    800025ce:	280000ef          	jal	8000284e <syscall>
  if(killed(p))
    800025d2:	8526                	mv	a0,s1
    800025d4:	b2fff0ef          	jal	80002102 <killed>
    800025d8:	c901                	beqz	a0,800025e8 <usertrap+0x8c>
    800025da:	4901                	li	s2,0
    exit(-1);
    800025dc:	557d                	li	a0,-1
    800025de:	9f9ff0ef          	jal	80001fd6 <exit>
  if(which_dev == 2) {
    800025e2:	4789                	li	a5,2
    800025e4:	04f90563          	beq	s2,a5,8000262e <usertrap+0xd2>
  usertrapret();
    800025e8:	e1bff0ef          	jal	80002402 <usertrapret>
}
    800025ec:	60e2                	ld	ra,24(sp)
    800025ee:	6442                	ld	s0,16(sp)
    800025f0:	64a2                	ld	s1,8(sp)
    800025f2:	6902                	ld	s2,0(sp)
    800025f4:	6105                	addi	sp,sp,32
    800025f6:	8082                	ret
      exit(-1);
    800025f8:	557d                	li	a0,-1
    800025fa:	9ddff0ef          	jal	80001fd6 <exit>
    800025fe:	bf75                	j	800025ba <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002600:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002604:	5890                	lw	a2,48(s1)
    80002606:	00005517          	auipc	a0,0x5
    8000260a:	d2a50513          	addi	a0,a0,-726 # 80007330 <etext+0x330>
    8000260e:	ec1fd0ef          	jal	800004ce <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002612:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002616:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000261a:	00005517          	auipc	a0,0x5
    8000261e:	d4650513          	addi	a0,a0,-698 # 80007360 <etext+0x360>
    80002622:	eadfd0ef          	jal	800004ce <printf>
    setkilled(p);
    80002626:	8526                	mv	a0,s1
    80002628:	ab7ff0ef          	jal	800020de <setkilled>
    8000262c:	b75d                	j	800025d2 <usertrap+0x76>
    struct proc *p = myproc();
    8000262e:	aaeff0ef          	jal	800018dc <myproc>
    80002632:	84aa                	mv	s1,a0
    if(p != 0 && p->alarm_on) {
    80002634:	d955                	beqz	a0,800025e8 <usertrap+0x8c>
    80002636:	17c52783          	lw	a5,380(a0)
    8000263a:	d7dd                	beqz	a5,800025e8 <usertrap+0x8c>
      p->ticks_count++;
    8000263c:	17852783          	lw	a5,376(a0)
    80002640:	2785                	addiw	a5,a5,1
    80002642:	16f52c23          	sw	a5,376(a0)
      if(p->ticks_count >= p->alarm_interval) {
    80002646:	16852703          	lw	a4,360(a0)
    8000264a:	f8e7cfe3          	blt	a5,a4,800025e8 <usertrap+0x8c>
        p->ticks_count = 0;
    8000264e:	16052c23          	sw	zero,376(a0)
        if(p->alarm_trapframe == 0) {
    80002652:	18053783          	ld	a5,384(a0)
    80002656:	fbc9                	bnez	a5,800025e8 <usertrap+0x8c>
          p->alarm_trapframe = kalloc();
    80002658:	cd2fe0ef          	jal	80000b2a <kalloc>
    8000265c:	18a4b023          	sd	a0,384(s1)
          memmove(p->alarm_trapframe, p->trapframe, sizeof(struct trapframe));
    80002660:	12000613          	li	a2,288
    80002664:	6cac                	ld	a1,88(s1)
    80002666:	eccfe0ef          	jal	80000d32 <memmove>
          p->trapframe->epc = (uint64)p->alarm_handler;
    8000266a:	6cbc                	ld	a5,88(s1)
    8000266c:	1704b703          	ld	a4,368(s1)
    80002670:	ef98                	sd	a4,24(a5)
    80002672:	bf9d                	j	800025e8 <usertrap+0x8c>

0000000080002674 <kerneltrap>:
{
    80002674:	7179                	addi	sp,sp,-48
    80002676:	f406                	sd	ra,40(sp)
    80002678:	f022                	sd	s0,32(sp)
    8000267a:	ec26                	sd	s1,24(sp)
    8000267c:	e84a                	sd	s2,16(sp)
    8000267e:	e44e                	sd	s3,8(sp)
    80002680:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002682:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002686:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000268a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000268e:	1004f793          	andi	a5,s1,256
    80002692:	c795                	beqz	a5,800026be <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002694:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002698:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000269a:	eb85                	bnez	a5,800026ca <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000269c:	e4dff0ef          	jal	800024e8 <devintr>
    800026a0:	c91d                	beqz	a0,800026d6 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800026a2:	4789                	li	a5,2
    800026a4:	04f50a63          	beq	a0,a5,800026f8 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026a8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ac:	10049073          	csrw	sstatus,s1
}
    800026b0:	70a2                	ld	ra,40(sp)
    800026b2:	7402                	ld	s0,32(sp)
    800026b4:	64e2                	ld	s1,24(sp)
    800026b6:	6942                	ld	s2,16(sp)
    800026b8:	69a2                	ld	s3,8(sp)
    800026ba:	6145                	addi	sp,sp,48
    800026bc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026be:	00005517          	auipc	a0,0x5
    800026c2:	cca50513          	addi	a0,a0,-822 # 80007388 <etext+0x388>
    800026c6:	8d8fe0ef          	jal	8000079e <panic>
    panic("kerneltrap: interrupts enabled");
    800026ca:	00005517          	auipc	a0,0x5
    800026ce:	ce650513          	addi	a0,a0,-794 # 800073b0 <etext+0x3b0>
    800026d2:	8ccfe0ef          	jal	8000079e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026d6:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026da:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026de:	85ce                	mv	a1,s3
    800026e0:	00005517          	auipc	a0,0x5
    800026e4:	cf050513          	addi	a0,a0,-784 # 800073d0 <etext+0x3d0>
    800026e8:	de7fd0ef          	jal	800004ce <printf>
    panic("kerneltrap");
    800026ec:	00005517          	auipc	a0,0x5
    800026f0:	d0c50513          	addi	a0,a0,-756 # 800073f8 <etext+0x3f8>
    800026f4:	8aafe0ef          	jal	8000079e <panic>
  if(which_dev == 2 && myproc() != 0)
    800026f8:	9e4ff0ef          	jal	800018dc <myproc>
    800026fc:	d555                	beqz	a0,800026a8 <kerneltrap+0x34>
    yield();
    800026fe:	fa0ff0ef          	jal	80001e9e <yield>
    80002702:	b75d                	j	800026a8 <kerneltrap+0x34>

0000000080002704 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002704:	1101                	addi	sp,sp,-32
    80002706:	ec06                	sd	ra,24(sp)
    80002708:	e822                	sd	s0,16(sp)
    8000270a:	e426                	sd	s1,8(sp)
    8000270c:	1000                	addi	s0,sp,32
    8000270e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002710:	9ccff0ef          	jal	800018dc <myproc>
  switch (n) {
    80002714:	4795                	li	a5,5
    80002716:	0497e163          	bltu	a5,s1,80002758 <argraw+0x54>
    8000271a:	048a                	slli	s1,s1,0x2
    8000271c:	00005717          	auipc	a4,0x5
    80002720:	0a470713          	addi	a4,a4,164 # 800077c0 <states.0+0x30>
    80002724:	94ba                	add	s1,s1,a4
    80002726:	409c                	lw	a5,0(s1)
    80002728:	97ba                	add	a5,a5,a4
    8000272a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000272c:	6d3c                	ld	a5,88(a0)
    8000272e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002730:	60e2                	ld	ra,24(sp)
    80002732:	6442                	ld	s0,16(sp)
    80002734:	64a2                	ld	s1,8(sp)
    80002736:	6105                	addi	sp,sp,32
    80002738:	8082                	ret
    return p->trapframe->a1;
    8000273a:	6d3c                	ld	a5,88(a0)
    8000273c:	7fa8                	ld	a0,120(a5)
    8000273e:	bfcd                	j	80002730 <argraw+0x2c>
    return p->trapframe->a2;
    80002740:	6d3c                	ld	a5,88(a0)
    80002742:	63c8                	ld	a0,128(a5)
    80002744:	b7f5                	j	80002730 <argraw+0x2c>
    return p->trapframe->a3;
    80002746:	6d3c                	ld	a5,88(a0)
    80002748:	67c8                	ld	a0,136(a5)
    8000274a:	b7dd                	j	80002730 <argraw+0x2c>
    return p->trapframe->a4;
    8000274c:	6d3c                	ld	a5,88(a0)
    8000274e:	6bc8                	ld	a0,144(a5)
    80002750:	b7c5                	j	80002730 <argraw+0x2c>
    return p->trapframe->a5;
    80002752:	6d3c                	ld	a5,88(a0)
    80002754:	6fc8                	ld	a0,152(a5)
    80002756:	bfe9                	j	80002730 <argraw+0x2c>
  panic("argraw");
    80002758:	00005517          	auipc	a0,0x5
    8000275c:	cb050513          	addi	a0,a0,-848 # 80007408 <etext+0x408>
    80002760:	83efe0ef          	jal	8000079e <panic>

0000000080002764 <fetchaddr>:
{
    80002764:	1101                	addi	sp,sp,-32
    80002766:	ec06                	sd	ra,24(sp)
    80002768:	e822                	sd	s0,16(sp)
    8000276a:	e426                	sd	s1,8(sp)
    8000276c:	e04a                	sd	s2,0(sp)
    8000276e:	1000                	addi	s0,sp,32
    80002770:	84aa                	mv	s1,a0
    80002772:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002774:	968ff0ef          	jal	800018dc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002778:	653c                	ld	a5,72(a0)
    8000277a:	02f4f663          	bgeu	s1,a5,800027a6 <fetchaddr+0x42>
    8000277e:	00848713          	addi	a4,s1,8
    80002782:	02e7e463          	bltu	a5,a4,800027aa <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002786:	46a1                	li	a3,8
    80002788:	8626                	mv	a2,s1
    8000278a:	85ca                	mv	a1,s2
    8000278c:	6928                	ld	a0,80(a0)
    8000278e:	ea7fe0ef          	jal	80001634 <copyin>
    80002792:	00a03533          	snez	a0,a0
    80002796:	40a0053b          	negw	a0,a0
}
    8000279a:	60e2                	ld	ra,24(sp)
    8000279c:	6442                	ld	s0,16(sp)
    8000279e:	64a2                	ld	s1,8(sp)
    800027a0:	6902                	ld	s2,0(sp)
    800027a2:	6105                	addi	sp,sp,32
    800027a4:	8082                	ret
    return -1;
    800027a6:	557d                	li	a0,-1
    800027a8:	bfcd                	j	8000279a <fetchaddr+0x36>
    800027aa:	557d                	li	a0,-1
    800027ac:	b7fd                	j	8000279a <fetchaddr+0x36>

00000000800027ae <fetchstr>:
{
    800027ae:	7179                	addi	sp,sp,-48
    800027b0:	f406                	sd	ra,40(sp)
    800027b2:	f022                	sd	s0,32(sp)
    800027b4:	ec26                	sd	s1,24(sp)
    800027b6:	e84a                	sd	s2,16(sp)
    800027b8:	e44e                	sd	s3,8(sp)
    800027ba:	1800                	addi	s0,sp,48
    800027bc:	892a                	mv	s2,a0
    800027be:	84ae                	mv	s1,a1
    800027c0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027c2:	91aff0ef          	jal	800018dc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027c6:	86ce                	mv	a3,s3
    800027c8:	864a                	mv	a2,s2
    800027ca:	85a6                	mv	a1,s1
    800027cc:	6928                	ld	a0,80(a0)
    800027ce:	eedfe0ef          	jal	800016ba <copyinstr>
    800027d2:	00054c63          	bltz	a0,800027ea <fetchstr+0x3c>
  return strlen(buf);
    800027d6:	8526                	mv	a0,s1
    800027d8:	e7efe0ef          	jal	80000e56 <strlen>
}
    800027dc:	70a2                	ld	ra,40(sp)
    800027de:	7402                	ld	s0,32(sp)
    800027e0:	64e2                	ld	s1,24(sp)
    800027e2:	6942                	ld	s2,16(sp)
    800027e4:	69a2                	ld	s3,8(sp)
    800027e6:	6145                	addi	sp,sp,48
    800027e8:	8082                	ret
    return -1;
    800027ea:	557d                	li	a0,-1
    800027ec:	bfc5                	j	800027dc <fetchstr+0x2e>

00000000800027ee <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027ee:	1101                	addi	sp,sp,-32
    800027f0:	ec06                	sd	ra,24(sp)
    800027f2:	e822                	sd	s0,16(sp)
    800027f4:	e426                	sd	s1,8(sp)
    800027f6:	1000                	addi	s0,sp,32
    800027f8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027fa:	f0bff0ef          	jal	80002704 <argraw>
    800027fe:	c088                	sw	a0,0(s1)
}
    80002800:	60e2                	ld	ra,24(sp)
    80002802:	6442                	ld	s0,16(sp)
    80002804:	64a2                	ld	s1,8(sp)
    80002806:	6105                	addi	sp,sp,32
    80002808:	8082                	ret

000000008000280a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000280a:	1101                	addi	sp,sp,-32
    8000280c:	ec06                	sd	ra,24(sp)
    8000280e:	e822                	sd	s0,16(sp)
    80002810:	e426                	sd	s1,8(sp)
    80002812:	1000                	addi	s0,sp,32
    80002814:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002816:	eefff0ef          	jal	80002704 <argraw>
    8000281a:	e088                	sd	a0,0(s1)
}
    8000281c:	60e2                	ld	ra,24(sp)
    8000281e:	6442                	ld	s0,16(sp)
    80002820:	64a2                	ld	s1,8(sp)
    80002822:	6105                	addi	sp,sp,32
    80002824:	8082                	ret

0000000080002826 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002826:	1101                	addi	sp,sp,-32
    80002828:	ec06                	sd	ra,24(sp)
    8000282a:	e822                	sd	s0,16(sp)
    8000282c:	e426                	sd	s1,8(sp)
    8000282e:	e04a                	sd	s2,0(sp)
    80002830:	1000                	addi	s0,sp,32
    80002832:	84ae                	mv	s1,a1
    80002834:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002836:	ecfff0ef          	jal	80002704 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000283a:	864a                	mv	a2,s2
    8000283c:	85a6                	mv	a1,s1
    8000283e:	f71ff0ef          	jal	800027ae <fetchstr>
}
    80002842:	60e2                	ld	ra,24(sp)
    80002844:	6442                	ld	s0,16(sp)
    80002846:	64a2                	ld	s1,8(sp)
    80002848:	6902                	ld	s2,0(sp)
    8000284a:	6105                	addi	sp,sp,32
    8000284c:	8082                	ret

000000008000284e <syscall>:
};


void
syscall(void)
{
    8000284e:	1101                	addi	sp,sp,-32
    80002850:	ec06                	sd	ra,24(sp)
    80002852:	e822                	sd	s0,16(sp)
    80002854:	e426                	sd	s1,8(sp)
    80002856:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002858:	884ff0ef          	jal	800018dc <myproc>
    8000285c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000285e:	6d3c                	ld	a5,88(a0)
    80002860:	77dc                	ld	a5,168(a5)
    80002862:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002866:	37fd                	addiw	a5,a5,-1
    80002868:	475d                	li	a4,23
    8000286a:	02f76763          	bltu	a4,a5,80002898 <syscall+0x4a>
    8000286e:	00369713          	slli	a4,a3,0x3
    80002872:	00005797          	auipc	a5,0x5
    80002876:	f6678793          	addi	a5,a5,-154 # 800077d8 <syscalls>
    8000287a:	97ba                	add	a5,a5,a4
    8000287c:	6390                	ld	a2,0(a5)
    8000287e:	ce09                	beqz	a2,80002898 <syscall+0x4a>
    // increment count of syscall
    syscall_counts[num]++;
    80002880:	00016797          	auipc	a5,0x16
    80002884:	25878793          	addi	a5,a5,600 # 80018ad8 <syscall_counts>
    80002888:	97ba                	add	a5,a5,a4
    8000288a:	6398                	ld	a4,0(a5)
    8000288c:	0705                	addi	a4,a4,1
    8000288e:	e398                	sd	a4,0(a5)
        //printsyscall(num);
        //printf(" [syscall %d is run %ld times]\n", num, p->syscall_counts[num]);
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002890:	6d24                	ld	s1,88(a0)
    80002892:	9602                	jalr	a2
    80002894:	f8a8                	sd	a0,112(s1)
    80002896:	a829                	j	800028b0 <syscall+0x62>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002898:	15848613          	addi	a2,s1,344
    8000289c:	588c                	lw	a1,48(s1)
    8000289e:	00005517          	auipc	a0,0x5
    800028a2:	b7250513          	addi	a0,a0,-1166 # 80007410 <etext+0x410>
    800028a6:	c29fd0ef          	jal	800004ce <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800028aa:	6cbc                	ld	a5,88(s1)
    800028ac:	577d                	li	a4,-1
    800028ae:	fbb8                	sd	a4,112(a5)
  }
}
    800028b0:	60e2                	ld	ra,24(sp)
    800028b2:	6442                	ld	s0,16(sp)
    800028b4:	64a2                	ld	s1,8(sp)
    800028b6:	6105                	addi	sp,sp,32
    800028b8:	8082                	ret

00000000800028ba <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800028ba:	1101                	addi	sp,sp,-32
    800028bc:	ec06                	sd	ra,24(sp)
    800028be:	e822                	sd	s0,16(sp)
    800028c0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028c2:	fec40593          	addi	a1,s0,-20
    800028c6:	4501                	li	a0,0
    800028c8:	f27ff0ef          	jal	800027ee <argint>
  exit(n);
    800028cc:	fec42503          	lw	a0,-20(s0)
    800028d0:	f06ff0ef          	jal	80001fd6 <exit>
  return 0;  // not reached
}
    800028d4:	4501                	li	a0,0
    800028d6:	60e2                	ld	ra,24(sp)
    800028d8:	6442                	ld	s0,16(sp)
    800028da:	6105                	addi	sp,sp,32
    800028dc:	8082                	ret

00000000800028de <sys_getpid>:

uint64
sys_getpid(void)
{
    800028de:	1141                	addi	sp,sp,-16
    800028e0:	e406                	sd	ra,8(sp)
    800028e2:	e022                	sd	s0,0(sp)
    800028e4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028e6:	ff7fe0ef          	jal	800018dc <myproc>
}
    800028ea:	5908                	lw	a0,48(a0)
    800028ec:	60a2                	ld	ra,8(sp)
    800028ee:	6402                	ld	s0,0(sp)
    800028f0:	0141                	addi	sp,sp,16
    800028f2:	8082                	ret

00000000800028f4 <sys_fork>:

uint64
sys_fork(void)
{
    800028f4:	1141                	addi	sp,sp,-16
    800028f6:	e406                	sd	ra,8(sp)
    800028f8:	e022                	sd	s0,0(sp)
    800028fa:	0800                	addi	s0,sp,16
  return fork();
    800028fc:	b06ff0ef          	jal	80001c02 <fork>
}
    80002900:	60a2                	ld	ra,8(sp)
    80002902:	6402                	ld	s0,0(sp)
    80002904:	0141                	addi	sp,sp,16
    80002906:	8082                	ret

0000000080002908 <sys_wait>:

uint64
sys_wait(void)
{
    80002908:	1101                	addi	sp,sp,-32
    8000290a:	ec06                	sd	ra,24(sp)
    8000290c:	e822                	sd	s0,16(sp)
    8000290e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002910:	fe840593          	addi	a1,s0,-24
    80002914:	4501                	li	a0,0
    80002916:	ef5ff0ef          	jal	8000280a <argaddr>
  return wait(p);
    8000291a:	fe843503          	ld	a0,-24(s0)
    8000291e:	80fff0ef          	jal	8000212c <wait>
}
    80002922:	60e2                	ld	ra,24(sp)
    80002924:	6442                	ld	s0,16(sp)
    80002926:	6105                	addi	sp,sp,32
    80002928:	8082                	ret

000000008000292a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000292a:	7179                	addi	sp,sp,-48
    8000292c:	f406                	sd	ra,40(sp)
    8000292e:	f022                	sd	s0,32(sp)
    80002930:	ec26                	sd	s1,24(sp)
    80002932:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002934:	fdc40593          	addi	a1,s0,-36
    80002938:	4501                	li	a0,0
    8000293a:	eb5ff0ef          	jal	800027ee <argint>
  addr = myproc()->sz;
    8000293e:	f9ffe0ef          	jal	800018dc <myproc>
    80002942:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002944:	fdc42503          	lw	a0,-36(s0)
    80002948:	a6aff0ef          	jal	80001bb2 <growproc>
    8000294c:	00054863          	bltz	a0,8000295c <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002950:	8526                	mv	a0,s1
    80002952:	70a2                	ld	ra,40(sp)
    80002954:	7402                	ld	s0,32(sp)
    80002956:	64e2                	ld	s1,24(sp)
    80002958:	6145                	addi	sp,sp,48
    8000295a:	8082                	ret
    return -1;
    8000295c:	54fd                	li	s1,-1
    8000295e:	bfcd                	j	80002950 <sys_sbrk+0x26>

0000000080002960 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002960:	7139                	addi	sp,sp,-64
    80002962:	fc06                	sd	ra,56(sp)
    80002964:	f822                	sd	s0,48(sp)
    80002966:	f04a                	sd	s2,32(sp)
    80002968:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000296a:	fcc40593          	addi	a1,s0,-52
    8000296e:	4501                	li	a0,0
    80002970:	e7fff0ef          	jal	800027ee <argint>
  if(n < 0)
    80002974:	fcc42783          	lw	a5,-52(s0)
    80002978:	0607c763          	bltz	a5,800029e6 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    8000297c:	00016517          	auipc	a0,0x16
    80002980:	14450513          	addi	a0,a0,324 # 80018ac0 <tickslock>
    80002984:	a7afe0ef          	jal	80000bfe <acquire>
  ticks0 = ticks;
    80002988:	00008917          	auipc	s2,0x8
    8000298c:	9d892903          	lw	s2,-1576(s2) # 8000a360 <ticks>
  while(ticks - ticks0 < n){
    80002990:	fcc42783          	lw	a5,-52(s0)
    80002994:	cf8d                	beqz	a5,800029ce <sys_sleep+0x6e>
    80002996:	f426                	sd	s1,40(sp)
    80002998:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000299a:	00016997          	auipc	s3,0x16
    8000299e:	12698993          	addi	s3,s3,294 # 80018ac0 <tickslock>
    800029a2:	00008497          	auipc	s1,0x8
    800029a6:	9be48493          	addi	s1,s1,-1602 # 8000a360 <ticks>
    if(killed(myproc())){
    800029aa:	f33fe0ef          	jal	800018dc <myproc>
    800029ae:	f54ff0ef          	jal	80002102 <killed>
    800029b2:	ed0d                	bnez	a0,800029ec <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800029b4:	85ce                	mv	a1,s3
    800029b6:	8526                	mv	a0,s1
    800029b8:	d12ff0ef          	jal	80001eca <sleep>
  while(ticks - ticks0 < n){
    800029bc:	409c                	lw	a5,0(s1)
    800029be:	412787bb          	subw	a5,a5,s2
    800029c2:	fcc42703          	lw	a4,-52(s0)
    800029c6:	fee7e2e3          	bltu	a5,a4,800029aa <sys_sleep+0x4a>
    800029ca:	74a2                	ld	s1,40(sp)
    800029cc:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029ce:	00016517          	auipc	a0,0x16
    800029d2:	0f250513          	addi	a0,a0,242 # 80018ac0 <tickslock>
    800029d6:	abcfe0ef          	jal	80000c92 <release>
  return 0;
    800029da:	4501                	li	a0,0
}
    800029dc:	70e2                	ld	ra,56(sp)
    800029de:	7442                	ld	s0,48(sp)
    800029e0:	7902                	ld	s2,32(sp)
    800029e2:	6121                	addi	sp,sp,64
    800029e4:	8082                	ret
    n = 0;
    800029e6:	fc042623          	sw	zero,-52(s0)
    800029ea:	bf49                	j	8000297c <sys_sleep+0x1c>
      release(&tickslock);
    800029ec:	00016517          	auipc	a0,0x16
    800029f0:	0d450513          	addi	a0,a0,212 # 80018ac0 <tickslock>
    800029f4:	a9efe0ef          	jal	80000c92 <release>
      return -1;
    800029f8:	557d                	li	a0,-1
    800029fa:	74a2                	ld	s1,40(sp)
    800029fc:	69e2                	ld	s3,24(sp)
    800029fe:	bff9                	j	800029dc <sys_sleep+0x7c>

0000000080002a00 <sys_kill>:

uint64
sys_kill(void)
{
    80002a00:	1101                	addi	sp,sp,-32
    80002a02:	ec06                	sd	ra,24(sp)
    80002a04:	e822                	sd	s0,16(sp)
    80002a06:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a08:	fec40593          	addi	a1,s0,-20
    80002a0c:	4501                	li	a0,0
    80002a0e:	de1ff0ef          	jal	800027ee <argint>
  return kill(pid);
    80002a12:	fec42503          	lw	a0,-20(s0)
    80002a16:	e62ff0ef          	jal	80002078 <kill>
}
    80002a1a:	60e2                	ld	ra,24(sp)
    80002a1c:	6442                	ld	s0,16(sp)
    80002a1e:	6105                	addi	sp,sp,32
    80002a20:	8082                	ret

0000000080002a22 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a22:	1101                	addi	sp,sp,-32
    80002a24:	ec06                	sd	ra,24(sp)
    80002a26:	e822                	sd	s0,16(sp)
    80002a28:	e426                	sd	s1,8(sp)
    80002a2a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a2c:	00016517          	auipc	a0,0x16
    80002a30:	09450513          	addi	a0,a0,148 # 80018ac0 <tickslock>
    80002a34:	9cafe0ef          	jal	80000bfe <acquire>
  xticks = ticks;
    80002a38:	00008497          	auipc	s1,0x8
    80002a3c:	9284a483          	lw	s1,-1752(s1) # 8000a360 <ticks>
  release(&tickslock);
    80002a40:	00016517          	auipc	a0,0x16
    80002a44:	08050513          	addi	a0,a0,128 # 80018ac0 <tickslock>
    80002a48:	a4afe0ef          	jal	80000c92 <release>
  return xticks;
}
    80002a4c:	02049513          	slli	a0,s1,0x20
    80002a50:	9101                	srli	a0,a0,0x20
    80002a52:	60e2                	ld	ra,24(sp)
    80002a54:	6442                	ld	s0,16(sp)
    80002a56:	64a2                	ld	s1,8(sp)
    80002a58:	6105                	addi	sp,sp,32
    80002a5a:	8082                	ret

0000000080002a5c <sys_getSyscount>:

uint64
sys_getSyscount(void)
{
    80002a5c:	1101                	addi	sp,sp,-32
    80002a5e:	ec06                	sd	ra,24(sp)
    80002a60:	e822                	sd	s0,16(sp)
    80002a62:	1000                	addi	s0,sp,32
  int mask;
  argint(0, &mask);
    80002a64:	fec40593          	addi	a1,s0,-20
    80002a68:	4501                	li	a0,0
    80002a6a:	d85ff0ef          	jal	800027ee <argint>
  if(mask < 0)
    80002a6e:	fec42683          	lw	a3,-20(s0)
    80002a72:	0406c663          	bltz	a3,80002abe <sys_getSyscount+0x62>
    return -1;
  
  // Find the syscall number from the mask
  int syscall_num = -1;
  for(int i = 0; i < 32; i++) {
    80002a76:	4701                	li	a4,0
    if(mask == (1 << i)) {
    80002a78:	4605                	li	a2,1
  for(int i = 0; i < 32; i++) {
    80002a7a:	02000593          	li	a1,32
    if(mask == (1 << i)) {
    80002a7e:	00e617bb          	sllw	a5,a2,a4
    80002a82:	00d78763          	beq	a5,a3,80002a90 <sys_getSyscount+0x34>
  for(int i = 0; i < 32; i++) {
    80002a86:	2705                	addiw	a4,a4,1
    80002a88:	feb71be3          	bne	a4,a1,80002a7e <sys_getSyscount+0x22>
      break;
    }
  }
  
  if(syscall_num == -1)
    return -1;
    80002a8c:	557d                	li	a0,-1
    80002a8e:	a025                	j	80002ab6 <sys_getSyscount+0x5a>
  if(syscall_num == -1)
    80002a90:	57fd                	li	a5,-1
    80002a92:	02f70863          	beq	a4,a5,80002ac2 <sys_getSyscount+0x66>
  //struct proc *p = myproc();

  int RETVALL = syscall_counts[syscall_num];
    80002a96:	00016797          	auipc	a5,0x16
    80002a9a:	04278793          	addi	a5,a5,66 # 80018ad8 <syscall_counts>
    80002a9e:	070e                	slli	a4,a4,0x3
    80002aa0:	973e                	add	a4,a4,a5
    80002aa2:	4308                	lw	a0,0(a4)

  // reset count
  for(int i=0; i<=NUMBER_OF_SYSCALLS; i++){
    80002aa4:	00016717          	auipc	a4,0x16
    80002aa8:	0ec70713          	addi	a4,a4,236 # 80018b90 <bcache>
    syscall_counts[i] = 0;
    80002aac:	0007b023          	sd	zero,0(a5)
  for(int i=0; i<=NUMBER_OF_SYSCALLS; i++){
    80002ab0:	07a1                	addi	a5,a5,8
    80002ab2:	fee79de3          	bne	a5,a4,80002aac <sys_getSyscount+0x50>
  }
  return RETVALL;
}
    80002ab6:	60e2                	ld	ra,24(sp)
    80002ab8:	6442                	ld	s0,16(sp)
    80002aba:	6105                	addi	sp,sp,32
    80002abc:	8082                	ret
    return -1;
    80002abe:	557d                	li	a0,-1
    80002ac0:	bfdd                	j	80002ab6 <sys_getSyscount+0x5a>
    return -1;
    80002ac2:	557d                	li	a0,-1
    80002ac4:	bfcd                	j	80002ab6 <sys_getSyscount+0x5a>

0000000080002ac6 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80002ac6:	7179                	addi	sp,sp,-48
    80002ac8:	f406                	sd	ra,40(sp)
    80002aca:	f022                	sd	s0,32(sp)
    80002acc:	ec26                	sd	s1,24(sp)
    80002ace:	1800                	addi	s0,sp,48
  int interval;
  uint64 handler;
  argint(0, &interval);
    80002ad0:	fdc40593          	addi	a1,s0,-36
    80002ad4:	4501                	li	a0,0
    80002ad6:	d19ff0ef          	jal	800027ee <argint>
  argaddr(1, &handler);
    80002ada:	fd040493          	addi	s1,s0,-48
    80002ade:	85a6                	mv	a1,s1
    80002ae0:	4505                	li	a0,1
    80002ae2:	d29ff0ef          	jal	8000280a <argaddr>
  printf("%p\n", &handler);
    80002ae6:	85a6                	mv	a1,s1
    80002ae8:	00005517          	auipc	a0,0x5
    80002aec:	94850513          	addi	a0,a0,-1720 # 80007430 <etext+0x430>
    80002af0:	9dffd0ef          	jal	800004ce <printf>
  struct proc *p = myproc();
    80002af4:	de9fe0ef          	jal	800018dc <myproc>
  p->alarm_interval = interval;
    80002af8:	fdc42783          	lw	a5,-36(s0)
    80002afc:	16f52423          	sw	a5,360(a0)
  p->alarm_handler = (void(*)())handler;
    80002b00:	fd043703          	ld	a4,-48(s0)
    80002b04:	16e53823          	sd	a4,368(a0)
  p->ticks_count = 0;
    80002b08:	16052c23          	sw	zero,376(a0)
  p->alarm_on = (interval > 0);
    80002b0c:	00f027b3          	sgtz	a5,a5
    80002b10:	16f52e23          	sw	a5,380(a0)
  
  return 0;
}
    80002b14:	4501                	li	a0,0
    80002b16:	70a2                	ld	ra,40(sp)
    80002b18:	7402                	ld	s0,32(sp)
    80002b1a:	64e2                	ld	s1,24(sp)
    80002b1c:	6145                	addi	sp,sp,48
    80002b1e:	8082                	ret

0000000080002b20 <sys_sigreturn>:


uint64
sys_sigreturn(void)
{
    80002b20:	1101                	addi	sp,sp,-32
    80002b22:	ec06                	sd	ra,24(sp)
    80002b24:	e822                	sd	s0,16(sp)
    80002b26:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002b28:	db5fe0ef          	jal	800018dc <myproc>
  if(p->alarm_trapframe == 0)
    80002b2c:	18053583          	ld	a1,384(a0)
    80002b30:	c585                	beqz	a1,80002b58 <sys_sigreturn+0x38>
    80002b32:	e426                	sd	s1,8(sp)
    80002b34:	84aa                	mv	s1,a0
    return -1;
  
  memmove(p->trapframe, p->alarm_trapframe, sizeof(struct trapframe));
    80002b36:	12000613          	li	a2,288
    80002b3a:	6d28                	ld	a0,88(a0)
    80002b3c:	9f6fe0ef          	jal	80000d32 <memmove>
  kfree(p->alarm_trapframe);
    80002b40:	1804b503          	ld	a0,384(s1)
    80002b44:	f05fd0ef          	jal	80000a48 <kfree>
  p->alarm_trapframe = 0;
    80002b48:	1804b023          	sd	zero,384(s1)
  
  return 0;
    80002b4c:	4501                	li	a0,0
    80002b4e:	64a2                	ld	s1,8(sp)
}
    80002b50:	60e2                	ld	ra,24(sp)
    80002b52:	6442                	ld	s0,16(sp)
    80002b54:	6105                	addi	sp,sp,32
    80002b56:	8082                	ret
    return -1;
    80002b58:	557d                	li	a0,-1
    80002b5a:	bfdd                	j	80002b50 <sys_sigreturn+0x30>

0000000080002b5c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b5c:	7179                	addi	sp,sp,-48
    80002b5e:	f406                	sd	ra,40(sp)
    80002b60:	f022                	sd	s0,32(sp)
    80002b62:	ec26                	sd	s1,24(sp)
    80002b64:	e84a                	sd	s2,16(sp)
    80002b66:	e44e                	sd	s3,8(sp)
    80002b68:	e052                	sd	s4,0(sp)
    80002b6a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b6c:	00005597          	auipc	a1,0x5
    80002b70:	8cc58593          	addi	a1,a1,-1844 # 80007438 <etext+0x438>
    80002b74:	00016517          	auipc	a0,0x16
    80002b78:	01c50513          	addi	a0,a0,28 # 80018b90 <bcache>
    80002b7c:	ffffd0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b80:	0001e797          	auipc	a5,0x1e
    80002b84:	01078793          	addi	a5,a5,16 # 80020b90 <bcache+0x8000>
    80002b88:	0001e717          	auipc	a4,0x1e
    80002b8c:	27070713          	addi	a4,a4,624 # 80020df8 <bcache+0x8268>
    80002b90:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b94:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b98:	00016497          	auipc	s1,0x16
    80002b9c:	01048493          	addi	s1,s1,16 # 80018ba8 <bcache+0x18>
    b->next = bcache.head.next;
    80002ba0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ba2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ba4:	00005a17          	auipc	s4,0x5
    80002ba8:	89ca0a13          	addi	s4,s4,-1892 # 80007440 <etext+0x440>
    b->next = bcache.head.next;
    80002bac:	2b893783          	ld	a5,696(s2)
    80002bb0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bb2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bb6:	85d2                	mv	a1,s4
    80002bb8:	01048513          	addi	a0,s1,16
    80002bbc:	244010ef          	jal	80003e00 <initsleeplock>
    bcache.head.next->prev = b;
    80002bc0:	2b893783          	ld	a5,696(s2)
    80002bc4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bc6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bca:	45848493          	addi	s1,s1,1112
    80002bce:	fd349fe3          	bne	s1,s3,80002bac <binit+0x50>
  }
}
    80002bd2:	70a2                	ld	ra,40(sp)
    80002bd4:	7402                	ld	s0,32(sp)
    80002bd6:	64e2                	ld	s1,24(sp)
    80002bd8:	6942                	ld	s2,16(sp)
    80002bda:	69a2                	ld	s3,8(sp)
    80002bdc:	6a02                	ld	s4,0(sp)
    80002bde:	6145                	addi	sp,sp,48
    80002be0:	8082                	ret

0000000080002be2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002be2:	7179                	addi	sp,sp,-48
    80002be4:	f406                	sd	ra,40(sp)
    80002be6:	f022                	sd	s0,32(sp)
    80002be8:	ec26                	sd	s1,24(sp)
    80002bea:	e84a                	sd	s2,16(sp)
    80002bec:	e44e                	sd	s3,8(sp)
    80002bee:	1800                	addi	s0,sp,48
    80002bf0:	892a                	mv	s2,a0
    80002bf2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bf4:	00016517          	auipc	a0,0x16
    80002bf8:	f9c50513          	addi	a0,a0,-100 # 80018b90 <bcache>
    80002bfc:	802fe0ef          	jal	80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c00:	0001e497          	auipc	s1,0x1e
    80002c04:	2484b483          	ld	s1,584(s1) # 80020e48 <bcache+0x82b8>
    80002c08:	0001e797          	auipc	a5,0x1e
    80002c0c:	1f078793          	addi	a5,a5,496 # 80020df8 <bcache+0x8268>
    80002c10:	02f48b63          	beq	s1,a5,80002c46 <bread+0x64>
    80002c14:	873e                	mv	a4,a5
    80002c16:	a021                	j	80002c1e <bread+0x3c>
    80002c18:	68a4                	ld	s1,80(s1)
    80002c1a:	02e48663          	beq	s1,a4,80002c46 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c1e:	449c                	lw	a5,8(s1)
    80002c20:	ff279ce3          	bne	a5,s2,80002c18 <bread+0x36>
    80002c24:	44dc                	lw	a5,12(s1)
    80002c26:	ff3799e3          	bne	a5,s3,80002c18 <bread+0x36>
      b->refcnt++;
    80002c2a:	40bc                	lw	a5,64(s1)
    80002c2c:	2785                	addiw	a5,a5,1
    80002c2e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c30:	00016517          	auipc	a0,0x16
    80002c34:	f6050513          	addi	a0,a0,-160 # 80018b90 <bcache>
    80002c38:	85afe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002c3c:	01048513          	addi	a0,s1,16
    80002c40:	1f6010ef          	jal	80003e36 <acquiresleep>
      return b;
    80002c44:	a889                	j	80002c96 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c46:	0001e497          	auipc	s1,0x1e
    80002c4a:	1fa4b483          	ld	s1,506(s1) # 80020e40 <bcache+0x82b0>
    80002c4e:	0001e797          	auipc	a5,0x1e
    80002c52:	1aa78793          	addi	a5,a5,426 # 80020df8 <bcache+0x8268>
    80002c56:	00f48863          	beq	s1,a5,80002c66 <bread+0x84>
    80002c5a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c5c:	40bc                	lw	a5,64(s1)
    80002c5e:	cb91                	beqz	a5,80002c72 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c60:	64a4                	ld	s1,72(s1)
    80002c62:	fee49de3          	bne	s1,a4,80002c5c <bread+0x7a>
  panic("bget: no buffers");
    80002c66:	00004517          	auipc	a0,0x4
    80002c6a:	7e250513          	addi	a0,a0,2018 # 80007448 <etext+0x448>
    80002c6e:	b31fd0ef          	jal	8000079e <panic>
      b->dev = dev;
    80002c72:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c76:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c7a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c7e:	4785                	li	a5,1
    80002c80:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c82:	00016517          	auipc	a0,0x16
    80002c86:	f0e50513          	addi	a0,a0,-242 # 80018b90 <bcache>
    80002c8a:	808fe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002c8e:	01048513          	addi	a0,s1,16
    80002c92:	1a4010ef          	jal	80003e36 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c96:	409c                	lw	a5,0(s1)
    80002c98:	cb89                	beqz	a5,80002caa <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c9a:	8526                	mv	a0,s1
    80002c9c:	70a2                	ld	ra,40(sp)
    80002c9e:	7402                	ld	s0,32(sp)
    80002ca0:	64e2                	ld	s1,24(sp)
    80002ca2:	6942                	ld	s2,16(sp)
    80002ca4:	69a2                	ld	s3,8(sp)
    80002ca6:	6145                	addi	sp,sp,48
    80002ca8:	8082                	ret
    virtio_disk_rw(b, 0);
    80002caa:	4581                	li	a1,0
    80002cac:	8526                	mv	a0,s1
    80002cae:	203020ef          	jal	800056b0 <virtio_disk_rw>
    b->valid = 1;
    80002cb2:	4785                	li	a5,1
    80002cb4:	c09c                	sw	a5,0(s1)
  return b;
    80002cb6:	b7d5                	j	80002c9a <bread+0xb8>

0000000080002cb8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cb8:	1101                	addi	sp,sp,-32
    80002cba:	ec06                	sd	ra,24(sp)
    80002cbc:	e822                	sd	s0,16(sp)
    80002cbe:	e426                	sd	s1,8(sp)
    80002cc0:	1000                	addi	s0,sp,32
    80002cc2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cc4:	0541                	addi	a0,a0,16
    80002cc6:	1ee010ef          	jal	80003eb4 <holdingsleep>
    80002cca:	c911                	beqz	a0,80002cde <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ccc:	4585                	li	a1,1
    80002cce:	8526                	mv	a0,s1
    80002cd0:	1e1020ef          	jal	800056b0 <virtio_disk_rw>
}
    80002cd4:	60e2                	ld	ra,24(sp)
    80002cd6:	6442                	ld	s0,16(sp)
    80002cd8:	64a2                	ld	s1,8(sp)
    80002cda:	6105                	addi	sp,sp,32
    80002cdc:	8082                	ret
    panic("bwrite");
    80002cde:	00004517          	auipc	a0,0x4
    80002ce2:	78250513          	addi	a0,a0,1922 # 80007460 <etext+0x460>
    80002ce6:	ab9fd0ef          	jal	8000079e <panic>

0000000080002cea <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cea:	1101                	addi	sp,sp,-32
    80002cec:	ec06                	sd	ra,24(sp)
    80002cee:	e822                	sd	s0,16(sp)
    80002cf0:	e426                	sd	s1,8(sp)
    80002cf2:	e04a                	sd	s2,0(sp)
    80002cf4:	1000                	addi	s0,sp,32
    80002cf6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cf8:	01050913          	addi	s2,a0,16
    80002cfc:	854a                	mv	a0,s2
    80002cfe:	1b6010ef          	jal	80003eb4 <holdingsleep>
    80002d02:	c125                	beqz	a0,80002d62 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002d04:	854a                	mv	a0,s2
    80002d06:	176010ef          	jal	80003e7c <releasesleep>

  acquire(&bcache.lock);
    80002d0a:	00016517          	auipc	a0,0x16
    80002d0e:	e8650513          	addi	a0,a0,-378 # 80018b90 <bcache>
    80002d12:	eedfd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002d16:	40bc                	lw	a5,64(s1)
    80002d18:	37fd                	addiw	a5,a5,-1
    80002d1a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d1c:	e79d                	bnez	a5,80002d4a <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d1e:	68b8                	ld	a4,80(s1)
    80002d20:	64bc                	ld	a5,72(s1)
    80002d22:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d24:	68b8                	ld	a4,80(s1)
    80002d26:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d28:	0001e797          	auipc	a5,0x1e
    80002d2c:	e6878793          	addi	a5,a5,-408 # 80020b90 <bcache+0x8000>
    80002d30:	2b87b703          	ld	a4,696(a5)
    80002d34:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d36:	0001e717          	auipc	a4,0x1e
    80002d3a:	0c270713          	addi	a4,a4,194 # 80020df8 <bcache+0x8268>
    80002d3e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d40:	2b87b703          	ld	a4,696(a5)
    80002d44:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d46:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d4a:	00016517          	auipc	a0,0x16
    80002d4e:	e4650513          	addi	a0,a0,-442 # 80018b90 <bcache>
    80002d52:	f41fd0ef          	jal	80000c92 <release>
}
    80002d56:	60e2                	ld	ra,24(sp)
    80002d58:	6442                	ld	s0,16(sp)
    80002d5a:	64a2                	ld	s1,8(sp)
    80002d5c:	6902                	ld	s2,0(sp)
    80002d5e:	6105                	addi	sp,sp,32
    80002d60:	8082                	ret
    panic("brelse");
    80002d62:	00004517          	auipc	a0,0x4
    80002d66:	70650513          	addi	a0,a0,1798 # 80007468 <etext+0x468>
    80002d6a:	a35fd0ef          	jal	8000079e <panic>

0000000080002d6e <bpin>:

void
bpin(struct buf *b) {
    80002d6e:	1101                	addi	sp,sp,-32
    80002d70:	ec06                	sd	ra,24(sp)
    80002d72:	e822                	sd	s0,16(sp)
    80002d74:	e426                	sd	s1,8(sp)
    80002d76:	1000                	addi	s0,sp,32
    80002d78:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d7a:	00016517          	auipc	a0,0x16
    80002d7e:	e1650513          	addi	a0,a0,-490 # 80018b90 <bcache>
    80002d82:	e7dfd0ef          	jal	80000bfe <acquire>
  b->refcnt++;
    80002d86:	40bc                	lw	a5,64(s1)
    80002d88:	2785                	addiw	a5,a5,1
    80002d8a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d8c:	00016517          	auipc	a0,0x16
    80002d90:	e0450513          	addi	a0,a0,-508 # 80018b90 <bcache>
    80002d94:	efffd0ef          	jal	80000c92 <release>
}
    80002d98:	60e2                	ld	ra,24(sp)
    80002d9a:	6442                	ld	s0,16(sp)
    80002d9c:	64a2                	ld	s1,8(sp)
    80002d9e:	6105                	addi	sp,sp,32
    80002da0:	8082                	ret

0000000080002da2 <bunpin>:

void
bunpin(struct buf *b) {
    80002da2:	1101                	addi	sp,sp,-32
    80002da4:	ec06                	sd	ra,24(sp)
    80002da6:	e822                	sd	s0,16(sp)
    80002da8:	e426                	sd	s1,8(sp)
    80002daa:	1000                	addi	s0,sp,32
    80002dac:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dae:	00016517          	auipc	a0,0x16
    80002db2:	de250513          	addi	a0,a0,-542 # 80018b90 <bcache>
    80002db6:	e49fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002dba:	40bc                	lw	a5,64(s1)
    80002dbc:	37fd                	addiw	a5,a5,-1
    80002dbe:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dc0:	00016517          	auipc	a0,0x16
    80002dc4:	dd050513          	addi	a0,a0,-560 # 80018b90 <bcache>
    80002dc8:	ecbfd0ef          	jal	80000c92 <release>
}
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	64a2                	ld	s1,8(sp)
    80002dd2:	6105                	addi	sp,sp,32
    80002dd4:	8082                	ret

0000000080002dd6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dd6:	1101                	addi	sp,sp,-32
    80002dd8:	ec06                	sd	ra,24(sp)
    80002dda:	e822                	sd	s0,16(sp)
    80002ddc:	e426                	sd	s1,8(sp)
    80002dde:	e04a                	sd	s2,0(sp)
    80002de0:	1000                	addi	s0,sp,32
    80002de2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002de4:	00d5d79b          	srliw	a5,a1,0xd
    80002de8:	0001e597          	auipc	a1,0x1e
    80002dec:	4845a583          	lw	a1,1156(a1) # 8002126c <sb+0x1c>
    80002df0:	9dbd                	addw	a1,a1,a5
    80002df2:	df1ff0ef          	jal	80002be2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002df6:	0074f713          	andi	a4,s1,7
    80002dfa:	4785                	li	a5,1
    80002dfc:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e00:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002e02:	90d9                	srli	s1,s1,0x36
    80002e04:	00950733          	add	a4,a0,s1
    80002e08:	05874703          	lbu	a4,88(a4)
    80002e0c:	00e7f6b3          	and	a3,a5,a4
    80002e10:	c29d                	beqz	a3,80002e36 <bfree+0x60>
    80002e12:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e14:	94aa                	add	s1,s1,a0
    80002e16:	fff7c793          	not	a5,a5
    80002e1a:	8f7d                	and	a4,a4,a5
    80002e1c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e20:	711000ef          	jal	80003d30 <log_write>
  brelse(bp);
    80002e24:	854a                	mv	a0,s2
    80002e26:	ec5ff0ef          	jal	80002cea <brelse>
}
    80002e2a:	60e2                	ld	ra,24(sp)
    80002e2c:	6442                	ld	s0,16(sp)
    80002e2e:	64a2                	ld	s1,8(sp)
    80002e30:	6902                	ld	s2,0(sp)
    80002e32:	6105                	addi	sp,sp,32
    80002e34:	8082                	ret
    panic("freeing free block");
    80002e36:	00004517          	auipc	a0,0x4
    80002e3a:	63a50513          	addi	a0,a0,1594 # 80007470 <etext+0x470>
    80002e3e:	961fd0ef          	jal	8000079e <panic>

0000000080002e42 <balloc>:
{
    80002e42:	715d                	addi	sp,sp,-80
    80002e44:	e486                	sd	ra,72(sp)
    80002e46:	e0a2                	sd	s0,64(sp)
    80002e48:	fc26                	sd	s1,56(sp)
    80002e4a:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002e4c:	0001e797          	auipc	a5,0x1e
    80002e50:	4087a783          	lw	a5,1032(a5) # 80021254 <sb+0x4>
    80002e54:	0e078863          	beqz	a5,80002f44 <balloc+0x102>
    80002e58:	f84a                	sd	s2,48(sp)
    80002e5a:	f44e                	sd	s3,40(sp)
    80002e5c:	f052                	sd	s4,32(sp)
    80002e5e:	ec56                	sd	s5,24(sp)
    80002e60:	e85a                	sd	s6,16(sp)
    80002e62:	e45e                	sd	s7,8(sp)
    80002e64:	e062                	sd	s8,0(sp)
    80002e66:	8baa                	mv	s7,a0
    80002e68:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e6a:	0001eb17          	auipc	s6,0x1e
    80002e6e:	3e6b0b13          	addi	s6,s6,998 # 80021250 <sb>
      m = 1 << (bi % 8);
    80002e72:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e74:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e76:	6c09                	lui	s8,0x2
    80002e78:	a09d                	j	80002ede <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e7a:	97ca                	add	a5,a5,s2
    80002e7c:	8e55                	or	a2,a2,a3
    80002e7e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e82:	854a                	mv	a0,s2
    80002e84:	6ad000ef          	jal	80003d30 <log_write>
        brelse(bp);
    80002e88:	854a                	mv	a0,s2
    80002e8a:	e61ff0ef          	jal	80002cea <brelse>
  bp = bread(dev, bno);
    80002e8e:	85a6                	mv	a1,s1
    80002e90:	855e                	mv	a0,s7
    80002e92:	d51ff0ef          	jal	80002be2 <bread>
    80002e96:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e98:	40000613          	li	a2,1024
    80002e9c:	4581                	li	a1,0
    80002e9e:	05850513          	addi	a0,a0,88
    80002ea2:	e2dfd0ef          	jal	80000cce <memset>
  log_write(bp);
    80002ea6:	854a                	mv	a0,s2
    80002ea8:	689000ef          	jal	80003d30 <log_write>
  brelse(bp);
    80002eac:	854a                	mv	a0,s2
    80002eae:	e3dff0ef          	jal	80002cea <brelse>
}
    80002eb2:	7942                	ld	s2,48(sp)
    80002eb4:	79a2                	ld	s3,40(sp)
    80002eb6:	7a02                	ld	s4,32(sp)
    80002eb8:	6ae2                	ld	s5,24(sp)
    80002eba:	6b42                	ld	s6,16(sp)
    80002ebc:	6ba2                	ld	s7,8(sp)
    80002ebe:	6c02                	ld	s8,0(sp)
}
    80002ec0:	8526                	mv	a0,s1
    80002ec2:	60a6                	ld	ra,72(sp)
    80002ec4:	6406                	ld	s0,64(sp)
    80002ec6:	74e2                	ld	s1,56(sp)
    80002ec8:	6161                	addi	sp,sp,80
    80002eca:	8082                	ret
    brelse(bp);
    80002ecc:	854a                	mv	a0,s2
    80002ece:	e1dff0ef          	jal	80002cea <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ed2:	015c0abb          	addw	s5,s8,s5
    80002ed6:	004b2783          	lw	a5,4(s6)
    80002eda:	04fafe63          	bgeu	s5,a5,80002f36 <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    80002ede:	41fad79b          	sraiw	a5,s5,0x1f
    80002ee2:	0137d79b          	srliw	a5,a5,0x13
    80002ee6:	015787bb          	addw	a5,a5,s5
    80002eea:	40d7d79b          	sraiw	a5,a5,0xd
    80002eee:	01cb2583          	lw	a1,28(s6)
    80002ef2:	9dbd                	addw	a1,a1,a5
    80002ef4:	855e                	mv	a0,s7
    80002ef6:	cedff0ef          	jal	80002be2 <bread>
    80002efa:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002efc:	004b2503          	lw	a0,4(s6)
    80002f00:	84d6                	mv	s1,s5
    80002f02:	4701                	li	a4,0
    80002f04:	fca4f4e3          	bgeu	s1,a0,80002ecc <balloc+0x8a>
      m = 1 << (bi % 8);
    80002f08:	00777693          	andi	a3,a4,7
    80002f0c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f10:	41f7579b          	sraiw	a5,a4,0x1f
    80002f14:	01d7d79b          	srliw	a5,a5,0x1d
    80002f18:	9fb9                	addw	a5,a5,a4
    80002f1a:	4037d79b          	sraiw	a5,a5,0x3
    80002f1e:	00f90633          	add	a2,s2,a5
    80002f22:	05864603          	lbu	a2,88(a2)
    80002f26:	00c6f5b3          	and	a1,a3,a2
    80002f2a:	d9a1                	beqz	a1,80002e7a <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f2c:	2705                	addiw	a4,a4,1
    80002f2e:	2485                	addiw	s1,s1,1
    80002f30:	fd471ae3          	bne	a4,s4,80002f04 <balloc+0xc2>
    80002f34:	bf61                	j	80002ecc <balloc+0x8a>
    80002f36:	7942                	ld	s2,48(sp)
    80002f38:	79a2                	ld	s3,40(sp)
    80002f3a:	7a02                	ld	s4,32(sp)
    80002f3c:	6ae2                	ld	s5,24(sp)
    80002f3e:	6b42                	ld	s6,16(sp)
    80002f40:	6ba2                	ld	s7,8(sp)
    80002f42:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002f44:	00004517          	auipc	a0,0x4
    80002f48:	54450513          	addi	a0,a0,1348 # 80007488 <etext+0x488>
    80002f4c:	d82fd0ef          	jal	800004ce <printf>
  return 0;
    80002f50:	4481                	li	s1,0
    80002f52:	b7bd                	j	80002ec0 <balloc+0x7e>

0000000080002f54 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f54:	7179                	addi	sp,sp,-48
    80002f56:	f406                	sd	ra,40(sp)
    80002f58:	f022                	sd	s0,32(sp)
    80002f5a:	ec26                	sd	s1,24(sp)
    80002f5c:	e84a                	sd	s2,16(sp)
    80002f5e:	e44e                	sd	s3,8(sp)
    80002f60:	1800                	addi	s0,sp,48
    80002f62:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f64:	47ad                	li	a5,11
    80002f66:	02b7e363          	bltu	a5,a1,80002f8c <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002f6a:	02059793          	slli	a5,a1,0x20
    80002f6e:	01e7d593          	srli	a1,a5,0x1e
    80002f72:	00b504b3          	add	s1,a0,a1
    80002f76:	0504a903          	lw	s2,80(s1)
    80002f7a:	06091363          	bnez	s2,80002fe0 <bmap+0x8c>
      addr = balloc(ip->dev);
    80002f7e:	4108                	lw	a0,0(a0)
    80002f80:	ec3ff0ef          	jal	80002e42 <balloc>
    80002f84:	892a                	mv	s2,a0
      if(addr == 0)
    80002f86:	cd29                	beqz	a0,80002fe0 <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80002f88:	c8a8                	sw	a0,80(s1)
    80002f8a:	a899                	j	80002fe0 <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f8c:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80002f90:	0ff00793          	li	a5,255
    80002f94:	0697e963          	bltu	a5,s1,80003006 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f98:	08052903          	lw	s2,128(a0)
    80002f9c:	00091b63          	bnez	s2,80002fb2 <bmap+0x5e>
      addr = balloc(ip->dev);
    80002fa0:	4108                	lw	a0,0(a0)
    80002fa2:	ea1ff0ef          	jal	80002e42 <balloc>
    80002fa6:	892a                	mv	s2,a0
      if(addr == 0)
    80002fa8:	cd05                	beqz	a0,80002fe0 <bmap+0x8c>
    80002faa:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fac:	08a9a023          	sw	a0,128(s3)
    80002fb0:	a011                	j	80002fb4 <bmap+0x60>
    80002fb2:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fb4:	85ca                	mv	a1,s2
    80002fb6:	0009a503          	lw	a0,0(s3)
    80002fba:	c29ff0ef          	jal	80002be2 <bread>
    80002fbe:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fc0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fc4:	02049713          	slli	a4,s1,0x20
    80002fc8:	01e75593          	srli	a1,a4,0x1e
    80002fcc:	00b784b3          	add	s1,a5,a1
    80002fd0:	0004a903          	lw	s2,0(s1)
    80002fd4:	00090e63          	beqz	s2,80002ff0 <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fd8:	8552                	mv	a0,s4
    80002fda:	d11ff0ef          	jal	80002cea <brelse>
    return addr;
    80002fde:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fe0:	854a                	mv	a0,s2
    80002fe2:	70a2                	ld	ra,40(sp)
    80002fe4:	7402                	ld	s0,32(sp)
    80002fe6:	64e2                	ld	s1,24(sp)
    80002fe8:	6942                	ld	s2,16(sp)
    80002fea:	69a2                	ld	s3,8(sp)
    80002fec:	6145                	addi	sp,sp,48
    80002fee:	8082                	ret
      addr = balloc(ip->dev);
    80002ff0:	0009a503          	lw	a0,0(s3)
    80002ff4:	e4fff0ef          	jal	80002e42 <balloc>
    80002ff8:	892a                	mv	s2,a0
      if(addr){
    80002ffa:	dd79                	beqz	a0,80002fd8 <bmap+0x84>
        a[bn] = addr;
    80002ffc:	c088                	sw	a0,0(s1)
        log_write(bp);
    80002ffe:	8552                	mv	a0,s4
    80003000:	531000ef          	jal	80003d30 <log_write>
    80003004:	bfd1                	j	80002fd8 <bmap+0x84>
    80003006:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003008:	00004517          	auipc	a0,0x4
    8000300c:	49850513          	addi	a0,a0,1176 # 800074a0 <etext+0x4a0>
    80003010:	f8efd0ef          	jal	8000079e <panic>

0000000080003014 <iget>:
{
    80003014:	7179                	addi	sp,sp,-48
    80003016:	f406                	sd	ra,40(sp)
    80003018:	f022                	sd	s0,32(sp)
    8000301a:	ec26                	sd	s1,24(sp)
    8000301c:	e84a                	sd	s2,16(sp)
    8000301e:	e44e                	sd	s3,8(sp)
    80003020:	e052                	sd	s4,0(sp)
    80003022:	1800                	addi	s0,sp,48
    80003024:	89aa                	mv	s3,a0
    80003026:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003028:	0001e517          	auipc	a0,0x1e
    8000302c:	24850513          	addi	a0,a0,584 # 80021270 <itable>
    80003030:	bcffd0ef          	jal	80000bfe <acquire>
  empty = 0;
    80003034:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003036:	0001e497          	auipc	s1,0x1e
    8000303a:	25248493          	addi	s1,s1,594 # 80021288 <itable+0x18>
    8000303e:	00020697          	auipc	a3,0x20
    80003042:	cda68693          	addi	a3,a3,-806 # 80022d18 <log>
    80003046:	a039                	j	80003054 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003048:	02090963          	beqz	s2,8000307a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000304c:	08848493          	addi	s1,s1,136
    80003050:	02d48863          	beq	s1,a3,80003080 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003054:	449c                	lw	a5,8(s1)
    80003056:	fef059e3          	blez	a5,80003048 <iget+0x34>
    8000305a:	4098                	lw	a4,0(s1)
    8000305c:	ff3716e3          	bne	a4,s3,80003048 <iget+0x34>
    80003060:	40d8                	lw	a4,4(s1)
    80003062:	ff4713e3          	bne	a4,s4,80003048 <iget+0x34>
      ip->ref++;
    80003066:	2785                	addiw	a5,a5,1
    80003068:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000306a:	0001e517          	auipc	a0,0x1e
    8000306e:	20650513          	addi	a0,a0,518 # 80021270 <itable>
    80003072:	c21fd0ef          	jal	80000c92 <release>
      return ip;
    80003076:	8926                	mv	s2,s1
    80003078:	a02d                	j	800030a2 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000307a:	fbe9                	bnez	a5,8000304c <iget+0x38>
      empty = ip;
    8000307c:	8926                	mv	s2,s1
    8000307e:	b7f9                	j	8000304c <iget+0x38>
  if(empty == 0)
    80003080:	02090a63          	beqz	s2,800030b4 <iget+0xa0>
  ip->dev = dev;
    80003084:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003088:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000308c:	4785                	li	a5,1
    8000308e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003092:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003096:	0001e517          	auipc	a0,0x1e
    8000309a:	1da50513          	addi	a0,a0,474 # 80021270 <itable>
    8000309e:	bf5fd0ef          	jal	80000c92 <release>
}
    800030a2:	854a                	mv	a0,s2
    800030a4:	70a2                	ld	ra,40(sp)
    800030a6:	7402                	ld	s0,32(sp)
    800030a8:	64e2                	ld	s1,24(sp)
    800030aa:	6942                	ld	s2,16(sp)
    800030ac:	69a2                	ld	s3,8(sp)
    800030ae:	6a02                	ld	s4,0(sp)
    800030b0:	6145                	addi	sp,sp,48
    800030b2:	8082                	ret
    panic("iget: no inodes");
    800030b4:	00004517          	auipc	a0,0x4
    800030b8:	40450513          	addi	a0,a0,1028 # 800074b8 <etext+0x4b8>
    800030bc:	ee2fd0ef          	jal	8000079e <panic>

00000000800030c0 <fsinit>:
fsinit(int dev) {
    800030c0:	7179                	addi	sp,sp,-48
    800030c2:	f406                	sd	ra,40(sp)
    800030c4:	f022                	sd	s0,32(sp)
    800030c6:	ec26                	sd	s1,24(sp)
    800030c8:	e84a                	sd	s2,16(sp)
    800030ca:	e44e                	sd	s3,8(sp)
    800030cc:	1800                	addi	s0,sp,48
    800030ce:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800030d0:	4585                	li	a1,1
    800030d2:	b11ff0ef          	jal	80002be2 <bread>
    800030d6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800030d8:	0001e997          	auipc	s3,0x1e
    800030dc:	17898993          	addi	s3,s3,376 # 80021250 <sb>
    800030e0:	02000613          	li	a2,32
    800030e4:	05850593          	addi	a1,a0,88
    800030e8:	854e                	mv	a0,s3
    800030ea:	c49fd0ef          	jal	80000d32 <memmove>
  brelse(bp);
    800030ee:	8526                	mv	a0,s1
    800030f0:	bfbff0ef          	jal	80002cea <brelse>
  if(sb.magic != FSMAGIC)
    800030f4:	0009a703          	lw	a4,0(s3)
    800030f8:	102037b7          	lui	a5,0x10203
    800030fc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003100:	02f71063          	bne	a4,a5,80003120 <fsinit+0x60>
  initlog(dev, &sb);
    80003104:	0001e597          	auipc	a1,0x1e
    80003108:	14c58593          	addi	a1,a1,332 # 80021250 <sb>
    8000310c:	854a                	mv	a0,s2
    8000310e:	215000ef          	jal	80003b22 <initlog>
}
    80003112:	70a2                	ld	ra,40(sp)
    80003114:	7402                	ld	s0,32(sp)
    80003116:	64e2                	ld	s1,24(sp)
    80003118:	6942                	ld	s2,16(sp)
    8000311a:	69a2                	ld	s3,8(sp)
    8000311c:	6145                	addi	sp,sp,48
    8000311e:	8082                	ret
    panic("invalid file system");
    80003120:	00004517          	auipc	a0,0x4
    80003124:	3a850513          	addi	a0,a0,936 # 800074c8 <etext+0x4c8>
    80003128:	e76fd0ef          	jal	8000079e <panic>

000000008000312c <iinit>:
{
    8000312c:	7179                	addi	sp,sp,-48
    8000312e:	f406                	sd	ra,40(sp)
    80003130:	f022                	sd	s0,32(sp)
    80003132:	ec26                	sd	s1,24(sp)
    80003134:	e84a                	sd	s2,16(sp)
    80003136:	e44e                	sd	s3,8(sp)
    80003138:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000313a:	00004597          	auipc	a1,0x4
    8000313e:	3a658593          	addi	a1,a1,934 # 800074e0 <etext+0x4e0>
    80003142:	0001e517          	auipc	a0,0x1e
    80003146:	12e50513          	addi	a0,a0,302 # 80021270 <itable>
    8000314a:	a31fd0ef          	jal	80000b7a <initlock>
  for(i = 0; i < NINODE; i++) {
    8000314e:	0001e497          	auipc	s1,0x1e
    80003152:	14a48493          	addi	s1,s1,330 # 80021298 <itable+0x28>
    80003156:	00020997          	auipc	s3,0x20
    8000315a:	bd298993          	addi	s3,s3,-1070 # 80022d28 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000315e:	00004917          	auipc	s2,0x4
    80003162:	38a90913          	addi	s2,s2,906 # 800074e8 <etext+0x4e8>
    80003166:	85ca                	mv	a1,s2
    80003168:	8526                	mv	a0,s1
    8000316a:	497000ef          	jal	80003e00 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000316e:	08848493          	addi	s1,s1,136
    80003172:	ff349ae3          	bne	s1,s3,80003166 <iinit+0x3a>
}
    80003176:	70a2                	ld	ra,40(sp)
    80003178:	7402                	ld	s0,32(sp)
    8000317a:	64e2                	ld	s1,24(sp)
    8000317c:	6942                	ld	s2,16(sp)
    8000317e:	69a2                	ld	s3,8(sp)
    80003180:	6145                	addi	sp,sp,48
    80003182:	8082                	ret

0000000080003184 <ialloc>:
{
    80003184:	7139                	addi	sp,sp,-64
    80003186:	fc06                	sd	ra,56(sp)
    80003188:	f822                	sd	s0,48(sp)
    8000318a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000318c:	0001e717          	auipc	a4,0x1e
    80003190:	0d072703          	lw	a4,208(a4) # 8002125c <sb+0xc>
    80003194:	4785                	li	a5,1
    80003196:	06e7f063          	bgeu	a5,a4,800031f6 <ialloc+0x72>
    8000319a:	f426                	sd	s1,40(sp)
    8000319c:	f04a                	sd	s2,32(sp)
    8000319e:	ec4e                	sd	s3,24(sp)
    800031a0:	e852                	sd	s4,16(sp)
    800031a2:	e456                	sd	s5,8(sp)
    800031a4:	e05a                	sd	s6,0(sp)
    800031a6:	8aaa                	mv	s5,a0
    800031a8:	8b2e                	mv	s6,a1
    800031aa:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800031ac:	0001ea17          	auipc	s4,0x1e
    800031b0:	0a4a0a13          	addi	s4,s4,164 # 80021250 <sb>
    800031b4:	00495593          	srli	a1,s2,0x4
    800031b8:	018a2783          	lw	a5,24(s4)
    800031bc:	9dbd                	addw	a1,a1,a5
    800031be:	8556                	mv	a0,s5
    800031c0:	a23ff0ef          	jal	80002be2 <bread>
    800031c4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031c6:	05850993          	addi	s3,a0,88
    800031ca:	00f97793          	andi	a5,s2,15
    800031ce:	079a                	slli	a5,a5,0x6
    800031d0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800031d2:	00099783          	lh	a5,0(s3)
    800031d6:	cb9d                	beqz	a5,8000320c <ialloc+0x88>
    brelse(bp);
    800031d8:	b13ff0ef          	jal	80002cea <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031dc:	0905                	addi	s2,s2,1
    800031de:	00ca2703          	lw	a4,12(s4)
    800031e2:	0009079b          	sext.w	a5,s2
    800031e6:	fce7e7e3          	bltu	a5,a4,800031b4 <ialloc+0x30>
    800031ea:	74a2                	ld	s1,40(sp)
    800031ec:	7902                	ld	s2,32(sp)
    800031ee:	69e2                	ld	s3,24(sp)
    800031f0:	6a42                	ld	s4,16(sp)
    800031f2:	6aa2                	ld	s5,8(sp)
    800031f4:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800031f6:	00004517          	auipc	a0,0x4
    800031fa:	2fa50513          	addi	a0,a0,762 # 800074f0 <etext+0x4f0>
    800031fe:	ad0fd0ef          	jal	800004ce <printf>
  return 0;
    80003202:	4501                	li	a0,0
}
    80003204:	70e2                	ld	ra,56(sp)
    80003206:	7442                	ld	s0,48(sp)
    80003208:	6121                	addi	sp,sp,64
    8000320a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000320c:	04000613          	li	a2,64
    80003210:	4581                	li	a1,0
    80003212:	854e                	mv	a0,s3
    80003214:	abbfd0ef          	jal	80000cce <memset>
      dip->type = type;
    80003218:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000321c:	8526                	mv	a0,s1
    8000321e:	313000ef          	jal	80003d30 <log_write>
      brelse(bp);
    80003222:	8526                	mv	a0,s1
    80003224:	ac7ff0ef          	jal	80002cea <brelse>
      return iget(dev, inum);
    80003228:	0009059b          	sext.w	a1,s2
    8000322c:	8556                	mv	a0,s5
    8000322e:	de7ff0ef          	jal	80003014 <iget>
    80003232:	74a2                	ld	s1,40(sp)
    80003234:	7902                	ld	s2,32(sp)
    80003236:	69e2                	ld	s3,24(sp)
    80003238:	6a42                	ld	s4,16(sp)
    8000323a:	6aa2                	ld	s5,8(sp)
    8000323c:	6b02                	ld	s6,0(sp)
    8000323e:	b7d9                	j	80003204 <ialloc+0x80>

0000000080003240 <iupdate>:
{
    80003240:	1101                	addi	sp,sp,-32
    80003242:	ec06                	sd	ra,24(sp)
    80003244:	e822                	sd	s0,16(sp)
    80003246:	e426                	sd	s1,8(sp)
    80003248:	e04a                	sd	s2,0(sp)
    8000324a:	1000                	addi	s0,sp,32
    8000324c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000324e:	415c                	lw	a5,4(a0)
    80003250:	0047d79b          	srliw	a5,a5,0x4
    80003254:	0001e597          	auipc	a1,0x1e
    80003258:	0145a583          	lw	a1,20(a1) # 80021268 <sb+0x18>
    8000325c:	9dbd                	addw	a1,a1,a5
    8000325e:	4108                	lw	a0,0(a0)
    80003260:	983ff0ef          	jal	80002be2 <bread>
    80003264:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003266:	05850793          	addi	a5,a0,88
    8000326a:	40d8                	lw	a4,4(s1)
    8000326c:	8b3d                	andi	a4,a4,15
    8000326e:	071a                	slli	a4,a4,0x6
    80003270:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003272:	04449703          	lh	a4,68(s1)
    80003276:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000327a:	04649703          	lh	a4,70(s1)
    8000327e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003282:	04849703          	lh	a4,72(s1)
    80003286:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000328a:	04a49703          	lh	a4,74(s1)
    8000328e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003292:	44f8                	lw	a4,76(s1)
    80003294:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003296:	03400613          	li	a2,52
    8000329a:	05048593          	addi	a1,s1,80
    8000329e:	00c78513          	addi	a0,a5,12
    800032a2:	a91fd0ef          	jal	80000d32 <memmove>
  log_write(bp);
    800032a6:	854a                	mv	a0,s2
    800032a8:	289000ef          	jal	80003d30 <log_write>
  brelse(bp);
    800032ac:	854a                	mv	a0,s2
    800032ae:	a3dff0ef          	jal	80002cea <brelse>
}
    800032b2:	60e2                	ld	ra,24(sp)
    800032b4:	6442                	ld	s0,16(sp)
    800032b6:	64a2                	ld	s1,8(sp)
    800032b8:	6902                	ld	s2,0(sp)
    800032ba:	6105                	addi	sp,sp,32
    800032bc:	8082                	ret

00000000800032be <idup>:
{
    800032be:	1101                	addi	sp,sp,-32
    800032c0:	ec06                	sd	ra,24(sp)
    800032c2:	e822                	sd	s0,16(sp)
    800032c4:	e426                	sd	s1,8(sp)
    800032c6:	1000                	addi	s0,sp,32
    800032c8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032ca:	0001e517          	auipc	a0,0x1e
    800032ce:	fa650513          	addi	a0,a0,-90 # 80021270 <itable>
    800032d2:	92dfd0ef          	jal	80000bfe <acquire>
  ip->ref++;
    800032d6:	449c                	lw	a5,8(s1)
    800032d8:	2785                	addiw	a5,a5,1
    800032da:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032dc:	0001e517          	auipc	a0,0x1e
    800032e0:	f9450513          	addi	a0,a0,-108 # 80021270 <itable>
    800032e4:	9affd0ef          	jal	80000c92 <release>
}
    800032e8:	8526                	mv	a0,s1
    800032ea:	60e2                	ld	ra,24(sp)
    800032ec:	6442                	ld	s0,16(sp)
    800032ee:	64a2                	ld	s1,8(sp)
    800032f0:	6105                	addi	sp,sp,32
    800032f2:	8082                	ret

00000000800032f4 <ilock>:
{
    800032f4:	1101                	addi	sp,sp,-32
    800032f6:	ec06                	sd	ra,24(sp)
    800032f8:	e822                	sd	s0,16(sp)
    800032fa:	e426                	sd	s1,8(sp)
    800032fc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032fe:	cd19                	beqz	a0,8000331c <ilock+0x28>
    80003300:	84aa                	mv	s1,a0
    80003302:	451c                	lw	a5,8(a0)
    80003304:	00f05c63          	blez	a5,8000331c <ilock+0x28>
  acquiresleep(&ip->lock);
    80003308:	0541                	addi	a0,a0,16
    8000330a:	32d000ef          	jal	80003e36 <acquiresleep>
  if(ip->valid == 0){
    8000330e:	40bc                	lw	a5,64(s1)
    80003310:	cf89                	beqz	a5,8000332a <ilock+0x36>
}
    80003312:	60e2                	ld	ra,24(sp)
    80003314:	6442                	ld	s0,16(sp)
    80003316:	64a2                	ld	s1,8(sp)
    80003318:	6105                	addi	sp,sp,32
    8000331a:	8082                	ret
    8000331c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000331e:	00004517          	auipc	a0,0x4
    80003322:	1ea50513          	addi	a0,a0,490 # 80007508 <etext+0x508>
    80003326:	c78fd0ef          	jal	8000079e <panic>
    8000332a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000332c:	40dc                	lw	a5,4(s1)
    8000332e:	0047d79b          	srliw	a5,a5,0x4
    80003332:	0001e597          	auipc	a1,0x1e
    80003336:	f365a583          	lw	a1,-202(a1) # 80021268 <sb+0x18>
    8000333a:	9dbd                	addw	a1,a1,a5
    8000333c:	4088                	lw	a0,0(s1)
    8000333e:	8a5ff0ef          	jal	80002be2 <bread>
    80003342:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003344:	05850593          	addi	a1,a0,88
    80003348:	40dc                	lw	a5,4(s1)
    8000334a:	8bbd                	andi	a5,a5,15
    8000334c:	079a                	slli	a5,a5,0x6
    8000334e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003350:	00059783          	lh	a5,0(a1)
    80003354:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003358:	00259783          	lh	a5,2(a1)
    8000335c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003360:	00459783          	lh	a5,4(a1)
    80003364:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003368:	00659783          	lh	a5,6(a1)
    8000336c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003370:	459c                	lw	a5,8(a1)
    80003372:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003374:	03400613          	li	a2,52
    80003378:	05b1                	addi	a1,a1,12
    8000337a:	05048513          	addi	a0,s1,80
    8000337e:	9b5fd0ef          	jal	80000d32 <memmove>
    brelse(bp);
    80003382:	854a                	mv	a0,s2
    80003384:	967ff0ef          	jal	80002cea <brelse>
    ip->valid = 1;
    80003388:	4785                	li	a5,1
    8000338a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000338c:	04449783          	lh	a5,68(s1)
    80003390:	c399                	beqz	a5,80003396 <ilock+0xa2>
    80003392:	6902                	ld	s2,0(sp)
    80003394:	bfbd                	j	80003312 <ilock+0x1e>
      panic("ilock: no type");
    80003396:	00004517          	auipc	a0,0x4
    8000339a:	17a50513          	addi	a0,a0,378 # 80007510 <etext+0x510>
    8000339e:	c00fd0ef          	jal	8000079e <panic>

00000000800033a2 <iunlock>:
{
    800033a2:	1101                	addi	sp,sp,-32
    800033a4:	ec06                	sd	ra,24(sp)
    800033a6:	e822                	sd	s0,16(sp)
    800033a8:	e426                	sd	s1,8(sp)
    800033aa:	e04a                	sd	s2,0(sp)
    800033ac:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800033ae:	c505                	beqz	a0,800033d6 <iunlock+0x34>
    800033b0:	84aa                	mv	s1,a0
    800033b2:	01050913          	addi	s2,a0,16
    800033b6:	854a                	mv	a0,s2
    800033b8:	2fd000ef          	jal	80003eb4 <holdingsleep>
    800033bc:	cd09                	beqz	a0,800033d6 <iunlock+0x34>
    800033be:	449c                	lw	a5,8(s1)
    800033c0:	00f05b63          	blez	a5,800033d6 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033c4:	854a                	mv	a0,s2
    800033c6:	2b7000ef          	jal	80003e7c <releasesleep>
}
    800033ca:	60e2                	ld	ra,24(sp)
    800033cc:	6442                	ld	s0,16(sp)
    800033ce:	64a2                	ld	s1,8(sp)
    800033d0:	6902                	ld	s2,0(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret
    panic("iunlock");
    800033d6:	00004517          	auipc	a0,0x4
    800033da:	14a50513          	addi	a0,a0,330 # 80007520 <etext+0x520>
    800033de:	bc0fd0ef          	jal	8000079e <panic>

00000000800033e2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033e2:	7179                	addi	sp,sp,-48
    800033e4:	f406                	sd	ra,40(sp)
    800033e6:	f022                	sd	s0,32(sp)
    800033e8:	ec26                	sd	s1,24(sp)
    800033ea:	e84a                	sd	s2,16(sp)
    800033ec:	e44e                	sd	s3,8(sp)
    800033ee:	1800                	addi	s0,sp,48
    800033f0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033f2:	05050493          	addi	s1,a0,80
    800033f6:	08050913          	addi	s2,a0,128
    800033fa:	a021                	j	80003402 <itrunc+0x20>
    800033fc:	0491                	addi	s1,s1,4
    800033fe:	01248b63          	beq	s1,s2,80003414 <itrunc+0x32>
    if(ip->addrs[i]){
    80003402:	408c                	lw	a1,0(s1)
    80003404:	dde5                	beqz	a1,800033fc <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003406:	0009a503          	lw	a0,0(s3)
    8000340a:	9cdff0ef          	jal	80002dd6 <bfree>
      ip->addrs[i] = 0;
    8000340e:	0004a023          	sw	zero,0(s1)
    80003412:	b7ed                	j	800033fc <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003414:	0809a583          	lw	a1,128(s3)
    80003418:	ed89                	bnez	a1,80003432 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000341a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000341e:	854e                	mv	a0,s3
    80003420:	e21ff0ef          	jal	80003240 <iupdate>
}
    80003424:	70a2                	ld	ra,40(sp)
    80003426:	7402                	ld	s0,32(sp)
    80003428:	64e2                	ld	s1,24(sp)
    8000342a:	6942                	ld	s2,16(sp)
    8000342c:	69a2                	ld	s3,8(sp)
    8000342e:	6145                	addi	sp,sp,48
    80003430:	8082                	ret
    80003432:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003434:	0009a503          	lw	a0,0(s3)
    80003438:	faaff0ef          	jal	80002be2 <bread>
    8000343c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000343e:	05850493          	addi	s1,a0,88
    80003442:	45850913          	addi	s2,a0,1112
    80003446:	a021                	j	8000344e <itrunc+0x6c>
    80003448:	0491                	addi	s1,s1,4
    8000344a:	01248963          	beq	s1,s2,8000345c <itrunc+0x7a>
      if(a[j])
    8000344e:	408c                	lw	a1,0(s1)
    80003450:	dde5                	beqz	a1,80003448 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003452:	0009a503          	lw	a0,0(s3)
    80003456:	981ff0ef          	jal	80002dd6 <bfree>
    8000345a:	b7fd                	j	80003448 <itrunc+0x66>
    brelse(bp);
    8000345c:	8552                	mv	a0,s4
    8000345e:	88dff0ef          	jal	80002cea <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003462:	0809a583          	lw	a1,128(s3)
    80003466:	0009a503          	lw	a0,0(s3)
    8000346a:	96dff0ef          	jal	80002dd6 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000346e:	0809a023          	sw	zero,128(s3)
    80003472:	6a02                	ld	s4,0(sp)
    80003474:	b75d                	j	8000341a <itrunc+0x38>

0000000080003476 <iput>:
{
    80003476:	1101                	addi	sp,sp,-32
    80003478:	ec06                	sd	ra,24(sp)
    8000347a:	e822                	sd	s0,16(sp)
    8000347c:	e426                	sd	s1,8(sp)
    8000347e:	1000                	addi	s0,sp,32
    80003480:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003482:	0001e517          	auipc	a0,0x1e
    80003486:	dee50513          	addi	a0,a0,-530 # 80021270 <itable>
    8000348a:	f74fd0ef          	jal	80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000348e:	4498                	lw	a4,8(s1)
    80003490:	4785                	li	a5,1
    80003492:	02f70063          	beq	a4,a5,800034b2 <iput+0x3c>
  ip->ref--;
    80003496:	449c                	lw	a5,8(s1)
    80003498:	37fd                	addiw	a5,a5,-1
    8000349a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000349c:	0001e517          	auipc	a0,0x1e
    800034a0:	dd450513          	addi	a0,a0,-556 # 80021270 <itable>
    800034a4:	feefd0ef          	jal	80000c92 <release>
}
    800034a8:	60e2                	ld	ra,24(sp)
    800034aa:	6442                	ld	s0,16(sp)
    800034ac:	64a2                	ld	s1,8(sp)
    800034ae:	6105                	addi	sp,sp,32
    800034b0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034b2:	40bc                	lw	a5,64(s1)
    800034b4:	d3ed                	beqz	a5,80003496 <iput+0x20>
    800034b6:	04a49783          	lh	a5,74(s1)
    800034ba:	fff1                	bnez	a5,80003496 <iput+0x20>
    800034bc:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800034be:	01048913          	addi	s2,s1,16
    800034c2:	854a                	mv	a0,s2
    800034c4:	173000ef          	jal	80003e36 <acquiresleep>
    release(&itable.lock);
    800034c8:	0001e517          	auipc	a0,0x1e
    800034cc:	da850513          	addi	a0,a0,-600 # 80021270 <itable>
    800034d0:	fc2fd0ef          	jal	80000c92 <release>
    itrunc(ip);
    800034d4:	8526                	mv	a0,s1
    800034d6:	f0dff0ef          	jal	800033e2 <itrunc>
    ip->type = 0;
    800034da:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034de:	8526                	mv	a0,s1
    800034e0:	d61ff0ef          	jal	80003240 <iupdate>
    ip->valid = 0;
    800034e4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034e8:	854a                	mv	a0,s2
    800034ea:	193000ef          	jal	80003e7c <releasesleep>
    acquire(&itable.lock);
    800034ee:	0001e517          	auipc	a0,0x1e
    800034f2:	d8250513          	addi	a0,a0,-638 # 80021270 <itable>
    800034f6:	f08fd0ef          	jal	80000bfe <acquire>
    800034fa:	6902                	ld	s2,0(sp)
    800034fc:	bf69                	j	80003496 <iput+0x20>

00000000800034fe <iunlockput>:
{
    800034fe:	1101                	addi	sp,sp,-32
    80003500:	ec06                	sd	ra,24(sp)
    80003502:	e822                	sd	s0,16(sp)
    80003504:	e426                	sd	s1,8(sp)
    80003506:	1000                	addi	s0,sp,32
    80003508:	84aa                	mv	s1,a0
  iunlock(ip);
    8000350a:	e99ff0ef          	jal	800033a2 <iunlock>
  iput(ip);
    8000350e:	8526                	mv	a0,s1
    80003510:	f67ff0ef          	jal	80003476 <iput>
}
    80003514:	60e2                	ld	ra,24(sp)
    80003516:	6442                	ld	s0,16(sp)
    80003518:	64a2                	ld	s1,8(sp)
    8000351a:	6105                	addi	sp,sp,32
    8000351c:	8082                	ret

000000008000351e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000351e:	1141                	addi	sp,sp,-16
    80003520:	e406                	sd	ra,8(sp)
    80003522:	e022                	sd	s0,0(sp)
    80003524:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003526:	411c                	lw	a5,0(a0)
    80003528:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000352a:	415c                	lw	a5,4(a0)
    8000352c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000352e:	04451783          	lh	a5,68(a0)
    80003532:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003536:	04a51783          	lh	a5,74(a0)
    8000353a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000353e:	04c56783          	lwu	a5,76(a0)
    80003542:	e99c                	sd	a5,16(a1)
}
    80003544:	60a2                	ld	ra,8(sp)
    80003546:	6402                	ld	s0,0(sp)
    80003548:	0141                	addi	sp,sp,16
    8000354a:	8082                	ret

000000008000354c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000354c:	457c                	lw	a5,76(a0)
    8000354e:	0ed7e663          	bltu	a5,a3,8000363a <readi+0xee>
{
    80003552:	7159                	addi	sp,sp,-112
    80003554:	f486                	sd	ra,104(sp)
    80003556:	f0a2                	sd	s0,96(sp)
    80003558:	eca6                	sd	s1,88(sp)
    8000355a:	e0d2                	sd	s4,64(sp)
    8000355c:	fc56                	sd	s5,56(sp)
    8000355e:	f85a                	sd	s6,48(sp)
    80003560:	f45e                	sd	s7,40(sp)
    80003562:	1880                	addi	s0,sp,112
    80003564:	8b2a                	mv	s6,a0
    80003566:	8bae                	mv	s7,a1
    80003568:	8a32                	mv	s4,a2
    8000356a:	84b6                	mv	s1,a3
    8000356c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000356e:	9f35                	addw	a4,a4,a3
    return 0;
    80003570:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003572:	0ad76b63          	bltu	a4,a3,80003628 <readi+0xdc>
    80003576:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003578:	00e7f463          	bgeu	a5,a4,80003580 <readi+0x34>
    n = ip->size - off;
    8000357c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003580:	080a8b63          	beqz	s5,80003616 <readi+0xca>
    80003584:	e8ca                	sd	s2,80(sp)
    80003586:	f062                	sd	s8,32(sp)
    80003588:	ec66                	sd	s9,24(sp)
    8000358a:	e86a                	sd	s10,16(sp)
    8000358c:	e46e                	sd	s11,8(sp)
    8000358e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003590:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003594:	5c7d                	li	s8,-1
    80003596:	a80d                	j	800035c8 <readi+0x7c>
    80003598:	020d1d93          	slli	s11,s10,0x20
    8000359c:	020ddd93          	srli	s11,s11,0x20
    800035a0:	05890613          	addi	a2,s2,88
    800035a4:	86ee                	mv	a3,s11
    800035a6:	963e                	add	a2,a2,a5
    800035a8:	85d2                	mv	a1,s4
    800035aa:	855e                	mv	a0,s7
    800035ac:	c75fe0ef          	jal	80002220 <either_copyout>
    800035b0:	05850363          	beq	a0,s8,800035f6 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800035b4:	854a                	mv	a0,s2
    800035b6:	f34ff0ef          	jal	80002cea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035ba:	013d09bb          	addw	s3,s10,s3
    800035be:	009d04bb          	addw	s1,s10,s1
    800035c2:	9a6e                	add	s4,s4,s11
    800035c4:	0559f363          	bgeu	s3,s5,8000360a <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800035c8:	00a4d59b          	srliw	a1,s1,0xa
    800035cc:	855a                	mv	a0,s6
    800035ce:	987ff0ef          	jal	80002f54 <bmap>
    800035d2:	85aa                	mv	a1,a0
    if(addr == 0)
    800035d4:	c139                	beqz	a0,8000361a <readi+0xce>
    bp = bread(ip->dev, addr);
    800035d6:	000b2503          	lw	a0,0(s6)
    800035da:	e08ff0ef          	jal	80002be2 <bread>
    800035de:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035e0:	3ff4f793          	andi	a5,s1,1023
    800035e4:	40fc873b          	subw	a4,s9,a5
    800035e8:	413a86bb          	subw	a3,s5,s3
    800035ec:	8d3a                	mv	s10,a4
    800035ee:	fae6f5e3          	bgeu	a3,a4,80003598 <readi+0x4c>
    800035f2:	8d36                	mv	s10,a3
    800035f4:	b755                	j	80003598 <readi+0x4c>
      brelse(bp);
    800035f6:	854a                	mv	a0,s2
    800035f8:	ef2ff0ef          	jal	80002cea <brelse>
      tot = -1;
    800035fc:	59fd                	li	s3,-1
      break;
    800035fe:	6946                	ld	s2,80(sp)
    80003600:	7c02                	ld	s8,32(sp)
    80003602:	6ce2                	ld	s9,24(sp)
    80003604:	6d42                	ld	s10,16(sp)
    80003606:	6da2                	ld	s11,8(sp)
    80003608:	a831                	j	80003624 <readi+0xd8>
    8000360a:	6946                	ld	s2,80(sp)
    8000360c:	7c02                	ld	s8,32(sp)
    8000360e:	6ce2                	ld	s9,24(sp)
    80003610:	6d42                	ld	s10,16(sp)
    80003612:	6da2                	ld	s11,8(sp)
    80003614:	a801                	j	80003624 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003616:	89d6                	mv	s3,s5
    80003618:	a031                	j	80003624 <readi+0xd8>
    8000361a:	6946                	ld	s2,80(sp)
    8000361c:	7c02                	ld	s8,32(sp)
    8000361e:	6ce2                	ld	s9,24(sp)
    80003620:	6d42                	ld	s10,16(sp)
    80003622:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003624:	854e                	mv	a0,s3
    80003626:	69a6                	ld	s3,72(sp)
}
    80003628:	70a6                	ld	ra,104(sp)
    8000362a:	7406                	ld	s0,96(sp)
    8000362c:	64e6                	ld	s1,88(sp)
    8000362e:	6a06                	ld	s4,64(sp)
    80003630:	7ae2                	ld	s5,56(sp)
    80003632:	7b42                	ld	s6,48(sp)
    80003634:	7ba2                	ld	s7,40(sp)
    80003636:	6165                	addi	sp,sp,112
    80003638:	8082                	ret
    return 0;
    8000363a:	4501                	li	a0,0
}
    8000363c:	8082                	ret

000000008000363e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000363e:	457c                	lw	a5,76(a0)
    80003640:	0ed7eb63          	bltu	a5,a3,80003736 <writei+0xf8>
{
    80003644:	7159                	addi	sp,sp,-112
    80003646:	f486                	sd	ra,104(sp)
    80003648:	f0a2                	sd	s0,96(sp)
    8000364a:	e8ca                	sd	s2,80(sp)
    8000364c:	e0d2                	sd	s4,64(sp)
    8000364e:	fc56                	sd	s5,56(sp)
    80003650:	f85a                	sd	s6,48(sp)
    80003652:	f45e                	sd	s7,40(sp)
    80003654:	1880                	addi	s0,sp,112
    80003656:	8aaa                	mv	s5,a0
    80003658:	8bae                	mv	s7,a1
    8000365a:	8a32                	mv	s4,a2
    8000365c:	8936                	mv	s2,a3
    8000365e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003660:	00e687bb          	addw	a5,a3,a4
    80003664:	0cd7eb63          	bltu	a5,a3,8000373a <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003668:	00043737          	lui	a4,0x43
    8000366c:	0cf76963          	bltu	a4,a5,8000373e <writei+0x100>
    80003670:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003672:	0a0b0a63          	beqz	s6,80003726 <writei+0xe8>
    80003676:	eca6                	sd	s1,88(sp)
    80003678:	f062                	sd	s8,32(sp)
    8000367a:	ec66                	sd	s9,24(sp)
    8000367c:	e86a                	sd	s10,16(sp)
    8000367e:	e46e                	sd	s11,8(sp)
    80003680:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003682:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003686:	5c7d                	li	s8,-1
    80003688:	a825                	j	800036c0 <writei+0x82>
    8000368a:	020d1d93          	slli	s11,s10,0x20
    8000368e:	020ddd93          	srli	s11,s11,0x20
    80003692:	05848513          	addi	a0,s1,88
    80003696:	86ee                	mv	a3,s11
    80003698:	8652                	mv	a2,s4
    8000369a:	85de                	mv	a1,s7
    8000369c:	953e                	add	a0,a0,a5
    8000369e:	bcdfe0ef          	jal	8000226a <either_copyin>
    800036a2:	05850663          	beq	a0,s8,800036ee <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800036a6:	8526                	mv	a0,s1
    800036a8:	688000ef          	jal	80003d30 <log_write>
    brelse(bp);
    800036ac:	8526                	mv	a0,s1
    800036ae:	e3cff0ef          	jal	80002cea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036b2:	013d09bb          	addw	s3,s10,s3
    800036b6:	012d093b          	addw	s2,s10,s2
    800036ba:	9a6e                	add	s4,s4,s11
    800036bc:	0369fc63          	bgeu	s3,s6,800036f4 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800036c0:	00a9559b          	srliw	a1,s2,0xa
    800036c4:	8556                	mv	a0,s5
    800036c6:	88fff0ef          	jal	80002f54 <bmap>
    800036ca:	85aa                	mv	a1,a0
    if(addr == 0)
    800036cc:	c505                	beqz	a0,800036f4 <writei+0xb6>
    bp = bread(ip->dev, addr);
    800036ce:	000aa503          	lw	a0,0(s5)
    800036d2:	d10ff0ef          	jal	80002be2 <bread>
    800036d6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036d8:	3ff97793          	andi	a5,s2,1023
    800036dc:	40fc873b          	subw	a4,s9,a5
    800036e0:	413b06bb          	subw	a3,s6,s3
    800036e4:	8d3a                	mv	s10,a4
    800036e6:	fae6f2e3          	bgeu	a3,a4,8000368a <writei+0x4c>
    800036ea:	8d36                	mv	s10,a3
    800036ec:	bf79                	j	8000368a <writei+0x4c>
      brelse(bp);
    800036ee:	8526                	mv	a0,s1
    800036f0:	dfaff0ef          	jal	80002cea <brelse>
  }

  if(off > ip->size)
    800036f4:	04caa783          	lw	a5,76(s5)
    800036f8:	0327f963          	bgeu	a5,s2,8000372a <writei+0xec>
    ip->size = off;
    800036fc:	052aa623          	sw	s2,76(s5)
    80003700:	64e6                	ld	s1,88(sp)
    80003702:	7c02                	ld	s8,32(sp)
    80003704:	6ce2                	ld	s9,24(sp)
    80003706:	6d42                	ld	s10,16(sp)
    80003708:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000370a:	8556                	mv	a0,s5
    8000370c:	b35ff0ef          	jal	80003240 <iupdate>

  return tot;
    80003710:	854e                	mv	a0,s3
    80003712:	69a6                	ld	s3,72(sp)
}
    80003714:	70a6                	ld	ra,104(sp)
    80003716:	7406                	ld	s0,96(sp)
    80003718:	6946                	ld	s2,80(sp)
    8000371a:	6a06                	ld	s4,64(sp)
    8000371c:	7ae2                	ld	s5,56(sp)
    8000371e:	7b42                	ld	s6,48(sp)
    80003720:	7ba2                	ld	s7,40(sp)
    80003722:	6165                	addi	sp,sp,112
    80003724:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003726:	89da                	mv	s3,s6
    80003728:	b7cd                	j	8000370a <writei+0xcc>
    8000372a:	64e6                	ld	s1,88(sp)
    8000372c:	7c02                	ld	s8,32(sp)
    8000372e:	6ce2                	ld	s9,24(sp)
    80003730:	6d42                	ld	s10,16(sp)
    80003732:	6da2                	ld	s11,8(sp)
    80003734:	bfd9                	j	8000370a <writei+0xcc>
    return -1;
    80003736:	557d                	li	a0,-1
}
    80003738:	8082                	ret
    return -1;
    8000373a:	557d                	li	a0,-1
    8000373c:	bfe1                	j	80003714 <writei+0xd6>
    return -1;
    8000373e:	557d                	li	a0,-1
    80003740:	bfd1                	j	80003714 <writei+0xd6>

0000000080003742 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003742:	1141                	addi	sp,sp,-16
    80003744:	e406                	sd	ra,8(sp)
    80003746:	e022                	sd	s0,0(sp)
    80003748:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000374a:	4639                	li	a2,14
    8000374c:	e5afd0ef          	jal	80000da6 <strncmp>
}
    80003750:	60a2                	ld	ra,8(sp)
    80003752:	6402                	ld	s0,0(sp)
    80003754:	0141                	addi	sp,sp,16
    80003756:	8082                	ret

0000000080003758 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003758:	711d                	addi	sp,sp,-96
    8000375a:	ec86                	sd	ra,88(sp)
    8000375c:	e8a2                	sd	s0,80(sp)
    8000375e:	e4a6                	sd	s1,72(sp)
    80003760:	e0ca                	sd	s2,64(sp)
    80003762:	fc4e                	sd	s3,56(sp)
    80003764:	f852                	sd	s4,48(sp)
    80003766:	f456                	sd	s5,40(sp)
    80003768:	f05a                	sd	s6,32(sp)
    8000376a:	ec5e                	sd	s7,24(sp)
    8000376c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000376e:	04451703          	lh	a4,68(a0)
    80003772:	4785                	li	a5,1
    80003774:	00f71f63          	bne	a4,a5,80003792 <dirlookup+0x3a>
    80003778:	892a                	mv	s2,a0
    8000377a:	8aae                	mv	s5,a1
    8000377c:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000377e:	457c                	lw	a5,76(a0)
    80003780:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003782:	fa040a13          	addi	s4,s0,-96
    80003786:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003788:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000378c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000378e:	e39d                	bnez	a5,800037b4 <dirlookup+0x5c>
    80003790:	a8b9                	j	800037ee <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003792:	00004517          	auipc	a0,0x4
    80003796:	d9650513          	addi	a0,a0,-618 # 80007528 <etext+0x528>
    8000379a:	804fd0ef          	jal	8000079e <panic>
      panic("dirlookup read");
    8000379e:	00004517          	auipc	a0,0x4
    800037a2:	da250513          	addi	a0,a0,-606 # 80007540 <etext+0x540>
    800037a6:	ff9fc0ef          	jal	8000079e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037aa:	24c1                	addiw	s1,s1,16
    800037ac:	04c92783          	lw	a5,76(s2)
    800037b0:	02f4fe63          	bgeu	s1,a5,800037ec <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037b4:	874e                	mv	a4,s3
    800037b6:	86a6                	mv	a3,s1
    800037b8:	8652                	mv	a2,s4
    800037ba:	4581                	li	a1,0
    800037bc:	854a                	mv	a0,s2
    800037be:	d8fff0ef          	jal	8000354c <readi>
    800037c2:	fd351ee3          	bne	a0,s3,8000379e <dirlookup+0x46>
    if(de.inum == 0)
    800037c6:	fa045783          	lhu	a5,-96(s0)
    800037ca:	d3e5                	beqz	a5,800037aa <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800037cc:	85da                	mv	a1,s6
    800037ce:	8556                	mv	a0,s5
    800037d0:	f73ff0ef          	jal	80003742 <namecmp>
    800037d4:	f979                	bnez	a0,800037aa <dirlookup+0x52>
      if(poff)
    800037d6:	000b8463          	beqz	s7,800037de <dirlookup+0x86>
        *poff = off;
    800037da:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800037de:	fa045583          	lhu	a1,-96(s0)
    800037e2:	00092503          	lw	a0,0(s2)
    800037e6:	82fff0ef          	jal	80003014 <iget>
    800037ea:	a011                	j	800037ee <dirlookup+0x96>
  return 0;
    800037ec:	4501                	li	a0,0
}
    800037ee:	60e6                	ld	ra,88(sp)
    800037f0:	6446                	ld	s0,80(sp)
    800037f2:	64a6                	ld	s1,72(sp)
    800037f4:	6906                	ld	s2,64(sp)
    800037f6:	79e2                	ld	s3,56(sp)
    800037f8:	7a42                	ld	s4,48(sp)
    800037fa:	7aa2                	ld	s5,40(sp)
    800037fc:	7b02                	ld	s6,32(sp)
    800037fe:	6be2                	ld	s7,24(sp)
    80003800:	6125                	addi	sp,sp,96
    80003802:	8082                	ret

0000000080003804 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003804:	711d                	addi	sp,sp,-96
    80003806:	ec86                	sd	ra,88(sp)
    80003808:	e8a2                	sd	s0,80(sp)
    8000380a:	e4a6                	sd	s1,72(sp)
    8000380c:	e0ca                	sd	s2,64(sp)
    8000380e:	fc4e                	sd	s3,56(sp)
    80003810:	f852                	sd	s4,48(sp)
    80003812:	f456                	sd	s5,40(sp)
    80003814:	f05a                	sd	s6,32(sp)
    80003816:	ec5e                	sd	s7,24(sp)
    80003818:	e862                	sd	s8,16(sp)
    8000381a:	e466                	sd	s9,8(sp)
    8000381c:	e06a                	sd	s10,0(sp)
    8000381e:	1080                	addi	s0,sp,96
    80003820:	84aa                	mv	s1,a0
    80003822:	8b2e                	mv	s6,a1
    80003824:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003826:	00054703          	lbu	a4,0(a0)
    8000382a:	02f00793          	li	a5,47
    8000382e:	00f70f63          	beq	a4,a5,8000384c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003832:	8aafe0ef          	jal	800018dc <myproc>
    80003836:	15053503          	ld	a0,336(a0)
    8000383a:	a85ff0ef          	jal	800032be <idup>
    8000383e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003840:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003844:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003846:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003848:	4b85                	li	s7,1
    8000384a:	a879                	j	800038e8 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000384c:	4585                	li	a1,1
    8000384e:	852e                	mv	a0,a1
    80003850:	fc4ff0ef          	jal	80003014 <iget>
    80003854:	8a2a                	mv	s4,a0
    80003856:	b7ed                	j	80003840 <namex+0x3c>
      iunlockput(ip);
    80003858:	8552                	mv	a0,s4
    8000385a:	ca5ff0ef          	jal	800034fe <iunlockput>
      return 0;
    8000385e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003860:	8552                	mv	a0,s4
    80003862:	60e6                	ld	ra,88(sp)
    80003864:	6446                	ld	s0,80(sp)
    80003866:	64a6                	ld	s1,72(sp)
    80003868:	6906                	ld	s2,64(sp)
    8000386a:	79e2                	ld	s3,56(sp)
    8000386c:	7a42                	ld	s4,48(sp)
    8000386e:	7aa2                	ld	s5,40(sp)
    80003870:	7b02                	ld	s6,32(sp)
    80003872:	6be2                	ld	s7,24(sp)
    80003874:	6c42                	ld	s8,16(sp)
    80003876:	6ca2                	ld	s9,8(sp)
    80003878:	6d02                	ld	s10,0(sp)
    8000387a:	6125                	addi	sp,sp,96
    8000387c:	8082                	ret
      iunlock(ip);
    8000387e:	8552                	mv	a0,s4
    80003880:	b23ff0ef          	jal	800033a2 <iunlock>
      return ip;
    80003884:	bff1                	j	80003860 <namex+0x5c>
      iunlockput(ip);
    80003886:	8552                	mv	a0,s4
    80003888:	c77ff0ef          	jal	800034fe <iunlockput>
      return 0;
    8000388c:	8a4e                	mv	s4,s3
    8000388e:	bfc9                	j	80003860 <namex+0x5c>
  len = path - s;
    80003890:	40998633          	sub	a2,s3,s1
    80003894:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003898:	09ac5063          	bge	s8,s10,80003918 <namex+0x114>
    memmove(name, s, DIRSIZ);
    8000389c:	8666                	mv	a2,s9
    8000389e:	85a6                	mv	a1,s1
    800038a0:	8556                	mv	a0,s5
    800038a2:	c90fd0ef          	jal	80000d32 <memmove>
    800038a6:	84ce                	mv	s1,s3
  while(*path == '/')
    800038a8:	0004c783          	lbu	a5,0(s1)
    800038ac:	01279763          	bne	a5,s2,800038ba <namex+0xb6>
    path++;
    800038b0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038b2:	0004c783          	lbu	a5,0(s1)
    800038b6:	ff278de3          	beq	a5,s2,800038b0 <namex+0xac>
    ilock(ip);
    800038ba:	8552                	mv	a0,s4
    800038bc:	a39ff0ef          	jal	800032f4 <ilock>
    if(ip->type != T_DIR){
    800038c0:	044a1783          	lh	a5,68(s4)
    800038c4:	f9779ae3          	bne	a5,s7,80003858 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800038c8:	000b0563          	beqz	s6,800038d2 <namex+0xce>
    800038cc:	0004c783          	lbu	a5,0(s1)
    800038d0:	d7dd                	beqz	a5,8000387e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800038d2:	4601                	li	a2,0
    800038d4:	85d6                	mv	a1,s5
    800038d6:	8552                	mv	a0,s4
    800038d8:	e81ff0ef          	jal	80003758 <dirlookup>
    800038dc:	89aa                	mv	s3,a0
    800038de:	d545                	beqz	a0,80003886 <namex+0x82>
    iunlockput(ip);
    800038e0:	8552                	mv	a0,s4
    800038e2:	c1dff0ef          	jal	800034fe <iunlockput>
    ip = next;
    800038e6:	8a4e                	mv	s4,s3
  while(*path == '/')
    800038e8:	0004c783          	lbu	a5,0(s1)
    800038ec:	01279763          	bne	a5,s2,800038fa <namex+0xf6>
    path++;
    800038f0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038f2:	0004c783          	lbu	a5,0(s1)
    800038f6:	ff278de3          	beq	a5,s2,800038f0 <namex+0xec>
  if(*path == 0)
    800038fa:	cb8d                	beqz	a5,8000392c <namex+0x128>
  while(*path != '/' && *path != 0)
    800038fc:	0004c783          	lbu	a5,0(s1)
    80003900:	89a6                	mv	s3,s1
  len = path - s;
    80003902:	4d01                	li	s10,0
    80003904:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003906:	01278963          	beq	a5,s2,80003918 <namex+0x114>
    8000390a:	d3d9                	beqz	a5,80003890 <namex+0x8c>
    path++;
    8000390c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000390e:	0009c783          	lbu	a5,0(s3)
    80003912:	ff279ce3          	bne	a5,s2,8000390a <namex+0x106>
    80003916:	bfad                	j	80003890 <namex+0x8c>
    memmove(name, s, len);
    80003918:	2601                	sext.w	a2,a2
    8000391a:	85a6                	mv	a1,s1
    8000391c:	8556                	mv	a0,s5
    8000391e:	c14fd0ef          	jal	80000d32 <memmove>
    name[len] = 0;
    80003922:	9d56                	add	s10,s10,s5
    80003924:	000d0023          	sb	zero,0(s10)
    80003928:	84ce                	mv	s1,s3
    8000392a:	bfbd                	j	800038a8 <namex+0xa4>
  if(nameiparent){
    8000392c:	f20b0ae3          	beqz	s6,80003860 <namex+0x5c>
    iput(ip);
    80003930:	8552                	mv	a0,s4
    80003932:	b45ff0ef          	jal	80003476 <iput>
    return 0;
    80003936:	4a01                	li	s4,0
    80003938:	b725                	j	80003860 <namex+0x5c>

000000008000393a <dirlink>:
{
    8000393a:	715d                	addi	sp,sp,-80
    8000393c:	e486                	sd	ra,72(sp)
    8000393e:	e0a2                	sd	s0,64(sp)
    80003940:	f84a                	sd	s2,48(sp)
    80003942:	ec56                	sd	s5,24(sp)
    80003944:	e85a                	sd	s6,16(sp)
    80003946:	0880                	addi	s0,sp,80
    80003948:	892a                	mv	s2,a0
    8000394a:	8aae                	mv	s5,a1
    8000394c:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000394e:	4601                	li	a2,0
    80003950:	e09ff0ef          	jal	80003758 <dirlookup>
    80003954:	ed1d                	bnez	a0,80003992 <dirlink+0x58>
    80003956:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003958:	04c92483          	lw	s1,76(s2)
    8000395c:	c4b9                	beqz	s1,800039aa <dirlink+0x70>
    8000395e:	f44e                	sd	s3,40(sp)
    80003960:	f052                	sd	s4,32(sp)
    80003962:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003964:	fb040a13          	addi	s4,s0,-80
    80003968:	49c1                	li	s3,16
    8000396a:	874e                	mv	a4,s3
    8000396c:	86a6                	mv	a3,s1
    8000396e:	8652                	mv	a2,s4
    80003970:	4581                	li	a1,0
    80003972:	854a                	mv	a0,s2
    80003974:	bd9ff0ef          	jal	8000354c <readi>
    80003978:	03351163          	bne	a0,s3,8000399a <dirlink+0x60>
    if(de.inum == 0)
    8000397c:	fb045783          	lhu	a5,-80(s0)
    80003980:	c39d                	beqz	a5,800039a6 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003982:	24c1                	addiw	s1,s1,16
    80003984:	04c92783          	lw	a5,76(s2)
    80003988:	fef4e1e3          	bltu	s1,a5,8000396a <dirlink+0x30>
    8000398c:	79a2                	ld	s3,40(sp)
    8000398e:	7a02                	ld	s4,32(sp)
    80003990:	a829                	j	800039aa <dirlink+0x70>
    iput(ip);
    80003992:	ae5ff0ef          	jal	80003476 <iput>
    return -1;
    80003996:	557d                	li	a0,-1
    80003998:	a83d                	j	800039d6 <dirlink+0x9c>
      panic("dirlink read");
    8000399a:	00004517          	auipc	a0,0x4
    8000399e:	bb650513          	addi	a0,a0,-1098 # 80007550 <etext+0x550>
    800039a2:	dfdfc0ef          	jal	8000079e <panic>
    800039a6:	79a2                	ld	s3,40(sp)
    800039a8:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    800039aa:	4639                	li	a2,14
    800039ac:	85d6                	mv	a1,s5
    800039ae:	fb240513          	addi	a0,s0,-78
    800039b2:	c2efd0ef          	jal	80000de0 <strncpy>
  de.inum = inum;
    800039b6:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039ba:	4741                	li	a4,16
    800039bc:	86a6                	mv	a3,s1
    800039be:	fb040613          	addi	a2,s0,-80
    800039c2:	4581                	li	a1,0
    800039c4:	854a                	mv	a0,s2
    800039c6:	c79ff0ef          	jal	8000363e <writei>
    800039ca:	1541                	addi	a0,a0,-16
    800039cc:	00a03533          	snez	a0,a0
    800039d0:	40a0053b          	negw	a0,a0
    800039d4:	74e2                	ld	s1,56(sp)
}
    800039d6:	60a6                	ld	ra,72(sp)
    800039d8:	6406                	ld	s0,64(sp)
    800039da:	7942                	ld	s2,48(sp)
    800039dc:	6ae2                	ld	s5,24(sp)
    800039de:	6b42                	ld	s6,16(sp)
    800039e0:	6161                	addi	sp,sp,80
    800039e2:	8082                	ret

00000000800039e4 <namei>:

struct inode*
namei(char *path)
{
    800039e4:	1101                	addi	sp,sp,-32
    800039e6:	ec06                	sd	ra,24(sp)
    800039e8:	e822                	sd	s0,16(sp)
    800039ea:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800039ec:	fe040613          	addi	a2,s0,-32
    800039f0:	4581                	li	a1,0
    800039f2:	e13ff0ef          	jal	80003804 <namex>
}
    800039f6:	60e2                	ld	ra,24(sp)
    800039f8:	6442                	ld	s0,16(sp)
    800039fa:	6105                	addi	sp,sp,32
    800039fc:	8082                	ret

00000000800039fe <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800039fe:	1141                	addi	sp,sp,-16
    80003a00:	e406                	sd	ra,8(sp)
    80003a02:	e022                	sd	s0,0(sp)
    80003a04:	0800                	addi	s0,sp,16
    80003a06:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a08:	4585                	li	a1,1
    80003a0a:	dfbff0ef          	jal	80003804 <namex>
}
    80003a0e:	60a2                	ld	ra,8(sp)
    80003a10:	6402                	ld	s0,0(sp)
    80003a12:	0141                	addi	sp,sp,16
    80003a14:	8082                	ret

0000000080003a16 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a16:	1101                	addi	sp,sp,-32
    80003a18:	ec06                	sd	ra,24(sp)
    80003a1a:	e822                	sd	s0,16(sp)
    80003a1c:	e426                	sd	s1,8(sp)
    80003a1e:	e04a                	sd	s2,0(sp)
    80003a20:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a22:	0001f917          	auipc	s2,0x1f
    80003a26:	2f690913          	addi	s2,s2,758 # 80022d18 <log>
    80003a2a:	01892583          	lw	a1,24(s2)
    80003a2e:	02892503          	lw	a0,40(s2)
    80003a32:	9b0ff0ef          	jal	80002be2 <bread>
    80003a36:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a38:	02c92603          	lw	a2,44(s2)
    80003a3c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a3e:	00c05f63          	blez	a2,80003a5c <write_head+0x46>
    80003a42:	0001f717          	auipc	a4,0x1f
    80003a46:	30670713          	addi	a4,a4,774 # 80022d48 <log+0x30>
    80003a4a:	87aa                	mv	a5,a0
    80003a4c:	060a                	slli	a2,a2,0x2
    80003a4e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a50:	4314                	lw	a3,0(a4)
    80003a52:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a54:	0711                	addi	a4,a4,4
    80003a56:	0791                	addi	a5,a5,4
    80003a58:	fec79ce3          	bne	a5,a2,80003a50 <write_head+0x3a>
  }
  bwrite(buf);
    80003a5c:	8526                	mv	a0,s1
    80003a5e:	a5aff0ef          	jal	80002cb8 <bwrite>
  brelse(buf);
    80003a62:	8526                	mv	a0,s1
    80003a64:	a86ff0ef          	jal	80002cea <brelse>
}
    80003a68:	60e2                	ld	ra,24(sp)
    80003a6a:	6442                	ld	s0,16(sp)
    80003a6c:	64a2                	ld	s1,8(sp)
    80003a6e:	6902                	ld	s2,0(sp)
    80003a70:	6105                	addi	sp,sp,32
    80003a72:	8082                	ret

0000000080003a74 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a74:	0001f797          	auipc	a5,0x1f
    80003a78:	2d07a783          	lw	a5,720(a5) # 80022d44 <log+0x2c>
    80003a7c:	0af05263          	blez	a5,80003b20 <install_trans+0xac>
{
    80003a80:	715d                	addi	sp,sp,-80
    80003a82:	e486                	sd	ra,72(sp)
    80003a84:	e0a2                	sd	s0,64(sp)
    80003a86:	fc26                	sd	s1,56(sp)
    80003a88:	f84a                	sd	s2,48(sp)
    80003a8a:	f44e                	sd	s3,40(sp)
    80003a8c:	f052                	sd	s4,32(sp)
    80003a8e:	ec56                	sd	s5,24(sp)
    80003a90:	e85a                	sd	s6,16(sp)
    80003a92:	e45e                	sd	s7,8(sp)
    80003a94:	0880                	addi	s0,sp,80
    80003a96:	8b2a                	mv	s6,a0
    80003a98:	0001fa97          	auipc	s5,0x1f
    80003a9c:	2b0a8a93          	addi	s5,s5,688 # 80022d48 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003aa0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003aa2:	0001f997          	auipc	s3,0x1f
    80003aa6:	27698993          	addi	s3,s3,630 # 80022d18 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003aaa:	40000b93          	li	s7,1024
    80003aae:	a829                	j	80003ac8 <install_trans+0x54>
    brelse(lbuf);
    80003ab0:	854a                	mv	a0,s2
    80003ab2:	a38ff0ef          	jal	80002cea <brelse>
    brelse(dbuf);
    80003ab6:	8526                	mv	a0,s1
    80003ab8:	a32ff0ef          	jal	80002cea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003abc:	2a05                	addiw	s4,s4,1
    80003abe:	0a91                	addi	s5,s5,4
    80003ac0:	02c9a783          	lw	a5,44(s3)
    80003ac4:	04fa5363          	bge	s4,a5,80003b0a <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ac8:	0189a583          	lw	a1,24(s3)
    80003acc:	014585bb          	addw	a1,a1,s4
    80003ad0:	2585                	addiw	a1,a1,1
    80003ad2:	0289a503          	lw	a0,40(s3)
    80003ad6:	90cff0ef          	jal	80002be2 <bread>
    80003ada:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003adc:	000aa583          	lw	a1,0(s5)
    80003ae0:	0289a503          	lw	a0,40(s3)
    80003ae4:	8feff0ef          	jal	80002be2 <bread>
    80003ae8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003aea:	865e                	mv	a2,s7
    80003aec:	05890593          	addi	a1,s2,88
    80003af0:	05850513          	addi	a0,a0,88
    80003af4:	a3efd0ef          	jal	80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003af8:	8526                	mv	a0,s1
    80003afa:	9beff0ef          	jal	80002cb8 <bwrite>
    if(recovering == 0)
    80003afe:	fa0b19e3          	bnez	s6,80003ab0 <install_trans+0x3c>
      bunpin(dbuf);
    80003b02:	8526                	mv	a0,s1
    80003b04:	a9eff0ef          	jal	80002da2 <bunpin>
    80003b08:	b765                	j	80003ab0 <install_trans+0x3c>
}
    80003b0a:	60a6                	ld	ra,72(sp)
    80003b0c:	6406                	ld	s0,64(sp)
    80003b0e:	74e2                	ld	s1,56(sp)
    80003b10:	7942                	ld	s2,48(sp)
    80003b12:	79a2                	ld	s3,40(sp)
    80003b14:	7a02                	ld	s4,32(sp)
    80003b16:	6ae2                	ld	s5,24(sp)
    80003b18:	6b42                	ld	s6,16(sp)
    80003b1a:	6ba2                	ld	s7,8(sp)
    80003b1c:	6161                	addi	sp,sp,80
    80003b1e:	8082                	ret
    80003b20:	8082                	ret

0000000080003b22 <initlog>:
{
    80003b22:	7179                	addi	sp,sp,-48
    80003b24:	f406                	sd	ra,40(sp)
    80003b26:	f022                	sd	s0,32(sp)
    80003b28:	ec26                	sd	s1,24(sp)
    80003b2a:	e84a                	sd	s2,16(sp)
    80003b2c:	e44e                	sd	s3,8(sp)
    80003b2e:	1800                	addi	s0,sp,48
    80003b30:	892a                	mv	s2,a0
    80003b32:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b34:	0001f497          	auipc	s1,0x1f
    80003b38:	1e448493          	addi	s1,s1,484 # 80022d18 <log>
    80003b3c:	00004597          	auipc	a1,0x4
    80003b40:	a2458593          	addi	a1,a1,-1500 # 80007560 <etext+0x560>
    80003b44:	8526                	mv	a0,s1
    80003b46:	834fd0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    80003b4a:	0149a583          	lw	a1,20(s3)
    80003b4e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003b50:	0109a783          	lw	a5,16(s3)
    80003b54:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003b56:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003b5a:	854a                	mv	a0,s2
    80003b5c:	886ff0ef          	jal	80002be2 <bread>
  log.lh.n = lh->n;
    80003b60:	4d30                	lw	a2,88(a0)
    80003b62:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003b64:	00c05f63          	blez	a2,80003b82 <initlog+0x60>
    80003b68:	87aa                	mv	a5,a0
    80003b6a:	0001f717          	auipc	a4,0x1f
    80003b6e:	1de70713          	addi	a4,a4,478 # 80022d48 <log+0x30>
    80003b72:	060a                	slli	a2,a2,0x2
    80003b74:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b76:	4ff4                	lw	a3,92(a5)
    80003b78:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b7a:	0791                	addi	a5,a5,4
    80003b7c:	0711                	addi	a4,a4,4
    80003b7e:	fec79ce3          	bne	a5,a2,80003b76 <initlog+0x54>
  brelse(buf);
    80003b82:	968ff0ef          	jal	80002cea <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b86:	4505                	li	a0,1
    80003b88:	eedff0ef          	jal	80003a74 <install_trans>
  log.lh.n = 0;
    80003b8c:	0001f797          	auipc	a5,0x1f
    80003b90:	1a07ac23          	sw	zero,440(a5) # 80022d44 <log+0x2c>
  write_head(); // clear the log
    80003b94:	e83ff0ef          	jal	80003a16 <write_head>
}
    80003b98:	70a2                	ld	ra,40(sp)
    80003b9a:	7402                	ld	s0,32(sp)
    80003b9c:	64e2                	ld	s1,24(sp)
    80003b9e:	6942                	ld	s2,16(sp)
    80003ba0:	69a2                	ld	s3,8(sp)
    80003ba2:	6145                	addi	sp,sp,48
    80003ba4:	8082                	ret

0000000080003ba6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ba6:	1101                	addi	sp,sp,-32
    80003ba8:	ec06                	sd	ra,24(sp)
    80003baa:	e822                	sd	s0,16(sp)
    80003bac:	e426                	sd	s1,8(sp)
    80003bae:	e04a                	sd	s2,0(sp)
    80003bb0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003bb2:	0001f517          	auipc	a0,0x1f
    80003bb6:	16650513          	addi	a0,a0,358 # 80022d18 <log>
    80003bba:	844fd0ef          	jal	80000bfe <acquire>
  while(1){
    if(log.committing){
    80003bbe:	0001f497          	auipc	s1,0x1f
    80003bc2:	15a48493          	addi	s1,s1,346 # 80022d18 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003bc6:	4979                	li	s2,30
    80003bc8:	a029                	j	80003bd2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003bca:	85a6                	mv	a1,s1
    80003bcc:	8526                	mv	a0,s1
    80003bce:	afcfe0ef          	jal	80001eca <sleep>
    if(log.committing){
    80003bd2:	50dc                	lw	a5,36(s1)
    80003bd4:	fbfd                	bnez	a5,80003bca <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003bd6:	5098                	lw	a4,32(s1)
    80003bd8:	2705                	addiw	a4,a4,1
    80003bda:	0027179b          	slliw	a5,a4,0x2
    80003bde:	9fb9                	addw	a5,a5,a4
    80003be0:	0017979b          	slliw	a5,a5,0x1
    80003be4:	54d4                	lw	a3,44(s1)
    80003be6:	9fb5                	addw	a5,a5,a3
    80003be8:	00f95763          	bge	s2,a5,80003bf6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003bec:	85a6                	mv	a1,s1
    80003bee:	8526                	mv	a0,s1
    80003bf0:	adafe0ef          	jal	80001eca <sleep>
    80003bf4:	bff9                	j	80003bd2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003bf6:	0001f517          	auipc	a0,0x1f
    80003bfa:	12250513          	addi	a0,a0,290 # 80022d18 <log>
    80003bfe:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003c00:	892fd0ef          	jal	80000c92 <release>
      break;
    }
  }
}
    80003c04:	60e2                	ld	ra,24(sp)
    80003c06:	6442                	ld	s0,16(sp)
    80003c08:	64a2                	ld	s1,8(sp)
    80003c0a:	6902                	ld	s2,0(sp)
    80003c0c:	6105                	addi	sp,sp,32
    80003c0e:	8082                	ret

0000000080003c10 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c10:	7139                	addi	sp,sp,-64
    80003c12:	fc06                	sd	ra,56(sp)
    80003c14:	f822                	sd	s0,48(sp)
    80003c16:	f426                	sd	s1,40(sp)
    80003c18:	f04a                	sd	s2,32(sp)
    80003c1a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c1c:	0001f497          	auipc	s1,0x1f
    80003c20:	0fc48493          	addi	s1,s1,252 # 80022d18 <log>
    80003c24:	8526                	mv	a0,s1
    80003c26:	fd9fc0ef          	jal	80000bfe <acquire>
  log.outstanding -= 1;
    80003c2a:	509c                	lw	a5,32(s1)
    80003c2c:	37fd                	addiw	a5,a5,-1
    80003c2e:	893e                	mv	s2,a5
    80003c30:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003c32:	50dc                	lw	a5,36(s1)
    80003c34:	ef9d                	bnez	a5,80003c72 <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c36:	04091863          	bnez	s2,80003c86 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003c3a:	0001f497          	auipc	s1,0x1f
    80003c3e:	0de48493          	addi	s1,s1,222 # 80022d18 <log>
    80003c42:	4785                	li	a5,1
    80003c44:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c46:	8526                	mv	a0,s1
    80003c48:	84afd0ef          	jal	80000c92 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c4c:	54dc                	lw	a5,44(s1)
    80003c4e:	04f04c63          	bgtz	a5,80003ca6 <end_op+0x96>
    acquire(&log.lock);
    80003c52:	0001f497          	auipc	s1,0x1f
    80003c56:	0c648493          	addi	s1,s1,198 # 80022d18 <log>
    80003c5a:	8526                	mv	a0,s1
    80003c5c:	fa3fc0ef          	jal	80000bfe <acquire>
    log.committing = 0;
    80003c60:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003c64:	8526                	mv	a0,s1
    80003c66:	ab0fe0ef          	jal	80001f16 <wakeup>
    release(&log.lock);
    80003c6a:	8526                	mv	a0,s1
    80003c6c:	826fd0ef          	jal	80000c92 <release>
}
    80003c70:	a02d                	j	80003c9a <end_op+0x8a>
    80003c72:	ec4e                	sd	s3,24(sp)
    80003c74:	e852                	sd	s4,16(sp)
    80003c76:	e456                	sd	s5,8(sp)
    80003c78:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003c7a:	00004517          	auipc	a0,0x4
    80003c7e:	8ee50513          	addi	a0,a0,-1810 # 80007568 <etext+0x568>
    80003c82:	b1dfc0ef          	jal	8000079e <panic>
    wakeup(&log);
    80003c86:	0001f497          	auipc	s1,0x1f
    80003c8a:	09248493          	addi	s1,s1,146 # 80022d18 <log>
    80003c8e:	8526                	mv	a0,s1
    80003c90:	a86fe0ef          	jal	80001f16 <wakeup>
  release(&log.lock);
    80003c94:	8526                	mv	a0,s1
    80003c96:	ffdfc0ef          	jal	80000c92 <release>
}
    80003c9a:	70e2                	ld	ra,56(sp)
    80003c9c:	7442                	ld	s0,48(sp)
    80003c9e:	74a2                	ld	s1,40(sp)
    80003ca0:	7902                	ld	s2,32(sp)
    80003ca2:	6121                	addi	sp,sp,64
    80003ca4:	8082                	ret
    80003ca6:	ec4e                	sd	s3,24(sp)
    80003ca8:	e852                	sd	s4,16(sp)
    80003caa:	e456                	sd	s5,8(sp)
    80003cac:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cae:	0001fa97          	auipc	s5,0x1f
    80003cb2:	09aa8a93          	addi	s5,s5,154 # 80022d48 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003cb6:	0001fa17          	auipc	s4,0x1f
    80003cba:	062a0a13          	addi	s4,s4,98 # 80022d18 <log>
    memmove(to->data, from->data, BSIZE);
    80003cbe:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003cc2:	018a2583          	lw	a1,24(s4)
    80003cc6:	012585bb          	addw	a1,a1,s2
    80003cca:	2585                	addiw	a1,a1,1
    80003ccc:	028a2503          	lw	a0,40(s4)
    80003cd0:	f13fe0ef          	jal	80002be2 <bread>
    80003cd4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003cd6:	000aa583          	lw	a1,0(s5)
    80003cda:	028a2503          	lw	a0,40(s4)
    80003cde:	f05fe0ef          	jal	80002be2 <bread>
    80003ce2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ce4:	865a                	mv	a2,s6
    80003ce6:	05850593          	addi	a1,a0,88
    80003cea:	05848513          	addi	a0,s1,88
    80003cee:	844fd0ef          	jal	80000d32 <memmove>
    bwrite(to);  // write the log
    80003cf2:	8526                	mv	a0,s1
    80003cf4:	fc5fe0ef          	jal	80002cb8 <bwrite>
    brelse(from);
    80003cf8:	854e                	mv	a0,s3
    80003cfa:	ff1fe0ef          	jal	80002cea <brelse>
    brelse(to);
    80003cfe:	8526                	mv	a0,s1
    80003d00:	febfe0ef          	jal	80002cea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d04:	2905                	addiw	s2,s2,1
    80003d06:	0a91                	addi	s5,s5,4
    80003d08:	02ca2783          	lw	a5,44(s4)
    80003d0c:	faf94be3          	blt	s2,a5,80003cc2 <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003d10:	d07ff0ef          	jal	80003a16 <write_head>
    install_trans(0); // Now install writes to home locations
    80003d14:	4501                	li	a0,0
    80003d16:	d5fff0ef          	jal	80003a74 <install_trans>
    log.lh.n = 0;
    80003d1a:	0001f797          	auipc	a5,0x1f
    80003d1e:	0207a523          	sw	zero,42(a5) # 80022d44 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003d22:	cf5ff0ef          	jal	80003a16 <write_head>
    80003d26:	69e2                	ld	s3,24(sp)
    80003d28:	6a42                	ld	s4,16(sp)
    80003d2a:	6aa2                	ld	s5,8(sp)
    80003d2c:	6b02                	ld	s6,0(sp)
    80003d2e:	b715                	j	80003c52 <end_op+0x42>

0000000080003d30 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d30:	1101                	addi	sp,sp,-32
    80003d32:	ec06                	sd	ra,24(sp)
    80003d34:	e822                	sd	s0,16(sp)
    80003d36:	e426                	sd	s1,8(sp)
    80003d38:	e04a                	sd	s2,0(sp)
    80003d3a:	1000                	addi	s0,sp,32
    80003d3c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d3e:	0001f917          	auipc	s2,0x1f
    80003d42:	fda90913          	addi	s2,s2,-38 # 80022d18 <log>
    80003d46:	854a                	mv	a0,s2
    80003d48:	eb7fc0ef          	jal	80000bfe <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003d4c:	02c92603          	lw	a2,44(s2)
    80003d50:	47f5                	li	a5,29
    80003d52:	06c7c363          	blt	a5,a2,80003db8 <log_write+0x88>
    80003d56:	0001f797          	auipc	a5,0x1f
    80003d5a:	fde7a783          	lw	a5,-34(a5) # 80022d34 <log+0x1c>
    80003d5e:	37fd                	addiw	a5,a5,-1
    80003d60:	04f65c63          	bge	a2,a5,80003db8 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d64:	0001f797          	auipc	a5,0x1f
    80003d68:	fd47a783          	lw	a5,-44(a5) # 80022d38 <log+0x20>
    80003d6c:	04f05c63          	blez	a5,80003dc4 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d70:	4781                	li	a5,0
    80003d72:	04c05f63          	blez	a2,80003dd0 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d76:	44cc                	lw	a1,12(s1)
    80003d78:	0001f717          	auipc	a4,0x1f
    80003d7c:	fd070713          	addi	a4,a4,-48 # 80022d48 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d80:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d82:	4314                	lw	a3,0(a4)
    80003d84:	04b68663          	beq	a3,a1,80003dd0 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003d88:	2785                	addiw	a5,a5,1
    80003d8a:	0711                	addi	a4,a4,4
    80003d8c:	fef61be3          	bne	a2,a5,80003d82 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d90:	0621                	addi	a2,a2,8
    80003d92:	060a                	slli	a2,a2,0x2
    80003d94:	0001f797          	auipc	a5,0x1f
    80003d98:	f8478793          	addi	a5,a5,-124 # 80022d18 <log>
    80003d9c:	97b2                	add	a5,a5,a2
    80003d9e:	44d8                	lw	a4,12(s1)
    80003da0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003da2:	8526                	mv	a0,s1
    80003da4:	fcbfe0ef          	jal	80002d6e <bpin>
    log.lh.n++;
    80003da8:	0001f717          	auipc	a4,0x1f
    80003dac:	f7070713          	addi	a4,a4,-144 # 80022d18 <log>
    80003db0:	575c                	lw	a5,44(a4)
    80003db2:	2785                	addiw	a5,a5,1
    80003db4:	d75c                	sw	a5,44(a4)
    80003db6:	a80d                	j	80003de8 <log_write+0xb8>
    panic("too big a transaction");
    80003db8:	00003517          	auipc	a0,0x3
    80003dbc:	7c050513          	addi	a0,a0,1984 # 80007578 <etext+0x578>
    80003dc0:	9dffc0ef          	jal	8000079e <panic>
    panic("log_write outside of trans");
    80003dc4:	00003517          	auipc	a0,0x3
    80003dc8:	7cc50513          	addi	a0,a0,1996 # 80007590 <etext+0x590>
    80003dcc:	9d3fc0ef          	jal	8000079e <panic>
  log.lh.block[i] = b->blockno;
    80003dd0:	00878693          	addi	a3,a5,8
    80003dd4:	068a                	slli	a3,a3,0x2
    80003dd6:	0001f717          	auipc	a4,0x1f
    80003dda:	f4270713          	addi	a4,a4,-190 # 80022d18 <log>
    80003dde:	9736                	add	a4,a4,a3
    80003de0:	44d4                	lw	a3,12(s1)
    80003de2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003de4:	faf60fe3          	beq	a2,a5,80003da2 <log_write+0x72>
  }
  release(&log.lock);
    80003de8:	0001f517          	auipc	a0,0x1f
    80003dec:	f3050513          	addi	a0,a0,-208 # 80022d18 <log>
    80003df0:	ea3fc0ef          	jal	80000c92 <release>
}
    80003df4:	60e2                	ld	ra,24(sp)
    80003df6:	6442                	ld	s0,16(sp)
    80003df8:	64a2                	ld	s1,8(sp)
    80003dfa:	6902                	ld	s2,0(sp)
    80003dfc:	6105                	addi	sp,sp,32
    80003dfe:	8082                	ret

0000000080003e00 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e00:	1101                	addi	sp,sp,-32
    80003e02:	ec06                	sd	ra,24(sp)
    80003e04:	e822                	sd	s0,16(sp)
    80003e06:	e426                	sd	s1,8(sp)
    80003e08:	e04a                	sd	s2,0(sp)
    80003e0a:	1000                	addi	s0,sp,32
    80003e0c:	84aa                	mv	s1,a0
    80003e0e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e10:	00003597          	auipc	a1,0x3
    80003e14:	7a058593          	addi	a1,a1,1952 # 800075b0 <etext+0x5b0>
    80003e18:	0521                	addi	a0,a0,8
    80003e1a:	d61fc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80003e1e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e22:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e26:	0204a423          	sw	zero,40(s1)
}
    80003e2a:	60e2                	ld	ra,24(sp)
    80003e2c:	6442                	ld	s0,16(sp)
    80003e2e:	64a2                	ld	s1,8(sp)
    80003e30:	6902                	ld	s2,0(sp)
    80003e32:	6105                	addi	sp,sp,32
    80003e34:	8082                	ret

0000000080003e36 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e36:	1101                	addi	sp,sp,-32
    80003e38:	ec06                	sd	ra,24(sp)
    80003e3a:	e822                	sd	s0,16(sp)
    80003e3c:	e426                	sd	s1,8(sp)
    80003e3e:	e04a                	sd	s2,0(sp)
    80003e40:	1000                	addi	s0,sp,32
    80003e42:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e44:	00850913          	addi	s2,a0,8
    80003e48:	854a                	mv	a0,s2
    80003e4a:	db5fc0ef          	jal	80000bfe <acquire>
  while (lk->locked) {
    80003e4e:	409c                	lw	a5,0(s1)
    80003e50:	c799                	beqz	a5,80003e5e <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e52:	85ca                	mv	a1,s2
    80003e54:	8526                	mv	a0,s1
    80003e56:	874fe0ef          	jal	80001eca <sleep>
  while (lk->locked) {
    80003e5a:	409c                	lw	a5,0(s1)
    80003e5c:	fbfd                	bnez	a5,80003e52 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003e5e:	4785                	li	a5,1
    80003e60:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003e62:	a7bfd0ef          	jal	800018dc <myproc>
    80003e66:	591c                	lw	a5,48(a0)
    80003e68:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003e6a:	854a                	mv	a0,s2
    80003e6c:	e27fc0ef          	jal	80000c92 <release>
}
    80003e70:	60e2                	ld	ra,24(sp)
    80003e72:	6442                	ld	s0,16(sp)
    80003e74:	64a2                	ld	s1,8(sp)
    80003e76:	6902                	ld	s2,0(sp)
    80003e78:	6105                	addi	sp,sp,32
    80003e7a:	8082                	ret

0000000080003e7c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003e7c:	1101                	addi	sp,sp,-32
    80003e7e:	ec06                	sd	ra,24(sp)
    80003e80:	e822                	sd	s0,16(sp)
    80003e82:	e426                	sd	s1,8(sp)
    80003e84:	e04a                	sd	s2,0(sp)
    80003e86:	1000                	addi	s0,sp,32
    80003e88:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e8a:	00850913          	addi	s2,a0,8
    80003e8e:	854a                	mv	a0,s2
    80003e90:	d6ffc0ef          	jal	80000bfe <acquire>
  lk->locked = 0;
    80003e94:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e98:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003e9c:	8526                	mv	a0,s1
    80003e9e:	878fe0ef          	jal	80001f16 <wakeup>
  release(&lk->lk);
    80003ea2:	854a                	mv	a0,s2
    80003ea4:	deffc0ef          	jal	80000c92 <release>
}
    80003ea8:	60e2                	ld	ra,24(sp)
    80003eaa:	6442                	ld	s0,16(sp)
    80003eac:	64a2                	ld	s1,8(sp)
    80003eae:	6902                	ld	s2,0(sp)
    80003eb0:	6105                	addi	sp,sp,32
    80003eb2:	8082                	ret

0000000080003eb4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003eb4:	7179                	addi	sp,sp,-48
    80003eb6:	f406                	sd	ra,40(sp)
    80003eb8:	f022                	sd	s0,32(sp)
    80003eba:	ec26                	sd	s1,24(sp)
    80003ebc:	e84a                	sd	s2,16(sp)
    80003ebe:	1800                	addi	s0,sp,48
    80003ec0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003ec2:	00850913          	addi	s2,a0,8
    80003ec6:	854a                	mv	a0,s2
    80003ec8:	d37fc0ef          	jal	80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ecc:	409c                	lw	a5,0(s1)
    80003ece:	ef81                	bnez	a5,80003ee6 <holdingsleep+0x32>
    80003ed0:	4481                	li	s1,0
  release(&lk->lk);
    80003ed2:	854a                	mv	a0,s2
    80003ed4:	dbffc0ef          	jal	80000c92 <release>
  return r;
}
    80003ed8:	8526                	mv	a0,s1
    80003eda:	70a2                	ld	ra,40(sp)
    80003edc:	7402                	ld	s0,32(sp)
    80003ede:	64e2                	ld	s1,24(sp)
    80003ee0:	6942                	ld	s2,16(sp)
    80003ee2:	6145                	addi	sp,sp,48
    80003ee4:	8082                	ret
    80003ee6:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ee8:	0284a983          	lw	s3,40(s1)
    80003eec:	9f1fd0ef          	jal	800018dc <myproc>
    80003ef0:	5904                	lw	s1,48(a0)
    80003ef2:	413484b3          	sub	s1,s1,s3
    80003ef6:	0014b493          	seqz	s1,s1
    80003efa:	69a2                	ld	s3,8(sp)
    80003efc:	bfd9                	j	80003ed2 <holdingsleep+0x1e>

0000000080003efe <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003efe:	1141                	addi	sp,sp,-16
    80003f00:	e406                	sd	ra,8(sp)
    80003f02:	e022                	sd	s0,0(sp)
    80003f04:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f06:	00003597          	auipc	a1,0x3
    80003f0a:	6ba58593          	addi	a1,a1,1722 # 800075c0 <etext+0x5c0>
    80003f0e:	0001f517          	auipc	a0,0x1f
    80003f12:	f5250513          	addi	a0,a0,-174 # 80022e60 <ftable>
    80003f16:	c65fc0ef          	jal	80000b7a <initlock>
}
    80003f1a:	60a2                	ld	ra,8(sp)
    80003f1c:	6402                	ld	s0,0(sp)
    80003f1e:	0141                	addi	sp,sp,16
    80003f20:	8082                	ret

0000000080003f22 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003f22:	1101                	addi	sp,sp,-32
    80003f24:	ec06                	sd	ra,24(sp)
    80003f26:	e822                	sd	s0,16(sp)
    80003f28:	e426                	sd	s1,8(sp)
    80003f2a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f2c:	0001f517          	auipc	a0,0x1f
    80003f30:	f3450513          	addi	a0,a0,-204 # 80022e60 <ftable>
    80003f34:	ccbfc0ef          	jal	80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f38:	0001f497          	auipc	s1,0x1f
    80003f3c:	f4048493          	addi	s1,s1,-192 # 80022e78 <ftable+0x18>
    80003f40:	00020717          	auipc	a4,0x20
    80003f44:	ed870713          	addi	a4,a4,-296 # 80023e18 <disk>
    if(f->ref == 0){
    80003f48:	40dc                	lw	a5,4(s1)
    80003f4a:	cf89                	beqz	a5,80003f64 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f4c:	02848493          	addi	s1,s1,40
    80003f50:	fee49ce3          	bne	s1,a4,80003f48 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f54:	0001f517          	auipc	a0,0x1f
    80003f58:	f0c50513          	addi	a0,a0,-244 # 80022e60 <ftable>
    80003f5c:	d37fc0ef          	jal	80000c92 <release>
  return 0;
    80003f60:	4481                	li	s1,0
    80003f62:	a809                	j	80003f74 <filealloc+0x52>
      f->ref = 1;
    80003f64:	4785                	li	a5,1
    80003f66:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003f68:	0001f517          	auipc	a0,0x1f
    80003f6c:	ef850513          	addi	a0,a0,-264 # 80022e60 <ftable>
    80003f70:	d23fc0ef          	jal	80000c92 <release>
}
    80003f74:	8526                	mv	a0,s1
    80003f76:	60e2                	ld	ra,24(sp)
    80003f78:	6442                	ld	s0,16(sp)
    80003f7a:	64a2                	ld	s1,8(sp)
    80003f7c:	6105                	addi	sp,sp,32
    80003f7e:	8082                	ret

0000000080003f80 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003f80:	1101                	addi	sp,sp,-32
    80003f82:	ec06                	sd	ra,24(sp)
    80003f84:	e822                	sd	s0,16(sp)
    80003f86:	e426                	sd	s1,8(sp)
    80003f88:	1000                	addi	s0,sp,32
    80003f8a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003f8c:	0001f517          	auipc	a0,0x1f
    80003f90:	ed450513          	addi	a0,a0,-300 # 80022e60 <ftable>
    80003f94:	c6bfc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003f98:	40dc                	lw	a5,4(s1)
    80003f9a:	02f05063          	blez	a5,80003fba <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003f9e:	2785                	addiw	a5,a5,1
    80003fa0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003fa2:	0001f517          	auipc	a0,0x1f
    80003fa6:	ebe50513          	addi	a0,a0,-322 # 80022e60 <ftable>
    80003faa:	ce9fc0ef          	jal	80000c92 <release>
  return f;
}
    80003fae:	8526                	mv	a0,s1
    80003fb0:	60e2                	ld	ra,24(sp)
    80003fb2:	6442                	ld	s0,16(sp)
    80003fb4:	64a2                	ld	s1,8(sp)
    80003fb6:	6105                	addi	sp,sp,32
    80003fb8:	8082                	ret
    panic("filedup");
    80003fba:	00003517          	auipc	a0,0x3
    80003fbe:	60e50513          	addi	a0,a0,1550 # 800075c8 <etext+0x5c8>
    80003fc2:	fdcfc0ef          	jal	8000079e <panic>

0000000080003fc6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003fc6:	7139                	addi	sp,sp,-64
    80003fc8:	fc06                	sd	ra,56(sp)
    80003fca:	f822                	sd	s0,48(sp)
    80003fcc:	f426                	sd	s1,40(sp)
    80003fce:	0080                	addi	s0,sp,64
    80003fd0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003fd2:	0001f517          	auipc	a0,0x1f
    80003fd6:	e8e50513          	addi	a0,a0,-370 # 80022e60 <ftable>
    80003fda:	c25fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003fde:	40dc                	lw	a5,4(s1)
    80003fe0:	04f05863          	blez	a5,80004030 <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    80003fe4:	37fd                	addiw	a5,a5,-1
    80003fe6:	c0dc                	sw	a5,4(s1)
    80003fe8:	04f04e63          	bgtz	a5,80004044 <fileclose+0x7e>
    80003fec:	f04a                	sd	s2,32(sp)
    80003fee:	ec4e                	sd	s3,24(sp)
    80003ff0:	e852                	sd	s4,16(sp)
    80003ff2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003ff4:	0004a903          	lw	s2,0(s1)
    80003ff8:	0094ca83          	lbu	s5,9(s1)
    80003ffc:	0104ba03          	ld	s4,16(s1)
    80004000:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004004:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004008:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000400c:	0001f517          	auipc	a0,0x1f
    80004010:	e5450513          	addi	a0,a0,-428 # 80022e60 <ftable>
    80004014:	c7ffc0ef          	jal	80000c92 <release>

  if(ff.type == FD_PIPE){
    80004018:	4785                	li	a5,1
    8000401a:	04f90063          	beq	s2,a5,8000405a <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000401e:	3979                	addiw	s2,s2,-2
    80004020:	4785                	li	a5,1
    80004022:	0527f563          	bgeu	a5,s2,8000406c <fileclose+0xa6>
    80004026:	7902                	ld	s2,32(sp)
    80004028:	69e2                	ld	s3,24(sp)
    8000402a:	6a42                	ld	s4,16(sp)
    8000402c:	6aa2                	ld	s5,8(sp)
    8000402e:	a00d                	j	80004050 <fileclose+0x8a>
    80004030:	f04a                	sd	s2,32(sp)
    80004032:	ec4e                	sd	s3,24(sp)
    80004034:	e852                	sd	s4,16(sp)
    80004036:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004038:	00003517          	auipc	a0,0x3
    8000403c:	59850513          	addi	a0,a0,1432 # 800075d0 <etext+0x5d0>
    80004040:	f5efc0ef          	jal	8000079e <panic>
    release(&ftable.lock);
    80004044:	0001f517          	auipc	a0,0x1f
    80004048:	e1c50513          	addi	a0,a0,-484 # 80022e60 <ftable>
    8000404c:	c47fc0ef          	jal	80000c92 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004050:	70e2                	ld	ra,56(sp)
    80004052:	7442                	ld	s0,48(sp)
    80004054:	74a2                	ld	s1,40(sp)
    80004056:	6121                	addi	sp,sp,64
    80004058:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000405a:	85d6                	mv	a1,s5
    8000405c:	8552                	mv	a0,s4
    8000405e:	340000ef          	jal	8000439e <pipeclose>
    80004062:	7902                	ld	s2,32(sp)
    80004064:	69e2                	ld	s3,24(sp)
    80004066:	6a42                	ld	s4,16(sp)
    80004068:	6aa2                	ld	s5,8(sp)
    8000406a:	b7dd                	j	80004050 <fileclose+0x8a>
    begin_op();
    8000406c:	b3bff0ef          	jal	80003ba6 <begin_op>
    iput(ff.ip);
    80004070:	854e                	mv	a0,s3
    80004072:	c04ff0ef          	jal	80003476 <iput>
    end_op();
    80004076:	b9bff0ef          	jal	80003c10 <end_op>
    8000407a:	7902                	ld	s2,32(sp)
    8000407c:	69e2                	ld	s3,24(sp)
    8000407e:	6a42                	ld	s4,16(sp)
    80004080:	6aa2                	ld	s5,8(sp)
    80004082:	b7f9                	j	80004050 <fileclose+0x8a>

0000000080004084 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004084:	715d                	addi	sp,sp,-80
    80004086:	e486                	sd	ra,72(sp)
    80004088:	e0a2                	sd	s0,64(sp)
    8000408a:	fc26                	sd	s1,56(sp)
    8000408c:	f44e                	sd	s3,40(sp)
    8000408e:	0880                	addi	s0,sp,80
    80004090:	84aa                	mv	s1,a0
    80004092:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004094:	849fd0ef          	jal	800018dc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004098:	409c                	lw	a5,0(s1)
    8000409a:	37f9                	addiw	a5,a5,-2
    8000409c:	4705                	li	a4,1
    8000409e:	04f76263          	bltu	a4,a5,800040e2 <filestat+0x5e>
    800040a2:	f84a                	sd	s2,48(sp)
    800040a4:	f052                	sd	s4,32(sp)
    800040a6:	892a                	mv	s2,a0
    ilock(f->ip);
    800040a8:	6c88                	ld	a0,24(s1)
    800040aa:	a4aff0ef          	jal	800032f4 <ilock>
    stati(f->ip, &st);
    800040ae:	fb840a13          	addi	s4,s0,-72
    800040b2:	85d2                	mv	a1,s4
    800040b4:	6c88                	ld	a0,24(s1)
    800040b6:	c68ff0ef          	jal	8000351e <stati>
    iunlock(f->ip);
    800040ba:	6c88                	ld	a0,24(s1)
    800040bc:	ae6ff0ef          	jal	800033a2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800040c0:	46e1                	li	a3,24
    800040c2:	8652                	mv	a2,s4
    800040c4:	85ce                	mv	a1,s3
    800040c6:	05093503          	ld	a0,80(s2)
    800040ca:	cbafd0ef          	jal	80001584 <copyout>
    800040ce:	41f5551b          	sraiw	a0,a0,0x1f
    800040d2:	7942                	ld	s2,48(sp)
    800040d4:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800040d6:	60a6                	ld	ra,72(sp)
    800040d8:	6406                	ld	s0,64(sp)
    800040da:	74e2                	ld	s1,56(sp)
    800040dc:	79a2                	ld	s3,40(sp)
    800040de:	6161                	addi	sp,sp,80
    800040e0:	8082                	ret
  return -1;
    800040e2:	557d                	li	a0,-1
    800040e4:	bfcd                	j	800040d6 <filestat+0x52>

00000000800040e6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800040e6:	7179                	addi	sp,sp,-48
    800040e8:	f406                	sd	ra,40(sp)
    800040ea:	f022                	sd	s0,32(sp)
    800040ec:	e84a                	sd	s2,16(sp)
    800040ee:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800040f0:	00854783          	lbu	a5,8(a0)
    800040f4:	cfd1                	beqz	a5,80004190 <fileread+0xaa>
    800040f6:	ec26                	sd	s1,24(sp)
    800040f8:	e44e                	sd	s3,8(sp)
    800040fa:	84aa                	mv	s1,a0
    800040fc:	89ae                	mv	s3,a1
    800040fe:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004100:	411c                	lw	a5,0(a0)
    80004102:	4705                	li	a4,1
    80004104:	04e78363          	beq	a5,a4,8000414a <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004108:	470d                	li	a4,3
    8000410a:	04e78763          	beq	a5,a4,80004158 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000410e:	4709                	li	a4,2
    80004110:	06e79a63          	bne	a5,a4,80004184 <fileread+0x9e>
    ilock(f->ip);
    80004114:	6d08                	ld	a0,24(a0)
    80004116:	9deff0ef          	jal	800032f4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000411a:	874a                	mv	a4,s2
    8000411c:	5094                	lw	a3,32(s1)
    8000411e:	864e                	mv	a2,s3
    80004120:	4585                	li	a1,1
    80004122:	6c88                	ld	a0,24(s1)
    80004124:	c28ff0ef          	jal	8000354c <readi>
    80004128:	892a                	mv	s2,a0
    8000412a:	00a05563          	blez	a0,80004134 <fileread+0x4e>
      f->off += r;
    8000412e:	509c                	lw	a5,32(s1)
    80004130:	9fa9                	addw	a5,a5,a0
    80004132:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004134:	6c88                	ld	a0,24(s1)
    80004136:	a6cff0ef          	jal	800033a2 <iunlock>
    8000413a:	64e2                	ld	s1,24(sp)
    8000413c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000413e:	854a                	mv	a0,s2
    80004140:	70a2                	ld	ra,40(sp)
    80004142:	7402                	ld	s0,32(sp)
    80004144:	6942                	ld	s2,16(sp)
    80004146:	6145                	addi	sp,sp,48
    80004148:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000414a:	6908                	ld	a0,16(a0)
    8000414c:	3a2000ef          	jal	800044ee <piperead>
    80004150:	892a                	mv	s2,a0
    80004152:	64e2                	ld	s1,24(sp)
    80004154:	69a2                	ld	s3,8(sp)
    80004156:	b7e5                	j	8000413e <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004158:	02451783          	lh	a5,36(a0)
    8000415c:	03079693          	slli	a3,a5,0x30
    80004160:	92c1                	srli	a3,a3,0x30
    80004162:	4725                	li	a4,9
    80004164:	02d76863          	bltu	a4,a3,80004194 <fileread+0xae>
    80004168:	0792                	slli	a5,a5,0x4
    8000416a:	0001f717          	auipc	a4,0x1f
    8000416e:	c5670713          	addi	a4,a4,-938 # 80022dc0 <devsw>
    80004172:	97ba                	add	a5,a5,a4
    80004174:	639c                	ld	a5,0(a5)
    80004176:	c39d                	beqz	a5,8000419c <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004178:	4505                	li	a0,1
    8000417a:	9782                	jalr	a5
    8000417c:	892a                	mv	s2,a0
    8000417e:	64e2                	ld	s1,24(sp)
    80004180:	69a2                	ld	s3,8(sp)
    80004182:	bf75                	j	8000413e <fileread+0x58>
    panic("fileread");
    80004184:	00003517          	auipc	a0,0x3
    80004188:	45c50513          	addi	a0,a0,1116 # 800075e0 <etext+0x5e0>
    8000418c:	e12fc0ef          	jal	8000079e <panic>
    return -1;
    80004190:	597d                	li	s2,-1
    80004192:	b775                	j	8000413e <fileread+0x58>
      return -1;
    80004194:	597d                	li	s2,-1
    80004196:	64e2                	ld	s1,24(sp)
    80004198:	69a2                	ld	s3,8(sp)
    8000419a:	b755                	j	8000413e <fileread+0x58>
    8000419c:	597d                	li	s2,-1
    8000419e:	64e2                	ld	s1,24(sp)
    800041a0:	69a2                	ld	s3,8(sp)
    800041a2:	bf71                	j	8000413e <fileread+0x58>

00000000800041a4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800041a4:	00954783          	lbu	a5,9(a0)
    800041a8:	10078e63          	beqz	a5,800042c4 <filewrite+0x120>
{
    800041ac:	711d                	addi	sp,sp,-96
    800041ae:	ec86                	sd	ra,88(sp)
    800041b0:	e8a2                	sd	s0,80(sp)
    800041b2:	e0ca                	sd	s2,64(sp)
    800041b4:	f456                	sd	s5,40(sp)
    800041b6:	f05a                	sd	s6,32(sp)
    800041b8:	1080                	addi	s0,sp,96
    800041ba:	892a                	mv	s2,a0
    800041bc:	8b2e                	mv	s6,a1
    800041be:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800041c0:	411c                	lw	a5,0(a0)
    800041c2:	4705                	li	a4,1
    800041c4:	02e78963          	beq	a5,a4,800041f6 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041c8:	470d                	li	a4,3
    800041ca:	02e78a63          	beq	a5,a4,800041fe <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800041ce:	4709                	li	a4,2
    800041d0:	0ce79e63          	bne	a5,a4,800042ac <filewrite+0x108>
    800041d4:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800041d6:	0ac05963          	blez	a2,80004288 <filewrite+0xe4>
    800041da:	e4a6                	sd	s1,72(sp)
    800041dc:	fc4e                	sd	s3,56(sp)
    800041de:	ec5e                	sd	s7,24(sp)
    800041e0:	e862                	sd	s8,16(sp)
    800041e2:	e466                	sd	s9,8(sp)
    int i = 0;
    800041e4:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800041e6:	6b85                	lui	s7,0x1
    800041e8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800041ec:	6c85                	lui	s9,0x1
    800041ee:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800041f2:	4c05                	li	s8,1
    800041f4:	a8ad                	j	8000426e <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    800041f6:	6908                	ld	a0,16(a0)
    800041f8:	1fe000ef          	jal	800043f6 <pipewrite>
    800041fc:	a04d                	j	8000429e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800041fe:	02451783          	lh	a5,36(a0)
    80004202:	03079693          	slli	a3,a5,0x30
    80004206:	92c1                	srli	a3,a3,0x30
    80004208:	4725                	li	a4,9
    8000420a:	0ad76f63          	bltu	a4,a3,800042c8 <filewrite+0x124>
    8000420e:	0792                	slli	a5,a5,0x4
    80004210:	0001f717          	auipc	a4,0x1f
    80004214:	bb070713          	addi	a4,a4,-1104 # 80022dc0 <devsw>
    80004218:	97ba                	add	a5,a5,a4
    8000421a:	679c                	ld	a5,8(a5)
    8000421c:	cbc5                	beqz	a5,800042cc <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000421e:	4505                	li	a0,1
    80004220:	9782                	jalr	a5
    80004222:	a8b5                	j	8000429e <filewrite+0xfa>
      if(n1 > max)
    80004224:	2981                	sext.w	s3,s3
      begin_op();
    80004226:	981ff0ef          	jal	80003ba6 <begin_op>
      ilock(f->ip);
    8000422a:	01893503          	ld	a0,24(s2)
    8000422e:	8c6ff0ef          	jal	800032f4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004232:	874e                	mv	a4,s3
    80004234:	02092683          	lw	a3,32(s2)
    80004238:	016a0633          	add	a2,s4,s6
    8000423c:	85e2                	mv	a1,s8
    8000423e:	01893503          	ld	a0,24(s2)
    80004242:	bfcff0ef          	jal	8000363e <writei>
    80004246:	84aa                	mv	s1,a0
    80004248:	00a05763          	blez	a0,80004256 <filewrite+0xb2>
        f->off += r;
    8000424c:	02092783          	lw	a5,32(s2)
    80004250:	9fa9                	addw	a5,a5,a0
    80004252:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004256:	01893503          	ld	a0,24(s2)
    8000425a:	948ff0ef          	jal	800033a2 <iunlock>
      end_op();
    8000425e:	9b3ff0ef          	jal	80003c10 <end_op>

      if(r != n1){
    80004262:	02999563          	bne	s3,s1,8000428c <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    80004266:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000426a:	015a5963          	bge	s4,s5,8000427c <filewrite+0xd8>
      int n1 = n - i;
    8000426e:	414a87bb          	subw	a5,s5,s4
    80004272:	89be                	mv	s3,a5
      if(n1 > max)
    80004274:	fafbd8e3          	bge	s7,a5,80004224 <filewrite+0x80>
    80004278:	89e6                	mv	s3,s9
    8000427a:	b76d                	j	80004224 <filewrite+0x80>
    8000427c:	64a6                	ld	s1,72(sp)
    8000427e:	79e2                	ld	s3,56(sp)
    80004280:	6be2                	ld	s7,24(sp)
    80004282:	6c42                	ld	s8,16(sp)
    80004284:	6ca2                	ld	s9,8(sp)
    80004286:	a801                	j	80004296 <filewrite+0xf2>
    int i = 0;
    80004288:	4a01                	li	s4,0
    8000428a:	a031                	j	80004296 <filewrite+0xf2>
    8000428c:	64a6                	ld	s1,72(sp)
    8000428e:	79e2                	ld	s3,56(sp)
    80004290:	6be2                	ld	s7,24(sp)
    80004292:	6c42                	ld	s8,16(sp)
    80004294:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004296:	034a9d63          	bne	s5,s4,800042d0 <filewrite+0x12c>
    8000429a:	8556                	mv	a0,s5
    8000429c:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000429e:	60e6                	ld	ra,88(sp)
    800042a0:	6446                	ld	s0,80(sp)
    800042a2:	6906                	ld	s2,64(sp)
    800042a4:	7aa2                	ld	s5,40(sp)
    800042a6:	7b02                	ld	s6,32(sp)
    800042a8:	6125                	addi	sp,sp,96
    800042aa:	8082                	ret
    800042ac:	e4a6                	sd	s1,72(sp)
    800042ae:	fc4e                	sd	s3,56(sp)
    800042b0:	f852                	sd	s4,48(sp)
    800042b2:	ec5e                	sd	s7,24(sp)
    800042b4:	e862                	sd	s8,16(sp)
    800042b6:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800042b8:	00003517          	auipc	a0,0x3
    800042bc:	33850513          	addi	a0,a0,824 # 800075f0 <etext+0x5f0>
    800042c0:	cdefc0ef          	jal	8000079e <panic>
    return -1;
    800042c4:	557d                	li	a0,-1
}
    800042c6:	8082                	ret
      return -1;
    800042c8:	557d                	li	a0,-1
    800042ca:	bfd1                	j	8000429e <filewrite+0xfa>
    800042cc:	557d                	li	a0,-1
    800042ce:	bfc1                	j	8000429e <filewrite+0xfa>
    ret = (i == n ? n : -1);
    800042d0:	557d                	li	a0,-1
    800042d2:	7a42                	ld	s4,48(sp)
    800042d4:	b7e9                	j	8000429e <filewrite+0xfa>

00000000800042d6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800042d6:	7179                	addi	sp,sp,-48
    800042d8:	f406                	sd	ra,40(sp)
    800042da:	f022                	sd	s0,32(sp)
    800042dc:	ec26                	sd	s1,24(sp)
    800042de:	e052                	sd	s4,0(sp)
    800042e0:	1800                	addi	s0,sp,48
    800042e2:	84aa                	mv	s1,a0
    800042e4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800042e6:	0005b023          	sd	zero,0(a1)
    800042ea:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800042ee:	c35ff0ef          	jal	80003f22 <filealloc>
    800042f2:	e088                	sd	a0,0(s1)
    800042f4:	c549                	beqz	a0,8000437e <pipealloc+0xa8>
    800042f6:	c2dff0ef          	jal	80003f22 <filealloc>
    800042fa:	00aa3023          	sd	a0,0(s4)
    800042fe:	cd25                	beqz	a0,80004376 <pipealloc+0xa0>
    80004300:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004302:	829fc0ef          	jal	80000b2a <kalloc>
    80004306:	892a                	mv	s2,a0
    80004308:	c12d                	beqz	a0,8000436a <pipealloc+0x94>
    8000430a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000430c:	4985                	li	s3,1
    8000430e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004312:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004316:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000431a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000431e:	00003597          	auipc	a1,0x3
    80004322:	2e258593          	addi	a1,a1,738 # 80007600 <etext+0x600>
    80004326:	855fc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    8000432a:	609c                	ld	a5,0(s1)
    8000432c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004330:	609c                	ld	a5,0(s1)
    80004332:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004336:	609c                	ld	a5,0(s1)
    80004338:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000433c:	609c                	ld	a5,0(s1)
    8000433e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004342:	000a3783          	ld	a5,0(s4)
    80004346:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000434a:	000a3783          	ld	a5,0(s4)
    8000434e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004352:	000a3783          	ld	a5,0(s4)
    80004356:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000435a:	000a3783          	ld	a5,0(s4)
    8000435e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004362:	4501                	li	a0,0
    80004364:	6942                	ld	s2,16(sp)
    80004366:	69a2                	ld	s3,8(sp)
    80004368:	a01d                	j	8000438e <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000436a:	6088                	ld	a0,0(s1)
    8000436c:	c119                	beqz	a0,80004372 <pipealloc+0x9c>
    8000436e:	6942                	ld	s2,16(sp)
    80004370:	a029                	j	8000437a <pipealloc+0xa4>
    80004372:	6942                	ld	s2,16(sp)
    80004374:	a029                	j	8000437e <pipealloc+0xa8>
    80004376:	6088                	ld	a0,0(s1)
    80004378:	c10d                	beqz	a0,8000439a <pipealloc+0xc4>
    fileclose(*f0);
    8000437a:	c4dff0ef          	jal	80003fc6 <fileclose>
  if(*f1)
    8000437e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004382:	557d                	li	a0,-1
  if(*f1)
    80004384:	c789                	beqz	a5,8000438e <pipealloc+0xb8>
    fileclose(*f1);
    80004386:	853e                	mv	a0,a5
    80004388:	c3fff0ef          	jal	80003fc6 <fileclose>
  return -1;
    8000438c:	557d                	li	a0,-1
}
    8000438e:	70a2                	ld	ra,40(sp)
    80004390:	7402                	ld	s0,32(sp)
    80004392:	64e2                	ld	s1,24(sp)
    80004394:	6a02                	ld	s4,0(sp)
    80004396:	6145                	addi	sp,sp,48
    80004398:	8082                	ret
  return -1;
    8000439a:	557d                	li	a0,-1
    8000439c:	bfcd                	j	8000438e <pipealloc+0xb8>

000000008000439e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000439e:	1101                	addi	sp,sp,-32
    800043a0:	ec06                	sd	ra,24(sp)
    800043a2:	e822                	sd	s0,16(sp)
    800043a4:	e426                	sd	s1,8(sp)
    800043a6:	e04a                	sd	s2,0(sp)
    800043a8:	1000                	addi	s0,sp,32
    800043aa:	84aa                	mv	s1,a0
    800043ac:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800043ae:	851fc0ef          	jal	80000bfe <acquire>
  if(writable){
    800043b2:	02090763          	beqz	s2,800043e0 <pipeclose+0x42>
    pi->writeopen = 0;
    800043b6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800043ba:	21848513          	addi	a0,s1,536
    800043be:	b59fd0ef          	jal	80001f16 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800043c2:	2204b783          	ld	a5,544(s1)
    800043c6:	e785                	bnez	a5,800043ee <pipeclose+0x50>
    release(&pi->lock);
    800043c8:	8526                	mv	a0,s1
    800043ca:	8c9fc0ef          	jal	80000c92 <release>
    kfree((char*)pi);
    800043ce:	8526                	mv	a0,s1
    800043d0:	e78fc0ef          	jal	80000a48 <kfree>
  } else
    release(&pi->lock);
}
    800043d4:	60e2                	ld	ra,24(sp)
    800043d6:	6442                	ld	s0,16(sp)
    800043d8:	64a2                	ld	s1,8(sp)
    800043da:	6902                	ld	s2,0(sp)
    800043dc:	6105                	addi	sp,sp,32
    800043de:	8082                	ret
    pi->readopen = 0;
    800043e0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800043e4:	21c48513          	addi	a0,s1,540
    800043e8:	b2ffd0ef          	jal	80001f16 <wakeup>
    800043ec:	bfd9                	j	800043c2 <pipeclose+0x24>
    release(&pi->lock);
    800043ee:	8526                	mv	a0,s1
    800043f0:	8a3fc0ef          	jal	80000c92 <release>
}
    800043f4:	b7c5                	j	800043d4 <pipeclose+0x36>

00000000800043f6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800043f6:	7159                	addi	sp,sp,-112
    800043f8:	f486                	sd	ra,104(sp)
    800043fa:	f0a2                	sd	s0,96(sp)
    800043fc:	eca6                	sd	s1,88(sp)
    800043fe:	e8ca                	sd	s2,80(sp)
    80004400:	e4ce                	sd	s3,72(sp)
    80004402:	e0d2                	sd	s4,64(sp)
    80004404:	fc56                	sd	s5,56(sp)
    80004406:	1880                	addi	s0,sp,112
    80004408:	84aa                	mv	s1,a0
    8000440a:	8aae                	mv	s5,a1
    8000440c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000440e:	ccefd0ef          	jal	800018dc <myproc>
    80004412:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004414:	8526                	mv	a0,s1
    80004416:	fe8fc0ef          	jal	80000bfe <acquire>
  while(i < n){
    8000441a:	0d405263          	blez	s4,800044de <pipewrite+0xe8>
    8000441e:	f85a                	sd	s6,48(sp)
    80004420:	f45e                	sd	s7,40(sp)
    80004422:	f062                	sd	s8,32(sp)
    80004424:	ec66                	sd	s9,24(sp)
    80004426:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004428:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000442a:	f9f40c13          	addi	s8,s0,-97
    8000442e:	4b85                	li	s7,1
    80004430:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004432:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004436:	21c48c93          	addi	s9,s1,540
    8000443a:	a82d                	j	80004474 <pipewrite+0x7e>
      release(&pi->lock);
    8000443c:	8526                	mv	a0,s1
    8000443e:	855fc0ef          	jal	80000c92 <release>
      return -1;
    80004442:	597d                	li	s2,-1
    80004444:	7b42                	ld	s6,48(sp)
    80004446:	7ba2                	ld	s7,40(sp)
    80004448:	7c02                	ld	s8,32(sp)
    8000444a:	6ce2                	ld	s9,24(sp)
    8000444c:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000444e:	854a                	mv	a0,s2
    80004450:	70a6                	ld	ra,104(sp)
    80004452:	7406                	ld	s0,96(sp)
    80004454:	64e6                	ld	s1,88(sp)
    80004456:	6946                	ld	s2,80(sp)
    80004458:	69a6                	ld	s3,72(sp)
    8000445a:	6a06                	ld	s4,64(sp)
    8000445c:	7ae2                	ld	s5,56(sp)
    8000445e:	6165                	addi	sp,sp,112
    80004460:	8082                	ret
      wakeup(&pi->nread);
    80004462:	856a                	mv	a0,s10
    80004464:	ab3fd0ef          	jal	80001f16 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004468:	85a6                	mv	a1,s1
    8000446a:	8566                	mv	a0,s9
    8000446c:	a5ffd0ef          	jal	80001eca <sleep>
  while(i < n){
    80004470:	05495a63          	bge	s2,s4,800044c4 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004474:	2204a783          	lw	a5,544(s1)
    80004478:	d3f1                	beqz	a5,8000443c <pipewrite+0x46>
    8000447a:	854e                	mv	a0,s3
    8000447c:	c87fd0ef          	jal	80002102 <killed>
    80004480:	fd55                	bnez	a0,8000443c <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004482:	2184a783          	lw	a5,536(s1)
    80004486:	21c4a703          	lw	a4,540(s1)
    8000448a:	2007879b          	addiw	a5,a5,512
    8000448e:	fcf70ae3          	beq	a4,a5,80004462 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004492:	86de                	mv	a3,s7
    80004494:	01590633          	add	a2,s2,s5
    80004498:	85e2                	mv	a1,s8
    8000449a:	0509b503          	ld	a0,80(s3)
    8000449e:	996fd0ef          	jal	80001634 <copyin>
    800044a2:	05650063          	beq	a0,s6,800044e2 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800044a6:	21c4a783          	lw	a5,540(s1)
    800044aa:	0017871b          	addiw	a4,a5,1
    800044ae:	20e4ae23          	sw	a4,540(s1)
    800044b2:	1ff7f793          	andi	a5,a5,511
    800044b6:	97a6                	add	a5,a5,s1
    800044b8:	f9f44703          	lbu	a4,-97(s0)
    800044bc:	00e78c23          	sb	a4,24(a5)
      i++;
    800044c0:	2905                	addiw	s2,s2,1
    800044c2:	b77d                	j	80004470 <pipewrite+0x7a>
    800044c4:	7b42                	ld	s6,48(sp)
    800044c6:	7ba2                	ld	s7,40(sp)
    800044c8:	7c02                	ld	s8,32(sp)
    800044ca:	6ce2                	ld	s9,24(sp)
    800044cc:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800044ce:	21848513          	addi	a0,s1,536
    800044d2:	a45fd0ef          	jal	80001f16 <wakeup>
  release(&pi->lock);
    800044d6:	8526                	mv	a0,s1
    800044d8:	fbafc0ef          	jal	80000c92 <release>
  return i;
    800044dc:	bf8d                	j	8000444e <pipewrite+0x58>
  int i = 0;
    800044de:	4901                	li	s2,0
    800044e0:	b7fd                	j	800044ce <pipewrite+0xd8>
    800044e2:	7b42                	ld	s6,48(sp)
    800044e4:	7ba2                	ld	s7,40(sp)
    800044e6:	7c02                	ld	s8,32(sp)
    800044e8:	6ce2                	ld	s9,24(sp)
    800044ea:	6d42                	ld	s10,16(sp)
    800044ec:	b7cd                	j	800044ce <pipewrite+0xd8>

00000000800044ee <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800044ee:	711d                	addi	sp,sp,-96
    800044f0:	ec86                	sd	ra,88(sp)
    800044f2:	e8a2                	sd	s0,80(sp)
    800044f4:	e4a6                	sd	s1,72(sp)
    800044f6:	e0ca                	sd	s2,64(sp)
    800044f8:	fc4e                	sd	s3,56(sp)
    800044fa:	f852                	sd	s4,48(sp)
    800044fc:	f456                	sd	s5,40(sp)
    800044fe:	1080                	addi	s0,sp,96
    80004500:	84aa                	mv	s1,a0
    80004502:	892e                	mv	s2,a1
    80004504:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004506:	bd6fd0ef          	jal	800018dc <myproc>
    8000450a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000450c:	8526                	mv	a0,s1
    8000450e:	ef0fc0ef          	jal	80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004512:	2184a703          	lw	a4,536(s1)
    80004516:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000451a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000451e:	02f71763          	bne	a4,a5,8000454c <piperead+0x5e>
    80004522:	2244a783          	lw	a5,548(s1)
    80004526:	cf85                	beqz	a5,8000455e <piperead+0x70>
    if(killed(pr)){
    80004528:	8552                	mv	a0,s4
    8000452a:	bd9fd0ef          	jal	80002102 <killed>
    8000452e:	e11d                	bnez	a0,80004554 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004530:	85a6                	mv	a1,s1
    80004532:	854e                	mv	a0,s3
    80004534:	997fd0ef          	jal	80001eca <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004538:	2184a703          	lw	a4,536(s1)
    8000453c:	21c4a783          	lw	a5,540(s1)
    80004540:	fef701e3          	beq	a4,a5,80004522 <piperead+0x34>
    80004544:	f05a                	sd	s6,32(sp)
    80004546:	ec5e                	sd	s7,24(sp)
    80004548:	e862                	sd	s8,16(sp)
    8000454a:	a829                	j	80004564 <piperead+0x76>
    8000454c:	f05a                	sd	s6,32(sp)
    8000454e:	ec5e                	sd	s7,24(sp)
    80004550:	e862                	sd	s8,16(sp)
    80004552:	a809                	j	80004564 <piperead+0x76>
      release(&pi->lock);
    80004554:	8526                	mv	a0,s1
    80004556:	f3cfc0ef          	jal	80000c92 <release>
      return -1;
    8000455a:	59fd                	li	s3,-1
    8000455c:	a0a5                	j	800045c4 <piperead+0xd6>
    8000455e:	f05a                	sd	s6,32(sp)
    80004560:	ec5e                	sd	s7,24(sp)
    80004562:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004564:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004566:	faf40c13          	addi	s8,s0,-81
    8000456a:	4b85                	li	s7,1
    8000456c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000456e:	05505163          	blez	s5,800045b0 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004572:	2184a783          	lw	a5,536(s1)
    80004576:	21c4a703          	lw	a4,540(s1)
    8000457a:	02f70b63          	beq	a4,a5,800045b0 <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000457e:	0017871b          	addiw	a4,a5,1
    80004582:	20e4ac23          	sw	a4,536(s1)
    80004586:	1ff7f793          	andi	a5,a5,511
    8000458a:	97a6                	add	a5,a5,s1
    8000458c:	0187c783          	lbu	a5,24(a5)
    80004590:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004594:	86de                	mv	a3,s7
    80004596:	8662                	mv	a2,s8
    80004598:	85ca                	mv	a1,s2
    8000459a:	050a3503          	ld	a0,80(s4)
    8000459e:	fe7fc0ef          	jal	80001584 <copyout>
    800045a2:	01650763          	beq	a0,s6,800045b0 <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045a6:	2985                	addiw	s3,s3,1
    800045a8:	0905                	addi	s2,s2,1
    800045aa:	fd3a94e3          	bne	s5,s3,80004572 <piperead+0x84>
    800045ae:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800045b0:	21c48513          	addi	a0,s1,540
    800045b4:	963fd0ef          	jal	80001f16 <wakeup>
  release(&pi->lock);
    800045b8:	8526                	mv	a0,s1
    800045ba:	ed8fc0ef          	jal	80000c92 <release>
    800045be:	7b02                	ld	s6,32(sp)
    800045c0:	6be2                	ld	s7,24(sp)
    800045c2:	6c42                	ld	s8,16(sp)
  return i;
}
    800045c4:	854e                	mv	a0,s3
    800045c6:	60e6                	ld	ra,88(sp)
    800045c8:	6446                	ld	s0,80(sp)
    800045ca:	64a6                	ld	s1,72(sp)
    800045cc:	6906                	ld	s2,64(sp)
    800045ce:	79e2                	ld	s3,56(sp)
    800045d0:	7a42                	ld	s4,48(sp)
    800045d2:	7aa2                	ld	s5,40(sp)
    800045d4:	6125                	addi	sp,sp,96
    800045d6:	8082                	ret

00000000800045d8 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800045d8:	1141                	addi	sp,sp,-16
    800045da:	e406                	sd	ra,8(sp)
    800045dc:	e022                	sd	s0,0(sp)
    800045de:	0800                	addi	s0,sp,16
    800045e0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800045e2:	0035151b          	slliw	a0,a0,0x3
    800045e6:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800045e8:	8b89                	andi	a5,a5,2
    800045ea:	c399                	beqz	a5,800045f0 <flags2perm+0x18>
      perm |= PTE_W;
    800045ec:	00456513          	ori	a0,a0,4
    return perm;
}
    800045f0:	60a2                	ld	ra,8(sp)
    800045f2:	6402                	ld	s0,0(sp)
    800045f4:	0141                	addi	sp,sp,16
    800045f6:	8082                	ret

00000000800045f8 <exec>:

int
exec(char *path, char **argv)
{
    800045f8:	de010113          	addi	sp,sp,-544
    800045fc:	20113c23          	sd	ra,536(sp)
    80004600:	20813823          	sd	s0,528(sp)
    80004604:	20913423          	sd	s1,520(sp)
    80004608:	21213023          	sd	s2,512(sp)
    8000460c:	1400                	addi	s0,sp,544
    8000460e:	892a                	mv	s2,a0
    80004610:	dea43823          	sd	a0,-528(s0)
    80004614:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004618:	ac4fd0ef          	jal	800018dc <myproc>
    8000461c:	84aa                	mv	s1,a0

  begin_op();
    8000461e:	d88ff0ef          	jal	80003ba6 <begin_op>

  if((ip = namei(path)) == 0){
    80004622:	854a                	mv	a0,s2
    80004624:	bc0ff0ef          	jal	800039e4 <namei>
    80004628:	cd21                	beqz	a0,80004680 <exec+0x88>
    8000462a:	fbd2                	sd	s4,496(sp)
    8000462c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000462e:	cc7fe0ef          	jal	800032f4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004632:	04000713          	li	a4,64
    80004636:	4681                	li	a3,0
    80004638:	e5040613          	addi	a2,s0,-432
    8000463c:	4581                	li	a1,0
    8000463e:	8552                	mv	a0,s4
    80004640:	f0dfe0ef          	jal	8000354c <readi>
    80004644:	04000793          	li	a5,64
    80004648:	00f51a63          	bne	a0,a5,8000465c <exec+0x64>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000464c:	e5042703          	lw	a4,-432(s0)
    80004650:	464c47b7          	lui	a5,0x464c4
    80004654:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004658:	02f70863          	beq	a4,a5,80004688 <exec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000465c:	8552                	mv	a0,s4
    8000465e:	ea1fe0ef          	jal	800034fe <iunlockput>
    end_op();
    80004662:	daeff0ef          	jal	80003c10 <end_op>
  }
  return -1;
    80004666:	557d                	li	a0,-1
    80004668:	7a5e                	ld	s4,496(sp)
}
    8000466a:	21813083          	ld	ra,536(sp)
    8000466e:	21013403          	ld	s0,528(sp)
    80004672:	20813483          	ld	s1,520(sp)
    80004676:	20013903          	ld	s2,512(sp)
    8000467a:	22010113          	addi	sp,sp,544
    8000467e:	8082                	ret
    end_op();
    80004680:	d90ff0ef          	jal	80003c10 <end_op>
    return -1;
    80004684:	557d                	li	a0,-1
    80004686:	b7d5                	j	8000466a <exec+0x72>
    80004688:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000468a:	8526                	mv	a0,s1
    8000468c:	af8fd0ef          	jal	80001984 <proc_pagetable>
    80004690:	8b2a                	mv	s6,a0
    80004692:	26050d63          	beqz	a0,8000490c <exec+0x314>
    80004696:	ffce                	sd	s3,504(sp)
    80004698:	f7d6                	sd	s5,488(sp)
    8000469a:	efde                	sd	s7,472(sp)
    8000469c:	ebe2                	sd	s8,464(sp)
    8000469e:	e7e6                	sd	s9,456(sp)
    800046a0:	e3ea                	sd	s10,448(sp)
    800046a2:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046a4:	e7042683          	lw	a3,-400(s0)
    800046a8:	e8845783          	lhu	a5,-376(s0)
    800046ac:	0e078763          	beqz	a5,8000479a <exec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046b0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046b2:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800046b4:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800046b8:	6c85                	lui	s9,0x1
    800046ba:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800046be:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800046c2:	6a85                	lui	s5,0x1
    800046c4:	a085                	j	80004724 <exec+0x12c>
      panic("loadseg: address should exist");
    800046c6:	00003517          	auipc	a0,0x3
    800046ca:	f4250513          	addi	a0,a0,-190 # 80007608 <etext+0x608>
    800046ce:	8d0fc0ef          	jal	8000079e <panic>
    if(sz - i < PGSIZE)
    800046d2:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800046d4:	874a                	mv	a4,s2
    800046d6:	009c06bb          	addw	a3,s8,s1
    800046da:	4581                	li	a1,0
    800046dc:	8552                	mv	a0,s4
    800046de:	e6ffe0ef          	jal	8000354c <readi>
    800046e2:	22a91963          	bne	s2,a0,80004914 <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    800046e6:	009a84bb          	addw	s1,s5,s1
    800046ea:	0334f263          	bgeu	s1,s3,8000470e <exec+0x116>
    pa = walkaddr(pagetable, va + i);
    800046ee:	02049593          	slli	a1,s1,0x20
    800046f2:	9181                	srli	a1,a1,0x20
    800046f4:	95de                	add	a1,a1,s7
    800046f6:	855a                	mv	a0,s6
    800046f8:	905fc0ef          	jal	80000ffc <walkaddr>
    800046fc:	862a                	mv	a2,a0
    if(pa == 0)
    800046fe:	d561                	beqz	a0,800046c6 <exec+0xce>
    if(sz - i < PGSIZE)
    80004700:	409987bb          	subw	a5,s3,s1
    80004704:	893e                	mv	s2,a5
    80004706:	fcfcf6e3          	bgeu	s9,a5,800046d2 <exec+0xda>
    8000470a:	8956                	mv	s2,s5
    8000470c:	b7d9                	j	800046d2 <exec+0xda>
    sz = sz1;
    8000470e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004712:	2d05                	addiw	s10,s10,1
    80004714:	e0843783          	ld	a5,-504(s0)
    80004718:	0387869b          	addiw	a3,a5,56
    8000471c:	e8845783          	lhu	a5,-376(s0)
    80004720:	06fd5e63          	bge	s10,a5,8000479c <exec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004724:	e0d43423          	sd	a3,-504(s0)
    80004728:	876e                	mv	a4,s11
    8000472a:	e1840613          	addi	a2,s0,-488
    8000472e:	4581                	li	a1,0
    80004730:	8552                	mv	a0,s4
    80004732:	e1bfe0ef          	jal	8000354c <readi>
    80004736:	1db51d63          	bne	a0,s11,80004910 <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    8000473a:	e1842783          	lw	a5,-488(s0)
    8000473e:	4705                	li	a4,1
    80004740:	fce799e3          	bne	a5,a4,80004712 <exec+0x11a>
    if(ph.memsz < ph.filesz)
    80004744:	e4043483          	ld	s1,-448(s0)
    80004748:	e3843783          	ld	a5,-456(s0)
    8000474c:	1ef4e263          	bltu	s1,a5,80004930 <exec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004750:	e2843783          	ld	a5,-472(s0)
    80004754:	94be                	add	s1,s1,a5
    80004756:	1ef4e063          	bltu	s1,a5,80004936 <exec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    8000475a:	de843703          	ld	a4,-536(s0)
    8000475e:	8ff9                	and	a5,a5,a4
    80004760:	1c079e63          	bnez	a5,8000493c <exec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004764:	e1c42503          	lw	a0,-484(s0)
    80004768:	e71ff0ef          	jal	800045d8 <flags2perm>
    8000476c:	86aa                	mv	a3,a0
    8000476e:	8626                	mv	a2,s1
    80004770:	85ca                	mv	a1,s2
    80004772:	855a                	mv	a0,s6
    80004774:	bf1fc0ef          	jal	80001364 <uvmalloc>
    80004778:	dea43c23          	sd	a0,-520(s0)
    8000477c:	1c050363          	beqz	a0,80004942 <exec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004780:	e2843b83          	ld	s7,-472(s0)
    80004784:	e2042c03          	lw	s8,-480(s0)
    80004788:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000478c:	00098463          	beqz	s3,80004794 <exec+0x19c>
    80004790:	4481                	li	s1,0
    80004792:	bfb1                	j	800046ee <exec+0xf6>
    sz = sz1;
    80004794:	df843903          	ld	s2,-520(s0)
    80004798:	bfad                	j	80004712 <exec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000479a:	4901                	li	s2,0
  iunlockput(ip);
    8000479c:	8552                	mv	a0,s4
    8000479e:	d61fe0ef          	jal	800034fe <iunlockput>
  end_op();
    800047a2:	c6eff0ef          	jal	80003c10 <end_op>
  p = myproc();
    800047a6:	936fd0ef          	jal	800018dc <myproc>
    800047aa:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800047ac:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800047b0:	6985                	lui	s3,0x1
    800047b2:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800047b4:	99ca                	add	s3,s3,s2
    800047b6:	77fd                	lui	a5,0xfffff
    800047b8:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800047bc:	4691                	li	a3,4
    800047be:	6609                	lui	a2,0x2
    800047c0:	964e                	add	a2,a2,s3
    800047c2:	85ce                	mv	a1,s3
    800047c4:	855a                	mv	a0,s6
    800047c6:	b9ffc0ef          	jal	80001364 <uvmalloc>
    800047ca:	8a2a                	mv	s4,a0
    800047cc:	e105                	bnez	a0,800047ec <exec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800047ce:	85ce                	mv	a1,s3
    800047d0:	855a                	mv	a0,s6
    800047d2:	a36fd0ef          	jal	80001a08 <proc_freepagetable>
  return -1;
    800047d6:	557d                	li	a0,-1
    800047d8:	79fe                	ld	s3,504(sp)
    800047da:	7a5e                	ld	s4,496(sp)
    800047dc:	7abe                	ld	s5,488(sp)
    800047de:	7b1e                	ld	s6,480(sp)
    800047e0:	6bfe                	ld	s7,472(sp)
    800047e2:	6c5e                	ld	s8,464(sp)
    800047e4:	6cbe                	ld	s9,456(sp)
    800047e6:	6d1e                	ld	s10,448(sp)
    800047e8:	7dfa                	ld	s11,440(sp)
    800047ea:	b541                	j	8000466a <exec+0x72>
  uvmclear(pagetable, sz-2*PGSIZE);
    800047ec:	75f9                	lui	a1,0xffffe
    800047ee:	95aa                	add	a1,a1,a0
    800047f0:	855a                	mv	a0,s6
    800047f2:	d69fc0ef          	jal	8000155a <uvmclear>
  stackbase = sp - PGSIZE;
    800047f6:	7bfd                	lui	s7,0xfffff
    800047f8:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    800047fa:	e0043783          	ld	a5,-512(s0)
    800047fe:	6388                	ld	a0,0(a5)
  sp = sz;
    80004800:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004802:	4481                	li	s1,0
    ustack[argc] = sp;
    80004804:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004808:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000480c:	cd21                	beqz	a0,80004864 <exec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    8000480e:	e48fc0ef          	jal	80000e56 <strlen>
    80004812:	0015079b          	addiw	a5,a0,1
    80004816:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000481a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000481e:	13796563          	bltu	s2,s7,80004948 <exec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004822:	e0043d83          	ld	s11,-512(s0)
    80004826:	000db983          	ld	s3,0(s11)
    8000482a:	854e                	mv	a0,s3
    8000482c:	e2afc0ef          	jal	80000e56 <strlen>
    80004830:	0015069b          	addiw	a3,a0,1
    80004834:	864e                	mv	a2,s3
    80004836:	85ca                	mv	a1,s2
    80004838:	855a                	mv	a0,s6
    8000483a:	d4bfc0ef          	jal	80001584 <copyout>
    8000483e:	10054763          	bltz	a0,8000494c <exec+0x354>
    ustack[argc] = sp;
    80004842:	00349793          	slli	a5,s1,0x3
    80004846:	97e6                	add	a5,a5,s9
    80004848:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb0a8>
  for(argc = 0; argv[argc]; argc++) {
    8000484c:	0485                	addi	s1,s1,1
    8000484e:	008d8793          	addi	a5,s11,8
    80004852:	e0f43023          	sd	a5,-512(s0)
    80004856:	008db503          	ld	a0,8(s11)
    8000485a:	c509                	beqz	a0,80004864 <exec+0x26c>
    if(argc >= MAXARG)
    8000485c:	fb8499e3          	bne	s1,s8,8000480e <exec+0x216>
  sz = sz1;
    80004860:	89d2                	mv	s3,s4
    80004862:	b7b5                	j	800047ce <exec+0x1d6>
  ustack[argc] = 0;
    80004864:	00349793          	slli	a5,s1,0x3
    80004868:	f9078793          	addi	a5,a5,-112
    8000486c:	97a2                	add	a5,a5,s0
    8000486e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004872:	00148693          	addi	a3,s1,1
    80004876:	068e                	slli	a3,a3,0x3
    80004878:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000487c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004880:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004882:	f57966e3          	bltu	s2,s7,800047ce <exec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004886:	e9040613          	addi	a2,s0,-368
    8000488a:	85ca                	mv	a1,s2
    8000488c:	855a                	mv	a0,s6
    8000488e:	cf7fc0ef          	jal	80001584 <copyout>
    80004892:	f2054ee3          	bltz	a0,800047ce <exec+0x1d6>
  p->trapframe->a1 = sp;
    80004896:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000489a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000489e:	df043783          	ld	a5,-528(s0)
    800048a2:	0007c703          	lbu	a4,0(a5)
    800048a6:	cf11                	beqz	a4,800048c2 <exec+0x2ca>
    800048a8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800048aa:	02f00693          	li	a3,47
    800048ae:	a029                	j	800048b8 <exec+0x2c0>
  for(last=s=path; *s; s++)
    800048b0:	0785                	addi	a5,a5,1
    800048b2:	fff7c703          	lbu	a4,-1(a5)
    800048b6:	c711                	beqz	a4,800048c2 <exec+0x2ca>
    if(*s == '/')
    800048b8:	fed71ce3          	bne	a4,a3,800048b0 <exec+0x2b8>
      last = s+1;
    800048bc:	def43823          	sd	a5,-528(s0)
    800048c0:	bfc5                	j	800048b0 <exec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    800048c2:	4641                	li	a2,16
    800048c4:	df043583          	ld	a1,-528(s0)
    800048c8:	158a8513          	addi	a0,s5,344
    800048cc:	d54fc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    800048d0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800048d4:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800048d8:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800048dc:	058ab783          	ld	a5,88(s5)
    800048e0:	e6843703          	ld	a4,-408(s0)
    800048e4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800048e6:	058ab783          	ld	a5,88(s5)
    800048ea:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800048ee:	85ea                	mv	a1,s10
    800048f0:	918fd0ef          	jal	80001a08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800048f4:	0004851b          	sext.w	a0,s1
    800048f8:	79fe                	ld	s3,504(sp)
    800048fa:	7a5e                	ld	s4,496(sp)
    800048fc:	7abe                	ld	s5,488(sp)
    800048fe:	7b1e                	ld	s6,480(sp)
    80004900:	6bfe                	ld	s7,472(sp)
    80004902:	6c5e                	ld	s8,464(sp)
    80004904:	6cbe                	ld	s9,456(sp)
    80004906:	6d1e                	ld	s10,448(sp)
    80004908:	7dfa                	ld	s11,440(sp)
    8000490a:	b385                	j	8000466a <exec+0x72>
    8000490c:	7b1e                	ld	s6,480(sp)
    8000490e:	b3b9                	j	8000465c <exec+0x64>
    80004910:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004914:	df843583          	ld	a1,-520(s0)
    80004918:	855a                	mv	a0,s6
    8000491a:	8eefd0ef          	jal	80001a08 <proc_freepagetable>
  if(ip){
    8000491e:	79fe                	ld	s3,504(sp)
    80004920:	7abe                	ld	s5,488(sp)
    80004922:	7b1e                	ld	s6,480(sp)
    80004924:	6bfe                	ld	s7,472(sp)
    80004926:	6c5e                	ld	s8,464(sp)
    80004928:	6cbe                	ld	s9,456(sp)
    8000492a:	6d1e                	ld	s10,448(sp)
    8000492c:	7dfa                	ld	s11,440(sp)
    8000492e:	b33d                	j	8000465c <exec+0x64>
    80004930:	df243c23          	sd	s2,-520(s0)
    80004934:	b7c5                	j	80004914 <exec+0x31c>
    80004936:	df243c23          	sd	s2,-520(s0)
    8000493a:	bfe9                	j	80004914 <exec+0x31c>
    8000493c:	df243c23          	sd	s2,-520(s0)
    80004940:	bfd1                	j	80004914 <exec+0x31c>
    80004942:	df243c23          	sd	s2,-520(s0)
    80004946:	b7f9                	j	80004914 <exec+0x31c>
  sz = sz1;
    80004948:	89d2                	mv	s3,s4
    8000494a:	b551                	j	800047ce <exec+0x1d6>
    8000494c:	89d2                	mv	s3,s4
    8000494e:	b541                	j	800047ce <exec+0x1d6>

0000000080004950 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004950:	7179                	addi	sp,sp,-48
    80004952:	f406                	sd	ra,40(sp)
    80004954:	f022                	sd	s0,32(sp)
    80004956:	ec26                	sd	s1,24(sp)
    80004958:	e84a                	sd	s2,16(sp)
    8000495a:	1800                	addi	s0,sp,48
    8000495c:	892e                	mv	s2,a1
    8000495e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004960:	fdc40593          	addi	a1,s0,-36
    80004964:	e8bfd0ef          	jal	800027ee <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004968:	fdc42703          	lw	a4,-36(s0)
    8000496c:	47bd                	li	a5,15
    8000496e:	02e7e963          	bltu	a5,a4,800049a0 <argfd+0x50>
    80004972:	f6bfc0ef          	jal	800018dc <myproc>
    80004976:	fdc42703          	lw	a4,-36(s0)
    8000497a:	01a70793          	addi	a5,a4,26
    8000497e:	078e                	slli	a5,a5,0x3
    80004980:	953e                	add	a0,a0,a5
    80004982:	611c                	ld	a5,0(a0)
    80004984:	c385                	beqz	a5,800049a4 <argfd+0x54>
    return -1;
  if(pfd)
    80004986:	00090463          	beqz	s2,8000498e <argfd+0x3e>
    *pfd = fd;
    8000498a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000498e:	4501                	li	a0,0
  if(pf)
    80004990:	c091                	beqz	s1,80004994 <argfd+0x44>
    *pf = f;
    80004992:	e09c                	sd	a5,0(s1)
}
    80004994:	70a2                	ld	ra,40(sp)
    80004996:	7402                	ld	s0,32(sp)
    80004998:	64e2                	ld	s1,24(sp)
    8000499a:	6942                	ld	s2,16(sp)
    8000499c:	6145                	addi	sp,sp,48
    8000499e:	8082                	ret
    return -1;
    800049a0:	557d                	li	a0,-1
    800049a2:	bfcd                	j	80004994 <argfd+0x44>
    800049a4:	557d                	li	a0,-1
    800049a6:	b7fd                	j	80004994 <argfd+0x44>

00000000800049a8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800049a8:	1101                	addi	sp,sp,-32
    800049aa:	ec06                	sd	ra,24(sp)
    800049ac:	e822                	sd	s0,16(sp)
    800049ae:	e426                	sd	s1,8(sp)
    800049b0:	1000                	addi	s0,sp,32
    800049b2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800049b4:	f29fc0ef          	jal	800018dc <myproc>
    800049b8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800049ba:	0d050793          	addi	a5,a0,208
    800049be:	4501                	li	a0,0
    800049c0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800049c2:	6398                	ld	a4,0(a5)
    800049c4:	cb19                	beqz	a4,800049da <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800049c6:	2505                	addiw	a0,a0,1
    800049c8:	07a1                	addi	a5,a5,8
    800049ca:	fed51ce3          	bne	a0,a3,800049c2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800049ce:	557d                	li	a0,-1
}
    800049d0:	60e2                	ld	ra,24(sp)
    800049d2:	6442                	ld	s0,16(sp)
    800049d4:	64a2                	ld	s1,8(sp)
    800049d6:	6105                	addi	sp,sp,32
    800049d8:	8082                	ret
      p->ofile[fd] = f;
    800049da:	01a50793          	addi	a5,a0,26
    800049de:	078e                	slli	a5,a5,0x3
    800049e0:	963e                	add	a2,a2,a5
    800049e2:	e204                	sd	s1,0(a2)
      return fd;
    800049e4:	b7f5                	j	800049d0 <fdalloc+0x28>

00000000800049e6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800049e6:	715d                	addi	sp,sp,-80
    800049e8:	e486                	sd	ra,72(sp)
    800049ea:	e0a2                	sd	s0,64(sp)
    800049ec:	fc26                	sd	s1,56(sp)
    800049ee:	f84a                	sd	s2,48(sp)
    800049f0:	f44e                	sd	s3,40(sp)
    800049f2:	ec56                	sd	s5,24(sp)
    800049f4:	e85a                	sd	s6,16(sp)
    800049f6:	0880                	addi	s0,sp,80
    800049f8:	8b2e                	mv	s6,a1
    800049fa:	89b2                	mv	s3,a2
    800049fc:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800049fe:	fb040593          	addi	a1,s0,-80
    80004a02:	ffdfe0ef          	jal	800039fe <nameiparent>
    80004a06:	84aa                	mv	s1,a0
    80004a08:	10050a63          	beqz	a0,80004b1c <create+0x136>
    return 0;

  ilock(dp);
    80004a0c:	8e9fe0ef          	jal	800032f4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a10:	4601                	li	a2,0
    80004a12:	fb040593          	addi	a1,s0,-80
    80004a16:	8526                	mv	a0,s1
    80004a18:	d41fe0ef          	jal	80003758 <dirlookup>
    80004a1c:	8aaa                	mv	s5,a0
    80004a1e:	c129                	beqz	a0,80004a60 <create+0x7a>
    iunlockput(dp);
    80004a20:	8526                	mv	a0,s1
    80004a22:	addfe0ef          	jal	800034fe <iunlockput>
    ilock(ip);
    80004a26:	8556                	mv	a0,s5
    80004a28:	8cdfe0ef          	jal	800032f4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a2c:	4789                	li	a5,2
    80004a2e:	02fb1463          	bne	s6,a5,80004a56 <create+0x70>
    80004a32:	044ad783          	lhu	a5,68(s5)
    80004a36:	37f9                	addiw	a5,a5,-2
    80004a38:	17c2                	slli	a5,a5,0x30
    80004a3a:	93c1                	srli	a5,a5,0x30
    80004a3c:	4705                	li	a4,1
    80004a3e:	00f76c63          	bltu	a4,a5,80004a56 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a42:	8556                	mv	a0,s5
    80004a44:	60a6                	ld	ra,72(sp)
    80004a46:	6406                	ld	s0,64(sp)
    80004a48:	74e2                	ld	s1,56(sp)
    80004a4a:	7942                	ld	s2,48(sp)
    80004a4c:	79a2                	ld	s3,40(sp)
    80004a4e:	6ae2                	ld	s5,24(sp)
    80004a50:	6b42                	ld	s6,16(sp)
    80004a52:	6161                	addi	sp,sp,80
    80004a54:	8082                	ret
    iunlockput(ip);
    80004a56:	8556                	mv	a0,s5
    80004a58:	aa7fe0ef          	jal	800034fe <iunlockput>
    return 0;
    80004a5c:	4a81                	li	s5,0
    80004a5e:	b7d5                	j	80004a42 <create+0x5c>
    80004a60:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a62:	85da                	mv	a1,s6
    80004a64:	4088                	lw	a0,0(s1)
    80004a66:	f1efe0ef          	jal	80003184 <ialloc>
    80004a6a:	8a2a                	mv	s4,a0
    80004a6c:	cd15                	beqz	a0,80004aa8 <create+0xc2>
  ilock(ip);
    80004a6e:	887fe0ef          	jal	800032f4 <ilock>
  ip->major = major;
    80004a72:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004a76:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004a7a:	4905                	li	s2,1
    80004a7c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004a80:	8552                	mv	a0,s4
    80004a82:	fbefe0ef          	jal	80003240 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004a86:	032b0763          	beq	s6,s2,80004ab4 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a8a:	004a2603          	lw	a2,4(s4)
    80004a8e:	fb040593          	addi	a1,s0,-80
    80004a92:	8526                	mv	a0,s1
    80004a94:	ea7fe0ef          	jal	8000393a <dirlink>
    80004a98:	06054563          	bltz	a0,80004b02 <create+0x11c>
  iunlockput(dp);
    80004a9c:	8526                	mv	a0,s1
    80004a9e:	a61fe0ef          	jal	800034fe <iunlockput>
  return ip;
    80004aa2:	8ad2                	mv	s5,s4
    80004aa4:	7a02                	ld	s4,32(sp)
    80004aa6:	bf71                	j	80004a42 <create+0x5c>
    iunlockput(dp);
    80004aa8:	8526                	mv	a0,s1
    80004aaa:	a55fe0ef          	jal	800034fe <iunlockput>
    return 0;
    80004aae:	8ad2                	mv	s5,s4
    80004ab0:	7a02                	ld	s4,32(sp)
    80004ab2:	bf41                	j	80004a42 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ab4:	004a2603          	lw	a2,4(s4)
    80004ab8:	00003597          	auipc	a1,0x3
    80004abc:	b7058593          	addi	a1,a1,-1168 # 80007628 <etext+0x628>
    80004ac0:	8552                	mv	a0,s4
    80004ac2:	e79fe0ef          	jal	8000393a <dirlink>
    80004ac6:	02054e63          	bltz	a0,80004b02 <create+0x11c>
    80004aca:	40d0                	lw	a2,4(s1)
    80004acc:	00003597          	auipc	a1,0x3
    80004ad0:	b6458593          	addi	a1,a1,-1180 # 80007630 <etext+0x630>
    80004ad4:	8552                	mv	a0,s4
    80004ad6:	e65fe0ef          	jal	8000393a <dirlink>
    80004ada:	02054463          	bltz	a0,80004b02 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ade:	004a2603          	lw	a2,4(s4)
    80004ae2:	fb040593          	addi	a1,s0,-80
    80004ae6:	8526                	mv	a0,s1
    80004ae8:	e53fe0ef          	jal	8000393a <dirlink>
    80004aec:	00054b63          	bltz	a0,80004b02 <create+0x11c>
    dp->nlink++;  // for ".."
    80004af0:	04a4d783          	lhu	a5,74(s1)
    80004af4:	2785                	addiw	a5,a5,1
    80004af6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004afa:	8526                	mv	a0,s1
    80004afc:	f44fe0ef          	jal	80003240 <iupdate>
    80004b00:	bf71                	j	80004a9c <create+0xb6>
  ip->nlink = 0;
    80004b02:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004b06:	8552                	mv	a0,s4
    80004b08:	f38fe0ef          	jal	80003240 <iupdate>
  iunlockput(ip);
    80004b0c:	8552                	mv	a0,s4
    80004b0e:	9f1fe0ef          	jal	800034fe <iunlockput>
  iunlockput(dp);
    80004b12:	8526                	mv	a0,s1
    80004b14:	9ebfe0ef          	jal	800034fe <iunlockput>
  return 0;
    80004b18:	7a02                	ld	s4,32(sp)
    80004b1a:	b725                	j	80004a42 <create+0x5c>
    return 0;
    80004b1c:	8aaa                	mv	s5,a0
    80004b1e:	b715                	j	80004a42 <create+0x5c>

0000000080004b20 <sys_dup>:
{
    80004b20:	7179                	addi	sp,sp,-48
    80004b22:	f406                	sd	ra,40(sp)
    80004b24:	f022                	sd	s0,32(sp)
    80004b26:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004b28:	fd840613          	addi	a2,s0,-40
    80004b2c:	4581                	li	a1,0
    80004b2e:	4501                	li	a0,0
    80004b30:	e21ff0ef          	jal	80004950 <argfd>
    return -1;
    80004b34:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004b36:	02054363          	bltz	a0,80004b5c <sys_dup+0x3c>
    80004b3a:	ec26                	sd	s1,24(sp)
    80004b3c:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004b3e:	fd843903          	ld	s2,-40(s0)
    80004b42:	854a                	mv	a0,s2
    80004b44:	e65ff0ef          	jal	800049a8 <fdalloc>
    80004b48:	84aa                	mv	s1,a0
    return -1;
    80004b4a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004b4c:	00054d63          	bltz	a0,80004b66 <sys_dup+0x46>
  filedup(f);
    80004b50:	854a                	mv	a0,s2
    80004b52:	c2eff0ef          	jal	80003f80 <filedup>
  return fd;
    80004b56:	87a6                	mv	a5,s1
    80004b58:	64e2                	ld	s1,24(sp)
    80004b5a:	6942                	ld	s2,16(sp)
}
    80004b5c:	853e                	mv	a0,a5
    80004b5e:	70a2                	ld	ra,40(sp)
    80004b60:	7402                	ld	s0,32(sp)
    80004b62:	6145                	addi	sp,sp,48
    80004b64:	8082                	ret
    80004b66:	64e2                	ld	s1,24(sp)
    80004b68:	6942                	ld	s2,16(sp)
    80004b6a:	bfcd                	j	80004b5c <sys_dup+0x3c>

0000000080004b6c <sys_read>:
{
    80004b6c:	7179                	addi	sp,sp,-48
    80004b6e:	f406                	sd	ra,40(sp)
    80004b70:	f022                	sd	s0,32(sp)
    80004b72:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b74:	fd840593          	addi	a1,s0,-40
    80004b78:	4505                	li	a0,1
    80004b7a:	c91fd0ef          	jal	8000280a <argaddr>
  argint(2, &n);
    80004b7e:	fe440593          	addi	a1,s0,-28
    80004b82:	4509                	li	a0,2
    80004b84:	c6bfd0ef          	jal	800027ee <argint>
  if(argfd(0, 0, &f) < 0)
    80004b88:	fe840613          	addi	a2,s0,-24
    80004b8c:	4581                	li	a1,0
    80004b8e:	4501                	li	a0,0
    80004b90:	dc1ff0ef          	jal	80004950 <argfd>
    80004b94:	87aa                	mv	a5,a0
    return -1;
    80004b96:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b98:	0007ca63          	bltz	a5,80004bac <sys_read+0x40>
  return fileread(f, p, n);
    80004b9c:	fe442603          	lw	a2,-28(s0)
    80004ba0:	fd843583          	ld	a1,-40(s0)
    80004ba4:	fe843503          	ld	a0,-24(s0)
    80004ba8:	d3eff0ef          	jal	800040e6 <fileread>
}
    80004bac:	70a2                	ld	ra,40(sp)
    80004bae:	7402                	ld	s0,32(sp)
    80004bb0:	6145                	addi	sp,sp,48
    80004bb2:	8082                	ret

0000000080004bb4 <sys_write>:
{
    80004bb4:	7179                	addi	sp,sp,-48
    80004bb6:	f406                	sd	ra,40(sp)
    80004bb8:	f022                	sd	s0,32(sp)
    80004bba:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bbc:	fd840593          	addi	a1,s0,-40
    80004bc0:	4505                	li	a0,1
    80004bc2:	c49fd0ef          	jal	8000280a <argaddr>
  argint(2, &n);
    80004bc6:	fe440593          	addi	a1,s0,-28
    80004bca:	4509                	li	a0,2
    80004bcc:	c23fd0ef          	jal	800027ee <argint>
  if(argfd(0, 0, &f) < 0)
    80004bd0:	fe840613          	addi	a2,s0,-24
    80004bd4:	4581                	li	a1,0
    80004bd6:	4501                	li	a0,0
    80004bd8:	d79ff0ef          	jal	80004950 <argfd>
    80004bdc:	87aa                	mv	a5,a0
    return -1;
    80004bde:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004be0:	0007ca63          	bltz	a5,80004bf4 <sys_write+0x40>
  return filewrite(f, p, n);
    80004be4:	fe442603          	lw	a2,-28(s0)
    80004be8:	fd843583          	ld	a1,-40(s0)
    80004bec:	fe843503          	ld	a0,-24(s0)
    80004bf0:	db4ff0ef          	jal	800041a4 <filewrite>
}
    80004bf4:	70a2                	ld	ra,40(sp)
    80004bf6:	7402                	ld	s0,32(sp)
    80004bf8:	6145                	addi	sp,sp,48
    80004bfa:	8082                	ret

0000000080004bfc <sys_close>:
{
    80004bfc:	1101                	addi	sp,sp,-32
    80004bfe:	ec06                	sd	ra,24(sp)
    80004c00:	e822                	sd	s0,16(sp)
    80004c02:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004c04:	fe040613          	addi	a2,s0,-32
    80004c08:	fec40593          	addi	a1,s0,-20
    80004c0c:	4501                	li	a0,0
    80004c0e:	d43ff0ef          	jal	80004950 <argfd>
    return -1;
    80004c12:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c14:	02054063          	bltz	a0,80004c34 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c18:	cc5fc0ef          	jal	800018dc <myproc>
    80004c1c:	fec42783          	lw	a5,-20(s0)
    80004c20:	07e9                	addi	a5,a5,26
    80004c22:	078e                	slli	a5,a5,0x3
    80004c24:	953e                	add	a0,a0,a5
    80004c26:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c2a:	fe043503          	ld	a0,-32(s0)
    80004c2e:	b98ff0ef          	jal	80003fc6 <fileclose>
  return 0;
    80004c32:	4781                	li	a5,0
}
    80004c34:	853e                	mv	a0,a5
    80004c36:	60e2                	ld	ra,24(sp)
    80004c38:	6442                	ld	s0,16(sp)
    80004c3a:	6105                	addi	sp,sp,32
    80004c3c:	8082                	ret

0000000080004c3e <sys_fstat>:
{
    80004c3e:	1101                	addi	sp,sp,-32
    80004c40:	ec06                	sd	ra,24(sp)
    80004c42:	e822                	sd	s0,16(sp)
    80004c44:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c46:	fe040593          	addi	a1,s0,-32
    80004c4a:	4505                	li	a0,1
    80004c4c:	bbffd0ef          	jal	8000280a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c50:	fe840613          	addi	a2,s0,-24
    80004c54:	4581                	li	a1,0
    80004c56:	4501                	li	a0,0
    80004c58:	cf9ff0ef          	jal	80004950 <argfd>
    80004c5c:	87aa                	mv	a5,a0
    return -1;
    80004c5e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c60:	0007c863          	bltz	a5,80004c70 <sys_fstat+0x32>
  return filestat(f, st);
    80004c64:	fe043583          	ld	a1,-32(s0)
    80004c68:	fe843503          	ld	a0,-24(s0)
    80004c6c:	c18ff0ef          	jal	80004084 <filestat>
}
    80004c70:	60e2                	ld	ra,24(sp)
    80004c72:	6442                	ld	s0,16(sp)
    80004c74:	6105                	addi	sp,sp,32
    80004c76:	8082                	ret

0000000080004c78 <sys_link>:
{
    80004c78:	7169                	addi	sp,sp,-304
    80004c7a:	f606                	sd	ra,296(sp)
    80004c7c:	f222                	sd	s0,288(sp)
    80004c7e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c80:	08000613          	li	a2,128
    80004c84:	ed040593          	addi	a1,s0,-304
    80004c88:	4501                	li	a0,0
    80004c8a:	b9dfd0ef          	jal	80002826 <argstr>
    return -1;
    80004c8e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c90:	0c054e63          	bltz	a0,80004d6c <sys_link+0xf4>
    80004c94:	08000613          	li	a2,128
    80004c98:	f5040593          	addi	a1,s0,-176
    80004c9c:	4505                	li	a0,1
    80004c9e:	b89fd0ef          	jal	80002826 <argstr>
    return -1;
    80004ca2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ca4:	0c054463          	bltz	a0,80004d6c <sys_link+0xf4>
    80004ca8:	ee26                	sd	s1,280(sp)
  begin_op();
    80004caa:	efdfe0ef          	jal	80003ba6 <begin_op>
  if((ip = namei(old)) == 0){
    80004cae:	ed040513          	addi	a0,s0,-304
    80004cb2:	d33fe0ef          	jal	800039e4 <namei>
    80004cb6:	84aa                	mv	s1,a0
    80004cb8:	c53d                	beqz	a0,80004d26 <sys_link+0xae>
  ilock(ip);
    80004cba:	e3afe0ef          	jal	800032f4 <ilock>
  if(ip->type == T_DIR){
    80004cbe:	04449703          	lh	a4,68(s1)
    80004cc2:	4785                	li	a5,1
    80004cc4:	06f70663          	beq	a4,a5,80004d30 <sys_link+0xb8>
    80004cc8:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004cca:	04a4d783          	lhu	a5,74(s1)
    80004cce:	2785                	addiw	a5,a5,1
    80004cd0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004cd4:	8526                	mv	a0,s1
    80004cd6:	d6afe0ef          	jal	80003240 <iupdate>
  iunlock(ip);
    80004cda:	8526                	mv	a0,s1
    80004cdc:	ec6fe0ef          	jal	800033a2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ce0:	fd040593          	addi	a1,s0,-48
    80004ce4:	f5040513          	addi	a0,s0,-176
    80004ce8:	d17fe0ef          	jal	800039fe <nameiparent>
    80004cec:	892a                	mv	s2,a0
    80004cee:	cd21                	beqz	a0,80004d46 <sys_link+0xce>
  ilock(dp);
    80004cf0:	e04fe0ef          	jal	800032f4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004cf4:	00092703          	lw	a4,0(s2)
    80004cf8:	409c                	lw	a5,0(s1)
    80004cfa:	04f71363          	bne	a4,a5,80004d40 <sys_link+0xc8>
    80004cfe:	40d0                	lw	a2,4(s1)
    80004d00:	fd040593          	addi	a1,s0,-48
    80004d04:	854a                	mv	a0,s2
    80004d06:	c35fe0ef          	jal	8000393a <dirlink>
    80004d0a:	02054b63          	bltz	a0,80004d40 <sys_link+0xc8>
  iunlockput(dp);
    80004d0e:	854a                	mv	a0,s2
    80004d10:	feefe0ef          	jal	800034fe <iunlockput>
  iput(ip);
    80004d14:	8526                	mv	a0,s1
    80004d16:	f60fe0ef          	jal	80003476 <iput>
  end_op();
    80004d1a:	ef7fe0ef          	jal	80003c10 <end_op>
  return 0;
    80004d1e:	4781                	li	a5,0
    80004d20:	64f2                	ld	s1,280(sp)
    80004d22:	6952                	ld	s2,272(sp)
    80004d24:	a0a1                	j	80004d6c <sys_link+0xf4>
    end_op();
    80004d26:	eebfe0ef          	jal	80003c10 <end_op>
    return -1;
    80004d2a:	57fd                	li	a5,-1
    80004d2c:	64f2                	ld	s1,280(sp)
    80004d2e:	a83d                	j	80004d6c <sys_link+0xf4>
    iunlockput(ip);
    80004d30:	8526                	mv	a0,s1
    80004d32:	fccfe0ef          	jal	800034fe <iunlockput>
    end_op();
    80004d36:	edbfe0ef          	jal	80003c10 <end_op>
    return -1;
    80004d3a:	57fd                	li	a5,-1
    80004d3c:	64f2                	ld	s1,280(sp)
    80004d3e:	a03d                	j	80004d6c <sys_link+0xf4>
    iunlockput(dp);
    80004d40:	854a                	mv	a0,s2
    80004d42:	fbcfe0ef          	jal	800034fe <iunlockput>
  ilock(ip);
    80004d46:	8526                	mv	a0,s1
    80004d48:	dacfe0ef          	jal	800032f4 <ilock>
  ip->nlink--;
    80004d4c:	04a4d783          	lhu	a5,74(s1)
    80004d50:	37fd                	addiw	a5,a5,-1
    80004d52:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d56:	8526                	mv	a0,s1
    80004d58:	ce8fe0ef          	jal	80003240 <iupdate>
  iunlockput(ip);
    80004d5c:	8526                	mv	a0,s1
    80004d5e:	fa0fe0ef          	jal	800034fe <iunlockput>
  end_op();
    80004d62:	eaffe0ef          	jal	80003c10 <end_op>
  return -1;
    80004d66:	57fd                	li	a5,-1
    80004d68:	64f2                	ld	s1,280(sp)
    80004d6a:	6952                	ld	s2,272(sp)
}
    80004d6c:	853e                	mv	a0,a5
    80004d6e:	70b2                	ld	ra,296(sp)
    80004d70:	7412                	ld	s0,288(sp)
    80004d72:	6155                	addi	sp,sp,304
    80004d74:	8082                	ret

0000000080004d76 <sys_unlink>:
{
    80004d76:	7111                	addi	sp,sp,-256
    80004d78:	fd86                	sd	ra,248(sp)
    80004d7a:	f9a2                	sd	s0,240(sp)
    80004d7c:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80004d7e:	08000613          	li	a2,128
    80004d82:	f2040593          	addi	a1,s0,-224
    80004d86:	4501                	li	a0,0
    80004d88:	a9ffd0ef          	jal	80002826 <argstr>
    80004d8c:	16054663          	bltz	a0,80004ef8 <sys_unlink+0x182>
    80004d90:	f5a6                	sd	s1,232(sp)
  begin_op();
    80004d92:	e15fe0ef          	jal	80003ba6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004d96:	fa040593          	addi	a1,s0,-96
    80004d9a:	f2040513          	addi	a0,s0,-224
    80004d9e:	c61fe0ef          	jal	800039fe <nameiparent>
    80004da2:	84aa                	mv	s1,a0
    80004da4:	c955                	beqz	a0,80004e58 <sys_unlink+0xe2>
  ilock(dp);
    80004da6:	d4efe0ef          	jal	800032f4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004daa:	00003597          	auipc	a1,0x3
    80004dae:	87e58593          	addi	a1,a1,-1922 # 80007628 <etext+0x628>
    80004db2:	fa040513          	addi	a0,s0,-96
    80004db6:	98dfe0ef          	jal	80003742 <namecmp>
    80004dba:	12050463          	beqz	a0,80004ee2 <sys_unlink+0x16c>
    80004dbe:	00003597          	auipc	a1,0x3
    80004dc2:	87258593          	addi	a1,a1,-1934 # 80007630 <etext+0x630>
    80004dc6:	fa040513          	addi	a0,s0,-96
    80004dca:	979fe0ef          	jal	80003742 <namecmp>
    80004dce:	10050a63          	beqz	a0,80004ee2 <sys_unlink+0x16c>
    80004dd2:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004dd4:	f1c40613          	addi	a2,s0,-228
    80004dd8:	fa040593          	addi	a1,s0,-96
    80004ddc:	8526                	mv	a0,s1
    80004dde:	97bfe0ef          	jal	80003758 <dirlookup>
    80004de2:	892a                	mv	s2,a0
    80004de4:	0e050e63          	beqz	a0,80004ee0 <sys_unlink+0x16a>
    80004de8:	edce                	sd	s3,216(sp)
  ilock(ip);
    80004dea:	d0afe0ef          	jal	800032f4 <ilock>
  if(ip->nlink < 1)
    80004dee:	04a91783          	lh	a5,74(s2)
    80004df2:	06f05863          	blez	a5,80004e62 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004df6:	04491703          	lh	a4,68(s2)
    80004dfa:	4785                	li	a5,1
    80004dfc:	06f70b63          	beq	a4,a5,80004e72 <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80004e00:	fb040993          	addi	s3,s0,-80
    80004e04:	4641                	li	a2,16
    80004e06:	4581                	li	a1,0
    80004e08:	854e                	mv	a0,s3
    80004e0a:	ec5fb0ef          	jal	80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e0e:	4741                	li	a4,16
    80004e10:	f1c42683          	lw	a3,-228(s0)
    80004e14:	864e                	mv	a2,s3
    80004e16:	4581                	li	a1,0
    80004e18:	8526                	mv	a0,s1
    80004e1a:	825fe0ef          	jal	8000363e <writei>
    80004e1e:	47c1                	li	a5,16
    80004e20:	08f51f63          	bne	a0,a5,80004ebe <sys_unlink+0x148>
  if(ip->type == T_DIR){
    80004e24:	04491703          	lh	a4,68(s2)
    80004e28:	4785                	li	a5,1
    80004e2a:	0af70263          	beq	a4,a5,80004ece <sys_unlink+0x158>
  iunlockput(dp);
    80004e2e:	8526                	mv	a0,s1
    80004e30:	ecefe0ef          	jal	800034fe <iunlockput>
  ip->nlink--;
    80004e34:	04a95783          	lhu	a5,74(s2)
    80004e38:	37fd                	addiw	a5,a5,-1
    80004e3a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e3e:	854a                	mv	a0,s2
    80004e40:	c00fe0ef          	jal	80003240 <iupdate>
  iunlockput(ip);
    80004e44:	854a                	mv	a0,s2
    80004e46:	eb8fe0ef          	jal	800034fe <iunlockput>
  end_op();
    80004e4a:	dc7fe0ef          	jal	80003c10 <end_op>
  return 0;
    80004e4e:	4501                	li	a0,0
    80004e50:	74ae                	ld	s1,232(sp)
    80004e52:	790e                	ld	s2,224(sp)
    80004e54:	69ee                	ld	s3,216(sp)
    80004e56:	a869                	j	80004ef0 <sys_unlink+0x17a>
    end_op();
    80004e58:	db9fe0ef          	jal	80003c10 <end_op>
    return -1;
    80004e5c:	557d                	li	a0,-1
    80004e5e:	74ae                	ld	s1,232(sp)
    80004e60:	a841                	j	80004ef0 <sys_unlink+0x17a>
    80004e62:	e9d2                	sd	s4,208(sp)
    80004e64:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80004e66:	00002517          	auipc	a0,0x2
    80004e6a:	7d250513          	addi	a0,a0,2002 # 80007638 <etext+0x638>
    80004e6e:	931fb0ef          	jal	8000079e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e72:	04c92703          	lw	a4,76(s2)
    80004e76:	02000793          	li	a5,32
    80004e7a:	f8e7f3e3          	bgeu	a5,a4,80004e00 <sys_unlink+0x8a>
    80004e7e:	e9d2                	sd	s4,208(sp)
    80004e80:	e5d6                	sd	s5,200(sp)
    80004e82:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e84:	f0840a93          	addi	s5,s0,-248
    80004e88:	4a41                	li	s4,16
    80004e8a:	8752                	mv	a4,s4
    80004e8c:	86ce                	mv	a3,s3
    80004e8e:	8656                	mv	a2,s5
    80004e90:	4581                	li	a1,0
    80004e92:	854a                	mv	a0,s2
    80004e94:	eb8fe0ef          	jal	8000354c <readi>
    80004e98:	01451d63          	bne	a0,s4,80004eb2 <sys_unlink+0x13c>
    if(de.inum != 0)
    80004e9c:	f0845783          	lhu	a5,-248(s0)
    80004ea0:	efb1                	bnez	a5,80004efc <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ea2:	29c1                	addiw	s3,s3,16
    80004ea4:	04c92783          	lw	a5,76(s2)
    80004ea8:	fef9e1e3          	bltu	s3,a5,80004e8a <sys_unlink+0x114>
    80004eac:	6a4e                	ld	s4,208(sp)
    80004eae:	6aae                	ld	s5,200(sp)
    80004eb0:	bf81                	j	80004e00 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004eb2:	00002517          	auipc	a0,0x2
    80004eb6:	79e50513          	addi	a0,a0,1950 # 80007650 <etext+0x650>
    80004eba:	8e5fb0ef          	jal	8000079e <panic>
    80004ebe:	e9d2                	sd	s4,208(sp)
    80004ec0:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80004ec2:	00002517          	auipc	a0,0x2
    80004ec6:	7a650513          	addi	a0,a0,1958 # 80007668 <etext+0x668>
    80004eca:	8d5fb0ef          	jal	8000079e <panic>
    dp->nlink--;
    80004ece:	04a4d783          	lhu	a5,74(s1)
    80004ed2:	37fd                	addiw	a5,a5,-1
    80004ed4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ed8:	8526                	mv	a0,s1
    80004eda:	b66fe0ef          	jal	80003240 <iupdate>
    80004ede:	bf81                	j	80004e2e <sys_unlink+0xb8>
    80004ee0:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	e1afe0ef          	jal	800034fe <iunlockput>
  end_op();
    80004ee8:	d29fe0ef          	jal	80003c10 <end_op>
  return -1;
    80004eec:	557d                	li	a0,-1
    80004eee:	74ae                	ld	s1,232(sp)
}
    80004ef0:	70ee                	ld	ra,248(sp)
    80004ef2:	744e                	ld	s0,240(sp)
    80004ef4:	6111                	addi	sp,sp,256
    80004ef6:	8082                	ret
    return -1;
    80004ef8:	557d                	li	a0,-1
    80004efa:	bfdd                	j	80004ef0 <sys_unlink+0x17a>
    iunlockput(ip);
    80004efc:	854a                	mv	a0,s2
    80004efe:	e00fe0ef          	jal	800034fe <iunlockput>
    goto bad;
    80004f02:	790e                	ld	s2,224(sp)
    80004f04:	69ee                	ld	s3,216(sp)
    80004f06:	6a4e                	ld	s4,208(sp)
    80004f08:	6aae                	ld	s5,200(sp)
    80004f0a:	bfe1                	j	80004ee2 <sys_unlink+0x16c>

0000000080004f0c <sys_open>:

uint64
sys_open(void)
{
    80004f0c:	7131                	addi	sp,sp,-192
    80004f0e:	fd06                	sd	ra,184(sp)
    80004f10:	f922                	sd	s0,176(sp)
    80004f12:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f14:	f4c40593          	addi	a1,s0,-180
    80004f18:	4505                	li	a0,1
    80004f1a:	8d5fd0ef          	jal	800027ee <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f1e:	08000613          	li	a2,128
    80004f22:	f5040593          	addi	a1,s0,-176
    80004f26:	4501                	li	a0,0
    80004f28:	8fffd0ef          	jal	80002826 <argstr>
    80004f2c:	87aa                	mv	a5,a0
    return -1;
    80004f2e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f30:	0a07c363          	bltz	a5,80004fd6 <sys_open+0xca>
    80004f34:	f526                	sd	s1,168(sp)

  begin_op();
    80004f36:	c71fe0ef          	jal	80003ba6 <begin_op>

  if(omode & O_CREATE){
    80004f3a:	f4c42783          	lw	a5,-180(s0)
    80004f3e:	2007f793          	andi	a5,a5,512
    80004f42:	c3dd                	beqz	a5,80004fe8 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80004f44:	4681                	li	a3,0
    80004f46:	4601                	li	a2,0
    80004f48:	4589                	li	a1,2
    80004f4a:	f5040513          	addi	a0,s0,-176
    80004f4e:	a99ff0ef          	jal	800049e6 <create>
    80004f52:	84aa                	mv	s1,a0
    if(ip == 0){
    80004f54:	c549                	beqz	a0,80004fde <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004f56:	04449703          	lh	a4,68(s1)
    80004f5a:	478d                	li	a5,3
    80004f5c:	00f71763          	bne	a4,a5,80004f6a <sys_open+0x5e>
    80004f60:	0464d703          	lhu	a4,70(s1)
    80004f64:	47a5                	li	a5,9
    80004f66:	0ae7ee63          	bltu	a5,a4,80005022 <sys_open+0x116>
    80004f6a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f6c:	fb7fe0ef          	jal	80003f22 <filealloc>
    80004f70:	892a                	mv	s2,a0
    80004f72:	c561                	beqz	a0,8000503a <sys_open+0x12e>
    80004f74:	ed4e                	sd	s3,152(sp)
    80004f76:	a33ff0ef          	jal	800049a8 <fdalloc>
    80004f7a:	89aa                	mv	s3,a0
    80004f7c:	0a054b63          	bltz	a0,80005032 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f80:	04449703          	lh	a4,68(s1)
    80004f84:	478d                	li	a5,3
    80004f86:	0cf70363          	beq	a4,a5,8000504c <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004f8a:	4789                	li	a5,2
    80004f8c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004f90:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004f94:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004f98:	f4c42783          	lw	a5,-180(s0)
    80004f9c:	0017f713          	andi	a4,a5,1
    80004fa0:	00174713          	xori	a4,a4,1
    80004fa4:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004fa8:	0037f713          	andi	a4,a5,3
    80004fac:	00e03733          	snez	a4,a4
    80004fb0:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004fb4:	4007f793          	andi	a5,a5,1024
    80004fb8:	c791                	beqz	a5,80004fc4 <sys_open+0xb8>
    80004fba:	04449703          	lh	a4,68(s1)
    80004fbe:	4789                	li	a5,2
    80004fc0:	08f70d63          	beq	a4,a5,8000505a <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	bdcfe0ef          	jal	800033a2 <iunlock>
  end_op();
    80004fca:	c47fe0ef          	jal	80003c10 <end_op>

  return fd;
    80004fce:	854e                	mv	a0,s3
    80004fd0:	74aa                	ld	s1,168(sp)
    80004fd2:	790a                	ld	s2,160(sp)
    80004fd4:	69ea                	ld	s3,152(sp)
}
    80004fd6:	70ea                	ld	ra,184(sp)
    80004fd8:	744a                	ld	s0,176(sp)
    80004fda:	6129                	addi	sp,sp,192
    80004fdc:	8082                	ret
      end_op();
    80004fde:	c33fe0ef          	jal	80003c10 <end_op>
      return -1;
    80004fe2:	557d                	li	a0,-1
    80004fe4:	74aa                	ld	s1,168(sp)
    80004fe6:	bfc5                	j	80004fd6 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80004fe8:	f5040513          	addi	a0,s0,-176
    80004fec:	9f9fe0ef          	jal	800039e4 <namei>
    80004ff0:	84aa                	mv	s1,a0
    80004ff2:	c11d                	beqz	a0,80005018 <sys_open+0x10c>
    ilock(ip);
    80004ff4:	b00fe0ef          	jal	800032f4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004ff8:	04449703          	lh	a4,68(s1)
    80004ffc:	4785                	li	a5,1
    80004ffe:	f4f71ce3          	bne	a4,a5,80004f56 <sys_open+0x4a>
    80005002:	f4c42783          	lw	a5,-180(s0)
    80005006:	d3b5                	beqz	a5,80004f6a <sys_open+0x5e>
      iunlockput(ip);
    80005008:	8526                	mv	a0,s1
    8000500a:	cf4fe0ef          	jal	800034fe <iunlockput>
      end_op();
    8000500e:	c03fe0ef          	jal	80003c10 <end_op>
      return -1;
    80005012:	557d                	li	a0,-1
    80005014:	74aa                	ld	s1,168(sp)
    80005016:	b7c1                	j	80004fd6 <sys_open+0xca>
      end_op();
    80005018:	bf9fe0ef          	jal	80003c10 <end_op>
      return -1;
    8000501c:	557d                	li	a0,-1
    8000501e:	74aa                	ld	s1,168(sp)
    80005020:	bf5d                	j	80004fd6 <sys_open+0xca>
    iunlockput(ip);
    80005022:	8526                	mv	a0,s1
    80005024:	cdafe0ef          	jal	800034fe <iunlockput>
    end_op();
    80005028:	be9fe0ef          	jal	80003c10 <end_op>
    return -1;
    8000502c:	557d                	li	a0,-1
    8000502e:	74aa                	ld	s1,168(sp)
    80005030:	b75d                	j	80004fd6 <sys_open+0xca>
      fileclose(f);
    80005032:	854a                	mv	a0,s2
    80005034:	f93fe0ef          	jal	80003fc6 <fileclose>
    80005038:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000503a:	8526                	mv	a0,s1
    8000503c:	cc2fe0ef          	jal	800034fe <iunlockput>
    end_op();
    80005040:	bd1fe0ef          	jal	80003c10 <end_op>
    return -1;
    80005044:	557d                	li	a0,-1
    80005046:	74aa                	ld	s1,168(sp)
    80005048:	790a                	ld	s2,160(sp)
    8000504a:	b771                	j	80004fd6 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000504c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005050:	04649783          	lh	a5,70(s1)
    80005054:	02f91223          	sh	a5,36(s2)
    80005058:	bf35                	j	80004f94 <sys_open+0x88>
    itrunc(ip);
    8000505a:	8526                	mv	a0,s1
    8000505c:	b86fe0ef          	jal	800033e2 <itrunc>
    80005060:	b795                	j	80004fc4 <sys_open+0xb8>

0000000080005062 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005062:	7175                	addi	sp,sp,-144
    80005064:	e506                	sd	ra,136(sp)
    80005066:	e122                	sd	s0,128(sp)
    80005068:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000506a:	b3dfe0ef          	jal	80003ba6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000506e:	08000613          	li	a2,128
    80005072:	f7040593          	addi	a1,s0,-144
    80005076:	4501                	li	a0,0
    80005078:	faefd0ef          	jal	80002826 <argstr>
    8000507c:	02054363          	bltz	a0,800050a2 <sys_mkdir+0x40>
    80005080:	4681                	li	a3,0
    80005082:	4601                	li	a2,0
    80005084:	4585                	li	a1,1
    80005086:	f7040513          	addi	a0,s0,-144
    8000508a:	95dff0ef          	jal	800049e6 <create>
    8000508e:	c911                	beqz	a0,800050a2 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005090:	c6efe0ef          	jal	800034fe <iunlockput>
  end_op();
    80005094:	b7dfe0ef          	jal	80003c10 <end_op>
  return 0;
    80005098:	4501                	li	a0,0
}
    8000509a:	60aa                	ld	ra,136(sp)
    8000509c:	640a                	ld	s0,128(sp)
    8000509e:	6149                	addi	sp,sp,144
    800050a0:	8082                	ret
    end_op();
    800050a2:	b6ffe0ef          	jal	80003c10 <end_op>
    return -1;
    800050a6:	557d                	li	a0,-1
    800050a8:	bfcd                	j	8000509a <sys_mkdir+0x38>

00000000800050aa <sys_mknod>:

uint64
sys_mknod(void)
{
    800050aa:	7135                	addi	sp,sp,-160
    800050ac:	ed06                	sd	ra,152(sp)
    800050ae:	e922                	sd	s0,144(sp)
    800050b0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800050b2:	af5fe0ef          	jal	80003ba6 <begin_op>
  argint(1, &major);
    800050b6:	f6c40593          	addi	a1,s0,-148
    800050ba:	4505                	li	a0,1
    800050bc:	f32fd0ef          	jal	800027ee <argint>
  argint(2, &minor);
    800050c0:	f6840593          	addi	a1,s0,-152
    800050c4:	4509                	li	a0,2
    800050c6:	f28fd0ef          	jal	800027ee <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050ca:	08000613          	li	a2,128
    800050ce:	f7040593          	addi	a1,s0,-144
    800050d2:	4501                	li	a0,0
    800050d4:	f52fd0ef          	jal	80002826 <argstr>
    800050d8:	02054563          	bltz	a0,80005102 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800050dc:	f6841683          	lh	a3,-152(s0)
    800050e0:	f6c41603          	lh	a2,-148(s0)
    800050e4:	458d                	li	a1,3
    800050e6:	f7040513          	addi	a0,s0,-144
    800050ea:	8fdff0ef          	jal	800049e6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050ee:	c911                	beqz	a0,80005102 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050f0:	c0efe0ef          	jal	800034fe <iunlockput>
  end_op();
    800050f4:	b1dfe0ef          	jal	80003c10 <end_op>
  return 0;
    800050f8:	4501                	li	a0,0
}
    800050fa:	60ea                	ld	ra,152(sp)
    800050fc:	644a                	ld	s0,144(sp)
    800050fe:	610d                	addi	sp,sp,160
    80005100:	8082                	ret
    end_op();
    80005102:	b0ffe0ef          	jal	80003c10 <end_op>
    return -1;
    80005106:	557d                	li	a0,-1
    80005108:	bfcd                	j	800050fa <sys_mknod+0x50>

000000008000510a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000510a:	7135                	addi	sp,sp,-160
    8000510c:	ed06                	sd	ra,152(sp)
    8000510e:	e922                	sd	s0,144(sp)
    80005110:	e14a                	sd	s2,128(sp)
    80005112:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005114:	fc8fc0ef          	jal	800018dc <myproc>
    80005118:	892a                	mv	s2,a0
  
  begin_op();
    8000511a:	a8dfe0ef          	jal	80003ba6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000511e:	08000613          	li	a2,128
    80005122:	f6040593          	addi	a1,s0,-160
    80005126:	4501                	li	a0,0
    80005128:	efefd0ef          	jal	80002826 <argstr>
    8000512c:	04054363          	bltz	a0,80005172 <sys_chdir+0x68>
    80005130:	e526                	sd	s1,136(sp)
    80005132:	f6040513          	addi	a0,s0,-160
    80005136:	8affe0ef          	jal	800039e4 <namei>
    8000513a:	84aa                	mv	s1,a0
    8000513c:	c915                	beqz	a0,80005170 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000513e:	9b6fe0ef          	jal	800032f4 <ilock>
  if(ip->type != T_DIR){
    80005142:	04449703          	lh	a4,68(s1)
    80005146:	4785                	li	a5,1
    80005148:	02f71963          	bne	a4,a5,8000517a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000514c:	8526                	mv	a0,s1
    8000514e:	a54fe0ef          	jal	800033a2 <iunlock>
  iput(p->cwd);
    80005152:	15093503          	ld	a0,336(s2)
    80005156:	b20fe0ef          	jal	80003476 <iput>
  end_op();
    8000515a:	ab7fe0ef          	jal	80003c10 <end_op>
  p->cwd = ip;
    8000515e:	14993823          	sd	s1,336(s2)
  return 0;
    80005162:	4501                	li	a0,0
    80005164:	64aa                	ld	s1,136(sp)
}
    80005166:	60ea                	ld	ra,152(sp)
    80005168:	644a                	ld	s0,144(sp)
    8000516a:	690a                	ld	s2,128(sp)
    8000516c:	610d                	addi	sp,sp,160
    8000516e:	8082                	ret
    80005170:	64aa                	ld	s1,136(sp)
    end_op();
    80005172:	a9ffe0ef          	jal	80003c10 <end_op>
    return -1;
    80005176:	557d                	li	a0,-1
    80005178:	b7fd                	j	80005166 <sys_chdir+0x5c>
    iunlockput(ip);
    8000517a:	8526                	mv	a0,s1
    8000517c:	b82fe0ef          	jal	800034fe <iunlockput>
    end_op();
    80005180:	a91fe0ef          	jal	80003c10 <end_op>
    return -1;
    80005184:	557d                	li	a0,-1
    80005186:	64aa                	ld	s1,136(sp)
    80005188:	bff9                	j	80005166 <sys_chdir+0x5c>

000000008000518a <sys_exec>:

uint64
sys_exec(void)
{
    8000518a:	7105                	addi	sp,sp,-480
    8000518c:	ef86                	sd	ra,472(sp)
    8000518e:	eba2                	sd	s0,464(sp)
    80005190:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005192:	e2840593          	addi	a1,s0,-472
    80005196:	4505                	li	a0,1
    80005198:	e72fd0ef          	jal	8000280a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000519c:	08000613          	li	a2,128
    800051a0:	f3040593          	addi	a1,s0,-208
    800051a4:	4501                	li	a0,0
    800051a6:	e80fd0ef          	jal	80002826 <argstr>
    800051aa:	87aa                	mv	a5,a0
    return -1;
    800051ac:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800051ae:	0e07c063          	bltz	a5,8000528e <sys_exec+0x104>
    800051b2:	e7a6                	sd	s1,456(sp)
    800051b4:	e3ca                	sd	s2,448(sp)
    800051b6:	ff4e                	sd	s3,440(sp)
    800051b8:	fb52                	sd	s4,432(sp)
    800051ba:	f756                	sd	s5,424(sp)
    800051bc:	f35a                	sd	s6,416(sp)
    800051be:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800051c0:	e3040a13          	addi	s4,s0,-464
    800051c4:	10000613          	li	a2,256
    800051c8:	4581                	li	a1,0
    800051ca:	8552                	mv	a0,s4
    800051cc:	b03fb0ef          	jal	80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800051d0:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800051d2:	89d2                	mv	s3,s4
    800051d4:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051d6:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051da:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800051dc:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051e0:	00391513          	slli	a0,s2,0x3
    800051e4:	85d6                	mv	a1,s5
    800051e6:	e2843783          	ld	a5,-472(s0)
    800051ea:	953e                	add	a0,a0,a5
    800051ec:	d78fd0ef          	jal	80002764 <fetchaddr>
    800051f0:	02054663          	bltz	a0,8000521c <sys_exec+0x92>
    if(uarg == 0){
    800051f4:	e2043783          	ld	a5,-480(s0)
    800051f8:	c7a1                	beqz	a5,80005240 <sys_exec+0xb6>
    argv[i] = kalloc();
    800051fa:	931fb0ef          	jal	80000b2a <kalloc>
    800051fe:	85aa                	mv	a1,a0
    80005200:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005204:	cd01                	beqz	a0,8000521c <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005206:	865a                	mv	a2,s6
    80005208:	e2043503          	ld	a0,-480(s0)
    8000520c:	da2fd0ef          	jal	800027ae <fetchstr>
    80005210:	00054663          	bltz	a0,8000521c <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005214:	0905                	addi	s2,s2,1
    80005216:	09a1                	addi	s3,s3,8
    80005218:	fd7914e3          	bne	s2,s7,800051e0 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000521c:	100a0a13          	addi	s4,s4,256
    80005220:	6088                	ld	a0,0(s1)
    80005222:	cd31                	beqz	a0,8000527e <sys_exec+0xf4>
    kfree(argv[i]);
    80005224:	825fb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005228:	04a1                	addi	s1,s1,8
    8000522a:	ff449be3          	bne	s1,s4,80005220 <sys_exec+0x96>
  return -1;
    8000522e:	557d                	li	a0,-1
    80005230:	64be                	ld	s1,456(sp)
    80005232:	691e                	ld	s2,448(sp)
    80005234:	79fa                	ld	s3,440(sp)
    80005236:	7a5a                	ld	s4,432(sp)
    80005238:	7aba                	ld	s5,424(sp)
    8000523a:	7b1a                	ld	s6,416(sp)
    8000523c:	6bfa                	ld	s7,408(sp)
    8000523e:	a881                	j	8000528e <sys_exec+0x104>
      argv[i] = 0;
    80005240:	0009079b          	sext.w	a5,s2
    80005244:	e3040593          	addi	a1,s0,-464
    80005248:	078e                	slli	a5,a5,0x3
    8000524a:	97ae                	add	a5,a5,a1
    8000524c:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80005250:	f3040513          	addi	a0,s0,-208
    80005254:	ba4ff0ef          	jal	800045f8 <exec>
    80005258:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000525a:	100a0a13          	addi	s4,s4,256
    8000525e:	6088                	ld	a0,0(s1)
    80005260:	c511                	beqz	a0,8000526c <sys_exec+0xe2>
    kfree(argv[i]);
    80005262:	fe6fb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005266:	04a1                	addi	s1,s1,8
    80005268:	ff449be3          	bne	s1,s4,8000525e <sys_exec+0xd4>
  return ret;
    8000526c:	854a                	mv	a0,s2
    8000526e:	64be                	ld	s1,456(sp)
    80005270:	691e                	ld	s2,448(sp)
    80005272:	79fa                	ld	s3,440(sp)
    80005274:	7a5a                	ld	s4,432(sp)
    80005276:	7aba                	ld	s5,424(sp)
    80005278:	7b1a                	ld	s6,416(sp)
    8000527a:	6bfa                	ld	s7,408(sp)
    8000527c:	a809                	j	8000528e <sys_exec+0x104>
  return -1;
    8000527e:	557d                	li	a0,-1
    80005280:	64be                	ld	s1,456(sp)
    80005282:	691e                	ld	s2,448(sp)
    80005284:	79fa                	ld	s3,440(sp)
    80005286:	7a5a                	ld	s4,432(sp)
    80005288:	7aba                	ld	s5,424(sp)
    8000528a:	7b1a                	ld	s6,416(sp)
    8000528c:	6bfa                	ld	s7,408(sp)
}
    8000528e:	60fe                	ld	ra,472(sp)
    80005290:	645e                	ld	s0,464(sp)
    80005292:	613d                	addi	sp,sp,480
    80005294:	8082                	ret

0000000080005296 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005296:	7139                	addi	sp,sp,-64
    80005298:	fc06                	sd	ra,56(sp)
    8000529a:	f822                	sd	s0,48(sp)
    8000529c:	f426                	sd	s1,40(sp)
    8000529e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800052a0:	e3cfc0ef          	jal	800018dc <myproc>
    800052a4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800052a6:	fd840593          	addi	a1,s0,-40
    800052aa:	4501                	li	a0,0
    800052ac:	d5efd0ef          	jal	8000280a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800052b0:	fc840593          	addi	a1,s0,-56
    800052b4:	fd040513          	addi	a0,s0,-48
    800052b8:	81eff0ef          	jal	800042d6 <pipealloc>
    return -1;
    800052bc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800052be:	0a054463          	bltz	a0,80005366 <sys_pipe+0xd0>
  fd0 = -1;
    800052c2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800052c6:	fd043503          	ld	a0,-48(s0)
    800052ca:	edeff0ef          	jal	800049a8 <fdalloc>
    800052ce:	fca42223          	sw	a0,-60(s0)
    800052d2:	08054163          	bltz	a0,80005354 <sys_pipe+0xbe>
    800052d6:	fc843503          	ld	a0,-56(s0)
    800052da:	eceff0ef          	jal	800049a8 <fdalloc>
    800052de:	fca42023          	sw	a0,-64(s0)
    800052e2:	06054063          	bltz	a0,80005342 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052e6:	4691                	li	a3,4
    800052e8:	fc440613          	addi	a2,s0,-60
    800052ec:	fd843583          	ld	a1,-40(s0)
    800052f0:	68a8                	ld	a0,80(s1)
    800052f2:	a92fc0ef          	jal	80001584 <copyout>
    800052f6:	00054e63          	bltz	a0,80005312 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800052fa:	4691                	li	a3,4
    800052fc:	fc040613          	addi	a2,s0,-64
    80005300:	fd843583          	ld	a1,-40(s0)
    80005304:	95b6                	add	a1,a1,a3
    80005306:	68a8                	ld	a0,80(s1)
    80005308:	a7cfc0ef          	jal	80001584 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000530c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000530e:	04055c63          	bgez	a0,80005366 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005312:	fc442783          	lw	a5,-60(s0)
    80005316:	07e9                	addi	a5,a5,26
    80005318:	078e                	slli	a5,a5,0x3
    8000531a:	97a6                	add	a5,a5,s1
    8000531c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005320:	fc042783          	lw	a5,-64(s0)
    80005324:	07e9                	addi	a5,a5,26
    80005326:	078e                	slli	a5,a5,0x3
    80005328:	94be                	add	s1,s1,a5
    8000532a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000532e:	fd043503          	ld	a0,-48(s0)
    80005332:	c95fe0ef          	jal	80003fc6 <fileclose>
    fileclose(wf);
    80005336:	fc843503          	ld	a0,-56(s0)
    8000533a:	c8dfe0ef          	jal	80003fc6 <fileclose>
    return -1;
    8000533e:	57fd                	li	a5,-1
    80005340:	a01d                	j	80005366 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005342:	fc442783          	lw	a5,-60(s0)
    80005346:	0007c763          	bltz	a5,80005354 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000534a:	07e9                	addi	a5,a5,26
    8000534c:	078e                	slli	a5,a5,0x3
    8000534e:	97a6                	add	a5,a5,s1
    80005350:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005354:	fd043503          	ld	a0,-48(s0)
    80005358:	c6ffe0ef          	jal	80003fc6 <fileclose>
    fileclose(wf);
    8000535c:	fc843503          	ld	a0,-56(s0)
    80005360:	c67fe0ef          	jal	80003fc6 <fileclose>
    return -1;
    80005364:	57fd                	li	a5,-1
}
    80005366:	853e                	mv	a0,a5
    80005368:	70e2                	ld	ra,56(sp)
    8000536a:	7442                	ld	s0,48(sp)
    8000536c:	74a2                	ld	s1,40(sp)
    8000536e:	6121                	addi	sp,sp,64
    80005370:	8082                	ret
	...

0000000080005380 <kernelvec>:
    80005380:	7111                	addi	sp,sp,-256
    80005382:	e006                	sd	ra,0(sp)
    80005384:	e40a                	sd	sp,8(sp)
    80005386:	e80e                	sd	gp,16(sp)
    80005388:	ec12                	sd	tp,24(sp)
    8000538a:	f016                	sd	t0,32(sp)
    8000538c:	f41a                	sd	t1,40(sp)
    8000538e:	f81e                	sd	t2,48(sp)
    80005390:	e4aa                	sd	a0,72(sp)
    80005392:	e8ae                	sd	a1,80(sp)
    80005394:	ecb2                	sd	a2,88(sp)
    80005396:	f0b6                	sd	a3,96(sp)
    80005398:	f4ba                	sd	a4,104(sp)
    8000539a:	f8be                	sd	a5,112(sp)
    8000539c:	fcc2                	sd	a6,120(sp)
    8000539e:	e146                	sd	a7,128(sp)
    800053a0:	edf2                	sd	t3,216(sp)
    800053a2:	f1f6                	sd	t4,224(sp)
    800053a4:	f5fa                	sd	t5,232(sp)
    800053a6:	f9fe                	sd	t6,240(sp)
    800053a8:	accfd0ef          	jal	80002674 <kerneltrap>
    800053ac:	6082                	ld	ra,0(sp)
    800053ae:	6122                	ld	sp,8(sp)
    800053b0:	61c2                	ld	gp,16(sp)
    800053b2:	7282                	ld	t0,32(sp)
    800053b4:	7322                	ld	t1,40(sp)
    800053b6:	73c2                	ld	t2,48(sp)
    800053b8:	6526                	ld	a0,72(sp)
    800053ba:	65c6                	ld	a1,80(sp)
    800053bc:	6666                	ld	a2,88(sp)
    800053be:	7686                	ld	a3,96(sp)
    800053c0:	7726                	ld	a4,104(sp)
    800053c2:	77c6                	ld	a5,112(sp)
    800053c4:	7866                	ld	a6,120(sp)
    800053c6:	688a                	ld	a7,128(sp)
    800053c8:	6e6e                	ld	t3,216(sp)
    800053ca:	7e8e                	ld	t4,224(sp)
    800053cc:	7f2e                	ld	t5,232(sp)
    800053ce:	7fce                	ld	t6,240(sp)
    800053d0:	6111                	addi	sp,sp,256
    800053d2:	10200073          	sret
	...

00000000800053de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053de:	1141                	addi	sp,sp,-16
    800053e0:	e406                	sd	ra,8(sp)
    800053e2:	e022                	sd	s0,0(sp)
    800053e4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800053e6:	0c000737          	lui	a4,0xc000
    800053ea:	4785                	li	a5,1
    800053ec:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800053ee:	c35c                	sw	a5,4(a4)
}
    800053f0:	60a2                	ld	ra,8(sp)
    800053f2:	6402                	ld	s0,0(sp)
    800053f4:	0141                	addi	sp,sp,16
    800053f6:	8082                	ret

00000000800053f8 <plicinithart>:

void
plicinithart(void)
{
    800053f8:	1141                	addi	sp,sp,-16
    800053fa:	e406                	sd	ra,8(sp)
    800053fc:	e022                	sd	s0,0(sp)
    800053fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005400:	ca8fc0ef          	jal	800018a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005404:	0085171b          	slliw	a4,a0,0x8
    80005408:	0c0027b7          	lui	a5,0xc002
    8000540c:	97ba                	add	a5,a5,a4
    8000540e:	40200713          	li	a4,1026
    80005412:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005416:	00d5151b          	slliw	a0,a0,0xd
    8000541a:	0c2017b7          	lui	a5,0xc201
    8000541e:	97aa                	add	a5,a5,a0
    80005420:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005424:	60a2                	ld	ra,8(sp)
    80005426:	6402                	ld	s0,0(sp)
    80005428:	0141                	addi	sp,sp,16
    8000542a:	8082                	ret

000000008000542c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000542c:	1141                	addi	sp,sp,-16
    8000542e:	e406                	sd	ra,8(sp)
    80005430:	e022                	sd	s0,0(sp)
    80005432:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005434:	c74fc0ef          	jal	800018a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005438:	00d5151b          	slliw	a0,a0,0xd
    8000543c:	0c2017b7          	lui	a5,0xc201
    80005440:	97aa                	add	a5,a5,a0
  return irq;
}
    80005442:	43c8                	lw	a0,4(a5)
    80005444:	60a2                	ld	ra,8(sp)
    80005446:	6402                	ld	s0,0(sp)
    80005448:	0141                	addi	sp,sp,16
    8000544a:	8082                	ret

000000008000544c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000544c:	1101                	addi	sp,sp,-32
    8000544e:	ec06                	sd	ra,24(sp)
    80005450:	e822                	sd	s0,16(sp)
    80005452:	e426                	sd	s1,8(sp)
    80005454:	1000                	addi	s0,sp,32
    80005456:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005458:	c50fc0ef          	jal	800018a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000545c:	00d5179b          	slliw	a5,a0,0xd
    80005460:	0c201737          	lui	a4,0xc201
    80005464:	97ba                	add	a5,a5,a4
    80005466:	c3c4                	sw	s1,4(a5)
}
    80005468:	60e2                	ld	ra,24(sp)
    8000546a:	6442                	ld	s0,16(sp)
    8000546c:	64a2                	ld	s1,8(sp)
    8000546e:	6105                	addi	sp,sp,32
    80005470:	8082                	ret

0000000080005472 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005472:	1141                	addi	sp,sp,-16
    80005474:	e406                	sd	ra,8(sp)
    80005476:	e022                	sd	s0,0(sp)
    80005478:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000547a:	479d                	li	a5,7
    8000547c:	04a7ca63          	blt	a5,a0,800054d0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005480:	0001f797          	auipc	a5,0x1f
    80005484:	99878793          	addi	a5,a5,-1640 # 80023e18 <disk>
    80005488:	97aa                	add	a5,a5,a0
    8000548a:	0187c783          	lbu	a5,24(a5)
    8000548e:	e7b9                	bnez	a5,800054dc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005490:	00451693          	slli	a3,a0,0x4
    80005494:	0001f797          	auipc	a5,0x1f
    80005498:	98478793          	addi	a5,a5,-1660 # 80023e18 <disk>
    8000549c:	6398                	ld	a4,0(a5)
    8000549e:	9736                	add	a4,a4,a3
    800054a0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800054a4:	6398                	ld	a4,0(a5)
    800054a6:	9736                	add	a4,a4,a3
    800054a8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800054ac:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800054b0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800054b4:	97aa                	add	a5,a5,a0
    800054b6:	4705                	li	a4,1
    800054b8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800054bc:	0001f517          	auipc	a0,0x1f
    800054c0:	97450513          	addi	a0,a0,-1676 # 80023e30 <disk+0x18>
    800054c4:	a53fc0ef          	jal	80001f16 <wakeup>
}
    800054c8:	60a2                	ld	ra,8(sp)
    800054ca:	6402                	ld	s0,0(sp)
    800054cc:	0141                	addi	sp,sp,16
    800054ce:	8082                	ret
    panic("free_desc 1");
    800054d0:	00002517          	auipc	a0,0x2
    800054d4:	1a850513          	addi	a0,a0,424 # 80007678 <etext+0x678>
    800054d8:	ac6fb0ef          	jal	8000079e <panic>
    panic("free_desc 2");
    800054dc:	00002517          	auipc	a0,0x2
    800054e0:	1ac50513          	addi	a0,a0,428 # 80007688 <etext+0x688>
    800054e4:	abafb0ef          	jal	8000079e <panic>

00000000800054e8 <virtio_disk_init>:
{
    800054e8:	1101                	addi	sp,sp,-32
    800054ea:	ec06                	sd	ra,24(sp)
    800054ec:	e822                	sd	s0,16(sp)
    800054ee:	e426                	sd	s1,8(sp)
    800054f0:	e04a                	sd	s2,0(sp)
    800054f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800054f4:	00002597          	auipc	a1,0x2
    800054f8:	1a458593          	addi	a1,a1,420 # 80007698 <etext+0x698>
    800054fc:	0001f517          	auipc	a0,0x1f
    80005500:	a4450513          	addi	a0,a0,-1468 # 80023f40 <disk+0x128>
    80005504:	e76fb0ef          	jal	80000b7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005508:	100017b7          	lui	a5,0x10001
    8000550c:	4398                	lw	a4,0(a5)
    8000550e:	2701                	sext.w	a4,a4
    80005510:	747277b7          	lui	a5,0x74727
    80005514:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005518:	14f71863          	bne	a4,a5,80005668 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000551c:	100017b7          	lui	a5,0x10001
    80005520:	43dc                	lw	a5,4(a5)
    80005522:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005524:	4709                	li	a4,2
    80005526:	14e79163          	bne	a5,a4,80005668 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000552a:	100017b7          	lui	a5,0x10001
    8000552e:	479c                	lw	a5,8(a5)
    80005530:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005532:	12e79b63          	bne	a5,a4,80005668 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005536:	100017b7          	lui	a5,0x10001
    8000553a:	47d8                	lw	a4,12(a5)
    8000553c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000553e:	554d47b7          	lui	a5,0x554d4
    80005542:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005546:	12f71163          	bne	a4,a5,80005668 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000554a:	100017b7          	lui	a5,0x10001
    8000554e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005552:	4705                	li	a4,1
    80005554:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005556:	470d                	li	a4,3
    80005558:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000555a:	10001737          	lui	a4,0x10001
    8000555e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005560:	c7ffe6b7          	lui	a3,0xc7ffe
    80005564:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fda807>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005568:	8f75                	and	a4,a4,a3
    8000556a:	100016b7          	lui	a3,0x10001
    8000556e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005570:	472d                	li	a4,11
    80005572:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005574:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005578:	439c                	lw	a5,0(a5)
    8000557a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000557e:	8ba1                	andi	a5,a5,8
    80005580:	0e078a63          	beqz	a5,80005674 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005584:	100017b7          	lui	a5,0x10001
    80005588:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000558c:	43fc                	lw	a5,68(a5)
    8000558e:	2781                	sext.w	a5,a5
    80005590:	0e079863          	bnez	a5,80005680 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005594:	100017b7          	lui	a5,0x10001
    80005598:	5bdc                	lw	a5,52(a5)
    8000559a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000559c:	0e078863          	beqz	a5,8000568c <virtio_disk_init+0x1a4>
  if(max < NUM)
    800055a0:	471d                	li	a4,7
    800055a2:	0ef77b63          	bgeu	a4,a5,80005698 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800055a6:	d84fb0ef          	jal	80000b2a <kalloc>
    800055aa:	0001f497          	auipc	s1,0x1f
    800055ae:	86e48493          	addi	s1,s1,-1938 # 80023e18 <disk>
    800055b2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800055b4:	d76fb0ef          	jal	80000b2a <kalloc>
    800055b8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800055ba:	d70fb0ef          	jal	80000b2a <kalloc>
    800055be:	87aa                	mv	a5,a0
    800055c0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800055c2:	6088                	ld	a0,0(s1)
    800055c4:	0e050063          	beqz	a0,800056a4 <virtio_disk_init+0x1bc>
    800055c8:	0001f717          	auipc	a4,0x1f
    800055cc:	85873703          	ld	a4,-1960(a4) # 80023e20 <disk+0x8>
    800055d0:	cb71                	beqz	a4,800056a4 <virtio_disk_init+0x1bc>
    800055d2:	cbe9                	beqz	a5,800056a4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800055d4:	6605                	lui	a2,0x1
    800055d6:	4581                	li	a1,0
    800055d8:	ef6fb0ef          	jal	80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    800055dc:	0001f497          	auipc	s1,0x1f
    800055e0:	83c48493          	addi	s1,s1,-1988 # 80023e18 <disk>
    800055e4:	6605                	lui	a2,0x1
    800055e6:	4581                	li	a1,0
    800055e8:	6488                	ld	a0,8(s1)
    800055ea:	ee4fb0ef          	jal	80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    800055ee:	6605                	lui	a2,0x1
    800055f0:	4581                	li	a1,0
    800055f2:	6888                	ld	a0,16(s1)
    800055f4:	edafb0ef          	jal	80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800055f8:	100017b7          	lui	a5,0x10001
    800055fc:	4721                	li	a4,8
    800055fe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005600:	4098                	lw	a4,0(s1)
    80005602:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005606:	40d8                	lw	a4,4(s1)
    80005608:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000560c:	649c                	ld	a5,8(s1)
    8000560e:	0007869b          	sext.w	a3,a5
    80005612:	10001737          	lui	a4,0x10001
    80005616:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000561a:	9781                	srai	a5,a5,0x20
    8000561c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005620:	689c                	ld	a5,16(s1)
    80005622:	0007869b          	sext.w	a3,a5
    80005626:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000562a:	9781                	srai	a5,a5,0x20
    8000562c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005630:	4785                	li	a5,1
    80005632:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005634:	00f48c23          	sb	a5,24(s1)
    80005638:	00f48ca3          	sb	a5,25(s1)
    8000563c:	00f48d23          	sb	a5,26(s1)
    80005640:	00f48da3          	sb	a5,27(s1)
    80005644:	00f48e23          	sb	a5,28(s1)
    80005648:	00f48ea3          	sb	a5,29(s1)
    8000564c:	00f48f23          	sb	a5,30(s1)
    80005650:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005654:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005658:	07272823          	sw	s2,112(a4)
}
    8000565c:	60e2                	ld	ra,24(sp)
    8000565e:	6442                	ld	s0,16(sp)
    80005660:	64a2                	ld	s1,8(sp)
    80005662:	6902                	ld	s2,0(sp)
    80005664:	6105                	addi	sp,sp,32
    80005666:	8082                	ret
    panic("could not find virtio disk");
    80005668:	00002517          	auipc	a0,0x2
    8000566c:	04050513          	addi	a0,a0,64 # 800076a8 <etext+0x6a8>
    80005670:	92efb0ef          	jal	8000079e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005674:	00002517          	auipc	a0,0x2
    80005678:	05450513          	addi	a0,a0,84 # 800076c8 <etext+0x6c8>
    8000567c:	922fb0ef          	jal	8000079e <panic>
    panic("virtio disk should not be ready");
    80005680:	00002517          	auipc	a0,0x2
    80005684:	06850513          	addi	a0,a0,104 # 800076e8 <etext+0x6e8>
    80005688:	916fb0ef          	jal	8000079e <panic>
    panic("virtio disk has no queue 0");
    8000568c:	00002517          	auipc	a0,0x2
    80005690:	07c50513          	addi	a0,a0,124 # 80007708 <etext+0x708>
    80005694:	90afb0ef          	jal	8000079e <panic>
    panic("virtio disk max queue too short");
    80005698:	00002517          	auipc	a0,0x2
    8000569c:	09050513          	addi	a0,a0,144 # 80007728 <etext+0x728>
    800056a0:	8fefb0ef          	jal	8000079e <panic>
    panic("virtio disk kalloc");
    800056a4:	00002517          	auipc	a0,0x2
    800056a8:	0a450513          	addi	a0,a0,164 # 80007748 <etext+0x748>
    800056ac:	8f2fb0ef          	jal	8000079e <panic>

00000000800056b0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800056b0:	711d                	addi	sp,sp,-96
    800056b2:	ec86                	sd	ra,88(sp)
    800056b4:	e8a2                	sd	s0,80(sp)
    800056b6:	e4a6                	sd	s1,72(sp)
    800056b8:	e0ca                	sd	s2,64(sp)
    800056ba:	fc4e                	sd	s3,56(sp)
    800056bc:	f852                	sd	s4,48(sp)
    800056be:	f456                	sd	s5,40(sp)
    800056c0:	f05a                	sd	s6,32(sp)
    800056c2:	ec5e                	sd	s7,24(sp)
    800056c4:	e862                	sd	s8,16(sp)
    800056c6:	1080                	addi	s0,sp,96
    800056c8:	89aa                	mv	s3,a0
    800056ca:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800056cc:	00c52b83          	lw	s7,12(a0)
    800056d0:	001b9b9b          	slliw	s7,s7,0x1
    800056d4:	1b82                	slli	s7,s7,0x20
    800056d6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800056da:	0001f517          	auipc	a0,0x1f
    800056de:	86650513          	addi	a0,a0,-1946 # 80023f40 <disk+0x128>
    800056e2:	d1cfb0ef          	jal	80000bfe <acquire>
  for(int i = 0; i < NUM; i++){
    800056e6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056e8:	0001ea97          	auipc	s5,0x1e
    800056ec:	730a8a93          	addi	s5,s5,1840 # 80023e18 <disk>
  for(int i = 0; i < 3; i++){
    800056f0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800056f2:	5c7d                	li	s8,-1
    800056f4:	a095                	j	80005758 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800056f6:	00fa8733          	add	a4,s5,a5
    800056fa:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800056fe:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005700:	0207c563          	bltz	a5,8000572a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005704:	2905                	addiw	s2,s2,1
    80005706:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005708:	05490c63          	beq	s2,s4,80005760 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000570c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000570e:	0001e717          	auipc	a4,0x1e
    80005712:	70a70713          	addi	a4,a4,1802 # 80023e18 <disk>
    80005716:	4781                	li	a5,0
    if(disk.free[i]){
    80005718:	01874683          	lbu	a3,24(a4)
    8000571c:	fee9                	bnez	a3,800056f6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000571e:	2785                	addiw	a5,a5,1
    80005720:	0705                	addi	a4,a4,1
    80005722:	fe979be3          	bne	a5,s1,80005718 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005726:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000572a:	01205d63          	blez	s2,80005744 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000572e:	fa042503          	lw	a0,-96(s0)
    80005732:	d41ff0ef          	jal	80005472 <free_desc>
      for(int j = 0; j < i; j++)
    80005736:	4785                	li	a5,1
    80005738:	0127d663          	bge	a5,s2,80005744 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000573c:	fa442503          	lw	a0,-92(s0)
    80005740:	d33ff0ef          	jal	80005472 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005744:	0001e597          	auipc	a1,0x1e
    80005748:	7fc58593          	addi	a1,a1,2044 # 80023f40 <disk+0x128>
    8000574c:	0001e517          	auipc	a0,0x1e
    80005750:	6e450513          	addi	a0,a0,1764 # 80023e30 <disk+0x18>
    80005754:	f76fc0ef          	jal	80001eca <sleep>
  for(int i = 0; i < 3; i++){
    80005758:	fa040613          	addi	a2,s0,-96
    8000575c:	4901                	li	s2,0
    8000575e:	b77d                	j	8000570c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005760:	fa042503          	lw	a0,-96(s0)
    80005764:	00451693          	slli	a3,a0,0x4

  if(write)
    80005768:	0001e797          	auipc	a5,0x1e
    8000576c:	6b078793          	addi	a5,a5,1712 # 80023e18 <disk>
    80005770:	00a50713          	addi	a4,a0,10
    80005774:	0712                	slli	a4,a4,0x4
    80005776:	973e                	add	a4,a4,a5
    80005778:	01603633          	snez	a2,s6
    8000577c:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000577e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005782:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005786:	6398                	ld	a4,0(a5)
    80005788:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000578a:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    8000578e:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005790:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005792:	6390                	ld	a2,0(a5)
    80005794:	00d605b3          	add	a1,a2,a3
    80005798:	4741                	li	a4,16
    8000579a:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000579c:	4805                	li	a6,1
    8000579e:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800057a2:	fa442703          	lw	a4,-92(s0)
    800057a6:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800057aa:	0712                	slli	a4,a4,0x4
    800057ac:	963a                	add	a2,a2,a4
    800057ae:	05898593          	addi	a1,s3,88
    800057b2:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800057b4:	0007b883          	ld	a7,0(a5)
    800057b8:	9746                	add	a4,a4,a7
    800057ba:	40000613          	li	a2,1024
    800057be:	c710                	sw	a2,8(a4)
  if(write)
    800057c0:	001b3613          	seqz	a2,s6
    800057c4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800057c8:	01066633          	or	a2,a2,a6
    800057cc:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800057d0:	fa842583          	lw	a1,-88(s0)
    800057d4:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800057d8:	00250613          	addi	a2,a0,2
    800057dc:	0612                	slli	a2,a2,0x4
    800057de:	963e                	add	a2,a2,a5
    800057e0:	577d                	li	a4,-1
    800057e2:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057e6:	0592                	slli	a1,a1,0x4
    800057e8:	98ae                	add	a7,a7,a1
    800057ea:	03068713          	addi	a4,a3,48
    800057ee:	973e                	add	a4,a4,a5
    800057f0:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800057f4:	6398                	ld	a4,0(a5)
    800057f6:	972e                	add	a4,a4,a1
    800057f8:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057fc:	4689                	li	a3,2
    800057fe:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005802:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005806:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    8000580a:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000580e:	6794                	ld	a3,8(a5)
    80005810:	0026d703          	lhu	a4,2(a3)
    80005814:	8b1d                	andi	a4,a4,7
    80005816:	0706                	slli	a4,a4,0x1
    80005818:	96ba                	add	a3,a3,a4
    8000581a:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000581e:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005822:	6798                	ld	a4,8(a5)
    80005824:	00275783          	lhu	a5,2(a4)
    80005828:	2785                	addiw	a5,a5,1
    8000582a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000582e:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005832:	100017b7          	lui	a5,0x10001
    80005836:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000583a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    8000583e:	0001e917          	auipc	s2,0x1e
    80005842:	70290913          	addi	s2,s2,1794 # 80023f40 <disk+0x128>
  while(b->disk == 1) {
    80005846:	84c2                	mv	s1,a6
    80005848:	01079a63          	bne	a5,a6,8000585c <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    8000584c:	85ca                	mv	a1,s2
    8000584e:	854e                	mv	a0,s3
    80005850:	e7afc0ef          	jal	80001eca <sleep>
  while(b->disk == 1) {
    80005854:	0049a783          	lw	a5,4(s3)
    80005858:	fe978ae3          	beq	a5,s1,8000584c <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    8000585c:	fa042903          	lw	s2,-96(s0)
    80005860:	00290713          	addi	a4,s2,2
    80005864:	0712                	slli	a4,a4,0x4
    80005866:	0001e797          	auipc	a5,0x1e
    8000586a:	5b278793          	addi	a5,a5,1458 # 80023e18 <disk>
    8000586e:	97ba                	add	a5,a5,a4
    80005870:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005874:	0001e997          	auipc	s3,0x1e
    80005878:	5a498993          	addi	s3,s3,1444 # 80023e18 <disk>
    8000587c:	00491713          	slli	a4,s2,0x4
    80005880:	0009b783          	ld	a5,0(s3)
    80005884:	97ba                	add	a5,a5,a4
    80005886:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000588a:	854a                	mv	a0,s2
    8000588c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005890:	be3ff0ef          	jal	80005472 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005894:	8885                	andi	s1,s1,1
    80005896:	f0fd                	bnez	s1,8000587c <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005898:	0001e517          	auipc	a0,0x1e
    8000589c:	6a850513          	addi	a0,a0,1704 # 80023f40 <disk+0x128>
    800058a0:	bf2fb0ef          	jal	80000c92 <release>
}
    800058a4:	60e6                	ld	ra,88(sp)
    800058a6:	6446                	ld	s0,80(sp)
    800058a8:	64a6                	ld	s1,72(sp)
    800058aa:	6906                	ld	s2,64(sp)
    800058ac:	79e2                	ld	s3,56(sp)
    800058ae:	7a42                	ld	s4,48(sp)
    800058b0:	7aa2                	ld	s5,40(sp)
    800058b2:	7b02                	ld	s6,32(sp)
    800058b4:	6be2                	ld	s7,24(sp)
    800058b6:	6c42                	ld	s8,16(sp)
    800058b8:	6125                	addi	sp,sp,96
    800058ba:	8082                	ret

00000000800058bc <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800058bc:	1101                	addi	sp,sp,-32
    800058be:	ec06                	sd	ra,24(sp)
    800058c0:	e822                	sd	s0,16(sp)
    800058c2:	e426                	sd	s1,8(sp)
    800058c4:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800058c6:	0001e497          	auipc	s1,0x1e
    800058ca:	55248493          	addi	s1,s1,1362 # 80023e18 <disk>
    800058ce:	0001e517          	auipc	a0,0x1e
    800058d2:	67250513          	addi	a0,a0,1650 # 80023f40 <disk+0x128>
    800058d6:	b28fb0ef          	jal	80000bfe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058da:	100017b7          	lui	a5,0x10001
    800058de:	53bc                	lw	a5,96(a5)
    800058e0:	8b8d                	andi	a5,a5,3
    800058e2:	10001737          	lui	a4,0x10001
    800058e6:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800058e8:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058ec:	689c                	ld	a5,16(s1)
    800058ee:	0204d703          	lhu	a4,32(s1)
    800058f2:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800058f6:	04f70663          	beq	a4,a5,80005942 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800058fa:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058fe:	6898                	ld	a4,16(s1)
    80005900:	0204d783          	lhu	a5,32(s1)
    80005904:	8b9d                	andi	a5,a5,7
    80005906:	078e                	slli	a5,a5,0x3
    80005908:	97ba                	add	a5,a5,a4
    8000590a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000590c:	00278713          	addi	a4,a5,2
    80005910:	0712                	slli	a4,a4,0x4
    80005912:	9726                	add	a4,a4,s1
    80005914:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005918:	e321                	bnez	a4,80005958 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000591a:	0789                	addi	a5,a5,2
    8000591c:	0792                	slli	a5,a5,0x4
    8000591e:	97a6                	add	a5,a5,s1
    80005920:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005922:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005926:	df0fc0ef          	jal	80001f16 <wakeup>

    disk.used_idx += 1;
    8000592a:	0204d783          	lhu	a5,32(s1)
    8000592e:	2785                	addiw	a5,a5,1
    80005930:	17c2                	slli	a5,a5,0x30
    80005932:	93c1                	srli	a5,a5,0x30
    80005934:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005938:	6898                	ld	a4,16(s1)
    8000593a:	00275703          	lhu	a4,2(a4)
    8000593e:	faf71ee3          	bne	a4,a5,800058fa <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005942:	0001e517          	auipc	a0,0x1e
    80005946:	5fe50513          	addi	a0,a0,1534 # 80023f40 <disk+0x128>
    8000594a:	b48fb0ef          	jal	80000c92 <release>
}
    8000594e:	60e2                	ld	ra,24(sp)
    80005950:	6442                	ld	s0,16(sp)
    80005952:	64a2                	ld	s1,8(sp)
    80005954:	6105                	addi	sp,sp,32
    80005956:	8082                	ret
      panic("virtio_disk_intr status");
    80005958:	00002517          	auipc	a0,0x2
    8000595c:	e0850513          	addi	a0,a0,-504 # 80007760 <etext+0x760>
    80005960:	e3ffa0ef          	jal	8000079e <panic>
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
