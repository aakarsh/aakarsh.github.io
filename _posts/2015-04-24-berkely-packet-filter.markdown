---
layout: post
title: Brief introduction to linux socket filtering
category:  linux,networking
published: true
---

We give a brief overview of the linux socket filtering
framework. Starting with a breif overview of raw sockets we look at
the attaching filters to sockets and give a breif overview of the
berekely packet filter machine implemented in the kernel.

## Introduction.

Linux socket filter is a register based packet filtering machine. It
has two components a network tap and a packet filter. The tap handles
the copying and delivery, the filter handles decision to copy. The
user has the ability to specify how many bytes of the packet he would
like to copied for his use. Only bytes needed for filtering are ever
referenced.


## Raw Sockets
The user can attach filters to sockets via a call to the `setsockopt`
system call specifying either the `SO_ATTACH_FILTER` or `SO_ATTACH_BPF`
to the socket. Now in our case assuming we created our socket as a
`SOCK_RAW` socket

The entry for `SOCK_RAW` in the `inetsw_array` looks like

{% highlight C %}
       {
	       .type =       SOCK_RAW,
	       .protocol =   IPPROTO_IP,	/* wild card */
	       .prot =       &raw_prot,
	       .ops =        &inet_sockraw_ops,
	       .flags =      INET_PROTOSW_REUSE,
       }
// From af_inet.c       
{% endhighlight %}


{% highlight C %}
// From  raw.c
struct proto raw_prot = {
	.name		   = "RAW",
	.owner		   = THIS_MODULE,
	.close		   = raw_close,
	.destroy	   = raw_destroy,
	.connect	   = ip4_datagram_connect,
	.disconnect	   = udp_disconnect,
	.ioctl		   = raw_ioctl,
	.init		   = raw_init,
	.setsockopt	   = raw_setsockopt,
	.getsockopt	   = raw_getsockopt,
	.sendmsg	   = raw_sendmsg,
	.recvmsg	   = raw_recvmsg,
	.bind		   = raw_bind,
	.backlog_rcv	   = raw_rcv_skb,
	.release_cb	   = ip4_datagram_release_cb,
	.hash		   = raw_hash_sk,
	.unhash		   = raw_unhash_sk,
	.obj_size	   = sizeof(struct raw_sock),
	.h.raw_hash	   = &raw_v4_hashinfo,
#ifdef CONFIG_COMPAT
	.compat_setsockopt = compat_raw_setsockopt,
	.compat_getsockopt = compat_raw_getsockopt,
	.compat_ioctl	   = compat_raw_ioctl,
#endif
};
{% endhighlight %}


Going back the  function of `ip_local_deliver_finish` Where the ip
header is checked to find out the protocol to dispatch incoming packet
to.

We see the function `raw_local_deliver` is used to made the
determination if the packet is meant for delivery to a raw socket.

{% highlight C %}
int raw_local_deliver(struct sk_buff *skb, int protocol)
{
	int hash;
	struct sock *raw_sk;

	hash = protocol & (RAW_HTABLE_SIZE - 1);
	raw_sk = sk_head(&raw_v4_hashinfo.ht[hash]);

	/* If there maybe a raw socket we must check - if not we
	 * don't care less
	 */
	if (raw_sk && !raw_v4_input(skb, ip_hdr(skb), hash))
		raw_sk = NULL;

	return raw_sk != NULL;

}
{% endhighlight %}

This will determine if there is a raw socket that is waiting on the
protocol.  If there is then we must deliver the packet to this
socket. The `__raw_v4_lookup` function is used to look up raw sockets
that would be interested in this skb. Attributes of the look up may
include protocol, source address, destination address, device
interface index. We call `skb_clone` function to clone the skb and
call the `raw_rcv` on the socket with the cloned packet. `raw_rcv`
will reset the packet headers back to pointing to this IP
layer. Finally adding the packet to the socket's receive queue. The
`raw_rcv` will eventually call `sock_queue_rcv_skb`. Which will check
if the packet ought to be filtered via a call to the `sk_filter`
function.


