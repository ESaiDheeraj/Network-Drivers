
user/_bcachetest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <createfile>:
  exit(0);
}

void
createfile(char *file, int nblock)
{
   0:	bd010113          	addi	sp,sp,-1072
   4:	42113423          	sd	ra,1064(sp)
   8:	42813023          	sd	s0,1056(sp)
   c:	40913c23          	sd	s1,1048(sp)
  10:	41213823          	sd	s2,1040(sp)
  14:	41313423          	sd	s3,1032(sp)
  18:	41413023          	sd	s4,1024(sp)
  1c:	43010413          	addi	s0,sp,1072
  20:	8a2a                	mv	s4,a0
  22:	89ae                	mv	s3,a1
  int fd;
  char buf[BSIZE];
  int i;
  
  fd = open(file, O_CREATE | O_RDWR);
  24:	20200593          	li	a1,514
  28:	00000097          	auipc	ra,0x0
  2c:	762080e7          	jalr	1890(ra) # 78a <open>
  if(fd < 0){
  30:	04054a63          	bltz	a0,84 <createfile+0x84>
  34:	892a                	mv	s2,a0
    printf("test0 create %s failed\n", file);
    exit(-1);
  }
  for(i = 0; i < nblock; i++) {
  36:	4481                	li	s1,0
  38:	03305263          	blez	s3,5c <createfile+0x5c>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)) {
  3c:	40000613          	li	a2,1024
  40:	bd040593          	addi	a1,s0,-1072
  44:	854a                	mv	a0,s2
  46:	00000097          	auipc	ra,0x0
  4a:	724080e7          	jalr	1828(ra) # 76a <write>
  4e:	40000793          	li	a5,1024
  52:	04f51763          	bne	a0,a5,a0 <createfile+0xa0>
  for(i = 0; i < nblock; i++) {
  56:	2485                	addiw	s1,s1,1
  58:	fe9992e3          	bne	s3,s1,3c <createfile+0x3c>
      printf("write %s failed\n", file);
      exit(-1);
    }
  }
  close(fd);
  5c:	854a                	mv	a0,s2
  5e:	00000097          	auipc	ra,0x0
  62:	714080e7          	jalr	1812(ra) # 772 <close>
}
  66:	42813083          	ld	ra,1064(sp)
  6a:	42013403          	ld	s0,1056(sp)
  6e:	41813483          	ld	s1,1048(sp)
  72:	41013903          	ld	s2,1040(sp)
  76:	40813983          	ld	s3,1032(sp)
  7a:	40013a03          	ld	s4,1024(sp)
  7e:	43010113          	addi	sp,sp,1072
  82:	8082                	ret
    printf("test0 create %s failed\n", file);
  84:	85d2                	mv	a1,s4
  86:	00001517          	auipc	a0,0x1
  8a:	bf250513          	addi	a0,a0,-1038 # c78 <malloc+0xe8>
  8e:	00001097          	auipc	ra,0x1
  92:	a44080e7          	jalr	-1468(ra) # ad2 <printf>
    exit(-1);
  96:	557d                	li	a0,-1
  98:	00000097          	auipc	ra,0x0
  9c:	6b2080e7          	jalr	1714(ra) # 74a <exit>
      printf("write %s failed\n", file);
  a0:	85d2                	mv	a1,s4
  a2:	00001517          	auipc	a0,0x1
  a6:	bee50513          	addi	a0,a0,-1042 # c90 <malloc+0x100>
  aa:	00001097          	auipc	ra,0x1
  ae:	a28080e7          	jalr	-1496(ra) # ad2 <printf>
      exit(-1);
  b2:	557d                	li	a0,-1
  b4:	00000097          	auipc	ra,0x0
  b8:	696080e7          	jalr	1686(ra) # 74a <exit>

00000000000000bc <readfile>:

