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
    // otherwise false.
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

* Implemented as inline functions & inline assembly
* word sized reads always atomic
* most architectures read/write of a single byte is atomic( no two simultaneous operations)
* read is consistent(ordered either before or after the write)
* Thus on most architectures we get

{% highlight C %}
/**
* atomic_read - read atomic variable
* @v: pointer of type atomic_t
*
* Atomically reads the value of @v.
*/
static inline int atomic_read(const atomic_t *v)
{
   return v->counter;
}
{% endhighlight %}

* Consitent atomicity does not guarantee consistent ordering (use memory barriers for enforced ordering)
* `64-bit` architectures
  * `atomic_t` size cant be different for different architectuers
    * `atomic_t` is consitently 32-bit accross architectuers
  * `atomic64_t` is used to for 64-bit atomic operations on 64 bit machines
  * nearly all atomic operations listed above implement a 64-bit version
  * all corresponding functions shown below

{% highlight C %}
typedef struct {
  volatile long counter;
} atomic64_t;
ATOMIC64_INIT(long i)
long atomic64_read(atomic64_t *v)
void atomic64_set(atomic64_t *v, int i)
void atomic64_add(int i, atomic64_t *v)
void atomic64_sub(int i, atomic64_t *v)
void atomic64_inc(atomic64_t *v)
void atomic64_dec(atomic64_t *v)
int atomic64_sub_and_test(int i, atomic64_t *v)
int atomic64_add_negative(int i, atomic64_t *v)
long atomic64_add_return(int i, atomic64_t *v)
long atomic64_sub_return(int i, atomic64_t *v)
long atomic64_inc_return(int i, atomic64_t *v)
long atomic64_dec_return(int i, atomic64_t *v)
int atomic64_dec_and_test(atomic64_t *v)
int atomic64_inc_and_test(atomic64_t *v)
{% endhighlight %}

* Atomic Bit Operations
  * architecture specific code
  * `asm/bitops.h` for details
  * operate on generic pointers
  * on `32-bit machines`
    * bit `31` most significant bit
    * bit `0` least significant bit
  * Non-atomic versions of bit operations provided but their name prefixed with `__`
    * `test_bit()` atomic version , `__test_bit()` non-atomic version
    * when dont need locking use non-atomic versions for performance
    
{% highlight C %}

/**
 * Atomically set the nr -th bit starting from addr.
 */
void set_bit(int nr, void *addr)

/**
 * Atomically clear the nr -th bit starting from addr.
 */
void clear_bit(int nr, void *addr)

/**
 * Atomically flip the value of the nr -th bit starting from addr.
 */
void change_bit(int nr, void *addr)

/**
 * Atomically set the nr -th bit starting from addr and return the previous value.
 */
int test_and_set_bit(int nr, void *addr)

/**
 * Atomically clear the nr -th bit starting from addr and return the
 * previous value.
 */
int test_and_clear_bit(int nr, void *addr)

/**
 * Atomically flip the nr -th bit starting from addr and return the
 * previous value.
 */
int test_and_change_bit(int nr, void *addr)

/**
 * Atomically return the value of the nr -
 * th bit starting from addr.
 */ 
int test_bit(int nr, void *addr)

{% endhighlight %}

* See example usage setting and clearing bits atomically

{% highlight C %}

unsigned long word = 0;
/* bit zero is now set (atomically) */
set_bit(0, &word);

/* bit one is now set (atomically) */
set_bit(1, &word);

/* will print “3” */
printk(“%ul\n”, word);
/* bit one is now unset (atomically) */
clear_bit(1, &word);
/*bit zero is flipped; now it is unset (atomically) */
change_bit(0, &word);

/* atomically sets bit zero and returns the previous value (zero) */
if (test_and_set_bit(0, &word)) {
/* never true ... */
}

/* the following is legal; you can mix atomic bit instructions with normal C */
word = 7;
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
