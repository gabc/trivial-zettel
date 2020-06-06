;;;; cl-zettel.lisp

(in-package #:cl-zettel)

(defun format-dates (title)
  (cl-ppcre:regex-replace "%5D"
                          (cl-ppcre:regex-replace "\\*%5B" title "[")
                          "]"))
(defun date-to-regex (date)
  (cl-ppcre:regex-replace "\\]"
                          (cl-ppcre:regex-replace "\\[" date "\\\[")
                          "\\\]"))

(defvar file #P"/Users/g/lib/org/Zettelkasten.org")

(defun get-no-links (graph)
  (let (nodes)
    (cl-org-mode::do-leaf-nodes (n graph)
      (if (not (cl-ppcre:all-matches "\\[\\[" (get-text n)))
          (push n nodes)))
    nodes))

(defun find-node (graph text)
  (cl-org-mode::do-leaf-nodes (n graph)
    (if (or (cl-ppcre:all-matches text (cl-org-mode::node.out n))
            (cl-ppcre:all-matches text (cl-org-mode::title-of n)))
        (return-from find-node n))))
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
