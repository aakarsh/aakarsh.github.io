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
* `:` denotes key workd symbol

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

###### Marker Type
* A position in a buffer.

###### Window Type
* Buffers are displayed in windows.

###### Frame Type
* Windows subdivide frames.

###### Terminal Type
* A terminal device displays frames.

###### Window Configuration Type
* Recording the way a frame is subdivided.

###### Frame Configuration Type
* Recording the status of all frames.

###### Process Type
* A subprocess of Emacs running on the underlying OS.

###### Stream Type
* Receive or send characters.

###### Keymap Type
* What function a keystroke invokes.

###### Overlay Type
* How an overlay is represented.

###### Font Type
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

##### Sequencing
* Evaluation in textual order.
* Special form `progn`

{% highlight emacs-lisp %}
(progn A B C ...)
{% endhighlight %}

* execute A , B, C in order
* body of Function defines implicity `progn`
* implicit in may control structures

{% highlight emacs-lisp %}
    (progn (print "The first form")
           (print "The second form")
           (print "The third form"))
         -| "The first form"
         -| "The second form"
         -| "The third form"
    => "The third form"
{% endhighlight %}

* `progn` : evaluates all forms returns value of final form
* `prog1` : This special form evaluates FORM1 and all of the FORMS, in textual order, returning the result of FORM1.
* `prog2` : This special form evaluates FORM1, FORM2, and all of the
  following FORMS, in textual order, returning the result of FORM2.

###### Conditionals
* `if`, `cond`, `when`, `unless`
* `if condition then-form else-forms...`
  * chooses between `then-form` and `else-forms` based on conditionals
  * else has implicit `progn`
  * unexecuted branches are not executed
  
