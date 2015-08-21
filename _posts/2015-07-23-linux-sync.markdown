---
layout: post
title: Some notes on synchronization in the Linux Kernel (draft)
category:  linux
published: true
---

Just a small collection of notes on synchronization mechanisms in the
Kernel. The underlying reference for which is the Linux Kernel
Development book by Robert Love.

# Atomic Operations

* Indivisible operations - executed without interruption
* Keep state consistent across threads of execution
* Some architectural support
* Atomic Integer Operations
  * Use special type `atomic_t` for int
    * Prevent compiler from optimizing value
    * hide architecture specific implementation differences
    * defined in `linux/types.h`
    
    {% highlight C %}
    typedef struct {
      volatile int counter;
    } atomic_t;    
    {% endhighlight %}
    * Devlopers need to limit the usage of `atomic_t` to `24 bits` to not  break on sparc
    * on sparc lock embeded in lower 8 bits (this may no longer be relevant)
  * atomic operations in `asm/atomic.h`
  * defining atomic
  {% highlight C %}
   /* define v */
   atomic_t v;
   
   /* define u and initialize it to zero */
   atomic_t u = ATOMIC_INIT(0);
  {% endhighlight %}
  
  * Some atomic operations :
  
  {% highlight C %}
  /* v = 4 (atomically) */
  atomic_set(&v, 4);
  /* v = v + 2 = 6 (atomically) */
  atomic_add(2, &v);  
  /* v = v + 1 = 7 (atomically) */
  atomic_inc(&v);

  /* will print "7" convert atomic_t to int */
  printk(“%d\n”, atomic_read(&v));
  
  {% endhighlight %}
  
  * Using `atomic_add` , `atomic_inc` ,`atomic_dec` lighter weight
    instead of complex locking
    
  * `int atomic_dec_and_test(atomic_t *v)`
    * decrement  `v`
      * if `v` is zero returns true
      * else return false
    * List of Atomic Operations
    {% highlight C %}
    // Atomic Integer Operation Description
    //At declaration, initialize to i.
    ATOMIC_INIT(int i)
    // Atomically read the integer value of v.
    int atomic_read(atomic_t *v)
    // Atomically set v equal to i.
    void atomic_set(atomic_t *v, int i)
    
    // Atomically add i to v.
    void atomic_add(int i, atomic_t *v)
    
    // Atomically subtract i from v.
    void atomic_sub(int i, atomic_t *v)
    
    // Atomically add one to v.
    void atomic_inc(atomic_t *v)
    
    // Atomically subtract one from v.
    void atomic_dec(atomic_t *v)
    
    // Atomically subtract i from v and
    // return true if the result is zero;
    //otherwise false.
    int atomic_sub_and_test(int i, atomic_t *v)
    
    //Atomically add i to v and return
    //true if the result is negative;
    //otherwise false.
    int atomic_add_negative(int i, atomic_t *v)
    
    //Atomically add i to v and return
    //the result.
    int atomic_add_return(int i, atomic_t *v)
    
    //Atomically subtract i from v and
    //return the result.
    int atomic_sub_return(int i, atomic_t *v)
    
    //Atomically increment v by one and
    //return the result.
    int atomic_inc_return(int i, atomic_t *v)
    
    // Atomically decrement v by one and
    // return the result.
    int atomic_dec_return(int i, atomic_t *v)
    
    //Atomically decrement v by one and
    //return true if zero; false otherwise.
    int atomic_dec_and_test(atomic_t *v)

    //Atomically increment v by one and
    //return true if the result is zero;
    //false otherwise.
    int atomic_inc_and_test(atomic_t *v) 
{% endhighlight %}

# Spin Locks

# Semaphores

# Reader-Writer Semaphores

# Mutexes

# Completion Variables

# BKL: The big kernel lock

# Sequential Locks

# Preemption Disabling

# Ordering and Barriers

  
### Summary


---
