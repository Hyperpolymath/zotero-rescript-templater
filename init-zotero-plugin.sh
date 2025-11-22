#!/usr/bin/env bash

# Zotero Plugin Scaffolder - Bash/Shell Version
# For Linux and macOS users
#
# Usage:
#   ./init-zotero-plugin.sh -n ProjectName -a "Author Name" -t template_type [-g]
#
# Options:
#   -n  Project name (required)
#   -a  Author name (required)
#   -t  Template type: practitioner|researcher|student (default: student)
#   -g  Initialize git repository
#   -v  Verify integrity of existing project
#   -h  Show help

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
PROJECT_NAME=""
AUTHOR_NAME=""
TEMPLATE_TYPE="student"
GIT_INIT=false
VERIFY_INTEGRITY=false

# Functions
usage() {
  cat <<EOF
Zotero Plugin Scaffolder - Bash Version

Usage:
  $0 -n ProjectName -a "Author Name" [-t template] [-g] [-v]

Options:
  -n NAME       Project name (required)
  -a AUTHOR     Author name (required)
  -t TEMPLATE   Template type: practitioner|researcher|student (default: student)
  -g            Initialize git repository
  -v            Verify integrity of existing project
  -h            Show this help message

Examples:
  # Create a student plugin
  $0 -n MyPlugin -a "John Doe"

  # Create a practitioner plugin with git
  $0 -n AdvancedPlugin -a "Jane Smith" -t practitioner -g

  # Verify integrity
  $0 -n MyPlugin -v

EOF
  exit 0
}

error() {
  echo -e "${RED}Error: $1${NC}" >&2
  exit 1
}

info() {
  echo -e "${CYAN}$1${NC}"
}

success() {
  echo -e "${GREEN}$1${NC}"
}

warning() {
  echo -e "${YELLOW}$1${NC}"
}

# XXHash64 implementation using xxhsum if available, fallback to sha256
compute_hash() {
  local file="$1"

  if command -v xxhsum &> /dev/null; then
    xxhsum -H64 "$file" | awk '{print $1}'
  elif command -v xxh64sum &> /dev/null; then
    xxh64sum "$file" | awk '{print $1}'
  else
    # Fallback to SHA256 if xxhash not available
    if [[ "$OSTYPE" == "darwin"* ]]; then
      shasum -a 256 "$file" | awk '{print $1}'
    else
      sha256sum "$file" | awk '{print $1}'
    fi
  fi
}

# Verify file integrity
verify_integrity() {
  local project="$1"
  local audit_file="$project/audit-index.json"

  if [[ ! -f "$audit_file" ]]; then
    error "audit-index.json not found in $project"
  fi

  info "Verifying integrity via audit-index.json..."

  local fail_count=0

  # Read audit file and verify each file
  # Note: This uses Python for JSON parsing if available, otherwise falls back to jq
  if command -v python3 &> /dev/null; then
    python3 <<EOF
import json
import sys
import os

with open('$audit_file', 'r') as f:
    audit = json.load(f)

fail_count = 0
for file_entry in audit['files']:
    path = os.path.join('$project', file_entry['path'])
    expected_hash = file_entry['hash']

    if not os.path.exists(path):
        print(f"⚠️  Missing: {file_entry['path']}", file=sys.stderr)
        fail_count += 1
    else:
        # For simplicity, we'll shell out to compute hash
        import subprocess
        actual_hash = subprocess.check_output(['bash', '-c', 'compute_hash "$0"', path]).decode().strip()

        if actual_hash != expected_hash:
            print(f"⚠️  Hash mismatch: {file_entry['path']}", file=sys.stderr)
            print(f"   expected {expected_hash}", file=sys.stderr)
            print(f"   actual   {actual_hash}", file=sys.stderr)
            fail_count += 1

if fail_count > 0:
    print(f"\\n❌ {fail_count} integrity issue(s) detected.", file=sys.stderr)
    sys.exit(1)
else:
    print("✅ All files intact")
EOF
    exit $?
  elif command -v jq &> /dev/null; then
    while IFS= read -r line; do
      local path=$(echo "$line" | jq -r '.path')
      local expected_hash=$(echo "$line" | jq -r '.hash')
      local full_path="$project/$path"

      if [[ ! -f "$full_path" ]]; then
        warning "Missing: $path"
        ((fail_count++))
      else
        local actual_hash=$(compute_hash "$full_path")
        if [[ "$actual_hash" != "$expected_hash" ]]; then
          warning "Hash mismatch: $path"
          echo "  expected $expected_hash"
          echo "  actual   $actual_hash"
          ((fail_count++))
        fi
      fi
    done < <(jq -c '.files[]' "$audit_file")

    if [[ $fail_count -gt 0 ]]; then
      error "$fail_count integrity issue(s) detected"
    fi
    success "✅ All files intact"
  else
    error "Neither python3 nor jq found. Please install one of them for integrity verification."
  fi
}

