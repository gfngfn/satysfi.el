;;; satysfi.el --- SATySFi                      -*- lexical-binding: t; -*-

;; Copyright (C) 2017  Takashi SUWA

;; Author: Takashi SUWA
;; Keywords:

(provide 'satysfi)


(defface satysfi-row-command-face
  '((t (:foreground "#8888ff" :background "dark")))
  "SATySFi row command")

(defface satysfi-column-command-face
  '((t (:foreground "#ff8888" :background "dark")))
  "SATySFi column command")

(defface satysfi-var-in-string-face
  '((t (:foreground "#44ff88" :background "dark")))
  "SATySFi variable in string")

(defface satysfi-escaped-character
  '((t (:foreground "#cc88ff" :background "dark")))
  "SATySFi escaped character")

(defface satysfi-literal-area
  '((t (:foreground "#ffff44" :background "dark")))
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

(defvar satysfi-mode-map (copy-keymap global-map))
(define-key satysfi-mode-map (kbd "(") 'satysfi-mode/insert-paren-pair)
(define-key satysfi-mode-map (kbd "[") 'satysfi-mode/insert-square-bracket-pair)
(define-key satysfi-mode-map (kbd "<") 'satysfi-mode/insert-angle-bracket-pair)
(define-key satysfi-mode-map (kbd "{") 'satysfi-mode/insert-brace-pair)
(define-key satysfi-mode-map (kbd "$") 'satysfi-mode/insert-math-brace-pair)

(define-generic-mode satysfi-mode
  '(?%)

  '("let" "let-rec" "let-mutable" "let-inline" "let-block" "let-math" "in" "and"
    "match" "with" "when" "as" "if" "then" "else" "fun"
    "type" "constraint" "val" "direct" "of"
    "module" "struct" "sig" "end"
    "before" "while" "do"
    "controls" "cycle")

  '(("\\(\\\\\\(?:\\\\\\\\\\)*[a-zA-Z0-9\\-]+\\)\\>"
     (1 'satysfi-row-command-face t))
    ("\\(\\+[a-zA-Z0-9\\-]+\\)\\>"
     (1 'satysfi-column-command-face t))
    ("\\(@[a-z][0-9A-Za-z\\-]*\\)\\>"
     (1 'satysfi-var-in-string-face t))
    ("\\(\\\\\\(?:@\\|`\\|\\*\\| \\|%\\||\\|;\\|{\\|}\\|\\\\\\)\\)"
     (1 'satysfi-escaped-character t))
    ("\\(`\\(?:[^`]\\|\\n\\)+`\\)"
     (1 'satysfi-literal-area t)))

  nil
  '((lambda () (use-local-map satysfi-mode-map))))
