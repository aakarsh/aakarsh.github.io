---
layout: post
title: Programming Language Reference - Java (draft)
category:  java
published: true
---

This is a series in which we look and create reference sheets for
various programming languages. The proliferation of programming
languages means that one is often called upon to be able to translate
ideas into various concrete languages each with their benefits and
drawbacks. This sheet has been created using The Java Programming
Language Book by James Gosling and Ken Arnold. Which seems to be one
of the better books for clarifying the language's ideas. This post is
more of a reference rather than any kind of exposition of the ideas.

### Ch  3: Extending Classes

### Ch 11: Generic Types
#### Generic Type Declarations
#### Working with Generic Types
#### Generic Methods and Constructors
#### Wildcard Captures
#### Type erasure and raw types
#### Class Extension and Generic Types

### Ch 12: Exceptions

### Ch 14: Threads

#### Creating Threads
#### Using Runnable
#### Synchronization
#### `wait`,`notifyAll`, `notify`
#### Details of waiting and notification
#### Thread Scheduling
#### Deadlocks
#### Ending Thread Execution
#### Ending Application Execution
#### The Memory Model
#### Threads and Exception
#### ThreadLocal Variables
#### Debugging Threads

### Ch 20: I/O Packages

#### Streams Overview
#### Byte Streams
#### Character Streams
#### `InputStreamReader` and `OutputStreamWriter`
#### Stream Classes
#### Working with files
#### Object Serialization
#### IO Exception Classes
#### New I/O Classes

### Ch 21: Collections

* Classes present in the `java.util` package.

#### Collections

* Core Interfaces

  * `Collection<E>` : root interface
    * `add`
    * `size`
    * `toArray`

  * `Set<E>` : Collection without duplicate elements
  * `SortedSet<E>`: Sorted , Non-Duplicate
  * `List<E>` : Ordered collection
  * `Queue<E>` : Ordering with implied head
    * peek
    * poll

  * `Map<K,V>` : Map key to single value
  * `SortedMap<K,V>` : Map sorted by keys.
  * `Iterator<E>` : 
    * returned by `Iterable.iterator`
  * `ListIterator<E>` :  
    * `List` methods
    * returned by : `List.listIterator`

  * `Iterable<E>` 
    * Object providing `Iterator<E>` via `iterator`

* Concrete Implementations
  * `HashSet<E>` : Set implemented as hash table
  * `TreeSet<E>` : `SortedSet` implemented as balanced binary tree
    * Can be slower to search/modify than `HashSet`
    * Keeps elements sorted
  * `ArrayList<E>` : `List` as re-sizable array
    * fast random access
    * expensive to add/remove at beginning
  * `LinkedList<E>`: `List`,`Queue` as linked list
    * cheap add/remove
    * slow random access
  * `HashMap<K,V>` : hash table implementation of `Map<K,V>`
    * cheap lookup
    * cheap insertion
  * `TreeMap<K,V>` : `SortedMap<K,V>` Implemented as balanced binary tree
    * moderately quick lookup
    * ordered data structure
  * `WeakHashMap<K,V>` : Uses weak references to store objects, referenced objects maybe garbage collectedx
    * Useful for caching

* All are `Cloneable` and `Serializable` :
  * WeakHashMap<K,V> not (`Cloneable` , `Serializable`)
  * PriorityQueue<E> not (`Cloneable`)


##### Class Hierarchy 

* `Iterable<E>`
  * `Collection<E>`
    * `Set<E>`
      * `SortedSet<E>`
        * `(C) TreeSet<E>`         
      * `EnumSet<E>`
      * `(C) HashSet<E>`
        * `(C) LinkedHashSet<E>`
    * `Queue<E>`
      * `(C)PriorityQueue<E>`
      * `(C)LinkedList<E>`      
    * `List<E>`
      * `LinkedList<E>`
      * `ArrayList<E>`
* `Iterator<E>`
  * `ListIterator<E>`

