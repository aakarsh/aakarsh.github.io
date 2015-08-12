---
layout: post
title: Programming Language Reference - Java (draft)
category:  python
published: true
---

This post is part of a series of cheatsheets for to help people get up
to speed and refresh rusty python skills. Thus the aim of these post
is to be short and sweet and to jog already pre-existing python
knowledge with minimum explanations. Acknowledgement to Python in a
Nutshell for a lot of the source material.

### The Python Language

#### Lexical Structure
#### Data Types
#### Variables and Other References
#### Expressions and Operators
#### Numeric Operations
#### Sequence Operations
#### Set Operations
#### Dictionary Operations
#### Control Flow Statements
#### Functions

### Object Oriented Python

#### Classes and Instances

##### Python Classes

Characteristics of a *classes* :

* Callable as functions
  * returns *instance* of class
  
* Attributes
  * bind and reference
  * value can be descriptors

* Methods
   * Attributes bound to functions
* Special Methods
  * Python  defined meaning 
  * __methodname__  format

* Inheritance
  * allows delegation of attribute look up to other classes

* Objects
  * Class behave like ordinary objects
  * used as keys into a dictionary


##### The *class* Statement

{% highlight Python %}
class classname(base-classes):
    statement(s)
{% endhighlight %}

* base-classes
  * comma-delimited series of class objects
  * optional - new style `class C(object):`
  * all classes sub class `object` class
  * new class style has a `__metaclass__` attribute

* Subclass Relation Ships
  * **Transitive** *C1 subclass C2* and *C2 subclass C3*  then *C1 subclass C3*
  * `issubclass` check transitive relationship
  * **Reflexive**  classes subclass themself

#### The Class Body

#####  Attributes of class objects

* Inbody attributes

{% highlight Python %}
class C1(object):
    x = 23

print C1.x
{% endhighlight %}

* Outbody attributes

{% highlight Python %}
class C2(object): pass # empty class
C2.x = 23
print C2.x   # print 23
{% endhighlight %}

* Implicit attributes
  * **__name__** the class name identifier
  * **__bases__**  tuple of class objects
  * **__dict__** dictionary of other attributes
  
  {% highlight Python %}
     C.S = x
     C.__dict__['S']=x
  {% endhighlight %}

* Must use *simple* names inside the class body
* Must use *fully qualified* name in methods

{% highlight Python %}
class C4(object):
   x = 23
   def amethod(self):
      print C4.x
{% endhighlight %}

##### Function definitions in class body

* Mandatory first parameter
* conventionally called *self*

{% highlight Python %}
class C5(object):
   def hello(self):
       print "hello"
{% endhighlight %}

##### Class-private variables

* *__ident* gets converted to *_classname__ident* where *classname*
is the name of the class.

* *_ident* single unders score used for private by convention.

###### Class documentation strings
* **__doc__** bound to fist string by compiler

##### Descriptors

* New-style object
* Contains `__get__` special method

##### Overriding and nonoverridign descriptors

* class containg  `__set__` called overriding descriptor else non-overriding

##### Instances

* Created by calling class objects

{% highlight Python %}
foo = C5()
isinstance(foo,C5)
{% endhighlight %}

##### `__init__` 

* invoked during construction

{% highlight Python %}

class C6(object):
    def __init__(self,n):
        self.x = n

foo = C6(10)
{% endhighlight %}

* Allows to bind instance attributes
* Should not return a value

###### Attributes of instance objects

{% highlight Python %}
class C7(object): pass
z = C7()
z.x = 23
print z.x   # prints: 23
{% endhighlight %}

* `__setattr__` intercepts every attempt to bind an attribute

* Some complexities are involved in interception between new and old
  style method interception

* For all identifiers except `__class__` and `__dict__`


###### The factory-function idiom

* Since using `__init__` as factory function infeasible
* use factory functions for specialized creation

{% highlight Python %}
class Cat(object):
     def sound(self): print "meo"

class Dog(object):
     def sound(self): print "bow"

def pet(likeable=True):
   if likeable: return Dog()
   return Cat()

p  = pet()
p.sound() # prints bow
{% endhighlight %}


##### `__new__`

