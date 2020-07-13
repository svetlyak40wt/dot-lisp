(if (file-exists-p (expand-file-name "~/projects/lisp/sly"))
    (add-to-list 'load-path (expand-file-name "~/projects/lisp/sly")))

(if (file-exists-p (expand-file-name "~/projects/lisp/lispy"))
    (add-to-list 'load-path (expand-file-name "~/projects/lisp/lispy")))


;;(require 'hideshow)

;;(use-package lispy)


(use-package
 slime
 ;; Делаем так, чтобы SLIME не добавлял свой хук,
 ;; и SLY не жаловался на него каждый раз когда делаешь M-x sly
 :config (setq lisp-mode-hook nil))           


(defun 40ants-mrepl-sync ()
  (interactive)
  (sly-mrepl-sync (sly-current-package)
                  ;; don't change directory
                  nil))

(use-package
 sly
 :hook (lisp-mode . sly-editing-mode)
 ;; :defer nil
 :bind
 (:map sly-mode-map
  ("C-c ~" . 40ants-mrepl-sync)
  ("C-c v" . 40ants-mrepl-sync)
  ("C-c u" . sly-unintern-symbol)
  ("C-o r" . sly-mrepl))
 :config
 (message "Configuring SLY") 
 (setq sly-default-lisp 'sbcl)
 (setq sly-lisp-implementations
       `((sbcl ("ros" "-L" "sbcl" "-Q" "run") :coding-system utf-8-unix)
         (sbcl-bin ("ros" "-L" "sbcl-bin" "-Q" "run") :coding-system utf-8-unix)
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

(use-package
 company
 :hook (lisp-mode . company-mode))
