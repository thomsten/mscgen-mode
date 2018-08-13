;;; mscgen-mode.el --- Major mode for editing mscgen sequence diagrams

;; Copyright (C) 2018 Thomas Stenersen

;; Author: Thomas Stenersen <stenersen.thomas@gmail.com>
;; Version: 0.1

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Major mode for editing mscgen sequence diagrams

;;; Code:


(defgroup mscgen nil "mscgen customizations"
  :group 'languages)

(defcustom mscgen-executable
  "mscgen"
  "Path to `mscgen' exectuable."
  :type 'string
  :group 'mscgen)

(defcustom mscgen-output-file-type
  "png"
  "Default output file type."
  :group 'mscgen
  :type 'string
  :options '("png" "eps" "svg" "ismap"))

;;; Fontification

(defconst mscgen--keywords
  '("label" "URL" "ID" "IDURL" "arcskip" "linecolor" "textcolor" "textbgcolor"
    "arclinecolor" "arctextcolor" "arctextbgcolor"))

(defconst mscgen--keywords-extra
  '("linecolour" "textcolour" "textbgcolour" "arclinecolour" "arctextcolour"
    "arctextbgcolour"))

(defconst mscgen--types
  '("box" "note" "rbox" "abox" "->" "<-" "=>" "<=" ">>" "<<"
    "=>>" "<<=" ":>" "<:" "-x" "x-" "*<-" "->*" "..." "---"
    "|||"))

(defconst mscgen--functions
  '("arcgradient" "wordwraparcs" "width" "hscale"))

(defconst mscgen--font-lock-keywords
  (let* ((x-keywords-regexp (regexp-opt (append mscgen--keywords
                                                mscgen--keywords-extra)))
         (x-types-regexp (regexp-opt mscgen--types) )
         (x-functions-regexp (regexp-opt mscgen--functions)))
    `((,x-keywords-regexp . font-lock-keyword-face)
      (,x-types-regexp . font-lock-type-face)
      (,x-functions-regexp . font-lock-function-name-face))))

(defconst mscgen-syntax-table
  (let ( (syn-table (make-syntax-table)))
    ;; python style comment: “# …”
    (modify-syntax-entry ?# "<" syn-table)
    (modify-syntax-entry ?\n ">" syn-table)
    syn-table)
  "Syntax table for mscgen comments.")


;;; Functions

(defun mscgen-completion-at-point ()
  "Complete the label or function at the current point."
  (interactive)
  (let* ((bds (bounds-of-thing-at-point 'symbol))
         (start (car bds))
         (end (cdr bds)))
    (list start end (append mscgen--keywords
                            mscgen--types
                            mscgen--functions) . nil)))

(defun mscgen-compile ()
  "Compile the current sequence diagram."
  (interactive)
  (let ((compile-command
         (read-from-minibuffer
          "Compile command: "
          (format
           "%s -T %s -i %s -o %s.%s"
           mscgen-executable
           mscgen-output-file-type
           (buffer-file-name)
           (file-name-sans-extension (buffer-file-name))
           mscgen-output-file-type))))
    (compile compile-command)))

(defun mscgen-insert-label-at-point ()
  "Quick insert a label at point."
  (interactive)
  (end-of-line)
  (insert (format "[label=\"%s\"];" (read-from-minibuffer "Label: "))))

(define-derived-mode mscgen-mode fundamental-mode "mscgen-mode"
  "Major mode for editing mscgen sequence diagrams. See
  http://www.mcternan.me.uk/mscgen/."

  (setq font-lock-defaults '((mscgen--font-lock-keywords)))
  (set-syntax-table mscgen-syntax-table)
  (setq-local comment-start "#")
  (setq-local comment-end "")
  (add-hook 'completion-at-point-functions
            'mscgen-completion-at-point nil 'local))

(provide 'mscgen-mode)


;;; mscgen-mode.el ends here