{% highlight C %}
//from raw.c 
static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
{
	struct sock *sk;
	struct hlist_head *head;
	int delivered = 0;
	struct net *net;

	read_lock(&raw_v4_hashinfo.lock);
	head = &raw_v4_hashinfo.ht[hash];
	if (hlist_empty(head))
		goto out;

	net = dev_net(skb->dev);
	sk = __raw_v4_lookup(net, __sk_head(head), iph->protocol,
			     iph->saddr, iph->daddr,
			     skb->dev->ifindex);

	while (sk) {
		delivered = 1;
		if ((iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) &&
		    ip_mc_sf_allow(sk, iph->daddr, iph->saddr,
				   skb->dev->ifindex)) {
			struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);

			/* Not releasing hash table! */
			if (clone)
				raw_rcv(sk, clone);
		}
		sk = __raw_v4_lookup(net, sk_next(sk), iph->protocol,
				     iph->saddr, iph->daddr,
				     skb->dev->ifindex);
	}
out:
	read_unlock(&raw_v4_hashinfo.lock);
	return delivered;
}
{% endhighlight %}


If we had attached a socket filter the raw socket we are going to run
this filter at this point.

## The packet filter details

The call to `sk_filter` gets passed in a `socket` and an `skb`. Inside
the socket if we have attached a socket filter this socket filter
`struct sk_filter *filter` is going to be found. Resulting in a call
to `SK_RUN_FILTER`. The return type of which is amount of packet
information the user program is interested in.

{% highlight C %}
// from filter.h
/* Macro to invoke filter function. */
#define SK_RUN_FILTER(filter, ctx) \
(*filter->prog->bpf_func)(ctx, filter->prog->insnsi)

.....

struct bpf_prog {
	u16			pages;		/* Number of allocated pages */
	bool			jited;		/* Is our filter JIT'ed? */
	u32			len;		/* Number of filter blocks */
	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
	unsigned int		(*bpf_func)(const struct sk_buff *skb,
					    const struct bpf_insn *filter);
	/* Instructions for interpreter */
	union {
		struct sock_filter	insns[0];
		struct bpf_insn		insnsi[0];
	};
};

struct sk_filter {
	atomic_t	refcnt;
	struct rcu_head	rcu;
	struct bpf_prog	*prog;
};

{% endhighlight %}

During the creation of the packet filter the program that the user
passed in will be copied into the socket filter and jit compiled via
`bpf_jit_compile` or in case no jit is available the program is
translated into an optimized interpreter via `bpf_migrate_filter`.

## Understanding the instruction set


The BPF engine contains a low level asm-like filter
language. Consisting of the following basic elements

{% highlight C %}
  Element          Description

  A                32 bit wide accumulator
  X                32 bit wide X register
  M[]              16 x 32 bit wide misc registers aka "scratch memory
                   store", addressable from 0 to 15
{% endhighlight %}

An instruction would look like

{% highlight C %}
    op:16, jt:8, jf:8, k:32
{% endhighlight %}

`op` is a 16 bit opcode for an instruction, `jt` and `jf` are two 8-bit
jump targets where `jt` is jump target if true and `jf` is jump
target if false `k` is an instruction dependent argument.

Following table lists the instructions based on the above machine
model. With A as accumulator, X as register and M as scratch memory.

{% highlight C %}

  Instruction      Addressing mode      Description

  ld               1, 2, 3, 4, 10       Load word into A
  ldi              4                    Load word into A
  ldh              1, 2                 Load half-word into A
  ldb              1, 2                 Load byte into A
  ldx              3, 4, 5, 10          Load word into X
  ldxi             4                    Load word into X
  ldxb             5                    Load byte into X

  st               3                    Store A into M[]
  stx              3                    Store X into M[]

  jmp              6                    Jump to label
  ja               6                    Jump to label
  jeq              7, 8                 Jump on k == A
  jneq             8                    Jump on k != A
  jne              8                    Jump on k != A
  jlt              8                    Jump on k < A
  jle              8                    Jump on k <= A
  jgt              7, 8                 Jump on k > A
  jge              7, 8                 Jump on k >= A
  jset             7, 8                 Jump on k & A

  add              0, 4                 A + <x>
  sub              0, 4                 A - <x>
  mul              0, 4                 A * <x>
  div              0, 4                 A / <x>
  mod              0, 4                 A % <x>
  neg              0, 4                 !A
  and              0, 4                 A & <x>
  or               0, 4                 A | <x>
  xor              0, 4                 A ^ <x>
  lsh              0, 4                 A << <x>
  rsh              0, 4                 A >> <x>

  tax                                   Copy A into X
  txa                                   Copy X into A

  ret              4, 9                 Return
  {% endhighlight %}

