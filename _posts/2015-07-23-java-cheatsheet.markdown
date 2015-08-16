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

### Ch 3: Extending Classes

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

#### Map<K,V> and SortedMap 

* `public int size()`
* `public boolean isEmpty()`
* `public boolean containsKey(Object key)`
  * O(1) if good hash
* `public boolean containsValue(Object value)`
  * O(n) assuming bad hash
* `public V get(Object key)`
* `public V put(K key,V value)`
  * return original value if key was present
  * null on no value or null value
* `public V remove(Object key)`
  * like put but removes k,v
* `public V putAll(K key,V value)`
* `public void clear()`
  * remove all mappings
* `public Set<K> keySet()`
* `public Set<Map,Entry<K,V>> entrySet()`
  * Entry represents single mapping entry
  * `Map.Entry` - inner class

* `SortedMap` extension of `Map` interface for keeping entries sorted by keys
  * `public Comparator<? super K> comparator()`
  * `public K firstKey()`
  * `public K lastKey()`
  * `public SortedMap<K,V> subMap(K minKey, K maxKey)`
    * a view on map in given interval
    * `[minKey,maxKey)` only start end included
  * `public SortedMap<K,V> headMap(K maxKey)`
  * `public SortedMap<K,V> tailMap(K minKey)`
* `SortedMap` : `Map`  :: `SortedSet`: `Set`

* `Map` implementers
  * `HashMap`
  * `LinkedHashMap`
  * `IdentityHashMap`
  * `WeakIdentityHashMap`
  * `TreeMap`


#### HashMap

