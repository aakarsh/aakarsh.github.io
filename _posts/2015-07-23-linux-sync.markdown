---
layout: post
title: Some notes on synchronization in the Linux Kernel 
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

* Allow for creation of critical regions in code
* spinlock can be held by at most one thread at a time
* contending threads busy loop waiting for the lock to unlock
* if lock is uncontended acquire lock and proceed instantly
* busy loop will `"waste"` processor time
* thus must minmize length of time spinlock is held
* advantage that doesnt result in context switches
* can be used in contexts which do not support blocking (interrupt context) or (preemption disabled?)
* Spin Lock Methods
  * Defined in `linux/spinlock.h`
  {% highlight C %}  
  DEFINE_SPINLOCK(my_lock);
  // acquire the spin lock
  spin_lock(&my_lock);
  ... place critical region here ..
  //release the spin lock
  spin_unlock(&my_lock);
  {% endhighlight %}

  * On uniprocessor system spinlocks compile away
    * "some people" say they have some side effects, and spinlocs are not noops
    * need to verify
    * act as markers to enable disable kernel preemption
  * Spinlocks are not recursive
    * trying to acquire the same lock again will hang the thread of execution
    
 * Using spinlock in interrupt context - need to disable `local interrupts` on this processor
   * if preemption not disabled may deadlock on the lock this processor already holds
   * Thus need to use methods to which will disable interrupts
 * `spin_lock_irqsave`
   * save the current state of interrupts
   * disables interrupts locally
   * obtain the spinlock
 * `spin_unlock_irqrestore`
   * unlock the given lock
   * returns interrupts to `previous state`
     * This is *key* , if the interrupts were disabled on entry then we need should keep them disabled
     * allows nesting of different spinlocks and interrupt disabling clode
 * Locks should be associated with data structures which they lock
 * make association of lock with data clearer by naming conventions


{% highlight C %}
DEFINE_SPINLOCK(my_lock);

unsigned long flags;

spin_lock_irqsave(&my_lock, flags);

/* critical region ... */

spin_unlock_irqrestore(&my_lock, flags);

{% endhighlight %}


* Kernel Configs to help Spin Lock Debugging
  * `CONFIG_DEBUG_SPINLOCK`
    * using uninitialized spinlock detection
    * unlocking a lock which was never locked
  * `CONFIG_DEBUG_LOCK_ALLOC`
    * debugging lock lifecycles?

* Dynamic Allocation of Spinlock
  * `spin_lock_init()` initialize dynamically created spinlock, ie with a pointer
  * `spin_trylock()` - try to obtain lock, if fail return 0, if succed return non-zero

{% highlight C %}
/* Acquires given lock*/
spin_lock()

/** Disables local interrupts and acquires given lock */
spin_lock_irq()

/** Saves current state of local interrupts, disables local inter-
/  rupts, and acquires given lock */
spin_lock_irqsave()

/** Releases given lock */
spin_unlock()

/** Releases given lock and enables local interrupts */
spin_unlock_irq()

/** Releases given lock and restores local interrupts to given pre-
vious state */
spin_unlock_irqrestore()

/** Dynamically initializes given spinlock_t */
spin_lock_init()

/** Tries to acquire given lock; if unavailable, returns nonzero */
spin_trylock()

/** Returns nonzero if the given lock is currently acquired, other-
wise it returns zero */
spin_is_locked()

{% endhighlight %}

* Spin Locks and Bottom Halfs
  * Bottom halfs preempt process contexts
  * two tasklets of same type don't run concurrently
  * tasklet never preempts another tasklet on same processor
  * interrupt context can preempt bottom halfs and process contexts
  * Process context should disable bottom half preemption over contended locks

* Reader-Writer Spin Locks
  * Dealing with the asymmetrical nature of reading and writing.
  * Writing demands mutal exclusion
    * no reading permitted
    * no writing permitted
  * Reading requires - write exclusion
    * no writers permitted
    * multiple readers ok
    
  * Reader-Writer spinlocks increase throughput by allowing multiple readers
  * Provide separate variants of read and write locks
  * one or more readers can hold read locks
  * only one writer and no one readers or writers can hold write lock
  * alternative terminology: (reader,writer) ,(shared/exlusive) , (concurrent/exclusive)

{% highlight C %}
DEFINE_RWLOCK(mr_rwlock);

// Attain read lock
read_lock(&mr_rwlock);
/* critical section (read only) ... */
read_unlock(&mr_rwlock);

