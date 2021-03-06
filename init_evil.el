;;; init_evil.el --- all related to EVILness
;;; Commentary:
;;;     
;;; Code:

(global-evil-leader-mode)
(evil-mode 1) 
(setq evil-motion-state-modes
	  (append evil-emacs-state-modes evil-motion-state-modes))
(setq evil-emacs-state-modes nil)

(setq evil-default-cursor t)
(define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)

(defun my-move-key (keymap-from keymap-to key)
     "Move key binding from one keymap to another, deleting from the old location."
     (define-key keymap-to key (lookup-key keymap-from key))
     (define-key keymap-from key nil))
(my-move-key evil-motion-state-map evil-normal-state-map (kbd "RET"))
(my-move-key evil-motion-state-map evil-normal-state-map " ")

(evil-set-initial-state 'bs-mode 'motion)
;; DOESNT WORK
;; (evil-set-initial-state 'recentf-mode 'motion)
;; (evil-set-initial-state 'fundamental-mode 'motion)

;; USE IDO
(define-key evil-ex-map "e " 'ido-find-file)
(define-key evil-ex-map "b " 'ido-switch-buffer)

;;; M-s AS GENERAL PURPOSE ESCAPE KEY SEQUENCE.
(defun my-esc (prompt)
  "Functionality for escaping generally. Includes exiting Evil insert state and C-g binding."
  (cond
   ;; If we're in one of the Evil states that defines [escape] key, return [escape] so as
   ;; Key Lookup will use it.
   ((or (evil-insert-state-p) (evil-normal-state-p) (evil-replace-state-p) (evil-visual-state-p) (evil-operator-state-p)) [escape])
   ;; This is the best way I could infer for now to have M-s work during evil-read-key.
   ;; note: as long as i return [escape] in normal-state, i don't need this.
   ;;((eq overriding-terminal-local-map evil-read-key-map) (keyboard-quit) (kbd ""))
   (t (kbd "C-g"))))
(define-key key-translation-map (kbd "M-s") 'my-esc)
;; works around the fact that evil uses read-event directly when in operator state, which
;; doesn't use the key-translation-map
(define-key evil-operator-state-map (kbd "M-s") 'keyboard-quit)

;; not sure what behavior this changes, but might as well set it, seeing the elisp manual's
;; documentation of it.
;; (set-quit-char (kbd "M-s"))

(setq evil-want-fine-undo t)

;; ESC as "kj"
;; (key-chord-mode 1)
;; (setq key-chord-two-keys-delay 0.5)
;; (key-chord-define evil-insert-state-map "kj" 'evil-normal-state)

(defun set-in-all-evil-states (key def &optional maps)
  (unless maps
    (setq maps (list evil-normal-state-map
                     evil-visual-state-map
                     evil-insert-state-map
                     evil-emacs-state-map
					 evil-motion-state-map)))
  (while maps
    (define-key (pop maps) key def)))

(defun set-in-all-evil-states-but-insert (key def)
  (set-in-all-evil-states key def (list evil-normal-state-map
										evil-visual-state-map
										;; evil-emacs-state-map
										evil-motion-state-map)))

(defun set-in-all-evil-states-but-insert-and-visual (key def)
  (set-in-all-evil-states key def (list evil-normal-state-map
										;; evil-emacs-state-map
										evil-motion-state-map)))

(evil-define-motion myevil-next-visual-line (count)
  "Move the cursor COUNT screen lines down, or 5."
  :type exclusive
  (let ((line-move-visual t))
	(evil-line-move (or count 5))))
(evil-define-motion myevil-previous-visual-line (count)
  "Move the cursor COUNT screen lines up, or 5."
  :type exclusive
  (let ((line-move-visual t))
	(evil-line-move (-(or count 5)))))
(evil-define-motion myevil-forward-char (count)
  :type exclusive
  (evil-forward-char (or count 5)))
(evil-define-motion myevil-backward-char (count)
  :type exclusive
  (evil-backward-char (or count 5)))

;; TURBO-NAVIGATION
(set-in-all-evil-states-but-insert-and-visual "\M-j"
'(lambda() (interactive) (evil-next-line 5)))
(set-in-all-evil-states-but-insert-and-visual "\M-k"
'(lambda() (interactive) (evil-previous-line 5)))
(define-key evil-visual-state-map "\M-j" 'myevil-next-visual-line)
(define-key evil-visual-state-map "\M-k" 'myevil-previous-visual-line)
(set-in-all-evil-states-but-insert "\M-h" 'myevil-backward-char)
(set-in-all-evil-states-but-insert "\M-l" 'myevil-forward-char)

;; ;; NERD COMMENTER
(setq evilnc-hotkey-comment-operator "\\")
(global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines)
(global-set-key (kbd "C-c l") 'evilnc-quick-comment-or-uncomment-to-the-line)
(global-set-key (kbd "C-c c") 'evilnc-copy-and-comment-lines)
(global-set-key (kbd "C-c p") 'evilnc-comment-or-uncomment-paragraphs)

;; EVIL LEADER MAPPINGS
(evil-leader/set-key
  ;; "ci" 'evilnc-comment-or-uncomment-lines
  ;; "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
  ;; "ll" 'evilnc-quick-comment-or-uncomment-to-the-line
  ;; "cc" 'evilnc-copy-and-comment-lines
  ;; "cp" 'evilnc-comment-or-uncomment-paragraphs
  ;; "cr" 'comment-or-uncomment-region
  ;; "cv" 'evilnc-toggle-invert-comment-line-by-line
  ;; "\\" 'evilnc-comment-operator
  "f" 'find-file-other-window
  "b" 'switch-to-buffer-other-window
  )

(evil-define-motion back-to-indentation-or-beginning ()
  "If cursor is at indentation, move to 'bol', else, move to
	indentation as a side effect."
  (interactive)
  (if (= (point) (progn (back-to-indentation) (point))) (beginning-of-line)))

;; jump to beginning or end of line
(define-key global-map (kbd "C-a") 'back-to-indentation-or-beginning)
(set-in-all-evil-states-but-insert "0" 'back-to-indentation-or-beginning)
(set-in-all-evil-states (kbd "C-e") 'end-of-line)

;; ;; jump words in camelcase  DOESN'T WORK IN NEW EVIL
;; (load "~/.emacs.d/evil-little-word")

;; bind "h" and "l" to dired+ commands
(eval-after-load 'dired
  '(evil-define-key 'normal dired-mode-map
	 (kbd "h") 'diredp-up-directory-reuse-dir-buffer
	 (kbd "l") 'diredp-find-file-reuse-dir-buffer)
  )

;; make movement keys work like they should
(define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
(define-key evil-motion-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
(define-key evil-motion-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
; make horizontal movement cross lines                                    
(setq-default evil-cross-lines t)

(provide 'init_evil)
;;; init_evil.el ends here
