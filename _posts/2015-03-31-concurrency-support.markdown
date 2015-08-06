---
layout: post
title: Efforts to understand concurrency support in the kernel
category:  linux,concurrency,x86
published: false
---

In this post we try to collect notes on concurrency support in the
linux kernel along with some architectural support provided by the x86
processor. These are meant to serve as personal notes as a result I
would recommend that care be taken in fully depending on them. For the
gory detail its helpful to consult the [__Intel Software Development
Manual__][intel-manual].


### Performance Optimization Tricks and Coherency



## Memory Barriers

#### Why ?

#### Types of Memory Barriers

#### Write (Store) memory barrier

#### Read (Load) memory barrier

#### General Memory Barrier

#### Data Dependency Barriers

### MESI Protocol

#### Implicit Barriers

##### Lock operations

##### Unlock operations

### Inter-processor communication on SMP systers




### Summary

The key [__reference text__][netfilter-modules] for this is the
wonderful guide written by Jan Engelhardt and Nicolas Bouliane. 

---
[wiki-memory-barrier]: http://en.wikipedia.org/wiki/Memory_barrier
[volatile-harmful]:https://www.kernel.org/doc/Documentation/volatile-considered-harmful.txt
[intel-manual]: http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developers-manual.pdf
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