* contained in `new-stye` classes.
* `C(*args,**kwds) -> C.__new__(C,*args,**kwds) -> C.__init__(x,*args,**kwds)`
* Value returned by `__new__` used in call to call to `__init__` as first argument

{% highlight Python %}
x = C(23)

# Expanded to
x = C.__new__(C,23)
if isinstance(x,C): type(x).__init__(x,23)
{% endhighlight %}

* `__new__` treated as static method by default.

* `__new__` can be used in leu of factory functions

* Example with singleton class

{% highlight Python %}
class Singleton(object):
   _singletons = {}

   def __new__(cls,*args,**kwds):
       if cls not in cls._singletons:
          cls._singletons[cls] = super(Singleton,cls).__new__(cls)
       return cls._singletons[cls]
{% endhighlight %}

* If new needs new instance can call `object.__new__` to get a new object

* Subclasses of singleton will always return a single instance.


##### Attribute Reference Basics

* Any reference of the form `x.attrname`
* Methods and fields are both attributes

{% highlight Python %}

class B(object):
    a = 23
    b = 45
    def f(self): print "method f class b"
    def g(self): print "method g class b"

class C(B):
    b = 67
    c = 89
    d = 123
    
    def g(self): print "method g in C"
    def h(self): print "method h in C"

x = C()
x.d = 77
x.e = 88

# prints: 88,77,89,67,23
print x.e,x.d ,x.c , x.b, x.a

{% endhighlight %}

* `C.__name__` is 'C'
* `C.__bases__` is (B)
* `x.__class__` is  C class object
* Allowed rebinding though rarely necessary
* `__dict__` All attribute except few special are in `__dict__`


##### Getting an attribute from a class

When referencing an attribute of class object `C.attrname`

* Check `C.__dict__` for `attrname` 
* If `C.__dict__[attrname]` is descriptor i.e `type(v)`
supplies `__get__`  method then call `type(v).__get__(v,None,C)`

* Else delegate to ancestors in method resolution order.

  
###### Getting an attribute from a instance

When using `obj.attrname`

* When `attrname` found in C as a descriptor `type(v).__get__(v,x,C)` 

* When `attrname` key in `x.__dict__` fetch `x.__dict__['name']`

* `x.name` delegate lookup to class `x.__dict__['name']`

* `AttributeError` exception if no look up found

* `__getattr__` if `C` defines sucha  method instead of `AttributeError`

{% highlight Python %}
# prints: 88,77,89,67,23
print x.e,x.d ,x.c , x.b, x.a 
{% endhighlight %}



###### Setting an attribute

* add to `__dict__` unless `__setattr__` or `__set__` defined 


##### Bound and Unbound Methods

* `__get__` returns either `bound` or `unbound` method object
* `bound` - associated with an instance
   * from attribute reference on instance
   * *self* parameter ommited
* `unbound` - **not** associated with an instance
  * from attribute reference on class
  * *self* parmeter specifie
* `x.h,x.h,x.f` : Examples of bound methods
* `C.h,C.g,C.f` :  Example of unbound bound methods

###### Unbound method details

* Attribute reference via class returns unbound method

* Has three attributes+attributes of wrapped method
  * im_class - class supplying the method
  * im_func  - the wrapped function
  * im_self - always set to None
  * call to unbound method type should be `im_class` or descendent.
  
###### Bound method details

* via instance attribute dereference
* created from a `__get__` method
* return bound method that wraps the function
* if found in `__dict__` no bound method created 
* no bound method for built-ins or non-descriptors

* Has three attributes
  * im_class - class supplying the method
  * im_func - wrapped function
  * im_self - refer to `x` object instance

{% highlight Python %}
def f(a,b): ... # function with two args
class C(object):
  name = f

x = C()
x.name(arg)
{% endhighlight %}


* `name` an attribute with function value
* `functions` descriptors `function class` define `__get__` but no `__set__`
* check `x.__dict__` for `name` it isnt there
* check `C.__dict__` find it
* Notice attribute value `f` is descriptor
* Call `f.__get__(x,C)` creates a bound method
   * Creates a bound method
     * im_func - set to f
     * im_class - C
     * im_self - x
* Overall effect of method call

{% highlight Python %}
x.__class__.__dict__['name'](x,arg)
{% endhighlight %}

