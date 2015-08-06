---
layout: post
title: Linux System Calls - Using and Implementing Poll
category:  linux
published: true
---

Here we try to describe the linux post system call from both the
client and the device driver perspective. Implementing post system
call can serve as a useful excercise in clarifying lots of
introductory device driver and systems programming concepts.



### Client side poll 

At a basic level the poll system call allows you to wait on several
file descriptors for data to become available allowing you perform
non-blocking I/O operations on the active file descriptors. As the
client for poll one you need to invoke the following system call.

{% highlight C %}
#include <poll.h>

/**
 * fds - the set of file descriptors to be monitored.
 * nfds - size of the set
 * timeout - in milliseconds specified how long to block waiting for
 * data to become available in any one one of the available
 * descriptors
 */
int poll(struct pollfd *fds, nfds_t nfds, int timeout);
{% endhighlight %}

The argument the set of file descriptors to be monitored is specified
using the an array of structures of the following form.

{% highlight C %}
struct pollfd {
    int   fd;         /* file descriptor */
    short events;     /* requested events */
    short revents;    /* returned events */
};
{% endhighlight %}

The *events* field is a bit mask of requested events that the
application program is interested in. While the *revents* is a an output
parameter filled in by the kernel.

The bits in the events can use predefined definitions in
**<poll.h>**. Some commonly used definitions are as follows:

{% highlight C %}
Bit Field   | Description   
------------|---------------
POLLIN      | There is data to read.  
POLLOUT     | Writing now will not block.  
POLLERR     | Error condition (output only).  
POLLHUP     | Hang up (output only).  
POLLNVAL    | Invalid request: fd  not  open  (output only).  
{% endhighlight %}

Upon success the poll system call will return the number of structures
which have non-zero *revents*. A value of *0* simply indicates that
*timeout* was reached with no file descriptor ready. A value *-1*
indicates that an *errono* was set for us.

 
### Example usage of poll

One of the commonly cited reasons for using poll is the example of a
server which needs to serve multiple clients when data becomes
available. For our somewhat contrived example however we will use
named pipes as a way to exercises our client. For a more detailed
account on named pipes see [here][named-pipe]

We can create a named pipe and write to it with the following commands: 
{% highlight bash%}
 $ mkfifo np
 $ tail -f /var/log/messages > np &
 
 $ mkfifo np2
 $ tail -f /var/log/wpa_supplicant.log > np2 &
 
{%endhighlight %}

Thus the output of tail shall becomes available to be read from at the
read end of the named pipe *np*. 

We can test then by it out

{% highlight bash %}
$ cat np
... output of tail should show up here...
{% endhighlight %}

Finally we can write a client with now given multiple file names can
poll them for output as and when data becomes available.

{% highlight bash%}
  $ ufollow np np2

 Some output read freom np
  ~~~~~~~~~ Last read  bytes from [np] ~~~~~~~~~
 Some ouput read from np2 
  ~~~~~~~~~ Last read bytes from [np2] ~~~~~~~~~
  
  ... interlace outputing from which ever descriptor has data
  available to be read.
  
{% endhighlight %}

Here ufollow is a client program which uses *poll* system call to open
check the file descriptors corresponding to the file names to read data
as and when it becomes available.

{% highlight C%}
   // main loop in ufollow.c
	while(1) {
    
		// wait infinitely for data on file descriptors
		// This only works for character devices,named pipes and sockets 
		// For regular files we need to do use the inotify interface.
		int retval = poll(poll_fds, nfiles,-1);
        
		if(retval == -1 ){
			perror("poll");
            break;
		}        

		for(i = 0; i < nfiles; i++) {
            if(poll_fds[i].revents & POLLIN) {
				print_data(files[i].name,files[i].fd,&config);
            }
            poll_fds[i].revents = 0;
		}
	}
{%endhighlight %}

One wrinkle in all of this is that *poll* system call always returns
success for regular files. Although i am yet to try it
[*inotify*][inotify] can be used to convert regular file descriptors
into file descriptors which will work with the *poll* system
call. Allowing us to preserve the regularity of the the poll
interface.


### Driver side view of Blocking I/O and  wait queues.




### Driver side implementation of poll system call.

Typically a users request for a poll an a file descriptor is going to
get translated into a call into the appropriate driver associated with
that file descriptor. Imagine for instance a simple device file
occurring in */dev* directory on the linux file system. Typically such
device file *inodes* are associated with a major number and minor
number as seen in from the following invocation of the *ls* command.

{% highlight bash %}
$ ls -al /dev | grep  '1,'

crw-rw-rw-.  1 root root      1,   7 Aug 11 15:40 full
crw-r--r--.  1 root root      1,  11 Aug 11 15:40 kmsg
crw-r-----.  1 root kmem      1,   1 Aug 11 15:40 mem
crw-rw-rw-.  1 root root      1,   3 Aug 11 15:40 null
crw-------.  1 root root      1,  12 Aug 11 15:40 oldmem
{% endhighlight %}

Here we see that **/dev/null** device is associated with the major
number *1* and the minor number *3*. We also notice that that this is
the same driver that is used to read and write the memory directly(as
witnessed by the shared major number of *1*). The 'c' at the beginning
specifies that the underlying device files are character devices.

Assuming thus that we have created and associated our driver with a
major number and minor number appropriately (See [LDD3][ldd-free]) for
details. We now get to the linux kernels internal architecture for
simplifying the implementation of the poll system call.

Drivers intending to support the poll system call must start by first
implementing 

{% highlight C%}
unsigned int (*poll) (struct file *filp, poll_table *wait);
{% endhighlight %}

{% highlight C %}
void poll_wait (struct file *, wait_queue_head_t *, poll_table *);
{% endhighlight %}


### Summary

The primary reference text that I have been using which is
tremendously helpful in understanding the implementation of the poll
and select interface is the
[_Linux Device Driver Third Edition_][ldd-free] by the dynamic trio
Jonathan Corbet, Alessandro Rubini, and Greg Kroah-Hartman. Available
for [free here][ldd-free] and at [Amazon][ldd-book]. While the kernel
has gone through many modifications since 2.6.10 many parts of the
book are still quite relevant and readable. As always any comments or
suggestions for improvements are always welcome.


---
[unix-poll]: http://unixhelp.ed.ac.uk/CGI/man-cgi?poll+2
[ldd-book]: http://www.amazon.com/gp/product/0596005903/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0596005903&linkCode=as2&tag=persblog073-20
[ldd-free]: http://lwn.net/Kernel/LDD3/
[named-pipe]: http://www.linuxjournal.com/article/2156?page=0,1
[inotify]: http://man7.org/linux/man-pages/man7/inotify.7.html
