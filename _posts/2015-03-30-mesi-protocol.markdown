---
layout: post
title: Understanding the MESI Protol
category:  linux,cache coherency,x86
published: false
---

#### Disclaimer :

# MESI Protocol

The MESI protocol is a protocol used to implement cache and memory
coherency amongst multiple CPU.

To each cache line we add two additional bits to represent the four
states of the cache. These are

## Modified


* Cache Line is present only in current CPU.
* Cache Line has been modified
* Write back needs to be performed

CPU has modified the cache, but this change has not be written through
to the main memory. Thus at future time its the cache's responsibility
to write the data back to main memory.

Any reads performed on main memory by another processor is going to
see outdated/older state at that address.

Write back will change the cache line state to exlusive.

## Exclusive

* Cache Line is present only in current CPU
* Cache line is clean (matches main memory)
* No writeback necessary.

If another CPU reads the address from main memory this cache line's
state bits need to be shared to shared.

## Shared

* Cache Line in multiple CPUs
* Cache Line is clean (matches main memory)

May change to invalid at any time.

## Invalid

Indicate cache line is not to be used, contains obsolete data.

The goal of the overall system is to minimize the use of shared
memory.

## Operation of MESI

Read can be performed from all states except invalid state.

Write can be perfoed only if cache line is Modified or Exclusive
state.  Write on shared state must invalidate all other cached
copies.Performed via a RFO (Request for Ownership) request.

Non-Modified lines discardable, change to invalid state. Modified line
requires write-back before discarding.

Mondified lines *snoop* all reads in system to cached memory location.
Sending a retry later, and write data to main memory. Chaning the
cache line state to shared state.

In Shared state we need to listen to RFO and discard lines.

In Exclusive state we must snoop on all read transactions and move to
shared state on match.

Modified and Exclusive states are precise match true ownership situation

Shared state are imprecise ??


## Memory Barriers









### Summary

The key [__reference text__][netfilter-modules] for this is the
wonderful guide written by Jan Engelhardt and Nicolas Bouliane. 

---
[wikipedia-MESI]: http://en.wikipedia.org/wiki/MESI_protocol
[auckland-MESI]: https://www.cs.auckland.ac.nz/~jmor159/363/html/cache_coh.html

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

