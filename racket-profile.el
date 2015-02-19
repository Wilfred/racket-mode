;;; racket-profile.el

;; Copyright (c) 2013-2015 by Greg Hendershott.
;; Portions Copyright (C) 1985-1986, 1999-2013 Free Software Foundation, Inc.

;; Author: Greg Hendershott
;; URL: https://github.com/greghendershott/racket-mode

;; License:
;; This is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version. This is distributed in the hope that it will be
;; useful, but without any warranty; without even the implied warranty
;; of merchantability or fitness for a particular purpose. See the GNU
;; General Public License for more details. See
;; http://www.gnu.org/licenses/ for details.

(require 'cl-lib)
(require 'racket-edit)

(defvar racket--profile-results nil)
(defvar racket--profile-sort-col 1)

(defun racket-profile ()
  "Get profiling results in a `racket-profile-mode' buffer.

\\{racket-profile-mode-map}

If the buffer has already been run with `racket-error-context'
set to 'profile, shows those results. Otherwise, prompts to
re-run with profiling instrumentation.

You may evaluate additonal expressions in the REPL. They will be
profiled, too. In that case use `racket--profile-refresh' to see
the updated results."
  (interactive)
  (when (eq major-mode 'racket-mode)
    (setq racket--profile-results (racket--eval/sexpr ",get-profile"))
    (unless racket--profile-results
      (y-or-n-p "No profiling results. Re-run with profiler enabled? ")
      (racket--do-run 'profile)
      (racket-profile))
    (setq racket--profile-sort-col 1)
    (with-current-buffer (get-buffer-create "*Racket Profile*")
      (racket-profile-mode)
      (racket--profile-draw)
      (pop-to-buffer (current-buffer)))))

(defun racket--profile-refresh ()
  (interactive)
  (setq racket--profile-results (racket--eval/sexpr ",get-profile"))
  (racket--profile-draw))

(defun racket--profile-draw ()
  (read-only-mode -1)
  (erase-buffer)
  (setq truncate-lines t) ;let run off right edge
  ;; TODO: Would be nice to set the Calls and Msec column widths based
  ;; on max values.
  (setq header-line-format
        (format " %8s %6s %-20.20s %s"
                (if (= 0 racket--profile-sort-col) "CALLS" "Calls")
                (if (= 1 racket--profile-sort-col) "MSEC" "Msec")
                "Name (inferred)"
                "File"))
  (insert (mapconcat (lambda (xs)
                       (cl-destructuring-bind (calls msec name file beg end) xs
                         (propertize (format "%8d %6d %-20.20s %s"
                                             calls msec name file)
                                     'racket-profile-location
                                     (and file beg end
                                          (list file beg end)))))
                     (sort (cl-copy-list racket--profile-results)
                           (lambda (a b) (> (nth racket--profile-sort-col a)
                                            (nth racket--profile-sort-col b))))
                     "\n"))
  (read-only-mode 1)
  (goto-char (point-min)))

(defun racket--profile-sort ()
  "Toggle sort between Calls and Msec."
  (interactive)
  (setq racket--profile-sort-col (if (= racket--profile-sort-col 0) 1 0))
  (racket--profile-draw))

(defvar racket--profile-overlay-this nil)
(defvar racket--profile-overlay-that nil)

(defun racket--profile-visit ()
  (interactive)
  (let ((win  (selected-window))
        (prop (get-text-property (point) 'racket-profile-location)))
    (when prop
      (cl-destructuring-bind (file beg end) prop
        (setq racket--profile-overlay-this
              (make-overlay (save-excursion (beginning-of-line) (point))
                            (save-excursion (end-of-line) (point))
                            (current-buffer)))
        (overlay-put racket--profile-overlay-this 'face 'next-error)
        (find-file-other-window file)
        (setq racket--profile-overlay-that (make-overlay beg end (current-buffer)))
        (overlay-put racket--profile-overlay-that 'face 'next-error)
        (goto-char beg)
        (add-hook 'pre-command-hook #'racket--profile-remove-overlay)
        (select-window win)))))

(defun racket--profile-remove-overlay ()
  (delete-overlay racket--profile-overlay-this)
  (delete-overlay racket--profile-overlay-that)
  (remove-hook 'pre-command-hook #'racket--profile-remove-overlay))

(defun racket--profile-next ()
  (interactive)
  (forward-line 1)
  (racket--profile-visit))

(defun racket--profile-prev ()
  (interactive)
  (forward-line -1)
  (racket--profile-visit))

(defun racket--profile-quit ()
  (interactive)
  (setq racket--profile-results nil)
  (quit-window))

(defvar racket-profile-mode-map
  (let ((m (make-sparse-keymap)))
    (set-keymap-parent m nil)
    (mapc (lambda (x)
            (define-key m (kbd (car x)) (cadr x)))
          '(("q"   racket--profile-quit)
            ("g"   racket--profile-refresh)
            ("n"   racket--profile-next)
            ("p"   racket--profile-prev)
            ("RET" racket--profile-visit)
            (","   racket--profile-sort)))
    m)
  "Keymap for Racket Profile mode.")

(define-derived-mode racket-profile-mode special-mode
  "RacketProfile"
  "Major mode for results of `racket-profile'.

\\{racket-profile-mode-map}"
  (setq show-trailing-whitespace nil))

(provide 'racket-profile)

;; racket-profile.el ends here
