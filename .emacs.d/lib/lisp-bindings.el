(cond
 ((file-exists-p (expand-file-name "~/.roswell/helper.el"))
  (load (expand-file-name "~/.roswell/helper.el")))
 ((file-exists-p (expand-file-name "~/.roswell/lisp/quicklisp/slime-helper.el"))
  (load (expand-file-name "~/.roswell/lisp/quicklisp/slime-helper.el")))
 ((file-exists-p (expand-file-name "~/quicklisp/slime-helper.el"))
  (load (expand-file-name "~/quicklisp/slime-helper.el")))
  (t (require-or-install 'slime)))

(require 'slime-autoloads)


(eval-after-load 'slime
  `(progn
     (define-key slime-mode-map (kbd "C-c u f") 'slime-undefine-function)
     (define-key slime-mode-map (kbd "C-c u s") 'slime-unintern-symbol)
     (define-key slime-mode-map (kbd "C-c u p") 'slime-delete-package)
     
     (define-key slime-mode-map (kbd "C-c s") 'slime-selector)
     (define-key slime-repl-mode-map (kbd "C-c s") 'slime-selector)
     (define-key shell-mode-map (kbd "C-c s") 'slime-selector)))


(require-or-install 'slime-company)
;(require-or-install 'slime-presentations)

(setq slime-contribs
      '(slime-fancy
        slime-banner
        slime-indentation
        ;; slime-repl-ansi-color
        slime-company
        ))
(slime-setup slime-contribs)


(add-hook 'slime-repl-mode-hook
          (lambda ()
            ;; For some reason, lisp runned by roswell,
            ;; does not load ~/.sbclrc so we'll do this now
            (when (file-exists-p "~/.sbclrc")
              (slime-eval '(cl:load "~/.sbclrc")))
            
            ;; (el-get 'sync 'slime-repl-ansi-color)
            ;; (slime-setup '(slime-repl-ansi-color))
            ))


(eval-after-load 'company
  '(progn
     (define-key company-mode-map (kbd "M-/") 'helm-company)
     (define-key company-active-map (kbd "M-/") 'helm-company)))


(eval-after-load 'paredit
  `(progn
     ;; по умолчанию, C-w у меня забинжен на backward-kill-word,
     ;; но это ломает балансированные скобки в paredit режиме,
     ;; поэтому надо использоваться специальную paredit функцию
     (define-key paredit-mode-map (kbd "C-w") 'paredit-backward-kill-word)

     ;; это нужно чтобы работать под Tmux
     (define-key paredit-mode-map (kbd "M-[ d") 'paredit-forward-barf-sexp)
     (define-key paredit-mode-map (kbd "M-[ c") 'paredit-forward-slurp-sexp)))

;; автоматически стартуем paredit-mode
(add-hook 'lisp-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)


