(my-el-get-bundles
 diminish
 dired-hacks
 geiser
 gh
 graphviz-dot-mode
 guide-key
 magit
 magit-gh-pulls
 magit-todos
 markdown-mode
 paredit
 plantuml-mode
 projectile
 window-numbering)

;;;;;;;;;;;;;;;; user-prefix keymap ;;;;;;;;;;;;;;;;

(defun user-commands-prefix-help ()
  (interactive)
  (message "Welcome to the User Commands Prefix map"))

(defvar user-commands-prefix-map (make-sparse-keymap))

(defun set-user-commands-prefix-key (k)
  (global-unset-key k)
  (define-prefix-command 'user-commands-prefix
    'user-commands-prefix-map
    k)
  (define-key global-map k 'user-commands-prefix))
;; (set-user-commands-prefix-key (kbd "C-;"))
(set-user-commands-prefix-key (kbd "\C-\\"))

(define-keys user-commands-prefix-map
  '(("\C-\\" compile)
    ("." find-tag)
    ("2" 2col-view)
    ("3" 3col-view)
    ("4" 4col-view)
    ("9" fill-vertical-panes)
    ("<" pop-tag-mark)
    ("\C-l" bury-buffer)
    ("g" toggle-debug-on-error)
    ("j" jump-to-register)
    ("l" cider-jack-in)
    ("m" switch-to-mu4e)
    ("o" browse-url-default-browser)
    ("q" switch-back)
    ("r" cider-switch-to-current-repl-buffer)
    ("t" toggle-truncate-lines)
    ("u" browse-url)
    ("v" magit-status)
    ("w" window-configuration-to-register)
    ("W" visual-line-mode)
    ("z" switch-to-app)
    ("\C-z" switch-to-app)
    ("|" toggle-window-split)
    ("\C-c" display-time-world)))

;;;;;;;;;;;;;;;;

(use-package buffer-move
  :bind (:map user-commands-prefix-map
              ("<left>"  . buf-move-left)
              ("<right>" . buf-move-right)
              ("<down>"  . buf-move-down)
              ("<up>"    . buf-move-up)))

(use-package diary-lib
  :config
  (add-hook 'list-diary-entries-hook 'include-other-diary-files t)
  (add-hook 'diary-hook 'appt-make-list)
  (add-hook 'diary-list-entries-hook 'diary-include-other-diary-files)
  (add-hook 'diary-mark-entries-hook 'diary-mark-included-diary-files)
  (when (file-exists-p diary-file)
    (diary 0)))

(use-package ansi-color
  :config
  (autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
  (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
  (add-hook 'comint-mode-hook 'ansi-color-for-comint-mode-on)
  (add-hook 'compilation-filter-hook 'compilation-mode-colorize-buffer)
  (add-hook 'eshell-preoutput-filter-functions 'ansi-color-filter-apply))

(defun magit-setup-hook ()
  (local-unset-key [C-tab])
  (define-key magit-mode-map [C-tab] nil)
  (global-set-key [f2] 'magit-status))

(use-package magit
  :config
  (when (facep 'magit-item-highlight)
    (set-face-attribute 'magit-item-highlight nil
                        :background "lightgrey"
                        :foreground "black"))
  (when (facep 'magit-tag)
    (set-face-attribute 'magit-tag nil :foreground "black"))
  (setq magit-last-seen-setup-instructions "1.4.0")
  (add-hook 'magit-mode-hook 'magit-setup-hook))

(use-package magit-todos
  :config
  (setq magit-todos-ignore-case t)
  (add-hook 'magit-mode-hook 'magit-todos-mode))

(defun add-el-get-info-dirs ()
  (require 'find-lisp)
  (let ((local-info-directory (expand-file-name "~/.emacs.d/info")))
    (unless (file-directory-p local-info-directory)
      (mkdir local-info-directory))
    (with-cwd local-info-directory
      (dolist (f (find-lisp-find-files "~/.emacs.d/el-get/" "\\.info$"))
        (let ((d (file-name-directory f)))
          (when (directory-files d nil "\\.info$")
            (call-process "install-info"
                          nil
                          '(" *info-setup*" t)
                          nil
                          "--debug"
                          f
                          "dir")
            (add-to-list 'Info-additional-directory-list d)))))
    (add-to-list 'Info-directory-list local-info-directory))
  (add-to-list 'Info-directory-list "/app/stumpwm/share/info")
  (add-to-list 'Info-directory-list "/app/sbcl/share/info")
  (add-to-list 'Info-directory-list "/usr/local/share/info"))

(use-package info
  :config
  (set-face-attribute 'info-header-node nil :foreground "black")
  (set-face-attribute 'info-node nil :foreground "black")
  (add-el-get-info-dirs))

(use-package man
  :config
  (setenv "MANPATH"
          (join ":"
                '("/usr/local/share/man/"
                  "/usr/share/man/")))
  (setenv "MANWIDTH" "80")
  (setq Man-fontify-manpage nil))

(use-package outline-mode
  :bind
  (("\C-c\C-e" . show-entry)
   ("C-c +"    . show-entry)
   ("\C-c["    . show-entry)
   ("\C-c\C-a" . show-all)
   ("C-c ("    . show-all)
   ("\C-c{"    . show-all)
   ("\C-c\C-t" . hide-body)
   ("\C-c}"    . hide-body)
   ("C-c )"    . hide-body)
   ("\C-c\C-c" . hide-entry)
   ("C-c -"    . hide-entry)
   ("\C-c]"    . hide-entry))
  :config
  (add-hook 'outline-minor-mode-hook 'setup-outline-minor-mode))

(defun alt-vc-git-annotate-command (file buf &optional rev)
  (let ((name (file-relative-name file)))
    (vc-git-command buf 0 name "blame" (if rev (concat  rev)))))

(use-package vc-git
  :config
  (fset 'vc-git-annotate-command 'alt-vc-git-annotate-command))

(use-package winner
  :bind (:map user-commands-prefix-map
              ("\C-b" . winner-undo)
              ("\C-f" . winner-redo))
  :config
  (winner-mode 1))

(use-package projectile
  :config
  (setq projectile-keymap-prefix (kbd "C-c C-p")))

;;;;;;;;;;;;;;;; startup ;;;;;;;;;;;;;;;;

(defun toggle-frame-width ()
  "Toggle between narrow and wide frame layouts"
  (interactive)
  (let ((z-wid (aif (assq 'width initial-frame-alist) (cdr it) 162)))
    (if (< (frame-width) z-wid)
        (set-frame-width (selected-frame) z-wid)
      (set-frame-width (selected-frame) 81))))

(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

(defun my-previous-window ()
  "Switch to previous window"
  (interactive)
  (other-window -1))

(defun my-next-window ()
  "Switch to next window"
  (interactive)
  (other-window 1))

(defun my-other-buffer ()
  "Replacement for bury-buffer"
  (interactive)
  (switch-to-buffer (other-buffer)))

(defun kill-files-matching (pattern)
  "Kill all buffers whose filenames match specified regexp"
  (interactive "sRegexp: ")
  (dolist (buffer (buffer-list))
    (let ((file-name (buffer-file-name buffer)))
      (if (and file-name (string-match pattern file-name))
          (kill-buffer buffer)))))

(defun narrow-forward-page (arg)
  (interactive "p")
  (widen)
  (forward-page arg)
  (narrow-to-page))

(defun narrow-backward-page (arg)
  (interactive "p")
  (widen)
  (backward-page (1+ (or arg 1)))
  (narrow-to-page))

(defun toggle-debug-on-error ()
  (interactive)
  (setq debug-on-error (not debug-on-error))
  (message "debug-on-error set to `%s'" debug-on-error))

(defun 4col-view ()
  (interactive)
  (n-col-view 4))

(defun 3col-view ()
  (interactive)
  (n-col-view 3))

(defun 2col-view ()
  (interactive)
  (n-col-view 2))

(defun dev-split-view ()
  (interactive)
  (delete-other-windows)
  (split-window-horizontally 85)
  (save-excursion
    (other-window 1)
    (split-window-vertically)
    (split-window-horizontally (/ (window-width) 2))))

(defun fill-vertical-panes ()
  (interactive)
  (delete-other-windows)
  (let ((pane-width 80)
        (cur (selected-window)))
    (save-excursion 
      (dotimes (i (1- (/ (/ (frame-pixel-width) (frame-char-width))
                         pane-width)))
        (split-window-horizontally pane-width)
        (other-window 1)
        (bury-buffer))
      (balance-windows))
    (select-window cur)))

(defun turn-on-line-truncation ()
  (interactive)
  (set-all-line-truncation t))

(defun other-window-send-keys (keys)
  (interactive (list (read-key-sequence "Keysequence: ")))
  (let ((window (selected-window)))
    (unwind-protect
        (save-excursion
          (other-window (or current-prefix-arg 1))
          (let ((last-kbd-macro (read-kbd-macro keys)))
            (call-last-kbd-macro)))
      (select-window window))))

(defun get-region-or-read-terms (prompt)
  (replace-regexp-in-string "[ ]+"
                            "+"
                            (or (region) (read-string prompt))))

(defun query-string-encode (s)
  (replace-regexp-in-string "[ ]+" "+" s))

(defun google (q)
  (interactive
   (list (query-string-encode (or (region) (read-string "Google: ")))))
  (browse-url
   (concat "https://www.google.com/search?q=" q)))

(defun ddg ()
  (interactive)
  (browse-url
   (concat "https://duckduckgo.com/?q="
           (query-string-encode (or (region) (read-string "DuckDuckGo: "))))))

(defun mdn (q)
  (interactive
   (list (query-string-encode (or (region) (read-string "MDN: ")))))
  (google (concat "site:developer.mozilla.org " q)))

(defun wikipedia ()
  (interactive)
  (browse-url
   (concat "http://en.wikipedia.org/w/index.php?search="
           (query-string-encode
            (capitalize (or (region) (read-string "Wikipedia: ")))))))

(defun emacswiki (q)
  (interactive (list (get-region-or-read-terms "emacswiki: ")))
  (browse-url
   (concat "http://www.emacswiki.org/emacs/Search?action=index&match="
           (query-string-encode q))))

(defun dired-open-file ()
  "In Dired, open a file using its default application."
  (interactive)
  (let ((file (dired-get-filename nil t)))
    (unless (file-directory-p file)
      (message "Opening %s..." file)
      (open-file-in-app file))))

(defun next-page ()
  (interactive)
  (widen)
  (forward-page)
  (narrow-to-page))

(defun prev-page ()
  (interactive)
  (widen)
  (backward-page 2)
  (narrow-to-page))

(defun rmail-mime-buffer ()
  "MIME decode the contents of the current buffer."
  (interactive)
  (let* ((data (buffer-string))
         (buf (get-buffer-create "*RMAIL*"))
         (rmail-mime-mbox-buffer rmail-view-buffer)
         (rmail-mime-view-buffer buf))
    (set-buffer buf)
    (setq buffer-undo-list t)
    (let ((inhibit-read-only t))
      ;; Decoding the message in fundamental mode for speed, only
      ;; switching to rmail-mime-mode at the end for display.  Eg
      ;; quoted-printable-decode-region gets very slow otherwise (Bug#4993).
      (fundamental-mode)
      (erase-buffer)
      (insert data)
      (rmail-mime-show t)
      (rmail-mime-mode)
      (set-buffer-modified-p nil))
    (view-buffer buf)))

(require 'ansi-color)
(defun ansi-colorize-region (&optional start end)
  "ANSI colorize a region"
  (interactive (list (mark) (point)))
  (ansi-color-apply-on-region start end))

(defun compress-whitespace ()
  "Compress the whitespace between two non-whitespace characters to a single space"
  (interactive "*")
  (save-excursion
    (save-restriction
      (save-match-data
        (progn
          (re-search-backward "[^ \t\r\n]" nil t)
          (re-search-forward "[ \t\r\n]+" nil t)
          (replace-match " " nil nil))))))

(defun my-isearch-word-at-point ()
  (interactive)
  (call-interactively 'isearch-forward-regexp))

(defun my-isearch-yank-word-hook ()
  (when (equal this-command 'my-isearch-word-at-point)
    (let ((string (concat "\\<"
                          (buffer-substring-no-properties
                           (progn (skip-syntax-backward "w_") (point))
                           (progn (skip-syntax-forward "w_") (point)))
                          "\\>")))
      (if (and isearch-case-fold-search
               (eq 'not-yanks search-upper-case))
          (setq string (downcase string)))
      (setq isearch-string string
            isearch-message
            (concat isearch-message
                    (mapconcat 'isearch-text-char-description
                               string ""))
            isearch-yank-flag t)
      (isearch-search-and-update))))

(add-hook 'isearch-mode-hook 'my-isearch-yank-word-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global key bindings

(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key [f1] 'shell)
(global-set-key [f2] 'magit-status)
(global-set-key (kbd "M-g") 'goto-line)

(global-set-key "\C-x2" (lambda () (interactive)(split-window-vertically) (other-window 1)))
(global-set-key "\C-x3" (lambda () (interactive)(split-window-horizontally) (other-window 1)))
(global-set-key "\C-xO" 'my-previous-window)

(global-set-key "\M-\\" 'compress-whitespace)
(global-set-key (kbd "C-x *") 'my-isearch-word-at-point)

