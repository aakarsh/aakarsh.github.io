--- 
layout: post 
title: Emacs/Evil-mode - A basic reference to using evil mode in Emacs.  
category: emacs 
published: true 
--- 


This cheat sheet will be used to provide a very basic reference to
using evil mode , vi emulation layer inside of emacs. For people who
would want to still have access to base emacs lisp layer while working
with vim's modal, noun verb editing features. Since evil-mode is
trying its best to emulate vim, this post might even serve as a basic
reference to vim's editing features for folks familiar emacs with
cursory (no pun intended) curiosity with vim.

### Introduction

Evil mode for emacs has been out for a while and is available to clone
from

```bash
     $ git clone https://github.com/emacs-evil/evil.git
```

It can be installed by cloning the above repo into your `.emacs.d/site-isp` and adding it to your `load-path`:

```emacslisp
     (add-to-list 'load-path "~/.emacs.d/site-lisp/evil")
     (require 'evil)
     (evil-mode 1)
```

#### Modes and States

If you eval the above code you will see a `<N>` in the mode line. This
reflects the fact that evil mode is running in vim's equivalent of
normal mode.  To revert from normal vim emulation to emacs use
`Ctrl-z`. This will put you back into emacs mode you are used
to. Typing `Ctrl-z` again will take you back into evil's vim normal
state. Other list of modes include:

       1. `<N>` - Normal state - for most vims commands.
       2. `<V>` - Visual state - Vim's rich selection sate.
       3. `<R>  - Replace state
       4. `<M>` - Motion state
       5. `<E>` - Emacs state - will be receptive to usual emacs key bindings in the buffer.


Each state has will have its own customization and bindings. Most of
the bindings can be seen in `evil-maps.el`.

Some of the key maps are
```emacslisp

