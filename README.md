# Aline

Align tables.

Use the Aline command to align tables like this:

col1;col2  ;col3;col4<br>
col1 ; col2;col3;col4;<br>
col1;col2;col3;col4;;

to become like this:

col1  ; col2   ; col3 ; col4<br>
col1  ;  col2  ; col3 ; col4 ;<br>
col1  ; col2   ; col3 ; col4 ;  ;<br>

(OMG!)

# Features

* No dependencies, written in vimscript
* Format using any separator
* Works with +1 byte chars

# Installation

* Plug
Add this to yout .vimrc

				call plug#begin()
				...
				Plug 'vinicius-toshiyuki/aline.git'
				...
				call plug#end()
and run

				:PlugInstall
after reopening Vim (or sourcing .vimrc again).

## Documentation

Just type 

				:Aline <sep> [<align>]
in normal mode with the cursor inside the block of text to be formatted, where \<sep\> is the separator (can be more than one character) and \<align\> is '-' for left, '=' center (default) or '+' for right alignment.

### TODO

* Doc
* Load code based on features (has textprop etc.)
* E685 Internal error

# License

MIT License.