Along with the above instructions we have the following addressing
modes for addressing locations in packets, in scratch memory and
registers.

{% highlight C %}
  Addressing mode  Syntax               Description

   0               x/%x                 Register X
   1               [k]                  BHW at byte offset k in the packet
   2               [x + k]              BHW at the offset X + k in the packet
   3               M[k]                 Word at offset k in M[]
   4               #k                   Literal value stored in k
   5               4*([k]&0xf)          Lower nibble * 4 at byte offset k in the packet
   6               L                    Jump label L
   7               #k,Lt,Lf             Jump to Lt if true, otherwise jump to Lf
   8               #k,Lt                Jump to Lt if predicate is true
   9               a/%a                 Accumulator A
   10               extension            BPF extension

{% endhighlight %}

Some linux extensions to BPF which allow more convenient access to
frequently needed data.
{% highlight C %}
Possible BPF extensions are shown in the following table:

  Extension                             Description

  len                                   skb->len
  proto                                 skb->protocol
  type                                  skb->pkt_type
  poff                                  Payload start offset
  ifidx                                 skb->dev->ifindex
  nla                                   Netlink attribute of type X with offset A
  nlan                                  Nested Netlink attribute of type X with offset A
  mark                                  skb->mark
  queue                                 skb->queue_mapping
  hatype                                skb->dev->type
  rxhash                                skb->hash
  cpu                                   raw_smp_processor_id()
  vlan_tci                              vlan_tx_tag_get(skb)
  vlan_pr                               vlan_tx_tag_present(skb)
  rand                                  prandom_u32()
  {% endhighlight %}


To get a feel for some of these instructions and their usages consider
a sample BPF programs.

{% highlight C %}
/* IPv4 TCP packet filter */
ldh [12]           /* not sure */
jne #0x800, drop   /*  If loaded half word(16 bits?) is not #0x800  go to label drop */
                   /*  I think checking for ip. */
ldb [23]           /*  load byte at offset 23  the protocol field of the ip packet */
jneq #6, drop      /*  compare with protocol number for tcp which  0x6 not go to drop */
ret #-1            /*  accept whole packet */
drop: ret #0       /*  drop the packet */
  {% endhighlight %}

We can now save this into a file say tcp.f , and run the accompanying
assembler. We can generate code that can be directly loaded by the
bpf_dbg where commands get converted into their op codes.

{% highlight bash %}
$ ./bpf_asm tcp.f
6,40 0 0 12,21 0 3 2048,48 0 0 23,21 0 1 6,6 0 0 4294967295,6 0 0 0,
{% endhighlight %}

Often one needs to get bpf code in syntax used to specify filters in C
code. We can get this by running

{% highlight bash %}
$ ./bpf_asm -c tcp.f
{ 0x28,  0,  0, 0x0000000c },
{ 0x15,  0,  3, 0x00000800 },
{ 0x30,  0,  0, 0x00000017 },
{ 0x15,  0,  1, 0x00000006 },
{ 0x06,  0,  0, 0xffffffff },
{ 0x06,  0,  0, 0000000000 },
{% endhighlight %}

This code can be used in one's c code to while attaching to sockets like so

{% highlight C %}
// untested.
// Where the instructionformat is
// bpf.h
struct bpf_insn {
	__u8	code;		/* opcode */
	__u8	dst_reg:4;	/* dest register */
	__u8	src_reg:4;	/* source register */
	__s16	off;		/* signed offset */
	__s32	imm;		/* signed immediate constant */
};

// in user code.
struct bpf_insn insns[] = {
     { 0x28,  0,  0, 0x0000000c },
     { 0x15,  0,  3, 0x00000800 },
     { 0x30,  0,  0, 0x00000017 },
     { 0x15,  0,  1, 0x00000006 },
     { 0x06,  0,  0, 0xffffffff },
     { 0x06,  0,  0, 0000000000 },
};
{% endhighlight %}
  

