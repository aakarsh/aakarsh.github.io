---
layout: post
title: Notes on memory addressing in x86 and Linux
category:  linux
published: false
---

Here we try to collect my notes on memory addressing as and when I
understand them. 



### x86
{% highlight asm %}
{% endhighlight %}

### Summary

Addressing is a complex topic which is always tough to wrap ones head
around. The myriad of platform specific details further complicate the
matter.
  [_Linux Device Driver Third Edition_][ldd-free] by the
dynamic trio Jonathan Corbet, Alessandro Rubini, and Greg
Kroah-Hartman. Available for [free here][ldd-free] and at
[Amazon][ldd-book]. While the kernel has gone through many
modifications since 2.6.10 many parts of the book are still quite
relevant and readable. As always any comments or suggestions for
improvements are always welcome.


---
[unix-poll]: http://unixhelp.ed.ac.uk/CGI/man-cgi?poll+2
[ldd-book]: http://www.amazon.com/gp/product/0596005903/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0596005903&linkCode=as2&tag=persblog073-20
[ldd-free]: http://lwn.net/Kernel/LDD3/
[named-pipe]: http://www.linuxjournal.com/article/2156?page=0,1
[inotify]: http://man7.org/linux/man-pages/man7/inotify.7.html
