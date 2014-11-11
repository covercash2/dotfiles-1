;;;; Initialize ;;;;

(require 'cask "~/.cask/cask.el")
(cask-initialize)

(add-to-list 'load-path "~/.emacs.d")
(require 'use-package)

;; Add /usr/local/bin to path
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setq exec-path (append exec-path '("/usr/local/bin")))

(setq default-directory (getenv "HOME"))

(server-start)

(use-package better-defaults)

;;;; Editor ;;;;

(setq inhibit-startup-message t)
(blink-cursor-mode 0)
(menu-bar-mode 1)

;; Disable annoying visible bell on OSX
(setq visible-bell nil)

;; Actually, why not disable the annoying audible bell as well
(setq ring-bell-function 'ignore)

;; Mac Emacs settings
(setq mac-option-modifier 'meta)
(setq mac-command-modifier 'super)

;; Color theme
(load-theme 'weft t)

;; Custom mode-line
(use-package powerline
  :init
  (use-package diminish
    :config
    (progn
      (eval-after-load "undo-tree" '(diminish 'undo-tree-mode))
      (eval-after-load "simple" '(diminish 'auto-fill-function))
      (eval-after-load "eldoc" '(diminish 'eldoc-mode))
      (eval-after-load "elisp-slime-nav" '(diminish 'elisp-slime-nav-mode "sln"))
      (eval-after-load "projectile" '(diminish 'projectile-mode " prj"))
      (eval-after-load "paredit" '(diminish 'paredit-mode " par"))
      (eval-after-load "company" '(diminish 'company-mode " cmp"))
      (eval-after-load "cider" '(diminish 'cider-mode " cid"))))
  :config
  (progn
    (require 'weft-powerline)
    (powerline-weft-theme)))

;; No slow stupid flyspell. Die!
(eval-after-load "flyspell"
  '(defun flyspell-mode (&optional arg)))


;;;; Modes ;;;;

(use-package company
  :init (global-company-mode)
  :config
  (progn
    (defun indent-or-complete ()
      (interactive)
      (if (looking-at "\\_>")
          (company-complete-common)
        (indent-according-to-mode)))

    (global-set-key "\t" 'indent-or-complete)))

(use-package evil
  :init
  (progn
    (evil-mode 1)
    (use-package evil-leader
      :init (global-evil-leader-mode)
      :config (evil-leader/set-leader ","))
    (use-package evil-paredit
      :init (add-hook 'paredit-mode-hook 'evil-paredit-mode))
    (use-package surround
      :init (global-surround-mode 1)
      :config
      (progn
        (add-to-list 'surround-operator-alist '(evil-paredit-change . change))
        (add-to-list 'surround-operator-alist '(evil-paredit-delete . delete)))))
  :config
  (progn
    (setq evil-cross-lines t)
    (setq evil-move-cursor-back nil)

    (evil-define-motion evil-forward-sexp (count)
      (if (paredit-in-string-p)
          (evil-forward-word-end count)
          (paredit-forward count)))

    (evil-define-motion evil-backward-sexp (count)
      (if (paredit-in-string-p)
          (evil-backward-word-begin)
          (paredit-backward count)))

    (evil-define-motion evil-forward-sexp-word (count)
      (if (paredit-in-string-p)
          (evil-forward-word-begin count)
          (progn (paredit-forward count)
                 (skip-chars-forward "[:space:]"))))

    (define-key evil-motion-state-map "w" 'evil-forward-sexp-word)
    (define-key evil-motion-state-map "e" 'evil-forward-sexp)
    (define-key evil-motion-state-map "b" 'evil-backward-sexp)))

(use-package ido
  :config
  (progn
    (global-set-key (kbd "s-b") 'ido-switch-buffer)
    (global-set-key (kbd "s-o") 'ido-find-file)
    (evil-leader/set-key "b" 'ido-switch-buffer)
    (evil-leader/set-key "o" 'ido-find-file)))

(use-package flx-ido
  :init (flx-ido-mode 1)
  :config (setq ido-use-faces nil))

(use-package ido-vertical-mode
  :init (ido-vertical-mode 1))

(use-package projectile
  :init (projectile-global-mode)
  :config
  (progn
    (global-set-key (kbd "s-p") 'projectile-find-file)
    (evil-leader/set-key "p" 'projectile-find-file)))

(use-package yaml-mode
  :mode ("\\.yml$" . yaml-mode))

(use-package markdown-mode
  :mode (("\\.markdown$" . markdown-mode)
         ("\\.md$" . markdown-mode)))

(use-package glsl-mode)

(use-package clojure-mode
  :mode ("\\.edn$" . clojure-mode)
  :init
  (progn
    (use-package cider
      :init
      (progn
        (add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
        (add-hook 'cider-repl-mode-hook 'subword-mode))
      :config
      (progn
        (setq nrepl-hide-special-buffers t)
        (setq cider-popup-stacktraces-in-repl t)
        (setq cider-repl-history-file "~/.emacs.d/nrepl-history")
        (setq cider-repl-pop-to-buffer-on-connect nil)
        (setq cider-auto-select-error-buffer nil)
        (setq cider-prompt-save-file-on-load nil))))
  :config
  (progn
    (define-clojure-indent
      (defroutes 'defun)
      (GET 2)
      (POST 2)
      (PUT 2)
      (DELETE 2)
      (HEAD 2)
      (ANY 2)
      (context 2))

    (define-clojure-indent
      (form-to 1))

    (define-clojure-indent
      (match 1)
      (are 2))

    (define-clojure-indent
      (select 1)
      (insert 1)
      (update 1)
      (delete 1))

    (define-clojure-indent
      (run* 1)
      (fresh 1))

    (define-clojure-indent
      (extend-freeze 2)
      (extend-thaw 1))

    (define-clojure-indent
      (go-loop 1))

    (define-clojure-indent
      (assoc-some 1))

    (defun toggle-nrepl-buffer ()
      "Toggle the nREPL REPL on and off"
      (interactive)
      (if (string-match "cider-repl" (buffer-name (current-buffer)))
          (delete-window)
        (cider-switch-to-relevant-repl-buffer)))

    (defun cider-project-reset ()
      (interactive)
      (cider-interactive-eval "(user/reset)"))

    (global-set-key (kbd "s-r") 'toggle-nrepl-buffer)
    (evil-leader/set-key "r" 'toggle-nrepl-buffer)
    (evil-leader/set-key "R" 'cider-project-reset)))