Since tools like tcpdump use the libpcap library to compile user
specified filter commands to bpf they can be helpful aids to quickly
generating bpf code. This is where tcpdump options `-d` , `-dd` and
`-ddd` are helpful. As shown bellow. We can use `-d` to see the
mnemonic code which the tcpdump will generate for an expression. `-dd`
to generate C-code for an expression and finally -ddd will generate
them as decimal numbers loadable directly into bpf_dbg and other
tools.


{% highlight bash %}
# tcpdump -iwlan0 -d  'tcp'
(000) ldh      [12]
(001) jeq      #0x86dd          jt 2	jf 7
(002) ldb      [20]
(003) jeq      #0x6             jt 10	jf 4
(004) jeq      #0x2c            jt 5	jf 11
(005) ldb      [54]
(006) jeq      #0x6             jt 10	jf 11
(007) jeq      #0x800           jt 8	jf 11
(008) ldb      [23]
(009) jeq      #0x6             jt 10	jf 11
(010) ret      #262144
(011) ret      #0

# sudo tcpdump -iwlan0 -dd  'tcp'
{ 0x28, 0, 0, 0x0000000c },
{ 0x15, 0, 5, 0x000086dd },
{ 0x30, 0, 0, 0x00000014 },
{ 0x15, 6, 0, 0x00000006 },
{ 0x15, 0, 6, 0x0000002c },
{ 0x30, 0, 0, 0x00000036 },
{ 0x15, 3, 4, 0x00000006 },
{ 0x15, 0, 3, 0x00000800 },
{ 0x30, 0, 0, 0x00000017 },
{ 0x15, 0, 1, 0x00000006 },
{ 0x6, 0, 0, 0x00040000 },
{ 0x6, 0, 0, 0x00000000 },

# sudo tcpdump -iwlan0 -ddd 'tcp
12
40 0 0 12
21 0 5 34525
48 0 0 20
21 6 0 6
21 0 6 44
48 0 0 54
21 3 4 6
21 0 3 2048
48 0 0 23
21 0 1 6
6 0 0 262144
6 0 0 0
{% endhighlight %}


One additional tool that my be helpful to mention in the context of
the bpf. Is the `bpf_dbg` tool(in `tools/net` directory of kernel
source) which can be used to debug bpf filters over pcap files.This a
bpf debugger allowing us to run bpf , step through the code and more.

{% highlight bash%}
// First we capture some traffic in the the pcap format
# sudo tcpdump -s 0 -i wlan0 -w mycap.pcap

// we generate the decimal notation of our desired packet filter.
# sudo tcpdump -iwlan0 -ddd  'tcp' | tr '\n' ','
12,40 0 0 12,21 0 5 34525,48 0 0 20,21 6 0 6,21 0 6 44,48 0 0 54,21 3 4 6,21 0 3 2048,48 0 0 23,21 0 1 6,6 0 0 262144,6 0 0 0,

# sudo ./bpf_dbg
> load pcap mycap.pcap
> load bpf 12,40 0 0 12,21 0 5 34525,48 0 0 20,21 6 0 6,21 0 6 44,48 0 0 54,21 3 4 6,21 0 3 2048,48 0 0 23,21 0 1 6,6 0 0 262144,6 0 0 0,
> run
bpf passes:1716 fails:432
> step
-- register dump --
pc:       [0]
code:     [40] jt[0] jf[0] k[12]
curr:     l0:	ldh [12]
A:        [00000000][0]
X:        [00000000][0]
M[0,15]:  [00000000][0]
-- packet dump --
len: 86
  0: 74 9d dc 8d 68 61 00 22 68 ac 53 2f 86 dd 60 00 
 16: 00 00 00 20 06 40 26 02 03 06 bc ca f1 00 4c 72 
 32: 39 e9 c1 5c 0c 1a 20 01 4d e0 41 01 00 01 00 00 
 48: 00 00 d1 6b c2 58 d2 54 01 bb f0 71 8c f0 3b ef 
 64: 34 b6 80 10 01 ec 51 2b 00 00 01 01 08 0a 00 b6 
 80: 2b 78 81 b3 46 5f 
 {% endhighlight %}


Where the `load` can be used in to load in captured packets and bpf
code which can then be stepped through and debugged.

Other helpful commands available in the debugger are
{% highlight bash %}
disassemble    - get the mnemonic code for filter
dump           - dump c like code 
breakpoint #   -  set a line break point
select     #   - select a given packet for running index of 1
step    #      - step and dump registers
quit           - quit the debugger
{% endhighlight %}