evil-emacs-state-map 
evil-ex-completion-map
evil-inner-text-objects-map
evil-insert-state-map
evil-motion-state-map
evil-normal-state-map
evil-operator-state-map
evil-outer-text-objects-map
evil-read-key-map
evil-replace-state-map
evil-visual-state-map
evil-window-map
```

You can checkout `evil-commands.el` for list of examples of commands
that have already been defined. As you begin to look at the custom
macro `evil-define-motion` used while defining motion types you will
see most of the commands take in a count for the number of times the
motion needs to be performed. This is a basic implementation of vim's
numeric parameterization of motion commands [See references][1].

```emacslisp
;; Simpler way to exit to normal states than pressing <ESC>
(define-key evil-visual-state-map (kbd "C-c") 'evil-normal-state)
(define-key evil-insert-state-map (kbd "C-c") 'evil-normal-state)
(define-key evil-motion-state-map (kbd "C-e") nil)
(define-key evil-visual-state-map (kbd "C-c") 'evil-exit-visual-state)

```
### Additional plugins

While base evil is fairly feature complete I have found the following
additional plugins to be useful at times.

#### Key chord mode

Key chord mode will make it easier to jump between modes which becomes
important when we enter the world of modal editing.

```
(require 'key-chord)
(key-chord-mode 1)

(require 'key-seq)
(key-chord-mode 1)

(key-chord-define evil-normal-state-map ",," 'evil-force-normal-state)
(key-chord-define evil-visual-state-map ",," 'evil-change-to-previous-state)
(key-chord-define evil-insert-state-map ",," 'evil-normal-state)
(key-chord-define evil-replace-state-map ",," 'evil-normal-state)

(key-chord-define evil-normal-state-map "jk" 'evil-force-normal-state)
(key-chord-define evil-visual-state-map "jk" 'evil-change-to-previous-state)
(key-chord-define evil-insert-state-map "jk" 'evil-normal-state)
(key-chord-define evil-replace-state-map "jk" 'evil-normal-state)

(key-chord-define evil-normal-state-map "ee" 'evil-emacs-state)
(key-chord-define evil-insert-state-map "ee" 'evil-emacs-state)
(key-chord-define evil-emacs-state-map "ee" 'evil-normal-state)
```

This will allow one to jump back into normal mode using the `jk` keys
hit in quick succession. Also hitting `ee` keys quickly will allow one
to exit and leave default emacs mode in the buffer quickly.

### Vim Basics

For people new to vim's philosophy of using here is a quick recap.

#### Motion Commands

##### Character Level Motion :

```
+---+------+
| h | left |
| j | down |
| k | up   |
| l | right|
+---+------+
```

Are single character motions actions. All of which can be
prefixed with numeric arguments. Thus `7j` will move down 7
lines in normal mode.

##### Screen Level Motions :
```
+---------+------------------+
| Ctrl-F  | back screen      |
| Ctrl-f  | forward screen   |
| Ctrl-B  | page down        |
| Ctrl-b  | page up          |
| Ctrl-U  | half page up     |
| Ctrl-D  | half page down   |
| <n>G    | goto line n      |
| gg      | goto first line  |
| z.      | center to point  |
| zz      | center to point  |
| zt      | center point top |
| zb      | center bottom    |
+---------+------------------+
```


Motions can also be performed at the page level using `Ctrl-F` will move
back one screen full. Where as `Ctrl-U` will move up one half page-full.
Most motion commands can be given as targets to action commands like copy, paste
delete. Thus `yCtrl-F` will copy a screen full of text back from the cursor position.

Additionally `z.` , `zt`, `zb` can be used to center and scroll screen
top and bottom.


##### Line Level Motions:


```
+---+-----------------------------+
| 0 | beginning of line           |
| ^ | beginning of non black line |
| $ | end of line                 |
+---+-----------------------------+
```
      
To operate on current line some useful commands are shown
above. For example `y^` will copy the line to beginning current
line. and `y$` will copy it to the end of the current line. `yy`
will copy the current line. 


##### Line forward and backwards
```
| f{char} | forward search in line for {char}   |
| F{char} | backward search in line for {char}  |
| t{char} | forward search till {char} in line  |
| t{char} | forward search till {char} in line  |
| T{char} | backward search till {char}in line  |
| ;       | repeat last search forward          |
| ,       | repeat last search backward         | 

```

While working within lines it may be convenient to jump forward to a
character. `2f,` will jump forward to the second comma in a
line. Previous searches can be repeated forward and backwards using
comma and semicolons.


##### Sentence and Paragraph Motions

```
| ( | sentence back      |
| ) | sentence forward   |
| { | paragraph forward  |
| | | paragraph backward |

```

All sentence and paragraph motions can take in numeric arguments.

##### Search and Replace:
```
| /                  | search forward            |
| ?                  | search backwards          |
| n                  | continue search forward   |
| N                  | continue search backward  |
| :%/<pat>/<pat2>/gc | search and replace        |
```

`/` and `?` allows you to search forward and backwards also allowing
you to perform actions as you search. So `y?##` will copy text till
previous heading in markdown and `P` will allow you to paste after
current cursor position. One can perform search and replace using
`:%/<pat1>/<pat2>/g` which will replace every occurance of regex
`<pat1>` with `<pat2>`.


##### Marks
```
| m{char}  | store current position in {char} register  |
| '{char}  | jump to position stored in {char} register |
```

Much like emacs marks allow one to jump back and forth between a
history of positions. `ma` for example will set a mark in register
named `a`. One can then yank from current line to mark using `y'a`.
Notice the usage of single apostrophe works line wise whereas using
back-quote will act line wise.

##### Macro recordings

```
| q{char} | record following commands in {char} register |
| @{char} | re-run recorded commands from {char} register|
| .       | re-run last macro                            |
```

Much like emacs macros `qa` can start recording a macro into register
`a`.  After you are done recording press `q` to indicate its end. `@a`
can then be used to re-run recorded macro. `.` can be used to repeat
last run commands.



##### Why bother?

The basic idea is to create as rich of a structured language for
editing allowing us to instruct the editor at the level of
intentionality using composable editing abstractions.


### References

[1]: http://blog.jakubarnold.cz/2014/06/23/evil-mode-how-to-switch-from-vim-to-emacs.html

---
