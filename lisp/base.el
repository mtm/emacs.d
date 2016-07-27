(require 'cl)

(defmacro if-let (binding then &optional else)
  (destructuring-bind (var predicate)
      binding
    `(let ((,var ,predicate))
       (if ,var
           ,then
         ,else))))

(defmacro when-let (binding &rest body)
  `(if-let ,binding
     (progn
       ,@body)))

(defun concat-path (path file)
  (concat (file-name-as-directory path) file))

(defun locate-path (file path-list)
  (when-let (path (find-if (lambda (path)
                             (let ((file-path (concat-path path file)))
                               (and (file-exists-p file-path) file-path)))
                           path-list))
    (concat-path path file)))

(defvar base-exec-path exec-path)

(defun add-exec-paths (exec-paths &optional append)
  (dolist (path exec-paths)
    (let ((path (expand-file-name path)))
      (when (file-directory-p path)
        (add-to-list 'exec-path path append)))
    (setenv "PATH" (join ":" exec-path))))



(defun region ()
  (when mark-active
    (buffer-substring (region-beginning) (region-end))))

(defun term-at-point-or-read (&optional label)
  (let* ((word-at-point (word-at-point))
	 (symbol-at-point (symbol-at-point))
	 (default (or word-at-point
		      (and symbol-at-point (symbol-name symbol-at-point)))))
    (read-from-minibuffer (or label "Term: ") default)))

(defun n-col-view (n)
  (let ((cur (selected-window)))
    (save-excursion 
      (delete-other-windows)
      (let* ((frame-width-cols (/ (frame-pixel-width) (frame-char-width)))
             (pane-width (round (/ (- frame-width-cols n 1) n))))
        (dotimes (i (1- n))
          (split-window-horizontally pane-width)
          (other-window 1)
          (bury-buffer))
        (balance-windows)))
    (select-window cur)))


(defun spaced (seq) (join " " seq))

(defun re-matches (re str)
  (when (string-match re str)
    (mapcar (lambda (match)
              (apply 'substring str match))
            (partition (match-data) 2))))

(defun emacs-version-info ()
  (bind (((_ &rest matches) (re-matches
                             "\\([0-2][0-9]*\\)\.\\([0-9]*\\).\\([0-9]*\\)"
                             emacs-version)))
    (mapcar 'string-to-number matches)))

(defun emacs24-or-newer-p () (<= 24 (first (emacs-version-info))))
(defun emacs24p () (= 24 (first (emacs-version-info))))
(defun emacs23p () (= 23 (first (emacs-version-info))))
(defun emacs22p () (= 22 (first (emacs-version-info))))

(defun html (spec)
  "Generate a string representation of the specified HTML spec."
  (labels ((attr-str (attrs)
             (spaced (mapcar (lambda (x)
                               (destructuring-bind (key val) x
                                 (concat (str key) "=\"" (str val) "\"")))
                             (partition attrs 2)))))
    (if (listp spec)
        (let ((head (first spec)))
          (destructuring-bind (tag &rest attribs) (seq head)
            (join ""
                  (append
                   (list*
                    (concat "<" (str tag)
                            (if (zerop (length attribs))
                                ""
                                (concat " " (attr-str attribs)))
                            ">")
                    (mapcar 'html (rest spec)))
                   (list (concat "</" (str tag) ">"))))))
        spec)))

(defun add-exec-paths (paths)
  (let ((paths (remove-if-not 'file-directory-p paths)))
    (dolist (path paths)
      (add-to-list 'exec-path path))
    (setenv "PATH" (join ":" exec-path))))

(defun set-all-line-truncation (v)
  (make-local-variable 'truncate-lines)
  (setq truncate-lines v)
  (make-local-variable 'truncate-partial-width-windows)
  (setq truncate-partial-width-windows v))

(defun test-string-match (item x) (string-match x item))

(defun find-file-if-exists (path &optional find-file-function find-file-args)
  (let ((path (expand-file-name path)))
    (when (file-exists-p path)
      (apply (or find-file-function 'find-file-noselect)
             path
             find-file-args))))

(defun find-file-no-desktop (path)
  (require 'desktop)
  (when-let (buf (find-file-if-exists f))
    (when (featurep 'desktop)
      (push (buffer-name buf)
            desktop-clear-preserve-buffers))))

(defun load-file-if-exists (path &rest load-args)
  (let ((path (expand-file-name path)))
    (when (file-exists-p path)
      (apply 'load path load-args))))

(defun try-require (feature)
  (condition-case nil
      (require feature)
    (error (message "Error loading feature %s" feature))))

(defun compilation-mode-colorize-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (toggle-read-only))

(defun setup-ansi-color ()
  (autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
  (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
  (add-hook 'comint-mode-hook 'ansi-color-for-comint-mode-on)
  (add-hook 'compilation-filter-hook 'compilation-mode-colorize-buffer)
  (add-hook 'eshell-preoutput-filter-functions 'ansi-color-filter-apply))