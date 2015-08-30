---
layout: post
title: Advanded File I/O Linux(draft)
category:  linux
published: true
---

Just a small collection of notes based on the Linux Systems
Programming book by Robert Love.



* Scatter Gather I/O
  * Allow single system call to read/write data to many buffers
  * Allow single transaction
  * Advantages
    * more natural handling of segmeted data
    * single vectored io replace multiple read and writes
    * more performant implementation
    * *atomicity*
      * no risk of interleaving read and write with another process
    
    
  * `readv()` and `writev()`
    * `#include <sys/uio.h>`
    * Each `struct iovcnt` represents buffer to reand or write from
    
    {% highlight C %}
    
    {% endhighlight %}
    * `ssize_t readv(int fd, const struct iovec *iov, int iovcnt);`
    * `ssize_t writev(int fd, const struct iovec *iov, int iovcnt);`



* Evant Poll Interface
  * Some Improvements on `poll()` and `select()` interface


* Mapping Files to Memory

* I/O Schedulers and I/O Performance
---
