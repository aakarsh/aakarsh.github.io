---
layout: post
title: Tracing a packet through the linux networking subsystems.
category:  linux,networking
published: true
---

In this post we trace the path of a packet from through the linux
networking subsystem. We go from a breif overview from packet's
arrival at the network card to its final destination on a socket's
receive queue.

### Networking drivers and their woes

We try to take as example a simple networking driver which seems to be
widely used as an example the RTL8139 ethernet driver. Its a fairly
complicated driver for a ethernet PCI card which I dont pretend to
understand. Just to document some key parts. Most of the source code
can be found in

{% highlight C %}
<linux-src>/drivers/net/ethernet/realtek/8139too.c
{% endhighlight %}

When the driver module is brought up it registers it self with the PCI
subsystem in the kernel using the standard call of
`pci_register_driver`. Defining standard interface methods, as shown
below.

{% highlight C %}

static struct pci_driver rtl8139_pci_driver = {
	.name		= DRV_NAME,
	.id_table	= rtl8139_pci_tbl,
	.probe		= rtl8139_init_one,
	.remove		= rtl8139_remove_one,
#ifdef CONFIG_PM
	.suspend	= rtl8139_suspend,
	.resume		= rtl8139_resume,
#endif /* CONFIG_PM */
};
{% endhighlight %}

As the board initialized via the probe function the method
rtl8139_init_one is called. This method will confirm that a board
plugged in is belongs to the current vendor. The board gets
initialized and the we map the memory regions on the PCI device to
and ioaddr.

{% highlight C %}
   	ioaddr = pci_iomap(pdev, bar, 0);
{% endhighlight %}

Using the bar register of the pci device. This is so that we can
perform memory mapped io with the device. We also initialize the key
kernel structure used to describe the network device a huge
datastructure called struct net_device.


The netdev data structure also contains a dev->netdev_ops defining
device operations.

{% highlight C %}
static const struct net_device_ops rtl8139_netdev_ops = {
	.ndo_open		= rtl8139_open,
	.ndo_stop		= rtl8139_close,
	.ndo_get_stats64	= rtl8139_get_stats64,
	.ndo_change_mtu		= rtl8139_change_mtu,
	.ndo_validate_addr	= eth_validate_addr,
	.ndo_set_mac_address 	= rtl8139_set_mac_address,
	.ndo_start_xmit		= rtl8139_start_xmit,
	.ndo_set_rx_mode	= rtl8139_set_rx_mode,
	.ndo_do_ioctl		= netdev_ioctl,
	.ndo_tx_timeout		= rtl8139_tx_timeout,
#ifdef CONFIG_NET_POLL_CONTROLLER
	.ndo_poll_controller	= rtl8139_poll_controller,
#endif
	.ndo_set_features	= rtl8139_set_features,
};
{% endhighlight %}


In the the function `rtl8139_open` as a key step we define a method to
respond to interrupts from the hardware done as follows

{% highlight C %}
   	retval = request_irq(irq, rtl8139_interrupt, IRQF_SHARED, dev->name, dev);
{% endhighlight %}

Where the irq to use is obtained from the pci configuration of the
device. We also allocate two buffers to which will be mapped to the
transfer and receive buffers on the device

{% highlight C %}
	struct rtl8139_private *tp = netdev_priv(dev);
        ....
         ....

	tp->tx_bufs = dma_alloc_coherent(&tp->pci_dev->dev, TX_BUF_TOT_LEN,
					   &tp->tx_bufs_dma, GFP_KERNEL);
	tp->rx_ring = dma_alloc_coherent(&tp->pci_dev->dev, RX_BUF_TOT_LEN,
					   &tp->rx_ring_dma, GFP_KERNEL);
{% endhighlight %}

Too delay with highly interrupting devices linux has started to move
to newer api called napi which can dynamically switch a device from
polling to interrupt mode based on certain policy considerations.

Finally we perform certain device specific initializations in
`rtl8139_hw_start` Like enabling interrupts on the device, setting
receive modes and other device specific miscellany.