* `Map<K,V>`
  * `SortedMap<K,V>`
    * `(C)TreeMap<K,V>`
  * `(C) HashMap<K,V>`
    * `(C) LinkedHashMap<K,V>`
  * `(C) WeakHashMap<K,V>`
  * `(C) EnumMap<K,V>`

##### Exception Conventions
* `UnsupportedOperationException` avoid giving full interface implementation
* `ClassCastException` lookup and addition methods
* `IllegalArgumentException` 
* `NoSuchElementException` from empty collections
* `NullPointerException` if argument passed in is null


#### Iteration

* Key methods in `Iterator<E>`
  * `public boolean hasNext()`
  * `public E next()`
    * `NoSuchElementException` on empty collections
  * `public void remove()`
    * remove element returned by `next` call
    * `IllegalStateException` remove before `next`

{% highlight Java %}
while(it.hasNext()) {
  String str = it.next();
  if(str.contains("foo")) {
    it.remove();
  }
}
{% endhighlight %}

* Enhanced for loop cant be used remove during iteration
* Removing during iteration any other way is unsafe.
* No snapshot guarantees to prevent multiple deletions
* `ConcurrentModificationException` detect modification of underlying collection outside current iterator

* `ListIterator<E>` provide `hasPrevious` `previous` in addition to `hasNext` and `next`
   * Start position provided at creation
   * `public void remove()` removes last returned value
   * `public void set(E elem)` replace last returned
     * `IllegalStateException` if no previous `previous` or `next` call
   * `public void add(E elem)`
     * place elem in front of element to be retuned by call to `next()`
     * call `previous` returns just added 

{% highlight Java %}
ListIterator<String> it = list.listIterator(list.size());
while(it.hasPrevious()){
  String s = it.previous();
  ...
}
{% endhighlight Java %}

#### Ordering with Comparable and Comparator

* `java.lang.Comparable<T>` - interface for comparable objects, implemented by object itself
  * `public int compareTo(T other)` like `this - obj `
    * `n < 0` `this` is `less` than other
    * `n == 0` `this` is `equal` to other
    * `n > 0` `this` is `greater` than other
  * Defines `total ordering`
* `java.lang.Comparator<T>` -
  * `public int compare(T o1, T o2)`

* Used as input to `Collections`  `sort` and `binarySearch`
* Example `String.CASE_INSENSITIVE_ORDER` comparator

#### The Collection Interface

* Core interface root of many
  * `public int size()`
    * limited by `Integer.MAX_VALUE`
  * `public boolean isEmpty()`
  * `public boolean contains(Object elem)`
    * accepts `null` returns true if collection has null
  * `public Iterator iterator()`
  * `public Object[] toArray()`
  * `public <T> T[] toArray(T[] dest)`
    * if elements fit in `dest` put in dest
    * else return new array
    * `ArrayStoreEception` array type incompatible
  * `public boolean add(E elem)`
    * return false if addition couldnt succeed due to duplicate
      restirction
  * `public void remove(Object elem)`

{% highlight Java %}
String[] strings = new String[collection.size()];
strings = collection.toArray(strings);

// using empty arrays
String[] strings = collection.toArray(new String[0]);
{% endhighlight %}

* Collection bulk methods
  * `public boolean containsAll(Collection<?> coll)`
  * `public boolean addAll(Collection<?> coll)`
  * `public boolean removeAll(Collection<?> coll)`
  * `public boolean retainAll(Collection<?> coll)`
     * remove all but given
  * `public void clear()`
    * remove all

#### Set and Sorted Set

* extends Collection Interface
* marker interface signifying no duplicate elements
* `add` returns false on second invocation
* at most one null element
* `SortedSet<E>` adds methods over `Set<E>`
  * `public Comparator<? super E> comparator()`
    Return underlying comparator being used
  * `public E first()`
  * `public E last()`
  * `public SortedSet<E> subSet(E min, E max)`
    * returns view backed by original
    * changes in original visible
  * `public SortedSet<E> headSet(E max)`
    * all elements less than max
    * a view
  * `public SortedSet<E> tailSet(E min)`
    * all elemetns gt than max
    * a view
* All views are backed by original , stay current.

