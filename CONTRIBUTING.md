# Contributing to Zotero ReScript Templater

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Adding New Templates](#adding-new-templates)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. Please be respectful and constructive in all interactions.

### Our Standards

**Positive behaviors:**
- Using welcoming and inclusive language
- Respecting differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community

**Unacceptable behaviors:**
- Harassment, trolling, or insulting comments
- Publishing others' private information
- Other conduct inappropriate in a professional setting

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**Good bug reports include:**
- **Clear title**: Descriptive and specific
- **Steps to reproduce**: Numbered, repeatable steps
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Environment**: OS, PowerShell/Racket version, etc.
- **Screenshots**: If applicable

**Example:**

```markdown
**Title:** PowerShell scaffolder fails with spaces in ProjectName

**Steps to Reproduce:**
1. Run `.\init-zotero-rscript-plugin.ps1 -ProjectName "My Plugin" -AuthorName "Test"`
2. Observe error

**Expected:** Project created successfully

**Actual:** Error: "Path contains invalid characters"

**Environment:**
- Windows 11 Pro
- PowerShell 7.4.0
- Script version: 0.1.0
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:
- **Use case**: Why is this needed?
- **Proposed solution**: How would it work?
- **Alternatives considered**: Other approaches?
- **Impact**: Who benefits? Any breaking changes?

### Adding Documentation

Documentation improvements are always appreciated:
- Fix typos or unclear explanations
- Add examples for complex features
- Translate to other languages
- Improve code comments

## Development Setup

### Prerequisites

**For PowerShell development:**
```powershell
# Install dependencies
.\zotero-template-dependencies.ps1 -Optional

# Verify installation
pwsh --version  # Should be 7.0+
git --version
```

**For Racket development:**
```bash
# Install Racket
# Download from https://racket-lang.org/

# Verify
racket --version  # Should be 8.0+
```

### Local Development Workflow

1. **Fork and clone:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/zotero-rescript-templater.git
   cd zotero-rescript-templater
   ```

2. **Create a branch:**
   ```bash
   git checkout -b feature/my-new-feature
   ```

3. **Make changes:**
   - Edit `init-zotero-rscript-plugin.ps1` or `init-raczotbuild.rkt`
   - Update documentation if needed
   - Add tests for new functionality

4. **Test your changes:**
   ```powershell
   # PowerShell: Test scaffolding
   .\init-zotero-rscript-plugin.ps1 -ProjectName TestPlugin -AuthorName "Test" -TemplateType student

   # Verify generated files
   cd TestPlugin
   Get-ChildItem -Recurse

   # Test integrity verification
   cd ..
   .\init-zotero-rscript-plugin.ps1 -ProjectName TestPlugin -VerifyIntegrity
   ```

   ```bash
   # Racket: Test scaffolding
   racket init-raczotbuild.rkt -n TestPlugin -a "Test" -g

   # Run tests (if implemented)
   cd TestPlugin
   raco test tests/
   ```

5. **Commit changes:**
   ```bash
   git add .
   git commit -m "feat: add new template type for bibliography management"
   ```

6. **Push and create PR:**
   ```bash
   git push origin feature/my-new-feature
   ```

## Coding Standards

### PowerShell

**Style Guidelines:**
- Use `PascalCase` for functions: `Get-XXHash64`, `Write-ProjectFile`
- Use `$camelCase` for variables: `$projectName`, `$templateData`
- Use 2-space indentation
- Keep lines under 120 characters
- Add comment-based help for functions

**Example:**
```powershell
<#
.SYNOPSIS
  Computes XXHash64 checksum of a file.

.PARAMETER FilePath
  Path to the file to hash.

.OUTPUTS
  String. Hexadecimal hash value.
#>
function Get-XXHash64 {
  param(
    [Parameter(Mandatory)]
    [string]$FilePath
  )

  $bytes = [System.IO.File]::ReadAllBytes($FilePath)
  $hash = [XXHash64]::Compute($bytes)
  return $hash.ToString("X16")
}
```

**Error Handling:**
```powershell
try {
  # Risky operation
  $data = Get-Content $path -ErrorAction Stop
} catch {
  Write-Error "Failed to read file: $_"
  exit 1
}
```

### Racket

**Style Guidelines:**
- Use `kebab-case` for identifiers: `project-spec`, `write-file`
- Use 2-space indentation
- Prefer functional style (avoid mutation)
- Use `provide` to export public APIs
- Document public functions with contracts

**Example:**
```racket
#lang racket

(provide write-project-file)

;; write-project-file : path? string? -> void?
;; Writes content to a project file, creating parent directories if needed.
(define (write-project-file path content)
  (define dir (path-only path))
  (when dir
    (make-directory* dir))
  (call-with-output-file path
    (λ (out) (display content out))
    #:exists 'replace))
```

**Testing:**
```racket
(module+ test
  (require rackunit)

  (test-case "write-project-file creates directories"
    (define temp-path (build-path (find-system-path 'temp-dir) "test" "file.txt"))
    (write-project-file temp-path "test content")
    (check-true (file-exists? temp-path))
    (delete-file temp-path)))
```

### Template JSON

**Format:**
- Use 2-space indentation
- Sort keys alphabetically (except `version` first)
- Use `\n` for newlines in strings
- Escape quotes: `\"`

**Example:**
```json
{
  "version": "0.1.0",
  "files": {
    "README.md": "# {{ProjectName}}\n\nBy {{AuthorName}}",
    "install.rdf": "<?xml version=\"1.0\"?>\n<RDF>...</RDF>"
  }
}
```

## Testing

### Manual Testing Checklist

Before submitting a PR, test:

- [ ] **PowerShell Scaffolding**
  - [ ] Create project with each template type
  - [ ] Verify all files created correctly
  - [ ] Check variable substitution (`{{ProjectName}}`, etc.)
  - [ ] Test with special characters in names
  - [ ] Verify GitInit flag creates `.gitignore`, etc.

- [ ] **Integrity Verification**
  - [ ] Generate audit-index.json
  - [ ] Verify passes on unmodified files
  - [ ] Modify a file and verify detection
  - [ ] Delete a file and verify detection

- [ ] **Racket Scaffolding**
  - [ ] Create project with `-n` and `-a` flags
  - [ ] Verify git init with `-g` flag
  - [ ] Check homoiconic structure generation
  - [ ] Validate generated Racket code

- [ ] **Cross-Platform**
  - [ ] Test on Windows (if PowerShell changes)
  - [ ] Test on Linux (if Racket changes)
  - [ ] Test on macOS (if Racket changes)

### Automated Testing

**PowerShell (Pester):**
```powershell
# Run tests
Invoke-Pester -Path ./tests/*.Tests.ps1

# With coverage
Invoke-Pester -Path ./tests/*.Tests.ps1 -CodeCoverage ./init-zotero-rscript-plugin.ps1
```

**Racket (rackunit):**
```bash
# Run all tests
raco test .

# Run specific test file
racket tests/scaffold-tests.rkt
```

## Pull Request Process

### Before Submitting

1. **Update documentation:**
   - Update README.md if adding features
   - Update CLAUDE.md for AI assistance context
   - Add/update code comments

2. **Test thoroughly:**
   - Run manual testing checklist
   - Run automated tests (if implemented)
   - Test on target platforms

3. **Commit message format:**
   ```
   type(scope): subject

   body

   footer
   ```

   **Types:**
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation only
   - `style`: Formatting changes
   - `refactor`: Code restructuring
   - `test`: Adding tests
   - `chore`: Maintenance tasks

   **Example:**
   ```
   feat(templates): add bibliography management template type

   Adds a new template type focused on bibliography workflows:
   - BibTeX export integration
   - Citation style management
   - Duplicate detection

   Closes #42
   ```

### PR Description Template

```markdown
## Description
Brief summary of changes.

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## Testing
Describe testing performed:
- [ ] Manual testing on Windows 11
- [ ] Manual testing on Ubuntu 22.04
- [ ] Pester tests pass
- [ ] Rackunit tests pass

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated as needed
- [ ] All tests pass
```

### Review Process

1. **Automated checks:** CI/CD runs tests and linters
2. **Maintainer review:** Code review for quality, style, functionality
3. **Feedback addressed:** Make requested changes
4. **Approval:** PR approved by maintainer(s)
5. **Merge:** Squash and merge into main branch

## Adding New Templates

### PowerShell Template Addition

1. **Define template in `$templates` hashtable:**
   ```powershell
   $templates = @{
     # Existing templates...

     bibliography = @'
   {
     "version": "0.1.0",
     "files": {
       "README.md": "# {{ProjectName}}\n\nBibliography management by {{AuthorName}}",
       "bootstrap.js": "// Bootstrap code here...",
       "chrome/content/main.js": "// Main logic..."
     }
   }
   '@
   }
   ```

2. **Update ValidateSet:**
   ```powershell
   [ValidateSet("practitioner","researcher","student","bibliography")]
   [string]$TemplateType = "practitioner",
   ```

3. **Test the template:**
   ```powershell
   .\init-zotero-rscript-plugin.ps1 `
     -ProjectName TestBiblio `
     -AuthorName "Test" `
     -TemplateType bibliography
   ```

4. **Document in README.md:**
   Add a section under "Template Types" describing the new template.

### Racket Template Addition

1. **Add template JSON to `project-spec`:**
   ```racket
   (dir "templates"
     (file "practitioner.json" ...)
     (file "bibliography.json"
       ,(jsexpr->string
         (hash 'version "0.1.0"
               'files (hash "README.md" "# {{ProjectName}}\nBiblio"
                           "main.rkt" "(provide main)")))))
   ```

2. **Update documentation:**
   Add template description to README.md

3. **Test generation:**
   ```bash
   racket init-raczotbuild.rkt -n TestPlugin -a "Test"
   cat TestPlugin/templates/bibliography.json
   ```

### Template Design Guidelines

**Good templates include:**
- Comprehensive README.md with usage examples
- Working example code (not just placeholders)
- Proper error handling
- Commented code explaining Zotero API usage
- package.json with useful scripts
- .gitignore with sensible defaults

**Template variables available:**
- `{{ProjectName}}` - User-provided project name
- `{{AuthorName}}` - User-provided author name
- `{{version}}` - Template version from JSON

## File Organization

```
zotero-rescript-templater/
├── .github/
│   └── workflows/
│       └── ci.yml                    # CI/CD pipeline
├── tests/                            # Test files
│   ├── PowerShell.Tests.ps1         # PowerShell tests
│   └── racket-tests.rkt             # Racket tests
├── docs/                             # Additional documentation
│   └── TEMPLATES.md                 # Template authoring guide
├── CONTRIBUTING.md                   # This file
├── README.md                        # Project README
├── CLAUDE.md                        # AI assistance context
├── LICENSE                          # AGPL-3.0 license
├── init-raczotbuild.rkt             # Racket scaffolder
├── init-raczotbuild.bak             # Backup
├── init-zotero-rscript-plugin.ps1   # PowerShell scaffolder
└── zotero-template-dependencies.ps1 # Dependency installer
```

## Release Process

**For maintainers:**

1. **Update version numbers:**
   - Update template versions in embedded JSON
   - Update any hardcoded version references

2. **Update CHANGELOG.md:**
   ```markdown
   ## [0.2.0] - 2024-11-22
   ### Added
   - New bibliography template type
   - Pester test suite

   ### Fixed
   - XXHash computation for files >2GB

   ### Changed
   - Improved error messages
   ```

3. **Create git tag:**
   ```bash
   git tag -a v0.2.0 -m "Release version 0.2.0"
   git push origin v0.2.0
   ```

4. **GitHub Release:**
   - Create release on GitHub
   - Attach any binary artifacts
   - Copy CHANGELOG content to release notes

## Questions?

- **Issues:** [GitHub Issues](https://github.com/Hyperpolymath/zotero-rescript-templater/issues)
- **Discussions:** [GitHub Discussions](https://github.com/Hyperpolymath/zotero-rescript-templater/discussions)

## License

By contributing, you agree that your contributions will be licensed under the AGPL-3.0 License.

---

Thank you for contributing! 🎉
