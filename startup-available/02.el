(my-el-get-bundles
 (cider :checkout "v0.23.0")
 highlight-sexp
 geiser
 csv-mode)

;;;;;;;;;;;;;;;; packages ;;;;;;;;;;;;;;;;

(load "lambda-mode")

(use-package highlight-sexp
  :config
  (setq hl-sexp-background-color "grey95"))

(defun clojure-mode-hook ()
  (auto-revert-mode 1)
  (outline-minor-mode 1)
  (enable-paredit-mode)
  (highlight-sexp-mode 1)
  (lambda-mode 1))

(use-package clojure-mode
  :bind
  (:map clojure-mode-map
        ("C-c ," . cider-test-run-loaded-tests)
        ("C-c M-," . cider-test-run-test)
        ("C-M-x" . cider-force-eval-defun-at-point)
        ("H-b" . projectile-switch-to-buffer)
        ("H-e" . cider-eval-last-sexp)
        ("H-r" . cider-eval-region)
        ("H-x" . cider-eval-defun-at-point)
        ("H-z" . cider-switch-to-repl-buffer)
        ("H-t" . projectile-toggle-between-implementation-and-test)
        ("H-d" . cider-doc)
        ("H-i" . cider-inspect)
        ("H-k" . cider-load-buffer)
        ("H-N" . cider-eval-ns-form)
        ("H-p" . cider-pprint-eval-last-sexp)
        ("H-s" . cider-docview-source)
        ("H-n" . cider-repl-set-ns)
        ("H-m" . cider-macroexpand-1)
        ("C-H-m" . cider-macroexpand-all))
  :config
  (add-hook 'clojure-mode-hook 'clojure-mode-hook)
  (setq auto-mode-alist
        (remove-if (lambda (x)
                     (equal (car x) "\\.cljc\\'"))
                   auto-mode-alist))
  (add-to-list 'auto-mode-alist '("\\.cljc\\'" . clojurec-mode))
  (add-to-list 'auto-mode-alist '("\\.edn$" . clojurec-mode)))