# Complete Example

Finally to wrap up we present a complete example program that uses raw
sockets to listen to http requests and responses and prints it out to
standard out. This is just a modification of the code presented in the
binary tides article for illustration purposes.

{% highlight C %}
/** References : https://gist.github.com/msantos/939154
    http://www.binarytides.com/packet-sniffer-code-in-c-using-linux-sockets-bsd-part-2/
*/
#include <stdio.h>
#include<errno.h>

#include<stdio.h> //For standard things
#include<stdlib.h>    //malloc
#include<string.h>    //strlen

#include<netinet/tcp.h>   //Provides declarations for tcp header
#include<netinet/ip.h>    //Provides declarations for ip header
#include<net/ethernet.h>  //For ether_header

#include<sys/socket.h>
#include<arpa/inet.h>

#include <linux/filter.h>

//sudo tcpdump -A -dd -s 0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'
struct sock_filter tcp_filter [] = {
{ 0x28, 0, 0, 0x0000000c },
{ 0x15, 27, 0, 0x000086dd },
{ 0x15, 0, 26, 0x00000800 },
{ 0x30, 0, 0, 0x00000017 },
{ 0x15, 0, 24, 0x00000006 },
{ 0x28, 0, 0, 0x00000014 },
{ 0x45, 22, 0, 0x00001fff },
{ 0xb1, 0, 0, 0x0000000e },
{ 0x48, 0, 0, 0x0000000e },
{ 0x15, 2, 0, 0x00000050 },
{ 0x48, 0, 0, 0x00000010 },
{ 0x15, 0, 17, 0x00000050 },
{ 0x28, 0, 0, 0x00000010 },
{ 0x2, 0, 0, 0x00000001 },
{ 0x30, 0, 0, 0x0000000e },
{ 0x54, 0, 0, 0x0000000f },
{ 0x64, 0, 0, 0x00000002 },
{ 0x7, 0, 0, 0x00000005 },
{ 0x60, 0, 0, 0x00000001 },
{ 0x1c, 0, 0, 0x00000000 },
{ 0x2, 0, 0, 0x00000005 },
{ 0xb1, 0, 0, 0x0000000e },
{ 0x50, 0, 0, 0x0000001a },
{ 0x54, 0, 0, 0x000000f0 },
{ 0x74, 0, 0, 0x00000002 },
{ 0x7, 0, 0, 0x00000009 },
{ 0x60, 0, 0, 0x00000005 },
{ 0x1d, 1, 0, 0x00000000 },
{ 0x6, 0, 0, 0x00040000 },
{ 0x6, 0, 0, 0x00000000 },
};

void print_tcp_packet(unsigned char* packet, int size);
void process_packet(char* packet, int packet_size);
void print_ip_header(unsigned char* packet, int packet_size);
void print_data (unsigned char* data , int Size);


int main(int argc , char* argv[]){
  unsigned char *packet ;
  int saddr_size ;
  int data_size;
  struct sockaddr saddr;         

  const int max_packet_size = 65536; //Its Big!
  printf("begin: http sniff\n");
  
  packet  = (unsigned char *) malloc(max_packet_size); 
  
  int sock_fd = socket(AF_PACKET,SOCK_RAW,htons(ETH_P_ALL)) ;
  if(sock_fd < 0)    {    
    perror("Socket Error");
    return 1;
  }
  struct sock_fprog fcode = {0};
  fcode.len = sizeof(tcp_filter) / sizeof(struct sock_filter);
  fcode.filter = &tcp_filter[0];
  
  setsockopt(sock_fd,SOL_SOCKET,SO_ATTACH_FILTER,&fcode,sizeof(fcode));
  
  while(1)
    {
        saddr_size = sizeof saddr;
        //Receive a packet
        data_size = recvfrom(sock_fd , packet , max_packet_size , 0 , &saddr , (socklen_t*)&saddr_size);
        if(data_size <0 )
        {
            printf("Recvfrom error , failed to get packets\n");
            return 1;
        }
        process_packet(packet,data_size);
    }
  
  free(packet);
  printf("end: http sniff\n");
  return 0;
}

void process_packet(char* packet, int packet_size)
{
  printf("process_packet: packet size %d \n",packet_size);
  print_tcp_packet(packet, packet_size);
}


