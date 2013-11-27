(require 'package)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

(defvar my-packages '(starter-kit
		      starter-kit-lisp
		      starter-kit-eshell
		      clojure-mode
		      clojure-test-mode
		      cider
                      window-number))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; paredit.el
'(define-key paredit-mode-map (kbd "C-S-<left>") 'paredit-backward-slurp-sexp)
'(define-key paredit-mode-map (kbd "C-S-<right>") 'paredit-backward-barf-sexp)

(require 'window-number)
(window-number-meta-mode)
