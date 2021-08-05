
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	80010113          	addi	sp,sp,-2048 # 8000b800 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	0000b617          	auipc	a2,0xb
    8000004e:	fb660613          	addi	a2,a2,-74 # 8000b000 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	e4478793          	addi	a5,a5,-444 # 80005ea0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd5453>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e8a78793          	addi	a5,a5,-374 # 80000f30 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(struct file *f, int user_dst, uint64 dst, int n)
{
    800000ec:	7119                	addi	sp,sp,-128
    800000ee:	fc86                	sd	ra,120(sp)
    800000f0:	f8a2                	sd	s0,112(sp)
    800000f2:	f4a6                	sd	s1,104(sp)
    800000f4:	f0ca                	sd	s2,96(sp)
    800000f6:	ecce                	sd	s3,88(sp)
    800000f8:	e8d2                	sd	s4,80(sp)
    800000fa:	e4d6                	sd	s5,72(sp)
    800000fc:	e0da                	sd	s6,64(sp)
    800000fe:	fc5e                	sd	s7,56(sp)
    80000100:	f862                	sd	s8,48(sp)
    80000102:	f466                	sd	s9,40(sp)
    80000104:	f06a                	sd	s10,32(sp)
    80000106:	ec6e                	sd	s11,24(sp)
    80000108:	0100                	addi	s0,sp,128
    8000010a:	8b2e                	mv	s6,a1
    8000010c:	8ab2                	mv	s5,a2
    8000010e:	8a36                	mv	s4,a3
  uint target;
  int c;
  char cbuf;

  target = n;
    80000110:	00068b9b          	sext.w	s7,a3
  acquire(&cons.lock);
    80000114:	00013517          	auipc	a0,0x13
    80000118:	6ec50513          	addi	a0,a0,1772 # 80013800 <cons>
    8000011c:	00001097          	auipc	ra,0x1
    80000120:	994080e7          	jalr	-1644(ra) # 80000ab0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000124:	00013497          	auipc	s1,0x13
    80000128:	6dc48493          	addi	s1,s1,1756 # 80013800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000012c:	89a6                	mv	s3,s1
    8000012e:	00013917          	auipc	s2,0x13
    80000132:	77290913          	addi	s2,s2,1906 # 800138a0 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    80000136:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000138:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000013a:	4da9                	li	s11,10
  while(n > 0){
    8000013c:	07405863          	blez	s4,800001ac <consoleread+0xc0>
    while(cons.r == cons.w){
    80000140:	0a04a783          	lw	a5,160(s1)
    80000144:	0a44a703          	lw	a4,164(s1)
    80000148:	02f71463          	bne	a4,a5,80000170 <consoleread+0x84>
      if(myproc()->killed){
    8000014c:	00002097          	auipc	ra,0x2
    80000150:	95a080e7          	jalr	-1702(ra) # 80001aa6 <myproc>
    80000154:	5d1c                	lw	a5,56(a0)
    80000156:	e7b5                	bnez	a5,800001c2 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    80000158:	85ce                	mv	a1,s3
    8000015a:	854a                	mv	a0,s2
    8000015c:	00002097          	auipc	ra,0x2
    80000160:	106080e7          	jalr	262(ra) # 80002262 <sleep>
    while(cons.r == cons.w){
    80000164:	0a04a783          	lw	a5,160(s1)
    80000168:	0a44a703          	lw	a4,164(s1)
    8000016c:	fef700e3          	beq	a4,a5,8000014c <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000170:	0017871b          	addiw	a4,a5,1
    80000174:	0ae4a023          	sw	a4,160(s1)
    80000178:	07f7f713          	andi	a4,a5,127
    8000017c:	9726                	add	a4,a4,s1
    8000017e:	02074703          	lbu	a4,32(a4)
    80000182:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000186:	079c0663          	beq	s8,s9,800001f2 <consoleread+0x106>
    cbuf = c;
    8000018a:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000018e:	4685                	li	a3,1
    80000190:	f8f40613          	addi	a2,s0,-113
    80000194:	85d6                	mv	a1,s5
    80000196:	855a                	mv	a0,s6
    80000198:	00002097          	auipc	ra,0x2
    8000019c:	32a080e7          	jalr	810(ra) # 800024c2 <either_copyout>
    800001a0:	01a50663          	beq	a0,s10,800001ac <consoleread+0xc0>
    dst++;
    800001a4:	0a85                	addi	s5,s5,1
    --n;
    800001a6:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    800001a8:	f9bc1ae3          	bne	s8,s11,8000013c <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001ac:	00013517          	auipc	a0,0x13
    800001b0:	65450513          	addi	a0,a0,1620 # 80013800 <cons>
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	9cc080e7          	jalr	-1588(ra) # 80000b80 <release>

  return target - n;
    800001bc:	414b853b          	subw	a0,s7,s4
    800001c0:	a811                	j	800001d4 <consoleread+0xe8>
        release(&cons.lock);
    800001c2:	00013517          	auipc	a0,0x13
    800001c6:	63e50513          	addi	a0,a0,1598 # 80013800 <cons>
    800001ca:	00001097          	auipc	ra,0x1
    800001ce:	9b6080e7          	jalr	-1610(ra) # 80000b80 <release>
        return -1;
    800001d2:	557d                	li	a0,-1
}
    800001d4:	70e6                	ld	ra,120(sp)
    800001d6:	7446                	ld	s0,112(sp)
    800001d8:	74a6                	ld	s1,104(sp)
    800001da:	7906                	ld	s2,96(sp)
    800001dc:	69e6                	ld	s3,88(sp)
    800001de:	6a46                	ld	s4,80(sp)
    800001e0:	6aa6                	ld	s5,72(sp)
    800001e2:	6b06                	ld	s6,64(sp)
    800001e4:	7be2                	ld	s7,56(sp)
    800001e6:	7c42                	ld	s8,48(sp)
    800001e8:	7ca2                	ld	s9,40(sp)
    800001ea:	7d02                	ld	s10,32(sp)
    800001ec:	6de2                	ld	s11,24(sp)
    800001ee:	6109                	addi	sp,sp,128
    800001f0:	8082                	ret
      if(n < target){
    800001f2:	000a071b          	sext.w	a4,s4
    800001f6:	fb777be3          	bgeu	a4,s7,800001ac <consoleread+0xc0>
        cons.r--;
    800001fa:	00013717          	auipc	a4,0x13
    800001fe:	6af72323          	sw	a5,1702(a4) # 800138a0 <cons+0xa0>
    80000202:	b76d                	j	800001ac <consoleread+0xc0>

0000000080000204 <consputc>:
  if(panicked){
    80000204:	00029797          	auipc	a5,0x29
    80000208:	15c7a783          	lw	a5,348(a5) # 80029360 <panicked>
    8000020c:	c391                	beqz	a5,80000210 <consputc+0xc>
    for(;;)
    8000020e:	a001                	j	8000020e <consputc+0xa>
{
    80000210:	1141                	addi	sp,sp,-16
    80000212:	e406                	sd	ra,8(sp)
    80000214:	e022                	sd	s0,0(sp)
    80000216:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000218:	10000793          	li	a5,256
    8000021c:	00f50a63          	beq	a0,a5,80000230 <consputc+0x2c>
    uartputc(c);
    80000220:	00000097          	auipc	ra,0x0
    80000224:	5e2080e7          	jalr	1506(ra) # 80000802 <uartputc>
}
    80000228:	60a2                	ld	ra,8(sp)
    8000022a:	6402                	ld	s0,0(sp)
    8000022c:	0141                	addi	sp,sp,16
    8000022e:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    80000230:	4521                	li	a0,8
    80000232:	00000097          	auipc	ra,0x0
    80000236:	5d0080e7          	jalr	1488(ra) # 80000802 <uartputc>
    8000023a:	02000513          	li	a0,32
    8000023e:	00000097          	auipc	ra,0x0
    80000242:	5c4080e7          	jalr	1476(ra) # 80000802 <uartputc>
    80000246:	4521                	li	a0,8
    80000248:	00000097          	auipc	ra,0x0
    8000024c:	5ba080e7          	jalr	1466(ra) # 80000802 <uartputc>
    80000250:	bfe1                	j	80000228 <consputc+0x24>

0000000080000252 <consolewrite>:
{
    80000252:	715d                	addi	sp,sp,-80
    80000254:	e486                	sd	ra,72(sp)
    80000256:	e0a2                	sd	s0,64(sp)
    80000258:	fc26                	sd	s1,56(sp)
    8000025a:	f84a                	sd	s2,48(sp)
    8000025c:	f44e                	sd	s3,40(sp)
    8000025e:	f052                	sd	s4,32(sp)
    80000260:	ec56                	sd	s5,24(sp)
    80000262:	0880                	addi	s0,sp,80
    80000264:	89ae                	mv	s3,a1
    80000266:	84b2                	mv	s1,a2
    80000268:	8ab6                	mv	s5,a3
  acquire(&cons.lock);
    8000026a:	00013517          	auipc	a0,0x13
    8000026e:	59650513          	addi	a0,a0,1430 # 80013800 <cons>
    80000272:	00001097          	auipc	ra,0x1
    80000276:	83e080e7          	jalr	-1986(ra) # 80000ab0 <acquire>
  for(i = 0; i < n; i++){
    8000027a:	03505e63          	blez	s5,800002b6 <consolewrite+0x64>
    8000027e:	00148913          	addi	s2,s1,1
    80000282:	fffa879b          	addiw	a5,s5,-1
    80000286:	1782                	slli	a5,a5,0x20
    80000288:	9381                	srli	a5,a5,0x20
    8000028a:	993e                	add	s2,s2,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000028c:	5a7d                	li	s4,-1
    8000028e:	4685                	li	a3,1
    80000290:	8626                	mv	a2,s1
    80000292:	85ce                	mv	a1,s3
    80000294:	fbf40513          	addi	a0,s0,-65
    80000298:	00002097          	auipc	ra,0x2
    8000029c:	280080e7          	jalr	640(ra) # 80002518 <either_copyin>
    800002a0:	01450b63          	beq	a0,s4,800002b6 <consolewrite+0x64>
    consputc(c);
    800002a4:	fbf44503          	lbu	a0,-65(s0)
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	f5c080e7          	jalr	-164(ra) # 80000204 <consputc>
  for(i = 0; i < n; i++){
    800002b0:	0485                	addi	s1,s1,1
    800002b2:	fd249ee3          	bne	s1,s2,8000028e <consolewrite+0x3c>
  release(&cons.lock);
    800002b6:	00013517          	auipc	a0,0x13
    800002ba:	54a50513          	addi	a0,a0,1354 # 80013800 <cons>
    800002be:	00001097          	auipc	ra,0x1
    800002c2:	8c2080e7          	jalr	-1854(ra) # 80000b80 <release>
}
    800002c6:	8556                	mv	a0,s5
    800002c8:	60a6                	ld	ra,72(sp)
    800002ca:	6406                	ld	s0,64(sp)
    800002cc:	74e2                	ld	s1,56(sp)
    800002ce:	7942                	ld	s2,48(sp)
    800002d0:	79a2                	ld	s3,40(sp)
    800002d2:	7a02                	ld	s4,32(sp)
    800002d4:	6ae2                	ld	s5,24(sp)
    800002d6:	6161                	addi	sp,sp,80
    800002d8:	8082                	ret

00000000800002da <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002da:	1101                	addi	sp,sp,-32
    800002dc:	ec06                	sd	ra,24(sp)
    800002de:	e822                	sd	s0,16(sp)
    800002e0:	e426                	sd	s1,8(sp)
    800002e2:	e04a                	sd	s2,0(sp)
    800002e4:	1000                	addi	s0,sp,32
    800002e6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e8:	00013517          	auipc	a0,0x13
    800002ec:	51850513          	addi	a0,a0,1304 # 80013800 <cons>
    800002f0:	00000097          	auipc	ra,0x0
    800002f4:	7c0080e7          	jalr	1984(ra) # 80000ab0 <acquire>

  switch(c){
    800002f8:	47d5                	li	a5,21
    800002fa:	0af48663          	beq	s1,a5,800003a6 <consoleintr+0xcc>
    800002fe:	0297ca63          	blt	a5,s1,80000332 <consoleintr+0x58>
    80000302:	47a1                	li	a5,8
    80000304:	0ef48763          	beq	s1,a5,800003f2 <consoleintr+0x118>
    80000308:	47c1                	li	a5,16
    8000030a:	10f49a63          	bne	s1,a5,8000041e <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    8000030e:	00002097          	auipc	ra,0x2
    80000312:	260080e7          	jalr	608(ra) # 8000256e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000316:	00013517          	auipc	a0,0x13
    8000031a:	4ea50513          	addi	a0,a0,1258 # 80013800 <cons>
    8000031e:	00001097          	auipc	ra,0x1
    80000322:	862080e7          	jalr	-1950(ra) # 80000b80 <release>
}
    80000326:	60e2                	ld	ra,24(sp)
    80000328:	6442                	ld	s0,16(sp)
    8000032a:	64a2                	ld	s1,8(sp)
    8000032c:	6902                	ld	s2,0(sp)
    8000032e:	6105                	addi	sp,sp,32
    80000330:	8082                	ret
  switch(c){
    80000332:	07f00793          	li	a5,127
    80000336:	0af48e63          	beq	s1,a5,800003f2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000033a:	00013717          	auipc	a4,0x13
    8000033e:	4c670713          	addi	a4,a4,1222 # 80013800 <cons>
    80000342:	0a872783          	lw	a5,168(a4)
    80000346:	0a072703          	lw	a4,160(a4)
    8000034a:	9f99                	subw	a5,a5,a4
    8000034c:	07f00713          	li	a4,127
    80000350:	fcf763e3          	bltu	a4,a5,80000316 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000354:	47b5                	li	a5,13
    80000356:	0cf48763          	beq	s1,a5,80000424 <consoleintr+0x14a>
      consputc(c);
    8000035a:	8526                	mv	a0,s1
    8000035c:	00000097          	auipc	ra,0x0
    80000360:	ea8080e7          	jalr	-344(ra) # 80000204 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000364:	00013797          	auipc	a5,0x13
    80000368:	49c78793          	addi	a5,a5,1180 # 80013800 <cons>
    8000036c:	0a87a703          	lw	a4,168(a5)
    80000370:	0017069b          	addiw	a3,a4,1
    80000374:	0006861b          	sext.w	a2,a3
    80000378:	0ad7a423          	sw	a3,168(a5)
    8000037c:	07f77713          	andi	a4,a4,127
    80000380:	97ba                	add	a5,a5,a4
    80000382:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000386:	47a9                	li	a5,10
    80000388:	0cf48563          	beq	s1,a5,80000452 <consoleintr+0x178>
    8000038c:	4791                	li	a5,4
    8000038e:	0cf48263          	beq	s1,a5,80000452 <consoleintr+0x178>
    80000392:	00013797          	auipc	a5,0x13
    80000396:	50e7a783          	lw	a5,1294(a5) # 800138a0 <cons+0xa0>
    8000039a:	0807879b          	addiw	a5,a5,128
    8000039e:	f6f61ce3          	bne	a2,a5,80000316 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003a2:	863e                	mv	a2,a5
    800003a4:	a07d                	j	80000452 <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003a6:	00013717          	auipc	a4,0x13
    800003aa:	45a70713          	addi	a4,a4,1114 # 80013800 <cons>
    800003ae:	0a872783          	lw	a5,168(a4)
    800003b2:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b6:	00013497          	auipc	s1,0x13
    800003ba:	44a48493          	addi	s1,s1,1098 # 80013800 <cons>
    while(cons.e != cons.w &&
    800003be:	4929                	li	s2,10
    800003c0:	f4f70be3          	beq	a4,a5,80000316 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c4:	37fd                	addiw	a5,a5,-1
    800003c6:	07f7f713          	andi	a4,a5,127
    800003ca:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003cc:	02074703          	lbu	a4,32(a4)
    800003d0:	f52703e3          	beq	a4,s2,80000316 <consoleintr+0x3c>
      cons.e--;
    800003d4:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003d8:	10000513          	li	a0,256
    800003dc:	00000097          	auipc	ra,0x0
    800003e0:	e28080e7          	jalr	-472(ra) # 80000204 <consputc>
    while(cons.e != cons.w &&
    800003e4:	0a84a783          	lw	a5,168(s1)
    800003e8:	0a44a703          	lw	a4,164(s1)
    800003ec:	fcf71ce3          	bne	a4,a5,800003c4 <consoleintr+0xea>
    800003f0:	b71d                	j	80000316 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003f2:	00013717          	auipc	a4,0x13
    800003f6:	40e70713          	addi	a4,a4,1038 # 80013800 <cons>
    800003fa:	0a872783          	lw	a5,168(a4)
    800003fe:	0a472703          	lw	a4,164(a4)
    80000402:	f0f70ae3          	beq	a4,a5,80000316 <consoleintr+0x3c>
      cons.e--;
    80000406:	37fd                	addiw	a5,a5,-1
    80000408:	00013717          	auipc	a4,0x13
    8000040c:	4af72023          	sw	a5,1184(a4) # 800138a8 <cons+0xa8>
      consputc(BACKSPACE);
    80000410:	10000513          	li	a0,256
    80000414:	00000097          	auipc	ra,0x0
    80000418:	df0080e7          	jalr	-528(ra) # 80000204 <consputc>
    8000041c:	bded                	j	80000316 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000041e:	ee048ce3          	beqz	s1,80000316 <consoleintr+0x3c>
    80000422:	bf21                	j	8000033a <consoleintr+0x60>
      consputc(c);
    80000424:	4529                	li	a0,10
    80000426:	00000097          	auipc	ra,0x0
    8000042a:	dde080e7          	jalr	-546(ra) # 80000204 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000042e:	00013797          	auipc	a5,0x13
    80000432:	3d278793          	addi	a5,a5,978 # 80013800 <cons>
    80000436:	0a87a703          	lw	a4,168(a5)
    8000043a:	0017069b          	addiw	a3,a4,1
    8000043e:	0006861b          	sext.w	a2,a3
    80000442:	0ad7a423          	sw	a3,168(a5)
    80000446:	07f77713          	andi	a4,a4,127
    8000044a:	97ba                	add	a5,a5,a4
    8000044c:	4729                	li	a4,10
    8000044e:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80000452:	00013797          	auipc	a5,0x13
    80000456:	44c7a923          	sw	a2,1106(a5) # 800138a4 <cons+0xa4>
        wakeup(&cons.r);
    8000045a:	00013517          	auipc	a0,0x13
    8000045e:	44650513          	addi	a0,a0,1094 # 800138a0 <cons+0xa0>
    80000462:	00002097          	auipc	ra,0x2
    80000466:	f86080e7          	jalr	-122(ra) # 800023e8 <wakeup>
    8000046a:	b575                	j	80000316 <consoleintr+0x3c>

000000008000046c <consoleinit>:

void
consoleinit(void)
{
    8000046c:	1141                	addi	sp,sp,-16
    8000046e:	e406                	sd	ra,8(sp)
    80000470:	e022                	sd	s0,0(sp)
    80000472:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000474:	00009597          	auipc	a1,0x9
    80000478:	ca458593          	addi	a1,a1,-860 # 80009118 <userret+0x88>
    8000047c:	00013517          	auipc	a0,0x13
    80000480:	38450513          	addi	a0,a0,900 # 80013800 <cons>
    80000484:	00000097          	auipc	ra,0x0
    80000488:	558080e7          	jalr	1368(ra) # 800009dc <initlock>

  uartinit();
    8000048c:	00000097          	auipc	ra,0x0
    80000490:	340080e7          	jalr	832(ra) # 800007cc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000494:	00021797          	auipc	a5,0x21
    80000498:	bcc78793          	addi	a5,a5,-1076 # 80021060 <devsw>
    8000049c:	00000717          	auipc	a4,0x0
    800004a0:	c5070713          	addi	a4,a4,-944 # 800000ec <consoleread>
    800004a4:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004a6:	00000717          	auipc	a4,0x0
    800004aa:	dac70713          	addi	a4,a4,-596 # 80000252 <consolewrite>
    800004ae:	ef98                	sd	a4,24(a5)
}
    800004b0:	60a2                	ld	ra,8(sp)
    800004b2:	6402                	ld	s0,0(sp)
    800004b4:	0141                	addi	sp,sp,16
    800004b6:	8082                	ret

00000000800004b8 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004b8:	7179                	addi	sp,sp,-48
    800004ba:	f406                	sd	ra,40(sp)
    800004bc:	f022                	sd	s0,32(sp)
    800004be:	ec26                	sd	s1,24(sp)
    800004c0:	e84a                	sd	s2,16(sp)
    800004c2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0x12>
    800004c6:	08054663          	bltz	a0,80000552 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	0000a617          	auipc	a2,0xa
    800004da:	89a60613          	addi	a2,a2,-1894 # 80009d70 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addiw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	addi	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x26>

  if(sign)
    80000502:	00088b63          	beqz	a7,80000518 <printint+0x60>
    buf[i++] = '-';
    80000506:	fe040793          	addi	a5,s0,-32
    8000050a:	973e                	add	a4,a4,a5
    8000050c:	02d00793          	li	a5,45
    80000510:	fef70823          	sb	a5,-16(a4)
    80000514:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000518:	02e05763          	blez	a4,80000546 <printint+0x8e>
    8000051c:	fd040793          	addi	a5,s0,-48
    80000520:	00e784b3          	add	s1,a5,a4
    80000524:	fff78913          	addi	s2,a5,-1
    80000528:	993a                	add	s2,s2,a4
    8000052a:	377d                	addiw	a4,a4,-1
    8000052c:	1702                	slli	a4,a4,0x20
    8000052e:	9301                	srli	a4,a4,0x20
    80000530:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000534:	fff4c503          	lbu	a0,-1(s1)
    80000538:	00000097          	auipc	ra,0x0
    8000053c:	ccc080e7          	jalr	-820(ra) # 80000204 <consputc>
  while(--i >= 0)
    80000540:	14fd                	addi	s1,s1,-1
    80000542:	ff2499e3          	bne	s1,s2,80000534 <printint+0x7c>
}
    80000546:	70a2                	ld	ra,40(sp)
    80000548:	7402                	ld	s0,32(sp)
    8000054a:	64e2                	ld	s1,24(sp)
    8000054c:	6942                	ld	s2,16(sp)
    8000054e:	6145                	addi	sp,sp,48
    80000550:	8082                	ret
    x = -xx;
    80000552:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000556:	4885                	li	a7,1
    x = -xx;
    80000558:	bf9d                	j	800004ce <printint+0x16>

000000008000055a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000055a:	1101                	addi	sp,sp,-32
    8000055c:	ec06                	sd	ra,24(sp)
    8000055e:	e822                	sd	s0,16(sp)
    80000560:	e426                	sd	s1,8(sp)
    80000562:	1000                	addi	s0,sp,32
    80000564:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000566:	00013797          	auipc	a5,0x13
    8000056a:	3607a523          	sw	zero,874(a5) # 800138d0 <pr+0x20>
  printf("PANIC: ");
    8000056e:	00009517          	auipc	a0,0x9
    80000572:	bb250513          	addi	a0,a0,-1102 # 80009120 <userret+0x90>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	03e080e7          	jalr	62(ra) # 800005b4 <printf>
  printf(s);
    8000057e:	8526                	mv	a0,s1
    80000580:	00000097          	auipc	ra,0x0
    80000584:	034080e7          	jalr	52(ra) # 800005b4 <printf>
  printf("\n");
    80000588:	00009517          	auipc	a0,0x9
    8000058c:	d0850513          	addi	a0,a0,-760 # 80009290 <userret+0x200>
    80000590:	00000097          	auipc	ra,0x0
    80000594:	024080e7          	jalr	36(ra) # 800005b4 <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000598:	00009517          	auipc	a0,0x9
    8000059c:	b9050513          	addi	a0,a0,-1136 # 80009128 <userret+0x98>
    800005a0:	00000097          	auipc	ra,0x0
    800005a4:	014080e7          	jalr	20(ra) # 800005b4 <printf>
  panicked = 1; // freeze other CPUs
    800005a8:	4785                	li	a5,1
    800005aa:	00029717          	auipc	a4,0x29
    800005ae:	daf72b23          	sw	a5,-586(a4) # 80029360 <panicked>
  for(;;)
    800005b2:	a001                	j	800005b2 <panic+0x58>

00000000800005b4 <printf>:
{
    800005b4:	7131                	addi	sp,sp,-192
    800005b6:	fc86                	sd	ra,120(sp)
    800005b8:	f8a2                	sd	s0,112(sp)
    800005ba:	f4a6                	sd	s1,104(sp)
    800005bc:	f0ca                	sd	s2,96(sp)
    800005be:	ecce                	sd	s3,88(sp)
    800005c0:	e8d2                	sd	s4,80(sp)
    800005c2:	e4d6                	sd	s5,72(sp)
    800005c4:	e0da                	sd	s6,64(sp)
    800005c6:	fc5e                	sd	s7,56(sp)
    800005c8:	f862                	sd	s8,48(sp)
    800005ca:	f466                	sd	s9,40(sp)
    800005cc:	f06a                	sd	s10,32(sp)
    800005ce:	ec6e                	sd	s11,24(sp)
    800005d0:	0100                	addi	s0,sp,128
    800005d2:	8a2a                	mv	s4,a0
    800005d4:	e40c                	sd	a1,8(s0)
    800005d6:	e810                	sd	a2,16(s0)
    800005d8:	ec14                	sd	a3,24(s0)
    800005da:	f018                	sd	a4,32(s0)
    800005dc:	f41c                	sd	a5,40(s0)
    800005de:	03043823          	sd	a6,48(s0)
    800005e2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005e6:	00013d97          	auipc	s11,0x13
    800005ea:	2eadad83          	lw	s11,746(s11) # 800138d0 <pr+0x20>
  if(locking)
    800005ee:	020d9b63          	bnez	s11,80000624 <printf+0x70>
  if (fmt == 0)
    800005f2:	040a0263          	beqz	s4,80000636 <printf+0x82>
  va_start(ap, fmt);
    800005f6:	00840793          	addi	a5,s0,8
    800005fa:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005fe:	000a4503          	lbu	a0,0(s4)
    80000602:	16050263          	beqz	a0,80000766 <printf+0x1b2>
    80000606:	4481                	li	s1,0
    if(c != '%'){
    80000608:	02500a93          	li	s5,37
    switch(c){
    8000060c:	07000b13          	li	s6,112
  consputc('x');
    80000610:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000612:	00009b97          	auipc	s7,0x9
    80000616:	75eb8b93          	addi	s7,s7,1886 # 80009d70 <digits>
    switch(c){
    8000061a:	07300c93          	li	s9,115
    8000061e:	06400c13          	li	s8,100
    80000622:	a82d                	j	8000065c <printf+0xa8>
    acquire(&pr.lock);
    80000624:	00013517          	auipc	a0,0x13
    80000628:	28c50513          	addi	a0,a0,652 # 800138b0 <pr>
    8000062c:	00000097          	auipc	ra,0x0
    80000630:	484080e7          	jalr	1156(ra) # 80000ab0 <acquire>
    80000634:	bf7d                	j	800005f2 <printf+0x3e>
    panic("null fmt");
    80000636:	00009517          	auipc	a0,0x9
    8000063a:	bca50513          	addi	a0,a0,-1078 # 80009200 <userret+0x170>
    8000063e:	00000097          	auipc	ra,0x0
    80000642:	f1c080e7          	jalr	-228(ra) # 8000055a <panic>
      consputc(c);
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	bbe080e7          	jalr	-1090(ra) # 80000204 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000064e:	2485                	addiw	s1,s1,1
    80000650:	009a07b3          	add	a5,s4,s1
    80000654:	0007c503          	lbu	a0,0(a5)
    80000658:	10050763          	beqz	a0,80000766 <printf+0x1b2>
    if(c != '%'){
    8000065c:	ff5515e3          	bne	a0,s5,80000646 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000660:	2485                	addiw	s1,s1,1
    80000662:	009a07b3          	add	a5,s4,s1
    80000666:	0007c783          	lbu	a5,0(a5)
    8000066a:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000066e:	cfe5                	beqz	a5,80000766 <printf+0x1b2>
    switch(c){
    80000670:	05678a63          	beq	a5,s6,800006c4 <printf+0x110>
    80000674:	02fb7663          	bgeu	s6,a5,800006a0 <printf+0xec>
    80000678:	09978963          	beq	a5,s9,8000070a <printf+0x156>
    8000067c:	07800713          	li	a4,120
    80000680:	0ce79863          	bne	a5,a4,80000750 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	4605                	li	a2,1
    80000692:	85ea                	mv	a1,s10
    80000694:	4388                	lw	a0,0(a5)
    80000696:	00000097          	auipc	ra,0x0
    8000069a:	e22080e7          	jalr	-478(ra) # 800004b8 <printint>
      break;
    8000069e:	bf45                	j	8000064e <printf+0x9a>
    switch(c){
    800006a0:	0b578263          	beq	a5,s5,80000744 <printf+0x190>
    800006a4:	0b879663          	bne	a5,s8,80000750 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    800006a8:	f8843783          	ld	a5,-120(s0)
    800006ac:	00878713          	addi	a4,a5,8
    800006b0:	f8e43423          	sd	a4,-120(s0)
    800006b4:	4605                	li	a2,1
    800006b6:	45a9                	li	a1,10
    800006b8:	4388                	lw	a0,0(a5)
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	dfe080e7          	jalr	-514(ra) # 800004b8 <printint>
      break;
    800006c2:	b771                	j	8000064e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006c4:	f8843783          	ld	a5,-120(s0)
    800006c8:	00878713          	addi	a4,a5,8
    800006cc:	f8e43423          	sd	a4,-120(s0)
    800006d0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006d4:	03000513          	li	a0,48
    800006d8:	00000097          	auipc	ra,0x0
    800006dc:	b2c080e7          	jalr	-1236(ra) # 80000204 <consputc>
  consputc('x');
    800006e0:	07800513          	li	a0,120
    800006e4:	00000097          	auipc	ra,0x0
    800006e8:	b20080e7          	jalr	-1248(ra) # 80000204 <consputc>
    800006ec:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ee:	03c9d793          	srli	a5,s3,0x3c
    800006f2:	97de                	add	a5,a5,s7
    800006f4:	0007c503          	lbu	a0,0(a5)
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	b0c080e7          	jalr	-1268(ra) # 80000204 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000700:	0992                	slli	s3,s3,0x4
    80000702:	397d                	addiw	s2,s2,-1
    80000704:	fe0915e3          	bnez	s2,800006ee <printf+0x13a>
    80000708:	b799                	j	8000064e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    8000070a:	f8843783          	ld	a5,-120(s0)
    8000070e:	00878713          	addi	a4,a5,8
    80000712:	f8e43423          	sd	a4,-120(s0)
    80000716:	0007b903          	ld	s2,0(a5)
    8000071a:	00090e63          	beqz	s2,80000736 <printf+0x182>
      for(; *s; s++)
    8000071e:	00094503          	lbu	a0,0(s2)
    80000722:	d515                	beqz	a0,8000064e <printf+0x9a>
        consputc(*s);
    80000724:	00000097          	auipc	ra,0x0
    80000728:	ae0080e7          	jalr	-1312(ra) # 80000204 <consputc>
      for(; *s; s++)
    8000072c:	0905                	addi	s2,s2,1
    8000072e:	00094503          	lbu	a0,0(s2)
    80000732:	f96d                	bnez	a0,80000724 <printf+0x170>
    80000734:	bf29                	j	8000064e <printf+0x9a>
        s = "(null)";
    80000736:	00009917          	auipc	s2,0x9
    8000073a:	ac290913          	addi	s2,s2,-1342 # 800091f8 <userret+0x168>
      for(; *s; s++)
    8000073e:	02800513          	li	a0,40
    80000742:	b7cd                	j	80000724 <printf+0x170>
      consputc('%');
    80000744:	8556                	mv	a0,s5
    80000746:	00000097          	auipc	ra,0x0
    8000074a:	abe080e7          	jalr	-1346(ra) # 80000204 <consputc>
      break;
    8000074e:	b701                	j	8000064e <printf+0x9a>
      consputc('%');
    80000750:	8556                	mv	a0,s5
    80000752:	00000097          	auipc	ra,0x0
    80000756:	ab2080e7          	jalr	-1358(ra) # 80000204 <consputc>
      consputc(c);
    8000075a:	854a                	mv	a0,s2
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	aa8080e7          	jalr	-1368(ra) # 80000204 <consputc>
      break;
    80000764:	b5ed                	j	8000064e <printf+0x9a>
  if(locking)
    80000766:	020d9163          	bnez	s11,80000788 <printf+0x1d4>
}
    8000076a:	70e6                	ld	ra,120(sp)
    8000076c:	7446                	ld	s0,112(sp)
    8000076e:	74a6                	ld	s1,104(sp)
    80000770:	7906                	ld	s2,96(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7ca2                	ld	s9,40(sp)
    80000780:	7d02                	ld	s10,32(sp)
    80000782:	6de2                	ld	s11,24(sp)
    80000784:	6129                	addi	sp,sp,192
    80000786:	8082                	ret
    release(&pr.lock);
    80000788:	00013517          	auipc	a0,0x13
    8000078c:	12850513          	addi	a0,a0,296 # 800138b0 <pr>
    80000790:	00000097          	auipc	ra,0x0
    80000794:	3f0080e7          	jalr	1008(ra) # 80000b80 <release>
}
    80000798:	bfc9                	j	8000076a <printf+0x1b6>

000000008000079a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000079a:	1101                	addi	sp,sp,-32
    8000079c:	ec06                	sd	ra,24(sp)
    8000079e:	e822                	sd	s0,16(sp)
    800007a0:	e426                	sd	s1,8(sp)
    800007a2:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007a4:	00013497          	auipc	s1,0x13
    800007a8:	10c48493          	addi	s1,s1,268 # 800138b0 <pr>
    800007ac:	00009597          	auipc	a1,0x9
    800007b0:	a6458593          	addi	a1,a1,-1436 # 80009210 <userret+0x180>
    800007b4:	8526                	mv	a0,s1
    800007b6:	00000097          	auipc	ra,0x0
    800007ba:	226080e7          	jalr	550(ra) # 800009dc <initlock>
  pr.locking = 1;
    800007be:	4785                	li	a5,1
    800007c0:	d09c                	sw	a5,32(s1)
}
    800007c2:	60e2                	ld	ra,24(sp)
    800007c4:	6442                	ld	s0,16(sp)
    800007c6:	64a2                	ld	s1,8(sp)
    800007c8:	6105                	addi	sp,sp,32
    800007ca:	8082                	ret

00000000800007cc <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    800007cc:	1141                	addi	sp,sp,-16
    800007ce:	e422                	sd	s0,8(sp)
    800007d0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007d2:	100007b7          	lui	a5,0x10000
    800007d6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800007da:	f8000713          	li	a4,-128
    800007de:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007e2:	470d                	li	a4,3
    800007e4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007e8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800007ec:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800007f0:	471d                	li	a4,7
    800007f2:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800007f6:	4705                	li	a4,1
    800007f8:	00e780a3          	sb	a4,1(a5)
}
    800007fc:	6422                	ld	s0,8(sp)
    800007fe:	0141                	addi	sp,sp,16
    80000800:	8082                	ret

0000000080000802 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    80000802:	1141                	addi	sp,sp,-16
    80000804:	e422                	sd	s0,8(sp)
    80000806:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    80000808:	10000737          	lui	a4,0x10000
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0ff7f793          	andi	a5,a5,255
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dbf5                	beqz	a5,8000080c <uartputc+0xa>
    ;
  WriteReg(THR, c);
    8000081a:	0ff57513          	andi	a0,a0,255
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    80000826:	6422                	ld	s0,8(sp)
    80000828:	0141                	addi	sp,sp,16
    8000082a:	8082                	ret

000000008000082c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e422                	sd	s0,8(sp)
    80000830:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000832:	100007b7          	lui	a5,0x10000
    80000836:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000083a:	8b85                	andi	a5,a5,1
    8000083c:	cb91                	beqz	a5,80000850 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000083e:	100007b7          	lui	a5,0x10000
    80000842:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000846:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000084a:	6422                	ld	s0,8(sp)
    8000084c:	0141                	addi	sp,sp,16
    8000084e:	8082                	ret
    return -1;
    80000850:	557d                	li	a0,-1
    80000852:	bfe5                	j	8000084a <uartgetc+0x1e>

0000000080000854 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000085e:	54fd                	li	s1,-1
    int c = uartgetc();
    80000860:	00000097          	auipc	ra,0x0
    80000864:	fcc080e7          	jalr	-52(ra) # 8000082c <uartgetc>
    if(c == -1)
    80000868:	00950763          	beq	a0,s1,80000876 <uartintr+0x22>
      break;
    consoleintr(c);
    8000086c:	00000097          	auipc	ra,0x0
    80000870:	a6e080e7          	jalr	-1426(ra) # 800002da <consoleintr>
  while(1){
    80000874:	b7f5                	j	80000860 <uartintr+0xc>
  }
}
    80000876:	60e2                	ld	ra,24(sp)
    80000878:	6442                	ld	s0,16(sp)
    8000087a:	64a2                	ld	s1,8(sp)
    8000087c:	6105                	addi	sp,sp,32
    8000087e:	8082                	ret

0000000080000880 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000880:	1101                	addi	sp,sp,-32
    80000882:	ec06                	sd	ra,24(sp)
    80000884:	e822                	sd	s0,16(sp)
    80000886:	e426                	sd	s1,8(sp)
    80000888:	e04a                	sd	s2,0(sp)
    8000088a:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    8000088c:	03451793          	slli	a5,a0,0x34
    80000890:	ebb9                	bnez	a5,800008e6 <kfree+0x66>
    80000892:	84aa                	mv	s1,a0
    80000894:	00029797          	auipc	a5,0x29
    80000898:	b1878793          	addi	a5,a5,-1256 # 800293ac <end>
    8000089c:	04f56563          	bltu	a0,a5,800008e6 <kfree+0x66>
    800008a0:	47c5                	li	a5,17
    800008a2:	07ee                	slli	a5,a5,0x1b
    800008a4:	04f57163          	bgeu	a0,a5,800008e6 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800008a8:	6605                	lui	a2,0x1
    800008aa:	4585                	li	a1,1
    800008ac:	00000097          	auipc	ra,0x0
    800008b0:	4d2080e7          	jalr	1234(ra) # 80000d7e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800008b4:	00013917          	auipc	s2,0x13
    800008b8:	02490913          	addi	s2,s2,36 # 800138d8 <kmem>
    800008bc:	854a                	mv	a0,s2
    800008be:	00000097          	auipc	ra,0x0
    800008c2:	1f2080e7          	jalr	498(ra) # 80000ab0 <acquire>
  r->next = kmem.freelist;
    800008c6:	02093783          	ld	a5,32(s2)
    800008ca:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800008cc:	02993023          	sd	s1,32(s2)
  release(&kmem.lock);
    800008d0:	854a                	mv	a0,s2
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	2ae080e7          	jalr	686(ra) # 80000b80 <release>
}
    800008da:	60e2                	ld	ra,24(sp)
    800008dc:	6442                	ld	s0,16(sp)
    800008de:	64a2                	ld	s1,8(sp)
    800008e0:	6902                	ld	s2,0(sp)
    800008e2:	6105                	addi	sp,sp,32
    800008e4:	8082                	ret
    panic("kfree");
    800008e6:	00009517          	auipc	a0,0x9
    800008ea:	93250513          	addi	a0,a0,-1742 # 80009218 <userret+0x188>
    800008ee:	00000097          	auipc	ra,0x0
    800008f2:	c6c080e7          	jalr	-916(ra) # 8000055a <panic>

00000000800008f6 <freerange>:
{
    800008f6:	7179                	addi	sp,sp,-48
    800008f8:	f406                	sd	ra,40(sp)
    800008fa:	f022                	sd	s0,32(sp)
    800008fc:	ec26                	sd	s1,24(sp)
    800008fe:	e84a                	sd	s2,16(sp)
    80000900:	e44e                	sd	s3,8(sp)
    80000902:	e052                	sd	s4,0(sp)
    80000904:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000906:	6785                	lui	a5,0x1
    80000908:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    8000090c:	94aa                	add	s1,s1,a0
    8000090e:	757d                	lui	a0,0xfffff
    80000910:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000912:	94be                	add	s1,s1,a5
    80000914:	0095ee63          	bltu	a1,s1,80000930 <freerange+0x3a>
    80000918:	892e                	mv	s2,a1
    kfree(p);
    8000091a:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000091c:	6985                	lui	s3,0x1
    kfree(p);
    8000091e:	01448533          	add	a0,s1,s4
    80000922:	00000097          	auipc	ra,0x0
    80000926:	f5e080e7          	jalr	-162(ra) # 80000880 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000092a:	94ce                	add	s1,s1,s3
    8000092c:	fe9979e3          	bgeu	s2,s1,8000091e <freerange+0x28>
}
    80000930:	70a2                	ld	ra,40(sp)
    80000932:	7402                	ld	s0,32(sp)
    80000934:	64e2                	ld	s1,24(sp)
    80000936:	6942                	ld	s2,16(sp)
    80000938:	69a2                	ld	s3,8(sp)
    8000093a:	6a02                	ld	s4,0(sp)
    8000093c:	6145                	addi	sp,sp,48
    8000093e:	8082                	ret

0000000080000940 <kinit>:
{
    80000940:	1141                	addi	sp,sp,-16
    80000942:	e406                	sd	ra,8(sp)
    80000944:	e022                	sd	s0,0(sp)
    80000946:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000948:	00009597          	auipc	a1,0x9
    8000094c:	8d858593          	addi	a1,a1,-1832 # 80009220 <userret+0x190>
    80000950:	00013517          	auipc	a0,0x13
    80000954:	f8850513          	addi	a0,a0,-120 # 800138d8 <kmem>
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	084080e7          	jalr	132(ra) # 800009dc <initlock>
  freerange(end, (void*)PHYSTOP);
    80000960:	45c5                	li	a1,17
    80000962:	05ee                	slli	a1,a1,0x1b
    80000964:	00029517          	auipc	a0,0x29
    80000968:	a4850513          	addi	a0,a0,-1464 # 800293ac <end>
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	f8a080e7          	jalr	-118(ra) # 800008f6 <freerange>
}
    80000974:	60a2                	ld	ra,8(sp)
    80000976:	6402                	ld	s0,0(sp)
    80000978:	0141                	addi	sp,sp,16
    8000097a:	8082                	ret

000000008000097c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    8000097c:	1101                	addi	sp,sp,-32
    8000097e:	ec06                	sd	ra,24(sp)
    80000980:	e822                	sd	s0,16(sp)
    80000982:	e426                	sd	s1,8(sp)
    80000984:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000986:	00013497          	auipc	s1,0x13
    8000098a:	f5248493          	addi	s1,s1,-174 # 800138d8 <kmem>
    8000098e:	8526                	mv	a0,s1
    80000990:	00000097          	auipc	ra,0x0
    80000994:	120080e7          	jalr	288(ra) # 80000ab0 <acquire>
  r = kmem.freelist;
    80000998:	7084                	ld	s1,32(s1)
  if(r)
    8000099a:	c885                	beqz	s1,800009ca <kalloc+0x4e>
    kmem.freelist = r->next;
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	00013517          	auipc	a0,0x13
    800009a2:	f3a50513          	addi	a0,a0,-198 # 800138d8 <kmem>
    800009a6:	f11c                	sd	a5,32(a0)
  release(&kmem.lock);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	1d8080e7          	jalr	472(ra) # 80000b80 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    800009b0:	6605                	lui	a2,0x1
    800009b2:	4595                	li	a1,5
    800009b4:	8526                	mv	a0,s1
    800009b6:	00000097          	auipc	ra,0x0
    800009ba:	3c8080e7          	jalr	968(ra) # 80000d7e <memset>
  return (void*)r;
}
    800009be:	8526                	mv	a0,s1
    800009c0:	60e2                	ld	ra,24(sp)
    800009c2:	6442                	ld	s0,16(sp)
    800009c4:	64a2                	ld	s1,8(sp)
    800009c6:	6105                	addi	sp,sp,32
    800009c8:	8082                	ret
  release(&kmem.lock);
    800009ca:	00013517          	auipc	a0,0x13
    800009ce:	f0e50513          	addi	a0,a0,-242 # 800138d8 <kmem>
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	1ae080e7          	jalr	430(ra) # 80000b80 <release>
  if(r)
    800009da:	b7d5                	j	800009be <kalloc+0x42>

00000000800009dc <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    800009dc:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800009de:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800009e2:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    800009e6:	00052e23          	sw	zero,28(a0)
  lk->n = 0;
    800009ea:	00052c23          	sw	zero,24(a0)
  if(nlock >= NLOCK)
    800009ee:	00029797          	auipc	a5,0x29
    800009f2:	9767a783          	lw	a5,-1674(a5) # 80029364 <nlock>
    800009f6:	3e700713          	li	a4,999
    800009fa:	02f74063          	blt	a4,a5,80000a1a <initlock+0x3e>
    panic("initlock");
  locks[nlock] = lk;
    800009fe:	00379693          	slli	a3,a5,0x3
    80000a02:	00013717          	auipc	a4,0x13
    80000a06:	efe70713          	addi	a4,a4,-258 # 80013900 <locks>
    80000a0a:	9736                	add	a4,a4,a3
    80000a0c:	e308                	sd	a0,0(a4)
  nlock++;
    80000a0e:	2785                	addiw	a5,a5,1
    80000a10:	00029717          	auipc	a4,0x29
    80000a14:	94f72a23          	sw	a5,-1708(a4) # 80029364 <nlock>
    80000a18:	8082                	ret
{
    80000a1a:	1141                	addi	sp,sp,-16
    80000a1c:	e406                	sd	ra,8(sp)
    80000a1e:	e022                	sd	s0,0(sp)
    80000a20:	0800                	addi	s0,sp,16
    panic("initlock");
    80000a22:	00009517          	auipc	a0,0x9
    80000a26:	80650513          	addi	a0,a0,-2042 # 80009228 <userret+0x198>
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	b30080e7          	jalr	-1232(ra) # 8000055a <panic>

0000000080000a32 <holding>:
// Must be called with interrupts off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000a32:	411c                	lw	a5,0(a0)
    80000a34:	e399                	bnez	a5,80000a3a <holding+0x8>
    80000a36:	4501                	li	a0,0
  return r;
}
    80000a38:	8082                	ret
{
    80000a3a:	1101                	addi	sp,sp,-32
    80000a3c:	ec06                	sd	ra,24(sp)
    80000a3e:	e822                	sd	s0,16(sp)
    80000a40:	e426                	sd	s1,8(sp)
    80000a42:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000a44:	6904                	ld	s1,16(a0)
    80000a46:	00001097          	auipc	ra,0x1
    80000a4a:	044080e7          	jalr	68(ra) # 80001a8a <mycpu>
    80000a4e:	40a48533          	sub	a0,s1,a0
    80000a52:	00153513          	seqz	a0,a0
}
    80000a56:	60e2                	ld	ra,24(sp)
    80000a58:	6442                	ld	s0,16(sp)
    80000a5a:	64a2                	ld	s1,8(sp)
    80000a5c:	6105                	addi	sp,sp,32
    80000a5e:	8082                	ret

0000000080000a60 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000a60:	1101                	addi	sp,sp,-32
    80000a62:	ec06                	sd	ra,24(sp)
    80000a64:	e822                	sd	s0,16(sp)
    80000a66:	e426                	sd	s1,8(sp)
    80000a68:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a6a:	100024f3          	csrr	s1,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000a6e:	8889                	andi	s1,s1,2
  int old = intr_get();
  if(old)
    80000a70:	c491                	beqz	s1,80000a7c <push_off+0x1c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a72:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000a76:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a78:	10079073          	csrw	sstatus,a5
    intr_off();
  if(mycpu()->noff == 0)
    80000a7c:	00001097          	auipc	ra,0x1
    80000a80:	00e080e7          	jalr	14(ra) # 80001a8a <mycpu>
    80000a84:	5d3c                	lw	a5,120(a0)
    80000a86:	cf89                	beqz	a5,80000aa0 <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000a88:	00001097          	auipc	ra,0x1
    80000a8c:	002080e7          	jalr	2(ra) # 80001a8a <mycpu>
    80000a90:	5d3c                	lw	a5,120(a0)
    80000a92:	2785                	addiw	a5,a5,1
    80000a94:	dd3c                	sw	a5,120(a0)
}
    80000a96:	60e2                	ld	ra,24(sp)
    80000a98:	6442                	ld	s0,16(sp)
    80000a9a:	64a2                	ld	s1,8(sp)
    80000a9c:	6105                	addi	sp,sp,32
    80000a9e:	8082                	ret
    mycpu()->intena = old;
    80000aa0:	00001097          	auipc	ra,0x1
    80000aa4:	fea080e7          	jalr	-22(ra) # 80001a8a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000aa8:	009034b3          	snez	s1,s1
    80000aac:	dd64                	sw	s1,124(a0)
    80000aae:	bfe9                	j	80000a88 <push_off+0x28>

0000000080000ab0 <acquire>:
{
    80000ab0:	1101                	addi	sp,sp,-32
    80000ab2:	ec06                	sd	ra,24(sp)
    80000ab4:	e822                	sd	s0,16(sp)
    80000ab6:	e426                	sd	s1,8(sp)
    80000ab8:	1000                	addi	s0,sp,32
    80000aba:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	fa4080e7          	jalr	-92(ra) # 80000a60 <push_off>
  if(holding(lk))
    80000ac4:	8526                	mv	a0,s1
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	f6c080e7          	jalr	-148(ra) # 80000a32 <holding>
    80000ace:	e911                	bnez	a0,80000ae2 <acquire+0x32>
  __sync_fetch_and_add(&(lk->n), 1);
    80000ad0:	4785                	li	a5,1
    80000ad2:	01848713          	addi	a4,s1,24
    80000ad6:	0f50000f          	fence	iorw,ow
    80000ada:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000ade:	4705                	li	a4,1
    80000ae0:	a839                	j	80000afe <acquire+0x4e>
    panic("acquire");
    80000ae2:	00008517          	auipc	a0,0x8
    80000ae6:	75650513          	addi	a0,a0,1878 # 80009238 <userret+0x1a8>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	a70080e7          	jalr	-1424(ra) # 8000055a <panic>
     __sync_fetch_and_add(&lk->nts, 1);
    80000af2:	01c48793          	addi	a5,s1,28
    80000af6:	0f50000f          	fence	iorw,ow
    80000afa:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000afe:	87ba                	mv	a5,a4
    80000b00:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b04:	2781                	sext.w	a5,a5
    80000b06:	f7f5                	bnez	a5,80000af2 <acquire+0x42>
  __sync_synchronize();
    80000b08:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b0c:	00001097          	auipc	ra,0x1
    80000b10:	f7e080e7          	jalr	-130(ra) # 80001a8a <mycpu>
    80000b14:	e888                	sd	a0,16(s1)
}
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret

0000000080000b20 <pop_off>:

void
pop_off(void)
{
    80000b20:	1141                	addi	sp,sp,-16
    80000b22:	e406                	sd	ra,8(sp)
    80000b24:	e022                	sd	s0,0(sp)
    80000b26:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b28:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000b2c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000b2e:	eb8d                	bnez	a5,80000b60 <pop_off+0x40>
    panic("pop_off - interruptible");
  struct cpu *c = mycpu();
    80000b30:	00001097          	auipc	ra,0x1
    80000b34:	f5a080e7          	jalr	-166(ra) # 80001a8a <mycpu>
  if(c->noff < 1)
    80000b38:	5d3c                	lw	a5,120(a0)
    80000b3a:	02f05b63          	blez	a5,80000b70 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000b3e:	37fd                	addiw	a5,a5,-1
    80000b40:	0007871b          	sext.w	a4,a5
    80000b44:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000b46:	eb09                	bnez	a4,80000b58 <pop_off+0x38>
    80000b48:	5d7c                	lw	a5,124(a0)
    80000b4a:	c799                	beqz	a5,80000b58 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b4c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000b50:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b54:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000b58:	60a2                	ld	ra,8(sp)
    80000b5a:	6402                	ld	s0,0(sp)
    80000b5c:	0141                	addi	sp,sp,16
    80000b5e:	8082                	ret
    panic("pop_off - interruptible");
    80000b60:	00008517          	auipc	a0,0x8
    80000b64:	6e050513          	addi	a0,a0,1760 # 80009240 <userret+0x1b0>
    80000b68:	00000097          	auipc	ra,0x0
    80000b6c:	9f2080e7          	jalr	-1550(ra) # 8000055a <panic>
    panic("pop_off");
    80000b70:	00008517          	auipc	a0,0x8
    80000b74:	6e850513          	addi	a0,a0,1768 # 80009258 <userret+0x1c8>
    80000b78:	00000097          	auipc	ra,0x0
    80000b7c:	9e2080e7          	jalr	-1566(ra) # 8000055a <panic>

0000000080000b80 <release>:
{
    80000b80:	1101                	addi	sp,sp,-32
    80000b82:	ec06                	sd	ra,24(sp)
    80000b84:	e822                	sd	s0,16(sp)
    80000b86:	e426                	sd	s1,8(sp)
    80000b88:	1000                	addi	s0,sp,32
    80000b8a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b8c:	00000097          	auipc	ra,0x0
    80000b90:	ea6080e7          	jalr	-346(ra) # 80000a32 <holding>
    80000b94:	c115                	beqz	a0,80000bb8 <release+0x38>
  lk->cpu = 0;
    80000b96:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b9a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b9e:	0f50000f          	fence	iorw,ow
    80000ba2:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ba6:	00000097          	auipc	ra,0x0
    80000baa:	f7a080e7          	jalr	-134(ra) # 80000b20 <pop_off>
}
    80000bae:	60e2                	ld	ra,24(sp)
    80000bb0:	6442                	ld	s0,16(sp)
    80000bb2:	64a2                	ld	s1,8(sp)
    80000bb4:	6105                	addi	sp,sp,32
    80000bb6:	8082                	ret
    panic("release");
    80000bb8:	00008517          	auipc	a0,0x8
    80000bbc:	6a850513          	addi	a0,a0,1704 # 80009260 <userret+0x1d0>
    80000bc0:	00000097          	auipc	ra,0x0
    80000bc4:	99a080e7          	jalr	-1638(ra) # 8000055a <panic>

0000000080000bc8 <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000bc8:	4d14                	lw	a3,24(a0)
    80000bca:	e291                	bnez	a3,80000bce <print_lock+0x6>
    80000bcc:	8082                	ret
{
    80000bce:	1141                	addi	sp,sp,-16
    80000bd0:	e406                	sd	ra,8(sp)
    80000bd2:	e022                	sd	s0,0(sp)
    80000bd4:	0800                	addi	s0,sp,16
    printf("lock: %s: #test-and-set %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000bd6:	4d50                	lw	a2,28(a0)
    80000bd8:	650c                	ld	a1,8(a0)
    80000bda:	00008517          	auipc	a0,0x8
    80000bde:	68e50513          	addi	a0,a0,1678 # 80009268 <userret+0x1d8>
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	9d2080e7          	jalr	-1582(ra) # 800005b4 <printf>
}
    80000bea:	60a2                	ld	ra,8(sp)
    80000bec:	6402                	ld	s0,0(sp)
    80000bee:	0141                	addi	sp,sp,16
    80000bf0:	8082                	ret

0000000080000bf2 <sys_ntas>:

uint64
sys_ntas(void)
{
    80000bf2:	711d                	addi	sp,sp,-96
    80000bf4:	ec86                	sd	ra,88(sp)
    80000bf6:	e8a2                	sd	s0,80(sp)
    80000bf8:	e4a6                	sd	s1,72(sp)
    80000bfa:	e0ca                	sd	s2,64(sp)
    80000bfc:	fc4e                	sd	s3,56(sp)
    80000bfe:	f852                	sd	s4,48(sp)
    80000c00:	f456                	sd	s5,40(sp)
    80000c02:	f05a                	sd	s6,32(sp)
    80000c04:	ec5e                	sd	s7,24(sp)
    80000c06:	e862                	sd	s8,16(sp)
    80000c08:	1080                	addi	s0,sp,96
  int zero = 0;
    80000c0a:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000c0e:	fac40593          	addi	a1,s0,-84
    80000c12:	4501                	li	a0,0
    80000c14:	00002097          	auipc	ra,0x2
    80000c18:	fba080e7          	jalr	-70(ra) # 80002bce <argint>
    80000c1c:	14054d63          	bltz	a0,80000d76 <sys_ntas+0x184>
    return -1;
  }
  if(zero == 0) {
    80000c20:	fac42783          	lw	a5,-84(s0)
    80000c24:	e78d                	bnez	a5,80000c4e <sys_ntas+0x5c>
    80000c26:	00013797          	auipc	a5,0x13
    80000c2a:	cda78793          	addi	a5,a5,-806 # 80013900 <locks>
    80000c2e:	00015697          	auipc	a3,0x15
    80000c32:	c1268693          	addi	a3,a3,-1006 # 80015840 <pid_lock>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000c36:	6398                	ld	a4,0(a5)
    80000c38:	14070163          	beqz	a4,80000d7a <sys_ntas+0x188>
        break;
      locks[i]->nts = 0;
    80000c3c:	00072e23          	sw	zero,28(a4)
      locks[i]->n = 0;
    80000c40:	00072c23          	sw	zero,24(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000c44:	07a1                	addi	a5,a5,8
    80000c46:	fed798e3          	bne	a5,a3,80000c36 <sys_ntas+0x44>
    }
    return 0;
    80000c4a:	4501                	li	a0,0
    80000c4c:	aa09                	j	80000d5e <sys_ntas+0x16c>
  }

  printf("=== lock kmem/bcache stats\n");
    80000c4e:	00008517          	auipc	a0,0x8
    80000c52:	64a50513          	addi	a0,a0,1610 # 80009298 <userret+0x208>
    80000c56:	00000097          	auipc	ra,0x0
    80000c5a:	95e080e7          	jalr	-1698(ra) # 800005b4 <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000c5e:	00013b17          	auipc	s6,0x13
    80000c62:	ca2b0b13          	addi	s6,s6,-862 # 80013900 <locks>
    80000c66:	00015b97          	auipc	s7,0x15
    80000c6a:	bdab8b93          	addi	s7,s7,-1062 # 80015840 <pid_lock>
  printf("=== lock kmem/bcache stats\n");
    80000c6e:	84da                	mv	s1,s6
  int tot = 0;
    80000c70:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000c72:	00008a17          	auipc	s4,0x8
    80000c76:	646a0a13          	addi	s4,s4,1606 # 800092b8 <userret+0x228>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000c7a:	00008c17          	auipc	s8,0x8
    80000c7e:	5a6c0c13          	addi	s8,s8,1446 # 80009220 <userret+0x190>
    80000c82:	a829                	j	80000c9c <sys_ntas+0xaa>
      tot += locks[i]->nts;
    80000c84:	00093503          	ld	a0,0(s2)
    80000c88:	4d5c                	lw	a5,28(a0)
    80000c8a:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000c8e:	00000097          	auipc	ra,0x0
    80000c92:	f3a080e7          	jalr	-198(ra) # 80000bc8 <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80000c96:	04a1                	addi	s1,s1,8
    80000c98:	05748763          	beq	s1,s7,80000ce6 <sys_ntas+0xf4>
    if(locks[i] == 0)
    80000c9c:	8926                	mv	s2,s1
    80000c9e:	609c                	ld	a5,0(s1)
    80000ca0:	c3b9                	beqz	a5,80000ce6 <sys_ntas+0xf4>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000ca2:	0087ba83          	ld	s5,8(a5)
    80000ca6:	8552                	mv	a0,s4
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	25e080e7          	jalr	606(ra) # 80000f06 <strlen>
    80000cb0:	0005061b          	sext.w	a2,a0
    80000cb4:	85d2                	mv	a1,s4
    80000cb6:	8556                	mv	a0,s5
    80000cb8:	00000097          	auipc	ra,0x0
    80000cbc:	1a2080e7          	jalr	418(ra) # 80000e5a <strncmp>
    80000cc0:	d171                	beqz	a0,80000c84 <sys_ntas+0x92>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000cc2:	609c                	ld	a5,0(s1)
    80000cc4:	0087ba83          	ld	s5,8(a5)
    80000cc8:	8562                	mv	a0,s8
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	23c080e7          	jalr	572(ra) # 80000f06 <strlen>
    80000cd2:	0005061b          	sext.w	a2,a0
    80000cd6:	85e2                	mv	a1,s8
    80000cd8:	8556                	mv	a0,s5
    80000cda:	00000097          	auipc	ra,0x0
    80000cde:	180080e7          	jalr	384(ra) # 80000e5a <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000ce2:	f955                	bnez	a0,80000c96 <sys_ntas+0xa4>
    80000ce4:	b745                	j	80000c84 <sys_ntas+0x92>
    }
  }

  printf("=== top 5 contended locks:\n");
    80000ce6:	00008517          	auipc	a0,0x8
    80000cea:	5da50513          	addi	a0,a0,1498 # 800092c0 <userret+0x230>
    80000cee:	00000097          	auipc	ra,0x0
    80000cf2:	8c6080e7          	jalr	-1850(ra) # 800005b4 <printf>
    80000cf6:	4a15                	li	s4,5
  int last = 100000000;
    80000cf8:	05f5e537          	lui	a0,0x5f5e
    80000cfc:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80000d00:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000d02:	00013497          	auipc	s1,0x13
    80000d06:	bfe48493          	addi	s1,s1,-1026 # 80013900 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80000d0a:	3e800913          	li	s2,1000
    80000d0e:	a091                	j	80000d52 <sys_ntas+0x160>
    80000d10:	2705                	addiw	a4,a4,1
    80000d12:	06a1                	addi	a3,a3,8
    80000d14:	03270063          	beq	a4,s2,80000d34 <sys_ntas+0x142>
      if(locks[i] == 0)
    80000d18:	629c                	ld	a5,0(a3)
    80000d1a:	cf89                	beqz	a5,80000d34 <sys_ntas+0x142>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000d1c:	4fd0                	lw	a2,28(a5)
    80000d1e:	00359793          	slli	a5,a1,0x3
    80000d22:	97a6                	add	a5,a5,s1
    80000d24:	639c                	ld	a5,0(a5)
    80000d26:	4fdc                	lw	a5,28(a5)
    80000d28:	fec7f4e3          	bgeu	a5,a2,80000d10 <sys_ntas+0x11e>
    80000d2c:	fea672e3          	bgeu	a2,a0,80000d10 <sys_ntas+0x11e>
    80000d30:	85ba                	mv	a1,a4
    80000d32:	bff9                	j	80000d10 <sys_ntas+0x11e>
        top = i;
      }
    }
    print_lock(locks[top]);
    80000d34:	058e                	slli	a1,a1,0x3
    80000d36:	00b48bb3          	add	s7,s1,a1
    80000d3a:	000bb503          	ld	a0,0(s7)
    80000d3e:	00000097          	auipc	ra,0x0
    80000d42:	e8a080e7          	jalr	-374(ra) # 80000bc8 <print_lock>
    last = locks[top]->nts;
    80000d46:	000bb783          	ld	a5,0(s7)
    80000d4a:	4fc8                	lw	a0,28(a5)
  for(int t= 0; t < 5; t++) {
    80000d4c:	3a7d                	addiw	s4,s4,-1
    80000d4e:	000a0763          	beqz	s4,80000d5c <sys_ntas+0x16a>
  int tot = 0;
    80000d52:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    80000d54:	8756                	mv	a4,s5
    int top = 0;
    80000d56:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000d58:	2501                	sext.w	a0,a0
    80000d5a:	bf7d                	j	80000d18 <sys_ntas+0x126>
  }
  return tot;
    80000d5c:	854e                	mv	a0,s3
}
    80000d5e:	60e6                	ld	ra,88(sp)
    80000d60:	6446                	ld	s0,80(sp)
    80000d62:	64a6                	ld	s1,72(sp)
    80000d64:	6906                	ld	s2,64(sp)
    80000d66:	79e2                	ld	s3,56(sp)
    80000d68:	7a42                	ld	s4,48(sp)
    80000d6a:	7aa2                	ld	s5,40(sp)
    80000d6c:	7b02                	ld	s6,32(sp)
    80000d6e:	6be2                	ld	s7,24(sp)
    80000d70:	6c42                	ld	s8,16(sp)
    80000d72:	6125                	addi	sp,sp,96
    80000d74:	8082                	ret
    return -1;
    80000d76:	557d                	li	a0,-1
    80000d78:	b7dd                	j	80000d5e <sys_ntas+0x16c>
    return 0;
    80000d7a:	4501                	li	a0,0
    80000d7c:	b7cd                	j	80000d5e <sys_ntas+0x16c>

0000000080000d7e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e422                	sd	s0,8(sp)
    80000d82:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d84:	ce09                	beqz	a2,80000d9e <memset+0x20>
    80000d86:	87aa                	mv	a5,a0
    80000d88:	fff6071b          	addiw	a4,a2,-1
    80000d8c:	1702                	slli	a4,a4,0x20
    80000d8e:	9301                	srli	a4,a4,0x20
    80000d90:	0705                	addi	a4,a4,1
    80000d92:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d94:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d98:	0785                	addi	a5,a5,1
    80000d9a:	fee79de3          	bne	a5,a4,80000d94 <memset+0x16>
  }
  return dst;
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000daa:	ca05                	beqz	a2,80000dda <memcmp+0x36>
    80000dac:	fff6069b          	addiw	a3,a2,-1
    80000db0:	1682                	slli	a3,a3,0x20
    80000db2:	9281                	srli	a3,a3,0x20
    80000db4:	0685                	addi	a3,a3,1
    80000db6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000db8:	00054783          	lbu	a5,0(a0)
    80000dbc:	0005c703          	lbu	a4,0(a1)
    80000dc0:	00e79863          	bne	a5,a4,80000dd0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dc4:	0505                	addi	a0,a0,1
    80000dc6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dc8:	fed518e3          	bne	a0,a3,80000db8 <memcmp+0x14>
  }

  return 0;
    80000dcc:	4501                	li	a0,0
    80000dce:	a019                	j	80000dd4 <memcmp+0x30>
      return *s1 - *s2;
    80000dd0:	40e7853b          	subw	a0,a5,a4
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
  return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <memcmp+0x30>

0000000080000dde <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000de4:	02a5e563          	bltu	a1,a0,80000e0e <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000de8:	fff6069b          	addiw	a3,a2,-1
    80000dec:	ce11                	beqz	a2,80000e08 <memmove+0x2a>
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	0685                	addi	a3,a3,1
    80000df4:	96ae                	add	a3,a3,a1
    80000df6:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	0785                	addi	a5,a5,1
    80000dfc:	fff5c703          	lbu	a4,-1(a1)
    80000e00:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e04:	fed59ae3          	bne	a1,a3,80000df8 <memmove+0x1a>

  return dst;
}
    80000e08:	6422                	ld	s0,8(sp)
    80000e0a:	0141                	addi	sp,sp,16
    80000e0c:	8082                	ret
  if(s < d && s + n > d){
    80000e0e:	02061713          	slli	a4,a2,0x20
    80000e12:	9301                	srli	a4,a4,0x20
    80000e14:	00e587b3          	add	a5,a1,a4
    80000e18:	fcf578e3          	bgeu	a0,a5,80000de8 <memmove+0xa>
    d += n;
    80000e1c:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e1e:	fff6069b          	addiw	a3,a2,-1
    80000e22:	d27d                	beqz	a2,80000e08 <memmove+0x2a>
    80000e24:	02069613          	slli	a2,a3,0x20
    80000e28:	9201                	srli	a2,a2,0x20
    80000e2a:	fff64613          	not	a2,a2
    80000e2e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e30:	17fd                	addi	a5,a5,-1
    80000e32:	177d                	addi	a4,a4,-1
    80000e34:	0007c683          	lbu	a3,0(a5)
    80000e38:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e3c:	fec79ae3          	bne	a5,a2,80000e30 <memmove+0x52>
    80000e40:	b7e1                	j	80000e08 <memmove+0x2a>

0000000080000e42 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e406                	sd	ra,8(sp)
    80000e46:	e022                	sd	s0,0(sp)
    80000e48:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e4a:	00000097          	auipc	ra,0x0
    80000e4e:	f94080e7          	jalr	-108(ra) # 80000dde <memmove>
}
    80000e52:	60a2                	ld	ra,8(sp)
    80000e54:	6402                	ld	s0,0(sp)
    80000e56:	0141                	addi	sp,sp,16
    80000e58:	8082                	ret

0000000080000e5a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e5a:	1141                	addi	sp,sp,-16
    80000e5c:	e422                	sd	s0,8(sp)
    80000e5e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e60:	ce11                	beqz	a2,80000e7c <strncmp+0x22>
    80000e62:	00054783          	lbu	a5,0(a0)
    80000e66:	cf89                	beqz	a5,80000e80 <strncmp+0x26>
    80000e68:	0005c703          	lbu	a4,0(a1)
    80000e6c:	00f71a63          	bne	a4,a5,80000e80 <strncmp+0x26>
    n--, p++, q++;
    80000e70:	367d                	addiw	a2,a2,-1
    80000e72:	0505                	addi	a0,a0,1
    80000e74:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e76:	f675                	bnez	a2,80000e62 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e78:	4501                	li	a0,0
    80000e7a:	a809                	j	80000e8c <strncmp+0x32>
    80000e7c:	4501                	li	a0,0
    80000e7e:	a039                	j	80000e8c <strncmp+0x32>
  if(n == 0)
    80000e80:	ca09                	beqz	a2,80000e92 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e82:	00054503          	lbu	a0,0(a0)
    80000e86:	0005c783          	lbu	a5,0(a1)
    80000e8a:	9d1d                	subw	a0,a0,a5
}
    80000e8c:	6422                	ld	s0,8(sp)
    80000e8e:	0141                	addi	sp,sp,16
    80000e90:	8082                	ret
    return 0;
    80000e92:	4501                	li	a0,0
    80000e94:	bfe5                	j	80000e8c <strncmp+0x32>

0000000080000e96 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e96:	1141                	addi	sp,sp,-16
    80000e98:	e422                	sd	s0,8(sp)
    80000e9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e9c:	872a                	mv	a4,a0
    80000e9e:	8832                	mv	a6,a2
    80000ea0:	367d                	addiw	a2,a2,-1
    80000ea2:	01005963          	blez	a6,80000eb4 <strncpy+0x1e>
    80000ea6:	0705                	addi	a4,a4,1
    80000ea8:	0005c783          	lbu	a5,0(a1)
    80000eac:	fef70fa3          	sb	a5,-1(a4)
    80000eb0:	0585                	addi	a1,a1,1
    80000eb2:	f7f5                	bnez	a5,80000e9e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000eb4:	86ba                	mv	a3,a4
    80000eb6:	00c05c63          	blez	a2,80000ece <strncpy+0x38>
    *s++ = 0;
    80000eba:	0685                	addi	a3,a3,1
    80000ebc:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ec0:	fff6c793          	not	a5,a3
    80000ec4:	9fb9                	addw	a5,a5,a4
    80000ec6:	010787bb          	addw	a5,a5,a6
    80000eca:	fef048e3          	bgtz	a5,80000eba <strncpy+0x24>
  return os;
}
    80000ece:	6422                	ld	s0,8(sp)
    80000ed0:	0141                	addi	sp,sp,16
    80000ed2:	8082                	ret

0000000080000ed4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ed4:	1141                	addi	sp,sp,-16
    80000ed6:	e422                	sd	s0,8(sp)
    80000ed8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eda:	02c05363          	blez	a2,80000f00 <safestrcpy+0x2c>
    80000ede:	fff6069b          	addiw	a3,a2,-1
    80000ee2:	1682                	slli	a3,a3,0x20
    80000ee4:	9281                	srli	a3,a3,0x20
    80000ee6:	96ae                	add	a3,a3,a1
    80000ee8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000eea:	00d58963          	beq	a1,a3,80000efc <safestrcpy+0x28>
    80000eee:	0585                	addi	a1,a1,1
    80000ef0:	0785                	addi	a5,a5,1
    80000ef2:	fff5c703          	lbu	a4,-1(a1)
    80000ef6:	fee78fa3          	sb	a4,-1(a5)
    80000efa:	fb65                	bnez	a4,80000eea <safestrcpy+0x16>
    ;
  *s = 0;
    80000efc:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f00:	6422                	ld	s0,8(sp)
    80000f02:	0141                	addi	sp,sp,16
    80000f04:	8082                	ret

0000000080000f06 <strlen>:

int
strlen(const char *s)
{
    80000f06:	1141                	addi	sp,sp,-16
    80000f08:	e422                	sd	s0,8(sp)
    80000f0a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f0c:	00054783          	lbu	a5,0(a0)
    80000f10:	cf91                	beqz	a5,80000f2c <strlen+0x26>
    80000f12:	0505                	addi	a0,a0,1
    80000f14:	87aa                	mv	a5,a0
    80000f16:	4685                	li	a3,1
    80000f18:	9e89                	subw	a3,a3,a0
    80000f1a:	00f6853b          	addw	a0,a3,a5
    80000f1e:	0785                	addi	a5,a5,1
    80000f20:	fff7c703          	lbu	a4,-1(a5)
    80000f24:	fb7d                	bnez	a4,80000f1a <strlen+0x14>
    ;
  return n;
}
    80000f26:	6422                	ld	s0,8(sp)
    80000f28:	0141                	addi	sp,sp,16
    80000f2a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f2c:	4501                	li	a0,0
    80000f2e:	bfe5                	j	80000f26 <strlen+0x20>

0000000080000f30 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f30:	1141                	addi	sp,sp,-16
    80000f32:	e406                	sd	ra,8(sp)
    80000f34:	e022                	sd	s0,0(sp)
    80000f36:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	b42080e7          	jalr	-1214(ra) # 80001a7a <cpuid>
    sockinit();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f40:	00028717          	auipc	a4,0x28
    80000f44:	42870713          	addi	a4,a4,1064 # 80029368 <started>
  if(cpuid() == 0){
    80000f48:	c139                	beqz	a0,80000f8e <main+0x5e>
    while(started == 0)
    80000f4a:	431c                	lw	a5,0(a4)
    80000f4c:	2781                	sext.w	a5,a5
    80000f4e:	dff5                	beqz	a5,80000f4a <main+0x1a>
      ;
    __sync_synchronize();
    80000f50:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f54:	00001097          	auipc	ra,0x1
    80000f58:	b26080e7          	jalr	-1242(ra) # 80001a7a <cpuid>
    80000f5c:	85aa                	mv	a1,a0
    80000f5e:	00008517          	auipc	a0,0x8
    80000f62:	39a50513          	addi	a0,a0,922 # 800092f8 <userret+0x268>
    80000f66:	fffff097          	auipc	ra,0xfffff
    80000f6a:	64e080e7          	jalr	1614(ra) # 800005b4 <printf>
    kvminithart();    // turn on paging
    80000f6e:	00000097          	auipc	ra,0x0
    80000f72:	1fa080e7          	jalr	506(ra) # 80001168 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	7d2080e7          	jalr	2002(ra) # 80002748 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f7e:	00005097          	auipc	ra,0x5
    80000f82:	f76080e7          	jalr	-138(ra) # 80005ef4 <plicinithart>
  }

  scheduler();        
    80000f86:	00001097          	auipc	ra,0x1
    80000f8a:	ffa080e7          	jalr	-6(ra) # 80001f80 <scheduler>
    consoleinit();
    80000f8e:	fffff097          	auipc	ra,0xfffff
    80000f92:	4de080e7          	jalr	1246(ra) # 8000046c <consoleinit>
    printfinit();
    80000f96:	00000097          	auipc	ra,0x0
    80000f9a:	804080e7          	jalr	-2044(ra) # 8000079a <printfinit>
    printf("\n");
    80000f9e:	00008517          	auipc	a0,0x8
    80000fa2:	2f250513          	addi	a0,a0,754 # 80009290 <userret+0x200>
    80000fa6:	fffff097          	auipc	ra,0xfffff
    80000faa:	60e080e7          	jalr	1550(ra) # 800005b4 <printf>
    printf("xv6 kernel is booting\n");
    80000fae:	00008517          	auipc	a0,0x8
    80000fb2:	33250513          	addi	a0,a0,818 # 800092e0 <userret+0x250>
    80000fb6:	fffff097          	auipc	ra,0xfffff
    80000fba:	5fe080e7          	jalr	1534(ra) # 800005b4 <printf>
    printf("\n");
    80000fbe:	00008517          	auipc	a0,0x8
    80000fc2:	2d250513          	addi	a0,a0,722 # 80009290 <userret+0x200>
    80000fc6:	fffff097          	auipc	ra,0xfffff
    80000fca:	5ee080e7          	jalr	1518(ra) # 800005b4 <printf>
    kinit();         // physical page allocator
    80000fce:	00000097          	auipc	ra,0x0
    80000fd2:	972080e7          	jalr	-1678(ra) # 80000940 <kinit>
    kvminit();       // create kernel page table
    80000fd6:	00000097          	auipc	ra,0x0
    80000fda:	31c080e7          	jalr	796(ra) # 800012f2 <kvminit>
    kvminithart();   // turn on paging
    80000fde:	00000097          	auipc	ra,0x0
    80000fe2:	18a080e7          	jalr	394(ra) # 80001168 <kvminithart>
    procinit();      // process table
    80000fe6:	00001097          	auipc	ra,0x1
    80000fea:	9c4080e7          	jalr	-1596(ra) # 800019aa <procinit>
    trapinit();      // trap vectors
    80000fee:	00001097          	auipc	ra,0x1
    80000ff2:	732080e7          	jalr	1842(ra) # 80002720 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ff6:	00001097          	auipc	ra,0x1
    80000ffa:	752080e7          	jalr	1874(ra) # 80002748 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ffe:	00005097          	auipc	ra,0x5
    80001002:	ecc080e7          	jalr	-308(ra) # 80005eca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001006:	00005097          	auipc	ra,0x5
    8000100a:	eee080e7          	jalr	-274(ra) # 80005ef4 <plicinithart>
    binit();         // buffer cache
    8000100e:	00002097          	auipc	ra,0x2
    80001012:	ea2080e7          	jalr	-350(ra) # 80002eb0 <binit>
    iinit();         // inode cache
    80001016:	00002097          	auipc	ra,0x2
    8000101a:	536080e7          	jalr	1334(ra) # 8000354c <iinit>
    fileinit();      // file table
    8000101e:	00003097          	auipc	ra,0x3
    80001022:	5c0080e7          	jalr	1472(ra) # 800045de <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80001026:	4501                	li	a0,0
    80001028:	00005097          	auipc	ra,0x5
    8000102c:	ff4080e7          	jalr	-12(ra) # 8000601c <virtio_disk_init>
    pci_init();
    80001030:	00006097          	auipc	ra,0x6
    80001034:	510080e7          	jalr	1296(ra) # 80007540 <pci_init>
    sockinit();
    80001038:	00006097          	auipc	ra,0x6
    8000103c:	0a2080e7          	jalr	162(ra) # 800070da <sockinit>
    userinit();      // first user process
    80001040:	00001097          	auipc	ra,0x1
    80001044:	cda080e7          	jalr	-806(ra) # 80001d1a <userinit>
    __sync_synchronize();
    80001048:	0ff0000f          	fence
    started = 1;
    8000104c:	4785                	li	a5,1
    8000104e:	00028717          	auipc	a4,0x28
    80001052:	30f72d23          	sw	a5,794(a4) # 80029368 <started>
    80001056:	bf05                	j	80000f86 <main+0x56>

0000000080001058 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001058:	7139                	addi	sp,sp,-64
    8000105a:	fc06                	sd	ra,56(sp)
    8000105c:	f822                	sd	s0,48(sp)
    8000105e:	f426                	sd	s1,40(sp)
    80001060:	f04a                	sd	s2,32(sp)
    80001062:	ec4e                	sd	s3,24(sp)
    80001064:	e852                	sd	s4,16(sp)
    80001066:	e456                	sd	s5,8(sp)
    80001068:	e05a                	sd	s6,0(sp)
    8000106a:	0080                	addi	s0,sp,64
    8000106c:	84aa                	mv	s1,a0
    8000106e:	89ae                	mv	s3,a1
    80001070:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001072:	57fd                	li	a5,-1
    80001074:	83e9                	srli	a5,a5,0x1a
    80001076:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001078:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000107a:	04b7f263          	bgeu	a5,a1,800010be <walk+0x66>
    panic("walk");
    8000107e:	00008517          	auipc	a0,0x8
    80001082:	29250513          	addi	a0,a0,658 # 80009310 <userret+0x280>
    80001086:	fffff097          	auipc	ra,0xfffff
    8000108a:	4d4080e7          	jalr	1236(ra) # 8000055a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000108e:	060a8663          	beqz	s5,800010fa <walk+0xa2>
    80001092:	00000097          	auipc	ra,0x0
    80001096:	8ea080e7          	jalr	-1814(ra) # 8000097c <kalloc>
    8000109a:	84aa                	mv	s1,a0
    8000109c:	c529                	beqz	a0,800010e6 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000109e:	6605                	lui	a2,0x1
    800010a0:	4581                	li	a1,0
    800010a2:	00000097          	auipc	ra,0x0
    800010a6:	cdc080e7          	jalr	-804(ra) # 80000d7e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010aa:	00c4d793          	srli	a5,s1,0xc
    800010ae:	07aa                	slli	a5,a5,0xa
    800010b0:	0017e793          	ori	a5,a5,1
    800010b4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010b8:	3a5d                	addiw	s4,s4,-9
    800010ba:	036a0063          	beq	s4,s6,800010da <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010be:	0149d933          	srl	s2,s3,s4
    800010c2:	1ff97913          	andi	s2,s2,511
    800010c6:	090e                	slli	s2,s2,0x3
    800010c8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010ca:	00093483          	ld	s1,0(s2)
    800010ce:	0014f793          	andi	a5,s1,1
    800010d2:	dfd5                	beqz	a5,8000108e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010d4:	80a9                	srli	s1,s1,0xa
    800010d6:	04b2                	slli	s1,s1,0xc
    800010d8:	b7c5                	j	800010b8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010da:	00c9d513          	srli	a0,s3,0xc
    800010de:	1ff57513          	andi	a0,a0,511
    800010e2:	050e                	slli	a0,a0,0x3
    800010e4:	9526                	add	a0,a0,s1
}
    800010e6:	70e2                	ld	ra,56(sp)
    800010e8:	7442                	ld	s0,48(sp)
    800010ea:	74a2                	ld	s1,40(sp)
    800010ec:	7902                	ld	s2,32(sp)
    800010ee:	69e2                	ld	s3,24(sp)
    800010f0:	6a42                	ld	s4,16(sp)
    800010f2:	6aa2                	ld	s5,8(sp)
    800010f4:	6b02                	ld	s6,0(sp)
    800010f6:	6121                	addi	sp,sp,64
    800010f8:	8082                	ret
        return 0;
    800010fa:	4501                	li	a0,0
    800010fc:	b7ed                	j	800010e6 <walk+0x8e>

00000000800010fe <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    800010fe:	7179                	addi	sp,sp,-48
    80001100:	f406                	sd	ra,40(sp)
    80001102:	f022                	sd	s0,32(sp)
    80001104:	ec26                	sd	s1,24(sp)
    80001106:	e84a                	sd	s2,16(sp)
    80001108:	e44e                	sd	s3,8(sp)
    8000110a:	e052                	sd	s4,0(sp)
    8000110c:	1800                	addi	s0,sp,48
    8000110e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001110:	84aa                	mv	s1,a0
    80001112:	6905                	lui	s2,0x1
    80001114:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001116:	4985                	li	s3,1
    80001118:	a821                	j	80001130 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000111a:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000111c:	0532                	slli	a0,a0,0xc
    8000111e:	00000097          	auipc	ra,0x0
    80001122:	fe0080e7          	jalr	-32(ra) # 800010fe <freewalk>
      pagetable[i] = 0;
    80001126:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000112a:	04a1                	addi	s1,s1,8
    8000112c:	03248163          	beq	s1,s2,8000114e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001130:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001132:	00f57793          	andi	a5,a0,15
    80001136:	ff3782e3          	beq	a5,s3,8000111a <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000113a:	8905                	andi	a0,a0,1
    8000113c:	d57d                	beqz	a0,8000112a <freewalk+0x2c>
      panic("freewalk: leaf");
    8000113e:	00008517          	auipc	a0,0x8
    80001142:	1da50513          	addi	a0,a0,474 # 80009318 <userret+0x288>
    80001146:	fffff097          	auipc	ra,0xfffff
    8000114a:	414080e7          	jalr	1044(ra) # 8000055a <panic>
    }
  }
  kfree((void*)pagetable);
    8000114e:	8552                	mv	a0,s4
    80001150:	fffff097          	auipc	ra,0xfffff
    80001154:	730080e7          	jalr	1840(ra) # 80000880 <kfree>
}
    80001158:	70a2                	ld	ra,40(sp)
    8000115a:	7402                	ld	s0,32(sp)
    8000115c:	64e2                	ld	s1,24(sp)
    8000115e:	6942                	ld	s2,16(sp)
    80001160:	69a2                	ld	s3,8(sp)
    80001162:	6a02                	ld	s4,0(sp)
    80001164:	6145                	addi	sp,sp,48
    80001166:	8082                	ret

0000000080001168 <kvminithart>:
{
    80001168:	1141                	addi	sp,sp,-16
    8000116a:	e422                	sd	s0,8(sp)
    8000116c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000116e:	00028797          	auipc	a5,0x28
    80001172:	2027b783          	ld	a5,514(a5) # 80029370 <kernel_pagetable>
    80001176:	83b1                	srli	a5,a5,0xc
    80001178:	577d                	li	a4,-1
    8000117a:	177e                	slli	a4,a4,0x3f
    8000117c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000117e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001182:	12000073          	sfence.vma
}
    80001186:	6422                	ld	s0,8(sp)
    80001188:	0141                	addi	sp,sp,16
    8000118a:	8082                	ret

000000008000118c <walkaddr>:
  if(va >= MAXVA)
    8000118c:	57fd                	li	a5,-1
    8000118e:	83e9                	srli	a5,a5,0x1a
    80001190:	00b7f463          	bgeu	a5,a1,80001198 <walkaddr+0xc>
    return 0;
    80001194:	4501                	li	a0,0
}
    80001196:	8082                	ret
{
    80001198:	1141                	addi	sp,sp,-16
    8000119a:	e406                	sd	ra,8(sp)
    8000119c:	e022                	sd	s0,0(sp)
    8000119e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011a0:	4601                	li	a2,0
    800011a2:	00000097          	auipc	ra,0x0
    800011a6:	eb6080e7          	jalr	-330(ra) # 80001058 <walk>
  if(pte == 0)
    800011aa:	c105                	beqz	a0,800011ca <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800011ac:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011ae:	0117f693          	andi	a3,a5,17
    800011b2:	4745                	li	a4,17
    return 0;
    800011b4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011b6:	00e68663          	beq	a3,a4,800011c2 <walkaddr+0x36>
}
    800011ba:	60a2                	ld	ra,8(sp)
    800011bc:	6402                	ld	s0,0(sp)
    800011be:	0141                	addi	sp,sp,16
    800011c0:	8082                	ret
  pa = PTE2PA(*pte);
    800011c2:	00a7d513          	srli	a0,a5,0xa
    800011c6:	0532                	slli	a0,a0,0xc
  return pa;
    800011c8:	bfcd                	j	800011ba <walkaddr+0x2e>
    return 0;
    800011ca:	4501                	li	a0,0
    800011cc:	b7fd                	j	800011ba <walkaddr+0x2e>

00000000800011ce <kvmpa>:
{
    800011ce:	1101                	addi	sp,sp,-32
    800011d0:	ec06                	sd	ra,24(sp)
    800011d2:	e822                	sd	s0,16(sp)
    800011d4:	e426                	sd	s1,8(sp)
    800011d6:	1000                	addi	s0,sp,32
    800011d8:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011da:	1552                	slli	a0,a0,0x34
    800011dc:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    800011e0:	4601                	li	a2,0
    800011e2:	00028517          	auipc	a0,0x28
    800011e6:	18e53503          	ld	a0,398(a0) # 80029370 <kernel_pagetable>
    800011ea:	00000097          	auipc	ra,0x0
    800011ee:	e6e080e7          	jalr	-402(ra) # 80001058 <walk>
  if(pte == 0)
    800011f2:	cd09                	beqz	a0,8000120c <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    800011f4:	6108                	ld	a0,0(a0)
    800011f6:	00157793          	andi	a5,a0,1
    800011fa:	c38d                	beqz	a5,8000121c <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    800011fc:	8129                	srli	a0,a0,0xa
    800011fe:	0532                	slli	a0,a0,0xc
}
    80001200:	9526                	add	a0,a0,s1
    80001202:	60e2                	ld	ra,24(sp)
    80001204:	6442                	ld	s0,16(sp)
    80001206:	64a2                	ld	s1,8(sp)
    80001208:	6105                	addi	sp,sp,32
    8000120a:	8082                	ret
    panic("kvmpa");
    8000120c:	00008517          	auipc	a0,0x8
    80001210:	11c50513          	addi	a0,a0,284 # 80009328 <userret+0x298>
    80001214:	fffff097          	auipc	ra,0xfffff
    80001218:	346080e7          	jalr	838(ra) # 8000055a <panic>
    panic("kvmpa");
    8000121c:	00008517          	auipc	a0,0x8
    80001220:	10c50513          	addi	a0,a0,268 # 80009328 <userret+0x298>
    80001224:	fffff097          	auipc	ra,0xfffff
    80001228:	336080e7          	jalr	822(ra) # 8000055a <panic>

000000008000122c <mappages>:
{
    8000122c:	715d                	addi	sp,sp,-80
    8000122e:	e486                	sd	ra,72(sp)
    80001230:	e0a2                	sd	s0,64(sp)
    80001232:	fc26                	sd	s1,56(sp)
    80001234:	f84a                	sd	s2,48(sp)
    80001236:	f44e                	sd	s3,40(sp)
    80001238:	f052                	sd	s4,32(sp)
    8000123a:	ec56                	sd	s5,24(sp)
    8000123c:	e85a                	sd	s6,16(sp)
    8000123e:	e45e                	sd	s7,8(sp)
    80001240:	0880                	addi	s0,sp,80
    80001242:	8aaa                	mv	s5,a0
    80001244:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80001246:	777d                	lui	a4,0xfffff
    80001248:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000124c:	167d                	addi	a2,a2,-1
    8000124e:	00b609b3          	add	s3,a2,a1
    80001252:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001256:	893e                	mv	s2,a5
    80001258:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    8000125c:	6b85                	lui	s7,0x1
    8000125e:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001262:	4605                	li	a2,1
    80001264:	85ca                	mv	a1,s2
    80001266:	8556                	mv	a0,s5
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	df0080e7          	jalr	-528(ra) # 80001058 <walk>
    80001270:	c51d                	beqz	a0,8000129e <mappages+0x72>
    if(*pte & PTE_V)
    80001272:	611c                	ld	a5,0(a0)
    80001274:	8b85                	andi	a5,a5,1
    80001276:	ef81                	bnez	a5,8000128e <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001278:	80b1                	srli	s1,s1,0xc
    8000127a:	04aa                	slli	s1,s1,0xa
    8000127c:	0164e4b3          	or	s1,s1,s6
    80001280:	0014e493          	ori	s1,s1,1
    80001284:	e104                	sd	s1,0(a0)
    if(a == last)
    80001286:	03390863          	beq	s2,s3,800012b6 <mappages+0x8a>
    a += PGSIZE;
    8000128a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000128c:	bfc9                	j	8000125e <mappages+0x32>
      panic("remap");
    8000128e:	00008517          	auipc	a0,0x8
    80001292:	0a250513          	addi	a0,a0,162 # 80009330 <userret+0x2a0>
    80001296:	fffff097          	auipc	ra,0xfffff
    8000129a:	2c4080e7          	jalr	708(ra) # 8000055a <panic>
      return -1;
    8000129e:	557d                	li	a0,-1
}
    800012a0:	60a6                	ld	ra,72(sp)
    800012a2:	6406                	ld	s0,64(sp)
    800012a4:	74e2                	ld	s1,56(sp)
    800012a6:	7942                	ld	s2,48(sp)
    800012a8:	79a2                	ld	s3,40(sp)
    800012aa:	7a02                	ld	s4,32(sp)
    800012ac:	6ae2                	ld	s5,24(sp)
    800012ae:	6b42                	ld	s6,16(sp)
    800012b0:	6ba2                	ld	s7,8(sp)
    800012b2:	6161                	addi	sp,sp,80
    800012b4:	8082                	ret
  return 0;
    800012b6:	4501                	li	a0,0
    800012b8:	b7e5                	j	800012a0 <mappages+0x74>

00000000800012ba <kvmmap>:
{
    800012ba:	1141                	addi	sp,sp,-16
    800012bc:	e406                	sd	ra,8(sp)
    800012be:	e022                	sd	s0,0(sp)
    800012c0:	0800                	addi	s0,sp,16
    800012c2:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800012c4:	86ae                	mv	a3,a1
    800012c6:	85aa                	mv	a1,a0
    800012c8:	00028517          	auipc	a0,0x28
    800012cc:	0a853503          	ld	a0,168(a0) # 80029370 <kernel_pagetable>
    800012d0:	00000097          	auipc	ra,0x0
    800012d4:	f5c080e7          	jalr	-164(ra) # 8000122c <mappages>
    800012d8:	e509                	bnez	a0,800012e2 <kvmmap+0x28>
}
    800012da:	60a2                	ld	ra,8(sp)
    800012dc:	6402                	ld	s0,0(sp)
    800012de:	0141                	addi	sp,sp,16
    800012e0:	8082                	ret
    panic("kvmmap");
    800012e2:	00008517          	auipc	a0,0x8
    800012e6:	05650513          	addi	a0,a0,86 # 80009338 <userret+0x2a8>
    800012ea:	fffff097          	auipc	ra,0xfffff
    800012ee:	270080e7          	jalr	624(ra) # 8000055a <panic>

00000000800012f2 <kvminit>:
{
    800012f2:	1101                	addi	sp,sp,-32
    800012f4:	ec06                	sd	ra,24(sp)
    800012f6:	e822                	sd	s0,16(sp)
    800012f8:	e426                	sd	s1,8(sp)
    800012fa:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	680080e7          	jalr	1664(ra) # 8000097c <kalloc>
    80001304:	00028797          	auipc	a5,0x28
    80001308:	06a7b623          	sd	a0,108(a5) # 80029370 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000130c:	6605                	lui	a2,0x1
    8000130e:	4581                	li	a1,0
    80001310:	00000097          	auipc	ra,0x0
    80001314:	a6e080e7          	jalr	-1426(ra) # 80000d7e <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001318:	4699                	li	a3,6
    8000131a:	6605                	lui	a2,0x1
    8000131c:	100005b7          	lui	a1,0x10000
    80001320:	10000537          	lui	a0,0x10000
    80001324:	00000097          	auipc	ra,0x0
    80001328:	f96080e7          	jalr	-106(ra) # 800012ba <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    8000132c:	4699                	li	a3,6
    8000132e:	6605                	lui	a2,0x1
    80001330:	100015b7          	lui	a1,0x10001
    80001334:	10001537          	lui	a0,0x10001
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	f82080e7          	jalr	-126(ra) # 800012ba <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    80001340:	4699                	li	a3,6
    80001342:	6605                	lui	a2,0x1
    80001344:	100025b7          	lui	a1,0x10002
    80001348:	10002537          	lui	a0,0x10002
    8000134c:	00000097          	auipc	ra,0x0
    80001350:	f6e080e7          	jalr	-146(ra) # 800012ba <kvmmap>
  kvmmap(0x30000000L, 0x30000000L, 0x10000000, PTE_R | PTE_W);
    80001354:	4699                	li	a3,6
    80001356:	10000637          	lui	a2,0x10000
    8000135a:	300005b7          	lui	a1,0x30000
    8000135e:	30000537          	lui	a0,0x30000
    80001362:	00000097          	auipc	ra,0x0
    80001366:	f58080e7          	jalr	-168(ra) # 800012ba <kvmmap>
  kvmmap(0x40000000L, 0x40000000L, 0x20000, PTE_R | PTE_W);
    8000136a:	4699                	li	a3,6
    8000136c:	00020637          	lui	a2,0x20
    80001370:	400005b7          	lui	a1,0x40000
    80001374:	40000537          	lui	a0,0x40000
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	f42080e7          	jalr	-190(ra) # 800012ba <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001380:	4699                	li	a3,6
    80001382:	6641                	lui	a2,0x10
    80001384:	020005b7          	lui	a1,0x2000
    80001388:	02000537          	lui	a0,0x2000
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	f2e080e7          	jalr	-210(ra) # 800012ba <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001394:	4699                	li	a3,6
    80001396:	00400637          	lui	a2,0x400
    8000139a:	0c0005b7          	lui	a1,0xc000
    8000139e:	0c000537          	lui	a0,0xc000
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	f18080e7          	jalr	-232(ra) # 800012ba <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800013aa:	00009497          	auipc	s1,0x9
    800013ae:	c5648493          	addi	s1,s1,-938 # 8000a000 <initcode>
    800013b2:	46a9                	li	a3,10
    800013b4:	80009617          	auipc	a2,0x80009
    800013b8:	c4c60613          	addi	a2,a2,-948 # a000 <_entry-0x7fff6000>
    800013bc:	4585                	li	a1,1
    800013be:	05fe                	slli	a1,a1,0x1f
    800013c0:	852e                	mv	a0,a1
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	ef8080e7          	jalr	-264(ra) # 800012ba <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800013ca:	4699                	li	a3,6
    800013cc:	4645                	li	a2,17
    800013ce:	066e                	slli	a2,a2,0x1b
    800013d0:	8e05                	sub	a2,a2,s1
    800013d2:	85a6                	mv	a1,s1
    800013d4:	8526                	mv	a0,s1
    800013d6:	00000097          	auipc	ra,0x0
    800013da:	ee4080e7          	jalr	-284(ra) # 800012ba <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800013de:	46a9                	li	a3,10
    800013e0:	6605                	lui	a2,0x1
    800013e2:	00008597          	auipc	a1,0x8
    800013e6:	c1e58593          	addi	a1,a1,-994 # 80009000 <trampoline>
    800013ea:	04000537          	lui	a0,0x4000
    800013ee:	157d                	addi	a0,a0,-1
    800013f0:	0532                	slli	a0,a0,0xc
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	ec8080e7          	jalr	-312(ra) # 800012ba <kvmmap>
}
    800013fa:	60e2                	ld	ra,24(sp)
    800013fc:	6442                	ld	s0,16(sp)
    800013fe:	64a2                	ld	s1,8(sp)
    80001400:	6105                	addi	sp,sp,32
    80001402:	8082                	ret

0000000080001404 <uvmunmap>:
{
    80001404:	715d                	addi	sp,sp,-80
    80001406:	e486                	sd	ra,72(sp)
    80001408:	e0a2                	sd	s0,64(sp)
    8000140a:	fc26                	sd	s1,56(sp)
    8000140c:	f84a                	sd	s2,48(sp)
    8000140e:	f44e                	sd	s3,40(sp)
    80001410:	f052                	sd	s4,32(sp)
    80001412:	ec56                	sd	s5,24(sp)
    80001414:	e85a                	sd	s6,16(sp)
    80001416:	e45e                	sd	s7,8(sp)
    80001418:	0880                	addi	s0,sp,80
    8000141a:	8a2a                	mv	s4,a0
    8000141c:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    8000141e:	77fd                	lui	a5,0xfffff
    80001420:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80001424:	167d                	addi	a2,a2,-1
    80001426:	00b609b3          	add	s3,a2,a1
    8000142a:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    8000142e:	4b05                	li	s6,1
    a += PGSIZE;
    80001430:	6b85                	lui	s7,0x1
    80001432:	a8b1                	j	8000148e <uvmunmap+0x8a>
      panic("uvmunmap: walk");
    80001434:	00008517          	auipc	a0,0x8
    80001438:	f0c50513          	addi	a0,a0,-244 # 80009340 <userret+0x2b0>
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	11e080e7          	jalr	286(ra) # 8000055a <panic>
      printf("va=%p pte=%p\n", a, *pte);
    80001444:	862a                	mv	a2,a0
    80001446:	85ca                	mv	a1,s2
    80001448:	00008517          	auipc	a0,0x8
    8000144c:	f0850513          	addi	a0,a0,-248 # 80009350 <userret+0x2c0>
    80001450:	fffff097          	auipc	ra,0xfffff
    80001454:	164080e7          	jalr	356(ra) # 800005b4 <printf>
      panic("uvmunmap: not mapped");
    80001458:	00008517          	auipc	a0,0x8
    8000145c:	f0850513          	addi	a0,a0,-248 # 80009360 <userret+0x2d0>
    80001460:	fffff097          	auipc	ra,0xfffff
    80001464:	0fa080e7          	jalr	250(ra) # 8000055a <panic>
      panic("uvmunmap: not a leaf");
    80001468:	00008517          	auipc	a0,0x8
    8000146c:	f1050513          	addi	a0,a0,-240 # 80009378 <userret+0x2e8>
    80001470:	fffff097          	auipc	ra,0xfffff
    80001474:	0ea080e7          	jalr	234(ra) # 8000055a <panic>
      pa = PTE2PA(*pte);
    80001478:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000147a:	0532                	slli	a0,a0,0xc
    8000147c:	fffff097          	auipc	ra,0xfffff
    80001480:	404080e7          	jalr	1028(ra) # 80000880 <kfree>
    *pte = 0;
    80001484:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001488:	03390763          	beq	s2,s3,800014b6 <uvmunmap+0xb2>
    a += PGSIZE;
    8000148c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    8000148e:	4601                	li	a2,0
    80001490:	85ca                	mv	a1,s2
    80001492:	8552                	mv	a0,s4
    80001494:	00000097          	auipc	ra,0x0
    80001498:	bc4080e7          	jalr	-1084(ra) # 80001058 <walk>
    8000149c:	84aa                	mv	s1,a0
    8000149e:	d959                	beqz	a0,80001434 <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    800014a0:	6108                	ld	a0,0(a0)
    800014a2:	00157793          	andi	a5,a0,1
    800014a6:	dfd9                	beqz	a5,80001444 <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    800014a8:	3ff57793          	andi	a5,a0,1023
    800014ac:	fb678ee3          	beq	a5,s6,80001468 <uvmunmap+0x64>
    if(do_free){
    800014b0:	fc0a8ae3          	beqz	s5,80001484 <uvmunmap+0x80>
    800014b4:	b7d1                	j	80001478 <uvmunmap+0x74>
}
    800014b6:	60a6                	ld	ra,72(sp)
    800014b8:	6406                	ld	s0,64(sp)
    800014ba:	74e2                	ld	s1,56(sp)
    800014bc:	7942                	ld	s2,48(sp)
    800014be:	79a2                	ld	s3,40(sp)
    800014c0:	7a02                	ld	s4,32(sp)
    800014c2:	6ae2                	ld	s5,24(sp)
    800014c4:	6b42                	ld	s6,16(sp)
    800014c6:	6ba2                	ld	s7,8(sp)
    800014c8:	6161                	addi	sp,sp,80
    800014ca:	8082                	ret

00000000800014cc <uvmcreate>:
{
    800014cc:	1101                	addi	sp,sp,-32
    800014ce:	ec06                	sd	ra,24(sp)
    800014d0:	e822                	sd	s0,16(sp)
    800014d2:	e426                	sd	s1,8(sp)
    800014d4:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    800014d6:	fffff097          	auipc	ra,0xfffff
    800014da:	4a6080e7          	jalr	1190(ra) # 8000097c <kalloc>
  if(pagetable == 0)
    800014de:	cd11                	beqz	a0,800014fa <uvmcreate+0x2e>
    800014e0:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    800014e2:	6605                	lui	a2,0x1
    800014e4:	4581                	li	a1,0
    800014e6:	00000097          	auipc	ra,0x0
    800014ea:	898080e7          	jalr	-1896(ra) # 80000d7e <memset>
}
    800014ee:	8526                	mv	a0,s1
    800014f0:	60e2                	ld	ra,24(sp)
    800014f2:	6442                	ld	s0,16(sp)
    800014f4:	64a2                	ld	s1,8(sp)
    800014f6:	6105                	addi	sp,sp,32
    800014f8:	8082                	ret
    panic("uvmcreate: out of memory");
    800014fa:	00008517          	auipc	a0,0x8
    800014fe:	e9650513          	addi	a0,a0,-362 # 80009390 <userret+0x300>
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	058080e7          	jalr	88(ra) # 8000055a <panic>

000000008000150a <uvminit>:
{
    8000150a:	7179                	addi	sp,sp,-48
    8000150c:	f406                	sd	ra,40(sp)
    8000150e:	f022                	sd	s0,32(sp)
    80001510:	ec26                	sd	s1,24(sp)
    80001512:	e84a                	sd	s2,16(sp)
    80001514:	e44e                	sd	s3,8(sp)
    80001516:	e052                	sd	s4,0(sp)
    80001518:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    8000151a:	6785                	lui	a5,0x1
    8000151c:	04f67863          	bgeu	a2,a5,8000156c <uvminit+0x62>
    80001520:	8a2a                	mv	s4,a0
    80001522:	89ae                	mv	s3,a1
    80001524:	84b2                	mv	s1,a2
  mem = kalloc();
    80001526:	fffff097          	auipc	ra,0xfffff
    8000152a:	456080e7          	jalr	1110(ra) # 8000097c <kalloc>
    8000152e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001530:	6605                	lui	a2,0x1
    80001532:	4581                	li	a1,0
    80001534:	00000097          	auipc	ra,0x0
    80001538:	84a080e7          	jalr	-1974(ra) # 80000d7e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000153c:	4779                	li	a4,30
    8000153e:	86ca                	mv	a3,s2
    80001540:	6605                	lui	a2,0x1
    80001542:	4581                	li	a1,0
    80001544:	8552                	mv	a0,s4
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	ce6080e7          	jalr	-794(ra) # 8000122c <mappages>
  memmove(mem, src, sz);
    8000154e:	8626                	mv	a2,s1
    80001550:	85ce                	mv	a1,s3
    80001552:	854a                	mv	a0,s2
    80001554:	00000097          	auipc	ra,0x0
    80001558:	88a080e7          	jalr	-1910(ra) # 80000dde <memmove>
}
    8000155c:	70a2                	ld	ra,40(sp)
    8000155e:	7402                	ld	s0,32(sp)
    80001560:	64e2                	ld	s1,24(sp)
    80001562:	6942                	ld	s2,16(sp)
    80001564:	69a2                	ld	s3,8(sp)
    80001566:	6a02                	ld	s4,0(sp)
    80001568:	6145                	addi	sp,sp,48
    8000156a:	8082                	ret
    panic("inituvm: more than a page");
    8000156c:	00008517          	auipc	a0,0x8
    80001570:	e4450513          	addi	a0,a0,-444 # 800093b0 <userret+0x320>
    80001574:	fffff097          	auipc	ra,0xfffff
    80001578:	fe6080e7          	jalr	-26(ra) # 8000055a <panic>

000000008000157c <uvmdealloc>:
{
    8000157c:	1101                	addi	sp,sp,-32
    8000157e:	ec06                	sd	ra,24(sp)
    80001580:	e822                	sd	s0,16(sp)
    80001582:	e426                	sd	s1,8(sp)
    80001584:	1000                	addi	s0,sp,32
    return oldsz;
    80001586:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001588:	00b67d63          	bgeu	a2,a1,800015a2 <uvmdealloc+0x26>
    8000158c:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    8000158e:	6785                	lui	a5,0x1
    80001590:	17fd                	addi	a5,a5,-1
    80001592:	00f60733          	add	a4,a2,a5
    80001596:	76fd                	lui	a3,0xfffff
    80001598:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    8000159a:	97ae                	add	a5,a5,a1
    8000159c:	8ff5                	and	a5,a5,a3
    8000159e:	00f76863          	bltu	a4,a5,800015ae <uvmdealloc+0x32>
}
    800015a2:	8526                	mv	a0,s1
    800015a4:	60e2                	ld	ra,24(sp)
    800015a6:	6442                	ld	s0,16(sp)
    800015a8:	64a2                	ld	s1,8(sp)
    800015aa:	6105                	addi	sp,sp,32
    800015ac:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    800015ae:	4685                	li	a3,1
    800015b0:	40e58633          	sub	a2,a1,a4
    800015b4:	85ba                	mv	a1,a4
    800015b6:	00000097          	auipc	ra,0x0
    800015ba:	e4e080e7          	jalr	-434(ra) # 80001404 <uvmunmap>
    800015be:	b7d5                	j	800015a2 <uvmdealloc+0x26>

00000000800015c0 <uvmalloc>:
  if(newsz < oldsz)
    800015c0:	0ab66163          	bltu	a2,a1,80001662 <uvmalloc+0xa2>
{
    800015c4:	7139                	addi	sp,sp,-64
    800015c6:	fc06                	sd	ra,56(sp)
    800015c8:	f822                	sd	s0,48(sp)
    800015ca:	f426                	sd	s1,40(sp)
    800015cc:	f04a                	sd	s2,32(sp)
    800015ce:	ec4e                	sd	s3,24(sp)
    800015d0:	e852                	sd	s4,16(sp)
    800015d2:	e456                	sd	s5,8(sp)
    800015d4:	0080                	addi	s0,sp,64
    800015d6:	8aaa                	mv	s5,a0
    800015d8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800015da:	6985                	lui	s3,0x1
    800015dc:	19fd                	addi	s3,s3,-1
    800015de:	95ce                	add	a1,a1,s3
    800015e0:	79fd                	lui	s3,0xfffff
    800015e2:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    800015e6:	08c9f063          	bgeu	s3,a2,80001666 <uvmalloc+0xa6>
  a = oldsz;
    800015ea:	894e                	mv	s2,s3
    mem = kalloc();
    800015ec:	fffff097          	auipc	ra,0xfffff
    800015f0:	390080e7          	jalr	912(ra) # 8000097c <kalloc>
    800015f4:	84aa                	mv	s1,a0
    if(mem == 0){
    800015f6:	c51d                	beqz	a0,80001624 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800015f8:	6605                	lui	a2,0x1
    800015fa:	4581                	li	a1,0
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	782080e7          	jalr	1922(ra) # 80000d7e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001604:	4779                	li	a4,30
    80001606:	86a6                	mv	a3,s1
    80001608:	6605                	lui	a2,0x1
    8000160a:	85ca                	mv	a1,s2
    8000160c:	8556                	mv	a0,s5
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	c1e080e7          	jalr	-994(ra) # 8000122c <mappages>
    80001616:	e905                	bnez	a0,80001646 <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    80001618:	6785                	lui	a5,0x1
    8000161a:	993e                	add	s2,s2,a5
    8000161c:	fd4968e3          	bltu	s2,s4,800015ec <uvmalloc+0x2c>
  return newsz;
    80001620:	8552                	mv	a0,s4
    80001622:	a809                	j	80001634 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001624:	864e                	mv	a2,s3
    80001626:	85ca                	mv	a1,s2
    80001628:	8556                	mv	a0,s5
    8000162a:	00000097          	auipc	ra,0x0
    8000162e:	f52080e7          	jalr	-174(ra) # 8000157c <uvmdealloc>
      return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	70e2                	ld	ra,56(sp)
    80001636:	7442                	ld	s0,48(sp)
    80001638:	74a2                	ld	s1,40(sp)
    8000163a:	7902                	ld	s2,32(sp)
    8000163c:	69e2                	ld	s3,24(sp)
    8000163e:	6a42                	ld	s4,16(sp)
    80001640:	6aa2                	ld	s5,8(sp)
    80001642:	6121                	addi	sp,sp,64
    80001644:	8082                	ret
      kfree(mem);
    80001646:	8526                	mv	a0,s1
    80001648:	fffff097          	auipc	ra,0xfffff
    8000164c:	238080e7          	jalr	568(ra) # 80000880 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001650:	864e                	mv	a2,s3
    80001652:	85ca                	mv	a1,s2
    80001654:	8556                	mv	a0,s5
    80001656:	00000097          	auipc	ra,0x0
    8000165a:	f26080e7          	jalr	-218(ra) # 8000157c <uvmdealloc>
      return 0;
    8000165e:	4501                	li	a0,0
    80001660:	bfd1                	j	80001634 <uvmalloc+0x74>
    return oldsz;
    80001662:	852e                	mv	a0,a1
}
    80001664:	8082                	ret
  return newsz;
    80001666:	8532                	mv	a0,a2
    80001668:	b7f1                	j	80001634 <uvmalloc+0x74>

000000008000166a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000166a:	1101                	addi	sp,sp,-32
    8000166c:	ec06                	sd	ra,24(sp)
    8000166e:	e822                	sd	s0,16(sp)
    80001670:	e426                	sd	s1,8(sp)
    80001672:	1000                	addi	s0,sp,32
    80001674:	84aa                	mv	s1,a0
    80001676:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001678:	4685                	li	a3,1
    8000167a:	4581                	li	a1,0
    8000167c:	00000097          	auipc	ra,0x0
    80001680:	d88080e7          	jalr	-632(ra) # 80001404 <uvmunmap>
  freewalk(pagetable);
    80001684:	8526                	mv	a0,s1
    80001686:	00000097          	auipc	ra,0x0
    8000168a:	a78080e7          	jalr	-1416(ra) # 800010fe <freewalk>
}
    8000168e:	60e2                	ld	ra,24(sp)
    80001690:	6442                	ld	s0,16(sp)
    80001692:	64a2                	ld	s1,8(sp)
    80001694:	6105                	addi	sp,sp,32
    80001696:	8082                	ret

0000000080001698 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001698:	c671                	beqz	a2,80001764 <uvmcopy+0xcc>
{
    8000169a:	715d                	addi	sp,sp,-80
    8000169c:	e486                	sd	ra,72(sp)
    8000169e:	e0a2                	sd	s0,64(sp)
    800016a0:	fc26                	sd	s1,56(sp)
    800016a2:	f84a                	sd	s2,48(sp)
    800016a4:	f44e                	sd	s3,40(sp)
    800016a6:	f052                	sd	s4,32(sp)
    800016a8:	ec56                	sd	s5,24(sp)
    800016aa:	e85a                	sd	s6,16(sp)
    800016ac:	e45e                	sd	s7,8(sp)
    800016ae:	0880                	addi	s0,sp,80
    800016b0:	8b2a                	mv	s6,a0
    800016b2:	8aae                	mv	s5,a1
    800016b4:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016b6:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800016b8:	4601                	li	a2,0
    800016ba:	85ce                	mv	a1,s3
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99a080e7          	jalr	-1638(ra) # 80001058 <walk>
    800016c6:	c531                	beqz	a0,80001712 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016c8:	6118                	ld	a4,0(a0)
    800016ca:	00177793          	andi	a5,a4,1
    800016ce:	cbb1                	beqz	a5,80001722 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016d0:	00a75593          	srli	a1,a4,0xa
    800016d4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016d8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800016dc:	fffff097          	auipc	ra,0xfffff
    800016e0:	2a0080e7          	jalr	672(ra) # 8000097c <kalloc>
    800016e4:	892a                	mv	s2,a0
    800016e6:	c939                	beqz	a0,8000173c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016e8:	6605                	lui	a2,0x1
    800016ea:	85de                	mv	a1,s7
    800016ec:	fffff097          	auipc	ra,0xfffff
    800016f0:	6f2080e7          	jalr	1778(ra) # 80000dde <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016f4:	8726                	mv	a4,s1
    800016f6:	86ca                	mv	a3,s2
    800016f8:	6605                	lui	a2,0x1
    800016fa:	85ce                	mv	a1,s3
    800016fc:	8556                	mv	a0,s5
    800016fe:	00000097          	auipc	ra,0x0
    80001702:	b2e080e7          	jalr	-1234(ra) # 8000122c <mappages>
    80001706:	e515                	bnez	a0,80001732 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001708:	6785                	lui	a5,0x1
    8000170a:	99be                	add	s3,s3,a5
    8000170c:	fb49e6e3          	bltu	s3,s4,800016b8 <uvmcopy+0x20>
    80001710:	a83d                	j	8000174e <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    80001712:	00008517          	auipc	a0,0x8
    80001716:	cbe50513          	addi	a0,a0,-834 # 800093d0 <userret+0x340>
    8000171a:	fffff097          	auipc	ra,0xfffff
    8000171e:	e40080e7          	jalr	-448(ra) # 8000055a <panic>
      panic("uvmcopy: page not present");
    80001722:	00008517          	auipc	a0,0x8
    80001726:	cce50513          	addi	a0,a0,-818 # 800093f0 <userret+0x360>
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	e30080e7          	jalr	-464(ra) # 8000055a <panic>
      kfree(mem);
    80001732:	854a                	mv	a0,s2
    80001734:	fffff097          	auipc	ra,0xfffff
    80001738:	14c080e7          	jalr	332(ra) # 80000880 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    8000173c:	4685                	li	a3,1
    8000173e:	864e                	mv	a2,s3
    80001740:	4581                	li	a1,0
    80001742:	8556                	mv	a0,s5
    80001744:	00000097          	auipc	ra,0x0
    80001748:	cc0080e7          	jalr	-832(ra) # 80001404 <uvmunmap>
  return -1;
    8000174c:	557d                	li	a0,-1
}
    8000174e:	60a6                	ld	ra,72(sp)
    80001750:	6406                	ld	s0,64(sp)
    80001752:	74e2                	ld	s1,56(sp)
    80001754:	7942                	ld	s2,48(sp)
    80001756:	79a2                	ld	s3,40(sp)
    80001758:	7a02                	ld	s4,32(sp)
    8000175a:	6ae2                	ld	s5,24(sp)
    8000175c:	6b42                	ld	s6,16(sp)
    8000175e:	6ba2                	ld	s7,8(sp)
    80001760:	6161                	addi	sp,sp,80
    80001762:	8082                	ret
  return 0;
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret

0000000080001768 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001768:	1141                	addi	sp,sp,-16
    8000176a:	e406                	sd	ra,8(sp)
    8000176c:	e022                	sd	s0,0(sp)
    8000176e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001770:	4601                	li	a2,0
    80001772:	00000097          	auipc	ra,0x0
    80001776:	8e6080e7          	jalr	-1818(ra) # 80001058 <walk>
  if(pte == 0)
    8000177a:	c901                	beqz	a0,8000178a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000177c:	611c                	ld	a5,0(a0)
    8000177e:	9bbd                	andi	a5,a5,-17
    80001780:	e11c                	sd	a5,0(a0)
}
    80001782:	60a2                	ld	ra,8(sp)
    80001784:	6402                	ld	s0,0(sp)
    80001786:	0141                	addi	sp,sp,16
    80001788:	8082                	ret
    panic("uvmclear");
    8000178a:	00008517          	auipc	a0,0x8
    8000178e:	c8650513          	addi	a0,a0,-890 # 80009410 <userret+0x380>
    80001792:	fffff097          	auipc	ra,0xfffff
    80001796:	dc8080e7          	jalr	-568(ra) # 8000055a <panic>

000000008000179a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000179a:	c6bd                	beqz	a3,80001808 <copyout+0x6e>
{
    8000179c:	715d                	addi	sp,sp,-80
    8000179e:	e486                	sd	ra,72(sp)
    800017a0:	e0a2                	sd	s0,64(sp)
    800017a2:	fc26                	sd	s1,56(sp)
    800017a4:	f84a                	sd	s2,48(sp)
    800017a6:	f44e                	sd	s3,40(sp)
    800017a8:	f052                	sd	s4,32(sp)
    800017aa:	ec56                	sd	s5,24(sp)
    800017ac:	e85a                	sd	s6,16(sp)
    800017ae:	e45e                	sd	s7,8(sp)
    800017b0:	e062                	sd	s8,0(sp)
    800017b2:	0880                	addi	s0,sp,80
    800017b4:	8b2a                	mv	s6,a0
    800017b6:	8c2e                	mv	s8,a1
    800017b8:	8a32                	mv	s4,a2
    800017ba:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017bc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017be:	6a85                	lui	s5,0x1
    800017c0:	a015                	j	800017e4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017c2:	9562                	add	a0,a0,s8
    800017c4:	0004861b          	sext.w	a2,s1
    800017c8:	85d2                	mv	a1,s4
    800017ca:	41250533          	sub	a0,a0,s2
    800017ce:	fffff097          	auipc	ra,0xfffff
    800017d2:	610080e7          	jalr	1552(ra) # 80000dde <memmove>

    len -= n;
    800017d6:	409989b3          	sub	s3,s3,s1
    src += n;
    800017da:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800017dc:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017e0:	02098263          	beqz	s3,80001804 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017e4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017e8:	85ca                	mv	a1,s2
    800017ea:	855a                	mv	a0,s6
    800017ec:	00000097          	auipc	ra,0x0
    800017f0:	9a0080e7          	jalr	-1632(ra) # 8000118c <walkaddr>
    if(pa0 == 0)
    800017f4:	cd01                	beqz	a0,8000180c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017f6:	418904b3          	sub	s1,s2,s8
    800017fa:	94d6                	add	s1,s1,s5
    if(n > len)
    800017fc:	fc99f3e3          	bgeu	s3,s1,800017c2 <copyout+0x28>
    80001800:	84ce                	mv	s1,s3
    80001802:	b7c1                	j	800017c2 <copyout+0x28>
  }
  return 0;
    80001804:	4501                	li	a0,0
    80001806:	a021                	j	8000180e <copyout+0x74>
    80001808:	4501                	li	a0,0
}
    8000180a:	8082                	ret
      return -1;
    8000180c:	557d                	li	a0,-1
}
    8000180e:	60a6                	ld	ra,72(sp)
    80001810:	6406                	ld	s0,64(sp)
    80001812:	74e2                	ld	s1,56(sp)
    80001814:	7942                	ld	s2,48(sp)
    80001816:	79a2                	ld	s3,40(sp)
    80001818:	7a02                	ld	s4,32(sp)
    8000181a:	6ae2                	ld	s5,24(sp)
    8000181c:	6b42                	ld	s6,16(sp)
    8000181e:	6ba2                	ld	s7,8(sp)
    80001820:	6c02                	ld	s8,0(sp)
    80001822:	6161                	addi	sp,sp,80
    80001824:	8082                	ret

0000000080001826 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001826:	c6bd                	beqz	a3,80001894 <copyin+0x6e>
{
    80001828:	715d                	addi	sp,sp,-80
    8000182a:	e486                	sd	ra,72(sp)
    8000182c:	e0a2                	sd	s0,64(sp)
    8000182e:	fc26                	sd	s1,56(sp)
    80001830:	f84a                	sd	s2,48(sp)
    80001832:	f44e                	sd	s3,40(sp)
    80001834:	f052                	sd	s4,32(sp)
    80001836:	ec56                	sd	s5,24(sp)
    80001838:	e85a                	sd	s6,16(sp)
    8000183a:	e45e                	sd	s7,8(sp)
    8000183c:	e062                	sd	s8,0(sp)
    8000183e:	0880                	addi	s0,sp,80
    80001840:	8b2a                	mv	s6,a0
    80001842:	8a2e                	mv	s4,a1
    80001844:	8c32                	mv	s8,a2
    80001846:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001848:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000184a:	6a85                	lui	s5,0x1
    8000184c:	a015                	j	80001870 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000184e:	9562                	add	a0,a0,s8
    80001850:	0004861b          	sext.w	a2,s1
    80001854:	412505b3          	sub	a1,a0,s2
    80001858:	8552                	mv	a0,s4
    8000185a:	fffff097          	auipc	ra,0xfffff
    8000185e:	584080e7          	jalr	1412(ra) # 80000dde <memmove>

    len -= n;
    80001862:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001866:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001868:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000186c:	02098263          	beqz	s3,80001890 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001870:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001874:	85ca                	mv	a1,s2
    80001876:	855a                	mv	a0,s6
    80001878:	00000097          	auipc	ra,0x0
    8000187c:	914080e7          	jalr	-1772(ra) # 8000118c <walkaddr>
    if(pa0 == 0)
    80001880:	cd01                	beqz	a0,80001898 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001882:	418904b3          	sub	s1,s2,s8
    80001886:	94d6                	add	s1,s1,s5
    if(n > len)
    80001888:	fc99f3e3          	bgeu	s3,s1,8000184e <copyin+0x28>
    8000188c:	84ce                	mv	s1,s3
    8000188e:	b7c1                	j	8000184e <copyin+0x28>
  }
  return 0;
    80001890:	4501                	li	a0,0
    80001892:	a021                	j	8000189a <copyin+0x74>
    80001894:	4501                	li	a0,0
}
    80001896:	8082                	ret
      return -1;
    80001898:	557d                	li	a0,-1
}
    8000189a:	60a6                	ld	ra,72(sp)
    8000189c:	6406                	ld	s0,64(sp)
    8000189e:	74e2                	ld	s1,56(sp)
    800018a0:	7942                	ld	s2,48(sp)
    800018a2:	79a2                	ld	s3,40(sp)
    800018a4:	7a02                	ld	s4,32(sp)
    800018a6:	6ae2                	ld	s5,24(sp)
    800018a8:	6b42                	ld	s6,16(sp)
    800018aa:	6ba2                	ld	s7,8(sp)
    800018ac:	6c02                	ld	s8,0(sp)
    800018ae:	6161                	addi	sp,sp,80
    800018b0:	8082                	ret

00000000800018b2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018b2:	c6c5                	beqz	a3,8000195a <copyinstr+0xa8>
{
    800018b4:	715d                	addi	sp,sp,-80
    800018b6:	e486                	sd	ra,72(sp)
    800018b8:	e0a2                	sd	s0,64(sp)
    800018ba:	fc26                	sd	s1,56(sp)
    800018bc:	f84a                	sd	s2,48(sp)
    800018be:	f44e                	sd	s3,40(sp)
    800018c0:	f052                	sd	s4,32(sp)
    800018c2:	ec56                	sd	s5,24(sp)
    800018c4:	e85a                	sd	s6,16(sp)
    800018c6:	e45e                	sd	s7,8(sp)
    800018c8:	0880                	addi	s0,sp,80
    800018ca:	8a2a                	mv	s4,a0
    800018cc:	8b2e                	mv	s6,a1
    800018ce:	8bb2                	mv	s7,a2
    800018d0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800018d2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018d4:	6985                	lui	s3,0x1
    800018d6:	a035                	j	80001902 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800018d8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800018dc:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800018de:	0017b793          	seqz	a5,a5
    800018e2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800018e6:	60a6                	ld	ra,72(sp)
    800018e8:	6406                	ld	s0,64(sp)
    800018ea:	74e2                	ld	s1,56(sp)
    800018ec:	7942                	ld	s2,48(sp)
    800018ee:	79a2                	ld	s3,40(sp)
    800018f0:	7a02                	ld	s4,32(sp)
    800018f2:	6ae2                	ld	s5,24(sp)
    800018f4:	6b42                	ld	s6,16(sp)
    800018f6:	6ba2                	ld	s7,8(sp)
    800018f8:	6161                	addi	sp,sp,80
    800018fa:	8082                	ret
    srcva = va0 + PGSIZE;
    800018fc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001900:	c8a9                	beqz	s1,80001952 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001902:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001906:	85ca                	mv	a1,s2
    80001908:	8552                	mv	a0,s4
    8000190a:	00000097          	auipc	ra,0x0
    8000190e:	882080e7          	jalr	-1918(ra) # 8000118c <walkaddr>
    if(pa0 == 0)
    80001912:	c131                	beqz	a0,80001956 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001914:	41790833          	sub	a6,s2,s7
    80001918:	984e                	add	a6,a6,s3
    if(n > max)
    8000191a:	0104f363          	bgeu	s1,a6,80001920 <copyinstr+0x6e>
    8000191e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001920:	955e                	add	a0,a0,s7
    80001922:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001926:	fc080be3          	beqz	a6,800018fc <copyinstr+0x4a>
    8000192a:	985a                	add	a6,a6,s6
    8000192c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000192e:	41650633          	sub	a2,a0,s6
    80001932:	14fd                	addi	s1,s1,-1
    80001934:	9b26                	add	s6,s6,s1
    80001936:	00f60733          	add	a4,a2,a5
    8000193a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd5c54>
    8000193e:	df49                	beqz	a4,800018d8 <copyinstr+0x26>
        *dst = *p;
    80001940:	00e78023          	sb	a4,0(a5)
      --max;
    80001944:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001948:	0785                	addi	a5,a5,1
    while(n > 0){
    8000194a:	ff0796e3          	bne	a5,a6,80001936 <copyinstr+0x84>
      dst++;
    8000194e:	8b42                	mv	s6,a6
    80001950:	b775                	j	800018fc <copyinstr+0x4a>
    80001952:	4781                	li	a5,0
    80001954:	b769                	j	800018de <copyinstr+0x2c>
      return -1;
    80001956:	557d                	li	a0,-1
    80001958:	b779                	j	800018e6 <copyinstr+0x34>
  int got_null = 0;
    8000195a:	4781                	li	a5,0
  if(got_null){
    8000195c:	0017b793          	seqz	a5,a5
    80001960:	40f00533          	neg	a0,a5
}
    80001964:	8082                	ret

0000000080001966 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001966:	1101                	addi	sp,sp,-32
    80001968:	ec06                	sd	ra,24(sp)
    8000196a:	e822                	sd	s0,16(sp)
    8000196c:	e426                	sd	s1,8(sp)
    8000196e:	1000                	addi	s0,sp,32
    80001970:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001972:	fffff097          	auipc	ra,0xfffff
    80001976:	0c0080e7          	jalr	192(ra) # 80000a32 <holding>
    8000197a:	c909                	beqz	a0,8000198c <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    8000197c:	789c                	ld	a5,48(s1)
    8000197e:	00978f63          	beq	a5,s1,8000199c <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001982:	60e2                	ld	ra,24(sp)
    80001984:	6442                	ld	s0,16(sp)
    80001986:	64a2                	ld	s1,8(sp)
    80001988:	6105                	addi	sp,sp,32
    8000198a:	8082                	ret
    panic("wakeup1");
    8000198c:	00008517          	auipc	a0,0x8
    80001990:	a9450513          	addi	a0,a0,-1388 # 80009420 <userret+0x390>
    80001994:	fffff097          	auipc	ra,0xfffff
    80001998:	bc6080e7          	jalr	-1082(ra) # 8000055a <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000199c:	5098                	lw	a4,32(s1)
    8000199e:	4785                	li	a5,1
    800019a0:	fef711e3          	bne	a4,a5,80001982 <wakeup1+0x1c>
    p->state = RUNNABLE;
    800019a4:	4789                	li	a5,2
    800019a6:	d09c                	sw	a5,32(s1)
}
    800019a8:	bfe9                	j	80001982 <wakeup1+0x1c>

00000000800019aa <procinit>:
{
    800019aa:	715d                	addi	sp,sp,-80
    800019ac:	e486                	sd	ra,72(sp)
    800019ae:	e0a2                	sd	s0,64(sp)
    800019b0:	fc26                	sd	s1,56(sp)
    800019b2:	f84a                	sd	s2,48(sp)
    800019b4:	f44e                	sd	s3,40(sp)
    800019b6:	f052                	sd	s4,32(sp)
    800019b8:	ec56                	sd	s5,24(sp)
    800019ba:	e85a                	sd	s6,16(sp)
    800019bc:	e45e                	sd	s7,8(sp)
    800019be:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800019c0:	00008597          	auipc	a1,0x8
    800019c4:	a6858593          	addi	a1,a1,-1432 # 80009428 <userret+0x398>
    800019c8:	00014517          	auipc	a0,0x14
    800019cc:	e7850513          	addi	a0,a0,-392 # 80015840 <pid_lock>
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	00c080e7          	jalr	12(ra) # 800009dc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d8:	00014917          	auipc	s2,0x14
    800019dc:	28890913          	addi	s2,s2,648 # 80015c60 <proc>
      initlock(&p->lock, "proc");
    800019e0:	00008a17          	auipc	s4,0x8
    800019e4:	a50a0a13          	addi	s4,s4,-1456 # 80009430 <userret+0x3a0>
      uint64 va = KSTACK((int) (p - proc));
    800019e8:	8bca                	mv	s7,s2
    800019ea:	00008b17          	auipc	s6,0x8
    800019ee:	59eb0b13          	addi	s6,s6,1438 # 80009f88 <syscalls+0xc0>
    800019f2:	040009b7          	lui	s3,0x4000
    800019f6:	19fd                	addi	s3,s3,-1
    800019f8:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019fa:	00015a97          	auipc	s5,0x15
    800019fe:	0c6a8a93          	addi	s5,s5,198 # 80016ac0 <tickslock>
      initlock(&p->lock, "proc");
    80001a02:	85d2                	mv	a1,s4
    80001a04:	854a                	mv	a0,s2
    80001a06:	fffff097          	auipc	ra,0xfffff
    80001a0a:	fd6080e7          	jalr	-42(ra) # 800009dc <initlock>
      char *pa = kalloc();
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	f6e080e7          	jalr	-146(ra) # 8000097c <kalloc>
    80001a16:	85aa                	mv	a1,a0
      if(pa == 0)
    80001a18:	c929                	beqz	a0,80001a6a <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001a1a:	417904b3          	sub	s1,s2,s7
    80001a1e:	8491                	srai	s1,s1,0x4
    80001a20:	000b3783          	ld	a5,0(s6)
    80001a24:	02f484b3          	mul	s1,s1,a5
    80001a28:	2485                	addiw	s1,s1,1
    80001a2a:	00d4949b          	slliw	s1,s1,0xd
    80001a2e:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a32:	4699                	li	a3,6
    80001a34:	6605                	lui	a2,0x1
    80001a36:	8526                	mv	a0,s1
    80001a38:	00000097          	auipc	ra,0x0
    80001a3c:	882080e7          	jalr	-1918(ra) # 800012ba <kvmmap>
      p->kstack = va;
    80001a40:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a44:	17090913          	addi	s2,s2,368
    80001a48:	fb591de3          	bne	s2,s5,80001a02 <procinit+0x58>
  kvminithart();
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	71c080e7          	jalr	1820(ra) # 80001168 <kvminithart>
}
    80001a54:	60a6                	ld	ra,72(sp)
    80001a56:	6406                	ld	s0,64(sp)
    80001a58:	74e2                	ld	s1,56(sp)
    80001a5a:	7942                	ld	s2,48(sp)
    80001a5c:	79a2                	ld	s3,40(sp)
    80001a5e:	7a02                	ld	s4,32(sp)
    80001a60:	6ae2                	ld	s5,24(sp)
    80001a62:	6b42                	ld	s6,16(sp)
    80001a64:	6ba2                	ld	s7,8(sp)
    80001a66:	6161                	addi	sp,sp,80
    80001a68:	8082                	ret
        panic("kalloc");
    80001a6a:	00008517          	auipc	a0,0x8
    80001a6e:	9ce50513          	addi	a0,a0,-1586 # 80009438 <userret+0x3a8>
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	ae8080e7          	jalr	-1304(ra) # 8000055a <panic>

0000000080001a7a <cpuid>:
{
    80001a7a:	1141                	addi	sp,sp,-16
    80001a7c:	e422                	sd	s0,8(sp)
    80001a7e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a80:	8512                	mv	a0,tp
}
    80001a82:	2501                	sext.w	a0,a0
    80001a84:	6422                	ld	s0,8(sp)
    80001a86:	0141                	addi	sp,sp,16
    80001a88:	8082                	ret

0000000080001a8a <mycpu>:
mycpu(void) {
    80001a8a:	1141                	addi	sp,sp,-16
    80001a8c:	e422                	sd	s0,8(sp)
    80001a8e:	0800                	addi	s0,sp,16
    80001a90:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a92:	2781                	sext.w	a5,a5
    80001a94:	079e                	slli	a5,a5,0x7
}
    80001a96:	00014517          	auipc	a0,0x14
    80001a9a:	dca50513          	addi	a0,a0,-566 # 80015860 <cpus>
    80001a9e:	953e                	add	a0,a0,a5
    80001aa0:	6422                	ld	s0,8(sp)
    80001aa2:	0141                	addi	sp,sp,16
    80001aa4:	8082                	ret

0000000080001aa6 <myproc>:
myproc(void) {
    80001aa6:	1101                	addi	sp,sp,-32
    80001aa8:	ec06                	sd	ra,24(sp)
    80001aaa:	e822                	sd	s0,16(sp)
    80001aac:	e426                	sd	s1,8(sp)
    80001aae:	1000                	addi	s0,sp,32
  push_off();
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	fb0080e7          	jalr	-80(ra) # 80000a60 <push_off>
    80001ab8:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001aba:	2781                	sext.w	a5,a5
    80001abc:	079e                	slli	a5,a5,0x7
    80001abe:	00014717          	auipc	a4,0x14
    80001ac2:	d8270713          	addi	a4,a4,-638 # 80015840 <pid_lock>
    80001ac6:	97ba                	add	a5,a5,a4
    80001ac8:	7384                	ld	s1,32(a5)
  pop_off();
    80001aca:	fffff097          	auipc	ra,0xfffff
    80001ace:	056080e7          	jalr	86(ra) # 80000b20 <pop_off>
}
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	60e2                	ld	ra,24(sp)
    80001ad6:	6442                	ld	s0,16(sp)
    80001ad8:	64a2                	ld	s1,8(sp)
    80001ada:	6105                	addi	sp,sp,32
    80001adc:	8082                	ret

0000000080001ade <forkret>:
{
    80001ade:	1141                	addi	sp,sp,-16
    80001ae0:	e406                	sd	ra,8(sp)
    80001ae2:	e022                	sd	s0,0(sp)
    80001ae4:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001ae6:	00000097          	auipc	ra,0x0
    80001aea:	fc0080e7          	jalr	-64(ra) # 80001aa6 <myproc>
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	092080e7          	jalr	146(ra) # 80000b80 <release>
  if (first) {
    80001af6:	00008797          	auipc	a5,0x8
    80001afa:	5427a783          	lw	a5,1346(a5) # 8000a038 <first.1787>
    80001afe:	eb89                	bnez	a5,80001b10 <forkret+0x32>
  usertrapret();
    80001b00:	00001097          	auipc	ra,0x1
    80001b04:	c60080e7          	jalr	-928(ra) # 80002760 <usertrapret>
}
    80001b08:	60a2                	ld	ra,8(sp)
    80001b0a:	6402                	ld	s0,0(sp)
    80001b0c:	0141                	addi	sp,sp,16
    80001b0e:	8082                	ret
    first = 0;
    80001b10:	00008797          	auipc	a5,0x8
    80001b14:	5207a423          	sw	zero,1320(a5) # 8000a038 <first.1787>
    fsinit(minor(ROOTDEV));
    80001b18:	4501                	li	a0,0
    80001b1a:	00002097          	auipc	ra,0x2
    80001b1e:	9b2080e7          	jalr	-1614(ra) # 800034cc <fsinit>
    80001b22:	bff9                	j	80001b00 <forkret+0x22>

0000000080001b24 <allocpid>:
allocpid() {
    80001b24:	1101                	addi	sp,sp,-32
    80001b26:	ec06                	sd	ra,24(sp)
    80001b28:	e822                	sd	s0,16(sp)
    80001b2a:	e426                	sd	s1,8(sp)
    80001b2c:	e04a                	sd	s2,0(sp)
    80001b2e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b30:	00014917          	auipc	s2,0x14
    80001b34:	d1090913          	addi	s2,s2,-752 # 80015840 <pid_lock>
    80001b38:	854a                	mv	a0,s2
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	f76080e7          	jalr	-138(ra) # 80000ab0 <acquire>
  pid = nextpid;
    80001b42:	00008797          	auipc	a5,0x8
    80001b46:	4fa78793          	addi	a5,a5,1274 # 8000a03c <nextpid>
    80001b4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b4c:	0014871b          	addiw	a4,s1,1
    80001b50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b52:	854a                	mv	a0,s2
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	02c080e7          	jalr	44(ra) # 80000b80 <release>
}
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	60e2                	ld	ra,24(sp)
    80001b60:	6442                	ld	s0,16(sp)
    80001b62:	64a2                	ld	s1,8(sp)
    80001b64:	6902                	ld	s2,0(sp)
    80001b66:	6105                	addi	sp,sp,32
    80001b68:	8082                	ret

0000000080001b6a <proc_pagetable>:
{
    80001b6a:	1101                	addi	sp,sp,-32
    80001b6c:	ec06                	sd	ra,24(sp)
    80001b6e:	e822                	sd	s0,16(sp)
    80001b70:	e426                	sd	s1,8(sp)
    80001b72:	e04a                	sd	s2,0(sp)
    80001b74:	1000                	addi	s0,sp,32
    80001b76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	954080e7          	jalr	-1708(ra) # 800014cc <uvmcreate>
    80001b80:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b82:	4729                	li	a4,10
    80001b84:	00007697          	auipc	a3,0x7
    80001b88:	47c68693          	addi	a3,a3,1148 # 80009000 <trampoline>
    80001b8c:	6605                	lui	a2,0x1
    80001b8e:	040005b7          	lui	a1,0x4000
    80001b92:	15fd                	addi	a1,a1,-1
    80001b94:	05b2                	slli	a1,a1,0xc
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	696080e7          	jalr	1686(ra) # 8000122c <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b9e:	4719                	li	a4,6
    80001ba0:	06093683          	ld	a3,96(s2)
    80001ba4:	6605                	lui	a2,0x1
    80001ba6:	020005b7          	lui	a1,0x2000
    80001baa:	15fd                	addi	a1,a1,-1
    80001bac:	05b6                	slli	a1,a1,0xd
    80001bae:	8526                	mv	a0,s1
    80001bb0:	fffff097          	auipc	ra,0xfffff
    80001bb4:	67c080e7          	jalr	1660(ra) # 8000122c <mappages>
}
    80001bb8:	8526                	mv	a0,s1
    80001bba:	60e2                	ld	ra,24(sp)
    80001bbc:	6442                	ld	s0,16(sp)
    80001bbe:	64a2                	ld	s1,8(sp)
    80001bc0:	6902                	ld	s2,0(sp)
    80001bc2:	6105                	addi	sp,sp,32
    80001bc4:	8082                	ret

0000000080001bc6 <allocproc>:
{
    80001bc6:	1101                	addi	sp,sp,-32
    80001bc8:	ec06                	sd	ra,24(sp)
    80001bca:	e822                	sd	s0,16(sp)
    80001bcc:	e426                	sd	s1,8(sp)
    80001bce:	e04a                	sd	s2,0(sp)
    80001bd0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd2:	00014497          	auipc	s1,0x14
    80001bd6:	08e48493          	addi	s1,s1,142 # 80015c60 <proc>
    80001bda:	00015917          	auipc	s2,0x15
    80001bde:	ee690913          	addi	s2,s2,-282 # 80016ac0 <tickslock>
    acquire(&p->lock);
    80001be2:	8526                	mv	a0,s1
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	ecc080e7          	jalr	-308(ra) # 80000ab0 <acquire>
    if(p->state == UNUSED) {
    80001bec:	509c                	lw	a5,32(s1)
    80001bee:	c395                	beqz	a5,80001c12 <allocproc+0x4c>
      release(&p->lock);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	f8e080e7          	jalr	-114(ra) # 80000b80 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bfa:	17048493          	addi	s1,s1,368
    80001bfe:	ff2492e3          	bne	s1,s2,80001be2 <allocproc+0x1c>
  return 0;
    80001c02:	4481                	li	s1,0
}
    80001c04:	8526                	mv	a0,s1
    80001c06:	60e2                	ld	ra,24(sp)
    80001c08:	6442                	ld	s0,16(sp)
    80001c0a:	64a2                	ld	s1,8(sp)
    80001c0c:	6902                	ld	s2,0(sp)
    80001c0e:	6105                	addi	sp,sp,32
    80001c10:	8082                	ret
  p->pid = allocpid();
    80001c12:	00000097          	auipc	ra,0x0
    80001c16:	f12080e7          	jalr	-238(ra) # 80001b24 <allocpid>
    80001c1a:	c0a8                	sw	a0,64(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001c1c:	fffff097          	auipc	ra,0xfffff
    80001c20:	d60080e7          	jalr	-672(ra) # 8000097c <kalloc>
    80001c24:	892a                	mv	s2,a0
    80001c26:	f0a8                	sd	a0,96(s1)
    80001c28:	c915                	beqz	a0,80001c5c <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	00000097          	auipc	ra,0x0
    80001c30:	f3e080e7          	jalr	-194(ra) # 80001b6a <proc_pagetable>
    80001c34:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001c36:	07000613          	li	a2,112
    80001c3a:	4581                	li	a1,0
    80001c3c:	06848513          	addi	a0,s1,104
    80001c40:	fffff097          	auipc	ra,0xfffff
    80001c44:	13e080e7          	jalr	318(ra) # 80000d7e <memset>
  p->context.ra = (uint64)forkret;
    80001c48:	00000797          	auipc	a5,0x0
    80001c4c:	e9678793          	addi	a5,a5,-362 # 80001ade <forkret>
    80001c50:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c52:	64bc                	ld	a5,72(s1)
    80001c54:	6705                	lui	a4,0x1
    80001c56:	97ba                	add	a5,a5,a4
    80001c58:	f8bc                	sd	a5,112(s1)
  return p;
    80001c5a:	b76d                	j	80001c04 <allocproc+0x3e>
    release(&p->lock);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	fffff097          	auipc	ra,0xfffff
    80001c62:	f22080e7          	jalr	-222(ra) # 80000b80 <release>
    return 0;
    80001c66:	84ca                	mv	s1,s2
    80001c68:	bf71                	j	80001c04 <allocproc+0x3e>

0000000080001c6a <proc_freepagetable>:
{
    80001c6a:	1101                	addi	sp,sp,-32
    80001c6c:	ec06                	sd	ra,24(sp)
    80001c6e:	e822                	sd	s0,16(sp)
    80001c70:	e426                	sd	s1,8(sp)
    80001c72:	e04a                	sd	s2,0(sp)
    80001c74:	1000                	addi	s0,sp,32
    80001c76:	84aa                	mv	s1,a0
    80001c78:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001c7a:	4681                	li	a3,0
    80001c7c:	6605                	lui	a2,0x1
    80001c7e:	040005b7          	lui	a1,0x4000
    80001c82:	15fd                	addi	a1,a1,-1
    80001c84:	05b2                	slli	a1,a1,0xc
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	77e080e7          	jalr	1918(ra) # 80001404 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001c8e:	4681                	li	a3,0
    80001c90:	6605                	lui	a2,0x1
    80001c92:	020005b7          	lui	a1,0x2000
    80001c96:	15fd                	addi	a1,a1,-1
    80001c98:	05b6                	slli	a1,a1,0xd
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	768080e7          	jalr	1896(ra) # 80001404 <uvmunmap>
  if(sz > 0)
    80001ca4:	00091863          	bnez	s2,80001cb4 <proc_freepagetable+0x4a>
}
    80001ca8:	60e2                	ld	ra,24(sp)
    80001caa:	6442                	ld	s0,16(sp)
    80001cac:	64a2                	ld	s1,8(sp)
    80001cae:	6902                	ld	s2,0(sp)
    80001cb0:	6105                	addi	sp,sp,32
    80001cb2:	8082                	ret
    uvmfree(pagetable, sz);
    80001cb4:	85ca                	mv	a1,s2
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	00000097          	auipc	ra,0x0
    80001cbc:	9b2080e7          	jalr	-1614(ra) # 8000166a <uvmfree>
}
    80001cc0:	b7e5                	j	80001ca8 <proc_freepagetable+0x3e>

0000000080001cc2 <freeproc>:
{
    80001cc2:	1101                	addi	sp,sp,-32
    80001cc4:	ec06                	sd	ra,24(sp)
    80001cc6:	e822                	sd	s0,16(sp)
    80001cc8:	e426                	sd	s1,8(sp)
    80001cca:	1000                	addi	s0,sp,32
    80001ccc:	84aa                	mv	s1,a0
  if(p->tf)
    80001cce:	7128                	ld	a0,96(a0)
    80001cd0:	c509                	beqz	a0,80001cda <freeproc+0x18>
    kfree((void*)p->tf);
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	bae080e7          	jalr	-1106(ra) # 80000880 <kfree>
  p->tf = 0;
    80001cda:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001cde:	6ca8                	ld	a0,88(s1)
    80001ce0:	c511                	beqz	a0,80001cec <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ce2:	68ac                	ld	a1,80(s1)
    80001ce4:	00000097          	auipc	ra,0x0
    80001ce8:	f86080e7          	jalr	-122(ra) # 80001c6a <proc_freepagetable>
  p->pagetable = 0;
    80001cec:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001cf0:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001cf4:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001cf8:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001cfc:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001d00:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001d04:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001d08:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001d0c:	0204a023          	sw	zero,32(s1)
}
    80001d10:	60e2                	ld	ra,24(sp)
    80001d12:	6442                	ld	s0,16(sp)
    80001d14:	64a2                	ld	s1,8(sp)
    80001d16:	6105                	addi	sp,sp,32
    80001d18:	8082                	ret

0000000080001d1a <userinit>:
{
    80001d1a:	1101                	addi	sp,sp,-32
    80001d1c:	ec06                	sd	ra,24(sp)
    80001d1e:	e822                	sd	s0,16(sp)
    80001d20:	e426                	sd	s1,8(sp)
    80001d22:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d24:	00000097          	auipc	ra,0x0
    80001d28:	ea2080e7          	jalr	-350(ra) # 80001bc6 <allocproc>
    80001d2c:	84aa                	mv	s1,a0
  initproc = p;
    80001d2e:	00027797          	auipc	a5,0x27
    80001d32:	64a7b523          	sd	a0,1610(a5) # 80029378 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d36:	03300613          	li	a2,51
    80001d3a:	00008597          	auipc	a1,0x8
    80001d3e:	2c658593          	addi	a1,a1,710 # 8000a000 <initcode>
    80001d42:	6d28                	ld	a0,88(a0)
    80001d44:	fffff097          	auipc	ra,0xfffff
    80001d48:	7c6080e7          	jalr	1990(ra) # 8000150a <uvminit>
  p->sz = PGSIZE;
    80001d4c:	6785                	lui	a5,0x1
    80001d4e:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001d50:	70b8                	ld	a4,96(s1)
    80001d52:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001d56:	70b8                	ld	a4,96(s1)
    80001d58:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d5a:	4641                	li	a2,16
    80001d5c:	00007597          	auipc	a1,0x7
    80001d60:	6e458593          	addi	a1,a1,1764 # 80009440 <userret+0x3b0>
    80001d64:	16048513          	addi	a0,s1,352
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	16c080e7          	jalr	364(ra) # 80000ed4 <safestrcpy>
  p->cwd = namei("/");
    80001d70:	00007517          	auipc	a0,0x7
    80001d74:	6e050513          	addi	a0,a0,1760 # 80009450 <userret+0x3c0>
    80001d78:	00002097          	auipc	ra,0x2
    80001d7c:	156080e7          	jalr	342(ra) # 80003ece <namei>
    80001d80:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d84:	4789                	li	a5,2
    80001d86:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001d88:	8526                	mv	a0,s1
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	df6080e7          	jalr	-522(ra) # 80000b80 <release>
}
    80001d92:	60e2                	ld	ra,24(sp)
    80001d94:	6442                	ld	s0,16(sp)
    80001d96:	64a2                	ld	s1,8(sp)
    80001d98:	6105                	addi	sp,sp,32
    80001d9a:	8082                	ret

0000000080001d9c <growproc>:
{
    80001d9c:	1101                	addi	sp,sp,-32
    80001d9e:	ec06                	sd	ra,24(sp)
    80001da0:	e822                	sd	s0,16(sp)
    80001da2:	e426                	sd	s1,8(sp)
    80001da4:	e04a                	sd	s2,0(sp)
    80001da6:	1000                	addi	s0,sp,32
    80001da8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001daa:	00000097          	auipc	ra,0x0
    80001dae:	cfc080e7          	jalr	-772(ra) # 80001aa6 <myproc>
    80001db2:	892a                	mv	s2,a0
  sz = p->sz;
    80001db4:	692c                	ld	a1,80(a0)
    80001db6:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001dba:	00904f63          	bgtz	s1,80001dd8 <growproc+0x3c>
  } else if(n < 0){
    80001dbe:	0204cc63          	bltz	s1,80001df6 <growproc+0x5a>
  p->sz = sz;
    80001dc2:	1602                	slli	a2,a2,0x20
    80001dc4:	9201                	srli	a2,a2,0x20
    80001dc6:	04c93823          	sd	a2,80(s2)
  return 0;
    80001dca:	4501                	li	a0,0
}
    80001dcc:	60e2                	ld	ra,24(sp)
    80001dce:	6442                	ld	s0,16(sp)
    80001dd0:	64a2                	ld	s1,8(sp)
    80001dd2:	6902                	ld	s2,0(sp)
    80001dd4:	6105                	addi	sp,sp,32
    80001dd6:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dd8:	9e25                	addw	a2,a2,s1
    80001dda:	1602                	slli	a2,a2,0x20
    80001ddc:	9201                	srli	a2,a2,0x20
    80001dde:	1582                	slli	a1,a1,0x20
    80001de0:	9181                	srli	a1,a1,0x20
    80001de2:	6d28                	ld	a0,88(a0)
    80001de4:	fffff097          	auipc	ra,0xfffff
    80001de8:	7dc080e7          	jalr	2012(ra) # 800015c0 <uvmalloc>
    80001dec:	0005061b          	sext.w	a2,a0
    80001df0:	fa69                	bnez	a2,80001dc2 <growproc+0x26>
      return -1;
    80001df2:	557d                	li	a0,-1
    80001df4:	bfe1                	j	80001dcc <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df6:	9e25                	addw	a2,a2,s1
    80001df8:	1602                	slli	a2,a2,0x20
    80001dfa:	9201                	srli	a2,a2,0x20
    80001dfc:	1582                	slli	a1,a1,0x20
    80001dfe:	9181                	srli	a1,a1,0x20
    80001e00:	6d28                	ld	a0,88(a0)
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	77a080e7          	jalr	1914(ra) # 8000157c <uvmdealloc>
    80001e0a:	0005061b          	sext.w	a2,a0
    80001e0e:	bf55                	j	80001dc2 <growproc+0x26>

0000000080001e10 <fork>:
{
    80001e10:	7179                	addi	sp,sp,-48
    80001e12:	f406                	sd	ra,40(sp)
    80001e14:	f022                	sd	s0,32(sp)
    80001e16:	ec26                	sd	s1,24(sp)
    80001e18:	e84a                	sd	s2,16(sp)
    80001e1a:	e44e                	sd	s3,8(sp)
    80001e1c:	e052                	sd	s4,0(sp)
    80001e1e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e20:	00000097          	auipc	ra,0x0
    80001e24:	c86080e7          	jalr	-890(ra) # 80001aa6 <myproc>
    80001e28:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e2a:	00000097          	auipc	ra,0x0
    80001e2e:	d9c080e7          	jalr	-612(ra) # 80001bc6 <allocproc>
    80001e32:	c175                	beqz	a0,80001f16 <fork+0x106>
    80001e34:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e36:	05093603          	ld	a2,80(s2)
    80001e3a:	6d2c                	ld	a1,88(a0)
    80001e3c:	05893503          	ld	a0,88(s2)
    80001e40:	00000097          	auipc	ra,0x0
    80001e44:	858080e7          	jalr	-1960(ra) # 80001698 <uvmcopy>
    80001e48:	04054863          	bltz	a0,80001e98 <fork+0x88>
  np->sz = p->sz;
    80001e4c:	05093783          	ld	a5,80(s2)
    80001e50:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->parent = p;
    80001e54:	0329b423          	sd	s2,40(s3)
  *(np->tf) = *(p->tf);
    80001e58:	06093683          	ld	a3,96(s2)
    80001e5c:	87b6                	mv	a5,a3
    80001e5e:	0609b703          	ld	a4,96(s3)
    80001e62:	12068693          	addi	a3,a3,288
    80001e66:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e6a:	6788                	ld	a0,8(a5)
    80001e6c:	6b8c                	ld	a1,16(a5)
    80001e6e:	6f90                	ld	a2,24(a5)
    80001e70:	01073023          	sd	a6,0(a4)
    80001e74:	e708                	sd	a0,8(a4)
    80001e76:	eb0c                	sd	a1,16(a4)
    80001e78:	ef10                	sd	a2,24(a4)
    80001e7a:	02078793          	addi	a5,a5,32
    80001e7e:	02070713          	addi	a4,a4,32
    80001e82:	fed792e3          	bne	a5,a3,80001e66 <fork+0x56>
  np->tf->a0 = 0;
    80001e86:	0609b783          	ld	a5,96(s3)
    80001e8a:	0607b823          	sd	zero,112(a5)
    80001e8e:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001e92:	15800a13          	li	s4,344
    80001e96:	a03d                	j	80001ec4 <fork+0xb4>
    freeproc(np);
    80001e98:	854e                	mv	a0,s3
    80001e9a:	00000097          	auipc	ra,0x0
    80001e9e:	e28080e7          	jalr	-472(ra) # 80001cc2 <freeproc>
    release(&np->lock);
    80001ea2:	854e                	mv	a0,s3
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	cdc080e7          	jalr	-804(ra) # 80000b80 <release>
    return -1;
    80001eac:	54fd                	li	s1,-1
    80001eae:	a899                	j	80001f04 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb0:	00002097          	auipc	ra,0x2
    80001eb4:	7c0080e7          	jalr	1984(ra) # 80004670 <filedup>
    80001eb8:	009987b3          	add	a5,s3,s1
    80001ebc:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001ebe:	04a1                	addi	s1,s1,8
    80001ec0:	01448763          	beq	s1,s4,80001ece <fork+0xbe>
    if(p->ofile[i])
    80001ec4:	009907b3          	add	a5,s2,s1
    80001ec8:	6388                	ld	a0,0(a5)
    80001eca:	f17d                	bnez	a0,80001eb0 <fork+0xa0>
    80001ecc:	bfcd                	j	80001ebe <fork+0xae>
  np->cwd = idup(p->cwd);
    80001ece:	15893503          	ld	a0,344(s2)
    80001ed2:	00002097          	auipc	ra,0x2
    80001ed6:	834080e7          	jalr	-1996(ra) # 80003706 <idup>
    80001eda:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ede:	4641                	li	a2,16
    80001ee0:	16090593          	addi	a1,s2,352
    80001ee4:	16098513          	addi	a0,s3,352
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	fec080e7          	jalr	-20(ra) # 80000ed4 <safestrcpy>
  pid = np->pid;
    80001ef0:	0409a483          	lw	s1,64(s3)
  np->state = RUNNABLE;
    80001ef4:	4789                	li	a5,2
    80001ef6:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    80001efa:	854e                	mv	a0,s3
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	c84080e7          	jalr	-892(ra) # 80000b80 <release>
}
    80001f04:	8526                	mv	a0,s1
    80001f06:	70a2                	ld	ra,40(sp)
    80001f08:	7402                	ld	s0,32(sp)
    80001f0a:	64e2                	ld	s1,24(sp)
    80001f0c:	6942                	ld	s2,16(sp)
    80001f0e:	69a2                	ld	s3,8(sp)
    80001f10:	6a02                	ld	s4,0(sp)
    80001f12:	6145                	addi	sp,sp,48
    80001f14:	8082                	ret
    return -1;
    80001f16:	54fd                	li	s1,-1
    80001f18:	b7f5                	j	80001f04 <fork+0xf4>

0000000080001f1a <reparent>:
{
    80001f1a:	7179                	addi	sp,sp,-48
    80001f1c:	f406                	sd	ra,40(sp)
    80001f1e:	f022                	sd	s0,32(sp)
    80001f20:	ec26                	sd	s1,24(sp)
    80001f22:	e84a                	sd	s2,16(sp)
    80001f24:	e44e                	sd	s3,8(sp)
    80001f26:	e052                	sd	s4,0(sp)
    80001f28:	1800                	addi	s0,sp,48
    80001f2a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f2c:	00014497          	auipc	s1,0x14
    80001f30:	d3448493          	addi	s1,s1,-716 # 80015c60 <proc>
      pp->parent = initproc;
    80001f34:	00027a17          	auipc	s4,0x27
    80001f38:	444a0a13          	addi	s4,s4,1092 # 80029378 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f3c:	00015997          	auipc	s3,0x15
    80001f40:	b8498993          	addi	s3,s3,-1148 # 80016ac0 <tickslock>
    80001f44:	a029                	j	80001f4e <reparent+0x34>
    80001f46:	17048493          	addi	s1,s1,368
    80001f4a:	03348363          	beq	s1,s3,80001f70 <reparent+0x56>
    if(pp->parent == p){
    80001f4e:	749c                	ld	a5,40(s1)
    80001f50:	ff279be3          	bne	a5,s2,80001f46 <reparent+0x2c>
      acquire(&pp->lock);
    80001f54:	8526                	mv	a0,s1
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	b5a080e7          	jalr	-1190(ra) # 80000ab0 <acquire>
      pp->parent = initproc;
    80001f5e:	000a3783          	ld	a5,0(s4)
    80001f62:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80001f64:	8526                	mv	a0,s1
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	c1a080e7          	jalr	-998(ra) # 80000b80 <release>
    80001f6e:	bfe1                	j	80001f46 <reparent+0x2c>
}
    80001f70:	70a2                	ld	ra,40(sp)
    80001f72:	7402                	ld	s0,32(sp)
    80001f74:	64e2                	ld	s1,24(sp)
    80001f76:	6942                	ld	s2,16(sp)
    80001f78:	69a2                	ld	s3,8(sp)
    80001f7a:	6a02                	ld	s4,0(sp)
    80001f7c:	6145                	addi	sp,sp,48
    80001f7e:	8082                	ret

0000000080001f80 <scheduler>:
{
    80001f80:	715d                	addi	sp,sp,-80
    80001f82:	e486                	sd	ra,72(sp)
    80001f84:	e0a2                	sd	s0,64(sp)
    80001f86:	fc26                	sd	s1,56(sp)
    80001f88:	f84a                	sd	s2,48(sp)
    80001f8a:	f44e                	sd	s3,40(sp)
    80001f8c:	f052                	sd	s4,32(sp)
    80001f8e:	ec56                	sd	s5,24(sp)
    80001f90:	e85a                	sd	s6,16(sp)
    80001f92:	e45e                	sd	s7,8(sp)
    80001f94:	e062                	sd	s8,0(sp)
    80001f96:	0880                	addi	s0,sp,80
    80001f98:	8792                	mv	a5,tp
  int id = r_tp();
    80001f9a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f9c:	00779b13          	slli	s6,a5,0x7
    80001fa0:	00014717          	auipc	a4,0x14
    80001fa4:	8a070713          	addi	a4,a4,-1888 # 80015840 <pid_lock>
    80001fa8:	975a                	add	a4,a4,s6
    80001faa:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    80001fae:	00014717          	auipc	a4,0x14
    80001fb2:	8ba70713          	addi	a4,a4,-1862 # 80015868 <cpus+0x8>
    80001fb6:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fb8:	4b8d                	li	s7,3
        c->proc = p;
    80001fba:	079e                	slli	a5,a5,0x7
    80001fbc:	00014917          	auipc	s2,0x14
    80001fc0:	88490913          	addi	s2,s2,-1916 # 80015840 <pid_lock>
    80001fc4:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc6:	00015a17          	auipc	s4,0x15
    80001fca:	afaa0a13          	addi	s4,s4,-1286 # 80016ac0 <tickslock>
    80001fce:	a0b9                	j	8000201c <scheduler+0x9c>
        p->state = RUNNING;
    80001fd0:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    80001fd4:	02993023          	sd	s1,32(s2)
        swtch(&c->scheduler, &p->context);
    80001fd8:	06848593          	addi	a1,s1,104
    80001fdc:	855a                	mv	a0,s6
    80001fde:	00000097          	auipc	ra,0x0
    80001fe2:	63e080e7          	jalr	1598(ra) # 8000261c <swtch>
        c->proc = 0;
    80001fe6:	02093023          	sd	zero,32(s2)
        found = 1;
    80001fea:	8ae2                	mv	s5,s8
      c->intena = 0;
    80001fec:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	b8e080e7          	jalr	-1138(ra) # 80000b80 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ffa:	17048493          	addi	s1,s1,368
    80001ffe:	01448b63          	beq	s1,s4,80002014 <scheduler+0x94>
      acquire(&p->lock);
    80002002:	8526                	mv	a0,s1
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	aac080e7          	jalr	-1364(ra) # 80000ab0 <acquire>
      if(p->state == RUNNABLE) {
    8000200c:	509c                	lw	a5,32(s1)
    8000200e:	fd379fe3          	bne	a5,s3,80001fec <scheduler+0x6c>
    80002012:	bf7d                	j	80001fd0 <scheduler+0x50>
    if(found == 0){
    80002014:	000a9463          	bnez	s5,8000201c <scheduler+0x9c>
      asm volatile("wfi");
    80002018:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000201c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002020:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002024:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002028:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000202c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000202e:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002032:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002034:	00014497          	auipc	s1,0x14
    80002038:	c2c48493          	addi	s1,s1,-980 # 80015c60 <proc>
      if(p->state == RUNNABLE) {
    8000203c:	4989                	li	s3,2
        found = 1;
    8000203e:	4c05                	li	s8,1
    80002040:	b7c9                	j	80002002 <scheduler+0x82>

0000000080002042 <sched>:
{
    80002042:	7179                	addi	sp,sp,-48
    80002044:	f406                	sd	ra,40(sp)
    80002046:	f022                	sd	s0,32(sp)
    80002048:	ec26                	sd	s1,24(sp)
    8000204a:	e84a                	sd	s2,16(sp)
    8000204c:	e44e                	sd	s3,8(sp)
    8000204e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002050:	00000097          	auipc	ra,0x0
    80002054:	a56080e7          	jalr	-1450(ra) # 80001aa6 <myproc>
    80002058:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	9d8080e7          	jalr	-1576(ra) # 80000a32 <holding>
    80002062:	c93d                	beqz	a0,800020d8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002064:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002066:	2781                	sext.w	a5,a5
    80002068:	079e                	slli	a5,a5,0x7
    8000206a:	00013717          	auipc	a4,0x13
    8000206e:	7d670713          	addi	a4,a4,2006 # 80015840 <pid_lock>
    80002072:	97ba                	add	a5,a5,a4
    80002074:	0987a703          	lw	a4,152(a5)
    80002078:	4785                	li	a5,1
    8000207a:	06f71763          	bne	a4,a5,800020e8 <sched+0xa6>
  if(p->state == RUNNING)
    8000207e:	5098                	lw	a4,32(s1)
    80002080:	478d                	li	a5,3
    80002082:	06f70b63          	beq	a4,a5,800020f8 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002086:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000208a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000208c:	efb5                	bnez	a5,80002108 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000208e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002090:	00013917          	auipc	s2,0x13
    80002094:	7b090913          	addi	s2,s2,1968 # 80015840 <pid_lock>
    80002098:	2781                	sext.w	a5,a5
    8000209a:	079e                	slli	a5,a5,0x7
    8000209c:	97ca                	add	a5,a5,s2
    8000209e:	09c7a983          	lw	s3,156(a5)
    800020a2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    800020a4:	2781                	sext.w	a5,a5
    800020a6:	079e                	slli	a5,a5,0x7
    800020a8:	00013597          	auipc	a1,0x13
    800020ac:	7c058593          	addi	a1,a1,1984 # 80015868 <cpus+0x8>
    800020b0:	95be                	add	a1,a1,a5
    800020b2:	06848513          	addi	a0,s1,104
    800020b6:	00000097          	auipc	ra,0x0
    800020ba:	566080e7          	jalr	1382(ra) # 8000261c <swtch>
    800020be:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020c0:	2781                	sext.w	a5,a5
    800020c2:	079e                	slli	a5,a5,0x7
    800020c4:	97ca                	add	a5,a5,s2
    800020c6:	0937ae23          	sw	s3,156(a5)
}
    800020ca:	70a2                	ld	ra,40(sp)
    800020cc:	7402                	ld	s0,32(sp)
    800020ce:	64e2                	ld	s1,24(sp)
    800020d0:	6942                	ld	s2,16(sp)
    800020d2:	69a2                	ld	s3,8(sp)
    800020d4:	6145                	addi	sp,sp,48
    800020d6:	8082                	ret
    panic("sched p->lock");
    800020d8:	00007517          	auipc	a0,0x7
    800020dc:	38050513          	addi	a0,a0,896 # 80009458 <userret+0x3c8>
    800020e0:	ffffe097          	auipc	ra,0xffffe
    800020e4:	47a080e7          	jalr	1146(ra) # 8000055a <panic>
    panic("sched locks");
    800020e8:	00007517          	auipc	a0,0x7
    800020ec:	38050513          	addi	a0,a0,896 # 80009468 <userret+0x3d8>
    800020f0:	ffffe097          	auipc	ra,0xffffe
    800020f4:	46a080e7          	jalr	1130(ra) # 8000055a <panic>
    panic("sched running");
    800020f8:	00007517          	auipc	a0,0x7
    800020fc:	38050513          	addi	a0,a0,896 # 80009478 <userret+0x3e8>
    80002100:	ffffe097          	auipc	ra,0xffffe
    80002104:	45a080e7          	jalr	1114(ra) # 8000055a <panic>
    panic("sched interruptible");
    80002108:	00007517          	auipc	a0,0x7
    8000210c:	38050513          	addi	a0,a0,896 # 80009488 <userret+0x3f8>
    80002110:	ffffe097          	auipc	ra,0xffffe
    80002114:	44a080e7          	jalr	1098(ra) # 8000055a <panic>

0000000080002118 <exit>:
{
    80002118:	7179                	addi	sp,sp,-48
    8000211a:	f406                	sd	ra,40(sp)
    8000211c:	f022                	sd	s0,32(sp)
    8000211e:	ec26                	sd	s1,24(sp)
    80002120:	e84a                	sd	s2,16(sp)
    80002122:	e44e                	sd	s3,8(sp)
    80002124:	e052                	sd	s4,0(sp)
    80002126:	1800                	addi	s0,sp,48
    80002128:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	97c080e7          	jalr	-1668(ra) # 80001aa6 <myproc>
    80002132:	89aa                	mv	s3,a0
  if(p == initproc)
    80002134:	00027797          	auipc	a5,0x27
    80002138:	2447b783          	ld	a5,580(a5) # 80029378 <initproc>
    8000213c:	0d850493          	addi	s1,a0,216
    80002140:	15850913          	addi	s2,a0,344
    80002144:	02a79363          	bne	a5,a0,8000216a <exit+0x52>
    panic("init exiting");
    80002148:	00007517          	auipc	a0,0x7
    8000214c:	35850513          	addi	a0,a0,856 # 800094a0 <userret+0x410>
    80002150:	ffffe097          	auipc	ra,0xffffe
    80002154:	40a080e7          	jalr	1034(ra) # 8000055a <panic>
      fileclose(f);
    80002158:	00002097          	auipc	ra,0x2
    8000215c:	56a080e7          	jalr	1386(ra) # 800046c2 <fileclose>
      p->ofile[fd] = 0;
    80002160:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002164:	04a1                	addi	s1,s1,8
    80002166:	01248563          	beq	s1,s2,80002170 <exit+0x58>
    if(p->ofile[fd]){
    8000216a:	6088                	ld	a0,0(s1)
    8000216c:	f575                	bnez	a0,80002158 <exit+0x40>
    8000216e:	bfdd                	j	80002164 <exit+0x4c>
  begin_op(ROOTDEV);
    80002170:	4501                	li	a0,0
    80002172:	00002097          	auipc	ra,0x2
    80002176:	fb6080e7          	jalr	-74(ra) # 80004128 <begin_op>
  iput(p->cwd);
    8000217a:	1589b503          	ld	a0,344(s3)
    8000217e:	00001097          	auipc	ra,0x1
    80002182:	6d4080e7          	jalr	1748(ra) # 80003852 <iput>
  end_op(ROOTDEV);
    80002186:	4501                	li	a0,0
    80002188:	00002097          	auipc	ra,0x2
    8000218c:	04a080e7          	jalr	74(ra) # 800041d2 <end_op>
  p->cwd = 0;
    80002190:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002194:	00027497          	auipc	s1,0x27
    80002198:	1e448493          	addi	s1,s1,484 # 80029378 <initproc>
    8000219c:	6088                	ld	a0,0(s1)
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	912080e7          	jalr	-1774(ra) # 80000ab0 <acquire>
  wakeup1(initproc);
    800021a6:	6088                	ld	a0,0(s1)
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	7be080e7          	jalr	1982(ra) # 80001966 <wakeup1>
  release(&initproc->lock);
    800021b0:	6088                	ld	a0,0(s1)
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	9ce080e7          	jalr	-1586(ra) # 80000b80 <release>
  acquire(&p->lock);
    800021ba:	854e                	mv	a0,s3
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	8f4080e7          	jalr	-1804(ra) # 80000ab0 <acquire>
  struct proc *original_parent = p->parent;
    800021c4:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800021c8:	854e                	mv	a0,s3
    800021ca:	fffff097          	auipc	ra,0xfffff
    800021ce:	9b6080e7          	jalr	-1610(ra) # 80000b80 <release>
  acquire(&original_parent->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	8dc080e7          	jalr	-1828(ra) # 80000ab0 <acquire>
  acquire(&p->lock);
    800021dc:	854e                	mv	a0,s3
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	8d2080e7          	jalr	-1838(ra) # 80000ab0 <acquire>
  reparent(p);
    800021e6:	854e                	mv	a0,s3
    800021e8:	00000097          	auipc	ra,0x0
    800021ec:	d32080e7          	jalr	-718(ra) # 80001f1a <reparent>
  wakeup1(original_parent);
    800021f0:	8526                	mv	a0,s1
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	774080e7          	jalr	1908(ra) # 80001966 <wakeup1>
  p->xstate = status;
    800021fa:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800021fe:	4791                	li	a5,4
    80002200:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	97a080e7          	jalr	-1670(ra) # 80000b80 <release>
  sched();
    8000220e:	00000097          	auipc	ra,0x0
    80002212:	e34080e7          	jalr	-460(ra) # 80002042 <sched>
  panic("zombie exit");
    80002216:	00007517          	auipc	a0,0x7
    8000221a:	29a50513          	addi	a0,a0,666 # 800094b0 <userret+0x420>
    8000221e:	ffffe097          	auipc	ra,0xffffe
    80002222:	33c080e7          	jalr	828(ra) # 8000055a <panic>

0000000080002226 <yield>:
{
    80002226:	1101                	addi	sp,sp,-32
    80002228:	ec06                	sd	ra,24(sp)
    8000222a:	e822                	sd	s0,16(sp)
    8000222c:	e426                	sd	s1,8(sp)
    8000222e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002230:	00000097          	auipc	ra,0x0
    80002234:	876080e7          	jalr	-1930(ra) # 80001aa6 <myproc>
    80002238:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	876080e7          	jalr	-1930(ra) # 80000ab0 <acquire>
  p->state = RUNNABLE;
    80002242:	4789                	li	a5,2
    80002244:	d09c                	sw	a5,32(s1)
  sched();
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	dfc080e7          	jalr	-516(ra) # 80002042 <sched>
  release(&p->lock);
    8000224e:	8526                	mv	a0,s1
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	930080e7          	jalr	-1744(ra) # 80000b80 <release>
}
    80002258:	60e2                	ld	ra,24(sp)
    8000225a:	6442                	ld	s0,16(sp)
    8000225c:	64a2                	ld	s1,8(sp)
    8000225e:	6105                	addi	sp,sp,32
    80002260:	8082                	ret

0000000080002262 <sleep>:
{
    80002262:	7179                	addi	sp,sp,-48
    80002264:	f406                	sd	ra,40(sp)
    80002266:	f022                	sd	s0,32(sp)
    80002268:	ec26                	sd	s1,24(sp)
    8000226a:	e84a                	sd	s2,16(sp)
    8000226c:	e44e                	sd	s3,8(sp)
    8000226e:	1800                	addi	s0,sp,48
    80002270:	89aa                	mv	s3,a0
    80002272:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002274:	00000097          	auipc	ra,0x0
    80002278:	832080e7          	jalr	-1998(ra) # 80001aa6 <myproc>
    8000227c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000227e:	05250663          	beq	a0,s2,800022ca <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	82e080e7          	jalr	-2002(ra) # 80000ab0 <acquire>
    release(lk);
    8000228a:	854a                	mv	a0,s2
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	8f4080e7          	jalr	-1804(ra) # 80000b80 <release>
  p->chan = chan;
    80002294:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    80002298:	4785                	li	a5,1
    8000229a:	d09c                	sw	a5,32(s1)
  sched();
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	da6080e7          	jalr	-602(ra) # 80002042 <sched>
  p->chan = 0;
    800022a4:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	8d6080e7          	jalr	-1834(ra) # 80000b80 <release>
    acquire(lk);
    800022b2:	854a                	mv	a0,s2
    800022b4:	ffffe097          	auipc	ra,0xffffe
    800022b8:	7fc080e7          	jalr	2044(ra) # 80000ab0 <acquire>
}
    800022bc:	70a2                	ld	ra,40(sp)
    800022be:	7402                	ld	s0,32(sp)
    800022c0:	64e2                	ld	s1,24(sp)
    800022c2:	6942                	ld	s2,16(sp)
    800022c4:	69a2                	ld	s3,8(sp)
    800022c6:	6145                	addi	sp,sp,48
    800022c8:	8082                	ret
  p->chan = chan;
    800022ca:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800022ce:	4785                	li	a5,1
    800022d0:	d11c                	sw	a5,32(a0)
  sched();
    800022d2:	00000097          	auipc	ra,0x0
    800022d6:	d70080e7          	jalr	-656(ra) # 80002042 <sched>
  p->chan = 0;
    800022da:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800022de:	bff9                	j	800022bc <sleep+0x5a>

00000000800022e0 <wait>:
{
    800022e0:	715d                	addi	sp,sp,-80
    800022e2:	e486                	sd	ra,72(sp)
    800022e4:	e0a2                	sd	s0,64(sp)
    800022e6:	fc26                	sd	s1,56(sp)
    800022e8:	f84a                	sd	s2,48(sp)
    800022ea:	f44e                	sd	s3,40(sp)
    800022ec:	f052                	sd	s4,32(sp)
    800022ee:	ec56                	sd	s5,24(sp)
    800022f0:	e85a                	sd	s6,16(sp)
    800022f2:	e45e                	sd	s7,8(sp)
    800022f4:	e062                	sd	s8,0(sp)
    800022f6:	0880                	addi	s0,sp,80
    800022f8:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	7ac080e7          	jalr	1964(ra) # 80001aa6 <myproc>
    80002302:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002304:	8c2a                	mv	s8,a0
    80002306:	ffffe097          	auipc	ra,0xffffe
    8000230a:	7aa080e7          	jalr	1962(ra) # 80000ab0 <acquire>
    havekids = 0;
    8000230e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002310:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002312:	00014997          	auipc	s3,0x14
    80002316:	7ae98993          	addi	s3,s3,1966 # 80016ac0 <tickslock>
        havekids = 1;
    8000231a:	4b05                	li	s6,1
    havekids = 0;
    8000231c:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000231e:	00014497          	auipc	s1,0x14
    80002322:	94248493          	addi	s1,s1,-1726 # 80015c60 <proc>
    80002326:	a08d                	j	80002388 <wait+0xa8>
          pid = np->pid;
    80002328:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000232c:	000a8e63          	beqz	s5,80002348 <wait+0x68>
    80002330:	4691                	li	a3,4
    80002332:	03c48613          	addi	a2,s1,60
    80002336:	85d6                	mv	a1,s5
    80002338:	05893503          	ld	a0,88(s2)
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	45e080e7          	jalr	1118(ra) # 8000179a <copyout>
    80002344:	02054263          	bltz	a0,80002368 <wait+0x88>
          freeproc(np);
    80002348:	8526                	mv	a0,s1
    8000234a:	00000097          	auipc	ra,0x0
    8000234e:	978080e7          	jalr	-1672(ra) # 80001cc2 <freeproc>
          release(&np->lock);
    80002352:	8526                	mv	a0,s1
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	82c080e7          	jalr	-2004(ra) # 80000b80 <release>
          release(&p->lock);
    8000235c:	854a                	mv	a0,s2
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	822080e7          	jalr	-2014(ra) # 80000b80 <release>
          return pid;
    80002366:	a8a9                	j	800023c0 <wait+0xe0>
            release(&np->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	816080e7          	jalr	-2026(ra) # 80000b80 <release>
            release(&p->lock);
    80002372:	854a                	mv	a0,s2
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	80c080e7          	jalr	-2036(ra) # 80000b80 <release>
            return -1;
    8000237c:	59fd                	li	s3,-1
    8000237e:	a089                	j	800023c0 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002380:	17048493          	addi	s1,s1,368
    80002384:	03348463          	beq	s1,s3,800023ac <wait+0xcc>
      if(np->parent == p){
    80002388:	749c                	ld	a5,40(s1)
    8000238a:	ff279be3          	bne	a5,s2,80002380 <wait+0xa0>
        acquire(&np->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	ffffe097          	auipc	ra,0xffffe
    80002394:	720080e7          	jalr	1824(ra) # 80000ab0 <acquire>
        if(np->state == ZOMBIE){
    80002398:	509c                	lw	a5,32(s1)
    8000239a:	f94787e3          	beq	a5,s4,80002328 <wait+0x48>
        release(&np->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	ffffe097          	auipc	ra,0xffffe
    800023a4:	7e0080e7          	jalr	2016(ra) # 80000b80 <release>
        havekids = 1;
    800023a8:	875a                	mv	a4,s6
    800023aa:	bfd9                	j	80002380 <wait+0xa0>
    if(!havekids || p->killed){
    800023ac:	c701                	beqz	a4,800023b4 <wait+0xd4>
    800023ae:	03892783          	lw	a5,56(s2)
    800023b2:	c785                	beqz	a5,800023da <wait+0xfa>
      release(&p->lock);
    800023b4:	854a                	mv	a0,s2
    800023b6:	ffffe097          	auipc	ra,0xffffe
    800023ba:	7ca080e7          	jalr	1994(ra) # 80000b80 <release>
      return -1;
    800023be:	59fd                	li	s3,-1
}
    800023c0:	854e                	mv	a0,s3
    800023c2:	60a6                	ld	ra,72(sp)
    800023c4:	6406                	ld	s0,64(sp)
    800023c6:	74e2                	ld	s1,56(sp)
    800023c8:	7942                	ld	s2,48(sp)
    800023ca:	79a2                	ld	s3,40(sp)
    800023cc:	7a02                	ld	s4,32(sp)
    800023ce:	6ae2                	ld	s5,24(sp)
    800023d0:	6b42                	ld	s6,16(sp)
    800023d2:	6ba2                	ld	s7,8(sp)
    800023d4:	6c02                	ld	s8,0(sp)
    800023d6:	6161                	addi	sp,sp,80
    800023d8:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023da:	85e2                	mv	a1,s8
    800023dc:	854a                	mv	a0,s2
    800023de:	00000097          	auipc	ra,0x0
    800023e2:	e84080e7          	jalr	-380(ra) # 80002262 <sleep>
    havekids = 0;
    800023e6:	bf1d                	j	8000231c <wait+0x3c>

00000000800023e8 <wakeup>:
{
    800023e8:	7139                	addi	sp,sp,-64
    800023ea:	fc06                	sd	ra,56(sp)
    800023ec:	f822                	sd	s0,48(sp)
    800023ee:	f426                	sd	s1,40(sp)
    800023f0:	f04a                	sd	s2,32(sp)
    800023f2:	ec4e                	sd	s3,24(sp)
    800023f4:	e852                	sd	s4,16(sp)
    800023f6:	e456                	sd	s5,8(sp)
    800023f8:	0080                	addi	s0,sp,64
    800023fa:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023fc:	00014497          	auipc	s1,0x14
    80002400:	86448493          	addi	s1,s1,-1948 # 80015c60 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002404:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002406:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002408:	00014917          	auipc	s2,0x14
    8000240c:	6b890913          	addi	s2,s2,1720 # 80016ac0 <tickslock>
    80002410:	a821                	j	80002428 <wakeup+0x40>
      p->state = RUNNABLE;
    80002412:	0354a023          	sw	s5,32(s1)
    release(&p->lock);
    80002416:	8526                	mv	a0,s1
    80002418:	ffffe097          	auipc	ra,0xffffe
    8000241c:	768080e7          	jalr	1896(ra) # 80000b80 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002420:	17048493          	addi	s1,s1,368
    80002424:	01248e63          	beq	s1,s2,80002440 <wakeup+0x58>
    acquire(&p->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	ffffe097          	auipc	ra,0xffffe
    8000242e:	686080e7          	jalr	1670(ra) # 80000ab0 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002432:	509c                	lw	a5,32(s1)
    80002434:	ff3791e3          	bne	a5,s3,80002416 <wakeup+0x2e>
    80002438:	789c                	ld	a5,48(s1)
    8000243a:	fd479ee3          	bne	a5,s4,80002416 <wakeup+0x2e>
    8000243e:	bfd1                	j	80002412 <wakeup+0x2a>
}
    80002440:	70e2                	ld	ra,56(sp)
    80002442:	7442                	ld	s0,48(sp)
    80002444:	74a2                	ld	s1,40(sp)
    80002446:	7902                	ld	s2,32(sp)
    80002448:	69e2                	ld	s3,24(sp)
    8000244a:	6a42                	ld	s4,16(sp)
    8000244c:	6aa2                	ld	s5,8(sp)
    8000244e:	6121                	addi	sp,sp,64
    80002450:	8082                	ret

0000000080002452 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002452:	7179                	addi	sp,sp,-48
    80002454:	f406                	sd	ra,40(sp)
    80002456:	f022                	sd	s0,32(sp)
    80002458:	ec26                	sd	s1,24(sp)
    8000245a:	e84a                	sd	s2,16(sp)
    8000245c:	e44e                	sd	s3,8(sp)
    8000245e:	1800                	addi	s0,sp,48
    80002460:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002462:	00013497          	auipc	s1,0x13
    80002466:	7fe48493          	addi	s1,s1,2046 # 80015c60 <proc>
    8000246a:	00014997          	auipc	s3,0x14
    8000246e:	65698993          	addi	s3,s3,1622 # 80016ac0 <tickslock>
    acquire(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	63c080e7          	jalr	1596(ra) # 80000ab0 <acquire>
    if(p->pid == pid){
    8000247c:	40bc                	lw	a5,64(s1)
    8000247e:	03278363          	beq	a5,s2,800024a4 <kill+0x52>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	ffffe097          	auipc	ra,0xffffe
    80002488:	6fc080e7          	jalr	1788(ra) # 80000b80 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000248c:	17048493          	addi	s1,s1,368
    80002490:	ff3491e3          	bne	s1,s3,80002472 <kill+0x20>
  }
  return -1;
    80002494:	557d                	li	a0,-1
}
    80002496:	70a2                	ld	ra,40(sp)
    80002498:	7402                	ld	s0,32(sp)
    8000249a:	64e2                	ld	s1,24(sp)
    8000249c:	6942                	ld	s2,16(sp)
    8000249e:	69a2                	ld	s3,8(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
      p->killed = 1;
    800024a4:	4785                	li	a5,1
    800024a6:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    800024a8:	5098                	lw	a4,32(s1)
    800024aa:	00f70963          	beq	a4,a5,800024bc <kill+0x6a>
      release(&p->lock);
    800024ae:	8526                	mv	a0,s1
    800024b0:	ffffe097          	auipc	ra,0xffffe
    800024b4:	6d0080e7          	jalr	1744(ra) # 80000b80 <release>
      return 0;
    800024b8:	4501                	li	a0,0
    800024ba:	bff1                	j	80002496 <kill+0x44>
        p->state = RUNNABLE;
    800024bc:	4789                	li	a5,2
    800024be:	d09c                	sw	a5,32(s1)
    800024c0:	b7fd                	j	800024ae <kill+0x5c>

00000000800024c2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024c2:	7179                	addi	sp,sp,-48
    800024c4:	f406                	sd	ra,40(sp)
    800024c6:	f022                	sd	s0,32(sp)
    800024c8:	ec26                	sd	s1,24(sp)
    800024ca:	e84a                	sd	s2,16(sp)
    800024cc:	e44e                	sd	s3,8(sp)
    800024ce:	e052                	sd	s4,0(sp)
    800024d0:	1800                	addi	s0,sp,48
    800024d2:	84aa                	mv	s1,a0
    800024d4:	892e                	mv	s2,a1
    800024d6:	89b2                	mv	s3,a2
    800024d8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024da:	fffff097          	auipc	ra,0xfffff
    800024de:	5cc080e7          	jalr	1484(ra) # 80001aa6 <myproc>
  if(user_dst){
    800024e2:	c08d                	beqz	s1,80002504 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024e4:	86d2                	mv	a3,s4
    800024e6:	864e                	mv	a2,s3
    800024e8:	85ca                	mv	a1,s2
    800024ea:	6d28                	ld	a0,88(a0)
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	2ae080e7          	jalr	686(ra) # 8000179a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024f4:	70a2                	ld	ra,40(sp)
    800024f6:	7402                	ld	s0,32(sp)
    800024f8:	64e2                	ld	s1,24(sp)
    800024fa:	6942                	ld	s2,16(sp)
    800024fc:	69a2                	ld	s3,8(sp)
    800024fe:	6a02                	ld	s4,0(sp)
    80002500:	6145                	addi	sp,sp,48
    80002502:	8082                	ret
    memmove((char *)dst, src, len);
    80002504:	000a061b          	sext.w	a2,s4
    80002508:	85ce                	mv	a1,s3
    8000250a:	854a                	mv	a0,s2
    8000250c:	fffff097          	auipc	ra,0xfffff
    80002510:	8d2080e7          	jalr	-1838(ra) # 80000dde <memmove>
    return 0;
    80002514:	8526                	mv	a0,s1
    80002516:	bff9                	j	800024f4 <either_copyout+0x32>

0000000080002518 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002518:	7179                	addi	sp,sp,-48
    8000251a:	f406                	sd	ra,40(sp)
    8000251c:	f022                	sd	s0,32(sp)
    8000251e:	ec26                	sd	s1,24(sp)
    80002520:	e84a                	sd	s2,16(sp)
    80002522:	e44e                	sd	s3,8(sp)
    80002524:	e052                	sd	s4,0(sp)
    80002526:	1800                	addi	s0,sp,48
    80002528:	892a                	mv	s2,a0
    8000252a:	84ae                	mv	s1,a1
    8000252c:	89b2                	mv	s3,a2
    8000252e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002530:	fffff097          	auipc	ra,0xfffff
    80002534:	576080e7          	jalr	1398(ra) # 80001aa6 <myproc>
  if(user_src){
    80002538:	c08d                	beqz	s1,8000255a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000253a:	86d2                	mv	a3,s4
    8000253c:	864e                	mv	a2,s3
    8000253e:	85ca                	mv	a1,s2
    80002540:	6d28                	ld	a0,88(a0)
    80002542:	fffff097          	auipc	ra,0xfffff
    80002546:	2e4080e7          	jalr	740(ra) # 80001826 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000254a:	70a2                	ld	ra,40(sp)
    8000254c:	7402                	ld	s0,32(sp)
    8000254e:	64e2                	ld	s1,24(sp)
    80002550:	6942                	ld	s2,16(sp)
    80002552:	69a2                	ld	s3,8(sp)
    80002554:	6a02                	ld	s4,0(sp)
    80002556:	6145                	addi	sp,sp,48
    80002558:	8082                	ret
    memmove(dst, (char*)src, len);
    8000255a:	000a061b          	sext.w	a2,s4
    8000255e:	85ce                	mv	a1,s3
    80002560:	854a                	mv	a0,s2
    80002562:	fffff097          	auipc	ra,0xfffff
    80002566:	87c080e7          	jalr	-1924(ra) # 80000dde <memmove>
    return 0;
    8000256a:	8526                	mv	a0,s1
    8000256c:	bff9                	j	8000254a <either_copyin+0x32>

000000008000256e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000256e:	715d                	addi	sp,sp,-80
    80002570:	e486                	sd	ra,72(sp)
    80002572:	e0a2                	sd	s0,64(sp)
    80002574:	fc26                	sd	s1,56(sp)
    80002576:	f84a                	sd	s2,48(sp)
    80002578:	f44e                	sd	s3,40(sp)
    8000257a:	f052                	sd	s4,32(sp)
    8000257c:	ec56                	sd	s5,24(sp)
    8000257e:	e85a                	sd	s6,16(sp)
    80002580:	e45e                	sd	s7,8(sp)
    80002582:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002584:	00007517          	auipc	a0,0x7
    80002588:	d0c50513          	addi	a0,a0,-756 # 80009290 <userret+0x200>
    8000258c:	ffffe097          	auipc	ra,0xffffe
    80002590:	028080e7          	jalr	40(ra) # 800005b4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002594:	00014497          	auipc	s1,0x14
    80002598:	82c48493          	addi	s1,s1,-2004 # 80015dc0 <proc+0x160>
    8000259c:	00014917          	auipc	s2,0x14
    800025a0:	68490913          	addi	s2,s2,1668 # 80016c20 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a4:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025a6:	00007997          	auipc	s3,0x7
    800025aa:	f1a98993          	addi	s3,s3,-230 # 800094c0 <userret+0x430>
    printf("%d %s %s", p->pid, state, p->name);
    800025ae:	00007a97          	auipc	s5,0x7
    800025b2:	f1aa8a93          	addi	s5,s5,-230 # 800094c8 <userret+0x438>
    printf("\n");
    800025b6:	00007a17          	auipc	s4,0x7
    800025ba:	cdaa0a13          	addi	s4,s4,-806 # 80009290 <userret+0x200>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025be:	00007b97          	auipc	s7,0x7
    800025c2:	7cab8b93          	addi	s7,s7,1994 # 80009d88 <states.1827>
    800025c6:	a00d                	j	800025e8 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025c8:	ee06a583          	lw	a1,-288(a3)
    800025cc:	8556                	mv	a0,s5
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	fe6080e7          	jalr	-26(ra) # 800005b4 <printf>
    printf("\n");
    800025d6:	8552                	mv	a0,s4
    800025d8:	ffffe097          	auipc	ra,0xffffe
    800025dc:	fdc080e7          	jalr	-36(ra) # 800005b4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025e0:	17048493          	addi	s1,s1,368
    800025e4:	03248163          	beq	s1,s2,80002606 <procdump+0x98>
    if(p->state == UNUSED)
    800025e8:	86a6                	mv	a3,s1
    800025ea:	ec04a783          	lw	a5,-320(s1)
    800025ee:	dbed                	beqz	a5,800025e0 <procdump+0x72>
      state = "???";
    800025f0:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f2:	fcfb6be3          	bltu	s6,a5,800025c8 <procdump+0x5a>
    800025f6:	1782                	slli	a5,a5,0x20
    800025f8:	9381                	srli	a5,a5,0x20
    800025fa:	078e                	slli	a5,a5,0x3
    800025fc:	97de                	add	a5,a5,s7
    800025fe:	6390                	ld	a2,0(a5)
    80002600:	f661                	bnez	a2,800025c8 <procdump+0x5a>
      state = "???";
    80002602:	864e                	mv	a2,s3
    80002604:	b7d1                	j	800025c8 <procdump+0x5a>
  }
}
    80002606:	60a6                	ld	ra,72(sp)
    80002608:	6406                	ld	s0,64(sp)
    8000260a:	74e2                	ld	s1,56(sp)
    8000260c:	7942                	ld	s2,48(sp)
    8000260e:	79a2                	ld	s3,40(sp)
    80002610:	7a02                	ld	s4,32(sp)
    80002612:	6ae2                	ld	s5,24(sp)
    80002614:	6b42                	ld	s6,16(sp)
    80002616:	6ba2                	ld	s7,8(sp)
    80002618:	6161                	addi	sp,sp,80
    8000261a:	8082                	ret

000000008000261c <swtch>:
    8000261c:	00153023          	sd	ra,0(a0)
    80002620:	00253423          	sd	sp,8(a0)
    80002624:	e900                	sd	s0,16(a0)
    80002626:	ed04                	sd	s1,24(a0)
    80002628:	03253023          	sd	s2,32(a0)
    8000262c:	03353423          	sd	s3,40(a0)
    80002630:	03453823          	sd	s4,48(a0)
    80002634:	03553c23          	sd	s5,56(a0)
    80002638:	05653023          	sd	s6,64(a0)
    8000263c:	05753423          	sd	s7,72(a0)
    80002640:	05853823          	sd	s8,80(a0)
    80002644:	05953c23          	sd	s9,88(a0)
    80002648:	07a53023          	sd	s10,96(a0)
    8000264c:	07b53423          	sd	s11,104(a0)
    80002650:	0005b083          	ld	ra,0(a1)
    80002654:	0085b103          	ld	sp,8(a1)
    80002658:	6980                	ld	s0,16(a1)
    8000265a:	6d84                	ld	s1,24(a1)
    8000265c:	0205b903          	ld	s2,32(a1)
    80002660:	0285b983          	ld	s3,40(a1)
    80002664:	0305ba03          	ld	s4,48(a1)
    80002668:	0385ba83          	ld	s5,56(a1)
    8000266c:	0405bb03          	ld	s6,64(a1)
    80002670:	0485bb83          	ld	s7,72(a1)
    80002674:	0505bc03          	ld	s8,80(a1)
    80002678:	0585bc83          	ld	s9,88(a1)
    8000267c:	0605bd03          	ld	s10,96(a1)
    80002680:	0685bd83          	ld	s11,104(a1)
    80002684:	8082                	ret

0000000080002686 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002686:	1141                	addi	sp,sp,-16
    80002688:	e422                	sd	s0,8(sp)
    8000268a:	0800                	addi	s0,sp,16
    8000268c:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    8000268e:	00151713          	slli	a4,a0,0x1
    80002692:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    80002694:	04054c63          	bltz	a0,800026ec <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002698:	5685                	li	a3,-31
    8000269a:	8285                	srli	a3,a3,0x1
    8000269c:	8ee9                	and	a3,a3,a0
    8000269e:	caad                	beqz	a3,80002710 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    800026a0:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    800026a2:	00007517          	auipc	a0,0x7
    800026a6:	e5e50513          	addi	a0,a0,-418 # 80009500 <userret+0x470>
    } else if (code <= 23) {
    800026aa:	06e6f063          	bgeu	a3,a4,8000270a <scause_desc+0x84>
    } else if (code <= 31) {
    800026ae:	fc100693          	li	a3,-63
    800026b2:	8285                	srli	a3,a3,0x1
    800026b4:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    800026b6:	00007517          	auipc	a0,0x7
    800026ba:	e7250513          	addi	a0,a0,-398 # 80009528 <userret+0x498>
    } else if (code <= 31) {
    800026be:	c6b1                	beqz	a3,8000270a <scause_desc+0x84>
    } else if (code <= 47) {
    800026c0:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    800026c4:	00007517          	auipc	a0,0x7
    800026c8:	e3c50513          	addi	a0,a0,-452 # 80009500 <userret+0x470>
    } else if (code <= 47) {
    800026cc:	02e6ff63          	bgeu	a3,a4,8000270a <scause_desc+0x84>
    } else if (code <= 63) {
    800026d0:	f8100513          	li	a0,-127
    800026d4:	8105                	srli	a0,a0,0x1
    800026d6:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    800026d8:	00007517          	auipc	a0,0x7
    800026dc:	e5050513          	addi	a0,a0,-432 # 80009528 <userret+0x498>
    } else if (code <= 63) {
    800026e0:	c78d                	beqz	a5,8000270a <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    800026e2:	00007517          	auipc	a0,0x7
    800026e6:	e1e50513          	addi	a0,a0,-482 # 80009500 <userret+0x470>
    800026ea:	a005                	j	8000270a <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    800026ec:	5505                	li	a0,-31
    800026ee:	8105                	srli	a0,a0,0x1
    800026f0:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    800026f2:	00007517          	auipc	a0,0x7
    800026f6:	e5650513          	addi	a0,a0,-426 # 80009548 <userret+0x4b8>
    if (code < NELEM(intr_desc)) {
    800026fa:	eb81                	bnez	a5,8000270a <scause_desc+0x84>
      return intr_desc[code];
    800026fc:	070e                	slli	a4,a4,0x3
    800026fe:	00007797          	auipc	a5,0x7
    80002702:	6b278793          	addi	a5,a5,1714 # 80009db0 <intr_desc.1644>
    80002706:	973e                	add	a4,a4,a5
    80002708:	6308                	ld	a0,0(a4)
    }
  }
}
    8000270a:	6422                	ld	s0,8(sp)
    8000270c:	0141                	addi	sp,sp,16
    8000270e:	8082                	ret
      return nointr_desc[code];
    80002710:	070e                	slli	a4,a4,0x3
    80002712:	00007797          	auipc	a5,0x7
    80002716:	69e78793          	addi	a5,a5,1694 # 80009db0 <intr_desc.1644>
    8000271a:	973e                	add	a4,a4,a5
    8000271c:	6348                	ld	a0,128(a4)
    8000271e:	b7f5                	j	8000270a <scause_desc+0x84>

0000000080002720 <trapinit>:
{
    80002720:	1141                	addi	sp,sp,-16
    80002722:	e406                	sd	ra,8(sp)
    80002724:	e022                	sd	s0,0(sp)
    80002726:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002728:	00007597          	auipc	a1,0x7
    8000272c:	e4058593          	addi	a1,a1,-448 # 80009568 <userret+0x4d8>
    80002730:	00014517          	auipc	a0,0x14
    80002734:	39050513          	addi	a0,a0,912 # 80016ac0 <tickslock>
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	2a4080e7          	jalr	676(ra) # 800009dc <initlock>
}
    80002740:	60a2                	ld	ra,8(sp)
    80002742:	6402                	ld	s0,0(sp)
    80002744:	0141                	addi	sp,sp,16
    80002746:	8082                	ret

0000000080002748 <trapinithart>:
{
    80002748:	1141                	addi	sp,sp,-16
    8000274a:	e422                	sd	s0,8(sp)
    8000274c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000274e:	00003797          	auipc	a5,0x3
    80002752:	6c278793          	addi	a5,a5,1730 # 80005e10 <kernelvec>
    80002756:	10579073          	csrw	stvec,a5
}
    8000275a:	6422                	ld	s0,8(sp)
    8000275c:	0141                	addi	sp,sp,16
    8000275e:	8082                	ret

0000000080002760 <usertrapret>:
{
    80002760:	1141                	addi	sp,sp,-16
    80002762:	e406                	sd	ra,8(sp)
    80002764:	e022                	sd	s0,0(sp)
    80002766:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002768:	fffff097          	auipc	ra,0xfffff
    8000276c:	33e080e7          	jalr	830(ra) # 80001aa6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002770:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002774:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002776:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000277a:	00007617          	auipc	a2,0x7
    8000277e:	88660613          	addi	a2,a2,-1914 # 80009000 <trampoline>
    80002782:	00007697          	auipc	a3,0x7
    80002786:	87e68693          	addi	a3,a3,-1922 # 80009000 <trampoline>
    8000278a:	8e91                	sub	a3,a3,a2
    8000278c:	040007b7          	lui	a5,0x4000
    80002790:	17fd                	addi	a5,a5,-1
    80002792:	07b2                	slli	a5,a5,0xc
    80002794:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002796:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    8000279a:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000279c:	180026f3          	csrr	a3,satp
    800027a0:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027a2:	7138                	ld	a4,96(a0)
    800027a4:	6534                	ld	a3,72(a0)
    800027a6:	6585                	lui	a1,0x1
    800027a8:	96ae                	add	a3,a3,a1
    800027aa:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800027ac:	7138                	ld	a4,96(a0)
    800027ae:	00000697          	auipc	a3,0x0
    800027b2:	13e68693          	addi	a3,a3,318 # 800028ec <usertrap>
    800027b6:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800027b8:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027ba:	8692                	mv	a3,tp
    800027bc:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027be:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027c2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027c6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027ca:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    800027ce:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027d0:	6f18                	ld	a4,24(a4)
    800027d2:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    800027d6:	6d2c                	ld	a1,88(a0)
    800027d8:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800027da:	00007717          	auipc	a4,0x7
    800027de:	8b670713          	addi	a4,a4,-1866 # 80009090 <userret>
    800027e2:	8f11                	sub	a4,a4,a2
    800027e4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800027e6:	577d                	li	a4,-1
    800027e8:	177e                	slli	a4,a4,0x3f
    800027ea:	8dd9                	or	a1,a1,a4
    800027ec:	02000537          	lui	a0,0x2000
    800027f0:	157d                	addi	a0,a0,-1
    800027f2:	0536                	slli	a0,a0,0xd
    800027f4:	9782                	jalr	a5
}
    800027f6:	60a2                	ld	ra,8(sp)
    800027f8:	6402                	ld	s0,0(sp)
    800027fa:	0141                	addi	sp,sp,16
    800027fc:	8082                	ret

00000000800027fe <clockintr>:
{
    800027fe:	1101                	addi	sp,sp,-32
    80002800:	ec06                	sd	ra,24(sp)
    80002802:	e822                	sd	s0,16(sp)
    80002804:	e426                	sd	s1,8(sp)
    80002806:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002808:	00014497          	auipc	s1,0x14
    8000280c:	2b848493          	addi	s1,s1,696 # 80016ac0 <tickslock>
    80002810:	8526                	mv	a0,s1
    80002812:	ffffe097          	auipc	ra,0xffffe
    80002816:	29e080e7          	jalr	670(ra) # 80000ab0 <acquire>
  ticks++;
    8000281a:	00027517          	auipc	a0,0x27
    8000281e:	b6650513          	addi	a0,a0,-1178 # 80029380 <ticks>
    80002822:	411c                	lw	a5,0(a0)
    80002824:	2785                	addiw	a5,a5,1
    80002826:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002828:	00000097          	auipc	ra,0x0
    8000282c:	bc0080e7          	jalr	-1088(ra) # 800023e8 <wakeup>
  release(&tickslock);
    80002830:	8526                	mv	a0,s1
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	34e080e7          	jalr	846(ra) # 80000b80 <release>
}
    8000283a:	60e2                	ld	ra,24(sp)
    8000283c:	6442                	ld	s0,16(sp)
    8000283e:	64a2                	ld	s1,8(sp)
    80002840:	6105                	addi	sp,sp,32
    80002842:	8082                	ret

0000000080002844 <devintr>:
{
    80002844:	1101                	addi	sp,sp,-32
    80002846:	ec06                	sd	ra,24(sp)
    80002848:	e822                	sd	s0,16(sp)
    8000284a:	e426                	sd	s1,8(sp)
    8000284c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000284e:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002852:	00074d63          	bltz	a4,8000286c <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002856:	57fd                	li	a5,-1
    80002858:	17fe                	slli	a5,a5,0x3f
    8000285a:	0785                	addi	a5,a5,1
    return 0;
    8000285c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000285e:	06f70663          	beq	a4,a5,800028ca <devintr+0x86>
}
    80002862:	60e2                	ld	ra,24(sp)
    80002864:	6442                	ld	s0,16(sp)
    80002866:	64a2                	ld	s1,8(sp)
    80002868:	6105                	addi	sp,sp,32
    8000286a:	8082                	ret
     (scause & 0xff) == 9){
    8000286c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002870:	46a5                	li	a3,9
    80002872:	fed792e3          	bne	a5,a3,80002856 <devintr+0x12>
    int irq = plic_claim();
    80002876:	00003097          	auipc	ra,0x3
    8000287a:	6bc080e7          	jalr	1724(ra) # 80005f32 <plic_claim>
    8000287e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002880:	47a9                	li	a5,10
    80002882:	00f50e63          	beq	a0,a5,8000289e <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80002886:	fff5079b          	addiw	a5,a0,-1
    8000288a:	4705                	li	a4,1
    8000288c:	00f77e63          	bgeu	a4,a5,800028a8 <devintr+0x64>
    } else if(irq == E1000_IRQ){
    80002890:	02100793          	li	a5,33
    80002894:	02f50663          	beq	a0,a5,800028c0 <devintr+0x7c>
    return 1;
    80002898:	4505                	li	a0,1
    if(irq)
    8000289a:	d4e1                	beqz	s1,80002862 <devintr+0x1e>
    8000289c:	a819                	j	800028b2 <devintr+0x6e>
      uartintr();
    8000289e:	ffffe097          	auipc	ra,0xffffe
    800028a2:	fb6080e7          	jalr	-74(ra) # 80000854 <uartintr>
    800028a6:	a031                	j	800028b2 <devintr+0x6e>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800028a8:	853e                	mv	a0,a5
    800028aa:	00004097          	auipc	ra,0x4
    800028ae:	c7c080e7          	jalr	-900(ra) # 80006526 <virtio_disk_intr>
      plic_complete(irq);
    800028b2:	8526                	mv	a0,s1
    800028b4:	00003097          	auipc	ra,0x3
    800028b8:	6a2080e7          	jalr	1698(ra) # 80005f56 <plic_complete>
    return 1;
    800028bc:	4505                	li	a0,1
    800028be:	b755                	j	80002862 <devintr+0x1e>
      e1000_intr();
    800028c0:	00004097          	auipc	ra,0x4
    800028c4:	fd4080e7          	jalr	-44(ra) # 80006894 <e1000_intr>
    800028c8:	b7ed                	j	800028b2 <devintr+0x6e>
    if(cpuid() == 0){
    800028ca:	fffff097          	auipc	ra,0xfffff
    800028ce:	1b0080e7          	jalr	432(ra) # 80001a7a <cpuid>
    800028d2:	c901                	beqz	a0,800028e2 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028d4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028d8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028da:	14479073          	csrw	sip,a5
    return 2;
    800028de:	4509                	li	a0,2
    800028e0:	b749                	j	80002862 <devintr+0x1e>
      clockintr();
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	f1c080e7          	jalr	-228(ra) # 800027fe <clockintr>
    800028ea:	b7ed                	j	800028d4 <devintr+0x90>

00000000800028ec <usertrap>:
{
    800028ec:	7179                	addi	sp,sp,-48
    800028ee:	f406                	sd	ra,40(sp)
    800028f0:	f022                	sd	s0,32(sp)
    800028f2:	ec26                	sd	s1,24(sp)
    800028f4:	e84a                	sd	s2,16(sp)
    800028f6:	e44e                	sd	s3,8(sp)
    800028f8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028fa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028fe:	1007f793          	andi	a5,a5,256
    80002902:	e3b5                	bnez	a5,80002966 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002904:	00003797          	auipc	a5,0x3
    80002908:	50c78793          	addi	a5,a5,1292 # 80005e10 <kernelvec>
    8000290c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002910:	fffff097          	auipc	ra,0xfffff
    80002914:	196080e7          	jalr	406(ra) # 80001aa6 <myproc>
    80002918:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    8000291a:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000291c:	14102773          	csrr	a4,sepc
    80002920:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002922:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002926:	47a1                	li	a5,8
    80002928:	04f71d63          	bne	a4,a5,80002982 <usertrap+0x96>
    if(p->killed)
    8000292c:	5d1c                	lw	a5,56(a0)
    8000292e:	e7a1                	bnez	a5,80002976 <usertrap+0x8a>
    p->tf->epc += 4;
    80002930:	70b8                	ld	a4,96(s1)
    80002932:	6f1c                	ld	a5,24(a4)
    80002934:	0791                	addi	a5,a5,4
    80002936:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002938:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000293c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002940:	10079073          	csrw	sstatus,a5
    syscall();
    80002944:	00000097          	auipc	ra,0x0
    80002948:	2fe080e7          	jalr	766(ra) # 80002c42 <syscall>
  if(p->killed)
    8000294c:	5c9c                	lw	a5,56(s1)
    8000294e:	e3cd                	bnez	a5,800029f0 <usertrap+0x104>
  usertrapret();
    80002950:	00000097          	auipc	ra,0x0
    80002954:	e10080e7          	jalr	-496(ra) # 80002760 <usertrapret>
}
    80002958:	70a2                	ld	ra,40(sp)
    8000295a:	7402                	ld	s0,32(sp)
    8000295c:	64e2                	ld	s1,24(sp)
    8000295e:	6942                	ld	s2,16(sp)
    80002960:	69a2                	ld	s3,8(sp)
    80002962:	6145                	addi	sp,sp,48
    80002964:	8082                	ret
    panic("usertrap: not from user mode");
    80002966:	00007517          	auipc	a0,0x7
    8000296a:	c0a50513          	addi	a0,a0,-1014 # 80009570 <userret+0x4e0>
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	bec080e7          	jalr	-1044(ra) # 8000055a <panic>
      exit(-1);
    80002976:	557d                	li	a0,-1
    80002978:	fffff097          	auipc	ra,0xfffff
    8000297c:	7a0080e7          	jalr	1952(ra) # 80002118 <exit>
    80002980:	bf45                	j	80002930 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002982:	00000097          	auipc	ra,0x0
    80002986:	ec2080e7          	jalr	-318(ra) # 80002844 <devintr>
    8000298a:	892a                	mv	s2,a0
    8000298c:	c501                	beqz	a0,80002994 <usertrap+0xa8>
  if(p->killed)
    8000298e:	5c9c                	lw	a5,56(s1)
    80002990:	cba1                	beqz	a5,800029e0 <usertrap+0xf4>
    80002992:	a091                	j	800029d6 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002994:	142029f3          	csrr	s3,scause
    80002998:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    8000299c:	00000097          	auipc	ra,0x0
    800029a0:	cea080e7          	jalr	-790(ra) # 80002686 <scause_desc>
    800029a4:	862a                	mv	a2,a0
    800029a6:	40b4                	lw	a3,64(s1)
    800029a8:	85ce                	mv	a1,s3
    800029aa:	00007517          	auipc	a0,0x7
    800029ae:	be650513          	addi	a0,a0,-1050 # 80009590 <userret+0x500>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	c02080e7          	jalr	-1022(ra) # 800005b4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ba:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029be:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029c2:	00007517          	auipc	a0,0x7
    800029c6:	bfe50513          	addi	a0,a0,-1026 # 800095c0 <userret+0x530>
    800029ca:	ffffe097          	auipc	ra,0xffffe
    800029ce:	bea080e7          	jalr	-1046(ra) # 800005b4 <printf>
    p->killed = 1;
    800029d2:	4785                	li	a5,1
    800029d4:	dc9c                	sw	a5,56(s1)
    exit(-1);
    800029d6:	557d                	li	a0,-1
    800029d8:	fffff097          	auipc	ra,0xfffff
    800029dc:	740080e7          	jalr	1856(ra) # 80002118 <exit>
  if(which_dev == 2)
    800029e0:	4789                	li	a5,2
    800029e2:	f6f917e3          	bne	s2,a5,80002950 <usertrap+0x64>
    yield();
    800029e6:	00000097          	auipc	ra,0x0
    800029ea:	840080e7          	jalr	-1984(ra) # 80002226 <yield>
    800029ee:	b78d                	j	80002950 <usertrap+0x64>
  int which_dev = 0;
    800029f0:	4901                	li	s2,0
    800029f2:	b7d5                	j	800029d6 <usertrap+0xea>

00000000800029f4 <kerneltrap>:
{
    800029f4:	7179                	addi	sp,sp,-48
    800029f6:	f406                	sd	ra,40(sp)
    800029f8:	f022                	sd	s0,32(sp)
    800029fa:	ec26                	sd	s1,24(sp)
    800029fc:	e84a                	sd	s2,16(sp)
    800029fe:	e44e                	sd	s3,8(sp)
    80002a00:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a02:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a06:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a0a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a0e:	1004f793          	andi	a5,s1,256
    80002a12:	cb85                	beqz	a5,80002a42 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a14:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a18:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a1a:	ef85                	bnez	a5,80002a52 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a1c:	00000097          	auipc	ra,0x0
    80002a20:	e28080e7          	jalr	-472(ra) # 80002844 <devintr>
    80002a24:	cd1d                	beqz	a0,80002a62 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a26:	4789                	li	a5,2
    80002a28:	08f50063          	beq	a0,a5,80002aa8 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a2c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a30:	10049073          	csrw	sstatus,s1
}
    80002a34:	70a2                	ld	ra,40(sp)
    80002a36:	7402                	ld	s0,32(sp)
    80002a38:	64e2                	ld	s1,24(sp)
    80002a3a:	6942                	ld	s2,16(sp)
    80002a3c:	69a2                	ld	s3,8(sp)
    80002a3e:	6145                	addi	sp,sp,48
    80002a40:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a42:	00007517          	auipc	a0,0x7
    80002a46:	b9e50513          	addi	a0,a0,-1122 # 800095e0 <userret+0x550>
    80002a4a:	ffffe097          	auipc	ra,0xffffe
    80002a4e:	b10080e7          	jalr	-1264(ra) # 8000055a <panic>
    panic("kerneltrap: interrupts enabled");
    80002a52:	00007517          	auipc	a0,0x7
    80002a56:	bb650513          	addi	a0,a0,-1098 # 80009608 <userret+0x578>
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	b00080e7          	jalr	-1280(ra) # 8000055a <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002a62:	854e                	mv	a0,s3
    80002a64:	00000097          	auipc	ra,0x0
    80002a68:	c22080e7          	jalr	-990(ra) # 80002686 <scause_desc>
    80002a6c:	862a                	mv	a2,a0
    80002a6e:	85ce                	mv	a1,s3
    80002a70:	00007517          	auipc	a0,0x7
    80002a74:	bb850513          	addi	a0,a0,-1096 # 80009628 <userret+0x598>
    80002a78:	ffffe097          	auipc	ra,0xffffe
    80002a7c:	b3c080e7          	jalr	-1220(ra) # 800005b4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a80:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a84:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a88:	00007517          	auipc	a0,0x7
    80002a8c:	bb050513          	addi	a0,a0,-1104 # 80009638 <userret+0x5a8>
    80002a90:	ffffe097          	auipc	ra,0xffffe
    80002a94:	b24080e7          	jalr	-1244(ra) # 800005b4 <printf>
    panic("kerneltrap");
    80002a98:	00007517          	auipc	a0,0x7
    80002a9c:	bb850513          	addi	a0,a0,-1096 # 80009650 <userret+0x5c0>
    80002aa0:	ffffe097          	auipc	ra,0xffffe
    80002aa4:	aba080e7          	jalr	-1350(ra) # 8000055a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002aa8:	fffff097          	auipc	ra,0xfffff
    80002aac:	ffe080e7          	jalr	-2(ra) # 80001aa6 <myproc>
    80002ab0:	dd35                	beqz	a0,80002a2c <kerneltrap+0x38>
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	ff4080e7          	jalr	-12(ra) # 80001aa6 <myproc>
    80002aba:	5118                	lw	a4,32(a0)
    80002abc:	478d                	li	a5,3
    80002abe:	f6f717e3          	bne	a4,a5,80002a2c <kerneltrap+0x38>
    yield();
    80002ac2:	fffff097          	auipc	ra,0xfffff
    80002ac6:	764080e7          	jalr	1892(ra) # 80002226 <yield>
    80002aca:	b78d                	j	80002a2c <kerneltrap+0x38>

0000000080002acc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002acc:	1101                	addi	sp,sp,-32
    80002ace:	ec06                	sd	ra,24(sp)
    80002ad0:	e822                	sd	s0,16(sp)
    80002ad2:	e426                	sd	s1,8(sp)
    80002ad4:	1000                	addi	s0,sp,32
    80002ad6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ad8:	fffff097          	auipc	ra,0xfffff
    80002adc:	fce080e7          	jalr	-50(ra) # 80001aa6 <myproc>
  switch (n) {
    80002ae0:	4795                	li	a5,5
    80002ae2:	0497e163          	bltu	a5,s1,80002b24 <argraw+0x58>
    80002ae6:	048a                	slli	s1,s1,0x2
    80002ae8:	00007717          	auipc	a4,0x7
    80002aec:	3c870713          	addi	a4,a4,968 # 80009eb0 <nointr_desc.1645+0x80>
    80002af0:	94ba                	add	s1,s1,a4
    80002af2:	409c                	lw	a5,0(s1)
    80002af4:	97ba                	add	a5,a5,a4
    80002af6:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002af8:	713c                	ld	a5,96(a0)
    80002afa:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002afc:	60e2                	ld	ra,24(sp)
    80002afe:	6442                	ld	s0,16(sp)
    80002b00:	64a2                	ld	s1,8(sp)
    80002b02:	6105                	addi	sp,sp,32
    80002b04:	8082                	ret
    return p->tf->a1;
    80002b06:	713c                	ld	a5,96(a0)
    80002b08:	7fa8                	ld	a0,120(a5)
    80002b0a:	bfcd                	j	80002afc <argraw+0x30>
    return p->tf->a2;
    80002b0c:	713c                	ld	a5,96(a0)
    80002b0e:	63c8                	ld	a0,128(a5)
    80002b10:	b7f5                	j	80002afc <argraw+0x30>
    return p->tf->a3;
    80002b12:	713c                	ld	a5,96(a0)
    80002b14:	67c8                	ld	a0,136(a5)
    80002b16:	b7dd                	j	80002afc <argraw+0x30>
    return p->tf->a4;
    80002b18:	713c                	ld	a5,96(a0)
    80002b1a:	6bc8                	ld	a0,144(a5)
    80002b1c:	b7c5                	j	80002afc <argraw+0x30>
    return p->tf->a5;
    80002b1e:	713c                	ld	a5,96(a0)
    80002b20:	6fc8                	ld	a0,152(a5)
    80002b22:	bfe9                	j	80002afc <argraw+0x30>
  panic("argraw");
    80002b24:	00007517          	auipc	a0,0x7
    80002b28:	d3450513          	addi	a0,a0,-716 # 80009858 <userret+0x7c8>
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	a2e080e7          	jalr	-1490(ra) # 8000055a <panic>

0000000080002b34 <fetchaddr>:
{
    80002b34:	1101                	addi	sp,sp,-32
    80002b36:	ec06                	sd	ra,24(sp)
    80002b38:	e822                	sd	s0,16(sp)
    80002b3a:	e426                	sd	s1,8(sp)
    80002b3c:	e04a                	sd	s2,0(sp)
    80002b3e:	1000                	addi	s0,sp,32
    80002b40:	84aa                	mv	s1,a0
    80002b42:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b44:	fffff097          	auipc	ra,0xfffff
    80002b48:	f62080e7          	jalr	-158(ra) # 80001aa6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b4c:	693c                	ld	a5,80(a0)
    80002b4e:	02f4f863          	bgeu	s1,a5,80002b7e <fetchaddr+0x4a>
    80002b52:	00848713          	addi	a4,s1,8
    80002b56:	02e7e663          	bltu	a5,a4,80002b82 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b5a:	46a1                	li	a3,8
    80002b5c:	8626                	mv	a2,s1
    80002b5e:	85ca                	mv	a1,s2
    80002b60:	6d28                	ld	a0,88(a0)
    80002b62:	fffff097          	auipc	ra,0xfffff
    80002b66:	cc4080e7          	jalr	-828(ra) # 80001826 <copyin>
    80002b6a:	00a03533          	snez	a0,a0
    80002b6e:	40a00533          	neg	a0,a0
}
    80002b72:	60e2                	ld	ra,24(sp)
    80002b74:	6442                	ld	s0,16(sp)
    80002b76:	64a2                	ld	s1,8(sp)
    80002b78:	6902                	ld	s2,0(sp)
    80002b7a:	6105                	addi	sp,sp,32
    80002b7c:	8082                	ret
    return -1;
    80002b7e:	557d                	li	a0,-1
    80002b80:	bfcd                	j	80002b72 <fetchaddr+0x3e>
    80002b82:	557d                	li	a0,-1
    80002b84:	b7fd                	j	80002b72 <fetchaddr+0x3e>

0000000080002b86 <fetchstr>:
{
    80002b86:	7179                	addi	sp,sp,-48
    80002b88:	f406                	sd	ra,40(sp)
    80002b8a:	f022                	sd	s0,32(sp)
    80002b8c:	ec26                	sd	s1,24(sp)
    80002b8e:	e84a                	sd	s2,16(sp)
    80002b90:	e44e                	sd	s3,8(sp)
    80002b92:	1800                	addi	s0,sp,48
    80002b94:	892a                	mv	s2,a0
    80002b96:	84ae                	mv	s1,a1
    80002b98:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b9a:	fffff097          	auipc	ra,0xfffff
    80002b9e:	f0c080e7          	jalr	-244(ra) # 80001aa6 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ba2:	86ce                	mv	a3,s3
    80002ba4:	864a                	mv	a2,s2
    80002ba6:	85a6                	mv	a1,s1
    80002ba8:	6d28                	ld	a0,88(a0)
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	d08080e7          	jalr	-760(ra) # 800018b2 <copyinstr>
  if(err < 0)
    80002bb2:	00054763          	bltz	a0,80002bc0 <fetchstr+0x3a>
  return strlen(buf);
    80002bb6:	8526                	mv	a0,s1
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	34e080e7          	jalr	846(ra) # 80000f06 <strlen>
}
    80002bc0:	70a2                	ld	ra,40(sp)
    80002bc2:	7402                	ld	s0,32(sp)
    80002bc4:	64e2                	ld	s1,24(sp)
    80002bc6:	6942                	ld	s2,16(sp)
    80002bc8:	69a2                	ld	s3,8(sp)
    80002bca:	6145                	addi	sp,sp,48
    80002bcc:	8082                	ret

0000000080002bce <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002bce:	1101                	addi	sp,sp,-32
    80002bd0:	ec06                	sd	ra,24(sp)
    80002bd2:	e822                	sd	s0,16(sp)
    80002bd4:	e426                	sd	s1,8(sp)
    80002bd6:	1000                	addi	s0,sp,32
    80002bd8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bda:	00000097          	auipc	ra,0x0
    80002bde:	ef2080e7          	jalr	-270(ra) # 80002acc <argraw>
    80002be2:	c088                	sw	a0,0(s1)
  return 0;
}
    80002be4:	4501                	li	a0,0
    80002be6:	60e2                	ld	ra,24(sp)
    80002be8:	6442                	ld	s0,16(sp)
    80002bea:	64a2                	ld	s1,8(sp)
    80002bec:	6105                	addi	sp,sp,32
    80002bee:	8082                	ret

0000000080002bf0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002bf0:	1101                	addi	sp,sp,-32
    80002bf2:	ec06                	sd	ra,24(sp)
    80002bf4:	e822                	sd	s0,16(sp)
    80002bf6:	e426                	sd	s1,8(sp)
    80002bf8:	1000                	addi	s0,sp,32
    80002bfa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bfc:	00000097          	auipc	ra,0x0
    80002c00:	ed0080e7          	jalr	-304(ra) # 80002acc <argraw>
    80002c04:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c06:	4501                	li	a0,0
    80002c08:	60e2                	ld	ra,24(sp)
    80002c0a:	6442                	ld	s0,16(sp)
    80002c0c:	64a2                	ld	s1,8(sp)
    80002c0e:	6105                	addi	sp,sp,32
    80002c10:	8082                	ret

0000000080002c12 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c12:	1101                	addi	sp,sp,-32
    80002c14:	ec06                	sd	ra,24(sp)
    80002c16:	e822                	sd	s0,16(sp)
    80002c18:	e426                	sd	s1,8(sp)
    80002c1a:	e04a                	sd	s2,0(sp)
    80002c1c:	1000                	addi	s0,sp,32
    80002c1e:	84ae                	mv	s1,a1
    80002c20:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c22:	00000097          	auipc	ra,0x0
    80002c26:	eaa080e7          	jalr	-342(ra) # 80002acc <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c2a:	864a                	mv	a2,s2
    80002c2c:	85a6                	mv	a1,s1
    80002c2e:	00000097          	auipc	ra,0x0
    80002c32:	f58080e7          	jalr	-168(ra) # 80002b86 <fetchstr>
}
    80002c36:	60e2                	ld	ra,24(sp)
    80002c38:	6442                	ld	s0,16(sp)
    80002c3a:	64a2                	ld	s1,8(sp)
    80002c3c:	6902                	ld	s2,0(sp)
    80002c3e:	6105                	addi	sp,sp,32
    80002c40:	8082                	ret

0000000080002c42 <syscall>:
[SYS_ntas]    sys_ntas,
};

void
syscall(void)
{
    80002c42:	1101                	addi	sp,sp,-32
    80002c44:	ec06                	sd	ra,24(sp)
    80002c46:	e822                	sd	s0,16(sp)
    80002c48:	e426                	sd	s1,8(sp)
    80002c4a:	e04a                	sd	s2,0(sp)
    80002c4c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	e58080e7          	jalr	-424(ra) # 80001aa6 <myproc>
    80002c56:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002c58:	06053903          	ld	s2,96(a0)
    80002c5c:	0a893783          	ld	a5,168(s2)
    80002c60:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c64:	37fd                	addiw	a5,a5,-1
    80002c66:	4759                	li	a4,22
    80002c68:	00f76f63          	bltu	a4,a5,80002c86 <syscall+0x44>
    80002c6c:	00369713          	slli	a4,a3,0x3
    80002c70:	00007797          	auipc	a5,0x7
    80002c74:	25878793          	addi	a5,a5,600 # 80009ec8 <syscalls>
    80002c78:	97ba                	add	a5,a5,a4
    80002c7a:	639c                	ld	a5,0(a5)
    80002c7c:	c789                	beqz	a5,80002c86 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002c7e:	9782                	jalr	a5
    80002c80:	06a93823          	sd	a0,112(s2)
    80002c84:	a839                	j	80002ca2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c86:	16048613          	addi	a2,s1,352
    80002c8a:	40ac                	lw	a1,64(s1)
    80002c8c:	00007517          	auipc	a0,0x7
    80002c90:	bd450513          	addi	a0,a0,-1068 # 80009860 <userret+0x7d0>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	920080e7          	jalr	-1760(ra) # 800005b4 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002c9c:	70bc                	ld	a5,96(s1)
    80002c9e:	577d                	li	a4,-1
    80002ca0:	fbb8                	sd	a4,112(a5)
  }
}
    80002ca2:	60e2                	ld	ra,24(sp)
    80002ca4:	6442                	ld	s0,16(sp)
    80002ca6:	64a2                	ld	s1,8(sp)
    80002ca8:	6902                	ld	s2,0(sp)
    80002caa:	6105                	addi	sp,sp,32
    80002cac:	8082                	ret

0000000080002cae <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cae:	1101                	addi	sp,sp,-32
    80002cb0:	ec06                	sd	ra,24(sp)
    80002cb2:	e822                	sd	s0,16(sp)
    80002cb4:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002cb6:	fec40593          	addi	a1,s0,-20
    80002cba:	4501                	li	a0,0
    80002cbc:	00000097          	auipc	ra,0x0
    80002cc0:	f12080e7          	jalr	-238(ra) # 80002bce <argint>
    return -1;
    80002cc4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cc6:	00054963          	bltz	a0,80002cd8 <sys_exit+0x2a>
  exit(n);
    80002cca:	fec42503          	lw	a0,-20(s0)
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	44a080e7          	jalr	1098(ra) # 80002118 <exit>
  return 0;  // not reached
    80002cd6:	4781                	li	a5,0
}
    80002cd8:	853e                	mv	a0,a5
    80002cda:	60e2                	ld	ra,24(sp)
    80002cdc:	6442                	ld	s0,16(sp)
    80002cde:	6105                	addi	sp,sp,32
    80002ce0:	8082                	ret

0000000080002ce2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ce2:	1141                	addi	sp,sp,-16
    80002ce4:	e406                	sd	ra,8(sp)
    80002ce6:	e022                	sd	s0,0(sp)
    80002ce8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cea:	fffff097          	auipc	ra,0xfffff
    80002cee:	dbc080e7          	jalr	-580(ra) # 80001aa6 <myproc>
}
    80002cf2:	4128                	lw	a0,64(a0)
    80002cf4:	60a2                	ld	ra,8(sp)
    80002cf6:	6402                	ld	s0,0(sp)
    80002cf8:	0141                	addi	sp,sp,16
    80002cfa:	8082                	ret

0000000080002cfc <sys_fork>:

uint64
sys_fork(void)
{
    80002cfc:	1141                	addi	sp,sp,-16
    80002cfe:	e406                	sd	ra,8(sp)
    80002d00:	e022                	sd	s0,0(sp)
    80002d02:	0800                	addi	s0,sp,16
  return fork();
    80002d04:	fffff097          	auipc	ra,0xfffff
    80002d08:	10c080e7          	jalr	268(ra) # 80001e10 <fork>
}
    80002d0c:	60a2                	ld	ra,8(sp)
    80002d0e:	6402                	ld	s0,0(sp)
    80002d10:	0141                	addi	sp,sp,16
    80002d12:	8082                	ret

0000000080002d14 <sys_wait>:

uint64
sys_wait(void)
{
    80002d14:	1101                	addi	sp,sp,-32
    80002d16:	ec06                	sd	ra,24(sp)
    80002d18:	e822                	sd	s0,16(sp)
    80002d1a:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d1c:	fe840593          	addi	a1,s0,-24
    80002d20:	4501                	li	a0,0
    80002d22:	00000097          	auipc	ra,0x0
    80002d26:	ece080e7          	jalr	-306(ra) # 80002bf0 <argaddr>
    80002d2a:	87aa                	mv	a5,a0
    return -1;
    80002d2c:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d2e:	0007c863          	bltz	a5,80002d3e <sys_wait+0x2a>
  return wait(p);
    80002d32:	fe843503          	ld	a0,-24(s0)
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	5aa080e7          	jalr	1450(ra) # 800022e0 <wait>
}
    80002d3e:	60e2                	ld	ra,24(sp)
    80002d40:	6442                	ld	s0,16(sp)
    80002d42:	6105                	addi	sp,sp,32
    80002d44:	8082                	ret

0000000080002d46 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d46:	7179                	addi	sp,sp,-48
    80002d48:	f406                	sd	ra,40(sp)
    80002d4a:	f022                	sd	s0,32(sp)
    80002d4c:	ec26                	sd	s1,24(sp)
    80002d4e:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d50:	fdc40593          	addi	a1,s0,-36
    80002d54:	4501                	li	a0,0
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	e78080e7          	jalr	-392(ra) # 80002bce <argint>
    80002d5e:	87aa                	mv	a5,a0
    return -1;
    80002d60:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002d62:	0207c063          	bltz	a5,80002d82 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002d66:	fffff097          	auipc	ra,0xfffff
    80002d6a:	d40080e7          	jalr	-704(ra) # 80001aa6 <myproc>
    80002d6e:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002d70:	fdc42503          	lw	a0,-36(s0)
    80002d74:	fffff097          	auipc	ra,0xfffff
    80002d78:	028080e7          	jalr	40(ra) # 80001d9c <growproc>
    80002d7c:	00054863          	bltz	a0,80002d8c <sys_sbrk+0x46>
    return -1;
  return addr;
    80002d80:	8526                	mv	a0,s1
}
    80002d82:	70a2                	ld	ra,40(sp)
    80002d84:	7402                	ld	s0,32(sp)
    80002d86:	64e2                	ld	s1,24(sp)
    80002d88:	6145                	addi	sp,sp,48
    80002d8a:	8082                	ret
    return -1;
    80002d8c:	557d                	li	a0,-1
    80002d8e:	bfd5                	j	80002d82 <sys_sbrk+0x3c>

0000000080002d90 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d90:	7139                	addi	sp,sp,-64
    80002d92:	fc06                	sd	ra,56(sp)
    80002d94:	f822                	sd	s0,48(sp)
    80002d96:	f426                	sd	s1,40(sp)
    80002d98:	f04a                	sd	s2,32(sp)
    80002d9a:	ec4e                	sd	s3,24(sp)
    80002d9c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d9e:	fcc40593          	addi	a1,s0,-52
    80002da2:	4501                	li	a0,0
    80002da4:	00000097          	auipc	ra,0x0
    80002da8:	e2a080e7          	jalr	-470(ra) # 80002bce <argint>
    return -1;
    80002dac:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dae:	06054563          	bltz	a0,80002e18 <sys_sleep+0x88>
  acquire(&tickslock);
    80002db2:	00014517          	auipc	a0,0x14
    80002db6:	d0e50513          	addi	a0,a0,-754 # 80016ac0 <tickslock>
    80002dba:	ffffe097          	auipc	ra,0xffffe
    80002dbe:	cf6080e7          	jalr	-778(ra) # 80000ab0 <acquire>
  ticks0 = ticks;
    80002dc2:	00026917          	auipc	s2,0x26
    80002dc6:	5be92903          	lw	s2,1470(s2) # 80029380 <ticks>
  while(ticks - ticks0 < n){
    80002dca:	fcc42783          	lw	a5,-52(s0)
    80002dce:	cf85                	beqz	a5,80002e06 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dd0:	00014997          	auipc	s3,0x14
    80002dd4:	cf098993          	addi	s3,s3,-784 # 80016ac0 <tickslock>
    80002dd8:	00026497          	auipc	s1,0x26
    80002ddc:	5a848493          	addi	s1,s1,1448 # 80029380 <ticks>
    if(myproc()->killed){
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	cc6080e7          	jalr	-826(ra) # 80001aa6 <myproc>
    80002de8:	5d1c                	lw	a5,56(a0)
    80002dea:	ef9d                	bnez	a5,80002e28 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002dec:	85ce                	mv	a1,s3
    80002dee:	8526                	mv	a0,s1
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	472080e7          	jalr	1138(ra) # 80002262 <sleep>
  while(ticks - ticks0 < n){
    80002df8:	409c                	lw	a5,0(s1)
    80002dfa:	412787bb          	subw	a5,a5,s2
    80002dfe:	fcc42703          	lw	a4,-52(s0)
    80002e02:	fce7efe3          	bltu	a5,a4,80002de0 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e06:	00014517          	auipc	a0,0x14
    80002e0a:	cba50513          	addi	a0,a0,-838 # 80016ac0 <tickslock>
    80002e0e:	ffffe097          	auipc	ra,0xffffe
    80002e12:	d72080e7          	jalr	-654(ra) # 80000b80 <release>
  return 0;
    80002e16:	4781                	li	a5,0
}
    80002e18:	853e                	mv	a0,a5
    80002e1a:	70e2                	ld	ra,56(sp)
    80002e1c:	7442                	ld	s0,48(sp)
    80002e1e:	74a2                	ld	s1,40(sp)
    80002e20:	7902                	ld	s2,32(sp)
    80002e22:	69e2                	ld	s3,24(sp)
    80002e24:	6121                	addi	sp,sp,64
    80002e26:	8082                	ret
      release(&tickslock);
    80002e28:	00014517          	auipc	a0,0x14
    80002e2c:	c9850513          	addi	a0,a0,-872 # 80016ac0 <tickslock>
    80002e30:	ffffe097          	auipc	ra,0xffffe
    80002e34:	d50080e7          	jalr	-688(ra) # 80000b80 <release>
      return -1;
    80002e38:	57fd                	li	a5,-1
    80002e3a:	bff9                	j	80002e18 <sys_sleep+0x88>

0000000080002e3c <sys_kill>:

uint64
sys_kill(void)
{
    80002e3c:	1101                	addi	sp,sp,-32
    80002e3e:	ec06                	sd	ra,24(sp)
    80002e40:	e822                	sd	s0,16(sp)
    80002e42:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e44:	fec40593          	addi	a1,s0,-20
    80002e48:	4501                	li	a0,0
    80002e4a:	00000097          	auipc	ra,0x0
    80002e4e:	d84080e7          	jalr	-636(ra) # 80002bce <argint>
    80002e52:	87aa                	mv	a5,a0
    return -1;
    80002e54:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e56:	0007c863          	bltz	a5,80002e66 <sys_kill+0x2a>
  return kill(pid);
    80002e5a:	fec42503          	lw	a0,-20(s0)
    80002e5e:	fffff097          	auipc	ra,0xfffff
    80002e62:	5f4080e7          	jalr	1524(ra) # 80002452 <kill>
}
    80002e66:	60e2                	ld	ra,24(sp)
    80002e68:	6442                	ld	s0,16(sp)
    80002e6a:	6105                	addi	sp,sp,32
    80002e6c:	8082                	ret

0000000080002e6e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e6e:	1101                	addi	sp,sp,-32
    80002e70:	ec06                	sd	ra,24(sp)
    80002e72:	e822                	sd	s0,16(sp)
    80002e74:	e426                	sd	s1,8(sp)
    80002e76:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e78:	00014517          	auipc	a0,0x14
    80002e7c:	c4850513          	addi	a0,a0,-952 # 80016ac0 <tickslock>
    80002e80:	ffffe097          	auipc	ra,0xffffe
    80002e84:	c30080e7          	jalr	-976(ra) # 80000ab0 <acquire>
  xticks = ticks;
    80002e88:	00026497          	auipc	s1,0x26
    80002e8c:	4f84a483          	lw	s1,1272(s1) # 80029380 <ticks>
  release(&tickslock);
    80002e90:	00014517          	auipc	a0,0x14
    80002e94:	c3050513          	addi	a0,a0,-976 # 80016ac0 <tickslock>
    80002e98:	ffffe097          	auipc	ra,0xffffe
    80002e9c:	ce8080e7          	jalr	-792(ra) # 80000b80 <release>
  return xticks;
}
    80002ea0:	02049513          	slli	a0,s1,0x20
    80002ea4:	9101                	srli	a0,a0,0x20
    80002ea6:	60e2                	ld	ra,24(sp)
    80002ea8:	6442                	ld	s0,16(sp)
    80002eaa:	64a2                	ld	s1,8(sp)
    80002eac:	6105                	addi	sp,sp,32
    80002eae:	8082                	ret

0000000080002eb0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002eb0:	7179                	addi	sp,sp,-48
    80002eb2:	f406                	sd	ra,40(sp)
    80002eb4:	f022                	sd	s0,32(sp)
    80002eb6:	ec26                	sd	s1,24(sp)
    80002eb8:	e84a                	sd	s2,16(sp)
    80002eba:	e44e                	sd	s3,8(sp)
    80002ebc:	e052                	sd	s4,0(sp)
    80002ebe:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ec0:	00006597          	auipc	a1,0x6
    80002ec4:	3f858593          	addi	a1,a1,1016 # 800092b8 <userret+0x228>
    80002ec8:	00014517          	auipc	a0,0x14
    80002ecc:	c1850513          	addi	a0,a0,-1000 # 80016ae0 <bcache>
    80002ed0:	ffffe097          	auipc	ra,0xffffe
    80002ed4:	b0c080e7          	jalr	-1268(ra) # 800009dc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ed8:	0001c797          	auipc	a5,0x1c
    80002edc:	c0878793          	addi	a5,a5,-1016 # 8001eae0 <bcache+0x8000>
    80002ee0:	0001c717          	auipc	a4,0x1c
    80002ee4:	f6070713          	addi	a4,a4,-160 # 8001ee40 <bcache+0x8360>
    80002ee8:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80002eec:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ef0:	00014497          	auipc	s1,0x14
    80002ef4:	c1048493          	addi	s1,s1,-1008 # 80016b00 <bcache+0x20>
    b->next = bcache.head.next;
    80002ef8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002efa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002efc:	00007a17          	auipc	s4,0x7
    80002f00:	984a0a13          	addi	s4,s4,-1660 # 80009880 <userret+0x7f0>
    b->next = bcache.head.next;
    80002f04:	3b893783          	ld	a5,952(s2)
    80002f08:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80002f0a:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80002f0e:	85d2                	mv	a1,s4
    80002f10:	01048513          	addi	a0,s1,16
    80002f14:	00001097          	auipc	ra,0x1
    80002f18:	5a0080e7          	jalr	1440(ra) # 800044b4 <initsleeplock>
    bcache.head.next->prev = b;
    80002f1c:	3b893783          	ld	a5,952(s2)
    80002f20:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80002f22:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f26:	46048493          	addi	s1,s1,1120
    80002f2a:	fd349de3          	bne	s1,s3,80002f04 <binit+0x54>
  }
}
    80002f2e:	70a2                	ld	ra,40(sp)
    80002f30:	7402                	ld	s0,32(sp)
    80002f32:	64e2                	ld	s1,24(sp)
    80002f34:	6942                	ld	s2,16(sp)
    80002f36:	69a2                	ld	s3,8(sp)
    80002f38:	6a02                	ld	s4,0(sp)
    80002f3a:	6145                	addi	sp,sp,48
    80002f3c:	8082                	ret

0000000080002f3e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f3e:	7179                	addi	sp,sp,-48
    80002f40:	f406                	sd	ra,40(sp)
    80002f42:	f022                	sd	s0,32(sp)
    80002f44:	ec26                	sd	s1,24(sp)
    80002f46:	e84a                	sd	s2,16(sp)
    80002f48:	e44e                	sd	s3,8(sp)
    80002f4a:	1800                	addi	s0,sp,48
    80002f4c:	89aa                	mv	s3,a0
    80002f4e:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002f50:	00014517          	auipc	a0,0x14
    80002f54:	b9050513          	addi	a0,a0,-1136 # 80016ae0 <bcache>
    80002f58:	ffffe097          	auipc	ra,0xffffe
    80002f5c:	b58080e7          	jalr	-1192(ra) # 80000ab0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f60:	0001c497          	auipc	s1,0x1c
    80002f64:	f384b483          	ld	s1,-200(s1) # 8001ee98 <bcache+0x83b8>
    80002f68:	0001c797          	auipc	a5,0x1c
    80002f6c:	ed878793          	addi	a5,a5,-296 # 8001ee40 <bcache+0x8360>
    80002f70:	02f48f63          	beq	s1,a5,80002fae <bread+0x70>
    80002f74:	873e                	mv	a4,a5
    80002f76:	a021                	j	80002f7e <bread+0x40>
    80002f78:	6ca4                	ld	s1,88(s1)
    80002f7a:	02e48a63          	beq	s1,a4,80002fae <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f7e:	449c                	lw	a5,8(s1)
    80002f80:	ff379ce3          	bne	a5,s3,80002f78 <bread+0x3a>
    80002f84:	44dc                	lw	a5,12(s1)
    80002f86:	ff2799e3          	bne	a5,s2,80002f78 <bread+0x3a>
      b->refcnt++;
    80002f8a:	44bc                	lw	a5,72(s1)
    80002f8c:	2785                	addiw	a5,a5,1
    80002f8e:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002f90:	00014517          	auipc	a0,0x14
    80002f94:	b5050513          	addi	a0,a0,-1200 # 80016ae0 <bcache>
    80002f98:	ffffe097          	auipc	ra,0xffffe
    80002f9c:	be8080e7          	jalr	-1048(ra) # 80000b80 <release>
      acquiresleep(&b->lock);
    80002fa0:	01048513          	addi	a0,s1,16
    80002fa4:	00001097          	auipc	ra,0x1
    80002fa8:	54a080e7          	jalr	1354(ra) # 800044ee <acquiresleep>
      return b;
    80002fac:	a8b9                	j	8000300a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fae:	0001c497          	auipc	s1,0x1c
    80002fb2:	ee24b483          	ld	s1,-286(s1) # 8001ee90 <bcache+0x83b0>
    80002fb6:	0001c797          	auipc	a5,0x1c
    80002fba:	e8a78793          	addi	a5,a5,-374 # 8001ee40 <bcache+0x8360>
    80002fbe:	00f48863          	beq	s1,a5,80002fce <bread+0x90>
    80002fc2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fc4:	44bc                	lw	a5,72(s1)
    80002fc6:	cf81                	beqz	a5,80002fde <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fc8:	68a4                	ld	s1,80(s1)
    80002fca:	fee49de3          	bne	s1,a4,80002fc4 <bread+0x86>
  panic("bget: no buffers");
    80002fce:	00007517          	auipc	a0,0x7
    80002fd2:	8ba50513          	addi	a0,a0,-1862 # 80009888 <userret+0x7f8>
    80002fd6:	ffffd097          	auipc	ra,0xffffd
    80002fda:	584080e7          	jalr	1412(ra) # 8000055a <panic>
      b->dev = dev;
    80002fde:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002fe2:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002fe6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fea:	4785                	li	a5,1
    80002fec:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002fee:	00014517          	auipc	a0,0x14
    80002ff2:	af250513          	addi	a0,a0,-1294 # 80016ae0 <bcache>
    80002ff6:	ffffe097          	auipc	ra,0xffffe
    80002ffa:	b8a080e7          	jalr	-1142(ra) # 80000b80 <release>
      acquiresleep(&b->lock);
    80002ffe:	01048513          	addi	a0,s1,16
    80003002:	00001097          	auipc	ra,0x1
    80003006:	4ec080e7          	jalr	1260(ra) # 800044ee <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000300a:	409c                	lw	a5,0(s1)
    8000300c:	cb89                	beqz	a5,8000301e <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    8000300e:	8526                	mv	a0,s1
    80003010:	70a2                	ld	ra,40(sp)
    80003012:	7402                	ld	s0,32(sp)
    80003014:	64e2                	ld	s1,24(sp)
    80003016:	6942                	ld	s2,16(sp)
    80003018:	69a2                	ld	s3,8(sp)
    8000301a:	6145                	addi	sp,sp,48
    8000301c:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    8000301e:	4601                	li	a2,0
    80003020:	85a6                	mv	a1,s1
    80003022:	4488                	lw	a0,8(s1)
    80003024:	00003097          	auipc	ra,0x3
    80003028:	1e0080e7          	jalr	480(ra) # 80006204 <virtio_disk_rw>
    b->valid = 1;
    8000302c:	4785                	li	a5,1
    8000302e:	c09c                	sw	a5,0(s1)
  return b;
    80003030:	bff9                	j	8000300e <bread+0xd0>

0000000080003032 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003032:	1101                	addi	sp,sp,-32
    80003034:	ec06                	sd	ra,24(sp)
    80003036:	e822                	sd	s0,16(sp)
    80003038:	e426                	sd	s1,8(sp)
    8000303a:	1000                	addi	s0,sp,32
    8000303c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000303e:	0541                	addi	a0,a0,16
    80003040:	00001097          	auipc	ra,0x1
    80003044:	548080e7          	jalr	1352(ra) # 80004588 <holdingsleep>
    80003048:	cd09                	beqz	a0,80003062 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    8000304a:	4605                	li	a2,1
    8000304c:	85a6                	mv	a1,s1
    8000304e:	4488                	lw	a0,8(s1)
    80003050:	00003097          	auipc	ra,0x3
    80003054:	1b4080e7          	jalr	436(ra) # 80006204 <virtio_disk_rw>
}
    80003058:	60e2                	ld	ra,24(sp)
    8000305a:	6442                	ld	s0,16(sp)
    8000305c:	64a2                	ld	s1,8(sp)
    8000305e:	6105                	addi	sp,sp,32
    80003060:	8082                	ret
    panic("bwrite");
    80003062:	00007517          	auipc	a0,0x7
    80003066:	83e50513          	addi	a0,a0,-1986 # 800098a0 <userret+0x810>
    8000306a:	ffffd097          	auipc	ra,0xffffd
    8000306e:	4f0080e7          	jalr	1264(ra) # 8000055a <panic>

0000000080003072 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003072:	1101                	addi	sp,sp,-32
    80003074:	ec06                	sd	ra,24(sp)
    80003076:	e822                	sd	s0,16(sp)
    80003078:	e426                	sd	s1,8(sp)
    8000307a:	e04a                	sd	s2,0(sp)
    8000307c:	1000                	addi	s0,sp,32
    8000307e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003080:	01050913          	addi	s2,a0,16
    80003084:	854a                	mv	a0,s2
    80003086:	00001097          	auipc	ra,0x1
    8000308a:	502080e7          	jalr	1282(ra) # 80004588 <holdingsleep>
    8000308e:	c92d                	beqz	a0,80003100 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003090:	854a                	mv	a0,s2
    80003092:	00001097          	auipc	ra,0x1
    80003096:	4b2080e7          	jalr	1202(ra) # 80004544 <releasesleep>

  acquire(&bcache.lock);
    8000309a:	00014517          	auipc	a0,0x14
    8000309e:	a4650513          	addi	a0,a0,-1466 # 80016ae0 <bcache>
    800030a2:	ffffe097          	auipc	ra,0xffffe
    800030a6:	a0e080e7          	jalr	-1522(ra) # 80000ab0 <acquire>
  b->refcnt--;
    800030aa:	44bc                	lw	a5,72(s1)
    800030ac:	37fd                	addiw	a5,a5,-1
    800030ae:	0007871b          	sext.w	a4,a5
    800030b2:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    800030b4:	eb05                	bnez	a4,800030e4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030b6:	6cbc                	ld	a5,88(s1)
    800030b8:	68b8                	ld	a4,80(s1)
    800030ba:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    800030bc:	68bc                	ld	a5,80(s1)
    800030be:	6cb8                	ld	a4,88(s1)
    800030c0:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    800030c2:	0001c797          	auipc	a5,0x1c
    800030c6:	a1e78793          	addi	a5,a5,-1506 # 8001eae0 <bcache+0x8000>
    800030ca:	3b87b703          	ld	a4,952(a5)
    800030ce:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    800030d0:	0001c717          	auipc	a4,0x1c
    800030d4:	d7070713          	addi	a4,a4,-656 # 8001ee40 <bcache+0x8360>
    800030d8:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    800030da:	3b87b703          	ld	a4,952(a5)
    800030de:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    800030e0:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    800030e4:	00014517          	auipc	a0,0x14
    800030e8:	9fc50513          	addi	a0,a0,-1540 # 80016ae0 <bcache>
    800030ec:	ffffe097          	auipc	ra,0xffffe
    800030f0:	a94080e7          	jalr	-1388(ra) # 80000b80 <release>
}
    800030f4:	60e2                	ld	ra,24(sp)
    800030f6:	6442                	ld	s0,16(sp)
    800030f8:	64a2                	ld	s1,8(sp)
    800030fa:	6902                	ld	s2,0(sp)
    800030fc:	6105                	addi	sp,sp,32
    800030fe:	8082                	ret
    panic("brelse");
    80003100:	00006517          	auipc	a0,0x6
    80003104:	7a850513          	addi	a0,a0,1960 # 800098a8 <userret+0x818>
    80003108:	ffffd097          	auipc	ra,0xffffd
    8000310c:	452080e7          	jalr	1106(ra) # 8000055a <panic>

0000000080003110 <bpin>:

void
bpin(struct buf *b) {
    80003110:	1101                	addi	sp,sp,-32
    80003112:	ec06                	sd	ra,24(sp)
    80003114:	e822                	sd	s0,16(sp)
    80003116:	e426                	sd	s1,8(sp)
    80003118:	1000                	addi	s0,sp,32
    8000311a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000311c:	00014517          	auipc	a0,0x14
    80003120:	9c450513          	addi	a0,a0,-1596 # 80016ae0 <bcache>
    80003124:	ffffe097          	auipc	ra,0xffffe
    80003128:	98c080e7          	jalr	-1652(ra) # 80000ab0 <acquire>
  b->refcnt++;
    8000312c:	44bc                	lw	a5,72(s1)
    8000312e:	2785                	addiw	a5,a5,1
    80003130:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003132:	00014517          	auipc	a0,0x14
    80003136:	9ae50513          	addi	a0,a0,-1618 # 80016ae0 <bcache>
    8000313a:	ffffe097          	auipc	ra,0xffffe
    8000313e:	a46080e7          	jalr	-1466(ra) # 80000b80 <release>
}
    80003142:	60e2                	ld	ra,24(sp)
    80003144:	6442                	ld	s0,16(sp)
    80003146:	64a2                	ld	s1,8(sp)
    80003148:	6105                	addi	sp,sp,32
    8000314a:	8082                	ret

000000008000314c <bunpin>:

void
bunpin(struct buf *b) {
    8000314c:	1101                	addi	sp,sp,-32
    8000314e:	ec06                	sd	ra,24(sp)
    80003150:	e822                	sd	s0,16(sp)
    80003152:	e426                	sd	s1,8(sp)
    80003154:	1000                	addi	s0,sp,32
    80003156:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003158:	00014517          	auipc	a0,0x14
    8000315c:	98850513          	addi	a0,a0,-1656 # 80016ae0 <bcache>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	950080e7          	jalr	-1712(ra) # 80000ab0 <acquire>
  b->refcnt--;
    80003168:	44bc                	lw	a5,72(s1)
    8000316a:	37fd                	addiw	a5,a5,-1
    8000316c:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000316e:	00014517          	auipc	a0,0x14
    80003172:	97250513          	addi	a0,a0,-1678 # 80016ae0 <bcache>
    80003176:	ffffe097          	auipc	ra,0xffffe
    8000317a:	a0a080e7          	jalr	-1526(ra) # 80000b80 <release>
}
    8000317e:	60e2                	ld	ra,24(sp)
    80003180:	6442                	ld	s0,16(sp)
    80003182:	64a2                	ld	s1,8(sp)
    80003184:	6105                	addi	sp,sp,32
    80003186:	8082                	ret

0000000080003188 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003188:	1101                	addi	sp,sp,-32
    8000318a:	ec06                	sd	ra,24(sp)
    8000318c:	e822                	sd	s0,16(sp)
    8000318e:	e426                	sd	s1,8(sp)
    80003190:	e04a                	sd	s2,0(sp)
    80003192:	1000                	addi	s0,sp,32
    80003194:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003196:	00d5d59b          	srliw	a1,a1,0xd
    8000319a:	0001c797          	auipc	a5,0x1c
    8000319e:	1227a783          	lw	a5,290(a5) # 8001f2bc <sb+0x1c>
    800031a2:	9dbd                	addw	a1,a1,a5
    800031a4:	00000097          	auipc	ra,0x0
    800031a8:	d9a080e7          	jalr	-614(ra) # 80002f3e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031ac:	0074f713          	andi	a4,s1,7
    800031b0:	4785                	li	a5,1
    800031b2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031b6:	14ce                	slli	s1,s1,0x33
    800031b8:	90d9                	srli	s1,s1,0x36
    800031ba:	00950733          	add	a4,a0,s1
    800031be:	06074703          	lbu	a4,96(a4)
    800031c2:	00e7f6b3          	and	a3,a5,a4
    800031c6:	c69d                	beqz	a3,800031f4 <bfree+0x6c>
    800031c8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031ca:	94aa                	add	s1,s1,a0
    800031cc:	fff7c793          	not	a5,a5
    800031d0:	8ff9                	and	a5,a5,a4
    800031d2:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800031d6:	00001097          	auipc	ra,0x1
    800031da:	19e080e7          	jalr	414(ra) # 80004374 <log_write>
  brelse(bp);
    800031de:	854a                	mv	a0,s2
    800031e0:	00000097          	auipc	ra,0x0
    800031e4:	e92080e7          	jalr	-366(ra) # 80003072 <brelse>
}
    800031e8:	60e2                	ld	ra,24(sp)
    800031ea:	6442                	ld	s0,16(sp)
    800031ec:	64a2                	ld	s1,8(sp)
    800031ee:	6902                	ld	s2,0(sp)
    800031f0:	6105                	addi	sp,sp,32
    800031f2:	8082                	ret
    panic("freeing free block");
    800031f4:	00006517          	auipc	a0,0x6
    800031f8:	6bc50513          	addi	a0,a0,1724 # 800098b0 <userret+0x820>
    800031fc:	ffffd097          	auipc	ra,0xffffd
    80003200:	35e080e7          	jalr	862(ra) # 8000055a <panic>

0000000080003204 <balloc>:
{
    80003204:	711d                	addi	sp,sp,-96
    80003206:	ec86                	sd	ra,88(sp)
    80003208:	e8a2                	sd	s0,80(sp)
    8000320a:	e4a6                	sd	s1,72(sp)
    8000320c:	e0ca                	sd	s2,64(sp)
    8000320e:	fc4e                	sd	s3,56(sp)
    80003210:	f852                	sd	s4,48(sp)
    80003212:	f456                	sd	s5,40(sp)
    80003214:	f05a                	sd	s6,32(sp)
    80003216:	ec5e                	sd	s7,24(sp)
    80003218:	e862                	sd	s8,16(sp)
    8000321a:	e466                	sd	s9,8(sp)
    8000321c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000321e:	0001c797          	auipc	a5,0x1c
    80003222:	0867a783          	lw	a5,134(a5) # 8001f2a4 <sb+0x4>
    80003226:	cbd1                	beqz	a5,800032ba <balloc+0xb6>
    80003228:	8baa                	mv	s7,a0
    8000322a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000322c:	0001cb17          	auipc	s6,0x1c
    80003230:	074b0b13          	addi	s6,s6,116 # 8001f2a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003234:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003236:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003238:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000323a:	6c89                	lui	s9,0x2
    8000323c:	a831                	j	80003258 <balloc+0x54>
    brelse(bp);
    8000323e:	854a                	mv	a0,s2
    80003240:	00000097          	auipc	ra,0x0
    80003244:	e32080e7          	jalr	-462(ra) # 80003072 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003248:	015c87bb          	addw	a5,s9,s5
    8000324c:	00078a9b          	sext.w	s5,a5
    80003250:	004b2703          	lw	a4,4(s6)
    80003254:	06eaf363          	bgeu	s5,a4,800032ba <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003258:	41fad79b          	sraiw	a5,s5,0x1f
    8000325c:	0137d79b          	srliw	a5,a5,0x13
    80003260:	015787bb          	addw	a5,a5,s5
    80003264:	40d7d79b          	sraiw	a5,a5,0xd
    80003268:	01cb2583          	lw	a1,28(s6)
    8000326c:	9dbd                	addw	a1,a1,a5
    8000326e:	855e                	mv	a0,s7
    80003270:	00000097          	auipc	ra,0x0
    80003274:	cce080e7          	jalr	-818(ra) # 80002f3e <bread>
    80003278:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000327a:	004b2503          	lw	a0,4(s6)
    8000327e:	000a849b          	sext.w	s1,s5
    80003282:	8662                	mv	a2,s8
    80003284:	faa4fde3          	bgeu	s1,a0,8000323e <balloc+0x3a>
      m = 1 << (bi % 8);
    80003288:	41f6579b          	sraiw	a5,a2,0x1f
    8000328c:	01d7d69b          	srliw	a3,a5,0x1d
    80003290:	00c6873b          	addw	a4,a3,a2
    80003294:	00777793          	andi	a5,a4,7
    80003298:	9f95                	subw	a5,a5,a3
    8000329a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000329e:	4037571b          	sraiw	a4,a4,0x3
    800032a2:	00e906b3          	add	a3,s2,a4
    800032a6:	0606c683          	lbu	a3,96(a3)
    800032aa:	00d7f5b3          	and	a1,a5,a3
    800032ae:	cd91                	beqz	a1,800032ca <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032b0:	2605                	addiw	a2,a2,1
    800032b2:	2485                	addiw	s1,s1,1
    800032b4:	fd4618e3          	bne	a2,s4,80003284 <balloc+0x80>
    800032b8:	b759                	j	8000323e <balloc+0x3a>
  panic("balloc: out of blocks");
    800032ba:	00006517          	auipc	a0,0x6
    800032be:	60e50513          	addi	a0,a0,1550 # 800098c8 <userret+0x838>
    800032c2:	ffffd097          	auipc	ra,0xffffd
    800032c6:	298080e7          	jalr	664(ra) # 8000055a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032ca:	974a                	add	a4,a4,s2
    800032cc:	8fd5                	or	a5,a5,a3
    800032ce:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    800032d2:	854a                	mv	a0,s2
    800032d4:	00001097          	auipc	ra,0x1
    800032d8:	0a0080e7          	jalr	160(ra) # 80004374 <log_write>
        brelse(bp);
    800032dc:	854a                	mv	a0,s2
    800032de:	00000097          	auipc	ra,0x0
    800032e2:	d94080e7          	jalr	-620(ra) # 80003072 <brelse>
  bp = bread(dev, bno);
    800032e6:	85a6                	mv	a1,s1
    800032e8:	855e                	mv	a0,s7
    800032ea:	00000097          	auipc	ra,0x0
    800032ee:	c54080e7          	jalr	-940(ra) # 80002f3e <bread>
    800032f2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032f4:	40000613          	li	a2,1024
    800032f8:	4581                	li	a1,0
    800032fa:	06050513          	addi	a0,a0,96
    800032fe:	ffffe097          	auipc	ra,0xffffe
    80003302:	a80080e7          	jalr	-1408(ra) # 80000d7e <memset>
  log_write(bp);
    80003306:	854a                	mv	a0,s2
    80003308:	00001097          	auipc	ra,0x1
    8000330c:	06c080e7          	jalr	108(ra) # 80004374 <log_write>
  brelse(bp);
    80003310:	854a                	mv	a0,s2
    80003312:	00000097          	auipc	ra,0x0
    80003316:	d60080e7          	jalr	-672(ra) # 80003072 <brelse>
}
    8000331a:	8526                	mv	a0,s1
    8000331c:	60e6                	ld	ra,88(sp)
    8000331e:	6446                	ld	s0,80(sp)
    80003320:	64a6                	ld	s1,72(sp)
    80003322:	6906                	ld	s2,64(sp)
    80003324:	79e2                	ld	s3,56(sp)
    80003326:	7a42                	ld	s4,48(sp)
    80003328:	7aa2                	ld	s5,40(sp)
    8000332a:	7b02                	ld	s6,32(sp)
    8000332c:	6be2                	ld	s7,24(sp)
    8000332e:	6c42                	ld	s8,16(sp)
    80003330:	6ca2                	ld	s9,8(sp)
    80003332:	6125                	addi	sp,sp,96
    80003334:	8082                	ret

0000000080003336 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003336:	7179                	addi	sp,sp,-48
    80003338:	f406                	sd	ra,40(sp)
    8000333a:	f022                	sd	s0,32(sp)
    8000333c:	ec26                	sd	s1,24(sp)
    8000333e:	e84a                	sd	s2,16(sp)
    80003340:	e44e                	sd	s3,8(sp)
    80003342:	e052                	sd	s4,0(sp)
    80003344:	1800                	addi	s0,sp,48
    80003346:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003348:	47ad                	li	a5,11
    8000334a:	04b7fe63          	bgeu	a5,a1,800033a6 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000334e:	ff45849b          	addiw	s1,a1,-12
    80003352:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003356:	0ff00793          	li	a5,255
    8000335a:	0ae7e363          	bltu	a5,a4,80003400 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000335e:	08852583          	lw	a1,136(a0)
    80003362:	c5ad                	beqz	a1,800033cc <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003364:	00092503          	lw	a0,0(s2)
    80003368:	00000097          	auipc	ra,0x0
    8000336c:	bd6080e7          	jalr	-1066(ra) # 80002f3e <bread>
    80003370:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003372:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003376:	02049593          	slli	a1,s1,0x20
    8000337a:	9181                	srli	a1,a1,0x20
    8000337c:	058a                	slli	a1,a1,0x2
    8000337e:	00b784b3          	add	s1,a5,a1
    80003382:	0004a983          	lw	s3,0(s1)
    80003386:	04098d63          	beqz	s3,800033e0 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000338a:	8552                	mv	a0,s4
    8000338c:	00000097          	auipc	ra,0x0
    80003390:	ce6080e7          	jalr	-794(ra) # 80003072 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003394:	854e                	mv	a0,s3
    80003396:	70a2                	ld	ra,40(sp)
    80003398:	7402                	ld	s0,32(sp)
    8000339a:	64e2                	ld	s1,24(sp)
    8000339c:	6942                	ld	s2,16(sp)
    8000339e:	69a2                	ld	s3,8(sp)
    800033a0:	6a02                	ld	s4,0(sp)
    800033a2:	6145                	addi	sp,sp,48
    800033a4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033a6:	02059493          	slli	s1,a1,0x20
    800033aa:	9081                	srli	s1,s1,0x20
    800033ac:	048a                	slli	s1,s1,0x2
    800033ae:	94aa                	add	s1,s1,a0
    800033b0:	0584a983          	lw	s3,88(s1)
    800033b4:	fe0990e3          	bnez	s3,80003394 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033b8:	4108                	lw	a0,0(a0)
    800033ba:	00000097          	auipc	ra,0x0
    800033be:	e4a080e7          	jalr	-438(ra) # 80003204 <balloc>
    800033c2:	0005099b          	sext.w	s3,a0
    800033c6:	0534ac23          	sw	s3,88(s1)
    800033ca:	b7e9                	j	80003394 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033cc:	4108                	lw	a0,0(a0)
    800033ce:	00000097          	auipc	ra,0x0
    800033d2:	e36080e7          	jalr	-458(ra) # 80003204 <balloc>
    800033d6:	0005059b          	sext.w	a1,a0
    800033da:	08b92423          	sw	a1,136(s2)
    800033de:	b759                	j	80003364 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800033e0:	00092503          	lw	a0,0(s2)
    800033e4:	00000097          	auipc	ra,0x0
    800033e8:	e20080e7          	jalr	-480(ra) # 80003204 <balloc>
    800033ec:	0005099b          	sext.w	s3,a0
    800033f0:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800033f4:	8552                	mv	a0,s4
    800033f6:	00001097          	auipc	ra,0x1
    800033fa:	f7e080e7          	jalr	-130(ra) # 80004374 <log_write>
    800033fe:	b771                	j	8000338a <bmap+0x54>
  panic("bmap: out of range");
    80003400:	00006517          	auipc	a0,0x6
    80003404:	4e050513          	addi	a0,a0,1248 # 800098e0 <userret+0x850>
    80003408:	ffffd097          	auipc	ra,0xffffd
    8000340c:	152080e7          	jalr	338(ra) # 8000055a <panic>

0000000080003410 <iget>:
{
    80003410:	7179                	addi	sp,sp,-48
    80003412:	f406                	sd	ra,40(sp)
    80003414:	f022                	sd	s0,32(sp)
    80003416:	ec26                	sd	s1,24(sp)
    80003418:	e84a                	sd	s2,16(sp)
    8000341a:	e44e                	sd	s3,8(sp)
    8000341c:	e052                	sd	s4,0(sp)
    8000341e:	1800                	addi	s0,sp,48
    80003420:	89aa                	mv	s3,a0
    80003422:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003424:	0001c517          	auipc	a0,0x1c
    80003428:	e9c50513          	addi	a0,a0,-356 # 8001f2c0 <icache>
    8000342c:	ffffd097          	auipc	ra,0xffffd
    80003430:	684080e7          	jalr	1668(ra) # 80000ab0 <acquire>
  empty = 0;
    80003434:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003436:	0001c497          	auipc	s1,0x1c
    8000343a:	eaa48493          	addi	s1,s1,-342 # 8001f2e0 <icache+0x20>
    8000343e:	0001e697          	auipc	a3,0x1e
    80003442:	ac268693          	addi	a3,a3,-1342 # 80020f00 <log>
    80003446:	a039                	j	80003454 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003448:	02090b63          	beqz	s2,8000347e <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000344c:	09048493          	addi	s1,s1,144
    80003450:	02d48a63          	beq	s1,a3,80003484 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003454:	449c                	lw	a5,8(s1)
    80003456:	fef059e3          	blez	a5,80003448 <iget+0x38>
    8000345a:	4098                	lw	a4,0(s1)
    8000345c:	ff3716e3          	bne	a4,s3,80003448 <iget+0x38>
    80003460:	40d8                	lw	a4,4(s1)
    80003462:	ff4713e3          	bne	a4,s4,80003448 <iget+0x38>
      ip->ref++;
    80003466:	2785                	addiw	a5,a5,1
    80003468:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000346a:	0001c517          	auipc	a0,0x1c
    8000346e:	e5650513          	addi	a0,a0,-426 # 8001f2c0 <icache>
    80003472:	ffffd097          	auipc	ra,0xffffd
    80003476:	70e080e7          	jalr	1806(ra) # 80000b80 <release>
      return ip;
    8000347a:	8926                	mv	s2,s1
    8000347c:	a03d                	j	800034aa <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000347e:	f7f9                	bnez	a5,8000344c <iget+0x3c>
    80003480:	8926                	mv	s2,s1
    80003482:	b7e9                	j	8000344c <iget+0x3c>
  if(empty == 0)
    80003484:	02090c63          	beqz	s2,800034bc <iget+0xac>
  ip->dev = dev;
    80003488:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000348c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003490:	4785                	li	a5,1
    80003492:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003496:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    8000349a:	0001c517          	auipc	a0,0x1c
    8000349e:	e2650513          	addi	a0,a0,-474 # 8001f2c0 <icache>
    800034a2:	ffffd097          	auipc	ra,0xffffd
    800034a6:	6de080e7          	jalr	1758(ra) # 80000b80 <release>
}
    800034aa:	854a                	mv	a0,s2
    800034ac:	70a2                	ld	ra,40(sp)
    800034ae:	7402                	ld	s0,32(sp)
    800034b0:	64e2                	ld	s1,24(sp)
    800034b2:	6942                	ld	s2,16(sp)
    800034b4:	69a2                	ld	s3,8(sp)
    800034b6:	6a02                	ld	s4,0(sp)
    800034b8:	6145                	addi	sp,sp,48
    800034ba:	8082                	ret
    panic("iget: no inodes");
    800034bc:	00006517          	auipc	a0,0x6
    800034c0:	43c50513          	addi	a0,a0,1084 # 800098f8 <userret+0x868>
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	096080e7          	jalr	150(ra) # 8000055a <panic>

00000000800034cc <fsinit>:
fsinit(int dev) {
    800034cc:	7179                	addi	sp,sp,-48
    800034ce:	f406                	sd	ra,40(sp)
    800034d0:	f022                	sd	s0,32(sp)
    800034d2:	ec26                	sd	s1,24(sp)
    800034d4:	e84a                	sd	s2,16(sp)
    800034d6:	e44e                	sd	s3,8(sp)
    800034d8:	1800                	addi	s0,sp,48
    800034da:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034dc:	4585                	li	a1,1
    800034de:	00000097          	auipc	ra,0x0
    800034e2:	a60080e7          	jalr	-1440(ra) # 80002f3e <bread>
    800034e6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034e8:	0001c997          	auipc	s3,0x1c
    800034ec:	db898993          	addi	s3,s3,-584 # 8001f2a0 <sb>
    800034f0:	02000613          	li	a2,32
    800034f4:	06050593          	addi	a1,a0,96
    800034f8:	854e                	mv	a0,s3
    800034fa:	ffffe097          	auipc	ra,0xffffe
    800034fe:	8e4080e7          	jalr	-1820(ra) # 80000dde <memmove>
  brelse(bp);
    80003502:	8526                	mv	a0,s1
    80003504:	00000097          	auipc	ra,0x0
    80003508:	b6e080e7          	jalr	-1170(ra) # 80003072 <brelse>
  if(sb.magic != FSMAGIC)
    8000350c:	0009a703          	lw	a4,0(s3)
    80003510:	102037b7          	lui	a5,0x10203
    80003514:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003518:	02f71263          	bne	a4,a5,8000353c <fsinit+0x70>
  initlog(dev, &sb);
    8000351c:	0001c597          	auipc	a1,0x1c
    80003520:	d8458593          	addi	a1,a1,-636 # 8001f2a0 <sb>
    80003524:	854a                	mv	a0,s2
    80003526:	00001097          	auipc	ra,0x1
    8000352a:	b38080e7          	jalr	-1224(ra) # 8000405e <initlog>
}
    8000352e:	70a2                	ld	ra,40(sp)
    80003530:	7402                	ld	s0,32(sp)
    80003532:	64e2                	ld	s1,24(sp)
    80003534:	6942                	ld	s2,16(sp)
    80003536:	69a2                	ld	s3,8(sp)
    80003538:	6145                	addi	sp,sp,48
    8000353a:	8082                	ret
    panic("invalid file system");
    8000353c:	00006517          	auipc	a0,0x6
    80003540:	3cc50513          	addi	a0,a0,972 # 80009908 <userret+0x878>
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	016080e7          	jalr	22(ra) # 8000055a <panic>

000000008000354c <iinit>:
{
    8000354c:	7179                	addi	sp,sp,-48
    8000354e:	f406                	sd	ra,40(sp)
    80003550:	f022                	sd	s0,32(sp)
    80003552:	ec26                	sd	s1,24(sp)
    80003554:	e84a                	sd	s2,16(sp)
    80003556:	e44e                	sd	s3,8(sp)
    80003558:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000355a:	00006597          	auipc	a1,0x6
    8000355e:	3c658593          	addi	a1,a1,966 # 80009920 <userret+0x890>
    80003562:	0001c517          	auipc	a0,0x1c
    80003566:	d5e50513          	addi	a0,a0,-674 # 8001f2c0 <icache>
    8000356a:	ffffd097          	auipc	ra,0xffffd
    8000356e:	472080e7          	jalr	1138(ra) # 800009dc <initlock>
  for(i = 0; i < NINODE; i++) {
    80003572:	0001c497          	auipc	s1,0x1c
    80003576:	d7e48493          	addi	s1,s1,-642 # 8001f2f0 <icache+0x30>
    8000357a:	0001e997          	auipc	s3,0x1e
    8000357e:	99698993          	addi	s3,s3,-1642 # 80020f10 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003582:	00006917          	auipc	s2,0x6
    80003586:	3a690913          	addi	s2,s2,934 # 80009928 <userret+0x898>
    8000358a:	85ca                	mv	a1,s2
    8000358c:	8526                	mv	a0,s1
    8000358e:	00001097          	auipc	ra,0x1
    80003592:	f26080e7          	jalr	-218(ra) # 800044b4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003596:	09048493          	addi	s1,s1,144
    8000359a:	ff3498e3          	bne	s1,s3,8000358a <iinit+0x3e>
}
    8000359e:	70a2                	ld	ra,40(sp)
    800035a0:	7402                	ld	s0,32(sp)
    800035a2:	64e2                	ld	s1,24(sp)
    800035a4:	6942                	ld	s2,16(sp)
    800035a6:	69a2                	ld	s3,8(sp)
    800035a8:	6145                	addi	sp,sp,48
    800035aa:	8082                	ret

00000000800035ac <ialloc>:
{
    800035ac:	715d                	addi	sp,sp,-80
    800035ae:	e486                	sd	ra,72(sp)
    800035b0:	e0a2                	sd	s0,64(sp)
    800035b2:	fc26                	sd	s1,56(sp)
    800035b4:	f84a                	sd	s2,48(sp)
    800035b6:	f44e                	sd	s3,40(sp)
    800035b8:	f052                	sd	s4,32(sp)
    800035ba:	ec56                	sd	s5,24(sp)
    800035bc:	e85a                	sd	s6,16(sp)
    800035be:	e45e                	sd	s7,8(sp)
    800035c0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035c2:	0001c717          	auipc	a4,0x1c
    800035c6:	cea72703          	lw	a4,-790(a4) # 8001f2ac <sb+0xc>
    800035ca:	4785                	li	a5,1
    800035cc:	04e7fa63          	bgeu	a5,a4,80003620 <ialloc+0x74>
    800035d0:	8aaa                	mv	s5,a0
    800035d2:	8bae                	mv	s7,a1
    800035d4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035d6:	0001ca17          	auipc	s4,0x1c
    800035da:	ccaa0a13          	addi	s4,s4,-822 # 8001f2a0 <sb>
    800035de:	00048b1b          	sext.w	s6,s1
    800035e2:	0044d593          	srli	a1,s1,0x4
    800035e6:	018a2783          	lw	a5,24(s4)
    800035ea:	9dbd                	addw	a1,a1,a5
    800035ec:	8556                	mv	a0,s5
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	950080e7          	jalr	-1712(ra) # 80002f3e <bread>
    800035f6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035f8:	06050993          	addi	s3,a0,96
    800035fc:	00f4f793          	andi	a5,s1,15
    80003600:	079a                	slli	a5,a5,0x6
    80003602:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003604:	00099783          	lh	a5,0(s3)
    80003608:	c785                	beqz	a5,80003630 <ialloc+0x84>
    brelse(bp);
    8000360a:	00000097          	auipc	ra,0x0
    8000360e:	a68080e7          	jalr	-1432(ra) # 80003072 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003612:	0485                	addi	s1,s1,1
    80003614:	00ca2703          	lw	a4,12(s4)
    80003618:	0004879b          	sext.w	a5,s1
    8000361c:	fce7e1e3          	bltu	a5,a4,800035de <ialloc+0x32>
  panic("ialloc: no inodes");
    80003620:	00006517          	auipc	a0,0x6
    80003624:	31050513          	addi	a0,a0,784 # 80009930 <userret+0x8a0>
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	f32080e7          	jalr	-206(ra) # 8000055a <panic>
      memset(dip, 0, sizeof(*dip));
    80003630:	04000613          	li	a2,64
    80003634:	4581                	li	a1,0
    80003636:	854e                	mv	a0,s3
    80003638:	ffffd097          	auipc	ra,0xffffd
    8000363c:	746080e7          	jalr	1862(ra) # 80000d7e <memset>
      dip->type = type;
    80003640:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003644:	854a                	mv	a0,s2
    80003646:	00001097          	auipc	ra,0x1
    8000364a:	d2e080e7          	jalr	-722(ra) # 80004374 <log_write>
      brelse(bp);
    8000364e:	854a                	mv	a0,s2
    80003650:	00000097          	auipc	ra,0x0
    80003654:	a22080e7          	jalr	-1502(ra) # 80003072 <brelse>
      return iget(dev, inum);
    80003658:	85da                	mv	a1,s6
    8000365a:	8556                	mv	a0,s5
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	db4080e7          	jalr	-588(ra) # 80003410 <iget>
}
    80003664:	60a6                	ld	ra,72(sp)
    80003666:	6406                	ld	s0,64(sp)
    80003668:	74e2                	ld	s1,56(sp)
    8000366a:	7942                	ld	s2,48(sp)
    8000366c:	79a2                	ld	s3,40(sp)
    8000366e:	7a02                	ld	s4,32(sp)
    80003670:	6ae2                	ld	s5,24(sp)
    80003672:	6b42                	ld	s6,16(sp)
    80003674:	6ba2                	ld	s7,8(sp)
    80003676:	6161                	addi	sp,sp,80
    80003678:	8082                	ret

000000008000367a <iupdate>:
{
    8000367a:	1101                	addi	sp,sp,-32
    8000367c:	ec06                	sd	ra,24(sp)
    8000367e:	e822                	sd	s0,16(sp)
    80003680:	e426                	sd	s1,8(sp)
    80003682:	e04a                	sd	s2,0(sp)
    80003684:	1000                	addi	s0,sp,32
    80003686:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003688:	415c                	lw	a5,4(a0)
    8000368a:	0047d79b          	srliw	a5,a5,0x4
    8000368e:	0001c597          	auipc	a1,0x1c
    80003692:	c2a5a583          	lw	a1,-982(a1) # 8001f2b8 <sb+0x18>
    80003696:	9dbd                	addw	a1,a1,a5
    80003698:	4108                	lw	a0,0(a0)
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	8a4080e7          	jalr	-1884(ra) # 80002f3e <bread>
    800036a2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036a4:	06050793          	addi	a5,a0,96
    800036a8:	40c8                	lw	a0,4(s1)
    800036aa:	893d                	andi	a0,a0,15
    800036ac:	051a                	slli	a0,a0,0x6
    800036ae:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800036b0:	04c49703          	lh	a4,76(s1)
    800036b4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800036b8:	04e49703          	lh	a4,78(s1)
    800036bc:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800036c0:	05049703          	lh	a4,80(s1)
    800036c4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800036c8:	05249703          	lh	a4,82(s1)
    800036cc:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800036d0:	48f8                	lw	a4,84(s1)
    800036d2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036d4:	03400613          	li	a2,52
    800036d8:	05848593          	addi	a1,s1,88
    800036dc:	0531                	addi	a0,a0,12
    800036de:	ffffd097          	auipc	ra,0xffffd
    800036e2:	700080e7          	jalr	1792(ra) # 80000dde <memmove>
  log_write(bp);
    800036e6:	854a                	mv	a0,s2
    800036e8:	00001097          	auipc	ra,0x1
    800036ec:	c8c080e7          	jalr	-884(ra) # 80004374 <log_write>
  brelse(bp);
    800036f0:	854a                	mv	a0,s2
    800036f2:	00000097          	auipc	ra,0x0
    800036f6:	980080e7          	jalr	-1664(ra) # 80003072 <brelse>
}
    800036fa:	60e2                	ld	ra,24(sp)
    800036fc:	6442                	ld	s0,16(sp)
    800036fe:	64a2                	ld	s1,8(sp)
    80003700:	6902                	ld	s2,0(sp)
    80003702:	6105                	addi	sp,sp,32
    80003704:	8082                	ret

0000000080003706 <idup>:
{
    80003706:	1101                	addi	sp,sp,-32
    80003708:	ec06                	sd	ra,24(sp)
    8000370a:	e822                	sd	s0,16(sp)
    8000370c:	e426                	sd	s1,8(sp)
    8000370e:	1000                	addi	s0,sp,32
    80003710:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003712:	0001c517          	auipc	a0,0x1c
    80003716:	bae50513          	addi	a0,a0,-1106 # 8001f2c0 <icache>
    8000371a:	ffffd097          	auipc	ra,0xffffd
    8000371e:	396080e7          	jalr	918(ra) # 80000ab0 <acquire>
  ip->ref++;
    80003722:	449c                	lw	a5,8(s1)
    80003724:	2785                	addiw	a5,a5,1
    80003726:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003728:	0001c517          	auipc	a0,0x1c
    8000372c:	b9850513          	addi	a0,a0,-1128 # 8001f2c0 <icache>
    80003730:	ffffd097          	auipc	ra,0xffffd
    80003734:	450080e7          	jalr	1104(ra) # 80000b80 <release>
}
    80003738:	8526                	mv	a0,s1
    8000373a:	60e2                	ld	ra,24(sp)
    8000373c:	6442                	ld	s0,16(sp)
    8000373e:	64a2                	ld	s1,8(sp)
    80003740:	6105                	addi	sp,sp,32
    80003742:	8082                	ret

0000000080003744 <ilock>:
{
    80003744:	1101                	addi	sp,sp,-32
    80003746:	ec06                	sd	ra,24(sp)
    80003748:	e822                	sd	s0,16(sp)
    8000374a:	e426                	sd	s1,8(sp)
    8000374c:	e04a                	sd	s2,0(sp)
    8000374e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003750:	c115                	beqz	a0,80003774 <ilock+0x30>
    80003752:	84aa                	mv	s1,a0
    80003754:	451c                	lw	a5,8(a0)
    80003756:	00f05f63          	blez	a5,80003774 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000375a:	0541                	addi	a0,a0,16
    8000375c:	00001097          	auipc	ra,0x1
    80003760:	d92080e7          	jalr	-622(ra) # 800044ee <acquiresleep>
  if(ip->valid == 0){
    80003764:	44bc                	lw	a5,72(s1)
    80003766:	cf99                	beqz	a5,80003784 <ilock+0x40>
}
    80003768:	60e2                	ld	ra,24(sp)
    8000376a:	6442                	ld	s0,16(sp)
    8000376c:	64a2                	ld	s1,8(sp)
    8000376e:	6902                	ld	s2,0(sp)
    80003770:	6105                	addi	sp,sp,32
    80003772:	8082                	ret
    panic("ilock");
    80003774:	00006517          	auipc	a0,0x6
    80003778:	1d450513          	addi	a0,a0,468 # 80009948 <userret+0x8b8>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	dde080e7          	jalr	-546(ra) # 8000055a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003784:	40dc                	lw	a5,4(s1)
    80003786:	0047d79b          	srliw	a5,a5,0x4
    8000378a:	0001c597          	auipc	a1,0x1c
    8000378e:	b2e5a583          	lw	a1,-1234(a1) # 8001f2b8 <sb+0x18>
    80003792:	9dbd                	addw	a1,a1,a5
    80003794:	4088                	lw	a0,0(s1)
    80003796:	fffff097          	auipc	ra,0xfffff
    8000379a:	7a8080e7          	jalr	1960(ra) # 80002f3e <bread>
    8000379e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037a0:	06050593          	addi	a1,a0,96
    800037a4:	40dc                	lw	a5,4(s1)
    800037a6:	8bbd                	andi	a5,a5,15
    800037a8:	079a                	slli	a5,a5,0x6
    800037aa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037ac:	00059783          	lh	a5,0(a1)
    800037b0:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    800037b4:	00259783          	lh	a5,2(a1)
    800037b8:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    800037bc:	00459783          	lh	a5,4(a1)
    800037c0:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    800037c4:	00659783          	lh	a5,6(a1)
    800037c8:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    800037cc:	459c                	lw	a5,8(a1)
    800037ce:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037d0:	03400613          	li	a2,52
    800037d4:	05b1                	addi	a1,a1,12
    800037d6:	05848513          	addi	a0,s1,88
    800037da:	ffffd097          	auipc	ra,0xffffd
    800037de:	604080e7          	jalr	1540(ra) # 80000dde <memmove>
    brelse(bp);
    800037e2:	854a                	mv	a0,s2
    800037e4:	00000097          	auipc	ra,0x0
    800037e8:	88e080e7          	jalr	-1906(ra) # 80003072 <brelse>
    ip->valid = 1;
    800037ec:	4785                	li	a5,1
    800037ee:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    800037f0:	04c49783          	lh	a5,76(s1)
    800037f4:	fbb5                	bnez	a5,80003768 <ilock+0x24>
      panic("ilock: no type");
    800037f6:	00006517          	auipc	a0,0x6
    800037fa:	15a50513          	addi	a0,a0,346 # 80009950 <userret+0x8c0>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	d5c080e7          	jalr	-676(ra) # 8000055a <panic>

0000000080003806 <iunlock>:
{
    80003806:	1101                	addi	sp,sp,-32
    80003808:	ec06                	sd	ra,24(sp)
    8000380a:	e822                	sd	s0,16(sp)
    8000380c:	e426                	sd	s1,8(sp)
    8000380e:	e04a                	sd	s2,0(sp)
    80003810:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003812:	c905                	beqz	a0,80003842 <iunlock+0x3c>
    80003814:	84aa                	mv	s1,a0
    80003816:	01050913          	addi	s2,a0,16
    8000381a:	854a                	mv	a0,s2
    8000381c:	00001097          	auipc	ra,0x1
    80003820:	d6c080e7          	jalr	-660(ra) # 80004588 <holdingsleep>
    80003824:	cd19                	beqz	a0,80003842 <iunlock+0x3c>
    80003826:	449c                	lw	a5,8(s1)
    80003828:	00f05d63          	blez	a5,80003842 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000382c:	854a                	mv	a0,s2
    8000382e:	00001097          	auipc	ra,0x1
    80003832:	d16080e7          	jalr	-746(ra) # 80004544 <releasesleep>
}
    80003836:	60e2                	ld	ra,24(sp)
    80003838:	6442                	ld	s0,16(sp)
    8000383a:	64a2                	ld	s1,8(sp)
    8000383c:	6902                	ld	s2,0(sp)
    8000383e:	6105                	addi	sp,sp,32
    80003840:	8082                	ret
    panic("iunlock");
    80003842:	00006517          	auipc	a0,0x6
    80003846:	11e50513          	addi	a0,a0,286 # 80009960 <userret+0x8d0>
    8000384a:	ffffd097          	auipc	ra,0xffffd
    8000384e:	d10080e7          	jalr	-752(ra) # 8000055a <panic>

0000000080003852 <iput>:
{
    80003852:	7139                	addi	sp,sp,-64
    80003854:	fc06                	sd	ra,56(sp)
    80003856:	f822                	sd	s0,48(sp)
    80003858:	f426                	sd	s1,40(sp)
    8000385a:	f04a                	sd	s2,32(sp)
    8000385c:	ec4e                	sd	s3,24(sp)
    8000385e:	e852                	sd	s4,16(sp)
    80003860:	e456                	sd	s5,8(sp)
    80003862:	0080                	addi	s0,sp,64
    80003864:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003866:	0001c517          	auipc	a0,0x1c
    8000386a:	a5a50513          	addi	a0,a0,-1446 # 8001f2c0 <icache>
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	242080e7          	jalr	578(ra) # 80000ab0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003876:	4498                	lw	a4,8(s1)
    80003878:	4785                	li	a5,1
    8000387a:	02f70663          	beq	a4,a5,800038a6 <iput+0x54>
  ip->ref--;
    8000387e:	449c                	lw	a5,8(s1)
    80003880:	37fd                	addiw	a5,a5,-1
    80003882:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003884:	0001c517          	auipc	a0,0x1c
    80003888:	a3c50513          	addi	a0,a0,-1476 # 8001f2c0 <icache>
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	2f4080e7          	jalr	756(ra) # 80000b80 <release>
}
    80003894:	70e2                	ld	ra,56(sp)
    80003896:	7442                	ld	s0,48(sp)
    80003898:	74a2                	ld	s1,40(sp)
    8000389a:	7902                	ld	s2,32(sp)
    8000389c:	69e2                	ld	s3,24(sp)
    8000389e:	6a42                	ld	s4,16(sp)
    800038a0:	6aa2                	ld	s5,8(sp)
    800038a2:	6121                	addi	sp,sp,64
    800038a4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038a6:	44bc                	lw	a5,72(s1)
    800038a8:	dbf9                	beqz	a5,8000387e <iput+0x2c>
    800038aa:	05249783          	lh	a5,82(s1)
    800038ae:	fbe1                	bnez	a5,8000387e <iput+0x2c>
    acquiresleep(&ip->lock);
    800038b0:	01048a13          	addi	s4,s1,16
    800038b4:	8552                	mv	a0,s4
    800038b6:	00001097          	auipc	ra,0x1
    800038ba:	c38080e7          	jalr	-968(ra) # 800044ee <acquiresleep>
    release(&icache.lock);
    800038be:	0001c517          	auipc	a0,0x1c
    800038c2:	a0250513          	addi	a0,a0,-1534 # 8001f2c0 <icache>
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	2ba080e7          	jalr	698(ra) # 80000b80 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038ce:	05848913          	addi	s2,s1,88
    800038d2:	08848993          	addi	s3,s1,136
    800038d6:	a819                	j	800038ec <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    800038d8:	4088                	lw	a0,0(s1)
    800038da:	00000097          	auipc	ra,0x0
    800038de:	8ae080e7          	jalr	-1874(ra) # 80003188 <bfree>
      ip->addrs[i] = 0;
    800038e2:	00092023          	sw	zero,0(s2)
  for(i = 0; i < NDIRECT; i++){
    800038e6:	0911                	addi	s2,s2,4
    800038e8:	01390663          	beq	s2,s3,800038f4 <iput+0xa2>
    if(ip->addrs[i]){
    800038ec:	00092583          	lw	a1,0(s2)
    800038f0:	d9fd                	beqz	a1,800038e6 <iput+0x94>
    800038f2:	b7dd                	j	800038d8 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038f4:	0884a583          	lw	a1,136(s1)
    800038f8:	ed9d                	bnez	a1,80003936 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038fa:	0404aa23          	sw	zero,84(s1)
  iupdate(ip);
    800038fe:	8526                	mv	a0,s1
    80003900:	00000097          	auipc	ra,0x0
    80003904:	d7a080e7          	jalr	-646(ra) # 8000367a <iupdate>
    ip->type = 0;
    80003908:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    8000390c:	8526                	mv	a0,s1
    8000390e:	00000097          	auipc	ra,0x0
    80003912:	d6c080e7          	jalr	-660(ra) # 8000367a <iupdate>
    ip->valid = 0;
    80003916:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    8000391a:	8552                	mv	a0,s4
    8000391c:	00001097          	auipc	ra,0x1
    80003920:	c28080e7          	jalr	-984(ra) # 80004544 <releasesleep>
    acquire(&icache.lock);
    80003924:	0001c517          	auipc	a0,0x1c
    80003928:	99c50513          	addi	a0,a0,-1636 # 8001f2c0 <icache>
    8000392c:	ffffd097          	auipc	ra,0xffffd
    80003930:	184080e7          	jalr	388(ra) # 80000ab0 <acquire>
    80003934:	b7a9                	j	8000387e <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003936:	4088                	lw	a0,0(s1)
    80003938:	fffff097          	auipc	ra,0xfffff
    8000393c:	606080e7          	jalr	1542(ra) # 80002f3e <bread>
    80003940:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003942:	06050913          	addi	s2,a0,96
    80003946:	46050993          	addi	s3,a0,1120
    8000394a:	a809                	j	8000395c <iput+0x10a>
        bfree(ip->dev, a[j]);
    8000394c:	4088                	lw	a0,0(s1)
    8000394e:	00000097          	auipc	ra,0x0
    80003952:	83a080e7          	jalr	-1990(ra) # 80003188 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003956:	0911                	addi	s2,s2,4
    80003958:	01390663          	beq	s2,s3,80003964 <iput+0x112>
      if(a[j])
    8000395c:	00092583          	lw	a1,0(s2)
    80003960:	d9fd                	beqz	a1,80003956 <iput+0x104>
    80003962:	b7ed                	j	8000394c <iput+0xfa>
    brelse(bp);
    80003964:	8556                	mv	a0,s5
    80003966:	fffff097          	auipc	ra,0xfffff
    8000396a:	70c080e7          	jalr	1804(ra) # 80003072 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000396e:	0884a583          	lw	a1,136(s1)
    80003972:	4088                	lw	a0,0(s1)
    80003974:	00000097          	auipc	ra,0x0
    80003978:	814080e7          	jalr	-2028(ra) # 80003188 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000397c:	0804a423          	sw	zero,136(s1)
    80003980:	bfad                	j	800038fa <iput+0xa8>

0000000080003982 <iunlockput>:
{
    80003982:	1101                	addi	sp,sp,-32
    80003984:	ec06                	sd	ra,24(sp)
    80003986:	e822                	sd	s0,16(sp)
    80003988:	e426                	sd	s1,8(sp)
    8000398a:	1000                	addi	s0,sp,32
    8000398c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000398e:	00000097          	auipc	ra,0x0
    80003992:	e78080e7          	jalr	-392(ra) # 80003806 <iunlock>
  iput(ip);
    80003996:	8526                	mv	a0,s1
    80003998:	00000097          	auipc	ra,0x0
    8000399c:	eba080e7          	jalr	-326(ra) # 80003852 <iput>
}
    800039a0:	60e2                	ld	ra,24(sp)
    800039a2:	6442                	ld	s0,16(sp)
    800039a4:	64a2                	ld	s1,8(sp)
    800039a6:	6105                	addi	sp,sp,32
    800039a8:	8082                	ret

00000000800039aa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039aa:	1141                	addi	sp,sp,-16
    800039ac:	e422                	sd	s0,8(sp)
    800039ae:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039b0:	411c                	lw	a5,0(a0)
    800039b2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039b4:	415c                	lw	a5,4(a0)
    800039b6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039b8:	04c51783          	lh	a5,76(a0)
    800039bc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039c0:	05251783          	lh	a5,82(a0)
    800039c4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039c8:	05456783          	lwu	a5,84(a0)
    800039cc:	e99c                	sd	a5,16(a1)
}
    800039ce:	6422                	ld	s0,8(sp)
    800039d0:	0141                	addi	sp,sp,16
    800039d2:	8082                	ret

00000000800039d4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039d4:	497c                	lw	a5,84(a0)
    800039d6:	0ed7e563          	bltu	a5,a3,80003ac0 <readi+0xec>
{
    800039da:	7159                	addi	sp,sp,-112
    800039dc:	f486                	sd	ra,104(sp)
    800039de:	f0a2                	sd	s0,96(sp)
    800039e0:	eca6                	sd	s1,88(sp)
    800039e2:	e8ca                	sd	s2,80(sp)
    800039e4:	e4ce                	sd	s3,72(sp)
    800039e6:	e0d2                	sd	s4,64(sp)
    800039e8:	fc56                	sd	s5,56(sp)
    800039ea:	f85a                	sd	s6,48(sp)
    800039ec:	f45e                	sd	s7,40(sp)
    800039ee:	f062                	sd	s8,32(sp)
    800039f0:	ec66                	sd	s9,24(sp)
    800039f2:	e86a                	sd	s10,16(sp)
    800039f4:	e46e                	sd	s11,8(sp)
    800039f6:	1880                	addi	s0,sp,112
    800039f8:	8baa                	mv	s7,a0
    800039fa:	8c2e                	mv	s8,a1
    800039fc:	8ab2                	mv	s5,a2
    800039fe:	8936                	mv	s2,a3
    80003a00:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a02:	9f35                	addw	a4,a4,a3
    80003a04:	0cd76063          	bltu	a4,a3,80003ac4 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80003a08:	00e7f463          	bgeu	a5,a4,80003a10 <readi+0x3c>
    n = ip->size - off;
    80003a0c:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a10:	080b0763          	beqz	s6,80003a9e <readi+0xca>
    80003a14:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a16:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a1a:	5cfd                	li	s9,-1
    80003a1c:	a82d                	j	80003a56 <readi+0x82>
    80003a1e:	02099d93          	slli	s11,s3,0x20
    80003a22:	020ddd93          	srli	s11,s11,0x20
    80003a26:	06048613          	addi	a2,s1,96
    80003a2a:	86ee                	mv	a3,s11
    80003a2c:	963a                	add	a2,a2,a4
    80003a2e:	85d6                	mv	a1,s5
    80003a30:	8562                	mv	a0,s8
    80003a32:	fffff097          	auipc	ra,0xfffff
    80003a36:	a90080e7          	jalr	-1392(ra) # 800024c2 <either_copyout>
    80003a3a:	05950d63          	beq	a0,s9,80003a94 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003a3e:	8526                	mv	a0,s1
    80003a40:	fffff097          	auipc	ra,0xfffff
    80003a44:	632080e7          	jalr	1586(ra) # 80003072 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a48:	01498a3b          	addw	s4,s3,s4
    80003a4c:	0129893b          	addw	s2,s3,s2
    80003a50:	9aee                	add	s5,s5,s11
    80003a52:	056a7663          	bgeu	s4,s6,80003a9e <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a56:	000ba483          	lw	s1,0(s7)
    80003a5a:	00a9559b          	srliw	a1,s2,0xa
    80003a5e:	855e                	mv	a0,s7
    80003a60:	00000097          	auipc	ra,0x0
    80003a64:	8d6080e7          	jalr	-1834(ra) # 80003336 <bmap>
    80003a68:	0005059b          	sext.w	a1,a0
    80003a6c:	8526                	mv	a0,s1
    80003a6e:	fffff097          	auipc	ra,0xfffff
    80003a72:	4d0080e7          	jalr	1232(ra) # 80002f3e <bread>
    80003a76:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a78:	3ff97713          	andi	a4,s2,1023
    80003a7c:	40ed07bb          	subw	a5,s10,a4
    80003a80:	414b06bb          	subw	a3,s6,s4
    80003a84:	89be                	mv	s3,a5
    80003a86:	2781                	sext.w	a5,a5
    80003a88:	0006861b          	sext.w	a2,a3
    80003a8c:	f8f679e3          	bgeu	a2,a5,80003a1e <readi+0x4a>
    80003a90:	89b6                	mv	s3,a3
    80003a92:	b771                	j	80003a1e <readi+0x4a>
      brelse(bp);
    80003a94:	8526                	mv	a0,s1
    80003a96:	fffff097          	auipc	ra,0xfffff
    80003a9a:	5dc080e7          	jalr	1500(ra) # 80003072 <brelse>
  }
  return n;
    80003a9e:	000b051b          	sext.w	a0,s6
}
    80003aa2:	70a6                	ld	ra,104(sp)
    80003aa4:	7406                	ld	s0,96(sp)
    80003aa6:	64e6                	ld	s1,88(sp)
    80003aa8:	6946                	ld	s2,80(sp)
    80003aaa:	69a6                	ld	s3,72(sp)
    80003aac:	6a06                	ld	s4,64(sp)
    80003aae:	7ae2                	ld	s5,56(sp)
    80003ab0:	7b42                	ld	s6,48(sp)
    80003ab2:	7ba2                	ld	s7,40(sp)
    80003ab4:	7c02                	ld	s8,32(sp)
    80003ab6:	6ce2                	ld	s9,24(sp)
    80003ab8:	6d42                	ld	s10,16(sp)
    80003aba:	6da2                	ld	s11,8(sp)
    80003abc:	6165                	addi	sp,sp,112
    80003abe:	8082                	ret
    return -1;
    80003ac0:	557d                	li	a0,-1
}
    80003ac2:	8082                	ret
    return -1;
    80003ac4:	557d                	li	a0,-1
    80003ac6:	bff1                	j	80003aa2 <readi+0xce>

0000000080003ac8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ac8:	497c                	lw	a5,84(a0)
    80003aca:	10d7e663          	bltu	a5,a3,80003bd6 <writei+0x10e>
{
    80003ace:	7159                	addi	sp,sp,-112
    80003ad0:	f486                	sd	ra,104(sp)
    80003ad2:	f0a2                	sd	s0,96(sp)
    80003ad4:	eca6                	sd	s1,88(sp)
    80003ad6:	e8ca                	sd	s2,80(sp)
    80003ad8:	e4ce                	sd	s3,72(sp)
    80003ada:	e0d2                	sd	s4,64(sp)
    80003adc:	fc56                	sd	s5,56(sp)
    80003ade:	f85a                	sd	s6,48(sp)
    80003ae0:	f45e                	sd	s7,40(sp)
    80003ae2:	f062                	sd	s8,32(sp)
    80003ae4:	ec66                	sd	s9,24(sp)
    80003ae6:	e86a                	sd	s10,16(sp)
    80003ae8:	e46e                	sd	s11,8(sp)
    80003aea:	1880                	addi	s0,sp,112
    80003aec:	8baa                	mv	s7,a0
    80003aee:	8c2e                	mv	s8,a1
    80003af0:	8ab2                	mv	s5,a2
    80003af2:	8936                	mv	s2,a3
    80003af4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003af6:	00e687bb          	addw	a5,a3,a4
    80003afa:	0ed7e063          	bltu	a5,a3,80003bda <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003afe:	00043737          	lui	a4,0x43
    80003b02:	0cf76e63          	bltu	a4,a5,80003bde <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b06:	0a0b0763          	beqz	s6,80003bb4 <writei+0xec>
    80003b0a:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b0c:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b10:	5cfd                	li	s9,-1
    80003b12:	a091                	j	80003b56 <writei+0x8e>
    80003b14:	02099d93          	slli	s11,s3,0x20
    80003b18:	020ddd93          	srli	s11,s11,0x20
    80003b1c:	06048513          	addi	a0,s1,96
    80003b20:	86ee                	mv	a3,s11
    80003b22:	8656                	mv	a2,s5
    80003b24:	85e2                	mv	a1,s8
    80003b26:	953a                	add	a0,a0,a4
    80003b28:	fffff097          	auipc	ra,0xfffff
    80003b2c:	9f0080e7          	jalr	-1552(ra) # 80002518 <either_copyin>
    80003b30:	07950263          	beq	a0,s9,80003b94 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b34:	8526                	mv	a0,s1
    80003b36:	00001097          	auipc	ra,0x1
    80003b3a:	83e080e7          	jalr	-1986(ra) # 80004374 <log_write>
    brelse(bp);
    80003b3e:	8526                	mv	a0,s1
    80003b40:	fffff097          	auipc	ra,0xfffff
    80003b44:	532080e7          	jalr	1330(ra) # 80003072 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b48:	01498a3b          	addw	s4,s3,s4
    80003b4c:	0129893b          	addw	s2,s3,s2
    80003b50:	9aee                	add	s5,s5,s11
    80003b52:	056a7663          	bgeu	s4,s6,80003b9e <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b56:	000ba483          	lw	s1,0(s7)
    80003b5a:	00a9559b          	srliw	a1,s2,0xa
    80003b5e:	855e                	mv	a0,s7
    80003b60:	fffff097          	auipc	ra,0xfffff
    80003b64:	7d6080e7          	jalr	2006(ra) # 80003336 <bmap>
    80003b68:	0005059b          	sext.w	a1,a0
    80003b6c:	8526                	mv	a0,s1
    80003b6e:	fffff097          	auipc	ra,0xfffff
    80003b72:	3d0080e7          	jalr	976(ra) # 80002f3e <bread>
    80003b76:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b78:	3ff97713          	andi	a4,s2,1023
    80003b7c:	40ed07bb          	subw	a5,s10,a4
    80003b80:	414b06bb          	subw	a3,s6,s4
    80003b84:	89be                	mv	s3,a5
    80003b86:	2781                	sext.w	a5,a5
    80003b88:	0006861b          	sext.w	a2,a3
    80003b8c:	f8f674e3          	bgeu	a2,a5,80003b14 <writei+0x4c>
    80003b90:	89b6                	mv	s3,a3
    80003b92:	b749                	j	80003b14 <writei+0x4c>
      brelse(bp);
    80003b94:	8526                	mv	a0,s1
    80003b96:	fffff097          	auipc	ra,0xfffff
    80003b9a:	4dc080e7          	jalr	1244(ra) # 80003072 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003b9e:	054ba783          	lw	a5,84(s7)
    80003ba2:	0127f463          	bgeu	a5,s2,80003baa <writei+0xe2>
      ip->size = off;
    80003ba6:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003baa:	855e                	mv	a0,s7
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	ace080e7          	jalr	-1330(ra) # 8000367a <iupdate>
  }

  return n;
    80003bb4:	000b051b          	sext.w	a0,s6
}
    80003bb8:	70a6                	ld	ra,104(sp)
    80003bba:	7406                	ld	s0,96(sp)
    80003bbc:	64e6                	ld	s1,88(sp)
    80003bbe:	6946                	ld	s2,80(sp)
    80003bc0:	69a6                	ld	s3,72(sp)
    80003bc2:	6a06                	ld	s4,64(sp)
    80003bc4:	7ae2                	ld	s5,56(sp)
    80003bc6:	7b42                	ld	s6,48(sp)
    80003bc8:	7ba2                	ld	s7,40(sp)
    80003bca:	7c02                	ld	s8,32(sp)
    80003bcc:	6ce2                	ld	s9,24(sp)
    80003bce:	6d42                	ld	s10,16(sp)
    80003bd0:	6da2                	ld	s11,8(sp)
    80003bd2:	6165                	addi	sp,sp,112
    80003bd4:	8082                	ret
    return -1;
    80003bd6:	557d                	li	a0,-1
}
    80003bd8:	8082                	ret
    return -1;
    80003bda:	557d                	li	a0,-1
    80003bdc:	bff1                	j	80003bb8 <writei+0xf0>
    return -1;
    80003bde:	557d                	li	a0,-1
    80003be0:	bfe1                	j	80003bb8 <writei+0xf0>

0000000080003be2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003be2:	1141                	addi	sp,sp,-16
    80003be4:	e406                	sd	ra,8(sp)
    80003be6:	e022                	sd	s0,0(sp)
    80003be8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bea:	4639                	li	a2,14
    80003bec:	ffffd097          	auipc	ra,0xffffd
    80003bf0:	26e080e7          	jalr	622(ra) # 80000e5a <strncmp>
}
    80003bf4:	60a2                	ld	ra,8(sp)
    80003bf6:	6402                	ld	s0,0(sp)
    80003bf8:	0141                	addi	sp,sp,16
    80003bfa:	8082                	ret

0000000080003bfc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bfc:	7139                	addi	sp,sp,-64
    80003bfe:	fc06                	sd	ra,56(sp)
    80003c00:	f822                	sd	s0,48(sp)
    80003c02:	f426                	sd	s1,40(sp)
    80003c04:	f04a                	sd	s2,32(sp)
    80003c06:	ec4e                	sd	s3,24(sp)
    80003c08:	e852                	sd	s4,16(sp)
    80003c0a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c0c:	04c51703          	lh	a4,76(a0)
    80003c10:	4785                	li	a5,1
    80003c12:	00f71a63          	bne	a4,a5,80003c26 <dirlookup+0x2a>
    80003c16:	892a                	mv	s2,a0
    80003c18:	89ae                	mv	s3,a1
    80003c1a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c1c:	497c                	lw	a5,84(a0)
    80003c1e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c20:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c22:	e79d                	bnez	a5,80003c50 <dirlookup+0x54>
    80003c24:	a8a5                	j	80003c9c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c26:	00006517          	auipc	a0,0x6
    80003c2a:	d4250513          	addi	a0,a0,-702 # 80009968 <userret+0x8d8>
    80003c2e:	ffffd097          	auipc	ra,0xffffd
    80003c32:	92c080e7          	jalr	-1748(ra) # 8000055a <panic>
      panic("dirlookup read");
    80003c36:	00006517          	auipc	a0,0x6
    80003c3a:	d4a50513          	addi	a0,a0,-694 # 80009980 <userret+0x8f0>
    80003c3e:	ffffd097          	auipc	ra,0xffffd
    80003c42:	91c080e7          	jalr	-1764(ra) # 8000055a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c46:	24c1                	addiw	s1,s1,16
    80003c48:	05492783          	lw	a5,84(s2)
    80003c4c:	04f4f763          	bgeu	s1,a5,80003c9a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c50:	4741                	li	a4,16
    80003c52:	86a6                	mv	a3,s1
    80003c54:	fc040613          	addi	a2,s0,-64
    80003c58:	4581                	li	a1,0
    80003c5a:	854a                	mv	a0,s2
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	d78080e7          	jalr	-648(ra) # 800039d4 <readi>
    80003c64:	47c1                	li	a5,16
    80003c66:	fcf518e3          	bne	a0,a5,80003c36 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c6a:	fc045783          	lhu	a5,-64(s0)
    80003c6e:	dfe1                	beqz	a5,80003c46 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c70:	fc240593          	addi	a1,s0,-62
    80003c74:	854e                	mv	a0,s3
    80003c76:	00000097          	auipc	ra,0x0
    80003c7a:	f6c080e7          	jalr	-148(ra) # 80003be2 <namecmp>
    80003c7e:	f561                	bnez	a0,80003c46 <dirlookup+0x4a>
      if(poff)
    80003c80:	000a0463          	beqz	s4,80003c88 <dirlookup+0x8c>
        *poff = off;
    80003c84:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c88:	fc045583          	lhu	a1,-64(s0)
    80003c8c:	00092503          	lw	a0,0(s2)
    80003c90:	fffff097          	auipc	ra,0xfffff
    80003c94:	780080e7          	jalr	1920(ra) # 80003410 <iget>
    80003c98:	a011                	j	80003c9c <dirlookup+0xa0>
  return 0;
    80003c9a:	4501                	li	a0,0
}
    80003c9c:	70e2                	ld	ra,56(sp)
    80003c9e:	7442                	ld	s0,48(sp)
    80003ca0:	74a2                	ld	s1,40(sp)
    80003ca2:	7902                	ld	s2,32(sp)
    80003ca4:	69e2                	ld	s3,24(sp)
    80003ca6:	6a42                	ld	s4,16(sp)
    80003ca8:	6121                	addi	sp,sp,64
    80003caa:	8082                	ret

0000000080003cac <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cac:	711d                	addi	sp,sp,-96
    80003cae:	ec86                	sd	ra,88(sp)
    80003cb0:	e8a2                	sd	s0,80(sp)
    80003cb2:	e4a6                	sd	s1,72(sp)
    80003cb4:	e0ca                	sd	s2,64(sp)
    80003cb6:	fc4e                	sd	s3,56(sp)
    80003cb8:	f852                	sd	s4,48(sp)
    80003cba:	f456                	sd	s5,40(sp)
    80003cbc:	f05a                	sd	s6,32(sp)
    80003cbe:	ec5e                	sd	s7,24(sp)
    80003cc0:	e862                	sd	s8,16(sp)
    80003cc2:	e466                	sd	s9,8(sp)
    80003cc4:	1080                	addi	s0,sp,96
    80003cc6:	84aa                	mv	s1,a0
    80003cc8:	8b2e                	mv	s6,a1
    80003cca:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ccc:	00054703          	lbu	a4,0(a0)
    80003cd0:	02f00793          	li	a5,47
    80003cd4:	02f70363          	beq	a4,a5,80003cfa <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cd8:	ffffe097          	auipc	ra,0xffffe
    80003cdc:	dce080e7          	jalr	-562(ra) # 80001aa6 <myproc>
    80003ce0:	15853503          	ld	a0,344(a0)
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	a22080e7          	jalr	-1502(ra) # 80003706 <idup>
    80003cec:	89aa                	mv	s3,a0
  while(*path == '/')
    80003cee:	02f00913          	li	s2,47
  len = path - s;
    80003cf2:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003cf4:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cf6:	4c05                	li	s8,1
    80003cf8:	a865                	j	80003db0 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003cfa:	4585                	li	a1,1
    80003cfc:	4501                	li	a0,0
    80003cfe:	fffff097          	auipc	ra,0xfffff
    80003d02:	712080e7          	jalr	1810(ra) # 80003410 <iget>
    80003d06:	89aa                	mv	s3,a0
    80003d08:	b7dd                	j	80003cee <namex+0x42>
      iunlockput(ip);
    80003d0a:	854e                	mv	a0,s3
    80003d0c:	00000097          	auipc	ra,0x0
    80003d10:	c76080e7          	jalr	-906(ra) # 80003982 <iunlockput>
      return 0;
    80003d14:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d16:	854e                	mv	a0,s3
    80003d18:	60e6                	ld	ra,88(sp)
    80003d1a:	6446                	ld	s0,80(sp)
    80003d1c:	64a6                	ld	s1,72(sp)
    80003d1e:	6906                	ld	s2,64(sp)
    80003d20:	79e2                	ld	s3,56(sp)
    80003d22:	7a42                	ld	s4,48(sp)
    80003d24:	7aa2                	ld	s5,40(sp)
    80003d26:	7b02                	ld	s6,32(sp)
    80003d28:	6be2                	ld	s7,24(sp)
    80003d2a:	6c42                	ld	s8,16(sp)
    80003d2c:	6ca2                	ld	s9,8(sp)
    80003d2e:	6125                	addi	sp,sp,96
    80003d30:	8082                	ret
      iunlock(ip);
    80003d32:	854e                	mv	a0,s3
    80003d34:	00000097          	auipc	ra,0x0
    80003d38:	ad2080e7          	jalr	-1326(ra) # 80003806 <iunlock>
      return ip;
    80003d3c:	bfe9                	j	80003d16 <namex+0x6a>
      iunlockput(ip);
    80003d3e:	854e                	mv	a0,s3
    80003d40:	00000097          	auipc	ra,0x0
    80003d44:	c42080e7          	jalr	-958(ra) # 80003982 <iunlockput>
      return 0;
    80003d48:	89d2                	mv	s3,s4
    80003d4a:	b7f1                	j	80003d16 <namex+0x6a>
  len = path - s;
    80003d4c:	40b48633          	sub	a2,s1,a1
    80003d50:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003d54:	094cd463          	bge	s9,s4,80003ddc <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d58:	4639                	li	a2,14
    80003d5a:	8556                	mv	a0,s5
    80003d5c:	ffffd097          	auipc	ra,0xffffd
    80003d60:	082080e7          	jalr	130(ra) # 80000dde <memmove>
  while(*path == '/')
    80003d64:	0004c783          	lbu	a5,0(s1)
    80003d68:	01279763          	bne	a5,s2,80003d76 <namex+0xca>
    path++;
    80003d6c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d6e:	0004c783          	lbu	a5,0(s1)
    80003d72:	ff278de3          	beq	a5,s2,80003d6c <namex+0xc0>
    ilock(ip);
    80003d76:	854e                	mv	a0,s3
    80003d78:	00000097          	auipc	ra,0x0
    80003d7c:	9cc080e7          	jalr	-1588(ra) # 80003744 <ilock>
    if(ip->type != T_DIR){
    80003d80:	04c99783          	lh	a5,76(s3)
    80003d84:	f98793e3          	bne	a5,s8,80003d0a <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d88:	000b0563          	beqz	s6,80003d92 <namex+0xe6>
    80003d8c:	0004c783          	lbu	a5,0(s1)
    80003d90:	d3cd                	beqz	a5,80003d32 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d92:	865e                	mv	a2,s7
    80003d94:	85d6                	mv	a1,s5
    80003d96:	854e                	mv	a0,s3
    80003d98:	00000097          	auipc	ra,0x0
    80003d9c:	e64080e7          	jalr	-412(ra) # 80003bfc <dirlookup>
    80003da0:	8a2a                	mv	s4,a0
    80003da2:	dd51                	beqz	a0,80003d3e <namex+0x92>
    iunlockput(ip);
    80003da4:	854e                	mv	a0,s3
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	bdc080e7          	jalr	-1060(ra) # 80003982 <iunlockput>
    ip = next;
    80003dae:	89d2                	mv	s3,s4
  while(*path == '/')
    80003db0:	0004c783          	lbu	a5,0(s1)
    80003db4:	05279763          	bne	a5,s2,80003e02 <namex+0x156>
    path++;
    80003db8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dba:	0004c783          	lbu	a5,0(s1)
    80003dbe:	ff278de3          	beq	a5,s2,80003db8 <namex+0x10c>
  if(*path == 0)
    80003dc2:	c79d                	beqz	a5,80003df0 <namex+0x144>
    path++;
    80003dc4:	85a6                	mv	a1,s1
  len = path - s;
    80003dc6:	8a5e                	mv	s4,s7
    80003dc8:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003dca:	01278963          	beq	a5,s2,80003ddc <namex+0x130>
    80003dce:	dfbd                	beqz	a5,80003d4c <namex+0xa0>
    path++;
    80003dd0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003dd2:	0004c783          	lbu	a5,0(s1)
    80003dd6:	ff279ce3          	bne	a5,s2,80003dce <namex+0x122>
    80003dda:	bf8d                	j	80003d4c <namex+0xa0>
    memmove(name, s, len);
    80003ddc:	2601                	sext.w	a2,a2
    80003dde:	8556                	mv	a0,s5
    80003de0:	ffffd097          	auipc	ra,0xffffd
    80003de4:	ffe080e7          	jalr	-2(ra) # 80000dde <memmove>
    name[len] = 0;
    80003de8:	9a56                	add	s4,s4,s5
    80003dea:	000a0023          	sb	zero,0(s4)
    80003dee:	bf9d                	j	80003d64 <namex+0xb8>
  if(nameiparent){
    80003df0:	f20b03e3          	beqz	s6,80003d16 <namex+0x6a>
    iput(ip);
    80003df4:	854e                	mv	a0,s3
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	a5c080e7          	jalr	-1444(ra) # 80003852 <iput>
    return 0;
    80003dfe:	4981                	li	s3,0
    80003e00:	bf19                	j	80003d16 <namex+0x6a>
  if(*path == 0)
    80003e02:	d7fd                	beqz	a5,80003df0 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e04:	0004c783          	lbu	a5,0(s1)
    80003e08:	85a6                	mv	a1,s1
    80003e0a:	b7d1                	j	80003dce <namex+0x122>

0000000080003e0c <dirlink>:
{
    80003e0c:	7139                	addi	sp,sp,-64
    80003e0e:	fc06                	sd	ra,56(sp)
    80003e10:	f822                	sd	s0,48(sp)
    80003e12:	f426                	sd	s1,40(sp)
    80003e14:	f04a                	sd	s2,32(sp)
    80003e16:	ec4e                	sd	s3,24(sp)
    80003e18:	e852                	sd	s4,16(sp)
    80003e1a:	0080                	addi	s0,sp,64
    80003e1c:	892a                	mv	s2,a0
    80003e1e:	8a2e                	mv	s4,a1
    80003e20:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e22:	4601                	li	a2,0
    80003e24:	00000097          	auipc	ra,0x0
    80003e28:	dd8080e7          	jalr	-552(ra) # 80003bfc <dirlookup>
    80003e2c:	e93d                	bnez	a0,80003ea2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e2e:	05492483          	lw	s1,84(s2)
    80003e32:	c49d                	beqz	s1,80003e60 <dirlink+0x54>
    80003e34:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e36:	4741                	li	a4,16
    80003e38:	86a6                	mv	a3,s1
    80003e3a:	fc040613          	addi	a2,s0,-64
    80003e3e:	4581                	li	a1,0
    80003e40:	854a                	mv	a0,s2
    80003e42:	00000097          	auipc	ra,0x0
    80003e46:	b92080e7          	jalr	-1134(ra) # 800039d4 <readi>
    80003e4a:	47c1                	li	a5,16
    80003e4c:	06f51163          	bne	a0,a5,80003eae <dirlink+0xa2>
    if(de.inum == 0)
    80003e50:	fc045783          	lhu	a5,-64(s0)
    80003e54:	c791                	beqz	a5,80003e60 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e56:	24c1                	addiw	s1,s1,16
    80003e58:	05492783          	lw	a5,84(s2)
    80003e5c:	fcf4ede3          	bltu	s1,a5,80003e36 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e60:	4639                	li	a2,14
    80003e62:	85d2                	mv	a1,s4
    80003e64:	fc240513          	addi	a0,s0,-62
    80003e68:	ffffd097          	auipc	ra,0xffffd
    80003e6c:	02e080e7          	jalr	46(ra) # 80000e96 <strncpy>
  de.inum = inum;
    80003e70:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e74:	4741                	li	a4,16
    80003e76:	86a6                	mv	a3,s1
    80003e78:	fc040613          	addi	a2,s0,-64
    80003e7c:	4581                	li	a1,0
    80003e7e:	854a                	mv	a0,s2
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	c48080e7          	jalr	-952(ra) # 80003ac8 <writei>
    80003e88:	872a                	mv	a4,a0
    80003e8a:	47c1                	li	a5,16
  return 0;
    80003e8c:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e8e:	02f71863          	bne	a4,a5,80003ebe <dirlink+0xb2>
}
    80003e92:	70e2                	ld	ra,56(sp)
    80003e94:	7442                	ld	s0,48(sp)
    80003e96:	74a2                	ld	s1,40(sp)
    80003e98:	7902                	ld	s2,32(sp)
    80003e9a:	69e2                	ld	s3,24(sp)
    80003e9c:	6a42                	ld	s4,16(sp)
    80003e9e:	6121                	addi	sp,sp,64
    80003ea0:	8082                	ret
    iput(ip);
    80003ea2:	00000097          	auipc	ra,0x0
    80003ea6:	9b0080e7          	jalr	-1616(ra) # 80003852 <iput>
    return -1;
    80003eaa:	557d                	li	a0,-1
    80003eac:	b7dd                	j	80003e92 <dirlink+0x86>
      panic("dirlink read");
    80003eae:	00006517          	auipc	a0,0x6
    80003eb2:	ae250513          	addi	a0,a0,-1310 # 80009990 <userret+0x900>
    80003eb6:	ffffc097          	auipc	ra,0xffffc
    80003eba:	6a4080e7          	jalr	1700(ra) # 8000055a <panic>
    panic("dirlink");
    80003ebe:	00006517          	auipc	a0,0x6
    80003ec2:	bf250513          	addi	a0,a0,-1038 # 80009ab0 <userret+0xa20>
    80003ec6:	ffffc097          	auipc	ra,0xffffc
    80003eca:	694080e7          	jalr	1684(ra) # 8000055a <panic>

0000000080003ece <namei>:

struct inode*
namei(char *path)
{
    80003ece:	1101                	addi	sp,sp,-32
    80003ed0:	ec06                	sd	ra,24(sp)
    80003ed2:	e822                	sd	s0,16(sp)
    80003ed4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ed6:	fe040613          	addi	a2,s0,-32
    80003eda:	4581                	li	a1,0
    80003edc:	00000097          	auipc	ra,0x0
    80003ee0:	dd0080e7          	jalr	-560(ra) # 80003cac <namex>
}
    80003ee4:	60e2                	ld	ra,24(sp)
    80003ee6:	6442                	ld	s0,16(sp)
    80003ee8:	6105                	addi	sp,sp,32
    80003eea:	8082                	ret

0000000080003eec <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003eec:	1141                	addi	sp,sp,-16
    80003eee:	e406                	sd	ra,8(sp)
    80003ef0:	e022                	sd	s0,0(sp)
    80003ef2:	0800                	addi	s0,sp,16
    80003ef4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ef6:	4585                	li	a1,1
    80003ef8:	00000097          	auipc	ra,0x0
    80003efc:	db4080e7          	jalr	-588(ra) # 80003cac <namex>
}
    80003f00:	60a2                	ld	ra,8(sp)
    80003f02:	6402                	ld	s0,0(sp)
    80003f04:	0141                	addi	sp,sp,16
    80003f06:	8082                	ret

0000000080003f08 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003f08:	7179                	addi	sp,sp,-48
    80003f0a:	f406                	sd	ra,40(sp)
    80003f0c:	f022                	sd	s0,32(sp)
    80003f0e:	ec26                	sd	s1,24(sp)
    80003f10:	e84a                	sd	s2,16(sp)
    80003f12:	e44e                	sd	s3,8(sp)
    80003f14:	1800                	addi	s0,sp,48
    80003f16:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003f18:	0b000993          	li	s3,176
    80003f1c:	033507b3          	mul	a5,a0,s3
    80003f20:	0001d997          	auipc	s3,0x1d
    80003f24:	fe098993          	addi	s3,s3,-32 # 80020f00 <log>
    80003f28:	99be                	add	s3,s3,a5
    80003f2a:	0209a583          	lw	a1,32(s3)
    80003f2e:	fffff097          	auipc	ra,0xfffff
    80003f32:	010080e7          	jalr	16(ra) # 80002f3e <bread>
    80003f36:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003f38:	0349a783          	lw	a5,52(s3)
    80003f3c:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003f3e:	0349a783          	lw	a5,52(s3)
    80003f42:	02f05763          	blez	a5,80003f70 <write_head+0x68>
    80003f46:	0b000793          	li	a5,176
    80003f4a:	02f487b3          	mul	a5,s1,a5
    80003f4e:	0001d717          	auipc	a4,0x1d
    80003f52:	fea70713          	addi	a4,a4,-22 # 80020f38 <log+0x38>
    80003f56:	97ba                	add	a5,a5,a4
    80003f58:	06450693          	addi	a3,a0,100
    80003f5c:	4701                	li	a4,0
    80003f5e:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003f60:	4390                	lw	a2,0(a5)
    80003f62:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003f64:	2705                	addiw	a4,a4,1
    80003f66:	0791                	addi	a5,a5,4
    80003f68:	0691                	addi	a3,a3,4
    80003f6a:	59d0                	lw	a2,52(a1)
    80003f6c:	fec74ae3          	blt	a4,a2,80003f60 <write_head+0x58>
  }
  bwrite(buf);
    80003f70:	854a                	mv	a0,s2
    80003f72:	fffff097          	auipc	ra,0xfffff
    80003f76:	0c0080e7          	jalr	192(ra) # 80003032 <bwrite>
  brelse(buf);
    80003f7a:	854a                	mv	a0,s2
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	0f6080e7          	jalr	246(ra) # 80003072 <brelse>
}
    80003f84:	70a2                	ld	ra,40(sp)
    80003f86:	7402                	ld	s0,32(sp)
    80003f88:	64e2                	ld	s1,24(sp)
    80003f8a:	6942                	ld	s2,16(sp)
    80003f8c:	69a2                	ld	s3,8(sp)
    80003f8e:	6145                	addi	sp,sp,48
    80003f90:	8082                	ret

0000000080003f92 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f92:	0b000793          	li	a5,176
    80003f96:	02f50733          	mul	a4,a0,a5
    80003f9a:	0001d797          	auipc	a5,0x1d
    80003f9e:	f6678793          	addi	a5,a5,-154 # 80020f00 <log>
    80003fa2:	97ba                	add	a5,a5,a4
    80003fa4:	5bdc                	lw	a5,52(a5)
    80003fa6:	0af05b63          	blez	a5,8000405c <install_trans+0xca>
{
    80003faa:	7139                	addi	sp,sp,-64
    80003fac:	fc06                	sd	ra,56(sp)
    80003fae:	f822                	sd	s0,48(sp)
    80003fb0:	f426                	sd	s1,40(sp)
    80003fb2:	f04a                	sd	s2,32(sp)
    80003fb4:	ec4e                	sd	s3,24(sp)
    80003fb6:	e852                	sd	s4,16(sp)
    80003fb8:	e456                	sd	s5,8(sp)
    80003fba:	e05a                	sd	s6,0(sp)
    80003fbc:	0080                	addi	s0,sp,64
    80003fbe:	0001d797          	auipc	a5,0x1d
    80003fc2:	f7a78793          	addi	a5,a5,-134 # 80020f38 <log+0x38>
    80003fc6:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003fca:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003fcc:	00050b1b          	sext.w	s6,a0
    80003fd0:	0001da97          	auipc	s5,0x1d
    80003fd4:	f30a8a93          	addi	s5,s5,-208 # 80020f00 <log>
    80003fd8:	9aba                	add	s5,s5,a4
    80003fda:	020aa583          	lw	a1,32(s5)
    80003fde:	013585bb          	addw	a1,a1,s3
    80003fe2:	2585                	addiw	a1,a1,1
    80003fe4:	855a                	mv	a0,s6
    80003fe6:	fffff097          	auipc	ra,0xfffff
    80003fea:	f58080e7          	jalr	-168(ra) # 80002f3e <bread>
    80003fee:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80003ff0:	000a2583          	lw	a1,0(s4)
    80003ff4:	855a                	mv	a0,s6
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	f48080e7          	jalr	-184(ra) # 80002f3e <bread>
    80003ffe:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004000:	40000613          	li	a2,1024
    80004004:	06090593          	addi	a1,s2,96
    80004008:	06050513          	addi	a0,a0,96
    8000400c:	ffffd097          	auipc	ra,0xffffd
    80004010:	dd2080e7          	jalr	-558(ra) # 80000dde <memmove>
    bwrite(dbuf);  // write dst to disk
    80004014:	8526                	mv	a0,s1
    80004016:	fffff097          	auipc	ra,0xfffff
    8000401a:	01c080e7          	jalr	28(ra) # 80003032 <bwrite>
    bunpin(dbuf);
    8000401e:	8526                	mv	a0,s1
    80004020:	fffff097          	auipc	ra,0xfffff
    80004024:	12c080e7          	jalr	300(ra) # 8000314c <bunpin>
    brelse(lbuf);
    80004028:	854a                	mv	a0,s2
    8000402a:	fffff097          	auipc	ra,0xfffff
    8000402e:	048080e7          	jalr	72(ra) # 80003072 <brelse>
    brelse(dbuf);
    80004032:	8526                	mv	a0,s1
    80004034:	fffff097          	auipc	ra,0xfffff
    80004038:	03e080e7          	jalr	62(ra) # 80003072 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000403c:	2985                	addiw	s3,s3,1
    8000403e:	0a11                	addi	s4,s4,4
    80004040:	034aa783          	lw	a5,52(s5)
    80004044:	f8f9cbe3          	blt	s3,a5,80003fda <install_trans+0x48>
}
    80004048:	70e2                	ld	ra,56(sp)
    8000404a:	7442                	ld	s0,48(sp)
    8000404c:	74a2                	ld	s1,40(sp)
    8000404e:	7902                	ld	s2,32(sp)
    80004050:	69e2                	ld	s3,24(sp)
    80004052:	6a42                	ld	s4,16(sp)
    80004054:	6aa2                	ld	s5,8(sp)
    80004056:	6b02                	ld	s6,0(sp)
    80004058:	6121                	addi	sp,sp,64
    8000405a:	8082                	ret
    8000405c:	8082                	ret

000000008000405e <initlog>:
{
    8000405e:	7179                	addi	sp,sp,-48
    80004060:	f406                	sd	ra,40(sp)
    80004062:	f022                	sd	s0,32(sp)
    80004064:	ec26                	sd	s1,24(sp)
    80004066:	e84a                	sd	s2,16(sp)
    80004068:	e44e                	sd	s3,8(sp)
    8000406a:	e052                	sd	s4,0(sp)
    8000406c:	1800                	addi	s0,sp,48
    8000406e:	84aa                	mv	s1,a0
    80004070:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80004072:	0b000713          	li	a4,176
    80004076:	02e509b3          	mul	s3,a0,a4
    8000407a:	0001d917          	auipc	s2,0x1d
    8000407e:	e8690913          	addi	s2,s2,-378 # 80020f00 <log>
    80004082:	994e                	add	s2,s2,s3
    80004084:	00006597          	auipc	a1,0x6
    80004088:	91c58593          	addi	a1,a1,-1764 # 800099a0 <userret+0x910>
    8000408c:	854a                	mv	a0,s2
    8000408e:	ffffd097          	auipc	ra,0xffffd
    80004092:	94e080e7          	jalr	-1714(ra) # 800009dc <initlock>
  log[dev].start = sb->logstart;
    80004096:	014a2583          	lw	a1,20(s4)
    8000409a:	02b92023          	sw	a1,32(s2)
  log[dev].size = sb->nlog;
    8000409e:	010a2783          	lw	a5,16(s4)
    800040a2:	02f92223          	sw	a5,36(s2)
  log[dev].dev = dev;
    800040a6:	02992823          	sw	s1,48(s2)
  struct buf *buf = bread(dev, log[dev].start);
    800040aa:	8526                	mv	a0,s1
    800040ac:	fffff097          	auipc	ra,0xfffff
    800040b0:	e92080e7          	jalr	-366(ra) # 80002f3e <bread>
  log[dev].lh.n = lh->n;
    800040b4:	513c                	lw	a5,96(a0)
    800040b6:	02f92a23          	sw	a5,52(s2)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040ba:	02f05663          	blez	a5,800040e6 <initlog+0x88>
    800040be:	06450693          	addi	a3,a0,100
    800040c2:	0001d717          	auipc	a4,0x1d
    800040c6:	e7670713          	addi	a4,a4,-394 # 80020f38 <log+0x38>
    800040ca:	974e                	add	a4,a4,s3
    800040cc:	37fd                	addiw	a5,a5,-1
    800040ce:	1782                	slli	a5,a5,0x20
    800040d0:	9381                	srli	a5,a5,0x20
    800040d2:	078a                	slli	a5,a5,0x2
    800040d4:	06850613          	addi	a2,a0,104
    800040d8:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    800040da:	4290                	lw	a2,0(a3)
    800040dc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040de:	0691                	addi	a3,a3,4
    800040e0:	0711                	addi	a4,a4,4
    800040e2:	fef69ce3          	bne	a3,a5,800040da <initlog+0x7c>
  brelse(buf);
    800040e6:	fffff097          	auipc	ra,0xfffff
    800040ea:	f8c080e7          	jalr	-116(ra) # 80003072 <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    800040ee:	8526                	mv	a0,s1
    800040f0:	00000097          	auipc	ra,0x0
    800040f4:	ea2080e7          	jalr	-350(ra) # 80003f92 <install_trans>
  log[dev].lh.n = 0;
    800040f8:	0b000793          	li	a5,176
    800040fc:	02f48733          	mul	a4,s1,a5
    80004100:	0001d797          	auipc	a5,0x1d
    80004104:	e0078793          	addi	a5,a5,-512 # 80020f00 <log>
    80004108:	97ba                	add	a5,a5,a4
    8000410a:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    8000410e:	8526                	mv	a0,s1
    80004110:	00000097          	auipc	ra,0x0
    80004114:	df8080e7          	jalr	-520(ra) # 80003f08 <write_head>
}
    80004118:	70a2                	ld	ra,40(sp)
    8000411a:	7402                	ld	s0,32(sp)
    8000411c:	64e2                	ld	s1,24(sp)
    8000411e:	6942                	ld	s2,16(sp)
    80004120:	69a2                	ld	s3,8(sp)
    80004122:	6a02                	ld	s4,0(sp)
    80004124:	6145                	addi	sp,sp,48
    80004126:	8082                	ret

0000000080004128 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    80004128:	7139                	addi	sp,sp,-64
    8000412a:	fc06                	sd	ra,56(sp)
    8000412c:	f822                	sd	s0,48(sp)
    8000412e:	f426                	sd	s1,40(sp)
    80004130:	f04a                	sd	s2,32(sp)
    80004132:	ec4e                	sd	s3,24(sp)
    80004134:	e852                	sd	s4,16(sp)
    80004136:	e456                	sd	s5,8(sp)
    80004138:	0080                	addi	s0,sp,64
    8000413a:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    8000413c:	0b000913          	li	s2,176
    80004140:	032507b3          	mul	a5,a0,s2
    80004144:	0001d917          	auipc	s2,0x1d
    80004148:	dbc90913          	addi	s2,s2,-580 # 80020f00 <log>
    8000414c:	993e                	add	s2,s2,a5
    8000414e:	854a                	mv	a0,s2
    80004150:	ffffd097          	auipc	ra,0xffffd
    80004154:	960080e7          	jalr	-1696(ra) # 80000ab0 <acquire>
  while(1){
    if(log[dev].committing){
    80004158:	0001d997          	auipc	s3,0x1d
    8000415c:	da898993          	addi	s3,s3,-600 # 80020f00 <log>
    80004160:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004162:	4a79                	li	s4,30
    80004164:	a039                	j	80004172 <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80004166:	85ca                	mv	a1,s2
    80004168:	854e                	mv	a0,s3
    8000416a:	ffffe097          	auipc	ra,0xffffe
    8000416e:	0f8080e7          	jalr	248(ra) # 80002262 <sleep>
    if(log[dev].committing){
    80004172:	54dc                	lw	a5,44(s1)
    80004174:	fbed                	bnez	a5,80004166 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004176:	549c                	lw	a5,40(s1)
    80004178:	0017871b          	addiw	a4,a5,1
    8000417c:	0007069b          	sext.w	a3,a4
    80004180:	0027179b          	slliw	a5,a4,0x2
    80004184:	9fb9                	addw	a5,a5,a4
    80004186:	0017979b          	slliw	a5,a5,0x1
    8000418a:	58d8                	lw	a4,52(s1)
    8000418c:	9fb9                	addw	a5,a5,a4
    8000418e:	00fa5963          	bge	s4,a5,800041a0 <begin_op+0x78>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    80004192:	85ca                	mv	a1,s2
    80004194:	854e                	mv	a0,s3
    80004196:	ffffe097          	auipc	ra,0xffffe
    8000419a:	0cc080e7          	jalr	204(ra) # 80002262 <sleep>
    8000419e:	bfd1                	j	80004172 <begin_op+0x4a>
    } else {
      log[dev].outstanding += 1;
    800041a0:	0b000513          	li	a0,176
    800041a4:	02aa8ab3          	mul	s5,s5,a0
    800041a8:	0001d797          	auipc	a5,0x1d
    800041ac:	d5878793          	addi	a5,a5,-680 # 80020f00 <log>
    800041b0:	9abe                	add	s5,s5,a5
    800041b2:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    800041b6:	854a                	mv	a0,s2
    800041b8:	ffffd097          	auipc	ra,0xffffd
    800041bc:	9c8080e7          	jalr	-1592(ra) # 80000b80 <release>
      break;
    }
  }
}
    800041c0:	70e2                	ld	ra,56(sp)
    800041c2:	7442                	ld	s0,48(sp)
    800041c4:	74a2                	ld	s1,40(sp)
    800041c6:	7902                	ld	s2,32(sp)
    800041c8:	69e2                	ld	s3,24(sp)
    800041ca:	6a42                	ld	s4,16(sp)
    800041cc:	6aa2                	ld	s5,8(sp)
    800041ce:	6121                	addi	sp,sp,64
    800041d0:	8082                	ret

00000000800041d2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    800041d2:	715d                	addi	sp,sp,-80
    800041d4:	e486                	sd	ra,72(sp)
    800041d6:	e0a2                	sd	s0,64(sp)
    800041d8:	fc26                	sd	s1,56(sp)
    800041da:	f84a                	sd	s2,48(sp)
    800041dc:	f44e                	sd	s3,40(sp)
    800041de:	f052                	sd	s4,32(sp)
    800041e0:	ec56                	sd	s5,24(sp)
    800041e2:	e85a                	sd	s6,16(sp)
    800041e4:	e45e                	sd	s7,8(sp)
    800041e6:	e062                	sd	s8,0(sp)
    800041e8:	0880                	addi	s0,sp,80
    800041ea:	8aaa                	mv	s5,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    800041ec:	0b000913          	li	s2,176
    800041f0:	03250933          	mul	s2,a0,s2
    800041f4:	0001d497          	auipc	s1,0x1d
    800041f8:	d0c48493          	addi	s1,s1,-756 # 80020f00 <log>
    800041fc:	94ca                	add	s1,s1,s2
    800041fe:	8526                	mv	a0,s1
    80004200:	ffffd097          	auipc	ra,0xffffd
    80004204:	8b0080e7          	jalr	-1872(ra) # 80000ab0 <acquire>
  log[dev].outstanding -= 1;
    80004208:	5498                	lw	a4,40(s1)
    8000420a:	377d                	addiw	a4,a4,-1
    8000420c:	d498                	sw	a4,40(s1)
  if(log[dev].committing)
    8000420e:	54dc                	lw	a5,44(s1)
    80004210:	efbd                	bnez	a5,8000428e <end_op+0xbc>
    80004212:	00070b1b          	sext.w	s6,a4
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004216:	080b1463          	bnez	s6,8000429e <end_op+0xcc>
    do_commit = 1;
    log[dev].committing = 1;
    8000421a:	0b000993          	li	s3,176
    8000421e:	033a87b3          	mul	a5,s5,s3
    80004222:	0001d997          	auipc	s3,0x1d
    80004226:	cde98993          	addi	s3,s3,-802 # 80020f00 <log>
    8000422a:	99be                	add	s3,s3,a5
    8000422c:	4785                	li	a5,1
    8000422e:	02f9a623          	sw	a5,44(s3)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    80004232:	8526                	mv	a0,s1
    80004234:	ffffd097          	auipc	ra,0xffffd
    80004238:	94c080e7          	jalr	-1716(ra) # 80000b80 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    8000423c:	0349a783          	lw	a5,52(s3)
    80004240:	06f04d63          	bgtz	a5,800042ba <end_op+0xe8>
    acquire(&log[dev].lock);
    80004244:	8526                	mv	a0,s1
    80004246:	ffffd097          	auipc	ra,0xffffd
    8000424a:	86a080e7          	jalr	-1942(ra) # 80000ab0 <acquire>
    log[dev].committing = 0;
    8000424e:	0001d517          	auipc	a0,0x1d
    80004252:	cb250513          	addi	a0,a0,-846 # 80020f00 <log>
    80004256:	0b000793          	li	a5,176
    8000425a:	02fa87b3          	mul	a5,s5,a5
    8000425e:	97aa                	add	a5,a5,a0
    80004260:	0207a623          	sw	zero,44(a5)
    wakeup(&log);
    80004264:	ffffe097          	auipc	ra,0xffffe
    80004268:	184080e7          	jalr	388(ra) # 800023e8 <wakeup>
    release(&log[dev].lock);
    8000426c:	8526                	mv	a0,s1
    8000426e:	ffffd097          	auipc	ra,0xffffd
    80004272:	912080e7          	jalr	-1774(ra) # 80000b80 <release>
}
    80004276:	60a6                	ld	ra,72(sp)
    80004278:	6406                	ld	s0,64(sp)
    8000427a:	74e2                	ld	s1,56(sp)
    8000427c:	7942                	ld	s2,48(sp)
    8000427e:	79a2                	ld	s3,40(sp)
    80004280:	7a02                	ld	s4,32(sp)
    80004282:	6ae2                	ld	s5,24(sp)
    80004284:	6b42                	ld	s6,16(sp)
    80004286:	6ba2                	ld	s7,8(sp)
    80004288:	6c02                	ld	s8,0(sp)
    8000428a:	6161                	addi	sp,sp,80
    8000428c:	8082                	ret
    panic("log[dev].committing");
    8000428e:	00005517          	auipc	a0,0x5
    80004292:	71a50513          	addi	a0,a0,1818 # 800099a8 <userret+0x918>
    80004296:	ffffc097          	auipc	ra,0xffffc
    8000429a:	2c4080e7          	jalr	708(ra) # 8000055a <panic>
    wakeup(&log);
    8000429e:	0001d517          	auipc	a0,0x1d
    800042a2:	c6250513          	addi	a0,a0,-926 # 80020f00 <log>
    800042a6:	ffffe097          	auipc	ra,0xffffe
    800042aa:	142080e7          	jalr	322(ra) # 800023e8 <wakeup>
  release(&log[dev].lock);
    800042ae:	8526                	mv	a0,s1
    800042b0:	ffffd097          	auipc	ra,0xffffd
    800042b4:	8d0080e7          	jalr	-1840(ra) # 80000b80 <release>
  if(do_commit){
    800042b8:	bf7d                	j	80004276 <end_op+0xa4>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800042ba:	0001d797          	auipc	a5,0x1d
    800042be:	c7e78793          	addi	a5,a5,-898 # 80020f38 <log+0x38>
    800042c2:	993e                	add	s2,s2,a5
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    800042c4:	000a8c1b          	sext.w	s8,s5
    800042c8:	0b000b93          	li	s7,176
    800042cc:	037a87b3          	mul	a5,s5,s7
    800042d0:	0001db97          	auipc	s7,0x1d
    800042d4:	c30b8b93          	addi	s7,s7,-976 # 80020f00 <log>
    800042d8:	9bbe                	add	s7,s7,a5
    800042da:	020ba583          	lw	a1,32(s7)
    800042de:	016585bb          	addw	a1,a1,s6
    800042e2:	2585                	addiw	a1,a1,1
    800042e4:	8562                	mv	a0,s8
    800042e6:	fffff097          	auipc	ra,0xfffff
    800042ea:	c58080e7          	jalr	-936(ra) # 80002f3e <bread>
    800042ee:	89aa                	mv	s3,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    800042f0:	00092583          	lw	a1,0(s2)
    800042f4:	8562                	mv	a0,s8
    800042f6:	fffff097          	auipc	ra,0xfffff
    800042fa:	c48080e7          	jalr	-952(ra) # 80002f3e <bread>
    800042fe:	8a2a                	mv	s4,a0
    memmove(to->data, from->data, BSIZE);
    80004300:	40000613          	li	a2,1024
    80004304:	06050593          	addi	a1,a0,96
    80004308:	06098513          	addi	a0,s3,96
    8000430c:	ffffd097          	auipc	ra,0xffffd
    80004310:	ad2080e7          	jalr	-1326(ra) # 80000dde <memmove>
    bwrite(to);  // write the log
    80004314:	854e                	mv	a0,s3
    80004316:	fffff097          	auipc	ra,0xfffff
    8000431a:	d1c080e7          	jalr	-740(ra) # 80003032 <bwrite>
    brelse(from);
    8000431e:	8552                	mv	a0,s4
    80004320:	fffff097          	auipc	ra,0xfffff
    80004324:	d52080e7          	jalr	-686(ra) # 80003072 <brelse>
    brelse(to);
    80004328:	854e                	mv	a0,s3
    8000432a:	fffff097          	auipc	ra,0xfffff
    8000432e:	d48080e7          	jalr	-696(ra) # 80003072 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004332:	2b05                	addiw	s6,s6,1
    80004334:	0911                	addi	s2,s2,4
    80004336:	034ba783          	lw	a5,52(s7)
    8000433a:	fafb40e3          	blt	s6,a5,800042da <end_op+0x108>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    8000433e:	8556                	mv	a0,s5
    80004340:	00000097          	auipc	ra,0x0
    80004344:	bc8080e7          	jalr	-1080(ra) # 80003f08 <write_head>
    install_trans(dev); // Now install writes to home locations
    80004348:	8556                	mv	a0,s5
    8000434a:	00000097          	auipc	ra,0x0
    8000434e:	c48080e7          	jalr	-952(ra) # 80003f92 <install_trans>
    log[dev].lh.n = 0;
    80004352:	0b000793          	li	a5,176
    80004356:	02fa8733          	mul	a4,s5,a5
    8000435a:	0001d797          	auipc	a5,0x1d
    8000435e:	ba678793          	addi	a5,a5,-1114 # 80020f00 <log>
    80004362:	97ba                	add	a5,a5,a4
    80004364:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    80004368:	8556                	mv	a0,s5
    8000436a:	00000097          	auipc	ra,0x0
    8000436e:	b9e080e7          	jalr	-1122(ra) # 80003f08 <write_head>
    80004372:	bdc9                	j	80004244 <end_op+0x72>

0000000080004374 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004374:	7179                	addi	sp,sp,-48
    80004376:	f406                	sd	ra,40(sp)
    80004378:	f022                	sd	s0,32(sp)
    8000437a:	ec26                	sd	s1,24(sp)
    8000437c:	e84a                	sd	s2,16(sp)
    8000437e:	e44e                	sd	s3,8(sp)
    80004380:	e052                	sd	s4,0(sp)
    80004382:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004384:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004388:	0b000793          	li	a5,176
    8000438c:	02f90733          	mul	a4,s2,a5
    80004390:	0001d797          	auipc	a5,0x1d
    80004394:	b7078793          	addi	a5,a5,-1168 # 80020f00 <log>
    80004398:	97ba                	add	a5,a5,a4
    8000439a:	5bd4                	lw	a3,52(a5)
    8000439c:	47f5                	li	a5,29
    8000439e:	0ad7cc63          	blt	a5,a3,80004456 <log_write+0xe2>
    800043a2:	89aa                	mv	s3,a0
    800043a4:	0001d797          	auipc	a5,0x1d
    800043a8:	b5c78793          	addi	a5,a5,-1188 # 80020f00 <log>
    800043ac:	97ba                	add	a5,a5,a4
    800043ae:	53dc                	lw	a5,36(a5)
    800043b0:	37fd                	addiw	a5,a5,-1
    800043b2:	0af6d263          	bge	a3,a5,80004456 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    800043b6:	0b000793          	li	a5,176
    800043ba:	02f90733          	mul	a4,s2,a5
    800043be:	0001d797          	auipc	a5,0x1d
    800043c2:	b4278793          	addi	a5,a5,-1214 # 80020f00 <log>
    800043c6:	97ba                	add	a5,a5,a4
    800043c8:	579c                	lw	a5,40(a5)
    800043ca:	08f05e63          	blez	a5,80004466 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    800043ce:	0b000793          	li	a5,176
    800043d2:	02f904b3          	mul	s1,s2,a5
    800043d6:	0001da17          	auipc	s4,0x1d
    800043da:	b2aa0a13          	addi	s4,s4,-1238 # 80020f00 <log>
    800043de:	9a26                	add	s4,s4,s1
    800043e0:	8552                	mv	a0,s4
    800043e2:	ffffc097          	auipc	ra,0xffffc
    800043e6:	6ce080e7          	jalr	1742(ra) # 80000ab0 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    800043ea:	034a2603          	lw	a2,52(s4)
    800043ee:	08c05463          	blez	a2,80004476 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800043f2:	00c9a583          	lw	a1,12(s3)
    800043f6:	0001d797          	auipc	a5,0x1d
    800043fa:	b4278793          	addi	a5,a5,-1214 # 80020f38 <log+0x38>
    800043fe:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    80004400:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004402:	4394                	lw	a3,0(a5)
    80004404:	06b68a63          	beq	a3,a1,80004478 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004408:	2705                	addiw	a4,a4,1
    8000440a:	0791                	addi	a5,a5,4
    8000440c:	fec71be3          	bne	a4,a2,80004402 <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004410:	02c00793          	li	a5,44
    80004414:	02f907b3          	mul	a5,s2,a5
    80004418:	97b2                	add	a5,a5,a2
    8000441a:	07b1                	addi	a5,a5,12
    8000441c:	078a                	slli	a5,a5,0x2
    8000441e:	0001d717          	auipc	a4,0x1d
    80004422:	ae270713          	addi	a4,a4,-1310 # 80020f00 <log>
    80004426:	97ba                	add	a5,a5,a4
    80004428:	00c9a703          	lw	a4,12(s3)
    8000442c:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    8000442e:	854e                	mv	a0,s3
    80004430:	fffff097          	auipc	ra,0xfffff
    80004434:	ce0080e7          	jalr	-800(ra) # 80003110 <bpin>
    log[dev].lh.n++;
    80004438:	0b000793          	li	a5,176
    8000443c:	02f90933          	mul	s2,s2,a5
    80004440:	0001d797          	auipc	a5,0x1d
    80004444:	ac078793          	addi	a5,a5,-1344 # 80020f00 <log>
    80004448:	993e                	add	s2,s2,a5
    8000444a:	03492783          	lw	a5,52(s2)
    8000444e:	2785                	addiw	a5,a5,1
    80004450:	02f92a23          	sw	a5,52(s2)
    80004454:	a099                	j	8000449a <log_write+0x126>
    panic("too big a transaction");
    80004456:	00005517          	auipc	a0,0x5
    8000445a:	56a50513          	addi	a0,a0,1386 # 800099c0 <userret+0x930>
    8000445e:	ffffc097          	auipc	ra,0xffffc
    80004462:	0fc080e7          	jalr	252(ra) # 8000055a <panic>
    panic("log_write outside of trans");
    80004466:	00005517          	auipc	a0,0x5
    8000446a:	57250513          	addi	a0,a0,1394 # 800099d8 <userret+0x948>
    8000446e:	ffffc097          	auipc	ra,0xffffc
    80004472:	0ec080e7          	jalr	236(ra) # 8000055a <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004476:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    80004478:	02c00793          	li	a5,44
    8000447c:	02f907b3          	mul	a5,s2,a5
    80004480:	97ba                	add	a5,a5,a4
    80004482:	07b1                	addi	a5,a5,12
    80004484:	078a                	slli	a5,a5,0x2
    80004486:	0001d697          	auipc	a3,0x1d
    8000448a:	a7a68693          	addi	a3,a3,-1414 # 80020f00 <log>
    8000448e:	97b6                	add	a5,a5,a3
    80004490:	00c9a683          	lw	a3,12(s3)
    80004494:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004496:	f8e60ce3          	beq	a2,a4,8000442e <log_write+0xba>
  }
  release(&log[dev].lock);
    8000449a:	8552                	mv	a0,s4
    8000449c:	ffffc097          	auipc	ra,0xffffc
    800044a0:	6e4080e7          	jalr	1764(ra) # 80000b80 <release>
}
    800044a4:	70a2                	ld	ra,40(sp)
    800044a6:	7402                	ld	s0,32(sp)
    800044a8:	64e2                	ld	s1,24(sp)
    800044aa:	6942                	ld	s2,16(sp)
    800044ac:	69a2                	ld	s3,8(sp)
    800044ae:	6a02                	ld	s4,0(sp)
    800044b0:	6145                	addi	sp,sp,48
    800044b2:	8082                	ret

00000000800044b4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044b4:	1101                	addi	sp,sp,-32
    800044b6:	ec06                	sd	ra,24(sp)
    800044b8:	e822                	sd	s0,16(sp)
    800044ba:	e426                	sd	s1,8(sp)
    800044bc:	e04a                	sd	s2,0(sp)
    800044be:	1000                	addi	s0,sp,32
    800044c0:	84aa                	mv	s1,a0
    800044c2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044c4:	00005597          	auipc	a1,0x5
    800044c8:	53458593          	addi	a1,a1,1332 # 800099f8 <userret+0x968>
    800044cc:	0521                	addi	a0,a0,8
    800044ce:	ffffc097          	auipc	ra,0xffffc
    800044d2:	50e080e7          	jalr	1294(ra) # 800009dc <initlock>
  lk->name = name;
    800044d6:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    800044da:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044de:	0204a823          	sw	zero,48(s1)
}
    800044e2:	60e2                	ld	ra,24(sp)
    800044e4:	6442                	ld	s0,16(sp)
    800044e6:	64a2                	ld	s1,8(sp)
    800044e8:	6902                	ld	s2,0(sp)
    800044ea:	6105                	addi	sp,sp,32
    800044ec:	8082                	ret

00000000800044ee <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044ee:	1101                	addi	sp,sp,-32
    800044f0:	ec06                	sd	ra,24(sp)
    800044f2:	e822                	sd	s0,16(sp)
    800044f4:	e426                	sd	s1,8(sp)
    800044f6:	e04a                	sd	s2,0(sp)
    800044f8:	1000                	addi	s0,sp,32
    800044fa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044fc:	00850913          	addi	s2,a0,8
    80004500:	854a                	mv	a0,s2
    80004502:	ffffc097          	auipc	ra,0xffffc
    80004506:	5ae080e7          	jalr	1454(ra) # 80000ab0 <acquire>
  while (lk->locked) {
    8000450a:	409c                	lw	a5,0(s1)
    8000450c:	cb89                	beqz	a5,8000451e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000450e:	85ca                	mv	a1,s2
    80004510:	8526                	mv	a0,s1
    80004512:	ffffe097          	auipc	ra,0xffffe
    80004516:	d50080e7          	jalr	-688(ra) # 80002262 <sleep>
  while (lk->locked) {
    8000451a:	409c                	lw	a5,0(s1)
    8000451c:	fbed                	bnez	a5,8000450e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000451e:	4785                	li	a5,1
    80004520:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004522:	ffffd097          	auipc	ra,0xffffd
    80004526:	584080e7          	jalr	1412(ra) # 80001aa6 <myproc>
    8000452a:	413c                	lw	a5,64(a0)
    8000452c:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    8000452e:	854a                	mv	a0,s2
    80004530:	ffffc097          	auipc	ra,0xffffc
    80004534:	650080e7          	jalr	1616(ra) # 80000b80 <release>
}
    80004538:	60e2                	ld	ra,24(sp)
    8000453a:	6442                	ld	s0,16(sp)
    8000453c:	64a2                	ld	s1,8(sp)
    8000453e:	6902                	ld	s2,0(sp)
    80004540:	6105                	addi	sp,sp,32
    80004542:	8082                	ret

0000000080004544 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004544:	1101                	addi	sp,sp,-32
    80004546:	ec06                	sd	ra,24(sp)
    80004548:	e822                	sd	s0,16(sp)
    8000454a:	e426                	sd	s1,8(sp)
    8000454c:	e04a                	sd	s2,0(sp)
    8000454e:	1000                	addi	s0,sp,32
    80004550:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004552:	00850913          	addi	s2,a0,8
    80004556:	854a                	mv	a0,s2
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	558080e7          	jalr	1368(ra) # 80000ab0 <acquire>
  lk->locked = 0;
    80004560:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004564:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004568:	8526                	mv	a0,s1
    8000456a:	ffffe097          	auipc	ra,0xffffe
    8000456e:	e7e080e7          	jalr	-386(ra) # 800023e8 <wakeup>
  release(&lk->lk);
    80004572:	854a                	mv	a0,s2
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	60c080e7          	jalr	1548(ra) # 80000b80 <release>
}
    8000457c:	60e2                	ld	ra,24(sp)
    8000457e:	6442                	ld	s0,16(sp)
    80004580:	64a2                	ld	s1,8(sp)
    80004582:	6902                	ld	s2,0(sp)
    80004584:	6105                	addi	sp,sp,32
    80004586:	8082                	ret

0000000080004588 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004588:	7179                	addi	sp,sp,-48
    8000458a:	f406                	sd	ra,40(sp)
    8000458c:	f022                	sd	s0,32(sp)
    8000458e:	ec26                	sd	s1,24(sp)
    80004590:	e84a                	sd	s2,16(sp)
    80004592:	e44e                	sd	s3,8(sp)
    80004594:	1800                	addi	s0,sp,48
    80004596:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004598:	00850913          	addi	s2,a0,8
    8000459c:	854a                	mv	a0,s2
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	512080e7          	jalr	1298(ra) # 80000ab0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045a6:	409c                	lw	a5,0(s1)
    800045a8:	ef99                	bnez	a5,800045c6 <holdingsleep+0x3e>
    800045aa:	4481                	li	s1,0
  release(&lk->lk);
    800045ac:	854a                	mv	a0,s2
    800045ae:	ffffc097          	auipc	ra,0xffffc
    800045b2:	5d2080e7          	jalr	1490(ra) # 80000b80 <release>
  return r;
}
    800045b6:	8526                	mv	a0,s1
    800045b8:	70a2                	ld	ra,40(sp)
    800045ba:	7402                	ld	s0,32(sp)
    800045bc:	64e2                	ld	s1,24(sp)
    800045be:	6942                	ld	s2,16(sp)
    800045c0:	69a2                	ld	s3,8(sp)
    800045c2:	6145                	addi	sp,sp,48
    800045c4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045c6:	0304a983          	lw	s3,48(s1)
    800045ca:	ffffd097          	auipc	ra,0xffffd
    800045ce:	4dc080e7          	jalr	1244(ra) # 80001aa6 <myproc>
    800045d2:	4124                	lw	s1,64(a0)
    800045d4:	413484b3          	sub	s1,s1,s3
    800045d8:	0014b493          	seqz	s1,s1
    800045dc:	bfc1                	j	800045ac <holdingsleep+0x24>

00000000800045de <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045de:	1141                	addi	sp,sp,-16
    800045e0:	e406                	sd	ra,8(sp)
    800045e2:	e022                	sd	s0,0(sp)
    800045e4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045e6:	00005597          	auipc	a1,0x5
    800045ea:	42258593          	addi	a1,a1,1058 # 80009a08 <userret+0x978>
    800045ee:	0001d517          	auipc	a0,0x1d
    800045f2:	b1250513          	addi	a0,a0,-1262 # 80021100 <ftable>
    800045f6:	ffffc097          	auipc	ra,0xffffc
    800045fa:	3e6080e7          	jalr	998(ra) # 800009dc <initlock>
}
    800045fe:	60a2                	ld	ra,8(sp)
    80004600:	6402                	ld	s0,0(sp)
    80004602:	0141                	addi	sp,sp,16
    80004604:	8082                	ret

0000000080004606 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004606:	1101                	addi	sp,sp,-32
    80004608:	ec06                	sd	ra,24(sp)
    8000460a:	e822                	sd	s0,16(sp)
    8000460c:	e426                	sd	s1,8(sp)
    8000460e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004610:	0001d517          	auipc	a0,0x1d
    80004614:	af050513          	addi	a0,a0,-1296 # 80021100 <ftable>
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	498080e7          	jalr	1176(ra) # 80000ab0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004620:	0001d497          	auipc	s1,0x1d
    80004624:	b0048493          	addi	s1,s1,-1280 # 80021120 <ftable+0x20>
    80004628:	0001e717          	auipc	a4,0x1e
    8000462c:	0d870713          	addi	a4,a4,216 # 80022700 <ftable+0x1600>
    if(f->ref == 0){
    80004630:	40dc                	lw	a5,4(s1)
    80004632:	cf99                	beqz	a5,80004650 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004634:	03848493          	addi	s1,s1,56
    80004638:	fee49ce3          	bne	s1,a4,80004630 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000463c:	0001d517          	auipc	a0,0x1d
    80004640:	ac450513          	addi	a0,a0,-1340 # 80021100 <ftable>
    80004644:	ffffc097          	auipc	ra,0xffffc
    80004648:	53c080e7          	jalr	1340(ra) # 80000b80 <release>
  return 0;
    8000464c:	4481                	li	s1,0
    8000464e:	a819                	j	80004664 <filealloc+0x5e>
      f->ref = 1;
    80004650:	4785                	li	a5,1
    80004652:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004654:	0001d517          	auipc	a0,0x1d
    80004658:	aac50513          	addi	a0,a0,-1364 # 80021100 <ftable>
    8000465c:	ffffc097          	auipc	ra,0xffffc
    80004660:	524080e7          	jalr	1316(ra) # 80000b80 <release>
}
    80004664:	8526                	mv	a0,s1
    80004666:	60e2                	ld	ra,24(sp)
    80004668:	6442                	ld	s0,16(sp)
    8000466a:	64a2                	ld	s1,8(sp)
    8000466c:	6105                	addi	sp,sp,32
    8000466e:	8082                	ret

0000000080004670 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004670:	1101                	addi	sp,sp,-32
    80004672:	ec06                	sd	ra,24(sp)
    80004674:	e822                	sd	s0,16(sp)
    80004676:	e426                	sd	s1,8(sp)
    80004678:	1000                	addi	s0,sp,32
    8000467a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000467c:	0001d517          	auipc	a0,0x1d
    80004680:	a8450513          	addi	a0,a0,-1404 # 80021100 <ftable>
    80004684:	ffffc097          	auipc	ra,0xffffc
    80004688:	42c080e7          	jalr	1068(ra) # 80000ab0 <acquire>
  if(f->ref < 1)
    8000468c:	40dc                	lw	a5,4(s1)
    8000468e:	02f05263          	blez	a5,800046b2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004692:	2785                	addiw	a5,a5,1
    80004694:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004696:	0001d517          	auipc	a0,0x1d
    8000469a:	a6a50513          	addi	a0,a0,-1430 # 80021100 <ftable>
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	4e2080e7          	jalr	1250(ra) # 80000b80 <release>
  return f;
}
    800046a6:	8526                	mv	a0,s1
    800046a8:	60e2                	ld	ra,24(sp)
    800046aa:	6442                	ld	s0,16(sp)
    800046ac:	64a2                	ld	s1,8(sp)
    800046ae:	6105                	addi	sp,sp,32
    800046b0:	8082                	ret
    panic("filedup");
    800046b2:	00005517          	auipc	a0,0x5
    800046b6:	35e50513          	addi	a0,a0,862 # 80009a10 <userret+0x980>
    800046ba:	ffffc097          	auipc	ra,0xffffc
    800046be:	ea0080e7          	jalr	-352(ra) # 8000055a <panic>

00000000800046c2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046c2:	7139                	addi	sp,sp,-64
    800046c4:	fc06                	sd	ra,56(sp)
    800046c6:	f822                	sd	s0,48(sp)
    800046c8:	f426                	sd	s1,40(sp)
    800046ca:	f04a                	sd	s2,32(sp)
    800046cc:	ec4e                	sd	s3,24(sp)
    800046ce:	e852                	sd	s4,16(sp)
    800046d0:	e456                	sd	s5,8(sp)
    800046d2:	e05a                	sd	s6,0(sp)
    800046d4:	0080                	addi	s0,sp,64
    800046d6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046d8:	0001d517          	auipc	a0,0x1d
    800046dc:	a2850513          	addi	a0,a0,-1496 # 80021100 <ftable>
    800046e0:	ffffc097          	auipc	ra,0xffffc
    800046e4:	3d0080e7          	jalr	976(ra) # 80000ab0 <acquire>
  if(f->ref < 1)
    800046e8:	40dc                	lw	a5,4(s1)
    800046ea:	06f05a63          	blez	a5,8000475e <fileclose+0x9c>
    panic("fileclose");
  if(--f->ref > 0){
    800046ee:	37fd                	addiw	a5,a5,-1
    800046f0:	0007871b          	sext.w	a4,a5
    800046f4:	c0dc                	sw	a5,4(s1)
    800046f6:	06e04c63          	bgtz	a4,8000476e <fileclose+0xac>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046fa:	0004a903          	lw	s2,0(s1)
    800046fe:	0094ca83          	lbu	s5,9(s1)
    80004702:	0184ba03          	ld	s4,24(s1)
    80004706:	0204b983          	ld	s3,32(s1)
    8000470a:	0284bb03          	ld	s6,40(s1)
  f->ref = 0;
    8000470e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004712:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004716:	0001d517          	auipc	a0,0x1d
    8000471a:	9ea50513          	addi	a0,a0,-1558 # 80021100 <ftable>
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	462080e7          	jalr	1122(ra) # 80000b80 <release>

  if(ff.type == FD_PIPE){
    80004726:	4785                	li	a5,1
    80004728:	06f90563          	beq	s2,a5,80004792 <fileclose+0xd0>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_SOCK){
    8000472c:	4791                	li	a5,4
    8000472e:	06f90963          	beq	s2,a5,800047a0 <fileclose+0xde>
    sockclose(ff.sock);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004732:	3979                	addiw	s2,s2,-2
    80004734:	4785                	li	a5,1
    80004736:	0527e463          	bltu	a5,s2,8000477e <fileclose+0xbc>
    begin_op(ff.ip->dev);
    8000473a:	0009a503          	lw	a0,0(s3)
    8000473e:	00000097          	auipc	ra,0x0
    80004742:	9ea080e7          	jalr	-1558(ra) # 80004128 <begin_op>
    iput(ff.ip);
    80004746:	854e                	mv	a0,s3
    80004748:	fffff097          	auipc	ra,0xfffff
    8000474c:	10a080e7          	jalr	266(ra) # 80003852 <iput>
    end_op(ff.ip->dev);
    80004750:	0009a503          	lw	a0,0(s3)
    80004754:	00000097          	auipc	ra,0x0
    80004758:	a7e080e7          	jalr	-1410(ra) # 800041d2 <end_op>
    8000475c:	a00d                	j	8000477e <fileclose+0xbc>
    panic("fileclose");
    8000475e:	00005517          	auipc	a0,0x5
    80004762:	2ba50513          	addi	a0,a0,698 # 80009a18 <userret+0x988>
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	df4080e7          	jalr	-524(ra) # 8000055a <panic>
    release(&ftable.lock);
    8000476e:	0001d517          	auipc	a0,0x1d
    80004772:	99250513          	addi	a0,a0,-1646 # 80021100 <ftable>
    80004776:	ffffc097          	auipc	ra,0xffffc
    8000477a:	40a080e7          	jalr	1034(ra) # 80000b80 <release>
  }
}
    8000477e:	70e2                	ld	ra,56(sp)
    80004780:	7442                	ld	s0,48(sp)
    80004782:	74a2                	ld	s1,40(sp)
    80004784:	7902                	ld	s2,32(sp)
    80004786:	69e2                	ld	s3,24(sp)
    80004788:	6a42                	ld	s4,16(sp)
    8000478a:	6aa2                	ld	s5,8(sp)
    8000478c:	6b02                	ld	s6,0(sp)
    8000478e:	6121                	addi	sp,sp,64
    80004790:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004792:	85d6                	mv	a1,s5
    80004794:	8552                	mv	a0,s4
    80004796:	00000097          	auipc	ra,0x0
    8000479a:	3a8080e7          	jalr	936(ra) # 80004b3e <pipeclose>
    8000479e:	b7c5                	j	8000477e <fileclose+0xbc>
    sockclose(ff.sock);
    800047a0:	855a                	mv	a0,s6
    800047a2:	00003097          	auipc	ra,0x3
    800047a6:	a86080e7          	jalr	-1402(ra) # 80007228 <sockclose>
    800047aa:	bfd1                	j	8000477e <fileclose+0xbc>

00000000800047ac <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047ac:	715d                	addi	sp,sp,-80
    800047ae:	e486                	sd	ra,72(sp)
    800047b0:	e0a2                	sd	s0,64(sp)
    800047b2:	fc26                	sd	s1,56(sp)
    800047b4:	f84a                	sd	s2,48(sp)
    800047b6:	f44e                	sd	s3,40(sp)
    800047b8:	0880                	addi	s0,sp,80
    800047ba:	84aa                	mv	s1,a0
    800047bc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047be:	ffffd097          	auipc	ra,0xffffd
    800047c2:	2e8080e7          	jalr	744(ra) # 80001aa6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047c6:	409c                	lw	a5,0(s1)
    800047c8:	37f9                	addiw	a5,a5,-2
    800047ca:	4705                	li	a4,1
    800047cc:	04f76763          	bltu	a4,a5,8000481a <filestat+0x6e>
    800047d0:	892a                	mv	s2,a0
    ilock(f->ip);
    800047d2:	7088                	ld	a0,32(s1)
    800047d4:	fffff097          	auipc	ra,0xfffff
    800047d8:	f70080e7          	jalr	-144(ra) # 80003744 <ilock>
    stati(f->ip, &st);
    800047dc:	fb840593          	addi	a1,s0,-72
    800047e0:	7088                	ld	a0,32(s1)
    800047e2:	fffff097          	auipc	ra,0xfffff
    800047e6:	1c8080e7          	jalr	456(ra) # 800039aa <stati>
    iunlock(f->ip);
    800047ea:	7088                	ld	a0,32(s1)
    800047ec:	fffff097          	auipc	ra,0xfffff
    800047f0:	01a080e7          	jalr	26(ra) # 80003806 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047f4:	46e1                	li	a3,24
    800047f6:	fb840613          	addi	a2,s0,-72
    800047fa:	85ce                	mv	a1,s3
    800047fc:	05893503          	ld	a0,88(s2)
    80004800:	ffffd097          	auipc	ra,0xffffd
    80004804:	f9a080e7          	jalr	-102(ra) # 8000179a <copyout>
    80004808:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000480c:	60a6                	ld	ra,72(sp)
    8000480e:	6406                	ld	s0,64(sp)
    80004810:	74e2                	ld	s1,56(sp)
    80004812:	7942                	ld	s2,48(sp)
    80004814:	79a2                	ld	s3,40(sp)
    80004816:	6161                	addi	sp,sp,80
    80004818:	8082                	ret
  return -1;
    8000481a:	557d                	li	a0,-1
    8000481c:	bfc5                	j	8000480c <filestat+0x60>

000000008000481e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000481e:	7179                	addi	sp,sp,-48
    80004820:	f406                	sd	ra,40(sp)
    80004822:	f022                	sd	s0,32(sp)
    80004824:	ec26                	sd	s1,24(sp)
    80004826:	e84a                	sd	s2,16(sp)
    80004828:	e44e                	sd	s3,8(sp)
    8000482a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000482c:	00854783          	lbu	a5,8(a0)
    80004830:	cfd5                	beqz	a5,800048ec <fileread+0xce>
    80004832:	84aa                	mv	s1,a0
    80004834:	89ae                	mv	s3,a1
    80004836:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004838:	411c                	lw	a5,0(a0)
    8000483a:	4705                	li	a4,1
    8000483c:	04e78c63          	beq	a5,a4,80004894 <fileread+0x76>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_SOCK){
    80004840:	4711                	li	a4,4
    80004842:	06e78063          	beq	a5,a4,800048a2 <fileread+0x84>
    r = sockread(f->sock, addr, n);
  } else if(f->type == FD_DEVICE){
    80004846:	470d                	li	a4,3
    80004848:	06e78463          	beq	a5,a4,800048b0 <fileread+0x92>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    8000484c:	4709                	li	a4,2
    8000484e:	08e79763          	bne	a5,a4,800048dc <fileread+0xbe>
    ilock(f->ip);
    80004852:	7108                	ld	a0,32(a0)
    80004854:	fffff097          	auipc	ra,0xfffff
    80004858:	ef0080e7          	jalr	-272(ra) # 80003744 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000485c:	874a                	mv	a4,s2
    8000485e:	5894                	lw	a3,48(s1)
    80004860:	864e                	mv	a2,s3
    80004862:	4585                	li	a1,1
    80004864:	7088                	ld	a0,32(s1)
    80004866:	fffff097          	auipc	ra,0xfffff
    8000486a:	16e080e7          	jalr	366(ra) # 800039d4 <readi>
    8000486e:	892a                	mv	s2,a0
    80004870:	00a05563          	blez	a0,8000487a <fileread+0x5c>
      f->off += r;
    80004874:	589c                	lw	a5,48(s1)
    80004876:	9fa9                	addw	a5,a5,a0
    80004878:	d89c                	sw	a5,48(s1)
    iunlock(f->ip);
    8000487a:	7088                	ld	a0,32(s1)
    8000487c:	fffff097          	auipc	ra,0xfffff
    80004880:	f8a080e7          	jalr	-118(ra) # 80003806 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004884:	854a                	mv	a0,s2
    80004886:	70a2                	ld	ra,40(sp)
    80004888:	7402                	ld	s0,32(sp)
    8000488a:	64e2                	ld	s1,24(sp)
    8000488c:	6942                	ld	s2,16(sp)
    8000488e:	69a2                	ld	s3,8(sp)
    80004890:	6145                	addi	sp,sp,48
    80004892:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004894:	6d08                	ld	a0,24(a0)
    80004896:	00000097          	auipc	ra,0x0
    8000489a:	42c080e7          	jalr	1068(ra) # 80004cc2 <piperead>
    8000489e:	892a                	mv	s2,a0
    800048a0:	b7d5                	j	80004884 <fileread+0x66>
    r = sockread(f->sock, addr, n);
    800048a2:	7508                	ld	a0,40(a0)
    800048a4:	00003097          	auipc	ra,0x3
    800048a8:	a46080e7          	jalr	-1466(ra) # 800072ea <sockread>
    800048ac:	892a                	mv	s2,a0
    800048ae:	bfd9                	j	80004884 <fileread+0x66>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048b0:	03451783          	lh	a5,52(a0)
    800048b4:	03079693          	slli	a3,a5,0x30
    800048b8:	92c1                	srli	a3,a3,0x30
    800048ba:	4725                	li	a4,9
    800048bc:	02d76a63          	bltu	a4,a3,800048f0 <fileread+0xd2>
    800048c0:	0792                	slli	a5,a5,0x4
    800048c2:	0001c717          	auipc	a4,0x1c
    800048c6:	79e70713          	addi	a4,a4,1950 # 80021060 <devsw>
    800048ca:	97ba                	add	a5,a5,a4
    800048cc:	639c                	ld	a5,0(a5)
    800048ce:	c39d                	beqz	a5,800048f4 <fileread+0xd6>
    r = devsw[f->major].read(f, 1, addr, n);
    800048d0:	86b2                	mv	a3,a2
    800048d2:	862e                	mv	a2,a1
    800048d4:	4585                	li	a1,1
    800048d6:	9782                	jalr	a5
    800048d8:	892a                	mv	s2,a0
    800048da:	b76d                	j	80004884 <fileread+0x66>
    panic("fileread");
    800048dc:	00005517          	auipc	a0,0x5
    800048e0:	14c50513          	addi	a0,a0,332 # 80009a28 <userret+0x998>
    800048e4:	ffffc097          	auipc	ra,0xffffc
    800048e8:	c76080e7          	jalr	-906(ra) # 8000055a <panic>
    return -1;
    800048ec:	597d                	li	s2,-1
    800048ee:	bf59                	j	80004884 <fileread+0x66>
      return -1;
    800048f0:	597d                	li	s2,-1
    800048f2:	bf49                	j	80004884 <fileread+0x66>
    800048f4:	597d                	li	s2,-1
    800048f6:	b779                	j	80004884 <fileread+0x66>

00000000800048f8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048f8:	00954783          	lbu	a5,9(a0)
    800048fc:	14078f63          	beqz	a5,80004a5a <filewrite+0x162>
{
    80004900:	715d                	addi	sp,sp,-80
    80004902:	e486                	sd	ra,72(sp)
    80004904:	e0a2                	sd	s0,64(sp)
    80004906:	fc26                	sd	s1,56(sp)
    80004908:	f84a                	sd	s2,48(sp)
    8000490a:	f44e                	sd	s3,40(sp)
    8000490c:	f052                	sd	s4,32(sp)
    8000490e:	ec56                	sd	s5,24(sp)
    80004910:	e85a                	sd	s6,16(sp)
    80004912:	e45e                	sd	s7,8(sp)
    80004914:	e062                	sd	s8,0(sp)
    80004916:	0880                	addi	s0,sp,80
    80004918:	84aa                	mv	s1,a0
    8000491a:	8aae                	mv	s5,a1
    8000491c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000491e:	411c                	lw	a5,0(a0)
    80004920:	4705                	li	a4,1
    80004922:	02e78563          	beq	a5,a4,8000494c <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_SOCK){
    80004926:	4711                	li	a4,4
    80004928:	02e78863          	beq	a5,a4,80004958 <filewrite+0x60>
    ret = sockwrite(f->sock, addr, n);
  } else if(f->type == FD_DEVICE){
    8000492c:	470d                	li	a4,3
    8000492e:	02e78b63          	beq	a5,a4,80004964 <filewrite+0x6c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004932:	4709                	li	a4,2
    80004934:	10e79b63          	bne	a5,a4,80004a4a <filewrite+0x152>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004938:	10c05563          	blez	a2,80004a42 <filewrite+0x14a>
    int i = 0;
    8000493c:	4981                	li	s3,0
    8000493e:	6b05                	lui	s6,0x1
    80004940:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004944:	6b85                	lui	s7,0x1
    80004946:	c00b8b9b          	addiw	s7,s7,-1024
    8000494a:	a045                	j	800049ea <filewrite+0xf2>
    ret = pipewrite(f->pipe, addr, n);
    8000494c:	6d08                	ld	a0,24(a0)
    8000494e:	00000097          	auipc	ra,0x0
    80004952:	260080e7          	jalr	608(ra) # 80004bae <pipewrite>
    80004956:	a0d1                	j	80004a1a <filewrite+0x122>
    ret = sockwrite(f->sock, addr, n);
    80004958:	7508                	ld	a0,40(a0)
    8000495a:	00003097          	auipc	ra,0x3
    8000495e:	a68080e7          	jalr	-1432(ra) # 800073c2 <sockwrite>
    80004962:	a865                	j	80004a1a <filewrite+0x122>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004964:	03451783          	lh	a5,52(a0)
    80004968:	03079693          	slli	a3,a5,0x30
    8000496c:	92c1                	srli	a3,a3,0x30
    8000496e:	4725                	li	a4,9
    80004970:	0ed76763          	bltu	a4,a3,80004a5e <filewrite+0x166>
    80004974:	0792                	slli	a5,a5,0x4
    80004976:	0001c717          	auipc	a4,0x1c
    8000497a:	6ea70713          	addi	a4,a4,1770 # 80021060 <devsw>
    8000497e:	97ba                	add	a5,a5,a4
    80004980:	679c                	ld	a5,8(a5)
    80004982:	c3e5                	beqz	a5,80004a62 <filewrite+0x16a>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004984:	86b2                	mv	a3,a2
    80004986:	862e                	mv	a2,a1
    80004988:	4585                	li	a1,1
    8000498a:	9782                	jalr	a5
    8000498c:	a079                	j	80004a1a <filewrite+0x122>
    8000498e:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80004992:	709c                	ld	a5,32(s1)
    80004994:	4388                	lw	a0,0(a5)
    80004996:	fffff097          	auipc	ra,0xfffff
    8000499a:	792080e7          	jalr	1938(ra) # 80004128 <begin_op>
      ilock(f->ip);
    8000499e:	7088                	ld	a0,32(s1)
    800049a0:	fffff097          	auipc	ra,0xfffff
    800049a4:	da4080e7          	jalr	-604(ra) # 80003744 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049a8:	8762                	mv	a4,s8
    800049aa:	5894                	lw	a3,48(s1)
    800049ac:	01598633          	add	a2,s3,s5
    800049b0:	4585                	li	a1,1
    800049b2:	7088                	ld	a0,32(s1)
    800049b4:	fffff097          	auipc	ra,0xfffff
    800049b8:	114080e7          	jalr	276(ra) # 80003ac8 <writei>
    800049bc:	892a                	mv	s2,a0
    800049be:	02a05e63          	blez	a0,800049fa <filewrite+0x102>
        f->off += r;
    800049c2:	589c                	lw	a5,48(s1)
    800049c4:	9fa9                	addw	a5,a5,a0
    800049c6:	d89c                	sw	a5,48(s1)
      iunlock(f->ip);
    800049c8:	7088                	ld	a0,32(s1)
    800049ca:	fffff097          	auipc	ra,0xfffff
    800049ce:	e3c080e7          	jalr	-452(ra) # 80003806 <iunlock>
      end_op(f->ip->dev);
    800049d2:	709c                	ld	a5,32(s1)
    800049d4:	4388                	lw	a0,0(a5)
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	7fc080e7          	jalr	2044(ra) # 800041d2 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800049de:	052c1a63          	bne	s8,s2,80004a32 <filewrite+0x13a>
        panic("short filewrite");
      i += r;
    800049e2:	013909bb          	addw	s3,s2,s3
    while(i < n){
    800049e6:	0349d763          	bge	s3,s4,80004a14 <filewrite+0x11c>
      int n1 = n - i;
    800049ea:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800049ee:	893e                	mv	s2,a5
    800049f0:	2781                	sext.w	a5,a5
    800049f2:	f8fb5ee3          	bge	s6,a5,8000498e <filewrite+0x96>
    800049f6:	895e                	mv	s2,s7
    800049f8:	bf59                	j	8000498e <filewrite+0x96>
      iunlock(f->ip);
    800049fa:	7088                	ld	a0,32(s1)
    800049fc:	fffff097          	auipc	ra,0xfffff
    80004a00:	e0a080e7          	jalr	-502(ra) # 80003806 <iunlock>
      end_op(f->ip->dev);
    80004a04:	709c                	ld	a5,32(s1)
    80004a06:	4388                	lw	a0,0(a5)
    80004a08:	fffff097          	auipc	ra,0xfffff
    80004a0c:	7ca080e7          	jalr	1994(ra) # 800041d2 <end_op>
      if(r < 0)
    80004a10:	fc0957e3          	bgez	s2,800049de <filewrite+0xe6>
    }
    ret = (i == n ? n : -1);
    80004a14:	8552                	mv	a0,s4
    80004a16:	033a1863          	bne	s4,s3,80004a46 <filewrite+0x14e>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a1a:	60a6                	ld	ra,72(sp)
    80004a1c:	6406                	ld	s0,64(sp)
    80004a1e:	74e2                	ld	s1,56(sp)
    80004a20:	7942                	ld	s2,48(sp)
    80004a22:	79a2                	ld	s3,40(sp)
    80004a24:	7a02                	ld	s4,32(sp)
    80004a26:	6ae2                	ld	s5,24(sp)
    80004a28:	6b42                	ld	s6,16(sp)
    80004a2a:	6ba2                	ld	s7,8(sp)
    80004a2c:	6c02                	ld	s8,0(sp)
    80004a2e:	6161                	addi	sp,sp,80
    80004a30:	8082                	ret
        panic("short filewrite");
    80004a32:	00005517          	auipc	a0,0x5
    80004a36:	00650513          	addi	a0,a0,6 # 80009a38 <userret+0x9a8>
    80004a3a:	ffffc097          	auipc	ra,0xffffc
    80004a3e:	b20080e7          	jalr	-1248(ra) # 8000055a <panic>
    int i = 0;
    80004a42:	4981                	li	s3,0
    80004a44:	bfc1                	j	80004a14 <filewrite+0x11c>
    ret = (i == n ? n : -1);
    80004a46:	557d                	li	a0,-1
    80004a48:	bfc9                	j	80004a1a <filewrite+0x122>
    panic("filewrite");
    80004a4a:	00005517          	auipc	a0,0x5
    80004a4e:	ffe50513          	addi	a0,a0,-2 # 80009a48 <userret+0x9b8>
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	b08080e7          	jalr	-1272(ra) # 8000055a <panic>
    return -1;
    80004a5a:	557d                	li	a0,-1
}
    80004a5c:	8082                	ret
      return -1;
    80004a5e:	557d                	li	a0,-1
    80004a60:	bf6d                	j	80004a1a <filewrite+0x122>
    80004a62:	557d                	li	a0,-1
    80004a64:	bf5d                	j	80004a1a <filewrite+0x122>

0000000080004a66 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a66:	7179                	addi	sp,sp,-48
    80004a68:	f406                	sd	ra,40(sp)
    80004a6a:	f022                	sd	s0,32(sp)
    80004a6c:	ec26                	sd	s1,24(sp)
    80004a6e:	e84a                	sd	s2,16(sp)
    80004a70:	e44e                	sd	s3,8(sp)
    80004a72:	e052                	sd	s4,0(sp)
    80004a74:	1800                	addi	s0,sp,48
    80004a76:	84aa                	mv	s1,a0
    80004a78:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a7a:	0005b023          	sd	zero,0(a1)
    80004a7e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a82:	00000097          	auipc	ra,0x0
    80004a86:	b84080e7          	jalr	-1148(ra) # 80004606 <filealloc>
    80004a8a:	e088                	sd	a0,0(s1)
    80004a8c:	c549                	beqz	a0,80004b16 <pipealloc+0xb0>
    80004a8e:	00000097          	auipc	ra,0x0
    80004a92:	b78080e7          	jalr	-1160(ra) # 80004606 <filealloc>
    80004a96:	00aa3023          	sd	a0,0(s4)
    80004a9a:	c925                	beqz	a0,80004b0a <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	ee0080e7          	jalr	-288(ra) # 8000097c <kalloc>
    80004aa4:	892a                	mv	s2,a0
    80004aa6:	cd39                	beqz	a0,80004b04 <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80004aa8:	4985                	li	s3,1
    80004aaa:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004aae:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004ab2:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004ab6:	22052023          	sw	zero,544(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80004aba:	02000613          	li	a2,32
    80004abe:	4581                	li	a1,0
    80004ac0:	ffffc097          	auipc	ra,0xffffc
    80004ac4:	2be080e7          	jalr	702(ra) # 80000d7e <memset>
  (*f0)->type = FD_PIPE;
    80004ac8:	609c                	ld	a5,0(s1)
    80004aca:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ace:	609c                	ld	a5,0(s1)
    80004ad0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ad4:	609c                	ld	a5,0(s1)
    80004ad6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ada:	609c                	ld	a5,0(s1)
    80004adc:	0127bc23          	sd	s2,24(a5)
  (*f1)->type = FD_PIPE;
    80004ae0:	000a3783          	ld	a5,0(s4)
    80004ae4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ae8:	000a3783          	ld	a5,0(s4)
    80004aec:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004af0:	000a3783          	ld	a5,0(s4)
    80004af4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004af8:	000a3783          	ld	a5,0(s4)
    80004afc:	0127bc23          	sd	s2,24(a5)
  return 0;
    80004b00:	4501                	li	a0,0
    80004b02:	a025                	j	80004b2a <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b04:	6088                	ld	a0,0(s1)
    80004b06:	e501                	bnez	a0,80004b0e <pipealloc+0xa8>
    80004b08:	a039                	j	80004b16 <pipealloc+0xb0>
    80004b0a:	6088                	ld	a0,0(s1)
    80004b0c:	c51d                	beqz	a0,80004b3a <pipealloc+0xd4>
    fileclose(*f0);
    80004b0e:	00000097          	auipc	ra,0x0
    80004b12:	bb4080e7          	jalr	-1100(ra) # 800046c2 <fileclose>
  if(*f1)
    80004b16:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b1a:	557d                	li	a0,-1
  if(*f1)
    80004b1c:	c799                	beqz	a5,80004b2a <pipealloc+0xc4>
    fileclose(*f1);
    80004b1e:	853e                	mv	a0,a5
    80004b20:	00000097          	auipc	ra,0x0
    80004b24:	ba2080e7          	jalr	-1118(ra) # 800046c2 <fileclose>
  return -1;
    80004b28:	557d                	li	a0,-1
}
    80004b2a:	70a2                	ld	ra,40(sp)
    80004b2c:	7402                	ld	s0,32(sp)
    80004b2e:	64e2                	ld	s1,24(sp)
    80004b30:	6942                	ld	s2,16(sp)
    80004b32:	69a2                	ld	s3,8(sp)
    80004b34:	6a02                	ld	s4,0(sp)
    80004b36:	6145                	addi	sp,sp,48
    80004b38:	8082                	ret
  return -1;
    80004b3a:	557d                	li	a0,-1
    80004b3c:	b7fd                	j	80004b2a <pipealloc+0xc4>

0000000080004b3e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b3e:	1101                	addi	sp,sp,-32
    80004b40:	ec06                	sd	ra,24(sp)
    80004b42:	e822                	sd	s0,16(sp)
    80004b44:	e426                	sd	s1,8(sp)
    80004b46:	e04a                	sd	s2,0(sp)
    80004b48:	1000                	addi	s0,sp,32
    80004b4a:	84aa                	mv	s1,a0
    80004b4c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b4e:	ffffc097          	auipc	ra,0xffffc
    80004b52:	f62080e7          	jalr	-158(ra) # 80000ab0 <acquire>
  if(writable){
    80004b56:	02090d63          	beqz	s2,80004b90 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b5a:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004b5e:	22048513          	addi	a0,s1,544
    80004b62:	ffffe097          	auipc	ra,0xffffe
    80004b66:	886080e7          	jalr	-1914(ra) # 800023e8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b6a:	2284b783          	ld	a5,552(s1)
    80004b6e:	eb95                	bnez	a5,80004ba2 <pipeclose+0x64>
    release(&pi->lock);
    80004b70:	8526                	mv	a0,s1
    80004b72:	ffffc097          	auipc	ra,0xffffc
    80004b76:	00e080e7          	jalr	14(ra) # 80000b80 <release>
    kfree((char*)pi);
    80004b7a:	8526                	mv	a0,s1
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	d04080e7          	jalr	-764(ra) # 80000880 <kfree>
  } else
    release(&pi->lock);
}
    80004b84:	60e2                	ld	ra,24(sp)
    80004b86:	6442                	ld	s0,16(sp)
    80004b88:	64a2                	ld	s1,8(sp)
    80004b8a:	6902                	ld	s2,0(sp)
    80004b8c:	6105                	addi	sp,sp,32
    80004b8e:	8082                	ret
    pi->readopen = 0;
    80004b90:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004b94:	22448513          	addi	a0,s1,548
    80004b98:	ffffe097          	auipc	ra,0xffffe
    80004b9c:	850080e7          	jalr	-1968(ra) # 800023e8 <wakeup>
    80004ba0:	b7e9                	j	80004b6a <pipeclose+0x2c>
    release(&pi->lock);
    80004ba2:	8526                	mv	a0,s1
    80004ba4:	ffffc097          	auipc	ra,0xffffc
    80004ba8:	fdc080e7          	jalr	-36(ra) # 80000b80 <release>
}
    80004bac:	bfe1                	j	80004b84 <pipeclose+0x46>

0000000080004bae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bae:	7159                	addi	sp,sp,-112
    80004bb0:	f486                	sd	ra,104(sp)
    80004bb2:	f0a2                	sd	s0,96(sp)
    80004bb4:	eca6                	sd	s1,88(sp)
    80004bb6:	e8ca                	sd	s2,80(sp)
    80004bb8:	e4ce                	sd	s3,72(sp)
    80004bba:	e0d2                	sd	s4,64(sp)
    80004bbc:	fc56                	sd	s5,56(sp)
    80004bbe:	f85a                	sd	s6,48(sp)
    80004bc0:	f45e                	sd	s7,40(sp)
    80004bc2:	f062                	sd	s8,32(sp)
    80004bc4:	ec66                	sd	s9,24(sp)
    80004bc6:	1880                	addi	s0,sp,112
    80004bc8:	84aa                	mv	s1,a0
    80004bca:	8b2e                	mv	s6,a1
    80004bcc:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004bce:	ffffd097          	auipc	ra,0xffffd
    80004bd2:	ed8080e7          	jalr	-296(ra) # 80001aa6 <myproc>
    80004bd6:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    80004bd8:	8526                	mv	a0,s1
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	ed6080e7          	jalr	-298(ra) # 80000ab0 <acquire>
  for(i = 0; i < n; i++)
    80004be2:	0b505063          	blez	s5,80004c82 <pipewrite+0xd4>
    80004be6:	8926                	mv	s2,s1
    80004be8:	fffa8b9b          	addiw	s7,s5,-1
    80004bec:	1b82                	slli	s7,s7,0x20
    80004bee:	020bdb93          	srli	s7,s7,0x20
    80004bf2:	001b0793          	addi	a5,s6,1
    80004bf6:	9bbe                	add	s7,s7,a5
    {  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);  // no one to read // buffer full but what is the use!
        return -1;
      }
      wakeup(&pi->nread);
    80004bf8:	22048a13          	addi	s4,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004bfc:	22448993          	addi	s3,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c00:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE)
    80004c02:	2204a783          	lw	a5,544(s1)
    80004c06:	2244a703          	lw	a4,548(s1)
    80004c0a:	2007879b          	addiw	a5,a5,512
    80004c0e:	02f71e63          	bne	a4,a5,80004c4a <pipewrite+0x9c>
      if(pi->readopen == 0 || myproc()->killed){
    80004c12:	2284a783          	lw	a5,552(s1)
    80004c16:	c3d9                	beqz	a5,80004c9c <pipewrite+0xee>
    80004c18:	ffffd097          	auipc	ra,0xffffd
    80004c1c:	e8e080e7          	jalr	-370(ra) # 80001aa6 <myproc>
    80004c20:	5d1c                	lw	a5,56(a0)
    80004c22:	efad                	bnez	a5,80004c9c <pipewrite+0xee>
      wakeup(&pi->nread);
    80004c24:	8552                	mv	a0,s4
    80004c26:	ffffd097          	auipc	ra,0xffffd
    80004c2a:	7c2080e7          	jalr	1986(ra) # 800023e8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c2e:	85ca                	mv	a1,s2
    80004c30:	854e                	mv	a0,s3
    80004c32:	ffffd097          	auipc	ra,0xffffd
    80004c36:	630080e7          	jalr	1584(ra) # 80002262 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE)
    80004c3a:	2204a783          	lw	a5,544(s1)
    80004c3e:	2244a703          	lw	a4,548(s1)
    80004c42:	2007879b          	addiw	a5,a5,512
    80004c46:	fcf706e3          	beq	a4,a5,80004c12 <pipewrite+0x64>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c4a:	4685                	li	a3,1
    80004c4c:	865a                	mv	a2,s6
    80004c4e:	f9f40593          	addi	a1,s0,-97
    80004c52:	058c3503          	ld	a0,88(s8)
    80004c56:	ffffd097          	auipc	ra,0xffffd
    80004c5a:	bd0080e7          	jalr	-1072(ra) # 80001826 <copyin>
    80004c5e:	03950263          	beq	a0,s9,80004c82 <pipewrite+0xd4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c62:	2244a783          	lw	a5,548(s1)
    80004c66:	0017871b          	addiw	a4,a5,1
    80004c6a:	22e4a223          	sw	a4,548(s1)
    80004c6e:	1ff7f793          	andi	a5,a5,511
    80004c72:	97a6                	add	a5,a5,s1
    80004c74:	f9f44703          	lbu	a4,-97(s0)
    80004c78:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++)
    80004c7c:	0b05                	addi	s6,s6,1
    80004c7e:	f97b12e3          	bne	s6,s7,80004c02 <pipewrite+0x54>
  }
  wakeup(&pi->nread);
    80004c82:	22048513          	addi	a0,s1,544
    80004c86:	ffffd097          	auipc	ra,0xffffd
    80004c8a:	762080e7          	jalr	1890(ra) # 800023e8 <wakeup>
  release(&pi->lock);
    80004c8e:	8526                	mv	a0,s1
    80004c90:	ffffc097          	auipc	ra,0xffffc
    80004c94:	ef0080e7          	jalr	-272(ra) # 80000b80 <release>
  return n;
    80004c98:	8556                	mv	a0,s5
    80004c9a:	a039                	j	80004ca8 <pipewrite+0xfa>
        release(&pi->lock);  // no one to read // buffer full but what is the use!
    80004c9c:	8526                	mv	a0,s1
    80004c9e:	ffffc097          	auipc	ra,0xffffc
    80004ca2:	ee2080e7          	jalr	-286(ra) # 80000b80 <release>
        return -1;
    80004ca6:	557d                	li	a0,-1
}
    80004ca8:	70a6                	ld	ra,104(sp)
    80004caa:	7406                	ld	s0,96(sp)
    80004cac:	64e6                	ld	s1,88(sp)
    80004cae:	6946                	ld	s2,80(sp)
    80004cb0:	69a6                	ld	s3,72(sp)
    80004cb2:	6a06                	ld	s4,64(sp)
    80004cb4:	7ae2                	ld	s5,56(sp)
    80004cb6:	7b42                	ld	s6,48(sp)
    80004cb8:	7ba2                	ld	s7,40(sp)
    80004cba:	7c02                	ld	s8,32(sp)
    80004cbc:	6ce2                	ld	s9,24(sp)
    80004cbe:	6165                	addi	sp,sp,112
    80004cc0:	8082                	ret

0000000080004cc2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cc2:	715d                	addi	sp,sp,-80
    80004cc4:	e486                	sd	ra,72(sp)
    80004cc6:	e0a2                	sd	s0,64(sp)
    80004cc8:	fc26                	sd	s1,56(sp)
    80004cca:	f84a                	sd	s2,48(sp)
    80004ccc:	f44e                	sd	s3,40(sp)
    80004cce:	f052                	sd	s4,32(sp)
    80004cd0:	ec56                	sd	s5,24(sp)
    80004cd2:	e85a                	sd	s6,16(sp)
    80004cd4:	0880                	addi	s0,sp,80
    80004cd6:	84aa                	mv	s1,a0
    80004cd8:	892e                	mv	s2,a1
    80004cda:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004cdc:	ffffd097          	auipc	ra,0xffffd
    80004ce0:	dca080e7          	jalr	-566(ra) # 80001aa6 <myproc>
    80004ce4:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004ce6:	8b26                	mv	s6,s1
    80004ce8:	8526                	mv	a0,s1
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	dc6080e7          	jalr	-570(ra) # 80000ab0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen)
    80004cf2:	2204a703          	lw	a4,544(s1)
    80004cf6:	2244a783          	lw	a5,548(s1)
  {  //DOC: pipe-empty
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cfa:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen)
    80004cfe:	02f71763          	bne	a4,a5,80004d2c <piperead+0x6a>
    80004d02:	22c4a783          	lw	a5,556(s1)
    80004d06:	c39d                	beqz	a5,80004d2c <piperead+0x6a>
    if(myproc()->killed){
    80004d08:	ffffd097          	auipc	ra,0xffffd
    80004d0c:	d9e080e7          	jalr	-610(ra) # 80001aa6 <myproc>
    80004d10:	5d1c                	lw	a5,56(a0)
    80004d12:	ebc1                	bnez	a5,80004da2 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d14:	85da                	mv	a1,s6
    80004d16:	854e                	mv	a0,s3
    80004d18:	ffffd097          	auipc	ra,0xffffd
    80004d1c:	54a080e7          	jalr	1354(ra) # 80002262 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen)
    80004d20:	2204a703          	lw	a4,544(s1)
    80004d24:	2244a783          	lw	a5,548(s1)
    80004d28:	fcf70de3          	beq	a4,a5,80004d02 <piperead+0x40>
  }
  for(i = 0; i < n; i++)
    80004d2c:	4981                	li	s3,0
  {  //DOC: piperead-copy
    if(pi->nread == pi->nwrite) // empty // nothing to read and writeopen off
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d2e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++)
    80004d30:	05405363          	blez	s4,80004d76 <piperead+0xb4>
    if(pi->nread == pi->nwrite) // empty // nothing to read and writeopen off
    80004d34:	2204a783          	lw	a5,544(s1)
    80004d38:	2244a703          	lw	a4,548(s1)
    80004d3c:	02f70d63          	beq	a4,a5,80004d76 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d40:	0017871b          	addiw	a4,a5,1
    80004d44:	22e4a023          	sw	a4,544(s1)
    80004d48:	1ff7f793          	andi	a5,a5,511
    80004d4c:	97a6                	add	a5,a5,s1
    80004d4e:	0207c783          	lbu	a5,32(a5)
    80004d52:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d56:	4685                	li	a3,1
    80004d58:	fbf40613          	addi	a2,s0,-65
    80004d5c:	85ca                	mv	a1,s2
    80004d5e:	058ab503          	ld	a0,88(s5)
    80004d62:	ffffd097          	auipc	ra,0xffffd
    80004d66:	a38080e7          	jalr	-1480(ra) # 8000179a <copyout>
    80004d6a:	01650663          	beq	a0,s6,80004d76 <piperead+0xb4>
  for(i = 0; i < n; i++)
    80004d6e:	2985                	addiw	s3,s3,1
    80004d70:	0905                	addi	s2,s2,1
    80004d72:	fd3a11e3          	bne	s4,s3,80004d34 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d76:	22448513          	addi	a0,s1,548
    80004d7a:	ffffd097          	auipc	ra,0xffffd
    80004d7e:	66e080e7          	jalr	1646(ra) # 800023e8 <wakeup>
  release(&pi->lock);
    80004d82:	8526                	mv	a0,s1
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	dfc080e7          	jalr	-516(ra) # 80000b80 <release>
  return i;
}
    80004d8c:	854e                	mv	a0,s3
    80004d8e:	60a6                	ld	ra,72(sp)
    80004d90:	6406                	ld	s0,64(sp)
    80004d92:	74e2                	ld	s1,56(sp)
    80004d94:	7942                	ld	s2,48(sp)
    80004d96:	79a2                	ld	s3,40(sp)
    80004d98:	7a02                	ld	s4,32(sp)
    80004d9a:	6ae2                	ld	s5,24(sp)
    80004d9c:	6b42                	ld	s6,16(sp)
    80004d9e:	6161                	addi	sp,sp,80
    80004da0:	8082                	ret
      release(&pi->lock);
    80004da2:	8526                	mv	a0,s1
    80004da4:	ffffc097          	auipc	ra,0xffffc
    80004da8:	ddc080e7          	jalr	-548(ra) # 80000b80 <release>
      return -1;
    80004dac:	59fd                	li	s3,-1
    80004dae:	bff9                	j	80004d8c <piperead+0xca>

0000000080004db0 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004db0:	df010113          	addi	sp,sp,-528
    80004db4:	20113423          	sd	ra,520(sp)
    80004db8:	20813023          	sd	s0,512(sp)
    80004dbc:	ffa6                	sd	s1,504(sp)
    80004dbe:	fbca                	sd	s2,496(sp)
    80004dc0:	f7ce                	sd	s3,488(sp)
    80004dc2:	f3d2                	sd	s4,480(sp)
    80004dc4:	efd6                	sd	s5,472(sp)
    80004dc6:	ebda                	sd	s6,464(sp)
    80004dc8:	e7de                	sd	s7,456(sp)
    80004dca:	e3e2                	sd	s8,448(sp)
    80004dcc:	ff66                	sd	s9,440(sp)
    80004dce:	fb6a                	sd	s10,432(sp)
    80004dd0:	f76e                	sd	s11,424(sp)
    80004dd2:	0c00                	addi	s0,sp,528
    80004dd4:	84aa                	mv	s1,a0
    80004dd6:	dea43c23          	sd	a0,-520(s0)
    80004dda:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004dde:	ffffd097          	auipc	ra,0xffffd
    80004de2:	cc8080e7          	jalr	-824(ra) # 80001aa6 <myproc>
    80004de6:	892a                	mv	s2,a0

  begin_op(ROOTDEV);
    80004de8:	4501                	li	a0,0
    80004dea:	fffff097          	auipc	ra,0xfffff
    80004dee:	33e080e7          	jalr	830(ra) # 80004128 <begin_op>

  if((ip = namei(path)) == 0){
    80004df2:	8526                	mv	a0,s1
    80004df4:	fffff097          	auipc	ra,0xfffff
    80004df8:	0da080e7          	jalr	218(ra) # 80003ece <namei>
    80004dfc:	c935                	beqz	a0,80004e70 <exec+0xc0>
    80004dfe:	84aa                	mv	s1,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004e00:	fffff097          	auipc	ra,0xfffff
    80004e04:	944080e7          	jalr	-1724(ra) # 80003744 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e08:	04000713          	li	a4,64
    80004e0c:	4681                	li	a3,0
    80004e0e:	e4840613          	addi	a2,s0,-440
    80004e12:	4581                	li	a1,0
    80004e14:	8526                	mv	a0,s1
    80004e16:	fffff097          	auipc	ra,0xfffff
    80004e1a:	bbe080e7          	jalr	-1090(ra) # 800039d4 <readi>
    80004e1e:	04000793          	li	a5,64
    80004e22:	00f51a63          	bne	a0,a5,80004e36 <exec+0x86>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e26:	e4842703          	lw	a4,-440(s0)
    80004e2a:	464c47b7          	lui	a5,0x464c4
    80004e2e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e32:	04f70663          	beq	a4,a5,80004e7e <exec+0xce>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e36:	8526                	mv	a0,s1
    80004e38:	fffff097          	auipc	ra,0xfffff
    80004e3c:	b4a080e7          	jalr	-1206(ra) # 80003982 <iunlockput>
    end_op(ROOTDEV);
    80004e40:	4501                	li	a0,0
    80004e42:	fffff097          	auipc	ra,0xfffff
    80004e46:	390080e7          	jalr	912(ra) # 800041d2 <end_op>
  }
  return -1;
    80004e4a:	557d                	li	a0,-1
}
    80004e4c:	20813083          	ld	ra,520(sp)
    80004e50:	20013403          	ld	s0,512(sp)
    80004e54:	74fe                	ld	s1,504(sp)
    80004e56:	795e                	ld	s2,496(sp)
    80004e58:	79be                	ld	s3,488(sp)
    80004e5a:	7a1e                	ld	s4,480(sp)
    80004e5c:	6afe                	ld	s5,472(sp)
    80004e5e:	6b5e                	ld	s6,464(sp)
    80004e60:	6bbe                	ld	s7,456(sp)
    80004e62:	6c1e                	ld	s8,448(sp)
    80004e64:	7cfa                	ld	s9,440(sp)
    80004e66:	7d5a                	ld	s10,432(sp)
    80004e68:	7dba                	ld	s11,424(sp)
    80004e6a:	21010113          	addi	sp,sp,528
    80004e6e:	8082                	ret
    end_op(ROOTDEV);
    80004e70:	4501                	li	a0,0
    80004e72:	fffff097          	auipc	ra,0xfffff
    80004e76:	360080e7          	jalr	864(ra) # 800041d2 <end_op>
    return -1;
    80004e7a:	557d                	li	a0,-1
    80004e7c:	bfc1                	j	80004e4c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e7e:	854a                	mv	a0,s2
    80004e80:	ffffd097          	auipc	ra,0xffffd
    80004e84:	cea080e7          	jalr	-790(ra) # 80001b6a <proc_pagetable>
    80004e88:	8c2a                	mv	s8,a0
    80004e8a:	d555                	beqz	a0,80004e36 <exec+0x86>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e8c:	e6842983          	lw	s3,-408(s0)
    80004e90:	e8045783          	lhu	a5,-384(s0)
    80004e94:	c7fd                	beqz	a5,80004f82 <exec+0x1d2>
  sz = 0;
    80004e96:	e0043423          	sd	zero,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e9a:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    80004e9c:	6b05                	lui	s6,0x1
    80004e9e:	fffb0793          	addi	a5,s6,-1 # fff <_entry-0x7ffff001>
    80004ea2:	def43823          	sd	a5,-528(s0)
    80004ea6:	a0a5                	j	80004f0e <exec+0x15e>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ea8:	00005517          	auipc	a0,0x5
    80004eac:	bb050513          	addi	a0,a0,-1104 # 80009a58 <userret+0x9c8>
    80004eb0:	ffffb097          	auipc	ra,0xffffb
    80004eb4:	6aa080e7          	jalr	1706(ra) # 8000055a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004eb8:	8756                	mv	a4,s5
    80004eba:	012d86bb          	addw	a3,s11,s2
    80004ebe:	4581                	li	a1,0
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	fffff097          	auipc	ra,0xfffff
    80004ec6:	b12080e7          	jalr	-1262(ra) # 800039d4 <readi>
    80004eca:	2501                	sext.w	a0,a0
    80004ecc:	10aa9263          	bne	s5,a0,80004fd0 <exec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    80004ed0:	6785                	lui	a5,0x1
    80004ed2:	0127893b          	addw	s2,a5,s2
    80004ed6:	77fd                	lui	a5,0xfffff
    80004ed8:	01478a3b          	addw	s4,a5,s4
    80004edc:	03997263          	bgeu	s2,s9,80004f00 <exec+0x150>
    pa = walkaddr(pagetable, va + i);
    80004ee0:	02091593          	slli	a1,s2,0x20
    80004ee4:	9181                	srli	a1,a1,0x20
    80004ee6:	95ea                	add	a1,a1,s10
    80004ee8:	8562                	mv	a0,s8
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	2a2080e7          	jalr	674(ra) # 8000118c <walkaddr>
    80004ef2:	862a                	mv	a2,a0
    if(pa == 0)
    80004ef4:	d955                	beqz	a0,80004ea8 <exec+0xf8>
      n = PGSIZE;
    80004ef6:	8ada                	mv	s5,s6
    if(sz - i < PGSIZE)
    80004ef8:	fd6a70e3          	bgeu	s4,s6,80004eb8 <exec+0x108>
      n = sz - i;
    80004efc:	8ad2                	mv	s5,s4
    80004efe:	bf6d                	j	80004eb8 <exec+0x108>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f00:	2b85                	addiw	s7,s7,1
    80004f02:	0389899b          	addiw	s3,s3,56
    80004f06:	e8045783          	lhu	a5,-384(s0)
    80004f0a:	06fbde63          	bge	s7,a5,80004f86 <exec+0x1d6>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f0e:	2981                	sext.w	s3,s3
    80004f10:	03800713          	li	a4,56
    80004f14:	86ce                	mv	a3,s3
    80004f16:	e1040613          	addi	a2,s0,-496
    80004f1a:	4581                	li	a1,0
    80004f1c:	8526                	mv	a0,s1
    80004f1e:	fffff097          	auipc	ra,0xfffff
    80004f22:	ab6080e7          	jalr	-1354(ra) # 800039d4 <readi>
    80004f26:	03800793          	li	a5,56
    80004f2a:	0af51363          	bne	a0,a5,80004fd0 <exec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    80004f2e:	e1042783          	lw	a5,-496(s0)
    80004f32:	4705                	li	a4,1
    80004f34:	fce796e3          	bne	a5,a4,80004f00 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004f38:	e3843603          	ld	a2,-456(s0)
    80004f3c:	e3043783          	ld	a5,-464(s0)
    80004f40:	08f66863          	bltu	a2,a5,80004fd0 <exec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f44:	e2043783          	ld	a5,-480(s0)
    80004f48:	963e                	add	a2,a2,a5
    80004f4a:	08f66363          	bltu	a2,a5,80004fd0 <exec+0x220>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f4e:	e0843583          	ld	a1,-504(s0)
    80004f52:	8562                	mv	a0,s8
    80004f54:	ffffc097          	auipc	ra,0xffffc
    80004f58:	66c080e7          	jalr	1644(ra) # 800015c0 <uvmalloc>
    80004f5c:	e0a43423          	sd	a0,-504(s0)
    80004f60:	c925                	beqz	a0,80004fd0 <exec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80004f62:	e2043d03          	ld	s10,-480(s0)
    80004f66:	df043783          	ld	a5,-528(s0)
    80004f6a:	00fd77b3          	and	a5,s10,a5
    80004f6e:	e3ad                	bnez	a5,80004fd0 <exec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f70:	e1842d83          	lw	s11,-488(s0)
    80004f74:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f78:	f80c84e3          	beqz	s9,80004f00 <exec+0x150>
    80004f7c:	8a66                	mv	s4,s9
    80004f7e:	4901                	li	s2,0
    80004f80:	b785                	j	80004ee0 <exec+0x130>
  sz = 0;
    80004f82:	e0043423          	sd	zero,-504(s0)
  iunlockput(ip);
    80004f86:	8526                	mv	a0,s1
    80004f88:	fffff097          	auipc	ra,0xfffff
    80004f8c:	9fa080e7          	jalr	-1542(ra) # 80003982 <iunlockput>
  end_op(ROOTDEV);
    80004f90:	4501                	li	a0,0
    80004f92:	fffff097          	auipc	ra,0xfffff
    80004f96:	240080e7          	jalr	576(ra) # 800041d2 <end_op>
  p = myproc();
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	b0c080e7          	jalr	-1268(ra) # 80001aa6 <myproc>
    80004fa2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004fa4:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004fa8:	6585                	lui	a1,0x1
    80004faa:	15fd                	addi	a1,a1,-1
    80004fac:	e0843783          	ld	a5,-504(s0)
    80004fb0:	00b78b33          	add	s6,a5,a1
    80004fb4:	75fd                	lui	a1,0xfffff
    80004fb6:	00bb75b3          	and	a1,s6,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fba:	6609                	lui	a2,0x2
    80004fbc:	962e                	add	a2,a2,a1
    80004fbe:	8562                	mv	a0,s8
    80004fc0:	ffffc097          	auipc	ra,0xffffc
    80004fc4:	600080e7          	jalr	1536(ra) # 800015c0 <uvmalloc>
    80004fc8:	e0a43423          	sd	a0,-504(s0)
  ip = 0;
    80004fcc:	4481                	li	s1,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fce:	ed01                	bnez	a0,80004fe6 <exec+0x236>
    proc_freepagetable(pagetable, sz);
    80004fd0:	e0843583          	ld	a1,-504(s0)
    80004fd4:	8562                	mv	a0,s8
    80004fd6:	ffffd097          	auipc	ra,0xffffd
    80004fda:	c94080e7          	jalr	-876(ra) # 80001c6a <proc_freepagetable>
  if(ip){
    80004fde:	e4049ce3          	bnez	s1,80004e36 <exec+0x86>
  return -1;
    80004fe2:	557d                	li	a0,-1
    80004fe4:	b5a5                	j	80004e4c <exec+0x9c>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fe6:	75f9                	lui	a1,0xffffe
    80004fe8:	84aa                	mv	s1,a0
    80004fea:	95aa                	add	a1,a1,a0
    80004fec:	8562                	mv	a0,s8
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	77a080e7          	jalr	1914(ra) # 80001768 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ff6:	7afd                	lui	s5,0xfffff
    80004ff8:	9aa6                	add	s5,s5,s1
  for(argc = 0; argv[argc]; argc++) {
    80004ffa:	e0043783          	ld	a5,-512(s0)
    80004ffe:	6388                	ld	a0,0(a5)
    80005000:	c135                	beqz	a0,80005064 <exec+0x2b4>
    80005002:	e8840993          	addi	s3,s0,-376
    80005006:	f8840c93          	addi	s9,s0,-120
    8000500a:	4901                	li	s2,0
    sp -= strlen(argv[argc]) + 1;
    8000500c:	ffffc097          	auipc	ra,0xffffc
    80005010:	efa080e7          	jalr	-262(ra) # 80000f06 <strlen>
    80005014:	2505                	addiw	a0,a0,1
    80005016:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005018:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    8000501a:	0f54ea63          	bltu	s1,s5,8000510e <exec+0x35e>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000501e:	e0043b03          	ld	s6,-512(s0)
    80005022:	000b3a03          	ld	s4,0(s6)
    80005026:	8552                	mv	a0,s4
    80005028:	ffffc097          	auipc	ra,0xffffc
    8000502c:	ede080e7          	jalr	-290(ra) # 80000f06 <strlen>
    80005030:	0015069b          	addiw	a3,a0,1
    80005034:	8652                	mv	a2,s4
    80005036:	85a6                	mv	a1,s1
    80005038:	8562                	mv	a0,s8
    8000503a:	ffffc097          	auipc	ra,0xffffc
    8000503e:	760080e7          	jalr	1888(ra) # 8000179a <copyout>
    80005042:	0c054863          	bltz	a0,80005112 <exec+0x362>
    ustack[argc] = sp;
    80005046:	0099b023          	sd	s1,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000504a:	0905                	addi	s2,s2,1
    8000504c:	008b0793          	addi	a5,s6,8
    80005050:	e0f43023          	sd	a5,-512(s0)
    80005054:	008b3503          	ld	a0,8(s6)
    80005058:	c909                	beqz	a0,8000506a <exec+0x2ba>
    if(argc >= MAXARG)
    8000505a:	09a1                	addi	s3,s3,8
    8000505c:	fb3c98e3          	bne	s9,s3,8000500c <exec+0x25c>
  ip = 0;
    80005060:	4481                	li	s1,0
    80005062:	b7bd                	j	80004fd0 <exec+0x220>
  sp = sz;
    80005064:	e0843483          	ld	s1,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005068:	4901                	li	s2,0
  ustack[argc] = 0;
    8000506a:	00391793          	slli	a5,s2,0x3
    8000506e:	f9040713          	addi	a4,s0,-112
    80005072:	97ba                	add	a5,a5,a4
    80005074:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd5b4c>
  sp -= (argc+1) * sizeof(uint64);
    80005078:	00190693          	addi	a3,s2,1
    8000507c:	068e                	slli	a3,a3,0x3
    8000507e:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    80005080:	ff04f993          	andi	s3,s1,-16
  ip = 0;
    80005084:	4481                	li	s1,0
  if(sp < stackbase)
    80005086:	f559e5e3          	bltu	s3,s5,80004fd0 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000508a:	e8840613          	addi	a2,s0,-376
    8000508e:	85ce                	mv	a1,s3
    80005090:	8562                	mv	a0,s8
    80005092:	ffffc097          	auipc	ra,0xffffc
    80005096:	708080e7          	jalr	1800(ra) # 8000179a <copyout>
    8000509a:	06054e63          	bltz	a0,80005116 <exec+0x366>
  p->tf->a1 = sp;
    8000509e:	060bb783          	ld	a5,96(s7) # 1060 <_entry-0x7fffefa0>
    800050a2:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    800050a6:	df843783          	ld	a5,-520(s0)
    800050aa:	0007c703          	lbu	a4,0(a5)
    800050ae:	cf11                	beqz	a4,800050ca <exec+0x31a>
    800050b0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050b2:	02f00693          	li	a3,47
    800050b6:	a029                	j	800050c0 <exec+0x310>
  for(last=s=path; *s; s++)
    800050b8:	0785                	addi	a5,a5,1
    800050ba:	fff7c703          	lbu	a4,-1(a5)
    800050be:	c711                	beqz	a4,800050ca <exec+0x31a>
    if(*s == '/')
    800050c0:	fed71ce3          	bne	a4,a3,800050b8 <exec+0x308>
      last = s+1;
    800050c4:	def43c23          	sd	a5,-520(s0)
    800050c8:	bfc5                	j	800050b8 <exec+0x308>
  safestrcpy(p->name, last, sizeof(p->name));
    800050ca:	4641                	li	a2,16
    800050cc:	df843583          	ld	a1,-520(s0)
    800050d0:	160b8513          	addi	a0,s7,352
    800050d4:	ffffc097          	auipc	ra,0xffffc
    800050d8:	e00080e7          	jalr	-512(ra) # 80000ed4 <safestrcpy>
  oldpagetable = p->pagetable;
    800050dc:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    800050e0:	058bbc23          	sd	s8,88(s7)
  p->sz = sz;
    800050e4:	e0843783          	ld	a5,-504(s0)
    800050e8:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    800050ec:	060bb783          	ld	a5,96(s7)
    800050f0:	e6043703          	ld	a4,-416(s0)
    800050f4:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    800050f6:	060bb783          	ld	a5,96(s7)
    800050fa:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050fe:	85ea                	mv	a1,s10
    80005100:	ffffd097          	auipc	ra,0xffffd
    80005104:	b6a080e7          	jalr	-1174(ra) # 80001c6a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005108:	0009051b          	sext.w	a0,s2
    8000510c:	b381                	j	80004e4c <exec+0x9c>
  ip = 0;
    8000510e:	4481                	li	s1,0
    80005110:	b5c1                	j	80004fd0 <exec+0x220>
    80005112:	4481                	li	s1,0
    80005114:	bd75                	j	80004fd0 <exec+0x220>
    80005116:	4481                	li	s1,0
    80005118:	bd65                	j	80004fd0 <exec+0x220>

000000008000511a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000511a:	1101                	addi	sp,sp,-32
    8000511c:	ec06                	sd	ra,24(sp)
    8000511e:	e822                	sd	s0,16(sp)
    80005120:	e426                	sd	s1,8(sp)
    80005122:	1000                	addi	s0,sp,32
    80005124:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005126:	ffffd097          	auipc	ra,0xffffd
    8000512a:	980080e7          	jalr	-1664(ra) # 80001aa6 <myproc>
    8000512e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005130:	0d850793          	addi	a5,a0,216
    80005134:	4501                	li	a0,0
    80005136:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005138:	6398                	ld	a4,0(a5)
    8000513a:	cb19                	beqz	a4,80005150 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000513c:	2505                	addiw	a0,a0,1
    8000513e:	07a1                	addi	a5,a5,8
    80005140:	fed51ce3          	bne	a0,a3,80005138 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005144:	557d                	li	a0,-1
}
    80005146:	60e2                	ld	ra,24(sp)
    80005148:	6442                	ld	s0,16(sp)
    8000514a:	64a2                	ld	s1,8(sp)
    8000514c:	6105                	addi	sp,sp,32
    8000514e:	8082                	ret
      p->ofile[fd] = f;
    80005150:	01a50793          	addi	a5,a0,26
    80005154:	078e                	slli	a5,a5,0x3
    80005156:	963e                	add	a2,a2,a5
    80005158:	e604                	sd	s1,8(a2)
      return fd;
    8000515a:	b7f5                	j	80005146 <fdalloc+0x2c>

000000008000515c <argfd>:
{
    8000515c:	7179                	addi	sp,sp,-48
    8000515e:	f406                	sd	ra,40(sp)
    80005160:	f022                	sd	s0,32(sp)
    80005162:	ec26                	sd	s1,24(sp)
    80005164:	e84a                	sd	s2,16(sp)
    80005166:	1800                	addi	s0,sp,48
    80005168:	892e                	mv	s2,a1
    8000516a:	84b2                	mv	s1,a2
  if(argint(n, &fd) < 0)
    8000516c:	fdc40593          	addi	a1,s0,-36
    80005170:	ffffe097          	auipc	ra,0xffffe
    80005174:	a5e080e7          	jalr	-1442(ra) # 80002bce <argint>
    80005178:	04054063          	bltz	a0,800051b8 <argfd+0x5c>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000517c:	fdc42703          	lw	a4,-36(s0)
    80005180:	47bd                	li	a5,15
    80005182:	02e7ed63          	bltu	a5,a4,800051bc <argfd+0x60>
    80005186:	ffffd097          	auipc	ra,0xffffd
    8000518a:	920080e7          	jalr	-1760(ra) # 80001aa6 <myproc>
    8000518e:	fdc42703          	lw	a4,-36(s0)
    80005192:	01a70793          	addi	a5,a4,26
    80005196:	078e                	slli	a5,a5,0x3
    80005198:	953e                	add	a0,a0,a5
    8000519a:	651c                	ld	a5,8(a0)
    8000519c:	c395                	beqz	a5,800051c0 <argfd+0x64>
  if(pfd)
    8000519e:	00090463          	beqz	s2,800051a6 <argfd+0x4a>
    *pfd = fd;
    800051a2:	00e92023          	sw	a4,0(s2)
  return 0;
    800051a6:	4501                	li	a0,0
  if(pf)
    800051a8:	c091                	beqz	s1,800051ac <argfd+0x50>
    *pf = f;
    800051aa:	e09c                	sd	a5,0(s1)
}
    800051ac:	70a2                	ld	ra,40(sp)
    800051ae:	7402                	ld	s0,32(sp)
    800051b0:	64e2                	ld	s1,24(sp)
    800051b2:	6942                	ld	s2,16(sp)
    800051b4:	6145                	addi	sp,sp,48
    800051b6:	8082                	ret
    return -1;
    800051b8:	557d                	li	a0,-1
    800051ba:	bfcd                	j	800051ac <argfd+0x50>
    return -1;
    800051bc:	557d                	li	a0,-1
    800051be:	b7fd                	j	800051ac <argfd+0x50>
    800051c0:	557d                	li	a0,-1
    800051c2:	b7ed                	j	800051ac <argfd+0x50>

00000000800051c4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051c4:	715d                	addi	sp,sp,-80
    800051c6:	e486                	sd	ra,72(sp)
    800051c8:	e0a2                	sd	s0,64(sp)
    800051ca:	fc26                	sd	s1,56(sp)
    800051cc:	f84a                	sd	s2,48(sp)
    800051ce:	f44e                	sd	s3,40(sp)
    800051d0:	f052                	sd	s4,32(sp)
    800051d2:	ec56                	sd	s5,24(sp)
    800051d4:	0880                	addi	s0,sp,80
    800051d6:	89ae                	mv	s3,a1
    800051d8:	8ab2                	mv	s5,a2
    800051da:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051dc:	fb040593          	addi	a1,s0,-80
    800051e0:	fffff097          	auipc	ra,0xfffff
    800051e4:	d0c080e7          	jalr	-756(ra) # 80003eec <nameiparent>
    800051e8:	892a                	mv	s2,a0
    800051ea:	12050e63          	beqz	a0,80005326 <create+0x162>
    return 0;

  ilock(dp);
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	556080e7          	jalr	1366(ra) # 80003744 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051f6:	4601                	li	a2,0
    800051f8:	fb040593          	addi	a1,s0,-80
    800051fc:	854a                	mv	a0,s2
    800051fe:	fffff097          	auipc	ra,0xfffff
    80005202:	9fe080e7          	jalr	-1538(ra) # 80003bfc <dirlookup>
    80005206:	84aa                	mv	s1,a0
    80005208:	c921                	beqz	a0,80005258 <create+0x94>
    iunlockput(dp);
    8000520a:	854a                	mv	a0,s2
    8000520c:	ffffe097          	auipc	ra,0xffffe
    80005210:	776080e7          	jalr	1910(ra) # 80003982 <iunlockput>
    ilock(ip);
    80005214:	8526                	mv	a0,s1
    80005216:	ffffe097          	auipc	ra,0xffffe
    8000521a:	52e080e7          	jalr	1326(ra) # 80003744 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000521e:	2981                	sext.w	s3,s3
    80005220:	4789                	li	a5,2
    80005222:	02f99463          	bne	s3,a5,8000524a <create+0x86>
    80005226:	04c4d783          	lhu	a5,76(s1)
    8000522a:	37f9                	addiw	a5,a5,-2
    8000522c:	17c2                	slli	a5,a5,0x30
    8000522e:	93c1                	srli	a5,a5,0x30
    80005230:	4705                	li	a4,1
    80005232:	00f76c63          	bltu	a4,a5,8000524a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005236:	8526                	mv	a0,s1
    80005238:	60a6                	ld	ra,72(sp)
    8000523a:	6406                	ld	s0,64(sp)
    8000523c:	74e2                	ld	s1,56(sp)
    8000523e:	7942                	ld	s2,48(sp)
    80005240:	79a2                	ld	s3,40(sp)
    80005242:	7a02                	ld	s4,32(sp)
    80005244:	6ae2                	ld	s5,24(sp)
    80005246:	6161                	addi	sp,sp,80
    80005248:	8082                	ret
    iunlockput(ip);
    8000524a:	8526                	mv	a0,s1
    8000524c:	ffffe097          	auipc	ra,0xffffe
    80005250:	736080e7          	jalr	1846(ra) # 80003982 <iunlockput>
    return 0;
    80005254:	4481                	li	s1,0
    80005256:	b7c5                	j	80005236 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005258:	85ce                	mv	a1,s3
    8000525a:	00092503          	lw	a0,0(s2)
    8000525e:	ffffe097          	auipc	ra,0xffffe
    80005262:	34e080e7          	jalr	846(ra) # 800035ac <ialloc>
    80005266:	84aa                	mv	s1,a0
    80005268:	c521                	beqz	a0,800052b0 <create+0xec>
  ilock(ip);
    8000526a:	ffffe097          	auipc	ra,0xffffe
    8000526e:	4da080e7          	jalr	1242(ra) # 80003744 <ilock>
  ip->major = major;
    80005272:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    80005276:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    8000527a:	4a05                	li	s4,1
    8000527c:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    80005280:	8526                	mv	a0,s1
    80005282:	ffffe097          	auipc	ra,0xffffe
    80005286:	3f8080e7          	jalr	1016(ra) # 8000367a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000528a:	2981                	sext.w	s3,s3
    8000528c:	03498a63          	beq	s3,s4,800052c0 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005290:	40d0                	lw	a2,4(s1)
    80005292:	fb040593          	addi	a1,s0,-80
    80005296:	854a                	mv	a0,s2
    80005298:	fffff097          	auipc	ra,0xfffff
    8000529c:	b74080e7          	jalr	-1164(ra) # 80003e0c <dirlink>
    800052a0:	06054b63          	bltz	a0,80005316 <create+0x152>
  iunlockput(dp);
    800052a4:	854a                	mv	a0,s2
    800052a6:	ffffe097          	auipc	ra,0xffffe
    800052aa:	6dc080e7          	jalr	1756(ra) # 80003982 <iunlockput>
  return ip;
    800052ae:	b761                	j	80005236 <create+0x72>
    panic("create: ialloc");
    800052b0:	00004517          	auipc	a0,0x4
    800052b4:	7c850513          	addi	a0,a0,1992 # 80009a78 <userret+0x9e8>
    800052b8:	ffffb097          	auipc	ra,0xffffb
    800052bc:	2a2080e7          	jalr	674(ra) # 8000055a <panic>
    dp->nlink++;  // for ".."
    800052c0:	05295783          	lhu	a5,82(s2)
    800052c4:	2785                	addiw	a5,a5,1
    800052c6:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800052ca:	854a                	mv	a0,s2
    800052cc:	ffffe097          	auipc	ra,0xffffe
    800052d0:	3ae080e7          	jalr	942(ra) # 8000367a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052d4:	40d0                	lw	a2,4(s1)
    800052d6:	00004597          	auipc	a1,0x4
    800052da:	7b258593          	addi	a1,a1,1970 # 80009a88 <userret+0x9f8>
    800052de:	8526                	mv	a0,s1
    800052e0:	fffff097          	auipc	ra,0xfffff
    800052e4:	b2c080e7          	jalr	-1236(ra) # 80003e0c <dirlink>
    800052e8:	00054f63          	bltz	a0,80005306 <create+0x142>
    800052ec:	00492603          	lw	a2,4(s2)
    800052f0:	00004597          	auipc	a1,0x4
    800052f4:	7a058593          	addi	a1,a1,1952 # 80009a90 <userret+0xa00>
    800052f8:	8526                	mv	a0,s1
    800052fa:	fffff097          	auipc	ra,0xfffff
    800052fe:	b12080e7          	jalr	-1262(ra) # 80003e0c <dirlink>
    80005302:	f80557e3          	bgez	a0,80005290 <create+0xcc>
      panic("create dots");
    80005306:	00004517          	auipc	a0,0x4
    8000530a:	79250513          	addi	a0,a0,1938 # 80009a98 <userret+0xa08>
    8000530e:	ffffb097          	auipc	ra,0xffffb
    80005312:	24c080e7          	jalr	588(ra) # 8000055a <panic>
    panic("create: dirlink");
    80005316:	00004517          	auipc	a0,0x4
    8000531a:	79250513          	addi	a0,a0,1938 # 80009aa8 <userret+0xa18>
    8000531e:	ffffb097          	auipc	ra,0xffffb
    80005322:	23c080e7          	jalr	572(ra) # 8000055a <panic>
    return 0;
    80005326:	84aa                	mv	s1,a0
    80005328:	b739                	j	80005236 <create+0x72>

000000008000532a <sys_connect>:
{
    8000532a:	7179                	addi	sp,sp,-48
    8000532c:	f406                	sd	ra,40(sp)
    8000532e:	f022                	sd	s0,32(sp)
    80005330:	1800                	addi	s0,sp,48
  if (argint(0, (int*)&raddr) < 0 ||
    80005332:	fe440593          	addi	a1,s0,-28
    80005336:	4501                	li	a0,0
    80005338:	ffffe097          	auipc	ra,0xffffe
    8000533c:	896080e7          	jalr	-1898(ra) # 80002bce <argint>
    return -1;
    80005340:	57fd                	li	a5,-1
  if (argint(0, (int*)&raddr) < 0 ||
    80005342:	04054e63          	bltz	a0,8000539e <sys_connect+0x74>
      argint(1, (int*)&lport) < 0 ||
    80005346:	fdc40593          	addi	a1,s0,-36
    8000534a:	4505                	li	a0,1
    8000534c:	ffffe097          	auipc	ra,0xffffe
    80005350:	882080e7          	jalr	-1918(ra) # 80002bce <argint>
    return -1;
    80005354:	57fd                	li	a5,-1
  if (argint(0, (int*)&raddr) < 0 ||
    80005356:	04054463          	bltz	a0,8000539e <sys_connect+0x74>
      argint(2, (int*)&rport) < 0) {
    8000535a:	fe040593          	addi	a1,s0,-32
    8000535e:	4509                	li	a0,2
    80005360:	ffffe097          	auipc	ra,0xffffe
    80005364:	86e080e7          	jalr	-1938(ra) # 80002bce <argint>
    return -1;
    80005368:	57fd                	li	a5,-1
      argint(1, (int*)&lport) < 0 ||
    8000536a:	02054a63          	bltz	a0,8000539e <sys_connect+0x74>
  if(sockalloc(&f, raddr, lport, rport) < 0)
    8000536e:	fe045683          	lhu	a3,-32(s0)
    80005372:	fdc45603          	lhu	a2,-36(s0)
    80005376:	fe442583          	lw	a1,-28(s0)
    8000537a:	fe840513          	addi	a0,s0,-24
    8000537e:	00002097          	auipc	ra,0x2
    80005382:	d84080e7          	jalr	-636(ra) # 80007102 <sockalloc>
    return -1;
    80005386:	57fd                	li	a5,-1
  if(sockalloc(&f, raddr, lport, rport) < 0)
    80005388:	00054b63          	bltz	a0,8000539e <sys_connect+0x74>
  if((fd=fdalloc(f)) < 0){
    8000538c:	fe843503          	ld	a0,-24(s0)
    80005390:	00000097          	auipc	ra,0x0
    80005394:	d8a080e7          	jalr	-630(ra) # 8000511a <fdalloc>
  return fd;
    80005398:	87aa                	mv	a5,a0
  if((fd=fdalloc(f)) < 0){
    8000539a:	00054763          	bltz	a0,800053a8 <sys_connect+0x7e>
}
    8000539e:	853e                	mv	a0,a5
    800053a0:	70a2                	ld	ra,40(sp)
    800053a2:	7402                	ld	s0,32(sp)
    800053a4:	6145                	addi	sp,sp,48
    800053a6:	8082                	ret
    fileclose(f);
    800053a8:	fe843503          	ld	a0,-24(s0)
    800053ac:	fffff097          	auipc	ra,0xfffff
    800053b0:	316080e7          	jalr	790(ra) # 800046c2 <fileclose>
    return -1;
    800053b4:	57fd                	li	a5,-1
    800053b6:	b7e5                	j	8000539e <sys_connect+0x74>

00000000800053b8 <sys_dup>:
{
    800053b8:	7179                	addi	sp,sp,-48
    800053ba:	f406                	sd	ra,40(sp)
    800053bc:	f022                	sd	s0,32(sp)
    800053be:	ec26                	sd	s1,24(sp)
    800053c0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053c2:	fd840613          	addi	a2,s0,-40
    800053c6:	4581                	li	a1,0
    800053c8:	4501                	li	a0,0
    800053ca:	00000097          	auipc	ra,0x0
    800053ce:	d92080e7          	jalr	-622(ra) # 8000515c <argfd>
    return -1;
    800053d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053d4:	02054363          	bltz	a0,800053fa <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053d8:	fd843503          	ld	a0,-40(s0)
    800053dc:	00000097          	auipc	ra,0x0
    800053e0:	d3e080e7          	jalr	-706(ra) # 8000511a <fdalloc>
    800053e4:	84aa                	mv	s1,a0
    return -1;
    800053e6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053e8:	00054963          	bltz	a0,800053fa <sys_dup+0x42>
  filedup(f);
    800053ec:	fd843503          	ld	a0,-40(s0)
    800053f0:	fffff097          	auipc	ra,0xfffff
    800053f4:	280080e7          	jalr	640(ra) # 80004670 <filedup>
  return fd;
    800053f8:	87a6                	mv	a5,s1
}
    800053fa:	853e                	mv	a0,a5
    800053fc:	70a2                	ld	ra,40(sp)
    800053fe:	7402                	ld	s0,32(sp)
    80005400:	64e2                	ld	s1,24(sp)
    80005402:	6145                	addi	sp,sp,48
    80005404:	8082                	ret

0000000080005406 <sys_read>:
{
    80005406:	7179                	addi	sp,sp,-48
    80005408:	f406                	sd	ra,40(sp)
    8000540a:	f022                	sd	s0,32(sp)
    8000540c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000540e:	fe840613          	addi	a2,s0,-24
    80005412:	4581                	li	a1,0
    80005414:	4501                	li	a0,0
    80005416:	00000097          	auipc	ra,0x0
    8000541a:	d46080e7          	jalr	-698(ra) # 8000515c <argfd>
    return -1;
    8000541e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005420:	04054163          	bltz	a0,80005462 <sys_read+0x5c>
    80005424:	fe440593          	addi	a1,s0,-28
    80005428:	4509                	li	a0,2
    8000542a:	ffffd097          	auipc	ra,0xffffd
    8000542e:	7a4080e7          	jalr	1956(ra) # 80002bce <argint>
    return -1;
    80005432:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005434:	02054763          	bltz	a0,80005462 <sys_read+0x5c>
    80005438:	fd840593          	addi	a1,s0,-40
    8000543c:	4505                	li	a0,1
    8000543e:	ffffd097          	auipc	ra,0xffffd
    80005442:	7b2080e7          	jalr	1970(ra) # 80002bf0 <argaddr>
    return -1;
    80005446:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005448:	00054d63          	bltz	a0,80005462 <sys_read+0x5c>
  return fileread(f, p, n);
    8000544c:	fe442603          	lw	a2,-28(s0)
    80005450:	fd843583          	ld	a1,-40(s0)
    80005454:	fe843503          	ld	a0,-24(s0)
    80005458:	fffff097          	auipc	ra,0xfffff
    8000545c:	3c6080e7          	jalr	966(ra) # 8000481e <fileread>
    80005460:	87aa                	mv	a5,a0
}
    80005462:	853e                	mv	a0,a5
    80005464:	70a2                	ld	ra,40(sp)
    80005466:	7402                	ld	s0,32(sp)
    80005468:	6145                	addi	sp,sp,48
    8000546a:	8082                	ret

000000008000546c <sys_write>:
{
    8000546c:	7179                	addi	sp,sp,-48
    8000546e:	f406                	sd	ra,40(sp)
    80005470:	f022                	sd	s0,32(sp)
    80005472:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005474:	fe840613          	addi	a2,s0,-24
    80005478:	4581                	li	a1,0
    8000547a:	4501                	li	a0,0
    8000547c:	00000097          	auipc	ra,0x0
    80005480:	ce0080e7          	jalr	-800(ra) # 8000515c <argfd>
    return -1;
    80005484:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005486:	04054163          	bltz	a0,800054c8 <sys_write+0x5c>
    8000548a:	fe440593          	addi	a1,s0,-28
    8000548e:	4509                	li	a0,2
    80005490:	ffffd097          	auipc	ra,0xffffd
    80005494:	73e080e7          	jalr	1854(ra) # 80002bce <argint>
    return -1;
    80005498:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000549a:	02054763          	bltz	a0,800054c8 <sys_write+0x5c>
    8000549e:	fd840593          	addi	a1,s0,-40
    800054a2:	4505                	li	a0,1
    800054a4:	ffffd097          	auipc	ra,0xffffd
    800054a8:	74c080e7          	jalr	1868(ra) # 80002bf0 <argaddr>
    return -1;
    800054ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ae:	00054d63          	bltz	a0,800054c8 <sys_write+0x5c>
  return filewrite(f, p, n);
    800054b2:	fe442603          	lw	a2,-28(s0)
    800054b6:	fd843583          	ld	a1,-40(s0)
    800054ba:	fe843503          	ld	a0,-24(s0)
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	43a080e7          	jalr	1082(ra) # 800048f8 <filewrite>
    800054c6:	87aa                	mv	a5,a0
}
    800054c8:	853e                	mv	a0,a5
    800054ca:	70a2                	ld	ra,40(sp)
    800054cc:	7402                	ld	s0,32(sp)
    800054ce:	6145                	addi	sp,sp,48
    800054d0:	8082                	ret

00000000800054d2 <sys_close>:
{
    800054d2:	1101                	addi	sp,sp,-32
    800054d4:	ec06                	sd	ra,24(sp)
    800054d6:	e822                	sd	s0,16(sp)
    800054d8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054da:	fe040613          	addi	a2,s0,-32
    800054de:	fec40593          	addi	a1,s0,-20
    800054e2:	4501                	li	a0,0
    800054e4:	00000097          	auipc	ra,0x0
    800054e8:	c78080e7          	jalr	-904(ra) # 8000515c <argfd>
    return -1;
    800054ec:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054ee:	02054463          	bltz	a0,80005516 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054f2:	ffffc097          	auipc	ra,0xffffc
    800054f6:	5b4080e7          	jalr	1460(ra) # 80001aa6 <myproc>
    800054fa:	fec42783          	lw	a5,-20(s0)
    800054fe:	07e9                	addi	a5,a5,26
    80005500:	078e                	slli	a5,a5,0x3
    80005502:	97aa                	add	a5,a5,a0
    80005504:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005508:	fe043503          	ld	a0,-32(s0)
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	1b6080e7          	jalr	438(ra) # 800046c2 <fileclose>
  return 0;
    80005514:	4781                	li	a5,0
}
    80005516:	853e                	mv	a0,a5
    80005518:	60e2                	ld	ra,24(sp)
    8000551a:	6442                	ld	s0,16(sp)
    8000551c:	6105                	addi	sp,sp,32
    8000551e:	8082                	ret

0000000080005520 <sys_fstat>:
{
    80005520:	1101                	addi	sp,sp,-32
    80005522:	ec06                	sd	ra,24(sp)
    80005524:	e822                	sd	s0,16(sp)
    80005526:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005528:	fe840613          	addi	a2,s0,-24
    8000552c:	4581                	li	a1,0
    8000552e:	4501                	li	a0,0
    80005530:	00000097          	auipc	ra,0x0
    80005534:	c2c080e7          	jalr	-980(ra) # 8000515c <argfd>
    return -1;
    80005538:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000553a:	02054563          	bltz	a0,80005564 <sys_fstat+0x44>
    8000553e:	fe040593          	addi	a1,s0,-32
    80005542:	4505                	li	a0,1
    80005544:	ffffd097          	auipc	ra,0xffffd
    80005548:	6ac080e7          	jalr	1708(ra) # 80002bf0 <argaddr>
    return -1;
    8000554c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000554e:	00054b63          	bltz	a0,80005564 <sys_fstat+0x44>
  return filestat(f, st);
    80005552:	fe043583          	ld	a1,-32(s0)
    80005556:	fe843503          	ld	a0,-24(s0)
    8000555a:	fffff097          	auipc	ra,0xfffff
    8000555e:	252080e7          	jalr	594(ra) # 800047ac <filestat>
    80005562:	87aa                	mv	a5,a0
}
    80005564:	853e                	mv	a0,a5
    80005566:	60e2                	ld	ra,24(sp)
    80005568:	6442                	ld	s0,16(sp)
    8000556a:	6105                	addi	sp,sp,32
    8000556c:	8082                	ret

000000008000556e <sys_link>:
{
    8000556e:	7169                	addi	sp,sp,-304
    80005570:	f606                	sd	ra,296(sp)
    80005572:	f222                	sd	s0,288(sp)
    80005574:	ee26                	sd	s1,280(sp)
    80005576:	ea4a                	sd	s2,272(sp)
    80005578:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000557a:	08000613          	li	a2,128
    8000557e:	ed040593          	addi	a1,s0,-304
    80005582:	4501                	li	a0,0
    80005584:	ffffd097          	auipc	ra,0xffffd
    80005588:	68e080e7          	jalr	1678(ra) # 80002c12 <argstr>
    return -1;
    8000558c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000558e:	12054363          	bltz	a0,800056b4 <sys_link+0x146>
    80005592:	08000613          	li	a2,128
    80005596:	f5040593          	addi	a1,s0,-176
    8000559a:	4505                	li	a0,1
    8000559c:	ffffd097          	auipc	ra,0xffffd
    800055a0:	676080e7          	jalr	1654(ra) # 80002c12 <argstr>
    return -1;
    800055a4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055a6:	10054763          	bltz	a0,800056b4 <sys_link+0x146>
  begin_op(ROOTDEV);
    800055aa:	4501                	li	a0,0
    800055ac:	fffff097          	auipc	ra,0xfffff
    800055b0:	b7c080e7          	jalr	-1156(ra) # 80004128 <begin_op>
  if((ip = namei(old)) == 0){
    800055b4:	ed040513          	addi	a0,s0,-304
    800055b8:	fffff097          	auipc	ra,0xfffff
    800055bc:	916080e7          	jalr	-1770(ra) # 80003ece <namei>
    800055c0:	84aa                	mv	s1,a0
    800055c2:	c559                	beqz	a0,80005650 <sys_link+0xe2>
  ilock(ip);
    800055c4:	ffffe097          	auipc	ra,0xffffe
    800055c8:	180080e7          	jalr	384(ra) # 80003744 <ilock>
  if(ip->type == T_DIR){
    800055cc:	04c49703          	lh	a4,76(s1)
    800055d0:	4785                	li	a5,1
    800055d2:	08f70663          	beq	a4,a5,8000565e <sys_link+0xf0>
  ip->nlink++;
    800055d6:	0524d783          	lhu	a5,82(s1)
    800055da:	2785                	addiw	a5,a5,1
    800055dc:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800055e0:	8526                	mv	a0,s1
    800055e2:	ffffe097          	auipc	ra,0xffffe
    800055e6:	098080e7          	jalr	152(ra) # 8000367a <iupdate>
  iunlock(ip);
    800055ea:	8526                	mv	a0,s1
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	21a080e7          	jalr	538(ra) # 80003806 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055f4:	fd040593          	addi	a1,s0,-48
    800055f8:	f5040513          	addi	a0,s0,-176
    800055fc:	fffff097          	auipc	ra,0xfffff
    80005600:	8f0080e7          	jalr	-1808(ra) # 80003eec <nameiparent>
    80005604:	892a                	mv	s2,a0
    80005606:	cd2d                	beqz	a0,80005680 <sys_link+0x112>
  ilock(dp);
    80005608:	ffffe097          	auipc	ra,0xffffe
    8000560c:	13c080e7          	jalr	316(ra) # 80003744 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005610:	00092703          	lw	a4,0(s2)
    80005614:	409c                	lw	a5,0(s1)
    80005616:	06f71063          	bne	a4,a5,80005676 <sys_link+0x108>
    8000561a:	40d0                	lw	a2,4(s1)
    8000561c:	fd040593          	addi	a1,s0,-48
    80005620:	854a                	mv	a0,s2
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	7ea080e7          	jalr	2026(ra) # 80003e0c <dirlink>
    8000562a:	04054663          	bltz	a0,80005676 <sys_link+0x108>
  iunlockput(dp);
    8000562e:	854a                	mv	a0,s2
    80005630:	ffffe097          	auipc	ra,0xffffe
    80005634:	352080e7          	jalr	850(ra) # 80003982 <iunlockput>
  iput(ip);
    80005638:	8526                	mv	a0,s1
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	218080e7          	jalr	536(ra) # 80003852 <iput>
  end_op(ROOTDEV);
    80005642:	4501                	li	a0,0
    80005644:	fffff097          	auipc	ra,0xfffff
    80005648:	b8e080e7          	jalr	-1138(ra) # 800041d2 <end_op>
  return 0;
    8000564c:	4781                	li	a5,0
    8000564e:	a09d                	j	800056b4 <sys_link+0x146>
    end_op(ROOTDEV);
    80005650:	4501                	li	a0,0
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	b80080e7          	jalr	-1152(ra) # 800041d2 <end_op>
    return -1;
    8000565a:	57fd                	li	a5,-1
    8000565c:	a8a1                	j	800056b4 <sys_link+0x146>
    iunlockput(ip);
    8000565e:	8526                	mv	a0,s1
    80005660:	ffffe097          	auipc	ra,0xffffe
    80005664:	322080e7          	jalr	802(ra) # 80003982 <iunlockput>
    end_op(ROOTDEV);
    80005668:	4501                	li	a0,0
    8000566a:	fffff097          	auipc	ra,0xfffff
    8000566e:	b68080e7          	jalr	-1176(ra) # 800041d2 <end_op>
    return -1;
    80005672:	57fd                	li	a5,-1
    80005674:	a081                	j	800056b4 <sys_link+0x146>
    iunlockput(dp);
    80005676:	854a                	mv	a0,s2
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	30a080e7          	jalr	778(ra) # 80003982 <iunlockput>
  ilock(ip);
    80005680:	8526                	mv	a0,s1
    80005682:	ffffe097          	auipc	ra,0xffffe
    80005686:	0c2080e7          	jalr	194(ra) # 80003744 <ilock>
  ip->nlink--;
    8000568a:	0524d783          	lhu	a5,82(s1)
    8000568e:	37fd                	addiw	a5,a5,-1
    80005690:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005694:	8526                	mv	a0,s1
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	fe4080e7          	jalr	-28(ra) # 8000367a <iupdate>
  iunlockput(ip);
    8000569e:	8526                	mv	a0,s1
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	2e2080e7          	jalr	738(ra) # 80003982 <iunlockput>
  end_op(ROOTDEV);
    800056a8:	4501                	li	a0,0
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	b28080e7          	jalr	-1240(ra) # 800041d2 <end_op>
  return -1;
    800056b2:	57fd                	li	a5,-1
}
    800056b4:	853e                	mv	a0,a5
    800056b6:	70b2                	ld	ra,296(sp)
    800056b8:	7412                	ld	s0,288(sp)
    800056ba:	64f2                	ld	s1,280(sp)
    800056bc:	6952                	ld	s2,272(sp)
    800056be:	6155                	addi	sp,sp,304
    800056c0:	8082                	ret

00000000800056c2 <sys_unlink>:
{
    800056c2:	7151                	addi	sp,sp,-240
    800056c4:	f586                	sd	ra,232(sp)
    800056c6:	f1a2                	sd	s0,224(sp)
    800056c8:	eda6                	sd	s1,216(sp)
    800056ca:	e9ca                	sd	s2,208(sp)
    800056cc:	e5ce                	sd	s3,200(sp)
    800056ce:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056d0:	08000613          	li	a2,128
    800056d4:	f3040593          	addi	a1,s0,-208
    800056d8:	4501                	li	a0,0
    800056da:	ffffd097          	auipc	ra,0xffffd
    800056de:	538080e7          	jalr	1336(ra) # 80002c12 <argstr>
    800056e2:	18054463          	bltz	a0,8000586a <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800056e6:	4501                	li	a0,0
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	a40080e7          	jalr	-1472(ra) # 80004128 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056f0:	fb040593          	addi	a1,s0,-80
    800056f4:	f3040513          	addi	a0,s0,-208
    800056f8:	ffffe097          	auipc	ra,0xffffe
    800056fc:	7f4080e7          	jalr	2036(ra) # 80003eec <nameiparent>
    80005700:	84aa                	mv	s1,a0
    80005702:	cd61                	beqz	a0,800057da <sys_unlink+0x118>
  ilock(dp);
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	040080e7          	jalr	64(ra) # 80003744 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000570c:	00004597          	auipc	a1,0x4
    80005710:	37c58593          	addi	a1,a1,892 # 80009a88 <userret+0x9f8>
    80005714:	fb040513          	addi	a0,s0,-80
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	4ca080e7          	jalr	1226(ra) # 80003be2 <namecmp>
    80005720:	14050c63          	beqz	a0,80005878 <sys_unlink+0x1b6>
    80005724:	00004597          	auipc	a1,0x4
    80005728:	36c58593          	addi	a1,a1,876 # 80009a90 <userret+0xa00>
    8000572c:	fb040513          	addi	a0,s0,-80
    80005730:	ffffe097          	auipc	ra,0xffffe
    80005734:	4b2080e7          	jalr	1202(ra) # 80003be2 <namecmp>
    80005738:	14050063          	beqz	a0,80005878 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000573c:	f2c40613          	addi	a2,s0,-212
    80005740:	fb040593          	addi	a1,s0,-80
    80005744:	8526                	mv	a0,s1
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	4b6080e7          	jalr	1206(ra) # 80003bfc <dirlookup>
    8000574e:	892a                	mv	s2,a0
    80005750:	12050463          	beqz	a0,80005878 <sys_unlink+0x1b6>
  ilock(ip);
    80005754:	ffffe097          	auipc	ra,0xffffe
    80005758:	ff0080e7          	jalr	-16(ra) # 80003744 <ilock>
  if(ip->nlink < 1)
    8000575c:	05291783          	lh	a5,82(s2)
    80005760:	08f05463          	blez	a5,800057e8 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005764:	04c91703          	lh	a4,76(s2)
    80005768:	4785                	li	a5,1
    8000576a:	08f70763          	beq	a4,a5,800057f8 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    8000576e:	4641                	li	a2,16
    80005770:	4581                	li	a1,0
    80005772:	fc040513          	addi	a0,s0,-64
    80005776:	ffffb097          	auipc	ra,0xffffb
    8000577a:	608080e7          	jalr	1544(ra) # 80000d7e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000577e:	4741                	li	a4,16
    80005780:	f2c42683          	lw	a3,-212(s0)
    80005784:	fc040613          	addi	a2,s0,-64
    80005788:	4581                	li	a1,0
    8000578a:	8526                	mv	a0,s1
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	33c080e7          	jalr	828(ra) # 80003ac8 <writei>
    80005794:	47c1                	li	a5,16
    80005796:	0af51763          	bne	a0,a5,80005844 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    8000579a:	04c91703          	lh	a4,76(s2)
    8000579e:	4785                	li	a5,1
    800057a0:	0af70a63          	beq	a4,a5,80005854 <sys_unlink+0x192>
  iunlockput(dp);
    800057a4:	8526                	mv	a0,s1
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	1dc080e7          	jalr	476(ra) # 80003982 <iunlockput>
  ip->nlink--;
    800057ae:	05295783          	lhu	a5,82(s2)
    800057b2:	37fd                	addiw	a5,a5,-1
    800057b4:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    800057b8:	854a                	mv	a0,s2
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	ec0080e7          	jalr	-320(ra) # 8000367a <iupdate>
  iunlockput(ip);
    800057c2:	854a                	mv	a0,s2
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	1be080e7          	jalr	446(ra) # 80003982 <iunlockput>
  end_op(ROOTDEV);
    800057cc:	4501                	li	a0,0
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	a04080e7          	jalr	-1532(ra) # 800041d2 <end_op>
  return 0;
    800057d6:	4501                	li	a0,0
    800057d8:	a85d                	j	8000588e <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800057da:	4501                	li	a0,0
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	9f6080e7          	jalr	-1546(ra) # 800041d2 <end_op>
    return -1;
    800057e4:	557d                	li	a0,-1
    800057e6:	a065                	j	8000588e <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800057e8:	00004517          	auipc	a0,0x4
    800057ec:	2d050513          	addi	a0,a0,720 # 80009ab8 <userret+0xa28>
    800057f0:	ffffb097          	auipc	ra,0xffffb
    800057f4:	d6a080e7          	jalr	-662(ra) # 8000055a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057f8:	05492703          	lw	a4,84(s2)
    800057fc:	02000793          	li	a5,32
    80005800:	f6e7f7e3          	bgeu	a5,a4,8000576e <sys_unlink+0xac>
    80005804:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005808:	4741                	li	a4,16
    8000580a:	86ce                	mv	a3,s3
    8000580c:	f1840613          	addi	a2,s0,-232
    80005810:	4581                	li	a1,0
    80005812:	854a                	mv	a0,s2
    80005814:	ffffe097          	auipc	ra,0xffffe
    80005818:	1c0080e7          	jalr	448(ra) # 800039d4 <readi>
    8000581c:	47c1                	li	a5,16
    8000581e:	00f51b63          	bne	a0,a5,80005834 <sys_unlink+0x172>
    if(de.inum != 0)
    80005822:	f1845783          	lhu	a5,-232(s0)
    80005826:	e7a1                	bnez	a5,8000586e <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005828:	29c1                	addiw	s3,s3,16
    8000582a:	05492783          	lw	a5,84(s2)
    8000582e:	fcf9ede3          	bltu	s3,a5,80005808 <sys_unlink+0x146>
    80005832:	bf35                	j	8000576e <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005834:	00004517          	auipc	a0,0x4
    80005838:	29c50513          	addi	a0,a0,668 # 80009ad0 <userret+0xa40>
    8000583c:	ffffb097          	auipc	ra,0xffffb
    80005840:	d1e080e7          	jalr	-738(ra) # 8000055a <panic>
    panic("unlink: writei");
    80005844:	00004517          	auipc	a0,0x4
    80005848:	2a450513          	addi	a0,a0,676 # 80009ae8 <userret+0xa58>
    8000584c:	ffffb097          	auipc	ra,0xffffb
    80005850:	d0e080e7          	jalr	-754(ra) # 8000055a <panic>
    dp->nlink--;
    80005854:	0524d783          	lhu	a5,82(s1)
    80005858:	37fd                	addiw	a5,a5,-1
    8000585a:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    8000585e:	8526                	mv	a0,s1
    80005860:	ffffe097          	auipc	ra,0xffffe
    80005864:	e1a080e7          	jalr	-486(ra) # 8000367a <iupdate>
    80005868:	bf35                	j	800057a4 <sys_unlink+0xe2>
    return -1;
    8000586a:	557d                	li	a0,-1
    8000586c:	a00d                	j	8000588e <sys_unlink+0x1cc>
    iunlockput(ip);
    8000586e:	854a                	mv	a0,s2
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	112080e7          	jalr	274(ra) # 80003982 <iunlockput>
  iunlockput(dp);
    80005878:	8526                	mv	a0,s1
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	108080e7          	jalr	264(ra) # 80003982 <iunlockput>
  end_op(ROOTDEV);
    80005882:	4501                	li	a0,0
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	94e080e7          	jalr	-1714(ra) # 800041d2 <end_op>
  return -1;
    8000588c:	557d                	li	a0,-1
}
    8000588e:	70ae                	ld	ra,232(sp)
    80005890:	740e                	ld	s0,224(sp)
    80005892:	64ee                	ld	s1,216(sp)
    80005894:	694e                	ld	s2,208(sp)
    80005896:	69ae                	ld	s3,200(sp)
    80005898:	616d                	addi	sp,sp,240
    8000589a:	8082                	ret

000000008000589c <sys_open>:

uint64
sys_open(void)
{
    8000589c:	7131                	addi	sp,sp,-192
    8000589e:	fd06                	sd	ra,184(sp)
    800058a0:	f922                	sd	s0,176(sp)
    800058a2:	f526                	sd	s1,168(sp)
    800058a4:	f14a                	sd	s2,160(sp)
    800058a6:	ed4e                	sd	s3,152(sp)
    800058a8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058aa:	08000613          	li	a2,128
    800058ae:	f5040593          	addi	a1,s0,-176
    800058b2:	4501                	li	a0,0
    800058b4:	ffffd097          	auipc	ra,0xffffd
    800058b8:	35e080e7          	jalr	862(ra) # 80002c12 <argstr>
    return -1;
    800058bc:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058be:	0a054963          	bltz	a0,80005970 <sys_open+0xd4>
    800058c2:	f4c40593          	addi	a1,s0,-180
    800058c6:	4505                	li	a0,1
    800058c8:	ffffd097          	auipc	ra,0xffffd
    800058cc:	306080e7          	jalr	774(ra) # 80002bce <argint>
    800058d0:	0a054063          	bltz	a0,80005970 <sys_open+0xd4>

  begin_op(ROOTDEV);
    800058d4:	4501                	li	a0,0
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	852080e7          	jalr	-1966(ra) # 80004128 <begin_op>

  if(omode & O_CREATE){
    800058de:	f4c42783          	lw	a5,-180(s0)
    800058e2:	2007f793          	andi	a5,a5,512
    800058e6:	c3dd                	beqz	a5,8000598c <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    800058e8:	4681                	li	a3,0
    800058ea:	4601                	li	a2,0
    800058ec:	4589                	li	a1,2
    800058ee:	f5040513          	addi	a0,s0,-176
    800058f2:	00000097          	auipc	ra,0x0
    800058f6:	8d2080e7          	jalr	-1838(ra) # 800051c4 <create>
    800058fa:	892a                	mv	s2,a0
    if(ip == 0){
    800058fc:	c151                	beqz	a0,80005980 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058fe:	04c91703          	lh	a4,76(s2)
    80005902:	478d                	li	a5,3
    80005904:	00f71763          	bne	a4,a5,80005912 <sys_open+0x76>
    80005908:	04e95703          	lhu	a4,78(s2)
    8000590c:	47a5                	li	a5,9
    8000590e:	0ce7e663          	bltu	a5,a4,800059da <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	cf4080e7          	jalr	-780(ra) # 80004606 <filealloc>
    8000591a:	89aa                	mv	s3,a0
    8000591c:	c97d                	beqz	a0,80005a12 <sys_open+0x176>
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	7fc080e7          	jalr	2044(ra) # 8000511a <fdalloc>
    80005926:	84aa                	mv	s1,a0
    80005928:	0e054063          	bltz	a0,80005a08 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000592c:	04c91703          	lh	a4,76(s2)
    80005930:	478d                	li	a5,3
    80005932:	0cf70063          	beq	a4,a5,800059f2 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005936:	4789                	li	a5,2
    80005938:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    8000593c:	0329b023          	sd	s2,32(s3)
  f->off = 0;
    80005940:	0209a823          	sw	zero,48(s3)
  f->readable = !(omode & O_WRONLY);
    80005944:	f4c42783          	lw	a5,-180(s0)
    80005948:	0017c713          	xori	a4,a5,1
    8000594c:	8b05                	andi	a4,a4,1
    8000594e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005952:	8b8d                	andi	a5,a5,3
    80005954:	00f037b3          	snez	a5,a5
    80005958:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    8000595c:	854a                	mv	a0,s2
    8000595e:	ffffe097          	auipc	ra,0xffffe
    80005962:	ea8080e7          	jalr	-344(ra) # 80003806 <iunlock>
  end_op(ROOTDEV);
    80005966:	4501                	li	a0,0
    80005968:	fffff097          	auipc	ra,0xfffff
    8000596c:	86a080e7          	jalr	-1942(ra) # 800041d2 <end_op>

  return fd;
}
    80005970:	8526                	mv	a0,s1
    80005972:	70ea                	ld	ra,184(sp)
    80005974:	744a                	ld	s0,176(sp)
    80005976:	74aa                	ld	s1,168(sp)
    80005978:	790a                	ld	s2,160(sp)
    8000597a:	69ea                	ld	s3,152(sp)
    8000597c:	6129                	addi	sp,sp,192
    8000597e:	8082                	ret
      end_op(ROOTDEV);
    80005980:	4501                	li	a0,0
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	850080e7          	jalr	-1968(ra) # 800041d2 <end_op>
      return -1;
    8000598a:	b7dd                	j	80005970 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    8000598c:	f5040513          	addi	a0,s0,-176
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	53e080e7          	jalr	1342(ra) # 80003ece <namei>
    80005998:	892a                	mv	s2,a0
    8000599a:	c90d                	beqz	a0,800059cc <sys_open+0x130>
    ilock(ip);
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	da8080e7          	jalr	-600(ra) # 80003744 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059a4:	04c91703          	lh	a4,76(s2)
    800059a8:	4785                	li	a5,1
    800059aa:	f4f71ae3          	bne	a4,a5,800058fe <sys_open+0x62>
    800059ae:	f4c42783          	lw	a5,-180(s0)
    800059b2:	d3a5                	beqz	a5,80005912 <sys_open+0x76>
      iunlockput(ip);
    800059b4:	854a                	mv	a0,s2
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	fcc080e7          	jalr	-52(ra) # 80003982 <iunlockput>
      end_op(ROOTDEV);
    800059be:	4501                	li	a0,0
    800059c0:	fffff097          	auipc	ra,0xfffff
    800059c4:	812080e7          	jalr	-2030(ra) # 800041d2 <end_op>
      return -1;
    800059c8:	54fd                	li	s1,-1
    800059ca:	b75d                	j	80005970 <sys_open+0xd4>
      end_op(ROOTDEV);
    800059cc:	4501                	li	a0,0
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	804080e7          	jalr	-2044(ra) # 800041d2 <end_op>
      return -1;
    800059d6:	54fd                	li	s1,-1
    800059d8:	bf61                	j	80005970 <sys_open+0xd4>
    iunlockput(ip);
    800059da:	854a                	mv	a0,s2
    800059dc:	ffffe097          	auipc	ra,0xffffe
    800059e0:	fa6080e7          	jalr	-90(ra) # 80003982 <iunlockput>
    end_op(ROOTDEV);
    800059e4:	4501                	li	a0,0
    800059e6:	ffffe097          	auipc	ra,0xffffe
    800059ea:	7ec080e7          	jalr	2028(ra) # 800041d2 <end_op>
    return -1;
    800059ee:	54fd                	li	s1,-1
    800059f0:	b741                	j	80005970 <sys_open+0xd4>
    f->type = FD_DEVICE;
    800059f2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059f6:	04e91783          	lh	a5,78(s2)
    800059fa:	02f99a23          	sh	a5,52(s3)
    f->minor = ip->minor;
    800059fe:	05091783          	lh	a5,80(s2)
    80005a02:	02f99b23          	sh	a5,54(s3)
    80005a06:	bf1d                	j	8000593c <sys_open+0xa0>
      fileclose(f);
    80005a08:	854e                	mv	a0,s3
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	cb8080e7          	jalr	-840(ra) # 800046c2 <fileclose>
    iunlockput(ip);
    80005a12:	854a                	mv	a0,s2
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	f6e080e7          	jalr	-146(ra) # 80003982 <iunlockput>
    end_op(ROOTDEV);
    80005a1c:	4501                	li	a0,0
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	7b4080e7          	jalr	1972(ra) # 800041d2 <end_op>
    return -1;
    80005a26:	54fd                	li	s1,-1
    80005a28:	b7a1                	j	80005970 <sys_open+0xd4>

0000000080005a2a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a2a:	7175                	addi	sp,sp,-144
    80005a2c:	e506                	sd	ra,136(sp)
    80005a2e:	e122                	sd	s0,128(sp)
    80005a30:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005a32:	4501                	li	a0,0
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	6f4080e7          	jalr	1780(ra) # 80004128 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a3c:	08000613          	li	a2,128
    80005a40:	f7040593          	addi	a1,s0,-144
    80005a44:	4501                	li	a0,0
    80005a46:	ffffd097          	auipc	ra,0xffffd
    80005a4a:	1cc080e7          	jalr	460(ra) # 80002c12 <argstr>
    80005a4e:	02054a63          	bltz	a0,80005a82 <sys_mkdir+0x58>
    80005a52:	4681                	li	a3,0
    80005a54:	4601                	li	a2,0
    80005a56:	4585                	li	a1,1
    80005a58:	f7040513          	addi	a0,s0,-144
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	768080e7          	jalr	1896(ra) # 800051c4 <create>
    80005a64:	cd19                	beqz	a0,80005a82 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	f1c080e7          	jalr	-228(ra) # 80003982 <iunlockput>
  end_op(ROOTDEV);
    80005a6e:	4501                	li	a0,0
    80005a70:	ffffe097          	auipc	ra,0xffffe
    80005a74:	762080e7          	jalr	1890(ra) # 800041d2 <end_op>
  return 0;
    80005a78:	4501                	li	a0,0
}
    80005a7a:	60aa                	ld	ra,136(sp)
    80005a7c:	640a                	ld	s0,128(sp)
    80005a7e:	6149                	addi	sp,sp,144
    80005a80:	8082                	ret
    end_op(ROOTDEV);
    80005a82:	4501                	li	a0,0
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	74e080e7          	jalr	1870(ra) # 800041d2 <end_op>
    return -1;
    80005a8c:	557d                	li	a0,-1
    80005a8e:	b7f5                	j	80005a7a <sys_mkdir+0x50>

0000000080005a90 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a90:	7135                	addi	sp,sp,-160
    80005a92:	ed06                	sd	ra,152(sp)
    80005a94:	e922                	sd	s0,144(sp)
    80005a96:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005a98:	4501                	li	a0,0
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	68e080e7          	jalr	1678(ra) # 80004128 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aa2:	08000613          	li	a2,128
    80005aa6:	f7040593          	addi	a1,s0,-144
    80005aaa:	4501                	li	a0,0
    80005aac:	ffffd097          	auipc	ra,0xffffd
    80005ab0:	166080e7          	jalr	358(ra) # 80002c12 <argstr>
    80005ab4:	04054b63          	bltz	a0,80005b0a <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005ab8:	f6c40593          	addi	a1,s0,-148
    80005abc:	4505                	li	a0,1
    80005abe:	ffffd097          	auipc	ra,0xffffd
    80005ac2:	110080e7          	jalr	272(ra) # 80002bce <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ac6:	04054263          	bltz	a0,80005b0a <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005aca:	f6840593          	addi	a1,s0,-152
    80005ace:	4509                	li	a0,2
    80005ad0:	ffffd097          	auipc	ra,0xffffd
    80005ad4:	0fe080e7          	jalr	254(ra) # 80002bce <argint>
     argint(1, &major) < 0 ||
    80005ad8:	02054963          	bltz	a0,80005b0a <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005adc:	f6841683          	lh	a3,-152(s0)
    80005ae0:	f6c41603          	lh	a2,-148(s0)
    80005ae4:	458d                	li	a1,3
    80005ae6:	f7040513          	addi	a0,s0,-144
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	6da080e7          	jalr	1754(ra) # 800051c4 <create>
     argint(2, &minor) < 0 ||
    80005af2:	cd01                	beqz	a0,80005b0a <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	e8e080e7          	jalr	-370(ra) # 80003982 <iunlockput>
  end_op(ROOTDEV);
    80005afc:	4501                	li	a0,0
    80005afe:	ffffe097          	auipc	ra,0xffffe
    80005b02:	6d4080e7          	jalr	1748(ra) # 800041d2 <end_op>
  return 0;
    80005b06:	4501                	li	a0,0
    80005b08:	a039                	j	80005b16 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005b0a:	4501                	li	a0,0
    80005b0c:	ffffe097          	auipc	ra,0xffffe
    80005b10:	6c6080e7          	jalr	1734(ra) # 800041d2 <end_op>
    return -1;
    80005b14:	557d                	li	a0,-1
}
    80005b16:	60ea                	ld	ra,152(sp)
    80005b18:	644a                	ld	s0,144(sp)
    80005b1a:	610d                	addi	sp,sp,160
    80005b1c:	8082                	ret

0000000080005b1e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b1e:	7135                	addi	sp,sp,-160
    80005b20:	ed06                	sd	ra,152(sp)
    80005b22:	e922                	sd	s0,144(sp)
    80005b24:	e526                	sd	s1,136(sp)
    80005b26:	e14a                	sd	s2,128(sp)
    80005b28:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b2a:	ffffc097          	auipc	ra,0xffffc
    80005b2e:	f7c080e7          	jalr	-132(ra) # 80001aa6 <myproc>
    80005b32:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005b34:	4501                	li	a0,0
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	5f2080e7          	jalr	1522(ra) # 80004128 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b3e:	08000613          	li	a2,128
    80005b42:	f6040593          	addi	a1,s0,-160
    80005b46:	4501                	li	a0,0
    80005b48:	ffffd097          	auipc	ra,0xffffd
    80005b4c:	0ca080e7          	jalr	202(ra) # 80002c12 <argstr>
    80005b50:	04054c63          	bltz	a0,80005ba8 <sys_chdir+0x8a>
    80005b54:	f6040513          	addi	a0,s0,-160
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	376080e7          	jalr	886(ra) # 80003ece <namei>
    80005b60:	84aa                	mv	s1,a0
    80005b62:	c139                	beqz	a0,80005ba8 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	be0080e7          	jalr	-1056(ra) # 80003744 <ilock>
  if(ip->type != T_DIR){
    80005b6c:	04c49703          	lh	a4,76(s1)
    80005b70:	4785                	li	a5,1
    80005b72:	04f71263          	bne	a4,a5,80005bb6 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005b76:	8526                	mv	a0,s1
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	c8e080e7          	jalr	-882(ra) # 80003806 <iunlock>
  iput(p->cwd);
    80005b80:	15893503          	ld	a0,344(s2)
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	cce080e7          	jalr	-818(ra) # 80003852 <iput>
  end_op(ROOTDEV);
    80005b8c:	4501                	li	a0,0
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	644080e7          	jalr	1604(ra) # 800041d2 <end_op>
  p->cwd = ip;
    80005b96:	14993c23          	sd	s1,344(s2)
  return 0;
    80005b9a:	4501                	li	a0,0
}
    80005b9c:	60ea                	ld	ra,152(sp)
    80005b9e:	644a                	ld	s0,144(sp)
    80005ba0:	64aa                	ld	s1,136(sp)
    80005ba2:	690a                	ld	s2,128(sp)
    80005ba4:	610d                	addi	sp,sp,160
    80005ba6:	8082                	ret
    end_op(ROOTDEV);
    80005ba8:	4501                	li	a0,0
    80005baa:	ffffe097          	auipc	ra,0xffffe
    80005bae:	628080e7          	jalr	1576(ra) # 800041d2 <end_op>
    return -1;
    80005bb2:	557d                	li	a0,-1
    80005bb4:	b7e5                	j	80005b9c <sys_chdir+0x7e>
    iunlockput(ip);
    80005bb6:	8526                	mv	a0,s1
    80005bb8:	ffffe097          	auipc	ra,0xffffe
    80005bbc:	dca080e7          	jalr	-566(ra) # 80003982 <iunlockput>
    end_op(ROOTDEV);
    80005bc0:	4501                	li	a0,0
    80005bc2:	ffffe097          	auipc	ra,0xffffe
    80005bc6:	610080e7          	jalr	1552(ra) # 800041d2 <end_op>
    return -1;
    80005bca:	557d                	li	a0,-1
    80005bcc:	bfc1                	j	80005b9c <sys_chdir+0x7e>

0000000080005bce <sys_exec>:

uint64
sys_exec(void)
{
    80005bce:	7145                	addi	sp,sp,-464
    80005bd0:	e786                	sd	ra,456(sp)
    80005bd2:	e3a2                	sd	s0,448(sp)
    80005bd4:	ff26                	sd	s1,440(sp)
    80005bd6:	fb4a                	sd	s2,432(sp)
    80005bd8:	f74e                	sd	s3,424(sp)
    80005bda:	f352                	sd	s4,416(sp)
    80005bdc:	ef56                	sd	s5,408(sp)
    80005bde:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005be0:	08000613          	li	a2,128
    80005be4:	f4040593          	addi	a1,s0,-192
    80005be8:	4501                	li	a0,0
    80005bea:	ffffd097          	auipc	ra,0xffffd
    80005bee:	028080e7          	jalr	40(ra) # 80002c12 <argstr>
    80005bf2:	0e054663          	bltz	a0,80005cde <sys_exec+0x110>
    80005bf6:	e3840593          	addi	a1,s0,-456
    80005bfa:	4505                	li	a0,1
    80005bfc:	ffffd097          	auipc	ra,0xffffd
    80005c00:	ff4080e7          	jalr	-12(ra) # 80002bf0 <argaddr>
    80005c04:	0e054763          	bltz	a0,80005cf2 <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005c08:	10000613          	li	a2,256
    80005c0c:	4581                	li	a1,0
    80005c0e:	e4040513          	addi	a0,s0,-448
    80005c12:	ffffb097          	auipc	ra,0xffffb
    80005c16:	16c080e7          	jalr	364(ra) # 80000d7e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c1a:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c1e:	89ca                	mv	s3,s2
    80005c20:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005c22:	02000a13          	li	s4,32
    80005c26:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c2a:	00349513          	slli	a0,s1,0x3
    80005c2e:	e3040593          	addi	a1,s0,-464
    80005c32:	e3843783          	ld	a5,-456(s0)
    80005c36:	953e                	add	a0,a0,a5
    80005c38:	ffffd097          	auipc	ra,0xffffd
    80005c3c:	efc080e7          	jalr	-260(ra) # 80002b34 <fetchaddr>
    80005c40:	02054a63          	bltz	a0,80005c74 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c44:	e3043783          	ld	a5,-464(s0)
    80005c48:	c7a1                	beqz	a5,80005c90 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c4a:	ffffb097          	auipc	ra,0xffffb
    80005c4e:	d32080e7          	jalr	-718(ra) # 8000097c <kalloc>
    80005c52:	85aa                	mv	a1,a0
    80005c54:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c58:	c92d                	beqz	a0,80005cca <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005c5a:	6605                	lui	a2,0x1
    80005c5c:	e3043503          	ld	a0,-464(s0)
    80005c60:	ffffd097          	auipc	ra,0xffffd
    80005c64:	f26080e7          	jalr	-218(ra) # 80002b86 <fetchstr>
    80005c68:	00054663          	bltz	a0,80005c74 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c6c:	0485                	addi	s1,s1,1
    80005c6e:	09a1                	addi	s3,s3,8
    80005c70:	fb449be3          	bne	s1,s4,80005c26 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c74:	10090493          	addi	s1,s2,256
    80005c78:	00093503          	ld	a0,0(s2)
    80005c7c:	cd39                	beqz	a0,80005cda <sys_exec+0x10c>
    kfree(argv[i]);
    80005c7e:	ffffb097          	auipc	ra,0xffffb
    80005c82:	c02080e7          	jalr	-1022(ra) # 80000880 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c86:	0921                	addi	s2,s2,8
    80005c88:	fe9918e3          	bne	s2,s1,80005c78 <sys_exec+0xaa>
  return -1;
    80005c8c:	557d                	li	a0,-1
    80005c8e:	a889                	j	80005ce0 <sys_exec+0x112>
      argv[i] = 0;
    80005c90:	0a8e                	slli	s5,s5,0x3
    80005c92:	fc040793          	addi	a5,s0,-64
    80005c96:	9abe                	add	s5,s5,a5
    80005c98:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd5ad4>
  int ret = exec(path, argv);
    80005c9c:	e4040593          	addi	a1,s0,-448
    80005ca0:	f4040513          	addi	a0,s0,-192
    80005ca4:	fffff097          	auipc	ra,0xfffff
    80005ca8:	10c080e7          	jalr	268(ra) # 80004db0 <exec>
    80005cac:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cae:	10090993          	addi	s3,s2,256
    80005cb2:	00093503          	ld	a0,0(s2)
    80005cb6:	c901                	beqz	a0,80005cc6 <sys_exec+0xf8>
    kfree(argv[i]);
    80005cb8:	ffffb097          	auipc	ra,0xffffb
    80005cbc:	bc8080e7          	jalr	-1080(ra) # 80000880 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc0:	0921                	addi	s2,s2,8
    80005cc2:	ff3918e3          	bne	s2,s3,80005cb2 <sys_exec+0xe4>
  return ret;
    80005cc6:	8526                	mv	a0,s1
    80005cc8:	a821                	j	80005ce0 <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005cca:	00004517          	auipc	a0,0x4
    80005cce:	e2e50513          	addi	a0,a0,-466 # 80009af8 <userret+0xa68>
    80005cd2:	ffffb097          	auipc	ra,0xffffb
    80005cd6:	888080e7          	jalr	-1912(ra) # 8000055a <panic>
  return -1;
    80005cda:	557d                	li	a0,-1
    80005cdc:	a011                	j	80005ce0 <sys_exec+0x112>
    return -1;
    80005cde:	557d                	li	a0,-1
}
    80005ce0:	60be                	ld	ra,456(sp)
    80005ce2:	641e                	ld	s0,448(sp)
    80005ce4:	74fa                	ld	s1,440(sp)
    80005ce6:	795a                	ld	s2,432(sp)
    80005ce8:	79ba                	ld	s3,424(sp)
    80005cea:	7a1a                	ld	s4,416(sp)
    80005cec:	6afa                	ld	s5,408(sp)
    80005cee:	6179                	addi	sp,sp,464
    80005cf0:	8082                	ret
    return -1;
    80005cf2:	557d                	li	a0,-1
    80005cf4:	b7f5                	j	80005ce0 <sys_exec+0x112>

0000000080005cf6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cf6:	7139                	addi	sp,sp,-64
    80005cf8:	fc06                	sd	ra,56(sp)
    80005cfa:	f822                	sd	s0,48(sp)
    80005cfc:	f426                	sd	s1,40(sp)
    80005cfe:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d00:	ffffc097          	auipc	ra,0xffffc
    80005d04:	da6080e7          	jalr	-602(ra) # 80001aa6 <myproc>
    80005d08:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d0a:	fd840593          	addi	a1,s0,-40
    80005d0e:	4501                	li	a0,0
    80005d10:	ffffd097          	auipc	ra,0xffffd
    80005d14:	ee0080e7          	jalr	-288(ra) # 80002bf0 <argaddr>
    return -1;
    80005d18:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d1a:	0e054063          	bltz	a0,80005dfa <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d1e:	fc840593          	addi	a1,s0,-56
    80005d22:	fd040513          	addi	a0,s0,-48
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	d40080e7          	jalr	-704(ra) # 80004a66 <pipealloc>
    return -1;
    80005d2e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d30:	0c054563          	bltz	a0,80005dfa <sys_pipe+0x104>
  fd0 = -1;
    80005d34:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d38:	fd043503          	ld	a0,-48(s0)
    80005d3c:	fffff097          	auipc	ra,0xfffff
    80005d40:	3de080e7          	jalr	990(ra) # 8000511a <fdalloc>
    80005d44:	fca42223          	sw	a0,-60(s0)
    80005d48:	08054c63          	bltz	a0,80005de0 <sys_pipe+0xea>
    80005d4c:	fc843503          	ld	a0,-56(s0)
    80005d50:	fffff097          	auipc	ra,0xfffff
    80005d54:	3ca080e7          	jalr	970(ra) # 8000511a <fdalloc>
    80005d58:	fca42023          	sw	a0,-64(s0)
    80005d5c:	06054863          	bltz	a0,80005dcc <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d60:	4691                	li	a3,4
    80005d62:	fc440613          	addi	a2,s0,-60
    80005d66:	fd843583          	ld	a1,-40(s0)
    80005d6a:	6ca8                	ld	a0,88(s1)
    80005d6c:	ffffc097          	auipc	ra,0xffffc
    80005d70:	a2e080e7          	jalr	-1490(ra) # 8000179a <copyout>
    80005d74:	02054063          	bltz	a0,80005d94 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d78:	4691                	li	a3,4
    80005d7a:	fc040613          	addi	a2,s0,-64
    80005d7e:	fd843583          	ld	a1,-40(s0)
    80005d82:	0591                	addi	a1,a1,4
    80005d84:	6ca8                	ld	a0,88(s1)
    80005d86:	ffffc097          	auipc	ra,0xffffc
    80005d8a:	a14080e7          	jalr	-1516(ra) # 8000179a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d8e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d90:	06055563          	bgez	a0,80005dfa <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d94:	fc442783          	lw	a5,-60(s0)
    80005d98:	07e9                	addi	a5,a5,26
    80005d9a:	078e                	slli	a5,a5,0x3
    80005d9c:	97a6                	add	a5,a5,s1
    80005d9e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005da2:	fc042503          	lw	a0,-64(s0)
    80005da6:	0569                	addi	a0,a0,26
    80005da8:	050e                	slli	a0,a0,0x3
    80005daa:	9526                	add	a0,a0,s1
    80005dac:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005db0:	fd043503          	ld	a0,-48(s0)
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	90e080e7          	jalr	-1778(ra) # 800046c2 <fileclose>
    fileclose(wf);
    80005dbc:	fc843503          	ld	a0,-56(s0)
    80005dc0:	fffff097          	auipc	ra,0xfffff
    80005dc4:	902080e7          	jalr	-1790(ra) # 800046c2 <fileclose>
    return -1;
    80005dc8:	57fd                	li	a5,-1
    80005dca:	a805                	j	80005dfa <sys_pipe+0x104>
    if(fd0 >= 0)
    80005dcc:	fc442783          	lw	a5,-60(s0)
    80005dd0:	0007c863          	bltz	a5,80005de0 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005dd4:	01a78513          	addi	a0,a5,26
    80005dd8:	050e                	slli	a0,a0,0x3
    80005dda:	9526                	add	a0,a0,s1
    80005ddc:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005de0:	fd043503          	ld	a0,-48(s0)
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	8de080e7          	jalr	-1826(ra) # 800046c2 <fileclose>
    fileclose(wf);
    80005dec:	fc843503          	ld	a0,-56(s0)
    80005df0:	fffff097          	auipc	ra,0xfffff
    80005df4:	8d2080e7          	jalr	-1838(ra) # 800046c2 <fileclose>
    return -1;
    80005df8:	57fd                	li	a5,-1
}
    80005dfa:	853e                	mv	a0,a5
    80005dfc:	70e2                	ld	ra,56(sp)
    80005dfe:	7442                	ld	s0,48(sp)
    80005e00:	74a2                	ld	s1,40(sp)
    80005e02:	6121                	addi	sp,sp,64
    80005e04:	8082                	ret
	...

0000000080005e10 <kernelvec>:
    80005e10:	7111                	addi	sp,sp,-256
    80005e12:	e006                	sd	ra,0(sp)
    80005e14:	e40a                	sd	sp,8(sp)
    80005e16:	e80e                	sd	gp,16(sp)
    80005e18:	ec12                	sd	tp,24(sp)
    80005e1a:	f016                	sd	t0,32(sp)
    80005e1c:	f41a                	sd	t1,40(sp)
    80005e1e:	f81e                	sd	t2,48(sp)
    80005e20:	fc22                	sd	s0,56(sp)
    80005e22:	e0a6                	sd	s1,64(sp)
    80005e24:	e4aa                	sd	a0,72(sp)
    80005e26:	e8ae                	sd	a1,80(sp)
    80005e28:	ecb2                	sd	a2,88(sp)
    80005e2a:	f0b6                	sd	a3,96(sp)
    80005e2c:	f4ba                	sd	a4,104(sp)
    80005e2e:	f8be                	sd	a5,112(sp)
    80005e30:	fcc2                	sd	a6,120(sp)
    80005e32:	e146                	sd	a7,128(sp)
    80005e34:	e54a                	sd	s2,136(sp)
    80005e36:	e94e                	sd	s3,144(sp)
    80005e38:	ed52                	sd	s4,152(sp)
    80005e3a:	f156                	sd	s5,160(sp)
    80005e3c:	f55a                	sd	s6,168(sp)
    80005e3e:	f95e                	sd	s7,176(sp)
    80005e40:	fd62                	sd	s8,184(sp)
    80005e42:	e1e6                	sd	s9,192(sp)
    80005e44:	e5ea                	sd	s10,200(sp)
    80005e46:	e9ee                	sd	s11,208(sp)
    80005e48:	edf2                	sd	t3,216(sp)
    80005e4a:	f1f6                	sd	t4,224(sp)
    80005e4c:	f5fa                	sd	t5,232(sp)
    80005e4e:	f9fe                	sd	t6,240(sp)
    80005e50:	ba5fc0ef          	jal	ra,800029f4 <kerneltrap>
    80005e54:	6082                	ld	ra,0(sp)
    80005e56:	6122                	ld	sp,8(sp)
    80005e58:	61c2                	ld	gp,16(sp)
    80005e5a:	7282                	ld	t0,32(sp)
    80005e5c:	7322                	ld	t1,40(sp)
    80005e5e:	73c2                	ld	t2,48(sp)
    80005e60:	7462                	ld	s0,56(sp)
    80005e62:	6486                	ld	s1,64(sp)
    80005e64:	6526                	ld	a0,72(sp)
    80005e66:	65c6                	ld	a1,80(sp)
    80005e68:	6666                	ld	a2,88(sp)
    80005e6a:	7686                	ld	a3,96(sp)
    80005e6c:	7726                	ld	a4,104(sp)
    80005e6e:	77c6                	ld	a5,112(sp)
    80005e70:	7866                	ld	a6,120(sp)
    80005e72:	688a                	ld	a7,128(sp)
    80005e74:	692a                	ld	s2,136(sp)
    80005e76:	69ca                	ld	s3,144(sp)
    80005e78:	6a6a                	ld	s4,152(sp)
    80005e7a:	7a8a                	ld	s5,160(sp)
    80005e7c:	7b2a                	ld	s6,168(sp)
    80005e7e:	7bca                	ld	s7,176(sp)
    80005e80:	7c6a                	ld	s8,184(sp)
    80005e82:	6c8e                	ld	s9,192(sp)
    80005e84:	6d2e                	ld	s10,200(sp)
    80005e86:	6dce                	ld	s11,208(sp)
    80005e88:	6e6e                	ld	t3,216(sp)
    80005e8a:	7e8e                	ld	t4,224(sp)
    80005e8c:	7f2e                	ld	t5,232(sp)
    80005e8e:	7fce                	ld	t6,240(sp)
    80005e90:	6111                	addi	sp,sp,256
    80005e92:	10200073          	sret
    80005e96:	00000013          	nop
    80005e9a:	00000013          	nop
    80005e9e:	0001                	nop

0000000080005ea0 <timervec>:
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	e10c                	sd	a1,0(a0)
    80005ea6:	e510                	sd	a2,8(a0)
    80005ea8:	e914                	sd	a3,16(a0)
    80005eaa:	710c                	ld	a1,32(a0)
    80005eac:	7510                	ld	a2,40(a0)
    80005eae:	6194                	ld	a3,0(a1)
    80005eb0:	96b2                	add	a3,a3,a2
    80005eb2:	e194                	sd	a3,0(a1)
    80005eb4:	4589                	li	a1,2
    80005eb6:	14459073          	csrw	sip,a1
    80005eba:	6914                	ld	a3,16(a0)
    80005ebc:	6510                	ld	a2,8(a0)
    80005ebe:	610c                	ld	a1,0(a0)
    80005ec0:	34051573          	csrrw	a0,mscratch,a0
    80005ec4:	30200073          	mret
	...

0000000080005eca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eca:	1141                	addi	sp,sp,-16
    80005ecc:	e422                	sd	s0,8(sp)
    80005ece:	0800                	addi	s0,sp,16
  // XXX need a PLIC_PRIORITY(irq) macro
  
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ed0:	0c0007b7          	lui	a5,0xc000
    80005ed4:	4705                	li	a4,1
    80005ed6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ed8:	c3d8                	sw	a4,4(a5)
    80005eda:	0791                	addi	a5,a5,4

  // PCIE IRQs are 32 to 35
  for(int irq = 1; irq < 0x35; irq++){
    *(uint32*)(PLIC + irq*4) = 1;
    80005edc:	4685                	li	a3,1
  for(int irq = 1; irq < 0x35; irq++){
    80005ede:	0c000737          	lui	a4,0xc000
    80005ee2:	0d470713          	addi	a4,a4,212 # c0000d4 <_entry-0x73ffff2c>
    *(uint32*)(PLIC + irq*4) = 1;
    80005ee6:	c394                	sw	a3,0(a5)
  for(int irq = 1; irq < 0x35; irq++){
    80005ee8:	0791                	addi	a5,a5,4
    80005eea:	fee79ee3          	bne	a5,a4,80005ee6 <plicinit+0x1c>
  }
}
    80005eee:	6422                	ld	s0,8(sp)
    80005ef0:	0141                	addi	sp,sp,16
    80005ef2:	8082                	ret

0000000080005ef4 <plicinithart>:

void
plicinithart(void)
{
    80005ef4:	1141                	addi	sp,sp,-16
    80005ef6:	e406                	sd	ra,8(sp)
    80005ef8:	e022                	sd	s0,0(sp)
    80005efa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005efc:	ffffc097          	auipc	ra,0xffffc
    80005f00:	b7e080e7          	jalr	-1154(ra) # 80001a7a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  uint32 enabled = 0;
  enabled |= (1 << UART0_IRQ);
  enabled |= (1 << VIRTIO0_IRQ);
  *(uint32*)PLIC_SENABLE(hart) = enabled;
    80005f04:	0085171b          	slliw	a4,a0,0x8
    80005f08:	0c0027b7          	lui	a5,0xc002
    80005f0c:	97ba                	add	a5,a5,a4
    80005f0e:	40200713          	li	a4,1026
    80005f12:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // hack to get at next 32 IRQs for e1000
  *(uint32*)(PLIC_SENABLE(hart)+4) = 0xffffffff;
    80005f16:	577d                	li	a4,-1
    80005f18:	08e7a223          	sw	a4,132(a5)

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f1c:	00d5151b          	slliw	a0,a0,0xd
    80005f20:	0c2017b7          	lui	a5,0xc201
    80005f24:	953e                	add	a0,a0,a5
    80005f26:	00052023          	sw	zero,0(a0)
}
    80005f2a:	60a2                	ld	ra,8(sp)
    80005f2c:	6402                	ld	s0,0(sp)
    80005f2e:	0141                	addi	sp,sp,16
    80005f30:	8082                	ret

0000000080005f32 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f32:	1141                	addi	sp,sp,-16
    80005f34:	e406                	sd	ra,8(sp)
    80005f36:	e022                	sd	s0,0(sp)
    80005f38:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f3a:	ffffc097          	auipc	ra,0xffffc
    80005f3e:	b40080e7          	jalr	-1216(ra) # 80001a7a <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f42:	00d5179b          	slliw	a5,a0,0xd
    80005f46:	0c201537          	lui	a0,0xc201
    80005f4a:	953e                	add	a0,a0,a5
  return irq;
}
    80005f4c:	4148                	lw	a0,4(a0)
    80005f4e:	60a2                	ld	ra,8(sp)
    80005f50:	6402                	ld	s0,0(sp)
    80005f52:	0141                	addi	sp,sp,16
    80005f54:	8082                	ret

0000000080005f56 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f56:	1101                	addi	sp,sp,-32
    80005f58:	ec06                	sd	ra,24(sp)
    80005f5a:	e822                	sd	s0,16(sp)
    80005f5c:	e426                	sd	s1,8(sp)
    80005f5e:	1000                	addi	s0,sp,32
    80005f60:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f62:	ffffc097          	auipc	ra,0xffffc
    80005f66:	b18080e7          	jalr	-1256(ra) # 80001a7a <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f6a:	00d5151b          	slliw	a0,a0,0xd
    80005f6e:	0c2017b7          	lui	a5,0xc201
    80005f72:	97aa                	add	a5,a5,a0
    80005f74:	c3c4                	sw	s1,4(a5)
}
    80005f76:	60e2                	ld	ra,24(sp)
    80005f78:	6442                	ld	s0,16(sp)
    80005f7a:	64a2                	ld	s1,8(sp)
    80005f7c:	6105                	addi	sp,sp,32
    80005f7e:	8082                	ret

0000000080005f80 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80005f80:	1141                	addi	sp,sp,-16
    80005f82:	e406                	sd	ra,8(sp)
    80005f84:	e022                	sd	s0,0(sp)
    80005f86:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f88:	479d                	li	a5,7
    80005f8a:	06b7c963          	blt	a5,a1,80005ffc <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80005f8e:	00151793          	slli	a5,a0,0x1
    80005f92:	97aa                	add	a5,a5,a0
    80005f94:	00c79713          	slli	a4,a5,0xc
    80005f98:	0001d797          	auipc	a5,0x1d
    80005f9c:	06878793          	addi	a5,a5,104 # 80023000 <disk>
    80005fa0:	97ba                	add	a5,a5,a4
    80005fa2:	97ae                	add	a5,a5,a1
    80005fa4:	6709                	lui	a4,0x2
    80005fa6:	97ba                	add	a5,a5,a4
    80005fa8:	0187c783          	lbu	a5,24(a5)
    80005fac:	e3a5                	bnez	a5,8000600c <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80005fae:	0001d817          	auipc	a6,0x1d
    80005fb2:	05280813          	addi	a6,a6,82 # 80023000 <disk>
    80005fb6:	00151693          	slli	a3,a0,0x1
    80005fba:	00a68733          	add	a4,a3,a0
    80005fbe:	0732                	slli	a4,a4,0xc
    80005fc0:	00e807b3          	add	a5,a6,a4
    80005fc4:	6709                	lui	a4,0x2
    80005fc6:	00f70633          	add	a2,a4,a5
    80005fca:	6210                	ld	a2,0(a2)
    80005fcc:	00459893          	slli	a7,a1,0x4
    80005fd0:	9646                	add	a2,a2,a7
    80005fd2:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    80005fd6:	97ae                	add	a5,a5,a1
    80005fd8:	97ba                	add	a5,a5,a4
    80005fda:	4605                	li	a2,1
    80005fdc:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80005fe0:	96aa                	add	a3,a3,a0
    80005fe2:	06b2                	slli	a3,a3,0xc
    80005fe4:	0761                	addi	a4,a4,24
    80005fe6:	96ba                	add	a3,a3,a4
    80005fe8:	00d80533          	add	a0,a6,a3
    80005fec:	ffffc097          	auipc	ra,0xffffc
    80005ff0:	3fc080e7          	jalr	1020(ra) # 800023e8 <wakeup>
}
    80005ff4:	60a2                	ld	ra,8(sp)
    80005ff6:	6402                	ld	s0,0(sp)
    80005ff8:	0141                	addi	sp,sp,16
    80005ffa:	8082                	ret
    panic("virtio_disk_intr 1");
    80005ffc:	00004517          	auipc	a0,0x4
    80006000:	b0c50513          	addi	a0,a0,-1268 # 80009b08 <userret+0xa78>
    80006004:	ffffa097          	auipc	ra,0xffffa
    80006008:	556080e7          	jalr	1366(ra) # 8000055a <panic>
    panic("virtio_disk_intr 2");
    8000600c:	00004517          	auipc	a0,0x4
    80006010:	b1450513          	addi	a0,a0,-1260 # 80009b20 <userret+0xa90>
    80006014:	ffffa097          	auipc	ra,0xffffa
    80006018:	546080e7          	jalr	1350(ra) # 8000055a <panic>

000000008000601c <virtio_disk_init>:
  __sync_synchronize();
    8000601c:	0ff0000f          	fence
  if(disk[n].init)
    80006020:	00151793          	slli	a5,a0,0x1
    80006024:	97aa                	add	a5,a5,a0
    80006026:	07b2                	slli	a5,a5,0xc
    80006028:	0001d717          	auipc	a4,0x1d
    8000602c:	fd870713          	addi	a4,a4,-40 # 80023000 <disk>
    80006030:	973e                	add	a4,a4,a5
    80006032:	6789                	lui	a5,0x2
    80006034:	97ba                	add	a5,a5,a4
    80006036:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    8000603a:	c391                	beqz	a5,8000603e <virtio_disk_init+0x22>
    8000603c:	8082                	ret
{
    8000603e:	7139                	addi	sp,sp,-64
    80006040:	fc06                	sd	ra,56(sp)
    80006042:	f822                	sd	s0,48(sp)
    80006044:	f426                	sd	s1,40(sp)
    80006046:	f04a                	sd	s2,32(sp)
    80006048:	ec4e                	sd	s3,24(sp)
    8000604a:	e852                	sd	s4,16(sp)
    8000604c:	e456                	sd	s5,8(sp)
    8000604e:	0080                	addi	s0,sp,64
    80006050:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80006052:	85aa                	mv	a1,a0
    80006054:	00004517          	auipc	a0,0x4
    80006058:	ae450513          	addi	a0,a0,-1308 # 80009b38 <userret+0xaa8>
    8000605c:	ffffa097          	auipc	ra,0xffffa
    80006060:	558080e7          	jalr	1368(ra) # 800005b4 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80006064:	00149993          	slli	s3,s1,0x1
    80006068:	99a6                	add	s3,s3,s1
    8000606a:	09b2                	slli	s3,s3,0xc
    8000606c:	6789                	lui	a5,0x2
    8000606e:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006072:	97ce                	add	a5,a5,s3
    80006074:	00004597          	auipc	a1,0x4
    80006078:	adc58593          	addi	a1,a1,-1316 # 80009b50 <userret+0xac0>
    8000607c:	0001d517          	auipc	a0,0x1d
    80006080:	f8450513          	addi	a0,a0,-124 # 80023000 <disk>
    80006084:	953e                	add	a0,a0,a5
    80006086:	ffffb097          	auipc	ra,0xffffb
    8000608a:	956080e7          	jalr	-1706(ra) # 800009dc <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000608e:	0014891b          	addiw	s2,s1,1
    80006092:	00c9191b          	slliw	s2,s2,0xc
    80006096:	100007b7          	lui	a5,0x10000
    8000609a:	97ca                	add	a5,a5,s2
    8000609c:	4398                	lw	a4,0(a5)
    8000609e:	2701                	sext.w	a4,a4
    800060a0:	747277b7          	lui	a5,0x74727
    800060a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060a8:	12f71663          	bne	a4,a5,800061d4 <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800060ac:	100007b7          	lui	a5,0x10000
    800060b0:	0791                	addi	a5,a5,4
    800060b2:	97ca                	add	a5,a5,s2
    800060b4:	439c                	lw	a5,0(a5)
    800060b6:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060b8:	4705                	li	a4,1
    800060ba:	10e79d63          	bne	a5,a4,800061d4 <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060be:	100007b7          	lui	a5,0x10000
    800060c2:	07a1                	addi	a5,a5,8
    800060c4:	97ca                	add	a5,a5,s2
    800060c6:	439c                	lw	a5,0(a5)
    800060c8:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800060ca:	4709                	li	a4,2
    800060cc:	10e79463          	bne	a5,a4,800061d4 <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060d0:	100007b7          	lui	a5,0x10000
    800060d4:	07b1                	addi	a5,a5,12
    800060d6:	97ca                	add	a5,a5,s2
    800060d8:	4398                	lw	a4,0(a5)
    800060da:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060dc:	554d47b7          	lui	a5,0x554d4
    800060e0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060e4:	0ef71863          	bne	a4,a5,800061d4 <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800060e8:	100007b7          	lui	a5,0x10000
    800060ec:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    800060f0:	96ca                	add	a3,a3,s2
    800060f2:	4705                	li	a4,1
    800060f4:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800060f6:	470d                	li	a4,3
    800060f8:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800060fa:	01078713          	addi	a4,a5,16
    800060fe:	974a                	add	a4,a4,s2
    80006100:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006102:	02078613          	addi	a2,a5,32
    80006106:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006108:	c7ffe737          	lui	a4,0xc7ffe
    8000610c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd53b3>
    80006110:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006112:	2701                	sext.w	a4,a4
    80006114:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006116:	472d                	li	a4,11
    80006118:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000611a:	473d                	li	a4,15
    8000611c:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000611e:	02878713          	addi	a4,a5,40
    80006122:	974a                	add	a4,a4,s2
    80006124:	6685                	lui	a3,0x1
    80006126:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006128:	03078713          	addi	a4,a5,48
    8000612c:	974a                	add	a4,a4,s2
    8000612e:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006132:	03478793          	addi	a5,a5,52
    80006136:	97ca                	add	a5,a5,s2
    80006138:	439c                	lw	a5,0(a5)
    8000613a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000613c:	c7c5                	beqz	a5,800061e4 <virtio_disk_init+0x1c8>
  if(max < NUM)
    8000613e:	471d                	li	a4,7
    80006140:	0af77a63          	bgeu	a4,a5,800061f4 <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006144:	10000ab7          	lui	s5,0x10000
    80006148:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    8000614c:	97ca                	add	a5,a5,s2
    8000614e:	4721                	li	a4,8
    80006150:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006152:	0001da17          	auipc	s4,0x1d
    80006156:	eaea0a13          	addi	s4,s4,-338 # 80023000 <disk>
    8000615a:	99d2                	add	s3,s3,s4
    8000615c:	6609                	lui	a2,0x2
    8000615e:	4581                	li	a1,0
    80006160:	854e                	mv	a0,s3
    80006162:	ffffb097          	auipc	ra,0xffffb
    80006166:	c1c080e7          	jalr	-996(ra) # 80000d7e <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    8000616a:	040a8a93          	addi	s5,s5,64
    8000616e:	9956                	add	s2,s2,s5
    80006170:	00c9d793          	srli	a5,s3,0xc
    80006174:	2781                	sext.w	a5,a5
    80006176:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    8000617a:	00149513          	slli	a0,s1,0x1
    8000617e:	009507b3          	add	a5,a0,s1
    80006182:	07b2                	slli	a5,a5,0xc
    80006184:	97d2                	add	a5,a5,s4
    80006186:	6689                	lui	a3,0x2
    80006188:	97b6                	add	a5,a5,a3
    8000618a:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    8000618e:	08098713          	addi	a4,s3,128
    80006192:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    80006194:	6705                	lui	a4,0x1
    80006196:	99ba                	add	s3,s3,a4
    80006198:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    8000619c:	4705                	li	a4,1
    8000619e:	00e78c23          	sb	a4,24(a5)
    800061a2:	00e78ca3          	sb	a4,25(a5)
    800061a6:	00e78d23          	sb	a4,26(a5)
    800061aa:	00e78da3          	sb	a4,27(a5)
    800061ae:	00e78e23          	sb	a4,28(a5)
    800061b2:	00e78ea3          	sb	a4,29(a5)
    800061b6:	00e78f23          	sb	a4,30(a5)
    800061ba:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    800061be:	0ae7a423          	sw	a4,168(a5)
}
    800061c2:	70e2                	ld	ra,56(sp)
    800061c4:	7442                	ld	s0,48(sp)
    800061c6:	74a2                	ld	s1,40(sp)
    800061c8:	7902                	ld	s2,32(sp)
    800061ca:	69e2                	ld	s3,24(sp)
    800061cc:	6a42                	ld	s4,16(sp)
    800061ce:	6aa2                	ld	s5,8(sp)
    800061d0:	6121                	addi	sp,sp,64
    800061d2:	8082                	ret
    panic("could not find virtio disk");
    800061d4:	00004517          	auipc	a0,0x4
    800061d8:	98c50513          	addi	a0,a0,-1652 # 80009b60 <userret+0xad0>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	37e080e7          	jalr	894(ra) # 8000055a <panic>
    panic("virtio disk has no queue 0");
    800061e4:	00004517          	auipc	a0,0x4
    800061e8:	99c50513          	addi	a0,a0,-1636 # 80009b80 <userret+0xaf0>
    800061ec:	ffffa097          	auipc	ra,0xffffa
    800061f0:	36e080e7          	jalr	878(ra) # 8000055a <panic>
    panic("virtio disk max queue too short");
    800061f4:	00004517          	auipc	a0,0x4
    800061f8:	9ac50513          	addi	a0,a0,-1620 # 80009ba0 <userret+0xb10>
    800061fc:	ffffa097          	auipc	ra,0xffffa
    80006200:	35e080e7          	jalr	862(ra) # 8000055a <panic>

0000000080006204 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    80006204:	7135                	addi	sp,sp,-160
    80006206:	ed06                	sd	ra,152(sp)
    80006208:	e922                	sd	s0,144(sp)
    8000620a:	e526                	sd	s1,136(sp)
    8000620c:	e14a                	sd	s2,128(sp)
    8000620e:	fcce                	sd	s3,120(sp)
    80006210:	f8d2                	sd	s4,112(sp)
    80006212:	f4d6                	sd	s5,104(sp)
    80006214:	f0da                	sd	s6,96(sp)
    80006216:	ecde                	sd	s7,88(sp)
    80006218:	e8e2                	sd	s8,80(sp)
    8000621a:	e4e6                	sd	s9,72(sp)
    8000621c:	e0ea                	sd	s10,64(sp)
    8000621e:	fc6e                	sd	s11,56(sp)
    80006220:	1100                	addi	s0,sp,160
    80006222:	892a                	mv	s2,a0
    80006224:	89ae                	mv	s3,a1
    80006226:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80006228:	45dc                	lw	a5,12(a1)
    8000622a:	0017979b          	slliw	a5,a5,0x1
    8000622e:	1782                	slli	a5,a5,0x20
    80006230:	9381                	srli	a5,a5,0x20
    80006232:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    80006236:	00151493          	slli	s1,a0,0x1
    8000623a:	94aa                	add	s1,s1,a0
    8000623c:	04b2                	slli	s1,s1,0xc
    8000623e:	6a89                	lui	s5,0x2
    80006240:	0b0a8a13          	addi	s4,s5,176 # 20b0 <_entry-0x7fffdf50>
    80006244:	9a26                	add	s4,s4,s1
    80006246:	0001db97          	auipc	s7,0x1d
    8000624a:	dbab8b93          	addi	s7,s7,-582 # 80023000 <disk>
    8000624e:	9a5e                	add	s4,s4,s7
    80006250:	8552                	mv	a0,s4
    80006252:	ffffb097          	auipc	ra,0xffffb
    80006256:	85e080e7          	jalr	-1954(ra) # 80000ab0 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000625a:	0ae1                	addi	s5,s5,24
    8000625c:	94d6                	add	s1,s1,s5
    8000625e:	01748ab3          	add	s5,s1,s7
    80006262:	8d56                	mv	s10,s5
  for(int i = 0; i < 3; i++){
    80006264:	4b81                	li	s7,0
  for(int i = 0; i < NUM; i++){
    80006266:	4ca1                	li	s9,8
      disk[n].free[i] = 0;
    80006268:	00191b13          	slli	s6,s2,0x1
    8000626c:	9b4a                	add	s6,s6,s2
    8000626e:	00cb1793          	slli	a5,s6,0xc
    80006272:	0001db17          	auipc	s6,0x1d
    80006276:	d8eb0b13          	addi	s6,s6,-626 # 80023000 <disk>
    8000627a:	9b3e                	add	s6,s6,a5
  for(int i = 0; i < NUM; i++){
    8000627c:	8c5e                	mv	s8,s7
    8000627e:	a8ad                	j	800062f8 <virtio_disk_rw+0xf4>
      disk[n].free[i] = 0;
    80006280:	00fb06b3          	add	a3,s6,a5
    80006284:	96aa                	add	a3,a3,a0
    80006286:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    8000628a:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000628c:	0207c363          	bltz	a5,800062b2 <virtio_disk_rw+0xae>
  for(int i = 0; i < 3; i++){
    80006290:	2485                	addiw	s1,s1,1
    80006292:	0711                	addi	a4,a4,4
    80006294:	1eb48363          	beq	s1,a1,8000647a <virtio_disk_rw+0x276>
    idx[i] = alloc_desc(n);
    80006298:	863a                	mv	a2,a4
    8000629a:	86ea                	mv	a3,s10
  for(int i = 0; i < NUM; i++){
    8000629c:	87e2                	mv	a5,s8
    if(disk[n].free[i]){
    8000629e:	0006c803          	lbu	a6,0(a3)
    800062a2:	fc081fe3          	bnez	a6,80006280 <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    800062a6:	2785                	addiw	a5,a5,1
    800062a8:	0685                	addi	a3,a3,1
    800062aa:	ff979ae3          	bne	a5,s9,8000629e <virtio_disk_rw+0x9a>
    idx[i] = alloc_desc(n);
    800062ae:	57fd                	li	a5,-1
    800062b0:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800062b2:	02905d63          	blez	s1,800062ec <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800062b6:	f8042583          	lw	a1,-128(s0)
    800062ba:	854a                	mv	a0,s2
    800062bc:	00000097          	auipc	ra,0x0
    800062c0:	cc4080e7          	jalr	-828(ra) # 80005f80 <free_desc>
      for(int j = 0; j < i; j++)
    800062c4:	4785                	li	a5,1
    800062c6:	0297d363          	bge	a5,s1,800062ec <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800062ca:	f8442583          	lw	a1,-124(s0)
    800062ce:	854a                	mv	a0,s2
    800062d0:	00000097          	auipc	ra,0x0
    800062d4:	cb0080e7          	jalr	-848(ra) # 80005f80 <free_desc>
      for(int j = 0; j < i; j++)
    800062d8:	4789                	li	a5,2
    800062da:	0097d963          	bge	a5,s1,800062ec <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800062de:	f8842583          	lw	a1,-120(s0)
    800062e2:	854a                	mv	a0,s2
    800062e4:	00000097          	auipc	ra,0x0
    800062e8:	c9c080e7          	jalr	-868(ra) # 80005f80 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800062ec:	85d2                	mv	a1,s4
    800062ee:	8556                	mv	a0,s5
    800062f0:	ffffc097          	auipc	ra,0xffffc
    800062f4:	f72080e7          	jalr	-142(ra) # 80002262 <sleep>
  for(int i = 0; i < 3; i++){
    800062f8:	f8040713          	addi	a4,s0,-128
    800062fc:	84de                	mv	s1,s7
      disk[n].free[i] = 0;
    800062fe:	6509                	lui	a0,0x2
  for(int i = 0; i < 3; i++){
    80006300:	458d                	li	a1,3
    80006302:	bf59                	j	80006298 <virtio_disk_rw+0x94>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006304:	00191793          	slli	a5,s2,0x1
    80006308:	97ca                	add	a5,a5,s2
    8000630a:	07b2                	slli	a5,a5,0xc
    8000630c:	0001d717          	auipc	a4,0x1d
    80006310:	cf470713          	addi	a4,a4,-780 # 80023000 <disk>
    80006314:	973e                	add	a4,a4,a5
    80006316:	6789                	lui	a5,0x2
    80006318:	97ba                	add	a5,a5,a4
    8000631a:	639c                	ld	a5,0(a5)
    8000631c:	97b6                	add	a5,a5,a3
    8000631e:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006322:	0001d517          	auipc	a0,0x1d
    80006326:	cde50513          	addi	a0,a0,-802 # 80023000 <disk>
    8000632a:	00191793          	slli	a5,s2,0x1
    8000632e:	01278733          	add	a4,a5,s2
    80006332:	0732                	slli	a4,a4,0xc
    80006334:	972a                	add	a4,a4,a0
    80006336:	6609                	lui	a2,0x2
    80006338:	9732                	add	a4,a4,a2
    8000633a:	630c                	ld	a1,0(a4)
    8000633c:	95b6                	add	a1,a1,a3
    8000633e:	00c5d603          	lhu	a2,12(a1)
    80006342:	00166613          	ori	a2,a2,1
    80006346:	00c59623          	sh	a2,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    8000634a:	f8842603          	lw	a2,-120(s0)
    8000634e:	630c                	ld	a1,0(a4)
    80006350:	96ae                	add	a3,a3,a1
    80006352:	00c69723          	sh	a2,14(a3)

  disk[n].info[idx[0]].status = 0;
    80006356:	97ca                	add	a5,a5,s2
    80006358:	07a2                	slli	a5,a5,0x8
    8000635a:	97a6                	add	a5,a5,s1
    8000635c:	20078793          	addi	a5,a5,512
    80006360:	0792                	slli	a5,a5,0x4
    80006362:	97aa                	add	a5,a5,a0
    80006364:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006368:	00461693          	slli	a3,a2,0x4
    8000636c:	00073803          	ld	a6,0(a4)
    80006370:	9836                	add	a6,a6,a3
    80006372:	20348613          	addi	a2,s1,515
    80006376:	00191593          	slli	a1,s2,0x1
    8000637a:	95ca                	add	a1,a1,s2
    8000637c:	05a2                	slli	a1,a1,0x8
    8000637e:	962e                	add	a2,a2,a1
    80006380:	0612                	slli	a2,a2,0x4
    80006382:	962a                	add	a2,a2,a0
    80006384:	00c83023          	sd	a2,0(a6)
  disk[n].desc[idx[2]].len = 1;
    80006388:	630c                	ld	a1,0(a4)
    8000638a:	95b6                	add	a1,a1,a3
    8000638c:	4605                	li	a2,1
    8000638e:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006390:	630c                	ld	a1,0(a4)
    80006392:	95b6                	add	a1,a1,a3
    80006394:	4509                	li	a0,2
    80006396:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    8000639a:	630c                	ld	a1,0(a4)
    8000639c:	96ae                	add	a3,a3,a1
    8000639e:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063a2:	00c9a223          	sw	a2,4(s3)
  disk[n].info[idx[0]].b = b;
    800063a6:	0337b423          	sd	s3,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    800063aa:	6714                	ld	a3,8(a4)
    800063ac:	0026d783          	lhu	a5,2(a3)
    800063b0:	8b9d                	andi	a5,a5,7
    800063b2:	2789                	addiw	a5,a5,2
    800063b4:	0786                	slli	a5,a5,0x1
    800063b6:	97b6                	add	a5,a5,a3
    800063b8:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800063bc:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    800063c0:	6718                	ld	a4,8(a4)
    800063c2:	00275783          	lhu	a5,2(a4)
    800063c6:	2785                	addiw	a5,a5,1
    800063c8:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063cc:	0019079b          	addiw	a5,s2,1
    800063d0:	00c7979b          	slliw	a5,a5,0xc
    800063d4:	10000737          	lui	a4,0x10000
    800063d8:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    800063dc:	97ba                	add	a5,a5,a4
    800063de:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063e2:	0049a783          	lw	a5,4(s3)
    800063e6:	00c79d63          	bne	a5,a2,80006400 <virtio_disk_rw+0x1fc>
    800063ea:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    800063ec:	85d2                	mv	a1,s4
    800063ee:	854e                	mv	a0,s3
    800063f0:	ffffc097          	auipc	ra,0xffffc
    800063f4:	e72080e7          	jalr	-398(ra) # 80002262 <sleep>
  while(b->disk == 1) {
    800063f8:	0049a783          	lw	a5,4(s3)
    800063fc:	fe9788e3          	beq	a5,s1,800063ec <virtio_disk_rw+0x1e8>
  }

  disk[n].info[idx[0]].b = 0;
    80006400:	f8042483          	lw	s1,-128(s0)
    80006404:	00191793          	slli	a5,s2,0x1
    80006408:	97ca                	add	a5,a5,s2
    8000640a:	07a2                	slli	a5,a5,0x8
    8000640c:	97a6                	add	a5,a5,s1
    8000640e:	20078793          	addi	a5,a5,512
    80006412:	0792                	slli	a5,a5,0x4
    80006414:	0001d717          	auipc	a4,0x1d
    80006418:	bec70713          	addi	a4,a4,-1044 # 80023000 <disk>
    8000641c:	97ba                	add	a5,a5,a4
    8000641e:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006422:	00191793          	slli	a5,s2,0x1
    80006426:	97ca                	add	a5,a5,s2
    80006428:	07b2                	slli	a5,a5,0xc
    8000642a:	97ba                	add	a5,a5,a4
    8000642c:	6989                	lui	s3,0x2
    8000642e:	99be                	add	s3,s3,a5
    free_desc(n, i);
    80006430:	85a6                	mv	a1,s1
    80006432:	854a                	mv	a0,s2
    80006434:	00000097          	auipc	ra,0x0
    80006438:	b4c080e7          	jalr	-1204(ra) # 80005f80 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    8000643c:	0492                	slli	s1,s1,0x4
    8000643e:	0009b783          	ld	a5,0(s3) # 2000 <_entry-0x7fffe000>
    80006442:	94be                	add	s1,s1,a5
    80006444:	00c4d783          	lhu	a5,12(s1)
    80006448:	8b85                	andi	a5,a5,1
    8000644a:	c781                	beqz	a5,80006452 <virtio_disk_rw+0x24e>
      i = disk[n].desc[i].next;
    8000644c:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006450:	b7c5                	j	80006430 <virtio_disk_rw+0x22c>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006452:	8552                	mv	a0,s4
    80006454:	ffffa097          	auipc	ra,0xffffa
    80006458:	72c080e7          	jalr	1836(ra) # 80000b80 <release>
}
    8000645c:	60ea                	ld	ra,152(sp)
    8000645e:	644a                	ld	s0,144(sp)
    80006460:	64aa                	ld	s1,136(sp)
    80006462:	690a                	ld	s2,128(sp)
    80006464:	79e6                	ld	s3,120(sp)
    80006466:	7a46                	ld	s4,112(sp)
    80006468:	7aa6                	ld	s5,104(sp)
    8000646a:	7b06                	ld	s6,96(sp)
    8000646c:	6be6                	ld	s7,88(sp)
    8000646e:	6c46                	ld	s8,80(sp)
    80006470:	6ca6                	ld	s9,72(sp)
    80006472:	6d06                	ld	s10,64(sp)
    80006474:	7de2                	ld	s11,56(sp)
    80006476:	610d                	addi	sp,sp,160
    80006478:	8082                	ret
  if(write)
    8000647a:	01b037b3          	snez	a5,s11
    8000647e:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006482:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006486:	f6843783          	ld	a5,-152(s0)
    8000648a:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000648e:	f8042483          	lw	s1,-128(s0)
    80006492:	00449b13          	slli	s6,s1,0x4
    80006496:	00191793          	slli	a5,s2,0x1
    8000649a:	97ca                	add	a5,a5,s2
    8000649c:	07b2                	slli	a5,a5,0xc
    8000649e:	0001da97          	auipc	s5,0x1d
    800064a2:	b62a8a93          	addi	s5,s5,-1182 # 80023000 <disk>
    800064a6:	97d6                	add	a5,a5,s5
    800064a8:	6a89                	lui	s5,0x2
    800064aa:	9abe                	add	s5,s5,a5
    800064ac:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    800064b0:	9bda                	add	s7,s7,s6
    800064b2:	f7040513          	addi	a0,s0,-144
    800064b6:	ffffb097          	auipc	ra,0xffffb
    800064ba:	d18080e7          	jalr	-744(ra) # 800011ce <kvmpa>
    800064be:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    800064c2:	000ab783          	ld	a5,0(s5)
    800064c6:	97da                	add	a5,a5,s6
    800064c8:	4741                	li	a4,16
    800064ca:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064cc:	000ab783          	ld	a5,0(s5)
    800064d0:	97da                	add	a5,a5,s6
    800064d2:	4705                	li	a4,1
    800064d4:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    800064d8:	f8442683          	lw	a3,-124(s0)
    800064dc:	000ab783          	ld	a5,0(s5)
    800064e0:	9b3e                	add	s6,s6,a5
    800064e2:	00db1723          	sh	a3,14(s6)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    800064e6:	0692                	slli	a3,a3,0x4
    800064e8:	000ab783          	ld	a5,0(s5)
    800064ec:	97b6                	add	a5,a5,a3
    800064ee:	06098713          	addi	a4,s3,96
    800064f2:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    800064f4:	000ab783          	ld	a5,0(s5)
    800064f8:	97b6                	add	a5,a5,a3
    800064fa:	40000713          	li	a4,1024
    800064fe:	c798                	sw	a4,8(a5)
  if(write)
    80006500:	e00d92e3          	bnez	s11,80006304 <virtio_disk_rw+0x100>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006504:	00191793          	slli	a5,s2,0x1
    80006508:	97ca                	add	a5,a5,s2
    8000650a:	07b2                	slli	a5,a5,0xc
    8000650c:	0001d717          	auipc	a4,0x1d
    80006510:	af470713          	addi	a4,a4,-1292 # 80023000 <disk>
    80006514:	973e                	add	a4,a4,a5
    80006516:	6789                	lui	a5,0x2
    80006518:	97ba                	add	a5,a5,a4
    8000651a:	639c                	ld	a5,0(a5)
    8000651c:	97b6                	add	a5,a5,a3
    8000651e:	4709                	li	a4,2
    80006520:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006524:	bbfd                	j	80006322 <virtio_disk_rw+0x11e>

0000000080006526 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006526:	7139                	addi	sp,sp,-64
    80006528:	fc06                	sd	ra,56(sp)
    8000652a:	f822                	sd	s0,48(sp)
    8000652c:	f426                	sd	s1,40(sp)
    8000652e:	f04a                	sd	s2,32(sp)
    80006530:	ec4e                	sd	s3,24(sp)
    80006532:	e852                	sd	s4,16(sp)
    80006534:	e456                	sd	s5,8(sp)
    80006536:	0080                	addi	s0,sp,64
    80006538:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    8000653a:	00151913          	slli	s2,a0,0x1
    8000653e:	00a90a33          	add	s4,s2,a0
    80006542:	0a32                	slli	s4,s4,0xc
    80006544:	6989                	lui	s3,0x2
    80006546:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    8000654a:	9a3e                	add	s4,s4,a5
    8000654c:	0001da97          	auipc	s5,0x1d
    80006550:	ab4a8a93          	addi	s5,s5,-1356 # 80023000 <disk>
    80006554:	9a56                	add	s4,s4,s5
    80006556:	8552                	mv	a0,s4
    80006558:	ffffa097          	auipc	ra,0xffffa
    8000655c:	558080e7          	jalr	1368(ra) # 80000ab0 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006560:	9926                	add	s2,s2,s1
    80006562:	0932                	slli	s2,s2,0xc
    80006564:	9956                	add	s2,s2,s5
    80006566:	99ca                	add	s3,s3,s2
    80006568:	0209d783          	lhu	a5,32(s3)
    8000656c:	0109b703          	ld	a4,16(s3)
    80006570:	00275683          	lhu	a3,2(a4)
    80006574:	8ebd                	xor	a3,a3,a5
    80006576:	8a9d                	andi	a3,a3,7
    80006578:	c2a5                	beqz	a3,800065d8 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    8000657a:	8956                	mv	s2,s5
    8000657c:	00149693          	slli	a3,s1,0x1
    80006580:	96a6                	add	a3,a3,s1
    80006582:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006586:	06b2                	slli	a3,a3,0xc
    80006588:	96d6                	add	a3,a3,s5
    8000658a:	6489                	lui	s1,0x2
    8000658c:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    8000658e:	078e                	slli	a5,a5,0x3
    80006590:	97ba                	add	a5,a5,a4
    80006592:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006594:	00f98733          	add	a4,s3,a5
    80006598:	20070713          	addi	a4,a4,512
    8000659c:	0712                	slli	a4,a4,0x4
    8000659e:	974a                	add	a4,a4,s2
    800065a0:	03074703          	lbu	a4,48(a4)
    800065a4:	eb21                	bnez	a4,800065f4 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    800065a6:	97ce                	add	a5,a5,s3
    800065a8:	20078793          	addi	a5,a5,512
    800065ac:	0792                	slli	a5,a5,0x4
    800065ae:	97ca                	add	a5,a5,s2
    800065b0:	7798                	ld	a4,40(a5)
    800065b2:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    800065b6:	7788                	ld	a0,40(a5)
    800065b8:	ffffc097          	auipc	ra,0xffffc
    800065bc:	e30080e7          	jalr	-464(ra) # 800023e8 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    800065c0:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    800065c4:	2785                	addiw	a5,a5,1
    800065c6:	8b9d                	andi	a5,a5,7
    800065c8:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    800065cc:	6898                	ld	a4,16(s1)
    800065ce:	00275683          	lhu	a3,2(a4)
    800065d2:	8a9d                	andi	a3,a3,7
    800065d4:	faf69de3          	bne	a3,a5,8000658e <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    800065d8:	8552                	mv	a0,s4
    800065da:	ffffa097          	auipc	ra,0xffffa
    800065de:	5a6080e7          	jalr	1446(ra) # 80000b80 <release>
}
    800065e2:	70e2                	ld	ra,56(sp)
    800065e4:	7442                	ld	s0,48(sp)
    800065e6:	74a2                	ld	s1,40(sp)
    800065e8:	7902                	ld	s2,32(sp)
    800065ea:	69e2                	ld	s3,24(sp)
    800065ec:	6a42                	ld	s4,16(sp)
    800065ee:	6aa2                	ld	s5,8(sp)
    800065f0:	6121                	addi	sp,sp,64
    800065f2:	8082                	ret
      panic("virtio_disk_intr status");
    800065f4:	00003517          	auipc	a0,0x3
    800065f8:	5cc50513          	addi	a0,a0,1484 # 80009bc0 <userret+0xb30>
    800065fc:	ffffa097          	auipc	ra,0xffffa
    80006600:	f5e080e7          	jalr	-162(ra) # 8000055a <panic>

0000000080006604 <e1000_init>:
// called by pci_init().
// xregs is the memory address at which the
// e1000's registers are mapped.
void
e1000_init(uint32 *xregs)
{
    80006604:	7179                	addi	sp,sp,-48
    80006606:	f406                	sd	ra,40(sp)
    80006608:	f022                	sd	s0,32(sp)
    8000660a:	ec26                	sd	s1,24(sp)
    8000660c:	e84a                	sd	s2,16(sp)
    8000660e:	e44e                	sd	s3,8(sp)
    80006610:	1800                	addi	s0,sp,48
    80006612:	84aa                	mv	s1,a0
  int i;

  initlock(&e1000_lock, "e1000");
    80006614:	00003597          	auipc	a1,0x3
    80006618:	5c458593          	addi	a1,a1,1476 # 80009bd8 <userret+0xb48>
    8000661c:	00023517          	auipc	a0,0x23
    80006620:	9e450513          	addi	a0,a0,-1564 # 80029000 <e1000_lock>
    80006624:	ffffa097          	auipc	ra,0xffffa
    80006628:	3b8080e7          	jalr	952(ra) # 800009dc <initlock>

  regs = xregs;
    8000662c:	00023797          	auipc	a5,0x23
    80006630:	d497be23          	sd	s1,-676(a5) # 80029388 <regs>

  // Reset the device
  regs[E1000_IMS] = 0; // disable interrupts
    80006634:	0c04a823          	sw	zero,208(s1)
  regs[E1000_CTL] |= E1000_CTL_RST;
    80006638:	409c                	lw	a5,0(s1)
    8000663a:	00400737          	lui	a4,0x400
    8000663e:	8fd9                	or	a5,a5,a4
    80006640:	2781                	sext.w	a5,a5
    80006642:	c09c                	sw	a5,0(s1)
  regs[E1000_IMS] = 0; // redisable interrupts
    80006644:	0c04a823          	sw	zero,208(s1)
  __sync_synchronize();
    80006648:	0ff0000f          	fence

  // [E1000 14.5] Transmit initialization
  memset(tx_ring, 0, sizeof(tx_ring));
    8000664c:	10000613          	li	a2,256
    80006650:	4581                	li	a1,0
    80006652:	00023517          	auipc	a0,0x23
    80006656:	9ce50513          	addi	a0,a0,-1586 # 80029020 <tx_ring>
    8000665a:	ffffa097          	auipc	ra,0xffffa
    8000665e:	724080e7          	jalr	1828(ra) # 80000d7e <memset>
  for (i = 0; i < TX_RING_SIZE; i++) {
    80006662:	00023717          	auipc	a4,0x23
    80006666:	9ca70713          	addi	a4,a4,-1590 # 8002902c <tx_ring+0xc>
    8000666a:	00023797          	auipc	a5,0x23
    8000666e:	ab678793          	addi	a5,a5,-1354 # 80029120 <tx_mbufs>
    80006672:	00023617          	auipc	a2,0x23
    80006676:	b2e60613          	addi	a2,a2,-1234 # 800291a0 <rx_ring>
    tx_ring[i].status = E1000_TXD_STAT_DD;
    8000667a:	4685                	li	a3,1
    8000667c:	00d70023          	sb	a3,0(a4)
    tx_mbufs[i] = 0;
    80006680:	0007b023          	sd	zero,0(a5)
  for (i = 0; i < TX_RING_SIZE; i++) {
    80006684:	0741                	addi	a4,a4,16
    80006686:	07a1                	addi	a5,a5,8
    80006688:	fec79ae3          	bne	a5,a2,8000667c <e1000_init+0x78>
  }
  regs[E1000_TDBAL] = (uint64) tx_ring;
    8000668c:	00023717          	auipc	a4,0x23
    80006690:	99470713          	addi	a4,a4,-1644 # 80029020 <tx_ring>
    80006694:	00023797          	auipc	a5,0x23
    80006698:	cf47b783          	ld	a5,-780(a5) # 80029388 <regs>
    8000669c:	6691                	lui	a3,0x4
    8000669e:	97b6                	add	a5,a5,a3
    800066a0:	80e7a023          	sw	a4,-2048(a5)
  if(sizeof(tx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_TDLEN] = sizeof(tx_ring);
    800066a4:	10000713          	li	a4,256
    800066a8:	80e7a423          	sw	a4,-2040(a5)
  regs[E1000_TDH] = regs[E1000_TDT] = 0;
    800066ac:	8007ac23          	sw	zero,-2024(a5)
    800066b0:	8007a823          	sw	zero,-2032(a5)
  
  // [E1000 14.4] Receive initialization
  memset(rx_ring, 0, sizeof(rx_ring));
    800066b4:	00023917          	auipc	s2,0x23
    800066b8:	aec90913          	addi	s2,s2,-1300 # 800291a0 <rx_ring>
    800066bc:	10000613          	li	a2,256
    800066c0:	4581                	li	a1,0
    800066c2:	854a                	mv	a0,s2
    800066c4:	ffffa097          	auipc	ra,0xffffa
    800066c8:	6ba080e7          	jalr	1722(ra) # 80000d7e <memset>
  for (i = 0; i < RX_RING_SIZE; i++) {
    800066cc:	00023497          	auipc	s1,0x23
    800066d0:	bd448493          	addi	s1,s1,-1068 # 800292a0 <rx_mbufs>
    800066d4:	00023997          	auipc	s3,0x23
    800066d8:	c4c98993          	addi	s3,s3,-948 # 80029320 <lock>
    rx_mbufs[i] = mbufalloc(0);
    800066dc:	4501                	li	a0,0
    800066de:	00000097          	auipc	ra,0x0
    800066e2:	43e080e7          	jalr	1086(ra) # 80006b1c <mbufalloc>
    800066e6:	e088                	sd	a0,0(s1)
    if (!rx_mbufs[i])
    800066e8:	c945                	beqz	a0,80006798 <e1000_init+0x194>
      panic("e1000");
    rx_ring[i].addr = (uint64) rx_mbufs[i]->head;
    800066ea:	651c                	ld	a5,8(a0)
    800066ec:	00f93023          	sd	a5,0(s2)
  for (i = 0; i < RX_RING_SIZE; i++) {
    800066f0:	04a1                	addi	s1,s1,8
    800066f2:	0941                	addi	s2,s2,16
    800066f4:	ff3494e3          	bne	s1,s3,800066dc <e1000_init+0xd8>
  }
  regs[E1000_RDBAL] = (uint64) rx_ring;
    800066f8:	00023697          	auipc	a3,0x23
    800066fc:	c906b683          	ld	a3,-880(a3) # 80029388 <regs>
    80006700:	00023717          	auipc	a4,0x23
    80006704:	aa070713          	addi	a4,a4,-1376 # 800291a0 <rx_ring>
    80006708:	678d                	lui	a5,0x3
    8000670a:	97b6                	add	a5,a5,a3
    8000670c:	80e7a023          	sw	a4,-2048(a5) # 2800 <_entry-0x7fffd800>
  if(sizeof(rx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_RDH] = 0;
    80006710:	8007a823          	sw	zero,-2032(a5)
  regs[E1000_RDT] = RX_RING_SIZE - 1;
    80006714:	473d                	li	a4,15
    80006716:	80e7ac23          	sw	a4,-2024(a5)
  regs[E1000_RDLEN] = sizeof(rx_ring);
    8000671a:	10000713          	li	a4,256
    8000671e:	80e7a423          	sw	a4,-2040(a5)

  // filter by qemu's MAC address, 52:54:00:12:34:56
  regs[E1000_RA] = 0x12005452;
    80006722:	6715                	lui	a4,0x5
    80006724:	00e68633          	add	a2,a3,a4
    80006728:	120057b7          	lui	a5,0x12005
    8000672c:	45278793          	addi	a5,a5,1106 # 12005452 <_entry-0x6dffabae>
    80006730:	40f62023          	sw	a5,1024(a2)
  regs[E1000_RA+1] = 0x5634 | (1<<31);
    80006734:	800057b7          	lui	a5,0x80005
    80006738:	63478793          	addi	a5,a5,1588 # ffffffff80005634 <end+0xfffffffefffdc288>
    8000673c:	40f62223          	sw	a5,1028(a2)
  // multicast table
  for (int i = 0; i < 4096/32; i++)
    80006740:	20070793          	addi	a5,a4,512 # 5200 <_entry-0x7fffae00>
    80006744:	97b6                	add	a5,a5,a3
    80006746:	40070713          	addi	a4,a4,1024
    8000674a:	9736                	add	a4,a4,a3
    regs[E1000_MTA + i] = 0;
    8000674c:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < 4096/32; i++)
    80006750:	0791                	addi	a5,a5,4
    80006752:	fee79de3          	bne	a5,a4,8000674c <e1000_init+0x148>

  // transmitter control bits.
  regs[E1000_TCTL] = E1000_TCTL_EN |  // enable
    80006756:	000407b7          	lui	a5,0x40
    8000675a:	10a78793          	addi	a5,a5,266 # 4010a <_entry-0x7ffbfef6>
    8000675e:	40f6a023          	sw	a5,1024(a3)
    E1000_TCTL_PSP |                  // pad short packets
    (0x10 << E1000_TCTL_CT_SHIFT) |   // collision stuff
    (0x40 << E1000_TCTL_COLD_SHIFT);
  regs[E1000_TIPG] = 10 | (8<<10) | (6<<20); // inter-pkt gap
    80006762:	006027b7          	lui	a5,0x602
    80006766:	07a9                	addi	a5,a5,10
    80006768:	40f6a823          	sw	a5,1040(a3)

  // receiver control bits.
  regs[E1000_RCTL] = E1000_RCTL_EN | // enable receiver
    8000676c:	040087b7          	lui	a5,0x4008
    80006770:	0789                	addi	a5,a5,2
    80006772:	10f6a023          	sw	a5,256(a3)
    E1000_RCTL_BAM |                 // enable broadcast
    E1000_RCTL_SZ_2048 |             // 2048-byte rx buffers
    E1000_RCTL_SECRC;                // strip CRC
  
  // ask e1000 for receive interrupts.
  regs[E1000_RDTR] = 0; // interrupt after every received packet (no timer)
    80006776:	678d                	lui	a5,0x3
    80006778:	97b6                	add	a5,a5,a3
    8000677a:	8207a023          	sw	zero,-2016(a5) # 2820 <_entry-0x7fffd7e0>
  regs[E1000_RADV] = 0; // interrupt after every packet (no timer)
    8000677e:	8207a623          	sw	zero,-2004(a5)
  regs[E1000_IMS] = (1 << 7); // RXDW -- Receiver Descriptor Write Back
    80006782:	08000793          	li	a5,128
    80006786:	0cf6a823          	sw	a5,208(a3)
}
    8000678a:	70a2                	ld	ra,40(sp)
    8000678c:	7402                	ld	s0,32(sp)
    8000678e:	64e2                	ld	s1,24(sp)
    80006790:	6942                	ld	s2,16(sp)
    80006792:	69a2                	ld	s3,8(sp)
    80006794:	6145                	addi	sp,sp,48
    80006796:	8082                	ret
      panic("e1000");
    80006798:	00003517          	auipc	a0,0x3
    8000679c:	44050513          	addi	a0,a0,1088 # 80009bd8 <userret+0xb48>
    800067a0:	ffffa097          	auipc	ra,0xffffa
    800067a4:	dba080e7          	jalr	-582(ra) # 8000055a <panic>

00000000800067a8 <e1000_transmit>:

int
e1000_transmit(struct mbuf *m)
{
    800067a8:	7179                	addi	sp,sp,-48
    800067aa:	f406                	sd	ra,40(sp)
    800067ac:	f022                	sd	s0,32(sp)
    800067ae:	ec26                	sd	s1,24(sp)
    800067b0:	e84a                	sd	s2,16(sp)
    800067b2:	e44e                	sd	s3,8(sp)
    800067b4:	1800                	addi	s0,sp,48
    800067b6:	892a                	mv	s2,a0
  //
  // the mbuf contains an ethernet frame; program it into
  // the TX descriptor ring so that the e1000 sends it. Stash
  // a pointer so that it can be freed after sending.
  //
  acquire(&e1000_lock);
    800067b8:	00023997          	auipc	s3,0x23
    800067bc:	84898993          	addi	s3,s3,-1976 # 80029000 <e1000_lock>
    800067c0:	854e                	mv	a0,s3
    800067c2:	ffffa097          	auipc	ra,0xffffa
    800067c6:	2ee080e7          	jalr	750(ra) # 80000ab0 <acquire>
  
  // Transmission Descriptor Tail (TDT)
  uint32 tail, head, next;
  
  tail = regs[E1000_TDT];
    800067ca:	00023717          	auipc	a4,0x23
    800067ce:	bbe73703          	ld	a4,-1090(a4) # 80029388 <regs>
    800067d2:	6791                	lui	a5,0x4
    800067d4:	973e                	add	a4,a4,a5
    800067d6:	81872783          	lw	a5,-2024(a4)
    800067da:	0007849b          	sext.w	s1,a5
  head = regs[E1000_TDH];
    800067de:	81072703          	lw	a4,-2032(a4)

  // Previous transmission is still in flight
  if((tx_ring[tail].status && E1000_TXD_STAT_DD) == 0) {
    800067e2:	1782                	slli	a5,a5,0x20
    800067e4:	9381                	srli	a5,a5,0x20
    800067e6:	0792                	slli	a5,a5,0x4
    800067e8:	97ce                	add	a5,a5,s3
    800067ea:	02c7c783          	lbu	a5,44(a5) # 402c <_entry-0x7fffbfd4>
    800067ee:	c7c1                	beqz	a5,80006876 <e1000_transmit+0xce>
    800067f0:	2701                	sext.w	a4,a4
    release(&e1000_lock);
    return -1;
  }
  
  next = (tail + 1) % TX_RING_SIZE;
    800067f2:	0014899b          	addiw	s3,s1,1
    800067f6:	00f9f993          	andi	s3,s3,15
  if(next == head) {
    800067fa:	09370563          	beq	a4,s3,80006884 <e1000_transmit+0xdc>
    panic("full tx_ring\n");
  }

  // free the last mbuf , if there was one ... mbuf structure is a linked list .. remove the prev mbuf from the list bcz it is already transmitted.
  // implementation based. Not really needed
  if(tx_mbufs[tail] != 0) mbuffree(tx_mbufs[tail]);
    800067fe:	02049793          	slli	a5,s1,0x20
    80006802:	9381                	srli	a5,a5,0x20
    80006804:	00379713          	slli	a4,a5,0x3
    80006808:	00022797          	auipc	a5,0x22
    8000680c:	7f878793          	addi	a5,a5,2040 # 80029000 <e1000_lock>
    80006810:	97ba                	add	a5,a5,a4
    80006812:	1207b503          	ld	a0,288(a5)
    80006816:	c509                	beqz	a0,80006820 <e1000_transmit+0x78>
    80006818:	00000097          	auipc	ra,0x0
    8000681c:	35c080e7          	jalr	860(ra) # 80006b74 <mbuffree>

  tx_mbufs[tail] = m;
    80006820:	00022517          	auipc	a0,0x22
    80006824:	7e050513          	addi	a0,a0,2016 # 80029000 <e1000_lock>
    80006828:	1482                	slli	s1,s1,0x20
    8000682a:	9081                	srli	s1,s1,0x20
    8000682c:	00349793          	slli	a5,s1,0x3
    80006830:	97aa                	add	a5,a5,a0
    80006832:	1327b023          	sd	s2,288(a5)

  // head of a character array (buffer)
  tx_ring[tail].addr = (uint64)m->head;
    80006836:	0492                	slli	s1,s1,0x4
    80006838:	94aa                	add	s1,s1,a0
    8000683a:	00893783          	ld	a5,8(s2)
    8000683e:	f09c                	sd	a5,32(s1)
  tx_ring[tail].length = (uint16)m->len;
    80006840:	01092783          	lw	a5,16(s2)
    80006844:	02f49423          	sh	a5,40(s1)

  // cmd flags 
  // 1. RS - report status - yes
  // 2. EOP - end of packet - yes
  tx_ring[tail].cmd = E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP;
    80006848:	47a5                	li	a5,9
    8000684a:	02f485a3          	sb	a5,43(s1)

  // increment tail
  regs[E1000_TDT] = (tail + 1) % TX_RING_SIZE;
    8000684e:	00023797          	auipc	a5,0x23
    80006852:	b3a7b783          	ld	a5,-1222(a5) # 80029388 <regs>
    80006856:	6711                	lui	a4,0x4
    80006858:	97ba                	add	a5,a5,a4
    8000685a:	8137ac23          	sw	s3,-2024(a5)

  release(&e1000_lock);
    8000685e:	ffffa097          	auipc	ra,0xffffa
    80006862:	322080e7          	jalr	802(ra) # 80000b80 <release>

  return 0;
    80006866:	4501                	li	a0,0
}
    80006868:	70a2                	ld	ra,40(sp)
    8000686a:	7402                	ld	s0,32(sp)
    8000686c:	64e2                	ld	s1,24(sp)
    8000686e:	6942                	ld	s2,16(sp)
    80006870:	69a2                	ld	s3,8(sp)
    80006872:	6145                	addi	sp,sp,48
    80006874:	8082                	ret
    release(&e1000_lock);
    80006876:	854e                	mv	a0,s3
    80006878:	ffffa097          	auipc	ra,0xffffa
    8000687c:	308080e7          	jalr	776(ra) # 80000b80 <release>
    return -1;
    80006880:	557d                	li	a0,-1
    80006882:	b7dd                	j	80006868 <e1000_transmit+0xc0>
    panic("full tx_ring\n");
    80006884:	00003517          	auipc	a0,0x3
    80006888:	35c50513          	addi	a0,a0,860 # 80009be0 <userret+0xb50>
    8000688c:	ffffa097          	auipc	ra,0xffffa
    80006890:	cce080e7          	jalr	-818(ra) # 8000055a <panic>

0000000080006894 <e1000_intr>:
  // printf("Packet received succesfully\n");
}

void
e1000_intr(void)
{
    80006894:	715d                	addi	sp,sp,-80
    80006896:	e486                	sd	ra,72(sp)
    80006898:	e0a2                	sd	s0,64(sp)
    8000689a:	fc26                	sd	s1,56(sp)
    8000689c:	f84a                	sd	s2,48(sp)
    8000689e:	f44e                	sd	s3,40(sp)
    800068a0:	f052                	sd	s4,32(sp)
    800068a2:	ec56                	sd	s5,24(sp)
    800068a4:	e85a                	sd	s6,16(sp)
    800068a6:	e45e                	sd	s7,8(sp)
    800068a8:	0880                	addi	s0,sp,80
  head = (regs[E1000_RDT] + 1) % RX_RING_SIZE;
    800068aa:	00023797          	auipc	a5,0x23
    800068ae:	ade7b783          	ld	a5,-1314(a5) # 80029388 <regs>
    800068b2:	670d                	lui	a4,0x3
    800068b4:	97ba                	add	a5,a5,a4
    800068b6:	8187a783          	lw	a5,-2024(a5)
    800068ba:	2785                	addiw	a5,a5,1
    800068bc:	00f7f493          	andi	s1,a5,15
  while((rx_ring[head].status & E1000_RXD_STAT_DD)) 
    800068c0:	00449793          	slli	a5,s1,0x4
    800068c4:	00022717          	auipc	a4,0x22
    800068c8:	73c70713          	addi	a4,a4,1852 # 80029000 <e1000_lock>
    800068cc:	97ba                	add	a5,a5,a4
    800068ce:	1ac7c783          	lbu	a5,428(a5)
    800068d2:	8b85                	andi	a5,a5,1
    800068d4:	c3c9                	beqz	a5,80006956 <e1000_intr+0xc2>
    acquire(&e1000_lock);
    800068d6:	89ba                	mv	s3,a4
    regs[E1000_RDT] = head;
    800068d8:	00023a97          	auipc	s5,0x23
    800068dc:	ab0a8a93          	addi	s5,s5,-1360 # 80029388 <regs>
    800068e0:	6a0d                	lui	s4,0x3
    acquire(&e1000_lock);
    800068e2:	854e                	mv	a0,s3
    800068e4:	ffffa097          	auipc	ra,0xffffa
    800068e8:	1cc080e7          	jalr	460(ra) # 80000ab0 <acquire>
    mbuf = rx_mbufs[head];
    800068ec:	00349b13          	slli	s6,s1,0x3
    800068f0:	9b4e                	add	s6,s6,s3
    800068f2:	2a0b3b83          	ld	s7,672(s6)
    mbufput(mbuf, rx_ring[head].length);
    800068f6:	00449913          	slli	s2,s1,0x4
    800068fa:	994e                	add	s2,s2,s3
    800068fc:	1a895583          	lhu	a1,424(s2)
    80006900:	855e                	mv	a0,s7
    80006902:	00000097          	auipc	ra,0x0
    80006906:	1be080e7          	jalr	446(ra) # 80006ac0 <mbufput>
    rx_mbufs[head] = mbufalloc(0);
    8000690a:	4501                	li	a0,0
    8000690c:	00000097          	auipc	ra,0x0
    80006910:	210080e7          	jalr	528(ra) # 80006b1c <mbufalloc>
    80006914:	2aab3023          	sd	a0,672(s6)
    rx_ring[head].addr = (uint64)rx_mbufs[head]->head;
    80006918:	651c                	ld	a5,8(a0)
    8000691a:	1af93023          	sd	a5,416(s2)
    rx_ring[head].status = 0;
    8000691e:	1a090623          	sb	zero,428(s2)
    regs[E1000_RDT] = head;
    80006922:	000ab783          	ld	a5,0(s5)
    80006926:	97d2                	add	a5,a5,s4
    80006928:	8097ac23          	sw	s1,-2024(a5)
    release(&e1000_lock);
    8000692c:	854e                	mv	a0,s3
    8000692e:	ffffa097          	auipc	ra,0xffffa
    80006932:	252080e7          	jalr	594(ra) # 80000b80 <release>
    net_rx(mbuf);
    80006936:	855e                	mv	a0,s7
    80006938:	00000097          	auipc	ra,0x0
    8000693c:	3b0080e7          	jalr	944(ra) # 80006ce8 <net_rx>
    head = (head + 1) % RX_RING_SIZE;
    80006940:	0014879b          	addiw	a5,s1,1
    80006944:	00f7f493          	andi	s1,a5,15
  while((rx_ring[head].status & E1000_RXD_STAT_DD)) 
    80006948:	00449793          	slli	a5,s1,0x4
    8000694c:	97ce                	add	a5,a5,s3
    8000694e:	1ac7c783          	lbu	a5,428(a5)
    80006952:	8b85                	andi	a5,a5,1
    80006954:	f7d9                	bnez	a5,800068e2 <e1000_intr+0x4e>
  e1000_recv();
  // tell the e1000 we've seen this interrupt;
  // without this the e1000 won't raise any
  // further interrupts.
  regs[E1000_ICR];
    80006956:	00023797          	auipc	a5,0x23
    8000695a:	a327b783          	ld	a5,-1486(a5) # 80029388 <regs>
    8000695e:	0c07a783          	lw	a5,192(a5)
}
    80006962:	60a6                	ld	ra,72(sp)
    80006964:	6406                	ld	s0,64(sp)
    80006966:	74e2                	ld	s1,56(sp)
    80006968:	7942                	ld	s2,48(sp)
    8000696a:	79a2                	ld	s3,40(sp)
    8000696c:	7a02                	ld	s4,32(sp)
    8000696e:	6ae2                	ld	s5,24(sp)
    80006970:	6b42                	ld	s6,16(sp)
    80006972:	6ba2                	ld	s7,8(sp)
    80006974:	6161                	addi	sp,sp,80
    80006976:	8082                	ret

0000000080006978 <in_cksum>:

// This code is lifted from FreeBSD's ping.c, and is copyright by the Regents
// of the University of California.
static unsigned short
in_cksum(const unsigned char *addr, int len)
{
    80006978:	1101                	addi	sp,sp,-32
    8000697a:	ec22                	sd	s0,24(sp)
    8000697c:	1000                	addi	s0,sp,32
  int nleft = len;
  const unsigned short *w = (const unsigned short *)addr;
  unsigned int sum = 0;
  unsigned short answer = 0;
    8000697e:	fe041723          	sh	zero,-18(s0)
  /*
   * Our algorithm is simple, using a 32 bit accumulator (sum), we add
   * sequential 16 bit words to it, and at the end, fold back all the
   * carry bits from the top 16 bits into the lower 16 bits.
   */
  while (nleft > 1)  {
    80006982:	4785                	li	a5,1
    80006984:	04b7d963          	bge	a5,a1,800069d6 <in_cksum+0x5e>
    80006988:	ffe5879b          	addiw	a5,a1,-2
    8000698c:	0017d61b          	srliw	a2,a5,0x1
    80006990:	0017d71b          	srliw	a4,a5,0x1
    80006994:	0705                	addi	a4,a4,1
    80006996:	0706                	slli	a4,a4,0x1
    80006998:	972a                	add	a4,a4,a0
  unsigned int sum = 0;
    8000699a:	4781                	li	a5,0
    sum += *w++;
    8000699c:	0509                	addi	a0,a0,2
    8000699e:	ffe55683          	lhu	a3,-2(a0)
    800069a2:	9fb5                	addw	a5,a5,a3
  while (nleft > 1)  {
    800069a4:	fee51ce3          	bne	a0,a4,8000699c <in_cksum+0x24>
    800069a8:	35f9                	addiw	a1,a1,-2
    800069aa:	0016169b          	slliw	a3,a2,0x1
    800069ae:	9d95                	subw	a1,a1,a3
    nleft -= 2;
  }

  /* mop up an odd byte, if necessary */
  if (nleft == 1) {
    800069b0:	4685                	li	a3,1
    800069b2:	02d58563          	beq	a1,a3,800069dc <in_cksum+0x64>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    sum += answer;
  }

  /* add back carry outs from top 16 bits to low 16 bits */
  sum = (sum & 0xffff) + (sum >> 16);
    800069b6:	03079513          	slli	a0,a5,0x30
    800069ba:	9141                	srli	a0,a0,0x30
    800069bc:	0107d79b          	srliw	a5,a5,0x10
    800069c0:	9fa9                	addw	a5,a5,a0
  sum += (sum >> 16);
    800069c2:	0107d51b          	srliw	a0,a5,0x10
  /* guaranteed now that the lower 16 bits of sum are correct */

  answer = ~sum; /* truncate to 16 bits */
    800069c6:	9d3d                	addw	a0,a0,a5
    800069c8:	fff54513          	not	a0,a0
  return answer;
}
    800069cc:	1542                	slli	a0,a0,0x30
    800069ce:	9141                	srli	a0,a0,0x30
    800069d0:	6462                	ld	s0,24(sp)
    800069d2:	6105                	addi	sp,sp,32
    800069d4:	8082                	ret
  const unsigned short *w = (const unsigned short *)addr;
    800069d6:	872a                	mv	a4,a0
  unsigned int sum = 0;
    800069d8:	4781                	li	a5,0
    800069da:	bfd9                	j	800069b0 <in_cksum+0x38>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    800069dc:	00074703          	lbu	a4,0(a4)
    800069e0:	fee40723          	sb	a4,-18(s0)
    sum += answer;
    800069e4:	fee45703          	lhu	a4,-18(s0)
    800069e8:	9fb9                	addw	a5,a5,a4
    800069ea:	b7f1                	j	800069b6 <in_cksum+0x3e>

00000000800069ec <mbufpull>:
{
    800069ec:	1141                	addi	sp,sp,-16
    800069ee:	e422                	sd	s0,8(sp)
    800069f0:	0800                	addi	s0,sp,16
    800069f2:	87aa                	mv	a5,a0
  char *tmp = m->head;
    800069f4:	6508                	ld	a0,8(a0)
  if (m->len < len)
    800069f6:	4b98                	lw	a4,16(a5)
    800069f8:	00b76b63          	bltu	a4,a1,80006a0e <mbufpull+0x22>
  m->len -= len;
    800069fc:	9f0d                	subw	a4,a4,a1
    800069fe:	cb98                	sw	a4,16(a5)
  m->head += len;
    80006a00:	1582                	slli	a1,a1,0x20
    80006a02:	9181                	srli	a1,a1,0x20
    80006a04:	95aa                	add	a1,a1,a0
    80006a06:	e78c                	sd	a1,8(a5)
}
    80006a08:	6422                	ld	s0,8(sp)
    80006a0a:	0141                	addi	sp,sp,16
    80006a0c:	8082                	ret
    return 0;
    80006a0e:	4501                	li	a0,0
    80006a10:	bfe5                	j	80006a08 <mbufpull+0x1c>

0000000080006a12 <mbufpush>:
{
    80006a12:	87aa                	mv	a5,a0
  m->head -= len;
    80006a14:	02059713          	slli	a4,a1,0x20
    80006a18:	9301                	srli	a4,a4,0x20
    80006a1a:	6508                	ld	a0,8(a0)
    80006a1c:	8d19                	sub	a0,a0,a4
    80006a1e:	e788                	sd	a0,8(a5)
  if (m->head < m->buf)
    80006a20:	01478713          	addi	a4,a5,20
    80006a24:	00e56663          	bltu	a0,a4,80006a30 <mbufpush+0x1e>
  m->len += len;
    80006a28:	4b98                	lw	a4,16(a5)
    80006a2a:	9db9                	addw	a1,a1,a4
    80006a2c:	cb8c                	sw	a1,16(a5)
}
    80006a2e:	8082                	ret
{
    80006a30:	1141                	addi	sp,sp,-16
    80006a32:	e406                	sd	ra,8(sp)
    80006a34:	e022                	sd	s0,0(sp)
    80006a36:	0800                	addi	s0,sp,16
    panic("mbufpush");
    80006a38:	00003517          	auipc	a0,0x3
    80006a3c:	1b850513          	addi	a0,a0,440 # 80009bf0 <userret+0xb60>
    80006a40:	ffffa097          	auipc	ra,0xffffa
    80006a44:	b1a080e7          	jalr	-1254(ra) # 8000055a <panic>

0000000080006a48 <net_tx_eth>:

// sends an ethernet packet
static void
net_tx_eth(struct mbuf *m, uint16 ethtype)
{
    80006a48:	7179                	addi	sp,sp,-48
    80006a4a:	f406                	sd	ra,40(sp)
    80006a4c:	f022                	sd	s0,32(sp)
    80006a4e:	ec26                	sd	s1,24(sp)
    80006a50:	e84a                	sd	s2,16(sp)
    80006a52:	e44e                	sd	s3,8(sp)
    80006a54:	1800                	addi	s0,sp,48
    80006a56:	89aa                	mv	s3,a0
    80006a58:	892e                	mv	s2,a1
  struct eth *ethhdr;

  ethhdr = mbufpushhdr(m, *ethhdr);
    80006a5a:	45b9                	li	a1,14
    80006a5c:	00000097          	auipc	ra,0x0
    80006a60:	fb6080e7          	jalr	-74(ra) # 80006a12 <mbufpush>
    80006a64:	84aa                	mv	s1,a0
  memmove(ethhdr->shost, local_mac, ETHADDR_LEN);
    80006a66:	4619                	li	a2,6
    80006a68:	00003597          	auipc	a1,0x3
    80006a6c:	5e058593          	addi	a1,a1,1504 # 8000a048 <local_mac>
    80006a70:	0519                	addi	a0,a0,6
    80006a72:	ffffa097          	auipc	ra,0xffffa
    80006a76:	36c080e7          	jalr	876(ra) # 80000dde <memmove>
  // In a real networking stack, dhost would be set to the address discovered
  // through ARP. Because we don't support enough of the ARP protocol, set it
  // to broadcast instead.
  memmove(ethhdr->dhost, broadcast_mac, ETHADDR_LEN);
    80006a7a:	4619                	li	a2,6
    80006a7c:	00003597          	auipc	a1,0x3
    80006a80:	5c458593          	addi	a1,a1,1476 # 8000a040 <broadcast_mac>
    80006a84:	8526                	mv	a0,s1
    80006a86:	ffffa097          	auipc	ra,0xffffa
    80006a8a:	358080e7          	jalr	856(ra) # 80000dde <memmove>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
    80006a8e:	0089579b          	srliw	a5,s2,0x8
  ethhdr->type = htons(ethtype);
    80006a92:	00f48623          	sb	a5,12(s1)
    80006a96:	012486a3          	sb	s2,13(s1)
  if (e1000_transmit(m)) {
    80006a9a:	854e                	mv	a0,s3
    80006a9c:	00000097          	auipc	ra,0x0
    80006aa0:	d0c080e7          	jalr	-756(ra) # 800067a8 <e1000_transmit>
    80006aa4:	e901                	bnez	a0,80006ab4 <net_tx_eth+0x6c>
    mbuffree(m);
  }
}
    80006aa6:	70a2                	ld	ra,40(sp)
    80006aa8:	7402                	ld	s0,32(sp)
    80006aaa:	64e2                	ld	s1,24(sp)
    80006aac:	6942                	ld	s2,16(sp)
    80006aae:	69a2                	ld	s3,8(sp)
    80006ab0:	6145                	addi	sp,sp,48
    80006ab2:	8082                	ret
  kfree(m);
    80006ab4:	854e                	mv	a0,s3
    80006ab6:	ffffa097          	auipc	ra,0xffffa
    80006aba:	dca080e7          	jalr	-566(ra) # 80000880 <kfree>
}
    80006abe:	b7e5                	j	80006aa6 <net_tx_eth+0x5e>

0000000080006ac0 <mbufput>:
{
    80006ac0:	87aa                	mv	a5,a0
  char *tmp = m->head + m->len;
    80006ac2:	4918                	lw	a4,16(a0)
    80006ac4:	02071693          	slli	a3,a4,0x20
    80006ac8:	9281                	srli	a3,a3,0x20
    80006aca:	6508                	ld	a0,8(a0)
    80006acc:	9536                	add	a0,a0,a3
  m->len += len;
    80006ace:	9f2d                	addw	a4,a4,a1
    80006ad0:	0007069b          	sext.w	a3,a4
    80006ad4:	cb98                	sw	a4,16(a5)
  if (m->len > MBUF_SIZE)
    80006ad6:	6785                	lui	a5,0x1
    80006ad8:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    80006adc:	00d7e363          	bltu	a5,a3,80006ae2 <mbufput+0x22>
}
    80006ae0:	8082                	ret
{
    80006ae2:	1141                	addi	sp,sp,-16
    80006ae4:	e406                	sd	ra,8(sp)
    80006ae6:	e022                	sd	s0,0(sp)
    80006ae8:	0800                	addi	s0,sp,16
    panic("mbufput");
    80006aea:	00003517          	auipc	a0,0x3
    80006aee:	11650513          	addi	a0,a0,278 # 80009c00 <userret+0xb70>
    80006af2:	ffffa097          	auipc	ra,0xffffa
    80006af6:	a68080e7          	jalr	-1432(ra) # 8000055a <panic>

0000000080006afa <mbuftrim>:
{
    80006afa:	1141                	addi	sp,sp,-16
    80006afc:	e422                	sd	s0,8(sp)
    80006afe:	0800                	addi	s0,sp,16
  if (len > m->len)
    80006b00:	491c                	lw	a5,16(a0)
    80006b02:	00b7eb63          	bltu	a5,a1,80006b18 <mbuftrim+0x1e>
  m->len -= len;
    80006b06:	9f8d                	subw	a5,a5,a1
    80006b08:	c91c                	sw	a5,16(a0)
  return m->head + m->len;
    80006b0a:	1782                	slli	a5,a5,0x20
    80006b0c:	9381                	srli	a5,a5,0x20
    80006b0e:	6508                	ld	a0,8(a0)
    80006b10:	953e                	add	a0,a0,a5
}
    80006b12:	6422                	ld	s0,8(sp)
    80006b14:	0141                	addi	sp,sp,16
    80006b16:	8082                	ret
    return 0;
    80006b18:	4501                	li	a0,0
    80006b1a:	bfe5                	j	80006b12 <mbuftrim+0x18>

0000000080006b1c <mbufalloc>:
{
    80006b1c:	1101                	addi	sp,sp,-32
    80006b1e:	ec06                	sd	ra,24(sp)
    80006b20:	e822                	sd	s0,16(sp)
    80006b22:	e426                	sd	s1,8(sp)
    80006b24:	e04a                	sd	s2,0(sp)
    80006b26:	1000                	addi	s0,sp,32
  if (headroom > MBUF_SIZE)
    80006b28:	6785                	lui	a5,0x1
    80006b2a:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    return 0;
    80006b2e:	4901                	li	s2,0
  if (headroom > MBUF_SIZE)
    80006b30:	02a7eb63          	bltu	a5,a0,80006b66 <mbufalloc+0x4a>
    80006b34:	84aa                	mv	s1,a0
  m = kalloc();
    80006b36:	ffffa097          	auipc	ra,0xffffa
    80006b3a:	e46080e7          	jalr	-442(ra) # 8000097c <kalloc>
    80006b3e:	892a                	mv	s2,a0
  if (m == 0)
    80006b40:	c11d                	beqz	a0,80006b66 <mbufalloc+0x4a>
  m->next = 0;
    80006b42:	00053023          	sd	zero,0(a0)
  m->head = (char *)m->buf + headroom;
    80006b46:	0551                	addi	a0,a0,20
    80006b48:	1482                	slli	s1,s1,0x20
    80006b4a:	9081                	srli	s1,s1,0x20
    80006b4c:	94aa                	add	s1,s1,a0
    80006b4e:	00993423          	sd	s1,8(s2)
  m->len = 0;
    80006b52:	00092823          	sw	zero,16(s2)
  memset(m->buf, 0, sizeof(m->buf));
    80006b56:	6605                	lui	a2,0x1
    80006b58:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80006b5c:	4581                	li	a1,0
    80006b5e:	ffffa097          	auipc	ra,0xffffa
    80006b62:	220080e7          	jalr	544(ra) # 80000d7e <memset>
}
    80006b66:	854a                	mv	a0,s2
    80006b68:	60e2                	ld	ra,24(sp)
    80006b6a:	6442                	ld	s0,16(sp)
    80006b6c:	64a2                	ld	s1,8(sp)
    80006b6e:	6902                	ld	s2,0(sp)
    80006b70:	6105                	addi	sp,sp,32
    80006b72:	8082                	ret

0000000080006b74 <mbuffree>:
{
    80006b74:	1141                	addi	sp,sp,-16
    80006b76:	e406                	sd	ra,8(sp)
    80006b78:	e022                	sd	s0,0(sp)
    80006b7a:	0800                	addi	s0,sp,16
  kfree(m);
    80006b7c:	ffffa097          	auipc	ra,0xffffa
    80006b80:	d04080e7          	jalr	-764(ra) # 80000880 <kfree>
}
    80006b84:	60a2                	ld	ra,8(sp)
    80006b86:	6402                	ld	s0,0(sp)
    80006b88:	0141                	addi	sp,sp,16
    80006b8a:	8082                	ret

0000000080006b8c <mbufq_pushtail>:
{
    80006b8c:	1141                	addi	sp,sp,-16
    80006b8e:	e422                	sd	s0,8(sp)
    80006b90:	0800                	addi	s0,sp,16
  m->next = 0;
    80006b92:	0005b023          	sd	zero,0(a1)
  if (!q->head){
    80006b96:	611c                	ld	a5,0(a0)
    80006b98:	c799                	beqz	a5,80006ba6 <mbufq_pushtail+0x1a>
  q->tail->next = m;
    80006b9a:	651c                	ld	a5,8(a0)
    80006b9c:	e38c                	sd	a1,0(a5)
  q->tail = m;
    80006b9e:	e50c                	sd	a1,8(a0)
}
    80006ba0:	6422                	ld	s0,8(sp)
    80006ba2:	0141                	addi	sp,sp,16
    80006ba4:	8082                	ret
    q->head = q->tail = m;
    80006ba6:	e50c                	sd	a1,8(a0)
    80006ba8:	e10c                	sd	a1,0(a0)
    return;
    80006baa:	bfdd                	j	80006ba0 <mbufq_pushtail+0x14>

0000000080006bac <mbufq_pophead>:
{
    80006bac:	1141                	addi	sp,sp,-16
    80006bae:	e422                	sd	s0,8(sp)
    80006bb0:	0800                	addi	s0,sp,16
    80006bb2:	87aa                	mv	a5,a0
  struct mbuf *head = q->head;
    80006bb4:	6108                	ld	a0,0(a0)
  if (!head)
    80006bb6:	c119                	beqz	a0,80006bbc <mbufq_pophead+0x10>
  q->head = head->next;
    80006bb8:	6118                	ld	a4,0(a0)
    80006bba:	e398                	sd	a4,0(a5)
}
    80006bbc:	6422                	ld	s0,8(sp)
    80006bbe:	0141                	addi	sp,sp,16
    80006bc0:	8082                	ret

0000000080006bc2 <mbufq_empty>:
{
    80006bc2:	1141                	addi	sp,sp,-16
    80006bc4:	e422                	sd	s0,8(sp)
    80006bc6:	0800                	addi	s0,sp,16
  return q->head == 0;
    80006bc8:	6108                	ld	a0,0(a0)
}
    80006bca:	00153513          	seqz	a0,a0
    80006bce:	6422                	ld	s0,8(sp)
    80006bd0:	0141                	addi	sp,sp,16
    80006bd2:	8082                	ret

0000000080006bd4 <mbufq_init>:
{
    80006bd4:	1141                	addi	sp,sp,-16
    80006bd6:	e422                	sd	s0,8(sp)
    80006bd8:	0800                	addi	s0,sp,16
  q->head = 0;
    80006bda:	00053023          	sd	zero,0(a0)
}
    80006bde:	6422                	ld	s0,8(sp)
    80006be0:	0141                	addi	sp,sp,16
    80006be2:	8082                	ret

0000000080006be4 <net_tx_udp>:

// sends a UDP packet
void
net_tx_udp(struct mbuf *m, uint32 dip,
           uint16 sport, uint16 dport)
{
    80006be4:	7179                	addi	sp,sp,-48
    80006be6:	f406                	sd	ra,40(sp)
    80006be8:	f022                	sd	s0,32(sp)
    80006bea:	ec26                	sd	s1,24(sp)
    80006bec:	e84a                	sd	s2,16(sp)
    80006bee:	e44e                	sd	s3,8(sp)
    80006bf0:	e052                	sd	s4,0(sp)
    80006bf2:	1800                	addi	s0,sp,48
    80006bf4:	8a2a                	mv	s4,a0
    80006bf6:	892e                	mv	s2,a1
    80006bf8:	89b2                	mv	s3,a2
    80006bfa:	84b6                	mv	s1,a3
  struct udp *udphdr;

  // put the UDP header
  udphdr = mbufpushhdr(m, *udphdr);
    80006bfc:	45a1                	li	a1,8
    80006bfe:	00000097          	auipc	ra,0x0
    80006c02:	e14080e7          	jalr	-492(ra) # 80006a12 <mbufpush>
    80006c06:	0089d61b          	srliw	a2,s3,0x8
    80006c0a:	0089999b          	slliw	s3,s3,0x8
    80006c0e:	00c9e9b3          	or	s3,s3,a2
  udphdr->sport = htons(sport);
    80006c12:	01351023          	sh	s3,0(a0)
    80006c16:	0084d69b          	srliw	a3,s1,0x8
    80006c1a:	0084949b          	slliw	s1,s1,0x8
    80006c1e:	8cd5                	or	s1,s1,a3
  udphdr->dport = htons(dport);
    80006c20:	00951123          	sh	s1,2(a0)
  udphdr->ulen = htons(m->len);
    80006c24:	010a2783          	lw	a5,16(s4) # 3010 <_entry-0x7fffcff0>
    80006c28:	0087d713          	srli	a4,a5,0x8
    80006c2c:	0087979b          	slliw	a5,a5,0x8
    80006c30:	0ff77713          	andi	a4,a4,255
    80006c34:	8fd9                	or	a5,a5,a4
    80006c36:	00f51223          	sh	a5,4(a0)
  udphdr->sum = 0; // zero means no checksum is provided
    80006c3a:	00051323          	sh	zero,6(a0)
  iphdr = mbufpushhdr(m, *iphdr);
    80006c3e:	45d1                	li	a1,20
    80006c40:	8552                	mv	a0,s4
    80006c42:	00000097          	auipc	ra,0x0
    80006c46:	dd0080e7          	jalr	-560(ra) # 80006a12 <mbufpush>
    80006c4a:	84aa                	mv	s1,a0
  memset(iphdr, 0, sizeof(*iphdr));
    80006c4c:	4651                	li	a2,20
    80006c4e:	4581                	li	a1,0
    80006c50:	ffffa097          	auipc	ra,0xffffa
    80006c54:	12e080e7          	jalr	302(ra) # 80000d7e <memset>
  iphdr->ip_vhl = (4 << 4) | (20 >> 2);
    80006c58:	04500793          	li	a5,69
    80006c5c:	00f48023          	sb	a5,0(s1)
  iphdr->ip_p = proto;
    80006c60:	47c5                	li	a5,17
    80006c62:	00f484a3          	sb	a5,9(s1)
  iphdr->ip_src = htonl(local_ip);
    80006c66:	0f0207b7          	lui	a5,0xf020
    80006c6a:	07a9                	addi	a5,a5,10
    80006c6c:	c4dc                	sw	a5,12(s1)
          ((val & 0xff00U) >> 8));
}

static inline uint32 bswapl(uint32 val)
{
  return (((val & 0x000000ffUL) << 24) |
    80006c6e:	0189179b          	slliw	a5,s2,0x18
          ((val & 0x0000ff00UL) << 8) |
          ((val & 0x00ff0000UL) >> 8) |
          ((val & 0xff000000UL) >> 24));
    80006c72:	0189571b          	srliw	a4,s2,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006c76:	8fd9                	or	a5,a5,a4
          ((val & 0x0000ff00UL) << 8) |
    80006c78:	0089171b          	slliw	a4,s2,0x8
    80006c7c:	00ff06b7          	lui	a3,0xff0
    80006c80:	8f75                	and	a4,a4,a3
          ((val & 0x00ff0000UL) >> 8) |
    80006c82:	8fd9                	or	a5,a5,a4
    80006c84:	0089591b          	srliw	s2,s2,0x8
    80006c88:	65c1                	lui	a1,0x10
    80006c8a:	f0058593          	addi	a1,a1,-256 # ff00 <_entry-0x7fff0100>
    80006c8e:	00b97933          	and	s2,s2,a1
    80006c92:	0127e933          	or	s2,a5,s2
  iphdr->ip_dst = htonl(dip);
    80006c96:	0124a823          	sw	s2,16(s1)
  iphdr->ip_len = htons(m->len);
    80006c9a:	010a2783          	lw	a5,16(s4)
  return (((val & 0x00ffU) << 8) |
    80006c9e:	0087d713          	srli	a4,a5,0x8
    80006ca2:	0087979b          	slliw	a5,a5,0x8
    80006ca6:	0ff77713          	andi	a4,a4,255
    80006caa:	8fd9                	or	a5,a5,a4
    80006cac:	00f49123          	sh	a5,2(s1)
  iphdr->ip_ttl = 100;
    80006cb0:	06400793          	li	a5,100
    80006cb4:	00f48423          	sb	a5,8(s1)
  iphdr->ip_sum = in_cksum((unsigned char *)iphdr, sizeof(*iphdr));
    80006cb8:	45d1                	li	a1,20
    80006cba:	8526                	mv	a0,s1
    80006cbc:	00000097          	auipc	ra,0x0
    80006cc0:	cbc080e7          	jalr	-836(ra) # 80006978 <in_cksum>
    80006cc4:	00a49523          	sh	a0,10(s1)
  net_tx_eth(m, ETHTYPE_IP);
    80006cc8:	6585                	lui	a1,0x1
    80006cca:	80058593          	addi	a1,a1,-2048 # 800 <_entry-0x7ffff800>
    80006cce:	8552                	mv	a0,s4
    80006cd0:	00000097          	auipc	ra,0x0
    80006cd4:	d78080e7          	jalr	-648(ra) # 80006a48 <net_tx_eth>

  // now on to the IP layer
  net_tx_ip(m, IPPROTO_UDP, dip);
}
    80006cd8:	70a2                	ld	ra,40(sp)
    80006cda:	7402                	ld	s0,32(sp)
    80006cdc:	64e2                	ld	s1,24(sp)
    80006cde:	6942                	ld	s2,16(sp)
    80006ce0:	69a2                	ld	s3,8(sp)
    80006ce2:	6a02                	ld	s4,0(sp)
    80006ce4:	6145                	addi	sp,sp,48
    80006ce6:	8082                	ret

0000000080006ce8 <net_rx>:
}

// called by e1000 driver's interrupt handler to deliver a packet to the
// networking stack
void net_rx(struct mbuf *m)
{
    80006ce8:	715d                	addi	sp,sp,-80
    80006cea:	e486                	sd	ra,72(sp)
    80006cec:	e0a2                	sd	s0,64(sp)
    80006cee:	fc26                	sd	s1,56(sp)
    80006cf0:	f84a                	sd	s2,48(sp)
    80006cf2:	f44e                	sd	s3,40(sp)
    80006cf4:	f052                	sd	s4,32(sp)
    80006cf6:	ec56                	sd	s5,24(sp)
    80006cf8:	0880                	addi	s0,sp,80
    80006cfa:	84aa                	mv	s1,a0
  struct eth *ethhdr;
  uint16 type;

  ethhdr = mbufpullhdr(m, *ethhdr);
    80006cfc:	45b9                	li	a1,14
    80006cfe:	00000097          	auipc	ra,0x0
    80006d02:	cee080e7          	jalr	-786(ra) # 800069ec <mbufpull>
  if (!ethhdr) {
    80006d06:	c521                	beqz	a0,80006d4e <net_rx+0x66>
    mbuffree(m);
    return;
  }

  type = ntohs(ethhdr->type);
    80006d08:	00c54783          	lbu	a5,12(a0)
    80006d0c:	00d54703          	lbu	a4,13(a0)
    80006d10:	0722                	slli	a4,a4,0x8
    80006d12:	8fd9                	or	a5,a5,a4
    80006d14:	0087979b          	slliw	a5,a5,0x8
    80006d18:	8321                	srli	a4,a4,0x8
    80006d1a:	8fd9                	or	a5,a5,a4
    80006d1c:	17c2                	slli	a5,a5,0x30
    80006d1e:	93c1                	srli	a5,a5,0x30
  if (type == ETHTYPE_IP)
    80006d20:	8007871b          	addiw	a4,a5,-2048
    80006d24:	cb1d                	beqz	a4,80006d5a <net_rx+0x72>
    net_rx_ip(m);
  else if (type == ETHTYPE_ARP)
    80006d26:	2781                	sext.w	a5,a5
    80006d28:	6705                	lui	a4,0x1
    80006d2a:	80670713          	addi	a4,a4,-2042 # 806 <_entry-0x7ffff7fa>
    80006d2e:	18e78e63          	beq	a5,a4,80006eca <net_rx+0x1e2>
  kfree(m);
    80006d32:	8526                	mv	a0,s1
    80006d34:	ffffa097          	auipc	ra,0xffffa
    80006d38:	b4c080e7          	jalr	-1204(ra) # 80000880 <kfree>
    net_rx_arp(m);
  else
    mbuffree(m);
}
    80006d3c:	60a6                	ld	ra,72(sp)
    80006d3e:	6406                	ld	s0,64(sp)
    80006d40:	74e2                	ld	s1,56(sp)
    80006d42:	7942                	ld	s2,48(sp)
    80006d44:	79a2                	ld	s3,40(sp)
    80006d46:	7a02                	ld	s4,32(sp)
    80006d48:	6ae2                	ld	s5,24(sp)
    80006d4a:	6161                	addi	sp,sp,80
    80006d4c:	8082                	ret
  kfree(m);
    80006d4e:	8526                	mv	a0,s1
    80006d50:	ffffa097          	auipc	ra,0xffffa
    80006d54:	b30080e7          	jalr	-1232(ra) # 80000880 <kfree>
}
    80006d58:	b7d5                	j	80006d3c <net_rx+0x54>
  iphdr = mbufpullhdr(m, *iphdr);
    80006d5a:	45d1                	li	a1,20
    80006d5c:	8526                	mv	a0,s1
    80006d5e:	00000097          	auipc	ra,0x0
    80006d62:	c8e080e7          	jalr	-882(ra) # 800069ec <mbufpull>
    80006d66:	892a                	mv	s2,a0
  if (!iphdr)
    80006d68:	c519                	beqz	a0,80006d76 <net_rx+0x8e>
  if (iphdr->ip_vhl != ((4 << 4) | (20 >> 2)))
    80006d6a:	00054703          	lbu	a4,0(a0)
    80006d6e:	04500793          	li	a5,69
    80006d72:	00f70863          	beq	a4,a5,80006d82 <net_rx+0x9a>
  kfree(m);
    80006d76:	8526                	mv	a0,s1
    80006d78:	ffffa097          	auipc	ra,0xffffa
    80006d7c:	b08080e7          	jalr	-1272(ra) # 80000880 <kfree>
}
    80006d80:	bf75                	j	80006d3c <net_rx+0x54>
  if (in_cksum((unsigned char *)iphdr, sizeof(*iphdr)))
    80006d82:	45d1                	li	a1,20
    80006d84:	00000097          	auipc	ra,0x0
    80006d88:	bf4080e7          	jalr	-1036(ra) # 80006978 <in_cksum>
    80006d8c:	f56d                	bnez	a0,80006d76 <net_rx+0x8e>
    80006d8e:	00695783          	lhu	a5,6(s2)
    80006d92:	0087d713          	srli	a4,a5,0x8
    80006d96:	0087979b          	slliw	a5,a5,0x8
    80006d9a:	0ff77713          	andi	a4,a4,255
    80006d9e:	8fd9                	or	a5,a5,a4
  if (htons(iphdr->ip_off) != 0)
    80006da0:	17c2                	slli	a5,a5,0x30
    80006da2:	93c1                	srli	a5,a5,0x30
    80006da4:	fbe9                	bnez	a5,80006d76 <net_rx+0x8e>
  if (htonl(iphdr->ip_dst) != local_ip)
    80006da6:	01092703          	lw	a4,16(s2)
  return (((val & 0x000000ffUL) << 24) |
    80006daa:	0187179b          	slliw	a5,a4,0x18
          ((val & 0xff000000UL) >> 24));
    80006dae:	0187569b          	srliw	a3,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006db2:	8fd5                	or	a5,a5,a3
          ((val & 0x0000ff00UL) << 8) |
    80006db4:	0087169b          	slliw	a3,a4,0x8
    80006db8:	00ff0637          	lui	a2,0xff0
    80006dbc:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    80006dbe:	8fd5                	or	a5,a5,a3
    80006dc0:	0087571b          	srliw	a4,a4,0x8
    80006dc4:	66c1                	lui	a3,0x10
    80006dc6:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80006dca:	8f75                	and	a4,a4,a3
    80006dcc:	8fd9                	or	a5,a5,a4
    80006dce:	2781                	sext.w	a5,a5
    80006dd0:	0a000737          	lui	a4,0xa000
    80006dd4:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    80006dd8:	f8e79fe3          	bne	a5,a4,80006d76 <net_rx+0x8e>
  if (iphdr->ip_p != IPPROTO_UDP)
    80006ddc:	00994703          	lbu	a4,9(s2)
    80006de0:	47c5                	li	a5,17
    80006de2:	f8f71ae3          	bne	a4,a5,80006d76 <net_rx+0x8e>
  return (((val & 0x00ffU) << 8) |
    80006de6:	00295783          	lhu	a5,2(s2)
    80006dea:	0087d713          	srli	a4,a5,0x8
    80006dee:	0087999b          	slliw	s3,a5,0x8
    80006df2:	0ff77793          	andi	a5,a4,255
    80006df6:	00f9e9b3          	or	s3,s3,a5
    80006dfa:	19c2                	slli	s3,s3,0x30
    80006dfc:	0309d993          	srli	s3,s3,0x30
  len = ntohs(iphdr->ip_len) - sizeof(*iphdr);
    80006e00:	fec9879b          	addiw	a5,s3,-20
    80006e04:	03079a13          	slli	s4,a5,0x30
    80006e08:	030a5a13          	srli	s4,s4,0x30
  udphdr = mbufpullhdr(m, *udphdr);
    80006e0c:	45a1                	li	a1,8
    80006e0e:	8526                	mv	a0,s1
    80006e10:	00000097          	auipc	ra,0x0
    80006e14:	bdc080e7          	jalr	-1060(ra) # 800069ec <mbufpull>
    80006e18:	8aaa                	mv	s5,a0
  if (!udphdr)
    80006e1a:	c915                	beqz	a0,80006e4e <net_rx+0x166>
    80006e1c:	00455783          	lhu	a5,4(a0)
    80006e20:	0087d713          	srli	a4,a5,0x8
    80006e24:	0087979b          	slliw	a5,a5,0x8
    80006e28:	0ff77713          	andi	a4,a4,255
    80006e2c:	8fd9                	or	a5,a5,a4
  if (ntohs(udphdr->ulen) != len)
    80006e2e:	2a01                	sext.w	s4,s4
    80006e30:	17c2                	slli	a5,a5,0x30
    80006e32:	93c1                	srli	a5,a5,0x30
    80006e34:	00fa1d63          	bne	s4,a5,80006e4e <net_rx+0x166>
  len -= sizeof(*udphdr);
    80006e38:	fe49879b          	addiw	a5,s3,-28
  if (len > m->len)
    80006e3c:	0107979b          	slliw	a5,a5,0x10
    80006e40:	0107d79b          	srliw	a5,a5,0x10
    80006e44:	0007871b          	sext.w	a4,a5
    80006e48:	488c                	lw	a1,16(s1)
    80006e4a:	00e5f863          	bgeu	a1,a4,80006e5a <net_rx+0x172>
  kfree(m);
    80006e4e:	8526                	mv	a0,s1
    80006e50:	ffffa097          	auipc	ra,0xffffa
    80006e54:	a30080e7          	jalr	-1488(ra) # 80000880 <kfree>
}
    80006e58:	b5d5                	j	80006d3c <net_rx+0x54>
  mbuftrim(m, m->len - len);
    80006e5a:	9d9d                	subw	a1,a1,a5
    80006e5c:	8526                	mv	a0,s1
    80006e5e:	00000097          	auipc	ra,0x0
    80006e62:	c9c080e7          	jalr	-868(ra) # 80006afa <mbuftrim>
  sip = ntohl(iphdr->ip_src);
    80006e66:	00c92783          	lw	a5,12(s2)
    80006e6a:	000ad703          	lhu	a4,0(s5)
    80006e6e:	00875693          	srli	a3,a4,0x8
    80006e72:	0087171b          	slliw	a4,a4,0x8
    80006e76:	0ff6f693          	andi	a3,a3,255
    80006e7a:	8ed9                	or	a3,a3,a4
    80006e7c:	002ad703          	lhu	a4,2(s5)
    80006e80:	00875613          	srli	a2,a4,0x8
    80006e84:	0087171b          	slliw	a4,a4,0x8
    80006e88:	0ff67613          	andi	a2,a2,255
    80006e8c:	8e59                	or	a2,a2,a4
  return (((val & 0x000000ffUL) << 24) |
    80006e8e:	0187971b          	slliw	a4,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006e92:	0187d59b          	srliw	a1,a5,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006e96:	8f4d                	or	a4,a4,a1
          ((val & 0x0000ff00UL) << 8) |
    80006e98:	0087959b          	slliw	a1,a5,0x8
    80006e9c:	00ff0537          	lui	a0,0xff0
    80006ea0:	8de9                	and	a1,a1,a0
          ((val & 0x00ff0000UL) >> 8) |
    80006ea2:	8f4d                	or	a4,a4,a1
    80006ea4:	0087d79b          	srliw	a5,a5,0x8
    80006ea8:	65c1                	lui	a1,0x10
    80006eaa:	f0058593          	addi	a1,a1,-256 # ff00 <_entry-0x7fff0100>
    80006eae:	8fed                	and	a5,a5,a1
    80006eb0:	8fd9                	or	a5,a5,a4
  sockrecvudp(m, sip, dport, sport);
    80006eb2:	16c2                	slli	a3,a3,0x30
    80006eb4:	92c1                	srli	a3,a3,0x30
    80006eb6:	1642                	slli	a2,a2,0x30
    80006eb8:	9241                	srli	a2,a2,0x30
    80006eba:	0007859b          	sext.w	a1,a5
    80006ebe:	8526                	mv	a0,s1
    80006ec0:	00000097          	auipc	ra,0x0
    80006ec4:	5b8080e7          	jalr	1464(ra) # 80007478 <sockrecvudp>
  return;
    80006ec8:	bd95                	j	80006d3c <net_rx+0x54>
  arphdr = mbufpullhdr(m, *arphdr);
    80006eca:	45f1                	li	a1,28
    80006ecc:	8526                	mv	a0,s1
    80006ece:	00000097          	auipc	ra,0x0
    80006ed2:	b1e080e7          	jalr	-1250(ra) # 800069ec <mbufpull>
    80006ed6:	892a                	mv	s2,a0
  if (!arphdr)
    80006ed8:	c179                	beqz	a0,80006f9e <net_rx+0x2b6>
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    80006eda:	00054783          	lbu	a5,0(a0) # ff0000 <_entry-0x7f010000>
    80006ede:	00154703          	lbu	a4,1(a0)
    80006ee2:	0722                	slli	a4,a4,0x8
    80006ee4:	8fd9                	or	a5,a5,a4
  return (((val & 0x00ffU) << 8) |
    80006ee6:	0087979b          	slliw	a5,a5,0x8
    80006eea:	8321                	srli	a4,a4,0x8
    80006eec:	8fd9                	or	a5,a5,a4
    80006eee:	17c2                	slli	a5,a5,0x30
    80006ef0:	93c1                	srli	a5,a5,0x30
    80006ef2:	4705                	li	a4,1
    80006ef4:	0ae79563          	bne	a5,a4,80006f9e <net_rx+0x2b6>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    80006ef8:	00254783          	lbu	a5,2(a0)
    80006efc:	00354703          	lbu	a4,3(a0)
    80006f00:	0722                	slli	a4,a4,0x8
    80006f02:	8fd9                	or	a5,a5,a4
    80006f04:	0087979b          	slliw	a5,a5,0x8
    80006f08:	8321                	srli	a4,a4,0x8
    80006f0a:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    80006f0c:	0107979b          	slliw	a5,a5,0x10
    80006f10:	0107d79b          	srliw	a5,a5,0x10
    80006f14:	8007879b          	addiw	a5,a5,-2048
    80006f18:	e3d9                	bnez	a5,80006f9e <net_rx+0x2b6>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    80006f1a:	00454703          	lbu	a4,4(a0)
    80006f1e:	4799                	li	a5,6
    80006f20:	06f71f63          	bne	a4,a5,80006f9e <net_rx+0x2b6>
      arphdr->hln != ETHADDR_LEN ||
    80006f24:	00554703          	lbu	a4,5(a0)
    80006f28:	4791                	li	a5,4
    80006f2a:	06f71a63          	bne	a4,a5,80006f9e <net_rx+0x2b6>
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    80006f2e:	00654783          	lbu	a5,6(a0)
    80006f32:	00754703          	lbu	a4,7(a0)
    80006f36:	0722                	slli	a4,a4,0x8
    80006f38:	8fd9                	or	a5,a5,a4
    80006f3a:	0087979b          	slliw	a5,a5,0x8
    80006f3e:	8321                	srli	a4,a4,0x8
    80006f40:	8fd9                	or	a5,a5,a4
    80006f42:	17c2                	slli	a5,a5,0x30
    80006f44:	93c1                	srli	a5,a5,0x30
    80006f46:	4705                	li	a4,1
    80006f48:	04e79b63          	bne	a5,a4,80006f9e <net_rx+0x2b6>
  tip = ntohl(arphdr->tip); // target IP address
    80006f4c:	01854783          	lbu	a5,24(a0)
    80006f50:	01954703          	lbu	a4,25(a0)
    80006f54:	0722                	slli	a4,a4,0x8
    80006f56:	8f5d                	or	a4,a4,a5
    80006f58:	01a54783          	lbu	a5,26(a0)
    80006f5c:	07c2                	slli	a5,a5,0x10
    80006f5e:	8f5d                	or	a4,a4,a5
    80006f60:	01b54783          	lbu	a5,27(a0)
    80006f64:	07e2                	slli	a5,a5,0x18
    80006f66:	8fd9                	or	a5,a5,a4
    80006f68:	0007871b          	sext.w	a4,a5
  return (((val & 0x000000ffUL) << 24) |
    80006f6c:	0187979b          	slliw	a5,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006f70:	0187569b          	srliw	a3,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006f74:	8fd5                	or	a5,a5,a3
          ((val & 0x0000ff00UL) << 8) |
    80006f76:	0087169b          	slliw	a3,a4,0x8
    80006f7a:	00ff0637          	lui	a2,0xff0
    80006f7e:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    80006f80:	8fd5                	or	a5,a5,a3
    80006f82:	0087571b          	srliw	a4,a4,0x8
    80006f86:	66c1                	lui	a3,0x10
    80006f88:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80006f8c:	8f75                	and	a4,a4,a3
    80006f8e:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    80006f90:	2781                	sext.w	a5,a5
    80006f92:	0a000737          	lui	a4,0xa000
    80006f96:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    80006f9a:	00e78863          	beq	a5,a4,80006faa <net_rx+0x2c2>
  kfree(m);
    80006f9e:	8526                	mv	a0,s1
    80006fa0:	ffffa097          	auipc	ra,0xffffa
    80006fa4:	8e0080e7          	jalr	-1824(ra) # 80000880 <kfree>
}
    80006fa8:	bb51                	j	80006d3c <net_rx+0x54>
  memmove(smac, arphdr->sha, ETHADDR_LEN); // sender's ethernet address
    80006faa:	4619                	li	a2,6
    80006fac:	00850593          	addi	a1,a0,8
    80006fb0:	fb840513          	addi	a0,s0,-72
    80006fb4:	ffffa097          	auipc	ra,0xffffa
    80006fb8:	e2a080e7          	jalr	-470(ra) # 80000dde <memmove>
  sip = ntohl(arphdr->sip); // sender's IP address (qemu's slirp)
    80006fbc:	00e94783          	lbu	a5,14(s2)
    80006fc0:	00f94703          	lbu	a4,15(s2)
    80006fc4:	0722                	slli	a4,a4,0x8
    80006fc6:	8f5d                	or	a4,a4,a5
    80006fc8:	01094783          	lbu	a5,16(s2)
    80006fcc:	07c2                	slli	a5,a5,0x10
    80006fce:	8f5d                	or	a4,a4,a5
    80006fd0:	01194783          	lbu	a5,17(s2)
    80006fd4:	07e2                	slli	a5,a5,0x18
    80006fd6:	8fd9                	or	a5,a5,a4
    80006fd8:	0007871b          	sext.w	a4,a5
  return (((val & 0x000000ffUL) << 24) |
    80006fdc:	0187991b          	slliw	s2,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006fe0:	0187579b          	srliw	a5,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006fe4:	00f96933          	or	s2,s2,a5
          ((val & 0x0000ff00UL) << 8) |
    80006fe8:	0087179b          	slliw	a5,a4,0x8
    80006fec:	00ff06b7          	lui	a3,0xff0
    80006ff0:	8ff5                	and	a5,a5,a3
          ((val & 0x00ff0000UL) >> 8) |
    80006ff2:	00f96933          	or	s2,s2,a5
    80006ff6:	0087579b          	srliw	a5,a4,0x8
    80006ffa:	6741                	lui	a4,0x10
    80006ffc:	f0070713          	addi	a4,a4,-256 # ff00 <_entry-0x7fff0100>
    80007000:	8ff9                	and	a5,a5,a4
    80007002:	00f96933          	or	s2,s2,a5
    80007006:	2901                	sext.w	s2,s2
  m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    80007008:	08000513          	li	a0,128
    8000700c:	00000097          	auipc	ra,0x0
    80007010:	b10080e7          	jalr	-1264(ra) # 80006b1c <mbufalloc>
    80007014:	8a2a                	mv	s4,a0
  if (!m)
    80007016:	d541                	beqz	a0,80006f9e <net_rx+0x2b6>
  arphdr = mbufputhdr(m, *arphdr);
    80007018:	45f1                	li	a1,28
    8000701a:	00000097          	auipc	ra,0x0
    8000701e:	aa6080e7          	jalr	-1370(ra) # 80006ac0 <mbufput>
    80007022:	89aa                	mv	s3,a0
  arphdr->hrd = htons(ARP_HRD_ETHER);
    80007024:	00050023          	sb	zero,0(a0)
    80007028:	4785                	li	a5,1
    8000702a:	00f500a3          	sb	a5,1(a0)
  arphdr->pro = htons(ETHTYPE_IP);
    8000702e:	47a1                	li	a5,8
    80007030:	00f50123          	sb	a5,2(a0)
    80007034:	000501a3          	sb	zero,3(a0)
  arphdr->hln = ETHADDR_LEN;
    80007038:	4799                	li	a5,6
    8000703a:	00f50223          	sb	a5,4(a0)
  arphdr->pln = sizeof(uint32);
    8000703e:	4791                	li	a5,4
    80007040:	00f502a3          	sb	a5,5(a0)
  arphdr->op = htons(op);
    80007044:	00050323          	sb	zero,6(a0)
    80007048:	4a89                	li	s5,2
    8000704a:	015503a3          	sb	s5,7(a0)
  memmove(arphdr->sha, local_mac, ETHADDR_LEN);
    8000704e:	4619                	li	a2,6
    80007050:	00003597          	auipc	a1,0x3
    80007054:	ff858593          	addi	a1,a1,-8 # 8000a048 <local_mac>
    80007058:	0521                	addi	a0,a0,8
    8000705a:	ffffa097          	auipc	ra,0xffffa
    8000705e:	d84080e7          	jalr	-636(ra) # 80000dde <memmove>
  arphdr->sip = htonl(local_ip);
    80007062:	47a9                	li	a5,10
    80007064:	00f98723          	sb	a5,14(s3)
    80007068:	000987a3          	sb	zero,15(s3)
    8000706c:	01598823          	sb	s5,16(s3)
    80007070:	47bd                	li	a5,15
    80007072:	00f988a3          	sb	a5,17(s3)
  memmove(arphdr->tha, dmac, ETHADDR_LEN);
    80007076:	4619                	li	a2,6
    80007078:	fb840593          	addi	a1,s0,-72
    8000707c:	01298513          	addi	a0,s3,18
    80007080:	ffffa097          	auipc	ra,0xffffa
    80007084:	d5e080e7          	jalr	-674(ra) # 80000dde <memmove>
  return (((val & 0x000000ffUL) << 24) |
    80007088:	0189171b          	slliw	a4,s2,0x18
          ((val & 0xff000000UL) >> 24));
    8000708c:	0189579b          	srliw	a5,s2,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80007090:	8f5d                	or	a4,a4,a5
          ((val & 0x0000ff00UL) << 8) |
    80007092:	0089179b          	slliw	a5,s2,0x8
    80007096:	00ff06b7          	lui	a3,0xff0
    8000709a:	8ff5                	and	a5,a5,a3
          ((val & 0x00ff0000UL) >> 8) |
    8000709c:	8f5d                	or	a4,a4,a5
    8000709e:	0089579b          	srliw	a5,s2,0x8
    800070a2:	66c1                	lui	a3,0x10
    800070a4:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    800070a8:	8ff5                	and	a5,a5,a3
    800070aa:	8fd9                	or	a5,a5,a4
  arphdr->tip = htonl(dip);
    800070ac:	00e98c23          	sb	a4,24(s3)
    800070b0:	0087d71b          	srliw	a4,a5,0x8
    800070b4:	00e98ca3          	sb	a4,25(s3)
    800070b8:	0107d71b          	srliw	a4,a5,0x10
    800070bc:	00e98d23          	sb	a4,26(s3)
    800070c0:	0187d79b          	srliw	a5,a5,0x18
    800070c4:	00f98da3          	sb	a5,27(s3)
  net_tx_eth(m, ETHTYPE_ARP);
    800070c8:	6585                	lui	a1,0x1
    800070ca:	80658593          	addi	a1,a1,-2042 # 806 <_entry-0x7ffff7fa>
    800070ce:	8552                	mv	a0,s4
    800070d0:	00000097          	auipc	ra,0x0
    800070d4:	978080e7          	jalr	-1672(ra) # 80006a48 <net_tx_eth>
  return 0;
    800070d8:	b5d9                	j	80006f9e <net_rx+0x2b6>

00000000800070da <sockinit>:
static struct spinlock lock;
static struct sock *sockets;

void
sockinit(void)
{
    800070da:	1141                	addi	sp,sp,-16
    800070dc:	e406                	sd	ra,8(sp)
    800070de:	e022                	sd	s0,0(sp)
    800070e0:	0800                	addi	s0,sp,16
  initlock(&lock, "socktbl");
    800070e2:	00003597          	auipc	a1,0x3
    800070e6:	b2658593          	addi	a1,a1,-1242 # 80009c08 <userret+0xb78>
    800070ea:	00022517          	auipc	a0,0x22
    800070ee:	23650513          	addi	a0,a0,566 # 80029320 <lock>
    800070f2:	ffffa097          	auipc	ra,0xffffa
    800070f6:	8ea080e7          	jalr	-1814(ra) # 800009dc <initlock>
}
    800070fa:	60a2                	ld	ra,8(sp)
    800070fc:	6402                	ld	s0,0(sp)
    800070fe:	0141                	addi	sp,sp,16
    80007100:	8082                	ret

0000000080007102 <sockalloc>:

int
sockalloc(struct file **f, uint32 raddr, uint16 lport, uint16 rport)
{
    80007102:	7139                	addi	sp,sp,-64
    80007104:	fc06                	sd	ra,56(sp)
    80007106:	f822                	sd	s0,48(sp)
    80007108:	f426                	sd	s1,40(sp)
    8000710a:	f04a                	sd	s2,32(sp)
    8000710c:	ec4e                	sd	s3,24(sp)
    8000710e:	e852                	sd	s4,16(sp)
    80007110:	e456                	sd	s5,8(sp)
    80007112:	0080                	addi	s0,sp,64
    80007114:	892a                	mv	s2,a0
    80007116:	84ae                	mv	s1,a1
    80007118:	8a32                	mv	s4,a2
    8000711a:	89b6                	mv	s3,a3
  struct sock *si, *pos;

  si = 0;
  *f = 0;
    8000711c:	00053023          	sd	zero,0(a0)
  if ((*f = filealloc()) == 0)
    80007120:	ffffd097          	auipc	ra,0xffffd
    80007124:	4e6080e7          	jalr	1254(ra) # 80004606 <filealloc>
    80007128:	00a93023          	sd	a0,0(s2)
    8000712c:	c975                	beqz	a0,80007220 <sockalloc+0x11e>
    goto bad;
  if ((si = (struct sock*)kalloc()) == 0)
    8000712e:	ffffa097          	auipc	ra,0xffffa
    80007132:	84e080e7          	jalr	-1970(ra) # 8000097c <kalloc>
    80007136:	8aaa                	mv	s5,a0
    80007138:	c15d                	beqz	a0,800071de <sockalloc+0xdc>
    goto bad;

  // initialize objects
  si->raddr = raddr;
    8000713a:	c504                	sw	s1,8(a0)
  si->lport = lport;
    8000713c:	01451623          	sh	s4,12(a0)
  si->rport = rport;
    80007140:	01351723          	sh	s3,14(a0)
  initlock(&si->lock, "sock");
    80007144:	00003597          	auipc	a1,0x3
    80007148:	acc58593          	addi	a1,a1,-1332 # 80009c10 <userret+0xb80>
    8000714c:	0541                	addi	a0,a0,16
    8000714e:	ffffa097          	auipc	ra,0xffffa
    80007152:	88e080e7          	jalr	-1906(ra) # 800009dc <initlock>
  mbufq_init(&si->rxq);
    80007156:	030a8513          	addi	a0,s5,48
    8000715a:	00000097          	auipc	ra,0x0
    8000715e:	a7a080e7          	jalr	-1414(ra) # 80006bd4 <mbufq_init>
  (*f)->type = FD_SOCK;
    80007162:	00093783          	ld	a5,0(s2)
    80007166:	4711                	li	a4,4
    80007168:	c398                	sw	a4,0(a5)
  (*f)->readable = 1;
    8000716a:	00093703          	ld	a4,0(s2)
    8000716e:	4785                	li	a5,1
    80007170:	00f70423          	sb	a5,8(a4)
  (*f)->writable = 1;
    80007174:	00093703          	ld	a4,0(s2)
    80007178:	00f704a3          	sb	a5,9(a4)
  (*f)->sock = si;
    8000717c:	00093783          	ld	a5,0(s2)
    80007180:	0357b423          	sd	s5,40(a5) # f020028 <_entry-0x70fdffd8>

  // add to list of sockets
  acquire(&lock);
    80007184:	00022517          	auipc	a0,0x22
    80007188:	19c50513          	addi	a0,a0,412 # 80029320 <lock>
    8000718c:	ffffa097          	auipc	ra,0xffffa
    80007190:	924080e7          	jalr	-1756(ra) # 80000ab0 <acquire>
  pos = sockets;
    80007194:	00022597          	auipc	a1,0x22
    80007198:	1fc5b583          	ld	a1,508(a1) # 80029390 <sockets>
  while (pos) {
    8000719c:	c9b1                	beqz	a1,800071f0 <sockalloc+0xee>
  pos = sockets;
    8000719e:	87ae                	mv	a5,a1
    if (pos->raddr == raddr &&
    800071a0:	000a061b          	sext.w	a2,s4
        pos->lport == lport &&
    800071a4:	0009869b          	sext.w	a3,s3
    800071a8:	a019                	j	800071ae <sockalloc+0xac>
	pos->rport == rport) {
      release(&lock);
      goto bad;
    }
    pos = pos->next;
    800071aa:	639c                	ld	a5,0(a5)
  while (pos) {
    800071ac:	c3b1                	beqz	a5,800071f0 <sockalloc+0xee>
    if (pos->raddr == raddr &&
    800071ae:	4798                	lw	a4,8(a5)
    800071b0:	fe971de3          	bne	a4,s1,800071aa <sockalloc+0xa8>
    800071b4:	00c7d703          	lhu	a4,12(a5)
    800071b8:	fec719e3          	bne	a4,a2,800071aa <sockalloc+0xa8>
        pos->lport == lport &&
    800071bc:	00e7d703          	lhu	a4,14(a5)
    800071c0:	fed715e3          	bne	a4,a3,800071aa <sockalloc+0xa8>
      release(&lock);
    800071c4:	00022517          	auipc	a0,0x22
    800071c8:	15c50513          	addi	a0,a0,348 # 80029320 <lock>
    800071cc:	ffffa097          	auipc	ra,0xffffa
    800071d0:	9b4080e7          	jalr	-1612(ra) # 80000b80 <release>
  release(&lock);
  return 0;

bad:
  if (si)
    kfree((char*)si);
    800071d4:	8556                	mv	a0,s5
    800071d6:	ffff9097          	auipc	ra,0xffff9
    800071da:	6aa080e7          	jalr	1706(ra) # 80000880 <kfree>
  if (*f)
    800071de:	00093503          	ld	a0,0(s2)
    800071e2:	c129                	beqz	a0,80007224 <sockalloc+0x122>
    fileclose(*f);
    800071e4:	ffffd097          	auipc	ra,0xffffd
    800071e8:	4de080e7          	jalr	1246(ra) # 800046c2 <fileclose>
  return -1;
    800071ec:	557d                	li	a0,-1
    800071ee:	a005                	j	8000720e <sockalloc+0x10c>
  si->next = sockets;
    800071f0:	00bab023          	sd	a1,0(s5)
  sockets = si;
    800071f4:	00022797          	auipc	a5,0x22
    800071f8:	1957be23          	sd	s5,412(a5) # 80029390 <sockets>
  release(&lock);
    800071fc:	00022517          	auipc	a0,0x22
    80007200:	12450513          	addi	a0,a0,292 # 80029320 <lock>
    80007204:	ffffa097          	auipc	ra,0xffffa
    80007208:	97c080e7          	jalr	-1668(ra) # 80000b80 <release>
  return 0;
    8000720c:	4501                	li	a0,0
}
    8000720e:	70e2                	ld	ra,56(sp)
    80007210:	7442                	ld	s0,48(sp)
    80007212:	74a2                	ld	s1,40(sp)
    80007214:	7902                	ld	s2,32(sp)
    80007216:	69e2                	ld	s3,24(sp)
    80007218:	6a42                	ld	s4,16(sp)
    8000721a:	6aa2                	ld	s5,8(sp)
    8000721c:	6121                	addi	sp,sp,64
    8000721e:	8082                	ret
  return -1;
    80007220:	557d                	li	a0,-1
    80007222:	b7f5                	j	8000720e <sockalloc+0x10c>
    80007224:	557d                	li	a0,-1
    80007226:	b7e5                	j	8000720e <sockalloc+0x10c>

0000000080007228 <sockclose>:
// and writing for network sockets.
//

void 
sockclose(struct sock *socket)
{
    80007228:	7179                	addi	sp,sp,-48
    8000722a:	f406                	sd	ra,40(sp)
    8000722c:	f022                	sd	s0,32(sp)
    8000722e:	ec26                	sd	s1,24(sp)
    80007230:	e84a                	sd	s2,16(sp)
    80007232:	e44e                	sd	s3,8(sp)
    80007234:	1800                	addi	s0,sp,48
    80007236:	892a                	mv	s2,a0
  // temp will be the socket to be freed
  // pos is used to iterate sockets
  struct sock *pos, *temp;
  temp = 0;
  acquire(&lock);
    80007238:	00022517          	auipc	a0,0x22
    8000723c:	0e850513          	addi	a0,a0,232 # 80029320 <lock>
    80007240:	ffffa097          	auipc	ra,0xffffa
    80007244:	870080e7          	jalr	-1936(ra) # 80000ab0 <acquire>

  pos = sockets;
    80007248:	00022797          	auipc	a5,0x22
    8000724c:	1487b783          	ld	a5,328(a5) # 80029390 <sockets>
  if(!pos) {
    80007250:	c7c1                	beqz	a5,800072d8 <sockclose+0xb0>
    // empty sockets
    // return;
  } 
  else if (pos == socket) {
    80007252:	07278463          	beq	a5,s2,800072ba <sockclose+0x92>
    // head of sockets is socket and hence head to be updated
    sockets = pos->next;
    temp = pos;
  } 
  else {
    while (pos->next) {
    80007256:	873e                	mv	a4,a5
    80007258:	639c                	ld	a5,0(a5)
    8000725a:	cfbd                	beqz	a5,800072d8 <sockclose+0xb0>
      if (pos->next == socket) {
    8000725c:	ff279de3          	bne	a5,s2,80007256 <sockclose+0x2e>
        // remove pos->next from socket list
        temp = pos->next;
        pos->next = temp->next;
    80007260:	00093783          	ld	a5,0(s2)
    80007264:	e31c                	sd	a5,0(a4)
        break;
      }
      pos = pos->next;
    }
  }
  release(&lock);
    80007266:	00022517          	auipc	a0,0x22
    8000726a:	0ba50513          	addi	a0,a0,186 # 80029320 <lock>
    8000726e:	ffffa097          	auipc	ra,0xffffa
    80007272:	912080e7          	jalr	-1774(ra) # 80000b80 <release>
  
  if(!temp) return;
  
  acquire(&temp->lock);
    80007276:	01090993          	addi	s3,s2,16
    8000727a:	854e                	mv	a0,s3
    8000727c:	ffffa097          	auipc	ra,0xffffa
    80007280:	834080e7          	jalr	-1996(ra) # 80000ab0 <acquire>

  // free temp but before free mbufq
  struct mbuf* mbuf = temp->rxq.head;
    80007284:	03093483          	ld	s1,48(s2)
  struct mbuf* iter_mbuf;
  while(mbuf) {
    80007288:	c881                	beqz	s1,80007298 <sockclose+0x70>
    // free rxq 
    // don't know how to read
    // just simply freeing
    iter_mbuf = mbuf;
    mbuf = mbuf->next;
    8000728a:	8526                	mv	a0,s1
    8000728c:	6084                	ld	s1,0(s1)
    mbuffree(iter_mbuf);
    8000728e:	00000097          	auipc	ra,0x0
    80007292:	8e6080e7          	jalr	-1818(ra) # 80006b74 <mbuffree>
  while(mbuf) {
    80007296:	f8f5                	bnez	s1,8000728a <sockclose+0x62>
  }
  
  release(&temp->lock);
    80007298:	854e                	mv	a0,s3
    8000729a:	ffffa097          	auipc	ra,0xffffa
    8000729e:	8e6080e7          	jalr	-1818(ra) # 80000b80 <release>

  kfree(temp);
    800072a2:	854a                	mv	a0,s2
    800072a4:	ffff9097          	auipc	ra,0xffff9
    800072a8:	5dc080e7          	jalr	1500(ra) # 80000880 <kfree>
}
    800072ac:	70a2                	ld	ra,40(sp)
    800072ae:	7402                	ld	s0,32(sp)
    800072b0:	64e2                	ld	s1,24(sp)
    800072b2:	6942                	ld	s2,16(sp)
    800072b4:	69a2                	ld	s3,8(sp)
    800072b6:	6145                	addi	sp,sp,48
    800072b8:	8082                	ret
    sockets = pos->next;
    800072ba:	00093783          	ld	a5,0(s2)
    800072be:	00022717          	auipc	a4,0x22
    800072c2:	0cf73923          	sd	a5,210(a4) # 80029390 <sockets>
  release(&lock);
    800072c6:	00022517          	auipc	a0,0x22
    800072ca:	05a50513          	addi	a0,a0,90 # 80029320 <lock>
    800072ce:	ffffa097          	auipc	ra,0xffffa
    800072d2:	8b2080e7          	jalr	-1870(ra) # 80000b80 <release>
  if(!temp) return;
    800072d6:	b745                	j	80007276 <sockclose+0x4e>
  release(&lock);
    800072d8:	00022517          	auipc	a0,0x22
    800072dc:	04850513          	addi	a0,a0,72 # 80029320 <lock>
    800072e0:	ffffa097          	auipc	ra,0xffffa
    800072e4:	8a0080e7          	jalr	-1888(ra) # 80000b80 <release>
  if(!temp) return;
    800072e8:	b7d1                	j	800072ac <sockclose+0x84>

00000000800072ea <sockread>:

int
sockread(struct sock* socket, uint64 addr, int n)
{
    800072ea:	7139                	addi	sp,sp,-64
    800072ec:	fc06                	sd	ra,56(sp)
    800072ee:	f822                	sd	s0,48(sp)
    800072f0:	f426                	sd	s1,40(sp)
    800072f2:	f04a                	sd	s2,32(sp)
    800072f4:	ec4e                	sd	s3,24(sp)
    800072f6:	e852                	sd	s4,16(sp)
    800072f8:	e456                	sd	s5,8(sp)
    800072fa:	0080                	addi	s0,sp,64
    800072fc:	84aa                	mv	s1,a0
    800072fe:	8a2e                	mv	s4,a1
    80007300:	89b2                	mv	s3,a2

  struct mbuf* mbuf;
  struct proc *pr = myproc();
    80007302:	ffffa097          	auipc	ra,0xffffa
    80007306:	7a4080e7          	jalr	1956(ra) # 80001aa6 <myproc>
    8000730a:	8aaa                	mv	s5,a0

  acquire(&socket->lock);
    8000730c:	01048913          	addi	s2,s1,16
    80007310:	854a                	mv	a0,s2
    80007312:	ffff9097          	auipc	ra,0xffff9
    80007316:	79e080e7          	jalr	1950(ra) # 80000ab0 <acquire>

  // check if mbuf is empty
  while(mbufq_empty(&socket->rxq)) {
    8000731a:	03048493          	addi	s1,s1,48
    8000731e:	8526                	mv	a0,s1
    80007320:	00000097          	auipc	ra,0x0
    80007324:	8a2080e7          	jalr	-1886(ra) # 80006bc2 <mbufq_empty>
    80007328:	c50d                	beqz	a0,80007352 <sockread+0x68>
    // wait until it gets non-empty
    if(myproc()->killed) {
    8000732a:	ffffa097          	auipc	ra,0xffffa
    8000732e:	77c080e7          	jalr	1916(ra) # 80001aa6 <myproc>
    80007332:	5d1c                	lw	a5,56(a0)
    80007334:	eb81                	bnez	a5,80007344 <sockread+0x5a>
      release(&socket->lock);
      return -1;
    }
    sleep(&socket->rxq, &socket->lock);
    80007336:	85ca                	mv	a1,s2
    80007338:	8526                	mv	a0,s1
    8000733a:	ffffb097          	auipc	ra,0xffffb
    8000733e:	f28080e7          	jalr	-216(ra) # 80002262 <sleep>
    80007342:	bff1                	j	8000731e <sockread+0x34>
      release(&socket->lock);
    80007344:	854a                	mv	a0,s2
    80007346:	ffffa097          	auipc	ra,0xffffa
    8000734a:	83a080e7          	jalr	-1990(ra) # 80000b80 <release>
      return -1;
    8000734e:	557d                	li	a0,-1
    80007350:	a0b1                	j	8000739c <sockread+0xb2>
  }

  // there will be at least one mbuf
  if((mbuf = mbufq_pophead(&socket->rxq)) == 0) {
    80007352:	8526                	mv	a0,s1
    80007354:	00000097          	auipc	ra,0x0
    80007358:	858080e7          	jalr	-1960(ra) # 80006bac <mbufq_pophead>
    8000735c:	84aa                	mv	s1,a0
    8000735e:	c921                	beqz	a0,800073ae <sockread+0xc4>
    panic("sockread");
  }

  release(&socket->lock);
    80007360:	854a                	mv	a0,s2
    80007362:	ffffa097          	auipc	ra,0xffffa
    80007366:	81e080e7          	jalr	-2018(ra) # 80000b80 <release>

  // mbuf length to be sent
  if(n > mbuf->len) n = mbuf->len;
    8000736a:	489c                	lw	a5,16(s1)
    8000736c:	0009871b          	sext.w	a4,s3
    80007370:	00e7f463          	bgeu	a5,a4,80007378 <sockread+0x8e>
    80007374:	0007899b          	sext.w	s3,a5

  if(copyout(pr->pagetable, addr, mbuf->head, n) == -1) {
    80007378:	86ce                	mv	a3,s3
    8000737a:	6490                	ld	a2,8(s1)
    8000737c:	85d2                	mv	a1,s4
    8000737e:	058ab503          	ld	a0,88(s5)
    80007382:	ffffa097          	auipc	ra,0xffffa
    80007386:	418080e7          	jalr	1048(ra) # 8000179a <copyout>
    8000738a:	57fd                	li	a5,-1
    8000738c:	02f50963          	beq	a0,a5,800073be <sockread+0xd4>
    n = -1;
  }

  // free mbuf as it is sent to user
  mbuffree(mbuf);
    80007390:	8526                	mv	a0,s1
    80007392:	fffff097          	auipc	ra,0xfffff
    80007396:	7e2080e7          	jalr	2018(ra) # 80006b74 <mbuffree>

  return n;
    8000739a:	854e                	mv	a0,s3
}
    8000739c:	70e2                	ld	ra,56(sp)
    8000739e:	7442                	ld	s0,48(sp)
    800073a0:	74a2                	ld	s1,40(sp)
    800073a2:	7902                	ld	s2,32(sp)
    800073a4:	69e2                	ld	s3,24(sp)
    800073a6:	6a42                	ld	s4,16(sp)
    800073a8:	6aa2                	ld	s5,8(sp)
    800073aa:	6121                	addi	sp,sp,64
    800073ac:	8082                	ret
    panic("sockread");
    800073ae:	00003517          	auipc	a0,0x3
    800073b2:	86a50513          	addi	a0,a0,-1942 # 80009c18 <userret+0xb88>
    800073b6:	ffff9097          	auipc	ra,0xffff9
    800073ba:	1a4080e7          	jalr	420(ra) # 8000055a <panic>
    n = -1;
    800073be:	89aa                	mv	s3,a0
    800073c0:	bfc1                	j	80007390 <sockread+0xa6>

00000000800073c2 <sockwrite>:

int 
sockwrite(struct sock* socket, uint64 addr, int n)
{
    800073c2:	7139                	addi	sp,sp,-64
    800073c4:	fc06                	sd	ra,56(sp)
    800073c6:	f822                	sd	s0,48(sp)
    800073c8:	f426                	sd	s1,40(sp)
    800073ca:	f04a                	sd	s2,32(sp)
    800073cc:	ec4e                	sd	s3,24(sp)
    800073ce:	e852                	sd	s4,16(sp)
    800073d0:	e456                	sd	s5,8(sp)
    800073d2:	0080                	addi	s0,sp,64
    800073d4:	892a                	mv	s2,a0
    800073d6:	8aae                	mv	s5,a1
    800073d8:	89b2                	mv	s3,a2
  struct mbuf *mbuf;
  struct proc *pr = myproc();
    800073da:	ffffa097          	auipc	ra,0xffffa
    800073de:	6cc080e7          	jalr	1740(ra) # 80001aa6 <myproc>
    800073e2:	8a2a                	mv	s4,a0
  // leave headroom size in  mbuf head
  headroom = sizeof(struct udp) + sizeof(struct ip) + sizeof(struct eth);
  // printf("Headroom size: %d\n", headroom);

  // allocate a new mbuf
  if((mbuf = mbufalloc(headroom)) == 0) {
    800073e4:	02a00513          	li	a0,42
    800073e8:	fffff097          	auipc	ra,0xfffff
    800073ec:	734080e7          	jalr	1844(ra) # 80006b1c <mbufalloc>
    800073f0:	c535                	beqz	a0,8000745c <sockwrite+0x9a>
    800073f2:	84aa                	mv	s1,a0
    panic("sockwrite");
  }

  // append
  mbufput(mbuf, n);
    800073f4:	85ce                	mv	a1,s3
    800073f6:	fffff097          	auipc	ra,0xfffff
    800073fa:	6ca080e7          	jalr	1738(ra) # 80006ac0 <mbufput>

  // copyin
  if(copyin(pr->pagetable, mbuf->head, addr, n) == -1) {
    800073fe:	86ce                	mv	a3,s3
    80007400:	8656                	mv	a2,s5
    80007402:	648c                	ld	a1,8(s1)
    80007404:	058a3503          	ld	a0,88(s4)
    80007408:	ffffa097          	auipc	ra,0xffffa
    8000740c:	41e080e7          	jalr	1054(ra) # 80001826 <copyin>
    80007410:	8a2a                	mv	s4,a0
    80007412:	57fd                	li	a5,-1
    80007414:	04f50c63          	beq	a0,a5,8000746c <sockwrite+0xaa>
    mbuffree(mbuf);
    return -1;
  }

  acquire(&socket->lock);
    80007418:	01090a13          	addi	s4,s2,16
    8000741c:	8552                	mv	a0,s4
    8000741e:	ffff9097          	auipc	ra,0xffff9
    80007422:	692080e7          	jalr	1682(ra) # 80000ab0 <acquire>

  net_tx_udp(mbuf, socket->raddr, socket->lport, socket->rport);
    80007426:	00e95683          	lhu	a3,14(s2)
    8000742a:	00c95603          	lhu	a2,12(s2)
    8000742e:	00892583          	lw	a1,8(s2)
    80007432:	8526                	mv	a0,s1
    80007434:	fffff097          	auipc	ra,0xfffff
    80007438:	7b0080e7          	jalr	1968(ra) # 80006be4 <net_tx_udp>

  release(&socket->lock);
    8000743c:	8552                	mv	a0,s4
    8000743e:	ffff9097          	auipc	ra,0xffff9
    80007442:	742080e7          	jalr	1858(ra) # 80000b80 <release>
  return n;
    80007446:	8a4e                	mv	s4,s3
}
    80007448:	8552                	mv	a0,s4
    8000744a:	70e2                	ld	ra,56(sp)
    8000744c:	7442                	ld	s0,48(sp)
    8000744e:	74a2                	ld	s1,40(sp)
    80007450:	7902                	ld	s2,32(sp)
    80007452:	69e2                	ld	s3,24(sp)
    80007454:	6a42                	ld	s4,16(sp)
    80007456:	6aa2                	ld	s5,8(sp)
    80007458:	6121                	addi	sp,sp,64
    8000745a:	8082                	ret
    panic("sockwrite");
    8000745c:	00002517          	auipc	a0,0x2
    80007460:	7cc50513          	addi	a0,a0,1996 # 80009c28 <userret+0xb98>
    80007464:	ffff9097          	auipc	ra,0xffff9
    80007468:	0f6080e7          	jalr	246(ra) # 8000055a <panic>
    mbuffree(mbuf);
    8000746c:	8526                	mv	a0,s1
    8000746e:	fffff097          	auipc	ra,0xfffff
    80007472:	706080e7          	jalr	1798(ra) # 80006b74 <mbuffree>
    return -1;
    80007476:	bfc9                	j	80007448 <sockwrite+0x86>

0000000080007478 <sockrecvudp>:

// called by protocol handler layer to deliver UDP packets
void
sockrecvudp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport)
{
    80007478:	7139                	addi	sp,sp,-64
    8000747a:	fc06                	sd	ra,56(sp)
    8000747c:	f822                	sd	s0,48(sp)
    8000747e:	f426                	sd	s1,40(sp)
    80007480:	f04a                	sd	s2,32(sp)
    80007482:	ec4e                	sd	s3,24(sp)
    80007484:	e852                	sd	s4,16(sp)
    80007486:	e456                	sd	s5,8(sp)
    80007488:	0080                	addi	s0,sp,64
    8000748a:	8a2a                	mv	s4,a0
    8000748c:	892e                	mv	s2,a1
    8000748e:	89b2                	mv	s3,a2
    80007490:	8ab6                	mv	s5,a3
  // registered to handle it.
  //

  struct sock* pos;

  acquire(&lock);
    80007492:	00022517          	auipc	a0,0x22
    80007496:	e8e50513          	addi	a0,a0,-370 # 80029320 <lock>
    8000749a:	ffff9097          	auipc	ra,0xffff9
    8000749e:	616080e7          	jalr	1558(ra) # 80000ab0 <acquire>

  pos = sockets;
    800074a2:	00022497          	auipc	s1,0x22
    800074a6:	eee4b483          	ld	s1,-274(s1) # 80029390 <sockets>
  while (pos) {
    800074aa:	ccad                	beqz	s1,80007524 <sockrecvudp+0xac>
    if (pos->raddr == raddr &&
    800074ac:	0009871b          	sext.w	a4,s3
        pos->lport == lport &&
    800074b0:	000a869b          	sext.w	a3,s5
    800074b4:	a019                	j	800074ba <sockrecvudp+0x42>
	      pos->rport == rport) {
      // socket found. Put the mbuf into rxq and wakeup the socket
      break;
    }
    pos = pos->next;
    800074b6:	6084                	ld	s1,0(s1)
  while (pos) {
    800074b8:	c4b5                	beqz	s1,80007524 <sockrecvudp+0xac>
    if (pos->raddr == raddr &&
    800074ba:	449c                	lw	a5,8(s1)
    800074bc:	ff279de3          	bne	a5,s2,800074b6 <sockrecvudp+0x3e>
    800074c0:	00c4d783          	lhu	a5,12(s1)
    800074c4:	fee799e3          	bne	a5,a4,800074b6 <sockrecvudp+0x3e>
        pos->lport == lport &&
    800074c8:	00e4d783          	lhu	a5,14(s1)
    800074cc:	fed795e3          	bne	a5,a3,800074b6 <sockrecvudp+0x3e>
  }

  release(&lock);
    800074d0:	00022517          	auipc	a0,0x22
    800074d4:	e5050513          	addi	a0,a0,-432 # 80029320 <lock>
    800074d8:	ffff9097          	auipc	ra,0xffff9
    800074dc:	6a8080e7          	jalr	1704(ra) # 80000b80 <release>

  if(pos) {
    acquire(&pos->lock);
    800074e0:	01048913          	addi	s2,s1,16
    800074e4:	854a                	mv	a0,s2
    800074e6:	ffff9097          	auipc	ra,0xffff9
    800074ea:	5ca080e7          	jalr	1482(ra) # 80000ab0 <acquire>
    // push mbuf into rxq and wakeup the rxq
    mbufq_pushtail(&pos->rxq, m);
    800074ee:	03048493          	addi	s1,s1,48
    800074f2:	85d2                	mv	a1,s4
    800074f4:	8526                	mv	a0,s1
    800074f6:	fffff097          	auipc	ra,0xfffff
    800074fa:	696080e7          	jalr	1686(ra) # 80006b8c <mbufq_pushtail>
    wakeup(&pos->rxq);
    800074fe:	8526                	mv	a0,s1
    80007500:	ffffb097          	auipc	ra,0xffffb
    80007504:	ee8080e7          	jalr	-280(ra) # 800023e8 <wakeup>

    release(&pos->lock);
    80007508:	854a                	mv	a0,s2
    8000750a:	ffff9097          	auipc	ra,0xffff9
    8000750e:	676080e7          	jalr	1654(ra) # 80000b80 <release>
  } 
  else {
    // free the mbuf as it cannot be ddelivered.
    mbuffree(m);
  }  
}
    80007512:	70e2                	ld	ra,56(sp)
    80007514:	7442                	ld	s0,48(sp)
    80007516:	74a2                	ld	s1,40(sp)
    80007518:	7902                	ld	s2,32(sp)
    8000751a:	69e2                	ld	s3,24(sp)
    8000751c:	6a42                	ld	s4,16(sp)
    8000751e:	6aa2                	ld	s5,8(sp)
    80007520:	6121                	addi	sp,sp,64
    80007522:	8082                	ret
  release(&lock);
    80007524:	00022517          	auipc	a0,0x22
    80007528:	dfc50513          	addi	a0,a0,-516 # 80029320 <lock>
    8000752c:	ffff9097          	auipc	ra,0xffff9
    80007530:	654080e7          	jalr	1620(ra) # 80000b80 <release>
    mbuffree(m);
    80007534:	8552                	mv	a0,s4
    80007536:	fffff097          	auipc	ra,0xfffff
    8000753a:	63e080e7          	jalr	1598(ra) # 80006b74 <mbuffree>
    8000753e:	bfd1                	j	80007512 <sockrecvudp+0x9a>

0000000080007540 <pci_init>:
#include "proc.h"
#include "defs.h"

void
pci_init()
{
    80007540:	715d                	addi	sp,sp,-80
    80007542:	e486                	sd	ra,72(sp)
    80007544:	e0a2                	sd	s0,64(sp)
    80007546:	fc26                	sd	s1,56(sp)
    80007548:	f84a                	sd	s2,48(sp)
    8000754a:	f44e                	sd	s3,40(sp)
    8000754c:	f052                	sd	s4,32(sp)
    8000754e:	ec56                	sd	s5,24(sp)
    80007550:	e85a                	sd	s6,16(sp)
    80007552:	e45e                	sd	s7,8(sp)
    80007554:	0880                	addi	s0,sp,80
    80007556:	300004b7          	lui	s1,0x30000
    uint32 off = (bus << 16) | (dev << 11) | (func << 8) | (offset);
    volatile uint32 *base = ecam + off;
    uint32 id = base[0];
    
    // 100e:8086 is an e1000
    if(id == 0x100e8086){
    8000755a:	100e8937          	lui	s2,0x100e8
    8000755e:	08690913          	addi	s2,s2,134 # 100e8086 <_entry-0x6ff17f7a>
      // command and status register.
      // bit 0 : I/O access enable
      // bit 1 : memory access enable
      // bit 2 : enable mastering
      base[1] = 7;
    80007562:	4b9d                	li	s7,7
      for(int i = 0; i < 6; i++){
        uint32 old = base[4+i];

        // writing all 1's to the BAR causes it to be
        // replaced with its size.
        base[4+i] = 0xffffffff;
    80007564:	5afd                	li	s5,-1
        base[4+i] = old;
      }

      // tell the e1000 to reveal its registers at
      // physical address 0x40000000.
      base[4+0] = e1000_regs;
    80007566:	40000b37          	lui	s6,0x40000
    8000756a:	6a09                	lui	s4,0x2
  for(int dev = 0; dev < 32; dev++){
    8000756c:	300409b7          	lui	s3,0x30040
    80007570:	a819                	j	80007586 <pci_init+0x46>
      base[4+0] = e1000_regs;
    80007572:	0166a823          	sw	s6,16(a3)

      e1000_init((uint32*)e1000_regs);
    80007576:	855a                	mv	a0,s6
    80007578:	fffff097          	auipc	ra,0xfffff
    8000757c:	08c080e7          	jalr	140(ra) # 80006604 <e1000_init>
  for(int dev = 0; dev < 32; dev++){
    80007580:	94d2                	add	s1,s1,s4
    80007582:	03348a63          	beq	s1,s3,800075b6 <pci_init+0x76>
    volatile uint32 *base = ecam + off;
    80007586:	86a6                	mv	a3,s1
    uint32 id = base[0];
    80007588:	409c                	lw	a5,0(s1)
    8000758a:	2781                	sext.w	a5,a5
    if(id == 0x100e8086){
    8000758c:	ff279ae3          	bne	a5,s2,80007580 <pci_init+0x40>
      base[1] = 7;
    80007590:	0174a223          	sw	s7,4(s1) # 30000004 <_entry-0x4ffffffc>
      __sync_synchronize();
    80007594:	0ff0000f          	fence
      for(int i = 0; i < 6; i++){
    80007598:	01048793          	addi	a5,s1,16
    8000759c:	02848613          	addi	a2,s1,40
        uint32 old = base[4+i];
    800075a0:	4398                	lw	a4,0(a5)
    800075a2:	2701                	sext.w	a4,a4
        base[4+i] = 0xffffffff;
    800075a4:	0157a023          	sw	s5,0(a5)
        __sync_synchronize();
    800075a8:	0ff0000f          	fence
        base[4+i] = old;
    800075ac:	c398                	sw	a4,0(a5)
      for(int i = 0; i < 6; i++){
    800075ae:	0791                	addi	a5,a5,4
    800075b0:	fec798e3          	bne	a5,a2,800075a0 <pci_init+0x60>
    800075b4:	bf7d                	j	80007572 <pci_init+0x32>
    }
  }
}
    800075b6:	60a6                	ld	ra,72(sp)
    800075b8:	6406                	ld	s0,64(sp)
    800075ba:	74e2                	ld	s1,56(sp)
    800075bc:	7942                	ld	s2,48(sp)
    800075be:	79a2                	ld	s3,40(sp)
    800075c0:	7a02                	ld	s4,32(sp)
    800075c2:	6ae2                	ld	s5,24(sp)
    800075c4:	6b42                	ld	s6,16(sp)
    800075c6:	6ba2                	ld	s7,8(sp)
    800075c8:	6161                	addi	sp,sp,80
    800075ca:	8082                	ret

00000000800075cc <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800075cc:	1141                	addi	sp,sp,-16
    800075ce:	e422                	sd	s0,8(sp)
    800075d0:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    800075d2:	41f5d79b          	sraiw	a5,a1,0x1f
    800075d6:	01d7d79b          	srliw	a5,a5,0x1d
    800075da:	9dbd                	addw	a1,a1,a5
    800075dc:	0075f713          	andi	a4,a1,7
    800075e0:	9f1d                	subw	a4,a4,a5
    800075e2:	4785                	li	a5,1
    800075e4:	00e797bb          	sllw	a5,a5,a4
    800075e8:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800075ec:	4035d59b          	sraiw	a1,a1,0x3
    800075f0:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800075f2:	0005c503          	lbu	a0,0(a1)
    800075f6:	8d7d                	and	a0,a0,a5
    800075f8:	8d1d                	sub	a0,a0,a5
}
    800075fa:	00153513          	seqz	a0,a0
    800075fe:	6422                	ld	s0,8(sp)
    80007600:	0141                	addi	sp,sp,16
    80007602:	8082                	ret

0000000080007604 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80007604:	1141                	addi	sp,sp,-16
    80007606:	e422                	sd	s0,8(sp)
    80007608:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000760a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000760e:	01d7d79b          	srliw	a5,a5,0x1d
    80007612:	9dbd                	addw	a1,a1,a5
    80007614:	4035d71b          	sraiw	a4,a1,0x3
    80007618:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    8000761a:	899d                	andi	a1,a1,7
    8000761c:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    8000761e:	4785                	li	a5,1
    80007620:	00b795bb          	sllw	a1,a5,a1
    80007624:	00054783          	lbu	a5,0(a0)
    80007628:	8ddd                	or	a1,a1,a5
    8000762a:	00b50023          	sb	a1,0(a0)
}
    8000762e:	6422                	ld	s0,8(sp)
    80007630:	0141                	addi	sp,sp,16
    80007632:	8082                	ret

0000000080007634 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80007634:	1141                	addi	sp,sp,-16
    80007636:	e422                	sd	s0,8(sp)
    80007638:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000763a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000763e:	01d7d79b          	srliw	a5,a5,0x1d
    80007642:	9dbd                	addw	a1,a1,a5
    80007644:	4035d71b          	sraiw	a4,a1,0x3
    80007648:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    8000764a:	899d                	andi	a1,a1,7
    8000764c:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    8000764e:	4785                	li	a5,1
    80007650:	00b795bb          	sllw	a1,a5,a1
    80007654:	fff5c593          	not	a1,a1
    80007658:	00054783          	lbu	a5,0(a0)
    8000765c:	8dfd                	and	a1,a1,a5
    8000765e:	00b50023          	sb	a1,0(a0)
}
    80007662:	6422                	ld	s0,8(sp)
    80007664:	0141                	addi	sp,sp,16
    80007666:	8082                	ret

0000000080007668 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80007668:	715d                	addi	sp,sp,-80
    8000766a:	e486                	sd	ra,72(sp)
    8000766c:	e0a2                	sd	s0,64(sp)
    8000766e:	fc26                	sd	s1,56(sp)
    80007670:	f84a                	sd	s2,48(sp)
    80007672:	f44e                	sd	s3,40(sp)
    80007674:	f052                	sd	s4,32(sp)
    80007676:	ec56                	sd	s5,24(sp)
    80007678:	e85a                	sd	s6,16(sp)
    8000767a:	e45e                	sd	s7,8(sp)
    8000767c:	0880                	addi	s0,sp,80
    8000767e:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80007680:	08b05b63          	blez	a1,80007716 <bd_print_vector+0xae>
    80007684:	89aa                	mv	s3,a0
    80007686:	4481                	li	s1,0
  lb = 0;
    80007688:	4a81                	li	s5,0
  last = 1;
    8000768a:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    8000768c:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    8000768e:	00002b97          	auipc	s7,0x2
    80007692:	5aab8b93          	addi	s7,s7,1450 # 80009c38 <userret+0xba8>
    80007696:	a01d                	j	800076bc <bd_print_vector+0x54>
    80007698:	8626                	mv	a2,s1
    8000769a:	85d6                	mv	a1,s5
    8000769c:	855e                	mv	a0,s7
    8000769e:	ffff9097          	auipc	ra,0xffff9
    800076a2:	f16080e7          	jalr	-234(ra) # 800005b4 <printf>
    lb = b;
    last = bit_isset(vector, b);
    800076a6:	85a6                	mv	a1,s1
    800076a8:	854e                	mv	a0,s3
    800076aa:	00000097          	auipc	ra,0x0
    800076ae:	f22080e7          	jalr	-222(ra) # 800075cc <bit_isset>
    800076b2:	892a                	mv	s2,a0
    800076b4:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    800076b6:	2485                	addiw	s1,s1,1
    800076b8:	009a0d63          	beq	s4,s1,800076d2 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    800076bc:	85a6                	mv	a1,s1
    800076be:	854e                	mv	a0,s3
    800076c0:	00000097          	auipc	ra,0x0
    800076c4:	f0c080e7          	jalr	-244(ra) # 800075cc <bit_isset>
    800076c8:	ff2507e3          	beq	a0,s2,800076b6 <bd_print_vector+0x4e>
    if(last == 1)
    800076cc:	fd691de3          	bne	s2,s6,800076a6 <bd_print_vector+0x3e>
    800076d0:	b7e1                	j	80007698 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    800076d2:	000a8563          	beqz	s5,800076dc <bd_print_vector+0x74>
    800076d6:	4785                	li	a5,1
    800076d8:	00f91c63          	bne	s2,a5,800076f0 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    800076dc:	8652                	mv	a2,s4
    800076de:	85d6                	mv	a1,s5
    800076e0:	00002517          	auipc	a0,0x2
    800076e4:	55850513          	addi	a0,a0,1368 # 80009c38 <userret+0xba8>
    800076e8:	ffff9097          	auipc	ra,0xffff9
    800076ec:	ecc080e7          	jalr	-308(ra) # 800005b4 <printf>
  }
  printf("\n");
    800076f0:	00002517          	auipc	a0,0x2
    800076f4:	ba050513          	addi	a0,a0,-1120 # 80009290 <userret+0x200>
    800076f8:	ffff9097          	auipc	ra,0xffff9
    800076fc:	ebc080e7          	jalr	-324(ra) # 800005b4 <printf>
}
    80007700:	60a6                	ld	ra,72(sp)
    80007702:	6406                	ld	s0,64(sp)
    80007704:	74e2                	ld	s1,56(sp)
    80007706:	7942                	ld	s2,48(sp)
    80007708:	79a2                	ld	s3,40(sp)
    8000770a:	7a02                	ld	s4,32(sp)
    8000770c:	6ae2                	ld	s5,24(sp)
    8000770e:	6b42                	ld	s6,16(sp)
    80007710:	6ba2                	ld	s7,8(sp)
    80007712:	6161                	addi	sp,sp,80
    80007714:	8082                	ret
  lb = 0;
    80007716:	4a81                	li	s5,0
    80007718:	b7d1                	j	800076dc <bd_print_vector+0x74>

000000008000771a <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    8000771a:	00022697          	auipc	a3,0x22
    8000771e:	c8e6a683          	lw	a3,-882(a3) # 800293a8 <nsizes>
    80007722:	10d05063          	blez	a3,80007822 <bd_print+0x108>
bd_print() {
    80007726:	711d                	addi	sp,sp,-96
    80007728:	ec86                	sd	ra,88(sp)
    8000772a:	e8a2                	sd	s0,80(sp)
    8000772c:	e4a6                	sd	s1,72(sp)
    8000772e:	e0ca                	sd	s2,64(sp)
    80007730:	fc4e                	sd	s3,56(sp)
    80007732:	f852                	sd	s4,48(sp)
    80007734:	f456                	sd	s5,40(sp)
    80007736:	f05a                	sd	s6,32(sp)
    80007738:	ec5e                	sd	s7,24(sp)
    8000773a:	e862                	sd	s8,16(sp)
    8000773c:	e466                	sd	s9,8(sp)
    8000773e:	e06a                	sd	s10,0(sp)
    80007740:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80007742:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80007744:	4a85                	li	s5,1
    80007746:	4c41                	li	s8,16
    80007748:	00002b97          	auipc	s7,0x2
    8000774c:	500b8b93          	addi	s7,s7,1280 # 80009c48 <userret+0xbb8>
    lst_print(&bd_sizes[k].free);
    80007750:	00022a17          	auipc	s4,0x22
    80007754:	c50a0a13          	addi	s4,s4,-944 # 800293a0 <bd_sizes>
    printf("  alloc:");
    80007758:	00002b17          	auipc	s6,0x2
    8000775c:	518b0b13          	addi	s6,s6,1304 # 80009c70 <userret+0xbe0>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80007760:	00022997          	auipc	s3,0x22
    80007764:	c4898993          	addi	s3,s3,-952 # 800293a8 <nsizes>
    if(k > 0) {
      printf("  split:");
    80007768:	00002c97          	auipc	s9,0x2
    8000776c:	518c8c93          	addi	s9,s9,1304 # 80009c80 <userret+0xbf0>
    80007770:	a801                	j	80007780 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80007772:	0009a683          	lw	a3,0(s3)
    80007776:	0485                	addi	s1,s1,1
    80007778:	0004879b          	sext.w	a5,s1
    8000777c:	08d7d563          	bge	a5,a3,80007806 <bd_print+0xec>
    80007780:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80007784:	36fd                	addiw	a3,a3,-1
    80007786:	9e85                	subw	a3,a3,s1
    80007788:	00da96bb          	sllw	a3,s5,a3
    8000778c:	009c1633          	sll	a2,s8,s1
    80007790:	85ca                	mv	a1,s2
    80007792:	855e                	mv	a0,s7
    80007794:	ffff9097          	auipc	ra,0xffff9
    80007798:	e20080e7          	jalr	-480(ra) # 800005b4 <printf>
    lst_print(&bd_sizes[k].free);
    8000779c:	00549d13          	slli	s10,s1,0x5
    800077a0:	000a3503          	ld	a0,0(s4)
    800077a4:	956a                	add	a0,a0,s10
    800077a6:	00001097          	auipc	ra,0x1
    800077aa:	a4e080e7          	jalr	-1458(ra) # 800081f4 <lst_print>
    printf("  alloc:");
    800077ae:	855a                	mv	a0,s6
    800077b0:	ffff9097          	auipc	ra,0xffff9
    800077b4:	e04080e7          	jalr	-508(ra) # 800005b4 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800077b8:	0009a583          	lw	a1,0(s3)
    800077bc:	35fd                	addiw	a1,a1,-1
    800077be:	412585bb          	subw	a1,a1,s2
    800077c2:	000a3783          	ld	a5,0(s4)
    800077c6:	97ea                	add	a5,a5,s10
    800077c8:	00ba95bb          	sllw	a1,s5,a1
    800077cc:	6b88                	ld	a0,16(a5)
    800077ce:	00000097          	auipc	ra,0x0
    800077d2:	e9a080e7          	jalr	-358(ra) # 80007668 <bd_print_vector>
    if(k > 0) {
    800077d6:	f9205ee3          	blez	s2,80007772 <bd_print+0x58>
      printf("  split:");
    800077da:	8566                	mv	a0,s9
    800077dc:	ffff9097          	auipc	ra,0xffff9
    800077e0:	dd8080e7          	jalr	-552(ra) # 800005b4 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    800077e4:	0009a583          	lw	a1,0(s3)
    800077e8:	35fd                	addiw	a1,a1,-1
    800077ea:	412585bb          	subw	a1,a1,s2
    800077ee:	000a3783          	ld	a5,0(s4)
    800077f2:	9d3e                	add	s10,s10,a5
    800077f4:	00ba95bb          	sllw	a1,s5,a1
    800077f8:	018d3503          	ld	a0,24(s10)
    800077fc:	00000097          	auipc	ra,0x0
    80007800:	e6c080e7          	jalr	-404(ra) # 80007668 <bd_print_vector>
    80007804:	b7bd                	j	80007772 <bd_print+0x58>
    }
  }
}
    80007806:	60e6                	ld	ra,88(sp)
    80007808:	6446                	ld	s0,80(sp)
    8000780a:	64a6                	ld	s1,72(sp)
    8000780c:	6906                	ld	s2,64(sp)
    8000780e:	79e2                	ld	s3,56(sp)
    80007810:	7a42                	ld	s4,48(sp)
    80007812:	7aa2                	ld	s5,40(sp)
    80007814:	7b02                	ld	s6,32(sp)
    80007816:	6be2                	ld	s7,24(sp)
    80007818:	6c42                	ld	s8,16(sp)
    8000781a:	6ca2                	ld	s9,8(sp)
    8000781c:	6d02                	ld	s10,0(sp)
    8000781e:	6125                	addi	sp,sp,96
    80007820:	8082                	ret
    80007822:	8082                	ret

0000000080007824 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80007824:	1141                	addi	sp,sp,-16
    80007826:	e422                	sd	s0,8(sp)
    80007828:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    8000782a:	47c1                	li	a5,16
    8000782c:	00a7fb63          	bgeu	a5,a0,80007842 <firstk+0x1e>
    80007830:	872a                	mv	a4,a0
  int k = 0;
    80007832:	4501                	li	a0,0
    k++;
    80007834:	2505                	addiw	a0,a0,1
    size *= 2;
    80007836:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80007838:	fee7eee3          	bltu	a5,a4,80007834 <firstk+0x10>
  }
  return k;
}
    8000783c:	6422                	ld	s0,8(sp)
    8000783e:	0141                	addi	sp,sp,16
    80007840:	8082                	ret
  int k = 0;
    80007842:	4501                	li	a0,0
    80007844:	bfe5                	j	8000783c <firstk+0x18>

0000000080007846 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80007846:	1141                	addi	sp,sp,-16
    80007848:	e422                	sd	s0,8(sp)
    8000784a:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    8000784c:	00022797          	auipc	a5,0x22
    80007850:	b4c7b783          	ld	a5,-1204(a5) # 80029398 <bd_base>
    80007854:	9d9d                	subw	a1,a1,a5
    80007856:	47c1                	li	a5,16
    80007858:	00a79533          	sll	a0,a5,a0
    8000785c:	02a5c533          	div	a0,a1,a0
}
    80007860:	2501                	sext.w	a0,a0
    80007862:	6422                	ld	s0,8(sp)
    80007864:	0141                	addi	sp,sp,16
    80007866:	8082                	ret

0000000080007868 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80007868:	1141                	addi	sp,sp,-16
    8000786a:	e422                	sd	s0,8(sp)
    8000786c:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    8000786e:	47c1                	li	a5,16
    80007870:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80007874:	02b787bb          	mulw	a5,a5,a1
}
    80007878:	00022517          	auipc	a0,0x22
    8000787c:	b2053503          	ld	a0,-1248(a0) # 80029398 <bd_base>
    80007880:	953e                	add	a0,a0,a5
    80007882:	6422                	ld	s0,8(sp)
    80007884:	0141                	addi	sp,sp,16
    80007886:	8082                	ret

0000000080007888 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80007888:	7159                	addi	sp,sp,-112
    8000788a:	f486                	sd	ra,104(sp)
    8000788c:	f0a2                	sd	s0,96(sp)
    8000788e:	eca6                	sd	s1,88(sp)
    80007890:	e8ca                	sd	s2,80(sp)
    80007892:	e4ce                	sd	s3,72(sp)
    80007894:	e0d2                	sd	s4,64(sp)
    80007896:	fc56                	sd	s5,56(sp)
    80007898:	f85a                	sd	s6,48(sp)
    8000789a:	f45e                	sd	s7,40(sp)
    8000789c:	f062                	sd	s8,32(sp)
    8000789e:	ec66                	sd	s9,24(sp)
    800078a0:	e86a                	sd	s10,16(sp)
    800078a2:	e46e                	sd	s11,8(sp)
    800078a4:	1880                	addi	s0,sp,112
    800078a6:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    800078a8:	00022517          	auipc	a0,0x22
    800078ac:	a9850513          	addi	a0,a0,-1384 # 80029340 <lock>
    800078b0:	ffff9097          	auipc	ra,0xffff9
    800078b4:	200080e7          	jalr	512(ra) # 80000ab0 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    800078b8:	8526                	mv	a0,s1
    800078ba:	00000097          	auipc	ra,0x0
    800078be:	f6a080e7          	jalr	-150(ra) # 80007824 <firstk>
  for (k = fk; k < nsizes; k++) {
    800078c2:	00022797          	auipc	a5,0x22
    800078c6:	ae67a783          	lw	a5,-1306(a5) # 800293a8 <nsizes>
    800078ca:	02f55d63          	bge	a0,a5,80007904 <bd_malloc+0x7c>
    800078ce:	8c2a                	mv	s8,a0
    800078d0:	00551913          	slli	s2,a0,0x5
    800078d4:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    800078d6:	00022997          	auipc	s3,0x22
    800078da:	aca98993          	addi	s3,s3,-1334 # 800293a0 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    800078de:	00022a17          	auipc	s4,0x22
    800078e2:	acaa0a13          	addi	s4,s4,-1334 # 800293a8 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    800078e6:	0009b503          	ld	a0,0(s3)
    800078ea:	954a                	add	a0,a0,s2
    800078ec:	00001097          	auipc	ra,0x1
    800078f0:	88e080e7          	jalr	-1906(ra) # 8000817a <lst_empty>
    800078f4:	c115                	beqz	a0,80007918 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    800078f6:	2485                	addiw	s1,s1,1
    800078f8:	02090913          	addi	s2,s2,32
    800078fc:	000a2783          	lw	a5,0(s4)
    80007900:	fef4c3e3          	blt	s1,a5,800078e6 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80007904:	00022517          	auipc	a0,0x22
    80007908:	a3c50513          	addi	a0,a0,-1476 # 80029340 <lock>
    8000790c:	ffff9097          	auipc	ra,0xffff9
    80007910:	274080e7          	jalr	628(ra) # 80000b80 <release>
    return 0;
    80007914:	4b01                	li	s6,0
    80007916:	a0e1                	j	800079de <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80007918:	00022797          	auipc	a5,0x22
    8000791c:	a907a783          	lw	a5,-1392(a5) # 800293a8 <nsizes>
    80007920:	fef4d2e3          	bge	s1,a5,80007904 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80007924:	00549993          	slli	s3,s1,0x5
    80007928:	00022917          	auipc	s2,0x22
    8000792c:	a7890913          	addi	s2,s2,-1416 # 800293a0 <bd_sizes>
    80007930:	00093503          	ld	a0,0(s2)
    80007934:	954e                	add	a0,a0,s3
    80007936:	00001097          	auipc	ra,0x1
    8000793a:	870080e7          	jalr	-1936(ra) # 800081a6 <lst_pop>
    8000793e:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80007940:	00022597          	auipc	a1,0x22
    80007944:	a585b583          	ld	a1,-1448(a1) # 80029398 <bd_base>
    80007948:	40b505bb          	subw	a1,a0,a1
    8000794c:	47c1                	li	a5,16
    8000794e:	009797b3          	sll	a5,a5,s1
    80007952:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80007956:	00093783          	ld	a5,0(s2)
    8000795a:	97ce                	add	a5,a5,s3
    8000795c:	2581                	sext.w	a1,a1
    8000795e:	6b88                	ld	a0,16(a5)
    80007960:	00000097          	auipc	ra,0x0
    80007964:	ca4080e7          	jalr	-860(ra) # 80007604 <bit_set>
  for(; k > fk; k--) {
    80007968:	069c5363          	bge	s8,s1,800079ce <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    8000796c:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    8000796e:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80007970:	00022d17          	auipc	s10,0x22
    80007974:	a28d0d13          	addi	s10,s10,-1496 # 80029398 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80007978:	85a6                	mv	a1,s1
    8000797a:	34fd                	addiw	s1,s1,-1
    8000797c:	009b9ab3          	sll	s5,s7,s1
    80007980:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80007984:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    80007988:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    8000798c:	412b093b          	subw	s2,s6,s2
    80007990:	00bb95b3          	sll	a1,s7,a1
    80007994:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80007998:	013a07b3          	add	a5,s4,s3
    8000799c:	2581                	sext.w	a1,a1
    8000799e:	6f88                	ld	a0,24(a5)
    800079a0:	00000097          	auipc	ra,0x0
    800079a4:	c64080e7          	jalr	-924(ra) # 80007604 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800079a8:	1981                	addi	s3,s3,-32
    800079aa:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    800079ac:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800079b0:	2581                	sext.w	a1,a1
    800079b2:	010a3503          	ld	a0,16(s4)
    800079b6:	00000097          	auipc	ra,0x0
    800079ba:	c4e080e7          	jalr	-946(ra) # 80007604 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    800079be:	85e6                	mv	a1,s9
    800079c0:	8552                	mv	a0,s4
    800079c2:	00001097          	auipc	ra,0x1
    800079c6:	81a080e7          	jalr	-2022(ra) # 800081dc <lst_push>
  for(; k > fk; k--) {
    800079ca:	fb8497e3          	bne	s1,s8,80007978 <bd_malloc+0xf0>
  }
  release(&lock);
    800079ce:	00022517          	auipc	a0,0x22
    800079d2:	97250513          	addi	a0,a0,-1678 # 80029340 <lock>
    800079d6:	ffff9097          	auipc	ra,0xffff9
    800079da:	1aa080e7          	jalr	426(ra) # 80000b80 <release>

  return p;
}
    800079de:	855a                	mv	a0,s6
    800079e0:	70a6                	ld	ra,104(sp)
    800079e2:	7406                	ld	s0,96(sp)
    800079e4:	64e6                	ld	s1,88(sp)
    800079e6:	6946                	ld	s2,80(sp)
    800079e8:	69a6                	ld	s3,72(sp)
    800079ea:	6a06                	ld	s4,64(sp)
    800079ec:	7ae2                	ld	s5,56(sp)
    800079ee:	7b42                	ld	s6,48(sp)
    800079f0:	7ba2                	ld	s7,40(sp)
    800079f2:	7c02                	ld	s8,32(sp)
    800079f4:	6ce2                	ld	s9,24(sp)
    800079f6:	6d42                	ld	s10,16(sp)
    800079f8:	6da2                	ld	s11,8(sp)
    800079fa:	6165                	addi	sp,sp,112
    800079fc:	8082                	ret

00000000800079fe <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    800079fe:	7139                	addi	sp,sp,-64
    80007a00:	fc06                	sd	ra,56(sp)
    80007a02:	f822                	sd	s0,48(sp)
    80007a04:	f426                	sd	s1,40(sp)
    80007a06:	f04a                	sd	s2,32(sp)
    80007a08:	ec4e                	sd	s3,24(sp)
    80007a0a:	e852                	sd	s4,16(sp)
    80007a0c:	e456                	sd	s5,8(sp)
    80007a0e:	e05a                	sd	s6,0(sp)
    80007a10:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80007a12:	00022a97          	auipc	s5,0x22
    80007a16:	996aaa83          	lw	s5,-1642(s5) # 800293a8 <nsizes>
  return n / BLK_SIZE(k);
    80007a1a:	00022a17          	auipc	s4,0x22
    80007a1e:	97ea3a03          	ld	s4,-1666(s4) # 80029398 <bd_base>
    80007a22:	41450a3b          	subw	s4,a0,s4
    80007a26:	00022497          	auipc	s1,0x22
    80007a2a:	97a4b483          	ld	s1,-1670(s1) # 800293a0 <bd_sizes>
    80007a2e:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80007a32:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80007a34:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80007a36:	03595363          	bge	s2,s5,80007a5c <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80007a3a:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80007a3e:	013b15b3          	sll	a1,s6,s3
    80007a42:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80007a46:	2581                	sext.w	a1,a1
    80007a48:	6088                	ld	a0,0(s1)
    80007a4a:	00000097          	auipc	ra,0x0
    80007a4e:	b82080e7          	jalr	-1150(ra) # 800075cc <bit_isset>
    80007a52:	02048493          	addi	s1,s1,32
    80007a56:	e501                	bnez	a0,80007a5e <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80007a58:	894e                	mv	s2,s3
    80007a5a:	bff1                	j	80007a36 <size+0x38>
      return k;
    }
  }
  return 0;
    80007a5c:	4901                	li	s2,0
}
    80007a5e:	854a                	mv	a0,s2
    80007a60:	70e2                	ld	ra,56(sp)
    80007a62:	7442                	ld	s0,48(sp)
    80007a64:	74a2                	ld	s1,40(sp)
    80007a66:	7902                	ld	s2,32(sp)
    80007a68:	69e2                	ld	s3,24(sp)
    80007a6a:	6a42                	ld	s4,16(sp)
    80007a6c:	6aa2                	ld	s5,8(sp)
    80007a6e:	6b02                	ld	s6,0(sp)
    80007a70:	6121                	addi	sp,sp,64
    80007a72:	8082                	ret

0000000080007a74 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80007a74:	7159                	addi	sp,sp,-112
    80007a76:	f486                	sd	ra,104(sp)
    80007a78:	f0a2                	sd	s0,96(sp)
    80007a7a:	eca6                	sd	s1,88(sp)
    80007a7c:	e8ca                	sd	s2,80(sp)
    80007a7e:	e4ce                	sd	s3,72(sp)
    80007a80:	e0d2                	sd	s4,64(sp)
    80007a82:	fc56                	sd	s5,56(sp)
    80007a84:	f85a                	sd	s6,48(sp)
    80007a86:	f45e                	sd	s7,40(sp)
    80007a88:	f062                	sd	s8,32(sp)
    80007a8a:	ec66                	sd	s9,24(sp)
    80007a8c:	e86a                	sd	s10,16(sp)
    80007a8e:	e46e                	sd	s11,8(sp)
    80007a90:	1880                	addi	s0,sp,112
    80007a92:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80007a94:	00022517          	auipc	a0,0x22
    80007a98:	8ac50513          	addi	a0,a0,-1876 # 80029340 <lock>
    80007a9c:	ffff9097          	auipc	ra,0xffff9
    80007aa0:	014080e7          	jalr	20(ra) # 80000ab0 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80007aa4:	8556                	mv	a0,s5
    80007aa6:	00000097          	auipc	ra,0x0
    80007aaa:	f58080e7          	jalr	-168(ra) # 800079fe <size>
    80007aae:	84aa                	mv	s1,a0
    80007ab0:	00022797          	auipc	a5,0x22
    80007ab4:	8f87a783          	lw	a5,-1800(a5) # 800293a8 <nsizes>
    80007ab8:	37fd                	addiw	a5,a5,-1
    80007aba:	0af55d63          	bge	a0,a5,80007b74 <bd_free+0x100>
    80007abe:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    80007ac2:	00022c17          	auipc	s8,0x22
    80007ac6:	8d6c0c13          	addi	s8,s8,-1834 # 80029398 <bd_base>
  return n / BLK_SIZE(k);
    80007aca:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007acc:	00022b17          	auipc	s6,0x22
    80007ad0:	8d4b0b13          	addi	s6,s6,-1836 # 800293a0 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80007ad4:	00022c97          	auipc	s9,0x22
    80007ad8:	8d4c8c93          	addi	s9,s9,-1836 # 800293a8 <nsizes>
    80007adc:	a82d                	j	80007b16 <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007ade:	fff58d9b          	addiw	s11,a1,-1
    80007ae2:	a881                	j	80007b32 <bd_free+0xbe>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007ae4:	020a0a13          	addi	s4,s4,32
    80007ae8:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80007aea:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80007aee:	40ba85bb          	subw	a1,s5,a1
    80007af2:	009b97b3          	sll	a5,s7,s1
    80007af6:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007afa:	000b3783          	ld	a5,0(s6)
    80007afe:	97d2                	add	a5,a5,s4
    80007b00:	2581                	sext.w	a1,a1
    80007b02:	6f88                	ld	a0,24(a5)
    80007b04:	00000097          	auipc	ra,0x0
    80007b08:	b30080e7          	jalr	-1232(ra) # 80007634 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80007b0c:	000ca783          	lw	a5,0(s9)
    80007b10:	37fd                	addiw	a5,a5,-1
    80007b12:	06f4d163          	bge	s1,a5,80007b74 <bd_free+0x100>
  int n = p - (char *) bd_base;
    80007b16:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80007b1a:	009b99b3          	sll	s3,s7,s1
    80007b1e:	412a87bb          	subw	a5,s5,s2
    80007b22:	0337c7b3          	div	a5,a5,s3
    80007b26:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007b2a:	8b85                	andi	a5,a5,1
    80007b2c:	fbcd                	bnez	a5,80007ade <bd_free+0x6a>
    80007b2e:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007b32:	000b3d03          	ld	s10,0(s6)
    80007b36:	9d52                	add	s10,s10,s4
    80007b38:	010d3503          	ld	a0,16(s10)
    80007b3c:	00000097          	auipc	ra,0x0
    80007b40:	af8080e7          	jalr	-1288(ra) # 80007634 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80007b44:	85ee                	mv	a1,s11
    80007b46:	010d3503          	ld	a0,16(s10)
    80007b4a:	00000097          	auipc	ra,0x0
    80007b4e:	a82080e7          	jalr	-1406(ra) # 800075cc <bit_isset>
    80007b52:	e10d                	bnez	a0,80007b74 <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    80007b54:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80007b58:	03b989bb          	mulw	s3,s3,s11
    80007b5c:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80007b5e:	854a                	mv	a0,s2
    80007b60:	00000097          	auipc	ra,0x0
    80007b64:	630080e7          	jalr	1584(ra) # 80008190 <lst_remove>
    if(buddy % 2 == 0) {
    80007b68:	001d7d13          	andi	s10,s10,1
    80007b6c:	f60d1ce3          	bnez	s10,80007ae4 <bd_free+0x70>
      p = q;
    80007b70:	8aca                	mv	s5,s2
    80007b72:	bf8d                	j	80007ae4 <bd_free+0x70>
  }
  lst_push(&bd_sizes[k].free, p);
    80007b74:	0496                	slli	s1,s1,0x5
    80007b76:	85d6                	mv	a1,s5
    80007b78:	00022517          	auipc	a0,0x22
    80007b7c:	82853503          	ld	a0,-2008(a0) # 800293a0 <bd_sizes>
    80007b80:	9526                	add	a0,a0,s1
    80007b82:	00000097          	auipc	ra,0x0
    80007b86:	65a080e7          	jalr	1626(ra) # 800081dc <lst_push>
  release(&lock);
    80007b8a:	00021517          	auipc	a0,0x21
    80007b8e:	7b650513          	addi	a0,a0,1974 # 80029340 <lock>
    80007b92:	ffff9097          	auipc	ra,0xffff9
    80007b96:	fee080e7          	jalr	-18(ra) # 80000b80 <release>
}
    80007b9a:	70a6                	ld	ra,104(sp)
    80007b9c:	7406                	ld	s0,96(sp)
    80007b9e:	64e6                	ld	s1,88(sp)
    80007ba0:	6946                	ld	s2,80(sp)
    80007ba2:	69a6                	ld	s3,72(sp)
    80007ba4:	6a06                	ld	s4,64(sp)
    80007ba6:	7ae2                	ld	s5,56(sp)
    80007ba8:	7b42                	ld	s6,48(sp)
    80007baa:	7ba2                	ld	s7,40(sp)
    80007bac:	7c02                	ld	s8,32(sp)
    80007bae:	6ce2                	ld	s9,24(sp)
    80007bb0:	6d42                	ld	s10,16(sp)
    80007bb2:	6da2                	ld	s11,8(sp)
    80007bb4:	6165                	addi	sp,sp,112
    80007bb6:	8082                	ret

0000000080007bb8 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80007bb8:	1141                	addi	sp,sp,-16
    80007bba:	e422                	sd	s0,8(sp)
    80007bbc:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80007bbe:	00021797          	auipc	a5,0x21
    80007bc2:	7da7b783          	ld	a5,2010(a5) # 80029398 <bd_base>
    80007bc6:	8d9d                	sub	a1,a1,a5
    80007bc8:	47c1                	li	a5,16
    80007bca:	00a797b3          	sll	a5,a5,a0
    80007bce:	02f5c533          	div	a0,a1,a5
    80007bd2:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80007bd4:	02f5e5b3          	rem	a1,a1,a5
    80007bd8:	c191                	beqz	a1,80007bdc <blk_index_next+0x24>
      n++;
    80007bda:	2505                	addiw	a0,a0,1
  return n ;
}
    80007bdc:	6422                	ld	s0,8(sp)
    80007bde:	0141                	addi	sp,sp,16
    80007be0:	8082                	ret

0000000080007be2 <log2>:

int
log2(uint64 n) {
    80007be2:	1141                	addi	sp,sp,-16
    80007be4:	e422                	sd	s0,8(sp)
    80007be6:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80007be8:	4705                	li	a4,1
    80007bea:	00a77b63          	bgeu	a4,a0,80007c00 <log2+0x1e>
    80007bee:	87aa                	mv	a5,a0
  int k = 0;
    80007bf0:	4501                	li	a0,0
    k++;
    80007bf2:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80007bf4:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80007bf6:	fef76ee3          	bltu	a4,a5,80007bf2 <log2+0x10>
  }
  return k;
}
    80007bfa:	6422                	ld	s0,8(sp)
    80007bfc:	0141                	addi	sp,sp,16
    80007bfe:	8082                	ret
  int k = 0;
    80007c00:	4501                	li	a0,0
    80007c02:	bfe5                	j	80007bfa <log2+0x18>

0000000080007c04 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80007c04:	711d                	addi	sp,sp,-96
    80007c06:	ec86                	sd	ra,88(sp)
    80007c08:	e8a2                	sd	s0,80(sp)
    80007c0a:	e4a6                	sd	s1,72(sp)
    80007c0c:	e0ca                	sd	s2,64(sp)
    80007c0e:	fc4e                	sd	s3,56(sp)
    80007c10:	f852                	sd	s4,48(sp)
    80007c12:	f456                	sd	s5,40(sp)
    80007c14:	f05a                	sd	s6,32(sp)
    80007c16:	ec5e                	sd	s7,24(sp)
    80007c18:	e862                	sd	s8,16(sp)
    80007c1a:	e466                	sd	s9,8(sp)
    80007c1c:	e06a                	sd	s10,0(sp)
    80007c1e:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80007c20:	00b56933          	or	s2,a0,a1
    80007c24:	00f97913          	andi	s2,s2,15
    80007c28:	04091263          	bnez	s2,80007c6c <bd_mark+0x68>
    80007c2c:	8b2a                	mv	s6,a0
    80007c2e:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80007c30:	00021c17          	auipc	s8,0x21
    80007c34:	778c2c03          	lw	s8,1912(s8) # 800293a8 <nsizes>
    80007c38:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80007c3a:	00021d17          	auipc	s10,0x21
    80007c3e:	75ed0d13          	addi	s10,s10,1886 # 80029398 <bd_base>
  return n / BLK_SIZE(k);
    80007c42:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80007c44:	00021a97          	auipc	s5,0x21
    80007c48:	75ca8a93          	addi	s5,s5,1884 # 800293a0 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80007c4c:	07804563          	bgtz	s8,80007cb6 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80007c50:	60e6                	ld	ra,88(sp)
    80007c52:	6446                	ld	s0,80(sp)
    80007c54:	64a6                	ld	s1,72(sp)
    80007c56:	6906                	ld	s2,64(sp)
    80007c58:	79e2                	ld	s3,56(sp)
    80007c5a:	7a42                	ld	s4,48(sp)
    80007c5c:	7aa2                	ld	s5,40(sp)
    80007c5e:	7b02                	ld	s6,32(sp)
    80007c60:	6be2                	ld	s7,24(sp)
    80007c62:	6c42                	ld	s8,16(sp)
    80007c64:	6ca2                	ld	s9,8(sp)
    80007c66:	6d02                	ld	s10,0(sp)
    80007c68:	6125                	addi	sp,sp,96
    80007c6a:	8082                	ret
    panic("bd_mark");
    80007c6c:	00002517          	auipc	a0,0x2
    80007c70:	02450513          	addi	a0,a0,36 # 80009c90 <userret+0xc00>
    80007c74:	ffff9097          	auipc	ra,0xffff9
    80007c78:	8e6080e7          	jalr	-1818(ra) # 8000055a <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80007c7c:	000ab783          	ld	a5,0(s5)
    80007c80:	97ca                	add	a5,a5,s2
    80007c82:	85a6                	mv	a1,s1
    80007c84:	6b88                	ld	a0,16(a5)
    80007c86:	00000097          	auipc	ra,0x0
    80007c8a:	97e080e7          	jalr	-1666(ra) # 80007604 <bit_set>
    for(; bi < bj; bi++) {
    80007c8e:	2485                	addiw	s1,s1,1
    80007c90:	009a0e63          	beq	s4,s1,80007cac <bd_mark+0xa8>
      if(k > 0) {
    80007c94:	ff3054e3          	blez	s3,80007c7c <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80007c98:	000ab783          	ld	a5,0(s5)
    80007c9c:	97ca                	add	a5,a5,s2
    80007c9e:	85a6                	mv	a1,s1
    80007ca0:	6f88                	ld	a0,24(a5)
    80007ca2:	00000097          	auipc	ra,0x0
    80007ca6:	962080e7          	jalr	-1694(ra) # 80007604 <bit_set>
    80007caa:	bfc9                	j	80007c7c <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80007cac:	2985                	addiw	s3,s3,1
    80007cae:	02090913          	addi	s2,s2,32
    80007cb2:	f9898fe3          	beq	s3,s8,80007c50 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80007cb6:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80007cba:	409b04bb          	subw	s1,s6,s1
    80007cbe:	013c97b3          	sll	a5,s9,s3
    80007cc2:	02f4c4b3          	div	s1,s1,a5
    80007cc6:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80007cc8:	85de                	mv	a1,s7
    80007cca:	854e                	mv	a0,s3
    80007ccc:	00000097          	auipc	ra,0x0
    80007cd0:	eec080e7          	jalr	-276(ra) # 80007bb8 <blk_index_next>
    80007cd4:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80007cd6:	faa4cfe3          	blt	s1,a0,80007c94 <bd_mark+0x90>
    80007cda:	bfc9                	j	80007cac <bd_mark+0xa8>

0000000080007cdc <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80007cdc:	7139                	addi	sp,sp,-64
    80007cde:	fc06                	sd	ra,56(sp)
    80007ce0:	f822                	sd	s0,48(sp)
    80007ce2:	f426                	sd	s1,40(sp)
    80007ce4:	f04a                	sd	s2,32(sp)
    80007ce6:	ec4e                	sd	s3,24(sp)
    80007ce8:	e852                	sd	s4,16(sp)
    80007cea:	e456                	sd	s5,8(sp)
    80007cec:	e05a                	sd	s6,0(sp)
    80007cee:	0080                	addi	s0,sp,64
    80007cf0:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007cf2:	00058a9b          	sext.w	s5,a1
    80007cf6:	0015f793          	andi	a5,a1,1
    80007cfa:	ebad                	bnez	a5,80007d6c <bd_initfree_pair+0x90>
    80007cfc:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007d00:	00599493          	slli	s1,s3,0x5
    80007d04:	00021797          	auipc	a5,0x21
    80007d08:	69c7b783          	ld	a5,1692(a5) # 800293a0 <bd_sizes>
    80007d0c:	94be                	add	s1,s1,a5
    80007d0e:	0104bb03          	ld	s6,16(s1)
    80007d12:	855a                	mv	a0,s6
    80007d14:	00000097          	auipc	ra,0x0
    80007d18:	8b8080e7          	jalr	-1864(ra) # 800075cc <bit_isset>
    80007d1c:	892a                	mv	s2,a0
    80007d1e:	85d2                	mv	a1,s4
    80007d20:	855a                	mv	a0,s6
    80007d22:	00000097          	auipc	ra,0x0
    80007d26:	8aa080e7          	jalr	-1878(ra) # 800075cc <bit_isset>
  int free = 0;
    80007d2a:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007d2c:	02a90563          	beq	s2,a0,80007d56 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80007d30:	45c1                	li	a1,16
    80007d32:	013599b3          	sll	s3,a1,s3
    80007d36:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80007d3a:	02090c63          	beqz	s2,80007d72 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80007d3e:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80007d42:	00021597          	auipc	a1,0x21
    80007d46:	6565b583          	ld	a1,1622(a1) # 80029398 <bd_base>
    80007d4a:	95ce                	add	a1,a1,s3
    80007d4c:	8526                	mv	a0,s1
    80007d4e:	00000097          	auipc	ra,0x0
    80007d52:	48e080e7          	jalr	1166(ra) # 800081dc <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80007d56:	855a                	mv	a0,s6
    80007d58:	70e2                	ld	ra,56(sp)
    80007d5a:	7442                	ld	s0,48(sp)
    80007d5c:	74a2                	ld	s1,40(sp)
    80007d5e:	7902                	ld	s2,32(sp)
    80007d60:	69e2                	ld	s3,24(sp)
    80007d62:	6a42                	ld	s4,16(sp)
    80007d64:	6aa2                	ld	s5,8(sp)
    80007d66:	6b02                	ld	s6,0(sp)
    80007d68:	6121                	addi	sp,sp,64
    80007d6a:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007d6c:	fff58a1b          	addiw	s4,a1,-1
    80007d70:	bf41                	j	80007d00 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80007d72:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80007d76:	00021597          	auipc	a1,0x21
    80007d7a:	6225b583          	ld	a1,1570(a1) # 80029398 <bd_base>
    80007d7e:	95ce                	add	a1,a1,s3
    80007d80:	8526                	mv	a0,s1
    80007d82:	00000097          	auipc	ra,0x0
    80007d86:	45a080e7          	jalr	1114(ra) # 800081dc <lst_push>
    80007d8a:	b7f1                	j	80007d56 <bd_initfree_pair+0x7a>

0000000080007d8c <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80007d8c:	711d                	addi	sp,sp,-96
    80007d8e:	ec86                	sd	ra,88(sp)
    80007d90:	e8a2                	sd	s0,80(sp)
    80007d92:	e4a6                	sd	s1,72(sp)
    80007d94:	e0ca                	sd	s2,64(sp)
    80007d96:	fc4e                	sd	s3,56(sp)
    80007d98:	f852                	sd	s4,48(sp)
    80007d9a:	f456                	sd	s5,40(sp)
    80007d9c:	f05a                	sd	s6,32(sp)
    80007d9e:	ec5e                	sd	s7,24(sp)
    80007da0:	e862                	sd	s8,16(sp)
    80007da2:	e466                	sd	s9,8(sp)
    80007da4:	e06a                	sd	s10,0(sp)
    80007da6:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007da8:	00021717          	auipc	a4,0x21
    80007dac:	60072703          	lw	a4,1536(a4) # 800293a8 <nsizes>
    80007db0:	4785                	li	a5,1
    80007db2:	06e7db63          	bge	a5,a4,80007e28 <bd_initfree+0x9c>
    80007db6:	8aaa                	mv	s5,a0
    80007db8:	8b2e                	mv	s6,a1
    80007dba:	4901                	li	s2,0
  int free = 0;
    80007dbc:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80007dbe:	00021c97          	auipc	s9,0x21
    80007dc2:	5dac8c93          	addi	s9,s9,1498 # 80029398 <bd_base>
  return n / BLK_SIZE(k);
    80007dc6:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007dc8:	00021b97          	auipc	s7,0x21
    80007dcc:	5e0b8b93          	addi	s7,s7,1504 # 800293a8 <nsizes>
    80007dd0:	a039                	j	80007dde <bd_initfree+0x52>
    80007dd2:	2905                	addiw	s2,s2,1
    80007dd4:	000ba783          	lw	a5,0(s7)
    80007dd8:	37fd                	addiw	a5,a5,-1
    80007dda:	04f95863          	bge	s2,a5,80007e2a <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80007dde:	85d6                	mv	a1,s5
    80007de0:	854a                	mv	a0,s2
    80007de2:	00000097          	auipc	ra,0x0
    80007de6:	dd6080e7          	jalr	-554(ra) # 80007bb8 <blk_index_next>
    80007dea:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80007dec:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80007df0:	409b04bb          	subw	s1,s6,s1
    80007df4:	012c17b3          	sll	a5,s8,s2
    80007df8:	02f4c4b3          	div	s1,s1,a5
    80007dfc:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80007dfe:	85aa                	mv	a1,a0
    80007e00:	854a                	mv	a0,s2
    80007e02:	00000097          	auipc	ra,0x0
    80007e06:	eda080e7          	jalr	-294(ra) # 80007cdc <bd_initfree_pair>
    80007e0a:	01450d3b          	addw	s10,a0,s4
    80007e0e:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80007e12:	fc99d0e3          	bge	s3,s1,80007dd2 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80007e16:	85a6                	mv	a1,s1
    80007e18:	854a                	mv	a0,s2
    80007e1a:	00000097          	auipc	ra,0x0
    80007e1e:	ec2080e7          	jalr	-318(ra) # 80007cdc <bd_initfree_pair>
    80007e22:	00ad0a3b          	addw	s4,s10,a0
    80007e26:	b775                	j	80007dd2 <bd_initfree+0x46>
  int free = 0;
    80007e28:	4a01                	li	s4,0
  }
  return free;
}
    80007e2a:	8552                	mv	a0,s4
    80007e2c:	60e6                	ld	ra,88(sp)
    80007e2e:	6446                	ld	s0,80(sp)
    80007e30:	64a6                	ld	s1,72(sp)
    80007e32:	6906                	ld	s2,64(sp)
    80007e34:	79e2                	ld	s3,56(sp)
    80007e36:	7a42                	ld	s4,48(sp)
    80007e38:	7aa2                	ld	s5,40(sp)
    80007e3a:	7b02                	ld	s6,32(sp)
    80007e3c:	6be2                	ld	s7,24(sp)
    80007e3e:	6c42                	ld	s8,16(sp)
    80007e40:	6ca2                	ld	s9,8(sp)
    80007e42:	6d02                	ld	s10,0(sp)
    80007e44:	6125                	addi	sp,sp,96
    80007e46:	8082                	ret

0000000080007e48 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80007e48:	7179                	addi	sp,sp,-48
    80007e4a:	f406                	sd	ra,40(sp)
    80007e4c:	f022                	sd	s0,32(sp)
    80007e4e:	ec26                	sd	s1,24(sp)
    80007e50:	e84a                	sd	s2,16(sp)
    80007e52:	e44e                	sd	s3,8(sp)
    80007e54:	1800                	addi	s0,sp,48
    80007e56:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80007e58:	00021997          	auipc	s3,0x21
    80007e5c:	54098993          	addi	s3,s3,1344 # 80029398 <bd_base>
    80007e60:	0009b483          	ld	s1,0(s3)
    80007e64:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80007e68:	00021797          	auipc	a5,0x21
    80007e6c:	5407a783          	lw	a5,1344(a5) # 800293a8 <nsizes>
    80007e70:	37fd                	addiw	a5,a5,-1
    80007e72:	4641                	li	a2,16
    80007e74:	00f61633          	sll	a2,a2,a5
    80007e78:	85a6                	mv	a1,s1
    80007e7a:	00002517          	auipc	a0,0x2
    80007e7e:	e1e50513          	addi	a0,a0,-482 # 80009c98 <userret+0xc08>
    80007e82:	ffff8097          	auipc	ra,0xffff8
    80007e86:	732080e7          	jalr	1842(ra) # 800005b4 <printf>
  bd_mark(bd_base, p);
    80007e8a:	85ca                	mv	a1,s2
    80007e8c:	0009b503          	ld	a0,0(s3)
    80007e90:	00000097          	auipc	ra,0x0
    80007e94:	d74080e7          	jalr	-652(ra) # 80007c04 <bd_mark>
  return meta;
}
    80007e98:	8526                	mv	a0,s1
    80007e9a:	70a2                	ld	ra,40(sp)
    80007e9c:	7402                	ld	s0,32(sp)
    80007e9e:	64e2                	ld	s1,24(sp)
    80007ea0:	6942                	ld	s2,16(sp)
    80007ea2:	69a2                	ld	s3,8(sp)
    80007ea4:	6145                	addi	sp,sp,48
    80007ea6:	8082                	ret

0000000080007ea8 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80007ea8:	1101                	addi	sp,sp,-32
    80007eaa:	ec06                	sd	ra,24(sp)
    80007eac:	e822                	sd	s0,16(sp)
    80007eae:	e426                	sd	s1,8(sp)
    80007eb0:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80007eb2:	00021497          	auipc	s1,0x21
    80007eb6:	4f64a483          	lw	s1,1270(s1) # 800293a8 <nsizes>
    80007eba:	fff4879b          	addiw	a5,s1,-1
    80007ebe:	44c1                	li	s1,16
    80007ec0:	00f494b3          	sll	s1,s1,a5
    80007ec4:	00021797          	auipc	a5,0x21
    80007ec8:	4d47b783          	ld	a5,1236(a5) # 80029398 <bd_base>
    80007ecc:	8d1d                	sub	a0,a0,a5
    80007ece:	40a4853b          	subw	a0,s1,a0
    80007ed2:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80007ed6:	00905a63          	blez	s1,80007eea <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80007eda:	357d                	addiw	a0,a0,-1
    80007edc:	41f5549b          	sraiw	s1,a0,0x1f
    80007ee0:	01c4d49b          	srliw	s1,s1,0x1c
    80007ee4:	9ca9                	addw	s1,s1,a0
    80007ee6:	98c1                	andi	s1,s1,-16
    80007ee8:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80007eea:	85a6                	mv	a1,s1
    80007eec:	00002517          	auipc	a0,0x2
    80007ef0:	de450513          	addi	a0,a0,-540 # 80009cd0 <userret+0xc40>
    80007ef4:	ffff8097          	auipc	ra,0xffff8
    80007ef8:	6c0080e7          	jalr	1728(ra) # 800005b4 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007efc:	00021717          	auipc	a4,0x21
    80007f00:	49c73703          	ld	a4,1180(a4) # 80029398 <bd_base>
    80007f04:	00021597          	auipc	a1,0x21
    80007f08:	4a45a583          	lw	a1,1188(a1) # 800293a8 <nsizes>
    80007f0c:	fff5879b          	addiw	a5,a1,-1
    80007f10:	45c1                	li	a1,16
    80007f12:	00f595b3          	sll	a1,a1,a5
    80007f16:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80007f1a:	95ba                	add	a1,a1,a4
    80007f1c:	953a                	add	a0,a0,a4
    80007f1e:	00000097          	auipc	ra,0x0
    80007f22:	ce6080e7          	jalr	-794(ra) # 80007c04 <bd_mark>
  return unavailable;
}
    80007f26:	8526                	mv	a0,s1
    80007f28:	60e2                	ld	ra,24(sp)
    80007f2a:	6442                	ld	s0,16(sp)
    80007f2c:	64a2                	ld	s1,8(sp)
    80007f2e:	6105                	addi	sp,sp,32
    80007f30:	8082                	ret

0000000080007f32 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80007f32:	715d                	addi	sp,sp,-80
    80007f34:	e486                	sd	ra,72(sp)
    80007f36:	e0a2                	sd	s0,64(sp)
    80007f38:	fc26                	sd	s1,56(sp)
    80007f3a:	f84a                	sd	s2,48(sp)
    80007f3c:	f44e                	sd	s3,40(sp)
    80007f3e:	f052                	sd	s4,32(sp)
    80007f40:	ec56                	sd	s5,24(sp)
    80007f42:	e85a                	sd	s6,16(sp)
    80007f44:	e45e                	sd	s7,8(sp)
    80007f46:	e062                	sd	s8,0(sp)
    80007f48:	0880                	addi	s0,sp,80
    80007f4a:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80007f4c:	fff50493          	addi	s1,a0,-1
    80007f50:	98c1                	andi	s1,s1,-16
    80007f52:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80007f54:	00002597          	auipc	a1,0x2
    80007f58:	d9c58593          	addi	a1,a1,-612 # 80009cf0 <userret+0xc60>
    80007f5c:	00021517          	auipc	a0,0x21
    80007f60:	3e450513          	addi	a0,a0,996 # 80029340 <lock>
    80007f64:	ffff9097          	auipc	ra,0xffff9
    80007f68:	a78080e7          	jalr	-1416(ra) # 800009dc <initlock>
  bd_base = (void *) p;
    80007f6c:	00021797          	auipc	a5,0x21
    80007f70:	4297b623          	sd	s1,1068(a5) # 80029398 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007f74:	409c0933          	sub	s2,s8,s1
    80007f78:	43f95513          	srai	a0,s2,0x3f
    80007f7c:	893d                	andi	a0,a0,15
    80007f7e:	954a                	add	a0,a0,s2
    80007f80:	8511                	srai	a0,a0,0x4
    80007f82:	00000097          	auipc	ra,0x0
    80007f86:	c60080e7          	jalr	-928(ra) # 80007be2 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80007f8a:	47c1                	li	a5,16
    80007f8c:	00a797b3          	sll	a5,a5,a0
    80007f90:	1b27c663          	blt	a5,s2,8000813c <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007f94:	2505                	addiw	a0,a0,1
    80007f96:	00021797          	auipc	a5,0x21
    80007f9a:	40a7a923          	sw	a0,1042(a5) # 800293a8 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80007f9e:	00021997          	auipc	s3,0x21
    80007fa2:	40a98993          	addi	s3,s3,1034 # 800293a8 <nsizes>
    80007fa6:	0009a603          	lw	a2,0(s3)
    80007faa:	85ca                	mv	a1,s2
    80007fac:	00002517          	auipc	a0,0x2
    80007fb0:	d4c50513          	addi	a0,a0,-692 # 80009cf8 <userret+0xc68>
    80007fb4:	ffff8097          	auipc	ra,0xffff8
    80007fb8:	600080e7          	jalr	1536(ra) # 800005b4 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80007fbc:	00021797          	auipc	a5,0x21
    80007fc0:	3e97b223          	sd	s1,996(a5) # 800293a0 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80007fc4:	0009a603          	lw	a2,0(s3)
    80007fc8:	00561913          	slli	s2,a2,0x5
    80007fcc:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80007fce:	0056161b          	slliw	a2,a2,0x5
    80007fd2:	4581                	li	a1,0
    80007fd4:	8526                	mv	a0,s1
    80007fd6:	ffff9097          	auipc	ra,0xffff9
    80007fda:	da8080e7          	jalr	-600(ra) # 80000d7e <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80007fde:	0009a783          	lw	a5,0(s3)
    80007fe2:	06f05a63          	blez	a5,80008056 <bd_init+0x124>
    80007fe6:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80007fe8:	00021a97          	auipc	s5,0x21
    80007fec:	3b8a8a93          	addi	s5,s5,952 # 800293a0 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007ff0:	00021a17          	auipc	s4,0x21
    80007ff4:	3b8a0a13          	addi	s4,s4,952 # 800293a8 <nsizes>
    80007ff8:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80007ffa:	00599b93          	slli	s7,s3,0x5
    80007ffe:	000ab503          	ld	a0,0(s5)
    80008002:	955e                	add	a0,a0,s7
    80008004:	00000097          	auipc	ra,0x0
    80008008:	166080e7          	jalr	358(ra) # 8000816a <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    8000800c:	000a2483          	lw	s1,0(s4)
    80008010:	34fd                	addiw	s1,s1,-1
    80008012:	413484bb          	subw	s1,s1,s3
    80008016:	009b14bb          	sllw	s1,s6,s1
    8000801a:	fff4879b          	addiw	a5,s1,-1
    8000801e:	41f7d49b          	sraiw	s1,a5,0x1f
    80008022:	01d4d49b          	srliw	s1,s1,0x1d
    80008026:	9cbd                	addw	s1,s1,a5
    80008028:	98e1                	andi	s1,s1,-8
    8000802a:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    8000802c:	000ab783          	ld	a5,0(s5)
    80008030:	9bbe                	add	s7,s7,a5
    80008032:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80008036:	848d                	srai	s1,s1,0x3
    80008038:	8626                	mv	a2,s1
    8000803a:	4581                	li	a1,0
    8000803c:	854a                	mv	a0,s2
    8000803e:	ffff9097          	auipc	ra,0xffff9
    80008042:	d40080e7          	jalr	-704(ra) # 80000d7e <memset>
    p += sz;
    80008046:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80008048:	0985                	addi	s3,s3,1
    8000804a:	000a2703          	lw	a4,0(s4)
    8000804e:	0009879b          	sext.w	a5,s3
    80008052:	fae7c4e3          	blt	a5,a4,80007ffa <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80008056:	00021797          	auipc	a5,0x21
    8000805a:	3527a783          	lw	a5,850(a5) # 800293a8 <nsizes>
    8000805e:	4705                	li	a4,1
    80008060:	06f75163          	bge	a4,a5,800080c2 <bd_init+0x190>
    80008064:	02000a13          	li	s4,32
    80008068:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000806a:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    8000806c:	00021b17          	auipc	s6,0x21
    80008070:	334b0b13          	addi	s6,s6,820 # 800293a0 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80008074:	00021a97          	auipc	s5,0x21
    80008078:	334a8a93          	addi	s5,s5,820 # 800293a8 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000807c:	37fd                	addiw	a5,a5,-1
    8000807e:	413787bb          	subw	a5,a5,s3
    80008082:	00fb94bb          	sllw	s1,s7,a5
    80008086:	fff4879b          	addiw	a5,s1,-1
    8000808a:	41f7d49b          	sraiw	s1,a5,0x1f
    8000808e:	01d4d49b          	srliw	s1,s1,0x1d
    80008092:	9cbd                	addw	s1,s1,a5
    80008094:	98e1                	andi	s1,s1,-8
    80008096:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80008098:	000b3783          	ld	a5,0(s6)
    8000809c:	97d2                	add	a5,a5,s4
    8000809e:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    800080a2:	848d                	srai	s1,s1,0x3
    800080a4:	8626                	mv	a2,s1
    800080a6:	4581                	li	a1,0
    800080a8:	854a                	mv	a0,s2
    800080aa:	ffff9097          	auipc	ra,0xffff9
    800080ae:	cd4080e7          	jalr	-812(ra) # 80000d7e <memset>
    p += sz;
    800080b2:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    800080b4:	2985                	addiw	s3,s3,1
    800080b6:	000aa783          	lw	a5,0(s5)
    800080ba:	020a0a13          	addi	s4,s4,32
    800080be:	faf9cfe3          	blt	s3,a5,8000807c <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    800080c2:	197d                	addi	s2,s2,-1
    800080c4:	ff097913          	andi	s2,s2,-16
    800080c8:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    800080ca:	854a                	mv	a0,s2
    800080cc:	00000097          	auipc	ra,0x0
    800080d0:	d7c080e7          	jalr	-644(ra) # 80007e48 <bd_mark_data_structures>
    800080d4:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    800080d6:	85ca                	mv	a1,s2
    800080d8:	8562                	mv	a0,s8
    800080da:	00000097          	auipc	ra,0x0
    800080de:	dce080e7          	jalr	-562(ra) # 80007ea8 <bd_mark_unavailable>
    800080e2:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800080e4:	00021a97          	auipc	s5,0x21
    800080e8:	2c4a8a93          	addi	s5,s5,708 # 800293a8 <nsizes>
    800080ec:	000aa783          	lw	a5,0(s5)
    800080f0:	37fd                	addiw	a5,a5,-1
    800080f2:	44c1                	li	s1,16
    800080f4:	00f497b3          	sll	a5,s1,a5
    800080f8:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    800080fa:	00021597          	auipc	a1,0x21
    800080fe:	29e5b583          	ld	a1,670(a1) # 80029398 <bd_base>
    80008102:	95be                	add	a1,a1,a5
    80008104:	854a                	mv	a0,s2
    80008106:	00000097          	auipc	ra,0x0
    8000810a:	c86080e7          	jalr	-890(ra) # 80007d8c <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    8000810e:	000aa603          	lw	a2,0(s5)
    80008112:	367d                	addiw	a2,a2,-1
    80008114:	00c49633          	sll	a2,s1,a2
    80008118:	41460633          	sub	a2,a2,s4
    8000811c:	41360633          	sub	a2,a2,s3
    80008120:	02c51463          	bne	a0,a2,80008148 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80008124:	60a6                	ld	ra,72(sp)
    80008126:	6406                	ld	s0,64(sp)
    80008128:	74e2                	ld	s1,56(sp)
    8000812a:	7942                	ld	s2,48(sp)
    8000812c:	79a2                	ld	s3,40(sp)
    8000812e:	7a02                	ld	s4,32(sp)
    80008130:	6ae2                	ld	s5,24(sp)
    80008132:	6b42                	ld	s6,16(sp)
    80008134:	6ba2                	ld	s7,8(sp)
    80008136:	6c02                	ld	s8,0(sp)
    80008138:	6161                	addi	sp,sp,80
    8000813a:	8082                	ret
    nsizes++;  // round up to the next power of 2
    8000813c:	2509                	addiw	a0,a0,2
    8000813e:	00021797          	auipc	a5,0x21
    80008142:	26a7a523          	sw	a0,618(a5) # 800293a8 <nsizes>
    80008146:	bda1                	j	80007f9e <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80008148:	85aa                	mv	a1,a0
    8000814a:	00002517          	auipc	a0,0x2
    8000814e:	bee50513          	addi	a0,a0,-1042 # 80009d38 <userret+0xca8>
    80008152:	ffff8097          	auipc	ra,0xffff8
    80008156:	462080e7          	jalr	1122(ra) # 800005b4 <printf>
    panic("bd_init: free mem");
    8000815a:	00002517          	auipc	a0,0x2
    8000815e:	bee50513          	addi	a0,a0,-1042 # 80009d48 <userret+0xcb8>
    80008162:	ffff8097          	auipc	ra,0xffff8
    80008166:	3f8080e7          	jalr	1016(ra) # 8000055a <panic>

000000008000816a <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    8000816a:	1141                	addi	sp,sp,-16
    8000816c:	e422                	sd	s0,8(sp)
    8000816e:	0800                	addi	s0,sp,16
  lst->next = lst;
    80008170:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80008172:	e508                	sd	a0,8(a0)
}
    80008174:	6422                	ld	s0,8(sp)
    80008176:	0141                	addi	sp,sp,16
    80008178:	8082                	ret

000000008000817a <lst_empty>:

int
lst_empty(struct list *lst) {
    8000817a:	1141                	addi	sp,sp,-16
    8000817c:	e422                	sd	s0,8(sp)
    8000817e:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80008180:	611c                	ld	a5,0(a0)
    80008182:	40a78533          	sub	a0,a5,a0
}
    80008186:	00153513          	seqz	a0,a0
    8000818a:	6422                	ld	s0,8(sp)
    8000818c:	0141                	addi	sp,sp,16
    8000818e:	8082                	ret

0000000080008190 <lst_remove>:

void
lst_remove(struct list *e) {
    80008190:	1141                	addi	sp,sp,-16
    80008192:	e422                	sd	s0,8(sp)
    80008194:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80008196:	6518                	ld	a4,8(a0)
    80008198:	611c                	ld	a5,0(a0)
    8000819a:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000819c:	6518                	ld	a4,8(a0)
    8000819e:	e798                	sd	a4,8(a5)
}
    800081a0:	6422                	ld	s0,8(sp)
    800081a2:	0141                	addi	sp,sp,16
    800081a4:	8082                	ret

00000000800081a6 <lst_pop>:

void*
lst_pop(struct list *lst) {
    800081a6:	1101                	addi	sp,sp,-32
    800081a8:	ec06                	sd	ra,24(sp)
    800081aa:	e822                	sd	s0,16(sp)
    800081ac:	e426                	sd	s1,8(sp)
    800081ae:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    800081b0:	6104                	ld	s1,0(a0)
    800081b2:	00a48d63          	beq	s1,a0,800081cc <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    800081b6:	8526                	mv	a0,s1
    800081b8:	00000097          	auipc	ra,0x0
    800081bc:	fd8080e7          	jalr	-40(ra) # 80008190 <lst_remove>
  return (void *)p;
}
    800081c0:	8526                	mv	a0,s1
    800081c2:	60e2                	ld	ra,24(sp)
    800081c4:	6442                	ld	s0,16(sp)
    800081c6:	64a2                	ld	s1,8(sp)
    800081c8:	6105                	addi	sp,sp,32
    800081ca:	8082                	ret
    panic("lst_pop");
    800081cc:	00002517          	auipc	a0,0x2
    800081d0:	b9450513          	addi	a0,a0,-1132 # 80009d60 <userret+0xcd0>
    800081d4:	ffff8097          	auipc	ra,0xffff8
    800081d8:	386080e7          	jalr	902(ra) # 8000055a <panic>

00000000800081dc <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    800081dc:	1141                	addi	sp,sp,-16
    800081de:	e422                	sd	s0,8(sp)
    800081e0:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800081e2:	611c                	ld	a5,0(a0)
    800081e4:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800081e6:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800081e8:	611c                	ld	a5,0(a0)
    800081ea:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800081ec:	e10c                	sd	a1,0(a0)
}
    800081ee:	6422                	ld	s0,8(sp)
    800081f0:	0141                	addi	sp,sp,16
    800081f2:	8082                	ret

00000000800081f4 <lst_print>:

void
lst_print(struct list *lst)
{
    800081f4:	7179                	addi	sp,sp,-48
    800081f6:	f406                	sd	ra,40(sp)
    800081f8:	f022                	sd	s0,32(sp)
    800081fa:	ec26                	sd	s1,24(sp)
    800081fc:	e84a                	sd	s2,16(sp)
    800081fe:	e44e                	sd	s3,8(sp)
    80008200:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80008202:	6104                	ld	s1,0(a0)
    80008204:	02950063          	beq	a0,s1,80008224 <lst_print+0x30>
    80008208:	892a                	mv	s2,a0
    printf(" %p", p);
    8000820a:	00002997          	auipc	s3,0x2
    8000820e:	b5e98993          	addi	s3,s3,-1186 # 80009d68 <userret+0xcd8>
    80008212:	85a6                	mv	a1,s1
    80008214:	854e                	mv	a0,s3
    80008216:	ffff8097          	auipc	ra,0xffff8
    8000821a:	39e080e7          	jalr	926(ra) # 800005b4 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000821e:	6084                	ld	s1,0(s1)
    80008220:	fe9919e3          	bne	s2,s1,80008212 <lst_print+0x1e>
  }
  printf("\n");
    80008224:	00001517          	auipc	a0,0x1
    80008228:	06c50513          	addi	a0,a0,108 # 80009290 <userret+0x200>
    8000822c:	ffff8097          	auipc	ra,0xffff8
    80008230:	388080e7          	jalr	904(ra) # 800005b4 <printf>
}
    80008234:	70a2                	ld	ra,40(sp)
    80008236:	7402                	ld	s0,32(sp)
    80008238:	64e2                	ld	s1,24(sp)
    8000823a:	6942                	ld	s2,16(sp)
    8000823c:	69a2                	ld	s3,8(sp)
    8000823e:	6145                	addi	sp,sp,48
    80008240:	8082                	ret
	...

0000000080009000 <trampoline>:
    80009000:	14051573          	csrrw	a0,sscratch,a0
    80009004:	02153423          	sd	ra,40(a0)
    80009008:	02253823          	sd	sp,48(a0)
    8000900c:	02353c23          	sd	gp,56(a0)
    80009010:	04453023          	sd	tp,64(a0)
    80009014:	04553423          	sd	t0,72(a0)
    80009018:	04653823          	sd	t1,80(a0)
    8000901c:	04753c23          	sd	t2,88(a0)
    80009020:	f120                	sd	s0,96(a0)
    80009022:	f524                	sd	s1,104(a0)
    80009024:	fd2c                	sd	a1,120(a0)
    80009026:	e150                	sd	a2,128(a0)
    80009028:	e554                	sd	a3,136(a0)
    8000902a:	e958                	sd	a4,144(a0)
    8000902c:	ed5c                	sd	a5,152(a0)
    8000902e:	0b053023          	sd	a6,160(a0)
    80009032:	0b153423          	sd	a7,168(a0)
    80009036:	0b253823          	sd	s2,176(a0)
    8000903a:	0b353c23          	sd	s3,184(a0)
    8000903e:	0d453023          	sd	s4,192(a0)
    80009042:	0d553423          	sd	s5,200(a0)
    80009046:	0d653823          	sd	s6,208(a0)
    8000904a:	0d753c23          	sd	s7,216(a0)
    8000904e:	0f853023          	sd	s8,224(a0)
    80009052:	0f953423          	sd	s9,232(a0)
    80009056:	0fa53823          	sd	s10,240(a0)
    8000905a:	0fb53c23          	sd	s11,248(a0)
    8000905e:	11c53023          	sd	t3,256(a0)
    80009062:	11d53423          	sd	t4,264(a0)
    80009066:	11e53823          	sd	t5,272(a0)
    8000906a:	11f53c23          	sd	t6,280(a0)
    8000906e:	140022f3          	csrr	t0,sscratch
    80009072:	06553823          	sd	t0,112(a0)
    80009076:	00853103          	ld	sp,8(a0)
    8000907a:	02053203          	ld	tp,32(a0)
    8000907e:	01053283          	ld	t0,16(a0)
    80009082:	00053303          	ld	t1,0(a0)
    80009086:	18031073          	csrw	satp,t1
    8000908a:	12000073          	sfence.vma
    8000908e:	8282                	jr	t0

0000000080009090 <userret>:
    80009090:	18059073          	csrw	satp,a1
    80009094:	12000073          	sfence.vma
    80009098:	07053283          	ld	t0,112(a0)
    8000909c:	14029073          	csrw	sscratch,t0
    800090a0:	02853083          	ld	ra,40(a0)
    800090a4:	03053103          	ld	sp,48(a0)
    800090a8:	03853183          	ld	gp,56(a0)
    800090ac:	04053203          	ld	tp,64(a0)
    800090b0:	04853283          	ld	t0,72(a0)
    800090b4:	05053303          	ld	t1,80(a0)
    800090b8:	05853383          	ld	t2,88(a0)
    800090bc:	7120                	ld	s0,96(a0)
    800090be:	7524                	ld	s1,104(a0)
    800090c0:	7d2c                	ld	a1,120(a0)
    800090c2:	6150                	ld	a2,128(a0)
    800090c4:	6554                	ld	a3,136(a0)
    800090c6:	6958                	ld	a4,144(a0)
    800090c8:	6d5c                	ld	a5,152(a0)
    800090ca:	0a053803          	ld	a6,160(a0)
    800090ce:	0a853883          	ld	a7,168(a0)
    800090d2:	0b053903          	ld	s2,176(a0)
    800090d6:	0b853983          	ld	s3,184(a0)
    800090da:	0c053a03          	ld	s4,192(a0)
    800090de:	0c853a83          	ld	s5,200(a0)
    800090e2:	0d053b03          	ld	s6,208(a0)
    800090e6:	0d853b83          	ld	s7,216(a0)
    800090ea:	0e053c03          	ld	s8,224(a0)
    800090ee:	0e853c83          	ld	s9,232(a0)
    800090f2:	0f053d03          	ld	s10,240(a0)
    800090f6:	0f853d83          	ld	s11,248(a0)
    800090fa:	10053e03          	ld	t3,256(a0)
    800090fe:	10853e83          	ld	t4,264(a0)
    80009102:	11053f03          	ld	t5,272(a0)
    80009106:	11853f83          	ld	t6,280(a0)
    8000910a:	14051573          	csrrw	a0,sscratch,a0
    8000910e:	10200073          	sret
