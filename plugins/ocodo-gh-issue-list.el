;;; plugins/ocodo-gh-issue-list.el -*- lexical-binding: t; -*-

(require 'ocodo-gh-lists)

(tblui-define ocodo/gh-issue-list-tblui
              "GitHub Issues list"
              "Display issues in a tabulated list."
              ocodo/gh-issue-list-entries-provider
  [("number" 8 t)
   ("title" 100 nil)
   ("state" 8 nil)
   ("updatedAt" 25 nil)
   ("url" 60 nil)]
  ((:key "C" :name ocodo/gh-issue-create
    :funcs ((?C "Create a new issue" ocodo/gh-create-new-issue)))
   (:key "W" :name ocood/gh-issue-browse
    :funcs ((?W "Browse URL for current issue" ocodo/gh-issue-open-url)))))

(defun ocodo/gh-create-new-issue (&optional &rest _)
  "Create a new issue, called by the popup so the WRAPPED-ID is discardable."
  (interactive)
  (let* ((title (read-string "Issue Title: "))
         (body (read-string "Body: "))
         (command (format "gh issue create --title '%s' --body '%s'" title body)))
     (shell-command command (get-buffer "*Messages*"))))

(defun ocodo/gh-issue-list-json-shell-command-string ()
  "Return a gh issue list command to generate json."
  (format
   "gh issue list -s all --json %s"
   (ocodo/tblui-column-names-from-layout
    ocodo/gh-issue-list-tblui-tabulated-list-format t)))

(defun ocodo/gh-issue-open-url (&optional wrapped-id)
  "Open the url for the row-id in at WRAPPED-ID."
  (let* ((row-id (car wrapped-id))
         (row
          (cadr (--find (= row-id (car it))
                        (ocodo/gh-issue-list-entries-provider)))))
    (shell-command (format "open \"%s\"" (elt row 4)))))

(defun ocodo/gh-issue-list-entries-provider ()
  "List workflow runs for the current project as a tblui view.
Filter by WORKFLOW-NAME.

Project is defined by pwd/git repo."
  (ocodo/gh-list-hash-to-tblui-vector-list
   (ocodo/tblui-column-names-from-layout
    ocodo/gh-issue-list-tblui-tabulated-list-format)
   (json-parse-string
    (shell-command-to-string
     (ocodo/gh-issue-list-json-shell-command-string)))))

(defun ocodo/gh-issue-list ()
  "Show the current repo's gh workflow run list."
  (interactive)
  (ocodo/gh-issue-list-tblui-goto-ui)
  (setq-local tabulated-list-sort-key '("number" . t)))

(provide 'ocodo-gh-issue-list)