// Attain write lock
write_lock(&mr_rwlock);
/* critical section (read and write) ... */
write_unlock(&mr_rwlock);
{% endhighlight %}


  * read locks cant later be transformed to write locks without first
    releasing the read lock and then asking for a write lock
    {% highlight C %}
    read_lock(&mr_rwlock);
    
    // Dead locks will never get a write lock since the read lock will
    // never get released
    
    write_lock(&mr_rwlock); 
    {% endhighlight %}
    
  * reader locks are recursive, same thread can re-obtain same
    reader locks without deadlock
    
  * Thus if only readers in interrupt handlers no need to disable
    interrupts.
      * use `read_lock()` instead of `read_lock_irqsave()`
      
      * Must use `write_lock_irqsave()` in interrupts
      
{% highlight C %}
// Acquires given lock for reading
 read_lock()

// Disables local interrupts and acquires given lock for reading
 read_lock_irq()

/**
 * Saves the current state of local interrupts, disables local in-
 * terrupts, and acquires the given lock for reading
 */
 read_lock_irqsave()

// Releases given lock for reading
 read_unlock()

// Releases given lock and enables local interrupts
 read_unlock_irq()

/**
 * Releases given lock and restores local interrupts to the
 * given previous state
 */
 read_unlock_ irqrestore()

//Acquires given lock for writing
 write_lock()

/**
 * Disables local interrupts and acquires the given lock for
 * writing
 */
 write_lock_irq()

/**
 * Saves current state of local interrupts, disables local inter-
 * rupts, and acquires the given lock for writing
 */
 write_lock_irqsave()

//Releases given lock
  write_unlock()

//Releases given lock and enables local interrupts
  write_unlock_irq()

/**
 * Releases given lock and restores local interrupts to given
 * previous state
 */
 write_unlock_irqrestore()

/**
 * Tries to acquire given lock for writing; if unavailable, returns
 * nonzero
 */
 write_trylock()

//Initializes given rwlock_t
rwlock_init()

{% endhighlight %}

   * Need to think of appropriate priority for writers. Else lots of
     readers may starve writer.
     
   * Spinlocks are on small timescales (nanosceconds?) For larger
     timescales blocking semaphores are advisable instead.
   
# Semaphores

  * For larger timescales where putting process context to sleep is
    advisable (ms) scale
    
  * Sets processor free to execute other code.

  * Should only be obtained in `process context` *cannot* be used in
    `interrupt context`, `interrupt context` is not schedulable.

  * Cannot hold a `spinlock` while acquiring a semaphore. Since you
    may sleep and cause a deadlock on the `spinlock` (how is this
    enforced?)

  * Semaphores don't disable kernel preemption, don't hurt affect
    scheduling latency as much as spinlocks

  * Counting vs Binary Semaphores
  
    * Unlike spinlocks allow *arbitrary number* of *simultaneous* lock
      holders
      
    * `usage count` or `count`  - number of permisable  *simultaneous* lock holders
    
    * Binary semaphore/mutex - enforces mutual exclusion - `usage
      count` is *one*
         
    * Counting semaphore - `usage count` greater than one

    * While `count` is greater than `zero` acquiring semaphore
      succeeds.

    * `asm/semaphore.h`
    
    * `struct semaphore` key structure
    
    {% highlight C %}
    struct semaphore name;
    sema_init(&name, count);
    // or alternatively for delcaring and inializing a staitc mutex
    static DECLARE_MUTEX(name);
    {% endhighlight %}
    
    * `init_MUTEX(sem)` - initialize a dynamically created semaphore
    * To try acquire use `down_*` methods.
    * To release use `up_*` methods
    * `down_interruptible()`
      * one failure to acquire lock puts calling process in
        `TASK_INTERRUPTIBLE` and sleep
      * If `process` receives a `signal` then wake up and fail by
        returning `-EINTR`
        
    * `down()`
      * place task in `TASK_UNINTERRUPTIBLE`, then sleep
      * process will not respond to signals

    * prefer `down_interruptible()` over `down()`
    
    * `down_trylock()`
      * acquire semaphore without blocking
      * if lock held return non-zero
      
   {% highlight  C %}
   /* define and declare a semaphore, named mr_sem, with a count of one */
   static DECLARE_MUTEX(mr_sem);
   /* attempt to acquire the semaphore ... */
   if (down_interruptible(&mr_sem)) {
   /* signal received, semaphore not acquired ... */
   }
   /* critical region ... */
   /* release the given semaphore */
   up(&mr_sem);
   {% endhighlight %}

   * Semaphore Methods

