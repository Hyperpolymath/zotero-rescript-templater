;; zotero-rescript-templater - Guix Package Definition
;; Run: guix shell -D -f guix.scm

(use-modules (guix packages)
             (guix gexp)
             (guix git-download)
             (guix build-system gnu)
             ((guix licenses) #:prefix license:)
             (gnu packages base))

(define-public zotero_rescript_templater
  (package
    (name "zotero-rescript-templater")
    (version "0.1.0")
    (source (local-file "." "zotero-rescript-templater-checkout"
                        #:recursive? #t
                        #:select? (git-predicate ".")))
    (build-system gnu-build-system)
    (synopsis "Guix channel/infrastructure")
    (description "Guix channel/infrastructure - part of the RSR ecosystem.")
    (home-page "https://github.com/hyperpolymath/zotero-rescript-templater")
    (license license:agpl3+)))

;; Return package for guix shell
zotero_rescript_templater