Having thus set up the device we allow the linux to start using this
device to send packets by calling the key method

{% highlight C %}
static inline void netif_start_queue(struct net_device *dev)

netif_start_queue (dev);

{% endhighlight %}

There is also a watchdog timer which I am punting on for now.


Now on packet receipt the device is going to raise the interrupt
calling our method.

{% highlight C %}
static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
{% endhighlight %}

If we can schedule the running of napi we do it as shown here

{% highlight C %}
	if (status & RxAckBits){
		if (napi_schedule_prep(&tp->napi)) {
			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
			__napi_schedule(&tp->napi);
		}
	}

{% endhighlight %}

The receipt of the packets being are processed thus by the napi which
will call the specified poll routine.

{% highlight C %}
static int rtl8139_poll(struct napi_struct *napi, int budget)
{% endhighlight %}

Passed in a fixed budget which decides to perform the receipt now or later.

The actual method doing the receipt is :

{% highlight C %}
static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
		      int budget)
{% endhighlight %}


If all is well we will allocate a an skb. The key kernel datastructure
to hold packets received and being processed up the protocol
stack. Thus we now copy the packet from the device receive buffer into
an skb. Update some device statistics. Detect the link layer protocl
used by the packet and finally call the key method `netif_receive_skb`
with the copied packet.

{% highlight C %}
   netif_receive_skb (skb);
{% endhighlight %}

As of reading this its unclear to me if the copy happens in the
context of the actual interrupt or in the context of the soft IRQ
generated by the napi subsystem.

Either way the `netif_receive_skb` will take place. The skb is not going
to get queued int to a per cpu packet backlog queue. Called
`softnet_data`. Using the function

{% highlight C %}
static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
			      unsigned int *qtail)

....
	__skb_queue_tail(&sd->input_pkt_queue, skb);
.....
	return NET_RX_SUCCESS;
...
{% endhighlight %}

### A packet arrives

After successfully queuing the packet onto the cpu backlog queue we
are going to return `NET_RX_SUCCESS` to the driver. Now moving away from
the driver side of packet receipt to the operating system side of
processing the packet. I still need to look into how the
`process_backlog` queue getting invoked.

{% highlight C %}
   static int process_backlog(struct napi_struct *napi, int quota)
{% endhighlight %}

Anyway our process function gets called at which point we dequeue the
from the per queue

{% highlight C %}
   static int process_backlog(struct napi_struct *napi, int quota)
   .....
		while ((skb = __skb_dequeue(&sd->process_queue))) {
			local_irq_enable();
			__netif_receive_skb(skb);
			local_irq_disable();
			input_queue_head_incr(sd);
			if (++work >= quota) {
				local_irq_enable();
				return work;
			}
		}

 ......
{% endhighlight %}

Its now the job of `__netif_receive_skb` to take the job of processing
the skb. After some munging around of the skb our
`__netif_receive_skb_core` will get called which will call the function
`deliver_skb`.

A key step here is to determine the packet type that we are dealing
with here. Different protocols register their packet types allowing
themselves to become identifiable.  The key packet type interface is
described as follows :

{% highlight C %}
struct packet_type {
	__be16			type;	/* This is really htons(ether_type). */
	struct net_device	*dev;	/* NULL is wildcarded here	     */
	int			(*func) (struct sk_buff *,
					 struct net_device *,
					 struct packet_type *,
					 struct net_device *);
	bool			(*id_match)(struct packet_type *ptype,
					    struct sock *sk);
	void			*af_packet_priv;
	struct list_head	list;
};
{% endhighlight %}

We can see the packet type of ipv4 in net/ipv4/af_inet.c. As shown here

{% highlight C %}
#define ETH_P_IP	0x0800		/* Internet Protocol packet	*/
....
static struct packet_type ip_packet_type __read_mostly = {
	.type = cpu_to_be16(ETH_P_IP),
	.func = ip_rcv,
};
{% endhighlight %}

Thus our `deliver_skb` function is going to match the type of the packet
as ip and call `ip_rcv`.


