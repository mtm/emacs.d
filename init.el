
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;(package-initialize)

(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
(load "base")
(load-file-if-exists "~/.personal.el")
(startup-emacs 5)
(load "plat")
(load "window")
(load-file-if-exists custom-file 'noerror)
(load-file-if-exists "~/omnyway/omnyway.el")
