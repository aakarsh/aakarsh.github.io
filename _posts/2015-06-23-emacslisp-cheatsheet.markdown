---
layout: post
title: Programming Language Reference - EmacsLisp (draft)
category:  emacs
published: true
---

In this post we explore the extension language for the powerful yet
very arcane 'text editor' emacs. Trying to keep track of various
features of emacs lisp along with useful extensions. The main
reference for his cheat sheet is the elisp manual which comes with you
installation of emacs. See `(info "elisp")`

### The Emacs Lisp

#### Lisp Data Types

* Lisp `object` data maintained by lisp
* `objects` belongs to at least one type
* Fundamental types example
  * `integer`
  * `float`
  * `cons`
  * `symbol`
  * `string`
  * `vector`
  * `hash-table`
  * `subr`
  * `byte-code function`
  * `buffer (editor specific types)`
* `objects` know their types variables point to objects

##### Printed Representation and Read Syntax
* Format from Lisp printer `prin1`
* printed representation also read syntax
* For certain objects dont have read syntax
* Start with `#<`
* Example

{% highlight EmacsLisp %}
(current-buffer)
  => #<buffer objects.texi>
{% endhighlight %}

* `invalid-read-syntax` if starts with `#<`
##### Comments
* start with `;`
* continues till end of line
* discarded by `Lisp reader`
* `#@COUNT` skips next `COUNT` characters

##### Programmer Types

###### Integer Types
* `-536870912` to `536870911` or `2^29` to `2^29 -1`
* read syntax
  * optional sign
  * optinoal period at end
* For too large read as floating point number

###### Floating Point Type

###### Character Type
###### Symbol Type
* 

###### Sequence Type
###### Cons Cell Type
###### Array Type
###### String Type
###### Vector Type
###### Char-Table Type
###### Bool-Vector Type
###### Hash Table Type
###### Function Type
###### Macro Type
###### Primitive Function Type
###### Byte-Code Type
###### Autoload Type

##### Programmer Types

####### Buffer Type
* The basic object of editing.
####### Marker Type
* A position in a buffer.
####### Window Type
* Buffers are displayed in windows.
####### Frame Type
* Windows subdivide frames.
####### Terminal Type
* A terminal device displays frames.
####### Window Configuration Type
* Recording the way a frame is subdivided.
####### Frame Configuration Type
* Recording the status of all frames.
####### Process Type
* A subprocess of Emacs running on the underlying OS.
####### Stream Type
* Receive or send characters.
####### Keymap Type
* What function a keystroke invokes.
####### Overlay Type
* How an overlay is represented.
####### Font Type
* Fonts for displaying text.

#### Numbers
#### Strings and Characters

#### Lists
###### Cons Cells
* How lists are made out of cons cells.
###### List-related Predicates
* Is this object a list?  Comparing two lists.
###### List Elements
* Extracting the pieces of a list.
###### Building Lists
* Creating list structure.
###### List Variables
* Modifying lists stored in variables.
###### Modifying Lists
* Storing new pieces into an existing list.
###### Sets And Lists
* A list can represent a finite mathematical set.
###### Association Lists
* A list can represent a finite relation or mapping.

#### Sequences Arrays Vectors
###### Sequence Functions
* Functions that accept any kind of sequence.
###### Arrays
* Characteristics of arrays in Emacs Lisp.
###### Array Functions
* Functions specifically for arrays.
###### Vectors
* Special characteristics of Emacs Lisp vectors.
###### Vector Functions
* Functions specifically for vectors.
###### Char-Tables
* How to work with char-tables.
###### Bool-Vectors
* How to work with bool-vectors.
###### Rings
* Managing a fixed-size ring of objects.

#### Hash Tables

###### Creating Hash
* Functions to create hash tables.
###### Hash Access
* Reading and writing the hash table contents.
###### Defining Hash
* Defining new comparison methods.
###### Other Hash
* Miscellaneous.

#### Symbols
#### Evaluation
#### Control Structures
#### Variables
#### Functions
#### Macros
#### Customization
#### Loading
#### Byte Compilation
#### Advising Function
#### Debugging
#### Read and Print
#### Minibuffers
#### Command Loop
#### Keymaps
#### Modes
#### Files
#### Buffers
#### Windows
#### Frames
#### Positions
#### Markers
#### Text
#### Searching and Matching
#### Syntax Tables

#### Processes 
##### Suprocess Creation
##### Shell Arguments
##### Syncronous Processes 
##### Asynchronous Processes
##### Deleting Processes
##### Process Information
##### Input to Processes
##### Signals to Processes

#### Display
#### System Interface

### Summary

Unfortunately with great power comes great responsibility. Managing
emacs can be something that requires great care and attention as well
as requires openness to hacking at its internals. Perhaps this
arcane editor is on its last legs or perhaps it is like a phoenix
about to be reborn. Only time will be the judge.

---