{% highlight C %}

int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)

ip_input.c
{% endhighlight %}


In the `ip_rcv` function we are going to parse out the ip header from
skb. Determine the length of the packet Update some
statistics. Finally ending with the mysterious Netfilter hook which is
generally used customize action on packets if we so choose. As shown here

{% highlight C %}
   int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
   ....
	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, dev, NULL,
		       ip_rcv_finish);
   .....                       
{% endhighlight %}


The key function that is provided to the netfilter hook is the
`ip_rcv`_finish function which is called if netfilter wants to continue
the processing of the packet.


{% highlight C %}
static int ip_rcv_finish(struct sk_buff *skb) {
....
}
{% endhighlight %}

### A packet begins its ascent

The `ip_rcv`_finish may need to look into the packet , check if it needs
to be routed to other machines. I am only going to look at the case
that the packet is destined to the current machine.

The ip layer consults the routing table and a routing table cache to
find out where the packet is meant to be delivered.

Finally if the packet is to be delivered to the local host it returns a
`struct dst_entry`  with its input method set to `ip_local_deliver`.

The `ip_local_deliver` gets called we encounter another netfilter hook
`NF_INET_LOCAL_IN` which is called as follows.


{% highlight C %}
int ip_local_deliver(struct sk_buff *skb)
{
....
  return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
         ip_local_deliver_finish);
}
{% endhighlight %}

Thus finding we can now add a netfilter hook just for packets meant
for the local host. Assuming again that netfilter allows for further
processing of the packet we are now ready to begin further processing
of the packet.

Inside of `ip_local_deliver_finish` we are now ready to examine the ip
protocol to which the packet ought to be delivered. There is some
thing about raw delivery which needs to be looked at but currently
skipped.

{% highlight C %}
static int ip_local_deliver_finish(struct sk_buff *skb)
{
        ......
        int protocol = ip_hdr(skb)->protocol;
        ....
	ipprot = rcu_dereference(inet_protos[protocol]);
        ...
   	ret = ipprot->handler(skb);
        ......
}
{% endhighlight %}

Notice how we look up the protocol in the ip header and then use this
protocol look up the inet_protos array for implementing protocol
finally calling its handler. These protocl handlers are initialized
inet subsystem initialization with a call to inet_inet.

{% highlight C %}
static int __init inet_init(void)
{
        ....
       	if (inet_add_protocol(&icmp_protocol, IPPROTO_ICMP) < 0)
		pr_crit("%s: Cannot add ICMP protocol\n", __func__);
	if (inet_add_protocol(&udp_protocol, IPPROTO_UDP) < 0)
		pr_crit("%s: Cannot add UDP protocol\n", __func__);
	if (inet_add_protocol(&tcp_protocol, IPPROTO_TCP) < 0)
		pr_crit("%s: Cannot add TCP protocol\n", __func__);
#ifdef CONFIG_IP_MULTICAST
	if (inet_add_protocol(&igmp_protocol, IPPROTO_IGMP) < 0)
		pr_crit("%s: Cannot add IGMP protocol\n", __func__);
#endif
        ....
}
{% endhighlight %}

There thus we see the initialization of the protocl array with some
common ip protocols. The protocol themselves are describe as follows.

{% highlight C %}
static const struct net_protocol tcp_protocol = {
	.early_demux	=	tcp_v4_early_demux,
	.handler	=	tcp_v4_rcv,
	.err_handler	=	tcp_v4_err,
	.no_policy	=	1,
	.netns_ok	=	1,
	.icmp_strict_tag_validation = 1,
};

static const struct net_protocol udp_protocol = {
	.early_demux =	udp_v4_early_demux,
	.handler =	udp_rcv,
	.err_handler =	udp_err,
	.no_policy =	1,
	.netns_ok =	1,
};

static const struct net_protocol icmp_protocol = {
	.handler =	icmp_rcv,
	.err_handler =	icmp_err,
	.no_policy =	1,
	.netns_ok =	1,
};
{% endhighlight %}


