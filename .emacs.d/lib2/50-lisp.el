(require 'cl-lib)

(when (file-exists-p (expand-file-name "~/.roswell/lisp/slime/master"))
  (add-to-list 'load-path (expand-file-name "~/.roswell/lisp/slime/master")))

;; This block should go before we add a path to the SLY,
;; because otherwise SLY will check in it's autoload file if there is
;; SLIME in a lisp-mode-hook and will promt if we want to remove it
;; each time Emacs is loaded.
(use-package slime
    :config
  (message "Configuring SLIME")
  (remove-hook 'lisp-mode-hook 'slime-lisp-mode-hook))


(when (file-exists-p (expand-file-name "~/projects/sly"))
  (add-to-list 'load-path (expand-file-name "~/projects/sly")))

(when (file-exists-p (expand-file-name "~/projects/lisp/sly"))
  (add-to-list 'load-path (expand-file-name "~/projects/lisp/sly")))

(when (file-exists-p (expand-file-name "~/projects/lisp/lispy"))
  (add-to-list 'load-path (expand-file-name "~/projects/lisp/lispy")))

(when (file-exists-p (expand-file-name "~/projects/lisp/log4sly/elisp")) ;
  (add-to-list 'load-path (expand-file-name "~/projects/lisp/log4sly/elisp"))
  (require 'log4sly))


(defun 40ants-mrepl-sync ()
  (interactive)
  (sly-mrepl-sync (sly-current-package)
                  ;; don't change directory
                  nil))

(use-package sly-named-readtables)

(use-package sly-macrostep)

;; https://github.com/PuercoPop/sly-repl-ansi-color
(use-package sly-repl-ansi-color
  :config
  (with-eval-after-load 'sly
    (add-to-list 'sly-contribs 'sly-repl-ansi-color 'append)))

;; https://github.com/fisxoj/sly-docker
(when (file-exists-p (expand-file-name "~/projects/lisp/sly-docker"))
  (use-package docker-tramp)
  (add-to-list 'load-path (expand-file-name "~/projects/lisp/sly-docker"))
  (add-to-list 'sly-contribs 'sly-docker 'append))

;; TODO: надо разобраться, как теперь правильно сотировать autocomplete
;;
;; (when (file-exists-p (expand-file-name "~/projects/lisp/sly-package-inferred"))
;;   (add-to-list 'load-path (expand-file-name "~/projects/lisp/sly-package-inferred"))
;;   (require 'sly-package-inferred))

;; A trick from https://www.n16f.net/blog/slime-compilation-tips/
(defun g-sly-maybe-show-compilation-log (success notes buffer loadp)
  (cond
   (success
    (let ((name (sly-buffer-name :compilation)))
        (when (get-buffer name)
          (kill-buffer name))))
   (t
    (sly-maybe-show-compilation-log success notes buffer loadp))))


(use-package
  sly
  :hook ((lisp-mode . sly-editing-mode)
         (lisp-mode . log4sly-mode))
  ;; :defer nil
  :bind
  (:map sly-mode-map
        ("C-c ~" . 40ants-mrepl-sync)
        ("C-c v" . 40ants-mrepl-sync)
        ;; Потерял где-то эту функцию. Потратил пару часов, пытаясь найти но ни у себя, ни в интернете не откопал
        ("C-c k" . sly-import-package-at-point)
        ("C-c u" . sly-unintern-symbol)
        ("C-o r" . sly-mrepl))
  :config
  (message "Configuring SLY")

  (setq sly-default-lisp 'sbcl-bin)

  ;; ros binary is here
  (cl-pushnew "~/.local/bin" exec-path :test #'equal)

  ;; Here we replace original hook with the new one:
(remove-hook 'sly-compilation-finished-hook
             'sly-maybe-show-compilation-log)
(add-hook 'sly-compilation-finished-hook
          'g-sly-maybe-show-compilation-log)

  (setq sly-lisp-implementations
        `((sbcl-bin ("ros" "-L" "sbcl-bin"
                     "--load" "~/.sbclrc"
                     "--eval" "(ql:quickload :quicklisp :silent t)"
                     "-Q" "run")
                    :coding-system utf-8-unix)
          (sbcl ("ros" "-L" "sbcl"
                 "--load" "~/.sbclrc"
                 ;; To load local version of quicklisp
                 ;; instead of provided by Roswell:
                 "--eval" "(ql:quickload :quicklisp :silent t)"
                 "-Q" "run")
                :coding-system utf-8-unix)
          (ccl-bin ("ros" "-L" "ccl-bin" "-Q" "run") :coding-system utf-8-unix))))


(defun 40wt-join-line ()
  (interactive)
  (join-line -1))


(use-package
 lispy
 ;; :defer nil
 :hook (lisp-mode . lispy-mode)
 :bind (:map lispy-mode-map
             ;; по умолчанию, C-w у меня забинжен на backward-kill-word,
             ;; но это ломает балансированные скобки в lispy режиме,
             ;; поэтому надо использовать специальную lispy функцию
             ("C-w" . lispy-backward-kill-word)
             ;; а это нужно чтобы по Alt-j подклеивалась следующая строка, так же
             ;; как у меня сделано для остальных режимов в 40wt-bindings.el
             ("M-j" . 40wt-join-line)
             ;; Так как Ctrl-3 почему-то не работает в Emacs, то
             ;; выход из выражения будем делать по Ctrl-o o
             ("C-o o" . lispy-right)
             ;; Перебиндим lispy на SLY
             ("M-n" . sly-next-note))
 :config
 ;; Turn on lisp style indentation
 (message "Configuring Lispy")
 
 (setq lispy-use-sly t)
 
 (setq lisp-indent-function 'common-lisp-indent-function)
 ;; (setq common-lisp-style "sbcl")
 (setq common-lisp-style-default "sbcl")

 ;; Чтобы внутри loop макросы некоторые элементы были с небольшим
 ;; отступом и была видна структура
 (setq lisp-loop-indent-subclauses t)

 ;; Запрещаем добавлять пробел после двоеточия в любых случаях
 (setq lispy-colon-no-space-regex
       '((lisp-mode . ".*")))
 
 ;; При копировании символа в :import-from, заменяем
 ;; точки на слёши.
 ;; Это было полезно, когда я рефакторил Weblocks
 ;; (setq sly-import-symbol-package-transform-function
 ;;       (lambda (package)
 ;;         (replace-regexp-in-string "\\."
 ;;                                   "/"
 ;;                                   package)))
 )

;; Previously I've used this completion, but in 2023 switched to Corfu
;; (use-package
;;  company
;;  :hook (lisp-mode . company-mode))


;; Source from
;; https://github.com/Gavinok/emacs.d/blob/588dd0cb88534c2f9455d83d9dc5468925200c3f/init.el#L564
(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.0)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preview-current 'insert) ; Do not preview current candidate
  (corfu-preselect-first nil)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets

  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("M-SPC"      . corfu-insert-separator)
              ("TAB"        . corfu-next)
              ([tab]        . corfu-next)
              ("S-TAB"      . corfu-previous)
              ([backtab]    . corfu-previous)
              ("S-<return>" . corfu-insert)
              ("RET"        . nil))

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode) ; Popup completion info
  :config
  (add-hook 'eshell-mode-hook
            (lambda () (setq-local corfu-quit-at-boundary t
                              corfu-quit-no-match t
                              corfu-auto nil)
              (corfu-mode))))
