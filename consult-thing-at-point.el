;;; consult-things-at-point.el --- Seed Consult commands with thing-at-point -*- lexical-binding: t; -*-

;; Copyright (C) 2026  ril

;; Author: ril <fenril.nh@gmail.com>
;; Version 1.0.0
;; Package-Requires: ((emacs "29.1") (consult "3.0"))
;; URL: https://github.com/fenril058/consult-line-thing-at-point
;; Keywords:matching, files, convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; consult-things-at-point: Seed Consult commands with thing-at-point.
;;
;; This package provides wrapper commands which take the "thing" near point
;; (via `bounds-of-thing-at-point') and pass it as INITIAL input to Consult.
;;
;; Provided commands:
;; - `consult-line-thing-at-point'
;; - `consult-line-multi-thing-at-point'
;; - `consult-find-thing-at-point'
;; - `consult-grep-thing-at-point'
;; - `consult-git-grep-thing-at-point'
;; - `consult-ripgrep-thing-at-point'
;;
;; Customization:
;; - `consult-things-at-point-types'         (default thing type priority)
;; - `consult-things-at-point-types-alist'   (per-command overrides)
;;
;; See readme.org for details and examples.
;;

;; The package, inspired by `isearch-forward-thing-at-point' in
;; `isearch.el', provides three functions:
;; - `consult-line-thing-at-point'
;; - `consult-line-multi-thing-at-point'
;; - `consult-ripgrep-multi-thing-at-point'
;;
;; You can customize which "thing" each funcion use as follows
;; (setq consult-things-at-point-types '(symbol word))
;; (add-to-list 'consult-things-at-point-types-alist
;;              '(consult-line . (region symbol word)))
;; (add-to-list 'consult-things-at-point-types-alist
;;              '(consult-ripgrep . (symbol word)))

;;; Code:

(require 'seq)
(require 'thingatpt)
(require 'consult)

(defcustom consult-things-at-point-types '(region symbol word)
  "Default list of thing types to try at point for seeding Consult commands.

Each element is a symbol accepted by `bounds-of-thing-at-point'.
The list order determines priority."
  :type '(repeat symbol)
  :group 'consult)

(defcustom consult-things-at-point-types-alist nil
  "Alist mapping Consult commands to thing-type lists used for initial input.

When a command is present in this alist, its associated list overrides
`consult-things-at-point-types'."
  :type '(alist :key-type function :value-type (repeat symbol))
  :group 'consult)

(defun consult-things-at-point--types (command)
  "Return thing types for COMMAND."
  (or (alist-get command consult-things-at-point-types-alist)
      consult-things-at-point-types))

(defun consult-things-at-point--bounds (types)
  "Return bounds of the first matching thing among TYPES, or nil."
  (seq-some (lambda (thing)
              (bounds-of-thing-at-point thing))
            types))

(defun consult-things-at-point--initial (types)
  "Return initial string from first matching thing among TYPES, or nil."
  (let ((b (consult-things-at-point--bounds types)))
    (when b
      (buffer-substring-no-properties (car b) (cdr b)))))

(defun consult-things-at-point--call (command &rest args)
  "Call COMMAND with ARGS, optionally appending thing-at-point as INITIAL.

COMMAND is a Consult command that accepts INITIAL as its last argument."
  (let* ((types (consult-things-at-point--types command))
         (initial (consult-things-at-point--initial types)))
    (when (use-region-p) (deactivate-mark))
    (if initial
        (apply command (append args (list initial)))
      (apply command args))))

;;;###autoload
(defun consult-line-thing-at-point ()
  "Run `consult-line' with thing at point as INITIAL input."
  (interactive)
  (consult-things-at-point--call #'consult-line))

;;;###autoload
(defun consult-line-multi-thing-at-point (query)
  "Run `consult-line-multi' with QUERY and thing at point as INITIAL input."
  (interactive "P")
  (consult-things-at-point--call #'consult-line-multi query))

;;;###autoload
(defun consult-find-thing-at-point (&optional dir)
  "Run `consult-find' with DIR and thing at point as INITIAL input."
  (interactive "P")
  (consult-things-at-point--call #'consult-find dir))

;;;###autoload
(defun consult-grep-thing-at-point (&optional dir)
  "Run `consult-grep' with DIR and thing at point as INITIAL input."
  (interactive "P")
  (consult-things-at-point--call #'consult-grep dir))

;;;###autoload
(defun consult-git-grep-thing-at-point (&optional dir)
  "Run `consult-git-grep' with DIR and thing at point as INITIAL input."
  (interactive "P")
  (consult-things-at-point--call #'consult-git-grep dir))

;;;###autoload
(defun consult-ripgrep-thing-at-point (&optional dir)
  "Run `consult-ripgrep' with DIR and thing at point as INITIAL input."
  (interactive "P")
  (consult-things-at-point--call #'consult-ripgrep dir))

(provide 'consult-thing-at-point)
;;; consult-thing-at-point.el ends here