We see each protocol defining its corresponding handlers.We however
are only going to look at the udp handler. To keep it relatively
simple.

### Home Sweet Socket

UDP much like tcp contains a hash table of sockets that are currently
in listening for packets.

{% highlight C %}

/**
 *	struct udp_table - UDP table
 *
 *	@hash:	hash table, sockets are hashed on (local port)
 *	@hash2:	hash table, sockets are hashed on (local port, local address)
 *	@mask:	number of slots in hash tables, minus 1
 *	@log:	log2(number of slots in hash table)
 */
struct udp_table {
	struct udp_hslot	*hash;
	struct udp_hslot	*hash2;
	unsigned int		mask;
	unsigned int		log;
};
extern struct udp_table udp_table;

{% endhighlight %}

The details of this are left to the reader to delve into. Assuming
that the packet was a udp packet its protocl must have been
initialized to

{% highlight C %}
#define IPPROTO_UDP		IPPROTO_UDP
  IPPROTO_IDP = 22,		/* XNS IDP protocol			*/
{% endhighlight %}

Now we begin to look up the socket and do simple checksum. The look up
takes into account the source and destination and the source port and
destination ports. As we see from the the arguments to the look
method.

{% highlight C %}
int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
		   int proto)
{
        ....
	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
        ....
}

struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
		__be16 sport, __be32 daddr, __be16 dport,
		int dif, struct udp_table *udptable)
                
{% endhighlight %}

If there is a socket listening we ought to find it. Finally calling
the `udp_queue_rcv_skb` with the found socket and the skb packet.

{% highlight C %}
   	ret = udp_queue_rcv_skb(sk, skb);
{% endhighlight %}

Which is going to finally translate into a call to
`sock_queue_rcv_skb`. In case we are using some sort of socket filtering
which I believe is somewhat similar to the Berkeley packet filter we
pass the socket and and the skb to that socket filter. The underlying
method for this is the `sk_filter`.

{% highlight C %}
   int sk_filter(struct sock *sk, struct sk_buff *skb)
   ...
   int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
   {
   ...
   	err = sk_filter(sk, skb);
   ...
   }
{% endhighlight %}

We call the `skb_set_owner_r` to set the skb to have the found socket as
its owner. And are now ready to queue this skb into the sockets
receive queue.

{% highlight C %}
int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
{
        ....
        struct sk_buff_head *list = &sk->sk_receive_queue;
        ....
       	__skb_queue_tail(list, skb);
        ....
}
{% endhighlight %}

Thus having reached the underlying socket.

## Oh Packet, I waited for you so long.

When the inet subsystem gets initialized apart from initializing all
sorts of caches and adding to the inet_protos array various ip
protocols. We also initialize the socks subsystem with call to
`sock_register` which ads a protocol handlers for various sockets.

{% highlight C %}
   	(void)sock_register(&inet_family_ops);


static const struct net_proto_family inet_family_ops = {
	.family = PF_INET,
	.create = inet_create,
	.owner	= THIS_MODULE,
};
{% endhighlight %}

We might recognize the `PF_INET` as the protocol family that is used
during the socket creation step. If we remember our socket programming
one of the first steps in the creation of the socket is the socket
system call which can be seen in `socket.c`. Which will thread down the
a call to `__sock_create`. with all the usual. 

{% highlight C %}
SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
int __sock_create(struct net *net, int family, int type, int protocol,
			 struct socket **res, int kern)
{
...
	sock = sock_alloc();
        ....
       	pf = rcu_dereference(net_families[family]);

        ...
       	err = pf->create(net, sock, protocol, kern);
}
{% endhighlight %}

The protocol family that is passed is an integer referencing the
net_families array.This is the very protocol family which we had
created and initialized at the inet_init. Thus our pf create method is
going to result in calling inet_create and the socket system call.

in `af_inet.c` we actually see the definition of various protocols of the ip family.


