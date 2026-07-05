;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;

;; (set-frame-font "JetBrains Mono-12" nil t)
(setq doom-font (font-spec :family "JetBrains Mono" :size 15 :weight 'semi-light)
     doom-variable-pitch-font (font-spec :family "JetBrains Mono" :size 14))

;; (setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;; (setq display-line-numbers-type t)
(setq display-line-numbers-type 'relative)


;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(add-to-list 'default-frame-alist '(width . 160))
(add-to-list 'default-frame-alist '(height . 45))

(after! lsp-mode
  (setq lsp-inlay-hint-enable t)
  (setq lsp-auto-guess-root nil))


(with-eval-after-load 'evil
  ;; 'm' goes to the next buffer in normal mode
  (evil-define-key 'normal 'global (kbd "m") 'next-buffer)

  ;; 'M' (Shift + m) goes to the previous buffer in normal mode
  (evil-define-key 'normal 'global (kbd "M") 'previous-buffer))

(use-package! evil-escape
  :config
  (setq evil-escape-key-sequence "jk")
  (setq evil-escape-delay 0.15) ; time window to hit both keys in seconds
  (evil-escape-mode 1))

;; ;; Set transparency (90 means 90% opaque, 10% transparent)
;; (set-frame-parameter nil 'alpha-background 90)

;; ;; Make sure transparency applies to any newly opened frames/windows too
;; (add-to-list 'default-frame-alist '(alpha-background . 90))


;; toggle transparency
(defvar my/transparency-enabled t
  "Toggle state for transparency.")

(defun my/toggle-transparency ()
  (interactive)
  (setq my/transparency-enabled (not my/transparency-enabled))

  (let ((value (if my/transparency-enabled
                   my/default-transparency
                 100)))
    (set-frame-parameter nil 'alpha-background value)
    (add-to-list 'default-frame-alist `(alpha-background . ,value))
    (message "Transparency: %s"
             (if my/transparency-enabled "ON" "OFF"))))

(setq my/default-transparency 90)



(map! :n "H" #'evil-first-non-blank
      :n "L" #'evil-end-of-line)



;; Add your local lisp folder to the load path
(add-to-list 'load-path (expand-file-name "lisp" doom-user-dir))

;; Load the package
(require 'neoscroll)

;; Optional: Turn it on globally if the plugin supports it
(if (fboundp 'neoscroll-mode)
    (neoscroll-mode 1))


(defun my-load-banners (file)
  (let* ((raw (with-temp-buffer
                (insert-file-contents file)
                (buffer-string)))
         (banners (split-string raw "\n%%%\n")))
    (seq-filter (lambda (s) (not (string-empty-p s))) banners)))

(defvar my-banner-list nil)

(setq my-banner-list
      (my-load-banners (expand-file-name "lisp/banner.txt" doom-user-dir)))

(defun my/random-banner ()
  (seq-random-elt my-banner-list))

(setq +dashboard-ascii-banner-fn #'my/random-banner)



(setq treesit-language-source-alist
      '((typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "tsx/src")))



(add-hook 'typescript-ts-mode-hook #'lsp-deferred)
(add-hook 'tsx-ts-mode-hook #'lsp-deferred)
(add-hook 'js-ts-mode-hook #'lsp-deferred)
(add-hook 'css-ts-mode-hook #'lsp-deferred)
(add-hook 'web-mode-hook #'lsp-deferred)

(after! flycheck
  (global-flycheck-mode))

(after! lsp-mode
  (setq
   lsp-auto-guess-root t
   lsp-inlay-hint-enable t
   lsp-diagnostics-provider :flycheck

   ;; performance
   lsp-idle-delay 0.3
   lsp-log-io nil
   lsp-enable-file-watchers nil

   ;; diagnostics
   lsp-modeline-diagnostics-enable t
   lsp-headerline-breadcrumb-enable t))


(use-package! lsp-tailwindcss :after lsp-mode)


(after! lsp-ui
  (setq
   lsp-ui-doc-enable t
   lsp-ui-doc-show-with-cursor nil
   lsp-ui-doc-show-with-mouse t
   lsp-ui-doc-position 'at-point
   lsp-ui-doc-max-width 150
   lsp-ui-doc-max-height 40

   lsp-ui-sideline-enable t
   lsp-ui-sideline-show-hover t
   lsp-ui-sideline-show-diagnostics t
   lsp-ui-sideline-show-code-actions t

   lsp-ui-peek-enable t
   lsp-ui-imenu-enable t))

;this disable show doc in defaulte
  (map! :n "K" #'lsp-ui-doc-show)

 ;;focouse in lsp-ui doc
  (map! :n "F" #'lsp-ui-doc-focus-frame)

  ;; switch between windows
  (map! :n "J" #'other-window)