{% highlight emacs-lisp %}
  (if nil
     (print 'true)
   'very-false)
{% endhighlight %}

* `when condition then-forms...`
  * variant of `if` without `else-forms`
  * implicit progn for `then-forms`

{% highlight emacs-lisp %}
(when CONDITION A B C)
;; equivalent to
(if CONDITION (progn A B C) nil)
{% endhighlight %}

* `unless condition forms...`
  * This is a variant of `if' where there is no THEN-FORM:

{% highlight emacs-lisp %}
(unless CONDITION A B C)
;; equivalent to
(if CONDITION nil
   A B C)
{% endhighlight %}

* `cond clause...`
  * `cond` chooses among an arbitrary number of alternatives.
  *  Each CLAUSE in the `cond` must be a list
  * The `CAR` of this list is the `CONDITION`
  * If the value of CONDITION is non-`nil`,
    * the clause "succeeds"; then `cond` evaluates its `BODY-FORMS`, 
    * the value of the last of `BODY-FORMS` becomes the value of the `cond`

{% highlight emacs-lisp %}
  (cond ((numberp x) x)
        ((stringp x) x)
        ((bufferp x)
         (setq temporary-hack x) ; multiple body-forms
         (buffer-name x))        ; in one clause
        ((symbolp x) (symbol-value x)))
{% endhighlight %}

* Use `t` for default clause which always passes.

{% highlight emacs-lisp %}
  (setq a 5)
    (cond ((eq a 'hack) 'foo)
          (t "default"))
  => "default"
{% endhighlight %}


###### Combining Conditions
* `and`, `or`, `not`.
####### `not condition`
* return `t` if condition is `nil` and `nil` otherwise
####### `and conditions...`
* ensures each condition is `t`
* short-circuits if any condition is `nil`
{% highlight emacs-lisp %}
(and (print 1) (print 2) nil (print 3))
     -| 1
     -| 2
=> nil

;; another example
(if (and (consp foo) (eq (car foo) 'x))
    (message "foo is a list starting with x"))
{% endhighlight %}

####### `or conditions...`

* Requires at least one of the conditions to be true
* short cirquits on first non-`nil` condition
* value returned is first non-`nil`
* else returns nil

{% highlight emacs-lisp %}
;; test x is nil or integer 0
(or (eq x nil) (eq x 0))
{% endhighlight %}


###### Iteration

####### `while condition forms...`
* while  `non-nil` condition evaluation,  evaluate forms in textual order
* exit on `nil` condition or `throw`

{% highlight emacs-lisp %}
 (setq num 0)
      => 0
 (while (< num 4)
   (princ (format "Iteration %d." num))
   (setq num (1+ num)))
      -| Iteration 0.
      -| Iteration 1.
      -| Iteration 2.
      -| Iteration 3.
      => nil
{% endhighlight %}

* support for `repeat` until loop available

####### `dolist (var list [result]) body...`
* execute body for each element of `list`
* `var` hods the current element
* returns value of `result` or `nil` if result ommited
{% highlight emacs-lisp %}
(defun reverse (list)
  (let (value)
    (dolist (elt list value)
      (setq value (cons elt value)))))
{% endhighlight %}

####### `dotimes (var count [result]) body...`
* evaluate body from `[0,count)`
* return `result`

{% highlight emacs-lisp %}
;; lol
(dotimes (i 100)
  (insert "I will not obey absurd orders\n"))
{% endhighlight %}


###### Nonlocal Exits
* Transfer control from one point to another
* Unbind all variable bindings made by exited constructs

####### Catch and Throw
* Allow nonlocal exit on request
{% highlight emacs-lisp %}
(defun foo-outer ()
  (catch 'foo
    (foo-inner)))

(defun foo-inner ()
  ...
  (if x
      (throw 'foo t))
  ...)
{% endhighlight %}

* throw when executed tranfers to corresponding catch
* second argument of throw is return value of `catch`
* first argument used to find matching catch `eq` comparision
* innermost matching catch takes precedence
* If binding constructs like `let` exited then variables get unbund
* `throw` restores buffers and position saved by `save-restriction`
* `throw` restores window selection saved by `save-window-excursion`
* `lexical` nesting unnecessary only needs to be chronologically after `catch`
* `emacs-lisp` uses only `throw` for non-local exits

####### `catch tag body...`
* extablishes a return point distinguished by tag
* `tag` can be anything but `nil`
* evaluate `body` in textual order
* if corresponding `throw` executed, exit with `throw` second argument as value

####### `throw tag value`

* return to previously established `catch`
* if multiple `tag` matches use innermost
* `value` becomes value returned by `catch`

####### Examples of Catch

* Using `catch` `throw` to exit a double nested loop

{% highlight emacs-lisp %}
;; Example exiting a double nested loop
(defun search-foo ()
  (catch 'loop
    (let ((i 0))
      (while (< i 10)
        (let ((j 0))
          (while (< j 10)
            (if (foo i j)
                (throw 'loop (list i j)))
            (setq j (1+ j))))
        (setq i (1+ i))))))
{% endhighlight %}


###### Errors



###### Cleanups

#### Variables

* Global Variables

  * simplest definition
  * Instantiate a variable throughout the lifetime of the system

{% highlight emacs-lisp %}
(setq x '(a b))
{% endhighlight %}

  * Gives x the value `(a b)`
  * `setq` special form
  * does not evaluate  first argument
  * second argument evaluated and bound to first
  

* Constant Variables
  * certain symbols that evaluate to themselves
  * `nil` and `t`
  * `:` symbols tarting with `:`

  * `keywordp object`
    * object is symbol name starts with `:`

* Local Variables
  * values which are scoped
  * argument variables toa function
  * only in effect during scope
  * allows for nesting and superceding of values
  * default scoping `dynamic scoping`
  * `dynamic scoping` current value is the most recent one created regardless of `lexical placement`
  * allows cusomtization of all variables in scope
  
  * `let (bindings...)  forms..`
     * sets up local bindings
     * returns value of last form in `forms`
     * `binding` is either `(val)` where `val` gets bound to `nil`
     * or `(var value)` where variable is bound to value
{%  highlight  emacs-lisp %}
(setq y 2)
     => 2
;; value of y gets overriden     
(let ((y 1)
      (z y))
  (list y z))
  => (1 2)
{% endhighlight %}

  * `let* (bindings...) forms...`
     * like let but binding available right after computation
     * expression in next binding can represent previous binding

{%  highlight  emacs-lisp %}
(setq y 2)
     => 2

(let* ((y 1)
       (z y))    ; Use the just-established value of `y'.
  (list y z))
     => (1 1)     
{% endhighlight %}

* Void Variables
  * if symbol has unassigned value cell
  * unassigned value cell not the same as `nil` assigned
  * evaluating results in `void-variable` error


  * `makeunbound symbol`
     * empties out value cell making variable void
     * return symbol
     * if symbol has `dynamic local binding` unbinding only has effect over last shadowed local

{% highlight emacs-lisp %}
(setq x 1)               ; Put a value in the global binding.
     => 1
(let ((x 2))             ; Locally bind it.
  (makunbound 'x)        ; Void the local binding.
  x)
error--> Symbol's value as variable is void: x
x                        ; The global binding is unchanged.
     => 1

(let ((x 2))             ; Locally bind it.
  (let ((x 3))           ; And again.
    (makunbound 'x)      ; Void the innermost-local binding.
    x))                  ; And refer: it's void.
error--> Symbol's value as variable is void: x

(let ((x 2))
  (let ((x 3))
    (makunbound 'x))     ; Void inner binding, then remove it.
  x)                     ; Now outer `let' binding is visible.
     => 2
{% endhighlight %}

  * `boundp variable`
     * returns `t` if `variable` is not void `nil` otherwise

{% highlight emacs-lisp %}
(boundp 'abracadabra)          ; Starts out void.
     => nil
(let ((abracadabra 5))         ; Locally bind it.
  (boundp 'abracadabra))
     => t
(boundp 'abracadabra)          ; Still globally void.
     => nil
(setq abracadabra 5)           ; Make it globally nonvoid.
     => 5
(boundp 'abracadabra)
     => t
{% endhighlight %}

  
* Defining Variables
  * `defconst` , `defvar` - signal intent of varable usage
  * `defconst` used for signaling but emacs allows you to change value defined as const
  * `defconst` unconditionally initializes a variable
  * `defvar`   initializes only if variable is originally void
  * `defcustom` defines a customizable variable (uses `defvar` internally)
  
  * `defvar symbol [value [doc-string]]`
    * defines `symbol` as a variable
    * `symbol` is not evaluated
    * variable marked as special always `dynamically bound`
    * if `symbol` already has a value then the `value` is not even evaluated
    * if `symbol` has buffer local value then `defvar` acts on buffer-independent value
    * not current `(buffer-local)` binding
    * `C-M-x`  `eval-defun` force setting variable unconditionally without testing
    
    {% highlight emacs-lisp %}
    (defvar bar 23
            "The normal weight of a bar.")
               => bar
    {% endhighlight %}

  * `defconst symbol value [doc-string]`
    * defines symbol and initializes it
    * establishes global value for the symbol
    * marked as `special` always dynamically bound
    * marks the variable as `risky`
    * sets the buffer independent value
    
* Tips for Defining
  * Some naming conventions as follows (defined by suffix) :
    * `-function` : defines functions
    * `-functions` : The value is a list of functions
    * `-hook` : variable is a hook
    * `-form` : The value is a form
    * `-forms`: The value is a list of forms
    * `-predicate` : The value is a predicate boolean expression
    * `-flag` : value significant only if not nil
    * `-program` : The value is a program name
    * `-command` : the value is a shell command
    * `-switches`: value is a list of command switches


  * For complicated initializations put it all in a `defvar`
{% highlight emacs-lisp %}
(defvar my-mode-map
       (let ((map (make-sparse-keymap)))
         (define-key map "\C-c\C-a" 'my-command)
         ...
         map)
       DOCSTRING)
{% endhighlight %}
  * file reloading will initialize it the first time but not second time unless `C-M-x` is used

* Accessing Variables
  * `symbaol-value symbol`
    * returns value in `symbol` value cell
    * value cell holds current (dynamic) value
    * if variable is void throws `void-variable` error

{% highlight emacs-lisp %}
 (let ((abracadabra 'foo))
   (symbol-value 'abracadabra))
      => foo
{% endhighlight %}

     
* Setting Variables
  * `setq [symbol form]...`
    * symbol given value result of form
    * does not evaluate symbol
    * argument gets automatically quoted
{% highlight emacs-lisp %}
(setq x (1+ 2))
     => 3
     
(let ((x 5))
  (setq x 6)        ; The local binding of `x' is set.
  x)
     => 6
x                   ; The global value is unchanged.
     => 3
{% endhighlight %}

* `set symbol value`
  * puts `VALUE` in the value cell of `symbol`
  * symbol is evaluated to obtain the symbol to set
  * when dynamic binding is in effect same as `setq`
  * when variable is lexically bound `set` affects `dynamic value`
  * `setq` affects the current `lexical value`
  
{% highlight emacs-lisp %}
(set one 1)
error--> Symbol's value as variable is void: one
(set 'one 1)
     => 1
(set 'two 'one)
     => one
(set two 2)         ; `two' evaluates to symbol `one'.
     => 2
one                 ; So it is `one' that was set.
     => 2
(let ((one 1))      ; This binding of `one' is set,
  (set 'one 3)      ;   not the global value.
  one)
     => 3
one
     => 2
{% endhighlight %}


* Scoping Rules for Variable Bindings
  * 
  * 
  
* Buffer Local Variables

* File Local Variables

* Directory Local Variables

* Variable Aliases

* Variables with Restricted Values

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