{% highlight C %}
static struct inet_protosw inetsw_array[] =
{
	{
		.type =       SOCK_STREAM,
		.protocol =   IPPROTO_TCP,
		.prot =       &tcp_prot,
		.ops =        &inet_stream_ops,
		.flags =      INET_PROTOSW_PERMANENT |
			      INET_PROTOSW_ICSK,
	},
	{
		.type =       SOCK_DGRAM,
		.protocol =   IPPROTO_UDP,
		.prot =       &udp_prot,
		.ops =        &inet_dgram_ops,
		.flags =      INET_PROTOSW_PERMANENT,
       },
       {
		.type =       SOCK_DGRAM,
		.protocol =   IPPROTO_ICMP,
		.prot =       &ping_prot,
		.ops =        &inet_dgram_ops,
		.flags =      INET_PROTOSW_REUSE,
       },
       {
	       .type =       SOCK_RAW,
	       .protocol =   IPPROTO_IP,	/* wild card */
	       .prot =       &raw_prot,
	       .ops =        &inet_sockraw_ops,
	       .flags =      INET_PROTOSW_REUSE,
       }
};
{% endhighlight %}

Each protocol defining its operations to common socket
operations. Consider for example `SOCK_DGRAM` which is the the uses
the udp_protocol. As we traverse through the inet_create we find that
the `struct socket` which gets created also gets gets assigned a
`struct sock`. If we remember the `struct sock` was the structure on
to whose `sk_receive_queue` the final packet ended up. Here we are
creating the empty queue on to which our sent and received packets
will get placed. Still need to look at why the `struct socket` as used
as a encapsulation layer over `struct sock`. Aneeways, moving on to
our next method i.e `bind()` if we remember will the bind system call
is defined in the kernel as follows

{% highlight C %}
SYSCALL_DEFINE3(bind, int, fd, struct sockaddr __user *, umyaddr, int, addrlen)

// Example usage

   
   serv_addr.sin_family = AF_INET;
   serv_addr.sin_addr.s_addr = INADDR_ANY;
   serv_addr.sin_port = htons(portno);
   
   /* Now bind the host address using bind() call.*/
   if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0)

{% endhighlight %}

Ok since the `fd` passed to the bind is a regular file descriptor The
first thing we must do is convert this regular file descriptor to a
`struct socket`. To do this we look at the current processes list
files just as we would for a regular file. This file descriptor entry
is had actually gotten added when we created the socket using socket
fs. The struct socket for this file descriptor is tucked away in the
file's private data. As seen here :

{% highlight C %}
struct socket *sock_from_file(struct file *file, int *err)
{
	if (file->f_op == &socket_file_ops)
		return file->private_data;	/* set in sock_map_fd */

	*err = -ENOTSOCK;
	return NULL;
}
{% endhighlight %}

We can see the cast to `struct socket*`. Finally having found the
socket we are referring to we end up calling the `bind` of the
underlying socket. as shown here.


{% highlight C %}


SYSCALL_DEFINE3(bind, int, fd, struct sockaddr __user *, umyaddr, int, addrlen)
{
...

				err = sock->ops->bind(sock,
						      (struct sockaddr *)
						      &address, addrlen);
...
}
{% endhighlight %}


Ah but then one might ask what does the ops of our AF_INET socket
which we created with `SOCK_DGRAM` point to ? I am just going to guess
the ops is `inet_dgram_ops`. Thus perhaps it will be helpful to look
at the `inet_dgram_ops`.

{% highlight C %}
const struct proto_ops inet_dgram_ops = {
	.family		   = PF_INET,
	.owner		   = THIS_MODULE,
	.release	   = inet_release,
	.bind		   = inet_bind,
	.connect	   = inet_dgram_connect,
	.socketpair	   = sock_no_socketpair,
	.accept		   = sock_no_accept,
	.getname	   = inet_getname,
	.poll		   = udp_poll,
	.ioctl		   = inet_ioctl,
	.listen		   = sock_no_listen,
	.shutdown	   = inet_shutdown,
	.setsockopt	   = sock_common_setsockopt,
	.getsockopt	   = sock_common_getsockopt,
	.sendmsg	   = inet_sendmsg,
	.recvmsg	   = inet_recvmsg,
	.mmap		   = sock_no_mmap,
	.sendpage	   = inet_sendpage,
#ifdef CONFIG_COMPAT
	.compat_setsockopt = compat_sock_common_setsockopt,
	.compat_getsockopt = compat_sock_common_getsockopt,
	.compat_ioctl	   = inet_compat_ioctl,
#endif
};
EXPORT_SYMBOL(inet_dgram_ops);
{% endhighlight %}


