
user/_nettests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <decode_qname>:
}

// Decode a DNS name
static void
decode_qname(char *qn)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  while(*qn != '\0') {
   6:	00054783          	lbu	a5,0(a0)
    int l = *qn;
   a:	0007861b          	sext.w	a2,a5
    if(l == 0)
      break;
    for(int i = 0; i < l; i++) {
   e:	4581                	li	a1,0
  10:	4885                	li	a7,1
      *qn = *(qn+1);
      qn++;
    }
    *qn++ = '.';
  12:	02e00813          	li	a6,46
  while(*qn != '\0') {
  16:	ef81                	bnez	a5,2e <decode_qname+0x2e>
  }
}
  18:	6422                	ld	s0,8(sp)
  1a:	0141                	addi	sp,sp,16
  1c:	8082                	ret
    *qn++ = '.';
  1e:	0709                	addi	a4,a4,2
  20:	953a                	add	a0,a0,a4
  22:	01078023          	sb	a6,0(a5)
  while(*qn != '\0') {
  26:	0017c603          	lbu	a2,1(a5)
  2a:	d67d                	beqz	a2,18 <decode_qname+0x18>
    int l = *qn;
  2c:	2601                	sext.w	a2,a2
{
  2e:	87aa                	mv	a5,a0
    for(int i = 0; i < l; i++) {
  30:	872e                	mv	a4,a1
      *qn = *(qn+1);
  32:	0017c683          	lbu	a3,1(a5)
  36:	00d78023          	sb	a3,0(a5)
      qn++;
  3a:	0785                	addi	a5,a5,1
    for(int i = 0; i < l; i++) {
  3c:	2705                	addiw	a4,a4,1
  3e:	fec74ae3          	blt	a4,a2,32 <decode_qname+0x32>
  42:	fff6069b          	addiw	a3,a2,-1
  46:	1682                	slli	a3,a3,0x20
  48:	9281                	srli	a3,a3,0x20
  4a:	87c6                	mv	a5,a7
  4c:	00c05463          	blez	a2,54 <decode_qname+0x54>
  50:	00168793          	addi	a5,a3,1
  54:	97aa                	add	a5,a5,a0
    *qn++ = '.';
  56:	872e                	mv	a4,a1
  58:	fcc053e3          	blez	a2,1e <decode_qname+0x1e>
  5c:	8736                	mv	a4,a3
  5e:	b7c1                	j	1e <decode_qname+0x1e>

0000000000000060 <ping>:
{
  60:	7131                	addi	sp,sp,-192
  62:	fd06                	sd	ra,184(sp)
  64:	f922                	sd	s0,176(sp)
  66:	f526                	sd	s1,168(sp)
  68:	f14a                	sd	s2,160(sp)
  6a:	ed4e                	sd	s3,152(sp)
  6c:	0180                	addi	s0,sp,192
  6e:	89b2                	mv	s3,a2
  char obuf[13] = "hello world!";
  70:	00001797          	auipc	a5,0x1
  74:	f2078793          	addi	a5,a5,-224 # f90 <malloc+0x154>
  78:	6398                	ld	a4,0(a5)
  7a:	fce43023          	sd	a4,-64(s0)
  7e:	4798                	lw	a4,8(a5)
  80:	fce42423          	sw	a4,-56(s0)
  84:	00c7c783          	lbu	a5,12(a5)
  88:	fcf40623          	sb	a5,-52(s0)
  if((fd = connect(dst, sport, dport)) < 0){
  8c:	862e                	mv	a2,a1
  8e:	85aa                	mv	a1,a0
  90:	0a000537          	lui	a0,0xa000
  94:	20250513          	addi	a0,a0,514 # a000202 <__global_pointer$+0x9ffe891>
  98:	00001097          	auipc	ra,0x1
  9c:	9fe080e7          	jalr	-1538(ra) # a96 <connect>
  a0:	06054763          	bltz	a0,10e <ping+0xae>
  a4:	892a                	mv	s2,a0
  for(int i = 0; i < attempts; i++) {
  a6:	4481                	li	s1,0
  a8:	01305f63          	blez	s3,c6 <ping+0x66>
    if(write(fd, obuf, sizeof(obuf)) < 0){
  ac:	4635                	li	a2,13
  ae:	fc040593          	addi	a1,s0,-64
  b2:	854a                	mv	a0,s2
  b4:	00001097          	auipc	ra,0x1
  b8:	962080e7          	jalr	-1694(ra) # a16 <write>
  bc:	06054763          	bltz	a0,12a <ping+0xca>
  for(int i = 0; i < attempts; i++) {
  c0:	2485                	addiw	s1,s1,1
  c2:	fe9995e3          	bne	s3,s1,ac <ping+0x4c>
  int cc = read(fd, ibuf, sizeof(ibuf));
  c6:	08000613          	li	a2,128
  ca:	f4040593          	addi	a1,s0,-192
  ce:	854a                	mv	a0,s2
  d0:	00001097          	auipc	ra,0x1
  d4:	93e080e7          	jalr	-1730(ra) # a0e <read>
  d8:	84aa                	mv	s1,a0
  if(cc < 0){
  da:	06054663          	bltz	a0,146 <ping+0xe6>
  close(fd);
  de:	854a                	mv	a0,s2
  e0:	00001097          	auipc	ra,0x1
  e4:	93e080e7          	jalr	-1730(ra) # a1e <close>
  if (strcmp(obuf, ibuf) || cc != sizeof(obuf)){
  e8:	f4040593          	addi	a1,s0,-192
  ec:	fc040513          	addi	a0,s0,-64
  f0:	00000097          	auipc	ra,0x0
  f4:	6ac080e7          	jalr	1708(ra) # 79c <strcmp>
  f8:	e52d                	bnez	a0,162 <ping+0x102>
  fa:	47b5                	li	a5,13
  fc:	06f49363          	bne	s1,a5,162 <ping+0x102>
}
 100:	70ea                	ld	ra,184(sp)
 102:	744a                	ld	s0,176(sp)
 104:	74aa                	ld	s1,168(sp)
 106:	790a                	ld	s2,160(sp)
 108:	69ea                	ld	s3,152(sp)
 10a:	6129                	addi	sp,sp,192
 10c:	8082                	ret
    fprintf(2, "ping: connect() failed\n");
 10e:	00001597          	auipc	a1,0x1
 112:	e1258593          	addi	a1,a1,-494 # f20 <malloc+0xe4>
 116:	4509                	li	a0,2
 118:	00001097          	auipc	ra,0x1
 11c:	c38080e7          	jalr	-968(ra) # d50 <fprintf>
    exit(1);
 120:	4505                	li	a0,1
 122:	00001097          	auipc	ra,0x1
 126:	8d4080e7          	jalr	-1836(ra) # 9f6 <exit>
      fprintf(2, "ping: send() failed\n");
 12a:	00001597          	auipc	a1,0x1
 12e:	e0e58593          	addi	a1,a1,-498 # f38 <malloc+0xfc>
 132:	4509                	li	a0,2
 134:	00001097          	auipc	ra,0x1
 138:	c1c080e7          	jalr	-996(ra) # d50 <fprintf>
      exit(1);
 13c:	4505                	li	a0,1
 13e:	00001097          	auipc	ra,0x1
 142:	8b8080e7          	jalr	-1864(ra) # 9f6 <exit>
    fprintf(2, "ping: recv() failed\n");
 146:	00001597          	auipc	a1,0x1
 14a:	e0a58593          	addi	a1,a1,-502 # f50 <malloc+0x114>
 14e:	4509                	li	a0,2
 150:	00001097          	auipc	ra,0x1
 154:	c00080e7          	jalr	-1024(ra) # d50 <fprintf>
    exit(1);
 158:	4505                	li	a0,1
 15a:	00001097          	auipc	ra,0x1
 15e:	89c080e7          	jalr	-1892(ra) # 9f6 <exit>
    fprintf(2, "ping didn't receive correct payload\n");
 162:	00001597          	auipc	a1,0x1
 166:	e0658593          	addi	a1,a1,-506 # f68 <malloc+0x12c>
 16a:	4509                	li	a0,2
 16c:	00001097          	auipc	ra,0x1
 170:	be4080e7          	jalr	-1052(ra) # d50 <fprintf>
    exit(1);
 174:	4505                	li	a0,1
 176:	00001097          	auipc	ra,0x1
 17a:	880080e7          	jalr	-1920(ra) # 9f6 <exit>

000000000000017e <dns>:
  }
}

static void
dns()
{
 17e:	7119                	addi	sp,sp,-128
 180:	fc86                	sd	ra,120(sp)
 182:	f8a2                	sd	s0,112(sp)
 184:	f4a6                	sd	s1,104(sp)
 186:	f0ca                	sd	s2,96(sp)
 188:	ecce                	sd	s3,88(sp)
 18a:	e8d2                	sd	s4,80(sp)
 18c:	e4d6                	sd	s5,72(sp)
 18e:	e0da                	sd	s6,64(sp)
 190:	fc5e                	sd	s7,56(sp)
 192:	f862                	sd	s8,48(sp)
 194:	f466                	sd	s9,40(sp)
 196:	f06a                	sd	s10,32(sp)
 198:	ec6e                	sd	s11,24(sp)
 19a:	0100                	addi	s0,sp,128
 19c:	83010113          	addi	sp,sp,-2000
  uint8 ibuf[N];
  uint32 dst;
  int fd;
  int len;

  memset(obuf, 0, N);
 1a0:	3e800613          	li	a2,1000
 1a4:	4581                	li	a1,0
 1a6:	ba840513          	addi	a0,s0,-1112
 1aa:	00000097          	auipc	ra,0x0
 1ae:	648080e7          	jalr	1608(ra) # 7f2 <memset>
  memset(ibuf, 0, N);
 1b2:	3e800613          	li	a2,1000
 1b6:	4581                	li	a1,0
 1b8:	77fd                	lui	a5,0xfffff
 1ba:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde4f>
 1be:	00f40533          	add	a0,s0,a5
 1c2:	00000097          	auipc	ra,0x0
 1c6:	630080e7          	jalr	1584(ra) # 7f2 <memset>
  
  // 8.8.8.8: google's name server
  dst = (8 << 24) | (8 << 16) | (8 << 8) | (8 << 0);

  if((fd = connect(dst, 10000, 53)) < 0){
 1ca:	03500613          	li	a2,53
 1ce:	6589                	lui	a1,0x2
 1d0:	71058593          	addi	a1,a1,1808 # 2710 <__global_pointer$+0xd9f>
 1d4:	08081537          	lui	a0,0x8081
 1d8:	80850513          	addi	a0,a0,-2040 # 8080808 <__global_pointer$+0x807ee97>
 1dc:	00001097          	auipc	ra,0x1
 1e0:	8ba080e7          	jalr	-1862(ra) # a96 <connect>
 1e4:	02054d63          	bltz	a0,21e <dns+0xa0>
 1e8:	892a                	mv	s2,a0
  hdr->id = htons(6828);
 1ea:	77ed                	lui	a5,0xffffb
 1ec:	c1a78793          	addi	a5,a5,-998 # ffffffffffffac1a <__global_pointer$+0xffffffffffff92a9>
 1f0:	baf41423          	sh	a5,-1112(s0)
  hdr->rd = 1;
 1f4:	baa45783          	lhu	a5,-1110(s0)
 1f8:	0017e793          	ori	a5,a5,1
 1fc:	baf41523          	sh	a5,-1110(s0)
  hdr->qdcount = htons(1);
 200:	10000793          	li	a5,256
 204:	baf41623          	sh	a5,-1108(s0)
  for(char *c = host; c < host+strlen(host)+1; c++) {
 208:	00001497          	auipc	s1,0x1
 20c:	d9848493          	addi	s1,s1,-616 # fa0 <malloc+0x164>
  char *l = host; 
 210:	8a26                	mv	s4,s1
  for(char *c = host; c < host+strlen(host)+1; c++) {
 212:	bb440993          	addi	s3,s0,-1100
 216:	8aa6                	mv	s5,s1
    if(*c == '.') {
 218:	02e00b13          	li	s6,46
  for(char *c = host; c < host+strlen(host)+1; c++) {
 21c:	a01d                	j	242 <dns+0xc4>
    fprintf(2, "ping: connect() failed\n");
 21e:	00001597          	auipc	a1,0x1
 222:	d0258593          	addi	a1,a1,-766 # f20 <malloc+0xe4>
 226:	4509                	li	a0,2
 228:	00001097          	auipc	ra,0x1
 22c:	b28080e7          	jalr	-1240(ra) # d50 <fprintf>
    exit(1);
 230:	4505                	li	a0,1
 232:	00000097          	auipc	ra,0x0
 236:	7c4080e7          	jalr	1988(ra) # 9f6 <exit>
      *qn++ = (char) (c-l);
 23a:	89b6                	mv	s3,a3
      l = c+1; // skip .
 23c:	00148a13          	addi	s4,s1,1
  for(char *c = host; c < host+strlen(host)+1; c++) {
 240:	0485                	addi	s1,s1,1
 242:	8556                	mv	a0,s5
 244:	00000097          	auipc	ra,0x0
 248:	584080e7          	jalr	1412(ra) # 7c8 <strlen>
 24c:	1502                	slli	a0,a0,0x20
 24e:	9101                	srli	a0,a0,0x20
 250:	0505                	addi	a0,a0,1
 252:	9556                	add	a0,a0,s5
 254:	02a4fc63          	bgeu	s1,a0,28c <dns+0x10e>
    if(*c == '.') {
 258:	0004c783          	lbu	a5,0(s1)
 25c:	ff6792e3          	bne	a5,s6,240 <dns+0xc2>
      *qn++ = (char) (c-l);
 260:	00198693          	addi	a3,s3,1
 264:	414487b3          	sub	a5,s1,s4
 268:	00f98023          	sb	a5,0(s3)
      for(char *d = l; d < c; d++) {
 26c:	fc9a77e3          	bgeu	s4,s1,23a <dns+0xbc>
 270:	87d2                	mv	a5,s4
      *qn++ = (char) (c-l);
 272:	8736                	mv	a4,a3
        *qn++ = *d;
 274:	0705                	addi	a4,a4,1
 276:	0007c603          	lbu	a2,0(a5)
 27a:	fec70fa3          	sb	a2,-1(a4)
      for(char *d = l; d < c; d++) {
 27e:	0785                	addi	a5,a5,1
 280:	fef49ae3          	bne	s1,a5,274 <dns+0xf6>
 284:	414489b3          	sub	s3,s1,s4
 288:	99b6                	add	s3,s3,a3
 28a:	bf4d                	j	23c <dns+0xbe>
  *qn = '\0';
 28c:	00098023          	sb	zero,0(s3)
  len += strlen(qname) + 1;
 290:	bb440513          	addi	a0,s0,-1100
 294:	00000097          	auipc	ra,0x0
 298:	534080e7          	jalr	1332(ra) # 7c8 <strlen>
 29c:	0005049b          	sext.w	s1,a0
  struct dns_question *h = (struct dns_question *) (qname+strlen(qname)+1);
 2a0:	bb440513          	addi	a0,s0,-1100
 2a4:	00000097          	auipc	ra,0x0
 2a8:	524080e7          	jalr	1316(ra) # 7c8 <strlen>
 2ac:	02051793          	slli	a5,a0,0x20
 2b0:	9381                	srli	a5,a5,0x20
 2b2:	0785                	addi	a5,a5,1
 2b4:	bb440713          	addi	a4,s0,-1100
 2b8:	97ba                	add	a5,a5,a4
  h->qtype = htons(0x1);
 2ba:	00078023          	sb	zero,0(a5)
 2be:	4705                	li	a4,1
 2c0:	00e780a3          	sb	a4,1(a5)
  h->qclass = htons(0x1);
 2c4:	00078123          	sb	zero,2(a5)
 2c8:	00e781a3          	sb	a4,3(a5)
  }

  len = dns_req(obuf);
  
  if(write(fd, obuf, len) < 0){
 2cc:	0114861b          	addiw	a2,s1,17
 2d0:	ba840593          	addi	a1,s0,-1112
 2d4:	854a                	mv	a0,s2
 2d6:	00000097          	auipc	ra,0x0
 2da:	740080e7          	jalr	1856(ra) # a16 <write>
 2de:	12054463          	bltz	a0,406 <dns+0x288>
    fprintf(2, "dns: send() failed\n");
    exit(1);
  }
  int cc = read(fd, ibuf, sizeof(ibuf));
 2e2:	3e800613          	li	a2,1000
 2e6:	77fd                	lui	a5,0xfffff
 2e8:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde4f>
 2ec:	00f405b3          	add	a1,s0,a5
 2f0:	854a                	mv	a0,s2
 2f2:	00000097          	auipc	ra,0x0
 2f6:	71c080e7          	jalr	1820(ra) # a0e <read>
 2fa:	89aa                	mv	s3,a0
  if(cc < 0){
 2fc:	12054363          	bltz	a0,422 <dns+0x2a4>
  if(!hdr->qr) {
 300:	77fd                	lui	a5,0xfffff
 302:	7c278793          	addi	a5,a5,1986 # fffffffffffff7c2 <__global_pointer$+0xffffffffffffde51>
 306:	97a2                	add	a5,a5,s0
 308:	00078783          	lb	a5,0(a5)
 30c:	1207d963          	bgez	a5,43e <dns+0x2c0>
  if(hdr->id != htons(6828))
 310:	77fd                	lui	a5,0xfffff
 312:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde4f>
 316:	97a2                	add	a5,a5,s0
 318:	0007d783          	lhu	a5,0(a5)
 31c:	0007869b          	sext.w	a3,a5
 320:	672d                	lui	a4,0xb
 322:	c1a70713          	addi	a4,a4,-998 # ac1a <__global_pointer$+0x92a9>
 326:	12e69163          	bne	a3,a4,448 <dns+0x2ca>
  if(hdr->rcode != 0) {
 32a:	777d                	lui	a4,0xfffff
 32c:	7c370793          	addi	a5,a4,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffde52>
 330:	97a2                	add	a5,a5,s0
 332:	0007c783          	lbu	a5,0(a5)
 336:	8bbd                	andi	a5,a5,15
 338:	12079863          	bnez	a5,468 <dns+0x2ea>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
 33c:	7c470793          	addi	a5,a4,1988
 340:	97a2                	add	a5,a5,s0
 342:	0007d783          	lhu	a5,0(a5)
 346:	0087d713          	srli	a4,a5,0x8
 34a:	0087979b          	slliw	a5,a5,0x8
 34e:	0ff77713          	andi	a4,a4,255
 352:	8fd9                	or	a5,a5,a4
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 354:	17c2                	slli	a5,a5,0x30
 356:	93c1                	srli	a5,a5,0x30
 358:	4a81                	li	s5,0
  len = sizeof(struct dns);
 35a:	44b1                	li	s1,12
  char *qname = 0;
 35c:	4a01                	li	s4,0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 35e:	c7a1                	beqz	a5,3a6 <dns+0x228>
    char *qn = (char *) (ibuf+len);
 360:	7b7d                	lui	s6,0xfffff
 362:	7c0b0793          	addi	a5,s6,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde4f>
 366:	97a2                	add	a5,a5,s0
 368:	00978a33          	add	s4,a5,s1
    decode_qname(qn);
 36c:	8552                	mv	a0,s4
 36e:	00000097          	auipc	ra,0x0
 372:	c92080e7          	jalr	-878(ra) # 0 <decode_qname>
    len += strlen(qn)+1;
 376:	8552                	mv	a0,s4
 378:	00000097          	auipc	ra,0x0
 37c:	450080e7          	jalr	1104(ra) # 7c8 <strlen>
    len += sizeof(struct dns_question);
 380:	2515                	addiw	a0,a0,5
 382:	9ca9                	addw	s1,s1,a0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 384:	2a85                	addiw	s5,s5,1
 386:	7c4b0793          	addi	a5,s6,1988
 38a:	97a2                	add	a5,a5,s0
 38c:	0007d783          	lhu	a5,0(a5)
 390:	0087d713          	srli	a4,a5,0x8
 394:	0087979b          	slliw	a5,a5,0x8
 398:	0ff77713          	andi	a4,a4,255
 39c:	8fd9                	or	a5,a5,a4
 39e:	17c2                	slli	a5,a5,0x30
 3a0:	93c1                	srli	a5,a5,0x30
 3a2:	fafacfe3          	blt	s5,a5,360 <dns+0x1e2>
 3a6:	77fd                	lui	a5,0xfffff
 3a8:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffde55>
 3ac:	97a2                	add	a5,a5,s0
 3ae:	0007d783          	lhu	a5,0(a5)
 3b2:	0087d713          	srli	a4,a5,0x8
 3b6:	0087979b          	slliw	a5,a5,0x8
 3ba:	0ff77713          	andi	a4,a4,255
 3be:	8fd9                	or	a5,a5,a4
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 3c0:	17c2                	slli	a5,a5,0x30
 3c2:	93c1                	srli	a5,a5,0x30
 3c4:	24078863          	beqz	a5,614 <dns+0x496>
 3c8:	00001797          	auipc	a5,0x1
 3cc:	cb878793          	addi	a5,a5,-840 # 1080 <malloc+0x244>
 3d0:	000a0363          	beqz	s4,3d6 <dns+0x258>
 3d4:	87d2                	mv	a5,s4
 3d6:	76fd                	lui	a3,0xfffff
 3d8:	7b068713          	addi	a4,a3,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffde3f>
 3dc:	9722                	add	a4,a4,s0
 3de:	e31c                	sd	a5,0(a4)
  int record = 0;
 3e0:	7b868793          	addi	a5,a3,1976
 3e4:	97a2                	add	a5,a5,s0
 3e6:	0007b023          	sd	zero,0(a5)
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 3ea:	4a01                	li	s4,0
    if((int) qn[0] > 63) {  // compression?
 3ec:	03f00d93          	li	s11,63
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 3f0:	4a85                	li	s5,1
 3f2:	4d11                	li	s10,4
      printf("DNS arecord for %s is ", qname ? qname : "" );
 3f4:	00001c97          	auipc	s9,0x1
 3f8:	c24c8c93          	addi	s9,s9,-988 # 1018 <malloc+0x1dc>
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 3fc:	08000c13          	li	s8,128
 400:	03400b93          	li	s7,52
 404:	a8e9                	j	4de <dns+0x360>
    fprintf(2, "dns: send() failed\n");
 406:	00001597          	auipc	a1,0x1
 40a:	bb258593          	addi	a1,a1,-1102 # fb8 <malloc+0x17c>
 40e:	4509                	li	a0,2
 410:	00001097          	auipc	ra,0x1
 414:	940080e7          	jalr	-1728(ra) # d50 <fprintf>
    exit(1);
 418:	4505                	li	a0,1
 41a:	00000097          	auipc	ra,0x0
 41e:	5dc080e7          	jalr	1500(ra) # 9f6 <exit>
    fprintf(2, "dns: recv() failed\n");
 422:	00001597          	auipc	a1,0x1
 426:	bae58593          	addi	a1,a1,-1106 # fd0 <malloc+0x194>
 42a:	4509                	li	a0,2
 42c:	00001097          	auipc	ra,0x1
 430:	924080e7          	jalr	-1756(ra) # d50 <fprintf>
    exit(1);
 434:	4505                	li	a0,1
 436:	00000097          	auipc	ra,0x0
 43a:	5c0080e7          	jalr	1472(ra) # 9f6 <exit>
    exit(1);
 43e:	4505                	li	a0,1
 440:	00000097          	auipc	ra,0x0
 444:	5b6080e7          	jalr	1462(ra) # 9f6 <exit>
 448:	0087d59b          	srliw	a1,a5,0x8
 44c:	0087979b          	slliw	a5,a5,0x8
 450:	8ddd                	or	a1,a1,a5
    printf("DNS wrong id: %d\n", ntohs(hdr->id));
 452:	15c2                	slli	a1,a1,0x30
 454:	91c1                	srli	a1,a1,0x30
 456:	00001517          	auipc	a0,0x1
 45a:	b9250513          	addi	a0,a0,-1134 # fe8 <malloc+0x1ac>
 45e:	00001097          	auipc	ra,0x1
 462:	920080e7          	jalr	-1760(ra) # d7e <printf>
 466:	b5d1                	j	32a <dns+0x1ac>
    printf("DNS rcode error: %x\n", hdr->rcode);
 468:	77fd                	lui	a5,0xfffff
 46a:	7c378793          	addi	a5,a5,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffde52>
 46e:	97a2                	add	a5,a5,s0
 470:	0007c583          	lbu	a1,0(a5)
 474:	89bd                	andi	a1,a1,15
 476:	00001517          	auipc	a0,0x1
 47a:	b8a50513          	addi	a0,a0,-1142 # 1000 <malloc+0x1c4>
 47e:	00001097          	auipc	ra,0x1
 482:	900080e7          	jalr	-1792(ra) # d7e <printf>
    exit(1);
 486:	4505                	li	a0,1
 488:	00000097          	auipc	ra,0x0
 48c:	56e080e7          	jalr	1390(ra) # 9f6 <exit>
      decode_qname(qn);
 490:	855a                	mv	a0,s6
 492:	00000097          	auipc	ra,0x0
 496:	b6e080e7          	jalr	-1170(ra) # 0 <decode_qname>
      len += strlen(qn)+1;
 49a:	855a                	mv	a0,s6
 49c:	00000097          	auipc	ra,0x0
 4a0:	32c080e7          	jalr	812(ra) # 7c8 <strlen>
 4a4:	2485                	addiw	s1,s1,1
 4a6:	9ca9                	addw	s1,s1,a0
 4a8:	a0b1                	j	4f4 <dns+0x376>
      len += 4;
 4aa:	00eb049b          	addiw	s1,s6,14
      record = 1;
 4ae:	77fd                	lui	a5,0xfffff
 4b0:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffde47>
 4b4:	97a2                	add	a5,a5,s0
 4b6:	0157b023          	sd	s5,0(a5)
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 4ba:	2a05                	addiw	s4,s4,1
 4bc:	77fd                	lui	a5,0xfffff
 4be:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffde55>
 4c2:	97a2                	add	a5,a5,s0
 4c4:	0007d783          	lhu	a5,0(a5)
 4c8:	0087d713          	srli	a4,a5,0x8
 4cc:	0087979b          	slliw	a5,a5,0x8
 4d0:	0ff77713          	andi	a4,a4,255
 4d4:	8fd9                	or	a5,a5,a4
 4d6:	17c2                	slli	a5,a5,0x30
 4d8:	93c1                	srli	a5,a5,0x30
 4da:	0efa5263          	bge	s4,a5,5be <dns+0x440>
    char *qn = (char *) (ibuf+len);
 4de:	77fd                	lui	a5,0xfffff
 4e0:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde4f>
 4e4:	97a2                	add	a5,a5,s0
 4e6:	00978b33          	add	s6,a5,s1
    if((int) qn[0] > 63) {  // compression?
 4ea:	000b4783          	lbu	a5,0(s6)
 4ee:	fafdf1e3          	bgeu	s11,a5,490 <dns+0x312>
      len += 2;
 4f2:	2489                	addiw	s1,s1,2
    struct dns_data *d = (struct dns_data *) (ibuf+len);
 4f4:	77fd                	lui	a5,0xfffff
 4f6:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde4f>
 4fa:	97a2                	add	a5,a5,s0
 4fc:	009786b3          	add	a3,a5,s1
    len += sizeof(struct dns_data);
 500:	00048b1b          	sext.w	s6,s1
 504:	24a9                	addiw	s1,s1,10
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 506:	0006c783          	lbu	a5,0(a3)
 50a:	0016c703          	lbu	a4,1(a3)
 50e:	0722                	slli	a4,a4,0x8
 510:	8fd9                	or	a5,a5,a4
 512:	0087979b          	slliw	a5,a5,0x8
 516:	8321                	srli	a4,a4,0x8
 518:	8fd9                	or	a5,a5,a4
 51a:	17c2                	slli	a5,a5,0x30
 51c:	93c1                	srli	a5,a5,0x30
 51e:	f9579ee3          	bne	a5,s5,4ba <dns+0x33c>
 522:	0086c783          	lbu	a5,8(a3)
 526:	0096c703          	lbu	a4,9(a3)
 52a:	0722                	slli	a4,a4,0x8
 52c:	8fd9                	or	a5,a5,a4
 52e:	0087979b          	slliw	a5,a5,0x8
 532:	8321                	srli	a4,a4,0x8
 534:	8fd9                	or	a5,a5,a4
 536:	17c2                	slli	a5,a5,0x30
 538:	93c1                	srli	a5,a5,0x30
 53a:	f9a790e3          	bne	a5,s10,4ba <dns+0x33c>
      printf("DNS arecord for %s is ", qname ? qname : "" );
 53e:	77fd                	lui	a5,0xfffff
 540:	7b078793          	addi	a5,a5,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffde3f>
 544:	97a2                	add	a5,a5,s0
 546:	638c                	ld	a1,0(a5)
 548:	8566                	mv	a0,s9
 54a:	00001097          	auipc	ra,0x1
 54e:	834080e7          	jalr	-1996(ra) # d7e <printf>
      uint8 *ip = (ibuf+len);
 552:	77fd                	lui	a5,0xfffff
 554:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde4f>
 558:	97a2                	add	a5,a5,s0
 55a:	94be                	add	s1,s1,a5
      printf("%d.%d.%d.%d\n", ip[0], ip[1], ip[2], ip[3]);
 55c:	0034c703          	lbu	a4,3(s1)
 560:	0024c683          	lbu	a3,2(s1)
 564:	0014c603          	lbu	a2,1(s1)
 568:	0004c583          	lbu	a1,0(s1)
 56c:	00001517          	auipc	a0,0x1
 570:	ac450513          	addi	a0,a0,-1340 # 1030 <malloc+0x1f4>
 574:	00001097          	auipc	ra,0x1
 578:	80a080e7          	jalr	-2038(ra) # d7e <printf>
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 57c:	0004c783          	lbu	a5,0(s1)
 580:	03879263          	bne	a5,s8,5a4 <dns+0x426>
 584:	0014c783          	lbu	a5,1(s1)
 588:	01779e63          	bne	a5,s7,5a4 <dns+0x426>
 58c:	0024c703          	lbu	a4,2(s1)
 590:	08100793          	li	a5,129
 594:	00f71863          	bne	a4,a5,5a4 <dns+0x426>
 598:	0034c703          	lbu	a4,3(s1)
 59c:	07e00793          	li	a5,126
 5a0:	f0f705e3          	beq	a4,a5,4aa <dns+0x32c>
        printf("wrong ip address");
 5a4:	00001517          	auipc	a0,0x1
 5a8:	a9c50513          	addi	a0,a0,-1380 # 1040 <malloc+0x204>
 5ac:	00000097          	auipc	ra,0x0
 5b0:	7d2080e7          	jalr	2002(ra) # d7e <printf>
        exit(1);
 5b4:	4505                	li	a0,1
 5b6:	00000097          	auipc	ra,0x0
 5ba:	440080e7          	jalr	1088(ra) # 9f6 <exit>
  if(len != cc) {
 5be:	04999d63          	bne	s3,s1,618 <dns+0x49a>
  if(!record) {
 5c2:	77fd                	lui	a5,0xfffff
 5c4:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffde47>
 5c8:	97a2                	add	a5,a5,s0
 5ca:	639c                	ld	a5,0(a5)
 5cc:	c79d                	beqz	a5,5fa <dns+0x47c>
  }
  dns_rep(ibuf, cc);

  close(fd);
 5ce:	854a                	mv	a0,s2
 5d0:	00000097          	auipc	ra,0x0
 5d4:	44e080e7          	jalr	1102(ra) # a1e <close>
}  
 5d8:	7d010113          	addi	sp,sp,2000
 5dc:	70e6                	ld	ra,120(sp)
 5de:	7446                	ld	s0,112(sp)
 5e0:	74a6                	ld	s1,104(sp)
 5e2:	7906                	ld	s2,96(sp)
 5e4:	69e6                	ld	s3,88(sp)
 5e6:	6a46                	ld	s4,80(sp)
 5e8:	6aa6                	ld	s5,72(sp)
 5ea:	6b06                	ld	s6,64(sp)
 5ec:	7be2                	ld	s7,56(sp)
 5ee:	7c42                	ld	s8,48(sp)
 5f0:	7ca2                	ld	s9,40(sp)
 5f2:	7d02                	ld	s10,32(sp)
 5f4:	6de2                	ld	s11,24(sp)
 5f6:	6109                	addi	sp,sp,128
 5f8:	8082                	ret
    printf("Didn't receive an arecord\n");
 5fa:	00001517          	auipc	a0,0x1
 5fe:	a8e50513          	addi	a0,a0,-1394 # 1088 <malloc+0x24c>
 602:	00000097          	auipc	ra,0x0
 606:	77c080e7          	jalr	1916(ra) # d7e <printf>
    exit(1);
 60a:	4505                	li	a0,1
 60c:	00000097          	auipc	ra,0x0
 610:	3ea080e7          	jalr	1002(ra) # 9f6 <exit>
  if(len != cc) {
 614:	fe9983e3          	beq	s3,s1,5fa <dns+0x47c>
    printf("Processed %d data bytes but received %d\n", len, cc);
 618:	864e                	mv	a2,s3
 61a:	85a6                	mv	a1,s1
 61c:	00001517          	auipc	a0,0x1
 620:	a3c50513          	addi	a0,a0,-1476 # 1058 <malloc+0x21c>
 624:	00000097          	auipc	ra,0x0
 628:	75a080e7          	jalr	1882(ra) # d7e <printf>
    exit(1);
 62c:	4505                	li	a0,1
 62e:	00000097          	auipc	ra,0x0
 632:	3c8080e7          	jalr	968(ra) # 9f6 <exit>

0000000000000636 <main>:

int
main(int argc, char *argv[])
{
 636:	7179                	addi	sp,sp,-48
 638:	f406                	sd	ra,40(sp)
 63a:	f022                	sd	s0,32(sp)
 63c:	ec26                	sd	s1,24(sp)
 63e:	e84a                	sd	s2,16(sp)
 640:	1800                	addi	s0,sp,48
  int i, ret;
  uint16 dport = NET_TESTS_PORT;

  printf("nettests running on port %d\n", dport);
 642:	6499                	lui	s1,0x6
 644:	5f348593          	addi	a1,s1,1523 # 65f3 <__global_pointer$+0x4c82>
 648:	00001517          	auipc	a0,0x1
 64c:	a6050513          	addi	a0,a0,-1440 # 10a8 <malloc+0x26c>
 650:	00000097          	auipc	ra,0x0
 654:	72e080e7          	jalr	1838(ra) # d7e <printf>

  printf("testing one ping: ");
 658:	00001517          	auipc	a0,0x1
 65c:	a7050513          	addi	a0,a0,-1424 # 10c8 <malloc+0x28c>
 660:	00000097          	auipc	ra,0x0
 664:	71e080e7          	jalr	1822(ra) # d7e <printf>
  ping(2000, dport, 2);
 668:	4609                	li	a2,2
 66a:	5f348593          	addi	a1,s1,1523
 66e:	7d000513          	li	a0,2000
 672:	00000097          	auipc	ra,0x0
 676:	9ee080e7          	jalr	-1554(ra) # 60 <ping>
  printf("OK\n");
 67a:	00001517          	auipc	a0,0x1
 67e:	a6650513          	addi	a0,a0,-1434 # 10e0 <malloc+0x2a4>
 682:	00000097          	auipc	ra,0x0
 686:	6fc080e7          	jalr	1788(ra) # d7e <printf>

  printf("testing single-process pings: ");
 68a:	00001517          	auipc	a0,0x1
 68e:	a5e50513          	addi	a0,a0,-1442 # 10e8 <malloc+0x2ac>
 692:	00000097          	auipc	ra,0x0
 696:	6ec080e7          	jalr	1772(ra) # d7e <printf>
 69a:	06400493          	li	s1,100
  for (i = 0; i < 100; i++)
    ping(2000, dport, 1);
 69e:	6919                	lui	s2,0x6
 6a0:	5f390913          	addi	s2,s2,1523 # 65f3 <__global_pointer$+0x4c82>
 6a4:	4605                	li	a2,1
 6a6:	85ca                	mv	a1,s2
 6a8:	7d000513          	li	a0,2000
 6ac:	00000097          	auipc	ra,0x0
 6b0:	9b4080e7          	jalr	-1612(ra) # 60 <ping>
  for (i = 0; i < 100; i++)
 6b4:	34fd                	addiw	s1,s1,-1
 6b6:	f4fd                	bnez	s1,6a4 <main+0x6e>
  printf("OK\n");
 6b8:	00001517          	auipc	a0,0x1
 6bc:	a2850513          	addi	a0,a0,-1496 # 10e0 <malloc+0x2a4>
 6c0:	00000097          	auipc	ra,0x0
 6c4:	6be080e7          	jalr	1726(ra) # d7e <printf>

  printf("testing multi-process pings: ");
 6c8:	00001517          	auipc	a0,0x1
 6cc:	a4050513          	addi	a0,a0,-1472 # 1108 <malloc+0x2cc>
 6d0:	00000097          	auipc	ra,0x0
 6d4:	6ae080e7          	jalr	1710(ra) # d7e <printf>
  for (i = 0; i < 10; i++){
 6d8:	4929                	li	s2,10
    int pid = fork();
 6da:	00000097          	auipc	ra,0x0
 6de:	314080e7          	jalr	788(ra) # 9ee <fork>
    if (pid == 0){
 6e2:	c92d                	beqz	a0,754 <main+0x11e>
  for (i = 0; i < 10; i++){
 6e4:	2485                	addiw	s1,s1,1
 6e6:	ff249ae3          	bne	s1,s2,6da <main+0xa4>
 6ea:	44a9                	li	s1,10
      ping(2000 + i + 1, dport, 1);
      exit(0);
    }
  }
  for (i = 0; i < 10; i++){
    wait(&ret);
 6ec:	fdc40513          	addi	a0,s0,-36
 6f0:	00000097          	auipc	ra,0x0
 6f4:	30e080e7          	jalr	782(ra) # 9fe <wait>
    if (ret != 0)
 6f8:	fdc42783          	lw	a5,-36(s0)
 6fc:	efad                	bnez	a5,776 <main+0x140>
  for (i = 0; i < 10; i++){
 6fe:	34fd                	addiw	s1,s1,-1
 700:	f4f5                	bnez	s1,6ec <main+0xb6>
      exit(1);
  }
  printf("OK\n");
 702:	00001517          	auipc	a0,0x1
 706:	9de50513          	addi	a0,a0,-1570 # 10e0 <malloc+0x2a4>
 70a:	00000097          	auipc	ra,0x0
 70e:	674080e7          	jalr	1652(ra) # d7e <printf>
  
  printf("testing DNS\n");
 712:	00001517          	auipc	a0,0x1
 716:	a1650513          	addi	a0,a0,-1514 # 1128 <malloc+0x2ec>
 71a:	00000097          	auipc	ra,0x0
 71e:	664080e7          	jalr	1636(ra) # d7e <printf>
  dns();
 722:	00000097          	auipc	ra,0x0
 726:	a5c080e7          	jalr	-1444(ra) # 17e <dns>
  printf("DNS OK\n");
 72a:	00001517          	auipc	a0,0x1
 72e:	a0e50513          	addi	a0,a0,-1522 # 1138 <malloc+0x2fc>
 732:	00000097          	auipc	ra,0x0
 736:	64c080e7          	jalr	1612(ra) # d7e <printf>
  
  printf("all tests passed.\n");
 73a:	00001517          	auipc	a0,0x1
 73e:	a0650513          	addi	a0,a0,-1530 # 1140 <malloc+0x304>
 742:	00000097          	auipc	ra,0x0
 746:	63c080e7          	jalr	1596(ra) # d7e <printf>
  exit(0);
 74a:	4501                	li	a0,0
 74c:	00000097          	auipc	ra,0x0
 750:	2aa080e7          	jalr	682(ra) # 9f6 <exit>
      ping(2000 + i + 1, dport, 1);
 754:	7d14851b          	addiw	a0,s1,2001
 758:	4605                	li	a2,1
 75a:	6599                	lui	a1,0x6
 75c:	5f358593          	addi	a1,a1,1523 # 65f3 <__global_pointer$+0x4c82>
 760:	1542                	slli	a0,a0,0x30
 762:	9141                	srli	a0,a0,0x30
 764:	00000097          	auipc	ra,0x0
 768:	8fc080e7          	jalr	-1796(ra) # 60 <ping>
      exit(0);
 76c:	4501                	li	a0,0
 76e:	00000097          	auipc	ra,0x0
 772:	288080e7          	jalr	648(ra) # 9f6 <exit>
      exit(1);
 776:	4505                	li	a0,1
 778:	00000097          	auipc	ra,0x0
 77c:	27e080e7          	jalr	638(ra) # 9f6 <exit>

0000000000000780 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 780:	1141                	addi	sp,sp,-16
 782:	e422                	sd	s0,8(sp)
 784:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 786:	87aa                	mv	a5,a0
 788:	0585                	addi	a1,a1,1
 78a:	0785                	addi	a5,a5,1
 78c:	fff5c703          	lbu	a4,-1(a1)
 790:	fee78fa3          	sb	a4,-1(a5)
 794:	fb75                	bnez	a4,788 <strcpy+0x8>
    ;
  return os;
}
 796:	6422                	ld	s0,8(sp)
 798:	0141                	addi	sp,sp,16
 79a:	8082                	ret

000000000000079c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 79c:	1141                	addi	sp,sp,-16
 79e:	e422                	sd	s0,8(sp)
 7a0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 7a2:	00054783          	lbu	a5,0(a0)
 7a6:	cb91                	beqz	a5,7ba <strcmp+0x1e>
 7a8:	0005c703          	lbu	a4,0(a1)
 7ac:	00f71763          	bne	a4,a5,7ba <strcmp+0x1e>
    p++, q++;
 7b0:	0505                	addi	a0,a0,1
 7b2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 7b4:	00054783          	lbu	a5,0(a0)
 7b8:	fbe5                	bnez	a5,7a8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 7ba:	0005c503          	lbu	a0,0(a1)
}
 7be:	40a7853b          	subw	a0,a5,a0
 7c2:	6422                	ld	s0,8(sp)
 7c4:	0141                	addi	sp,sp,16
 7c6:	8082                	ret

00000000000007c8 <strlen>:

uint
strlen(const char *s)
{
 7c8:	1141                	addi	sp,sp,-16
 7ca:	e422                	sd	s0,8(sp)
 7cc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 7ce:	00054783          	lbu	a5,0(a0)
 7d2:	cf91                	beqz	a5,7ee <strlen+0x26>
 7d4:	0505                	addi	a0,a0,1
 7d6:	87aa                	mv	a5,a0
 7d8:	4685                	li	a3,1
 7da:	9e89                	subw	a3,a3,a0
 7dc:	00f6853b          	addw	a0,a3,a5
 7e0:	0785                	addi	a5,a5,1
 7e2:	fff7c703          	lbu	a4,-1(a5)
 7e6:	fb7d                	bnez	a4,7dc <strlen+0x14>
    ;
  return n;
}
 7e8:	6422                	ld	s0,8(sp)
 7ea:	0141                	addi	sp,sp,16
 7ec:	8082                	ret
  for(n = 0; s[n]; n++)
 7ee:	4501                	li	a0,0
 7f0:	bfe5                	j	7e8 <strlen+0x20>

00000000000007f2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 7f2:	1141                	addi	sp,sp,-16
 7f4:	e422                	sd	s0,8(sp)
 7f6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 7f8:	ce09                	beqz	a2,812 <memset+0x20>
 7fa:	87aa                	mv	a5,a0
 7fc:	fff6071b          	addiw	a4,a2,-1
 800:	1702                	slli	a4,a4,0x20
 802:	9301                	srli	a4,a4,0x20
 804:	0705                	addi	a4,a4,1
 806:	972a                	add	a4,a4,a0
    cdst[i] = c;
 808:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 80c:	0785                	addi	a5,a5,1
 80e:	fee79de3          	bne	a5,a4,808 <memset+0x16>
  }
  return dst;
}
 812:	6422                	ld	s0,8(sp)
 814:	0141                	addi	sp,sp,16
 816:	8082                	ret

0000000000000818 <strchr>:

char*
strchr(const char *s, char c)
{
 818:	1141                	addi	sp,sp,-16
 81a:	e422                	sd	s0,8(sp)
 81c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 81e:	00054783          	lbu	a5,0(a0)
 822:	cb99                	beqz	a5,838 <strchr+0x20>
    if(*s == c)
 824:	00f58763          	beq	a1,a5,832 <strchr+0x1a>
  for(; *s; s++)
 828:	0505                	addi	a0,a0,1
 82a:	00054783          	lbu	a5,0(a0)
 82e:	fbfd                	bnez	a5,824 <strchr+0xc>
      return (char*)s;
  return 0;
 830:	4501                	li	a0,0
}
 832:	6422                	ld	s0,8(sp)
 834:	0141                	addi	sp,sp,16
 836:	8082                	ret
  return 0;
 838:	4501                	li	a0,0
 83a:	bfe5                	j	832 <strchr+0x1a>

000000000000083c <gets>:

char*
gets(char *buf, int max)
{
 83c:	711d                	addi	sp,sp,-96
 83e:	ec86                	sd	ra,88(sp)
 840:	e8a2                	sd	s0,80(sp)
 842:	e4a6                	sd	s1,72(sp)
 844:	e0ca                	sd	s2,64(sp)
 846:	fc4e                	sd	s3,56(sp)
 848:	f852                	sd	s4,48(sp)
 84a:	f456                	sd	s5,40(sp)
 84c:	f05a                	sd	s6,32(sp)
 84e:	ec5e                	sd	s7,24(sp)
 850:	1080                	addi	s0,sp,96
 852:	8baa                	mv	s7,a0
 854:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 856:	892a                	mv	s2,a0
 858:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 85a:	4aa9                	li	s5,10
 85c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 85e:	89a6                	mv	s3,s1
 860:	2485                	addiw	s1,s1,1
 862:	0344d863          	bge	s1,s4,892 <gets+0x56>
    cc = read(0, &c, 1);
 866:	4605                	li	a2,1
 868:	faf40593          	addi	a1,s0,-81
 86c:	4501                	li	a0,0
 86e:	00000097          	auipc	ra,0x0
 872:	1a0080e7          	jalr	416(ra) # a0e <read>
    if(cc < 1)
 876:	00a05e63          	blez	a0,892 <gets+0x56>
    buf[i++] = c;
 87a:	faf44783          	lbu	a5,-81(s0)
 87e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 882:	01578763          	beq	a5,s5,890 <gets+0x54>
 886:	0905                	addi	s2,s2,1
 888:	fd679be3          	bne	a5,s6,85e <gets+0x22>
  for(i=0; i+1 < max; ){
 88c:	89a6                	mv	s3,s1
 88e:	a011                	j	892 <gets+0x56>
 890:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 892:	99de                	add	s3,s3,s7
 894:	00098023          	sb	zero,0(s3)
  return buf;
}
 898:	855e                	mv	a0,s7
 89a:	60e6                	ld	ra,88(sp)
 89c:	6446                	ld	s0,80(sp)
 89e:	64a6                	ld	s1,72(sp)
 8a0:	6906                	ld	s2,64(sp)
 8a2:	79e2                	ld	s3,56(sp)
 8a4:	7a42                	ld	s4,48(sp)
 8a6:	7aa2                	ld	s5,40(sp)
 8a8:	7b02                	ld	s6,32(sp)
 8aa:	6be2                	ld	s7,24(sp)
 8ac:	6125                	addi	sp,sp,96
 8ae:	8082                	ret

00000000000008b0 <stat>:

int
stat(const char *n, struct stat *st)
{
 8b0:	1101                	addi	sp,sp,-32
 8b2:	ec06                	sd	ra,24(sp)
 8b4:	e822                	sd	s0,16(sp)
 8b6:	e426                	sd	s1,8(sp)
 8b8:	e04a                	sd	s2,0(sp)
 8ba:	1000                	addi	s0,sp,32
 8bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 8be:	4581                	li	a1,0
 8c0:	00000097          	auipc	ra,0x0
 8c4:	176080e7          	jalr	374(ra) # a36 <open>
  if(fd < 0)
 8c8:	02054563          	bltz	a0,8f2 <stat+0x42>
 8cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 8ce:	85ca                	mv	a1,s2
 8d0:	00000097          	auipc	ra,0x0
 8d4:	17e080e7          	jalr	382(ra) # a4e <fstat>
 8d8:	892a                	mv	s2,a0
  close(fd);
 8da:	8526                	mv	a0,s1
 8dc:	00000097          	auipc	ra,0x0
 8e0:	142080e7          	jalr	322(ra) # a1e <close>
  return r;
}
 8e4:	854a                	mv	a0,s2
 8e6:	60e2                	ld	ra,24(sp)
 8e8:	6442                	ld	s0,16(sp)
 8ea:	64a2                	ld	s1,8(sp)
 8ec:	6902                	ld	s2,0(sp)
 8ee:	6105                	addi	sp,sp,32
 8f0:	8082                	ret
    return -1;
 8f2:	597d                	li	s2,-1
 8f4:	bfc5                	j	8e4 <stat+0x34>

00000000000008f6 <atoi>:

int
atoi(const char *s)
{
 8f6:	1141                	addi	sp,sp,-16
 8f8:	e422                	sd	s0,8(sp)
 8fa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 8fc:	00054603          	lbu	a2,0(a0)
 900:	fd06079b          	addiw	a5,a2,-48
 904:	0ff7f793          	andi	a5,a5,255
 908:	4725                	li	a4,9
 90a:	02f76963          	bltu	a4,a5,93c <atoi+0x46>
 90e:	86aa                	mv	a3,a0
  n = 0;
 910:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 912:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 914:	0685                	addi	a3,a3,1
 916:	0025179b          	slliw	a5,a0,0x2
 91a:	9fa9                	addw	a5,a5,a0
 91c:	0017979b          	slliw	a5,a5,0x1
 920:	9fb1                	addw	a5,a5,a2
 922:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 926:	0006c603          	lbu	a2,0(a3)
 92a:	fd06071b          	addiw	a4,a2,-48
 92e:	0ff77713          	andi	a4,a4,255
 932:	fee5f1e3          	bgeu	a1,a4,914 <atoi+0x1e>
  return n;
}
 936:	6422                	ld	s0,8(sp)
 938:	0141                	addi	sp,sp,16
 93a:	8082                	ret
  n = 0;
 93c:	4501                	li	a0,0
 93e:	bfe5                	j	936 <atoi+0x40>

0000000000000940 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 940:	1141                	addi	sp,sp,-16
 942:	e422                	sd	s0,8(sp)
 944:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 946:	02b57663          	bgeu	a0,a1,972 <memmove+0x32>
    while(n-- > 0)
 94a:	02c05163          	blez	a2,96c <memmove+0x2c>
 94e:	fff6079b          	addiw	a5,a2,-1
 952:	1782                	slli	a5,a5,0x20
 954:	9381                	srli	a5,a5,0x20
 956:	0785                	addi	a5,a5,1
 958:	97aa                	add	a5,a5,a0
  dst = vdst;
 95a:	872a                	mv	a4,a0
      *dst++ = *src++;
 95c:	0585                	addi	a1,a1,1
 95e:	0705                	addi	a4,a4,1
 960:	fff5c683          	lbu	a3,-1(a1)
 964:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 968:	fee79ae3          	bne	a5,a4,95c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 96c:	6422                	ld	s0,8(sp)
 96e:	0141                	addi	sp,sp,16
 970:	8082                	ret
    dst += n;
 972:	00c50733          	add	a4,a0,a2
    src += n;
 976:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 978:	fec05ae3          	blez	a2,96c <memmove+0x2c>
 97c:	fff6079b          	addiw	a5,a2,-1
 980:	1782                	slli	a5,a5,0x20
 982:	9381                	srli	a5,a5,0x20
 984:	fff7c793          	not	a5,a5
 988:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 98a:	15fd                	addi	a1,a1,-1
 98c:	177d                	addi	a4,a4,-1
 98e:	0005c683          	lbu	a3,0(a1)
 992:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 996:	fee79ae3          	bne	a5,a4,98a <memmove+0x4a>
 99a:	bfc9                	j	96c <memmove+0x2c>

000000000000099c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 99c:	1141                	addi	sp,sp,-16
 99e:	e422                	sd	s0,8(sp)
 9a0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 9a2:	ca05                	beqz	a2,9d2 <memcmp+0x36>
 9a4:	fff6069b          	addiw	a3,a2,-1
 9a8:	1682                	slli	a3,a3,0x20
 9aa:	9281                	srli	a3,a3,0x20
 9ac:	0685                	addi	a3,a3,1
 9ae:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 9b0:	00054783          	lbu	a5,0(a0)
 9b4:	0005c703          	lbu	a4,0(a1)
 9b8:	00e79863          	bne	a5,a4,9c8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 9bc:	0505                	addi	a0,a0,1
    p2++;
 9be:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 9c0:	fed518e3          	bne	a0,a3,9b0 <memcmp+0x14>
  }
  return 0;
 9c4:	4501                	li	a0,0
 9c6:	a019                	j	9cc <memcmp+0x30>
      return *p1 - *p2;
 9c8:	40e7853b          	subw	a0,a5,a4
}
 9cc:	6422                	ld	s0,8(sp)
 9ce:	0141                	addi	sp,sp,16
 9d0:	8082                	ret
  return 0;
 9d2:	4501                	li	a0,0
 9d4:	bfe5                	j	9cc <memcmp+0x30>

00000000000009d6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 9d6:	1141                	addi	sp,sp,-16
 9d8:	e406                	sd	ra,8(sp)
 9da:	e022                	sd	s0,0(sp)
 9dc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 9de:	00000097          	auipc	ra,0x0
 9e2:	f62080e7          	jalr	-158(ra) # 940 <memmove>
}
 9e6:	60a2                	ld	ra,8(sp)
 9e8:	6402                	ld	s0,0(sp)
 9ea:	0141                	addi	sp,sp,16
 9ec:	8082                	ret

00000000000009ee <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 9ee:	4885                	li	a7,1
 ecall
 9f0:	00000073          	ecall
 ret
 9f4:	8082                	ret

00000000000009f6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 9f6:	4889                	li	a7,2
 ecall
 9f8:	00000073          	ecall
 ret
 9fc:	8082                	ret

00000000000009fe <wait>:
.global wait
wait:
 li a7, SYS_wait
 9fe:	488d                	li	a7,3
 ecall
 a00:	00000073          	ecall
 ret
 a04:	8082                	ret

0000000000000a06 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 a06:	4891                	li	a7,4
 ecall
 a08:	00000073          	ecall
 ret
 a0c:	8082                	ret

0000000000000a0e <read>:
.global read
read:
 li a7, SYS_read
 a0e:	4895                	li	a7,5
 ecall
 a10:	00000073          	ecall
 ret
 a14:	8082                	ret

0000000000000a16 <write>:
.global write
write:
 li a7, SYS_write
 a16:	48c1                	li	a7,16
 ecall
 a18:	00000073          	ecall
 ret
 a1c:	8082                	ret

0000000000000a1e <close>:
.global close
close:
 li a7, SYS_close
 a1e:	48d5                	li	a7,21
 ecall
 a20:	00000073          	ecall
 ret
 a24:	8082                	ret

0000000000000a26 <kill>:
.global kill
kill:
 li a7, SYS_kill
 a26:	4899                	li	a7,6
 ecall
 a28:	00000073          	ecall
 ret
 a2c:	8082                	ret

0000000000000a2e <exec>:
.global exec
exec:
 li a7, SYS_exec
 a2e:	489d                	li	a7,7
 ecall
 a30:	00000073          	ecall
 ret
 a34:	8082                	ret

0000000000000a36 <open>:
.global open
open:
 li a7, SYS_open
 a36:	48bd                	li	a7,15
 ecall
 a38:	00000073          	ecall
 ret
 a3c:	8082                	ret

0000000000000a3e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 a3e:	48c5                	li	a7,17
 ecall
 a40:	00000073          	ecall
 ret
 a44:	8082                	ret

0000000000000a46 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 a46:	48c9                	li	a7,18
 ecall
 a48:	00000073          	ecall
 ret
 a4c:	8082                	ret

0000000000000a4e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 a4e:	48a1                	li	a7,8
 ecall
 a50:	00000073          	ecall
 ret
 a54:	8082                	ret

0000000000000a56 <link>:
.global link
link:
 li a7, SYS_link
 a56:	48cd                	li	a7,19
 ecall
 a58:	00000073          	ecall
 ret
 a5c:	8082                	ret

0000000000000a5e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 a5e:	48d1                	li	a7,20
 ecall
 a60:	00000073          	ecall
 ret
 a64:	8082                	ret

0000000000000a66 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 a66:	48a5                	li	a7,9
 ecall
 a68:	00000073          	ecall
 ret
 a6c:	8082                	ret

0000000000000a6e <dup>:
.global dup
dup:
 li a7, SYS_dup
 a6e:	48a9                	li	a7,10
 ecall
 a70:	00000073          	ecall
 ret
 a74:	8082                	ret

0000000000000a76 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 a76:	48ad                	li	a7,11
 ecall
 a78:	00000073          	ecall
 ret
 a7c:	8082                	ret

0000000000000a7e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 a7e:	48b1                	li	a7,12
 ecall
 a80:	00000073          	ecall
 ret
 a84:	8082                	ret

0000000000000a86 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 a86:	48b5                	li	a7,13
 ecall
 a88:	00000073          	ecall
 ret
 a8c:	8082                	ret

0000000000000a8e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 a8e:	48b9                	li	a7,14
 ecall
 a90:	00000073          	ecall
 ret
 a94:	8082                	ret

0000000000000a96 <connect>:
.global connect
connect:
 li a7, SYS_connect
 a96:	48d9                	li	a7,22
 ecall
 a98:	00000073          	ecall
 ret
 a9c:	8082                	ret

0000000000000a9e <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 a9e:	48dd                	li	a7,23
 ecall
 aa0:	00000073          	ecall
 ret
 aa4:	8082                	ret

0000000000000aa6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 aa6:	1101                	addi	sp,sp,-32
 aa8:	ec06                	sd	ra,24(sp)
 aaa:	e822                	sd	s0,16(sp)
 aac:	1000                	addi	s0,sp,32
 aae:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 ab2:	4605                	li	a2,1
 ab4:	fef40593          	addi	a1,s0,-17
 ab8:	00000097          	auipc	ra,0x0
 abc:	f5e080e7          	jalr	-162(ra) # a16 <write>
}
 ac0:	60e2                	ld	ra,24(sp)
 ac2:	6442                	ld	s0,16(sp)
 ac4:	6105                	addi	sp,sp,32
 ac6:	8082                	ret

0000000000000ac8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 ac8:	7139                	addi	sp,sp,-64
 aca:	fc06                	sd	ra,56(sp)
 acc:	f822                	sd	s0,48(sp)
 ace:	f426                	sd	s1,40(sp)
 ad0:	f04a                	sd	s2,32(sp)
 ad2:	ec4e                	sd	s3,24(sp)
 ad4:	0080                	addi	s0,sp,64
 ad6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 ad8:	c299                	beqz	a3,ade <printint+0x16>
 ada:	0805c863          	bltz	a1,b6a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 ade:	2581                	sext.w	a1,a1
  neg = 0;
 ae0:	4881                	li	a7,0
 ae2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 ae6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 ae8:	2601                	sext.w	a2,a2
 aea:	00000517          	auipc	a0,0x0
 aee:	67650513          	addi	a0,a0,1654 # 1160 <digits>
 af2:	883a                	mv	a6,a4
 af4:	2705                	addiw	a4,a4,1
 af6:	02c5f7bb          	remuw	a5,a1,a2
 afa:	1782                	slli	a5,a5,0x20
 afc:	9381                	srli	a5,a5,0x20
 afe:	97aa                	add	a5,a5,a0
 b00:	0007c783          	lbu	a5,0(a5)
 b04:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 b08:	0005879b          	sext.w	a5,a1
 b0c:	02c5d5bb          	divuw	a1,a1,a2
 b10:	0685                	addi	a3,a3,1
 b12:	fec7f0e3          	bgeu	a5,a2,af2 <printint+0x2a>
  if(neg)
 b16:	00088b63          	beqz	a7,b2c <printint+0x64>
    buf[i++] = '-';
 b1a:	fd040793          	addi	a5,s0,-48
 b1e:	973e                	add	a4,a4,a5
 b20:	02d00793          	li	a5,45
 b24:	fef70823          	sb	a5,-16(a4)
 b28:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 b2c:	02e05863          	blez	a4,b5c <printint+0x94>
 b30:	fc040793          	addi	a5,s0,-64
 b34:	00e78933          	add	s2,a5,a4
 b38:	fff78993          	addi	s3,a5,-1
 b3c:	99ba                	add	s3,s3,a4
 b3e:	377d                	addiw	a4,a4,-1
 b40:	1702                	slli	a4,a4,0x20
 b42:	9301                	srli	a4,a4,0x20
 b44:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 b48:	fff94583          	lbu	a1,-1(s2)
 b4c:	8526                	mv	a0,s1
 b4e:	00000097          	auipc	ra,0x0
 b52:	f58080e7          	jalr	-168(ra) # aa6 <putc>
  while(--i >= 0)
 b56:	197d                	addi	s2,s2,-1
 b58:	ff3918e3          	bne	s2,s3,b48 <printint+0x80>
}
 b5c:	70e2                	ld	ra,56(sp)
 b5e:	7442                	ld	s0,48(sp)
 b60:	74a2                	ld	s1,40(sp)
 b62:	7902                	ld	s2,32(sp)
 b64:	69e2                	ld	s3,24(sp)
 b66:	6121                	addi	sp,sp,64
 b68:	8082                	ret
    x = -xx;
 b6a:	40b005bb          	negw	a1,a1
    neg = 1;
 b6e:	4885                	li	a7,1
    x = -xx;
 b70:	bf8d                	j	ae2 <printint+0x1a>

0000000000000b72 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 b72:	7119                	addi	sp,sp,-128
 b74:	fc86                	sd	ra,120(sp)
 b76:	f8a2                	sd	s0,112(sp)
 b78:	f4a6                	sd	s1,104(sp)
 b7a:	f0ca                	sd	s2,96(sp)
 b7c:	ecce                	sd	s3,88(sp)
 b7e:	e8d2                	sd	s4,80(sp)
 b80:	e4d6                	sd	s5,72(sp)
 b82:	e0da                	sd	s6,64(sp)
 b84:	fc5e                	sd	s7,56(sp)
 b86:	f862                	sd	s8,48(sp)
 b88:	f466                	sd	s9,40(sp)
 b8a:	f06a                	sd	s10,32(sp)
 b8c:	ec6e                	sd	s11,24(sp)
 b8e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 b90:	0005c903          	lbu	s2,0(a1)
 b94:	18090f63          	beqz	s2,d32 <vprintf+0x1c0>
 b98:	8aaa                	mv	s5,a0
 b9a:	8b32                	mv	s6,a2
 b9c:	00158493          	addi	s1,a1,1
  state = 0;
 ba0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 ba2:	02500a13          	li	s4,37
      if(c == 'd'){
 ba6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 baa:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 bae:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 bb2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bb6:	00000b97          	auipc	s7,0x0
 bba:	5aab8b93          	addi	s7,s7,1450 # 1160 <digits>
 bbe:	a839                	j	bdc <vprintf+0x6a>
        putc(fd, c);
 bc0:	85ca                	mv	a1,s2
 bc2:	8556                	mv	a0,s5
 bc4:	00000097          	auipc	ra,0x0
 bc8:	ee2080e7          	jalr	-286(ra) # aa6 <putc>
 bcc:	a019                	j	bd2 <vprintf+0x60>
    } else if(state == '%'){
 bce:	01498f63          	beq	s3,s4,bec <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 bd2:	0485                	addi	s1,s1,1
 bd4:	fff4c903          	lbu	s2,-1(s1)
 bd8:	14090d63          	beqz	s2,d32 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 bdc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 be0:	fe0997e3          	bnez	s3,bce <vprintf+0x5c>
      if(c == '%'){
 be4:	fd479ee3          	bne	a5,s4,bc0 <vprintf+0x4e>
        state = '%';
 be8:	89be                	mv	s3,a5
 bea:	b7e5                	j	bd2 <vprintf+0x60>
      if(c == 'd'){
 bec:	05878063          	beq	a5,s8,c2c <vprintf+0xba>
      } else if(c == 'l') {
 bf0:	05978c63          	beq	a5,s9,c48 <vprintf+0xd6>
      } else if(c == 'x') {
 bf4:	07a78863          	beq	a5,s10,c64 <vprintf+0xf2>
      } else if(c == 'p') {
 bf8:	09b78463          	beq	a5,s11,c80 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 bfc:	07300713          	li	a4,115
 c00:	0ce78663          	beq	a5,a4,ccc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c04:	06300713          	li	a4,99
 c08:	0ee78e63          	beq	a5,a4,d04 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 c0c:	11478863          	beq	a5,s4,d1c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c10:	85d2                	mv	a1,s4
 c12:	8556                	mv	a0,s5
 c14:	00000097          	auipc	ra,0x0
 c18:	e92080e7          	jalr	-366(ra) # aa6 <putc>
        putc(fd, c);
 c1c:	85ca                	mv	a1,s2
 c1e:	8556                	mv	a0,s5
 c20:	00000097          	auipc	ra,0x0
 c24:	e86080e7          	jalr	-378(ra) # aa6 <putc>
      }
      state = 0;
 c28:	4981                	li	s3,0
 c2a:	b765                	j	bd2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 c2c:	008b0913          	addi	s2,s6,8
 c30:	4685                	li	a3,1
 c32:	4629                	li	a2,10
 c34:	000b2583          	lw	a1,0(s6)
 c38:	8556                	mv	a0,s5
 c3a:	00000097          	auipc	ra,0x0
 c3e:	e8e080e7          	jalr	-370(ra) # ac8 <printint>
 c42:	8b4a                	mv	s6,s2
      state = 0;
 c44:	4981                	li	s3,0
 c46:	b771                	j	bd2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 c48:	008b0913          	addi	s2,s6,8
 c4c:	4681                	li	a3,0
 c4e:	4629                	li	a2,10
 c50:	000b2583          	lw	a1,0(s6)
 c54:	8556                	mv	a0,s5
 c56:	00000097          	auipc	ra,0x0
 c5a:	e72080e7          	jalr	-398(ra) # ac8 <printint>
 c5e:	8b4a                	mv	s6,s2
      state = 0;
 c60:	4981                	li	s3,0
 c62:	bf85                	j	bd2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 c64:	008b0913          	addi	s2,s6,8
 c68:	4681                	li	a3,0
 c6a:	4641                	li	a2,16
 c6c:	000b2583          	lw	a1,0(s6)
 c70:	8556                	mv	a0,s5
 c72:	00000097          	auipc	ra,0x0
 c76:	e56080e7          	jalr	-426(ra) # ac8 <printint>
 c7a:	8b4a                	mv	s6,s2
      state = 0;
 c7c:	4981                	li	s3,0
 c7e:	bf91                	j	bd2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 c80:	008b0793          	addi	a5,s6,8
 c84:	f8f43423          	sd	a5,-120(s0)
 c88:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 c8c:	03000593          	li	a1,48
 c90:	8556                	mv	a0,s5
 c92:	00000097          	auipc	ra,0x0
 c96:	e14080e7          	jalr	-492(ra) # aa6 <putc>
  putc(fd, 'x');
 c9a:	85ea                	mv	a1,s10
 c9c:	8556                	mv	a0,s5
 c9e:	00000097          	auipc	ra,0x0
 ca2:	e08080e7          	jalr	-504(ra) # aa6 <putc>
 ca6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ca8:	03c9d793          	srli	a5,s3,0x3c
 cac:	97de                	add	a5,a5,s7
 cae:	0007c583          	lbu	a1,0(a5)
 cb2:	8556                	mv	a0,s5
 cb4:	00000097          	auipc	ra,0x0
 cb8:	df2080e7          	jalr	-526(ra) # aa6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 cbc:	0992                	slli	s3,s3,0x4
 cbe:	397d                	addiw	s2,s2,-1
 cc0:	fe0914e3          	bnez	s2,ca8 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 cc4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 cc8:	4981                	li	s3,0
 cca:	b721                	j	bd2 <vprintf+0x60>
        s = va_arg(ap, char*);
 ccc:	008b0993          	addi	s3,s6,8
 cd0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 cd4:	02090163          	beqz	s2,cf6 <vprintf+0x184>
        while(*s != 0){
 cd8:	00094583          	lbu	a1,0(s2)
 cdc:	c9a1                	beqz	a1,d2c <vprintf+0x1ba>
          putc(fd, *s);
 cde:	8556                	mv	a0,s5
 ce0:	00000097          	auipc	ra,0x0
 ce4:	dc6080e7          	jalr	-570(ra) # aa6 <putc>
          s++;
 ce8:	0905                	addi	s2,s2,1
        while(*s != 0){
 cea:	00094583          	lbu	a1,0(s2)
 cee:	f9e5                	bnez	a1,cde <vprintf+0x16c>
        s = va_arg(ap, char*);
 cf0:	8b4e                	mv	s6,s3
      state = 0;
 cf2:	4981                	li	s3,0
 cf4:	bdf9                	j	bd2 <vprintf+0x60>
          s = "(null)";
 cf6:	00000917          	auipc	s2,0x0
 cfa:	46290913          	addi	s2,s2,1122 # 1158 <malloc+0x31c>
        while(*s != 0){
 cfe:	02800593          	li	a1,40
 d02:	bff1                	j	cde <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 d04:	008b0913          	addi	s2,s6,8
 d08:	000b4583          	lbu	a1,0(s6)
 d0c:	8556                	mv	a0,s5
 d0e:	00000097          	auipc	ra,0x0
 d12:	d98080e7          	jalr	-616(ra) # aa6 <putc>
 d16:	8b4a                	mv	s6,s2
      state = 0;
 d18:	4981                	li	s3,0
 d1a:	bd65                	j	bd2 <vprintf+0x60>
        putc(fd, c);
 d1c:	85d2                	mv	a1,s4
 d1e:	8556                	mv	a0,s5
 d20:	00000097          	auipc	ra,0x0
 d24:	d86080e7          	jalr	-634(ra) # aa6 <putc>
      state = 0;
 d28:	4981                	li	s3,0
 d2a:	b565                	j	bd2 <vprintf+0x60>
        s = va_arg(ap, char*);
 d2c:	8b4e                	mv	s6,s3
      state = 0;
 d2e:	4981                	li	s3,0
 d30:	b54d                	j	bd2 <vprintf+0x60>
    }
  }
}
 d32:	70e6                	ld	ra,120(sp)
 d34:	7446                	ld	s0,112(sp)
 d36:	74a6                	ld	s1,104(sp)
 d38:	7906                	ld	s2,96(sp)
 d3a:	69e6                	ld	s3,88(sp)
 d3c:	6a46                	ld	s4,80(sp)
 d3e:	6aa6                	ld	s5,72(sp)
 d40:	6b06                	ld	s6,64(sp)
 d42:	7be2                	ld	s7,56(sp)
 d44:	7c42                	ld	s8,48(sp)
 d46:	7ca2                	ld	s9,40(sp)
 d48:	7d02                	ld	s10,32(sp)
 d4a:	6de2                	ld	s11,24(sp)
 d4c:	6109                	addi	sp,sp,128
 d4e:	8082                	ret

0000000000000d50 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 d50:	715d                	addi	sp,sp,-80
 d52:	ec06                	sd	ra,24(sp)
 d54:	e822                	sd	s0,16(sp)
 d56:	1000                	addi	s0,sp,32
 d58:	e010                	sd	a2,0(s0)
 d5a:	e414                	sd	a3,8(s0)
 d5c:	e818                	sd	a4,16(s0)
 d5e:	ec1c                	sd	a5,24(s0)
 d60:	03043023          	sd	a6,32(s0)
 d64:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 d68:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 d6c:	8622                	mv	a2,s0
 d6e:	00000097          	auipc	ra,0x0
 d72:	e04080e7          	jalr	-508(ra) # b72 <vprintf>
}
 d76:	60e2                	ld	ra,24(sp)
 d78:	6442                	ld	s0,16(sp)
 d7a:	6161                	addi	sp,sp,80
 d7c:	8082                	ret

0000000000000d7e <printf>:

void
printf(const char *fmt, ...)
{
 d7e:	711d                	addi	sp,sp,-96
 d80:	ec06                	sd	ra,24(sp)
 d82:	e822                	sd	s0,16(sp)
 d84:	1000                	addi	s0,sp,32
 d86:	e40c                	sd	a1,8(s0)
 d88:	e810                	sd	a2,16(s0)
 d8a:	ec14                	sd	a3,24(s0)
 d8c:	f018                	sd	a4,32(s0)
 d8e:	f41c                	sd	a5,40(s0)
 d90:	03043823          	sd	a6,48(s0)
 d94:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 d98:	00840613          	addi	a2,s0,8
 d9c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 da0:	85aa                	mv	a1,a0
 da2:	4505                	li	a0,1
 da4:	00000097          	auipc	ra,0x0
 da8:	dce080e7          	jalr	-562(ra) # b72 <vprintf>
}
 dac:	60e2                	ld	ra,24(sp)
 dae:	6442                	ld	s0,16(sp)
 db0:	6125                	addi	sp,sp,96
 db2:	8082                	ret

0000000000000db4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 db4:	1141                	addi	sp,sp,-16
 db6:	e422                	sd	s0,8(sp)
 db8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 dba:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 dbe:	00000797          	auipc	a5,0x0
 dc2:	3ba7b783          	ld	a5,954(a5) # 1178 <freep>
 dc6:	a805                	j	df6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 dc8:	4618                	lw	a4,8(a2)
 dca:	9db9                	addw	a1,a1,a4
 dcc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 dd0:	6398                	ld	a4,0(a5)
 dd2:	6318                	ld	a4,0(a4)
 dd4:	fee53823          	sd	a4,-16(a0)
 dd8:	a091                	j	e1c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 dda:	ff852703          	lw	a4,-8(a0)
 dde:	9e39                	addw	a2,a2,a4
 de0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 de2:	ff053703          	ld	a4,-16(a0)
 de6:	e398                	sd	a4,0(a5)
 de8:	a099                	j	e2e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 dea:	6398                	ld	a4,0(a5)
 dec:	00e7e463          	bltu	a5,a4,df4 <free+0x40>
 df0:	00e6ea63          	bltu	a3,a4,e04 <free+0x50>
{
 df4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 df6:	fed7fae3          	bgeu	a5,a3,dea <free+0x36>
 dfa:	6398                	ld	a4,0(a5)
 dfc:	00e6e463          	bltu	a3,a4,e04 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e00:	fee7eae3          	bltu	a5,a4,df4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 e04:	ff852583          	lw	a1,-8(a0)
 e08:	6390                	ld	a2,0(a5)
 e0a:	02059713          	slli	a4,a1,0x20
 e0e:	9301                	srli	a4,a4,0x20
 e10:	0712                	slli	a4,a4,0x4
 e12:	9736                	add	a4,a4,a3
 e14:	fae60ae3          	beq	a2,a4,dc8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 e18:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 e1c:	4790                	lw	a2,8(a5)
 e1e:	02061713          	slli	a4,a2,0x20
 e22:	9301                	srli	a4,a4,0x20
 e24:	0712                	slli	a4,a4,0x4
 e26:	973e                	add	a4,a4,a5
 e28:	fae689e3          	beq	a3,a4,dda <free+0x26>
  } else
    p->s.ptr = bp;
 e2c:	e394                	sd	a3,0(a5)
  freep = p;
 e2e:	00000717          	auipc	a4,0x0
 e32:	34f73523          	sd	a5,842(a4) # 1178 <freep>
}
 e36:	6422                	ld	s0,8(sp)
 e38:	0141                	addi	sp,sp,16
 e3a:	8082                	ret

0000000000000e3c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 e3c:	7139                	addi	sp,sp,-64
 e3e:	fc06                	sd	ra,56(sp)
 e40:	f822                	sd	s0,48(sp)
 e42:	f426                	sd	s1,40(sp)
 e44:	f04a                	sd	s2,32(sp)
 e46:	ec4e                	sd	s3,24(sp)
 e48:	e852                	sd	s4,16(sp)
 e4a:	e456                	sd	s5,8(sp)
 e4c:	e05a                	sd	s6,0(sp)
 e4e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e50:	02051493          	slli	s1,a0,0x20
 e54:	9081                	srli	s1,s1,0x20
 e56:	04bd                	addi	s1,s1,15
 e58:	8091                	srli	s1,s1,0x4
 e5a:	0014899b          	addiw	s3,s1,1
 e5e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 e60:	00000517          	auipc	a0,0x0
 e64:	31853503          	ld	a0,792(a0) # 1178 <freep>
 e68:	c515                	beqz	a0,e94 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e6a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e6c:	4798                	lw	a4,8(a5)
 e6e:	02977f63          	bgeu	a4,s1,eac <malloc+0x70>
 e72:	8a4e                	mv	s4,s3
 e74:	0009871b          	sext.w	a4,s3
 e78:	6685                	lui	a3,0x1
 e7a:	00d77363          	bgeu	a4,a3,e80 <malloc+0x44>
 e7e:	6a05                	lui	s4,0x1
 e80:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 e84:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 e88:	00000917          	auipc	s2,0x0
 e8c:	2f090913          	addi	s2,s2,752 # 1178 <freep>
  if(p == (char*)-1)
 e90:	5afd                	li	s5,-1
 e92:	a88d                	j	f04 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 e94:	00000797          	auipc	a5,0x0
 e98:	2ec78793          	addi	a5,a5,748 # 1180 <base>
 e9c:	00000717          	auipc	a4,0x0
 ea0:	2cf73e23          	sd	a5,732(a4) # 1178 <freep>
 ea4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ea6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 eaa:	b7e1                	j	e72 <malloc+0x36>
      if(p->s.size == nunits)
 eac:	02e48b63          	beq	s1,a4,ee2 <malloc+0xa6>
        p->s.size -= nunits;
 eb0:	4137073b          	subw	a4,a4,s3
 eb4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 eb6:	1702                	slli	a4,a4,0x20
 eb8:	9301                	srli	a4,a4,0x20
 eba:	0712                	slli	a4,a4,0x4
 ebc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ebe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ec2:	00000717          	auipc	a4,0x0
 ec6:	2aa73b23          	sd	a0,694(a4) # 1178 <freep>
      return (void*)(p + 1);
 eca:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
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
        prevp->s.ptr = p->s.ptr;
 ee2:	6398                	ld	a4,0(a5)
 ee4:	e118                	sd	a4,0(a0)
 ee6:	bff1                	j	ec2 <malloc+0x86>
  hp->s.size = nu;
 ee8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 eec:	0541                	addi	a0,a0,16
 eee:	00000097          	auipc	ra,0x0
 ef2:	ec6080e7          	jalr	-314(ra) # db4 <free>
  return freep;
 ef6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 efa:	d971                	beqz	a0,ece <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 efc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 efe:	4798                	lw	a4,8(a5)
 f00:	fa9776e3          	bgeu	a4,s1,eac <malloc+0x70>
    if(p == freep)
 f04:	00093703          	ld	a4,0(s2)
 f08:	853e                	mv	a0,a5
 f0a:	fef719e3          	bne	a4,a5,efc <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 f0e:	8552                	mv	a0,s4
 f10:	00000097          	auipc	ra,0x0
 f14:	b6e080e7          	jalr	-1170(ra) # a7e <sbrk>
  if(p == (char*)-1)
 f18:	fd5518e3          	bne	a0,s5,ee8 <malloc+0xac>
        return 0;
 f1c:	4501                	li	a0,0
 f1e:	bf45                	j	ece <malloc+0x92>
