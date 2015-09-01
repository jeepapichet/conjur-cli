(defcustom conjur-completion-command "_conjur"
  "command to invoke using Bash completion conventions")

(defun pcomplete/conjur ()
  (let ((completions (conjur-get-completions pcomplete-args pcomplete-index)))
    (while (pcomplete-here* completions))))

(defun conjur-get-completions (args index)
  (with-temp-buffer ;; omg hack
    (let* ((default-directory "/home/ryan/dev/cli-ruby/")
           (completion-line (mapconcat 'identity args " "))
           (completion-point (number-to-string (length completion-line)))
           (process-environment (append
                                 (cons (concat "COMP_LINE=" completion-line) nil)
                                 (cons (concat "COMP_POINT=" completion-point) nil)
                                 process-environment)))
      (mapcar (lambda (word)
                (replace-regexp-in-string (rx (* " " eos)) "" word))
              (split-string (shell-command-to-string conjur-completion-command) "\n")))))
