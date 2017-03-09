---
layout: post
title: A simple reference for common linux system monitoring commands (draft)
category:  linux
published: false
---

Linux comes with many system monitoring commands here we try create a
list of some common system monitoring commands along with useful usage
patterns. Hopefully this will be a living document where I will be
adding stuff as and when I find it.


# `top`

* Perhaps the goto command when monitoring a linux system.
* Screen devided into three parts
  * Summary Area
  * Fields/Column Headers
  * Task Area
* 

# `vmstat`

* Information about processes
  * memory, paging
  * block IO
  * traps
  * disks
  * cpu activity

* Arguments
  * `delay`
    * delay in seconds between updates
    * without delay print single report
  * `count`
    * Number of updates
  * `-f`
    * dipslay number of forsk
  * `-d`
    * display disk statistics

* Example Output
{% highlight bash %}
$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0 675428 118860   5116 230768   57   77   325   155  435  218 22  4 67  7
 0  0 675428 118948   5116 230784    0    0     0     0  440  569  5  0 94  0
{% endhighlight %}

* Output Description
  * Process Information
    * r : processes waiting to run
    * b : processes in uninterruptible sleep
  * Memory
    * swpd: the amount of virtual memory used.
    * free: the amount of idle memory.
    * buff: the amount of memory used as buffers.
    * cache: the amount of memory used as cache.
    * inact: the amount of inactive memory.  (-a option)
    * active: the amount of active memory.  (-a option)
  * Swap
    * si: Amount of memory swapped in from disk (/s).
    * so: Amount of memory swapped to disk (/s).

  * IO
    * bi: Blocks received from a block device (blocks/s).
    * bo: Blocks sent to a block device (blocks/s).
  * System
    * in: The number of interrupts per second, including the clock.
    * cs: The number of context switches per second.

  * CPU
    * These are percentages of total CPU time.
    * us: Time spent running non-kernel code.  (user time, including nice time)
    * sy: Time spent running kernel code.  (system time)
    * id: Time spent idle.  Prior to Linux 2.5.41, this includes IO-wait time.
    * wa: Time spent waiting for IO.  Prior to Linux 2.5.41, included in idle.
    * st: Time stolen from a virtual machine.  Prior to Linux 2.6.11, unknown.

{% highlight bash %}
$ vmstat 1 -d  # disk statistics

disk- ------------reads------------ ------------writes----------- -----IO------
       total merged sectors      ms  total merged sectors      ms    cur    sec
loop2      0      0       0       0      0      0       0       0      0      0
loop3      0      0       0       0      0      0       0       0      0      0
loop4      0      0       0       0      0      0       0       0      0      0
loop5      0      0       0       0      0      0       0       0      0      0
loop6      0      0       0       0      0      0       0       0      0      0
loop7      0      0       0       0      0      0       0       0      0      0
sda   1964346 662179 46556808 29505812 233161 761472 16409080 21476344      0   7385
zram0      0      0       0       0      0      0       0       0      0      0
zram1      0      0       0       0      0      0       0       0      0      0
{% endhighlight %}

* Field discription for disk mode
  * Reads :
    * total: Total reads completed successfully
    * merged: grouped writes (resulting in one I/O)
    * sectors: Sectors written successfully    
  * IO
    * cur: I/O in progress
    * s: seconds spent for I/O

# `df`

* `df [OPTION]... [FILE]...`
* Display amount of diskspace available on file system containing file name argument 
* If no file name then display all mounted file systems
* `-h` dispalys human readable sizes
* Example usage :


{% highlight bash %}
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda5        94G   88G  435M 100% /
none            4.0K     0  4.0K   0% /sys/fs/cgroup
udev            393M  4.0K  393M   1% /dev
tmpfs           100M  1.2M   99M   2% /run
none            5.0M     0  5.0M   0% /run/lock
none            496M  868K  495M   1% /run/shm
none            100M   16K  100M   1% /run/user
{% endhighlight %}

{% highlight bash %}
$ df . -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda5        94G   88G  434M 100% /
{% endhighlight %}






  
### Summary


---