void print_ip_header(unsigned char* Buffer, int Size)
{
  //    print_ethernet_header(Buffer , Size);
  struct sockaddr_in source,dest;
    unsigned short iphdrlen;
         
    struct iphdr *iph = (struct iphdr *)(Buffer  + sizeof(struct ethhdr) );
    iphdrlen =iph->ihl*4;

    memset(&source, 0, sizeof(source));
    source.sin_addr.s_addr = iph->saddr;
     
    memset(&dest, 0, sizeof(dest));
    dest.sin_addr.s_addr = iph->daddr;
     
    fprintf(stdout , "\n");
    fprintf(stdout , "IP Header\n");
    fprintf(stdout , "   |-IP Version        : %d\n",(unsigned int)iph->version);
    fprintf(stdout , "   |-IP Header Length  : %d DWORDS or %d Bytes\n",(unsigned int)iph->ihl,((unsigned int)(iph->ihl))*4);
    fprintf(stdout , "   |-Type Of Service   : %d\n",(unsigned int)iph->tos);
    fprintf(stdout , "   |-IP Total Length   : %d  Bytes(Size of Packet)\n",ntohs(iph->tot_len));
    fprintf(stdout , "   |-Identification    : %d\n",ntohs(iph->id));
    //fprintf(stdout , "   |-Reserved ZERO Field   : %d\n",(unsigned int)iphdr->ip_reserved_zero);
    //fprintf(stdout , "   |-Dont Fragment Field   : %d\n",(unsigned int)iphdr->ip_dont_fragment);
    //fprintf(stdout , "   |-More Fragment Field   : %d\n",(unsigned int)iphdr->ip_more_fragment);
    fprintf(stdout , "   |-TTL      : %d\n",(unsigned int)iph->ttl);
    fprintf(stdout , "   |-Protocol : %d\n",(unsigned int)iph->protocol);
    fprintf(stdout , "   |-Checksum : %d\n",ntohs(iph->check));
    fprintf(stdout , "   |-Source IP        : %s\n",inet_ntoa(source.sin_addr));
    fprintf(stdout , "   |-Destination IP   : %s\n",inet_ntoa(dest.sin_addr));

}



void print_tcp_packet(unsigned char* Buffer, int Size)
{
    unsigned short iphdrlen;
     
    struct iphdr *iph = (struct iphdr *)( Buffer  + sizeof(struct ethhdr) );
    iphdrlen = iph->ihl*4;
     
    struct tcphdr *tcph=(struct tcphdr*)(Buffer + iphdrlen + sizeof(struct ethhdr));
             
    int header_size =  sizeof(struct ethhdr) + iphdrlen + tcph->doff*4;
     
    fprintf(stdout , "\n\n***********************TCP Packet*************************\n");  
         
    print_ip_header(Buffer,Size);
         
    fprintf(stdout , "\n");
    fprintf(stdout , "TCP Header\n");
    fprintf(stdout , "   |-Source Port      : %u\n",ntohs(tcph->source));
    fprintf(stdout , "   |-Destination Port : %u\n",ntohs(tcph->dest));
    fprintf(stdout , "   |-Sequence Number    : %u\n",ntohl(tcph->seq));
    fprintf(stdout , "   |-Acknowledge Number : %u\n",ntohl(tcph->ack_seq));
    fprintf(stdout , "   |-Header Length      : %d DWORDS or %d BYTES\n" ,(unsigned int)tcph->doff,(unsigned int)tcph->doff*4);
    //fprintf(stdout , "   |-CWR Flag : %d\n",(unsigned int)tcph->cwr);
    //fprintf(stdout , "   |-ECN Flag : %d\n",(unsigned int)tcph->ece);
    fprintf(stdout , "   |-Urgent Flag          : %d\n",(unsigned int)tcph->urg);
    fprintf(stdout , "   |-Acknowledgement Flag : %d\n",(unsigned int)tcph->ack);
    fprintf(stdout , "   |-Push Flag            : %d\n",(unsigned int)tcph->psh);
    fprintf(stdout , "   |-Reset Flag           : %d\n",(unsigned int)tcph->rst);
    fprintf(stdout , "   |-Synchronise Flag     : %d\n",(unsigned int)tcph->syn);
    fprintf(stdout , "   |-Finish Flag          : %d\n",(unsigned int)tcph->fin);
    fprintf(stdout , "   |-Window         : %d\n",ntohs(tcph->window));
    fprintf(stdout , "   |-Checksum       : %d\n",ntohs(tcph->check));
    fprintf(stdout , "   |-Urgent Pointer : %d\n",tcph->urg_ptr);
    fprintf(stdout , "\n");
    fprintf(stdout , "                        DATA Dump                         ");
    fprintf(stdout , "\n");

    /**
    fprintf(stdout , "IP Header\n");
    print_data(Buffer,iphdrlen);
         
    fprintf(stdout , "TCP Header\n");
    print_data(Buffer+iphdrlen,tcph->doff*4);
    */                           
    fprintf(stdout , "Data Payload\n");    
    print_data(Buffer + header_size , Size - header_size );

    fprintf(stdout , "\n###########################################################\n");
}