* self reference explicitly passed takes means no implicit scoping
* Possible alternative to closures.
* Bound methods are first class objects
* Bind method to underlying instance and themself
* similar to closure bundle of code and data.

* Comparison of closure to bound methods given as follows

* Using closure
{% highlight Python %}
# simple closure which returns a function with with augund bound  argument 
# passed in during its construction
def make_adder_as_closure(auged):
    def add(added,_augend=augend): return added+augend
    return add
{% endhighlight %}

* Using bound method
{% highlight Python %}
def make_adder_as_bound_method(augend):
    class Adder(object):
       def __init__(self,augend): self.augend = augend
       def add(self,addend) : return addend+self.augend
    return Adder(augend).add
{% endhighlight %}


* Using `__call__` for callable instance method

{% highlight Python %}

def make_adder_as_callable_instance(augend):
    class Adder(object):
          def __init__(self,augend): self.augend = augend
          def __call__(self,augend): return addend+self.augend
    return Adder(augend)
{% endhighlight %}

* Makes Adder a collable object attribute saved in self.augend

##### Inheritance

* Describes how resolution  takes place through class heirarchy
* Proceeds 'one-by-one' stop when found

###### Method resolution order

* Visit anscestors : **left-to-right** **depth-first**

* Multiple Inheritence graph is a directed acyclic graph
* Double visiting problem consider only **rightmost** occurrence 

* Issues with **left-to-right**, **depth-first**
{% highlight Python %}
class Base1:
    def amethod(self):print "Base1"
class Base2(Base1):pass
class Base3(Base1):
    def amethod(self): print "Base3"
class Derevied(Base2,Base3) :pass

x = Derevied()
x.amethod()  # prints Base 1
{% endhighlight %}

* Lookup `Base2 > Base1`
* New Style : if `(B,C..) subclass D` dont proceed to `D` until both `B and C and ..` have been lookat at for the attribute
* Descendents guaranteed to be examined before ancestors
* Specifially implemented to deal with diamonds

* `__mro__` read only class attribute : tuple of types for method resolutoin

* Used for implementing overriding behavior

###### Delegating to superclass methods

* Unbound methods can be used to delegate to super class


{% highlight Python %}

class Base(object):
    def greet(self,name): print "Welcome ",name

class Sub(Base):
    def greet(self,name):
        print "Well met and",
        Base.greet(self,name)

x = Sub()
x.greet('Alex')

{% endhighlight %}

* Python base class `__init__` not automatically invoked

{% highlight Python %}
class Base(object):
    def __init__(self): 
        self.attr = 23
class Derived(Base):
    def __init__(self):
       Base.__init__(self) # ensure a call to base class
       self.attr = 45
{% endhighlight %}


###### Cooperative superclass method calling

* Severe problems with unbound method calling + multiple inheritence

{% highlight Python %}

class A(object):
   def met(self):
       print 'A.met'

class B(A):
   def met(self):
       print 'B.met'
       A.met(self)

class C(A):
   def met(self):
       print 'C.met'
       A.met(self)

class D(B,C):
   def met(self):
       print 'D.met'
       B.met(self)
       C.met(self)

# A.met called twice via B and via C
{% endhighlight %}