{% highlight C %}
/**
 * Initializes the dynamically created semaphore
 * to the given count
 */
sema_init(struct semaphore *, int)

/**
 * Initializes the dynamically created semaphore
 * with a count of one
 */
init_MUTEX(struct semaphore *)

/**
 * Initializes the dynamically created semaphore
 * with a count of zero (so it is initially locked)
 */
init_MUTEX_LOCKED(struct semaphore *)

/**
 * Tries to acquire the given semaphore and
 * enter interruptible sleep if it is contended
 */
down_interruptible (struct semaphore *)

/**
 * Tries to acquire the given semaphore and
 * enter uninterruptible sleep if it is contended
 */
down(struct semaphore *)

/**
 * Tries to acquire the given semaphore and
 * immediately return nonzero if it is contended
 */
down_trylock(struct semaphore *)

/**
 * Releases the given semaphore and wakes a
 * waiting task, if any
 */
up(struct semaphore *)

{% endhighlight %}

# Reader-Writer Semaphores

* Similar to `reader-writer` spinlocks
* `linux/rwsem.h`
* Static Creation
  * `static DECLARE_RWSEM(name);`
* Dynamic Creation
  * `init_rwsem(struct rw_semaphore *sem)`
  
* Define mutual exclusion on writers with usage `count` 1
* Allow simultaneous reads
* All readers and writers use uninterruptible sleep

{% highlight C %}

// statically declare  a read only semaphore
static DECLARE_RWSEM(mr_rwsem);

/* attempt to acquire the semaphore for reading ... */
down_read(&mr_rwsem);

/* critical region (read only) ... */
/* release the semaphore */
up_read(&mr_rwsem);

/* attempt to acquire the semaphore for writing ... */
down_write(&mr_rwsem);
/* critical region (read and write) ... */
/* release the semaphore */
up_write(&mr_sem);

{% endhighlight %}

* For non-blocking lock-acquisition use `down_read_trylock()` and
  `down_write_trylock()`
  * return non-zero if lock *can* be acquired
  * return zero if lock *cannot* bet acquired

* `downgrade_write()` converts a `write` lock to a read lock

# Mutexes

* `struct mutex`
*  used to simplify common use case of semaphores
* Static Definition
  * `DEFINE_MUTEX(name)`
* Dynamic Definition
  * `mutex_init(&mutex)`
* Locking and Unlocking Mutex

  {% highlight C %}
  mutex_lock(&mutex);
  /* critical region ... */
  mutex_unlock(&mutex);
  {% endhighlight %}
  
* Does not require usage counts

{% highlight C %}
/**
 * Locks the given mutex; sleeps if the lock is
 * unavailable
 */
mutex_lock(struct mutex *)

/**
 * Unlocks the given mutex
 */
mutex_unlock(struct mutex *)

/**
 * Tries to acquire the given mutex; returns one if suc-
 * cessful and the lock is acquired and zero otherwise
 */
mutex_trylock(struct mutex *)

/**
 * Returns one if the lock is locked and zero otherwise
 */
mutex_is_locked (struct mutex *)
{% endhighlight %}

 * Constrains Imposed on mutex usage
   * usage count is always `one`
   * single task holds mutex
   * only original locker allowed to unlock mutex
   * recursive locks and unlocks are not allowed.
   * process cannot exit while holding a mutex
   * a mutex cannot be acquired by an interrupt handler or bottom half
   * Constraints checked via `CONFIG_DEBUG_MUTEXES`

 * Usage guidelines
   * start with mutex use semaphore if constriants not statisfiable

* When to use Spinlocks vs (Semaphore , Mutex) ?

{% highlight C %}
| Low overhead                        | Spin lock              |
| Short lock hold time                | Spin lock              |
| Long lock hold time                 | Mutex is preferred.    |
| Need to lock from interrupt context | Spin lock is required. |
| Need to sleep while holding lock    | Mutex is required.     |
{% endhighlight %}


# Completion Variables

* Event signalling between tasks
* One task waits for signal, other task signals on completion
* On completion wake up all sleeping tasks
* Ex. Completion Variable, wake up parent when child exits
  * * See `kernel/sched.c` and `kernel/fork.c`
* Static
  * `DECLARE_COMPLETION(mr_comp);`
* Dynamic
  * `init_completion()`
* To wait for completion call `wait_for_completion`
* To signal completion call `complete`

{% highlight C %}
/**
 * Initializes the given dynamically created
 * completion variable
 */

