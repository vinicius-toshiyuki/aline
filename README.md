# Aline

Align tables.

Use the Aline command to align tables like this:

col1;col2  ;col3;col4<br>
col1 ; col2;col3;col4;<br>
col1;col2;col3;col4;;

to become like this:

col1 ;col2  ;col3;col4<br>
col1 ;col2  ;col3;col4;<br>
col1 ;col2  ;col3;col4;;

or:

 col1; col2 ;col3;col4
 col1; col2 ;col3;col4;
 col1; col2 ;col3;col4;;

or:

 col1;  col2;col3;col4
 col1;  col2;col3;col4;
 col1;  col2;col3;col4;;

(OMG!)


\* imagine a nice cool gif showing text being updated automatically here \*

# Features

* No dependencies, works with only Vimscript
* Format using any separator
* Auto re-format modified text
* Python3 aligning option

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

It's only one command.

				:Aline <sep> [<options>]
in normal mode with the cursor inside the block of text to be formatted.

* \<sep\> is the separator (can be more than one character)
* \<options\>  can be an alignment ('-' for left (default), '=' for center or '+' for right), 'c' for clearing extra white spaces and a number to specify padding added to the separator.

The options must not contain white spaces and may be in any order.

## Customization

These variables can be set in your configuration file to change Aline's behavior:
 
* g:aline#use\_python3 (default=v:false): controls whether python3 is used (does not support options for now)
* g:aline#max\_line_count (default=100): max text block line size to keep auto updating when modified
* g:aline#separator\_padding (default=0): white space padding to be added to the separator
* g:aline#default\_alignment (default=-): alignment to be used if none was provided
* g:aline#update#hold\_time (default=500): time to not update after an update (prevents the update being counted as a modification and enter an update loop)
* g:aline#update#update\_time (default=750): time with no new changes needed before updating

### Performance

While the processing of the text can be very quick, when using to format a block of text too long it might take a few seconds to complete due to Vim's function call inside scripts taking a lot of time (or Vim's function calls overhead, which might be solved with Vimscript9 idk).

For this reason, auto update is disabled for long texts, but you can control this behavior (see above).

Vim throws an error when undoing changes because the use of text properties in older versions. It was fixed in a patch for v8.2, the newest version of Vim should work just fine. However, if you use Ubuntu and install Vim using apt or similar, you probably don't have the newest version and you might want to build Vim from source (it's not that difficult, look up Google).

# License

MIT License.