* Prevent double calling of ancetor via built-in type `super``
* `super(aclass,obj)` special super object of obj
* Special super object of object obj

{% highlight Python %}
class A(object):
   def met(self):
       print 'A.met'

class B(A):
   def met(self):
       print 'B.met'
       super(B,self).met()

class C(A):
    def met(self):
        print 'B.met'
        super(B,self).met()

class D(B,C):
    def met(self):
        print 'D.met'
        super(D,self).met()

{% endhighlight %}

* `D().met()` exactly single call to each met
* Look up begins **after** the provided class in obj's MRO
* `super(D,self).met()` will find 'B.met()' 'C.met()', 'A.met'()
* TODO This is super confusing and needs to be revisited.


###### "Deleting" class attributes

Possibilities for hiding base class definitions
* Override + raise exceptions
* Use new-style object override *__getattribute__*

##### The Built-in object Type

* Ancestor of all built-in types and new-style classes.

* `__new __` && `__init__`
 * Can create direct instance using `object()`
 * Implicitly uses `object.__new__` and `object.__init__`
 
* `__delattr__` , `__getattr__`, `__getattribute__`,`__setattr__`
   *   default object attribute reference handlers

* `__hash__` , `__repr__`,`__str__`

  * functions to hash and represent objects.

##### Class-Level Methods

* Two built-in nonoverriding descriptor types

###### Static methods

* Unconstrained methods
* Can have no argumetns
* Behave like ordinary functions
* bind an attribute wrapping with `staticmethod`

{% highlight Python %}
class AClass(object):
   def foo(): print 'a static method'
   astatic = staticmethod(foo)

x = AClass()
AClass.foo()  # prints 'a static mehtod'
x.foo()       # prints 'a static method'

{% endhighlight %}


###### Class methods

* Callable on a class or instance of the class
* First param bound to class, conventionally called `cls`
* use `classmethod` typ to bind to a class attribute

{% highlight Python %}
class ABase(object):
    def foo(cls): print ' a class method',cls.__name__
    foo = classmethod(foo)

class ADeriv(ABase): pass

b = ABase()
d = ADeriv()
ABase.foo()   # print ABase
b.foo()       # print ABase

ADeriv.foo()  # print ADeriv
d.foo()       # print ADeriv

{% endhighlight %}

##### Properties

* instance attribute with special functionality
* use built-in type `property`


{% highlight Python %}
class Rectangle(object):
     def __init__(self,width,height):
         self.width = width
         self. height = height
         
     def getArea(self):
         return self.width * self.height

      area = property(getArea, doc='area of rectangle')
{% endhighlight %}


* `r.area` a synthetic read only attribute computed using `r.getArea()`
*  Generic property description

{% highlight Python %}
attrib = property(fget=None,fset=None,fdel=None,doc=None)
{% endhighlight %}

* `x.attrib` calls fget
* `x.attrib = value` calls the fset 
* `del x.attrib` calls fdel


* Allows for exposing public data attribute
* Part of public interface.
* Allows changing ordinary attributes to properties for extension effect
* No need to add setter and getter methods

###### Properties and Inheritance

* methods suplied are bound in class definition thus do not have
overriding effects

{% highlight Python %}
class B(objecT):
    def f(self): return 23
    g = property(f)

class C(B):
    def f(self): return 42

c = C()

print c.g    # will print 23 not 42

{% endhighlight %}

* Fix is to create a hidden property binding method which then goes
through a self reference 

{% highlight Python %}
class B(object):
   def f(self): return 23
   def _f_getter(self): return self.f()
   g = property(_f_getter)

class C(B):
   def f(self): return 42

c = C()
print c.g    #print 42 , as expected
{% endhighlight %}

###### `__slots__`

* alternative to `__dict__`
* idk are they worth it?

###### `__getattribute__`

* used to intercept instance attribute accesses.
* eg. Hiding certain attributes

{% highlight Python %}
# list type which does not support appending
class listNoAppend(list):
     def __getattribute__(self,name):
         if name == 'append' : raise AttributeError,name
         return list.__getattribute_(self,name)
{% endhighlight %}


###### Per-Instance Methods

* 


###### Inheritence from Built In Types


#### Special Methods pg 104
##### General Purpose Special Methods
####### `__call__`
####### `__cmp__`
####### `__del__`
####### `__delattr__`
####### `__eq__` and `__ge__`
####### `__getattr__`
####### `__get-attribute__`
####### `__hash__`
####### `__init__`
####### `__nonzero__`
####### `__repr__`
####### `__setattr__`
####### `__str__`
####### `__unicode__`

##### Special Methods for Containers

* Sequences

  * For sequences of size `L`
  * `-L<=key<L` where negative keys get `k+L` to get sequence
  * `IndexError`: key out of range
  * `TypeError`: key invalid type
  * iter(seq) : list iterator of sequence
  * accept built in type slice arguments `start`,`step`, `stop`
  * `__add__`,`__mul__`,`__radd__`,`__rmul__` to support index list operations
  * `append`,`count`, `index`,`insert`,`extend`,`pop` , `remove` , `reverse` and `sort`
  * immutable sequences should be hashable if all elements hashable

* Mappings
  * KeyError : key not found
  * `copy`,`get`,`has_key`,`items`,`keys`,`values`,`iteritems`,`iterkeys` and `itervalues`
  * `__iter__` should be `iterkeys`
  * mutable methods `clear`,`popitem`,`setdefault` and `update`

* Sets
  * set operators `&,|,^,-`
  * `intersection`, `union` and so on

* Container slicing
  * Reference `x[i:j]` or `x[i:j:k]` on container x will be tranformed
    into a call with `slice` object
 *  `slice.indeces` get `(start,stop,step)` tuple
  * We need to switch on the type of the index `isinstance(index,slice)`  vs `isinstance(index,int)`
  * Older system did not user `getitem` based type checking for `getslice` or `setslice`

* Container methods
  * `__contains__`
     * `y` in `x` becomes `x.__contains__(y)`
    
    * `__delitem__`
      *  `del x[key]` becomes `x.__delitem__(key)`

  * `__getitem__`
     * `x[key]` is accesssed `x.__getitem__(key)`

  * `__iter__`
     * `for item in x` get iterator using `x.__iter__()`
     * if no `__iter__` then sequnce of calls `x[0]` ,`x[1]` ,...

  * `__len__`
     * len() 
     * used for boolean context too
     
  * `__setitem__`
   `x[key] = value` becomes `s.__setitem__(key,value)` 

####### Special Methods for Numerical Objects



###### `__unicode__`
#### Decorators
#### Metaclasses


### Exceptions

#### The try Statement
#### Exception Propogation
#### Exception Objects
#### Custom Exception Classes
#### Error-Checking



### Python Module System

** Keywords: **  *import*, *from*, *extensions*

* Modules can be handled like ordinary objects

* `sys.modules` : Contains dictionary loaded modules

{% highlight Python %}
import modname [as somename],....
{% endhighlight %}

* `import` keyword will bind the modname to the module object in current
scope.

* `as` keyword can be used to customize the binding as in :

   {% highlight Python %}
       import mod as alias
   {% endhighlight %}

* Modules have associated body which get exectuted on import.

* Before execution `sys.modules` assosciates the module to its ojbect.

#### Module Attributes

* `M.attr` can be used to access `attr` of module `M`

{% highlight Python %}
import mod as foo # import mod as foo
bar = foo.bar()   # invoke the bar method on foo
{% endhighlight %}

* `__dict__` used to hold attributes bound in module
* `__file__` the filename module is loaded
* `__name__` the module name.
* `M.S=x` gets transformed  into `M.__dict__["S"]=x`. `M.S`
* `M.<non-attribute>` throws `AttributeError`

#### Python built-ins

* `__builtin__` preloaded module holding built in objects.
* `__builtins__` is at module attibute that points to the
`__builtin__` dictionary of python
* `__builtins__` used as in search path if identifier not found in
current module or throw `NameError`

* `__builtin__` can be used to substitute custom function for normal
built in functions

#### Module Doc Strings

* `__doc__` : The first line string literal in module body gets bound
to `__doc__`

#### Module Private Variables

* All module variables public
* `_hidden` used to indicate module internal variables.

#### From Statement

* Import specific attributes

{% highlight Python %}
from modname import attrname [as varname],
from modname import *
{% endhighlight %}

* Python 2.4

{% highlight Python %}
from modname import (one_name,two_name,three_name)
{% endhighlight %}

#### from import* statement
* import all module attributes as global variables.

{% highlight Python %}
from modname import *
{% endhighlight %}

* `__all__` if bound then only atribues specified in it are imported

* `_hidden` attributes starting with `_` not imported.

* use with caution.

#### Module Loading

* `__import__` built in function which performs module loading.
  * call to `M.__import__`
     * checks `sys.modules`
     * if not found bind `sys.modules[m]` loading from file path
* `__import__` cache of does not read to re-read file to for
subsequent imports

#### Built-in Modules

* `sys.builtin_module_names` used by `__import__` to check module is a
built in one.
* Allows platfor specific loading

#### Searching Filesystem for a Module

* `sys.path`: list of directories or zip files., uses the `PYTHONPATH`
environment variable.
    * Contains the directory in which this module was loaded 
    * `sys.path` changes dont affect already loaded modules.

* `.pth` files in `PYTHONHOME` also added to `sys.path`

* Extensions consideraion order:
   * `pyd` , `dll` (windows) , `.so` (unix)
   * `.py` pure source python modules
   * `.pyc` bytecode compiled Python modules.

* `M/__init__.py` for initializing packages

* `M.py` compiled to `M.pyc`

#### The Main Program

* `__main__`   top level script of that started the exectuion
* `if __name__ == "__main__":` Use only when module
is run as main


#### The reload Function

* `reload(M)` reload a module object with built in function `reload`
* does not affect references already bound using the `from` statement
* non-recursive will not cause cause reload of dependencies

#### Circular Imports

* a depends on b depends on a
   * create sys.modules['a']
   * start executing a
   * encounter import b
   * suspend a start running b
   * all references before import b accesible in b

#### sys.modules Entries

* By default return if module found in `sys.module`


#### Not covered
* Custom Importers (see reference material)
* Import Hooks (see reference material)


### Packages

* module containing other modules
* can have subpackage module heirarhy
* `P/__init__.py` module body for package
   * loaded on first import

* `import P.M` Import module in package `P`
* `from P import M` import only specific module

####  Special attributes of package objects

* `__file__` path of module body or `P/__init__.py`
* `__all__` control the execution of `P import *`, `P import *` doesnt
  import other modules only package body
* `__path__` list of strings that are paths to directories from which
`P's` modules and subpackages are loaded.


