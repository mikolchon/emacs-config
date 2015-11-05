;; OCTAVE MODE
(autoload 'octave-mode "octave-mod" nil t)
(setq auto-mode-alist
      (cons '("\\.m$" . octave-mode) auto-mode-alist))
(add-hook 'octave-mode-hook
          (lambda ()
            (abbrev-mode 1)
            (auto-fill-mode 1)
            (if (eq window-system 'x)
                (font-lock-mode 1))))

;; WORD COUNT MODE
(require 'wc-mode)
(global-set-key "\C-cw" 'wc-mode)

;; RECENT FILES
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; SPLIT AND SWITCH
(defadvice split-window (after move-point-to-new-window activate)
  "Moves the point to the newly created window after splitting."
  (other-window 1))

;; Fortran 90 HOOKS
(add-hook 'f90-mode-hook (lambda ()
						   (local-set-key (kbd "RET") 'reindent-then-newline-and-indent)
						   (auto-fill-mode 1)
						   (set-fill-column 80)))

;; IDO mode
(require 'ido)
(ido-mode 1)
(setq ido-ignore-extensions t)

;; DIRED X
(require 'dired-x)
(setq-default dired-omit-files-p t) ; Buffer-local variable
(setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))

;; DIRED +
(require 'dired+)
(toggle-diredp-find-file-reuse-dir 1)

;; ELPY mode
(elpy-enable)

;; REPLACE FLYMAKE BY FLYCHECK
(when (require 'flycheck nil t)
  (setq elpy-modules (delete 'flymake-mode 'elpy-modules))
  (add-to-list 'elpy-modules 'flycheck-mode))

;; FLYCHECK
(add-hook 'after-init-hook #'global-flycheck-mode)

;; EVIL SURROUND
(require 'evil-surround)
(global-evil-surround-mode 1)

;; AUTO CLOSE BRACKETS. NEW IN EMACS 24
(electric-pair-mode 1)

;; SHOW MATCHING BRACKET
(show-paren-mode 1)