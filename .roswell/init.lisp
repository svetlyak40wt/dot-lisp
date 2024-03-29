(in-package :cl-user)

;; #+sbcl
;; (sb-ext:restrict-compiler-policy 'debug 3)

;; Это включает ворнинги на несоответствие типов
;; для слотов классов, где указаны типы
;; #+sbcl
;; (sb-ext:restrict-compiler-policy 'safety 3)

#-sbcl
(declaim (optimize (debug 3) (safety 3)))


;; Загружается через Emacs
;; (pushnew "~/projects/lisp/sly-package-inferred/" asdf:*central-registry*
;;          :test #'equal)
;; (pushnew "~/projects/lisp/sly/slynk/" asdf:*central-registry*
;;          :test #'equal)

;; (let ((*debug-io* (make-broadcast-stream)))
;;   (ql:quickload :sly-package-inferred :silent t))

;; (sly-package-inferred/completion:install)


;;; Use CLPM with default configuration.
;;;
;;; Generated by CLPM 0.4.0-0.14+g2aa742a-dirty

#+lispworks
(setf system:*stack-overflow-behaviour* nil)

(require "asdf")

;; (pushnew "~/projects/lisp/cffi/"
;;            asdf:*central-registry*
;;            :test 'equal)

;; Unnecessary since PR was merged:
;; https://github.com/cl-plus-ssl/cl-plus-ssl/pull/180
;; (when (probe-file "~/projects/lisp/cl-plus-ssl-osx-fix/")
;;   (pushnew "~/projects/lisp/cl-plus-ssl-osx-fix/"
;;            asdf:*central-registry*
;;            :test 'equal)
;;   (pushnew "~/projects/lisp/40ants-asdf-system/"
;;            asdf:*central-registry*
;;            :test 'equal)
;;   ;; (pushnew "~/projects/lisp/cl-plus-ssl/"
;;   ;;          asdf:*central-registry*
;;   ;;          :test 'equal)
;;   ;; (asdf:load-asd "~/projects/lisp/cl-plus-ssl/cl+ssl.asd")

;;   ;; (asdf:load-system "quicklisp")

;;   ;; (uiop:symbol-call :ql :quickload "cl-plus-ssl-osx-fix")

;;   ;; #+quicklisp
;;   ;; (ql:quickload "cl-plus-ssl-osx-fix")
;;   ;; #+asdf
;;   (asdf:load-system "cl-plus-ssl-osx-fix"))

;; #-clpm-client
(defun load-clpm ()
  (when (asdf:find-system "clpm-client" nil)
    ;; Load the CLPM client if we can find it.
    (asdf:load-system "clpm-client")

    (let ((local-clpmfile (probe-file #P"clpmfile")))
      (when local-clpmfile
        (format t "Activating CLPM bunldle ~A~%"
                local-clpmfile)
        (uiop:symbol-call :clpm-client '#:activate-context
                          local-clpmfile)))

    (when (uiop:symbol-call :clpm-client '#:active-context)
      ;; If started inside a context (i.e., with `clpm exec` or `clpm bundle exec`),
      ;; activate ASDF integration
      (uiop:symbol-call :clpm-client '#:activate-asdf-integration))))


;;#-ocicl
;;(when (probe-file #P"/Users/art/.local/share/ocicl/ocicl-runtime.lisp")
;;  (load #P"/Users/art/.local/share/ocicl/ocicl-runtime.lisp"))


;;(setf ocicl-runtime:*verbose* t)
;; Any systems you install in /Users/art/.local/share/ocicl/
;; will be available globally unless you comment out this line:
;;(asdf:initialize-source-registry
;;  '(:source-registry :ignore-inherited-configuration (:tree #P"/Users/art/.local/share/ocicl/")))

;; Autoactivates CLPM and bundle if clpmfile was found
;; (load-clpm)
