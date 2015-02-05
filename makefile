EMACS=$(shell if [ -z "`which emacs`" ]; then echo "Emacs executable not found"; exit 1; else echo emacs; fi)

BATCHEMACS=${EMACS} --batch --no-site-file -q -eval '(add-to-list (quote load-path) "${PWD}/")'

BYTECOMP = $(BATCHEMACS) -eval '(progn (require (quote bytecomp)) (setq byte-compile-warnings t) (setq byte-compile-error-on-warn t) (require (quote package)) (package-initialize))' -f batch-byte-compile

default:
	@echo Try \'make help\'

help:
	@echo "Targets: clean, compile, test, test-racket, test-elisp"

clean:
	-rm *.elc

%.elc : %.el
	$(BYTECOMP) $<

compile: clean \
	racket-common.elc \
	racket-collection.elc \
	racket-complete.elc \
	racket-edit.elc \
	racket-eval.elc \
	racket-font-lock.elc \
	racket-indent.elc \
	racket-keywords-and-builtins.elc \
	racket-make-doc.elc \
	racket-mode.elc \
	racket-repl.elc \
	racket-tests.elc \
	racket-util.elc

# Install packages we depend on. Intended for one-time use by
# developers and for Travis CI. (Normal users of the package get these
# deps automatically as a result of our Package-Requires in
# racket-mode.el)
deps:
	$(BATCHEMACS) -eval "(progn (require (quote package)) (package-initialize) (package-refresh-contents) (package-install dash) (package-install faceup))"

doc:
	$(BATCHEMACS) -l racket-make-doc.el -f racket-make-doc/write-reference-file

test: test-racket test-elisp

test-racket:
	raco test -x ./*.rkt  # not example/*.rkt

test-elisp:
	$(BATCHEMACS) -l ert -l racket-tests.el -f ert-run-tests-batch-and-exit