We see a mapping for the bind method to the generic `inet_bind`. Which
is used both by TCP and UDP. Inside `inet_bind` we see we get the
underlying `struct sock` and now using the `struct sockaddr
*uaddr`. can set it up with relevant information which will be used
later.


{% highlight C %}
int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
{
 .....
      
      	struct inet_sock *inet = inet_sk(sk);
 .....
  inet->inet_rcv_saddr = inet->inet_saddr = addr->sin_addr.s_addr;
  ...
  inet->inet_sport = htons(inet->inet_num);
}
{% endhighlight %}

# Are you listening to the words coming out of my mouth.

While it seems that the `fd` can be used by any sort of file
descriptor reader. I dont know much about it. Instead I shall look
into the `recvfrom` method. An example usage of which could be

{% highlight C %}
// Example Usage
char buffer[549];
struct sockaddr_storage src_addr;
socklen_t src_addr_len=sizeof(src_addr);
ssize_t count=recvfrom(fd,buffer,sizeof(buffer),0,(struct sockaddr*)&src_addr,&src_addr_len);
if (count==-1) {
    die("%s",strerror(errno));
} else if (count==sizeof(buffer)) {
    warn("datagram too large for buffer: truncated");
} else {
    handle_datagram(buffer,count);
}

// System call in the kernel
SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
		unsigned int, flags, struct sockaddr __user *, addr,
		int __user *, addr_len)
{
....
       	err = sock_recvmsg(sock, &msg, size, flags);
....
}

// Calling underlying socket recvmsg
static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
				       struct msghdr *msg, size_t size, int flags)
{
	struct sock_iocb *si = kiocb_to_siocb(iocb);

	si->sock = sock;
	si->scm = NULL;
	si->msg = msg;
	si->size = size;
	si->flags = flags;

	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
}
{% endhighlight %}


Now switching over to the recvmsg. We see that we can receive messages
by calling `inet_recvmsg`.

{% highlight C %}
int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
		 size_t size, int flags)
{
....
       	err = sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAIT,
			   flags & ~MSG_DONTWAIT, &addr_len);
....
}
{% endhighlight %}

Which in the end just calls the udp protocols `recvmsg` . We can see
it define all sorts of method that are common to protocols running
over IP.

{% highlight C %}
// udp.c
struct proto udp_prot = {
	.name		   = "UDP",
	.owner		   = THIS_MODULE,
	.close		   = udp_lib_close,
	.connect	   = ip4_datagram_connect,
	.disconnect	   = udp_disconnect,
	.ioctl		   = udp_ioctl,
	.destroy	   = udp_destroy_sock,
	.setsockopt	   = udp_setsockopt,
	.getsockopt	   = udp_getsockopt,
	.sendmsg	   = udp_sendmsg,
	.recvmsg	   = udp_recvmsg,
	.sendpage	   = udp_sendpage,
	.backlog_rcv	   = __udp_queue_rcv_skb,
	.release_cb	   = ip4_datagram_release_cb,
	.hash		   = udp_lib_hash,
	.unhash		   = udp_lib_unhash,
	.rehash		   = udp_v4_rehash,
	.get_port	   = udp_v4_get_port,
	.memory_allocated  = &udp_memory_allocated,
	.sysctl_mem	   = sysctl_udp_mem,
	.sysctl_wmem	   = &sysctl_udp_wmem_min,
	.sysctl_rmem	   = &sysctl_udp_rmem_min,
	.obj_size	   = sizeof(struct udp_sock),
	.slab_flags	   = SLAB_DESTROY_BY_RCU,
	.h.udp_table	   = &udp_table,
#ifdef CONFIG_COMPAT
	.compat_setsockopt = compat_udp_setsockopt,
	.compat_getsockopt = compat_udp_getsockopt,
#endif
	.clear_sk	   = sk_prot_clear_portaddr_nulls,
};
EXPORT_SYMBOL(udp_prot);

