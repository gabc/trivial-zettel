;;;; cl-zettel.lisp

(in-package #:cl-zettel)

(defun format-dates (title)
  (cl-ppcre:regex-replace "%5D"
                          (cl-ppcre:regex-replace "%5B" title "[")
                          "]"))
(defun date-to-regex (date)
  (cl-ppcre:regex-replace "\\]"
                          (cl-ppcre:regex-replace "\\[" date "\\\[")
                          "\\\]"))

(defvar file #P"/Users/g/lib/org/Zettelkasten.org")

(defun get-no-tags (graph)
  (let (nodes)
    (cl-org-mode::do-leaf-nodes (n graph)
      (if (null (cl-org-mode::tags-of n))
          (push n nodes)))
    nodes))

(defun get-no-links (graph)
  (let (nodes)
    (cl-org-mode::do-leaf-nodes (n graph)
      (if (not (cl-ppcre:all-matches "\\[\\[" (get-text n)))
          (push n nodes)))
    nodes))

(defun find-node (graph predicate)
  (let (nodes)
    (cl-org-mode::do-leaf-nodes (n graph)
      (if (funcall predicate n)
          (push n nodes)))
    nodes))
(defmacro fn (graph &body body)
  "Power interactive thing"
  `(find-node ,graph (lambda (n) ,@body)))

(defun find-node-text (graph text)
  (find-node graph (lambda (n)
                     (or (cl-ppcre:all-matches text (get-text n))
                         (cl-ppcre:all-matches text (cl-org-mode::title-of n))))))

(defun find-node-title (graph text)
  (find-node graph (lambda (n)
                     (cl-ppcre:all-matches text (cl-org-mode::title-of n)))) )

(defun find-node-with-link (graph)
  (find-node graph (lambda (n)
                     (cl-ppcre:all-matches "\\[\\[" (get-text n)))))

(defun get-link-name (link)
  "From a link string [[link][description]]
returns the title of the node"
  (let* ((string (nth 1 (reverse (split-sequence:split-sequence #\[ link)))))
    (if (= 0 (length string))
        (return-from get-link-name "")
        (setf string (string-right-trim '(#\]) (string-trim '(#\*) string))))
    string))

(defun get-nodes (&optional file-arg)
  (cl-org-mode::org-parse (or file-arg file)))

(defun get-text (node)
  (cond ((cl-org-mode::node.out node)
         (cl-org-mode::node.out node))
        ((and (cl-org-mode::section-of node)
              (cl-org-mode::children-of
               (cl-org-mode::section-of node)))
         (car (cl-org-mode::children-of
               (cl-org-mode::section-of node))))))


(defun replace-all (tx)
  (cl-ppcre:regex-replace-all "\/"
                              (cl-ppcre:regex-replace-all "\\\["
                                                          (cl-ppcre:regex-replace-all "\\\]" tx "\\\]")
                                                          "\\\[") "\\/"))
(defun dot ()
  (let (nodes g text)
    (setf g (cl-org-mode::org-parse file))
    (setf nodes (find-node-with-link g))
    (format t "digraph \"zettel\" {~%")
    (dolist (n nodes)
      (setf text (split-sequence:split-sequence #\Newline (get-text n)))
      (dolist (l text) 
        (when (and (cl-ppcre:all-matches "\\[\\[" l)
                   (not (cl-ppcre:all-matches "http" (get-link-name l))))
          (format t "\"~A\" -> \"~A\";~%" (replace-all (cl-org-mode::title-of n))
                  (replace-all (format-dates (get-link-name l)))))))
    (format t "}~%")))