{% highlight Java %}
public <T> SortedSet<T> copyHead(SortedSet<T> set, T max) {
    SortedSet<T> head = set.headSet(max);
    // a new copy from the view
    return new TreeSet<T>(head); // contents from head
}
{% endhighlight %}


#### HashSet

* Set implemented with a hashtable
* Testing containment : O(1) (assuming good hashcode)
* `public HashSet(int initialCapacity, float loadFactor)`
  * `initialCapacity` number of hash buckets
  *  number elements
  
* `public HashSet(int initialCapacity)`

* `public HashSet(Collection<? extends E> coll)`
  * Use default load factor
  *

#### LinkedHashSet<E>

* perserve element ordering

#### TreeSet<E>

* tree structure which is kept balanced
* `public TreeSet<E>()`
   * All elements added to the set must be `Comparable`
* `public TreeSet<E>(Collection<? extends E> coll)`
  * Add all elements to the tree set
* `public TreeSet<E>(Comparator<? extends E> comp)`
  * instead of natural comparator
* `public TreeSet(SortedSet<E> set)`
  * with initial contents

#### `List<E>`

* Extends `Collection<E>`
* `public int indexOf(Object elem)`
* `public int lastIndexOf(Object elem)`
* `public List<E> subList(int min,int max)`
* `public ListIterator<E> listIterator(int startIndex)`
* `public ListIterator<E> listIterator()`

#### `ArrayList<E>`

* `O(1)` removal from the end
* `O(n-i)` addition and removal from the `i^th` position / copy the remainder up
* `public ArrayList()`
* `public ArrayList(int initialCapacity)`
* `public ArrayList(Collection<? extends E> coll)`
  * initial capacity is 110% of original
* `public void trimToSize()`
* `public void ensureCapacity(int minCapacity)`
  * allow for a certain capacity prevent frequent reallocations

#### `LinkedList`

* Doubly linked list
* Adding and removing elements in middle is O(1)
* 
* `public LinkedList()`
* `public LinkedList(Collections<? extends E> coll)`
* `public E getFirst()`
* `public E getLast()`
* `public E removeFirst()`
* `public E removeLast()`
* `public void addLast(E elem)`

#### RandomAccess List

* marker interface
* used to indicate fast random or not
* using explicit for loop will be faster for RandomAccess

{% highlight Java %}
for(int i = 0; i < list.size();i++) {
  process(list.get(i));
}
{% endhighlight %}


{% highlight Java %}
Iterator it = list.iterator();
while(it.hasNext())
  process(list.next());
{% endhighlight %}


#### Queue

* `Queue<E>` extends `Collection<E>`
* `public E element()`
* `public E peek()`
  * check dont remove
  * null on empty queue
* `public E remove()`
  * remove from `head`
  * NoSuchElementException on empty queue
* `public E poll()`
  * returns and removes from head of the queue
  * empty queue get null unlike remove
* `public boolean offer(E elem)`
  * insert at end
  * false for queue has finite capacity
* Shouldnt accept null , null is sentinal for poll


#### PriorityQueue

* unbounded queue
* based on priority heaps
* head is smallest
* not sorted in general
* iterator traverse in heap order ?
* Insertions : `O(log n)`
* Searching/Traversing : `O(n)`

* `public PriorityQueue(int capacity)`
  * new queue with given capacity avoid resizing
* `public PriorityQueue()`
* `public PriorityQueue(int capacity, Comparator <? super E> comp)`
  * use supplied comparator instead
* `public PriorityQueue(Collection<? extends E> coll)`
  * new queue that is 110% of this capacity
  * ClassCastException for non comparable
* `public PriorityQueue(SortedSet<? extends E> coll)`



#### Map and Sorted Map 

#### enum Collections

#### Wrapped Collections and Collection Class

#### Synchronized Wrappers and Concurrent Collections

#### The Arrays Utility Class

#### Writing Iterator Implementations

#### The Legacy Collection Types

#### Properties




### Summary

Of course one has just scratched the surface. The truly interesting
parts about the language are the actually in the design of the virtual
machine. 



---
