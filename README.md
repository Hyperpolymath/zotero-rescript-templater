# Zotero ReScript Templater

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey)]()
[![Racket](https://img.shields.io/badge/racket-8.0%2B-blue)](https://racket-lang.org/)
[![PowerShell](https://img.shields.io/badge/powershell-7.0%2B-blue)](https://github.com/PowerShell/PowerShell)

A sophisticated scaffolding system for Zotero plugins, offering both **Racket** and **PowerShell** implementations with template interpolation, integrity verification, and type-safe development options.

## ✨ Features

- 🎯 **Three Ready-to-Use Templates**
  - **Practitioner** - Professional-grade ReScript/ReasonML plugins
  - **Researcher** - Research-focused with citation analysis and database integration
  - **Student** - Educational templates with extensive documentation and TypeScript

- 🔒 **File Integrity Verification** - XXHash64-based checksums for tamper detection
- 🎨 **Template Interpolation** - Simple `{{variable}}` syntax for customization
- 🏗️ **Homoiconic Design** - Racket version uses code-as-data for ultimate flexibility
- 📦 **Automated Dependency Management** - One-command setup for all prerequisites
- 🔄 **CI/CD Ready** - GitHub Actions workflows included
- 🐳 **Container Support** - Containerfile generation for isolated development

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
  - [PowerShell Scaffolder](#powershell-scaffolder)
  - [Racket Scaffolder](#racket-scaffolder)
- [Template Types](#template-types)
- [File Integrity Verification](#file-integrity-verification)
- [Dependencies](#dependencies)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)

## 🚀 Quick Start

### PowerShell (Windows)

```powershell
# 1. Install dependencies (first time only)
.\zotero-template-dependencies.ps1

# 2. Create a new plugin
.\init-zotero-rscript-plugin.ps1 `
  -ProjectName "MyAwesomePlugin" `
  -AuthorName "Your Name" `
  -TemplateType practitioner `
  -GitInit

# 3. Your plugin is ready!
cd MyAwesomePlugin
npm install
npm run build
```

### Racket (Cross-Platform)

```bash
# 1. Install Racket from https://racket-lang.org/

# 2. Create a new plugin
racket init-raczotbuild.rkt \
  -n MyAwesomePlugin \
  -a "Your Name" \
  -g

# 3. Explore the generated structure
cd MyAwesomePlugin
cat README.md
```

## 📥 Installation

### Prerequisites

**For PowerShell:**
- Windows 10/11 with PowerShell 7+
- Git
- (Optional) Node.js LTS for npm-based templates

**For Racket:**
- Racket 8.0 or later
- Git (for `-g` flag)

### Automated Setup (Windows)

Run the dependency installer to set up all required tools:

```powershell
# Required tools only
.\zotero-template-dependencies.ps1

# Include optional dev tools (Node.js, Rust, etc.)
.\zotero-template-dependencies.ps1 -Optional
```

This installs:
- ✅ PowerShell 7+
- ✅ Git
- ✅ PostgreSQL 12+
- ✅ Deno
- ✅ Dhall CLI
- ✅ Erlang/OTP
- ✅ Elixir
- ✅ (Optional) Node.js LTS + AssemblyScript + axe-cli
- ✅ (Optional) Rust toolchain + wasm-pack
- ✅ (Optional) PowerShell modules: Pester, TomlPS

## 🎮 Usage

### PowerShell Scaffolder

#### Basic Scaffolding

```powershell
.\init-zotero-rscript-plugin.ps1 `
  -ProjectName "CitationHelper" `
  -AuthorName "Jane Doe" `
  -TemplateType researcher
```

#### With Git Initialization

```powershell
.\init-zotero-rscript-plugin.ps1 `
  -ProjectName "CitationHelper" `
  -AuthorName "Jane Doe" `
  -TemplateType researcher `
  -GitInit
```

This creates:
- `.gitignore` with sensible defaults
- `LICENSE` file (AGPL-3.0)
- `Containerfile` for containerized development
- `.github/workflows/` for CI/CD

#### Verify File Integrity

```powershell
.\init-zotero-rscript-plugin.ps1 `
  -ProjectName "CitationHelper" `
  -VerifyIntegrity
```

Checks all files against stored XXHash64 checksums in `audit-index.json`.

### Racket Scaffolder

#### Basic Scaffolding

```bash
racket init-raczotbuild.rkt -n MyPlugin -a "John Smith"
```

#### With Git Auto-Init and First Commit

```bash
racket init-raczotbuild.rkt -n MyPlugin -a "John Smith" -g
```

This creates a complete Racket package with:
- `raczotbuild/` - Core scaffolding library
- `templates/` - JSON template definitions
- `tests/` - Rackunit test suite
- `examples/` - Usage examples
- `.github/workflows/ci.yml` - Automated testing

#### Custom Description

```bash
racket init-raczotbuild.rkt \
  -n MyPlugin \
  -a "John Smith" \
  -d "Advanced citation analysis for Zotero" \
  -g
```

## 🎨 Template Types

### 1. Practitioner (Professional)

**Best for:** Production plugins, commercial projects, professional development

**Includes:**
- ReScript/ReasonML type-safe source code
- Bootstrap-based architecture
- XUL overlay for UI integration
- Comprehensive error handling
- Package scripts for build/watch/package

**Structure:**
```
MyPlugin/
├── bootstrap.js          # Entry point
├── chrome/
│   ├── content/          # UI and logic
│   ├── locale/           # Localization
│   └── skin/             # Styling
├── src/                  # ReScript sources
├── install.rdf           # Plugin manifest
├── chrome.manifest       # Chrome registration
├── package.json          # npm configuration
└── bsconfig.json         # ReScript config
```

### 2. Researcher (Academic)

**Best for:** Research projects, citation analysis, metadata extraction

**Includes:**
- Advanced citation network analysis
- SQLite database integration (`Zotero.DBConnection`)
- Metadata extraction and export
- Multi-format data export (JSON, CSV)
- Research-specific UI components

**Key Features:**
```javascript
// Citation analysis
await Zotero.YourPlugin.analyzeCitations(item);

// Metadata extraction
const metadata = Zotero.YourPlugin.UI.extractMetadata();

// Data export
Zotero.YourPlugin.UI.exportData(); // File picker dialog
```

### 3. Student (Educational)

**Best for:** Learning Zotero development, tutorials, teaching materials

**Includes:**
- Extensively commented code (every function documented)
- TypeScript for type safety and IDE support
- `TUTORIAL.md` with step-by-step guide
- Interactive examples (`sayHello`, `countSelected`)
- Zotero API patterns and best practices

**Learning Path:**
1. Read `TUTORIAL.md` - Understanding plugin architecture
2. Modify `chrome/content/main.js` - Add custom functions
3. Extend `chrome/content/overlay.xul` - Create UI elements
4. Study `src/index.ts` - TypeScript integration
5. Experiment with Zotero API - Item manipulation

## 🔐 File Integrity Verification

The PowerShell scaffolder includes automatic integrity verification using **XXHash64** hashing.

### Audit Index Structure

After scaffolding, an `audit-index.json` is generated:

```json
{
  "generated": "2024-11-22T10:30:00.000Z",
  "files": [
    {
      "path": "README.md",
      "hash": "A1B2C3D4E5F60708"
    },
    {
      "path": "bootstrap.js",
      "hash": "9F8E7D6C5B4A3021"
    }
  ]
}
```

### Verification Process

```powershell
# Verify all files
.\init-zotero-rscript-plugin.ps1 -ProjectName MyPlugin -VerifyIntegrity
```

Output:
```
✅ All files intact (15/15 files verified)
```

Or if tampering detected:
```
⚠️  Hash mismatch: bootstrap.js
    expected A1B2C3D4E5F60708
    actual   DEADBEEF01234567
❌ 1 integrity issue(s) detected.
```

### Why XXHash64?

- **Fast:** ~10 GB/s on modern hardware
- **Collision-resistant:** 64-bit output space
- **Portable:** Pure C# implementation (no native dependencies)
- **Deterministic:** Same input always produces same hash

## 📦 Dependencies

### Required (All Platforms)

| Tool | Version | Purpose |
|------|---------|---------|
| Git | 2.x+ | Version control |

### PowerShell-Specific

| Tool | Version | Purpose |
|------|---------|---------|
| PowerShell | 7.0+ | Script execution |
| .NET Runtime | 6.0+ | XXHash computation |

### Racket-Specific

| Tool | Version | Purpose |
|------|---------|---------|
| Racket | 8.0+ | Script execution, package management |

### Optional (Template-Dependent)

| Tool | Required By | Purpose |
|------|-------------|---------|
| Node.js LTS | Practitioner | ReScript compilation, npm scripts |
| TypeScript 5.x | Student | Type checking, compilation |
| ReScript 10.x | Practitioner | Reason→JS compilation |
| PostgreSQL 12+ | Researcher (advanced) | External data storage |
| Deno | Advanced templates | Alternative runtime |

## 🗂️ Project Structure

```
zotero-rescript-templater/
├── LICENSE                              # AGPL-3.0
├── README.md                            # This file
├── CLAUDE.md                            # Claude AI documentation
│
├── init-raczotbuild.rkt                # Racket scaffolder
├── init-raczotbuild.bak                # Backup
├── init-zotero-rscript-plugin.ps1      # PowerShell scaffolder
├── zotero-template-dependencies.ps1    # Windows dependency installer
│
└── (generated by scaffolders)
    ├── MyPlugin/                        # Your generated plugin
    │   ├── audit-index.json             # Integrity checksums (PowerShell)
    │   ├── bootstrap.js                 # Zotero entry point
    │   ├── install.rdf                  # Plugin manifest
    │   ├── chrome.manifest              # UI registration
    │   ├── chrome/                      # UI and locales
    │   ├── src/                         # Source code (ReScript/TS)
    │   ├── package.json                 # npm config
    │   └── README.md                    # Plugin-specific docs
    └── ...
```

## 🏛️ Architecture

### Design Philosophy

1. **Dual Implementation**
   - **Racket:** Homoiconic, functional, minimal dependencies
   - **PowerShell:** Windows-native, enterprise-friendly, extensive tooling

2. **Embedded Templates**
   - No external files required
   - Portable single-script deployment
   - Version-controlled alongside code

3. **Variable Interpolation**
   - Simple `{{Variable}}` syntax
   - Sequential replacement (prevents nested issues)
   - No complex templating engine dependencies

4. **Integrity by Design**
   - Automatic checksum generation (PowerShell)
   - Tamper detection
   - Audit trail with timestamps

### Template Processing Flow

```
┌─────────────────────┐
│  User Input         │
│  - ProjectName      │
│  - AuthorName       │
│  - TemplateType     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Load Template JSON │
│  (embedded in       │
│   script)           │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Variable           │
│  Substitution       │
│  {{var}} → value    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Write Files        │
│  (preserving        │
│   structure)        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Generate           │
│  audit-index.json   │
│  (XXHash64)         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Optional: Git Init │
│  - .gitignore       │
│  - LICENSE          │
│  - workflows/       │
└─────────────────────┘
```

### PowerShell XXHash64 Implementation

Full C# implementation embedded in PowerShell:

```csharp
public static class XXHash64 {
  private const ulong PRIME64_1 = 11400714785074694791UL;
  private const ulong PRIME64_2 = 14029467366897019727UL;
  // ... (see init-zotero-rscript-plugin.ps1 for full code)

  public static ulong Compute(byte[] buf, ulong seed) {
    // Streaming hash computation
    // Handles arbitrary-length inputs
    // Returns 64-bit hash
  }
}
```

### Racket Homoiconic Specification

Project structure as data:

```racket
(define project-spec
  `(dir ,proj-name
    (dir "raczotbuild"
      (file "main.rkt" ,(format main-tpl proj-name)))
    (dir "templates"
      (file "practitioner.json" ,(jsexpr->string template-data)))
    (file "README.md" ,(format readme-tpl proj-name proj-author))))
```

Code and data are the same — manipulate structure like any Racket list!

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests if applicable
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Adding New Templates

**PowerShell:**
```powershell
$templates.newtype = @'
{
  "version": "0.1.0",
  "files": {
    "README.md": "# {{ProjectName}}\n...",
    "main.js": "// Your template code"
  }
}
'@
```

**Racket:**
```racket
(define project-spec
  `(dir ,proj-name
    (file "README.md" ,(format "# ~a\n" proj-name))
    (file "main.rkt" ,(format main-template proj-name))))
```

## 📄 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

Key points:
- ✅ Free to use, modify, and distribute
- ✅ Source code must remain open
- ✅ Network use triggers source disclosure
- ✅ Modifications must use same license
- ⚠️ No warranty provided

See [LICENSE](LICENSE) for full text.

### Why AGPL?

The AGPL ensures that if you run a modified version of this software on a server (e.g., as a web service for generating plugins), you must make your modified source code available to users. This prevents the "SaaS loophole" in regular GPL.

## 📚 Resources

- [Zotero Plugin Development](https://www.zotero.org/support/dev/client_coding)
- [Zotero JavaScript API](https://www.zotero.org/support/dev/client_coding/javascript_api)
- [XUL Tutorial](https://developer.mozilla.org/en-US/docs/Archive/Mozilla/XUL/Tutorial)
- [ReScript Documentation](https://rescript-lang.org/)
- [Racket Documentation](https://docs.racket-lang.org/)

## 🙏 Acknowledgments

- Zotero development team for comprehensive API documentation
- Racket community for homoiconic language design inspiration
- XXHash authors for fast, collision-resistant hashing algorithm

## 📧 Support

- **Issues:** [GitHub Issues](https://github.com/Hyperpolymath/zotero-rescript-templater/issues)
- **Discussions:** [GitHub Discussions](https://github.com/Hyperpolymath/zotero-rescript-templater/discussions)
- **Zotero Forums:** [Plugin Development Category](https://forums.zotero.org/categories/dev)

---

**Made with ❤️ for the Zotero community**

⭐ Star this repo if you find it useful!