# Create a file with variable substitution
create_file() {
  local path="$1"
  local content="$2"

  # Create parent directory if needed
  local dir=$(dirname "$path")
  mkdir -p "$dir"

  # Perform variable substitution
  content="${content//\{\{ProjectName\}\}/$PROJECT_NAME}"
  content="${content//\{\{AuthorName\}\}/$AUTHOR_NAME}"
  content="${content//\{\{version\}\}/0.1.0}"

  # Write file
  echo "$content" > "$path"
}

# Generate audit index
generate_audit_index() {
  local project="$1"
  local audit_file="$project/audit-index.json"

  info "Generating audit-index.json..."

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

  # Start JSON
  echo "{" > "$audit_file"
  echo "  \"generated\": \"$timestamp\"," >> "$audit_file"
  echo "  \"files\": [" >> "$audit_file"

  local first=true
  while IFS= read -r -d '' file; do
    local rel_path="${file#$project/}"

    # Skip audit-index.json itself
    if [[ "$rel_path" == "audit-index.json" ]]; then
      continue
    fi

    local hash=$(compute_hash "$file")

    if [[ "$first" == true ]]; then
      first=false
    else
      echo "," >> "$audit_file"
    fi

    echo -n "    {\"path\": \"$rel_path\", \"hash\": \"$hash\"}" >> "$audit_file"
  done < <(find "$project" -type f -print0)

  echo "" >> "$audit_file"
  echo "  ]" >> "$audit_file"
  echo "}" >> "$audit_file"

  success "audit-index.json generated"
}

# Scaffold project
scaffold_project() {
  if [[ -d "$PROJECT_NAME" ]]; then
    error "Directory '$PROJECT_NAME' already exists"
  fi

  info "Creating project: $PROJECT_NAME"
  info "Template type: $TEMPLATE_TYPE"

  mkdir -p "$PROJECT_NAME"

  # Load template based on type
  case "$TEMPLATE_TYPE" in
    practitioner)
      scaffold_practitioner
      ;;
    researcher)
      scaffold_researcher
      ;;
    student)
      scaffold_student
      ;;
    *)
      error "Unknown template type: $TEMPLATE_TYPE"
      ;;
  esac

  # Generate audit index
  generate_audit_index "$PROJECT_NAME"

  # Git init if requested
  if [[ "$GIT_INIT" == true ]]; then
    info "Initializing git repository..."
    (cd "$PROJECT_NAME" && git init && git add . && git commit -m "chore: initial commit from scaffolder")
  fi

  success "✅ Project '$PROJECT_NAME' created successfully!"
}

