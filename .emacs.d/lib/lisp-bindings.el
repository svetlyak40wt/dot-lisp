(eval-after-load 'paredit
  `(progn
     ;; это нужно чтобы работать под Tmux
     (define-key paredit-mode-map (kbd "M-[ d") 'paredit-forward-barf-sexp)
     (define-key paredit-mode-map (kbd "M-[ c") 'paredit-forward-slurp-sexp)))

;; автоматически стартуем paredit-mode
(add-hook 'lisp-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)


