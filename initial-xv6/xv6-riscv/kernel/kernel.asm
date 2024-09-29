
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	2b013103          	ld	sp,688(sp) # 8000a2b0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd81bf>
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
    80000106:	16e020ef          	jal	80002274 <either_copyin>
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
    8000016a:	1aa50513          	addi	a0,a0,426 # 80012310 <cons>
    8000016e:	291000ef          	jal	80000bfe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000172:	00012497          	auipc	s1,0x12
    80000176:	19e48493          	addi	s1,s1,414 # 80012310 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000017a:	00012917          	auipc	s2,0x12
    8000017e:	22e90913          	addi	s2,s2,558 # 800123a8 <cons+0x98>
  while(n > 0){
    80000182:	0b305b63          	blez	s3,80000238 <consoleread+0xee>
    while(cons.r == cons.w){
    80000186:	0984a783          	lw	a5,152(s1)
    8000018a:	09c4a703          	lw	a4,156(s1)
    8000018e:	0af71063          	bne	a4,a5,8000022e <consoleread+0xe4>
      if(killed(myproc())){
    80000192:	74a010ef          	jal	800018dc <myproc>
    80000196:	777010ef          	jal	8000210c <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	535010ef          	jal	80001ed4 <sleep>
    while(cons.r == cons.w){
    800001a4:	0984a783          	lw	a5,152(s1)
    800001a8:	09c4a703          	lw	a4,156(s1)
    800001ac:	fef703e3          	beq	a4,a5,80000192 <consoleread+0x48>
    800001b0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001b2:	00012717          	auipc	a4,0x12
    800001b6:	15e70713          	addi	a4,a4,350 # 80012310 <cons>
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
    800001e4:	046020ef          	jal	8000222a <either_copyout>
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
    80000200:	11450513          	addi	a0,a0,276 # 80012310 <cons>
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
    80000226:	18f72323          	sw	a5,390(a4) # 800123a8 <cons+0x98>
    8000022a:	6be2                	ld	s7,24(sp)
    8000022c:	a031                	j	80000238 <consoleread+0xee>
    8000022e:	ec5e                	sd	s7,24(sp)
    80000230:	b749                	j	800001b2 <consoleread+0x68>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	a011                	j	80000238 <consoleread+0xee>
    80000236:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	0d850513          	addi	a0,a0,216 # 80012310 <cons>
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
    80000290:	08450513          	addi	a0,a0,132 # 80012310 <cons>
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
    800002ae:	010020ef          	jal	800022be <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002b2:	00012517          	auipc	a0,0x12
    800002b6:	05e50513          	addi	a0,a0,94 # 80012310 <cons>
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
    800002d4:	04070713          	addi	a4,a4,64 # 80012310 <cons>
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
    800002fa:	01a78793          	addi	a5,a5,26 # 80012310 <cons>
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
    80000326:	0867a783          	lw	a5,134(a5) # 800123a8 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f8f711e3          	bne	a4,a5,800002b2 <consoleintr+0x32>
    80000334:	a85d                	j	800003ea <consoleintr+0x16a>
    80000336:	e84a                	sd	s2,16(sp)
    80000338:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    8000033a:	00012717          	auipc	a4,0x12
    8000033e:	fd670713          	addi	a4,a4,-42 # 80012310 <cons>
    80000342:	0a072783          	lw	a5,160(a4)
    80000346:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	00012497          	auipc	s1,0x12
    8000034e:	fc648493          	addi	s1,s1,-58 # 80012310 <cons>
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
    80000398:	f7c70713          	addi	a4,a4,-132 # 80012310 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
    800003a4:	f0f707e3          	beq	a4,a5,800002b2 <consoleintr+0x32>
      cons.e--;
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	00012717          	auipc	a4,0x12
    800003ae:	00f72323          	sw	a5,6(a4) # 800123b0 <cons+0xa0>
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
    800003cc:	f4878793          	addi	a5,a5,-184 # 80012310 <cons>
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
    800003ee:	fcc7a123          	sw	a2,-62(a5) # 800123ac <cons+0x9c>
        wakeup(&cons.r);
    800003f2:	00012517          	auipc	a0,0x12
    800003f6:	fb650513          	addi	a0,a0,-74 # 800123a8 <cons+0x98>
    800003fa:	327010ef          	jal	80001f20 <wakeup>
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
    80000414:	f0050513          	addi	a0,a0,-256 # 80012310 <cons>
    80000418:	762000ef          	jal	80000b7a <initlock>

  uartinit();
    8000041c:	3ea000ef          	jal	80000806 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000420:	00025797          	auipc	a5,0x25
    80000424:	08878793          	addi	a5,a5,136 # 800254a8 <devsw>
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
    80000464:	31080813          	addi	a6,a6,784 # 80007770 <digits>
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
    800004f0:	ee47a783          	lw	a5,-284(a5) # 800123d0 <pr+0x18>
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
    8000053c:	e8050513          	addi	a0,a0,-384 # 800123b8 <pr>
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
    800006fa:	07ab8b93          	addi	s7,s7,122 # 80007770 <digits>
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
    80000794:	c2850513          	addi	a0,a0,-984 # 800123b8 <pr>
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
    800007ae:	c207a323          	sw	zero,-986(a5) # 800123d0 <pr+0x18>
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
    800007d2:	b0f72123          	sw	a5,-1278(a4) # 8000a2d0 <panicked>
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
    800007e6:	bd648493          	addi	s1,s1,-1066 # 800123b8 <pr>
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
    8000084c:	b9050513          	addi	a0,a0,-1136 # 800123d8 <uart_tx_lock>
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
    80000870:	a647a783          	lw	a5,-1436(a5) # 8000a2d0 <panicked>
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
    800008a6:	a367b783          	ld	a5,-1482(a5) # 8000a2d8 <uart_tx_r>
    800008aa:	0000a717          	auipc	a4,0xa
    800008ae:	a3673703          	ld	a4,-1482(a4) # 8000a2e0 <uart_tx_w>
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
    800008d4:	b08a8a93          	addi	s5,s5,-1272 # 800123d8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d8:	0000a497          	auipc	s1,0xa
    800008dc:	a0048493          	addi	s1,s1,-1536 # 8000a2d8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008e0:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e4:	0000a997          	auipc	s3,0xa
    800008e8:	9fc98993          	addi	s3,s3,-1540 # 8000a2e0 <uart_tx_w>
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
    80000906:	61a010ef          	jal	80001f20 <wakeup>
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
    80000954:	a8850513          	addi	a0,a0,-1400 # 800123d8 <uart_tx_lock>
    80000958:	2a6000ef          	jal	80000bfe <acquire>
  if(panicked){
    8000095c:	0000a797          	auipc	a5,0xa
    80000960:	9747a783          	lw	a5,-1676(a5) # 8000a2d0 <panicked>
    80000964:	efbd                	bnez	a5,800009e2 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000966:	0000a717          	auipc	a4,0xa
    8000096a:	97a73703          	ld	a4,-1670(a4) # 8000a2e0 <uart_tx_w>
    8000096e:	0000a797          	auipc	a5,0xa
    80000972:	96a7b783          	ld	a5,-1686(a5) # 8000a2d8 <uart_tx_r>
    80000976:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	00012997          	auipc	s3,0x12
    8000097e:	a5e98993          	addi	s3,s3,-1442 # 800123d8 <uart_tx_lock>
    80000982:	0000a497          	auipc	s1,0xa
    80000986:	95648493          	addi	s1,s1,-1706 # 8000a2d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000098a:	0000a917          	auipc	s2,0xa
    8000098e:	95690913          	addi	s2,s2,-1706 # 8000a2e0 <uart_tx_w>
    80000992:	00e79d63          	bne	a5,a4,800009ac <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000996:	85ce                	mv	a1,s3
    80000998:	8526                	mv	a0,s1
    8000099a:	53a010ef          	jal	80001ed4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099e:	00093703          	ld	a4,0(s2)
    800009a2:	609c                	ld	a5,0(s1)
    800009a4:	02078793          	addi	a5,a5,32
    800009a8:	fee787e3          	beq	a5,a4,80000996 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009ac:	00012497          	auipc	s1,0x12
    800009b0:	a2c48493          	addi	s1,s1,-1492 # 800123d8 <uart_tx_lock>
    800009b4:	01f77793          	andi	a5,a4,31
    800009b8:	97a6                	add	a5,a5,s1
    800009ba:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009be:	0705                	addi	a4,a4,1
    800009c0:	0000a797          	auipc	a5,0xa
    800009c4:	92e7b023          	sd	a4,-1760(a5) # 8000a2e0 <uart_tx_w>
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
    80000a2a:	9b248493          	addi	s1,s1,-1614 # 800123d8 <uart_tx_lock>
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
    80000a5c:	00026797          	auipc	a5,0x26
    80000a60:	be478793          	addi	a5,a5,-1052 # 80026640 <end>
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
    80000a7c:	99890913          	addi	s2,s2,-1640 # 80012410 <kmem>
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
    80000b0a:	90a50513          	addi	a0,a0,-1782 # 80012410 <kmem>
    80000b0e:	06c000ef          	jal	80000b7a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b12:	45c5                	li	a1,17
    80000b14:	05ee                	slli	a1,a1,0x1b
    80000b16:	00026517          	auipc	a0,0x26
    80000b1a:	b2a50513          	addi	a0,a0,-1238 # 80026640 <end>
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
    80000b38:	8dc48493          	addi	s1,s1,-1828 # 80012410 <kmem>
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	0c0000ef          	jal	80000bfe <acquire>
  r = kmem.freelist;
    80000b42:	6c84                	ld	s1,24(s1)
  if(r)
    80000b44:	c485                	beqz	s1,80000b6c <kalloc+0x42>
    kmem.freelist = r->next;
    80000b46:	609c                	ld	a5,0(s1)
    80000b48:	00012517          	auipc	a0,0x12
    80000b4c:	8c850513          	addi	a0,a0,-1848 # 80012410 <kmem>
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
    80000b70:	8a450513          	addi	a0,a0,-1884 # 80012410 <kmem>
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

static inline uint64
r_sstatus()
{
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bc8:	100024f3          	csrr	s1,sstatus
    80000bcc:	100027f3          	csrr	a5,sstatus

// disable device interrupts
static inline void
intr_off()
{
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
// are device interrupts enabled?
static inline int
intr_get()
{
  uint64 x = r_sstatus();
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
    80000d4c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd89c1>
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
    80000e94:	45870713          	addi	a4,a4,1112 # 8000a2e8 <started>
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
    80000eba:	536010ef          	jal	800023f0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	46a040ef          	jal	80005328 <plicinithart>
  }

  scheduler();        
    80000ec2:	679000ef          	jal	80001d3a <scheduler>
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
    80000f02:	4ca010ef          	jal	800023cc <trapinit>
    trapinithart();  // install kernel trap vector
    80000f06:	4ea010ef          	jal	800023f0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f0a:	404040ef          	jal	8000530e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f0e:	41a040ef          	jal	80005328 <plicinithart>
    binit();         // buffer cache
    80000f12:	37d010ef          	jal	80002a8e <binit>
    iinit();         // inode table
    80000f16:	148020ef          	jal	8000305e <iinit>
    fileinit();      // file table
    80000f1a:	717020ef          	jal	80003e30 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1e:	4fa040ef          	jal	80005418 <virtio_disk_init>
    userinit();      // first user process
    80000f22:	435000ef          	jal	80001b56 <userinit>
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    started = 1;
    80000f2a:	4785                	li	a5,1
    80000f2c:	00009717          	auipc	a4,0x9
    80000f30:	3af72e23          	sw	a5,956(a4) # 8000a2e8 <started>
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
    80000f46:	3ae7b783          	ld	a5,942(a5) # 8000a2f0 <kernel_pagetable>
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
    800011d4:	12a7b023          	sd	a0,288(a5) # 8000a2f0 <kernel_pagetable>
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
    80001778:	0ec48493          	addi	s1,s1,236 # 80012860 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000177c:	8c26                	mv	s8,s1
    8000177e:	a33f17b7          	lui	a5,0xa33f1
    80001782:	28d78793          	addi	a5,a5,653 # ffffffffa33f128d <end+0xffffffff233cac4d>
    80001786:	f128d937          	lui	s2,0xf128d
    8000178a:	fc590913          	addi	s2,s2,-59 # fffffffff128cfc5 <end+0xffffffff71266985>
    8000178e:	1902                	slli	s2,s2,0x20
    80001790:	993e                	add	s2,s2,a5
    80001792:	040009b7          	lui	s3,0x4000
    80001796:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001798:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000179a:	4b99                	li	s7,6
    8000179c:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    8000179e:	0001aa97          	auipc	s5,0x1a
    800017a2:	ac2a8a93          	addi	s5,s5,-1342 # 8001b260 <tickslock>
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
    800017cc:	22848493          	addi	s1,s1,552
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
    80001818:	c1c50513          	addi	a0,a0,-996 # 80012430 <pid_lock>
    8000181c:	b5eff0ef          	jal	80000b7a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001820:	00006597          	auipc	a1,0x6
    80001824:	9e858593          	addi	a1,a1,-1560 # 80007208 <etext+0x208>
    80001828:	00011517          	auipc	a0,0x11
    8000182c:	c2050513          	addi	a0,a0,-992 # 80012448 <wait_lock>
    80001830:	b4aff0ef          	jal	80000b7a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001834:	00011497          	auipc	s1,0x11
    80001838:	02c48493          	addi	s1,s1,44 # 80012860 <proc>
      initlock(&p->lock, "proc");
    8000183c:	00006b17          	auipc	s6,0x6
    80001840:	9dcb0b13          	addi	s6,s6,-1572 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001844:	8aa6                	mv	s5,s1
    80001846:	a33f17b7          	lui	a5,0xa33f1
    8000184a:	28d78793          	addi	a5,a5,653 # ffffffffa33f128d <end+0xffffffff233cac4d>
    8000184e:	f128d937          	lui	s2,0xf128d
    80001852:	fc590913          	addi	s2,s2,-59 # fffffffff128cfc5 <end+0xffffffff71266985>
    80001856:	1902                	slli	s2,s2,0x20
    80001858:	993e                	add	s2,s2,a5
    8000185a:	040009b7          	lui	s3,0x4000
    8000185e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001862:	0001aa17          	auipc	s4,0x1a
    80001866:	9fea0a13          	addi	s4,s4,-1538 # 8001b260 <tickslock>
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
    8000188c:	22848493          	addi	s1,s1,552
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
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
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
    800018ce:	b9650513          	addi	a0,a0,-1130 # 80012460 <cpus>
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
    800018f4:	b4070713          	addi	a4,a4,-1216 # 80012430 <pid_lock>
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
    80001920:	9447a783          	lw	a5,-1724(a5) # 8000a260 <first.1>
    80001924:	e799                	bnez	a5,80001932 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001926:	2e7000ef          	jal	8000240c <usertrapret>
}
    8000192a:	60a2                	ld	ra,8(sp)
    8000192c:	6402                	ld	s0,0(sp)
    8000192e:	0141                	addi	sp,sp,16
    80001930:	8082                	ret
    fsinit(ROOTDEV);
    80001932:	4505                	li	a0,1
    80001934:	6be010ef          	jal	80002ff2 <fsinit>
    first = 0;
    80001938:	00009797          	auipc	a5,0x9
    8000193c:	9207a423          	sw	zero,-1752(a5) # 8000a260 <first.1>
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
    80001956:	ade90913          	addi	s2,s2,-1314 # 80012430 <pid_lock>
    8000195a:	854a                	mv	a0,s2
    8000195c:	aa2ff0ef          	jal	80000bfe <acquire>
  pid = nextpid;
    80001960:	00009797          	auipc	a5,0x9
    80001964:	90478793          	addi	a5,a5,-1788 # 8000a264 <nextpid>
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
    80001aae:	db648493          	addi	s1,s1,-586 # 80012860 <proc>
    80001ab2:	00019917          	auipc	s2,0x19
    80001ab6:	7ae90913          	addi	s2,s2,1966 # 8001b260 <tickslock>
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
    80001aca:	22848493          	addi	s1,s1,552
    80001ace:	ff2496e3          	bne	s1,s2,80001aba <allocproc+0x1c>
  return 0;
    80001ad2:	4481                	li	s1,0
    80001ad4:	a891                	j	80001b28 <allocproc+0x8a>
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
    80001ae8:	c539                	beqz	a0,80001b36 <allocproc+0x98>
  p->pagetable = proc_pagetable(p);
    80001aea:	8526                	mv	a0,s1
    80001aec:	e99ff0ef          	jal	80001984 <proc_pagetable>
    80001af0:	892a                	mv	s2,a0
    80001af2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af4:	c929                	beqz	a0,80001b46 <allocproc+0xa8>
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
  for(int i=1; i<=SYSCALL_COUNT; i++){
    80001b16:	17048793          	addi	a5,s1,368
    80001b1a:	22048713          	addi	a4,s1,544
    p->syscall_counts[i] = 0;
    80001b1e:	0007b023          	sd	zero,0(a5)
  for(int i=1; i<=SYSCALL_COUNT; i++){
    80001b22:	07a1                	addi	a5,a5,8
    80001b24:	fee79de3          	bne	a5,a4,80001b1e <allocproc+0x80>
}
    80001b28:	8526                	mv	a0,s1
    80001b2a:	60e2                	ld	ra,24(sp)
    80001b2c:	6442                	ld	s0,16(sp)
    80001b2e:	64a2                	ld	s1,8(sp)
    80001b30:	6902                	ld	s2,0(sp)
    80001b32:	6105                	addi	sp,sp,32
    80001b34:	8082                	ret
    freeproc(p);
    80001b36:	8526                	mv	a0,s1
    80001b38:	f17ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	954ff0ef          	jal	80000c92 <release>
    return 0;
    80001b42:	84ca                	mv	s1,s2
    80001b44:	b7d5                	j	80001b28 <allocproc+0x8a>
    freeproc(p);
    80001b46:	8526                	mv	a0,s1
    80001b48:	f07ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	944ff0ef          	jal	80000c92 <release>
    return 0;
    80001b52:	84ca                	mv	s1,s2
    80001b54:	bfd1                	j	80001b28 <allocproc+0x8a>

0000000080001b56 <userinit>:
{
    80001b56:	1101                	addi	sp,sp,-32
    80001b58:	ec06                	sd	ra,24(sp)
    80001b5a:	e822                	sd	s0,16(sp)
    80001b5c:	e426                	sd	s1,8(sp)
    80001b5e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b60:	f3fff0ef          	jal	80001a9e <allocproc>
    80001b64:	84aa                	mv	s1,a0
  initproc = p;
    80001b66:	00008797          	auipc	a5,0x8
    80001b6a:	78a7b923          	sd	a0,1938(a5) # 8000a2f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b6e:	03400613          	li	a2,52
    80001b72:	00008597          	auipc	a1,0x8
    80001b76:	6fe58593          	addi	a1,a1,1790 # 8000a270 <initcode>
    80001b7a:	6928                	ld	a0,80(a0)
    80001b7c:	f46ff0ef          	jal	800012c2 <uvmfirst>
  p->sz = PGSIZE;
    80001b80:	6785                	lui	a5,0x1
    80001b82:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b84:	6cb8                	ld	a4,88(s1)
    80001b86:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b8a:	6cb8                	ld	a4,88(s1)
    80001b8c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b8e:	4641                	li	a2,16
    80001b90:	00005597          	auipc	a1,0x5
    80001b94:	69058593          	addi	a1,a1,1680 # 80007220 <etext+0x220>
    80001b98:	15848513          	addi	a0,s1,344
    80001b9c:	a84ff0ef          	jal	80000e20 <safestrcpy>
  p->cwd = namei("/");
    80001ba0:	00005517          	auipc	a0,0x5
    80001ba4:	69050513          	addi	a0,a0,1680 # 80007230 <etext+0x230>
    80001ba8:	56f010ef          	jal	80003916 <namei>
    80001bac:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bb0:	478d                	li	a5,3
    80001bb2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	8dcff0ef          	jal	80000c92 <release>
}
    80001bba:	60e2                	ld	ra,24(sp)
    80001bbc:	6442                	ld	s0,16(sp)
    80001bbe:	64a2                	ld	s1,8(sp)
    80001bc0:	6105                	addi	sp,sp,32
    80001bc2:	8082                	ret

0000000080001bc4 <growproc>:
{
    80001bc4:	1101                	addi	sp,sp,-32
    80001bc6:	ec06                	sd	ra,24(sp)
    80001bc8:	e822                	sd	s0,16(sp)
    80001bca:	e426                	sd	s1,8(sp)
    80001bcc:	e04a                	sd	s2,0(sp)
    80001bce:	1000                	addi	s0,sp,32
    80001bd0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bd2:	d0bff0ef          	jal	800018dc <myproc>
    80001bd6:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bd8:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bda:	01204c63          	bgtz	s2,80001bf2 <growproc+0x2e>
  } else if(n < 0){
    80001bde:	02094463          	bltz	s2,80001c06 <growproc+0x42>
  p->sz = sz;
    80001be2:	e4ac                	sd	a1,72(s1)
  return 0;
    80001be4:	4501                	li	a0,0
}
    80001be6:	60e2                	ld	ra,24(sp)
    80001be8:	6442                	ld	s0,16(sp)
    80001bea:	64a2                	ld	s1,8(sp)
    80001bec:	6902                	ld	s2,0(sp)
    80001bee:	6105                	addi	sp,sp,32
    80001bf0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bf2:	4691                	li	a3,4
    80001bf4:	00b90633          	add	a2,s2,a1
    80001bf8:	6928                	ld	a0,80(a0)
    80001bfa:	f6aff0ef          	jal	80001364 <uvmalloc>
    80001bfe:	85aa                	mv	a1,a0
    80001c00:	f16d                	bnez	a0,80001be2 <growproc+0x1e>
      return -1;
    80001c02:	557d                	li	a0,-1
    80001c04:	b7cd                	j	80001be6 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c06:	00b90633          	add	a2,s2,a1
    80001c0a:	6928                	ld	a0,80(a0)
    80001c0c:	f14ff0ef          	jal	80001320 <uvmdealloc>
    80001c10:	85aa                	mv	a1,a0
    80001c12:	bfc1                	j	80001be2 <growproc+0x1e>

0000000080001c14 <fork>:
{
    80001c14:	7139                	addi	sp,sp,-64
    80001c16:	fc06                	sd	ra,56(sp)
    80001c18:	f822                	sd	s0,48(sp)
    80001c1a:	f04a                	sd	s2,32(sp)
    80001c1c:	e456                	sd	s5,8(sp)
    80001c1e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c20:	cbdff0ef          	jal	800018dc <myproc>
    80001c24:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c26:	e79ff0ef          	jal	80001a9e <allocproc>
    80001c2a:	10050663          	beqz	a0,80001d36 <fork+0x122>
    80001c2e:	ec4e                	sd	s3,24(sp)
    80001c30:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c32:	048ab603          	ld	a2,72(s5)
    80001c36:	692c                	ld	a1,80(a0)
    80001c38:	050ab503          	ld	a0,80(s5)
    80001c3c:	869ff0ef          	jal	800014a4 <uvmcopy>
    80001c40:	06054663          	bltz	a0,80001cac <fork+0x98>
    80001c44:	f426                	sd	s1,40(sp)
    80001c46:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c48:	048ab783          	ld	a5,72(s5)
    80001c4c:	04f9b423          	sd	a5,72(s3)
  for(int i = 0; i <= SYSCALL_COUNT; i++){
    80001c50:	168a8793          	addi	a5,s5,360
    80001c54:	16898713          	addi	a4,s3,360
    80001c58:	220a8613          	addi	a2,s5,544
    np->syscall_counts[i] = p->syscall_counts[i];
    80001c5c:	6394                	ld	a3,0(a5)
    80001c5e:	e314                	sd	a3,0(a4)
  for(int i = 0; i <= SYSCALL_COUNT; i++){
    80001c60:	07a1                	addi	a5,a5,8 # 1008 <_entry-0x7fffeff8>
    80001c62:	0721                	addi	a4,a4,8
    80001c64:	fec79ce3          	bne	a5,a2,80001c5c <fork+0x48>
  *(np->trapframe) = *(p->trapframe);
    80001c68:	058ab683          	ld	a3,88(s5)
    80001c6c:	87b6                	mv	a5,a3
    80001c6e:	0589b703          	ld	a4,88(s3)
    80001c72:	12068693          	addi	a3,a3,288
    80001c76:	0007b803          	ld	a6,0(a5)
    80001c7a:	6788                	ld	a0,8(a5)
    80001c7c:	6b8c                	ld	a1,16(a5)
    80001c7e:	6f90                	ld	a2,24(a5)
    80001c80:	01073023          	sd	a6,0(a4)
    80001c84:	e708                	sd	a0,8(a4)
    80001c86:	eb0c                	sd	a1,16(a4)
    80001c88:	ef10                	sd	a2,24(a4)
    80001c8a:	02078793          	addi	a5,a5,32
    80001c8e:	02070713          	addi	a4,a4,32
    80001c92:	fed792e3          	bne	a5,a3,80001c76 <fork+0x62>
  np->trapframe->a0 = 0;
    80001c96:	0589b783          	ld	a5,88(s3)
    80001c9a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c9e:	0d0a8493          	addi	s1,s5,208
    80001ca2:	0d098913          	addi	s2,s3,208
    80001ca6:	150a8a13          	addi	s4,s5,336
    80001caa:	a831                	j	80001cc6 <fork+0xb2>
    freeproc(np);
    80001cac:	854e                	mv	a0,s3
    80001cae:	da1ff0ef          	jal	80001a4e <freeproc>
    release(&np->lock);
    80001cb2:	854e                	mv	a0,s3
    80001cb4:	fdffe0ef          	jal	80000c92 <release>
    return -1;
    80001cb8:	597d                	li	s2,-1
    80001cba:	69e2                	ld	s3,24(sp)
    80001cbc:	a0b5                	j	80001d28 <fork+0x114>
  for(i = 0; i < NOFILE; i++)
    80001cbe:	04a1                	addi	s1,s1,8
    80001cc0:	0921                	addi	s2,s2,8
    80001cc2:	01448963          	beq	s1,s4,80001cd4 <fork+0xc0>
    if(p->ofile[i])
    80001cc6:	6088                	ld	a0,0(s1)
    80001cc8:	d97d                	beqz	a0,80001cbe <fork+0xaa>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cca:	1e8020ef          	jal	80003eb2 <filedup>
    80001cce:	00a93023          	sd	a0,0(s2)
    80001cd2:	b7f5                	j	80001cbe <fork+0xaa>
  np->cwd = idup(p->cwd);
    80001cd4:	150ab503          	ld	a0,336(s5)
    80001cd8:	518010ef          	jal	800031f0 <idup>
    80001cdc:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ce0:	4641                	li	a2,16
    80001ce2:	158a8593          	addi	a1,s5,344
    80001ce6:	15898513          	addi	a0,s3,344
    80001cea:	936ff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001cee:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001cf2:	854e                	mv	a0,s3
    80001cf4:	f9ffe0ef          	jal	80000c92 <release>
  acquire(&wait_lock);
    80001cf8:	00010497          	auipc	s1,0x10
    80001cfc:	75048493          	addi	s1,s1,1872 # 80012448 <wait_lock>
    80001d00:	8526                	mv	a0,s1
    80001d02:	efdfe0ef          	jal	80000bfe <acquire>
  np->parent = p;
    80001d06:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	f87fe0ef          	jal	80000c92 <release>
  acquire(&np->lock);
    80001d10:	854e                	mv	a0,s3
    80001d12:	eedfe0ef          	jal	80000bfe <acquire>
  np->state = RUNNABLE;
    80001d16:	478d                	li	a5,3
    80001d18:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d1c:	854e                	mv	a0,s3
    80001d1e:	f75fe0ef          	jal	80000c92 <release>
  return pid;
    80001d22:	74a2                	ld	s1,40(sp)
    80001d24:	69e2                	ld	s3,24(sp)
    80001d26:	6a42                	ld	s4,16(sp)
}
    80001d28:	854a                	mv	a0,s2
    80001d2a:	70e2                	ld	ra,56(sp)
    80001d2c:	7442                	ld	s0,48(sp)
    80001d2e:	7902                	ld	s2,32(sp)
    80001d30:	6aa2                	ld	s5,8(sp)
    80001d32:	6121                	addi	sp,sp,64
    80001d34:	8082                	ret
    return -1;
    80001d36:	597d                	li	s2,-1
    80001d38:	bfc5                	j	80001d28 <fork+0x114>

0000000080001d3a <scheduler>:
{
    80001d3a:	715d                	addi	sp,sp,-80
    80001d3c:	e486                	sd	ra,72(sp)
    80001d3e:	e0a2                	sd	s0,64(sp)
    80001d40:	fc26                	sd	s1,56(sp)
    80001d42:	f84a                	sd	s2,48(sp)
    80001d44:	f44e                	sd	s3,40(sp)
    80001d46:	f052                	sd	s4,32(sp)
    80001d48:	ec56                	sd	s5,24(sp)
    80001d4a:	e85a                	sd	s6,16(sp)
    80001d4c:	e45e                	sd	s7,8(sp)
    80001d4e:	e062                	sd	s8,0(sp)
    80001d50:	0880                	addi	s0,sp,80
    80001d52:	8792                	mv	a5,tp
  int id = r_tp();
    80001d54:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d56:	00779b13          	slli	s6,a5,0x7
    80001d5a:	00010717          	auipc	a4,0x10
    80001d5e:	6d670713          	addi	a4,a4,1750 # 80012430 <pid_lock>
    80001d62:	975a                	add	a4,a4,s6
    80001d64:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d68:	00010717          	auipc	a4,0x10
    80001d6c:	70070713          	addi	a4,a4,1792 # 80012468 <cpus+0x8>
    80001d70:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d72:	4c11                	li	s8,4
        c->proc = p;
    80001d74:	079e                	slli	a5,a5,0x7
    80001d76:	00010a17          	auipc	s4,0x10
    80001d7a:	6baa0a13          	addi	s4,s4,1722 # 80012430 <pid_lock>
    80001d7e:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d80:	4b85                	li	s7,1
    80001d82:	a0a9                	j	80001dcc <scheduler+0x92>
      release(&p->lock);
    80001d84:	8526                	mv	a0,s1
    80001d86:	f0dfe0ef          	jal	80000c92 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d8a:	22848493          	addi	s1,s1,552
    80001d8e:	03248563          	beq	s1,s2,80001db8 <scheduler+0x7e>
      acquire(&p->lock);
    80001d92:	8526                	mv	a0,s1
    80001d94:	e6bfe0ef          	jal	80000bfe <acquire>
      if(p->state == RUNNABLE) {
    80001d98:	4c9c                	lw	a5,24(s1)
    80001d9a:	ff3795e3          	bne	a5,s3,80001d84 <scheduler+0x4a>
        p->state = RUNNING;
    80001d9e:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001da2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001da6:	06048593          	addi	a1,s1,96
    80001daa:	855a                	mv	a0,s6
    80001dac:	5b6000ef          	jal	80002362 <swtch>
        c->proc = 0;
    80001db0:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001db4:	8ade                	mv	s5,s7
    80001db6:	b7f9                	j	80001d84 <scheduler+0x4a>
    if(found == 0) {
    80001db8:	000a9a63          	bnez	s5,80001dcc <scheduler+0x92>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dbc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dc0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dc4:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001dc8:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dcc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dd0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dd4:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dd8:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dda:	00011497          	auipc	s1,0x11
    80001dde:	a8648493          	addi	s1,s1,-1402 # 80012860 <proc>
      if(p->state == RUNNABLE) {
    80001de2:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001de4:	00019917          	auipc	s2,0x19
    80001de8:	47c90913          	addi	s2,s2,1148 # 8001b260 <tickslock>
    80001dec:	b75d                	j	80001d92 <scheduler+0x58>

0000000080001dee <sched>:
{
    80001dee:	7179                	addi	sp,sp,-48
    80001df0:	f406                	sd	ra,40(sp)
    80001df2:	f022                	sd	s0,32(sp)
    80001df4:	ec26                	sd	s1,24(sp)
    80001df6:	e84a                	sd	s2,16(sp)
    80001df8:	e44e                	sd	s3,8(sp)
    80001dfa:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dfc:	ae1ff0ef          	jal	800018dc <myproc>
    80001e00:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e02:	d93fe0ef          	jal	80000b94 <holding>
    80001e06:	c92d                	beqz	a0,80001e78 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e08:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e0a:	2781                	sext.w	a5,a5
    80001e0c:	079e                	slli	a5,a5,0x7
    80001e0e:	00010717          	auipc	a4,0x10
    80001e12:	62270713          	addi	a4,a4,1570 # 80012430 <pid_lock>
    80001e16:	97ba                	add	a5,a5,a4
    80001e18:	0a87a703          	lw	a4,168(a5)
    80001e1c:	4785                	li	a5,1
    80001e1e:	06f71363          	bne	a4,a5,80001e84 <sched+0x96>
  if(p->state == RUNNING)
    80001e22:	4c98                	lw	a4,24(s1)
    80001e24:	4791                	li	a5,4
    80001e26:	06f70563          	beq	a4,a5,80001e90 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e2a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e2e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e30:	e7b5                	bnez	a5,80001e9c <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e32:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e34:	00010917          	auipc	s2,0x10
    80001e38:	5fc90913          	addi	s2,s2,1532 # 80012430 <pid_lock>
    80001e3c:	2781                	sext.w	a5,a5
    80001e3e:	079e                	slli	a5,a5,0x7
    80001e40:	97ca                	add	a5,a5,s2
    80001e42:	0ac7a983          	lw	s3,172(a5)
    80001e46:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e48:	2781                	sext.w	a5,a5
    80001e4a:	079e                	slli	a5,a5,0x7
    80001e4c:	00010597          	auipc	a1,0x10
    80001e50:	61c58593          	addi	a1,a1,1564 # 80012468 <cpus+0x8>
    80001e54:	95be                	add	a1,a1,a5
    80001e56:	06048513          	addi	a0,s1,96
    80001e5a:	508000ef          	jal	80002362 <swtch>
    80001e5e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e60:	2781                	sext.w	a5,a5
    80001e62:	079e                	slli	a5,a5,0x7
    80001e64:	993e                	add	s2,s2,a5
    80001e66:	0b392623          	sw	s3,172(s2)
}
    80001e6a:	70a2                	ld	ra,40(sp)
    80001e6c:	7402                	ld	s0,32(sp)
    80001e6e:	64e2                	ld	s1,24(sp)
    80001e70:	6942                	ld	s2,16(sp)
    80001e72:	69a2                	ld	s3,8(sp)
    80001e74:	6145                	addi	sp,sp,48
    80001e76:	8082                	ret
    panic("sched p->lock");
    80001e78:	00005517          	auipc	a0,0x5
    80001e7c:	3c050513          	addi	a0,a0,960 # 80007238 <etext+0x238>
    80001e80:	91ffe0ef          	jal	8000079e <panic>
    panic("sched locks");
    80001e84:	00005517          	auipc	a0,0x5
    80001e88:	3c450513          	addi	a0,a0,964 # 80007248 <etext+0x248>
    80001e8c:	913fe0ef          	jal	8000079e <panic>
    panic("sched running");
    80001e90:	00005517          	auipc	a0,0x5
    80001e94:	3c850513          	addi	a0,a0,968 # 80007258 <etext+0x258>
    80001e98:	907fe0ef          	jal	8000079e <panic>
    panic("sched interruptible");
    80001e9c:	00005517          	auipc	a0,0x5
    80001ea0:	3cc50513          	addi	a0,a0,972 # 80007268 <etext+0x268>
    80001ea4:	8fbfe0ef          	jal	8000079e <panic>

0000000080001ea8 <yield>:
{
    80001ea8:	1101                	addi	sp,sp,-32
    80001eaa:	ec06                	sd	ra,24(sp)
    80001eac:	e822                	sd	s0,16(sp)
    80001eae:	e426                	sd	s1,8(sp)
    80001eb0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001eb2:	a2bff0ef          	jal	800018dc <myproc>
    80001eb6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001eb8:	d47fe0ef          	jal	80000bfe <acquire>
  p->state = RUNNABLE;
    80001ebc:	478d                	li	a5,3
    80001ebe:	cc9c                	sw	a5,24(s1)
  sched();
    80001ec0:	f2fff0ef          	jal	80001dee <sched>
  release(&p->lock);
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	dcdfe0ef          	jal	80000c92 <release>
}
    80001eca:	60e2                	ld	ra,24(sp)
    80001ecc:	6442                	ld	s0,16(sp)
    80001ece:	64a2                	ld	s1,8(sp)
    80001ed0:	6105                	addi	sp,sp,32
    80001ed2:	8082                	ret

0000000080001ed4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ed4:	7179                	addi	sp,sp,-48
    80001ed6:	f406                	sd	ra,40(sp)
    80001ed8:	f022                	sd	s0,32(sp)
    80001eda:	ec26                	sd	s1,24(sp)
    80001edc:	e84a                	sd	s2,16(sp)
    80001ede:	e44e                	sd	s3,8(sp)
    80001ee0:	1800                	addi	s0,sp,48
    80001ee2:	89aa                	mv	s3,a0
    80001ee4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ee6:	9f7ff0ef          	jal	800018dc <myproc>
    80001eea:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001eec:	d13fe0ef          	jal	80000bfe <acquire>
  release(lk);
    80001ef0:	854a                	mv	a0,s2
    80001ef2:	da1fe0ef          	jal	80000c92 <release>

  // Go to sleep.
  p->chan = chan;
    80001ef6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001efa:	4789                	li	a5,2
    80001efc:	cc9c                	sw	a5,24(s1)

  sched();
    80001efe:	ef1ff0ef          	jal	80001dee <sched>

  // Tidy up.
  p->chan = 0;
    80001f02:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	d8bfe0ef          	jal	80000c92 <release>
  acquire(lk);
    80001f0c:	854a                	mv	a0,s2
    80001f0e:	cf1fe0ef          	jal	80000bfe <acquire>
}
    80001f12:	70a2                	ld	ra,40(sp)
    80001f14:	7402                	ld	s0,32(sp)
    80001f16:	64e2                	ld	s1,24(sp)
    80001f18:	6942                	ld	s2,16(sp)
    80001f1a:	69a2                	ld	s3,8(sp)
    80001f1c:	6145                	addi	sp,sp,48
    80001f1e:	8082                	ret

0000000080001f20 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f20:	7139                	addi	sp,sp,-64
    80001f22:	fc06                	sd	ra,56(sp)
    80001f24:	f822                	sd	s0,48(sp)
    80001f26:	f426                	sd	s1,40(sp)
    80001f28:	f04a                	sd	s2,32(sp)
    80001f2a:	ec4e                	sd	s3,24(sp)
    80001f2c:	e852                	sd	s4,16(sp)
    80001f2e:	e456                	sd	s5,8(sp)
    80001f30:	0080                	addi	s0,sp,64
    80001f32:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f34:	00011497          	auipc	s1,0x11
    80001f38:	92c48493          	addi	s1,s1,-1748 # 80012860 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f3c:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f3e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f40:	00019917          	auipc	s2,0x19
    80001f44:	32090913          	addi	s2,s2,800 # 8001b260 <tickslock>
    80001f48:	a801                	j	80001f58 <wakeup+0x38>
      }
      release(&p->lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	d47fe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f50:	22848493          	addi	s1,s1,552
    80001f54:	03248263          	beq	s1,s2,80001f78 <wakeup+0x58>
    if(p != myproc()){
    80001f58:	985ff0ef          	jal	800018dc <myproc>
    80001f5c:	fea48ae3          	beq	s1,a0,80001f50 <wakeup+0x30>
      acquire(&p->lock);
    80001f60:	8526                	mv	a0,s1
    80001f62:	c9dfe0ef          	jal	80000bfe <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f66:	4c9c                	lw	a5,24(s1)
    80001f68:	ff3791e3          	bne	a5,s3,80001f4a <wakeup+0x2a>
    80001f6c:	709c                	ld	a5,32(s1)
    80001f6e:	fd479ee3          	bne	a5,s4,80001f4a <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f72:	0154ac23          	sw	s5,24(s1)
    80001f76:	bfd1                	j	80001f4a <wakeup+0x2a>
    }
  }
}
    80001f78:	70e2                	ld	ra,56(sp)
    80001f7a:	7442                	ld	s0,48(sp)
    80001f7c:	74a2                	ld	s1,40(sp)
    80001f7e:	7902                	ld	s2,32(sp)
    80001f80:	69e2                	ld	s3,24(sp)
    80001f82:	6a42                	ld	s4,16(sp)
    80001f84:	6aa2                	ld	s5,8(sp)
    80001f86:	6121                	addi	sp,sp,64
    80001f88:	8082                	ret

0000000080001f8a <reparent>:
{
    80001f8a:	7179                	addi	sp,sp,-48
    80001f8c:	f406                	sd	ra,40(sp)
    80001f8e:	f022                	sd	s0,32(sp)
    80001f90:	ec26                	sd	s1,24(sp)
    80001f92:	e84a                	sd	s2,16(sp)
    80001f94:	e44e                	sd	s3,8(sp)
    80001f96:	e052                	sd	s4,0(sp)
    80001f98:	1800                	addi	s0,sp,48
    80001f9a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f9c:	00011497          	auipc	s1,0x11
    80001fa0:	8c448493          	addi	s1,s1,-1852 # 80012860 <proc>
      pp->parent = initproc;
    80001fa4:	00008a17          	auipc	s4,0x8
    80001fa8:	354a0a13          	addi	s4,s4,852 # 8000a2f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fac:	00019997          	auipc	s3,0x19
    80001fb0:	2b498993          	addi	s3,s3,692 # 8001b260 <tickslock>
    80001fb4:	a029                	j	80001fbe <reparent+0x34>
    80001fb6:	22848493          	addi	s1,s1,552
    80001fba:	01348b63          	beq	s1,s3,80001fd0 <reparent+0x46>
    if(pp->parent == p){
    80001fbe:	7c9c                	ld	a5,56(s1)
    80001fc0:	ff279be3          	bne	a5,s2,80001fb6 <reparent+0x2c>
      pp->parent = initproc;
    80001fc4:	000a3503          	ld	a0,0(s4)
    80001fc8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fca:	f57ff0ef          	jal	80001f20 <wakeup>
    80001fce:	b7e5                	j	80001fb6 <reparent+0x2c>
}
    80001fd0:	70a2                	ld	ra,40(sp)
    80001fd2:	7402                	ld	s0,32(sp)
    80001fd4:	64e2                	ld	s1,24(sp)
    80001fd6:	6942                	ld	s2,16(sp)
    80001fd8:	69a2                	ld	s3,8(sp)
    80001fda:	6a02                	ld	s4,0(sp)
    80001fdc:	6145                	addi	sp,sp,48
    80001fde:	8082                	ret

0000000080001fe0 <exit>:
{
    80001fe0:	7179                	addi	sp,sp,-48
    80001fe2:	f406                	sd	ra,40(sp)
    80001fe4:	f022                	sd	s0,32(sp)
    80001fe6:	ec26                	sd	s1,24(sp)
    80001fe8:	e84a                	sd	s2,16(sp)
    80001fea:	e44e                	sd	s3,8(sp)
    80001fec:	e052                	sd	s4,0(sp)
    80001fee:	1800                	addi	s0,sp,48
    80001ff0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001ff2:	8ebff0ef          	jal	800018dc <myproc>
    80001ff6:	89aa                	mv	s3,a0
  if(p == initproc)
    80001ff8:	00008797          	auipc	a5,0x8
    80001ffc:	3007b783          	ld	a5,768(a5) # 8000a2f8 <initproc>
    80002000:	0d050493          	addi	s1,a0,208
    80002004:	15050913          	addi	s2,a0,336
    80002008:	00a79b63          	bne	a5,a0,8000201e <exit+0x3e>
    panic("init exiting");
    8000200c:	00005517          	auipc	a0,0x5
    80002010:	27450513          	addi	a0,a0,628 # 80007280 <etext+0x280>
    80002014:	f8afe0ef          	jal	8000079e <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002018:	04a1                	addi	s1,s1,8
    8000201a:	01248963          	beq	s1,s2,8000202c <exit+0x4c>
    if(p->ofile[fd]){
    8000201e:	6088                	ld	a0,0(s1)
    80002020:	dd65                	beqz	a0,80002018 <exit+0x38>
      fileclose(f);
    80002022:	6d7010ef          	jal	80003ef8 <fileclose>
      p->ofile[fd] = 0;
    80002026:	0004b023          	sd	zero,0(s1)
    8000202a:	b7fd                	j	80002018 <exit+0x38>
  begin_op();
    8000202c:	2ad010ef          	jal	80003ad8 <begin_op>
  iput(p->cwd);
    80002030:	1509b503          	ld	a0,336(s3)
    80002034:	374010ef          	jal	800033a8 <iput>
  end_op();
    80002038:	30b010ef          	jal	80003b42 <end_op>
  p->cwd = 0;
    8000203c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002040:	00010497          	auipc	s1,0x10
    80002044:	40848493          	addi	s1,s1,1032 # 80012448 <wait_lock>
    80002048:	8526                	mv	a0,s1
    8000204a:	bb5fe0ef          	jal	80000bfe <acquire>
  reparent(p);
    8000204e:	854e                	mv	a0,s3
    80002050:	f3bff0ef          	jal	80001f8a <reparent>
  wakeup(p->parent);
    80002054:	0389b503          	ld	a0,56(s3)
    80002058:	ec9ff0ef          	jal	80001f20 <wakeup>
  acquire(&p->lock);
    8000205c:	854e                	mv	a0,s3
    8000205e:	ba1fe0ef          	jal	80000bfe <acquire>
  p->xstate = status;
    80002062:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002066:	4795                	li	a5,5
    80002068:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000206c:	8526                	mv	a0,s1
    8000206e:	c25fe0ef          	jal	80000c92 <release>
  sched();
    80002072:	d7dff0ef          	jal	80001dee <sched>
  panic("zombie exit");
    80002076:	00005517          	auipc	a0,0x5
    8000207a:	21a50513          	addi	a0,a0,538 # 80007290 <etext+0x290>
    8000207e:	f20fe0ef          	jal	8000079e <panic>

0000000080002082 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002082:	7179                	addi	sp,sp,-48
    80002084:	f406                	sd	ra,40(sp)
    80002086:	f022                	sd	s0,32(sp)
    80002088:	ec26                	sd	s1,24(sp)
    8000208a:	e84a                	sd	s2,16(sp)
    8000208c:	e44e                	sd	s3,8(sp)
    8000208e:	1800                	addi	s0,sp,48
    80002090:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002092:	00010497          	auipc	s1,0x10
    80002096:	7ce48493          	addi	s1,s1,1998 # 80012860 <proc>
    8000209a:	00019997          	auipc	s3,0x19
    8000209e:	1c698993          	addi	s3,s3,454 # 8001b260 <tickslock>
    acquire(&p->lock);
    800020a2:	8526                	mv	a0,s1
    800020a4:	b5bfe0ef          	jal	80000bfe <acquire>
    if(p->pid == pid){
    800020a8:	589c                	lw	a5,48(s1)
    800020aa:	01278b63          	beq	a5,s2,800020c0 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	be3fe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020b4:	22848493          	addi	s1,s1,552
    800020b8:	ff3495e3          	bne	s1,s3,800020a2 <kill+0x20>
  }
  return -1;
    800020bc:	557d                	li	a0,-1
    800020be:	a819                	j	800020d4 <kill+0x52>
      p->killed = 1;
    800020c0:	4785                	li	a5,1
    800020c2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020c4:	4c98                	lw	a4,24(s1)
    800020c6:	4789                	li	a5,2
    800020c8:	00f70d63          	beq	a4,a5,800020e2 <kill+0x60>
      release(&p->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	bc5fe0ef          	jal	80000c92 <release>
      return 0;
    800020d2:	4501                	li	a0,0
}
    800020d4:	70a2                	ld	ra,40(sp)
    800020d6:	7402                	ld	s0,32(sp)
    800020d8:	64e2                	ld	s1,24(sp)
    800020da:	6942                	ld	s2,16(sp)
    800020dc:	69a2                	ld	s3,8(sp)
    800020de:	6145                	addi	sp,sp,48
    800020e0:	8082                	ret
        p->state = RUNNABLE;
    800020e2:	478d                	li	a5,3
    800020e4:	cc9c                	sw	a5,24(s1)
    800020e6:	b7dd                	j	800020cc <kill+0x4a>

00000000800020e8 <setkilled>:

void
setkilled(struct proc *p)
{
    800020e8:	1101                	addi	sp,sp,-32
    800020ea:	ec06                	sd	ra,24(sp)
    800020ec:	e822                	sd	s0,16(sp)
    800020ee:	e426                	sd	s1,8(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f4:	b0bfe0ef          	jal	80000bfe <acquire>
  p->killed = 1;
    800020f8:	4785                	li	a5,1
    800020fa:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	b95fe0ef          	jal	80000c92 <release>
}
    80002102:	60e2                	ld	ra,24(sp)
    80002104:	6442                	ld	s0,16(sp)
    80002106:	64a2                	ld	s1,8(sp)
    80002108:	6105                	addi	sp,sp,32
    8000210a:	8082                	ret

000000008000210c <killed>:

int
killed(struct proc *p)
{
    8000210c:	1101                	addi	sp,sp,-32
    8000210e:	ec06                	sd	ra,24(sp)
    80002110:	e822                	sd	s0,16(sp)
    80002112:	e426                	sd	s1,8(sp)
    80002114:	e04a                	sd	s2,0(sp)
    80002116:	1000                	addi	s0,sp,32
    80002118:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000211a:	ae5fe0ef          	jal	80000bfe <acquire>
  k = p->killed;
    8000211e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002122:	8526                	mv	a0,s1
    80002124:	b6ffe0ef          	jal	80000c92 <release>
  return k;
}
    80002128:	854a                	mv	a0,s2
    8000212a:	60e2                	ld	ra,24(sp)
    8000212c:	6442                	ld	s0,16(sp)
    8000212e:	64a2                	ld	s1,8(sp)
    80002130:	6902                	ld	s2,0(sp)
    80002132:	6105                	addi	sp,sp,32
    80002134:	8082                	ret

0000000080002136 <wait>:
{
    80002136:	715d                	addi	sp,sp,-80
    80002138:	e486                	sd	ra,72(sp)
    8000213a:	e0a2                	sd	s0,64(sp)
    8000213c:	fc26                	sd	s1,56(sp)
    8000213e:	f84a                	sd	s2,48(sp)
    80002140:	f44e                	sd	s3,40(sp)
    80002142:	f052                	sd	s4,32(sp)
    80002144:	ec56                	sd	s5,24(sp)
    80002146:	e85a                	sd	s6,16(sp)
    80002148:	e45e                	sd	s7,8(sp)
    8000214a:	0880                	addi	s0,sp,80
    8000214c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000214e:	f8eff0ef          	jal	800018dc <myproc>
    80002152:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002154:	00010517          	auipc	a0,0x10
    80002158:	2f450513          	addi	a0,a0,756 # 80012448 <wait_lock>
    8000215c:	aa3fe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    80002160:	4a15                	li	s4,5
        havekids = 1;
    80002162:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002164:	00019997          	auipc	s3,0x19
    80002168:	0fc98993          	addi	s3,s3,252 # 8001b260 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000216c:	00010b97          	auipc	s7,0x10
    80002170:	2dcb8b93          	addi	s7,s7,732 # 80012448 <wait_lock>
    80002174:	a869                	j	8000220e <wait+0xd8>
          pid = pp->pid;
    80002176:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000217a:	000b0c63          	beqz	s6,80002192 <wait+0x5c>
    8000217e:	4691                	li	a3,4
    80002180:	02c48613          	addi	a2,s1,44
    80002184:	85da                	mv	a1,s6
    80002186:	05093503          	ld	a0,80(s2)
    8000218a:	bfaff0ef          	jal	80001584 <copyout>
    8000218e:	02054a63          	bltz	a0,800021c2 <wait+0x8c>
          freeproc(pp);
    80002192:	8526                	mv	a0,s1
    80002194:	8bbff0ef          	jal	80001a4e <freeproc>
          release(&pp->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	af9fe0ef          	jal	80000c92 <release>
          release(&wait_lock);
    8000219e:	00010517          	auipc	a0,0x10
    800021a2:	2aa50513          	addi	a0,a0,682 # 80012448 <wait_lock>
    800021a6:	aedfe0ef          	jal	80000c92 <release>
}
    800021aa:	854e                	mv	a0,s3
    800021ac:	60a6                	ld	ra,72(sp)
    800021ae:	6406                	ld	s0,64(sp)
    800021b0:	74e2                	ld	s1,56(sp)
    800021b2:	7942                	ld	s2,48(sp)
    800021b4:	79a2                	ld	s3,40(sp)
    800021b6:	7a02                	ld	s4,32(sp)
    800021b8:	6ae2                	ld	s5,24(sp)
    800021ba:	6b42                	ld	s6,16(sp)
    800021bc:	6ba2                	ld	s7,8(sp)
    800021be:	6161                	addi	sp,sp,80
    800021c0:	8082                	ret
            release(&pp->lock);
    800021c2:	8526                	mv	a0,s1
    800021c4:	acffe0ef          	jal	80000c92 <release>
            release(&wait_lock);
    800021c8:	00010517          	auipc	a0,0x10
    800021cc:	28050513          	addi	a0,a0,640 # 80012448 <wait_lock>
    800021d0:	ac3fe0ef          	jal	80000c92 <release>
            return -1;
    800021d4:	59fd                	li	s3,-1
    800021d6:	bfd1                	j	800021aa <wait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021d8:	22848493          	addi	s1,s1,552
    800021dc:	03348063          	beq	s1,s3,800021fc <wait+0xc6>
      if(pp->parent == p){
    800021e0:	7c9c                	ld	a5,56(s1)
    800021e2:	ff279be3          	bne	a5,s2,800021d8 <wait+0xa2>
        acquire(&pp->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	a17fe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    800021ec:	4c9c                	lw	a5,24(s1)
    800021ee:	f94784e3          	beq	a5,s4,80002176 <wait+0x40>
        release(&pp->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	a9ffe0ef          	jal	80000c92 <release>
        havekids = 1;
    800021f8:	8756                	mv	a4,s5
    800021fa:	bff9                	j	800021d8 <wait+0xa2>
    if(!havekids || killed(p)){
    800021fc:	cf19                	beqz	a4,8000221a <wait+0xe4>
    800021fe:	854a                	mv	a0,s2
    80002200:	f0dff0ef          	jal	8000210c <killed>
    80002204:	e919                	bnez	a0,8000221a <wait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002206:	85de                	mv	a1,s7
    80002208:	854a                	mv	a0,s2
    8000220a:	ccbff0ef          	jal	80001ed4 <sleep>
    havekids = 0;
    8000220e:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002210:	00010497          	auipc	s1,0x10
    80002214:	65048493          	addi	s1,s1,1616 # 80012860 <proc>
    80002218:	b7e1                	j	800021e0 <wait+0xaa>
      release(&wait_lock);
    8000221a:	00010517          	auipc	a0,0x10
    8000221e:	22e50513          	addi	a0,a0,558 # 80012448 <wait_lock>
    80002222:	a71fe0ef          	jal	80000c92 <release>
      return -1;
    80002226:	59fd                	li	s3,-1
    80002228:	b749                	j	800021aa <wait+0x74>

000000008000222a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000222a:	7179                	addi	sp,sp,-48
    8000222c:	f406                	sd	ra,40(sp)
    8000222e:	f022                	sd	s0,32(sp)
    80002230:	ec26                	sd	s1,24(sp)
    80002232:	e84a                	sd	s2,16(sp)
    80002234:	e44e                	sd	s3,8(sp)
    80002236:	e052                	sd	s4,0(sp)
    80002238:	1800                	addi	s0,sp,48
    8000223a:	84aa                	mv	s1,a0
    8000223c:	892e                	mv	s2,a1
    8000223e:	89b2                	mv	s3,a2
    80002240:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002242:	e9aff0ef          	jal	800018dc <myproc>
  if(user_dst){
    80002246:	cc99                	beqz	s1,80002264 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002248:	86d2                	mv	a3,s4
    8000224a:	864e                	mv	a2,s3
    8000224c:	85ca                	mv	a1,s2
    8000224e:	6928                	ld	a0,80(a0)
    80002250:	b34ff0ef          	jal	80001584 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002254:	70a2                	ld	ra,40(sp)
    80002256:	7402                	ld	s0,32(sp)
    80002258:	64e2                	ld	s1,24(sp)
    8000225a:	6942                	ld	s2,16(sp)
    8000225c:	69a2                	ld	s3,8(sp)
    8000225e:	6a02                	ld	s4,0(sp)
    80002260:	6145                	addi	sp,sp,48
    80002262:	8082                	ret
    memmove((char *)dst, src, len);
    80002264:	000a061b          	sext.w	a2,s4
    80002268:	85ce                	mv	a1,s3
    8000226a:	854a                	mv	a0,s2
    8000226c:	ac7fe0ef          	jal	80000d32 <memmove>
    return 0;
    80002270:	8526                	mv	a0,s1
    80002272:	b7cd                	j	80002254 <either_copyout+0x2a>

0000000080002274 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002274:	7179                	addi	sp,sp,-48
    80002276:	f406                	sd	ra,40(sp)
    80002278:	f022                	sd	s0,32(sp)
    8000227a:	ec26                	sd	s1,24(sp)
    8000227c:	e84a                	sd	s2,16(sp)
    8000227e:	e44e                	sd	s3,8(sp)
    80002280:	e052                	sd	s4,0(sp)
    80002282:	1800                	addi	s0,sp,48
    80002284:	892a                	mv	s2,a0
    80002286:	84ae                	mv	s1,a1
    80002288:	89b2                	mv	s3,a2
    8000228a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000228c:	e50ff0ef          	jal	800018dc <myproc>
  if(user_src){
    80002290:	cc99                	beqz	s1,800022ae <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002292:	86d2                	mv	a3,s4
    80002294:	864e                	mv	a2,s3
    80002296:	85ca                	mv	a1,s2
    80002298:	6928                	ld	a0,80(a0)
    8000229a:	b9aff0ef          	jal	80001634 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000229e:	70a2                	ld	ra,40(sp)
    800022a0:	7402                	ld	s0,32(sp)
    800022a2:	64e2                	ld	s1,24(sp)
    800022a4:	6942                	ld	s2,16(sp)
    800022a6:	69a2                	ld	s3,8(sp)
    800022a8:	6a02                	ld	s4,0(sp)
    800022aa:	6145                	addi	sp,sp,48
    800022ac:	8082                	ret
    memmove(dst, (char*)src, len);
    800022ae:	000a061b          	sext.w	a2,s4
    800022b2:	85ce                	mv	a1,s3
    800022b4:	854a                	mv	a0,s2
    800022b6:	a7dfe0ef          	jal	80000d32 <memmove>
    return 0;
    800022ba:	8526                	mv	a0,s1
    800022bc:	b7cd                	j	8000229e <either_copyin+0x2a>

00000000800022be <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022be:	715d                	addi	sp,sp,-80
    800022c0:	e486                	sd	ra,72(sp)
    800022c2:	e0a2                	sd	s0,64(sp)
    800022c4:	fc26                	sd	s1,56(sp)
    800022c6:	f84a                	sd	s2,48(sp)
    800022c8:	f44e                	sd	s3,40(sp)
    800022ca:	f052                	sd	s4,32(sp)
    800022cc:	ec56                	sd	s5,24(sp)
    800022ce:	e85a                	sd	s6,16(sp)
    800022d0:	e45e                	sd	s7,8(sp)
    800022d2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022d4:	00005517          	auipc	a0,0x5
    800022d8:	da450513          	addi	a0,a0,-604 # 80007078 <etext+0x78>
    800022dc:	9f2fe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022e0:	00010497          	auipc	s1,0x10
    800022e4:	6d848493          	addi	s1,s1,1752 # 800129b8 <proc+0x158>
    800022e8:	00019917          	auipc	s2,0x19
    800022ec:	0d090913          	addi	s2,s2,208 # 8001b3b8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022f0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022f2:	00005997          	auipc	s3,0x5
    800022f6:	fae98993          	addi	s3,s3,-82 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022fa:	00005a97          	auipc	s5,0x5
    800022fe:	faea8a93          	addi	s5,s5,-82 # 800072a8 <etext+0x2a8>
    printf("\n");
    80002302:	00005a17          	auipc	s4,0x5
    80002306:	d76a0a13          	addi	s4,s4,-650 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000230a:	00005b97          	auipc	s7,0x5
    8000230e:	47eb8b93          	addi	s7,s7,1150 # 80007788 <states.0>
    80002312:	a829                	j	8000232c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002314:	ed86a583          	lw	a1,-296(a3)
    80002318:	8556                	mv	a0,s5
    8000231a:	9b4fe0ef          	jal	800004ce <printf>
    printf("\n");
    8000231e:	8552                	mv	a0,s4
    80002320:	9aefe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002324:	22848493          	addi	s1,s1,552
    80002328:	03248263          	beq	s1,s2,8000234c <procdump+0x8e>
    if(p->state == UNUSED)
    8000232c:	86a6                	mv	a3,s1
    8000232e:	ec04a783          	lw	a5,-320(s1)
    80002332:	dbed                	beqz	a5,80002324 <procdump+0x66>
      state = "???";
    80002334:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002336:	fcfb6fe3          	bltu	s6,a5,80002314 <procdump+0x56>
    8000233a:	02079713          	slli	a4,a5,0x20
    8000233e:	01d75793          	srli	a5,a4,0x1d
    80002342:	97de                	add	a5,a5,s7
    80002344:	6390                	ld	a2,0(a5)
    80002346:	f679                	bnez	a2,80002314 <procdump+0x56>
      state = "???";
    80002348:	864e                	mv	a2,s3
    8000234a:	b7e9                	j	80002314 <procdump+0x56>
  }
}
    8000234c:	60a6                	ld	ra,72(sp)
    8000234e:	6406                	ld	s0,64(sp)
    80002350:	74e2                	ld	s1,56(sp)
    80002352:	7942                	ld	s2,48(sp)
    80002354:	79a2                	ld	s3,40(sp)
    80002356:	7a02                	ld	s4,32(sp)
    80002358:	6ae2                	ld	s5,24(sp)
    8000235a:	6b42                	ld	s6,16(sp)
    8000235c:	6ba2                	ld	s7,8(sp)
    8000235e:	6161                	addi	sp,sp,80
    80002360:	8082                	ret

0000000080002362 <swtch>:
    80002362:	00153023          	sd	ra,0(a0)
    80002366:	00253423          	sd	sp,8(a0)
    8000236a:	e900                	sd	s0,16(a0)
    8000236c:	ed04                	sd	s1,24(a0)
    8000236e:	03253023          	sd	s2,32(a0)
    80002372:	03353423          	sd	s3,40(a0)
    80002376:	03453823          	sd	s4,48(a0)
    8000237a:	03553c23          	sd	s5,56(a0)
    8000237e:	05653023          	sd	s6,64(a0)
    80002382:	05753423          	sd	s7,72(a0)
    80002386:	05853823          	sd	s8,80(a0)
    8000238a:	05953c23          	sd	s9,88(a0)
    8000238e:	07a53023          	sd	s10,96(a0)
    80002392:	07b53423          	sd	s11,104(a0)
    80002396:	0005b083          	ld	ra,0(a1)
    8000239a:	0085b103          	ld	sp,8(a1)
    8000239e:	6980                	ld	s0,16(a1)
    800023a0:	6d84                	ld	s1,24(a1)
    800023a2:	0205b903          	ld	s2,32(a1)
    800023a6:	0285b983          	ld	s3,40(a1)
    800023aa:	0305ba03          	ld	s4,48(a1)
    800023ae:	0385ba83          	ld	s5,56(a1)
    800023b2:	0405bb03          	ld	s6,64(a1)
    800023b6:	0485bb83          	ld	s7,72(a1)
    800023ba:	0505bc03          	ld	s8,80(a1)
    800023be:	0585bc83          	ld	s9,88(a1)
    800023c2:	0605bd03          	ld	s10,96(a1)
    800023c6:	0685bd83          	ld	s11,104(a1)
    800023ca:	8082                	ret

00000000800023cc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023cc:	1141                	addi	sp,sp,-16
    800023ce:	e406                	sd	ra,8(sp)
    800023d0:	e022                	sd	s0,0(sp)
    800023d2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023d4:	00005597          	auipc	a1,0x5
    800023d8:	f1458593          	addi	a1,a1,-236 # 800072e8 <etext+0x2e8>
    800023dc:	00019517          	auipc	a0,0x19
    800023e0:	e8450513          	addi	a0,a0,-380 # 8001b260 <tickslock>
    800023e4:	f96fe0ef          	jal	80000b7a <initlock>
}
    800023e8:	60a2                	ld	ra,8(sp)
    800023ea:	6402                	ld	s0,0(sp)
    800023ec:	0141                	addi	sp,sp,16
    800023ee:	8082                	ret

00000000800023f0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023f0:	1141                	addi	sp,sp,-16
    800023f2:	e406                	sd	ra,8(sp)
    800023f4:	e022                	sd	s0,0(sp)
    800023f6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023f8:	00003797          	auipc	a5,0x3
    800023fc:	eb878793          	addi	a5,a5,-328 # 800052b0 <kernelvec>
    80002400:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002404:	60a2                	ld	ra,8(sp)
    80002406:	6402                	ld	s0,0(sp)
    80002408:	0141                	addi	sp,sp,16
    8000240a:	8082                	ret

000000008000240c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000240c:	1141                	addi	sp,sp,-16
    8000240e:	e406                	sd	ra,8(sp)
    80002410:	e022                	sd	s0,0(sp)
    80002412:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002414:	cc8ff0ef          	jal	800018dc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002418:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000241c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000241e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002422:	00004697          	auipc	a3,0x4
    80002426:	bde68693          	addi	a3,a3,-1058 # 80006000 <_trampoline>
    8000242a:	00004717          	auipc	a4,0x4
    8000242e:	bd670713          	addi	a4,a4,-1066 # 80006000 <_trampoline>
    80002432:	8f15                	sub	a4,a4,a3
    80002434:	040007b7          	lui	a5,0x4000
    80002438:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000243a:	07b2                	slli	a5,a5,0xc
    8000243c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000243e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002442:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002444:	18002673          	csrr	a2,satp
    80002448:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000244a:	6d30                	ld	a2,88(a0)
    8000244c:	6138                	ld	a4,64(a0)
    8000244e:	6585                	lui	a1,0x1
    80002450:	972e                	add	a4,a4,a1
    80002452:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002454:	6d38                	ld	a4,88(a0)
    80002456:	00000617          	auipc	a2,0x0
    8000245a:	11060613          	addi	a2,a2,272 # 80002566 <usertrap>
    8000245e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002460:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002462:	8612                	mv	a2,tp
    80002464:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002466:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000246a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000246e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002472:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002476:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002478:	6f18                	ld	a4,24(a4)
    8000247a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000247e:	6928                	ld	a0,80(a0)
    80002480:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002482:	00004717          	auipc	a4,0x4
    80002486:	c1a70713          	addi	a4,a4,-998 # 8000609c <userret>
    8000248a:	8f15                	sub	a4,a4,a3
    8000248c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000248e:	577d                	li	a4,-1
    80002490:	177e                	slli	a4,a4,0x3f
    80002492:	8d59                	or	a0,a0,a4
    80002494:	9782                	jalr	a5
}
    80002496:	60a2                	ld	ra,8(sp)
    80002498:	6402                	ld	s0,0(sp)
    8000249a:	0141                	addi	sp,sp,16
    8000249c:	8082                	ret

000000008000249e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000249e:	1101                	addi	sp,sp,-32
    800024a0:	ec06                	sd	ra,24(sp)
    800024a2:	e822                	sd	s0,16(sp)
    800024a4:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024a6:	c02ff0ef          	jal	800018a8 <cpuid>
    800024aa:	cd11                	beqz	a0,800024c6 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024ac:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024b0:	000f4737          	lui	a4,0xf4
    800024b4:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024b8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stimecmp, %0" : : "r" (x));
    800024ba:	14d79073          	csrw	stimecmp,a5
}
    800024be:	60e2                	ld	ra,24(sp)
    800024c0:	6442                	ld	s0,16(sp)
    800024c2:	6105                	addi	sp,sp,32
    800024c4:	8082                	ret
    800024c6:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024c8:	00019497          	auipc	s1,0x19
    800024cc:	d9848493          	addi	s1,s1,-616 # 8001b260 <tickslock>
    800024d0:	8526                	mv	a0,s1
    800024d2:	f2cfe0ef          	jal	80000bfe <acquire>
    ticks++;
    800024d6:	00008517          	auipc	a0,0x8
    800024da:	e2a50513          	addi	a0,a0,-470 # 8000a300 <ticks>
    800024de:	411c                	lw	a5,0(a0)
    800024e0:	2785                	addiw	a5,a5,1
    800024e2:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024e4:	a3dff0ef          	jal	80001f20 <wakeup>
    release(&tickslock);
    800024e8:	8526                	mv	a0,s1
    800024ea:	fa8fe0ef          	jal	80000c92 <release>
    800024ee:	64a2                	ld	s1,8(sp)
    800024f0:	bf75                	j	800024ac <clockintr+0xe>

00000000800024f2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024f2:	1101                	addi	sp,sp,-32
    800024f4:	ec06                	sd	ra,24(sp)
    800024f6:	e822                	sd	s0,16(sp)
    800024f8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024fa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024fe:	57fd                	li	a5,-1
    80002500:	17fe                	slli	a5,a5,0x3f
    80002502:	07a5                	addi	a5,a5,9
    80002504:	00f70c63          	beq	a4,a5,8000251c <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002508:	57fd                	li	a5,-1
    8000250a:	17fe                	slli	a5,a5,0x3f
    8000250c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000250e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002510:	04f70763          	beq	a4,a5,8000255e <devintr+0x6c>
  }
}
    80002514:	60e2                	ld	ra,24(sp)
    80002516:	6442                	ld	s0,16(sp)
    80002518:	6105                	addi	sp,sp,32
    8000251a:	8082                	ret
    8000251c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000251e:	63f020ef          	jal	8000535c <plic_claim>
    80002522:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002524:	47a9                	li	a5,10
    80002526:	00f50963          	beq	a0,a5,80002538 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    8000252a:	4785                	li	a5,1
    8000252c:	00f50963          	beq	a0,a5,8000253e <devintr+0x4c>
    return 1;
    80002530:	4505                	li	a0,1
    } else if(irq){
    80002532:	e889                	bnez	s1,80002544 <devintr+0x52>
    80002534:	64a2                	ld	s1,8(sp)
    80002536:	bff9                	j	80002514 <devintr+0x22>
      uartintr();
    80002538:	cd4fe0ef          	jal	80000a0c <uartintr>
    if(irq)
    8000253c:	a819                	j	80002552 <devintr+0x60>
      virtio_disk_intr();
    8000253e:	2ae030ef          	jal	800057ec <virtio_disk_intr>
    if(irq)
    80002542:	a801                	j	80002552 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002544:	85a6                	mv	a1,s1
    80002546:	00005517          	auipc	a0,0x5
    8000254a:	daa50513          	addi	a0,a0,-598 # 800072f0 <etext+0x2f0>
    8000254e:	f81fd0ef          	jal	800004ce <printf>
      plic_complete(irq);
    80002552:	8526                	mv	a0,s1
    80002554:	629020ef          	jal	8000537c <plic_complete>
    return 1;
    80002558:	4505                	li	a0,1
    8000255a:	64a2                	ld	s1,8(sp)
    8000255c:	bf65                	j	80002514 <devintr+0x22>
    clockintr();
    8000255e:	f41ff0ef          	jal	8000249e <clockintr>
    return 2;
    80002562:	4509                	li	a0,2
    80002564:	bf45                	j	80002514 <devintr+0x22>

0000000080002566 <usertrap>:
{
    80002566:	1101                	addi	sp,sp,-32
    80002568:	ec06                	sd	ra,24(sp)
    8000256a:	e822                	sd	s0,16(sp)
    8000256c:	e426                	sd	s1,8(sp)
    8000256e:	e04a                	sd	s2,0(sp)
    80002570:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002572:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002576:	1007f793          	andi	a5,a5,256
    8000257a:	ef85                	bnez	a5,800025b2 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000257c:	00003797          	auipc	a5,0x3
    80002580:	d3478793          	addi	a5,a5,-716 # 800052b0 <kernelvec>
    80002584:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002588:	b54ff0ef          	jal	800018dc <myproc>
    8000258c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000258e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002590:	14102773          	csrr	a4,sepc
    80002594:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002596:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000259a:	47a1                	li	a5,8
    8000259c:	02f70163          	beq	a4,a5,800025be <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800025a0:	f53ff0ef          	jal	800024f2 <devintr>
    800025a4:	892a                	mv	s2,a0
    800025a6:	c135                	beqz	a0,8000260a <usertrap+0xa4>
  if(killed(p))
    800025a8:	8526                	mv	a0,s1
    800025aa:	b63ff0ef          	jal	8000210c <killed>
    800025ae:	cd1d                	beqz	a0,800025ec <usertrap+0x86>
    800025b0:	a81d                	j	800025e6 <usertrap+0x80>
    panic("usertrap: not from user mode");
    800025b2:	00005517          	auipc	a0,0x5
    800025b6:	d5e50513          	addi	a0,a0,-674 # 80007310 <etext+0x310>
    800025ba:	9e4fe0ef          	jal	8000079e <panic>
    if(killed(p))
    800025be:	b4fff0ef          	jal	8000210c <killed>
    800025c2:	e121                	bnez	a0,80002602 <usertrap+0x9c>
    p->trapframe->epc += 4;
    800025c4:	6cb8                	ld	a4,88(s1)
    800025c6:	6f1c                	ld	a5,24(a4)
    800025c8:	0791                	addi	a5,a5,4
    800025ca:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025cc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025d0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025d4:	10079073          	csrw	sstatus,a5
    syscall();
    800025d8:	240000ef          	jal	80002818 <syscall>
  if(killed(p))
    800025dc:	8526                	mv	a0,s1
    800025de:	b2fff0ef          	jal	8000210c <killed>
    800025e2:	c901                	beqz	a0,800025f2 <usertrap+0x8c>
    800025e4:	4901                	li	s2,0
    exit(-1);
    800025e6:	557d                	li	a0,-1
    800025e8:	9f9ff0ef          	jal	80001fe0 <exit>
  if(which_dev == 2)
    800025ec:	4789                	li	a5,2
    800025ee:	04f90563          	beq	s2,a5,80002638 <usertrap+0xd2>
  usertrapret();
    800025f2:	e1bff0ef          	jal	8000240c <usertrapret>
}
    800025f6:	60e2                	ld	ra,24(sp)
    800025f8:	6442                	ld	s0,16(sp)
    800025fa:	64a2                	ld	s1,8(sp)
    800025fc:	6902                	ld	s2,0(sp)
    800025fe:	6105                	addi	sp,sp,32
    80002600:	8082                	ret
      exit(-1);
    80002602:	557d                	li	a0,-1
    80002604:	9ddff0ef          	jal	80001fe0 <exit>
    80002608:	bf75                	j	800025c4 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000260a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000260e:	5890                	lw	a2,48(s1)
    80002610:	00005517          	auipc	a0,0x5
    80002614:	d2050513          	addi	a0,a0,-736 # 80007330 <etext+0x330>
    80002618:	eb7fd0ef          	jal	800004ce <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000261c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002620:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002624:	00005517          	auipc	a0,0x5
    80002628:	d3c50513          	addi	a0,a0,-708 # 80007360 <etext+0x360>
    8000262c:	ea3fd0ef          	jal	800004ce <printf>
    setkilled(p);
    80002630:	8526                	mv	a0,s1
    80002632:	ab7ff0ef          	jal	800020e8 <setkilled>
    80002636:	b75d                	j	800025dc <usertrap+0x76>
    yield();
    80002638:	871ff0ef          	jal	80001ea8 <yield>
    8000263c:	bf5d                	j	800025f2 <usertrap+0x8c>

000000008000263e <kerneltrap>:
{
    8000263e:	7179                	addi	sp,sp,-48
    80002640:	f406                	sd	ra,40(sp)
    80002642:	f022                	sd	s0,32(sp)
    80002644:	ec26                	sd	s1,24(sp)
    80002646:	e84a                	sd	s2,16(sp)
    80002648:	e44e                	sd	s3,8(sp)
    8000264a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000264c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002650:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002654:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002658:	1004f793          	andi	a5,s1,256
    8000265c:	c795                	beqz	a5,80002688 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000265e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002662:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002664:	eb85                	bnez	a5,80002694 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002666:	e8dff0ef          	jal	800024f2 <devintr>
    8000266a:	c91d                	beqz	a0,800026a0 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000266c:	4789                	li	a5,2
    8000266e:	04f50a63          	beq	a0,a5,800026c2 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002672:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002676:	10049073          	csrw	sstatus,s1
}
    8000267a:	70a2                	ld	ra,40(sp)
    8000267c:	7402                	ld	s0,32(sp)
    8000267e:	64e2                	ld	s1,24(sp)
    80002680:	6942                	ld	s2,16(sp)
    80002682:	69a2                	ld	s3,8(sp)
    80002684:	6145                	addi	sp,sp,48
    80002686:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002688:	00005517          	auipc	a0,0x5
    8000268c:	d0050513          	addi	a0,a0,-768 # 80007388 <etext+0x388>
    80002690:	90efe0ef          	jal	8000079e <panic>
    panic("kerneltrap: interrupts enabled");
    80002694:	00005517          	auipc	a0,0x5
    80002698:	d1c50513          	addi	a0,a0,-740 # 800073b0 <etext+0x3b0>
    8000269c:	902fe0ef          	jal	8000079e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026a0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026a4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026a8:	85ce                	mv	a1,s3
    800026aa:	00005517          	auipc	a0,0x5
    800026ae:	d2650513          	addi	a0,a0,-730 # 800073d0 <etext+0x3d0>
    800026b2:	e1dfd0ef          	jal	800004ce <printf>
    panic("kerneltrap");
    800026b6:	00005517          	auipc	a0,0x5
    800026ba:	d4250513          	addi	a0,a0,-702 # 800073f8 <etext+0x3f8>
    800026be:	8e0fe0ef          	jal	8000079e <panic>
  if(which_dev == 2 && myproc() != 0)
    800026c2:	a1aff0ef          	jal	800018dc <myproc>
    800026c6:	d555                	beqz	a0,80002672 <kerneltrap+0x34>
    yield();
    800026c8:	fe0ff0ef          	jal	80001ea8 <yield>
    800026cc:	b75d                	j	80002672 <kerneltrap+0x34>

00000000800026ce <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026ce:	1101                	addi	sp,sp,-32
    800026d0:	ec06                	sd	ra,24(sp)
    800026d2:	e822                	sd	s0,16(sp)
    800026d4:	e426                	sd	s1,8(sp)
    800026d6:	1000                	addi	s0,sp,32
    800026d8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026da:	a02ff0ef          	jal	800018dc <myproc>
  switch (n) {
    800026de:	4795                	li	a5,5
    800026e0:	0497e163          	bltu	a5,s1,80002722 <argraw+0x54>
    800026e4:	048a                	slli	s1,s1,0x2
    800026e6:	00005717          	auipc	a4,0x5
    800026ea:	0d270713          	addi	a4,a4,210 # 800077b8 <states.0+0x30>
    800026ee:	94ba                	add	s1,s1,a4
    800026f0:	409c                	lw	a5,0(s1)
    800026f2:	97ba                	add	a5,a5,a4
    800026f4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026f6:	6d3c                	ld	a5,88(a0)
    800026f8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800026fa:	60e2                	ld	ra,24(sp)
    800026fc:	6442                	ld	s0,16(sp)
    800026fe:	64a2                	ld	s1,8(sp)
    80002700:	6105                	addi	sp,sp,32
    80002702:	8082                	ret
    return p->trapframe->a1;
    80002704:	6d3c                	ld	a5,88(a0)
    80002706:	7fa8                	ld	a0,120(a5)
    80002708:	bfcd                	j	800026fa <argraw+0x2c>
    return p->trapframe->a2;
    8000270a:	6d3c                	ld	a5,88(a0)
    8000270c:	63c8                	ld	a0,128(a5)
    8000270e:	b7f5                	j	800026fa <argraw+0x2c>
    return p->trapframe->a3;
    80002710:	6d3c                	ld	a5,88(a0)
    80002712:	67c8                	ld	a0,136(a5)
    80002714:	b7dd                	j	800026fa <argraw+0x2c>
    return p->trapframe->a4;
    80002716:	6d3c                	ld	a5,88(a0)
    80002718:	6bc8                	ld	a0,144(a5)
    8000271a:	b7c5                	j	800026fa <argraw+0x2c>
    return p->trapframe->a5;
    8000271c:	6d3c                	ld	a5,88(a0)
    8000271e:	6fc8                	ld	a0,152(a5)
    80002720:	bfe9                	j	800026fa <argraw+0x2c>
  panic("argraw");
    80002722:	00005517          	auipc	a0,0x5
    80002726:	ce650513          	addi	a0,a0,-794 # 80007408 <etext+0x408>
    8000272a:	874fe0ef          	jal	8000079e <panic>

000000008000272e <fetchaddr>:
{
    8000272e:	1101                	addi	sp,sp,-32
    80002730:	ec06                	sd	ra,24(sp)
    80002732:	e822                	sd	s0,16(sp)
    80002734:	e426                	sd	s1,8(sp)
    80002736:	e04a                	sd	s2,0(sp)
    80002738:	1000                	addi	s0,sp,32
    8000273a:	84aa                	mv	s1,a0
    8000273c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000273e:	99eff0ef          	jal	800018dc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002742:	653c                	ld	a5,72(a0)
    80002744:	02f4f663          	bgeu	s1,a5,80002770 <fetchaddr+0x42>
    80002748:	00848713          	addi	a4,s1,8
    8000274c:	02e7e463          	bltu	a5,a4,80002774 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002750:	46a1                	li	a3,8
    80002752:	8626                	mv	a2,s1
    80002754:	85ca                	mv	a1,s2
    80002756:	6928                	ld	a0,80(a0)
    80002758:	eddfe0ef          	jal	80001634 <copyin>
    8000275c:	00a03533          	snez	a0,a0
    80002760:	40a0053b          	negw	a0,a0
}
    80002764:	60e2                	ld	ra,24(sp)
    80002766:	6442                	ld	s0,16(sp)
    80002768:	64a2                	ld	s1,8(sp)
    8000276a:	6902                	ld	s2,0(sp)
    8000276c:	6105                	addi	sp,sp,32
    8000276e:	8082                	ret
    return -1;
    80002770:	557d                	li	a0,-1
    80002772:	bfcd                	j	80002764 <fetchaddr+0x36>
    80002774:	557d                	li	a0,-1
    80002776:	b7fd                	j	80002764 <fetchaddr+0x36>

0000000080002778 <fetchstr>:
{
    80002778:	7179                	addi	sp,sp,-48
    8000277a:	f406                	sd	ra,40(sp)
    8000277c:	f022                	sd	s0,32(sp)
    8000277e:	ec26                	sd	s1,24(sp)
    80002780:	e84a                	sd	s2,16(sp)
    80002782:	e44e                	sd	s3,8(sp)
    80002784:	1800                	addi	s0,sp,48
    80002786:	892a                	mv	s2,a0
    80002788:	84ae                	mv	s1,a1
    8000278a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000278c:	950ff0ef          	jal	800018dc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002790:	86ce                	mv	a3,s3
    80002792:	864a                	mv	a2,s2
    80002794:	85a6                	mv	a1,s1
    80002796:	6928                	ld	a0,80(a0)
    80002798:	f23fe0ef          	jal	800016ba <copyinstr>
    8000279c:	00054c63          	bltz	a0,800027b4 <fetchstr+0x3c>
  return strlen(buf);
    800027a0:	8526                	mv	a0,s1
    800027a2:	eb4fe0ef          	jal	80000e56 <strlen>
}
    800027a6:	70a2                	ld	ra,40(sp)
    800027a8:	7402                	ld	s0,32(sp)
    800027aa:	64e2                	ld	s1,24(sp)
    800027ac:	6942                	ld	s2,16(sp)
    800027ae:	69a2                	ld	s3,8(sp)
    800027b0:	6145                	addi	sp,sp,48
    800027b2:	8082                	ret
    return -1;
    800027b4:	557d                	li	a0,-1
    800027b6:	bfc5                	j	800027a6 <fetchstr+0x2e>

00000000800027b8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027b8:	1101                	addi	sp,sp,-32
    800027ba:	ec06                	sd	ra,24(sp)
    800027bc:	e822                	sd	s0,16(sp)
    800027be:	e426                	sd	s1,8(sp)
    800027c0:	1000                	addi	s0,sp,32
    800027c2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027c4:	f0bff0ef          	jal	800026ce <argraw>
    800027c8:	c088                	sw	a0,0(s1)
}
    800027ca:	60e2                	ld	ra,24(sp)
    800027cc:	6442                	ld	s0,16(sp)
    800027ce:	64a2                	ld	s1,8(sp)
    800027d0:	6105                	addi	sp,sp,32
    800027d2:	8082                	ret

00000000800027d4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027d4:	1101                	addi	sp,sp,-32
    800027d6:	ec06                	sd	ra,24(sp)
    800027d8:	e822                	sd	s0,16(sp)
    800027da:	e426                	sd	s1,8(sp)
    800027dc:	1000                	addi	s0,sp,32
    800027de:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027e0:	eefff0ef          	jal	800026ce <argraw>
    800027e4:	e088                	sd	a0,0(s1)
}
    800027e6:	60e2                	ld	ra,24(sp)
    800027e8:	6442                	ld	s0,16(sp)
    800027ea:	64a2                	ld	s1,8(sp)
    800027ec:	6105                	addi	sp,sp,32
    800027ee:	8082                	ret

00000000800027f0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027f0:	1101                	addi	sp,sp,-32
    800027f2:	ec06                	sd	ra,24(sp)
    800027f4:	e822                	sd	s0,16(sp)
    800027f6:	e426                	sd	s1,8(sp)
    800027f8:	e04a                	sd	s2,0(sp)
    800027fa:	1000                	addi	s0,sp,32
    800027fc:	84ae                	mv	s1,a1
    800027fe:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002800:	ecfff0ef          	jal	800026ce <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002804:	864a                	mv	a2,s2
    80002806:	85a6                	mv	a1,s1
    80002808:	f71ff0ef          	jal	80002778 <fetchstr>
}
    8000280c:	60e2                	ld	ra,24(sp)
    8000280e:	6442                	ld	s0,16(sp)
    80002810:	64a2                	ld	s1,8(sp)
    80002812:	6902                	ld	s2,0(sp)
    80002814:	6105                	addi	sp,sp,32
    80002816:	8082                	ret

0000000080002818 <syscall>:
};


void
syscall(void)
{
    80002818:	1101                	addi	sp,sp,-32
    8000281a:	ec06                	sd	ra,24(sp)
    8000281c:	e822                	sd	s0,16(sp)
    8000281e:	e426                	sd	s1,8(sp)
    80002820:	e04a                	sd	s2,0(sp)
    80002822:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002824:	8b8ff0ef          	jal	800018dc <myproc>
    80002828:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000282a:	05853903          	ld	s2,88(a0)
    8000282e:	0a893783          	ld	a5,168(s2)
    80002832:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002836:	37fd                	addiw	a5,a5,-1
    80002838:	4755                	li	a4,21
    8000283a:	02f76763          	bltu	a4,a5,80002868 <syscall+0x50>
    8000283e:	00369713          	slli	a4,a3,0x3
    80002842:	00005797          	auipc	a5,0x5
    80002846:	f8e78793          	addi	a5,a5,-114 # 800077d0 <syscalls>
    8000284a:	97ba                	add	a5,a5,a4
    8000284c:	6398                	ld	a4,0(a5)
    8000284e:	cf09                	beqz	a4,80002868 <syscall+0x50>
    // increment count of syscall
    p->syscall_counts[num]++;
    80002850:	068e                	slli	a3,a3,0x3
    80002852:	00d504b3          	add	s1,a0,a3
    80002856:	1684b783          	ld	a5,360(s1)
    8000285a:	0785                	addi	a5,a5,1
    8000285c:	16f4b423          	sd	a5,360(s1)
        //printsyscall(num);
        //printf(" [syscall %d is run %ld times]\n", num, p->syscall_counts[num]);
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002860:	9702                	jalr	a4
    80002862:	06a93823          	sd	a0,112(s2)
    80002866:	a829                	j	80002880 <syscall+0x68>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002868:	15848613          	addi	a2,s1,344
    8000286c:	588c                	lw	a1,48(s1)
    8000286e:	00005517          	auipc	a0,0x5
    80002872:	ba250513          	addi	a0,a0,-1118 # 80007410 <etext+0x410>
    80002876:	c59fd0ef          	jal	800004ce <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000287a:	6cbc                	ld	a5,88(s1)
    8000287c:	577d                	li	a4,-1
    8000287e:	fbb8                	sd	a4,112(a5)
  }
}
    80002880:	60e2                	ld	ra,24(sp)
    80002882:	6442                	ld	s0,16(sp)
    80002884:	64a2                	ld	s1,8(sp)
    80002886:	6902                	ld	s2,0(sp)
    80002888:	6105                	addi	sp,sp,32
    8000288a:	8082                	ret

000000008000288c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000288c:	1101                	addi	sp,sp,-32
    8000288e:	ec06                	sd	ra,24(sp)
    80002890:	e822                	sd	s0,16(sp)
    80002892:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002894:	fec40593          	addi	a1,s0,-20
    80002898:	4501                	li	a0,0
    8000289a:	f1fff0ef          	jal	800027b8 <argint>
  exit(n);
    8000289e:	fec42503          	lw	a0,-20(s0)
    800028a2:	f3eff0ef          	jal	80001fe0 <exit>
  return 0;  // not reached
}
    800028a6:	4501                	li	a0,0
    800028a8:	60e2                	ld	ra,24(sp)
    800028aa:	6442                	ld	s0,16(sp)
    800028ac:	6105                	addi	sp,sp,32
    800028ae:	8082                	ret

00000000800028b0 <sys_getpid>:

uint64
sys_getpid(void)
{
    800028b0:	1141                	addi	sp,sp,-16
    800028b2:	e406                	sd	ra,8(sp)
    800028b4:	e022                	sd	s0,0(sp)
    800028b6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028b8:	824ff0ef          	jal	800018dc <myproc>
}
    800028bc:	5908                	lw	a0,48(a0)
    800028be:	60a2                	ld	ra,8(sp)
    800028c0:	6402                	ld	s0,0(sp)
    800028c2:	0141                	addi	sp,sp,16
    800028c4:	8082                	ret

00000000800028c6 <sys_fork>:

uint64
sys_fork(void)
{
    800028c6:	1141                	addi	sp,sp,-16
    800028c8:	e406                	sd	ra,8(sp)
    800028ca:	e022                	sd	s0,0(sp)
    800028cc:	0800                	addi	s0,sp,16
  return fork();
    800028ce:	b46ff0ef          	jal	80001c14 <fork>
}
    800028d2:	60a2                	ld	ra,8(sp)
    800028d4:	6402                	ld	s0,0(sp)
    800028d6:	0141                	addi	sp,sp,16
    800028d8:	8082                	ret

00000000800028da <sys_wait>:

uint64
sys_wait(void)
{
    800028da:	1101                	addi	sp,sp,-32
    800028dc:	ec06                	sd	ra,24(sp)
    800028de:	e822                	sd	s0,16(sp)
    800028e0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028e2:	fe840593          	addi	a1,s0,-24
    800028e6:	4501                	li	a0,0
    800028e8:	eedff0ef          	jal	800027d4 <argaddr>
  return wait(p);
    800028ec:	fe843503          	ld	a0,-24(s0)
    800028f0:	847ff0ef          	jal	80002136 <wait>
}
    800028f4:	60e2                	ld	ra,24(sp)
    800028f6:	6442                	ld	s0,16(sp)
    800028f8:	6105                	addi	sp,sp,32
    800028fa:	8082                	ret

00000000800028fc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800028fc:	7179                	addi	sp,sp,-48
    800028fe:	f406                	sd	ra,40(sp)
    80002900:	f022                	sd	s0,32(sp)
    80002902:	ec26                	sd	s1,24(sp)
    80002904:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002906:	fdc40593          	addi	a1,s0,-36
    8000290a:	4501                	li	a0,0
    8000290c:	eadff0ef          	jal	800027b8 <argint>
  addr = myproc()->sz;
    80002910:	fcdfe0ef          	jal	800018dc <myproc>
    80002914:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002916:	fdc42503          	lw	a0,-36(s0)
    8000291a:	aaaff0ef          	jal	80001bc4 <growproc>
    8000291e:	00054863          	bltz	a0,8000292e <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002922:	8526                	mv	a0,s1
    80002924:	70a2                	ld	ra,40(sp)
    80002926:	7402                	ld	s0,32(sp)
    80002928:	64e2                	ld	s1,24(sp)
    8000292a:	6145                	addi	sp,sp,48
    8000292c:	8082                	ret
    return -1;
    8000292e:	54fd                	li	s1,-1
    80002930:	bfcd                	j	80002922 <sys_sbrk+0x26>

0000000080002932 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002932:	7139                	addi	sp,sp,-64
    80002934:	fc06                	sd	ra,56(sp)
    80002936:	f822                	sd	s0,48(sp)
    80002938:	f04a                	sd	s2,32(sp)
    8000293a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000293c:	fcc40593          	addi	a1,s0,-52
    80002940:	4501                	li	a0,0
    80002942:	e77ff0ef          	jal	800027b8 <argint>
  if(n < 0)
    80002946:	fcc42783          	lw	a5,-52(s0)
    8000294a:	0607c763          	bltz	a5,800029b8 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    8000294e:	00019517          	auipc	a0,0x19
    80002952:	91250513          	addi	a0,a0,-1774 # 8001b260 <tickslock>
    80002956:	aa8fe0ef          	jal	80000bfe <acquire>
  ticks0 = ticks;
    8000295a:	00008917          	auipc	s2,0x8
    8000295e:	9a692903          	lw	s2,-1626(s2) # 8000a300 <ticks>
  while(ticks - ticks0 < n){
    80002962:	fcc42783          	lw	a5,-52(s0)
    80002966:	cf8d                	beqz	a5,800029a0 <sys_sleep+0x6e>
    80002968:	f426                	sd	s1,40(sp)
    8000296a:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000296c:	00019997          	auipc	s3,0x19
    80002970:	8f498993          	addi	s3,s3,-1804 # 8001b260 <tickslock>
    80002974:	00008497          	auipc	s1,0x8
    80002978:	98c48493          	addi	s1,s1,-1652 # 8000a300 <ticks>
    if(killed(myproc())){
    8000297c:	f61fe0ef          	jal	800018dc <myproc>
    80002980:	f8cff0ef          	jal	8000210c <killed>
    80002984:	ed0d                	bnez	a0,800029be <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002986:	85ce                	mv	a1,s3
    80002988:	8526                	mv	a0,s1
    8000298a:	d4aff0ef          	jal	80001ed4 <sleep>
  while(ticks - ticks0 < n){
    8000298e:	409c                	lw	a5,0(s1)
    80002990:	412787bb          	subw	a5,a5,s2
    80002994:	fcc42703          	lw	a4,-52(s0)
    80002998:	fee7e2e3          	bltu	a5,a4,8000297c <sys_sleep+0x4a>
    8000299c:	74a2                	ld	s1,40(sp)
    8000299e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029a0:	00019517          	auipc	a0,0x19
    800029a4:	8c050513          	addi	a0,a0,-1856 # 8001b260 <tickslock>
    800029a8:	aeafe0ef          	jal	80000c92 <release>
  return 0;
    800029ac:	4501                	li	a0,0
}
    800029ae:	70e2                	ld	ra,56(sp)
    800029b0:	7442                	ld	s0,48(sp)
    800029b2:	7902                	ld	s2,32(sp)
    800029b4:	6121                	addi	sp,sp,64
    800029b6:	8082                	ret
    n = 0;
    800029b8:	fc042623          	sw	zero,-52(s0)
    800029bc:	bf49                	j	8000294e <sys_sleep+0x1c>
      release(&tickslock);
    800029be:	00019517          	auipc	a0,0x19
    800029c2:	8a250513          	addi	a0,a0,-1886 # 8001b260 <tickslock>
    800029c6:	accfe0ef          	jal	80000c92 <release>
      return -1;
    800029ca:	557d                	li	a0,-1
    800029cc:	74a2                	ld	s1,40(sp)
    800029ce:	69e2                	ld	s3,24(sp)
    800029d0:	bff9                	j	800029ae <sys_sleep+0x7c>

00000000800029d2 <sys_kill>:

uint64
sys_kill(void)
{
    800029d2:	1101                	addi	sp,sp,-32
    800029d4:	ec06                	sd	ra,24(sp)
    800029d6:	e822                	sd	s0,16(sp)
    800029d8:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800029da:	fec40593          	addi	a1,s0,-20
    800029de:	4501                	li	a0,0
    800029e0:	dd9ff0ef          	jal	800027b8 <argint>
  return kill(pid);
    800029e4:	fec42503          	lw	a0,-20(s0)
    800029e8:	e9aff0ef          	jal	80002082 <kill>
}
    800029ec:	60e2                	ld	ra,24(sp)
    800029ee:	6442                	ld	s0,16(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret

00000000800029f4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800029f4:	1101                	addi	sp,sp,-32
    800029f6:	ec06                	sd	ra,24(sp)
    800029f8:	e822                	sd	s0,16(sp)
    800029fa:	e426                	sd	s1,8(sp)
    800029fc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800029fe:	00019517          	auipc	a0,0x19
    80002a02:	86250513          	addi	a0,a0,-1950 # 8001b260 <tickslock>
    80002a06:	9f8fe0ef          	jal	80000bfe <acquire>
  xticks = ticks;
    80002a0a:	00008497          	auipc	s1,0x8
    80002a0e:	8f64a483          	lw	s1,-1802(s1) # 8000a300 <ticks>
  release(&tickslock);
    80002a12:	00019517          	auipc	a0,0x19
    80002a16:	84e50513          	addi	a0,a0,-1970 # 8001b260 <tickslock>
    80002a1a:	a78fe0ef          	jal	80000c92 <release>
  return xticks;
}
    80002a1e:	02049513          	slli	a0,s1,0x20
    80002a22:	9101                	srli	a0,a0,0x20
    80002a24:	60e2                	ld	ra,24(sp)
    80002a26:	6442                	ld	s0,16(sp)
    80002a28:	64a2                	ld	s1,8(sp)
    80002a2a:	6105                	addi	sp,sp,32
    80002a2c:	8082                	ret

0000000080002a2e <sys_getsyscount>:

uint64
sys_getsyscount(void)
{
    80002a2e:	7179                	addi	sp,sp,-48
    80002a30:	f406                	sd	ra,40(sp)
    80002a32:	f022                	sd	s0,32(sp)
    80002a34:	1800                	addi	s0,sp,48
  int mask;
  argint(0, &mask);
    80002a36:	fdc40593          	addi	a1,s0,-36
    80002a3a:	4501                	li	a0,0
    80002a3c:	d7dff0ef          	jal	800027b8 <argint>
  if(mask < 0)
    80002a40:	fdc42703          	lw	a4,-36(s0)
    80002a44:	04074063          	bltz	a4,80002a84 <sys_getsyscount+0x56>
    80002a48:	ec26                	sd	s1,24(sp)
    return -1;
  
  // Find the syscall number from the mask
  int syscall_num = -1;
  for(int i = 0; i < 32; i++) {
    80002a4a:	4481                	li	s1,0
    if(mask == (1 << i)) {
    80002a4c:	4685                	li	a3,1
  for(int i = 0; i < 32; i++) {
    80002a4e:	02000613          	li	a2,32
    if(mask == (1 << i)) {
    80002a52:	009697bb          	sllw	a5,a3,s1
    80002a56:	00e78863          	beq	a5,a4,80002a66 <sys_getsyscount+0x38>
  for(int i = 0; i < 32; i++) {
    80002a5a:	2485                	addiw	s1,s1,1
    80002a5c:	fec49be3          	bne	s1,a2,80002a52 <sys_getsyscount+0x24>
      break;
    }
  }
  
  if(syscall_num == -1)
    return -1;
    80002a60:	557d                	li	a0,-1
    80002a62:	64e2                	ld	s1,24(sp)
    80002a64:	a821                	j	80002a7c <sys_getsyscount+0x4e>
  if(syscall_num == -1)
    80002a66:	57fd                	li	a5,-1
    80002a68:	02f48063          	beq	s1,a5,80002a88 <sys_getsyscount+0x5a>
  struct proc *p = myproc();
    80002a6c:	e71fe0ef          	jal	800018dc <myproc>
  return p->syscall_counts[syscall_num];
    80002a70:	02c48493          	addi	s1,s1,44
    80002a74:	048e                	slli	s1,s1,0x3
    80002a76:	9526                	add	a0,a0,s1
    80002a78:	6508                	ld	a0,8(a0)
    80002a7a:	64e2                	ld	s1,24(sp)
    80002a7c:	70a2                	ld	ra,40(sp)
    80002a7e:	7402                	ld	s0,32(sp)
    80002a80:	6145                	addi	sp,sp,48
    80002a82:	8082                	ret
    return -1;
    80002a84:	557d                	li	a0,-1
    80002a86:	bfdd                	j	80002a7c <sys_getsyscount+0x4e>
    return -1;
    80002a88:	557d                	li	a0,-1
    80002a8a:	64e2                	ld	s1,24(sp)
    80002a8c:	bfc5                	j	80002a7c <sys_getsyscount+0x4e>

0000000080002a8e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a8e:	7179                	addi	sp,sp,-48
    80002a90:	f406                	sd	ra,40(sp)
    80002a92:	f022                	sd	s0,32(sp)
    80002a94:	ec26                	sd	s1,24(sp)
    80002a96:	e84a                	sd	s2,16(sp)
    80002a98:	e44e                	sd	s3,8(sp)
    80002a9a:	e052                	sd	s4,0(sp)
    80002a9c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002a9e:	00005597          	auipc	a1,0x5
    80002aa2:	99258593          	addi	a1,a1,-1646 # 80007430 <etext+0x430>
    80002aa6:	00018517          	auipc	a0,0x18
    80002aaa:	7d250513          	addi	a0,a0,2002 # 8001b278 <bcache>
    80002aae:	8ccfe0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ab2:	00020797          	auipc	a5,0x20
    80002ab6:	7c678793          	addi	a5,a5,1990 # 80023278 <bcache+0x8000>
    80002aba:	00021717          	auipc	a4,0x21
    80002abe:	a2670713          	addi	a4,a4,-1498 # 800234e0 <bcache+0x8268>
    80002ac2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ac6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002aca:	00018497          	auipc	s1,0x18
    80002ace:	7c648493          	addi	s1,s1,1990 # 8001b290 <bcache+0x18>
    b->next = bcache.head.next;
    80002ad2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ad4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ad6:	00005a17          	auipc	s4,0x5
    80002ada:	962a0a13          	addi	s4,s4,-1694 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002ade:	2b893783          	ld	a5,696(s2)
    80002ae2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ae4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ae8:	85d2                	mv	a1,s4
    80002aea:	01048513          	addi	a0,s1,16
    80002aee:	244010ef          	jal	80003d32 <initsleeplock>
    bcache.head.next->prev = b;
    80002af2:	2b893783          	ld	a5,696(s2)
    80002af6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002af8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002afc:	45848493          	addi	s1,s1,1112
    80002b00:	fd349fe3          	bne	s1,s3,80002ade <binit+0x50>
  }
}
    80002b04:	70a2                	ld	ra,40(sp)
    80002b06:	7402                	ld	s0,32(sp)
    80002b08:	64e2                	ld	s1,24(sp)
    80002b0a:	6942                	ld	s2,16(sp)
    80002b0c:	69a2                	ld	s3,8(sp)
    80002b0e:	6a02                	ld	s4,0(sp)
    80002b10:	6145                	addi	sp,sp,48
    80002b12:	8082                	ret

0000000080002b14 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b14:	7179                	addi	sp,sp,-48
    80002b16:	f406                	sd	ra,40(sp)
    80002b18:	f022                	sd	s0,32(sp)
    80002b1a:	ec26                	sd	s1,24(sp)
    80002b1c:	e84a                	sd	s2,16(sp)
    80002b1e:	e44e                	sd	s3,8(sp)
    80002b20:	1800                	addi	s0,sp,48
    80002b22:	892a                	mv	s2,a0
    80002b24:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b26:	00018517          	auipc	a0,0x18
    80002b2a:	75250513          	addi	a0,a0,1874 # 8001b278 <bcache>
    80002b2e:	8d0fe0ef          	jal	80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b32:	00021497          	auipc	s1,0x21
    80002b36:	9fe4b483          	ld	s1,-1538(s1) # 80023530 <bcache+0x82b8>
    80002b3a:	00021797          	auipc	a5,0x21
    80002b3e:	9a678793          	addi	a5,a5,-1626 # 800234e0 <bcache+0x8268>
    80002b42:	02f48b63          	beq	s1,a5,80002b78 <bread+0x64>
    80002b46:	873e                	mv	a4,a5
    80002b48:	a021                	j	80002b50 <bread+0x3c>
    80002b4a:	68a4                	ld	s1,80(s1)
    80002b4c:	02e48663          	beq	s1,a4,80002b78 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b50:	449c                	lw	a5,8(s1)
    80002b52:	ff279ce3          	bne	a5,s2,80002b4a <bread+0x36>
    80002b56:	44dc                	lw	a5,12(s1)
    80002b58:	ff3799e3          	bne	a5,s3,80002b4a <bread+0x36>
      b->refcnt++;
    80002b5c:	40bc                	lw	a5,64(s1)
    80002b5e:	2785                	addiw	a5,a5,1
    80002b60:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b62:	00018517          	auipc	a0,0x18
    80002b66:	71650513          	addi	a0,a0,1814 # 8001b278 <bcache>
    80002b6a:	928fe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002b6e:	01048513          	addi	a0,s1,16
    80002b72:	1f6010ef          	jal	80003d68 <acquiresleep>
      return b;
    80002b76:	a889                	j	80002bc8 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b78:	00021497          	auipc	s1,0x21
    80002b7c:	9b04b483          	ld	s1,-1616(s1) # 80023528 <bcache+0x82b0>
    80002b80:	00021797          	auipc	a5,0x21
    80002b84:	96078793          	addi	a5,a5,-1696 # 800234e0 <bcache+0x8268>
    80002b88:	00f48863          	beq	s1,a5,80002b98 <bread+0x84>
    80002b8c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002b8e:	40bc                	lw	a5,64(s1)
    80002b90:	cb91                	beqz	a5,80002ba4 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b92:	64a4                	ld	s1,72(s1)
    80002b94:	fee49de3          	bne	s1,a4,80002b8e <bread+0x7a>
  panic("bget: no buffers");
    80002b98:	00005517          	auipc	a0,0x5
    80002b9c:	8a850513          	addi	a0,a0,-1880 # 80007440 <etext+0x440>
    80002ba0:	bfffd0ef          	jal	8000079e <panic>
      b->dev = dev;
    80002ba4:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ba8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002bac:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bb0:	4785                	li	a5,1
    80002bb2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bb4:	00018517          	auipc	a0,0x18
    80002bb8:	6c450513          	addi	a0,a0,1732 # 8001b278 <bcache>
    80002bbc:	8d6fe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002bc0:	01048513          	addi	a0,s1,16
    80002bc4:	1a4010ef          	jal	80003d68 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002bc8:	409c                	lw	a5,0(s1)
    80002bca:	cb89                	beqz	a5,80002bdc <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002bcc:	8526                	mv	a0,s1
    80002bce:	70a2                	ld	ra,40(sp)
    80002bd0:	7402                	ld	s0,32(sp)
    80002bd2:	64e2                	ld	s1,24(sp)
    80002bd4:	6942                	ld	s2,16(sp)
    80002bd6:	69a2                	ld	s3,8(sp)
    80002bd8:	6145                	addi	sp,sp,48
    80002bda:	8082                	ret
    virtio_disk_rw(b, 0);
    80002bdc:	4581                	li	a1,0
    80002bde:	8526                	mv	a0,s1
    80002be0:	201020ef          	jal	800055e0 <virtio_disk_rw>
    b->valid = 1;
    80002be4:	4785                	li	a5,1
    80002be6:	c09c                	sw	a5,0(s1)
  return b;
    80002be8:	b7d5                	j	80002bcc <bread+0xb8>

0000000080002bea <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002bea:	1101                	addi	sp,sp,-32
    80002bec:	ec06                	sd	ra,24(sp)
    80002bee:	e822                	sd	s0,16(sp)
    80002bf0:	e426                	sd	s1,8(sp)
    80002bf2:	1000                	addi	s0,sp,32
    80002bf4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002bf6:	0541                	addi	a0,a0,16
    80002bf8:	1ee010ef          	jal	80003de6 <holdingsleep>
    80002bfc:	c911                	beqz	a0,80002c10 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002bfe:	4585                	li	a1,1
    80002c00:	8526                	mv	a0,s1
    80002c02:	1df020ef          	jal	800055e0 <virtio_disk_rw>
}
    80002c06:	60e2                	ld	ra,24(sp)
    80002c08:	6442                	ld	s0,16(sp)
    80002c0a:	64a2                	ld	s1,8(sp)
    80002c0c:	6105                	addi	sp,sp,32
    80002c0e:	8082                	ret
    panic("bwrite");
    80002c10:	00005517          	auipc	a0,0x5
    80002c14:	84850513          	addi	a0,a0,-1976 # 80007458 <etext+0x458>
    80002c18:	b87fd0ef          	jal	8000079e <panic>

0000000080002c1c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c1c:	1101                	addi	sp,sp,-32
    80002c1e:	ec06                	sd	ra,24(sp)
    80002c20:	e822                	sd	s0,16(sp)
    80002c22:	e426                	sd	s1,8(sp)
    80002c24:	e04a                	sd	s2,0(sp)
    80002c26:	1000                	addi	s0,sp,32
    80002c28:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c2a:	01050913          	addi	s2,a0,16
    80002c2e:	854a                	mv	a0,s2
    80002c30:	1b6010ef          	jal	80003de6 <holdingsleep>
    80002c34:	c125                	beqz	a0,80002c94 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002c36:	854a                	mv	a0,s2
    80002c38:	176010ef          	jal	80003dae <releasesleep>

  acquire(&bcache.lock);
    80002c3c:	00018517          	auipc	a0,0x18
    80002c40:	63c50513          	addi	a0,a0,1596 # 8001b278 <bcache>
    80002c44:	fbbfd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002c48:	40bc                	lw	a5,64(s1)
    80002c4a:	37fd                	addiw	a5,a5,-1
    80002c4c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c4e:	e79d                	bnez	a5,80002c7c <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c50:	68b8                	ld	a4,80(s1)
    80002c52:	64bc                	ld	a5,72(s1)
    80002c54:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c56:	68b8                	ld	a4,80(s1)
    80002c58:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c5a:	00020797          	auipc	a5,0x20
    80002c5e:	61e78793          	addi	a5,a5,1566 # 80023278 <bcache+0x8000>
    80002c62:	2b87b703          	ld	a4,696(a5)
    80002c66:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c68:	00021717          	auipc	a4,0x21
    80002c6c:	87870713          	addi	a4,a4,-1928 # 800234e0 <bcache+0x8268>
    80002c70:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c72:	2b87b703          	ld	a4,696(a5)
    80002c76:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c78:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002c7c:	00018517          	auipc	a0,0x18
    80002c80:	5fc50513          	addi	a0,a0,1532 # 8001b278 <bcache>
    80002c84:	80efe0ef          	jal	80000c92 <release>
}
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	64a2                	ld	s1,8(sp)
    80002c8e:	6902                	ld	s2,0(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret
    panic("brelse");
    80002c94:	00004517          	auipc	a0,0x4
    80002c98:	7cc50513          	addi	a0,a0,1996 # 80007460 <etext+0x460>
    80002c9c:	b03fd0ef          	jal	8000079e <panic>

0000000080002ca0 <bpin>:

void
bpin(struct buf *b) {
    80002ca0:	1101                	addi	sp,sp,-32
    80002ca2:	ec06                	sd	ra,24(sp)
    80002ca4:	e822                	sd	s0,16(sp)
    80002ca6:	e426                	sd	s1,8(sp)
    80002ca8:	1000                	addi	s0,sp,32
    80002caa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cac:	00018517          	auipc	a0,0x18
    80002cb0:	5cc50513          	addi	a0,a0,1484 # 8001b278 <bcache>
    80002cb4:	f4bfd0ef          	jal	80000bfe <acquire>
  b->refcnt++;
    80002cb8:	40bc                	lw	a5,64(s1)
    80002cba:	2785                	addiw	a5,a5,1
    80002cbc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cbe:	00018517          	auipc	a0,0x18
    80002cc2:	5ba50513          	addi	a0,a0,1466 # 8001b278 <bcache>
    80002cc6:	fcdfd0ef          	jal	80000c92 <release>
}
    80002cca:	60e2                	ld	ra,24(sp)
    80002ccc:	6442                	ld	s0,16(sp)
    80002cce:	64a2                	ld	s1,8(sp)
    80002cd0:	6105                	addi	sp,sp,32
    80002cd2:	8082                	ret

0000000080002cd4 <bunpin>:

void
bunpin(struct buf *b) {
    80002cd4:	1101                	addi	sp,sp,-32
    80002cd6:	ec06                	sd	ra,24(sp)
    80002cd8:	e822                	sd	s0,16(sp)
    80002cda:	e426                	sd	s1,8(sp)
    80002cdc:	1000                	addi	s0,sp,32
    80002cde:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ce0:	00018517          	auipc	a0,0x18
    80002ce4:	59850513          	addi	a0,a0,1432 # 8001b278 <bcache>
    80002ce8:	f17fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002cec:	40bc                	lw	a5,64(s1)
    80002cee:	37fd                	addiw	a5,a5,-1
    80002cf0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cf2:	00018517          	auipc	a0,0x18
    80002cf6:	58650513          	addi	a0,a0,1414 # 8001b278 <bcache>
    80002cfa:	f99fd0ef          	jal	80000c92 <release>
}
    80002cfe:	60e2                	ld	ra,24(sp)
    80002d00:	6442                	ld	s0,16(sp)
    80002d02:	64a2                	ld	s1,8(sp)
    80002d04:	6105                	addi	sp,sp,32
    80002d06:	8082                	ret

0000000080002d08 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d08:	1101                	addi	sp,sp,-32
    80002d0a:	ec06                	sd	ra,24(sp)
    80002d0c:	e822                	sd	s0,16(sp)
    80002d0e:	e426                	sd	s1,8(sp)
    80002d10:	e04a                	sd	s2,0(sp)
    80002d12:	1000                	addi	s0,sp,32
    80002d14:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d16:	00d5d79b          	srliw	a5,a1,0xd
    80002d1a:	00021597          	auipc	a1,0x21
    80002d1e:	c3a5a583          	lw	a1,-966(a1) # 80023954 <sb+0x1c>
    80002d22:	9dbd                	addw	a1,a1,a5
    80002d24:	df1ff0ef          	jal	80002b14 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d28:	0074f713          	andi	a4,s1,7
    80002d2c:	4785                	li	a5,1
    80002d2e:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002d32:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002d34:	90d9                	srli	s1,s1,0x36
    80002d36:	00950733          	add	a4,a0,s1
    80002d3a:	05874703          	lbu	a4,88(a4)
    80002d3e:	00e7f6b3          	and	a3,a5,a4
    80002d42:	c29d                	beqz	a3,80002d68 <bfree+0x60>
    80002d44:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d46:	94aa                	add	s1,s1,a0
    80002d48:	fff7c793          	not	a5,a5
    80002d4c:	8f7d                	and	a4,a4,a5
    80002d4e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d52:	711000ef          	jal	80003c62 <log_write>
  brelse(bp);
    80002d56:	854a                	mv	a0,s2
    80002d58:	ec5ff0ef          	jal	80002c1c <brelse>
}
    80002d5c:	60e2                	ld	ra,24(sp)
    80002d5e:	6442                	ld	s0,16(sp)
    80002d60:	64a2                	ld	s1,8(sp)
    80002d62:	6902                	ld	s2,0(sp)
    80002d64:	6105                	addi	sp,sp,32
    80002d66:	8082                	ret
    panic("freeing free block");
    80002d68:	00004517          	auipc	a0,0x4
    80002d6c:	70050513          	addi	a0,a0,1792 # 80007468 <etext+0x468>
    80002d70:	a2ffd0ef          	jal	8000079e <panic>

0000000080002d74 <balloc>:
{
    80002d74:	715d                	addi	sp,sp,-80
    80002d76:	e486                	sd	ra,72(sp)
    80002d78:	e0a2                	sd	s0,64(sp)
    80002d7a:	fc26                	sd	s1,56(sp)
    80002d7c:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002d7e:	00021797          	auipc	a5,0x21
    80002d82:	bbe7a783          	lw	a5,-1090(a5) # 8002393c <sb+0x4>
    80002d86:	0e078863          	beqz	a5,80002e76 <balloc+0x102>
    80002d8a:	f84a                	sd	s2,48(sp)
    80002d8c:	f44e                	sd	s3,40(sp)
    80002d8e:	f052                	sd	s4,32(sp)
    80002d90:	ec56                	sd	s5,24(sp)
    80002d92:	e85a                	sd	s6,16(sp)
    80002d94:	e45e                	sd	s7,8(sp)
    80002d96:	e062                	sd	s8,0(sp)
    80002d98:	8baa                	mv	s7,a0
    80002d9a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002d9c:	00021b17          	auipc	s6,0x21
    80002da0:	b9cb0b13          	addi	s6,s6,-1124 # 80023938 <sb>
      m = 1 << (bi % 8);
    80002da4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002da6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002da8:	6c09                	lui	s8,0x2
    80002daa:	a09d                	j	80002e10 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002dac:	97ca                	add	a5,a5,s2
    80002dae:	8e55                	or	a2,a2,a3
    80002db0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002db4:	854a                	mv	a0,s2
    80002db6:	6ad000ef          	jal	80003c62 <log_write>
        brelse(bp);
    80002dba:	854a                	mv	a0,s2
    80002dbc:	e61ff0ef          	jal	80002c1c <brelse>
  bp = bread(dev, bno);
    80002dc0:	85a6                	mv	a1,s1
    80002dc2:	855e                	mv	a0,s7
    80002dc4:	d51ff0ef          	jal	80002b14 <bread>
    80002dc8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002dca:	40000613          	li	a2,1024
    80002dce:	4581                	li	a1,0
    80002dd0:	05850513          	addi	a0,a0,88
    80002dd4:	efbfd0ef          	jal	80000cce <memset>
  log_write(bp);
    80002dd8:	854a                	mv	a0,s2
    80002dda:	689000ef          	jal	80003c62 <log_write>
  brelse(bp);
    80002dde:	854a                	mv	a0,s2
    80002de0:	e3dff0ef          	jal	80002c1c <brelse>
}
    80002de4:	7942                	ld	s2,48(sp)
    80002de6:	79a2                	ld	s3,40(sp)
    80002de8:	7a02                	ld	s4,32(sp)
    80002dea:	6ae2                	ld	s5,24(sp)
    80002dec:	6b42                	ld	s6,16(sp)
    80002dee:	6ba2                	ld	s7,8(sp)
    80002df0:	6c02                	ld	s8,0(sp)
}
    80002df2:	8526                	mv	a0,s1
    80002df4:	60a6                	ld	ra,72(sp)
    80002df6:	6406                	ld	s0,64(sp)
    80002df8:	74e2                	ld	s1,56(sp)
    80002dfa:	6161                	addi	sp,sp,80
    80002dfc:	8082                	ret
    brelse(bp);
    80002dfe:	854a                	mv	a0,s2
    80002e00:	e1dff0ef          	jal	80002c1c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e04:	015c0abb          	addw	s5,s8,s5
    80002e08:	004b2783          	lw	a5,4(s6)
    80002e0c:	04fafe63          	bgeu	s5,a5,80002e68 <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    80002e10:	41fad79b          	sraiw	a5,s5,0x1f
    80002e14:	0137d79b          	srliw	a5,a5,0x13
    80002e18:	015787bb          	addw	a5,a5,s5
    80002e1c:	40d7d79b          	sraiw	a5,a5,0xd
    80002e20:	01cb2583          	lw	a1,28(s6)
    80002e24:	9dbd                	addw	a1,a1,a5
    80002e26:	855e                	mv	a0,s7
    80002e28:	cedff0ef          	jal	80002b14 <bread>
    80002e2c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e2e:	004b2503          	lw	a0,4(s6)
    80002e32:	84d6                	mv	s1,s5
    80002e34:	4701                	li	a4,0
    80002e36:	fca4f4e3          	bgeu	s1,a0,80002dfe <balloc+0x8a>
      m = 1 << (bi % 8);
    80002e3a:	00777693          	andi	a3,a4,7
    80002e3e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e42:	41f7579b          	sraiw	a5,a4,0x1f
    80002e46:	01d7d79b          	srliw	a5,a5,0x1d
    80002e4a:	9fb9                	addw	a5,a5,a4
    80002e4c:	4037d79b          	sraiw	a5,a5,0x3
    80002e50:	00f90633          	add	a2,s2,a5
    80002e54:	05864603          	lbu	a2,88(a2)
    80002e58:	00c6f5b3          	and	a1,a3,a2
    80002e5c:	d9a1                	beqz	a1,80002dac <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e5e:	2705                	addiw	a4,a4,1
    80002e60:	2485                	addiw	s1,s1,1
    80002e62:	fd471ae3          	bne	a4,s4,80002e36 <balloc+0xc2>
    80002e66:	bf61                	j	80002dfe <balloc+0x8a>
    80002e68:	7942                	ld	s2,48(sp)
    80002e6a:	79a2                	ld	s3,40(sp)
    80002e6c:	7a02                	ld	s4,32(sp)
    80002e6e:	6ae2                	ld	s5,24(sp)
    80002e70:	6b42                	ld	s6,16(sp)
    80002e72:	6ba2                	ld	s7,8(sp)
    80002e74:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002e76:	00004517          	auipc	a0,0x4
    80002e7a:	60a50513          	addi	a0,a0,1546 # 80007480 <etext+0x480>
    80002e7e:	e50fd0ef          	jal	800004ce <printf>
  return 0;
    80002e82:	4481                	li	s1,0
    80002e84:	b7bd                	j	80002df2 <balloc+0x7e>

0000000080002e86 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e86:	7179                	addi	sp,sp,-48
    80002e88:	f406                	sd	ra,40(sp)
    80002e8a:	f022                	sd	s0,32(sp)
    80002e8c:	ec26                	sd	s1,24(sp)
    80002e8e:	e84a                	sd	s2,16(sp)
    80002e90:	e44e                	sd	s3,8(sp)
    80002e92:	1800                	addi	s0,sp,48
    80002e94:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002e96:	47ad                	li	a5,11
    80002e98:	02b7e363          	bltu	a5,a1,80002ebe <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002e9c:	02059793          	slli	a5,a1,0x20
    80002ea0:	01e7d593          	srli	a1,a5,0x1e
    80002ea4:	00b504b3          	add	s1,a0,a1
    80002ea8:	0504a903          	lw	s2,80(s1)
    80002eac:	06091363          	bnez	s2,80002f12 <bmap+0x8c>
      addr = balloc(ip->dev);
    80002eb0:	4108                	lw	a0,0(a0)
    80002eb2:	ec3ff0ef          	jal	80002d74 <balloc>
    80002eb6:	892a                	mv	s2,a0
      if(addr == 0)
    80002eb8:	cd29                	beqz	a0,80002f12 <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80002eba:	c8a8                	sw	a0,80(s1)
    80002ebc:	a899                	j	80002f12 <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002ebe:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80002ec2:	0ff00793          	li	a5,255
    80002ec6:	0697e963          	bltu	a5,s1,80002f38 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002eca:	08052903          	lw	s2,128(a0)
    80002ece:	00091b63          	bnez	s2,80002ee4 <bmap+0x5e>
      addr = balloc(ip->dev);
    80002ed2:	4108                	lw	a0,0(a0)
    80002ed4:	ea1ff0ef          	jal	80002d74 <balloc>
    80002ed8:	892a                	mv	s2,a0
      if(addr == 0)
    80002eda:	cd05                	beqz	a0,80002f12 <bmap+0x8c>
    80002edc:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002ede:	08a9a023          	sw	a0,128(s3)
    80002ee2:	a011                	j	80002ee6 <bmap+0x60>
    80002ee4:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002ee6:	85ca                	mv	a1,s2
    80002ee8:	0009a503          	lw	a0,0(s3)
    80002eec:	c29ff0ef          	jal	80002b14 <bread>
    80002ef0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002ef2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002ef6:	02049713          	slli	a4,s1,0x20
    80002efa:	01e75593          	srli	a1,a4,0x1e
    80002efe:	00b784b3          	add	s1,a5,a1
    80002f02:	0004a903          	lw	s2,0(s1)
    80002f06:	00090e63          	beqz	s2,80002f22 <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f0a:	8552                	mv	a0,s4
    80002f0c:	d11ff0ef          	jal	80002c1c <brelse>
    return addr;
    80002f10:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f12:	854a                	mv	a0,s2
    80002f14:	70a2                	ld	ra,40(sp)
    80002f16:	7402                	ld	s0,32(sp)
    80002f18:	64e2                	ld	s1,24(sp)
    80002f1a:	6942                	ld	s2,16(sp)
    80002f1c:	69a2                	ld	s3,8(sp)
    80002f1e:	6145                	addi	sp,sp,48
    80002f20:	8082                	ret
      addr = balloc(ip->dev);
    80002f22:	0009a503          	lw	a0,0(s3)
    80002f26:	e4fff0ef          	jal	80002d74 <balloc>
    80002f2a:	892a                	mv	s2,a0
      if(addr){
    80002f2c:	dd79                	beqz	a0,80002f0a <bmap+0x84>
        a[bn] = addr;
    80002f2e:	c088                	sw	a0,0(s1)
        log_write(bp);
    80002f30:	8552                	mv	a0,s4
    80002f32:	531000ef          	jal	80003c62 <log_write>
    80002f36:	bfd1                	j	80002f0a <bmap+0x84>
    80002f38:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f3a:	00004517          	auipc	a0,0x4
    80002f3e:	55e50513          	addi	a0,a0,1374 # 80007498 <etext+0x498>
    80002f42:	85dfd0ef          	jal	8000079e <panic>

0000000080002f46 <iget>:
{
    80002f46:	7179                	addi	sp,sp,-48
    80002f48:	f406                	sd	ra,40(sp)
    80002f4a:	f022                	sd	s0,32(sp)
    80002f4c:	ec26                	sd	s1,24(sp)
    80002f4e:	e84a                	sd	s2,16(sp)
    80002f50:	e44e                	sd	s3,8(sp)
    80002f52:	e052                	sd	s4,0(sp)
    80002f54:	1800                	addi	s0,sp,48
    80002f56:	89aa                	mv	s3,a0
    80002f58:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f5a:	00021517          	auipc	a0,0x21
    80002f5e:	9fe50513          	addi	a0,a0,-1538 # 80023958 <itable>
    80002f62:	c9dfd0ef          	jal	80000bfe <acquire>
  empty = 0;
    80002f66:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f68:	00021497          	auipc	s1,0x21
    80002f6c:	a0848493          	addi	s1,s1,-1528 # 80023970 <itable+0x18>
    80002f70:	00022697          	auipc	a3,0x22
    80002f74:	49068693          	addi	a3,a3,1168 # 80025400 <log>
    80002f78:	a039                	j	80002f86 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f7a:	02090963          	beqz	s2,80002fac <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f7e:	08848493          	addi	s1,s1,136
    80002f82:	02d48863          	beq	s1,a3,80002fb2 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002f86:	449c                	lw	a5,8(s1)
    80002f88:	fef059e3          	blez	a5,80002f7a <iget+0x34>
    80002f8c:	4098                	lw	a4,0(s1)
    80002f8e:	ff3716e3          	bne	a4,s3,80002f7a <iget+0x34>
    80002f92:	40d8                	lw	a4,4(s1)
    80002f94:	ff4713e3          	bne	a4,s4,80002f7a <iget+0x34>
      ip->ref++;
    80002f98:	2785                	addiw	a5,a5,1
    80002f9a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002f9c:	00021517          	auipc	a0,0x21
    80002fa0:	9bc50513          	addi	a0,a0,-1604 # 80023958 <itable>
    80002fa4:	ceffd0ef          	jal	80000c92 <release>
      return ip;
    80002fa8:	8926                	mv	s2,s1
    80002faa:	a02d                	j	80002fd4 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fac:	fbe9                	bnez	a5,80002f7e <iget+0x38>
      empty = ip;
    80002fae:	8926                	mv	s2,s1
    80002fb0:	b7f9                	j	80002f7e <iget+0x38>
  if(empty == 0)
    80002fb2:	02090a63          	beqz	s2,80002fe6 <iget+0xa0>
  ip->dev = dev;
    80002fb6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002fba:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002fbe:	4785                	li	a5,1
    80002fc0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002fc4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002fc8:	00021517          	auipc	a0,0x21
    80002fcc:	99050513          	addi	a0,a0,-1648 # 80023958 <itable>
    80002fd0:	cc3fd0ef          	jal	80000c92 <release>
}
    80002fd4:	854a                	mv	a0,s2
    80002fd6:	70a2                	ld	ra,40(sp)
    80002fd8:	7402                	ld	s0,32(sp)
    80002fda:	64e2                	ld	s1,24(sp)
    80002fdc:	6942                	ld	s2,16(sp)
    80002fde:	69a2                	ld	s3,8(sp)
    80002fe0:	6a02                	ld	s4,0(sp)
    80002fe2:	6145                	addi	sp,sp,48
    80002fe4:	8082                	ret
    panic("iget: no inodes");
    80002fe6:	00004517          	auipc	a0,0x4
    80002fea:	4ca50513          	addi	a0,a0,1226 # 800074b0 <etext+0x4b0>
    80002fee:	fb0fd0ef          	jal	8000079e <panic>

0000000080002ff2 <fsinit>:
fsinit(int dev) {
    80002ff2:	7179                	addi	sp,sp,-48
    80002ff4:	f406                	sd	ra,40(sp)
    80002ff6:	f022                	sd	s0,32(sp)
    80002ff8:	ec26                	sd	s1,24(sp)
    80002ffa:	e84a                	sd	s2,16(sp)
    80002ffc:	e44e                	sd	s3,8(sp)
    80002ffe:	1800                	addi	s0,sp,48
    80003000:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003002:	4585                	li	a1,1
    80003004:	b11ff0ef          	jal	80002b14 <bread>
    80003008:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000300a:	00021997          	auipc	s3,0x21
    8000300e:	92e98993          	addi	s3,s3,-1746 # 80023938 <sb>
    80003012:	02000613          	li	a2,32
    80003016:	05850593          	addi	a1,a0,88
    8000301a:	854e                	mv	a0,s3
    8000301c:	d17fd0ef          	jal	80000d32 <memmove>
  brelse(bp);
    80003020:	8526                	mv	a0,s1
    80003022:	bfbff0ef          	jal	80002c1c <brelse>
  if(sb.magic != FSMAGIC)
    80003026:	0009a703          	lw	a4,0(s3)
    8000302a:	102037b7          	lui	a5,0x10203
    8000302e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003032:	02f71063          	bne	a4,a5,80003052 <fsinit+0x60>
  initlog(dev, &sb);
    80003036:	00021597          	auipc	a1,0x21
    8000303a:	90258593          	addi	a1,a1,-1790 # 80023938 <sb>
    8000303e:	854a                	mv	a0,s2
    80003040:	215000ef          	jal	80003a54 <initlog>
}
    80003044:	70a2                	ld	ra,40(sp)
    80003046:	7402                	ld	s0,32(sp)
    80003048:	64e2                	ld	s1,24(sp)
    8000304a:	6942                	ld	s2,16(sp)
    8000304c:	69a2                	ld	s3,8(sp)
    8000304e:	6145                	addi	sp,sp,48
    80003050:	8082                	ret
    panic("invalid file system");
    80003052:	00004517          	auipc	a0,0x4
    80003056:	46e50513          	addi	a0,a0,1134 # 800074c0 <etext+0x4c0>
    8000305a:	f44fd0ef          	jal	8000079e <panic>

000000008000305e <iinit>:
{
    8000305e:	7179                	addi	sp,sp,-48
    80003060:	f406                	sd	ra,40(sp)
    80003062:	f022                	sd	s0,32(sp)
    80003064:	ec26                	sd	s1,24(sp)
    80003066:	e84a                	sd	s2,16(sp)
    80003068:	e44e                	sd	s3,8(sp)
    8000306a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000306c:	00004597          	auipc	a1,0x4
    80003070:	46c58593          	addi	a1,a1,1132 # 800074d8 <etext+0x4d8>
    80003074:	00021517          	auipc	a0,0x21
    80003078:	8e450513          	addi	a0,a0,-1820 # 80023958 <itable>
    8000307c:	afffd0ef          	jal	80000b7a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003080:	00021497          	auipc	s1,0x21
    80003084:	90048493          	addi	s1,s1,-1792 # 80023980 <itable+0x28>
    80003088:	00022997          	auipc	s3,0x22
    8000308c:	38898993          	addi	s3,s3,904 # 80025410 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003090:	00004917          	auipc	s2,0x4
    80003094:	45090913          	addi	s2,s2,1104 # 800074e0 <etext+0x4e0>
    80003098:	85ca                	mv	a1,s2
    8000309a:	8526                	mv	a0,s1
    8000309c:	497000ef          	jal	80003d32 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800030a0:	08848493          	addi	s1,s1,136
    800030a4:	ff349ae3          	bne	s1,s3,80003098 <iinit+0x3a>
}
    800030a8:	70a2                	ld	ra,40(sp)
    800030aa:	7402                	ld	s0,32(sp)
    800030ac:	64e2                	ld	s1,24(sp)
    800030ae:	6942                	ld	s2,16(sp)
    800030b0:	69a2                	ld	s3,8(sp)
    800030b2:	6145                	addi	sp,sp,48
    800030b4:	8082                	ret

00000000800030b6 <ialloc>:
{
    800030b6:	7139                	addi	sp,sp,-64
    800030b8:	fc06                	sd	ra,56(sp)
    800030ba:	f822                	sd	s0,48(sp)
    800030bc:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800030be:	00021717          	auipc	a4,0x21
    800030c2:	88672703          	lw	a4,-1914(a4) # 80023944 <sb+0xc>
    800030c6:	4785                	li	a5,1
    800030c8:	06e7f063          	bgeu	a5,a4,80003128 <ialloc+0x72>
    800030cc:	f426                	sd	s1,40(sp)
    800030ce:	f04a                	sd	s2,32(sp)
    800030d0:	ec4e                	sd	s3,24(sp)
    800030d2:	e852                	sd	s4,16(sp)
    800030d4:	e456                	sd	s5,8(sp)
    800030d6:	e05a                	sd	s6,0(sp)
    800030d8:	8aaa                	mv	s5,a0
    800030da:	8b2e                	mv	s6,a1
    800030dc:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800030de:	00021a17          	auipc	s4,0x21
    800030e2:	85aa0a13          	addi	s4,s4,-1958 # 80023938 <sb>
    800030e6:	00495593          	srli	a1,s2,0x4
    800030ea:	018a2783          	lw	a5,24(s4)
    800030ee:	9dbd                	addw	a1,a1,a5
    800030f0:	8556                	mv	a0,s5
    800030f2:	a23ff0ef          	jal	80002b14 <bread>
    800030f6:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800030f8:	05850993          	addi	s3,a0,88
    800030fc:	00f97793          	andi	a5,s2,15
    80003100:	079a                	slli	a5,a5,0x6
    80003102:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003104:	00099783          	lh	a5,0(s3)
    80003108:	cb9d                	beqz	a5,8000313e <ialloc+0x88>
    brelse(bp);
    8000310a:	b13ff0ef          	jal	80002c1c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000310e:	0905                	addi	s2,s2,1
    80003110:	00ca2703          	lw	a4,12(s4)
    80003114:	0009079b          	sext.w	a5,s2
    80003118:	fce7e7e3          	bltu	a5,a4,800030e6 <ialloc+0x30>
    8000311c:	74a2                	ld	s1,40(sp)
    8000311e:	7902                	ld	s2,32(sp)
    80003120:	69e2                	ld	s3,24(sp)
    80003122:	6a42                	ld	s4,16(sp)
    80003124:	6aa2                	ld	s5,8(sp)
    80003126:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003128:	00004517          	auipc	a0,0x4
    8000312c:	3c050513          	addi	a0,a0,960 # 800074e8 <etext+0x4e8>
    80003130:	b9efd0ef          	jal	800004ce <printf>
  return 0;
    80003134:	4501                	li	a0,0
}
    80003136:	70e2                	ld	ra,56(sp)
    80003138:	7442                	ld	s0,48(sp)
    8000313a:	6121                	addi	sp,sp,64
    8000313c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000313e:	04000613          	li	a2,64
    80003142:	4581                	li	a1,0
    80003144:	854e                	mv	a0,s3
    80003146:	b89fd0ef          	jal	80000cce <memset>
      dip->type = type;
    8000314a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000314e:	8526                	mv	a0,s1
    80003150:	313000ef          	jal	80003c62 <log_write>
      brelse(bp);
    80003154:	8526                	mv	a0,s1
    80003156:	ac7ff0ef          	jal	80002c1c <brelse>
      return iget(dev, inum);
    8000315a:	0009059b          	sext.w	a1,s2
    8000315e:	8556                	mv	a0,s5
    80003160:	de7ff0ef          	jal	80002f46 <iget>
    80003164:	74a2                	ld	s1,40(sp)
    80003166:	7902                	ld	s2,32(sp)
    80003168:	69e2                	ld	s3,24(sp)
    8000316a:	6a42                	ld	s4,16(sp)
    8000316c:	6aa2                	ld	s5,8(sp)
    8000316e:	6b02                	ld	s6,0(sp)
    80003170:	b7d9                	j	80003136 <ialloc+0x80>

0000000080003172 <iupdate>:
{
    80003172:	1101                	addi	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	e426                	sd	s1,8(sp)
    8000317a:	e04a                	sd	s2,0(sp)
    8000317c:	1000                	addi	s0,sp,32
    8000317e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003180:	415c                	lw	a5,4(a0)
    80003182:	0047d79b          	srliw	a5,a5,0x4
    80003186:	00020597          	auipc	a1,0x20
    8000318a:	7ca5a583          	lw	a1,1994(a1) # 80023950 <sb+0x18>
    8000318e:	9dbd                	addw	a1,a1,a5
    80003190:	4108                	lw	a0,0(a0)
    80003192:	983ff0ef          	jal	80002b14 <bread>
    80003196:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003198:	05850793          	addi	a5,a0,88
    8000319c:	40d8                	lw	a4,4(s1)
    8000319e:	8b3d                	andi	a4,a4,15
    800031a0:	071a                	slli	a4,a4,0x6
    800031a2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031a4:	04449703          	lh	a4,68(s1)
    800031a8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800031ac:	04649703          	lh	a4,70(s1)
    800031b0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031b4:	04849703          	lh	a4,72(s1)
    800031b8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031bc:	04a49703          	lh	a4,74(s1)
    800031c0:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031c4:	44f8                	lw	a4,76(s1)
    800031c6:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031c8:	03400613          	li	a2,52
    800031cc:	05048593          	addi	a1,s1,80
    800031d0:	00c78513          	addi	a0,a5,12
    800031d4:	b5ffd0ef          	jal	80000d32 <memmove>
  log_write(bp);
    800031d8:	854a                	mv	a0,s2
    800031da:	289000ef          	jal	80003c62 <log_write>
  brelse(bp);
    800031de:	854a                	mv	a0,s2
    800031e0:	a3dff0ef          	jal	80002c1c <brelse>
}
    800031e4:	60e2                	ld	ra,24(sp)
    800031e6:	6442                	ld	s0,16(sp)
    800031e8:	64a2                	ld	s1,8(sp)
    800031ea:	6902                	ld	s2,0(sp)
    800031ec:	6105                	addi	sp,sp,32
    800031ee:	8082                	ret

00000000800031f0 <idup>:
{
    800031f0:	1101                	addi	sp,sp,-32
    800031f2:	ec06                	sd	ra,24(sp)
    800031f4:	e822                	sd	s0,16(sp)
    800031f6:	e426                	sd	s1,8(sp)
    800031f8:	1000                	addi	s0,sp,32
    800031fa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031fc:	00020517          	auipc	a0,0x20
    80003200:	75c50513          	addi	a0,a0,1884 # 80023958 <itable>
    80003204:	9fbfd0ef          	jal	80000bfe <acquire>
  ip->ref++;
    80003208:	449c                	lw	a5,8(s1)
    8000320a:	2785                	addiw	a5,a5,1
    8000320c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000320e:	00020517          	auipc	a0,0x20
    80003212:	74a50513          	addi	a0,a0,1866 # 80023958 <itable>
    80003216:	a7dfd0ef          	jal	80000c92 <release>
}
    8000321a:	8526                	mv	a0,s1
    8000321c:	60e2                	ld	ra,24(sp)
    8000321e:	6442                	ld	s0,16(sp)
    80003220:	64a2                	ld	s1,8(sp)
    80003222:	6105                	addi	sp,sp,32
    80003224:	8082                	ret

0000000080003226 <ilock>:
{
    80003226:	1101                	addi	sp,sp,-32
    80003228:	ec06                	sd	ra,24(sp)
    8000322a:	e822                	sd	s0,16(sp)
    8000322c:	e426                	sd	s1,8(sp)
    8000322e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003230:	cd19                	beqz	a0,8000324e <ilock+0x28>
    80003232:	84aa                	mv	s1,a0
    80003234:	451c                	lw	a5,8(a0)
    80003236:	00f05c63          	blez	a5,8000324e <ilock+0x28>
  acquiresleep(&ip->lock);
    8000323a:	0541                	addi	a0,a0,16
    8000323c:	32d000ef          	jal	80003d68 <acquiresleep>
  if(ip->valid == 0){
    80003240:	40bc                	lw	a5,64(s1)
    80003242:	cf89                	beqz	a5,8000325c <ilock+0x36>
}
    80003244:	60e2                	ld	ra,24(sp)
    80003246:	6442                	ld	s0,16(sp)
    80003248:	64a2                	ld	s1,8(sp)
    8000324a:	6105                	addi	sp,sp,32
    8000324c:	8082                	ret
    8000324e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003250:	00004517          	auipc	a0,0x4
    80003254:	2b050513          	addi	a0,a0,688 # 80007500 <etext+0x500>
    80003258:	d46fd0ef          	jal	8000079e <panic>
    8000325c:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000325e:	40dc                	lw	a5,4(s1)
    80003260:	0047d79b          	srliw	a5,a5,0x4
    80003264:	00020597          	auipc	a1,0x20
    80003268:	6ec5a583          	lw	a1,1772(a1) # 80023950 <sb+0x18>
    8000326c:	9dbd                	addw	a1,a1,a5
    8000326e:	4088                	lw	a0,0(s1)
    80003270:	8a5ff0ef          	jal	80002b14 <bread>
    80003274:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003276:	05850593          	addi	a1,a0,88
    8000327a:	40dc                	lw	a5,4(s1)
    8000327c:	8bbd                	andi	a5,a5,15
    8000327e:	079a                	slli	a5,a5,0x6
    80003280:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003282:	00059783          	lh	a5,0(a1)
    80003286:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000328a:	00259783          	lh	a5,2(a1)
    8000328e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003292:	00459783          	lh	a5,4(a1)
    80003296:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000329a:	00659783          	lh	a5,6(a1)
    8000329e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032a2:	459c                	lw	a5,8(a1)
    800032a4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032a6:	03400613          	li	a2,52
    800032aa:	05b1                	addi	a1,a1,12
    800032ac:	05048513          	addi	a0,s1,80
    800032b0:	a83fd0ef          	jal	80000d32 <memmove>
    brelse(bp);
    800032b4:	854a                	mv	a0,s2
    800032b6:	967ff0ef          	jal	80002c1c <brelse>
    ip->valid = 1;
    800032ba:	4785                	li	a5,1
    800032bc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800032be:	04449783          	lh	a5,68(s1)
    800032c2:	c399                	beqz	a5,800032c8 <ilock+0xa2>
    800032c4:	6902                	ld	s2,0(sp)
    800032c6:	bfbd                	j	80003244 <ilock+0x1e>
      panic("ilock: no type");
    800032c8:	00004517          	auipc	a0,0x4
    800032cc:	24050513          	addi	a0,a0,576 # 80007508 <etext+0x508>
    800032d0:	ccefd0ef          	jal	8000079e <panic>

00000000800032d4 <iunlock>:
{
    800032d4:	1101                	addi	sp,sp,-32
    800032d6:	ec06                	sd	ra,24(sp)
    800032d8:	e822                	sd	s0,16(sp)
    800032da:	e426                	sd	s1,8(sp)
    800032dc:	e04a                	sd	s2,0(sp)
    800032de:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032e0:	c505                	beqz	a0,80003308 <iunlock+0x34>
    800032e2:	84aa                	mv	s1,a0
    800032e4:	01050913          	addi	s2,a0,16
    800032e8:	854a                	mv	a0,s2
    800032ea:	2fd000ef          	jal	80003de6 <holdingsleep>
    800032ee:	cd09                	beqz	a0,80003308 <iunlock+0x34>
    800032f0:	449c                	lw	a5,8(s1)
    800032f2:	00f05b63          	blez	a5,80003308 <iunlock+0x34>
  releasesleep(&ip->lock);
    800032f6:	854a                	mv	a0,s2
    800032f8:	2b7000ef          	jal	80003dae <releasesleep>
}
    800032fc:	60e2                	ld	ra,24(sp)
    800032fe:	6442                	ld	s0,16(sp)
    80003300:	64a2                	ld	s1,8(sp)
    80003302:	6902                	ld	s2,0(sp)
    80003304:	6105                	addi	sp,sp,32
    80003306:	8082                	ret
    panic("iunlock");
    80003308:	00004517          	auipc	a0,0x4
    8000330c:	21050513          	addi	a0,a0,528 # 80007518 <etext+0x518>
    80003310:	c8efd0ef          	jal	8000079e <panic>

0000000080003314 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003314:	7179                	addi	sp,sp,-48
    80003316:	f406                	sd	ra,40(sp)
    80003318:	f022                	sd	s0,32(sp)
    8000331a:	ec26                	sd	s1,24(sp)
    8000331c:	e84a                	sd	s2,16(sp)
    8000331e:	e44e                	sd	s3,8(sp)
    80003320:	1800                	addi	s0,sp,48
    80003322:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003324:	05050493          	addi	s1,a0,80
    80003328:	08050913          	addi	s2,a0,128
    8000332c:	a021                	j	80003334 <itrunc+0x20>
    8000332e:	0491                	addi	s1,s1,4
    80003330:	01248b63          	beq	s1,s2,80003346 <itrunc+0x32>
    if(ip->addrs[i]){
    80003334:	408c                	lw	a1,0(s1)
    80003336:	dde5                	beqz	a1,8000332e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003338:	0009a503          	lw	a0,0(s3)
    8000333c:	9cdff0ef          	jal	80002d08 <bfree>
      ip->addrs[i] = 0;
    80003340:	0004a023          	sw	zero,0(s1)
    80003344:	b7ed                	j	8000332e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003346:	0809a583          	lw	a1,128(s3)
    8000334a:	ed89                	bnez	a1,80003364 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000334c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003350:	854e                	mv	a0,s3
    80003352:	e21ff0ef          	jal	80003172 <iupdate>
}
    80003356:	70a2                	ld	ra,40(sp)
    80003358:	7402                	ld	s0,32(sp)
    8000335a:	64e2                	ld	s1,24(sp)
    8000335c:	6942                	ld	s2,16(sp)
    8000335e:	69a2                	ld	s3,8(sp)
    80003360:	6145                	addi	sp,sp,48
    80003362:	8082                	ret
    80003364:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003366:	0009a503          	lw	a0,0(s3)
    8000336a:	faaff0ef          	jal	80002b14 <bread>
    8000336e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003370:	05850493          	addi	s1,a0,88
    80003374:	45850913          	addi	s2,a0,1112
    80003378:	a021                	j	80003380 <itrunc+0x6c>
    8000337a:	0491                	addi	s1,s1,4
    8000337c:	01248963          	beq	s1,s2,8000338e <itrunc+0x7a>
      if(a[j])
    80003380:	408c                	lw	a1,0(s1)
    80003382:	dde5                	beqz	a1,8000337a <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003384:	0009a503          	lw	a0,0(s3)
    80003388:	981ff0ef          	jal	80002d08 <bfree>
    8000338c:	b7fd                	j	8000337a <itrunc+0x66>
    brelse(bp);
    8000338e:	8552                	mv	a0,s4
    80003390:	88dff0ef          	jal	80002c1c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003394:	0809a583          	lw	a1,128(s3)
    80003398:	0009a503          	lw	a0,0(s3)
    8000339c:	96dff0ef          	jal	80002d08 <bfree>
    ip->addrs[NDIRECT] = 0;
    800033a0:	0809a023          	sw	zero,128(s3)
    800033a4:	6a02                	ld	s4,0(sp)
    800033a6:	b75d                	j	8000334c <itrunc+0x38>

00000000800033a8 <iput>:
{
    800033a8:	1101                	addi	sp,sp,-32
    800033aa:	ec06                	sd	ra,24(sp)
    800033ac:	e822                	sd	s0,16(sp)
    800033ae:	e426                	sd	s1,8(sp)
    800033b0:	1000                	addi	s0,sp,32
    800033b2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033b4:	00020517          	auipc	a0,0x20
    800033b8:	5a450513          	addi	a0,a0,1444 # 80023958 <itable>
    800033bc:	843fd0ef          	jal	80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033c0:	4498                	lw	a4,8(s1)
    800033c2:	4785                	li	a5,1
    800033c4:	02f70063          	beq	a4,a5,800033e4 <iput+0x3c>
  ip->ref--;
    800033c8:	449c                	lw	a5,8(s1)
    800033ca:	37fd                	addiw	a5,a5,-1
    800033cc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033ce:	00020517          	auipc	a0,0x20
    800033d2:	58a50513          	addi	a0,a0,1418 # 80023958 <itable>
    800033d6:	8bdfd0ef          	jal	80000c92 <release>
}
    800033da:	60e2                	ld	ra,24(sp)
    800033dc:	6442                	ld	s0,16(sp)
    800033de:	64a2                	ld	s1,8(sp)
    800033e0:	6105                	addi	sp,sp,32
    800033e2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033e4:	40bc                	lw	a5,64(s1)
    800033e6:	d3ed                	beqz	a5,800033c8 <iput+0x20>
    800033e8:	04a49783          	lh	a5,74(s1)
    800033ec:	fff1                	bnez	a5,800033c8 <iput+0x20>
    800033ee:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800033f0:	01048913          	addi	s2,s1,16
    800033f4:	854a                	mv	a0,s2
    800033f6:	173000ef          	jal	80003d68 <acquiresleep>
    release(&itable.lock);
    800033fa:	00020517          	auipc	a0,0x20
    800033fe:	55e50513          	addi	a0,a0,1374 # 80023958 <itable>
    80003402:	891fd0ef          	jal	80000c92 <release>
    itrunc(ip);
    80003406:	8526                	mv	a0,s1
    80003408:	f0dff0ef          	jal	80003314 <itrunc>
    ip->type = 0;
    8000340c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003410:	8526                	mv	a0,s1
    80003412:	d61ff0ef          	jal	80003172 <iupdate>
    ip->valid = 0;
    80003416:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000341a:	854a                	mv	a0,s2
    8000341c:	193000ef          	jal	80003dae <releasesleep>
    acquire(&itable.lock);
    80003420:	00020517          	auipc	a0,0x20
    80003424:	53850513          	addi	a0,a0,1336 # 80023958 <itable>
    80003428:	fd6fd0ef          	jal	80000bfe <acquire>
    8000342c:	6902                	ld	s2,0(sp)
    8000342e:	bf69                	j	800033c8 <iput+0x20>

0000000080003430 <iunlockput>:
{
    80003430:	1101                	addi	sp,sp,-32
    80003432:	ec06                	sd	ra,24(sp)
    80003434:	e822                	sd	s0,16(sp)
    80003436:	e426                	sd	s1,8(sp)
    80003438:	1000                	addi	s0,sp,32
    8000343a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000343c:	e99ff0ef          	jal	800032d4 <iunlock>
  iput(ip);
    80003440:	8526                	mv	a0,s1
    80003442:	f67ff0ef          	jal	800033a8 <iput>
}
    80003446:	60e2                	ld	ra,24(sp)
    80003448:	6442                	ld	s0,16(sp)
    8000344a:	64a2                	ld	s1,8(sp)
    8000344c:	6105                	addi	sp,sp,32
    8000344e:	8082                	ret

0000000080003450 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003450:	1141                	addi	sp,sp,-16
    80003452:	e406                	sd	ra,8(sp)
    80003454:	e022                	sd	s0,0(sp)
    80003456:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003458:	411c                	lw	a5,0(a0)
    8000345a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000345c:	415c                	lw	a5,4(a0)
    8000345e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003460:	04451783          	lh	a5,68(a0)
    80003464:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003468:	04a51783          	lh	a5,74(a0)
    8000346c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003470:	04c56783          	lwu	a5,76(a0)
    80003474:	e99c                	sd	a5,16(a1)
}
    80003476:	60a2                	ld	ra,8(sp)
    80003478:	6402                	ld	s0,0(sp)
    8000347a:	0141                	addi	sp,sp,16
    8000347c:	8082                	ret

000000008000347e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000347e:	457c                	lw	a5,76(a0)
    80003480:	0ed7e663          	bltu	a5,a3,8000356c <readi+0xee>
{
    80003484:	7159                	addi	sp,sp,-112
    80003486:	f486                	sd	ra,104(sp)
    80003488:	f0a2                	sd	s0,96(sp)
    8000348a:	eca6                	sd	s1,88(sp)
    8000348c:	e0d2                	sd	s4,64(sp)
    8000348e:	fc56                	sd	s5,56(sp)
    80003490:	f85a                	sd	s6,48(sp)
    80003492:	f45e                	sd	s7,40(sp)
    80003494:	1880                	addi	s0,sp,112
    80003496:	8b2a                	mv	s6,a0
    80003498:	8bae                	mv	s7,a1
    8000349a:	8a32                	mv	s4,a2
    8000349c:	84b6                	mv	s1,a3
    8000349e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800034a0:	9f35                	addw	a4,a4,a3
    return 0;
    800034a2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800034a4:	0ad76b63          	bltu	a4,a3,8000355a <readi+0xdc>
    800034a8:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800034aa:	00e7f463          	bgeu	a5,a4,800034b2 <readi+0x34>
    n = ip->size - off;
    800034ae:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034b2:	080a8b63          	beqz	s5,80003548 <readi+0xca>
    800034b6:	e8ca                	sd	s2,80(sp)
    800034b8:	f062                	sd	s8,32(sp)
    800034ba:	ec66                	sd	s9,24(sp)
    800034bc:	e86a                	sd	s10,16(sp)
    800034be:	e46e                	sd	s11,8(sp)
    800034c0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800034c2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800034c6:	5c7d                	li	s8,-1
    800034c8:	a80d                	j	800034fa <readi+0x7c>
    800034ca:	020d1d93          	slli	s11,s10,0x20
    800034ce:	020ddd93          	srli	s11,s11,0x20
    800034d2:	05890613          	addi	a2,s2,88
    800034d6:	86ee                	mv	a3,s11
    800034d8:	963e                	add	a2,a2,a5
    800034da:	85d2                	mv	a1,s4
    800034dc:	855e                	mv	a0,s7
    800034de:	d4dfe0ef          	jal	8000222a <either_copyout>
    800034e2:	05850363          	beq	a0,s8,80003528 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800034e6:	854a                	mv	a0,s2
    800034e8:	f34ff0ef          	jal	80002c1c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034ec:	013d09bb          	addw	s3,s10,s3
    800034f0:	009d04bb          	addw	s1,s10,s1
    800034f4:	9a6e                	add	s4,s4,s11
    800034f6:	0559f363          	bgeu	s3,s5,8000353c <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800034fa:	00a4d59b          	srliw	a1,s1,0xa
    800034fe:	855a                	mv	a0,s6
    80003500:	987ff0ef          	jal	80002e86 <bmap>
    80003504:	85aa                	mv	a1,a0
    if(addr == 0)
    80003506:	c139                	beqz	a0,8000354c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003508:	000b2503          	lw	a0,0(s6)
    8000350c:	e08ff0ef          	jal	80002b14 <bread>
    80003510:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003512:	3ff4f793          	andi	a5,s1,1023
    80003516:	40fc873b          	subw	a4,s9,a5
    8000351a:	413a86bb          	subw	a3,s5,s3
    8000351e:	8d3a                	mv	s10,a4
    80003520:	fae6f5e3          	bgeu	a3,a4,800034ca <readi+0x4c>
    80003524:	8d36                	mv	s10,a3
    80003526:	b755                	j	800034ca <readi+0x4c>
      brelse(bp);
    80003528:	854a                	mv	a0,s2
    8000352a:	ef2ff0ef          	jal	80002c1c <brelse>
      tot = -1;
    8000352e:	59fd                	li	s3,-1
      break;
    80003530:	6946                	ld	s2,80(sp)
    80003532:	7c02                	ld	s8,32(sp)
    80003534:	6ce2                	ld	s9,24(sp)
    80003536:	6d42                	ld	s10,16(sp)
    80003538:	6da2                	ld	s11,8(sp)
    8000353a:	a831                	j	80003556 <readi+0xd8>
    8000353c:	6946                	ld	s2,80(sp)
    8000353e:	7c02                	ld	s8,32(sp)
    80003540:	6ce2                	ld	s9,24(sp)
    80003542:	6d42                	ld	s10,16(sp)
    80003544:	6da2                	ld	s11,8(sp)
    80003546:	a801                	j	80003556 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003548:	89d6                	mv	s3,s5
    8000354a:	a031                	j	80003556 <readi+0xd8>
    8000354c:	6946                	ld	s2,80(sp)
    8000354e:	7c02                	ld	s8,32(sp)
    80003550:	6ce2                	ld	s9,24(sp)
    80003552:	6d42                	ld	s10,16(sp)
    80003554:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003556:	854e                	mv	a0,s3
    80003558:	69a6                	ld	s3,72(sp)
}
    8000355a:	70a6                	ld	ra,104(sp)
    8000355c:	7406                	ld	s0,96(sp)
    8000355e:	64e6                	ld	s1,88(sp)
    80003560:	6a06                	ld	s4,64(sp)
    80003562:	7ae2                	ld	s5,56(sp)
    80003564:	7b42                	ld	s6,48(sp)
    80003566:	7ba2                	ld	s7,40(sp)
    80003568:	6165                	addi	sp,sp,112
    8000356a:	8082                	ret
    return 0;
    8000356c:	4501                	li	a0,0
}
    8000356e:	8082                	ret

0000000080003570 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003570:	457c                	lw	a5,76(a0)
    80003572:	0ed7eb63          	bltu	a5,a3,80003668 <writei+0xf8>
{
    80003576:	7159                	addi	sp,sp,-112
    80003578:	f486                	sd	ra,104(sp)
    8000357a:	f0a2                	sd	s0,96(sp)
    8000357c:	e8ca                	sd	s2,80(sp)
    8000357e:	e0d2                	sd	s4,64(sp)
    80003580:	fc56                	sd	s5,56(sp)
    80003582:	f85a                	sd	s6,48(sp)
    80003584:	f45e                	sd	s7,40(sp)
    80003586:	1880                	addi	s0,sp,112
    80003588:	8aaa                	mv	s5,a0
    8000358a:	8bae                	mv	s7,a1
    8000358c:	8a32                	mv	s4,a2
    8000358e:	8936                	mv	s2,a3
    80003590:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003592:	00e687bb          	addw	a5,a3,a4
    80003596:	0cd7eb63          	bltu	a5,a3,8000366c <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000359a:	00043737          	lui	a4,0x43
    8000359e:	0cf76963          	bltu	a4,a5,80003670 <writei+0x100>
    800035a2:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035a4:	0a0b0a63          	beqz	s6,80003658 <writei+0xe8>
    800035a8:	eca6                	sd	s1,88(sp)
    800035aa:	f062                	sd	s8,32(sp)
    800035ac:	ec66                	sd	s9,24(sp)
    800035ae:	e86a                	sd	s10,16(sp)
    800035b0:	e46e                	sd	s11,8(sp)
    800035b2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035b4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800035b8:	5c7d                	li	s8,-1
    800035ba:	a825                	j	800035f2 <writei+0x82>
    800035bc:	020d1d93          	slli	s11,s10,0x20
    800035c0:	020ddd93          	srli	s11,s11,0x20
    800035c4:	05848513          	addi	a0,s1,88
    800035c8:	86ee                	mv	a3,s11
    800035ca:	8652                	mv	a2,s4
    800035cc:	85de                	mv	a1,s7
    800035ce:	953e                	add	a0,a0,a5
    800035d0:	ca5fe0ef          	jal	80002274 <either_copyin>
    800035d4:	05850663          	beq	a0,s8,80003620 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800035d8:	8526                	mv	a0,s1
    800035da:	688000ef          	jal	80003c62 <log_write>
    brelse(bp);
    800035de:	8526                	mv	a0,s1
    800035e0:	e3cff0ef          	jal	80002c1c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035e4:	013d09bb          	addw	s3,s10,s3
    800035e8:	012d093b          	addw	s2,s10,s2
    800035ec:	9a6e                	add	s4,s4,s11
    800035ee:	0369fc63          	bgeu	s3,s6,80003626 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800035f2:	00a9559b          	srliw	a1,s2,0xa
    800035f6:	8556                	mv	a0,s5
    800035f8:	88fff0ef          	jal	80002e86 <bmap>
    800035fc:	85aa                	mv	a1,a0
    if(addr == 0)
    800035fe:	c505                	beqz	a0,80003626 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003600:	000aa503          	lw	a0,0(s5)
    80003604:	d10ff0ef          	jal	80002b14 <bread>
    80003608:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000360a:	3ff97793          	andi	a5,s2,1023
    8000360e:	40fc873b          	subw	a4,s9,a5
    80003612:	413b06bb          	subw	a3,s6,s3
    80003616:	8d3a                	mv	s10,a4
    80003618:	fae6f2e3          	bgeu	a3,a4,800035bc <writei+0x4c>
    8000361c:	8d36                	mv	s10,a3
    8000361e:	bf79                	j	800035bc <writei+0x4c>
      brelse(bp);
    80003620:	8526                	mv	a0,s1
    80003622:	dfaff0ef          	jal	80002c1c <brelse>
  }

  if(off > ip->size)
    80003626:	04caa783          	lw	a5,76(s5)
    8000362a:	0327f963          	bgeu	a5,s2,8000365c <writei+0xec>
    ip->size = off;
    8000362e:	052aa623          	sw	s2,76(s5)
    80003632:	64e6                	ld	s1,88(sp)
    80003634:	7c02                	ld	s8,32(sp)
    80003636:	6ce2                	ld	s9,24(sp)
    80003638:	6d42                	ld	s10,16(sp)
    8000363a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000363c:	8556                	mv	a0,s5
    8000363e:	b35ff0ef          	jal	80003172 <iupdate>

  return tot;
    80003642:	854e                	mv	a0,s3
    80003644:	69a6                	ld	s3,72(sp)
}
    80003646:	70a6                	ld	ra,104(sp)
    80003648:	7406                	ld	s0,96(sp)
    8000364a:	6946                	ld	s2,80(sp)
    8000364c:	6a06                	ld	s4,64(sp)
    8000364e:	7ae2                	ld	s5,56(sp)
    80003650:	7b42                	ld	s6,48(sp)
    80003652:	7ba2                	ld	s7,40(sp)
    80003654:	6165                	addi	sp,sp,112
    80003656:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003658:	89da                	mv	s3,s6
    8000365a:	b7cd                	j	8000363c <writei+0xcc>
    8000365c:	64e6                	ld	s1,88(sp)
    8000365e:	7c02                	ld	s8,32(sp)
    80003660:	6ce2                	ld	s9,24(sp)
    80003662:	6d42                	ld	s10,16(sp)
    80003664:	6da2                	ld	s11,8(sp)
    80003666:	bfd9                	j	8000363c <writei+0xcc>
    return -1;
    80003668:	557d                	li	a0,-1
}
    8000366a:	8082                	ret
    return -1;
    8000366c:	557d                	li	a0,-1
    8000366e:	bfe1                	j	80003646 <writei+0xd6>
    return -1;
    80003670:	557d                	li	a0,-1
    80003672:	bfd1                	j	80003646 <writei+0xd6>

0000000080003674 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003674:	1141                	addi	sp,sp,-16
    80003676:	e406                	sd	ra,8(sp)
    80003678:	e022                	sd	s0,0(sp)
    8000367a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000367c:	4639                	li	a2,14
    8000367e:	f28fd0ef          	jal	80000da6 <strncmp>
}
    80003682:	60a2                	ld	ra,8(sp)
    80003684:	6402                	ld	s0,0(sp)
    80003686:	0141                	addi	sp,sp,16
    80003688:	8082                	ret

000000008000368a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000368a:	711d                	addi	sp,sp,-96
    8000368c:	ec86                	sd	ra,88(sp)
    8000368e:	e8a2                	sd	s0,80(sp)
    80003690:	e4a6                	sd	s1,72(sp)
    80003692:	e0ca                	sd	s2,64(sp)
    80003694:	fc4e                	sd	s3,56(sp)
    80003696:	f852                	sd	s4,48(sp)
    80003698:	f456                	sd	s5,40(sp)
    8000369a:	f05a                	sd	s6,32(sp)
    8000369c:	ec5e                	sd	s7,24(sp)
    8000369e:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800036a0:	04451703          	lh	a4,68(a0)
    800036a4:	4785                	li	a5,1
    800036a6:	00f71f63          	bne	a4,a5,800036c4 <dirlookup+0x3a>
    800036aa:	892a                	mv	s2,a0
    800036ac:	8aae                	mv	s5,a1
    800036ae:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800036b0:	457c                	lw	a5,76(a0)
    800036b2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800036b4:	fa040a13          	addi	s4,s0,-96
    800036b8:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800036ba:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800036be:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036c0:	e39d                	bnez	a5,800036e6 <dirlookup+0x5c>
    800036c2:	a8b9                	j	80003720 <dirlookup+0x96>
    panic("dirlookup not DIR");
    800036c4:	00004517          	auipc	a0,0x4
    800036c8:	e5c50513          	addi	a0,a0,-420 # 80007520 <etext+0x520>
    800036cc:	8d2fd0ef          	jal	8000079e <panic>
      panic("dirlookup read");
    800036d0:	00004517          	auipc	a0,0x4
    800036d4:	e6850513          	addi	a0,a0,-408 # 80007538 <etext+0x538>
    800036d8:	8c6fd0ef          	jal	8000079e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036dc:	24c1                	addiw	s1,s1,16
    800036de:	04c92783          	lw	a5,76(s2)
    800036e2:	02f4fe63          	bgeu	s1,a5,8000371e <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800036e6:	874e                	mv	a4,s3
    800036e8:	86a6                	mv	a3,s1
    800036ea:	8652                	mv	a2,s4
    800036ec:	4581                	li	a1,0
    800036ee:	854a                	mv	a0,s2
    800036f0:	d8fff0ef          	jal	8000347e <readi>
    800036f4:	fd351ee3          	bne	a0,s3,800036d0 <dirlookup+0x46>
    if(de.inum == 0)
    800036f8:	fa045783          	lhu	a5,-96(s0)
    800036fc:	d3e5                	beqz	a5,800036dc <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800036fe:	85da                	mv	a1,s6
    80003700:	8556                	mv	a0,s5
    80003702:	f73ff0ef          	jal	80003674 <namecmp>
    80003706:	f979                	bnez	a0,800036dc <dirlookup+0x52>
      if(poff)
    80003708:	000b8463          	beqz	s7,80003710 <dirlookup+0x86>
        *poff = off;
    8000370c:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003710:	fa045583          	lhu	a1,-96(s0)
    80003714:	00092503          	lw	a0,0(s2)
    80003718:	82fff0ef          	jal	80002f46 <iget>
    8000371c:	a011                	j	80003720 <dirlookup+0x96>
  return 0;
    8000371e:	4501                	li	a0,0
}
    80003720:	60e6                	ld	ra,88(sp)
    80003722:	6446                	ld	s0,80(sp)
    80003724:	64a6                	ld	s1,72(sp)
    80003726:	6906                	ld	s2,64(sp)
    80003728:	79e2                	ld	s3,56(sp)
    8000372a:	7a42                	ld	s4,48(sp)
    8000372c:	7aa2                	ld	s5,40(sp)
    8000372e:	7b02                	ld	s6,32(sp)
    80003730:	6be2                	ld	s7,24(sp)
    80003732:	6125                	addi	sp,sp,96
    80003734:	8082                	ret

0000000080003736 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003736:	711d                	addi	sp,sp,-96
    80003738:	ec86                	sd	ra,88(sp)
    8000373a:	e8a2                	sd	s0,80(sp)
    8000373c:	e4a6                	sd	s1,72(sp)
    8000373e:	e0ca                	sd	s2,64(sp)
    80003740:	fc4e                	sd	s3,56(sp)
    80003742:	f852                	sd	s4,48(sp)
    80003744:	f456                	sd	s5,40(sp)
    80003746:	f05a                	sd	s6,32(sp)
    80003748:	ec5e                	sd	s7,24(sp)
    8000374a:	e862                	sd	s8,16(sp)
    8000374c:	e466                	sd	s9,8(sp)
    8000374e:	e06a                	sd	s10,0(sp)
    80003750:	1080                	addi	s0,sp,96
    80003752:	84aa                	mv	s1,a0
    80003754:	8b2e                	mv	s6,a1
    80003756:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003758:	00054703          	lbu	a4,0(a0)
    8000375c:	02f00793          	li	a5,47
    80003760:	00f70f63          	beq	a4,a5,8000377e <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003764:	978fe0ef          	jal	800018dc <myproc>
    80003768:	15053503          	ld	a0,336(a0)
    8000376c:	a85ff0ef          	jal	800031f0 <idup>
    80003770:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003772:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003776:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003778:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000377a:	4b85                	li	s7,1
    8000377c:	a879                	j	8000381a <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000377e:	4585                	li	a1,1
    80003780:	852e                	mv	a0,a1
    80003782:	fc4ff0ef          	jal	80002f46 <iget>
    80003786:	8a2a                	mv	s4,a0
    80003788:	b7ed                	j	80003772 <namex+0x3c>
      iunlockput(ip);
    8000378a:	8552                	mv	a0,s4
    8000378c:	ca5ff0ef          	jal	80003430 <iunlockput>
      return 0;
    80003790:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003792:	8552                	mv	a0,s4
    80003794:	60e6                	ld	ra,88(sp)
    80003796:	6446                	ld	s0,80(sp)
    80003798:	64a6                	ld	s1,72(sp)
    8000379a:	6906                	ld	s2,64(sp)
    8000379c:	79e2                	ld	s3,56(sp)
    8000379e:	7a42                	ld	s4,48(sp)
    800037a0:	7aa2                	ld	s5,40(sp)
    800037a2:	7b02                	ld	s6,32(sp)
    800037a4:	6be2                	ld	s7,24(sp)
    800037a6:	6c42                	ld	s8,16(sp)
    800037a8:	6ca2                	ld	s9,8(sp)
    800037aa:	6d02                	ld	s10,0(sp)
    800037ac:	6125                	addi	sp,sp,96
    800037ae:	8082                	ret
      iunlock(ip);
    800037b0:	8552                	mv	a0,s4
    800037b2:	b23ff0ef          	jal	800032d4 <iunlock>
      return ip;
    800037b6:	bff1                	j	80003792 <namex+0x5c>
      iunlockput(ip);
    800037b8:	8552                	mv	a0,s4
    800037ba:	c77ff0ef          	jal	80003430 <iunlockput>
      return 0;
    800037be:	8a4e                	mv	s4,s3
    800037c0:	bfc9                	j	80003792 <namex+0x5c>
  len = path - s;
    800037c2:	40998633          	sub	a2,s3,s1
    800037c6:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800037ca:	09ac5063          	bge	s8,s10,8000384a <namex+0x114>
    memmove(name, s, DIRSIZ);
    800037ce:	8666                	mv	a2,s9
    800037d0:	85a6                	mv	a1,s1
    800037d2:	8556                	mv	a0,s5
    800037d4:	d5efd0ef          	jal	80000d32 <memmove>
    800037d8:	84ce                	mv	s1,s3
  while(*path == '/')
    800037da:	0004c783          	lbu	a5,0(s1)
    800037de:	01279763          	bne	a5,s2,800037ec <namex+0xb6>
    path++;
    800037e2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800037e4:	0004c783          	lbu	a5,0(s1)
    800037e8:	ff278de3          	beq	a5,s2,800037e2 <namex+0xac>
    ilock(ip);
    800037ec:	8552                	mv	a0,s4
    800037ee:	a39ff0ef          	jal	80003226 <ilock>
    if(ip->type != T_DIR){
    800037f2:	044a1783          	lh	a5,68(s4)
    800037f6:	f9779ae3          	bne	a5,s7,8000378a <namex+0x54>
    if(nameiparent && *path == '\0'){
    800037fa:	000b0563          	beqz	s6,80003804 <namex+0xce>
    800037fe:	0004c783          	lbu	a5,0(s1)
    80003802:	d7dd                	beqz	a5,800037b0 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003804:	4601                	li	a2,0
    80003806:	85d6                	mv	a1,s5
    80003808:	8552                	mv	a0,s4
    8000380a:	e81ff0ef          	jal	8000368a <dirlookup>
    8000380e:	89aa                	mv	s3,a0
    80003810:	d545                	beqz	a0,800037b8 <namex+0x82>
    iunlockput(ip);
    80003812:	8552                	mv	a0,s4
    80003814:	c1dff0ef          	jal	80003430 <iunlockput>
    ip = next;
    80003818:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000381a:	0004c783          	lbu	a5,0(s1)
    8000381e:	01279763          	bne	a5,s2,8000382c <namex+0xf6>
    path++;
    80003822:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003824:	0004c783          	lbu	a5,0(s1)
    80003828:	ff278de3          	beq	a5,s2,80003822 <namex+0xec>
  if(*path == 0)
    8000382c:	cb8d                	beqz	a5,8000385e <namex+0x128>
  while(*path != '/' && *path != 0)
    8000382e:	0004c783          	lbu	a5,0(s1)
    80003832:	89a6                	mv	s3,s1
  len = path - s;
    80003834:	4d01                	li	s10,0
    80003836:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003838:	01278963          	beq	a5,s2,8000384a <namex+0x114>
    8000383c:	d3d9                	beqz	a5,800037c2 <namex+0x8c>
    path++;
    8000383e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003840:	0009c783          	lbu	a5,0(s3)
    80003844:	ff279ce3          	bne	a5,s2,8000383c <namex+0x106>
    80003848:	bfad                	j	800037c2 <namex+0x8c>
    memmove(name, s, len);
    8000384a:	2601                	sext.w	a2,a2
    8000384c:	85a6                	mv	a1,s1
    8000384e:	8556                	mv	a0,s5
    80003850:	ce2fd0ef          	jal	80000d32 <memmove>
    name[len] = 0;
    80003854:	9d56                	add	s10,s10,s5
    80003856:	000d0023          	sb	zero,0(s10)
    8000385a:	84ce                	mv	s1,s3
    8000385c:	bfbd                	j	800037da <namex+0xa4>
  if(nameiparent){
    8000385e:	f20b0ae3          	beqz	s6,80003792 <namex+0x5c>
    iput(ip);
    80003862:	8552                	mv	a0,s4
    80003864:	b45ff0ef          	jal	800033a8 <iput>
    return 0;
    80003868:	4a01                	li	s4,0
    8000386a:	b725                	j	80003792 <namex+0x5c>

000000008000386c <dirlink>:
{
    8000386c:	715d                	addi	sp,sp,-80
    8000386e:	e486                	sd	ra,72(sp)
    80003870:	e0a2                	sd	s0,64(sp)
    80003872:	f84a                	sd	s2,48(sp)
    80003874:	ec56                	sd	s5,24(sp)
    80003876:	e85a                	sd	s6,16(sp)
    80003878:	0880                	addi	s0,sp,80
    8000387a:	892a                	mv	s2,a0
    8000387c:	8aae                	mv	s5,a1
    8000387e:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003880:	4601                	li	a2,0
    80003882:	e09ff0ef          	jal	8000368a <dirlookup>
    80003886:	ed1d                	bnez	a0,800038c4 <dirlink+0x58>
    80003888:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000388a:	04c92483          	lw	s1,76(s2)
    8000388e:	c4b9                	beqz	s1,800038dc <dirlink+0x70>
    80003890:	f44e                	sd	s3,40(sp)
    80003892:	f052                	sd	s4,32(sp)
    80003894:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003896:	fb040a13          	addi	s4,s0,-80
    8000389a:	49c1                	li	s3,16
    8000389c:	874e                	mv	a4,s3
    8000389e:	86a6                	mv	a3,s1
    800038a0:	8652                	mv	a2,s4
    800038a2:	4581                	li	a1,0
    800038a4:	854a                	mv	a0,s2
    800038a6:	bd9ff0ef          	jal	8000347e <readi>
    800038aa:	03351163          	bne	a0,s3,800038cc <dirlink+0x60>
    if(de.inum == 0)
    800038ae:	fb045783          	lhu	a5,-80(s0)
    800038b2:	c39d                	beqz	a5,800038d8 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038b4:	24c1                	addiw	s1,s1,16
    800038b6:	04c92783          	lw	a5,76(s2)
    800038ba:	fef4e1e3          	bltu	s1,a5,8000389c <dirlink+0x30>
    800038be:	79a2                	ld	s3,40(sp)
    800038c0:	7a02                	ld	s4,32(sp)
    800038c2:	a829                	j	800038dc <dirlink+0x70>
    iput(ip);
    800038c4:	ae5ff0ef          	jal	800033a8 <iput>
    return -1;
    800038c8:	557d                	li	a0,-1
    800038ca:	a83d                	j	80003908 <dirlink+0x9c>
      panic("dirlink read");
    800038cc:	00004517          	auipc	a0,0x4
    800038d0:	c7c50513          	addi	a0,a0,-900 # 80007548 <etext+0x548>
    800038d4:	ecbfc0ef          	jal	8000079e <panic>
    800038d8:	79a2                	ld	s3,40(sp)
    800038da:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    800038dc:	4639                	li	a2,14
    800038de:	85d6                	mv	a1,s5
    800038e0:	fb240513          	addi	a0,s0,-78
    800038e4:	cfcfd0ef          	jal	80000de0 <strncpy>
  de.inum = inum;
    800038e8:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038ec:	4741                	li	a4,16
    800038ee:	86a6                	mv	a3,s1
    800038f0:	fb040613          	addi	a2,s0,-80
    800038f4:	4581                	li	a1,0
    800038f6:	854a                	mv	a0,s2
    800038f8:	c79ff0ef          	jal	80003570 <writei>
    800038fc:	1541                	addi	a0,a0,-16
    800038fe:	00a03533          	snez	a0,a0
    80003902:	40a0053b          	negw	a0,a0
    80003906:	74e2                	ld	s1,56(sp)
}
    80003908:	60a6                	ld	ra,72(sp)
    8000390a:	6406                	ld	s0,64(sp)
    8000390c:	7942                	ld	s2,48(sp)
    8000390e:	6ae2                	ld	s5,24(sp)
    80003910:	6b42                	ld	s6,16(sp)
    80003912:	6161                	addi	sp,sp,80
    80003914:	8082                	ret

0000000080003916 <namei>:

struct inode*
namei(char *path)
{
    80003916:	1101                	addi	sp,sp,-32
    80003918:	ec06                	sd	ra,24(sp)
    8000391a:	e822                	sd	s0,16(sp)
    8000391c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000391e:	fe040613          	addi	a2,s0,-32
    80003922:	4581                	li	a1,0
    80003924:	e13ff0ef          	jal	80003736 <namex>
}
    80003928:	60e2                	ld	ra,24(sp)
    8000392a:	6442                	ld	s0,16(sp)
    8000392c:	6105                	addi	sp,sp,32
    8000392e:	8082                	ret

0000000080003930 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003930:	1141                	addi	sp,sp,-16
    80003932:	e406                	sd	ra,8(sp)
    80003934:	e022                	sd	s0,0(sp)
    80003936:	0800                	addi	s0,sp,16
    80003938:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000393a:	4585                	li	a1,1
    8000393c:	dfbff0ef          	jal	80003736 <namex>
}
    80003940:	60a2                	ld	ra,8(sp)
    80003942:	6402                	ld	s0,0(sp)
    80003944:	0141                	addi	sp,sp,16
    80003946:	8082                	ret

0000000080003948 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003948:	1101                	addi	sp,sp,-32
    8000394a:	ec06                	sd	ra,24(sp)
    8000394c:	e822                	sd	s0,16(sp)
    8000394e:	e426                	sd	s1,8(sp)
    80003950:	e04a                	sd	s2,0(sp)
    80003952:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003954:	00022917          	auipc	s2,0x22
    80003958:	aac90913          	addi	s2,s2,-1364 # 80025400 <log>
    8000395c:	01892583          	lw	a1,24(s2)
    80003960:	02892503          	lw	a0,40(s2)
    80003964:	9b0ff0ef          	jal	80002b14 <bread>
    80003968:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000396a:	02c92603          	lw	a2,44(s2)
    8000396e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003970:	00c05f63          	blez	a2,8000398e <write_head+0x46>
    80003974:	00022717          	auipc	a4,0x22
    80003978:	abc70713          	addi	a4,a4,-1348 # 80025430 <log+0x30>
    8000397c:	87aa                	mv	a5,a0
    8000397e:	060a                	slli	a2,a2,0x2
    80003980:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003982:	4314                	lw	a3,0(a4)
    80003984:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003986:	0711                	addi	a4,a4,4
    80003988:	0791                	addi	a5,a5,4
    8000398a:	fec79ce3          	bne	a5,a2,80003982 <write_head+0x3a>
  }
  bwrite(buf);
    8000398e:	8526                	mv	a0,s1
    80003990:	a5aff0ef          	jal	80002bea <bwrite>
  brelse(buf);
    80003994:	8526                	mv	a0,s1
    80003996:	a86ff0ef          	jal	80002c1c <brelse>
}
    8000399a:	60e2                	ld	ra,24(sp)
    8000399c:	6442                	ld	s0,16(sp)
    8000399e:	64a2                	ld	s1,8(sp)
    800039a0:	6902                	ld	s2,0(sp)
    800039a2:	6105                	addi	sp,sp,32
    800039a4:	8082                	ret

00000000800039a6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800039a6:	00022797          	auipc	a5,0x22
    800039aa:	a867a783          	lw	a5,-1402(a5) # 8002542c <log+0x2c>
    800039ae:	0af05263          	blez	a5,80003a52 <install_trans+0xac>
{
    800039b2:	715d                	addi	sp,sp,-80
    800039b4:	e486                	sd	ra,72(sp)
    800039b6:	e0a2                	sd	s0,64(sp)
    800039b8:	fc26                	sd	s1,56(sp)
    800039ba:	f84a                	sd	s2,48(sp)
    800039bc:	f44e                	sd	s3,40(sp)
    800039be:	f052                	sd	s4,32(sp)
    800039c0:	ec56                	sd	s5,24(sp)
    800039c2:	e85a                	sd	s6,16(sp)
    800039c4:	e45e                	sd	s7,8(sp)
    800039c6:	0880                	addi	s0,sp,80
    800039c8:	8b2a                	mv	s6,a0
    800039ca:	00022a97          	auipc	s5,0x22
    800039ce:	a66a8a93          	addi	s5,s5,-1434 # 80025430 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039d2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039d4:	00022997          	auipc	s3,0x22
    800039d8:	a2c98993          	addi	s3,s3,-1492 # 80025400 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800039dc:	40000b93          	li	s7,1024
    800039e0:	a829                	j	800039fa <install_trans+0x54>
    brelse(lbuf);
    800039e2:	854a                	mv	a0,s2
    800039e4:	a38ff0ef          	jal	80002c1c <brelse>
    brelse(dbuf);
    800039e8:	8526                	mv	a0,s1
    800039ea:	a32ff0ef          	jal	80002c1c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039ee:	2a05                	addiw	s4,s4,1
    800039f0:	0a91                	addi	s5,s5,4
    800039f2:	02c9a783          	lw	a5,44(s3)
    800039f6:	04fa5363          	bge	s4,a5,80003a3c <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039fa:	0189a583          	lw	a1,24(s3)
    800039fe:	014585bb          	addw	a1,a1,s4
    80003a02:	2585                	addiw	a1,a1,1
    80003a04:	0289a503          	lw	a0,40(s3)
    80003a08:	90cff0ef          	jal	80002b14 <bread>
    80003a0c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003a0e:	000aa583          	lw	a1,0(s5)
    80003a12:	0289a503          	lw	a0,40(s3)
    80003a16:	8feff0ef          	jal	80002b14 <bread>
    80003a1a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003a1c:	865e                	mv	a2,s7
    80003a1e:	05890593          	addi	a1,s2,88
    80003a22:	05850513          	addi	a0,a0,88
    80003a26:	b0cfd0ef          	jal	80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003a2a:	8526                	mv	a0,s1
    80003a2c:	9beff0ef          	jal	80002bea <bwrite>
    if(recovering == 0)
    80003a30:	fa0b19e3          	bnez	s6,800039e2 <install_trans+0x3c>
      bunpin(dbuf);
    80003a34:	8526                	mv	a0,s1
    80003a36:	a9eff0ef          	jal	80002cd4 <bunpin>
    80003a3a:	b765                	j	800039e2 <install_trans+0x3c>
}
    80003a3c:	60a6                	ld	ra,72(sp)
    80003a3e:	6406                	ld	s0,64(sp)
    80003a40:	74e2                	ld	s1,56(sp)
    80003a42:	7942                	ld	s2,48(sp)
    80003a44:	79a2                	ld	s3,40(sp)
    80003a46:	7a02                	ld	s4,32(sp)
    80003a48:	6ae2                	ld	s5,24(sp)
    80003a4a:	6b42                	ld	s6,16(sp)
    80003a4c:	6ba2                	ld	s7,8(sp)
    80003a4e:	6161                	addi	sp,sp,80
    80003a50:	8082                	ret
    80003a52:	8082                	ret

0000000080003a54 <initlog>:
{
    80003a54:	7179                	addi	sp,sp,-48
    80003a56:	f406                	sd	ra,40(sp)
    80003a58:	f022                	sd	s0,32(sp)
    80003a5a:	ec26                	sd	s1,24(sp)
    80003a5c:	e84a                	sd	s2,16(sp)
    80003a5e:	e44e                	sd	s3,8(sp)
    80003a60:	1800                	addi	s0,sp,48
    80003a62:	892a                	mv	s2,a0
    80003a64:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003a66:	00022497          	auipc	s1,0x22
    80003a6a:	99a48493          	addi	s1,s1,-1638 # 80025400 <log>
    80003a6e:	00004597          	auipc	a1,0x4
    80003a72:	aea58593          	addi	a1,a1,-1302 # 80007558 <etext+0x558>
    80003a76:	8526                	mv	a0,s1
    80003a78:	902fd0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    80003a7c:	0149a583          	lw	a1,20(s3)
    80003a80:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003a82:	0109a783          	lw	a5,16(s3)
    80003a86:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003a88:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003a8c:	854a                	mv	a0,s2
    80003a8e:	886ff0ef          	jal	80002b14 <bread>
  log.lh.n = lh->n;
    80003a92:	4d30                	lw	a2,88(a0)
    80003a94:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003a96:	00c05f63          	blez	a2,80003ab4 <initlog+0x60>
    80003a9a:	87aa                	mv	a5,a0
    80003a9c:	00022717          	auipc	a4,0x22
    80003aa0:	99470713          	addi	a4,a4,-1644 # 80025430 <log+0x30>
    80003aa4:	060a                	slli	a2,a2,0x2
    80003aa6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003aa8:	4ff4                	lw	a3,92(a5)
    80003aaa:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003aac:	0791                	addi	a5,a5,4
    80003aae:	0711                	addi	a4,a4,4
    80003ab0:	fec79ce3          	bne	a5,a2,80003aa8 <initlog+0x54>
  brelse(buf);
    80003ab4:	968ff0ef          	jal	80002c1c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ab8:	4505                	li	a0,1
    80003aba:	eedff0ef          	jal	800039a6 <install_trans>
  log.lh.n = 0;
    80003abe:	00022797          	auipc	a5,0x22
    80003ac2:	9607a723          	sw	zero,-1682(a5) # 8002542c <log+0x2c>
  write_head(); // clear the log
    80003ac6:	e83ff0ef          	jal	80003948 <write_head>
}
    80003aca:	70a2                	ld	ra,40(sp)
    80003acc:	7402                	ld	s0,32(sp)
    80003ace:	64e2                	ld	s1,24(sp)
    80003ad0:	6942                	ld	s2,16(sp)
    80003ad2:	69a2                	ld	s3,8(sp)
    80003ad4:	6145                	addi	sp,sp,48
    80003ad6:	8082                	ret

0000000080003ad8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ad8:	1101                	addi	sp,sp,-32
    80003ada:	ec06                	sd	ra,24(sp)
    80003adc:	e822                	sd	s0,16(sp)
    80003ade:	e426                	sd	s1,8(sp)
    80003ae0:	e04a                	sd	s2,0(sp)
    80003ae2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ae4:	00022517          	auipc	a0,0x22
    80003ae8:	91c50513          	addi	a0,a0,-1764 # 80025400 <log>
    80003aec:	912fd0ef          	jal	80000bfe <acquire>
  while(1){
    if(log.committing){
    80003af0:	00022497          	auipc	s1,0x22
    80003af4:	91048493          	addi	s1,s1,-1776 # 80025400 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003af8:	4979                	li	s2,30
    80003afa:	a029                	j	80003b04 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003afc:	85a6                	mv	a1,s1
    80003afe:	8526                	mv	a0,s1
    80003b00:	bd4fe0ef          	jal	80001ed4 <sleep>
    if(log.committing){
    80003b04:	50dc                	lw	a5,36(s1)
    80003b06:	fbfd                	bnez	a5,80003afc <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b08:	5098                	lw	a4,32(s1)
    80003b0a:	2705                	addiw	a4,a4,1
    80003b0c:	0027179b          	slliw	a5,a4,0x2
    80003b10:	9fb9                	addw	a5,a5,a4
    80003b12:	0017979b          	slliw	a5,a5,0x1
    80003b16:	54d4                	lw	a3,44(s1)
    80003b18:	9fb5                	addw	a5,a5,a3
    80003b1a:	00f95763          	bge	s2,a5,80003b28 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003b1e:	85a6                	mv	a1,s1
    80003b20:	8526                	mv	a0,s1
    80003b22:	bb2fe0ef          	jal	80001ed4 <sleep>
    80003b26:	bff9                	j	80003b04 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003b28:	00022517          	auipc	a0,0x22
    80003b2c:	8d850513          	addi	a0,a0,-1832 # 80025400 <log>
    80003b30:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003b32:	960fd0ef          	jal	80000c92 <release>
      break;
    }
  }
}
    80003b36:	60e2                	ld	ra,24(sp)
    80003b38:	6442                	ld	s0,16(sp)
    80003b3a:	64a2                	ld	s1,8(sp)
    80003b3c:	6902                	ld	s2,0(sp)
    80003b3e:	6105                	addi	sp,sp,32
    80003b40:	8082                	ret

0000000080003b42 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003b42:	7139                	addi	sp,sp,-64
    80003b44:	fc06                	sd	ra,56(sp)
    80003b46:	f822                	sd	s0,48(sp)
    80003b48:	f426                	sd	s1,40(sp)
    80003b4a:	f04a                	sd	s2,32(sp)
    80003b4c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003b4e:	00022497          	auipc	s1,0x22
    80003b52:	8b248493          	addi	s1,s1,-1870 # 80025400 <log>
    80003b56:	8526                	mv	a0,s1
    80003b58:	8a6fd0ef          	jal	80000bfe <acquire>
  log.outstanding -= 1;
    80003b5c:	509c                	lw	a5,32(s1)
    80003b5e:	37fd                	addiw	a5,a5,-1
    80003b60:	893e                	mv	s2,a5
    80003b62:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003b64:	50dc                	lw	a5,36(s1)
    80003b66:	ef9d                	bnez	a5,80003ba4 <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80003b68:	04091863          	bnez	s2,80003bb8 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003b6c:	00022497          	auipc	s1,0x22
    80003b70:	89448493          	addi	s1,s1,-1900 # 80025400 <log>
    80003b74:	4785                	li	a5,1
    80003b76:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b78:	8526                	mv	a0,s1
    80003b7a:	918fd0ef          	jal	80000c92 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b7e:	54dc                	lw	a5,44(s1)
    80003b80:	04f04c63          	bgtz	a5,80003bd8 <end_op+0x96>
    acquire(&log.lock);
    80003b84:	00022497          	auipc	s1,0x22
    80003b88:	87c48493          	addi	s1,s1,-1924 # 80025400 <log>
    80003b8c:	8526                	mv	a0,s1
    80003b8e:	870fd0ef          	jal	80000bfe <acquire>
    log.committing = 0;
    80003b92:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003b96:	8526                	mv	a0,s1
    80003b98:	b88fe0ef          	jal	80001f20 <wakeup>
    release(&log.lock);
    80003b9c:	8526                	mv	a0,s1
    80003b9e:	8f4fd0ef          	jal	80000c92 <release>
}
    80003ba2:	a02d                	j	80003bcc <end_op+0x8a>
    80003ba4:	ec4e                	sd	s3,24(sp)
    80003ba6:	e852                	sd	s4,16(sp)
    80003ba8:	e456                	sd	s5,8(sp)
    80003baa:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003bac:	00004517          	auipc	a0,0x4
    80003bb0:	9b450513          	addi	a0,a0,-1612 # 80007560 <etext+0x560>
    80003bb4:	bebfc0ef          	jal	8000079e <panic>
    wakeup(&log);
    80003bb8:	00022497          	auipc	s1,0x22
    80003bbc:	84848493          	addi	s1,s1,-1976 # 80025400 <log>
    80003bc0:	8526                	mv	a0,s1
    80003bc2:	b5efe0ef          	jal	80001f20 <wakeup>
  release(&log.lock);
    80003bc6:	8526                	mv	a0,s1
    80003bc8:	8cafd0ef          	jal	80000c92 <release>
}
    80003bcc:	70e2                	ld	ra,56(sp)
    80003bce:	7442                	ld	s0,48(sp)
    80003bd0:	74a2                	ld	s1,40(sp)
    80003bd2:	7902                	ld	s2,32(sp)
    80003bd4:	6121                	addi	sp,sp,64
    80003bd6:	8082                	ret
    80003bd8:	ec4e                	sd	s3,24(sp)
    80003bda:	e852                	sd	s4,16(sp)
    80003bdc:	e456                	sd	s5,8(sp)
    80003bde:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003be0:	00022a97          	auipc	s5,0x22
    80003be4:	850a8a93          	addi	s5,s5,-1968 # 80025430 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003be8:	00022a17          	auipc	s4,0x22
    80003bec:	818a0a13          	addi	s4,s4,-2024 # 80025400 <log>
    memmove(to->data, from->data, BSIZE);
    80003bf0:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003bf4:	018a2583          	lw	a1,24(s4)
    80003bf8:	012585bb          	addw	a1,a1,s2
    80003bfc:	2585                	addiw	a1,a1,1
    80003bfe:	028a2503          	lw	a0,40(s4)
    80003c02:	f13fe0ef          	jal	80002b14 <bread>
    80003c06:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003c08:	000aa583          	lw	a1,0(s5)
    80003c0c:	028a2503          	lw	a0,40(s4)
    80003c10:	f05fe0ef          	jal	80002b14 <bread>
    80003c14:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003c16:	865a                	mv	a2,s6
    80003c18:	05850593          	addi	a1,a0,88
    80003c1c:	05848513          	addi	a0,s1,88
    80003c20:	912fd0ef          	jal	80000d32 <memmove>
    bwrite(to);  // write the log
    80003c24:	8526                	mv	a0,s1
    80003c26:	fc5fe0ef          	jal	80002bea <bwrite>
    brelse(from);
    80003c2a:	854e                	mv	a0,s3
    80003c2c:	ff1fe0ef          	jal	80002c1c <brelse>
    brelse(to);
    80003c30:	8526                	mv	a0,s1
    80003c32:	febfe0ef          	jal	80002c1c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c36:	2905                	addiw	s2,s2,1
    80003c38:	0a91                	addi	s5,s5,4
    80003c3a:	02ca2783          	lw	a5,44(s4)
    80003c3e:	faf94be3          	blt	s2,a5,80003bf4 <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003c42:	d07ff0ef          	jal	80003948 <write_head>
    install_trans(0); // Now install writes to home locations
    80003c46:	4501                	li	a0,0
    80003c48:	d5fff0ef          	jal	800039a6 <install_trans>
    log.lh.n = 0;
    80003c4c:	00021797          	auipc	a5,0x21
    80003c50:	7e07a023          	sw	zero,2016(a5) # 8002542c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003c54:	cf5ff0ef          	jal	80003948 <write_head>
    80003c58:	69e2                	ld	s3,24(sp)
    80003c5a:	6a42                	ld	s4,16(sp)
    80003c5c:	6aa2                	ld	s5,8(sp)
    80003c5e:	6b02                	ld	s6,0(sp)
    80003c60:	b715                	j	80003b84 <end_op+0x42>

0000000080003c62 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003c62:	1101                	addi	sp,sp,-32
    80003c64:	ec06                	sd	ra,24(sp)
    80003c66:	e822                	sd	s0,16(sp)
    80003c68:	e426                	sd	s1,8(sp)
    80003c6a:	e04a                	sd	s2,0(sp)
    80003c6c:	1000                	addi	s0,sp,32
    80003c6e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003c70:	00021917          	auipc	s2,0x21
    80003c74:	79090913          	addi	s2,s2,1936 # 80025400 <log>
    80003c78:	854a                	mv	a0,s2
    80003c7a:	f85fc0ef          	jal	80000bfe <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003c7e:	02c92603          	lw	a2,44(s2)
    80003c82:	47f5                	li	a5,29
    80003c84:	06c7c363          	blt	a5,a2,80003cea <log_write+0x88>
    80003c88:	00021797          	auipc	a5,0x21
    80003c8c:	7947a783          	lw	a5,1940(a5) # 8002541c <log+0x1c>
    80003c90:	37fd                	addiw	a5,a5,-1
    80003c92:	04f65c63          	bge	a2,a5,80003cea <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003c96:	00021797          	auipc	a5,0x21
    80003c9a:	78a7a783          	lw	a5,1930(a5) # 80025420 <log+0x20>
    80003c9e:	04f05c63          	blez	a5,80003cf6 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003ca2:	4781                	li	a5,0
    80003ca4:	04c05f63          	blez	a2,80003d02 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ca8:	44cc                	lw	a1,12(s1)
    80003caa:	00021717          	auipc	a4,0x21
    80003cae:	78670713          	addi	a4,a4,1926 # 80025430 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003cb2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003cb4:	4314                	lw	a3,0(a4)
    80003cb6:	04b68663          	beq	a3,a1,80003d02 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003cba:	2785                	addiw	a5,a5,1
    80003cbc:	0711                	addi	a4,a4,4
    80003cbe:	fef61be3          	bne	a2,a5,80003cb4 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003cc2:	0621                	addi	a2,a2,8
    80003cc4:	060a                	slli	a2,a2,0x2
    80003cc6:	00021797          	auipc	a5,0x21
    80003cca:	73a78793          	addi	a5,a5,1850 # 80025400 <log>
    80003cce:	97b2                	add	a5,a5,a2
    80003cd0:	44d8                	lw	a4,12(s1)
    80003cd2:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003cd4:	8526                	mv	a0,s1
    80003cd6:	fcbfe0ef          	jal	80002ca0 <bpin>
    log.lh.n++;
    80003cda:	00021717          	auipc	a4,0x21
    80003cde:	72670713          	addi	a4,a4,1830 # 80025400 <log>
    80003ce2:	575c                	lw	a5,44(a4)
    80003ce4:	2785                	addiw	a5,a5,1
    80003ce6:	d75c                	sw	a5,44(a4)
    80003ce8:	a80d                	j	80003d1a <log_write+0xb8>
    panic("too big a transaction");
    80003cea:	00004517          	auipc	a0,0x4
    80003cee:	88650513          	addi	a0,a0,-1914 # 80007570 <etext+0x570>
    80003cf2:	aadfc0ef          	jal	8000079e <panic>
    panic("log_write outside of trans");
    80003cf6:	00004517          	auipc	a0,0x4
    80003cfa:	89250513          	addi	a0,a0,-1902 # 80007588 <etext+0x588>
    80003cfe:	aa1fc0ef          	jal	8000079e <panic>
  log.lh.block[i] = b->blockno;
    80003d02:	00878693          	addi	a3,a5,8
    80003d06:	068a                	slli	a3,a3,0x2
    80003d08:	00021717          	auipc	a4,0x21
    80003d0c:	6f870713          	addi	a4,a4,1784 # 80025400 <log>
    80003d10:	9736                	add	a4,a4,a3
    80003d12:	44d4                	lw	a3,12(s1)
    80003d14:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003d16:	faf60fe3          	beq	a2,a5,80003cd4 <log_write+0x72>
  }
  release(&log.lock);
    80003d1a:	00021517          	auipc	a0,0x21
    80003d1e:	6e650513          	addi	a0,a0,1766 # 80025400 <log>
    80003d22:	f71fc0ef          	jal	80000c92 <release>
}
    80003d26:	60e2                	ld	ra,24(sp)
    80003d28:	6442                	ld	s0,16(sp)
    80003d2a:	64a2                	ld	s1,8(sp)
    80003d2c:	6902                	ld	s2,0(sp)
    80003d2e:	6105                	addi	sp,sp,32
    80003d30:	8082                	ret

0000000080003d32 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003d32:	1101                	addi	sp,sp,-32
    80003d34:	ec06                	sd	ra,24(sp)
    80003d36:	e822                	sd	s0,16(sp)
    80003d38:	e426                	sd	s1,8(sp)
    80003d3a:	e04a                	sd	s2,0(sp)
    80003d3c:	1000                	addi	s0,sp,32
    80003d3e:	84aa                	mv	s1,a0
    80003d40:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003d42:	00004597          	auipc	a1,0x4
    80003d46:	86658593          	addi	a1,a1,-1946 # 800075a8 <etext+0x5a8>
    80003d4a:	0521                	addi	a0,a0,8
    80003d4c:	e2ffc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80003d50:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003d54:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d58:	0204a423          	sw	zero,40(s1)
}
    80003d5c:	60e2                	ld	ra,24(sp)
    80003d5e:	6442                	ld	s0,16(sp)
    80003d60:	64a2                	ld	s1,8(sp)
    80003d62:	6902                	ld	s2,0(sp)
    80003d64:	6105                	addi	sp,sp,32
    80003d66:	8082                	ret

0000000080003d68 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003d68:	1101                	addi	sp,sp,-32
    80003d6a:	ec06                	sd	ra,24(sp)
    80003d6c:	e822                	sd	s0,16(sp)
    80003d6e:	e426                	sd	s1,8(sp)
    80003d70:	e04a                	sd	s2,0(sp)
    80003d72:	1000                	addi	s0,sp,32
    80003d74:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d76:	00850913          	addi	s2,a0,8
    80003d7a:	854a                	mv	a0,s2
    80003d7c:	e83fc0ef          	jal	80000bfe <acquire>
  while (lk->locked) {
    80003d80:	409c                	lw	a5,0(s1)
    80003d82:	c799                	beqz	a5,80003d90 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d84:	85ca                	mv	a1,s2
    80003d86:	8526                	mv	a0,s1
    80003d88:	94cfe0ef          	jal	80001ed4 <sleep>
  while (lk->locked) {
    80003d8c:	409c                	lw	a5,0(s1)
    80003d8e:	fbfd                	bnez	a5,80003d84 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003d90:	4785                	li	a5,1
    80003d92:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003d94:	b49fd0ef          	jal	800018dc <myproc>
    80003d98:	591c                	lw	a5,48(a0)
    80003d9a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003d9c:	854a                	mv	a0,s2
    80003d9e:	ef5fc0ef          	jal	80000c92 <release>
}
    80003da2:	60e2                	ld	ra,24(sp)
    80003da4:	6442                	ld	s0,16(sp)
    80003da6:	64a2                	ld	s1,8(sp)
    80003da8:	6902                	ld	s2,0(sp)
    80003daa:	6105                	addi	sp,sp,32
    80003dac:	8082                	ret

0000000080003dae <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003dae:	1101                	addi	sp,sp,-32
    80003db0:	ec06                	sd	ra,24(sp)
    80003db2:	e822                	sd	s0,16(sp)
    80003db4:	e426                	sd	s1,8(sp)
    80003db6:	e04a                	sd	s2,0(sp)
    80003db8:	1000                	addi	s0,sp,32
    80003dba:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003dbc:	00850913          	addi	s2,a0,8
    80003dc0:	854a                	mv	a0,s2
    80003dc2:	e3dfc0ef          	jal	80000bfe <acquire>
  lk->locked = 0;
    80003dc6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003dca:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003dce:	8526                	mv	a0,s1
    80003dd0:	950fe0ef          	jal	80001f20 <wakeup>
  release(&lk->lk);
    80003dd4:	854a                	mv	a0,s2
    80003dd6:	ebdfc0ef          	jal	80000c92 <release>
}
    80003dda:	60e2                	ld	ra,24(sp)
    80003ddc:	6442                	ld	s0,16(sp)
    80003dde:	64a2                	ld	s1,8(sp)
    80003de0:	6902                	ld	s2,0(sp)
    80003de2:	6105                	addi	sp,sp,32
    80003de4:	8082                	ret

0000000080003de6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003de6:	7179                	addi	sp,sp,-48
    80003de8:	f406                	sd	ra,40(sp)
    80003dea:	f022                	sd	s0,32(sp)
    80003dec:	ec26                	sd	s1,24(sp)
    80003dee:	e84a                	sd	s2,16(sp)
    80003df0:	1800                	addi	s0,sp,48
    80003df2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003df4:	00850913          	addi	s2,a0,8
    80003df8:	854a                	mv	a0,s2
    80003dfa:	e05fc0ef          	jal	80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003dfe:	409c                	lw	a5,0(s1)
    80003e00:	ef81                	bnez	a5,80003e18 <holdingsleep+0x32>
    80003e02:	4481                	li	s1,0
  release(&lk->lk);
    80003e04:	854a                	mv	a0,s2
    80003e06:	e8dfc0ef          	jal	80000c92 <release>
  return r;
}
    80003e0a:	8526                	mv	a0,s1
    80003e0c:	70a2                	ld	ra,40(sp)
    80003e0e:	7402                	ld	s0,32(sp)
    80003e10:	64e2                	ld	s1,24(sp)
    80003e12:	6942                	ld	s2,16(sp)
    80003e14:	6145                	addi	sp,sp,48
    80003e16:	8082                	ret
    80003e18:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e1a:	0284a983          	lw	s3,40(s1)
    80003e1e:	abffd0ef          	jal	800018dc <myproc>
    80003e22:	5904                	lw	s1,48(a0)
    80003e24:	413484b3          	sub	s1,s1,s3
    80003e28:	0014b493          	seqz	s1,s1
    80003e2c:	69a2                	ld	s3,8(sp)
    80003e2e:	bfd9                	j	80003e04 <holdingsleep+0x1e>

0000000080003e30 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003e30:	1141                	addi	sp,sp,-16
    80003e32:	e406                	sd	ra,8(sp)
    80003e34:	e022                	sd	s0,0(sp)
    80003e36:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003e38:	00003597          	auipc	a1,0x3
    80003e3c:	78058593          	addi	a1,a1,1920 # 800075b8 <etext+0x5b8>
    80003e40:	00021517          	auipc	a0,0x21
    80003e44:	70850513          	addi	a0,a0,1800 # 80025548 <ftable>
    80003e48:	d33fc0ef          	jal	80000b7a <initlock>
}
    80003e4c:	60a2                	ld	ra,8(sp)
    80003e4e:	6402                	ld	s0,0(sp)
    80003e50:	0141                	addi	sp,sp,16
    80003e52:	8082                	ret

0000000080003e54 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003e54:	1101                	addi	sp,sp,-32
    80003e56:	ec06                	sd	ra,24(sp)
    80003e58:	e822                	sd	s0,16(sp)
    80003e5a:	e426                	sd	s1,8(sp)
    80003e5c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003e5e:	00021517          	auipc	a0,0x21
    80003e62:	6ea50513          	addi	a0,a0,1770 # 80025548 <ftable>
    80003e66:	d99fc0ef          	jal	80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e6a:	00021497          	auipc	s1,0x21
    80003e6e:	6f648493          	addi	s1,s1,1782 # 80025560 <ftable+0x18>
    80003e72:	00022717          	auipc	a4,0x22
    80003e76:	68e70713          	addi	a4,a4,1678 # 80026500 <disk>
    if(f->ref == 0){
    80003e7a:	40dc                	lw	a5,4(s1)
    80003e7c:	cf89                	beqz	a5,80003e96 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e7e:	02848493          	addi	s1,s1,40
    80003e82:	fee49ce3          	bne	s1,a4,80003e7a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003e86:	00021517          	auipc	a0,0x21
    80003e8a:	6c250513          	addi	a0,a0,1730 # 80025548 <ftable>
    80003e8e:	e05fc0ef          	jal	80000c92 <release>
  return 0;
    80003e92:	4481                	li	s1,0
    80003e94:	a809                	j	80003ea6 <filealloc+0x52>
      f->ref = 1;
    80003e96:	4785                	li	a5,1
    80003e98:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003e9a:	00021517          	auipc	a0,0x21
    80003e9e:	6ae50513          	addi	a0,a0,1710 # 80025548 <ftable>
    80003ea2:	df1fc0ef          	jal	80000c92 <release>
}
    80003ea6:	8526                	mv	a0,s1
    80003ea8:	60e2                	ld	ra,24(sp)
    80003eaa:	6442                	ld	s0,16(sp)
    80003eac:	64a2                	ld	s1,8(sp)
    80003eae:	6105                	addi	sp,sp,32
    80003eb0:	8082                	ret

0000000080003eb2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003eb2:	1101                	addi	sp,sp,-32
    80003eb4:	ec06                	sd	ra,24(sp)
    80003eb6:	e822                	sd	s0,16(sp)
    80003eb8:	e426                	sd	s1,8(sp)
    80003eba:	1000                	addi	s0,sp,32
    80003ebc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003ebe:	00021517          	auipc	a0,0x21
    80003ec2:	68a50513          	addi	a0,a0,1674 # 80025548 <ftable>
    80003ec6:	d39fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003eca:	40dc                	lw	a5,4(s1)
    80003ecc:	02f05063          	blez	a5,80003eec <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003ed0:	2785                	addiw	a5,a5,1
    80003ed2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003ed4:	00021517          	auipc	a0,0x21
    80003ed8:	67450513          	addi	a0,a0,1652 # 80025548 <ftable>
    80003edc:	db7fc0ef          	jal	80000c92 <release>
  return f;
}
    80003ee0:	8526                	mv	a0,s1
    80003ee2:	60e2                	ld	ra,24(sp)
    80003ee4:	6442                	ld	s0,16(sp)
    80003ee6:	64a2                	ld	s1,8(sp)
    80003ee8:	6105                	addi	sp,sp,32
    80003eea:	8082                	ret
    panic("filedup");
    80003eec:	00003517          	auipc	a0,0x3
    80003ef0:	6d450513          	addi	a0,a0,1748 # 800075c0 <etext+0x5c0>
    80003ef4:	8abfc0ef          	jal	8000079e <panic>

0000000080003ef8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003ef8:	7139                	addi	sp,sp,-64
    80003efa:	fc06                	sd	ra,56(sp)
    80003efc:	f822                	sd	s0,48(sp)
    80003efe:	f426                	sd	s1,40(sp)
    80003f00:	0080                	addi	s0,sp,64
    80003f02:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003f04:	00021517          	auipc	a0,0x21
    80003f08:	64450513          	addi	a0,a0,1604 # 80025548 <ftable>
    80003f0c:	cf3fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003f10:	40dc                	lw	a5,4(s1)
    80003f12:	04f05863          	blez	a5,80003f62 <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    80003f16:	37fd                	addiw	a5,a5,-1
    80003f18:	c0dc                	sw	a5,4(s1)
    80003f1a:	04f04e63          	bgtz	a5,80003f76 <fileclose+0x7e>
    80003f1e:	f04a                	sd	s2,32(sp)
    80003f20:	ec4e                	sd	s3,24(sp)
    80003f22:	e852                	sd	s4,16(sp)
    80003f24:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003f26:	0004a903          	lw	s2,0(s1)
    80003f2a:	0094ca83          	lbu	s5,9(s1)
    80003f2e:	0104ba03          	ld	s4,16(s1)
    80003f32:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003f36:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003f3a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003f3e:	00021517          	auipc	a0,0x21
    80003f42:	60a50513          	addi	a0,a0,1546 # 80025548 <ftable>
    80003f46:	d4dfc0ef          	jal	80000c92 <release>

  if(ff.type == FD_PIPE){
    80003f4a:	4785                	li	a5,1
    80003f4c:	04f90063          	beq	s2,a5,80003f8c <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003f50:	3979                	addiw	s2,s2,-2
    80003f52:	4785                	li	a5,1
    80003f54:	0527f563          	bgeu	a5,s2,80003f9e <fileclose+0xa6>
    80003f58:	7902                	ld	s2,32(sp)
    80003f5a:	69e2                	ld	s3,24(sp)
    80003f5c:	6a42                	ld	s4,16(sp)
    80003f5e:	6aa2                	ld	s5,8(sp)
    80003f60:	a00d                	j	80003f82 <fileclose+0x8a>
    80003f62:	f04a                	sd	s2,32(sp)
    80003f64:	ec4e                	sd	s3,24(sp)
    80003f66:	e852                	sd	s4,16(sp)
    80003f68:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003f6a:	00003517          	auipc	a0,0x3
    80003f6e:	65e50513          	addi	a0,a0,1630 # 800075c8 <etext+0x5c8>
    80003f72:	82dfc0ef          	jal	8000079e <panic>
    release(&ftable.lock);
    80003f76:	00021517          	auipc	a0,0x21
    80003f7a:	5d250513          	addi	a0,a0,1490 # 80025548 <ftable>
    80003f7e:	d15fc0ef          	jal	80000c92 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003f82:	70e2                	ld	ra,56(sp)
    80003f84:	7442                	ld	s0,48(sp)
    80003f86:	74a2                	ld	s1,40(sp)
    80003f88:	6121                	addi	sp,sp,64
    80003f8a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003f8c:	85d6                	mv	a1,s5
    80003f8e:	8552                	mv	a0,s4
    80003f90:	340000ef          	jal	800042d0 <pipeclose>
    80003f94:	7902                	ld	s2,32(sp)
    80003f96:	69e2                	ld	s3,24(sp)
    80003f98:	6a42                	ld	s4,16(sp)
    80003f9a:	6aa2                	ld	s5,8(sp)
    80003f9c:	b7dd                	j	80003f82 <fileclose+0x8a>
    begin_op();
    80003f9e:	b3bff0ef          	jal	80003ad8 <begin_op>
    iput(ff.ip);
    80003fa2:	854e                	mv	a0,s3
    80003fa4:	c04ff0ef          	jal	800033a8 <iput>
    end_op();
    80003fa8:	b9bff0ef          	jal	80003b42 <end_op>
    80003fac:	7902                	ld	s2,32(sp)
    80003fae:	69e2                	ld	s3,24(sp)
    80003fb0:	6a42                	ld	s4,16(sp)
    80003fb2:	6aa2                	ld	s5,8(sp)
    80003fb4:	b7f9                	j	80003f82 <fileclose+0x8a>

0000000080003fb6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003fb6:	715d                	addi	sp,sp,-80
    80003fb8:	e486                	sd	ra,72(sp)
    80003fba:	e0a2                	sd	s0,64(sp)
    80003fbc:	fc26                	sd	s1,56(sp)
    80003fbe:	f44e                	sd	s3,40(sp)
    80003fc0:	0880                	addi	s0,sp,80
    80003fc2:	84aa                	mv	s1,a0
    80003fc4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003fc6:	917fd0ef          	jal	800018dc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003fca:	409c                	lw	a5,0(s1)
    80003fcc:	37f9                	addiw	a5,a5,-2
    80003fce:	4705                	li	a4,1
    80003fd0:	04f76263          	bltu	a4,a5,80004014 <filestat+0x5e>
    80003fd4:	f84a                	sd	s2,48(sp)
    80003fd6:	f052                	sd	s4,32(sp)
    80003fd8:	892a                	mv	s2,a0
    ilock(f->ip);
    80003fda:	6c88                	ld	a0,24(s1)
    80003fdc:	a4aff0ef          	jal	80003226 <ilock>
    stati(f->ip, &st);
    80003fe0:	fb840a13          	addi	s4,s0,-72
    80003fe4:	85d2                	mv	a1,s4
    80003fe6:	6c88                	ld	a0,24(s1)
    80003fe8:	c68ff0ef          	jal	80003450 <stati>
    iunlock(f->ip);
    80003fec:	6c88                	ld	a0,24(s1)
    80003fee:	ae6ff0ef          	jal	800032d4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003ff2:	46e1                	li	a3,24
    80003ff4:	8652                	mv	a2,s4
    80003ff6:	85ce                	mv	a1,s3
    80003ff8:	05093503          	ld	a0,80(s2)
    80003ffc:	d88fd0ef          	jal	80001584 <copyout>
    80004000:	41f5551b          	sraiw	a0,a0,0x1f
    80004004:	7942                	ld	s2,48(sp)
    80004006:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004008:	60a6                	ld	ra,72(sp)
    8000400a:	6406                	ld	s0,64(sp)
    8000400c:	74e2                	ld	s1,56(sp)
    8000400e:	79a2                	ld	s3,40(sp)
    80004010:	6161                	addi	sp,sp,80
    80004012:	8082                	ret
  return -1;
    80004014:	557d                	li	a0,-1
    80004016:	bfcd                	j	80004008 <filestat+0x52>

0000000080004018 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004018:	7179                	addi	sp,sp,-48
    8000401a:	f406                	sd	ra,40(sp)
    8000401c:	f022                	sd	s0,32(sp)
    8000401e:	e84a                	sd	s2,16(sp)
    80004020:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004022:	00854783          	lbu	a5,8(a0)
    80004026:	cfd1                	beqz	a5,800040c2 <fileread+0xaa>
    80004028:	ec26                	sd	s1,24(sp)
    8000402a:	e44e                	sd	s3,8(sp)
    8000402c:	84aa                	mv	s1,a0
    8000402e:	89ae                	mv	s3,a1
    80004030:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004032:	411c                	lw	a5,0(a0)
    80004034:	4705                	li	a4,1
    80004036:	04e78363          	beq	a5,a4,8000407c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000403a:	470d                	li	a4,3
    8000403c:	04e78763          	beq	a5,a4,8000408a <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004040:	4709                	li	a4,2
    80004042:	06e79a63          	bne	a5,a4,800040b6 <fileread+0x9e>
    ilock(f->ip);
    80004046:	6d08                	ld	a0,24(a0)
    80004048:	9deff0ef          	jal	80003226 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000404c:	874a                	mv	a4,s2
    8000404e:	5094                	lw	a3,32(s1)
    80004050:	864e                	mv	a2,s3
    80004052:	4585                	li	a1,1
    80004054:	6c88                	ld	a0,24(s1)
    80004056:	c28ff0ef          	jal	8000347e <readi>
    8000405a:	892a                	mv	s2,a0
    8000405c:	00a05563          	blez	a0,80004066 <fileread+0x4e>
      f->off += r;
    80004060:	509c                	lw	a5,32(s1)
    80004062:	9fa9                	addw	a5,a5,a0
    80004064:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004066:	6c88                	ld	a0,24(s1)
    80004068:	a6cff0ef          	jal	800032d4 <iunlock>
    8000406c:	64e2                	ld	s1,24(sp)
    8000406e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004070:	854a                	mv	a0,s2
    80004072:	70a2                	ld	ra,40(sp)
    80004074:	7402                	ld	s0,32(sp)
    80004076:	6942                	ld	s2,16(sp)
    80004078:	6145                	addi	sp,sp,48
    8000407a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000407c:	6908                	ld	a0,16(a0)
    8000407e:	3a2000ef          	jal	80004420 <piperead>
    80004082:	892a                	mv	s2,a0
    80004084:	64e2                	ld	s1,24(sp)
    80004086:	69a2                	ld	s3,8(sp)
    80004088:	b7e5                	j	80004070 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000408a:	02451783          	lh	a5,36(a0)
    8000408e:	03079693          	slli	a3,a5,0x30
    80004092:	92c1                	srli	a3,a3,0x30
    80004094:	4725                	li	a4,9
    80004096:	02d76863          	bltu	a4,a3,800040c6 <fileread+0xae>
    8000409a:	0792                	slli	a5,a5,0x4
    8000409c:	00021717          	auipc	a4,0x21
    800040a0:	40c70713          	addi	a4,a4,1036 # 800254a8 <devsw>
    800040a4:	97ba                	add	a5,a5,a4
    800040a6:	639c                	ld	a5,0(a5)
    800040a8:	c39d                	beqz	a5,800040ce <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800040aa:	4505                	li	a0,1
    800040ac:	9782                	jalr	a5
    800040ae:	892a                	mv	s2,a0
    800040b0:	64e2                	ld	s1,24(sp)
    800040b2:	69a2                	ld	s3,8(sp)
    800040b4:	bf75                	j	80004070 <fileread+0x58>
    panic("fileread");
    800040b6:	00003517          	auipc	a0,0x3
    800040ba:	52250513          	addi	a0,a0,1314 # 800075d8 <etext+0x5d8>
    800040be:	ee0fc0ef          	jal	8000079e <panic>
    return -1;
    800040c2:	597d                	li	s2,-1
    800040c4:	b775                	j	80004070 <fileread+0x58>
      return -1;
    800040c6:	597d                	li	s2,-1
    800040c8:	64e2                	ld	s1,24(sp)
    800040ca:	69a2                	ld	s3,8(sp)
    800040cc:	b755                	j	80004070 <fileread+0x58>
    800040ce:	597d                	li	s2,-1
    800040d0:	64e2                	ld	s1,24(sp)
    800040d2:	69a2                	ld	s3,8(sp)
    800040d4:	bf71                	j	80004070 <fileread+0x58>

00000000800040d6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800040d6:	00954783          	lbu	a5,9(a0)
    800040da:	10078e63          	beqz	a5,800041f6 <filewrite+0x120>
{
    800040de:	711d                	addi	sp,sp,-96
    800040e0:	ec86                	sd	ra,88(sp)
    800040e2:	e8a2                	sd	s0,80(sp)
    800040e4:	e0ca                	sd	s2,64(sp)
    800040e6:	f456                	sd	s5,40(sp)
    800040e8:	f05a                	sd	s6,32(sp)
    800040ea:	1080                	addi	s0,sp,96
    800040ec:	892a                	mv	s2,a0
    800040ee:	8b2e                	mv	s6,a1
    800040f0:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800040f2:	411c                	lw	a5,0(a0)
    800040f4:	4705                	li	a4,1
    800040f6:	02e78963          	beq	a5,a4,80004128 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800040fa:	470d                	li	a4,3
    800040fc:	02e78a63          	beq	a5,a4,80004130 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004100:	4709                	li	a4,2
    80004102:	0ce79e63          	bne	a5,a4,800041de <filewrite+0x108>
    80004106:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004108:	0ac05963          	blez	a2,800041ba <filewrite+0xe4>
    8000410c:	e4a6                	sd	s1,72(sp)
    8000410e:	fc4e                	sd	s3,56(sp)
    80004110:	ec5e                	sd	s7,24(sp)
    80004112:	e862                	sd	s8,16(sp)
    80004114:	e466                	sd	s9,8(sp)
    int i = 0;
    80004116:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004118:	6b85                	lui	s7,0x1
    8000411a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000411e:	6c85                	lui	s9,0x1
    80004120:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004124:	4c05                	li	s8,1
    80004126:	a8ad                	j	800041a0 <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    80004128:	6908                	ld	a0,16(a0)
    8000412a:	1fe000ef          	jal	80004328 <pipewrite>
    8000412e:	a04d                	j	800041d0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004130:	02451783          	lh	a5,36(a0)
    80004134:	03079693          	slli	a3,a5,0x30
    80004138:	92c1                	srli	a3,a3,0x30
    8000413a:	4725                	li	a4,9
    8000413c:	0ad76f63          	bltu	a4,a3,800041fa <filewrite+0x124>
    80004140:	0792                	slli	a5,a5,0x4
    80004142:	00021717          	auipc	a4,0x21
    80004146:	36670713          	addi	a4,a4,870 # 800254a8 <devsw>
    8000414a:	97ba                	add	a5,a5,a4
    8000414c:	679c                	ld	a5,8(a5)
    8000414e:	cbc5                	beqz	a5,800041fe <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004150:	4505                	li	a0,1
    80004152:	9782                	jalr	a5
    80004154:	a8b5                	j	800041d0 <filewrite+0xfa>
      if(n1 > max)
    80004156:	2981                	sext.w	s3,s3
      begin_op();
    80004158:	981ff0ef          	jal	80003ad8 <begin_op>
      ilock(f->ip);
    8000415c:	01893503          	ld	a0,24(s2)
    80004160:	8c6ff0ef          	jal	80003226 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004164:	874e                	mv	a4,s3
    80004166:	02092683          	lw	a3,32(s2)
    8000416a:	016a0633          	add	a2,s4,s6
    8000416e:	85e2                	mv	a1,s8
    80004170:	01893503          	ld	a0,24(s2)
    80004174:	bfcff0ef          	jal	80003570 <writei>
    80004178:	84aa                	mv	s1,a0
    8000417a:	00a05763          	blez	a0,80004188 <filewrite+0xb2>
        f->off += r;
    8000417e:	02092783          	lw	a5,32(s2)
    80004182:	9fa9                	addw	a5,a5,a0
    80004184:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004188:	01893503          	ld	a0,24(s2)
    8000418c:	948ff0ef          	jal	800032d4 <iunlock>
      end_op();
    80004190:	9b3ff0ef          	jal	80003b42 <end_op>

      if(r != n1){
    80004194:	02999563          	bne	s3,s1,800041be <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    80004198:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000419c:	015a5963          	bge	s4,s5,800041ae <filewrite+0xd8>
      int n1 = n - i;
    800041a0:	414a87bb          	subw	a5,s5,s4
    800041a4:	89be                	mv	s3,a5
      if(n1 > max)
    800041a6:	fafbd8e3          	bge	s7,a5,80004156 <filewrite+0x80>
    800041aa:	89e6                	mv	s3,s9
    800041ac:	b76d                	j	80004156 <filewrite+0x80>
    800041ae:	64a6                	ld	s1,72(sp)
    800041b0:	79e2                	ld	s3,56(sp)
    800041b2:	6be2                	ld	s7,24(sp)
    800041b4:	6c42                	ld	s8,16(sp)
    800041b6:	6ca2                	ld	s9,8(sp)
    800041b8:	a801                	j	800041c8 <filewrite+0xf2>
    int i = 0;
    800041ba:	4a01                	li	s4,0
    800041bc:	a031                	j	800041c8 <filewrite+0xf2>
    800041be:	64a6                	ld	s1,72(sp)
    800041c0:	79e2                	ld	s3,56(sp)
    800041c2:	6be2                	ld	s7,24(sp)
    800041c4:	6c42                	ld	s8,16(sp)
    800041c6:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800041c8:	034a9d63          	bne	s5,s4,80004202 <filewrite+0x12c>
    800041cc:	8556                	mv	a0,s5
    800041ce:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800041d0:	60e6                	ld	ra,88(sp)
    800041d2:	6446                	ld	s0,80(sp)
    800041d4:	6906                	ld	s2,64(sp)
    800041d6:	7aa2                	ld	s5,40(sp)
    800041d8:	7b02                	ld	s6,32(sp)
    800041da:	6125                	addi	sp,sp,96
    800041dc:	8082                	ret
    800041de:	e4a6                	sd	s1,72(sp)
    800041e0:	fc4e                	sd	s3,56(sp)
    800041e2:	f852                	sd	s4,48(sp)
    800041e4:	ec5e                	sd	s7,24(sp)
    800041e6:	e862                	sd	s8,16(sp)
    800041e8:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800041ea:	00003517          	auipc	a0,0x3
    800041ee:	3fe50513          	addi	a0,a0,1022 # 800075e8 <etext+0x5e8>
    800041f2:	dacfc0ef          	jal	8000079e <panic>
    return -1;
    800041f6:	557d                	li	a0,-1
}
    800041f8:	8082                	ret
      return -1;
    800041fa:	557d                	li	a0,-1
    800041fc:	bfd1                	j	800041d0 <filewrite+0xfa>
    800041fe:	557d                	li	a0,-1
    80004200:	bfc1                	j	800041d0 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004202:	557d                	li	a0,-1
    80004204:	7a42                	ld	s4,48(sp)
    80004206:	b7e9                	j	800041d0 <filewrite+0xfa>

0000000080004208 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004208:	7179                	addi	sp,sp,-48
    8000420a:	f406                	sd	ra,40(sp)
    8000420c:	f022                	sd	s0,32(sp)
    8000420e:	ec26                	sd	s1,24(sp)
    80004210:	e052                	sd	s4,0(sp)
    80004212:	1800                	addi	s0,sp,48
    80004214:	84aa                	mv	s1,a0
    80004216:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004218:	0005b023          	sd	zero,0(a1)
    8000421c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004220:	c35ff0ef          	jal	80003e54 <filealloc>
    80004224:	e088                	sd	a0,0(s1)
    80004226:	c549                	beqz	a0,800042b0 <pipealloc+0xa8>
    80004228:	c2dff0ef          	jal	80003e54 <filealloc>
    8000422c:	00aa3023          	sd	a0,0(s4)
    80004230:	cd25                	beqz	a0,800042a8 <pipealloc+0xa0>
    80004232:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004234:	8f7fc0ef          	jal	80000b2a <kalloc>
    80004238:	892a                	mv	s2,a0
    8000423a:	c12d                	beqz	a0,8000429c <pipealloc+0x94>
    8000423c:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000423e:	4985                	li	s3,1
    80004240:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004244:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004248:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000424c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004250:	00003597          	auipc	a1,0x3
    80004254:	3a858593          	addi	a1,a1,936 # 800075f8 <etext+0x5f8>
    80004258:	923fc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    8000425c:	609c                	ld	a5,0(s1)
    8000425e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004262:	609c                	ld	a5,0(s1)
    80004264:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004268:	609c                	ld	a5,0(s1)
    8000426a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000426e:	609c                	ld	a5,0(s1)
    80004270:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004274:	000a3783          	ld	a5,0(s4)
    80004278:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000427c:	000a3783          	ld	a5,0(s4)
    80004280:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004284:	000a3783          	ld	a5,0(s4)
    80004288:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000428c:	000a3783          	ld	a5,0(s4)
    80004290:	0127b823          	sd	s2,16(a5)
  return 0;
    80004294:	4501                	li	a0,0
    80004296:	6942                	ld	s2,16(sp)
    80004298:	69a2                	ld	s3,8(sp)
    8000429a:	a01d                	j	800042c0 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000429c:	6088                	ld	a0,0(s1)
    8000429e:	c119                	beqz	a0,800042a4 <pipealloc+0x9c>
    800042a0:	6942                	ld	s2,16(sp)
    800042a2:	a029                	j	800042ac <pipealloc+0xa4>
    800042a4:	6942                	ld	s2,16(sp)
    800042a6:	a029                	j	800042b0 <pipealloc+0xa8>
    800042a8:	6088                	ld	a0,0(s1)
    800042aa:	c10d                	beqz	a0,800042cc <pipealloc+0xc4>
    fileclose(*f0);
    800042ac:	c4dff0ef          	jal	80003ef8 <fileclose>
  if(*f1)
    800042b0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800042b4:	557d                	li	a0,-1
  if(*f1)
    800042b6:	c789                	beqz	a5,800042c0 <pipealloc+0xb8>
    fileclose(*f1);
    800042b8:	853e                	mv	a0,a5
    800042ba:	c3fff0ef          	jal	80003ef8 <fileclose>
  return -1;
    800042be:	557d                	li	a0,-1
}
    800042c0:	70a2                	ld	ra,40(sp)
    800042c2:	7402                	ld	s0,32(sp)
    800042c4:	64e2                	ld	s1,24(sp)
    800042c6:	6a02                	ld	s4,0(sp)
    800042c8:	6145                	addi	sp,sp,48
    800042ca:	8082                	ret
  return -1;
    800042cc:	557d                	li	a0,-1
    800042ce:	bfcd                	j	800042c0 <pipealloc+0xb8>

00000000800042d0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800042d0:	1101                	addi	sp,sp,-32
    800042d2:	ec06                	sd	ra,24(sp)
    800042d4:	e822                	sd	s0,16(sp)
    800042d6:	e426                	sd	s1,8(sp)
    800042d8:	e04a                	sd	s2,0(sp)
    800042da:	1000                	addi	s0,sp,32
    800042dc:	84aa                	mv	s1,a0
    800042de:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800042e0:	91ffc0ef          	jal	80000bfe <acquire>
  if(writable){
    800042e4:	02090763          	beqz	s2,80004312 <pipeclose+0x42>
    pi->writeopen = 0;
    800042e8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800042ec:	21848513          	addi	a0,s1,536
    800042f0:	c31fd0ef          	jal	80001f20 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800042f4:	2204b783          	ld	a5,544(s1)
    800042f8:	e785                	bnez	a5,80004320 <pipeclose+0x50>
    release(&pi->lock);
    800042fa:	8526                	mv	a0,s1
    800042fc:	997fc0ef          	jal	80000c92 <release>
    kfree((char*)pi);
    80004300:	8526                	mv	a0,s1
    80004302:	f46fc0ef          	jal	80000a48 <kfree>
  } else
    release(&pi->lock);
}
    80004306:	60e2                	ld	ra,24(sp)
    80004308:	6442                	ld	s0,16(sp)
    8000430a:	64a2                	ld	s1,8(sp)
    8000430c:	6902                	ld	s2,0(sp)
    8000430e:	6105                	addi	sp,sp,32
    80004310:	8082                	ret
    pi->readopen = 0;
    80004312:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004316:	21c48513          	addi	a0,s1,540
    8000431a:	c07fd0ef          	jal	80001f20 <wakeup>
    8000431e:	bfd9                	j	800042f4 <pipeclose+0x24>
    release(&pi->lock);
    80004320:	8526                	mv	a0,s1
    80004322:	971fc0ef          	jal	80000c92 <release>
}
    80004326:	b7c5                	j	80004306 <pipeclose+0x36>

0000000080004328 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004328:	7159                	addi	sp,sp,-112
    8000432a:	f486                	sd	ra,104(sp)
    8000432c:	f0a2                	sd	s0,96(sp)
    8000432e:	eca6                	sd	s1,88(sp)
    80004330:	e8ca                	sd	s2,80(sp)
    80004332:	e4ce                	sd	s3,72(sp)
    80004334:	e0d2                	sd	s4,64(sp)
    80004336:	fc56                	sd	s5,56(sp)
    80004338:	1880                	addi	s0,sp,112
    8000433a:	84aa                	mv	s1,a0
    8000433c:	8aae                	mv	s5,a1
    8000433e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004340:	d9cfd0ef          	jal	800018dc <myproc>
    80004344:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004346:	8526                	mv	a0,s1
    80004348:	8b7fc0ef          	jal	80000bfe <acquire>
  while(i < n){
    8000434c:	0d405263          	blez	s4,80004410 <pipewrite+0xe8>
    80004350:	f85a                	sd	s6,48(sp)
    80004352:	f45e                	sd	s7,40(sp)
    80004354:	f062                	sd	s8,32(sp)
    80004356:	ec66                	sd	s9,24(sp)
    80004358:	e86a                	sd	s10,16(sp)
  int i = 0;
    8000435a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000435c:	f9f40c13          	addi	s8,s0,-97
    80004360:	4b85                	li	s7,1
    80004362:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004364:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004368:	21c48c93          	addi	s9,s1,540
    8000436c:	a82d                	j	800043a6 <pipewrite+0x7e>
      release(&pi->lock);
    8000436e:	8526                	mv	a0,s1
    80004370:	923fc0ef          	jal	80000c92 <release>
      return -1;
    80004374:	597d                	li	s2,-1
    80004376:	7b42                	ld	s6,48(sp)
    80004378:	7ba2                	ld	s7,40(sp)
    8000437a:	7c02                	ld	s8,32(sp)
    8000437c:	6ce2                	ld	s9,24(sp)
    8000437e:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004380:	854a                	mv	a0,s2
    80004382:	70a6                	ld	ra,104(sp)
    80004384:	7406                	ld	s0,96(sp)
    80004386:	64e6                	ld	s1,88(sp)
    80004388:	6946                	ld	s2,80(sp)
    8000438a:	69a6                	ld	s3,72(sp)
    8000438c:	6a06                	ld	s4,64(sp)
    8000438e:	7ae2                	ld	s5,56(sp)
    80004390:	6165                	addi	sp,sp,112
    80004392:	8082                	ret
      wakeup(&pi->nread);
    80004394:	856a                	mv	a0,s10
    80004396:	b8bfd0ef          	jal	80001f20 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000439a:	85a6                	mv	a1,s1
    8000439c:	8566                	mv	a0,s9
    8000439e:	b37fd0ef          	jal	80001ed4 <sleep>
  while(i < n){
    800043a2:	05495a63          	bge	s2,s4,800043f6 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800043a6:	2204a783          	lw	a5,544(s1)
    800043aa:	d3f1                	beqz	a5,8000436e <pipewrite+0x46>
    800043ac:	854e                	mv	a0,s3
    800043ae:	d5ffd0ef          	jal	8000210c <killed>
    800043b2:	fd55                	bnez	a0,8000436e <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800043b4:	2184a783          	lw	a5,536(s1)
    800043b8:	21c4a703          	lw	a4,540(s1)
    800043bc:	2007879b          	addiw	a5,a5,512
    800043c0:	fcf70ae3          	beq	a4,a5,80004394 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043c4:	86de                	mv	a3,s7
    800043c6:	01590633          	add	a2,s2,s5
    800043ca:	85e2                	mv	a1,s8
    800043cc:	0509b503          	ld	a0,80(s3)
    800043d0:	a64fd0ef          	jal	80001634 <copyin>
    800043d4:	05650063          	beq	a0,s6,80004414 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800043d8:	21c4a783          	lw	a5,540(s1)
    800043dc:	0017871b          	addiw	a4,a5,1
    800043e0:	20e4ae23          	sw	a4,540(s1)
    800043e4:	1ff7f793          	andi	a5,a5,511
    800043e8:	97a6                	add	a5,a5,s1
    800043ea:	f9f44703          	lbu	a4,-97(s0)
    800043ee:	00e78c23          	sb	a4,24(a5)
      i++;
    800043f2:	2905                	addiw	s2,s2,1
    800043f4:	b77d                	j	800043a2 <pipewrite+0x7a>
    800043f6:	7b42                	ld	s6,48(sp)
    800043f8:	7ba2                	ld	s7,40(sp)
    800043fa:	7c02                	ld	s8,32(sp)
    800043fc:	6ce2                	ld	s9,24(sp)
    800043fe:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004400:	21848513          	addi	a0,s1,536
    80004404:	b1dfd0ef          	jal	80001f20 <wakeup>
  release(&pi->lock);
    80004408:	8526                	mv	a0,s1
    8000440a:	889fc0ef          	jal	80000c92 <release>
  return i;
    8000440e:	bf8d                	j	80004380 <pipewrite+0x58>
  int i = 0;
    80004410:	4901                	li	s2,0
    80004412:	b7fd                	j	80004400 <pipewrite+0xd8>
    80004414:	7b42                	ld	s6,48(sp)
    80004416:	7ba2                	ld	s7,40(sp)
    80004418:	7c02                	ld	s8,32(sp)
    8000441a:	6ce2                	ld	s9,24(sp)
    8000441c:	6d42                	ld	s10,16(sp)
    8000441e:	b7cd                	j	80004400 <pipewrite+0xd8>

0000000080004420 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004420:	711d                	addi	sp,sp,-96
    80004422:	ec86                	sd	ra,88(sp)
    80004424:	e8a2                	sd	s0,80(sp)
    80004426:	e4a6                	sd	s1,72(sp)
    80004428:	e0ca                	sd	s2,64(sp)
    8000442a:	fc4e                	sd	s3,56(sp)
    8000442c:	f852                	sd	s4,48(sp)
    8000442e:	f456                	sd	s5,40(sp)
    80004430:	1080                	addi	s0,sp,96
    80004432:	84aa                	mv	s1,a0
    80004434:	892e                	mv	s2,a1
    80004436:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004438:	ca4fd0ef          	jal	800018dc <myproc>
    8000443c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000443e:	8526                	mv	a0,s1
    80004440:	fbefc0ef          	jal	80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004444:	2184a703          	lw	a4,536(s1)
    80004448:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000444c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004450:	02f71763          	bne	a4,a5,8000447e <piperead+0x5e>
    80004454:	2244a783          	lw	a5,548(s1)
    80004458:	cf85                	beqz	a5,80004490 <piperead+0x70>
    if(killed(pr)){
    8000445a:	8552                	mv	a0,s4
    8000445c:	cb1fd0ef          	jal	8000210c <killed>
    80004460:	e11d                	bnez	a0,80004486 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004462:	85a6                	mv	a1,s1
    80004464:	854e                	mv	a0,s3
    80004466:	a6ffd0ef          	jal	80001ed4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000446a:	2184a703          	lw	a4,536(s1)
    8000446e:	21c4a783          	lw	a5,540(s1)
    80004472:	fef701e3          	beq	a4,a5,80004454 <piperead+0x34>
    80004476:	f05a                	sd	s6,32(sp)
    80004478:	ec5e                	sd	s7,24(sp)
    8000447a:	e862                	sd	s8,16(sp)
    8000447c:	a829                	j	80004496 <piperead+0x76>
    8000447e:	f05a                	sd	s6,32(sp)
    80004480:	ec5e                	sd	s7,24(sp)
    80004482:	e862                	sd	s8,16(sp)
    80004484:	a809                	j	80004496 <piperead+0x76>
      release(&pi->lock);
    80004486:	8526                	mv	a0,s1
    80004488:	80bfc0ef          	jal	80000c92 <release>
      return -1;
    8000448c:	59fd                	li	s3,-1
    8000448e:	a0a5                	j	800044f6 <piperead+0xd6>
    80004490:	f05a                	sd	s6,32(sp)
    80004492:	ec5e                	sd	s7,24(sp)
    80004494:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004496:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004498:	faf40c13          	addi	s8,s0,-81
    8000449c:	4b85                	li	s7,1
    8000449e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044a0:	05505163          	blez	s5,800044e2 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    800044a4:	2184a783          	lw	a5,536(s1)
    800044a8:	21c4a703          	lw	a4,540(s1)
    800044ac:	02f70b63          	beq	a4,a5,800044e2 <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800044b0:	0017871b          	addiw	a4,a5,1
    800044b4:	20e4ac23          	sw	a4,536(s1)
    800044b8:	1ff7f793          	andi	a5,a5,511
    800044bc:	97a6                	add	a5,a5,s1
    800044be:	0187c783          	lbu	a5,24(a5)
    800044c2:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800044c6:	86de                	mv	a3,s7
    800044c8:	8662                	mv	a2,s8
    800044ca:	85ca                	mv	a1,s2
    800044cc:	050a3503          	ld	a0,80(s4)
    800044d0:	8b4fd0ef          	jal	80001584 <copyout>
    800044d4:	01650763          	beq	a0,s6,800044e2 <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044d8:	2985                	addiw	s3,s3,1
    800044da:	0905                	addi	s2,s2,1
    800044dc:	fd3a94e3          	bne	s5,s3,800044a4 <piperead+0x84>
    800044e0:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800044e2:	21c48513          	addi	a0,s1,540
    800044e6:	a3bfd0ef          	jal	80001f20 <wakeup>
  release(&pi->lock);
    800044ea:	8526                	mv	a0,s1
    800044ec:	fa6fc0ef          	jal	80000c92 <release>
    800044f0:	7b02                	ld	s6,32(sp)
    800044f2:	6be2                	ld	s7,24(sp)
    800044f4:	6c42                	ld	s8,16(sp)
  return i;
}
    800044f6:	854e                	mv	a0,s3
    800044f8:	60e6                	ld	ra,88(sp)
    800044fa:	6446                	ld	s0,80(sp)
    800044fc:	64a6                	ld	s1,72(sp)
    800044fe:	6906                	ld	s2,64(sp)
    80004500:	79e2                	ld	s3,56(sp)
    80004502:	7a42                	ld	s4,48(sp)
    80004504:	7aa2                	ld	s5,40(sp)
    80004506:	6125                	addi	sp,sp,96
    80004508:	8082                	ret

000000008000450a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000450a:	1141                	addi	sp,sp,-16
    8000450c:	e406                	sd	ra,8(sp)
    8000450e:	e022                	sd	s0,0(sp)
    80004510:	0800                	addi	s0,sp,16
    80004512:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004514:	0035151b          	slliw	a0,a0,0x3
    80004518:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    8000451a:	8b89                	andi	a5,a5,2
    8000451c:	c399                	beqz	a5,80004522 <flags2perm+0x18>
      perm |= PTE_W;
    8000451e:	00456513          	ori	a0,a0,4
    return perm;
}
    80004522:	60a2                	ld	ra,8(sp)
    80004524:	6402                	ld	s0,0(sp)
    80004526:	0141                	addi	sp,sp,16
    80004528:	8082                	ret

000000008000452a <exec>:

int
exec(char *path, char **argv)
{
    8000452a:	de010113          	addi	sp,sp,-544
    8000452e:	20113c23          	sd	ra,536(sp)
    80004532:	20813823          	sd	s0,528(sp)
    80004536:	20913423          	sd	s1,520(sp)
    8000453a:	21213023          	sd	s2,512(sp)
    8000453e:	1400                	addi	s0,sp,544
    80004540:	892a                	mv	s2,a0
    80004542:	dea43823          	sd	a0,-528(s0)
    80004546:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000454a:	b92fd0ef          	jal	800018dc <myproc>
    8000454e:	84aa                	mv	s1,a0

  begin_op();
    80004550:	d88ff0ef          	jal	80003ad8 <begin_op>

  if((ip = namei(path)) == 0){
    80004554:	854a                	mv	a0,s2
    80004556:	bc0ff0ef          	jal	80003916 <namei>
    8000455a:	cd21                	beqz	a0,800045b2 <exec+0x88>
    8000455c:	fbd2                	sd	s4,496(sp)
    8000455e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004560:	cc7fe0ef          	jal	80003226 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004564:	04000713          	li	a4,64
    80004568:	4681                	li	a3,0
    8000456a:	e5040613          	addi	a2,s0,-432
    8000456e:	4581                	li	a1,0
    80004570:	8552                	mv	a0,s4
    80004572:	f0dfe0ef          	jal	8000347e <readi>
    80004576:	04000793          	li	a5,64
    8000457a:	00f51a63          	bne	a0,a5,8000458e <exec+0x64>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000457e:	e5042703          	lw	a4,-432(s0)
    80004582:	464c47b7          	lui	a5,0x464c4
    80004586:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000458a:	02f70863          	beq	a4,a5,800045ba <exec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000458e:	8552                	mv	a0,s4
    80004590:	ea1fe0ef          	jal	80003430 <iunlockput>
    end_op();
    80004594:	daeff0ef          	jal	80003b42 <end_op>
  }
  return -1;
    80004598:	557d                	li	a0,-1
    8000459a:	7a5e                	ld	s4,496(sp)
}
    8000459c:	21813083          	ld	ra,536(sp)
    800045a0:	21013403          	ld	s0,528(sp)
    800045a4:	20813483          	ld	s1,520(sp)
    800045a8:	20013903          	ld	s2,512(sp)
    800045ac:	22010113          	addi	sp,sp,544
    800045b0:	8082                	ret
    end_op();
    800045b2:	d90ff0ef          	jal	80003b42 <end_op>
    return -1;
    800045b6:	557d                	li	a0,-1
    800045b8:	b7d5                	j	8000459c <exec+0x72>
    800045ba:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800045bc:	8526                	mv	a0,s1
    800045be:	bc6fd0ef          	jal	80001984 <proc_pagetable>
    800045c2:	8b2a                	mv	s6,a0
    800045c4:	26050d63          	beqz	a0,8000483e <exec+0x314>
    800045c8:	ffce                	sd	s3,504(sp)
    800045ca:	f7d6                	sd	s5,488(sp)
    800045cc:	efde                	sd	s7,472(sp)
    800045ce:	ebe2                	sd	s8,464(sp)
    800045d0:	e7e6                	sd	s9,456(sp)
    800045d2:	e3ea                	sd	s10,448(sp)
    800045d4:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045d6:	e7042683          	lw	a3,-400(s0)
    800045da:	e8845783          	lhu	a5,-376(s0)
    800045de:	0e078763          	beqz	a5,800046cc <exec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800045e2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045e4:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800045e6:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800045ea:	6c85                	lui	s9,0x1
    800045ec:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800045f0:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800045f4:	6a85                	lui	s5,0x1
    800045f6:	a085                	j	80004656 <exec+0x12c>
      panic("loadseg: address should exist");
    800045f8:	00003517          	auipc	a0,0x3
    800045fc:	00850513          	addi	a0,a0,8 # 80007600 <etext+0x600>
    80004600:	99efc0ef          	jal	8000079e <panic>
    if(sz - i < PGSIZE)
    80004604:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004606:	874a                	mv	a4,s2
    80004608:	009c06bb          	addw	a3,s8,s1
    8000460c:	4581                	li	a1,0
    8000460e:	8552                	mv	a0,s4
    80004610:	e6ffe0ef          	jal	8000347e <readi>
    80004614:	22a91963          	bne	s2,a0,80004846 <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    80004618:	009a84bb          	addw	s1,s5,s1
    8000461c:	0334f263          	bgeu	s1,s3,80004640 <exec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004620:	02049593          	slli	a1,s1,0x20
    80004624:	9181                	srli	a1,a1,0x20
    80004626:	95de                	add	a1,a1,s7
    80004628:	855a                	mv	a0,s6
    8000462a:	9d3fc0ef          	jal	80000ffc <walkaddr>
    8000462e:	862a                	mv	a2,a0
    if(pa == 0)
    80004630:	d561                	beqz	a0,800045f8 <exec+0xce>
    if(sz - i < PGSIZE)
    80004632:	409987bb          	subw	a5,s3,s1
    80004636:	893e                	mv	s2,a5
    80004638:	fcfcf6e3          	bgeu	s9,a5,80004604 <exec+0xda>
    8000463c:	8956                	mv	s2,s5
    8000463e:	b7d9                	j	80004604 <exec+0xda>
    sz = sz1;
    80004640:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004644:	2d05                	addiw	s10,s10,1
    80004646:	e0843783          	ld	a5,-504(s0)
    8000464a:	0387869b          	addiw	a3,a5,56
    8000464e:	e8845783          	lhu	a5,-376(s0)
    80004652:	06fd5e63          	bge	s10,a5,800046ce <exec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004656:	e0d43423          	sd	a3,-504(s0)
    8000465a:	876e                	mv	a4,s11
    8000465c:	e1840613          	addi	a2,s0,-488
    80004660:	4581                	li	a1,0
    80004662:	8552                	mv	a0,s4
    80004664:	e1bfe0ef          	jal	8000347e <readi>
    80004668:	1db51d63          	bne	a0,s11,80004842 <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    8000466c:	e1842783          	lw	a5,-488(s0)
    80004670:	4705                	li	a4,1
    80004672:	fce799e3          	bne	a5,a4,80004644 <exec+0x11a>
    if(ph.memsz < ph.filesz)
    80004676:	e4043483          	ld	s1,-448(s0)
    8000467a:	e3843783          	ld	a5,-456(s0)
    8000467e:	1ef4e263          	bltu	s1,a5,80004862 <exec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004682:	e2843783          	ld	a5,-472(s0)
    80004686:	94be                	add	s1,s1,a5
    80004688:	1ef4e063          	bltu	s1,a5,80004868 <exec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    8000468c:	de843703          	ld	a4,-536(s0)
    80004690:	8ff9                	and	a5,a5,a4
    80004692:	1c079e63          	bnez	a5,8000486e <exec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004696:	e1c42503          	lw	a0,-484(s0)
    8000469a:	e71ff0ef          	jal	8000450a <flags2perm>
    8000469e:	86aa                	mv	a3,a0
    800046a0:	8626                	mv	a2,s1
    800046a2:	85ca                	mv	a1,s2
    800046a4:	855a                	mv	a0,s6
    800046a6:	cbffc0ef          	jal	80001364 <uvmalloc>
    800046aa:	dea43c23          	sd	a0,-520(s0)
    800046ae:	1c050363          	beqz	a0,80004874 <exec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800046b2:	e2843b83          	ld	s7,-472(s0)
    800046b6:	e2042c03          	lw	s8,-480(s0)
    800046ba:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800046be:	00098463          	beqz	s3,800046c6 <exec+0x19c>
    800046c2:	4481                	li	s1,0
    800046c4:	bfb1                	j	80004620 <exec+0xf6>
    sz = sz1;
    800046c6:	df843903          	ld	s2,-520(s0)
    800046ca:	bfad                	j	80004644 <exec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046cc:	4901                	li	s2,0
  iunlockput(ip);
    800046ce:	8552                	mv	a0,s4
    800046d0:	d61fe0ef          	jal	80003430 <iunlockput>
  end_op();
    800046d4:	c6eff0ef          	jal	80003b42 <end_op>
  p = myproc();
    800046d8:	a04fd0ef          	jal	800018dc <myproc>
    800046dc:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800046de:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800046e2:	6985                	lui	s3,0x1
    800046e4:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800046e6:	99ca                	add	s3,s3,s2
    800046e8:	77fd                	lui	a5,0xfffff
    800046ea:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800046ee:	4691                	li	a3,4
    800046f0:	6609                	lui	a2,0x2
    800046f2:	964e                	add	a2,a2,s3
    800046f4:	85ce                	mv	a1,s3
    800046f6:	855a                	mv	a0,s6
    800046f8:	c6dfc0ef          	jal	80001364 <uvmalloc>
    800046fc:	8a2a                	mv	s4,a0
    800046fe:	e105                	bnez	a0,8000471e <exec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004700:	85ce                	mv	a1,s3
    80004702:	855a                	mv	a0,s6
    80004704:	b04fd0ef          	jal	80001a08 <proc_freepagetable>
  return -1;
    80004708:	557d                	li	a0,-1
    8000470a:	79fe                	ld	s3,504(sp)
    8000470c:	7a5e                	ld	s4,496(sp)
    8000470e:	7abe                	ld	s5,488(sp)
    80004710:	7b1e                	ld	s6,480(sp)
    80004712:	6bfe                	ld	s7,472(sp)
    80004714:	6c5e                	ld	s8,464(sp)
    80004716:	6cbe                	ld	s9,456(sp)
    80004718:	6d1e                	ld	s10,448(sp)
    8000471a:	7dfa                	ld	s11,440(sp)
    8000471c:	b541                	j	8000459c <exec+0x72>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000471e:	75f9                	lui	a1,0xffffe
    80004720:	95aa                	add	a1,a1,a0
    80004722:	855a                	mv	a0,s6
    80004724:	e37fc0ef          	jal	8000155a <uvmclear>
  stackbase = sp - PGSIZE;
    80004728:	7bfd                	lui	s7,0xfffff
    8000472a:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    8000472c:	e0043783          	ld	a5,-512(s0)
    80004730:	6388                	ld	a0,0(a5)
  sp = sz;
    80004732:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004734:	4481                	li	s1,0
    ustack[argc] = sp;
    80004736:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    8000473a:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000473e:	cd21                	beqz	a0,80004796 <exec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    80004740:	f16fc0ef          	jal	80000e56 <strlen>
    80004744:	0015079b          	addiw	a5,a0,1
    80004748:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000474c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004750:	13796563          	bltu	s2,s7,8000487a <exec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004754:	e0043d83          	ld	s11,-512(s0)
    80004758:	000db983          	ld	s3,0(s11)
    8000475c:	854e                	mv	a0,s3
    8000475e:	ef8fc0ef          	jal	80000e56 <strlen>
    80004762:	0015069b          	addiw	a3,a0,1
    80004766:	864e                	mv	a2,s3
    80004768:	85ca                	mv	a1,s2
    8000476a:	855a                	mv	a0,s6
    8000476c:	e19fc0ef          	jal	80001584 <copyout>
    80004770:	10054763          	bltz	a0,8000487e <exec+0x354>
    ustack[argc] = sp;
    80004774:	00349793          	slli	a5,s1,0x3
    80004778:	97e6                	add	a5,a5,s9
    8000477a:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd89c0>
  for(argc = 0; argv[argc]; argc++) {
    8000477e:	0485                	addi	s1,s1,1
    80004780:	008d8793          	addi	a5,s11,8
    80004784:	e0f43023          	sd	a5,-512(s0)
    80004788:	008db503          	ld	a0,8(s11)
    8000478c:	c509                	beqz	a0,80004796 <exec+0x26c>
    if(argc >= MAXARG)
    8000478e:	fb8499e3          	bne	s1,s8,80004740 <exec+0x216>
  sz = sz1;
    80004792:	89d2                	mv	s3,s4
    80004794:	b7b5                	j	80004700 <exec+0x1d6>
  ustack[argc] = 0;
    80004796:	00349793          	slli	a5,s1,0x3
    8000479a:	f9078793          	addi	a5,a5,-112
    8000479e:	97a2                	add	a5,a5,s0
    800047a0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800047a4:	00148693          	addi	a3,s1,1
    800047a8:	068e                	slli	a3,a3,0x3
    800047aa:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800047ae:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800047b2:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800047b4:	f57966e3          	bltu	s2,s7,80004700 <exec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800047b8:	e9040613          	addi	a2,s0,-368
    800047bc:	85ca                	mv	a1,s2
    800047be:	855a                	mv	a0,s6
    800047c0:	dc5fc0ef          	jal	80001584 <copyout>
    800047c4:	f2054ee3          	bltz	a0,80004700 <exec+0x1d6>
  p->trapframe->a1 = sp;
    800047c8:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800047cc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800047d0:	df043783          	ld	a5,-528(s0)
    800047d4:	0007c703          	lbu	a4,0(a5)
    800047d8:	cf11                	beqz	a4,800047f4 <exec+0x2ca>
    800047da:	0785                	addi	a5,a5,1
    if(*s == '/')
    800047dc:	02f00693          	li	a3,47
    800047e0:	a029                	j	800047ea <exec+0x2c0>
  for(last=s=path; *s; s++)
    800047e2:	0785                	addi	a5,a5,1
    800047e4:	fff7c703          	lbu	a4,-1(a5)
    800047e8:	c711                	beqz	a4,800047f4 <exec+0x2ca>
    if(*s == '/')
    800047ea:	fed71ce3          	bne	a4,a3,800047e2 <exec+0x2b8>
      last = s+1;
    800047ee:	def43823          	sd	a5,-528(s0)
    800047f2:	bfc5                	j	800047e2 <exec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    800047f4:	4641                	li	a2,16
    800047f6:	df043583          	ld	a1,-528(s0)
    800047fa:	158a8513          	addi	a0,s5,344
    800047fe:	e22fc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    80004802:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004806:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000480a:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000480e:	058ab783          	ld	a5,88(s5)
    80004812:	e6843703          	ld	a4,-408(s0)
    80004816:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004818:	058ab783          	ld	a5,88(s5)
    8000481c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004820:	85ea                	mv	a1,s10
    80004822:	9e6fd0ef          	jal	80001a08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004826:	0004851b          	sext.w	a0,s1
    8000482a:	79fe                	ld	s3,504(sp)
    8000482c:	7a5e                	ld	s4,496(sp)
    8000482e:	7abe                	ld	s5,488(sp)
    80004830:	7b1e                	ld	s6,480(sp)
    80004832:	6bfe                	ld	s7,472(sp)
    80004834:	6c5e                	ld	s8,464(sp)
    80004836:	6cbe                	ld	s9,456(sp)
    80004838:	6d1e                	ld	s10,448(sp)
    8000483a:	7dfa                	ld	s11,440(sp)
    8000483c:	b385                	j	8000459c <exec+0x72>
    8000483e:	7b1e                	ld	s6,480(sp)
    80004840:	b3b9                	j	8000458e <exec+0x64>
    80004842:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004846:	df843583          	ld	a1,-520(s0)
    8000484a:	855a                	mv	a0,s6
    8000484c:	9bcfd0ef          	jal	80001a08 <proc_freepagetable>
  if(ip){
    80004850:	79fe                	ld	s3,504(sp)
    80004852:	7abe                	ld	s5,488(sp)
    80004854:	7b1e                	ld	s6,480(sp)
    80004856:	6bfe                	ld	s7,472(sp)
    80004858:	6c5e                	ld	s8,464(sp)
    8000485a:	6cbe                	ld	s9,456(sp)
    8000485c:	6d1e                	ld	s10,448(sp)
    8000485e:	7dfa                	ld	s11,440(sp)
    80004860:	b33d                	j	8000458e <exec+0x64>
    80004862:	df243c23          	sd	s2,-520(s0)
    80004866:	b7c5                	j	80004846 <exec+0x31c>
    80004868:	df243c23          	sd	s2,-520(s0)
    8000486c:	bfe9                	j	80004846 <exec+0x31c>
    8000486e:	df243c23          	sd	s2,-520(s0)
    80004872:	bfd1                	j	80004846 <exec+0x31c>
    80004874:	df243c23          	sd	s2,-520(s0)
    80004878:	b7f9                	j	80004846 <exec+0x31c>
  sz = sz1;
    8000487a:	89d2                	mv	s3,s4
    8000487c:	b551                	j	80004700 <exec+0x1d6>
    8000487e:	89d2                	mv	s3,s4
    80004880:	b541                	j	80004700 <exec+0x1d6>

0000000080004882 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004882:	7179                	addi	sp,sp,-48
    80004884:	f406                	sd	ra,40(sp)
    80004886:	f022                	sd	s0,32(sp)
    80004888:	ec26                	sd	s1,24(sp)
    8000488a:	e84a                	sd	s2,16(sp)
    8000488c:	1800                	addi	s0,sp,48
    8000488e:	892e                	mv	s2,a1
    80004890:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004892:	fdc40593          	addi	a1,s0,-36
    80004896:	f23fd0ef          	jal	800027b8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000489a:	fdc42703          	lw	a4,-36(s0)
    8000489e:	47bd                	li	a5,15
    800048a0:	02e7e963          	bltu	a5,a4,800048d2 <argfd+0x50>
    800048a4:	838fd0ef          	jal	800018dc <myproc>
    800048a8:	fdc42703          	lw	a4,-36(s0)
    800048ac:	01a70793          	addi	a5,a4,26
    800048b0:	078e                	slli	a5,a5,0x3
    800048b2:	953e                	add	a0,a0,a5
    800048b4:	611c                	ld	a5,0(a0)
    800048b6:	c385                	beqz	a5,800048d6 <argfd+0x54>
    return -1;
  if(pfd)
    800048b8:	00090463          	beqz	s2,800048c0 <argfd+0x3e>
    *pfd = fd;
    800048bc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800048c0:	4501                	li	a0,0
  if(pf)
    800048c2:	c091                	beqz	s1,800048c6 <argfd+0x44>
    *pf = f;
    800048c4:	e09c                	sd	a5,0(s1)
}
    800048c6:	70a2                	ld	ra,40(sp)
    800048c8:	7402                	ld	s0,32(sp)
    800048ca:	64e2                	ld	s1,24(sp)
    800048cc:	6942                	ld	s2,16(sp)
    800048ce:	6145                	addi	sp,sp,48
    800048d0:	8082                	ret
    return -1;
    800048d2:	557d                	li	a0,-1
    800048d4:	bfcd                	j	800048c6 <argfd+0x44>
    800048d6:	557d                	li	a0,-1
    800048d8:	b7fd                	j	800048c6 <argfd+0x44>

00000000800048da <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800048da:	1101                	addi	sp,sp,-32
    800048dc:	ec06                	sd	ra,24(sp)
    800048de:	e822                	sd	s0,16(sp)
    800048e0:	e426                	sd	s1,8(sp)
    800048e2:	1000                	addi	s0,sp,32
    800048e4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800048e6:	ff7fc0ef          	jal	800018dc <myproc>
    800048ea:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800048ec:	0d050793          	addi	a5,a0,208
    800048f0:	4501                	li	a0,0
    800048f2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800048f4:	6398                	ld	a4,0(a5)
    800048f6:	cb19                	beqz	a4,8000490c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800048f8:	2505                	addiw	a0,a0,1
    800048fa:	07a1                	addi	a5,a5,8
    800048fc:	fed51ce3          	bne	a0,a3,800048f4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004900:	557d                	li	a0,-1
}
    80004902:	60e2                	ld	ra,24(sp)
    80004904:	6442                	ld	s0,16(sp)
    80004906:	64a2                	ld	s1,8(sp)
    80004908:	6105                	addi	sp,sp,32
    8000490a:	8082                	ret
      p->ofile[fd] = f;
    8000490c:	01a50793          	addi	a5,a0,26
    80004910:	078e                	slli	a5,a5,0x3
    80004912:	963e                	add	a2,a2,a5
    80004914:	e204                	sd	s1,0(a2)
      return fd;
    80004916:	b7f5                	j	80004902 <fdalloc+0x28>

0000000080004918 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004918:	715d                	addi	sp,sp,-80
    8000491a:	e486                	sd	ra,72(sp)
    8000491c:	e0a2                	sd	s0,64(sp)
    8000491e:	fc26                	sd	s1,56(sp)
    80004920:	f84a                	sd	s2,48(sp)
    80004922:	f44e                	sd	s3,40(sp)
    80004924:	ec56                	sd	s5,24(sp)
    80004926:	e85a                	sd	s6,16(sp)
    80004928:	0880                	addi	s0,sp,80
    8000492a:	8b2e                	mv	s6,a1
    8000492c:	89b2                	mv	s3,a2
    8000492e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004930:	fb040593          	addi	a1,s0,-80
    80004934:	ffdfe0ef          	jal	80003930 <nameiparent>
    80004938:	84aa                	mv	s1,a0
    8000493a:	10050a63          	beqz	a0,80004a4e <create+0x136>
    return 0;

  ilock(dp);
    8000493e:	8e9fe0ef          	jal	80003226 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004942:	4601                	li	a2,0
    80004944:	fb040593          	addi	a1,s0,-80
    80004948:	8526                	mv	a0,s1
    8000494a:	d41fe0ef          	jal	8000368a <dirlookup>
    8000494e:	8aaa                	mv	s5,a0
    80004950:	c129                	beqz	a0,80004992 <create+0x7a>
    iunlockput(dp);
    80004952:	8526                	mv	a0,s1
    80004954:	addfe0ef          	jal	80003430 <iunlockput>
    ilock(ip);
    80004958:	8556                	mv	a0,s5
    8000495a:	8cdfe0ef          	jal	80003226 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000495e:	4789                	li	a5,2
    80004960:	02fb1463          	bne	s6,a5,80004988 <create+0x70>
    80004964:	044ad783          	lhu	a5,68(s5)
    80004968:	37f9                	addiw	a5,a5,-2
    8000496a:	17c2                	slli	a5,a5,0x30
    8000496c:	93c1                	srli	a5,a5,0x30
    8000496e:	4705                	li	a4,1
    80004970:	00f76c63          	bltu	a4,a5,80004988 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004974:	8556                	mv	a0,s5
    80004976:	60a6                	ld	ra,72(sp)
    80004978:	6406                	ld	s0,64(sp)
    8000497a:	74e2                	ld	s1,56(sp)
    8000497c:	7942                	ld	s2,48(sp)
    8000497e:	79a2                	ld	s3,40(sp)
    80004980:	6ae2                	ld	s5,24(sp)
    80004982:	6b42                	ld	s6,16(sp)
    80004984:	6161                	addi	sp,sp,80
    80004986:	8082                	ret
    iunlockput(ip);
    80004988:	8556                	mv	a0,s5
    8000498a:	aa7fe0ef          	jal	80003430 <iunlockput>
    return 0;
    8000498e:	4a81                	li	s5,0
    80004990:	b7d5                	j	80004974 <create+0x5c>
    80004992:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004994:	85da                	mv	a1,s6
    80004996:	4088                	lw	a0,0(s1)
    80004998:	f1efe0ef          	jal	800030b6 <ialloc>
    8000499c:	8a2a                	mv	s4,a0
    8000499e:	cd15                	beqz	a0,800049da <create+0xc2>
  ilock(ip);
    800049a0:	887fe0ef          	jal	80003226 <ilock>
  ip->major = major;
    800049a4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800049a8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800049ac:	4905                	li	s2,1
    800049ae:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800049b2:	8552                	mv	a0,s4
    800049b4:	fbefe0ef          	jal	80003172 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800049b8:	032b0763          	beq	s6,s2,800049e6 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800049bc:	004a2603          	lw	a2,4(s4)
    800049c0:	fb040593          	addi	a1,s0,-80
    800049c4:	8526                	mv	a0,s1
    800049c6:	ea7fe0ef          	jal	8000386c <dirlink>
    800049ca:	06054563          	bltz	a0,80004a34 <create+0x11c>
  iunlockput(dp);
    800049ce:	8526                	mv	a0,s1
    800049d0:	a61fe0ef          	jal	80003430 <iunlockput>
  return ip;
    800049d4:	8ad2                	mv	s5,s4
    800049d6:	7a02                	ld	s4,32(sp)
    800049d8:	bf71                	j	80004974 <create+0x5c>
    iunlockput(dp);
    800049da:	8526                	mv	a0,s1
    800049dc:	a55fe0ef          	jal	80003430 <iunlockput>
    return 0;
    800049e0:	8ad2                	mv	s5,s4
    800049e2:	7a02                	ld	s4,32(sp)
    800049e4:	bf41                	j	80004974 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800049e6:	004a2603          	lw	a2,4(s4)
    800049ea:	00003597          	auipc	a1,0x3
    800049ee:	c3658593          	addi	a1,a1,-970 # 80007620 <etext+0x620>
    800049f2:	8552                	mv	a0,s4
    800049f4:	e79fe0ef          	jal	8000386c <dirlink>
    800049f8:	02054e63          	bltz	a0,80004a34 <create+0x11c>
    800049fc:	40d0                	lw	a2,4(s1)
    800049fe:	00003597          	auipc	a1,0x3
    80004a02:	c2a58593          	addi	a1,a1,-982 # 80007628 <etext+0x628>
    80004a06:	8552                	mv	a0,s4
    80004a08:	e65fe0ef          	jal	8000386c <dirlink>
    80004a0c:	02054463          	bltz	a0,80004a34 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a10:	004a2603          	lw	a2,4(s4)
    80004a14:	fb040593          	addi	a1,s0,-80
    80004a18:	8526                	mv	a0,s1
    80004a1a:	e53fe0ef          	jal	8000386c <dirlink>
    80004a1e:	00054b63          	bltz	a0,80004a34 <create+0x11c>
    dp->nlink++;  // for ".."
    80004a22:	04a4d783          	lhu	a5,74(s1)
    80004a26:	2785                	addiw	a5,a5,1
    80004a28:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004a2c:	8526                	mv	a0,s1
    80004a2e:	f44fe0ef          	jal	80003172 <iupdate>
    80004a32:	bf71                	j	800049ce <create+0xb6>
  ip->nlink = 0;
    80004a34:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004a38:	8552                	mv	a0,s4
    80004a3a:	f38fe0ef          	jal	80003172 <iupdate>
  iunlockput(ip);
    80004a3e:	8552                	mv	a0,s4
    80004a40:	9f1fe0ef          	jal	80003430 <iunlockput>
  iunlockput(dp);
    80004a44:	8526                	mv	a0,s1
    80004a46:	9ebfe0ef          	jal	80003430 <iunlockput>
  return 0;
    80004a4a:	7a02                	ld	s4,32(sp)
    80004a4c:	b725                	j	80004974 <create+0x5c>
    return 0;
    80004a4e:	8aaa                	mv	s5,a0
    80004a50:	b715                	j	80004974 <create+0x5c>

0000000080004a52 <sys_dup>:
{
    80004a52:	7179                	addi	sp,sp,-48
    80004a54:	f406                	sd	ra,40(sp)
    80004a56:	f022                	sd	s0,32(sp)
    80004a58:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004a5a:	fd840613          	addi	a2,s0,-40
    80004a5e:	4581                	li	a1,0
    80004a60:	4501                	li	a0,0
    80004a62:	e21ff0ef          	jal	80004882 <argfd>
    return -1;
    80004a66:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004a68:	02054363          	bltz	a0,80004a8e <sys_dup+0x3c>
    80004a6c:	ec26                	sd	s1,24(sp)
    80004a6e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004a70:	fd843903          	ld	s2,-40(s0)
    80004a74:	854a                	mv	a0,s2
    80004a76:	e65ff0ef          	jal	800048da <fdalloc>
    80004a7a:	84aa                	mv	s1,a0
    return -1;
    80004a7c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004a7e:	00054d63          	bltz	a0,80004a98 <sys_dup+0x46>
  filedup(f);
    80004a82:	854a                	mv	a0,s2
    80004a84:	c2eff0ef          	jal	80003eb2 <filedup>
  return fd;
    80004a88:	87a6                	mv	a5,s1
    80004a8a:	64e2                	ld	s1,24(sp)
    80004a8c:	6942                	ld	s2,16(sp)
}
    80004a8e:	853e                	mv	a0,a5
    80004a90:	70a2                	ld	ra,40(sp)
    80004a92:	7402                	ld	s0,32(sp)
    80004a94:	6145                	addi	sp,sp,48
    80004a96:	8082                	ret
    80004a98:	64e2                	ld	s1,24(sp)
    80004a9a:	6942                	ld	s2,16(sp)
    80004a9c:	bfcd                	j	80004a8e <sys_dup+0x3c>

0000000080004a9e <sys_read>:
{
    80004a9e:	7179                	addi	sp,sp,-48
    80004aa0:	f406                	sd	ra,40(sp)
    80004aa2:	f022                	sd	s0,32(sp)
    80004aa4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004aa6:	fd840593          	addi	a1,s0,-40
    80004aaa:	4505                	li	a0,1
    80004aac:	d29fd0ef          	jal	800027d4 <argaddr>
  argint(2, &n);
    80004ab0:	fe440593          	addi	a1,s0,-28
    80004ab4:	4509                	li	a0,2
    80004ab6:	d03fd0ef          	jal	800027b8 <argint>
  if(argfd(0, 0, &f) < 0)
    80004aba:	fe840613          	addi	a2,s0,-24
    80004abe:	4581                	li	a1,0
    80004ac0:	4501                	li	a0,0
    80004ac2:	dc1ff0ef          	jal	80004882 <argfd>
    80004ac6:	87aa                	mv	a5,a0
    return -1;
    80004ac8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004aca:	0007ca63          	bltz	a5,80004ade <sys_read+0x40>
  return fileread(f, p, n);
    80004ace:	fe442603          	lw	a2,-28(s0)
    80004ad2:	fd843583          	ld	a1,-40(s0)
    80004ad6:	fe843503          	ld	a0,-24(s0)
    80004ada:	d3eff0ef          	jal	80004018 <fileread>
}
    80004ade:	70a2                	ld	ra,40(sp)
    80004ae0:	7402                	ld	s0,32(sp)
    80004ae2:	6145                	addi	sp,sp,48
    80004ae4:	8082                	ret

0000000080004ae6 <sys_write>:
{
    80004ae6:	7179                	addi	sp,sp,-48
    80004ae8:	f406                	sd	ra,40(sp)
    80004aea:	f022                	sd	s0,32(sp)
    80004aec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004aee:	fd840593          	addi	a1,s0,-40
    80004af2:	4505                	li	a0,1
    80004af4:	ce1fd0ef          	jal	800027d4 <argaddr>
  argint(2, &n);
    80004af8:	fe440593          	addi	a1,s0,-28
    80004afc:	4509                	li	a0,2
    80004afe:	cbbfd0ef          	jal	800027b8 <argint>
  if(argfd(0, 0, &f) < 0)
    80004b02:	fe840613          	addi	a2,s0,-24
    80004b06:	4581                	li	a1,0
    80004b08:	4501                	li	a0,0
    80004b0a:	d79ff0ef          	jal	80004882 <argfd>
    80004b0e:	87aa                	mv	a5,a0
    return -1;
    80004b10:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b12:	0007ca63          	bltz	a5,80004b26 <sys_write+0x40>
  return filewrite(f, p, n);
    80004b16:	fe442603          	lw	a2,-28(s0)
    80004b1a:	fd843583          	ld	a1,-40(s0)
    80004b1e:	fe843503          	ld	a0,-24(s0)
    80004b22:	db4ff0ef          	jal	800040d6 <filewrite>
}
    80004b26:	70a2                	ld	ra,40(sp)
    80004b28:	7402                	ld	s0,32(sp)
    80004b2a:	6145                	addi	sp,sp,48
    80004b2c:	8082                	ret

0000000080004b2e <sys_close>:
{
    80004b2e:	1101                	addi	sp,sp,-32
    80004b30:	ec06                	sd	ra,24(sp)
    80004b32:	e822                	sd	s0,16(sp)
    80004b34:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004b36:	fe040613          	addi	a2,s0,-32
    80004b3a:	fec40593          	addi	a1,s0,-20
    80004b3e:	4501                	li	a0,0
    80004b40:	d43ff0ef          	jal	80004882 <argfd>
    return -1;
    80004b44:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004b46:	02054063          	bltz	a0,80004b66 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004b4a:	d93fc0ef          	jal	800018dc <myproc>
    80004b4e:	fec42783          	lw	a5,-20(s0)
    80004b52:	07e9                	addi	a5,a5,26
    80004b54:	078e                	slli	a5,a5,0x3
    80004b56:	953e                	add	a0,a0,a5
    80004b58:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004b5c:	fe043503          	ld	a0,-32(s0)
    80004b60:	b98ff0ef          	jal	80003ef8 <fileclose>
  return 0;
    80004b64:	4781                	li	a5,0
}
    80004b66:	853e                	mv	a0,a5
    80004b68:	60e2                	ld	ra,24(sp)
    80004b6a:	6442                	ld	s0,16(sp)
    80004b6c:	6105                	addi	sp,sp,32
    80004b6e:	8082                	ret

0000000080004b70 <sys_fstat>:
{
    80004b70:	1101                	addi	sp,sp,-32
    80004b72:	ec06                	sd	ra,24(sp)
    80004b74:	e822                	sd	s0,16(sp)
    80004b76:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004b78:	fe040593          	addi	a1,s0,-32
    80004b7c:	4505                	li	a0,1
    80004b7e:	c57fd0ef          	jal	800027d4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004b82:	fe840613          	addi	a2,s0,-24
    80004b86:	4581                	li	a1,0
    80004b88:	4501                	li	a0,0
    80004b8a:	cf9ff0ef          	jal	80004882 <argfd>
    80004b8e:	87aa                	mv	a5,a0
    return -1;
    80004b90:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b92:	0007c863          	bltz	a5,80004ba2 <sys_fstat+0x32>
  return filestat(f, st);
    80004b96:	fe043583          	ld	a1,-32(s0)
    80004b9a:	fe843503          	ld	a0,-24(s0)
    80004b9e:	c18ff0ef          	jal	80003fb6 <filestat>
}
    80004ba2:	60e2                	ld	ra,24(sp)
    80004ba4:	6442                	ld	s0,16(sp)
    80004ba6:	6105                	addi	sp,sp,32
    80004ba8:	8082                	ret

0000000080004baa <sys_link>:
{
    80004baa:	7169                	addi	sp,sp,-304
    80004bac:	f606                	sd	ra,296(sp)
    80004bae:	f222                	sd	s0,288(sp)
    80004bb0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bb2:	08000613          	li	a2,128
    80004bb6:	ed040593          	addi	a1,s0,-304
    80004bba:	4501                	li	a0,0
    80004bbc:	c35fd0ef          	jal	800027f0 <argstr>
    return -1;
    80004bc0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bc2:	0c054e63          	bltz	a0,80004c9e <sys_link+0xf4>
    80004bc6:	08000613          	li	a2,128
    80004bca:	f5040593          	addi	a1,s0,-176
    80004bce:	4505                	li	a0,1
    80004bd0:	c21fd0ef          	jal	800027f0 <argstr>
    return -1;
    80004bd4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bd6:	0c054463          	bltz	a0,80004c9e <sys_link+0xf4>
    80004bda:	ee26                	sd	s1,280(sp)
  begin_op();
    80004bdc:	efdfe0ef          	jal	80003ad8 <begin_op>
  if((ip = namei(old)) == 0){
    80004be0:	ed040513          	addi	a0,s0,-304
    80004be4:	d33fe0ef          	jal	80003916 <namei>
    80004be8:	84aa                	mv	s1,a0
    80004bea:	c53d                	beqz	a0,80004c58 <sys_link+0xae>
  ilock(ip);
    80004bec:	e3afe0ef          	jal	80003226 <ilock>
  if(ip->type == T_DIR){
    80004bf0:	04449703          	lh	a4,68(s1)
    80004bf4:	4785                	li	a5,1
    80004bf6:	06f70663          	beq	a4,a5,80004c62 <sys_link+0xb8>
    80004bfa:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004bfc:	04a4d783          	lhu	a5,74(s1)
    80004c00:	2785                	addiw	a5,a5,1
    80004c02:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c06:	8526                	mv	a0,s1
    80004c08:	d6afe0ef          	jal	80003172 <iupdate>
  iunlock(ip);
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	ec6fe0ef          	jal	800032d4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004c12:	fd040593          	addi	a1,s0,-48
    80004c16:	f5040513          	addi	a0,s0,-176
    80004c1a:	d17fe0ef          	jal	80003930 <nameiparent>
    80004c1e:	892a                	mv	s2,a0
    80004c20:	cd21                	beqz	a0,80004c78 <sys_link+0xce>
  ilock(dp);
    80004c22:	e04fe0ef          	jal	80003226 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004c26:	00092703          	lw	a4,0(s2)
    80004c2a:	409c                	lw	a5,0(s1)
    80004c2c:	04f71363          	bne	a4,a5,80004c72 <sys_link+0xc8>
    80004c30:	40d0                	lw	a2,4(s1)
    80004c32:	fd040593          	addi	a1,s0,-48
    80004c36:	854a                	mv	a0,s2
    80004c38:	c35fe0ef          	jal	8000386c <dirlink>
    80004c3c:	02054b63          	bltz	a0,80004c72 <sys_link+0xc8>
  iunlockput(dp);
    80004c40:	854a                	mv	a0,s2
    80004c42:	feefe0ef          	jal	80003430 <iunlockput>
  iput(ip);
    80004c46:	8526                	mv	a0,s1
    80004c48:	f60fe0ef          	jal	800033a8 <iput>
  end_op();
    80004c4c:	ef7fe0ef          	jal	80003b42 <end_op>
  return 0;
    80004c50:	4781                	li	a5,0
    80004c52:	64f2                	ld	s1,280(sp)
    80004c54:	6952                	ld	s2,272(sp)
    80004c56:	a0a1                	j	80004c9e <sys_link+0xf4>
    end_op();
    80004c58:	eebfe0ef          	jal	80003b42 <end_op>
    return -1;
    80004c5c:	57fd                	li	a5,-1
    80004c5e:	64f2                	ld	s1,280(sp)
    80004c60:	a83d                	j	80004c9e <sys_link+0xf4>
    iunlockput(ip);
    80004c62:	8526                	mv	a0,s1
    80004c64:	fccfe0ef          	jal	80003430 <iunlockput>
    end_op();
    80004c68:	edbfe0ef          	jal	80003b42 <end_op>
    return -1;
    80004c6c:	57fd                	li	a5,-1
    80004c6e:	64f2                	ld	s1,280(sp)
    80004c70:	a03d                	j	80004c9e <sys_link+0xf4>
    iunlockput(dp);
    80004c72:	854a                	mv	a0,s2
    80004c74:	fbcfe0ef          	jal	80003430 <iunlockput>
  ilock(ip);
    80004c78:	8526                	mv	a0,s1
    80004c7a:	dacfe0ef          	jal	80003226 <ilock>
  ip->nlink--;
    80004c7e:	04a4d783          	lhu	a5,74(s1)
    80004c82:	37fd                	addiw	a5,a5,-1
    80004c84:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c88:	8526                	mv	a0,s1
    80004c8a:	ce8fe0ef          	jal	80003172 <iupdate>
  iunlockput(ip);
    80004c8e:	8526                	mv	a0,s1
    80004c90:	fa0fe0ef          	jal	80003430 <iunlockput>
  end_op();
    80004c94:	eaffe0ef          	jal	80003b42 <end_op>
  return -1;
    80004c98:	57fd                	li	a5,-1
    80004c9a:	64f2                	ld	s1,280(sp)
    80004c9c:	6952                	ld	s2,272(sp)
}
    80004c9e:	853e                	mv	a0,a5
    80004ca0:	70b2                	ld	ra,296(sp)
    80004ca2:	7412                	ld	s0,288(sp)
    80004ca4:	6155                	addi	sp,sp,304
    80004ca6:	8082                	ret

0000000080004ca8 <sys_unlink>:
{
    80004ca8:	7111                	addi	sp,sp,-256
    80004caa:	fd86                	sd	ra,248(sp)
    80004cac:	f9a2                	sd	s0,240(sp)
    80004cae:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80004cb0:	08000613          	li	a2,128
    80004cb4:	f2040593          	addi	a1,s0,-224
    80004cb8:	4501                	li	a0,0
    80004cba:	b37fd0ef          	jal	800027f0 <argstr>
    80004cbe:	16054663          	bltz	a0,80004e2a <sys_unlink+0x182>
    80004cc2:	f5a6                	sd	s1,232(sp)
  begin_op();
    80004cc4:	e15fe0ef          	jal	80003ad8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004cc8:	fa040593          	addi	a1,s0,-96
    80004ccc:	f2040513          	addi	a0,s0,-224
    80004cd0:	c61fe0ef          	jal	80003930 <nameiparent>
    80004cd4:	84aa                	mv	s1,a0
    80004cd6:	c955                	beqz	a0,80004d8a <sys_unlink+0xe2>
  ilock(dp);
    80004cd8:	d4efe0ef          	jal	80003226 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004cdc:	00003597          	auipc	a1,0x3
    80004ce0:	94458593          	addi	a1,a1,-1724 # 80007620 <etext+0x620>
    80004ce4:	fa040513          	addi	a0,s0,-96
    80004ce8:	98dfe0ef          	jal	80003674 <namecmp>
    80004cec:	12050463          	beqz	a0,80004e14 <sys_unlink+0x16c>
    80004cf0:	00003597          	auipc	a1,0x3
    80004cf4:	93858593          	addi	a1,a1,-1736 # 80007628 <etext+0x628>
    80004cf8:	fa040513          	addi	a0,s0,-96
    80004cfc:	979fe0ef          	jal	80003674 <namecmp>
    80004d00:	10050a63          	beqz	a0,80004e14 <sys_unlink+0x16c>
    80004d04:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004d06:	f1c40613          	addi	a2,s0,-228
    80004d0a:	fa040593          	addi	a1,s0,-96
    80004d0e:	8526                	mv	a0,s1
    80004d10:	97bfe0ef          	jal	8000368a <dirlookup>
    80004d14:	892a                	mv	s2,a0
    80004d16:	0e050e63          	beqz	a0,80004e12 <sys_unlink+0x16a>
    80004d1a:	edce                	sd	s3,216(sp)
  ilock(ip);
    80004d1c:	d0afe0ef          	jal	80003226 <ilock>
  if(ip->nlink < 1)
    80004d20:	04a91783          	lh	a5,74(s2)
    80004d24:	06f05863          	blez	a5,80004d94 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004d28:	04491703          	lh	a4,68(s2)
    80004d2c:	4785                	li	a5,1
    80004d2e:	06f70b63          	beq	a4,a5,80004da4 <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80004d32:	fb040993          	addi	s3,s0,-80
    80004d36:	4641                	li	a2,16
    80004d38:	4581                	li	a1,0
    80004d3a:	854e                	mv	a0,s3
    80004d3c:	f93fb0ef          	jal	80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d40:	4741                	li	a4,16
    80004d42:	f1c42683          	lw	a3,-228(s0)
    80004d46:	864e                	mv	a2,s3
    80004d48:	4581                	li	a1,0
    80004d4a:	8526                	mv	a0,s1
    80004d4c:	825fe0ef          	jal	80003570 <writei>
    80004d50:	47c1                	li	a5,16
    80004d52:	08f51f63          	bne	a0,a5,80004df0 <sys_unlink+0x148>
  if(ip->type == T_DIR){
    80004d56:	04491703          	lh	a4,68(s2)
    80004d5a:	4785                	li	a5,1
    80004d5c:	0af70263          	beq	a4,a5,80004e00 <sys_unlink+0x158>
  iunlockput(dp);
    80004d60:	8526                	mv	a0,s1
    80004d62:	ecefe0ef          	jal	80003430 <iunlockput>
  ip->nlink--;
    80004d66:	04a95783          	lhu	a5,74(s2)
    80004d6a:	37fd                	addiw	a5,a5,-1
    80004d6c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d70:	854a                	mv	a0,s2
    80004d72:	c00fe0ef          	jal	80003172 <iupdate>
  iunlockput(ip);
    80004d76:	854a                	mv	a0,s2
    80004d78:	eb8fe0ef          	jal	80003430 <iunlockput>
  end_op();
    80004d7c:	dc7fe0ef          	jal	80003b42 <end_op>
  return 0;
    80004d80:	4501                	li	a0,0
    80004d82:	74ae                	ld	s1,232(sp)
    80004d84:	790e                	ld	s2,224(sp)
    80004d86:	69ee                	ld	s3,216(sp)
    80004d88:	a869                	j	80004e22 <sys_unlink+0x17a>
    end_op();
    80004d8a:	db9fe0ef          	jal	80003b42 <end_op>
    return -1;
    80004d8e:	557d                	li	a0,-1
    80004d90:	74ae                	ld	s1,232(sp)
    80004d92:	a841                	j	80004e22 <sys_unlink+0x17a>
    80004d94:	e9d2                	sd	s4,208(sp)
    80004d96:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80004d98:	00003517          	auipc	a0,0x3
    80004d9c:	89850513          	addi	a0,a0,-1896 # 80007630 <etext+0x630>
    80004da0:	9fffb0ef          	jal	8000079e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004da4:	04c92703          	lw	a4,76(s2)
    80004da8:	02000793          	li	a5,32
    80004dac:	f8e7f3e3          	bgeu	a5,a4,80004d32 <sys_unlink+0x8a>
    80004db0:	e9d2                	sd	s4,208(sp)
    80004db2:	e5d6                	sd	s5,200(sp)
    80004db4:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004db6:	f0840a93          	addi	s5,s0,-248
    80004dba:	4a41                	li	s4,16
    80004dbc:	8752                	mv	a4,s4
    80004dbe:	86ce                	mv	a3,s3
    80004dc0:	8656                	mv	a2,s5
    80004dc2:	4581                	li	a1,0
    80004dc4:	854a                	mv	a0,s2
    80004dc6:	eb8fe0ef          	jal	8000347e <readi>
    80004dca:	01451d63          	bne	a0,s4,80004de4 <sys_unlink+0x13c>
    if(de.inum != 0)
    80004dce:	f0845783          	lhu	a5,-248(s0)
    80004dd2:	efb1                	bnez	a5,80004e2e <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004dd4:	29c1                	addiw	s3,s3,16
    80004dd6:	04c92783          	lw	a5,76(s2)
    80004dda:	fef9e1e3          	bltu	s3,a5,80004dbc <sys_unlink+0x114>
    80004dde:	6a4e                	ld	s4,208(sp)
    80004de0:	6aae                	ld	s5,200(sp)
    80004de2:	bf81                	j	80004d32 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004de4:	00003517          	auipc	a0,0x3
    80004de8:	86450513          	addi	a0,a0,-1948 # 80007648 <etext+0x648>
    80004dec:	9b3fb0ef          	jal	8000079e <panic>
    80004df0:	e9d2                	sd	s4,208(sp)
    80004df2:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80004df4:	00003517          	auipc	a0,0x3
    80004df8:	86c50513          	addi	a0,a0,-1940 # 80007660 <etext+0x660>
    80004dfc:	9a3fb0ef          	jal	8000079e <panic>
    dp->nlink--;
    80004e00:	04a4d783          	lhu	a5,74(s1)
    80004e04:	37fd                	addiw	a5,a5,-1
    80004e06:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e0a:	8526                	mv	a0,s1
    80004e0c:	b66fe0ef          	jal	80003172 <iupdate>
    80004e10:	bf81                	j	80004d60 <sys_unlink+0xb8>
    80004e12:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80004e14:	8526                	mv	a0,s1
    80004e16:	e1afe0ef          	jal	80003430 <iunlockput>
  end_op();
    80004e1a:	d29fe0ef          	jal	80003b42 <end_op>
  return -1;
    80004e1e:	557d                	li	a0,-1
    80004e20:	74ae                	ld	s1,232(sp)
}
    80004e22:	70ee                	ld	ra,248(sp)
    80004e24:	744e                	ld	s0,240(sp)
    80004e26:	6111                	addi	sp,sp,256
    80004e28:	8082                	ret
    return -1;
    80004e2a:	557d                	li	a0,-1
    80004e2c:	bfdd                	j	80004e22 <sys_unlink+0x17a>
    iunlockput(ip);
    80004e2e:	854a                	mv	a0,s2
    80004e30:	e00fe0ef          	jal	80003430 <iunlockput>
    goto bad;
    80004e34:	790e                	ld	s2,224(sp)
    80004e36:	69ee                	ld	s3,216(sp)
    80004e38:	6a4e                	ld	s4,208(sp)
    80004e3a:	6aae                	ld	s5,200(sp)
    80004e3c:	bfe1                	j	80004e14 <sys_unlink+0x16c>

0000000080004e3e <sys_open>:

uint64
sys_open(void)
{
    80004e3e:	7131                	addi	sp,sp,-192
    80004e40:	fd06                	sd	ra,184(sp)
    80004e42:	f922                	sd	s0,176(sp)
    80004e44:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004e46:	f4c40593          	addi	a1,s0,-180
    80004e4a:	4505                	li	a0,1
    80004e4c:	96dfd0ef          	jal	800027b8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e50:	08000613          	li	a2,128
    80004e54:	f5040593          	addi	a1,s0,-176
    80004e58:	4501                	li	a0,0
    80004e5a:	997fd0ef          	jal	800027f0 <argstr>
    80004e5e:	87aa                	mv	a5,a0
    return -1;
    80004e60:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e62:	0a07c363          	bltz	a5,80004f08 <sys_open+0xca>
    80004e66:	f526                	sd	s1,168(sp)

  begin_op();
    80004e68:	c71fe0ef          	jal	80003ad8 <begin_op>

  if(omode & O_CREATE){
    80004e6c:	f4c42783          	lw	a5,-180(s0)
    80004e70:	2007f793          	andi	a5,a5,512
    80004e74:	c3dd                	beqz	a5,80004f1a <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80004e76:	4681                	li	a3,0
    80004e78:	4601                	li	a2,0
    80004e7a:	4589                	li	a1,2
    80004e7c:	f5040513          	addi	a0,s0,-176
    80004e80:	a99ff0ef          	jal	80004918 <create>
    80004e84:	84aa                	mv	s1,a0
    if(ip == 0){
    80004e86:	c549                	beqz	a0,80004f10 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004e88:	04449703          	lh	a4,68(s1)
    80004e8c:	478d                	li	a5,3
    80004e8e:	00f71763          	bne	a4,a5,80004e9c <sys_open+0x5e>
    80004e92:	0464d703          	lhu	a4,70(s1)
    80004e96:	47a5                	li	a5,9
    80004e98:	0ae7ee63          	bltu	a5,a4,80004f54 <sys_open+0x116>
    80004e9c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004e9e:	fb7fe0ef          	jal	80003e54 <filealloc>
    80004ea2:	892a                	mv	s2,a0
    80004ea4:	c561                	beqz	a0,80004f6c <sys_open+0x12e>
    80004ea6:	ed4e                	sd	s3,152(sp)
    80004ea8:	a33ff0ef          	jal	800048da <fdalloc>
    80004eac:	89aa                	mv	s3,a0
    80004eae:	0a054b63          	bltz	a0,80004f64 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004eb2:	04449703          	lh	a4,68(s1)
    80004eb6:	478d                	li	a5,3
    80004eb8:	0cf70363          	beq	a4,a5,80004f7e <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004ebc:	4789                	li	a5,2
    80004ebe:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004ec2:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004ec6:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004eca:	f4c42783          	lw	a5,-180(s0)
    80004ece:	0017f713          	andi	a4,a5,1
    80004ed2:	00174713          	xori	a4,a4,1
    80004ed6:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004eda:	0037f713          	andi	a4,a5,3
    80004ede:	00e03733          	snez	a4,a4
    80004ee2:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004ee6:	4007f793          	andi	a5,a5,1024
    80004eea:	c791                	beqz	a5,80004ef6 <sys_open+0xb8>
    80004eec:	04449703          	lh	a4,68(s1)
    80004ef0:	4789                	li	a5,2
    80004ef2:	08f70d63          	beq	a4,a5,80004f8c <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80004ef6:	8526                	mv	a0,s1
    80004ef8:	bdcfe0ef          	jal	800032d4 <iunlock>
  end_op();
    80004efc:	c47fe0ef          	jal	80003b42 <end_op>

  return fd;
    80004f00:	854e                	mv	a0,s3
    80004f02:	74aa                	ld	s1,168(sp)
    80004f04:	790a                	ld	s2,160(sp)
    80004f06:	69ea                	ld	s3,152(sp)
}
    80004f08:	70ea                	ld	ra,184(sp)
    80004f0a:	744a                	ld	s0,176(sp)
    80004f0c:	6129                	addi	sp,sp,192
    80004f0e:	8082                	ret
      end_op();
    80004f10:	c33fe0ef          	jal	80003b42 <end_op>
      return -1;
    80004f14:	557d                	li	a0,-1
    80004f16:	74aa                	ld	s1,168(sp)
    80004f18:	bfc5                	j	80004f08 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80004f1a:	f5040513          	addi	a0,s0,-176
    80004f1e:	9f9fe0ef          	jal	80003916 <namei>
    80004f22:	84aa                	mv	s1,a0
    80004f24:	c11d                	beqz	a0,80004f4a <sys_open+0x10c>
    ilock(ip);
    80004f26:	b00fe0ef          	jal	80003226 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004f2a:	04449703          	lh	a4,68(s1)
    80004f2e:	4785                	li	a5,1
    80004f30:	f4f71ce3          	bne	a4,a5,80004e88 <sys_open+0x4a>
    80004f34:	f4c42783          	lw	a5,-180(s0)
    80004f38:	d3b5                	beqz	a5,80004e9c <sys_open+0x5e>
      iunlockput(ip);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	cf4fe0ef          	jal	80003430 <iunlockput>
      end_op();
    80004f40:	c03fe0ef          	jal	80003b42 <end_op>
      return -1;
    80004f44:	557d                	li	a0,-1
    80004f46:	74aa                	ld	s1,168(sp)
    80004f48:	b7c1                	j	80004f08 <sys_open+0xca>
      end_op();
    80004f4a:	bf9fe0ef          	jal	80003b42 <end_op>
      return -1;
    80004f4e:	557d                	li	a0,-1
    80004f50:	74aa                	ld	s1,168(sp)
    80004f52:	bf5d                	j	80004f08 <sys_open+0xca>
    iunlockput(ip);
    80004f54:	8526                	mv	a0,s1
    80004f56:	cdafe0ef          	jal	80003430 <iunlockput>
    end_op();
    80004f5a:	be9fe0ef          	jal	80003b42 <end_op>
    return -1;
    80004f5e:	557d                	li	a0,-1
    80004f60:	74aa                	ld	s1,168(sp)
    80004f62:	b75d                	j	80004f08 <sys_open+0xca>
      fileclose(f);
    80004f64:	854a                	mv	a0,s2
    80004f66:	f93fe0ef          	jal	80003ef8 <fileclose>
    80004f6a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004f6c:	8526                	mv	a0,s1
    80004f6e:	cc2fe0ef          	jal	80003430 <iunlockput>
    end_op();
    80004f72:	bd1fe0ef          	jal	80003b42 <end_op>
    return -1;
    80004f76:	557d                	li	a0,-1
    80004f78:	74aa                	ld	s1,168(sp)
    80004f7a:	790a                	ld	s2,160(sp)
    80004f7c:	b771                	j	80004f08 <sys_open+0xca>
    f->type = FD_DEVICE;
    80004f7e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004f82:	04649783          	lh	a5,70(s1)
    80004f86:	02f91223          	sh	a5,36(s2)
    80004f8a:	bf35                	j	80004ec6 <sys_open+0x88>
    itrunc(ip);
    80004f8c:	8526                	mv	a0,s1
    80004f8e:	b86fe0ef          	jal	80003314 <itrunc>
    80004f92:	b795                	j	80004ef6 <sys_open+0xb8>

0000000080004f94 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004f94:	7175                	addi	sp,sp,-144
    80004f96:	e506                	sd	ra,136(sp)
    80004f98:	e122                	sd	s0,128(sp)
    80004f9a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004f9c:	b3dfe0ef          	jal	80003ad8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004fa0:	08000613          	li	a2,128
    80004fa4:	f7040593          	addi	a1,s0,-144
    80004fa8:	4501                	li	a0,0
    80004faa:	847fd0ef          	jal	800027f0 <argstr>
    80004fae:	02054363          	bltz	a0,80004fd4 <sys_mkdir+0x40>
    80004fb2:	4681                	li	a3,0
    80004fb4:	4601                	li	a2,0
    80004fb6:	4585                	li	a1,1
    80004fb8:	f7040513          	addi	a0,s0,-144
    80004fbc:	95dff0ef          	jal	80004918 <create>
    80004fc0:	c911                	beqz	a0,80004fd4 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004fc2:	c6efe0ef          	jal	80003430 <iunlockput>
  end_op();
    80004fc6:	b7dfe0ef          	jal	80003b42 <end_op>
  return 0;
    80004fca:	4501                	li	a0,0
}
    80004fcc:	60aa                	ld	ra,136(sp)
    80004fce:	640a                	ld	s0,128(sp)
    80004fd0:	6149                	addi	sp,sp,144
    80004fd2:	8082                	ret
    end_op();
    80004fd4:	b6ffe0ef          	jal	80003b42 <end_op>
    return -1;
    80004fd8:	557d                	li	a0,-1
    80004fda:	bfcd                	j	80004fcc <sys_mkdir+0x38>

0000000080004fdc <sys_mknod>:

uint64
sys_mknod(void)
{
    80004fdc:	7135                	addi	sp,sp,-160
    80004fde:	ed06                	sd	ra,152(sp)
    80004fe0:	e922                	sd	s0,144(sp)
    80004fe2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004fe4:	af5fe0ef          	jal	80003ad8 <begin_op>
  argint(1, &major);
    80004fe8:	f6c40593          	addi	a1,s0,-148
    80004fec:	4505                	li	a0,1
    80004fee:	fcafd0ef          	jal	800027b8 <argint>
  argint(2, &minor);
    80004ff2:	f6840593          	addi	a1,s0,-152
    80004ff6:	4509                	li	a0,2
    80004ff8:	fc0fd0ef          	jal	800027b8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004ffc:	08000613          	li	a2,128
    80005000:	f7040593          	addi	a1,s0,-144
    80005004:	4501                	li	a0,0
    80005006:	feafd0ef          	jal	800027f0 <argstr>
    8000500a:	02054563          	bltz	a0,80005034 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000500e:	f6841683          	lh	a3,-152(s0)
    80005012:	f6c41603          	lh	a2,-148(s0)
    80005016:	458d                	li	a1,3
    80005018:	f7040513          	addi	a0,s0,-144
    8000501c:	8fdff0ef          	jal	80004918 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005020:	c911                	beqz	a0,80005034 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005022:	c0efe0ef          	jal	80003430 <iunlockput>
  end_op();
    80005026:	b1dfe0ef          	jal	80003b42 <end_op>
  return 0;
    8000502a:	4501                	li	a0,0
}
    8000502c:	60ea                	ld	ra,152(sp)
    8000502e:	644a                	ld	s0,144(sp)
    80005030:	610d                	addi	sp,sp,160
    80005032:	8082                	ret
    end_op();
    80005034:	b0ffe0ef          	jal	80003b42 <end_op>
    return -1;
    80005038:	557d                	li	a0,-1
    8000503a:	bfcd                	j	8000502c <sys_mknod+0x50>

000000008000503c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000503c:	7135                	addi	sp,sp,-160
    8000503e:	ed06                	sd	ra,152(sp)
    80005040:	e922                	sd	s0,144(sp)
    80005042:	e14a                	sd	s2,128(sp)
    80005044:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005046:	897fc0ef          	jal	800018dc <myproc>
    8000504a:	892a                	mv	s2,a0
  
  begin_op();
    8000504c:	a8dfe0ef          	jal	80003ad8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005050:	08000613          	li	a2,128
    80005054:	f6040593          	addi	a1,s0,-160
    80005058:	4501                	li	a0,0
    8000505a:	f96fd0ef          	jal	800027f0 <argstr>
    8000505e:	04054363          	bltz	a0,800050a4 <sys_chdir+0x68>
    80005062:	e526                	sd	s1,136(sp)
    80005064:	f6040513          	addi	a0,s0,-160
    80005068:	8affe0ef          	jal	80003916 <namei>
    8000506c:	84aa                	mv	s1,a0
    8000506e:	c915                	beqz	a0,800050a2 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005070:	9b6fe0ef          	jal	80003226 <ilock>
  if(ip->type != T_DIR){
    80005074:	04449703          	lh	a4,68(s1)
    80005078:	4785                	li	a5,1
    8000507a:	02f71963          	bne	a4,a5,800050ac <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000507e:	8526                	mv	a0,s1
    80005080:	a54fe0ef          	jal	800032d4 <iunlock>
  iput(p->cwd);
    80005084:	15093503          	ld	a0,336(s2)
    80005088:	b20fe0ef          	jal	800033a8 <iput>
  end_op();
    8000508c:	ab7fe0ef          	jal	80003b42 <end_op>
  p->cwd = ip;
    80005090:	14993823          	sd	s1,336(s2)
  return 0;
    80005094:	4501                	li	a0,0
    80005096:	64aa                	ld	s1,136(sp)
}
    80005098:	60ea                	ld	ra,152(sp)
    8000509a:	644a                	ld	s0,144(sp)
    8000509c:	690a                	ld	s2,128(sp)
    8000509e:	610d                	addi	sp,sp,160
    800050a0:	8082                	ret
    800050a2:	64aa                	ld	s1,136(sp)
    end_op();
    800050a4:	a9ffe0ef          	jal	80003b42 <end_op>
    return -1;
    800050a8:	557d                	li	a0,-1
    800050aa:	b7fd                	j	80005098 <sys_chdir+0x5c>
    iunlockput(ip);
    800050ac:	8526                	mv	a0,s1
    800050ae:	b82fe0ef          	jal	80003430 <iunlockput>
    end_op();
    800050b2:	a91fe0ef          	jal	80003b42 <end_op>
    return -1;
    800050b6:	557d                	li	a0,-1
    800050b8:	64aa                	ld	s1,136(sp)
    800050ba:	bff9                	j	80005098 <sys_chdir+0x5c>

00000000800050bc <sys_exec>:

uint64
sys_exec(void)
{
    800050bc:	7105                	addi	sp,sp,-480
    800050be:	ef86                	sd	ra,472(sp)
    800050c0:	eba2                	sd	s0,464(sp)
    800050c2:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800050c4:	e2840593          	addi	a1,s0,-472
    800050c8:	4505                	li	a0,1
    800050ca:	f0afd0ef          	jal	800027d4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800050ce:	08000613          	li	a2,128
    800050d2:	f3040593          	addi	a1,s0,-208
    800050d6:	4501                	li	a0,0
    800050d8:	f18fd0ef          	jal	800027f0 <argstr>
    800050dc:	87aa                	mv	a5,a0
    return -1;
    800050de:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800050e0:	0e07c063          	bltz	a5,800051c0 <sys_exec+0x104>
    800050e4:	e7a6                	sd	s1,456(sp)
    800050e6:	e3ca                	sd	s2,448(sp)
    800050e8:	ff4e                	sd	s3,440(sp)
    800050ea:	fb52                	sd	s4,432(sp)
    800050ec:	f756                	sd	s5,424(sp)
    800050ee:	f35a                	sd	s6,416(sp)
    800050f0:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800050f2:	e3040a13          	addi	s4,s0,-464
    800050f6:	10000613          	li	a2,256
    800050fa:	4581                	li	a1,0
    800050fc:	8552                	mv	a0,s4
    800050fe:	bd1fb0ef          	jal	80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005102:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005104:	89d2                	mv	s3,s4
    80005106:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005108:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000510c:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    8000510e:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005112:	00391513          	slli	a0,s2,0x3
    80005116:	85d6                	mv	a1,s5
    80005118:	e2843783          	ld	a5,-472(s0)
    8000511c:	953e                	add	a0,a0,a5
    8000511e:	e10fd0ef          	jal	8000272e <fetchaddr>
    80005122:	02054663          	bltz	a0,8000514e <sys_exec+0x92>
    if(uarg == 0){
    80005126:	e2043783          	ld	a5,-480(s0)
    8000512a:	c7a1                	beqz	a5,80005172 <sys_exec+0xb6>
    argv[i] = kalloc();
    8000512c:	9fffb0ef          	jal	80000b2a <kalloc>
    80005130:	85aa                	mv	a1,a0
    80005132:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005136:	cd01                	beqz	a0,8000514e <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005138:	865a                	mv	a2,s6
    8000513a:	e2043503          	ld	a0,-480(s0)
    8000513e:	e3afd0ef          	jal	80002778 <fetchstr>
    80005142:	00054663          	bltz	a0,8000514e <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005146:	0905                	addi	s2,s2,1
    80005148:	09a1                	addi	s3,s3,8
    8000514a:	fd7914e3          	bne	s2,s7,80005112 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000514e:	100a0a13          	addi	s4,s4,256
    80005152:	6088                	ld	a0,0(s1)
    80005154:	cd31                	beqz	a0,800051b0 <sys_exec+0xf4>
    kfree(argv[i]);
    80005156:	8f3fb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000515a:	04a1                	addi	s1,s1,8
    8000515c:	ff449be3          	bne	s1,s4,80005152 <sys_exec+0x96>
  return -1;
    80005160:	557d                	li	a0,-1
    80005162:	64be                	ld	s1,456(sp)
    80005164:	691e                	ld	s2,448(sp)
    80005166:	79fa                	ld	s3,440(sp)
    80005168:	7a5a                	ld	s4,432(sp)
    8000516a:	7aba                	ld	s5,424(sp)
    8000516c:	7b1a                	ld	s6,416(sp)
    8000516e:	6bfa                	ld	s7,408(sp)
    80005170:	a881                	j	800051c0 <sys_exec+0x104>
      argv[i] = 0;
    80005172:	0009079b          	sext.w	a5,s2
    80005176:	e3040593          	addi	a1,s0,-464
    8000517a:	078e                	slli	a5,a5,0x3
    8000517c:	97ae                	add	a5,a5,a1
    8000517e:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80005182:	f3040513          	addi	a0,s0,-208
    80005186:	ba4ff0ef          	jal	8000452a <exec>
    8000518a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000518c:	100a0a13          	addi	s4,s4,256
    80005190:	6088                	ld	a0,0(s1)
    80005192:	c511                	beqz	a0,8000519e <sys_exec+0xe2>
    kfree(argv[i]);
    80005194:	8b5fb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005198:	04a1                	addi	s1,s1,8
    8000519a:	ff449be3          	bne	s1,s4,80005190 <sys_exec+0xd4>
  return ret;
    8000519e:	854a                	mv	a0,s2
    800051a0:	64be                	ld	s1,456(sp)
    800051a2:	691e                	ld	s2,448(sp)
    800051a4:	79fa                	ld	s3,440(sp)
    800051a6:	7a5a                	ld	s4,432(sp)
    800051a8:	7aba                	ld	s5,424(sp)
    800051aa:	7b1a                	ld	s6,416(sp)
    800051ac:	6bfa                	ld	s7,408(sp)
    800051ae:	a809                	j	800051c0 <sys_exec+0x104>
  return -1;
    800051b0:	557d                	li	a0,-1
    800051b2:	64be                	ld	s1,456(sp)
    800051b4:	691e                	ld	s2,448(sp)
    800051b6:	79fa                	ld	s3,440(sp)
    800051b8:	7a5a                	ld	s4,432(sp)
    800051ba:	7aba                	ld	s5,424(sp)
    800051bc:	7b1a                	ld	s6,416(sp)
    800051be:	6bfa                	ld	s7,408(sp)
}
    800051c0:	60fe                	ld	ra,472(sp)
    800051c2:	645e                	ld	s0,464(sp)
    800051c4:	613d                	addi	sp,sp,480
    800051c6:	8082                	ret

00000000800051c8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800051c8:	7139                	addi	sp,sp,-64
    800051ca:	fc06                	sd	ra,56(sp)
    800051cc:	f822                	sd	s0,48(sp)
    800051ce:	f426                	sd	s1,40(sp)
    800051d0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800051d2:	f0afc0ef          	jal	800018dc <myproc>
    800051d6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800051d8:	fd840593          	addi	a1,s0,-40
    800051dc:	4501                	li	a0,0
    800051de:	df6fd0ef          	jal	800027d4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800051e2:	fc840593          	addi	a1,s0,-56
    800051e6:	fd040513          	addi	a0,s0,-48
    800051ea:	81eff0ef          	jal	80004208 <pipealloc>
    return -1;
    800051ee:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800051f0:	0a054463          	bltz	a0,80005298 <sys_pipe+0xd0>
  fd0 = -1;
    800051f4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800051f8:	fd043503          	ld	a0,-48(s0)
    800051fc:	edeff0ef          	jal	800048da <fdalloc>
    80005200:	fca42223          	sw	a0,-60(s0)
    80005204:	08054163          	bltz	a0,80005286 <sys_pipe+0xbe>
    80005208:	fc843503          	ld	a0,-56(s0)
    8000520c:	eceff0ef          	jal	800048da <fdalloc>
    80005210:	fca42023          	sw	a0,-64(s0)
    80005214:	06054063          	bltz	a0,80005274 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005218:	4691                	li	a3,4
    8000521a:	fc440613          	addi	a2,s0,-60
    8000521e:	fd843583          	ld	a1,-40(s0)
    80005222:	68a8                	ld	a0,80(s1)
    80005224:	b60fc0ef          	jal	80001584 <copyout>
    80005228:	00054e63          	bltz	a0,80005244 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000522c:	4691                	li	a3,4
    8000522e:	fc040613          	addi	a2,s0,-64
    80005232:	fd843583          	ld	a1,-40(s0)
    80005236:	95b6                	add	a1,a1,a3
    80005238:	68a8                	ld	a0,80(s1)
    8000523a:	b4afc0ef          	jal	80001584 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000523e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005240:	04055c63          	bgez	a0,80005298 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005244:	fc442783          	lw	a5,-60(s0)
    80005248:	07e9                	addi	a5,a5,26
    8000524a:	078e                	slli	a5,a5,0x3
    8000524c:	97a6                	add	a5,a5,s1
    8000524e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005252:	fc042783          	lw	a5,-64(s0)
    80005256:	07e9                	addi	a5,a5,26
    80005258:	078e                	slli	a5,a5,0x3
    8000525a:	94be                	add	s1,s1,a5
    8000525c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005260:	fd043503          	ld	a0,-48(s0)
    80005264:	c95fe0ef          	jal	80003ef8 <fileclose>
    fileclose(wf);
    80005268:	fc843503          	ld	a0,-56(s0)
    8000526c:	c8dfe0ef          	jal	80003ef8 <fileclose>
    return -1;
    80005270:	57fd                	li	a5,-1
    80005272:	a01d                	j	80005298 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005274:	fc442783          	lw	a5,-60(s0)
    80005278:	0007c763          	bltz	a5,80005286 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000527c:	07e9                	addi	a5,a5,26
    8000527e:	078e                	slli	a5,a5,0x3
    80005280:	97a6                	add	a5,a5,s1
    80005282:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005286:	fd043503          	ld	a0,-48(s0)
    8000528a:	c6ffe0ef          	jal	80003ef8 <fileclose>
    fileclose(wf);
    8000528e:	fc843503          	ld	a0,-56(s0)
    80005292:	c67fe0ef          	jal	80003ef8 <fileclose>
    return -1;
    80005296:	57fd                	li	a5,-1
}
    80005298:	853e                	mv	a0,a5
    8000529a:	70e2                	ld	ra,56(sp)
    8000529c:	7442                	ld	s0,48(sp)
    8000529e:	74a2                	ld	s1,40(sp)
    800052a0:	6121                	addi	sp,sp,64
    800052a2:	8082                	ret
	...

00000000800052b0 <kernelvec>:
    800052b0:	7111                	addi	sp,sp,-256
    800052b2:	e006                	sd	ra,0(sp)
    800052b4:	e40a                	sd	sp,8(sp)
    800052b6:	e80e                	sd	gp,16(sp)
    800052b8:	ec12                	sd	tp,24(sp)
    800052ba:	f016                	sd	t0,32(sp)
    800052bc:	f41a                	sd	t1,40(sp)
    800052be:	f81e                	sd	t2,48(sp)
    800052c0:	e4aa                	sd	a0,72(sp)
    800052c2:	e8ae                	sd	a1,80(sp)
    800052c4:	ecb2                	sd	a2,88(sp)
    800052c6:	f0b6                	sd	a3,96(sp)
    800052c8:	f4ba                	sd	a4,104(sp)
    800052ca:	f8be                	sd	a5,112(sp)
    800052cc:	fcc2                	sd	a6,120(sp)
    800052ce:	e146                	sd	a7,128(sp)
    800052d0:	edf2                	sd	t3,216(sp)
    800052d2:	f1f6                	sd	t4,224(sp)
    800052d4:	f5fa                	sd	t5,232(sp)
    800052d6:	f9fe                	sd	t6,240(sp)
    800052d8:	b66fd0ef          	jal	8000263e <kerneltrap>
    800052dc:	6082                	ld	ra,0(sp)
    800052de:	6122                	ld	sp,8(sp)
    800052e0:	61c2                	ld	gp,16(sp)
    800052e2:	7282                	ld	t0,32(sp)
    800052e4:	7322                	ld	t1,40(sp)
    800052e6:	73c2                	ld	t2,48(sp)
    800052e8:	6526                	ld	a0,72(sp)
    800052ea:	65c6                	ld	a1,80(sp)
    800052ec:	6666                	ld	a2,88(sp)
    800052ee:	7686                	ld	a3,96(sp)
    800052f0:	7726                	ld	a4,104(sp)
    800052f2:	77c6                	ld	a5,112(sp)
    800052f4:	7866                	ld	a6,120(sp)
    800052f6:	688a                	ld	a7,128(sp)
    800052f8:	6e6e                	ld	t3,216(sp)
    800052fa:	7e8e                	ld	t4,224(sp)
    800052fc:	7f2e                	ld	t5,232(sp)
    800052fe:	7fce                	ld	t6,240(sp)
    80005300:	6111                	addi	sp,sp,256
    80005302:	10200073          	sret
	...

000000008000530e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000530e:	1141                	addi	sp,sp,-16
    80005310:	e406                	sd	ra,8(sp)
    80005312:	e022                	sd	s0,0(sp)
    80005314:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005316:	0c000737          	lui	a4,0xc000
    8000531a:	4785                	li	a5,1
    8000531c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000531e:	c35c                	sw	a5,4(a4)
}
    80005320:	60a2                	ld	ra,8(sp)
    80005322:	6402                	ld	s0,0(sp)
    80005324:	0141                	addi	sp,sp,16
    80005326:	8082                	ret

0000000080005328 <plicinithart>:

void
plicinithart(void)
{
    80005328:	1141                	addi	sp,sp,-16
    8000532a:	e406                	sd	ra,8(sp)
    8000532c:	e022                	sd	s0,0(sp)
    8000532e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005330:	d78fc0ef          	jal	800018a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005334:	0085171b          	slliw	a4,a0,0x8
    80005338:	0c0027b7          	lui	a5,0xc002
    8000533c:	97ba                	add	a5,a5,a4
    8000533e:	40200713          	li	a4,1026
    80005342:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005346:	00d5151b          	slliw	a0,a0,0xd
    8000534a:	0c2017b7          	lui	a5,0xc201
    8000534e:	97aa                	add	a5,a5,a0
    80005350:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005354:	60a2                	ld	ra,8(sp)
    80005356:	6402                	ld	s0,0(sp)
    80005358:	0141                	addi	sp,sp,16
    8000535a:	8082                	ret

000000008000535c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000535c:	1141                	addi	sp,sp,-16
    8000535e:	e406                	sd	ra,8(sp)
    80005360:	e022                	sd	s0,0(sp)
    80005362:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005364:	d44fc0ef          	jal	800018a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005368:	00d5151b          	slliw	a0,a0,0xd
    8000536c:	0c2017b7          	lui	a5,0xc201
    80005370:	97aa                	add	a5,a5,a0
  return irq;
}
    80005372:	43c8                	lw	a0,4(a5)
    80005374:	60a2                	ld	ra,8(sp)
    80005376:	6402                	ld	s0,0(sp)
    80005378:	0141                	addi	sp,sp,16
    8000537a:	8082                	ret

000000008000537c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000537c:	1101                	addi	sp,sp,-32
    8000537e:	ec06                	sd	ra,24(sp)
    80005380:	e822                	sd	s0,16(sp)
    80005382:	e426                	sd	s1,8(sp)
    80005384:	1000                	addi	s0,sp,32
    80005386:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005388:	d20fc0ef          	jal	800018a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000538c:	00d5179b          	slliw	a5,a0,0xd
    80005390:	0c201737          	lui	a4,0xc201
    80005394:	97ba                	add	a5,a5,a4
    80005396:	c3c4                	sw	s1,4(a5)
}
    80005398:	60e2                	ld	ra,24(sp)
    8000539a:	6442                	ld	s0,16(sp)
    8000539c:	64a2                	ld	s1,8(sp)
    8000539e:	6105                	addi	sp,sp,32
    800053a0:	8082                	ret

00000000800053a2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800053a2:	1141                	addi	sp,sp,-16
    800053a4:	e406                	sd	ra,8(sp)
    800053a6:	e022                	sd	s0,0(sp)
    800053a8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800053aa:	479d                	li	a5,7
    800053ac:	04a7ca63          	blt	a5,a0,80005400 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800053b0:	00021797          	auipc	a5,0x21
    800053b4:	15078793          	addi	a5,a5,336 # 80026500 <disk>
    800053b8:	97aa                	add	a5,a5,a0
    800053ba:	0187c783          	lbu	a5,24(a5)
    800053be:	e7b9                	bnez	a5,8000540c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800053c0:	00451693          	slli	a3,a0,0x4
    800053c4:	00021797          	auipc	a5,0x21
    800053c8:	13c78793          	addi	a5,a5,316 # 80026500 <disk>
    800053cc:	6398                	ld	a4,0(a5)
    800053ce:	9736                	add	a4,a4,a3
    800053d0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800053d4:	6398                	ld	a4,0(a5)
    800053d6:	9736                	add	a4,a4,a3
    800053d8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800053dc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800053e0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800053e4:	97aa                	add	a5,a5,a0
    800053e6:	4705                	li	a4,1
    800053e8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800053ec:	00021517          	auipc	a0,0x21
    800053f0:	12c50513          	addi	a0,a0,300 # 80026518 <disk+0x18>
    800053f4:	b2dfc0ef          	jal	80001f20 <wakeup>
}
    800053f8:	60a2                	ld	ra,8(sp)
    800053fa:	6402                	ld	s0,0(sp)
    800053fc:	0141                	addi	sp,sp,16
    800053fe:	8082                	ret
    panic("free_desc 1");
    80005400:	00002517          	auipc	a0,0x2
    80005404:	27050513          	addi	a0,a0,624 # 80007670 <etext+0x670>
    80005408:	b96fb0ef          	jal	8000079e <panic>
    panic("free_desc 2");
    8000540c:	00002517          	auipc	a0,0x2
    80005410:	27450513          	addi	a0,a0,628 # 80007680 <etext+0x680>
    80005414:	b8afb0ef          	jal	8000079e <panic>

0000000080005418 <virtio_disk_init>:
{
    80005418:	1101                	addi	sp,sp,-32
    8000541a:	ec06                	sd	ra,24(sp)
    8000541c:	e822                	sd	s0,16(sp)
    8000541e:	e426                	sd	s1,8(sp)
    80005420:	e04a                	sd	s2,0(sp)
    80005422:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005424:	00002597          	auipc	a1,0x2
    80005428:	26c58593          	addi	a1,a1,620 # 80007690 <etext+0x690>
    8000542c:	00021517          	auipc	a0,0x21
    80005430:	1fc50513          	addi	a0,a0,508 # 80026628 <disk+0x128>
    80005434:	f46fb0ef          	jal	80000b7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005438:	100017b7          	lui	a5,0x10001
    8000543c:	4398                	lw	a4,0(a5)
    8000543e:	2701                	sext.w	a4,a4
    80005440:	747277b7          	lui	a5,0x74727
    80005444:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005448:	14f71863          	bne	a4,a5,80005598 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000544c:	100017b7          	lui	a5,0x10001
    80005450:	43dc                	lw	a5,4(a5)
    80005452:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005454:	4709                	li	a4,2
    80005456:	14e79163          	bne	a5,a4,80005598 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000545a:	100017b7          	lui	a5,0x10001
    8000545e:	479c                	lw	a5,8(a5)
    80005460:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005462:	12e79b63          	bne	a5,a4,80005598 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005466:	100017b7          	lui	a5,0x10001
    8000546a:	47d8                	lw	a4,12(a5)
    8000546c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000546e:	554d47b7          	lui	a5,0x554d4
    80005472:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005476:	12f71163          	bne	a4,a5,80005598 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000547a:	100017b7          	lui	a5,0x10001
    8000547e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005482:	4705                	li	a4,1
    80005484:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005486:	470d                	li	a4,3
    80005488:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000548a:	10001737          	lui	a4,0x10001
    8000548e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005490:	c7ffe6b7          	lui	a3,0xc7ffe
    80005494:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd811f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005498:	8f75                	and	a4,a4,a3
    8000549a:	100016b7          	lui	a3,0x10001
    8000549e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054a0:	472d                	li	a4,11
    800054a2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054a4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800054a8:	439c                	lw	a5,0(a5)
    800054aa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800054ae:	8ba1                	andi	a5,a5,8
    800054b0:	0e078a63          	beqz	a5,800055a4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800054b4:	100017b7          	lui	a5,0x10001
    800054b8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800054bc:	43fc                	lw	a5,68(a5)
    800054be:	2781                	sext.w	a5,a5
    800054c0:	0e079863          	bnez	a5,800055b0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800054c4:	100017b7          	lui	a5,0x10001
    800054c8:	5bdc                	lw	a5,52(a5)
    800054ca:	2781                	sext.w	a5,a5
  if(max == 0)
    800054cc:	0e078863          	beqz	a5,800055bc <virtio_disk_init+0x1a4>
  if(max < NUM)
    800054d0:	471d                	li	a4,7
    800054d2:	0ef77b63          	bgeu	a4,a5,800055c8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800054d6:	e54fb0ef          	jal	80000b2a <kalloc>
    800054da:	00021497          	auipc	s1,0x21
    800054de:	02648493          	addi	s1,s1,38 # 80026500 <disk>
    800054e2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800054e4:	e46fb0ef          	jal	80000b2a <kalloc>
    800054e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800054ea:	e40fb0ef          	jal	80000b2a <kalloc>
    800054ee:	87aa                	mv	a5,a0
    800054f0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800054f2:	6088                	ld	a0,0(s1)
    800054f4:	0e050063          	beqz	a0,800055d4 <virtio_disk_init+0x1bc>
    800054f8:	00021717          	auipc	a4,0x21
    800054fc:	01073703          	ld	a4,16(a4) # 80026508 <disk+0x8>
    80005500:	cb71                	beqz	a4,800055d4 <virtio_disk_init+0x1bc>
    80005502:	cbe9                	beqz	a5,800055d4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005504:	6605                	lui	a2,0x1
    80005506:	4581                	li	a1,0
    80005508:	fc6fb0ef          	jal	80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    8000550c:	00021497          	auipc	s1,0x21
    80005510:	ff448493          	addi	s1,s1,-12 # 80026500 <disk>
    80005514:	6605                	lui	a2,0x1
    80005516:	4581                	li	a1,0
    80005518:	6488                	ld	a0,8(s1)
    8000551a:	fb4fb0ef          	jal	80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    8000551e:	6605                	lui	a2,0x1
    80005520:	4581                	li	a1,0
    80005522:	6888                	ld	a0,16(s1)
    80005524:	faafb0ef          	jal	80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005528:	100017b7          	lui	a5,0x10001
    8000552c:	4721                	li	a4,8
    8000552e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005530:	4098                	lw	a4,0(s1)
    80005532:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005536:	40d8                	lw	a4,4(s1)
    80005538:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000553c:	649c                	ld	a5,8(s1)
    8000553e:	0007869b          	sext.w	a3,a5
    80005542:	10001737          	lui	a4,0x10001
    80005546:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000554a:	9781                	srai	a5,a5,0x20
    8000554c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005550:	689c                	ld	a5,16(s1)
    80005552:	0007869b          	sext.w	a3,a5
    80005556:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000555a:	9781                	srai	a5,a5,0x20
    8000555c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005560:	4785                	li	a5,1
    80005562:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005564:	00f48c23          	sb	a5,24(s1)
    80005568:	00f48ca3          	sb	a5,25(s1)
    8000556c:	00f48d23          	sb	a5,26(s1)
    80005570:	00f48da3          	sb	a5,27(s1)
    80005574:	00f48e23          	sb	a5,28(s1)
    80005578:	00f48ea3          	sb	a5,29(s1)
    8000557c:	00f48f23          	sb	a5,30(s1)
    80005580:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005584:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005588:	07272823          	sw	s2,112(a4)
}
    8000558c:	60e2                	ld	ra,24(sp)
    8000558e:	6442                	ld	s0,16(sp)
    80005590:	64a2                	ld	s1,8(sp)
    80005592:	6902                	ld	s2,0(sp)
    80005594:	6105                	addi	sp,sp,32
    80005596:	8082                	ret
    panic("could not find virtio disk");
    80005598:	00002517          	auipc	a0,0x2
    8000559c:	10850513          	addi	a0,a0,264 # 800076a0 <etext+0x6a0>
    800055a0:	9fefb0ef          	jal	8000079e <panic>
    panic("virtio disk FEATURES_OK unset");
    800055a4:	00002517          	auipc	a0,0x2
    800055a8:	11c50513          	addi	a0,a0,284 # 800076c0 <etext+0x6c0>
    800055ac:	9f2fb0ef          	jal	8000079e <panic>
    panic("virtio disk should not be ready");
    800055b0:	00002517          	auipc	a0,0x2
    800055b4:	13050513          	addi	a0,a0,304 # 800076e0 <etext+0x6e0>
    800055b8:	9e6fb0ef          	jal	8000079e <panic>
    panic("virtio disk has no queue 0");
    800055bc:	00002517          	auipc	a0,0x2
    800055c0:	14450513          	addi	a0,a0,324 # 80007700 <etext+0x700>
    800055c4:	9dafb0ef          	jal	8000079e <panic>
    panic("virtio disk max queue too short");
    800055c8:	00002517          	auipc	a0,0x2
    800055cc:	15850513          	addi	a0,a0,344 # 80007720 <etext+0x720>
    800055d0:	9cefb0ef          	jal	8000079e <panic>
    panic("virtio disk kalloc");
    800055d4:	00002517          	auipc	a0,0x2
    800055d8:	16c50513          	addi	a0,a0,364 # 80007740 <etext+0x740>
    800055dc:	9c2fb0ef          	jal	8000079e <panic>

00000000800055e0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800055e0:	711d                	addi	sp,sp,-96
    800055e2:	ec86                	sd	ra,88(sp)
    800055e4:	e8a2                	sd	s0,80(sp)
    800055e6:	e4a6                	sd	s1,72(sp)
    800055e8:	e0ca                	sd	s2,64(sp)
    800055ea:	fc4e                	sd	s3,56(sp)
    800055ec:	f852                	sd	s4,48(sp)
    800055ee:	f456                	sd	s5,40(sp)
    800055f0:	f05a                	sd	s6,32(sp)
    800055f2:	ec5e                	sd	s7,24(sp)
    800055f4:	e862                	sd	s8,16(sp)
    800055f6:	1080                	addi	s0,sp,96
    800055f8:	89aa                	mv	s3,a0
    800055fa:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800055fc:	00c52b83          	lw	s7,12(a0)
    80005600:	001b9b9b          	slliw	s7,s7,0x1
    80005604:	1b82                	slli	s7,s7,0x20
    80005606:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000560a:	00021517          	auipc	a0,0x21
    8000560e:	01e50513          	addi	a0,a0,30 # 80026628 <disk+0x128>
    80005612:	decfb0ef          	jal	80000bfe <acquire>
  for(int i = 0; i < NUM; i++){
    80005616:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005618:	00021a97          	auipc	s5,0x21
    8000561c:	ee8a8a93          	addi	s5,s5,-280 # 80026500 <disk>
  for(int i = 0; i < 3; i++){
    80005620:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005622:	5c7d                	li	s8,-1
    80005624:	a095                	j	80005688 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005626:	00fa8733          	add	a4,s5,a5
    8000562a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000562e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005630:	0207c563          	bltz	a5,8000565a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005634:	2905                	addiw	s2,s2,1
    80005636:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005638:	05490c63          	beq	s2,s4,80005690 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000563c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000563e:	00021717          	auipc	a4,0x21
    80005642:	ec270713          	addi	a4,a4,-318 # 80026500 <disk>
    80005646:	4781                	li	a5,0
    if(disk.free[i]){
    80005648:	01874683          	lbu	a3,24(a4)
    8000564c:	fee9                	bnez	a3,80005626 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000564e:	2785                	addiw	a5,a5,1
    80005650:	0705                	addi	a4,a4,1
    80005652:	fe979be3          	bne	a5,s1,80005648 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005656:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000565a:	01205d63          	blez	s2,80005674 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000565e:	fa042503          	lw	a0,-96(s0)
    80005662:	d41ff0ef          	jal	800053a2 <free_desc>
      for(int j = 0; j < i; j++)
    80005666:	4785                	li	a5,1
    80005668:	0127d663          	bge	a5,s2,80005674 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000566c:	fa442503          	lw	a0,-92(s0)
    80005670:	d33ff0ef          	jal	800053a2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005674:	00021597          	auipc	a1,0x21
    80005678:	fb458593          	addi	a1,a1,-76 # 80026628 <disk+0x128>
    8000567c:	00021517          	auipc	a0,0x21
    80005680:	e9c50513          	addi	a0,a0,-356 # 80026518 <disk+0x18>
    80005684:	851fc0ef          	jal	80001ed4 <sleep>
  for(int i = 0; i < 3; i++){
    80005688:	fa040613          	addi	a2,s0,-96
    8000568c:	4901                	li	s2,0
    8000568e:	b77d                	j	8000563c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005690:	fa042503          	lw	a0,-96(s0)
    80005694:	00451693          	slli	a3,a0,0x4

  if(write)
    80005698:	00021797          	auipc	a5,0x21
    8000569c:	e6878793          	addi	a5,a5,-408 # 80026500 <disk>
    800056a0:	00a50713          	addi	a4,a0,10
    800056a4:	0712                	slli	a4,a4,0x4
    800056a6:	973e                	add	a4,a4,a5
    800056a8:	01603633          	snez	a2,s6
    800056ac:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800056ae:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800056b2:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800056b6:	6398                	ld	a4,0(a5)
    800056b8:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056ba:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    800056be:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800056c0:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800056c2:	6390                	ld	a2,0(a5)
    800056c4:	00d605b3          	add	a1,a2,a3
    800056c8:	4741                	li	a4,16
    800056ca:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800056cc:	4805                	li	a6,1
    800056ce:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800056d2:	fa442703          	lw	a4,-92(s0)
    800056d6:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800056da:	0712                	slli	a4,a4,0x4
    800056dc:	963a                	add	a2,a2,a4
    800056de:	05898593          	addi	a1,s3,88
    800056e2:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800056e4:	0007b883          	ld	a7,0(a5)
    800056e8:	9746                	add	a4,a4,a7
    800056ea:	40000613          	li	a2,1024
    800056ee:	c710                	sw	a2,8(a4)
  if(write)
    800056f0:	001b3613          	seqz	a2,s6
    800056f4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800056f8:	01066633          	or	a2,a2,a6
    800056fc:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005700:	fa842583          	lw	a1,-88(s0)
    80005704:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005708:	00250613          	addi	a2,a0,2
    8000570c:	0612                	slli	a2,a2,0x4
    8000570e:	963e                	add	a2,a2,a5
    80005710:	577d                	li	a4,-1
    80005712:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005716:	0592                	slli	a1,a1,0x4
    80005718:	98ae                	add	a7,a7,a1
    8000571a:	03068713          	addi	a4,a3,48
    8000571e:	973e                	add	a4,a4,a5
    80005720:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005724:	6398                	ld	a4,0(a5)
    80005726:	972e                	add	a4,a4,a1
    80005728:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000572c:	4689                	li	a3,2
    8000572e:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005732:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005736:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    8000573a:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000573e:	6794                	ld	a3,8(a5)
    80005740:	0026d703          	lhu	a4,2(a3)
    80005744:	8b1d                	andi	a4,a4,7
    80005746:	0706                	slli	a4,a4,0x1
    80005748:	96ba                	add	a3,a3,a4
    8000574a:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000574e:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005752:	6798                	ld	a4,8(a5)
    80005754:	00275783          	lhu	a5,2(a4)
    80005758:	2785                	addiw	a5,a5,1
    8000575a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000575e:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005762:	100017b7          	lui	a5,0x10001
    80005766:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000576a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    8000576e:	00021917          	auipc	s2,0x21
    80005772:	eba90913          	addi	s2,s2,-326 # 80026628 <disk+0x128>
  while(b->disk == 1) {
    80005776:	84c2                	mv	s1,a6
    80005778:	01079a63          	bne	a5,a6,8000578c <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    8000577c:	85ca                	mv	a1,s2
    8000577e:	854e                	mv	a0,s3
    80005780:	f54fc0ef          	jal	80001ed4 <sleep>
  while(b->disk == 1) {
    80005784:	0049a783          	lw	a5,4(s3)
    80005788:	fe978ae3          	beq	a5,s1,8000577c <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    8000578c:	fa042903          	lw	s2,-96(s0)
    80005790:	00290713          	addi	a4,s2,2
    80005794:	0712                	slli	a4,a4,0x4
    80005796:	00021797          	auipc	a5,0x21
    8000579a:	d6a78793          	addi	a5,a5,-662 # 80026500 <disk>
    8000579e:	97ba                	add	a5,a5,a4
    800057a0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800057a4:	00021997          	auipc	s3,0x21
    800057a8:	d5c98993          	addi	s3,s3,-676 # 80026500 <disk>
    800057ac:	00491713          	slli	a4,s2,0x4
    800057b0:	0009b783          	ld	a5,0(s3)
    800057b4:	97ba                	add	a5,a5,a4
    800057b6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800057ba:	854a                	mv	a0,s2
    800057bc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800057c0:	be3ff0ef          	jal	800053a2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800057c4:	8885                	andi	s1,s1,1
    800057c6:	f0fd                	bnez	s1,800057ac <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800057c8:	00021517          	auipc	a0,0x21
    800057cc:	e6050513          	addi	a0,a0,-416 # 80026628 <disk+0x128>
    800057d0:	cc2fb0ef          	jal	80000c92 <release>
}
    800057d4:	60e6                	ld	ra,88(sp)
    800057d6:	6446                	ld	s0,80(sp)
    800057d8:	64a6                	ld	s1,72(sp)
    800057da:	6906                	ld	s2,64(sp)
    800057dc:	79e2                	ld	s3,56(sp)
    800057de:	7a42                	ld	s4,48(sp)
    800057e0:	7aa2                	ld	s5,40(sp)
    800057e2:	7b02                	ld	s6,32(sp)
    800057e4:	6be2                	ld	s7,24(sp)
    800057e6:	6c42                	ld	s8,16(sp)
    800057e8:	6125                	addi	sp,sp,96
    800057ea:	8082                	ret

00000000800057ec <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800057ec:	1101                	addi	sp,sp,-32
    800057ee:	ec06                	sd	ra,24(sp)
    800057f0:	e822                	sd	s0,16(sp)
    800057f2:	e426                	sd	s1,8(sp)
    800057f4:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800057f6:	00021497          	auipc	s1,0x21
    800057fa:	d0a48493          	addi	s1,s1,-758 # 80026500 <disk>
    800057fe:	00021517          	auipc	a0,0x21
    80005802:	e2a50513          	addi	a0,a0,-470 # 80026628 <disk+0x128>
    80005806:	bf8fb0ef          	jal	80000bfe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000580a:	100017b7          	lui	a5,0x10001
    8000580e:	53bc                	lw	a5,96(a5)
    80005810:	8b8d                	andi	a5,a5,3
    80005812:	10001737          	lui	a4,0x10001
    80005816:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005818:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000581c:	689c                	ld	a5,16(s1)
    8000581e:	0204d703          	lhu	a4,32(s1)
    80005822:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005826:	04f70663          	beq	a4,a5,80005872 <virtio_disk_intr+0x86>
    __sync_synchronize();
    8000582a:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000582e:	6898                	ld	a4,16(s1)
    80005830:	0204d783          	lhu	a5,32(s1)
    80005834:	8b9d                	andi	a5,a5,7
    80005836:	078e                	slli	a5,a5,0x3
    80005838:	97ba                	add	a5,a5,a4
    8000583a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000583c:	00278713          	addi	a4,a5,2
    80005840:	0712                	slli	a4,a4,0x4
    80005842:	9726                	add	a4,a4,s1
    80005844:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005848:	e321                	bnez	a4,80005888 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000584a:	0789                	addi	a5,a5,2
    8000584c:	0792                	slli	a5,a5,0x4
    8000584e:	97a6                	add	a5,a5,s1
    80005850:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005852:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005856:	ecafc0ef          	jal	80001f20 <wakeup>

    disk.used_idx += 1;
    8000585a:	0204d783          	lhu	a5,32(s1)
    8000585e:	2785                	addiw	a5,a5,1
    80005860:	17c2                	slli	a5,a5,0x30
    80005862:	93c1                	srli	a5,a5,0x30
    80005864:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005868:	6898                	ld	a4,16(s1)
    8000586a:	00275703          	lhu	a4,2(a4)
    8000586e:	faf71ee3          	bne	a4,a5,8000582a <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005872:	00021517          	auipc	a0,0x21
    80005876:	db650513          	addi	a0,a0,-586 # 80026628 <disk+0x128>
    8000587a:	c18fb0ef          	jal	80000c92 <release>
}
    8000587e:	60e2                	ld	ra,24(sp)
    80005880:	6442                	ld	s0,16(sp)
    80005882:	64a2                	ld	s1,8(sp)
    80005884:	6105                	addi	sp,sp,32
    80005886:	8082                	ret
      panic("virtio_disk_intr status");
    80005888:	00002517          	auipc	a0,0x2
    8000588c:	ed050513          	addi	a0,a0,-304 # 80007758 <etext+0x758>
    80005890:	f0ffa0ef          	jal	8000079e <panic>
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
