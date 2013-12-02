(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

(package-initialize)

(defvar my-packages '(starter-kit
		      starter-kit-lisp
		      starter-kit-eshell
                      auto-complete
		      clojure-mode
                      clojure-snippets
		      clojure-test-mode
		      cider
                      jedi
                      solarized-theme
                      markdown-mode
                      powerline
                      smartparens
                      window-number
                      yasnippet))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; use solarized light color theme
(load-theme 'solarized-light t)

;; GUI specific settings
(when (display-graphic-p)
  (custom-set-variables
   '(initial-frame-alist (quote ((fullscreen . maximized))))
   (set-face-attribute 'default nil :font "Monaco-14")))

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

;; yasnippet
(require 'yasnippet)
(setq yas-snippet-dirs
      '("~/bin/yasnippet-snippets"))

(yas-global-mode 1)

;; auto-complete; must be activated *after* yasnippet plugin
(require 'auto-complete-config)
(ac-config-default)

;; set the trigger key so that it can work together with yasnippet on
;; tab key, if the word exists in yasnippet, pressing tab will cause yasnippet
;; to activate, otherwise, auto-complete will
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")

;; smartparens
(smartparens-global-mode t)

;; paredit.el
'(define-key paredit-mode-map (kbd "C-S-<left>") 'paredit-backward-slurp-sexp)
'(define-key paredit-mode-map (kbd "C-S-<right>") 'paredit-backward-barf-sexp)
'(define-key paredit-mode-map (kbd "C-M-@") 'paredit-mark-sexp)

;; markdown-mode
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:setup-keys t)
(setq jedi:complete-on-dot t)

(require 'window-number)
(window-number-meta-mode)