void
readfile(char *file, int nbytes, int inc)
{
  bc:	bc010113          	addi	sp,sp,-1088
  c0:	42113c23          	sd	ra,1080(sp)
  c4:	42813823          	sd	s0,1072(sp)
  c8:	42913423          	sd	s1,1064(sp)
  cc:	43213023          	sd	s2,1056(sp)
  d0:	41313c23          	sd	s3,1048(sp)
  d4:	41413823          	sd	s4,1040(sp)
  d8:	41513423          	sd	s5,1032(sp)
  dc:	44010413          	addi	s0,sp,1088
  char buf[BSIZE];
  int fd;
  int i;

  if(inc > BSIZE) {
  e0:	40000793          	li	a5,1024
  e4:	06c7c463          	blt	a5,a2,14c <readfile+0x90>
  e8:	8aaa                	mv	s5,a0
  ea:	8a2e                	mv	s4,a1
  ec:	84b2                	mv	s1,a2
    printf("test0: inc too large\n");
    exit(-1);
  }
  if ((fd = open(file, O_RDONLY)) < 0) {
  ee:	4581                	li	a1,0
  f0:	00000097          	auipc	ra,0x0
  f4:	69a080e7          	jalr	1690(ra) # 78a <open>
  f8:	89aa                	mv	s3,a0
  fa:	06054663          	bltz	a0,166 <readfile+0xaa>
    printf("test0 open %s failed\n", file);
    exit(-1);
  }
  for (i = 0; i < nbytes; i += inc) {
  fe:	4901                	li	s2,0
 100:	03405063          	blez	s4,120 <readfile+0x64>
    if(read(fd, buf, inc) != inc) {
 104:	8626                	mv	a2,s1
 106:	bc040593          	addi	a1,s0,-1088
 10a:	854e                	mv	a0,s3
 10c:	00000097          	auipc	ra,0x0
 110:	656080e7          	jalr	1622(ra) # 762 <read>
 114:	06951763          	bne	a0,s1,182 <readfile+0xc6>
  for (i = 0; i < nbytes; i += inc) {
 118:	0124893b          	addw	s2,s1,s2
 11c:	ff4944e3          	blt	s2,s4,104 <readfile+0x48>
      printf("read %s failed for block %d (%d)\n", file, i, nbytes);
      exit(-1);
    }
  }
  close(fd);
 120:	854e                	mv	a0,s3
 122:	00000097          	auipc	ra,0x0
 126:	650080e7          	jalr	1616(ra) # 772 <close>
}
 12a:	43813083          	ld	ra,1080(sp)
 12e:	43013403          	ld	s0,1072(sp)
 132:	42813483          	ld	s1,1064(sp)
 136:	42013903          	ld	s2,1056(sp)
 13a:	41813983          	ld	s3,1048(sp)
 13e:	41013a03          	ld	s4,1040(sp)
 142:	40813a83          	ld	s5,1032(sp)
 146:	44010113          	addi	sp,sp,1088
 14a:	8082                	ret
    printf("test0: inc too large\n");
 14c:	00001517          	auipc	a0,0x1
 150:	b5c50513          	addi	a0,a0,-1188 # ca8 <malloc+0x118>
 154:	00001097          	auipc	ra,0x1
 158:	97e080e7          	jalr	-1666(ra) # ad2 <printf>
    exit(-1);
 15c:	557d                	li	a0,-1
 15e:	00000097          	auipc	ra,0x0
 162:	5ec080e7          	jalr	1516(ra) # 74a <exit>
    printf("test0 open %s failed\n", file);
 166:	85d6                	mv	a1,s5
 168:	00001517          	auipc	a0,0x1
 16c:	b5850513          	addi	a0,a0,-1192 # cc0 <malloc+0x130>
 170:	00001097          	auipc	ra,0x1
 174:	962080e7          	jalr	-1694(ra) # ad2 <printf>
    exit(-1);
 178:	557d                	li	a0,-1
 17a:	00000097          	auipc	ra,0x0
 17e:	5d0080e7          	jalr	1488(ra) # 74a <exit>
      printf("read %s failed for block %d (%d)\n", file, i, nbytes);
 182:	86d2                	mv	a3,s4
 184:	864a                	mv	a2,s2
 186:	85d6                	mv	a1,s5
 188:	00001517          	auipc	a0,0x1
 18c:	b5050513          	addi	a0,a0,-1200 # cd8 <malloc+0x148>
 190:	00001097          	auipc	ra,0x1
 194:	942080e7          	jalr	-1726(ra) # ad2 <printf>
      exit(-1);
 198:	557d                	li	a0,-1
 19a:	00000097          	auipc	ra,0x0
 19e:	5b0080e7          	jalr	1456(ra) # 74a <exit>

00000000000001a2 <test0>:

void
test0()
{
 1a2:	7139                	addi	sp,sp,-64
 1a4:	fc06                	sd	ra,56(sp)
 1a6:	f822                	sd	s0,48(sp)
 1a8:	f426                	sd	s1,40(sp)
 1aa:	f04a                	sd	s2,32(sp)
 1ac:	ec4e                	sd	s3,24(sp)
 1ae:	0080                	addi	s0,sp,64
  char file[2];
  char dir[2];
  enum { N = 10, NCHILD = 3 };
  int n;

  dir[0] = '0';
 1b0:	03000793          	li	a5,48
 1b4:	fcf40023          	sb	a5,-64(s0)
  dir[1] = '\0';
 1b8:	fc0400a3          	sb	zero,-63(s0)
  file[0] = 'F';
 1bc:	04600793          	li	a5,70
 1c0:	fcf40423          	sb	a5,-56(s0)
  file[1] = '\0';
 1c4:	fc0404a3          	sb	zero,-55(s0)

  printf("start test0\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	b3850513          	addi	a0,a0,-1224 # d00 <malloc+0x170>
 1d0:	00001097          	auipc	ra,0x1
 1d4:	902080e7          	jalr	-1790(ra) # ad2 <printf>
 1d8:	03000493          	li	s1,48
      printf("chdir failed\n");
      exit(1);
    }
    unlink(file);
    createfile(file, N);
    if (chdir("..") < 0) {
 1dc:	00001997          	auipc	s3,0x1
 1e0:	b4498993          	addi	s3,s3,-1212 # d20 <malloc+0x190>
  for(int i = 0; i < NCHILD; i++){
 1e4:	03300913          	li	s2,51
    dir[0] = '0' + i;
 1e8:	fc940023          	sb	s1,-64(s0)
    mkdir(dir);
 1ec:	fc040513          	addi	a0,s0,-64
 1f0:	00000097          	auipc	ra,0x0
 1f4:	5c2080e7          	jalr	1474(ra) # 7b2 <mkdir>
    if (chdir(dir) < 0) {
 1f8:	fc040513          	addi	a0,s0,-64
 1fc:	00000097          	auipc	ra,0x0
 200:	5be080e7          	jalr	1470(ra) # 7ba <chdir>
 204:	0c054163          	bltz	a0,2c6 <test0+0x124>
    unlink(file);
 208:	fc840513          	addi	a0,s0,-56
 20c:	00000097          	auipc	ra,0x0
 210:	58e080e7          	jalr	1422(ra) # 79a <unlink>
    createfile(file, N);
 214:	45a9                	li	a1,10
 216:	fc840513          	addi	a0,s0,-56
 21a:	00000097          	auipc	ra,0x0
 21e:	de6080e7          	jalr	-538(ra) # 0 <createfile>
    if (chdir("..") < 0) {
 222:	854e                	mv	a0,s3
 224:	00000097          	auipc	ra,0x0
 228:	596080e7          	jalr	1430(ra) # 7ba <chdir>
 22c:	0a054a63          	bltz	a0,2e0 <test0+0x13e>
  for(int i = 0; i < NCHILD; i++){
 230:	2485                	addiw	s1,s1,1
 232:	0ff4f493          	andi	s1,s1,255
 236:	fb2499e3          	bne	s1,s2,1e8 <test0+0x46>
      printf("chdir failed\n");
      exit(1);
    }
  }
  ntas(0);
 23a:	4501                	li	a0,0
 23c:	00000097          	auipc	ra,0x0
 240:	5b6080e7          	jalr	1462(ra) # 7f2 <ntas>
 244:	03000493          	li	s1,48
  for(int i = 0; i < NCHILD; i++){
 248:	03300913          	li	s2,51
    dir[0] = '0' + i;
 24c:	fc940023          	sb	s1,-64(s0)
    int pid = fork();
 250:	00000097          	auipc	ra,0x0
 254:	4f2080e7          	jalr	1266(ra) # 742 <fork>
    if(pid < 0){
 258:	0a054163          	bltz	a0,2fa <test0+0x158>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 25c:	cd45                	beqz	a0,314 <test0+0x172>
  for(int i = 0; i < NCHILD; i++){
 25e:	2485                	addiw	s1,s1,1
 260:	0ff4f493          	andi	s1,s1,255
 264:	ff2494e3          	bne	s1,s2,24c <test0+0xaa>
      exit(0);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
 268:	4501                	li	a0,0
 26a:	00000097          	auipc	ra,0x0
 26e:	4e8080e7          	jalr	1256(ra) # 752 <wait>
 272:	4501                	li	a0,0
 274:	00000097          	auipc	ra,0x0
 278:	4de080e7          	jalr	1246(ra) # 752 <wait>
 27c:	4501                	li	a0,0
 27e:	00000097          	auipc	ra,0x0
 282:	4d4080e7          	jalr	1236(ra) # 752 <wait>
  }
  printf("test0 results:\n");
 286:	00001517          	auipc	a0,0x1
 28a:	ab250513          	addi	a0,a0,-1358 # d38 <malloc+0x1a8>
 28e:	00001097          	auipc	ra,0x1
 292:	844080e7          	jalr	-1980(ra) # ad2 <printf>
  n = ntas(1);
 296:	4505                	li	a0,1
 298:	00000097          	auipc	ra,0x0
 29c:	55a080e7          	jalr	1370(ra) # 7f2 <ntas>
  if (n < 500)
 2a0:	1f300793          	li	a5,499
 2a4:	0aa7cc63          	blt	a5,a0,35c <test0+0x1ba>
    printf("test0: OK\n");
 2a8:	00001517          	auipc	a0,0x1
 2ac:	aa050513          	addi	a0,a0,-1376 # d48 <malloc+0x1b8>
 2b0:	00001097          	auipc	ra,0x1
 2b4:	822080e7          	jalr	-2014(ra) # ad2 <printf>
  else
    printf("test0: FAIL\n");
}
 2b8:	70e2                	ld	ra,56(sp)
 2ba:	7442                	ld	s0,48(sp)
 2bc:	74a2                	ld	s1,40(sp)
 2be:	7902                	ld	s2,32(sp)
 2c0:	69e2                	ld	s3,24(sp)
 2c2:	6121                	addi	sp,sp,64
 2c4:	8082                	ret
      printf("chdir failed\n");
 2c6:	00001517          	auipc	a0,0x1
 2ca:	a4a50513          	addi	a0,a0,-1462 # d10 <malloc+0x180>
 2ce:	00001097          	auipc	ra,0x1
 2d2:	804080e7          	jalr	-2044(ra) # ad2 <printf>
      exit(1);
 2d6:	4505                	li	a0,1
 2d8:	00000097          	auipc	ra,0x0
 2dc:	472080e7          	jalr	1138(ra) # 74a <exit>
      printf("chdir failed\n");
 2e0:	00001517          	auipc	a0,0x1
 2e4:	a3050513          	addi	a0,a0,-1488 # d10 <malloc+0x180>
 2e8:	00000097          	auipc	ra,0x0
 2ec:	7ea080e7          	jalr	2026(ra) # ad2 <printf>
      exit(1);
 2f0:	4505                	li	a0,1
 2f2:	00000097          	auipc	ra,0x0
 2f6:	458080e7          	jalr	1112(ra) # 74a <exit>
      printf("fork failed");
 2fa:	00001517          	auipc	a0,0x1
 2fe:	a2e50513          	addi	a0,a0,-1490 # d28 <malloc+0x198>
 302:	00000097          	auipc	ra,0x0
 306:	7d0080e7          	jalr	2000(ra) # ad2 <printf>
      exit(-1);
 30a:	557d                	li	a0,-1
 30c:	00000097          	auipc	ra,0x0
 310:	43e080e7          	jalr	1086(ra) # 74a <exit>
      if (chdir(dir) < 0) {
 314:	fc040513          	addi	a0,s0,-64
 318:	00000097          	auipc	ra,0x0
 31c:	4a2080e7          	jalr	1186(ra) # 7ba <chdir>
 320:	02054163          	bltz	a0,342 <test0+0x1a0>
      readfile(file, N*BSIZE, 1);
 324:	4605                	li	a2,1
 326:	658d                	lui	a1,0x3
 328:	80058593          	addi	a1,a1,-2048 # 2800 <__global_pointer$+0x125f>
 32c:	fc840513          	addi	a0,s0,-56
 330:	00000097          	auipc	ra,0x0
 334:	d8c080e7          	jalr	-628(ra) # bc <readfile>
      exit(0);
 338:	4501                	li	a0,0
 33a:	00000097          	auipc	ra,0x0
 33e:	410080e7          	jalr	1040(ra) # 74a <exit>
        printf("chdir failed\n");
 342:	00001517          	auipc	a0,0x1
 346:	9ce50513          	addi	a0,a0,-1586 # d10 <malloc+0x180>
 34a:	00000097          	auipc	ra,0x0
 34e:	788080e7          	jalr	1928(ra) # ad2 <printf>
        exit(1);
 352:	4505                	li	a0,1
 354:	00000097          	auipc	ra,0x0
 358:	3f6080e7          	jalr	1014(ra) # 74a <exit>
    printf("test0: FAIL\n");
 35c:	00001517          	auipc	a0,0x1
 360:	9fc50513          	addi	a0,a0,-1540 # d58 <malloc+0x1c8>
 364:	00000097          	auipc	ra,0x0
 368:	76e080e7          	jalr	1902(ra) # ad2 <printf>
}
 36c:	b7b1                	j	2b8 <test0+0x116>

000000000000036e <test1>:

void test1()
{
 36e:	7179                	addi	sp,sp,-48
 370:	f406                	sd	ra,40(sp)
 372:	f022                	sd	s0,32(sp)
 374:	ec26                	sd	s1,24(sp)
 376:	e84a                	sd	s2,16(sp)
 378:	1800                	addi	s0,sp,48
  char file[3];
  enum { N = 100, BIG=100, NCHILD=2 };
  
  printf("start test1\n");
 37a:	00001517          	auipc	a0,0x1
 37e:	9ee50513          	addi	a0,a0,-1554 # d68 <malloc+0x1d8>
 382:	00000097          	auipc	ra,0x0
 386:	750080e7          	jalr	1872(ra) # ad2 <printf>
  file[0] = 'B';
 38a:	04200793          	li	a5,66
 38e:	fcf40c23          	sb	a5,-40(s0)
  file[2] = '\0';
 392:	fc040d23          	sb	zero,-38(s0)
 396:	4485                	li	s1,1
  for(int i = 0; i < NCHILD; i++){
    file[1] = '0' + i;
    unlink(file);
    if (i == 0) {
 398:	4905                	li	s2,1
 39a:	a811                	j	3ae <test1+0x40>
      createfile(file, BIG);
 39c:	06400593          	li	a1,100
 3a0:	fd840513          	addi	a0,s0,-40
 3a4:	00000097          	auipc	ra,0x0
 3a8:	c5c080e7          	jalr	-932(ra) # 0 <createfile>
  for(int i = 0; i < NCHILD; i++){
 3ac:	2485                	addiw	s1,s1,1
    file[1] = '0' + i;
 3ae:	02f4879b          	addiw	a5,s1,47
 3b2:	fcf40ca3          	sb	a5,-39(s0)
    unlink(file);
 3b6:	fd840513          	addi	a0,s0,-40
 3ba:	00000097          	auipc	ra,0x0
 3be:	3e0080e7          	jalr	992(ra) # 79a <unlink>
    if (i == 0) {
 3c2:	fd248de3          	beq	s1,s2,39c <test1+0x2e>
    } else {
      createfile(file, 1);
 3c6:	85ca                	mv	a1,s2
 3c8:	fd840513          	addi	a0,s0,-40
 3cc:	00000097          	auipc	ra,0x0
 3d0:	c34080e7          	jalr	-972(ra) # 0 <createfile>
  for(int i = 0; i < NCHILD; i++){
 3d4:	0004879b          	sext.w	a5,s1
 3d8:	fcf95ae3          	bge	s2,a5,3ac <test1+0x3e>
    }
  }
  for(int i = 0; i < NCHILD; i++){
    file[1] = '0' + i;
 3dc:	03000793          	li	a5,48
 3e0:	fcf40ca3          	sb	a5,-39(s0)
    int pid = fork();
 3e4:	00000097          	auipc	ra,0x0
 3e8:	35e080e7          	jalr	862(ra) # 742 <fork>
    if(pid < 0){
 3ec:	04054663          	bltz	a0,438 <test1+0xca>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 3f0:	c12d                	beqz	a0,452 <test1+0xe4>
    file[1] = '0' + i;
 3f2:	03100793          	li	a5,49
 3f6:	fcf40ca3          	sb	a5,-39(s0)
    int pid = fork();
 3fa:	00000097          	auipc	ra,0x0
 3fe:	348080e7          	jalr	840(ra) # 742 <fork>
    if(pid < 0){
 402:	02054b63          	bltz	a0,438 <test1+0xca>
    if(pid == 0){
 406:	cd35                	beqz	a0,482 <test1+0x114>
      exit(0);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
 408:	4501                	li	a0,0
 40a:	00000097          	auipc	ra,0x0
 40e:	348080e7          	jalr	840(ra) # 752 <wait>
 412:	4501                	li	a0,0
 414:	00000097          	auipc	ra,0x0
 418:	33e080e7          	jalr	830(ra) # 752 <wait>
  }
  printf("test1 OK\n");
 41c:	00001517          	auipc	a0,0x1
 420:	95c50513          	addi	a0,a0,-1700 # d78 <malloc+0x1e8>
 424:	00000097          	auipc	ra,0x0
 428:	6ae080e7          	jalr	1710(ra) # ad2 <printf>
}
 42c:	70a2                	ld	ra,40(sp)
 42e:	7402                	ld	s0,32(sp)
 430:	64e2                	ld	s1,24(sp)
 432:	6942                	ld	s2,16(sp)
 434:	6145                	addi	sp,sp,48
 436:	8082                	ret
      printf("fork failed");
 438:	00001517          	auipc	a0,0x1
 43c:	8f050513          	addi	a0,a0,-1808 # d28 <malloc+0x198>
 440:	00000097          	auipc	ra,0x0
 444:	692080e7          	jalr	1682(ra) # ad2 <printf>
      exit(-1);
 448:	557d                	li	a0,-1
 44a:	00000097          	auipc	ra,0x0
 44e:	300080e7          	jalr	768(ra) # 74a <exit>
    if(pid == 0){
 452:	06400493          	li	s1,100
          readfile(file, BIG*BSIZE, BSIZE);
 456:	40000613          	li	a2,1024
 45a:	65e5                	lui	a1,0x19
 45c:	fd840513          	addi	a0,s0,-40
 460:	00000097          	auipc	ra,0x0
 464:	c5c080e7          	jalr	-932(ra) # bc <readfile>
        for (i = 0; i < N; i++) {
 468:	34fd                	addiw	s1,s1,-1
 46a:	f4f5                	bnez	s1,456 <test1+0xe8>
        unlink(file);
 46c:	fd840513          	addi	a0,s0,-40
 470:	00000097          	auipc	ra,0x0
 474:	32a080e7          	jalr	810(ra) # 79a <unlink>
        exit(0);
 478:	4501                	li	a0,0
 47a:	00000097          	auipc	ra,0x0
 47e:	2d0080e7          	jalr	720(ra) # 74a <exit>
 482:	06400493          	li	s1,100
          readfile(file, 1, BSIZE);
 486:	40000613          	li	a2,1024
 48a:	4585                	li	a1,1
 48c:	fd840513          	addi	a0,s0,-40
 490:	00000097          	auipc	ra,0x0
 494:	c2c080e7          	jalr	-980(ra) # bc <readfile>
        for (i = 0; i < N; i++) {
 498:	34fd                	addiw	s1,s1,-1
 49a:	f4f5                	bnez	s1,486 <test1+0x118>
        unlink(file);
 49c:	fd840513          	addi	a0,s0,-40
 4a0:	00000097          	auipc	ra,0x0
 4a4:	2fa080e7          	jalr	762(ra) # 79a <unlink>
      exit(0);
 4a8:	4501                	li	a0,0
 4aa:	00000097          	auipc	ra,0x0
 4ae:	2a0080e7          	jalr	672(ra) # 74a <exit>

00000000000004b2 <main>:
{
 4b2:	1141                	addi	sp,sp,-16
 4b4:	e406                	sd	ra,8(sp)
 4b6:	e022                	sd	s0,0(sp)
 4b8:	0800                	addi	s0,sp,16
  test0();
 4ba:	00000097          	auipc	ra,0x0
 4be:	ce8080e7          	jalr	-792(ra) # 1a2 <test0>
  test1();
 4c2:	00000097          	auipc	ra,0x0
 4c6:	eac080e7          	jalr	-340(ra) # 36e <test1>
  exit(0);
 4ca:	4501                	li	a0,0
 4cc:	00000097          	auipc	ra,0x0
 4d0:	27e080e7          	jalr	638(ra) # 74a <exit>

00000000000004d4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 4d4:	1141                	addi	sp,sp,-16
 4d6:	e422                	sd	s0,8(sp)
 4d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4da:	87aa                	mv	a5,a0
 4dc:	0585                	addi	a1,a1,1
 4de:	0785                	addi	a5,a5,1
 4e0:	fff5c703          	lbu	a4,-1(a1) # 18fff <__global_pointer$+0x17a5e>
 4e4:	fee78fa3          	sb	a4,-1(a5)
 4e8:	fb75                	bnez	a4,4dc <strcpy+0x8>
    ;
  return os;
}
 4ea:	6422                	ld	s0,8(sp)
 4ec:	0141                	addi	sp,sp,16
 4ee:	8082                	ret

00000000000004f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4f0:	1141                	addi	sp,sp,-16
 4f2:	e422                	sd	s0,8(sp)
 4f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4f6:	00054783          	lbu	a5,0(a0)
 4fa:	cb91                	beqz	a5,50e <strcmp+0x1e>
 4fc:	0005c703          	lbu	a4,0(a1)
 500:	00f71763          	bne	a4,a5,50e <strcmp+0x1e>
    p++, q++;
 504:	0505                	addi	a0,a0,1
 506:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 508:	00054783          	lbu	a5,0(a0)
 50c:	fbe5                	bnez	a5,4fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 50e:	0005c503          	lbu	a0,0(a1)
}
 512:	40a7853b          	subw	a0,a5,a0
 516:	6422                	ld	s0,8(sp)
 518:	0141                	addi	sp,sp,16
 51a:	8082                	ret

000000000000051c <strlen>:

uint
strlen(const char *s)
{
 51c:	1141                	addi	sp,sp,-16
 51e:	e422                	sd	s0,8(sp)
 520:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 522:	00054783          	lbu	a5,0(a0)
 526:	cf91                	beqz	a5,542 <strlen+0x26>
 528:	0505                	addi	a0,a0,1
 52a:	87aa                	mv	a5,a0
 52c:	4685                	li	a3,1
 52e:	9e89                	subw	a3,a3,a0
 530:	00f6853b          	addw	a0,a3,a5
 534:	0785                	addi	a5,a5,1
 536:	fff7c703          	lbu	a4,-1(a5)
 53a:	fb7d                	bnez	a4,530 <strlen+0x14>
    ;
  return n;
}
 53c:	6422                	ld	s0,8(sp)
 53e:	0141                	addi	sp,sp,16
 540:	8082                	ret
  for(n = 0; s[n]; n++)
 542:	4501                	li	a0,0
 544:	bfe5                	j	53c <strlen+0x20>

0000000000000546 <memset>:

void*
memset(void *dst, int c, uint n)
{
 546:	1141                	addi	sp,sp,-16
 548:	e422                	sd	s0,8(sp)
 54a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 54c:	ce09                	beqz	a2,566 <memset+0x20>
 54e:	87aa                	mv	a5,a0
 550:	fff6071b          	addiw	a4,a2,-1
 554:	1702                	slli	a4,a4,0x20
 556:	9301                	srli	a4,a4,0x20
 558:	0705                	addi	a4,a4,1
 55a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 55c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 560:	0785                	addi	a5,a5,1
 562:	fee79de3          	bne	a5,a4,55c <memset+0x16>
  }
  return dst;
}
 566:	6422                	ld	s0,8(sp)
 568:	0141                	addi	sp,sp,16
 56a:	8082                	ret

000000000000056c <strchr>:

char*
strchr(const char *s, char c)
{
 56c:	1141                	addi	sp,sp,-16
 56e:	e422                	sd	s0,8(sp)
 570:	0800                	addi	s0,sp,16
  for(; *s; s++)
 572:	00054783          	lbu	a5,0(a0)
 576:	cb99                	beqz	a5,58c <strchr+0x20>
    if(*s == c)
 578:	00f58763          	beq	a1,a5,586 <strchr+0x1a>
  for(; *s; s++)
 57c:	0505                	addi	a0,a0,1
 57e:	00054783          	lbu	a5,0(a0)
 582:	fbfd                	bnez	a5,578 <strchr+0xc>
      return (char*)s;
  return 0;
 584:	4501                	li	a0,0
}
 586:	6422                	ld	s0,8(sp)
 588:	0141                	addi	sp,sp,16
 58a:	8082                	ret
  return 0;
 58c:	4501                	li	a0,0
 58e:	bfe5                	j	586 <strchr+0x1a>

0000000000000590 <gets>:

char*
gets(char *buf, int max)
{
 590:	711d                	addi	sp,sp,-96
 592:	ec86                	sd	ra,88(sp)
 594:	e8a2                	sd	s0,80(sp)
 596:	e4a6                	sd	s1,72(sp)
 598:	e0ca                	sd	s2,64(sp)
 59a:	fc4e                	sd	s3,56(sp)
 59c:	f852                	sd	s4,48(sp)
 59e:	f456                	sd	s5,40(sp)
 5a0:	f05a                	sd	s6,32(sp)
 5a2:	ec5e                	sd	s7,24(sp)
 5a4:	1080                	addi	s0,sp,96
 5a6:	8baa                	mv	s7,a0
 5a8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5aa:	892a                	mv	s2,a0
 5ac:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 5ae:	4aa9                	li	s5,10
 5b0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 5b2:	89a6                	mv	s3,s1
 5b4:	2485                	addiw	s1,s1,1
 5b6:	0344d863          	bge	s1,s4,5e6 <gets+0x56>
    cc = read(0, &c, 1);
 5ba:	4605                	li	a2,1
 5bc:	faf40593          	addi	a1,s0,-81
 5c0:	4501                	li	a0,0
 5c2:	00000097          	auipc	ra,0x0
 5c6:	1a0080e7          	jalr	416(ra) # 762 <read>
    if(cc < 1)
 5ca:	00a05e63          	blez	a0,5e6 <gets+0x56>
    buf[i++] = c;
 5ce:	faf44783          	lbu	a5,-81(s0)
 5d2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5d6:	01578763          	beq	a5,s5,5e4 <gets+0x54>
 5da:	0905                	addi	s2,s2,1
 5dc:	fd679be3          	bne	a5,s6,5b2 <gets+0x22>
  for(i=0; i+1 < max; ){
 5e0:	89a6                	mv	s3,s1
 5e2:	a011                	j	5e6 <gets+0x56>
 5e4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 5e6:	99de                	add	s3,s3,s7
 5e8:	00098023          	sb	zero,0(s3)
  return buf;
}
 5ec:	855e                	mv	a0,s7
 5ee:	60e6                	ld	ra,88(sp)
 5f0:	6446                	ld	s0,80(sp)
 5f2:	64a6                	ld	s1,72(sp)
 5f4:	6906                	ld	s2,64(sp)
 5f6:	79e2                	ld	s3,56(sp)
 5f8:	7a42                	ld	s4,48(sp)
 5fa:	7aa2                	ld	s5,40(sp)
 5fc:	7b02                	ld	s6,32(sp)
 5fe:	6be2                	ld	s7,24(sp)
 600:	6125                	addi	sp,sp,96
 602:	8082                	ret

0000000000000604 <stat>:

int
stat(const char *n, struct stat *st)
{
 604:	1101                	addi	sp,sp,-32
 606:	ec06                	sd	ra,24(sp)
 608:	e822                	sd	s0,16(sp)
 60a:	e426                	sd	s1,8(sp)
 60c:	e04a                	sd	s2,0(sp)
 60e:	1000                	addi	s0,sp,32
 610:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 612:	4581                	li	a1,0
 614:	00000097          	auipc	ra,0x0
 618:	176080e7          	jalr	374(ra) # 78a <open>
  if(fd < 0)
 61c:	02054563          	bltz	a0,646 <stat+0x42>
 620:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 622:	85ca                	mv	a1,s2
 624:	00000097          	auipc	ra,0x0
 628:	17e080e7          	jalr	382(ra) # 7a2 <fstat>
 62c:	892a                	mv	s2,a0
  close(fd);
 62e:	8526                	mv	a0,s1
 630:	00000097          	auipc	ra,0x0
 634:	142080e7          	jalr	322(ra) # 772 <close>
  return r;
}
 638:	854a                	mv	a0,s2
 63a:	60e2                	ld	ra,24(sp)
 63c:	6442                	ld	s0,16(sp)
 63e:	64a2                	ld	s1,8(sp)
 640:	6902                	ld	s2,0(sp)
 642:	6105                	addi	sp,sp,32
 644:	8082                	ret
    return -1;
 646:	597d                	li	s2,-1
 648:	bfc5                	j	638 <stat+0x34>

000000000000064a <atoi>:

int
atoi(const char *s)
{
 64a:	1141                	addi	sp,sp,-16
 64c:	e422                	sd	s0,8(sp)
 64e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 650:	00054603          	lbu	a2,0(a0)
 654:	fd06079b          	addiw	a5,a2,-48
 658:	0ff7f793          	andi	a5,a5,255
 65c:	4725                	li	a4,9
 65e:	02f76963          	bltu	a4,a5,690 <atoi+0x46>
 662:	86aa                	mv	a3,a0
  n = 0;
 664:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 666:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 668:	0685                	addi	a3,a3,1
 66a:	0025179b          	slliw	a5,a0,0x2
 66e:	9fa9                	addw	a5,a5,a0
 670:	0017979b          	slliw	a5,a5,0x1
 674:	9fb1                	addw	a5,a5,a2
 676:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 67a:	0006c603          	lbu	a2,0(a3)
 67e:	fd06071b          	addiw	a4,a2,-48
 682:	0ff77713          	andi	a4,a4,255
 686:	fee5f1e3          	bgeu	a1,a4,668 <atoi+0x1e>
  return n;
}
 68a:	6422                	ld	s0,8(sp)
 68c:	0141                	addi	sp,sp,16
 68e:	8082                	ret
  n = 0;
 690:	4501                	li	a0,0
 692:	bfe5                	j	68a <atoi+0x40>

0000000000000694 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 694:	1141                	addi	sp,sp,-16
 696:	e422                	sd	s0,8(sp)
 698:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 69a:	02b57663          	bgeu	a0,a1,6c6 <memmove+0x32>
    while(n-- > 0)
 69e:	02c05163          	blez	a2,6c0 <memmove+0x2c>
 6a2:	fff6079b          	addiw	a5,a2,-1
 6a6:	1782                	slli	a5,a5,0x20
 6a8:	9381                	srli	a5,a5,0x20
 6aa:	0785                	addi	a5,a5,1
 6ac:	97aa                	add	a5,a5,a0
  dst = vdst;
 6ae:	872a                	mv	a4,a0
      *dst++ = *src++;
 6b0:	0585                	addi	a1,a1,1
 6b2:	0705                	addi	a4,a4,1
 6b4:	fff5c683          	lbu	a3,-1(a1)
 6b8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 6bc:	fee79ae3          	bne	a5,a4,6b0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 6c0:	6422                	ld	s0,8(sp)
 6c2:	0141                	addi	sp,sp,16
 6c4:	8082                	ret
    dst += n;
 6c6:	00c50733          	add	a4,a0,a2
    src += n;
 6ca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 6cc:	fec05ae3          	blez	a2,6c0 <memmove+0x2c>
 6d0:	fff6079b          	addiw	a5,a2,-1
 6d4:	1782                	slli	a5,a5,0x20
 6d6:	9381                	srli	a5,a5,0x20
 6d8:	fff7c793          	not	a5,a5
 6dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6de:	15fd                	addi	a1,a1,-1
 6e0:	177d                	addi	a4,a4,-1
 6e2:	0005c683          	lbu	a3,0(a1)
 6e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6ea:	fee79ae3          	bne	a5,a4,6de <memmove+0x4a>
 6ee:	bfc9                	j	6c0 <memmove+0x2c>

00000000000006f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 6f0:	1141                	addi	sp,sp,-16
 6f2:	e422                	sd	s0,8(sp)
 6f4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 6f6:	ca05                	beqz	a2,726 <memcmp+0x36>
 6f8:	fff6069b          	addiw	a3,a2,-1
 6fc:	1682                	slli	a3,a3,0x20
 6fe:	9281                	srli	a3,a3,0x20
 700:	0685                	addi	a3,a3,1
 702:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 704:	00054783          	lbu	a5,0(a0)
 708:	0005c703          	lbu	a4,0(a1)
 70c:	00e79863          	bne	a5,a4,71c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 710:	0505                	addi	a0,a0,1
    p2++;
 712:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 714:	fed518e3          	bne	a0,a3,704 <memcmp+0x14>
  }
  return 0;
 718:	4501                	li	a0,0
 71a:	a019                	j	720 <memcmp+0x30>
      return *p1 - *p2;
 71c:	40e7853b          	subw	a0,a5,a4
}
 720:	6422                	ld	s0,8(sp)
 722:	0141                	addi	sp,sp,16
 724:	8082                	ret
  return 0;
 726:	4501                	li	a0,0
 728:	bfe5                	j	720 <memcmp+0x30>

000000000000072a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 72a:	1141                	addi	sp,sp,-16
 72c:	e406                	sd	ra,8(sp)
 72e:	e022                	sd	s0,0(sp)
 730:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 732:	00000097          	auipc	ra,0x0
 736:	f62080e7          	jalr	-158(ra) # 694 <memmove>
}
 73a:	60a2                	ld	ra,8(sp)
 73c:	6402                	ld	s0,0(sp)
 73e:	0141                	addi	sp,sp,16
 740:	8082                	ret

0000000000000742 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 742:	4885                	li	a7,1
 ecall
 744:	00000073          	ecall
 ret
 748:	8082                	ret

000000000000074a <exit>:
.global exit
exit:
 li a7, SYS_exit
 74a:	4889                	li	a7,2
 ecall
 74c:	00000073          	ecall
 ret
 750:	8082                	ret

0000000000000752 <wait>:
.global wait
wait:
 li a7, SYS_wait
 752:	488d                	li	a7,3
 ecall
 754:	00000073          	ecall
 ret
 758:	8082                	ret

000000000000075a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 75a:	4891                	li	a7,4
 ecall
 75c:	00000073          	ecall
 ret
 760:	8082                	ret

0000000000000762 <read>:
.global read
read:
 li a7, SYS_read
 762:	4895                	li	a7,5
 ecall
 764:	00000073          	ecall
 ret
 768:	8082                	ret

000000000000076a <write>:
.global write
write:
 li a7, SYS_write
 76a:	48c1                	li	a7,16
 ecall
 76c:	00000073          	ecall
 ret
 770:	8082                	ret

0000000000000772 <close>:
.global close
close:
 li a7, SYS_close
 772:	48d5                	li	a7,21
 ecall
 774:	00000073          	ecall
 ret
 778:	8082                	ret

000000000000077a <kill>:
.global kill
kill:
 li a7, SYS_kill
 77a:	4899                	li	a7,6
 ecall
 77c:	00000073          	ecall
 ret
 780:	8082                	ret

0000000000000782 <exec>:
.global exec
exec:
 li a7, SYS_exec
 782:	489d                	li	a7,7
 ecall
 784:	00000073          	ecall
 ret
 788:	8082                	ret

000000000000078a <open>:
.global open
open:
 li a7, SYS_open
 78a:	48bd                	li	a7,15
 ecall
 78c:	00000073          	ecall
 ret
 790:	8082                	ret

0000000000000792 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 792:	48c5                	li	a7,17
 ecall
 794:	00000073          	ecall
 ret
 798:	8082                	ret

000000000000079a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 79a:	48c9                	li	a7,18
 ecall
 79c:	00000073          	ecall
 ret
 7a0:	8082                	ret

00000000000007a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 7a2:	48a1                	li	a7,8
 ecall
 7a4:	00000073          	ecall
 ret
 7a8:	8082                	ret

00000000000007aa <link>:
.global link
link:
 li a7, SYS_link
 7aa:	48cd                	li	a7,19
 ecall
 7ac:	00000073          	ecall
 ret
 7b0:	8082                	ret

00000000000007b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 7b2:	48d1                	li	a7,20
 ecall
 7b4:	00000073          	ecall
 ret
 7b8:	8082                	ret

00000000000007ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7ba:	48a5                	li	a7,9
 ecall
 7bc:	00000073          	ecall
 ret
 7c0:	8082                	ret

00000000000007c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 7c2:	48a9                	li	a7,10
 ecall
 7c4:	00000073          	ecall
 ret
 7c8:	8082                	ret

00000000000007ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7ca:	48ad                	li	a7,11
 ecall
 7cc:	00000073          	ecall
 ret
 7d0:	8082                	ret

00000000000007d2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7d2:	48b1                	li	a7,12
 ecall
 7d4:	00000073          	ecall
 ret
 7d8:	8082                	ret

00000000000007da <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7da:	48b5                	li	a7,13
 ecall
 7dc:	00000073          	ecall
 ret
 7e0:	8082                	ret

00000000000007e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7e2:	48b9                	li	a7,14
 ecall
 7e4:	00000073          	ecall
 ret
 7e8:	8082                	ret

00000000000007ea <connect>:
.global connect
connect:
 li a7, SYS_connect
 7ea:	48d9                	li	a7,22
 ecall
 7ec:	00000073          	ecall
 ret
 7f0:	8082                	ret

00000000000007f2 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 7f2:	48dd                	li	a7,23
 ecall
 7f4:	00000073          	ecall
 ret
 7f8:	8082                	ret

00000000000007fa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7fa:	1101                	addi	sp,sp,-32
 7fc:	ec06                	sd	ra,24(sp)
 7fe:	e822                	sd	s0,16(sp)
 800:	1000                	addi	s0,sp,32
 802:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 806:	4605                	li	a2,1
 808:	fef40593          	addi	a1,s0,-17
 80c:	00000097          	auipc	ra,0x0
 810:	f5e080e7          	jalr	-162(ra) # 76a <write>
}
 814:	60e2                	ld	ra,24(sp)
 816:	6442                	ld	s0,16(sp)
 818:	6105                	addi	sp,sp,32
 81a:	8082                	ret

000000000000081c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 81c:	7139                	addi	sp,sp,-64
 81e:	fc06                	sd	ra,56(sp)
 820:	f822                	sd	s0,48(sp)
 822:	f426                	sd	s1,40(sp)
 824:	f04a                	sd	s2,32(sp)
 826:	ec4e                	sd	s3,24(sp)
 828:	0080                	addi	s0,sp,64
 82a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 82c:	c299                	beqz	a3,832 <printint+0x16>
 82e:	0805c863          	bltz	a1,8be <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 832:	2581                	sext.w	a1,a1
  neg = 0;
 834:	4881                	li	a7,0
 836:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 83a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 83c:	2601                	sext.w	a2,a2
 83e:	00000517          	auipc	a0,0x0
 842:	55250513          	addi	a0,a0,1362 # d90 <digits>
 846:	883a                	mv	a6,a4
 848:	2705                	addiw	a4,a4,1
 84a:	02c5f7bb          	remuw	a5,a1,a2
 84e:	1782                	slli	a5,a5,0x20
 850:	9381                	srli	a5,a5,0x20
 852:	97aa                	add	a5,a5,a0
 854:	0007c783          	lbu	a5,0(a5)
 858:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 85c:	0005879b          	sext.w	a5,a1
 860:	02c5d5bb          	divuw	a1,a1,a2
 864:	0685                	addi	a3,a3,1
 866:	fec7f0e3          	bgeu	a5,a2,846 <printint+0x2a>
  if(neg)
 86a:	00088b63          	beqz	a7,880 <printint+0x64>
    buf[i++] = '-';
 86e:	fd040793          	addi	a5,s0,-48
 872:	973e                	add	a4,a4,a5
 874:	02d00793          	li	a5,45
 878:	fef70823          	sb	a5,-16(a4)
 87c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 880:	02e05863          	blez	a4,8b0 <printint+0x94>
 884:	fc040793          	addi	a5,s0,-64
 888:	00e78933          	add	s2,a5,a4
 88c:	fff78993          	addi	s3,a5,-1
 890:	99ba                	add	s3,s3,a4
 892:	377d                	addiw	a4,a4,-1
 894:	1702                	slli	a4,a4,0x20
 896:	9301                	srli	a4,a4,0x20
 898:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 89c:	fff94583          	lbu	a1,-1(s2)
 8a0:	8526                	mv	a0,s1
 8a2:	00000097          	auipc	ra,0x0
 8a6:	f58080e7          	jalr	-168(ra) # 7fa <putc>
  while(--i >= 0)
 8aa:	197d                	addi	s2,s2,-1
 8ac:	ff3918e3          	bne	s2,s3,89c <printint+0x80>
}
 8b0:	70e2                	ld	ra,56(sp)
 8b2:	7442                	ld	s0,48(sp)
 8b4:	74a2                	ld	s1,40(sp)
 8b6:	7902                	ld	s2,32(sp)
 8b8:	69e2                	ld	s3,24(sp)
 8ba:	6121                	addi	sp,sp,64
 8bc:	8082                	ret
    x = -xx;
 8be:	40b005bb          	negw	a1,a1
    neg = 1;
 8c2:	4885                	li	a7,1
    x = -xx;
 8c4:	bf8d                	j	836 <printint+0x1a>

00000000000008c6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8c6:	7119                	addi	sp,sp,-128
 8c8:	fc86                	sd	ra,120(sp)
 8ca:	f8a2                	sd	s0,112(sp)
 8cc:	f4a6                	sd	s1,104(sp)
 8ce:	f0ca                	sd	s2,96(sp)
 8d0:	ecce                	sd	s3,88(sp)
 8d2:	e8d2                	sd	s4,80(sp)
 8d4:	e4d6                	sd	s5,72(sp)
 8d6:	e0da                	sd	s6,64(sp)
 8d8:	fc5e                	sd	s7,56(sp)
 8da:	f862                	sd	s8,48(sp)
 8dc:	f466                	sd	s9,40(sp)
 8de:	f06a                	sd	s10,32(sp)
 8e0:	ec6e                	sd	s11,24(sp)
 8e2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8e4:	0005c903          	lbu	s2,0(a1)
 8e8:	18090f63          	beqz	s2,a86 <vprintf+0x1c0>
 8ec:	8aaa                	mv	s5,a0
 8ee:	8b32                	mv	s6,a2
 8f0:	00158493          	addi	s1,a1,1
  state = 0;
 8f4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8f6:	02500a13          	li	s4,37
      if(c == 'd'){
 8fa:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 8fe:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 902:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 906:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 90a:	00000b97          	auipc	s7,0x0
 90e:	486b8b93          	addi	s7,s7,1158 # d90 <digits>
 912:	a839                	j	930 <vprintf+0x6a>
        putc(fd, c);
 914:	85ca                	mv	a1,s2
 916:	8556                	mv	a0,s5
 918:	00000097          	auipc	ra,0x0
 91c:	ee2080e7          	jalr	-286(ra) # 7fa <putc>
 920:	a019                	j	926 <vprintf+0x60>
    } else if(state == '%'){
 922:	01498f63          	beq	s3,s4,940 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 926:	0485                	addi	s1,s1,1
 928:	fff4c903          	lbu	s2,-1(s1)
 92c:	14090d63          	beqz	s2,a86 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 930:	0009079b          	sext.w	a5,s2
    if(state == 0){
 934:	fe0997e3          	bnez	s3,922 <vprintf+0x5c>
      if(c == '%'){
 938:	fd479ee3          	bne	a5,s4,914 <vprintf+0x4e>
        state = '%';
 93c:	89be                	mv	s3,a5
 93e:	b7e5                	j	926 <vprintf+0x60>
      if(c == 'd'){
 940:	05878063          	beq	a5,s8,980 <vprintf+0xba>
      } else if(c == 'l') {
 944:	05978c63          	beq	a5,s9,99c <vprintf+0xd6>
      } else if(c == 'x') {
 948:	07a78863          	beq	a5,s10,9b8 <vprintf+0xf2>
      } else if(c == 'p') {
 94c:	09b78463          	beq	a5,s11,9d4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 950:	07300713          	li	a4,115
 954:	0ce78663          	beq	a5,a4,a20 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 958:	06300713          	li	a4,99
 95c:	0ee78e63          	beq	a5,a4,a58 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 960:	11478863          	beq	a5,s4,a70 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 964:	85d2                	mv	a1,s4
 966:	8556                	mv	a0,s5
 968:	00000097          	auipc	ra,0x0
 96c:	e92080e7          	jalr	-366(ra) # 7fa <putc>
        putc(fd, c);
 970:	85ca                	mv	a1,s2
 972:	8556                	mv	a0,s5
 974:	00000097          	auipc	ra,0x0
 978:	e86080e7          	jalr	-378(ra) # 7fa <putc>
      }
      state = 0;
 97c:	4981                	li	s3,0
 97e:	b765                	j	926 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 980:	008b0913          	addi	s2,s6,8
 984:	4685                	li	a3,1
 986:	4629                	li	a2,10
 988:	000b2583          	lw	a1,0(s6)
 98c:	8556                	mv	a0,s5
 98e:	00000097          	auipc	ra,0x0
 992:	e8e080e7          	jalr	-370(ra) # 81c <printint>
 996:	8b4a                	mv	s6,s2
      state = 0;
 998:	4981                	li	s3,0
 99a:	b771                	j	926 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 99c:	008b0913          	addi	s2,s6,8
 9a0:	4681                	li	a3,0
 9a2:	4629                	li	a2,10
 9a4:	000b2583          	lw	a1,0(s6)
 9a8:	8556                	mv	a0,s5
 9aa:	00000097          	auipc	ra,0x0
 9ae:	e72080e7          	jalr	-398(ra) # 81c <printint>
 9b2:	8b4a                	mv	s6,s2
      state = 0;
 9b4:	4981                	li	s3,0
 9b6:	bf85                	j	926 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9b8:	008b0913          	addi	s2,s6,8
 9bc:	4681                	li	a3,0
 9be:	4641                	li	a2,16
 9c0:	000b2583          	lw	a1,0(s6)
 9c4:	8556                	mv	a0,s5
 9c6:	00000097          	auipc	ra,0x0
 9ca:	e56080e7          	jalr	-426(ra) # 81c <printint>
 9ce:	8b4a                	mv	s6,s2
      state = 0;
 9d0:	4981                	li	s3,0
 9d2:	bf91                	j	926 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 9d4:	008b0793          	addi	a5,s6,8
 9d8:	f8f43423          	sd	a5,-120(s0)
 9dc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 9e0:	03000593          	li	a1,48
 9e4:	8556                	mv	a0,s5
 9e6:	00000097          	auipc	ra,0x0
 9ea:	e14080e7          	jalr	-492(ra) # 7fa <putc>
  putc(fd, 'x');
 9ee:	85ea                	mv	a1,s10
 9f0:	8556                	mv	a0,s5
 9f2:	00000097          	auipc	ra,0x0
 9f6:	e08080e7          	jalr	-504(ra) # 7fa <putc>
 9fa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9fc:	03c9d793          	srli	a5,s3,0x3c
 a00:	97de                	add	a5,a5,s7
 a02:	0007c583          	lbu	a1,0(a5)
 a06:	8556                	mv	a0,s5
 a08:	00000097          	auipc	ra,0x0
 a0c:	df2080e7          	jalr	-526(ra) # 7fa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a10:	0992                	slli	s3,s3,0x4
 a12:	397d                	addiw	s2,s2,-1
 a14:	fe0914e3          	bnez	s2,9fc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 a18:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a1c:	4981                	li	s3,0
 a1e:	b721                	j	926 <vprintf+0x60>
        s = va_arg(ap, char*);
 a20:	008b0993          	addi	s3,s6,8
 a24:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 a28:	02090163          	beqz	s2,a4a <vprintf+0x184>
        while(*s != 0){
 a2c:	00094583          	lbu	a1,0(s2)
 a30:	c9a1                	beqz	a1,a80 <vprintf+0x1ba>
          putc(fd, *s);
 a32:	8556                	mv	a0,s5
 a34:	00000097          	auipc	ra,0x0
 a38:	dc6080e7          	jalr	-570(ra) # 7fa <putc>
          s++;
 a3c:	0905                	addi	s2,s2,1
        while(*s != 0){
 a3e:	00094583          	lbu	a1,0(s2)
 a42:	f9e5                	bnez	a1,a32 <vprintf+0x16c>
        s = va_arg(ap, char*);
 a44:	8b4e                	mv	s6,s3
      state = 0;
 a46:	4981                	li	s3,0
 a48:	bdf9                	j	926 <vprintf+0x60>
          s = "(null)";
 a4a:	00000917          	auipc	s2,0x0
 a4e:	33e90913          	addi	s2,s2,830 # d88 <malloc+0x1f8>
        while(*s != 0){
 a52:	02800593          	li	a1,40
 a56:	bff1                	j	a32 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a58:	008b0913          	addi	s2,s6,8
 a5c:	000b4583          	lbu	a1,0(s6)
 a60:	8556                	mv	a0,s5
 a62:	00000097          	auipc	ra,0x0
 a66:	d98080e7          	jalr	-616(ra) # 7fa <putc>
 a6a:	8b4a                	mv	s6,s2
      state = 0;
 a6c:	4981                	li	s3,0
 a6e:	bd65                	j	926 <vprintf+0x60>
        putc(fd, c);
 a70:	85d2                	mv	a1,s4
 a72:	8556                	mv	a0,s5
 a74:	00000097          	auipc	ra,0x0
 a78:	d86080e7          	jalr	-634(ra) # 7fa <putc>
      state = 0;
 a7c:	4981                	li	s3,0
 a7e:	b565                	j	926 <vprintf+0x60>
        s = va_arg(ap, char*);
 a80:	8b4e                	mv	s6,s3
      state = 0;
 a82:	4981                	li	s3,0
 a84:	b54d                	j	926 <vprintf+0x60>
    }
  }
}
 a86:	70e6                	ld	ra,120(sp)
 a88:	7446                	ld	s0,112(sp)
 a8a:	74a6                	ld	s1,104(sp)
 a8c:	7906                	ld	s2,96(sp)
 a8e:	69e6                	ld	s3,88(sp)
 a90:	6a46                	ld	s4,80(sp)
 a92:	6aa6                	ld	s5,72(sp)
 a94:	6b06                	ld	s6,64(sp)
 a96:	7be2                	ld	s7,56(sp)
 a98:	7c42                	ld	s8,48(sp)
 a9a:	7ca2                	ld	s9,40(sp)
 a9c:	7d02                	ld	s10,32(sp)
 a9e:	6de2                	ld	s11,24(sp)
 aa0:	6109                	addi	sp,sp,128
 aa2:	8082                	ret

0000000000000aa4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 aa4:	715d                	addi	sp,sp,-80
 aa6:	ec06                	sd	ra,24(sp)
 aa8:	e822                	sd	s0,16(sp)
 aaa:	1000                	addi	s0,sp,32
 aac:	e010                	sd	a2,0(s0)
 aae:	e414                	sd	a3,8(s0)
 ab0:	e818                	sd	a4,16(s0)
 ab2:	ec1c                	sd	a5,24(s0)
 ab4:	03043023          	sd	a6,32(s0)
 ab8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 abc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ac0:	8622                	mv	a2,s0
 ac2:	00000097          	auipc	ra,0x0
 ac6:	e04080e7          	jalr	-508(ra) # 8c6 <vprintf>
}
 aca:	60e2                	ld	ra,24(sp)
 acc:	6442                	ld	s0,16(sp)
 ace:	6161                	addi	sp,sp,80
 ad0:	8082                	ret

0000000000000ad2 <printf>:

void
printf(const char *fmt, ...)
{
 ad2:	711d                	addi	sp,sp,-96
 ad4:	ec06                	sd	ra,24(sp)
 ad6:	e822                	sd	s0,16(sp)
 ad8:	1000                	addi	s0,sp,32
 ada:	e40c                	sd	a1,8(s0)
 adc:	e810                	sd	a2,16(s0)
 ade:	ec14                	sd	a3,24(s0)
 ae0:	f018                	sd	a4,32(s0)
 ae2:	f41c                	sd	a5,40(s0)
 ae4:	03043823          	sd	a6,48(s0)
 ae8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 aec:	00840613          	addi	a2,s0,8
 af0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 af4:	85aa                	mv	a1,a0
 af6:	4505                	li	a0,1
 af8:	00000097          	auipc	ra,0x0
 afc:	dce080e7          	jalr	-562(ra) # 8c6 <vprintf>
}
 b00:	60e2                	ld	ra,24(sp)
 b02:	6442                	ld	s0,16(sp)
 b04:	6125                	addi	sp,sp,96
 b06:	8082                	ret

0000000000000b08 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b08:	1141                	addi	sp,sp,-16
 b0a:	e422                	sd	s0,8(sp)
 b0c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b0e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b12:	00000797          	auipc	a5,0x0
 b16:	2967b783          	ld	a5,662(a5) # da8 <freep>
 b1a:	a805                	j	b4a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b1c:	4618                	lw	a4,8(a2)
 b1e:	9db9                	addw	a1,a1,a4
 b20:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b24:	6398                	ld	a4,0(a5)
 b26:	6318                	ld	a4,0(a4)
 b28:	fee53823          	sd	a4,-16(a0)
 b2c:	a091                	j	b70 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b2e:	ff852703          	lw	a4,-8(a0)
 b32:	9e39                	addw	a2,a2,a4
 b34:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b36:	ff053703          	ld	a4,-16(a0)
 b3a:	e398                	sd	a4,0(a5)
 b3c:	a099                	j	b82 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b3e:	6398                	ld	a4,0(a5)
 b40:	00e7e463          	bltu	a5,a4,b48 <free+0x40>
 b44:	00e6ea63          	bltu	a3,a4,b58 <free+0x50>
{
 b48:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b4a:	fed7fae3          	bgeu	a5,a3,b3e <free+0x36>
 b4e:	6398                	ld	a4,0(a5)
 b50:	00e6e463          	bltu	a3,a4,b58 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b54:	fee7eae3          	bltu	a5,a4,b48 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b58:	ff852583          	lw	a1,-8(a0)
 b5c:	6390                	ld	a2,0(a5)
 b5e:	02059713          	slli	a4,a1,0x20
 b62:	9301                	srli	a4,a4,0x20
 b64:	0712                	slli	a4,a4,0x4
 b66:	9736                	add	a4,a4,a3
 b68:	fae60ae3          	beq	a2,a4,b1c <free+0x14>
    bp->s.ptr = p->s.ptr;
 b6c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b70:	4790                	lw	a2,8(a5)
 b72:	02061713          	slli	a4,a2,0x20
 b76:	9301                	srli	a4,a4,0x20
 b78:	0712                	slli	a4,a4,0x4
 b7a:	973e                	add	a4,a4,a5
 b7c:	fae689e3          	beq	a3,a4,b2e <free+0x26>
  } else
    p->s.ptr = bp;
 b80:	e394                	sd	a3,0(a5)
  freep = p;
 b82:	00000717          	auipc	a4,0x0
 b86:	22f73323          	sd	a5,550(a4) # da8 <freep>
}
 b8a:	6422                	ld	s0,8(sp)
 b8c:	0141                	addi	sp,sp,16
 b8e:	8082                	ret

0000000000000b90 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b90:	7139                	addi	sp,sp,-64
 b92:	fc06                	sd	ra,56(sp)
 b94:	f822                	sd	s0,48(sp)
 b96:	f426                	sd	s1,40(sp)
 b98:	f04a                	sd	s2,32(sp)
 b9a:	ec4e                	sd	s3,24(sp)
 b9c:	e852                	sd	s4,16(sp)
 b9e:	e456                	sd	s5,8(sp)
 ba0:	e05a                	sd	s6,0(sp)
 ba2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ba4:	02051493          	slli	s1,a0,0x20
 ba8:	9081                	srli	s1,s1,0x20
 baa:	04bd                	addi	s1,s1,15
 bac:	8091                	srli	s1,s1,0x4
 bae:	0014899b          	addiw	s3,s1,1
 bb2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 bb4:	00000517          	auipc	a0,0x0
 bb8:	1f453503          	ld	a0,500(a0) # da8 <freep>
 bbc:	c515                	beqz	a0,be8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bbe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bc0:	4798                	lw	a4,8(a5)
 bc2:	02977f63          	bgeu	a4,s1,c00 <malloc+0x70>
 bc6:	8a4e                	mv	s4,s3
 bc8:	0009871b          	sext.w	a4,s3
 bcc:	6685                	lui	a3,0x1
 bce:	00d77363          	bgeu	a4,a3,bd4 <malloc+0x44>
 bd2:	6a05                	lui	s4,0x1
 bd4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bd8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bdc:	00000917          	auipc	s2,0x0
 be0:	1cc90913          	addi	s2,s2,460 # da8 <freep>
  if(p == (char*)-1)
 be4:	5afd                	li	s5,-1
 be6:	a88d                	j	c58 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 be8:	00000797          	auipc	a5,0x0
 bec:	1c878793          	addi	a5,a5,456 # db0 <base>
 bf0:	00000717          	auipc	a4,0x0
 bf4:	1af73c23          	sd	a5,440(a4) # da8 <freep>
 bf8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bfa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bfe:	b7e1                	j	bc6 <malloc+0x36>
      if(p->s.size == nunits)
 c00:	02e48b63          	beq	s1,a4,c36 <malloc+0xa6>
        p->s.size -= nunits;
 c04:	4137073b          	subw	a4,a4,s3
 c08:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c0a:	1702                	slli	a4,a4,0x20
 c0c:	9301                	srli	a4,a4,0x20
 c0e:	0712                	slli	a4,a4,0x4
 c10:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c12:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c16:	00000717          	auipc	a4,0x0
 c1a:	18a73923          	sd	a0,402(a4) # da8 <freep>
      return (void*)(p + 1);
 c1e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c22:	70e2                	ld	ra,56(sp)
 c24:	7442                	ld	s0,48(sp)
 c26:	74a2                	ld	s1,40(sp)
 c28:	7902                	ld	s2,32(sp)
 c2a:	69e2                	ld	s3,24(sp)
 c2c:	6a42                	ld	s4,16(sp)
 c2e:	6aa2                	ld	s5,8(sp)
 c30:	6b02                	ld	s6,0(sp)
 c32:	6121                	addi	sp,sp,64
 c34:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c36:	6398                	ld	a4,0(a5)
 c38:	e118                	sd	a4,0(a0)
 c3a:	bff1                	j	c16 <malloc+0x86>
  hp->s.size = nu;
 c3c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c40:	0541                	addi	a0,a0,16
 c42:	00000097          	auipc	ra,0x0
 c46:	ec6080e7          	jalr	-314(ra) # b08 <free>
  return freep;
 c4a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c4e:	d971                	beqz	a0,c22 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c50:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c52:	4798                	lw	a4,8(a5)
 c54:	fa9776e3          	bgeu	a4,s1,c00 <malloc+0x70>
    if(p == freep)
 c58:	00093703          	ld	a4,0(s2)
 c5c:	853e                	mv	a0,a5
 c5e:	fef719e3          	bne	a4,a5,c50 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c62:	8552                	mv	a0,s4
 c64:	00000097          	auipc	ra,0x0
 c68:	b6e080e7          	jalr	-1170(ra) # 7d2 <sbrk>
  if(p == (char*)-1)
 c6c:	fd5518e3          	bne	a0,s5,c3c <malloc+0xac>
        return 0;
 c70:	4501                	li	a0,0
 c72:	bf45                	j	c22 <malloc+0x92>
