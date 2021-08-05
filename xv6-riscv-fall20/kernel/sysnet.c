//
// network system calls.
//

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"
#include "net.h"

struct sock {
  struct sock *next; // the next socket in the list
  uint32 raddr;      // the remote IPv4 address
  uint16 lport;      // the local UDP port number
  uint16 rport;      // the remote UDP port number
  struct spinlock lock; // protects the rxq
  struct mbufq rxq;  // a queue of packets waiting to be received
};

static struct spinlock lock;
static struct sock *sockets;

void
sockinit(void)
{
  initlock(&lock, "socktbl");
}

int
sockalloc(struct file **f, uint32 raddr, uint16 lport, uint16 rport)
{
  struct sock *si, *pos;

  si = 0;
  *f = 0;
  if ((*f = filealloc()) == 0)
    goto bad;
  if ((si = (struct sock*)kalloc()) == 0)
    goto bad;

  // initialize objects
  si->raddr = raddr;
  si->lport = lport;
  si->rport = rport;
  initlock(&si->lock, "sock");
  mbufq_init(&si->rxq);
  (*f)->type = FD_SOCK;
  (*f)->readable = 1;
  (*f)->writable = 1;
  (*f)->sock = si;

  // add to list of sockets
  acquire(&lock);
  pos = sockets;
  while (pos) {
    if (pos->raddr == raddr &&
        pos->lport == lport &&
	pos->rport == rport) {
      release(&lock);
      goto bad;
    }
    pos = pos->next;
  }
  si->next = sockets;
  sockets = si;
  release(&lock);
  return 0;

bad:
  if (si)
    kfree((char*)si);
  if (*f)
    fileclose(*f);
  return -1;
}

//
// Your code here.
//
// Add and wire in methods to handle closing, reading,
// and writing for network sockets.
//

void 
sockclose(struct sock *socket)
{
  // temp will be the socket to be freed
  // pos is used to iterate sockets
  struct sock *pos, *temp;
  temp = 0;
  acquire(&lock);

  pos = sockets;
  if(!pos) {
    // empty sockets
    // return;
  } 
  else if (pos == socket) {
    // head of sockets is socket and hence head to be updated
    sockets = pos->next;
    temp = pos;
  } 
  else {
    while (pos->next) {
      if (pos->next == socket) {
        // remove pos->next from socket list
        temp = pos->next;
        pos->next = temp->next;
        break;
      }
      pos = pos->next;
    }
  }
  release(&lock);
  
  if(!temp) return;
  
  acquire(&temp->lock);

  // free temp but before free mbufq
  struct mbuf* mbuf = temp->rxq.head;
  struct mbuf* iter_mbuf;
  while(mbuf) {
    // free rxq 
    // don't know how to read
    // just simply freeing
    iter_mbuf = mbuf;
    mbuf = mbuf->next;
    mbuffree(iter_mbuf);
  }
  
  release(&temp->lock);

  kfree(temp);
}

int
sockread(struct sock* socket, uint64 addr, int n)
{

  struct mbuf* mbuf;
  struct proc *pr = myproc();

  acquire(&socket->lock);

  // check if mbuf is empty
  while(mbufq_empty(&socket->rxq)) {
    // wait until it gets non-empty
    if(myproc()->killed) {
      release(&socket->lock);
      return -1;
    }
    sleep(&socket->rxq, &socket->lock);
  }

  // there will be at least one mbuf
  if((mbuf = mbufq_pophead(&socket->rxq)) == 0) {
    panic("sockread");
  }

  release(&socket->lock);

  // mbuf length to be sent
  if(n > mbuf->len) n = mbuf->len;

  if(copyout(pr->pagetable, addr, mbuf->head, n) == -1) {
    n = -1;
  }

  // free mbuf as it is sent to user
  mbuffree(mbuf);

  return n;
}

int 
sockwrite(struct sock* socket, uint64 addr, int n)
{
  struct mbuf *mbuf;
  struct proc *pr = myproc();

  unsigned int headroom;
  // leave headroom size in  mbuf head
  headroom = sizeof(struct udp) + sizeof(struct ip) + sizeof(struct eth);
  // printf("Headroom size: %d\n", headroom);

  // allocate a new mbuf
  if((mbuf = mbufalloc(headroom)) == 0) {
    panic("sockwrite");
  }

  // append
  mbufput(mbuf, n);

  // copyin
  if(copyin(pr->pagetable, mbuf->head, addr, n) == -1) {
    mbuffree(mbuf);
    return -1;
  }

  acquire(&socket->lock);

  net_tx_udp(mbuf, socket->raddr, socket->lport, socket->rport);

  release(&socket->lock);
  return n;
}

// called by protocol handler layer to deliver UDP packets
void
sockrecvudp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport)
{
  //
  // Your code here.
  //
  // Find the socket that handles this mbuf and deliver it, waking
  // any sleeping reader. Free the mbuf if there are no sockets
  // registered to handle it.
  //

  struct sock* pos;

  acquire(&lock);

  pos = sockets;
  while (pos) {
    if (pos->raddr == raddr &&
        pos->lport == lport &&
	      pos->rport == rport) {
      // socket found. Put the mbuf into rxq and wakeup the socket
      break;
    }
    pos = pos->next;
  }

  release(&lock);

  if(pos) {
    acquire(&pos->lock);
    // push mbuf into rxq and wakeup the rxq
    mbufq_pushtail(&pos->rxq, m);
    wakeup(&pos->rxq);

    release(&pos->lock);
  } 
  else {
    // free the mbuf as it cannot be ddelivered.
    mbuffree(m);
  }  
}
