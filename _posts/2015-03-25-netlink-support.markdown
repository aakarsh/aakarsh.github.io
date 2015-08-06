---
layout: post
title: Enable Netlink Support In your Kernel Modules
category:  linux,networking,netlink,sockets
published: false
---

In this post we look at extending a kernel module to support
asynchronous communication and configuration via netlink
sockets. Though very flexible these sockets can be difficult to
configure and implement. However if done well can lot of the
complexity of the implementation to be user space. Making for a far
more configurable module.

## Creating Netlink Socket In Your Kernel Module.

To start using netlink we must first register against the netlink
subsystem letting it know how we plan to handle messages which are
going to get routed to us. Thus we can begin to start exploring
netlink through the key system call of `netlink_kernel_create`

{% highlight C %}
static inline struct sock *
netlink_kernel_create(struct net *net, int unit, struct netlink_kernel_cfg *cfg);
{% endhighlight %}

We see that this system call returns to us a pointer to a `struct sock`
that we will be working against to manage the state of our netlink
configuration. When we are done with our module we clean up the by
calling the `netlink_kernel_release` system call which will free our
resources.

Next it is instructive to look at the `struct netlink_kernel_cfg*`
structure used during the registration.

Till we decide on a subsystem name we are going to use
`NETLINK_GENERIC` for unit. I don't know if this is a good idea. ??

{% highlight C %}
/* optional Netlink kernel configuration parameters */
struct netlink_kernel_cfg {
	unsigned int	groups;
	unsigned int	flags;
	void		(*input)(struct sk_buff *skb);
	struct mutex	*cb_mutex;
	int		(*bind)(struct net *net, int group);
	void		(*unbind)(struct net *net, int group);
	bool		(*compare)(struct net *net, struct sock *sk);
};
{% endhighlight %}

We see the struct defines the interface around which we will be
configuring the socket. Most important of there are the `input` method
which gets passed the received `struct sk_buff *skb` which will be our
input handler. And the `bind` method which will allow us to do
something (TODO)??.

Before we can do this we need to use `register_pernet_subsystem` to
register our networking subsystem. This is going to allow us to be
passing it our init and exit functions. Registering our operations
into the networking subsystem. On module unload we can unregister our
networking namespace. Allowing us to do namespace clean up.

The networking subsystem will at some point in the future come back to
us and do somethingSince this more as a brain dump of reading through
the source in the 3.19-rc7 kernel networking subsystem,thus it may be
**highly unreliable** and **inaccurate**. **Users beware!, this
article is work in progress** With that fair warning lets try to
begin.


### Summary

The key [__reference text__][netfilter-modules] for this is the
wonderful guide written by Jan Engelhardt and Nicolas Bouliane. 

---
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
[sunysb]: http://www.ecsl.cs.sunysb.edu/elibrary/linux/network/net.pdf