void print_data (unsigned char* data , int Size)
{
    int i , j;
    for(i=0 ; i < Size ; i++)
    {
        if( i!=0 && i%16==0)   //if one line of hex printing is complete...
        {
            fprintf(stdout , "         ");
            for(j=i-16 ; j<i ; j++)
            {
                if(data[j]>=32 && data[j]<=128)
                    fprintf(stdout , "%c",(unsigned char)data[j]); //if its a number or alphabet
                 
                else fprintf(stdout , "."); //otherwise print a dot
            }
            fprintf(stdout , "\n");
        } 
         
        if(i%16==0) fprintf(stdout , "   ");
            fprintf(stdout , " %02X",(unsigned int)data[i]);
                 
        if( i==Size-1)  //print the last spaces
        {
            for(j=0;j<15-i%16;j++) 
            {
              fprintf(stdout , "   "); //extra spaces
            }
             
            fprintf(stdout , "         ");
             
            for(j=i-i%16 ; j<=i ; j++)
            {
                if(data[j]>=32 && data[j]<=128) 
                {
                  fprintf(stdout , "%c",(unsigned char)data[j]);
                }
                else
                {
                  fprintf(stdout , ".");
                }
            }
             
            fprintf(stdout ,  "\n" );
        }
    }
}
{% endhighlight %}

# Summary

This article scratches the surface of understanding the flexibility
offered in the linux networking stack.  Since this more as a brain
dump of reading through the source in the 3.19-rc7 kernel networking
subsystem,thus it may be **highly unreliable** and
**inaccurate**. **Users beware!** With that fair warning lets try to
begin.Any errors in the article are entirely my fault.


---
[socket-filtering]:http://www.linuxjournal.com/article/4659
[kernel-bpf]: https://www.kernel.org/doc/Documentation/networking/filter.txt
[bpf]: http://www.tcpdump.org/papers/bpf-usenix93.pdf
[raw-sockets]: http://sock-raw.org/papers/sock_raw
[netfilter-modules]: http://inai.de/documents/Netfilter_Modules.pdf
[linuxeco]: http://linuxeco.com/
[lwn]: http://lwn.net/
[ukl]: http://www.amazon.com/gp/product/0596005652/ref=pd_lpo_sbs_dp_ss_2?pf_rd_p=1944687462&pf_rd_s=lpo-top-stripe-1&pf_rd_t=201&pf_rd_i=0596002556&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=040GZAP017H8K2XKZPJA
[lin-net]: http://www.amazon.com/Understanding-Network-Internals-Christian-Benvenuti/dp/0596002556
[unix-poll]: http://unixhelp.ed.ac.uk/CGI/man-cgi?poll+2
[ldd-book]: http://www.amazon.com/gp/product/0596005903/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0596005903&linkCode=as2&tag=persblog073-20
[ldd-free]: http://lwn.net/Kernel/LDD3/
[named-pipe]: http://www.linuxjournal.com/article/2156?page=0,1
[inotify]: http://man7.org/linux/man-pages/man7/inotify.7.html
[rtl-8139]: http://www.tldp.org/LDP/LG/issue93/bhaskaran.html
[udp-server]: http://www.microhowto.info/howto/listen_for_and_receive_udp_datagrams_in_c.html
[bpf-cloudfare]: https://blog.cloudflare.com/bpf-the-forgotten-bytecode/
[bpf-couldfare2]: https://blog.cloudflare.com/introducing-the-bpf-tools/
