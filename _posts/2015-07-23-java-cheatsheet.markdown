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
of the better books for clarifying the language's ideas.

### Ch  3: Extending Classes

### Ch 11: Generic Types

### Ch 12: Exceptions

### Ch 14: Threads

### Ch 20: I/O Packages

### Ch 21: Collections

* Classes present in the `java.util` package.

#### Collections

* Core Interfaces

  * `Collection<E>` : root interface
    * `add`
    * `size`
    * `toArray`

  * `Set<E>` : Collection without dupulicate elements
  * `SortedSet<E>`: Sorted , Non-Dupulicate
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

* Concrete Implemenations
  * `HashSet<E>` : Set implemented as hash table
  * `TreeSet<E>` : `SortedSet` implemented as balanced binary tree
    * Can be slower to search/modify than `HashSet`
    * Keeps elements sorted
  * `ArrayList<E>` : `List` as resizable array
    * fast random access
    * expensive to add/remove at begining
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

All are `Cloneable` and `Serializable` :
  * WeakHashMap<K,V> not (`Cloneable` , `Serializable`)
  * PriorityQueue<E> not (`Cloneable`)


##### Class Heirarchy 

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



#### Iteration

#### Ordering with Comparable and Comparator

#### The Collection Iterface

#### Set and Sorted Set

#### List

#### Queue

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
