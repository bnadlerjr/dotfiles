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
                      solarized-theme
                      markdown-mode
                      powerline
                      window-number))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; use solarized light color theme
(load-theme 'solarized-light t)

;; powerline
(require 'powerline)
(powerline-default-theme)
(setq powerline-color1 "#073642")
(setq powerline-color2 "#002b36")

(set-face-attribute 'mode-line nil
                    :foreground "#fdf6e3"
                    :background "#2aa198"
                    :box nil)
(set-face-attribute 'mode-line-inactive nil
                    :box nil)

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
