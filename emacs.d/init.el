(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

(package-initialize)

(defvar my-packages '(starter-kit
		      starter-kit-lisp
		      starter-kit-eshell
		      clojure-mode
		      clojure-test-mode
		      cider
                      markdown-mode
                      window-number))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; paredit.el
'(define-key paredit-mode-map (kbd "C-S-<left>") 'paredit-backward-slurp-sexp)
'(define-key paredit-mode-map (kbd "C-S-<right>") 'paredit-backward-barf-sexp)
'(define-key paredit-mode-map (kbd "C-M-@") 'paredit-mark-sexp)

;; markdown-mode
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(require 'window-number)
(window-number-meta-mode)
