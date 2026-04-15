;;; consult-line-thing-at-point.el --- List of things to try for consult-line-thing-at-point  -*- lexical-binding: t; -*-

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

;; The package, inspired by `isearch-forward-thing-at-point', provides
;; two functions: `consult-line-thing-at-point' and
;; `consult-line-multi-thing-at-point'.

;;; Code:

(require 'seq)
(require 'thingatpt)
(require 'consult)

(defcustom consult-line-thing-at-point '(region symbol word)
  "List of things to try for `consult-line-thing-at-point'.

  Each element is a symbol accepted by `bounds-of-thing-at-point'.
  If the list contains `region' and the region is active, then
  text from the active region is used."
  :type '(repeat symbol))

(defcustom consult-line-multi-thing-at-point '(region symbol word)
  "List of things to try for `consult-line-multi-thing-at-point'.

  Each element is a symbol accepted by `bounds-of-thing-at-point'.
  If the list contains `region' and the region is active, then
  text from the active region is used."
  :type '(repeat symbol))

;;;###autoload
(defun consult-line-thing-at-point ()
  "Run `consult-line' with the \"thing\" near point as INITIAL input.

The \"thing\" is searched by trying each symbol in
`consult-line-thing-at-point' with `bounds-of-thing-at-point'.  The
function depends on `thingatpt.el' and `seq.el' and is derived from
`isearch-forward-thing-at-point'"
  (interactive)
  (let* ((bounds (seq-some (lambda (thing)
                             (bounds-of-thing-at-point thing))
                           consult-line-thing-at-point))
         (initial (and bounds
                       (buffer-substring-no-properties (car bounds) (cdr bounds)))))
    (cond
     (initial
      (when (use-region-p)
        (deactivate-mark))
      (when (< (car bounds) (point))
        (goto-char (car bounds)))
      (consult-line initial))
     (t
      ;; (message "No thing at point")
      (consult-line)))))

;;;###autoload
(defun consult-line-multi-thing-at-point (query)
  "Run `consult-line-multi' with QUERY and the \"thing\" near point as INITIAL input.

The \"thing\" is searched by trying each symbol in
`consult-line-thing-multi-at-point' with `bounds-of-thing-at-point'.
The function depends on `thingatpt.el' and `seq.el' and is derived from
`isearch-forward-thing-at-point'"
  (interactive "P")
  (let* ((bounds (seq-some (lambda (thing)
                             (bounds-of-thing-at-point thing))
                           consult-line-multi-thing-at-point))
         (initial (and bounds
                       (buffer-substring-no-properties (car bounds) (cdr bounds)))))
    (cond
     (initial
      (when (use-region-p)
        (deactivate-mark))
      (when (< (car bounds) (point))
        (goto-char (car bounds)))
      (consult-line-multi query initial))
     (t
      ;; (message "No thing at point")
      (consult-line-multi query)))))

(provide 'consult-line-thing-at-point)
;;; consult-line-thing-at-point.el ends here
