(defvar jekyll-buf-name  "*jekyll*")
(defvar jekyll-dir "~/src/prv/aakarsh.github.io")

(defun blog/start()
  (interactive)
  (with-current-buffer (find-file jekyll-dir)
    (start-process "*jekyll*" jekyll-buf-name "jekyll"  "serve" "--watch")))


(defun blog/stop()
  (interactive)
  (kill-buffer jekyll-buf-name))
                      
