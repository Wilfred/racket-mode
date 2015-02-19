# Reference

- [Commands](#commands)
    - [Run](#run)
    - [Test](#test)
    - [Eval](#eval)
    - [Visit](#visit)
    - [Learn](#learn)
    - [Edit](#edit)
    - [Macro expand](#macro-expand)
- [Variables](#variables)
    - [General](#general)
    - [REPL](#repl)
    - [Other](#other)
- [Faces](#faces)

# Commands

## Run

### racket-run
<kbd>&lt;f5&gt;</kbd> or <kbd>C-c C-k</kbd>

Save and evaluate the buffer in REPL, much like DrRacket's Run.

When you run again, the file is evaluated from scratch -- the
custodian releases resources like threads and the evaluation
environment is reset to the contents of the file. In other words,
like DrRacket, this provides the predictability of a "static"
baseline, plus some interactive exploration.

With a C-u prefix, uses errortrace for improved stack traces.
Otherwise follows the [`racket-error-context`](#racket-error-context) setting.

Output in the `*Racket REPL*` buffer that describes a file and
position is automatically "linkified". To visit, move point
there and press <kdb>RET</kbd>, mouse click, or use a
Compilation mode command such as C-x ` (next error).
Examples of such text include:

- Racket error messages.
- `rackunit` test failure location messages.
- `print`s of `#<path>` objects.

In the `*Racket REPL*` buffer you can issue some special
commands. Some of them are the foundation for Emacs commands.
Others are available only as a command in the REPL.

- `,help`: See these commands.

- `,top`: Reset the REPL to "no file" (i.e. a base namespace).

- `,run <file>`: Run the file. What [`racket-run`](#racket-run) uses. Either
  `"file.rkt"` is `file.rkt` OK.

- `,exit`: Exit Racket. Handy in a `#lang` like r5rs where the
  `exit` procedure is not available. (Regardless of how Racket
  exits, the `*Racket REPL*` buffer is not killed and is reused
  if you [`racket-run`](#racket-run) again.)

- `,doc <symbol-or-string>`: Look for `<symbol-or-string>` in
  Racket's documentation. What [`racket-doc`](#racket-doc) uses.

- `,cd`, `,pwd`: Change and show [`current-directory`].

- `,log` controls the log output level, overall, as well as for
  specific named loggers created with [`define-logger`].

    - `,log`: Show the current levels.

    - `,log <logger> <level>`: Set a logger to show at least level
      `none`, `fatal`, `error`, `warning`, `info`, or `debug`.

    - `,log <logger> <level>`: Set a logger to use the default
      level.

    - `,log <level>`: Set the default level for all other loggers
      not specified individually.


### racket-racket
<kbd>&lt;C-M-f5&gt;</kbd>

Do `racket <file>` in `*shell*` buffer.

### racket-profile
<kbd>M-x racket-profile</kbd>

Get profiling results in a [`racket-profile-mode`](#racket-profile-mode) buffer.

key             binding
---             -------

RET		racket--profile-visit
,		racket--profile-sort
g		racket--profile-refresh
n		racket--profile-next
p		racket--profile-prev
q		racket--profile-quit



Run the buffer with profiling instrumentation enabled.

You may evaluate additonal expressions in the REPL. They will be
profiled, too. In that case use [`racket--profile-refresh`](#racket--profile-refresh) to see
the updated results.

Caveat: Only .rkt files can be instrumented. You may need to
delete compiled/*.zo files.

## Test

### racket-test
<kbd>&lt;C-f5&gt;</kbd>

Do `(require (submod "." test))` in `*Racket REPL*` buffer.

See also:
- [`racket-fold-all-tests`](#racket-fold-all-tests)
- [`racket-unfold-all-tests`](#racket-unfold-all-tests)


### racket-raco-test
<kbd>M-x racket-raco-test</kbd>

Do `raco test -x <file>` in `*shell*` buffer.
To run <file>'s `test` submodule.

## Eval

### racket-send-region
<kbd>C-c C-r</kbd>

Send the current region (if any) to the Racket REPL.

### racket-send-definition
<kbd>C-M-x</kbd>

Send the current definition to the Racket REPL.

### racket-send-last-sexp
<kbd>C-x C-e</kbd>

Send the previous sexp to the Racket REPL.

## Visit

### racket-visit-definition
<kbd>M-.</kbd>

Visit definition of symbol at point.

Use M-x racket-unvisit to return.

Note: Only finds symbols defined in the current namespace. You
may need to invoke [`racket-run`](#racket-run) on the current buffer, first.

Note: Only visits the definition of module level identifiers (i.e.
things for which Racket's `identifier-binding` function returns a
list, as opposed to `'lexical`).

Note: If the definition is from Racket's `#%kernel` module, it
will tell you so but won't visit the definition site.

### racket-visit-module
<kbd>C-M-.</kbd>

Visit definition of module at point, e.g. net/url or "file.rkt".

Use M-x racket-unvisit to return.

Note: Only works if you've [`racket-run`](#racket-run) the buffer so that its
namespace is active.

See also: [`racket-find-collection`](#racket-find-collection).

### racket-unvisit
<kbd>M-,</kbd>

Return from previous [`racket-visit-definition`](#racket-visit-definition) or [`racket-visit-module`](#racket-visit-module).

### racket-open-require-path
<kbd>C-c C-x C-f</kbd>

Like Dr Racket's Open Require Path.

Type (or delete) characters that are part of a module path name.
"Fuzzy" matches appear. For example try typing "t/t/r".

Choices are displayed in a vertical list. The current choice is
at the top, marked with "->".

- C-n and C-p move among the choices.
- RET on a directory adds its contents to the choices.
- RET on a file exits doing `find-file`.
- C-g aborts.

Note: This requires Racket 6.1.1.6 or newer. Otherwise it won't
error, it will just never return any matches.

### racket-find-collection
<kbd>M-x racket-find-collection</kbd>

Given a collection name, try to find its directory and files.

Takes a collection name from point (or, with a prefix, prompts you).

If only one directory is found, `ido-find-file-in-dir` lets you
pick a file there.

If more than one directory is found, `ido-completing-read` lets
you pick one, then `ido-find-file-in-dir` lets you pick a file
there.

Note: This requires the `raco-find-collection` package to be
installed. To install it, in `shell` enter:

    raco pkg install raco-find-collection

Tip: This works best with `ido-enable-flex-matching` set to t.
Also handy is the `flx-ido` package from MELPA.

See also: [`racket-visit-module`](#racket-visit-module) and [`racket-open-require-path`](#racket-open-require-path).

## Learn

### racket-describe
<kbd>C-c C-.</kbd>

Describes the function at point in a `*Racket Describe*` buffer.

The intent is to give a quick reminder or introduction to a
function, regardless of whether it has installed documentation --
and to do so within Emacs, without switching to a web browser
window.

This buffer is also displayed when you use company-mode and press
<kbd>C-h</kbd> in the pop up completion list.

- If the function has installed Racket documentation, then a
  simplified version of the HTML is presented in the buffer,
  including the "blue box", documentation prose, and examples.

- Otherwise, the function's signature -- e.g. `(name arg-1-name
  arg-2-name)` is displayed. If the function has a Typed Racket
  type, or has a contract, then that is also displayed.

You can quit the buffer by pressing <kbd>q</kbd>. Also, at the
bottom of the buffer are Emacs buttons (which you may navigate among
using <kbd>TAB</kbd> for visiting the definition or opening the full
browser documentation (if any).

### racket-doc
<kbd>C-c C-d</kbd>

View documentation of the identifier or string at point.

Uses the default external web browser.

If point is an identifier required in the current namespace that
has help, opens the web browser directly at that help
topic. (i.e. Uses the identifier variant of racket/help.)

Otherwise, opens the 'search for a term' page, where you can
choose among multiple possibilities. (i.e. Uses the string
variant of racket/help.)

With a C-u prefix, prompts for the identifier or quoted string,
instead of looking at point.

## Edit

### racket-fold-all-tests
<kbd>C-c C-f</kbd>

Fold (hide) all test submodules.

### racket-unfold-all-tests
<kbd>C-c C-u</kbd>

Unfold (show) all test submodules.

### racket-tidy-requires
<kbd>M-x racket-tidy-requires</kbd>

Make a single top-level `require`, modules sorted, one per line.

All top-level `require` forms are combined into a single form.
Within that form:

- A single subform is used for each phase level, sorted in this
  order: for-syntax, for-template, for-label, for-meta, and
  plain (phase 0).

  - Within each level subform, the modules are sorted:

    - Collection path modules -- sorted alphabetically.

    - Subforms such as `only-in`.

    - Quoted relative requires -- sorted alphabetically.

At most one module is listed per line.

Note: This only works for requires at the top level of a source
file using `#lang`. It does *not* work for `require`s inside
`module` forms.

See also: [`racket-trim-requires`](#racket-trim-requires) and [`racket-base-requires`](#racket-base-requires).

### racket-trim-requires
<kbd>M-x racket-trim-requires</kbd>

Like [`racket-tidy-requires`](#racket-tidy-requires) but also deletes unused modules.

Note: This only works when the source file can be evaluated with
no errors.

Note: This only works for requires at the top level of a source
file using `#lang`. It does *not* work for `require`s inside
`module` forms.

See also: [`racket-base-requires`](#racket-base-requires).

### racket-base-requires
<kbd>M-x racket-base-requires</kbd>

Change from `#lang racket` to `#lang racket/base`.

Adds explicit requires for modules that are provided by `racket`
but not by `racket/base`.

This is a recommended optimization for Racket applications.
Avoiding loading all of `racket` can reduce load time and memory
footprint.

Also, as does [`racket-trim-requires`](#racket-trim-requires), this removes unneeded
modules and tidies everything into a single, sorted require form.

Note: This only works when the source file can be evaluated with
no errors.

Note: This only works for requires at the top level of a source
file using `#lang`. It does *not* work for `require`s inside
`module` forms.

Note: Currently this only helps change `#lang racket` to
`#lang racket/base`. It does *not* help with other similar conversions,
such as changing `#lang typed/racket` to `#lang typed/racket/base`.

### racket-newline-and-indent
<kbd>RET</kbd>

Do `newline` and [`racket-indent-line`](#racket-indent-line).

### racket-indent-or-complete
<kbd>TAB</kbd>

Try `indent-for-tab-command` then `completion-at-point`.

Call `indent-for-tab-command`. If did not change the indentation
or move point to `beginning-of-line-text`, and if point is
in/after at least 3 word/symbol characters, then call
`completion-at-point`.

Note: Completion only finds symbols in the current namespace. You
may need to [`racket-run`](#racket-run) the buffer, first.

### racket-indent-line
<kbd>M-x racket-indent-line</kbd>

Indent current line as Racket code.

This behaves like `lisp-indent-line`, except that whole-line
comments are treated the same regardless of whether they start
with single or double semicolons.

- Automatically indents forms that start with `begin` in the usual
  way that `begin` is indented.

- Automatically indents forms that start with `def` or `with-` in the
  usual way that `define` is indented.

- Has rules for many specific standard Racket forms.

To extend, use your Emacs init file to

    (put SYMBOL 'racket-indent-function INDENT)

where `SYMBOL` is the name of the Racket form (e.g. `'test-case`)
and `INDENT` is an integer or the symbol `'defun`. When `INDENT`
is an integer, the meaning is the same as for
`lisp-indent-function` and `scheme-indent-function`: Indent the
first `n` arguments specially and then indent any further
arguments like a body.

For example in your `.emacs` file you could use:

    (put 'test-case 'racket-indent-function 1)

to change the indent of `test-case` from this:

    (test-case foo
               blah
               blah)

to this:

    (test-case foo
      blah
      blah)


### racket-smart-open-bracket
<kbd>[</kbd>

Automatically insert a `(` or a `[` as appropriate.

When [`racket-smart-open-bracket-enable`](#racket-smart-open-bracket-enable) is nil, this simply
inserts `[`. Otherwise, this behaves like the "Automatically
adjust opening square brackets" feature in Dr. Racket:

By default, inserts a `(`. Inserts a `[` in the following cases:

  - `let`-like bindings -- forms with `let` in the name as well
    as things like `parameterize`, `with-handlers`, and
    `with-syntax`.

  - `case`, `cond`, `match`, `syntax-case`, `syntax-parse`, and
    `syntax-rules` clauses.

  - `for`-like bindings and `for/fold` accumulators.

When the previous s-expression in a sequence is a compound
expression, uses the same kind of delimiter.

To force insert `[`, use `quoted-insert`: C-q [.

Combined with [`racket-insert-closing-bracket`](#racket-insert-closing-bracket), this means that
you can press the unshifted `[` and `]` keys to get whatever
delimiters follow the Racket conventions for these forms. (When
`paredit-mode` is active, you need not even press `]`. This calls
`paredit-open-round` or `paredit-open-square` so that paredit
will work as usual.)

### racket-cycle-paren-shapes
<kbd>C-c C-p</kbd>

In an s-expression, move to the opening, and cycle the shape among () [] {}

### racket-backward-up-list
<kbd>C-M-u</kbd>

Like `backward-up-list` but also works when point is in a string literal.

## Macro expand

### racket-expand-region
<kbd>C-c C-e r</kbd>

Like [`racket-send-region`](#racket-send-region), but macro expand.

With C-u prefix, expands fully.

Otherwise, expands once. You may use [`racket-expand-again`](#racket-expand-again).

### racket-expand-definition
<kbd>C-c C-e x</kbd>

Like [`racket-send-definition`](#racket-send-definition), but macro expand.

With C-u prefix, expands fully.

Otherwise, expands once. You may use [`racket-expand-again`](#racket-expand-again).

### racket-expand-last-sexp
<kbd>C-c C-e e</kbd>

Like [`racket-send-last-sexp`](#racket-send-last-sexp), but macro expand.

With C-u prefix, expands fully.

Otherwise, expands once. You may use [`racket-expand-again`](#racket-expand-again).

### racket-expand-again
<kbd>C-c C-e a</kbd>

Macro expand again the previous expansion done by one of:
- [`racket-expand-region`](#racket-expand-region)
- [`racket-expand-definition`](#racket-expand-definition)
- [`racket-expand-last-sexp`](#racket-expand-last-sexp)
- [`racket-expand-again`](#racket-expand-again)

### racket-gui-macro-stepper
<kbd>M-x racket-gui-macro-stepper</kbd>

Run the DrRacket GUI macro stepper.

Runs on the active region, if any, else the entire buffer.

EXPERIMENTAL: May be changed or removed.

BUGGY: The first-ever invocation might not display a GUI window.
If so, try again.

# Variables

> Note: You may also set these via Customize.

## General

### racket-racket-program
Pathname of the racket executable.

### racket-raco-program
Pathname of the raco executable.

### racket-memory-limit
Terminate the Racket process if memory use exceeds this value in MB.
Changes to this value take effect upon the next [`racket-run`](#racket-run).

Caveat: This uses Racket's `custodian-limit-memory`, which does
not enforce the limit exactly. Instead, the program will be
terminated upon the first garbage collection where memory exceeds
the limit (maybe by a significant amount).

### racket-error-context
The level of context used for [`racket-run`](#racket-run) error stack traces.

Each level improves stack trace information, but causes your
program to run more slowly.

  - 'low corresponds to `compile-context-preservation-enabled`
    `#f`.

  - 'medium corresponds to `compile-context-preservation-enabled`
    `#t`, which disables some optimizations like inlining.

  - 'high corresponds to `compile-context-preservation-enabled`
    `#t` and to use of `errortrace`, which heavily instruments
    your code and therefore may be significantly slower.

  - 'profile corresponds using all of
    `compile-context-preservation-enabled`, `errortrace`,
    `instrumenting-enabled`, `profiling-enabled`. For use with
    [`racket-profile`](#racket-profile).

Tip: Regardless of this setting, you can enable full errortrace
for a specific [`racket-run`](#racket-run) using a C-u prefix.

## REPL

### racket-history-filter-regexp
Input matching this regexp are not saved on the history list.
Defaults to a regexp ignoring all inputs of 0, 1, or 2 letters.

### racket-images-inline
Whether to display inline images in the REPL.

### racket-images-keep-last
How many images to keep in the image cache.

### racket-images-system-viewer
Which system image viewer program to invoke upon M-x
 [`racket-view-last-image`](#racket-view-last-image).

### racket-pretty-print
Use pretty-print instead of print in REPL.

### racket-wait-for-prompt-timeout
When REPL starts Racket process, how long to wait for Racket prompt.

## Other

### racket-indent-curly-as-sequence
Indent `{}` with items aligned with the head item?
This is indirectly disabled if [`racket-indent-sequence-depth`](#racket-indent-sequence-depth) is 0.
This is safe to set as a file-local variable.

### racket-indent-sequence-depth
To what depth should [`racket--align-sequence-to-head`](#racket--align-sequence-to-head) search.
This affects the indentation of forms like `` '()` `() #() `` --
and `{}` if [`racket-indent-curly-as-sequence`](#racket-indent-curly-as-sequence) is t -- but not
`` #'() #`() ,() ,@() ``. A zero value disables, giving the
normal indent behavior of DrRacket or Emacs `lisp-mode` derived
modes like `scheme-mode`. Setting this to a high value can make
indentation noticeably slower. This is safe to set as a
file-local variable.

### racket-pretty-lambda
Display lambda keywords using λ. This is deprecated.
Instead you can insert actual λ characters using
C-M-y
[`racket-insert-lambda`](#racket-insert-lambda).

### racket-smart-open-bracket-enable
Use [`racket-smart-open-bracket`](#racket-smart-open-bracket) when `[` is pressed?

### racket-use-company-mode
Enable company-mode for racket-mode edit buffers?

# Faces

> Note: You may also set these via Customize.

### racket-keyword-argument-face
Face for `#:keyword` arguments.

### racket-paren-face
Face for `() [] {}`.

### racket-selfeval-face
Face for self-evaluating expressions like numbers, symbols, strings.

