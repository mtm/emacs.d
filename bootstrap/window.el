(load-relative
 (concat (symbol-name (or window-system 'tty)) ".el"))
(blink-cursor-mode -1)
(tool-bar-mode -1)
;; (menu-bar-mode -1)
(setq isearch-lazy-highlight nil)
(set-default 'cursor-in-non-selected-windows nil)
(set-default 'mode-line-in-non-selected-windows nil)

(defun light-theme-white ()
  (interactive)
  (let ((fgcolor "black")
        (bgcolor "white"))
    (when window-system
      (set-foreground-color fgcolor)
      (set-background-color bgcolor)
      (set-face-foreground 'mode-line bgcolor)
      (set-face-background 'mode-line fgcolor)
      (set-cursor-color "red")
      (set-face-foreground 'default fgcolor))
    (set-face-foreground 'region fgcolor)
    (set-face-background 'region "lightgrey")
    (set-face-foreground 'minibuffer-prompt fgcolor)
    (set-face-background 'minibuffer-prompt nil)
    (unless window-system
      (set-face-foreground 'mode-line fgcolor)
      (set-face-background 'mode-line bgcolor)
      (set-face-foreground 'menu bgcolor))
    (set-face-background 'isearch "indian red")
    (set-face-foreground 'isearch "white")
    (set-face-background 'fringe "grey99")
    (when (boundp 'font-lock-comment-face)
      (set-face-foreground 'font-lock-comment-face "DimGrey")
      (set-face-foreground 'font-lock-builtin-face "gray20")
      (set-face-foreground 'font-lock-constant-face "DimGrey")
      (set-face-foreground 'font-lock-function-name-face "blue")
      (set-face-foreground 'font-lock-keyword-face "gray20")
      (set-face-foreground 'font-lock-string-face "DimGrey")
      (set-face-foreground 'font-lock-type-face fgcolor)
      (set-face-foreground 'font-lock-variable-name-face fgcolor)
      (set-face-foreground 'font-lock-warning-face "red"))
    (set-face-attribute 'vertical-border nil :background bgcolor :foreground fgcolor)))

(light-theme-white)

(defun dark-theme-green ()
  (interactive)
  (let ((fgcolor "green")
	(bgcolor "black"))
    (when window-system
      (set-foreground-color fgcolor)
      (set-background-color bgcolor)
      (set-face-foreground 'mode-line bgcolor)
      (set-face-background 'mode-line fgcolor)
      (set-cursor-color "red")
      (set-face-foreground 'default fgcolor))
    (set-face-foreground 'region bgcolor)
    (set-face-background 'region fgcolor)
    (unless window-system
      (set-face-foreground 'mode-line fgcolor)
      (set-face-foreground 'menu fgcolor))
    (when (string-match "^2[123]" emacs-version)
      (set-face-background 'isearch "indian red")
      (set-face-foreground 'isearch bgcolor))
    (set-face-foreground 'minibuffer-prompt fgcolor)
    (set-face-background 'fringe bgcolor)
    (when (boundp 'font-lock-comment-face)
      (set-face-foreground 'font-lock-comment-face "DimGrey")
      (set-face-foreground 'font-lock-builtin-face "green4")
      (set-face-foreground 'font-lock-constant-face "green4")
      (set-face-foreground 'font-lock-function-name-face "DarkSlateGray1")
      ;; (set-face-foreground 'font-lock-function-name-face "green")
      (set-face-foreground 'font-lock-keyword-face "green4")
      (set-face-foreground 'font-lock-string-face "green")
      (set-face-foreground 'font-lock-type-face fgcolor)
      (set-face-foreground 'font-lock-variable-name-face fgcolor)
      (set-face-foreground 'font-lock-warning-face "red"))
    (set-face-attribute 'vertical-border nil :background bgcolor :foreground fgcolor)))

;; (dark-theme-green)

(defun dark-theme-amber ()
  (interactive)
  (let ((fgcolor "DarkGoldenrod3")
	(bgcolor "black"))
    (when window-system
      (set-foreground-color fgcolor)
      (set-background-color bgcolor)
      (set-face-foreground 'mode-line bgcolor)
      (set-face-background 'mode-line fgcolor)
      (set-cursor-color "red")
      (set-face-foreground 'default fgcolor))
    (set-face-foreground 'region bgcolor)
    (set-face-background 'region fgcolor)
    (unless window-system
      (set-face-foreground 'mode-line fgcolor)
      (set-face-foreground 'menu fgcolor))
    (when (string-match "^2[123]" emacs-version)
      (set-face-background 'isearch "indian red")
      (set-face-foreground 'isearch bgcolor))
    (set-face-foreground 'minibuffer-prompt fgcolor)
    (set-face-background 'fringe bgcolor)
    (when (boundp 'font-lock-comment-face)
      (set-face-foreground 'font-lock-comment-face "DimGrey")
      (set-face-foreground 'font-lock-builtin-face "DarkGoldenrod4")
      (set-face-foreground 'font-lock-constant-face "green4")
      (set-face-foreground 'font-lock-function-name-face "DarkGoldenrod1")
      ;; (set-face-foreground 'font-lock-function-name-face "green")
      (set-face-foreground 'font-lock-keyword-face "DarkGoldenrod4")
      (set-face-foreground 'font-lock-string-face fgcolor)
      (set-face-foreground 'font-lock-type-face fgcolor)
      (set-face-foreground 'font-lock-variable-name-face fgcolor)
      (set-face-foreground 'font-lock-warning-face "red"))
    (set-face-attribute 'vertical-border nil :background bgcolor :foreground fgcolor)))

;; (dark-theme-amber)
