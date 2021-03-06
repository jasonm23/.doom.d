;;; use/use-ert.el -*- lexical-binding: t; -*-

;; ert settings
(use-package! ert

  :init
   (defun ert-run-all-tests ()
     "Run all tests available."
     (interactive)
     (ert t))

   (defun ert-load-file-run-all-tests (file)
     "Load FILE and run all tests."
     (interactive "fSelect tests file: ")
     (load-file file)
     (find-file-other-window file)
     (ert-run-all-tests))

   (defun ert-eval-buffer-run-all-tests (buffer)
     "Eval BUFFER and run all tests."
     (interactive "bSelect tests buffer: ")
     (eval-buffer buffer)
     (ert-run-all-tests))

   (bind-key "C-c / t"   #'ert-run-tests-interactively   'emacs-lisp-mode-map)
   (bind-key "C-c / l"   #'ert-load-file-run-all-tests   'emacs-lisp-mode-map)
   (bind-key "C-c / b"   #'ert-eval-buffer-run-all-tests 'emacs-lisp-mode-map)
   (bind-key "C-c / /"   #'ert-run-all-tests             'emacs-lisp-mode-map)
   (bind-key "C-c / c"   #'ert-delete-all-tests          'emacs-lisp-mode-map))
