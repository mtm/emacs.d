;;;;;;;;;;;;;;;; dependencies ;;;;;;;;;;;;;;;;

(my-el-get-bundles
 alert
;; (disable-mouse :url "https://github.com/purcell/disable-mouse.git"
;;                :features disable-mouse)
 dictionary
;; elscreen
 edit-server
 ;; (ipinfo.el :url "https://github.com/dakra/ipinfo.el.git"
 ;;            :features ipinfo)
 (password-mode
  :url "https://github.com/juergenhoetzel/password-mode.git"
  :features password-mode)
 magit-popup
 pdf-tools
 forge)

;;;;;;;;;;;;;;;; packages ;;;;;;;;;;;;;;;;

(use-package dictionary
  :bind
  (("\C-cs" . dictionary-search)
   ("\C-cm" . dictionary-match-words))
  :config
  (load-library "dictionary-init"))

;; (use-package elscreen
;;   :demand t
;;   :bind
;;   (:map elscreen-map
;;         ("z" . elscreen-toggle)
;;         ("\C-z" . elscreen-toggle))
;;   :config
;;   (global-unset-key "\C-z")
;;   (setq elscreen-display-tab nil))

(defun iso-calendar ()
  (interactive)
  (setq european-calendar-style nil)
  (setq calendar-date-display-form
        '(year
          "-"
          (if (< (length month) 2) (concat "0" month) month)
          "-"
          (if (< (length day) 2) (concat "0" day) day)))
  (setq diary-date-forms
        '((year "-" month "-" day "[^0-9]")
          (month "/" day "[^/0-9]")
          (month "/" day "/" year "[^0-9]")
          (monthname " *" day "[^,0-9]")
          (monthname " *" day ", *" year "[^0-9]")
          (dayname "\\W")))
  (cond
   ((string-match "^2[12]" emacs-version)
    (update-calendar-mode-line))
   (t
    (when (fboundp 'calendar-update-mode-line)
      (calendar-update-mode-line)))))

(use-package calendar
  :config
  (iso-calendar)
  (add-hook 'diary-display-hook 'fancy-diary-display)
  ;; (add-hook 'calendar-load-hook 'mark-diary-entries)
  (add-hook 'list-diary-entries-hook 'sort-diary-entries t)
  (setq display-time-day-and-date nil
        display-time-world-list '(("Pacific/Honolulu" "Honolulu")
                                  ("America/Anchorage" "Anchorage")
                                  ("America/Los_Angeles" "Los Angeles")
                                  ("America/Phoenix" "Phoenix")
                                  ("America/Chicago" "Chicago")
                                  ("America/New_York" "New York")
                                  ("Europe/London" "London")
                                  ("Europe/Paris" "Paris")
                                  ("Asia/Calcutta" "Calcutta")
                                  ("Asia/Singapore" "Singapore")
                                  ("Australia/Sydney" "Sydney")
                                  ("Pacific/Auckland" "Auckland"))
        display-time-world-time-format "%a %d %b %R %Z"))

;; (use-package disable-mouse
;;   :diminish disable-mouse-global-mode
;;   :delight disable-mouse-global-mode
;;   :config
;;   (global-disable-mouse-mode))

(use-package edit-server
  :config
  (setq edit-server-default-major-mode 'normal-mode
        edit-server-new-frame nil)
  (edit-server-start))

;; (use-package ipinfo)

(defun my-midnight-hook ()
  (org-gcal-multi-fetch)
  (org-agenda-list nil nil 'day))

(use-package midnight
  :config
  (midnight-delay-set 'midnight-delay "9:00am")
  (add-hook 'midnight-hook 'my-midnight-hook))

(use-package password-mode)

(use-package pdf-tools
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page)
  (bind-keys :map pdf-view-mode-map
             ("<s-spc>" .  pdf-view-scroll-down-or-previous-page)
             ("g"  . pdf-view-first-page)
             ("G"  . pdf-view-last-page)
             ("l"  . image-forward-hscroll)
             ("h"  . image-backward-hscroll)
             ("j"  . pdf-view-next-page)
             ("k"  . pdf-view-previous-page)
             ("e"  . pdf-view-goto-page)
             ("u"  . pdf-view-revert-buffer)
             ("al" . pdf-annot-list-annotations)
             ("ad" . pdf-annot-delete)
             ("aa" . pdf-annot-attachment-dired)
             ("am" . pdf-annot-add-markup-annotation)
             ("at" . pdf-annot-add-text-annotation)
             ("y"  . pdf-view-kill-ring-save)
             ("i"  . pdf-misc-display-metadata)
             ("s"  . pdf-occur)
             ("b"  . pdf-view-set-slice-from-bounding-box)
             ("r"  . pdf-view-reset-slice)))

(use-package magit-popup)

(defvar *my-forge-toggle-topic-settings* '((25 . 0) (100 . 25)))

(defun my-forge-toggle-closed-topics ()
  (interactive)
  (setq forge-topic-list-limit
        (if (equal (car *my-forge-toggle-topic-settings*)
                   forge-topic-list-limit)
            (cadr *my-forge-toggle-topic-settings*)
          (car *my-forge-toggle-topic-settings*)))
  (magit-refresh))

(use-package forge
  :after magit
  :config
  (setq forge-topic-list-limit (car *my-forge-toggle-topic-settings*))
  (define-key magit-mode-map "\M-c" 'my-forge-toggle-closed-topics))

;;;;;;;;;;;;;;;; startup ;;;;;;;;;;;;;;;;

(setq server-use-tcp t)
(server-start)


