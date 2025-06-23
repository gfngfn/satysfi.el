;;; satysfi.el --- SATySFi                      -*- lexical-binding: t; -*-

;; Copyright (C) 2017-2018 Takashi SUWA

(provide 'satysfi)

(defgroup satysfi nil
  "Major mode for SATySFi."
  :group 'text)

(defcustom satysfi-pdf-viewer-command "open"
  "Command to open the PDF file."
  :type 'file
  :group 'satysfi)

(defcustom satysfi-command "opam exec satysfi -- -b"
  "Command to run SATySFi."
  :type 'file
  :group 'satysfi)

(defcustom satysfi-compilation-window-height 10
  "Number of lines in a compilation window of SATySFi.
If nil, use Emacs default."
  :type '(choice (const nil) integer))

(defface satysfi-inline-command-face
  '((t (:foreground "#8888ff")))
  "SATySFi inline command")

(defface satysfi-block-command-face
  '((t (:foreground "#ff8888")))
  "SATySFi block command")

(defface satysfi-var-in-string-face
  '((t (:foreground "#44ff88")))
  "SATySFi variable in string")

(defface satysfi-escaped-character
  '((t (:foreground "#cc88ff")))
  "SATySFi escaped character")

(defface satysfi-literal-area
  '((t (:foreground "#ffff44")))
  "SATySFi literal area")

(defun satysfi-mode/insert-pair-scheme (open-string close-string)
  (cond ((use-region-p)
         (let ((rb (region-beginning)))
           (let ((re (region-end)))
             (progn
               (goto-char rb)
               (insert open-string)
               (goto-char (+ (length open-string) re))
               (insert close-string)
               (forward-char -1)))))
        (t
         (progn
           (insert (format "%s%s" open-string close-string))
           (forward-char -1)))))

(defun satysfi-mode/insert-paren-pair ()
  (interactive)
  (satysfi-mode/insert-pair-scheme "(" ")"))

(defun satysfi-mode/insert-brace-pair ()
  (interactive)
  (satysfi-mode/insert-pair-scheme "{" "}"))

(defun satysfi-mode/insert-square-bracket-pair ()
  (interactive)
  (satysfi-mode/insert-pair-scheme "[" "]"))

(defun satysfi-mode/insert-angle-bracket-pair ()
  (interactive)
  (satysfi-mode/insert-pair-scheme "<" ">"))

(defun satysfi-mode/insert-math-brace-pair ()
  (interactive)
  (satysfi-mode/insert-pair-scheme "${" "}"))

(defun satysfi-mode/remove-tramp-prefix (filename)
  (if (string-match-p ":" filename)
      ;; If it does, remove the prefix
      (replace-regexp-in-string ".*:" "" filename)
    ;; If it doesn't, use the original filename
    filename))

(defun satysfi-mode/open-pdf ()
  (interactive)
  (let ((pdf-file-path (concat (file-name-sans-extension buffer-file-name) ".pdf")))
    (progn
      (message "Opening '%s' ..." pdf-file-path)
      (let ((escaped-pdf-file-path
             (shell-quote-argument pdf-file-path)))
        (async-shell-command
         (format "%s %s\n" satysfi-pdf-viewer-command escaped-pdf-file-path))))))

(defun satysfi-mode/typeset ()
  (interactive)
  (let ((local-file-name (satysfi-mode/remove-tramp-prefix buffer-file-name)))
    (progn
      (defun satysfi-mode/compilation-hook ()
        (when (not (get-buffer-window "*compilation*"))
          (save-selected-window
            (save-excursion
              (let* ((w (split-window-vertically))
                     (h (window-height w)))
                (select-window w)
                (switch-to-buffer "*compilation*")
                (shrink-window (- h compilation-window-height)))))))
      (add-hook 'compilation-mode-hook 'satysfi-mode/compilation-hook)
      (message "Typesetting '%s' ..." local-file-name)
      (let ((escaped-buffer-file-name
             (shell-quote-argument local-file-name))
            (compilation-window-height satysfi-compilation-window-height))
        (compilation-start
         (format "%s %s\n" satysfi-command escaped-buffer-file-name)))
      (remove-hook 'compilation-mode-hook 'satysfi-mode/compilation-hook))))

(defvar satysfi-mode-map (copy-keymap global-map))
(define-key satysfi-mode-map (kbd "(") 'satysfi-mode/insert-paren-pair)
(define-key satysfi-mode-map (kbd "[") 'satysfi-mode/insert-square-bracket-pair)
(define-key satysfi-mode-map (kbd "<") 'satysfi-mode/insert-angle-bracket-pair)
(define-key satysfi-mode-map (kbd "{") 'satysfi-mode/insert-brace-pair)
(define-key satysfi-mode-map (kbd "$") 'satysfi-mode/insert-math-brace-pair)
(define-key satysfi-mode-map (kbd "C-c C-t") 'satysfi-mode/typeset)
(define-key satysfi-mode-map (kbd "C-c C-f") 'satysfi-mode/open-pdf)

;;;###autoload
(define-generic-mode satysfi-mode
  '(?%)

  '("let" "let-rec" "let-mutable" "let-inline" "let-block" "let-math" "in" "and"
    "match" "with" "when" "as" "if" "then" "else" "fun"
    "type" "constraint" "val" "direct" "of"
    "module" "struct" "sig" "end"
    "before" "while" "do"
    "controls" "cycle")

  '(("\\(\\\\\\(?:\\\\\\\\\\)*\\([a-zA-Z0-9\\-]+\\.\\)*[a-zA-Z0-9\\-]+\\)\\>"
     (1 'satysfi-inline-command-face t))
    ("\\(\\+\\([a-zA-Z0-9\\-]+\\.\\)*[a-zA-Z0-9\\-]+\\)\\>"
     (1 'satysfi-block-command-face t))
    ("\\(@[a-z][0-9A-Za-z\\-]*\\)\\>"
     (1 'satysfi-var-in-string-face t))
    ("\\(\\\\\\(?:@\\|`\\|\\*\\| \\|%\\||\\|;\\|{\\|}\\|<\\|>\\|\\$\\|#\\|\\\\\\)\\)"
     (1 'satysfi-escaped-character t))
;    ("\\(`\\(?:[^`]\\|\\n\\)+`\\)" (1 'satysfi-literal-area t))
    )

  nil
  '((lambda () (use-local-map satysfi-mode-map))))

;;;###autoload
(add-to-list 'auto-mode-alist
             '("\\.\\(saty\\|satyh\\)\\'"
               . satysfi-mode))
