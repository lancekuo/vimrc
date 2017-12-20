# Lance's Vim Notes

[TOC]

This repo stores my most used bundles and tricks.

## General

### Use system clipboard on Mac (:y+)

Have to install vim via `brew` to have the version of +clipboard enabled.
```bash
brew install vim jq
```

Ouch, do not forget `jq`, it is pretty awesome and little tiny swiss knife tool in restful world.

Take a jq tutorial [here](https://stedolan.github.io/jq/manual/).

## Bundle: [Vim-go](https://github.com/fatih/vim-go-tutorial/blob/master/README.md)

This bundle is pretty much everything I have built on.

1.  `:GoInstallBinaries` in Vim
2.  ​
3.  ​

| Action           | Sub actions                              | KeyMap    | Commands                                 | NOTE!                                    |
| ---------------- | ---------------------------------------- | --------- | ---------------------------------------- | ---------------------------------------- |
|                  | Next error in quickfix                   | <C-n>     |                                          |                                          |
|                  | Previous error in quick fix              | <C-m>     |                                          |                                          |
|                  | Close quick fix                          | <leader>a |                                          |                                          |
| Build            |                                          | <leader>b | (build_go_files)                         | run `:GoBuild` or `:GoTestCompile` based on the file we currently have |
| Test             |                                          | <leader>t | `:GoTest`                                |                                          |
|                  |                                          |           | `:GoTestFunc`                            |                                          |
| Coverage         |                                          | <leader>c | `:GoCoverageToggle`                      |                                          |
|                  |                                          | <leader>C | `:GOCoverageBrowser`                     |                                          |
| Go Import        |                                          |           | `:GoImport strings` `:GoImportAs str strings` |                                          |
| Go Drop          |                                          |           | `:GoDrop strings`                        |                                          |
|                  | Range, Inside the function               | if        |                                          | vif                                      |
|                  | Range, All the function                  | at        |                                          | vaf, includes comment                    |
| GoAlternate      | Jump between go and go test file         |           | `:GoAlternate` `:A` `:AV` `:AS` `:AT`    | `:AV` vSplit `:AS`Split `:AT`Tab         |
| Go To Definition |                                          | gd        |                                          |                                          |
|                  |                                          | gt        |                                          |                                          |
| Navigation       | Jump to previous position                | <C-o>     |                                          |                                          |
|                  | Jump to previous location                | <C-t>     |                                          |                                          |
|                  | Open GoDef history                       |           | `:GoDefStack`                            |                                          |
|                  | Clear GoDef history                      |           | `:GoDefStackClear`                       |                                          |
|                  | Jump to previous function                | [[        |                                          | v[[                                      |
|                  | Jump to next function                    | ]]        |                                          | 3[[                                      |
|                  | Looking for declaration                  |           | `:GoDecls` `:GoDeclsDir` `:GoDeclsClear` | Required `ctrlp`                         |
|                  | Looking for documentation                | K         | `:GoDoc`                                 |                                          |
|                  | Show identifier                          | <leader>i | `:GoInfo`                                | auto_type_info                           |
|                  | List package dependency files            |           | `:GoFiles`                               |                                          |
|                  | List all dependency files                |           | `:GoDeps`                                |                                          |
|                  | Find reference                           |           | `:GoReferrers`                           |                                          |
|                  | Show identifier advanced                 |           | `:GoDescribe`                            |                                          |
|                  | List interfaces the type is implementing |           | `:GoImplements`                          |                                          |
|                  | List possible error value of the type    |           | `:GoWhicherrs`                           |                                          |
|                  | Describe channels                        |           | `:GoChannelPeers`                        |                                          |
|                  | Who been called as the function?         |           | `:GoCallees`                             |                                          |
|                  | Who call the function?                   |           | `:GoCallers`                             |                                          |
|                  | List call stack from root                |           | `:GoCallstack`                           |                                          |
|                  | Change guru scope                        |           | `:GoGuruScope`                           | `:GoGuruScope ...`                       |
|                  | Refactory name                           |           | `:GoRename`                              | Change struct field                      |
|                  | Detect Free Vars                         |           | `:GoFreevars`                            | Select a range...                        |
|                  | AutoGen - Implement                      |           | `:GoImpl`                                | Put your cursor on top of `T` `:GoImpl io.ReadWriteCloser`<br />`:GoImpl b *B fmt.Stringer` |
```bash
let g:go_guru_scope = ["github.com/fatih/vim-go-tutorial"]
let g:go_guru_scope = ["..."]
let g:go_guru_scope = ["github.com/...", "golang.org/x/tools"]
let g:go_guru_scope = ["encoding/...", "-encoding/xml"]
```



## Bundle: Struct Split and Join

```Go
package main

type Foo struct {
	Name    string
	Ports   []int
	Enabled bool
}

func main() {
	foo := Foo{Name: "gopher", Ports: []int{80, 443}, Enabled: true}
}
```

*   `gS`: Move your cursor at `foo` in #10, spit it into multiple line.
*   `gJ`: Move your cursor at `foo`, join it into oneline.


## Bundle: Snippets

```Go
type foo struct {
	Message    string .
                      ^ put your cursor here
	Ports      []int
	ServerName string
}
```

In `insert` mode, type `json` and hit tab. You'll see that it'll be automatically expanded to valid field tag.

## Bundle: AutoClose

Matching the counterpart when you're typing.

## Bundle: Align

Help folks to align text, equals, declarations, tables, etc.

Usage:

* ``\t=`` Align assignments.
* ``\t,`` Align on commas.
* ``\tsp`` Align on whitespace.
* ``\acom`` Align comments.
* ``\Htd`` Align HTML tables.

## Bundle: Commentary

Makes commenting out your code with ease!

Usage:

*   `gcc` Comments/uncomments one line
*   `<Range>gc` Comments/uncomments a visual range

Command:

*   `:g/TODO/Commentary`
*   `:7,17Commentary`

## Bundle: Surround

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

## Bundle: Vimux/vimux-golang

You have to step into Tmux and start vim before you can run/test golang code in Tmux panel.

Usage:

*   `ra` :GolangTestCurrentPackage
*   `rw` :GolangTestFocused

## Notes

Vim-go has the functionality to go over the reference by using `:GoReferrer` but it just works for go language. There is another option we can use for the other languages, most are ruby and javascript.

https://github.com/eapache/starscope



## scriptease.vim

The tool box for creating vim plugins.