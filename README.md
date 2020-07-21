# Aline

Align tables.

Use the Aline command to align tables like this:

col1;col2  ;col3;col4
col1 ; col2;col3;col4;
col1;col2;col3;col4;;

to become like this:

col1  ; col2   ; col3 ; col4
col1  ;  col2  ; col3 ; col4 ;
col1  ; col2   ; col3 ; col4 ;  ;

(OMG!)

# Features

* No dependencies, written in vimscript
* Format using any separator
* Works with 1+ byte chars

# Installation

* Plug
Add this to yout .vimrc

				call plug#begin()
				...
				Plug 'vinicius-toshiyuki/aline'
				...
				call plug#end()
and run
				:PlugInstall
after reopening Vim (or sourcing .vimrc again).

## Usage


## Documentation

Only one command, chap, ain't much to document. ツ

Just type 
				:Aline <sep>
in normal mode with the cursor inside the block of text to be formatted, where \<sep\> is the separator (can be more than one character).

### TODO

* Format the entire file
* Doc

# License

MIT License.
