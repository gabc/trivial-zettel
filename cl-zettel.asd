;;;; cl-zettel.asd

(asdf:defsystem #:cl-zettel
  :description "Describe cl-zettel here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:cl-org-mode #:cl-ppcre)
  :components ((:file "package")
               (:file "cl-zettel")))
