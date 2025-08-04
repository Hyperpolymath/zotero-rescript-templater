#lang racket (require racket/cmdline racket/path racket/file racket/date racket/process racket/json)

(define proj-name #f) (define proj-author #f) (define proj-desc "RacZotBuild – a Racket-based Zotero plugin scaffolder") (define do-gitinit? #f)

(command-line #:program "init-raczotbuild.rkt" #:once-each [("-n" "--name") proj-name "Project directory & package name"] [("-a" "--author") proj-author "Author name"] [("-d" "--desc") proj-desc "Project description"] [("-g" "--git-init") do-gitinit? "Run git init + first commit"] #:after-each [(void) (unless (and proj-name proj-author) (error 'args "Both --name and --author are required"))])

(define (write-file path content) (define dir (path-only path)) (when dir (mkdirs dir)) (call-with-output-file path (λ(out) (display content out)) #:exists 'replace))

(define (year) (date-year (current-date)))

;; Templates as format-strings via string-join (define info-tpl (string-join '("#lang setup/infotab\n\n" "(\n" " name ~a\n" " version \"0.1.0\"\n" " authors '(~a)\n" " license \"MIT\"\n" " categories '(scaffolding zotero racket)\n" " description ~a\n" " homepage \"https://github.com/your/repo\"\n" " files (submod \"raczotbuild/main.rkt\" \"raczotbuild/*\")\n" ")\n") ""))

(define main-tpl (string-join '("#lang racket\n\n" ";; ~a\n\n" "(provide scaffold create-audit verify-audit)\n\n" "(define (scaffold project author template)\n" " (error 'scaffold \"Not implemented\"))\n\n" "(define (create-audit project)\n" " (error 'create-audit \"Not implemented\"))\n\n" "(define (verify-audit project)\n" " (error 'verify-audit \"Not implemented\"))\n") ""))

(define readme-tpl (string-join '("# ~a\n\n" "~a\n\n" "## Installation\n\n" "shell\n" "raco pkg install ~a\n" "\n\n" "## Usage\n\n" "shell\n" "raco ~a scaffold -p MyPlugin -a \"Author Name\" -t practitioner\n" "\n\n" "## License\n\n" "MIT © ~a\n") ""))

(define license-tpl (string-join '("MIT License\n\n" "Copyright (c) ~a ~a\n\n" "Permission is hereby granted, free of charge, to any person obtaining a copy\n" "of this software and associated documentation files (the \"Software\"), to deal\n" "in the Software without restriction...\n") ""))

(define gitignore-txt (string-join '("_build/" "deps/" ".zo" ".DS_Store" "node_modules/" "template-.json" "audit-index.json" "audit-index.json.sig") "\n"))

(define gitattributes-txt (string-join '(".rkt text" ".json text" "templates/*.json text" "LICENSE text" "README.md text") "\n"))

(define ci-txt (string-join '("name: CI\n" "on: [push, pull_request]\n" "jobs:\n" " build:\n" " runs-on: ubuntu-latest\n" " steps:\n" " - uses: actions/checkout@v3\n" " - name: Install Racket\n" " uses: racket-lang/setup-racket@v1\n" " - name: Run Tests\n" " run: raco test\n" " - name: Scaffold Smoke Test\n" " run: raco racket -l raczotbuild/main.rkt -- -p SmokeTest -a \"CI\" -t practitioner\n" " - name: Verify Integrity\n" " run: raco racket -l raczotbuild/main.rkt -- -p SmokeTest -a \"CI\" -v\n") ""))

;; Homoiconic project specification (define project-spec `(dir ,proj-name (dir "raczotbuild" (file "info.rkt" ,(format info-tpl proj-name proj-author proj-desc)) (file "main.rkt" ,(format main-tpl proj-name))) (dir "templates" (file "practitioner.json" ,(jsexpr->string (hash 'version "0.1.0" 'files (hash "README.md" "# {{ProjectName}}\n\nPro scaffold by {{AuthorName}}." "main.rkt" "(provide main)\n"))))) (dir "tests" (file "main-test.rkt" ,(string-join '("#lang racket\n" "(require rackunit)\n\n" ";; TODO: add rackunit tests for your scaffold functions\n") ""))) (dir "examples" (file "run-scaffold.rkt" ,(string-join '("#lang racket\n" "(require \"raczotbuild/main.rkt\")\n\n" "(scaffold \"MyPlugin\" \"Author Name\" \"practitioner\")\n") ""))) (file "README.md" ,(format readme-tpl proj-name proj-desc proj-name proj-name proj-author)) (file "LICENSE" ,(format license-tpl proj-author (year))) (file ".gitignore" ,gitignore-txt) (file ".gitattributes" ,gitattributes-txt) (dir ".github" (dir "workflows" (file "ci.yml" ,ci-txt)))))

(define (process node parent) (match node [(dir ,name ,@children) (define path (path-join parent name)) (mkdirs path) (for ([child children]) (process child path))] [(file ,name ,content) (write-file (path-join parent name) content)]))

(define (main) (process project-spec (current-directory)) (when do-gitinit? (parameterize ([current-directory (path-join (current-directory) proj-name)]) (system/exit-code "git" "init" ".") (system/exit-code "git" "add" ".") (system*/exit-code "git" "commit" "-m" (format "chore: init ~a" proj-name)))) (printf "✓ RacZotBuild repo '~a' created successfully!\n" proj-name))

(main)