{% endhighlight %}

Thus the finally the call will find us trickling down to the
`udp_recvmsg`.

{% highlight C %}
int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
		size_t len, int noblock, int flags, int *addr_len)
{
    .....
    	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
				  &peeked, &off, &err);
    .....
}
{% endhighlight  %}

We we call here which blocks depending on the options and waits for
the the `skb` in anycase. Of course the receive method for datagram is
endlessly flexible in ways which we are currently not interested
in. But for now we see a a loop which will wait for and assemble
packets to be ready to be served to the user, working with various
timeout issues as necessary.


{% highlight C %}
struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
				    int *peeked, int *off, int *err)
{
...
	do {
        ...
        ..
        } while (!wait_for_more_packets(sk, err, &timeo, last));
....
}
{% endhighlight %}

Where `wait_for_more_packets` will optionally creates a wait queue on
which it can wait until a packet arrives

{% highlight C %}
static int wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
				 const struct sk_buff *skb)
{

	DEFINE_WAIT_FUNC(wait, receiver_wake_function);
       	prepare_to_wait_exclusive(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
        ...
        ..
       	*timeo_p = schedule_timeout(*timeo_p);
}
{% endhighlight %}

Enqueue the task to the `sk->sk_wq` (I think). periodically waking
itself up and checking the queue (I think).

On waking up we walk through the sockets `sk_receive_queue` piking up
first skb and return it

{% highlight C%}
struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
				    int *peeked, int *off, int *err)
{
        struct sk_buff_head *queue = &sk->sk_receive_queue;
         ....
 	skb_queue_walk(queue, skb) {
        {
         ....
         __skb_unlink(skb, queue);
         ....
         return skb;
        }
}
{% endhighlight %}

Now that we have gotten the `skb` from the network we need to copy it
into the msg for the user to consume. This happens in th
`skb_copy_and_csum_datagram_msg` passed in the message header. If the
message is too big it may need to be chunked `struct iov_iter *to` an
iterator of the `msg`.

{% highlight C %}
int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
				   int hlen, struct msghdr *msg)
{
...
	if (iov_iter_count(&msg->msg_iter) < chunk) {
		if (__skb_checksum_complete(skb))
			goto csum_error;
		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
			goto fault;
	}
        ....
}
{% endhighlight %}

Where `skb_copy_datagram_msg` copies as much of the data as is
required by the underlying application. Using the appropriate
`__copy_to_user` method

{% highlight C %}
__copy_to_user(v.iov_base, (from += v.iov_len) - v.iov_len,
			       v.iov_len),
{% endhighlight %}

Thus finally handing the data to user space.



### Summary

The primary reference text which contains a lot of the gory details is
the extremely detailed [_Linux Networking Internals_][lin-net] which
reads kind of like a bible. And for reference to kernel details there
is the equally detailed [__Understanding Linux Kernel__][ukl]. And
then there is always the good google search which invariable lands on
to a [__lwn__][lwn] article. As always any comments or suggestions for
improvements are always welcome. Nice tutorial on pci cards on
[__tldp__][rtl-8139].For a more sane introduction to listening to UDP
datagrams see [__UDP server__][udp-server]. Lot of the material was
discussed in a linux kernel class I am taking at UCSC whose
[__reference site__][linuxeco] probably contains more accurate
information. Clearly the most amazing thing about this is that all
this logic really does get executed many times all over the internet
and on the localhost for every packet. I guess I am writing this more
as a brain dump of reading through the source in the 3.19-rc7 kernel
networking subsystem,thus it may be **highly unreliable** and
**inaccurate**. **Users beware!** With that fair warning lets try to
begin.


---
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