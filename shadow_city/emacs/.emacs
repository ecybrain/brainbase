(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("936e7826b8f208b8bde6875c4b1546b327e524df0483e7adbeb607ef5c240008" default))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Home folder - D:/Home/Jimmy
;; Start up folder - D:/Home/Jimmy/src
(setq default-directory "D:/Home/Jimmy/elisp")
(cd "~/src")

(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'load-path "~/.emacs.d/lisp/color-theme-sanityinc-solarized/")
(add-to-list 'load-path "~/elisp")
(add-to-list 'load-path "~/elisp/ecb-2.40/")
(add-to-list 'load-path user-emacs-directory)

;; Global Functions
;; Full-screen mode for Windows
(defun w32-maximize-frame ()
    "Maximize the current frame"
     (interactive)
     (w32-send-sys-command 61488))
(run-with-idle-timer 1 nil 'w32-maximize-frame)

;; Use ./_backup/<filename>.bak as backup file name
(defun make-backup-file-name (file-name)
  (if (not (file-exists-p "./_backup"))
      (make-directory "./_backup"))
  (concat (expand-file-name "./_backup/")
    (file-name-nondirectory file-name)
    ".bak")) 

;; Read all values and subkeys for a key path in the Windows registry.
;; The return value is a list (KEYNAME VALUES SUBKEYS).  KEYNAME is
;; the name of the key. VALUES is a list of values, each one
;; following this form: (NAME TYPE VALUE) where each are strings,
;; and the TYPE is like \"REG_DWORD\" and so on.
;; SUBKEYS is a simple list of strings.
;; If the path does not exist, it returns nil.
(defun w32reg-read-key (key)
  (let ((reg.exe (concat (getenv "windir") "\\system32\\reg.exe"))
	keyname values subkeys (state 0))
    (with-temp-buffer
      (insert (shell-command-to-string
	       (concat reg.exe " query " "\"" key "\"")))
      (while (not (= (point-min) (point-max)))
	(goto-char (point-min))
	(let ((start (point))
	      (end (line-end-position))
	      line this-value)
	  (setq line (buffer-substring-no-properties start end))
	  (delete-region start end)
	  (delete-char 1) ;; NL
	  (cond
	   ((string/starts-with line "ERROR:")
	    nil)
	   ((string= "" line)
	    (setq state (1+ state)))
	   ((not keyname)
	    (setq keyname line
		  state 1))
	   ((eq state 1)
	    (let ((parts (split-string line nil t)))
	      (setq this-value (mapconcat 'identity (cddr parts) " "))
	      ;; convert to integer, maybe
	      (if (string= (nth 1 parts) "REG_DWORD")
		  (setq this-value
			(string-to-number (substring this-value 2))))
	      (setq values (cons (list (nth 0 parts)
				       (nth 1 parts)
				       this-value) values))))
	   ((eq state 2)
	    (setq subkeys (cons
			   (if (string/starts-with line keyname)
			       (substring line (1+ (length keyname)))
			     line)
			   subkeys)))
	   (t nil)))))
    (and keyname
	 (list keyname values subkeys))))

(setq default-major-mode 'text-mode)
(add-hook 'text-mode-hook 'text-mode-hook-identify)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(setq-default ident-tabs-mode nil)
(setq-default transient-mark-mode t)
(setq inhibit-startup-message t)
(setq enable-recursive-minibuffers t)

(setq line-number-mode t)
(setq column-number-mode t) 
(setq mouse-yank-at-point t)

(set-cursor-color "white")
(set-mouse-color "blue")
(set-foreground-color "green")
(set-background-color "darkblue")
(set-face-foreground 'highlight "white")
(set-face-background 'highlight "blue")
(set-face-foreground 'region "white")
(set-face-background 'region "blue")
(set-face-foreground 'secondary-selection "skyblue")
(set-face-background 'secondary-selection "darkblue") 
(menu-bar-mode 1)
(tool-bar-mode 0)
(tooltip-mode nil)
(setq tooltip-delay 0.1)

(setq custom-theme-directory "~/.emacs.d/color-theme")
(add-to-list 'custom-theme-load-path "~/.emacs.d/color-theme")
(load-theme 'deeper-blue t)


;; blink cursor to identify the active window
(blink-cursor-mode 0)

(set-default-coding-systems 'utf-8)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(require 'init-benchmarking) ;; Measure startup time

;;----------------------------------------------------------------------------
;; Which functionality to enable (use t or nil for true and false)
;;----------------------------------------------------------------------------
(defconst *spell-check-support-enabled* nil)
(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-carbon-emacs* (eq window-system 'mac))
(defconst *is-cocoa-emacs* (and *is-a-mac* (eq window-system 'ns)))

;;----------------------------------------------------------------------------
;; Bootstrap config
;;----------------------------------------------------------------------------
(require 'init-compat)
(require 'init-utils)
(require 'init-site-lisp) ;; Must come before elpa, as it may provide package.el
(require 'init-elpa)      ;; Machinery for installing required packages
(require 'init-exec-path) ;; Set up $PATH

;;----------------------------------------------------------------------------
;; Load configs for specific features and modes
;;----------------------------------------------------------------------------

(require-package 'wgrep)
(require-package 'project-local-variables)
(require-package 'diminish)
(require-package 'scratch)
(require-package 'mwe-log-commands)

(require 'init-frame-hooks)
(require 'init-dired)

(require 'init-recentf)
(require 'init-ido)
(require 'init-hippie-expand)
(require 'init-auto-complete)
(require 'init-windows)
(require 'init-sessions)
(require 'init-fonts)
(require 'init-mmm)

(require 'init-editing-utils)

(require 'init-git)

(require 'init-csv)
(require 'init-erlang)
(require 'init-javascript)
(require 'init-sh)
(require 'init-php)
(require 'init-org)
(require 'init-nxml)
(require 'init-css)
(require 'init-haml)
(require 'init-python-mode)
(require 'init-haskell)
(require 'init-ruby-mode)
(require 'init-rails)
(require 'init-sql)

(require 'init-paredit)
(require 'init-lisp)
(require 'init-slime)
(require 'init-clojure)
(require 'init-common-lisp)

(when *spell-check-support-enabled*
  (require 'init-spelling))
(require 'init-marmalade)
(require 'init-misc)

;; Extra packages which don't require any configuration

;(require-package 'gnuplot)
(require-package 'lua-mode)
(require-package 'htmlize)
;(require-package 'dsvn)
;(when *is-a-mac*
;  (require-package 'osx-location))
(require-package 'regex-tool)

;;------------------------------------------------------------------------------
;; My custom edit options
;;------------------------------------------------------------------------------
(setq abbrev-file-name "~/.emacs.d/abbrev-defs")
(if (file-exists-p abbrev-file-name)
        (quietly-read-abbrev-file))
(require 'flymake)
(require 'wgrep)
(require 'w32-registry)
(require 'session)
(require 'powershell)
(require 'powershell-mode)
;(require 'lua-mode)
(require 'mongo)
(require 'go-mode)
(require 'google-c-style)
(require 'csharp-mode)
(require 'auto-complete)
(require 'clojure-mode)
(require 'json-mode)
;(require 'groovy-mode)
(require 'google-this)
(require 'python-mode)
(require 'pytest)
(require 'ruby-dev)
(require 'web-mode)
(require 'web)
(require 'w32-browser)
(require 'auto-complete-clang)

(add-hook 'c-mode-common-hook 'google-make-newline-indent)

(require 'init-loader)
(init-loader-load "~/.emacs.d/my-init-folder")


;;----------------------------------------------------------------------------
;; Allow access from emacsclient
;;----------------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))
