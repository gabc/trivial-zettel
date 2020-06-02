;;;; cl-zettel.lisp

(in-package #:cl-zettel)

(defun present-nodes (graph matches)
  (let ((*present-depth* 0)
        (*presented-nodes* (make-hash-table :test 'eq))
        (*present-depth-increment* 0))
    (with-output-to-string (s)
      (do-leaf-nodes (n graph)
        (if (cl-ppcre:all-matches matches (title-of n))
            (org-present :flat n s))))))

(defun format-dates (title)
  (cl-ppcre:regex-replace "%5D"
                          (cl-ppcre:regex-replace "\\*%5B" title "[")
                          "]"))
(defun date-to-regex (date)
  (cl-ppcre:regex-replace "\\]"
                          (cl-ppcre:regex-replace "\\[" date "\\\[")
                          "\\\]"))
