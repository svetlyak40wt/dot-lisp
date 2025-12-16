(require 'cl-lib)

(message "Configuring LISP 1")

;; (when (file-exists-p (expand-file-name "~/.roswell/lisp/slime/master"))
;;   (add-to-list 'load-path (expand-file-name "~/.roswell/lisp/slime/master")))

;; This block should go before we add a path to the SLY,
;; because otherwise SLY will check in it's autoload file if there is
;; SLIME in a lisp-mode-hook and will promt if we want to remove it
;; each time Emacs is loaded.
;; (use-package slime
;;     :config
;;   (message "Configuring SLIME")
;;   (remove-hook 'lisp-mode-hook 'slime-lisp-mode-hook))


(when (file-exists-p (expand-file-name "~/projects/sly"))
  (add-to-list 'load-path (expand-file-name "~/projects/sly")))

(when (file-exists-p (expand-file-name "~/projects/lisp/sly"))
  (add-to-list 'load-path (expand-file-name "~/projects/lisp/sly")))

(when (file-exists-p (expand-file-name "~/projects/lisp/lispy"))
  (add-to-list 'load-path (expand-file-name "~/projects/lisp/lispy")))

(message "Configuring LISP 2")

(defun 40ants-mrepl-sync ()
  (interactive)
  (sly-mrepl-sync (sly-current-package)
                  ;; don't change directory
                  nil))

(message "Configuring LISP 3")

(use-package sly-mrepl
  :defer t
  :after sly
  :bind
  ;; This does reverse to the sly-mrepl as described at
  ;; https://www.reddit.com/r/Common_Lisp/comments/17g9377/revisiting_stupid_slime_tricks/
  (:map sly-mrepl-mode-map
        ("C-o r" . sly-switch-to-most-recent)))

(use-package sly-named-readtables
  :defer t
  :after sly
  ;; :ensure t
  )

(message "Configuring LISP 4")

(use-package sly-macrostep
  :defer t
  :after sly
  ;; :ensure t
  )

(message "Configuring LISP 5")

;; https://github.com/PuercoPop/sly-repl-ansi-color
(use-package sly-repl-ansi-color
  :defer t
  :after sly
  :config
  (with-eval-after-load 'sly
    (add-to-list 'sly-contribs 'sly-repl-ansi-color 'append)))

(message "Configuring LISP 6")

;; https://github.com/fisxoj/sly-docker
;; Я так и не заставил эту штуку работать. Отключил 2025-11-27,
;; Потому что удалил docker-tramp, так как Emacs жаловался что
;; этот пакет устарел.
;; (when (file-exists-p (expand-file-name "~/projects/lisp/sly-docker"))
;;   (use-package docker-tramp
;;     :after sly
;;     :defer t)
;;   (add-to-list 'load-path (expand-file-name "~/projects/lisp/sly-docker"))
;;   (add-to-list 'sly-contribs 'sly-docker 'append))

(message "Configuring LISP 7")

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


(defun 40ants-sly-search-buffer-package ()
  (let ((name (sly-search-buffer-package)))
     (when name (string-trim-left name
                    "[:#]+"))))


(defun 40wt-configure-sly ()
  (message "Configuring SLY")

  ;; Without this wrapper, for packages having uninterned symbols
  ;; in the (in-package #:foo-bar), SLY will not show package selection
  ;; and symbol uninterning will show only Quit message without any changes:
  (setq sly-find-buffer-package-function '40ants-sly-search-buffer-package)
  ;; This style indents LOOP macro clauses
  ;; like this:
  ;;
  ;; (loop for i upto 10
  ;;         when (evenp i)
  ;;           do (foo i))
  (message "Configuring SLY 1")

  ;; Заменил на custom sly-common-lisp-style-default,
  ;; потому что тут оно вызывает исключение мол функция не найдена
  ;; (sly-common-lisp-set-style-bad "classic")

  (message "Configuring SLY 2")

  (setq sly-default-lisp 'sbcl-bin)

  (message "Configuring SLY 3")

  ;; ros binary is here
  (cl-pushnew "~/.local/bin" exec-path :test #'equal)

  ;; Here we replace original hook with the new one:
  (remove-hook 'sly-compilation-finished-hook
               'sly-maybe-show-compilation-log)
  (add-hook 'sly-compilation-finished-hook
            'g-sly-maybe-show-compilation-log)

  (message "Configuring SLY 4")

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
          (ccl-bin ("ros" "-L" "ccl-bin" "-Q" "run") :coding-system utf-8-unix)))

  (message "Configuring SLY 5")
  
  (when (file-exists-p (expand-file-name "~/projects/lisp/log4sly/elisp")) ;
    (add-to-list 'load-path (expand-file-name "~/projects/lisp/log4sly/elisp"))
    (require 'log4sly))

  (message "Configuring SLY DONE"))


(message "Configuring LISP 8")

(use-package
    sly
    :defer t
    ;; To suppress this warning:
    ;; Warning (emacs): To restore SLIME in this session, customize ‘lisp-mode-hook’ and replace ‘sly-editing-mode’ with ‘slime-lisp-mode-hook’.
    :init (remove-hook 'lisp-mode-hook 'slime-lisp-mode-hook)
;    :hook ((lisp-mode . sly-editing-mode)
           ;; (lisp-mode . log4sly-mode)
;           )
    ;; :defer nil
    :custom
    (sly-replace-slime t)
    (sly-common-lisp-style-default "classic")

    :bind
    (:map sly-mode-map
          ("C-c ~" . 40ants-mrepl-sync)
          ("C-c v" . 40ants-mrepl-sync)
          ;; Потерял где-то эту функцию. Потратил пару часов, пытаясь найти но ни у себя, ни в интернете не откопал
          ("C-c k" . sly-import-package-at-point)
          ("C-c u" . sly-unintern-symbol))
    (:map lisp-mode-map
          ("C-o r" . sly-mrepl)))


(defun 40wt-safe-run-with-logging (func &rest args)
  "Run FUNC with ARGS, catch errors, log to *Errors* buffer with trace."
  (condition-case err
      (apply func args)
    (error
     (let ((err-msg (error-message-string err))
           (trace (with-output-to-string (backtrace))))
       (with-current-buffer (get-buffer-create "*Errors*")
         (goto-char (point-max))
         (insert (format "=== ERROR ===\n%s\n\nBacktrace:\n%s\n" err-msg trace)))
       (message "ERROR: %s, more info in *Errors* buffer"
                err-msg)))))


(eval-after-load 'sly-cl-indent
  (40wt-safe-run-with-logging '40wt-configure-sly))


(defun 40wt-join-line ()
  (interactive)
  (join-line -1))

(message "Configuring LISP 9")

(use-package
 lispy
 :defer t
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
 
 (setq lisp-indent-function 'sly-common-lisp-indent-function)
 ;; (setq common-lisp-style "sbcl")
 (setq common-lisp-style-default "classic")

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


(message "Configuring LISP 10")

;; Source from
;; https://github.com/Gavinok/emacs.d/blob/588dd0cb88534c2f9455d83d9dc5468925200c3f/init.el#L564
(use-package corfu
  ;; Optional customizations
  :defer t
  :custom
  (corfu-cycle t)                       ; Allows cycling through candidates
  (corfu-auto t)                        ; Enable auto completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 3.0)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preview-current 'insert)       ; Do not preview current candidate
  (corfu-preselect-first t)
  (corfu-on-exact-match nil)            ; Don't auto expand tempel snippets

  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("M-SPC"      . corfu-insert-separator)
              ("TAB"        . corfu-next)
              ([tab]        . corfu-next)
              ("S-TAB"      . corfu-previous)
              ([backtab]    . corfu-previous)
              ("S-<return>" . corfu-insert)
              ("RET"        . corfu-insert))

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-echo-mode)
  (corfu-popupinfo-mode)                ; Popup completion info
  :config
  (add-hook 'eshell-mode-hook
            (lambda ()
              (setq-local corfu-quit-at-boundary t
                          corfu-quit-no-match t
                          corfu-auto nil)
              (corfu-mode))))


(message "Configuring LISP 11")

;; To make corfu work
(use-package corfu-terminal
  :defer t
  :config
  (unless (display-graphic-p)
    (corfu-terminal-mode +1)))

(message "Configuring LISP 12")

(remove-hook 'lisp-mode-hook 'slime-lisp-mode-hook)

(message "Configuring LISP DONE")
