(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;;; from purcell/emacs.d
(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
      t
    (if (or (assoc package package-archive-contents) no-refresh)
        (package-install package)
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))


(package-initialize)

(require-package 'evil)
(require-package 'color-theme-solarized)
(require-package 'powerline)

(load-theme 'solarized t)
(require 'color-theme)
(require 'color-theme-solarized)
(color-theme-solarized-dark)

(require 'powerline)
(set-face-attribute 'mode-line-inactive nil
                    :box nil)

(setq evil-search-module 'evil-search
      evil-want-C-u-scroll t
      evil-want-C-w-in-emacs-state t)

(setq scroll-step           1
         scroll-conservatively 10000)
(require 'evil)
(evil-mode t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default)))
 '(package-selected-packages
   (quote
    (smart-mode-line-powerline-theme smart-mode-line powerline-evil clojure-mode cider evil)))
 '(powerline-default-separator (quote wave))
 '(powerline-height 9))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(powerline-active1 ((t (:background "dark blue"))))
 '(powerline-active2 ((t (:background "dark cyan")))))

(setenv "PATH" (concat "/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin" (getenv "PATH")))
(if (eq system-type 'darwin)
    (setq shell-file-name "/usr/local/bin/bash"))

(show-paren-mode 1)

(set-frame-parameter (selected-frame) 'alpha '(97 80))

(setq inhibit-splash-screen t)
(switch-to-buffer "*scratch*")