### Distribution utilities (distutils)

* Available Formats :
  * Compressed archive:
  * self-unpacking
  * zero install ready to run
  * installers
  * python eggs

* `setup.py` included file in a distributed file that will use
`distutils` to install package
* `pythhon setup.py --help`
* `pydistutils.cfg` to configure distutils system wide.

* Python Eggs :
  * No installation needed place in `sys.path`
  * .egg extension zip format



### Core Built-ins


#### Built-in Types

* `basestring`
  * Non-instatiable
  * super class :`str`,`unicode`
  * check : instance(x,basestring)

* `bool(x)`
  * False - x evaluates to false
  * True - x evals to true
  * subclass of `int`
  * integers equal to 0,1
  * str(x) - 'True' or 'False'

* `buffer(obj,offset=0,size=-1)`
  * read only buffer slice of obj data
  * from offset to offset+size
  * obj must support call interface
  * eg. str,array

* `classmethod(function)`
  * get class method object

* `complex(real,imag=0)`
   * convert number to complex

* `dict(x={})`
   * copy of x with same objecs as x
   * equivalent : x.copy()
   * If x iterable : items are pairs return dictionary
     {% highlight Python %}
     c = {}
     for key,value in x: c[key] = value
     {% endhighlight %}
* `enumerate(iterable)`
   * (i,iterval) - returns pair where `iterval` is from itrable and `i` is index position

   {% highlight Python %}
   for i,num in enumerate(L):
       if num % 2 == 0 :
          L[i] = num //2 
   {% endhighlight %}