(use-package cider-repl
  :config
  (cider-repl-add-shortcut "sayoonara" 'cider-quit)
  (setq cider-completion-use-context nil
        cider-prompt-for-symbol nil
        cider-repl-display-help-banner nil
        cider-use-overlays t
        cider-repl-use-pretty-printing nil
        cider-redirect-server-output-to-repl nil))

(defun cider-mode-hook ()
  (eldoc-mode)
  (outline-minor-mode)
  (paredit-mode 1))

(use-package cider
  :bind
  (:map cider-mode-map
        ("C-c C-k" . cider-load-buffer-ext))
  :config
  (add-hook 'cider-mode-hook 'cider-mode-hook)
  (setq cider-lein-parameters "trampoline repl :headless"
        cider-clojure-global-options "-Anrepl:dev"
        cider-clojure-cli-global-options "-Anrepl:dev")
  (add-to-list 'clojure-build-tool-files "deps.edn"))

(defun cider--remove-current-ns (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (cider-tooling-eval
     (format "(remove-ns '%s)" (cider-current-ns))
     (cider-interactive-eval-handler (current-buffer)))))

(defun cider-load-buffer-ext (&optional arg)
  (interactive "p")
  (if (< 1 arg)
      (progn
        (message "Removing namespace: %s" (cider-current-ns))
        (cider--remove-current-ns)
        (cider-load-buffer))
    (cider-load-buffer)))

(defun cider--remove-sym (sym)
  (with-current-buffer (current-buffer)
    (cider-tooling-eval
     (format "(ns-unmap *ns* '%s)" sym)
     (cider-interactive-eval-handler (current-buffer)))))

(defun cider-force-eval-defun-at-point (&optional arg)
  (interactive "p")
  (when (< 1 arg)
    (save-excursion
      (beginning-of-defun)
      (forward-char)
      (forward-sexp 2)
      (backward-sexp)
      (when (string-match "^\\^" (cider-sexp-at-point))
        (forward-sexp 2)
        (backward-sexp))
      (let ((sym (cider-symbol-at-point)))
        (message "Removing sym: %s" sym)
        (cider--remove-sym sym))))
  (cider-eval-defun-at-point nil))

(use-package csv-mode
  :config
  (setq csv-align-style 'auto))

(use-package ediff
  :config
  (set 'ediff-window-setup-function 'ediff-setup-windows-plain))

(defun setup-geiser ()
  )

(use-package geiser
  :config
  (add-hook 'geiser-mode-hook 'setup-geiser))

(defun run-chez ()
  (interactive)
  (run-geiser 'chez))

(defun run-guile ()
  (interactive)
  (run-geiser 'guile))

(defun run-racket ()
  (interactive)
  (run-geiser 'racket))

(use-package graphviz-dot-mode
  :config
  (setq graphviz-dot-view-command "xdot %s"))

(use-package sql
  :config
  (dolist (pv '((:prompt-regexp "^[-[:alnum:]_]*=[#>] ")
                (:prompt-cont-regexp "^[-[:alnum:]_]*[-(][#>] ")))
    (apply 'sql-set-product-feature 'postgres pv)))

(defun my-emacs-lisp-mode-hook ()
  ;; (local-set-key " " 'lisp-complete-symbol)
  (outline-minor-mode 1)
  (setq outline-regexp "^[(;]"
        indent-tabs-mode nil)
  ;; (setup-lisp-indent-function)
  (local-set-key "\M-." 'find-function)
  (font-lock-mode 1)
  ;; (auto-complete-mode -1)
  (eldoc-mode 1)
  (paredit-mode 1)
  (lambda-mode 1))

(defun setup-lisp-indent-function (&optional indent-function)
  (let ((indent-function (or indent-function 'lisp-indent-function))
        (lisp-indent-alist '((awhen . 1)
                             (when-let . 1)
                             (aif . if)
                             (if-let . if)
                             (awhile . 1)
                             (while-let . 1)
                             (bind . 1)
                             (callback . lambda)
                             (c-fficall . with-slots)
                             (with-cwd . 1)
                             (save-values . 1))))
    (dolist (x lisp-indent-alist)
      (put (car x)
           indent-function
           (if (numberp (cdr x))
               (cdr x)
             (get (cdr x) indent-function))))))

(defun set-common-lisp-block-comment-syntax ()
  (modify-syntax-entry ?# "<1" font-lock-syntax-table)
  (modify-syntax-entry ?| ">2" font-lock-syntax-table)
  (modify-syntax-entry ?| "<3" font-lock-syntax-table)
  (modify-syntax-entry ?# ">4" font-lock-syntax-table))

(defun my-common-lisp-mode-hook ()
  (font-lock-mode)
  (font-lock-add-keywords 'lisp-mode
                          '(("defclass\*" . font-lock-keyword-face)))
  (modify-syntax-entry ?\[ "(]" lisp-mode-syntax-table)
  (modify-syntax-entry ?\] ")[" lisp-mode-syntax-table)
  (set (make-local-variable 'lisp-indent-function) 'common-lisp-indent-function)
  (setup-lisp-indent-function 'common-lisp-indent-function)
  (setq indent-tabs-mode nil))

(use-package lisp-mode
  :config
  (add-hook 'emacs-lisp-mode-hook 'my-emacs-lisp-mode-hook)
  (add-hook 'lisp-interaction-mode-hook 'my-emacs-lisp-mode-hook)
  (add-hook 'lisp-mode-hook 'my-common-lisp-mode-hook)
  (add-to-list 'auto-mode-alist '("\\.cl\\'" . lisp-mode))
  (enable-paredit-mode)
  (advice-add 'find-function-do-it :around #'find-function-do-it-around))
