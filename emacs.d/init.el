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
                      color-theme-solarized
                      markdown-mode
                      window-number))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; use solarized light color theme
(load-theme 'solarized-light t)

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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