# Template implementations
scaffold_student() {
  info "Scaffolding student template..."

  # README.md
  create_file "$PROJECT_NAME/README.md" "# {{ProjectName}}

A learning-focused Zotero plugin by {{AuthorName}}.

## Educational Purpose

This plugin is designed as a learning project for understanding Zotero plugin development.

## Getting Started

1. Read TUTORIAL.md
2. Install dependencies: \`npm install\`
3. Build: \`npm run build\`

## License

MIT © {{AuthorName}}"

  # TUTORIAL.md
  create_file "$PROJECT_NAME/TUTORIAL.md" "# {{ProjectName}} Tutorial

Welcome to your Zotero plugin learning journey!

## Table of Contents

1. [Understanding Zotero Plugins](#understanding-zotero-plugins)
2. [Project Structure](#project-structure)
3. [Your First Modification](#your-first-modification)

## Understanding Zotero Plugins

Zotero plugins extend the functionality of Zotero...

## Project Structure

\`\`\`
{{ProjectName}}/
├── bootstrap.js      # Plugin entry point
├── chrome/          # UI components
│   ├── content/     # JavaScript logic
│   ├── locale/      # Localization
│   └── skin/        # CSS styles
├── install.rdf      # Plugin manifest
└── src/            # TypeScript sources
\`\`\`

## Your First Modification

Let's add a simple menu item...

Happy coding! 🎓"

  # install.rdf
  create_file "$PROJECT_NAME/install.rdf" "<?xml version=\"1.0\"?>
<RDF xmlns=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
     xmlns:em=\"http://www.mozilla.org/2004/em-rdf#\">
  <Description about=\"urn:mozilla:install-manifest\">
    <em:id>{{ProjectName}}@student.zotero.org</em:id>
    <em:name>{{ProjectName}} Student Edition</em:name>
    <em:version>{{version}}</em:version>
    <em:description>Learning-focused Zotero plugin</em:description>
    <em:creator>{{AuthorName}}</em:creator>
    <em:type>2</em:type>
    <em:bootstrap>true</em:bootstrap>
    <em:targetApplication>
      <Description>
        <em:id>zotero@chnm.gmu.edu</em:id>
        <em:minVersion>5.0</em:minVersion>
        <em:maxVersion>6.*</em:maxVersion>
      </Description>
    </em:targetApplication>
  </Description>
</RDF>"

  # chrome.manifest
  create_file "$PROJECT_NAME/chrome.manifest" "content {{ProjectName}} chrome/content/
locale {{ProjectName}} en-US chrome/locale/en-US/
skin {{ProjectName}} default chrome/skin/
overlay chrome://zotero/content/zoteroPane.xul chrome://{{ProjectName}}/content/overlay.xul"

  # bootstrap.js
  create_file "$PROJECT_NAME/bootstrap.js" "/**
 * Bootstrap Entry Point - Student Edition
 * This file is heavily commented for educational purposes
 */

const { classes: Cc, interfaces: Ci, utils: Cu } = Components;

function startup({ id, version, resourceURI, rootURI = resourceURI.spec }, reason) {
  Cu.import('resource://gre/modules/Services.jsm');

  // Load main script
  Services.scriptloader.loadSubScript(rootURI + 'chrome/content/main.js');

  if (typeof Zotero === 'undefined') {
    Zotero = {};
  }

  // Initialize plugin
  Zotero.{{ProjectName}} = {
    init: function() {
      console.log('{{ProjectName}} initialized!');
      this.initialized = true;
    },
    shutdown: function() {
      this.initialized = false;
    }
  };

  Zotero.{{ProjectName}}.init();
}

function shutdown({ id, version, resourceURI, rootURI = resourceURI.spec }, reason) {
  if (typeof Zotero !== 'undefined' && Zotero.{{ProjectName}}) {
    Zotero.{{ProjectName}}.shutdown();
  }
}

function install(data, reason) {}
function uninstall(data, reason) {}"

  # chrome/content/main.js
  create_file "$PROJECT_NAME/chrome/content/main.js" "/**
 * Main UI Logic - Student Edition
 * Educational examples with extensive comments
 */

(function() {
  'use strict';

  if (!Zotero.{{ProjectName}}) {
    Zotero.{{ProjectName}} = {};
  }

  Zotero.{{ProjectName}}.UI = {
    sayHello: function() {
      const items = ZoteroPane.getSelectedItems();
      alert(\`Hello! You selected \${items.length} item(s)\`);
    }
  };
})();"

  # chrome/content/overlay.xul
  create_file "$PROJECT_NAME/chrome/content/overlay.xul" "<?xml version=\"1.0\"?>
<overlay id=\"{{ProjectName}}-overlay\"
         xmlns=\"http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul\">
  <script src=\"chrome://{{ProjectName}}/content/main.js\"/>
  <menupopup id=\"zotero-itemmenu\">
    <menuitem id=\"{{ProjectName}}-hello\"
              label=\"Say Hello ({{ProjectName}})\"
              oncommand=\"Zotero.{{ProjectName}}.UI.sayHello();\"/>
  </menupopup>
</overlay>"

  # package.json
  create_file "$PROJECT_NAME/package.json" "{
  \"name\": \"{{ProjectName}}\",
  \"version\": \"{{version}}\",
  \"description\": \"Educational Zotero plugin\",
  \"author\": \"{{AuthorName}}\",
  \"license\": \"MIT\",
  \"scripts\": {
    \"build\": \"tsc\",
    \"watch\": \"tsc --watch\"
  },
  \"devDependencies\": {
    \"typescript\": \"^5.0.0\"
  }
}"

  # .gitignore
  create_file "$PROJECT_NAME/.gitignore" "node_modules/
dist/
*.xpi
.DS_Store
*.log"

  success "Student template created"
}

scaffold_practitioner() {
  info "Scaffolding practitioner template..."
  # Similar implementation for practitioner template
  # (Abbreviated for space - would include full practitioner template)
  scaffold_student  # Temporary fallback
  warning "Note: Practitioner template uses student base (full implementation pending)"
}

scaffold_researcher() {
  info "Scaffolding researcher template..."
  # Similar implementation for researcher template
  # (Abbreviated for space - would include full researcher template)
  scaffold_student  # Temporary fallback
  warning "Note: Researcher template uses student base (full implementation pending)"
}

# Parse command line arguments
while getopts ":n:a:t:gvh" opt; do
  case $opt in
    n)
      PROJECT_NAME="$OPTARG"
      ;;
    a)
      AUTHOR_NAME="$OPTARG"
      ;;
    t)
      TEMPLATE_TYPE="$OPTARG"
      ;;
    g)
      GIT_INIT=true
      ;;
    v)
      VERIFY_INTEGRITY=true
      ;;
    h)
      usage
      ;;
    \?)
      error "Invalid option: -$OPTARG"
      ;;
    :)
      error "Option -$OPTARG requires an argument"
      ;;
  esac
done

# Main execution
main() {
  if [[ "$VERIFY_INTEGRITY" == true ]]; then
    if [[ -z "$PROJECT_NAME" ]]; then
      error "Project name (-n) is required for integrity verification"
    fi
    verify_integrity "$PROJECT_NAME"
    exit 0
  fi

  # Validate required arguments
  if [[ -z "$PROJECT_NAME" ]]; then
    error "Project name (-n) is required"
  fi

  if [[ -z "$AUTHOR_NAME" ]]; then
    error "Author name (-a) is required"
  fi

  # Scaffold the project
  scaffold_project
}

main