* `file(path,mode='r',bufsize=-1)` `open(filename,mode='r',bufsize=-1)`
   * Opens or creates a new file

* `float(x)`
   * Converts any number to string

* `frozenset(seq=[])`
   * Returns  a new immutable set with iterable
   * usable as hash key

* `int(x[,radix])` 
   * Number or string to int
   * drop fractional part

* `list(seq=[])`
   * return new list object
   * if seq list create a copy
   * like `seq[:]`

* `long(x,[radix])`
   * Converts any number/string to long
   * like `int`

* `object()`
   * return new instance of fundmental type
   * no use except failing object referece equality checks

* `property(fget=None,fset=None,fdel=None,doc=None)`
   * Proerty descriptor within class body

* `reversed(seq)`
   * new iterator with original iterator reversed

* `set(seq=[])`
   * return new mutalbe set with same items

* `slice([start,]stop[,step])`
   * Returns a slice object of `start`,`stop` and `step` 
   * used as argument to `__getitem__`,`__setitem__`,`__delitem__`

* `staticmethod(function)`
   * Returns static method object inside class body

* `str(obj)`
  * returns readble string representation of `obj`
  * see `repr`

* `super(cls,obj)`
   *  Returns super-object of obj for calling super class methods
   * only inside methods
   
* `tuple(seq)`
   * same items as iterable ,but in a tuple

