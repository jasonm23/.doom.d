;;; plugins/elisp-to-markdown.el -*- lexical-binding: t; -*-

(defun order-substring-matches (raw-substring-matches)
  "Order a set of RAW-SUBSTRING-MATCHES.

Ordered substrings can then be used to perform replacements
on the original source string.

The list is sorted last to first, so that string replacements
don't invalidate replacements using subsequent substring indexes.

Raw substring matches are in the form:

    '((\"s1\" ((10 . 12) (30 . 32) ...))...)
      (\"s2\" ((15 . 17) (20 . 22) ...))...)

This would become:

    '((\"s1\" (30 . 33)))
      (\"s2\" (20 . 22)))
      (\"s2\" (15 . 17)))
      (\"s1\" (10 . 13)))
"
  (--sort
     (> (car (car (cdr it)))
        (car (car (cdr other))))
   (cl-reduce (lambda (acc entry)
                (let* ((indexes (car (cdr entry)))
                       (str (car entry))
                       (mapped (--map
                                `(,str ,it)
                                indexes)))
                 (seq-concatenate 'list acc mapped)))
              raw-substring-matches
              :initial-value '())))

(defun docstring-args-to-markdown-code (args docstring)
  "Using ARGS transform DOCSTRING arguments to inline markdown `code` style."
  (let ((case-fold-search nil))
   (let* ((replacements '(("(" . "")
                          (")" . "")
                          ("&rest" . "")
                          ("&optional" . "")))
          (arg-list     (s-split-words (upcase (s-trim (s-replace-all replacements args)))))
          (doc-matches  (--map
                         `(,it ,(reverse
                                 (s-matched-positions-all
                                  it
                                  docstring)))
                         arg-list))
          (edit-list    (order-substring-matches doc-matches)))
     (cl-reduce (lambda (doc match)
                  (let* ((name (car match))
                         (a (caadr match))
                         (b (cdadr match))
                         (left (substring doc 0 a))
                         (right (substring doc b)))
                     (if (segments-ok-p left right)
                       (format "%s`%s`%s" left (downcase name) right)
                      doc)))
                edit-list
                :initial-value docstring))))

(defun segments-ok-p (left-string right-string)
  "Check the LEFT-STRING and RIGHT-STRING."
  (let ((a  (substring (reverse left-string) 0 1))
        (b  (substring right-string 0 1)))
    (not (s-matches?
          "[A-Za-z]"
          (concat a b)))))


;; TODO: Write a test for this function stub
(defun docstring-to-text-and-code (docstring)
  "Split DOCSTRING into text and code sections.

```
(setq docstring (format-multiline \"|Split DOCSTRING into text and code blocks
                                   |
                                   |Example:
                                   |
                                   |```
                                   |(docstring-to-text-and-code docstring)
                                   |```
                                   |
                                   |Also indented code blocks...
                                   |
                                   |    (docstring-to-text-and-code docstring)
                                   |\")

# docstring split into text and code
'((:text \"Split DOCSTRING into text and code blocks\n\nExample:\n\n\")
  (:code \"(docstring-to-text-and-code docstring)\"))
  (:text \"\n\nAlso indented code blocks...\n\n\"))
  (:code \"(docstring-to-text-and-code docstring)\"))
```")

(defun docstring-back-quoted-to-markdown-code (docstring)
  "transform back-quoted docstring elements to inline markdown `code` style."
  (if (null docstring)
      ""
    (replace-regexp-in-string
      (rx "`" (group (*? not-newline)) "'")
      "`\\1`"
      docstring)))

(defun generate-markdown-defun-entry (fn)
  "Generate a markdown entry for FN."
  (cl-destructuring-bind (name args docstring is-interactive) fn
   (let ((name (format "%s" name))
         (args (if args (format " %s" args) "")))
       (when (string= nil docstring)
         (setq docstring "No docstring available: TODO"))
       (format "### %s%s\n\n%s\n\n<sup>function signature</sup>\n```lisp\n(%s)\n```\n\n- - -\n"
               name
               (if is-interactive " [command]" "")
               ;; TODO: Process the docstring as code and text separately.
               ;; (docstring-to-text-and-code docstring)
               (docstring-args-to-markdown-code args
                 (docstring-back-quoted-to-markdown-code
                   docstring))
               (format "%s%s" name args)))))

(defun get-defun-info (buffer)
  "Get information about all `defun' top-level sexps in a BUFFER.
Returns a list with elements of the form (symbol args docstring)."
  (with-current-buffer buffer
    (save-excursion
      (save-restriction
        (widen)
        (goto-char (point-min))
        (let (result)
          ;; keep going while reading succeeds
          (while (condition-case nil
                     (progn
                       (read (current-buffer))
                       (forward-sexp -1)
                       t)
                   (error nil))
            (let ((form (read (current-buffer))))
              (cond
               ((not (listp form)) nil)
               ((eq (nth 0 form) 'defun)
                (let ((sym (nth 1 form))
                      (args (nth 2 form))
                      (doc (when (stringp (nth 3 form)) (nth 3 form)))
                      (is-interactive (string= "interactive" (car (nth 4 form)))))
                      ;;(interactive-info (when (string= "interactive" (car (nth 4 form)))
                      ;;                   (cadr (nth 4 form)))))
                  (push (list sym args doc is-interactive) result))))))
          result)))))

(defun generate-markdown-list-of-buffer-defuns (buffer)
  "Generate markdown text of all defuns in buffer"
  (s-join "\n"
          (mapcar
           #'generate-markdown-defun-entry
           (-sort (lambda (a b)
                    (let ((c (symbol-name (first a)))
                          (d (symbol-name (first b))))
                      (string< c d)))
                  (get-defun-info (current-buffer))))))

(defun generate-markdown-page-of-buffer-defuns (&optional buffer)
  "Generate markdown page for all defun in BUFFER.

BUFFER file name and commentary are used as the page heading."

  (concat
   (format-multiline "|# %s
                      |%s
                      | - - -
                      |## Functions
                      |
                      |"
                     (s-capitalized-words (s-replace-regexp "[.]el$" "" (buffer-name buffer)))
                     (docstring-back-quoted-to-markdown-code (lm-commentary (buffer-file-name))))
   (generate-markdown-list-of-buffer-defuns buffer)))

(defun current-buffer-defuns-to-markdown (file)
  "Create a markdown FILE of all defuns in the current buffer."
  (interactive "FWrite List of defuns to Markdown File: ")
  (f-write (generate-markdown-page-of-buffer-defuns (current-buffer)) 'utf-8 file)
  (when (y-or-n-p (format "Open %s?" file))
    (find-file file)))

(defun buffer-defuns-to-markdown (buffer file)
  "Parse all defuns in BUFFER and save to markdown FILE."
  (interactive "bSelect Buffer: \nFWrite List of defuns to Markdown File: ")
  (f-write (generate-markdown-page-of-buffer-defuns (get-buffer buffer)) 'utf-8 file)
  (when (y-or-n-p (format "Open %s?" file))
    (find-file file)))