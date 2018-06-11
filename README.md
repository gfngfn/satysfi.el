<!-- -*- coding: utf-8 -*- -->
# `satysfi.el`

## Configuration

add the following commands to your `init.el`:

```lisp
(require 'satysfi)
(add-to-list 'auto-mode-alist '("\\.saty$" . satysfi-mode))
(add-to-list 'auto-mode-alist '("\\.satyh$" . satysfi-mode))
(setq satysfi-command "satysfi")
  ; set the command for typesetting (default: "satysfi -b")
(setq satysfi-pdf-viewer-command "sumatrapdf")
  ; set the command for opening PDF files (default: "open")
```

## Key Binds

| key bind | effect |
|----------|--------|
| `(` | inserts `()` |
| `[` | inserts `[]` |
| `{` | inserts `{}` |
| `<` | inserts `<>` |
| `$` | inserts `${}` |
| `C-c C-t` | typesets the current buffer file |
| `C-c C-f` | open the generated PDF corresponding to the current buffer file |