* `type(obj)`
   * Returns the left-most type object of `obj`
   * `InstanceType` type of legacy instances
   * See oop

* `xrange([start,]stop[,step=1])`
  * Read-only sequence object - arithmetic progression
  * slightly more efficient  than list

#### Built in functions

* Functions in the `__builtin__` module in alphabetical order.

* `__import__(module_name[,globals[,locals[,fromlist]]])`
   * load module given by string
   * globals - defualts to `globals()`
   * locals  - defaults to `locals()`

* `abs(x)`
  * absolute value
  * z complex then `z.imag**2+z.real**2`

* `all(seq)`
   * require all to be tre
   * short-circuiting operation
   * false if any in seq is false

* `any(seq)`
   * seq is any iterable
   * True if any is true

* `callable(obj)`
   * True if obj can be called
   * function, method,class,type or has `__call__`

* `chr(code)`
   * returns string of lenght 1 integer ascii/iso encoding

* `cmp(x,y)`
   * 0 when x equals y
   * -1 when x less than y
   * 1 when x greater than y

* `coerce(x,y)`
   * Returns coerce to common type - return a pair

* `compile(string,filename,kind)`
   * compile string return code object 
   * code obj usable by `exec` or `eval`
   * raise `SyntaxError` if not valid
   * kind should be 'eval' or 'exec' depnding on what will be done with call object

* `delattr(obj,name)`
   * Removes attr `name` from `obj`

* `dir([obj])`
   * returns sored list of all variables in scope
   * including from inheritence in `obj`

* `divmod(divident,divisor)`
   * `(quotient,remainder)` : Divides two numbers and returns a pair 

* `eval(expr,[globals[,locals]])
   * result of code object or string using globals and locals
   * or use current namespace
   * only expressions not statements

* `execfile(filename,[globals,[locals]])`

   {% highlight Python %}
   exec open(filename).read() in globals,locals 
   {% endhighlight %}

* `filter(func,seq)`
   * filter `seq` based on `predicate` funcion

     {% highlight Python %}
        [item for item in seq if func(item)]
     {% endhighlight %}

* `getattr(obj,name[,default])`

   * Return obj's attibute named by str `name`
   * `obj.ident` is `getattr(obj,'ident')`
   * `AttributeError` if no attribute

* `globals()`
   * `__dict__` returns dict of calling module

* `hasattr(obj,name)`
   * False if no attribte `name` in obj 

* `hash(obj)`
   * hash value of `obj`
   * if equal then hash must be equal

* `hex(x)`
   * Convert integer `x` to hex string repr

* `id(obj)`
   * integer denoting identy of `obj`
   * unique during obj life time
   * used for default obj comparison
   * used as default hashcode

* `input(prompt='')`
  * short cut for `eval(raw_input(prompt))`


* `intern(string)`
  * table of interned string
  * slight faster equality comparison can use the == comparison
  * garbage collector cannot recover interned strings


* `isinstance(obj,cls)`
  * True when `obj` instance of class `cls`
  * False otherwise

* `issubclass(cls1,cls2)`
   * true if direct or indirect subclass

* `iter(obj)` or `iter(func,sentinel)`
   * returns iterator
   * returns `obj.__iter__`
   * If sequence then uses `yield` to generate sequence
   * if called with sentinal then `item == sentinal` will raise `StopIteration`
   

* `len(container)`
  * Returns number of items in `container`
  * `__len__`

* `locals()`
   * a dict representing locals in current name space

* `map(func,seq,*seqs)`
  * applies function to every item in `seq` 
  * return list of results
  * None function results in tuple list

* `max(s,*args)
  * max of s or multiple arguments

* `pow(x,y[,z])`
  * x**y%z

* `range([start,]stop[,step=1])`
   * returns a list of integers in progression
   * `start+i*step` for i^th

* `raw_input(prompt='')`
   * `prompt` read from standard input 
   * remove `\n` from user input
   * EOFError on end of file.

* `reduce(func,seq,[,init])`
   * single value result of recursive reduction
   * init start value - if not specified uses first two argument of function
   * `func` two arg function -

* `reload(module)`
   * reloads and reinitialized module object

* `repr(obj)`
   * unambiguous string representation of object

* `setattr(obj,name,value)`
   * like obj.name=val

### Summary




---