init_completion(struct completion *)

/**
 * Waits for the given completion variable
 * to be signaled
 */
wait_for_completion(struct completion *)
/**
 * Signals any waiting tasks to wake up
 */
complete(struct completion *)

{% endhighlight %}

# BKL: The big kernel lock

* Spinlock used to ease transition to SMP
* *global spinlock*
* Lock dropped on sleep
* Is a recursive lock: same process multiple acquisition allowed
* Forbidden new users
* Transition away from it
* `lock_kernel` acquires lock
* `unclock_kernel` releases recursively
* `kernel_locked` returns 
  * `0` - lock already held
  * `non-zero` -lock not being held
* `linux/smp_lock.h`
* problem with single lock - difficult to determine which two parties
actually need to syncrhonize with each other # Sequential Locks

# Sequential Locking

* Simple mechanism reading/writing shared data
* maintains a sequence counter
* when sequence counter is odd a write is taking palce
* check sequence counter is even prior to and after read to be sure no
  write was underway

{% highlight C %}
// define a seq lock
seqlock_t mr_seq_lock = DEFINE_SEQLOCK(mr_seq_lock);

// Create a write lock region
write_seqlock(&mr_seq_lock);
/* write lock is obtained... */
write_sequnlock(&mr_seq_lock);

// Read  path
unsigned long seq;
do {
  seq = read_seqbegin(&mr_seq_lock);
  /* read data here ... */
} while (read_seqretry(&mr_seq_lock, seq));
{% endhighlight %}

* Write lock always succeeds as long as no writers
* Favor writers over readers

* Ideal cases
  * Many of readers
  * Few writers
  * readers never starve writers
  * simple data


  
* Ex : `seq_lock` on `jiffies`

{% highlight C %}
u64 get_jiffies_64(void)
{
    unsigned long seq;
    u64 ret;
    do {
       seq = read_seqbegin(&xtime_lock);
       ret = jiffies_64;
    } while (read_seqretry(&xtime_lock, seq)); // if unsuccesful read tries again
    return ret;
}
{% endhighlight %}

{% highlight C %}
// update jiffies in timer interrupt
write_seqlock(&xtime_lock);
jiffies_64 += 1;
write_sequnlock(&xtime_lock);
{% endhighlight %}


# Preemption Disabling

* kernel is preemptive
* spin locks disable premption for duration held
* during modification of per-processor data disable preemption to
  prevent corrupting in flight data
* `preempt_disable` and `preempt_enable` can be nested
* methods maintain counts of the number of times preeption is enabled
  or disabled.
* If count is `0` kernel is preemptive


{% highlight C %}
/**
 * Disables kernel preemption by incrementing the preemp-
 * tion counter
 */
preempt_disable()

/**
 * Decrements the preemption counter and checks and serv-
 * ices any pending reschedules if the count is now zero
 */
preempt_enable()

/**
 * Enables kernel preemption but does not check for any
 * pending reschedules
 */
preempt_enable_no_resched()

/* Returns the preemption count*/
preempt_count() 
{% endhighlight %}

* Alternatively calling `get_cpu()` to obtain an index into
  perprocessor data will disable kernel preemption.
  
* `put_cpu()` will reenable kernel preemption


# Ordering and Barriers

* Ensuring ordering of memory loads and stores
* Compiler and Processors like to reorder loads and stores
* Barriers prevent compiler and processor from reordering instructions
* `x86` does not do out of order stores
* Other processors might do out of order stores
* Reorderings can have dependencies :
{% highlight C %}
a = 1
b = a
{% endhighlight %}
  * data dependency between b and a
  
* static reordering :  compiler
  * Reflected in object code
* dynamic reordering: processor

* `rmb()`
  * a read memory barrier
  * loads before the `rmb()` will *never* be reordered to loads
    *after* the call
  * `read_barrier_depends()`
    * read barrier for loads
    * only for loads where the subsequent load depends on previous load
    * much quicker on some architectures
    * on some architectures transforms to `noop`
    
* `wmb()`
  * write barrier
  * stores before the `wmb()` will *never* be reordered with stores
    *after* the call
  * `x86` does not reorder stores
  
* `mb()`
  * read/write barrier
  * (loads and stores) before the `wmb()` will *never* be reordered
    with (loads and stores) *after* the call

* `smp_rmb` , `smp_wmb` and `smp_read_barrier_depends`
  * turn memory barrier to compiler barrier on smp
  * compiler barrires are nearly free - only preventing static rearrangement
  

 
### Summary

---
