(cond
  ((file-exists-p (expand-file-name "~/.roswell/helper.el"))
   (load (expand-file-name "~/.roswell/helper.el")))
  ;; ((file-exists-p (expand-file-name "~/.roswell/lisp/quicklisp/slime-helper.el"))
  ;;  (load (expand-file-name "~/.roswell/lisp/quicklisp/slime-helper.el")))
  ;; ((file-exists-p (expand-file-name "~/quicklisp/slime-helper.el"))
  ;;  (load (expand-file-name "~/quicklisp/slime-helper.el")))
  ;; (t (require-or-install 'slime))
  )

(if (file-exists-p (expand-file-name "~/projects/lisp/sly"))
    (add-to-list 'load-path (expand-file-name "~/projects/lisp/sly")))

(if (file-exists-p (expand-file-name "~/projects/lisp/lispy"))
    (add-to-list 'load-path (expand-file-name "~/projects/lisp/lispy")))

;;(require 'slime-autoloads)
(require 'hideshow)
(require-or-install 'lispy)


(setq sly-default-lisp 'ccl)
(setq sly-lisp-implementations
      `((sbcl ("ros" "-L" "sbcl-bin" "-Q" "run") :coding-system utf-8-unix)
        (ccl ("ros" "-L" "ccl-bin" "-Q" "run") :coding-system utf-8-unix)))


;; snippets
;; (require-or-install 'yasnippet)
;; (require-or-install 'common-lisp-snippets)


;; (eval-after-load
;;     'slime
;;   `(progn
;;      (use-packages '(yasnippet
;;                      common-lisp-snippets
;;                      helm-projectile
;;                      helm-ag))
    
;;      (define-key slime-mode-map (kbd "C-c u f") 'slime-undefine-function)
;;      (define-key slime-mode-map (kbd "C-c u s") 'slime-unintern-symbol)
;;      (define-key slime-mode-map (kbd "C-c u p") 'slime-delete-package)
     
;;      (define-key slime-mode-map (kbd "C-c s") 'slime-selector)
;;      (define-key slime-repl-mode-map (kbd "C-c s") 'slime-selector)
    
;;      ;; Now will try to load log4slime mode
;;      (with-no-warnings
;;        (when (file-exists-p (expand-file-name "~/.roswell/lisp/quicklisp/log4slime-setup.el"))
;;          (load (expand-file-name "~/.roswell/lisp/quicklisp/log4slime-setup.el"))
;;          (global-log4slime-mode 1)))))


;; (eval-after-load 'shell
;;   '(progn
;;      (define-key shell-mode-map (kbd "C-c s") 'slime-selector)))


;; (require-or-install 'slime-company)
;(require-or-install 'slime-presentations)

;; (setq slime-contribs
;;       '(slime-fancy
;;         slime-banner
;;         ;; To make a nice loop indentation.
;;         ;; More details:
;;         ;; https://emacs.stackexchange.com/questions/30788/why-does-emacs-indent-my-lisp-loop-construct-weirdly
;;         slime-indentation
;;         ;; slime-repl-ansi-color
;;         slime-company
;;         ))
;; (slime-setup slime-contribs)

;; Turn on lisp style indentation
(setq lisp-indent-function 'common-lisp-indent-function)
(setq common-lisp-style "sbcl")


;; This snippet expands hide/show block when cursor is
;; moved via goto-line or search (which uses goto-line under the hood).
;; Take from https://www.emacswiki.org/emacs/HideShow
(defadvice goto-line (after expand-after-goto-line
                            activate compile)
  "hideshow-expand affected block when using goto-line in a collapsed buffer"
  (save-excursion
   (hs-show-block)))

(defadvice goto-char (after expand-after-goto-line
                            activate compile)
  "hideshow-expand affected block when using goto-line in a collapsed buffer"
  (save-excursion
   (hs-show-block)))

(defadvice helm-ag-mode-jump (after expand-after-helm-ag-mode-jump
                            activate compile)
  "hideshow-expand affected block when using helm-ag-mode-jump in a collapsed buffer"
  (save-excursion
   (hs-show-block)))


;; (add-hook 'slime-repl-mode-hook
;;           (lambda ()
;;             (slime-eval '(cl:progn
;;                           ;; enable loading of the system from current working directory
;;                           (cl:pushnew "./" asdf:*central-registry*)
;;                           (cl:declaim (cl:optimize (cl:debug 3)))))
            
;;             ;; For some reason, lisp runned by roswell,
;;             ;; does not load ~/.sbclrc so we'll do this now
;;             ;; (slime-eval '(cl:let ((path (cl:merge-pathnames
;;             ;;                              (cl:user-homedir-pathname)
;;             ;;                              "~/.sbclrc")))
;;             ;;                      (cl:when (cl:probe-file path)
;;             ;;                        (cl:load path))))
            
;;             ;; (el-get 'sync 'slime-repl-ansi-color)
;;             ;; (slime-setup '(slime-repl-ansi-color))
;;             ))

(defun 40ants-mrepl-sync ()
  (interactive)
  (sly-mrepl-sync (sly-current-package)
                  ;; don't change directory
                  nil))

(add-hook 'sly-mode-hook
          '(lambda ()
            (message "REDefining sly-mrepl-sync from my settings")
            (define-key sly-mode-map (kbd "C-c ~") '40ants-mrepl-sync)
            (define-key sly-mode-map (kbd "C-c u") 'sly-unintern-symbol)))


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
     ;; (define-key paredit-mode-map (kbd "M-[ d") 'paredit-forward-barf-sexp)
     ;; (define-key paredit-mode-map (kbd "M-[ c") 'paredit-forward-slurp-sexp)
     ))

(eval-after-load 'lispy
  `(progn
     ;; по умолчанию, C-w у меня забинжен на backward-kill-word,
     ;; но это ломает балансированные скобки в lispy режиме,
     ;; поэтому надо использовать специальную lispy функцию
     (define-key lispy-mode-map (kbd "C-w") 'lispy-backward-kill-word)
     ;; а это нужно чтобы по Alt-j подклеивалась следующая строка, так же
     ;; как у меня сделано для остальных режимов в 40wt-bindings.el
     (define-key lispy-mode-map (kbd "M-j")
       (lambda ()
         (interactive)
         (join-line -1)))

     ;; Так как Ctrl-3 почему-то не работает в Emacs, то
     ;; выход из выражения будем делать по Ctrl-o o
     (define-key lispy-mode-map (kbd "C-o o")
       'lispy-right)))


(add-hook 'lisp-mode-hook
          (lambda ()
            (lispy-mode 1)
            (setq-local lispy-use-sly t)
            ;; Запрещаем добавлять пробел после двоеточия в любых случаях
            (setq-local lispy-colon-no-space-regex
                        '((lisp-mode . ".*")))
            
            ;; При копировании символа в :import-from, заменяем
            ;; точки на слёши
            (setq sly-import-symbol-package-transform-function
                  (lambda (package)
                    (replace-regexp-in-string "\\."
                                              "/"
                                              package)))
            
            ;; сниппеты
            (yas-minor-mode)
            ;; для работы с проектом
            (projectile-global-mode)
            (setq projectile-completion-system 'helm)

            ;; Helm is overhelming!
            (helm-mode)
            (helm-projectile-on)


            ;; Настраиваем хоткеи для скрытия блоков
            (hs-minor-mode 1)
            (hs-hide-all)
            
            (local-set-key (kbd "C-c <up>") 'hs-hide-block)
            (local-set-key (kbd "C-c C-x <up>") 'hs-hide-all)
            (local-set-key (kbd "C-c <left>") 'bm-previous)
            (local-set-key (kbd "C-c <down>") 'hs-show-block)
            (local-set-key (kbd "C-c <right>") 'bm-next)))

(defun 40wt-switch-to-ielm-buffer ()
  (interactive)
  (switch-to-buffer "*ielm*"))


(defun 40wt-init-lisp-repl ()
  (warn "Loading custom LISP configuration for the REPL")
  
  ;; (sly-eval '(cl:progn
  ;;             (cl:ignore-errors (ql:quickload :prove))
  ;;             (cl:ignore-errors (ql:quickload :rove))
  ;;             (cl:ignore-errors (ql:quickload :log4slime))))

  (let ((log4slime-exists (sly-eval '(cl:when (cl:find-package :log4slime)
                                      t)))
        (prove-exists (sly-eval '(cl:when (cl:find-package :prove)
                                  t)))
        (rove-exists (sly-eval '(cl:when (cl:find-package :rove)
                                 t))))
    (unless prove-exists
      (warn "Package prove was not found."))
    (unless rove-exists
      (warn "Package rove was not found."))
    (unless log4slime-exists
      (warn "Package log4slime was not found."))
  
    (when prove-exists
      ;; что-то в емаксе не показываются нормально цвета
      (sly-eval '(cl:setf prove:*enable-colors* nil
                  ;; и я хочу чтобы выскакивал дебаггер на каждую ошибку
                  prove:*debug-on-error* t)))

    ;; Я хочу чтобы выскакивал дебаггер на каждую ошибку,
    ;; но иногда rove может быть недоступна
    (when rove-exists
      (sly-eval '(cl:setf rove:*debug-on-error* t)))
  
    (when log4slime-exists
      (let ((log4slime-el (sly-eval '(cl:format nil
                                      "~Alog4slime-setup.el"
                                      log4slime:*QUICKLISP-DIRECTORY*))))
        (unless (file-exists-p log4slime-el)
          (sly-eval '(log4slime:install)))

        ;; Если файла всё ещё нет, возможно мы запустили install на удалённой машине

        (cond
          ((file-exists-p log4slime-el)
           (load log4slime-el)
           (global-log4slime-mode 1))
          (t (warn "Unable to load emacs part of the Log4Slime. Seems you are connecting to remote Lisp.")))))))


(add-hook 'sly-mrepl-mode-hook
          '40wt-init-lisp-repl
          ;; append
          t)


(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            ;; автоматически стартуем lispy-mode и для Emacs Lisp
            (lispy-mode 1)

            ;; по C-o переключаемся на IELM буфер, так же как SLY переключает
            ;; на Common Lisp REPL
            (define-key emacs-lisp-mode-map (kbd "C-o r")
              '40wt-switch-to-ielm-buffer)))
