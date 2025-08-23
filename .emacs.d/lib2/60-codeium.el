(when (file-exists-p "/home/art/projects/codeium.el")
  (add-to-list 'load-path "/home/art/projects/codeium.el")
  (use-package codeium))
;; :init
;; (add-hook 'lisp-mode-hook
;;           (lambda ()
;;             (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)))
