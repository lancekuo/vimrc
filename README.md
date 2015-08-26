### align
Help folks to align text, equals, declarations, tables, etc.

Usage:

* ``\t=`` Align assignments.
* ``\t,`` Align on commas.
* ``\tsp`` Align on whitespace.
* ``\acom`` Align comments.
* ``\Htd`` Align HTML tables.

### surround
Delete/change/add parentheses/quotes/XML-tags/much more with ease.

Usage:

* Normal mode:
 * ``cs<$1><$2>`` Replace(c) surrounding(s) from $1 to $2. 
  * ``cs'"`` Replace single quotes with double quotes. 
  * ``cs'<q>`` Replace single quotes with <q/> tags.
  * ``cst"`` Replace tags with double quotes.
 * ``ds<$1>`` Delete(d) $1 surrounding.
  * ``ds"`` Delete surrounding double quotes.
 * ``yss<$1>`` Wrap entire line with $1.
* Visual mode:
 * ``S<$1>`` Wrap with $1.
  * ``S<p class="foo">`` 