* Adding/Removing key pairs O(1)
* large number of bucket size means slow iterations , greater memory use
* small number of buckets means more collision
* which of these is without evil
* loadFactor to determine resize time
* capacity doubled when loadFactor crossed
* doubling capacity = rehash all entries in the map
* low loadFactor + low initial capacity = many resizes
* default loadFactor = .75
* default capacity = 16
* resize if (# elements) > (loadFactor * current capacity)

* `public HashMap(int initialCapacity, float loadFactor)`
  * number of buckets
  * 

* `public HashMap(Map<? extends K, ? extends V> map)`
* `public HashMap()`
* 

#### LinkedHashMap<K,V>


* Defines order of entries by keys
* default to insertion order
* iteration of the order of size instead of capacity
* overhead of linked list maintenance
* accessOrder - if true then most accessed first


#### IdentityHashMap<K,V>

* use object reference equality to do key comparison
* that is use `==` instead of `equals` for key comparison

#### WeakHashMap<K,V>
* Refer to keys using `WeakReference` object
* Let object get garbage collected,references dont force object to stay in memory
* if key garbage collected automatically removed from WeakHashMap
* iterators can return no such element after hasNext = true
* good for caches

#### TreeMap<K,V>

* A map sorted by keys
* `public TreeMap(Comparator<? super K> comp)`

#### enum Collections


* `EnumSet` and `EnumMap` to work better with enums
* `EnumSet`
  * `EnumSet<E extends Enum<E>>` a set of enums of a particular type
  * `public static <E extends Enum<E>> EnumSet<E> allOf(Class<E> enumType)`
    * set of all enum of this class type
  * `public static <E extends Enum<E>> EnumSet<E> noneOf(Class<E> enumType)`
    * empty enum set of this class type.
  * `public static <E extends Enum<E>> EnumSet<E> copyOf(EnumSet<E> set)`
  * `public static <E extends Enum<E>> EnumSet<E> complementOf(EnumSet<E> set)`
  * `public static <E extends Enum<E>> EnumSet<E> of(E e1, E e2, E e3)`
    * set from given Enum
  * `EnumSet` uses compact bit vector representation internally
* `EnumMap`
  * Use Enum value as keys
  * `EnumMap<K extends Enum<K>,V>`


#### Wrapped Collections and Collection Class

* static utilites for collections

##### Collections class

* Find the min and max using comparator or natural order
* `public static <T extends Object & Comparable<? super T>> T min(Collection<? extends T> coll)`
* `public static <T> T min(Collection<? extends T> coll, Comparator<? super T> comp)`
* `public static <T extends Object & Comparable<? super T>> T max(Collection<? extends T> coll)`
* `public static <T> T max(Collection<? extends T> coll, Comparator<? super T> comp)`

* `Comparator` building functions
  * `public static <T> Comparator<T> reverseOrder()`
     * reverse of natural order of objects it compares
  * `public static <T> Comparator<T> reverseOrder(Comparator<T> comp)`
    * a comparator which is reverse of given `comp`

* `public static <T> boolean addAll(Collection<? super T> coll, T... elems)`
* `public static <T> boolean addAll(Collection<? super T> coll, T... elems)`
* `public static boolean disjoint(Collection<?> coll1, Collection<?> coll2)`

###### List Methods
* `public static <T> boolean replaceAll(List<T> list, T oldVal, T newVal)`
* `public static void reverse(List<?> list)`
* `public static void rotate(List<?> list, int distance)`
  * push forward and rotate
  * v,w,x,y,z  -> z,v,w,x,y (rotate by 1)

* `public static void shuffle(List<?> list)`
  * randomly shuffle the list
* `public static void shuffle(List<?> list, Random randomSource)`  

* `public static void swap(List<?> list, int i, int j)`
* `public static <T> void fill(List<? super T> list, T elem)`
  * replace each in list with elem
* `public static <T> void copy(List<? super T> dest, List<? extends T> src)`

* `public static <T> List<T> nCopies(int n, T elem)`
  * immutable list
  * store n copies of same object
  * stored compactly
  
* `public static int indexOfSubList(List<?> source, List<?> target)`
  * like string indexOf
  * returns first index
* `public static int lastIndexOfSubList(List<?> source, List<?> target)`

###### Sorting and Searching lists

* `public static <T extends Comparable<? super T>> void sort(List<T> list)`
* `public static <T> void sort(List<T> list, Comparator<? super T> comp)`
* `public static <T> int binarySearch(List<? extends Comparable<? super T>> list,T key)`
  * list must be in sorted natural order
  * `-safe_insertion_point` when not found if failed at i returns (i+1) as insertion point
* `public static <T> int binarySearch(List<? extends T> list, T key, Comparator<? superT> comp)`

###### Statistics
* `public static int frequency(Collection<?> coll, Object elem)`

###### Singleton Collections
* `public static <T> Set<T> singleton(T elem)`
  * single element , singleton , immutable set
* `public static <T> List<T> singletonList(T elem)`
* `public static <K,V> Map<K,V> singletonMap(K key, V value)`

###### Empty Collections
* `public static <T> List<T> emptyList()`
* `public static <T> Set<T> emptySet()`
* `public static <K,V> Map<K,V> emptyMap()`

###### Unmodifiable Wrappers

* Returns same collection but unmodifiable

* unmodifiableCollection
* unmodifiableSet
* unmodifiableSortedSet
* unmodifiableList
* unmodifiableMap
* unmodifiableSortedMap

###### Checked Wrappers
* Deal with generic type erasure, to ensure collection throws error when adding to it a object of wrong type
* `public static <E> Collection<E> checkedCollection(Collection<E> coll, Class<E> type)`
  * `ClassCastException`


#### Synchronized Wrappers and Concurrent Collections

* Add synchronization to unsynchronized collections
* recommendation to drop reference to unsynchronized map
* uses the unsync map as the backing store
* iterators returned by sync wrappers are not synchronized

#### Concurrent Collections

* Specifically Defined for concurrency
* `BlockingQueue<E>` Interface
  * capacity constrained collection
  * wait until space appears in collection
  * `public void put(E elem) throws InterruptedException`
    * wait for space
  * `public boolean offer(E elem, long time, TimeUnit unit) throws InterruptedException`
    * wait for space
    * false if timeunit expired but still couldnt add
  * `public E take() throws InterruptedException`
    * take , wait if none
  * `public E poll(long time, TimeUnit unit) throws InterruptedException`
    * take wait or expire
    * `null` if time elapsed
  * * `drainTo` - to allow bulk transfer to a collection, may be more efficient in some concrete implementations

* `InterruptedException` - support for cancellation of thread

* `ArrayBlockingQueue<E>` 
  * backed by array
* `LinkedBlockingQueue<E>`
  * Linked List based
  * greather throughput allow independent locking of head and tail
  * put goes to end and take takes from head so indpendent locking helpful
  * requiring allocation for each insertion produces more garbage
* `PriorityBlockingQueue`
* `SynchronousQueue`
  * each `take` wait for a `put` and vice versa
* `DelayQueue`
  * elements must expire a delay before they can be taken
  * `getdelay` to see what it is

###### ConcurrentHashMap
* fully concurrent retrieval
* fixed num concurrent insertions
* all operations are thread safe
* no locking involved !!
* `public V putIfAbsent(K key, V value)`
  * atomic store if key doesnt exist
  * null returned if exits
* `public boolean remove(Object key, Object value)`
  * remove if `key` mapping to `value` is present
  * no other remove method
* `public boolean replace(K key, V oldValue, V newValue)`
  * replace key old value with new value

###### ConcurrentLinkedQueue<E>
* lockless,highly concurrent
* linked list
* weakly consistent iterator

###### CopyOnWriteArrayList<E>
* make a copy only if original ArrayList is modified
* efficient for many readers few writers
* iterator always sees same snapshot

#### The Arrays Utility Class

* Useful static methods for dealing with Arrays
* sort : sort in ascending /increasing order : O(nlog(n))
* binarySearch: key index, or negative value safe insertion point
* fill: Fills array with a specified value
* equals , deepEquals : true if two arrays are equal, deepEquals check for equality by iterating nested arrays
* hashCode, deepHashCode : compute the hashCode for an array

#### Writing Iterator Implementations

* 


#### The Legacy Collection Types



#### Properties



### Summary

Of course one has just scratched the surface. The truly interesting
parts about the language are the actually in the design of the virtual
machine. 



---
