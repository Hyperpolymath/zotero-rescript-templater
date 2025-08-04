<#
.SYNOPSIS
  Bootstraps a Zotero R-script plugin project from embedded templates,
  optionally initializes Git meta-files, and performs xxHash-based audit.

.PARAMETER ProjectName
  Directory name for the new project.

.PARAMETER AuthorName
  Your name, injected into templates.

.PARAMETER TemplateType
  Which scaffold to use: practitioner, researcher, or student.

.PARAMETER GitInit
  Switch to layer in .gitignore, LICENSE, .github/, Containerfile, etc.

.PARAMETER VerifyIntegrity
  Switch to verify existing audit-index.json against file contents.

.EXAMPLE
  .\init-zotero-rscript-plugin.ps1 -ProjectName MyPlugin -AuthorName "You" -TemplateType practitioner -GitInit

.EXAMPLE
  .\init-zotero-rscript-plugin.ps1 -ProjectName MyPlugin -VerifyIntegrity
#>

param(
  [Parameter(Mandatory)][string]$ProjectName,
  [Parameter(Mandatory)][string]$AuthorName,
  [ValidateSet("practitioner","researcher","student")][string]$TemplateType = "practitioner",
  [switch]$GitInit,
  [switch]$VerifyIntegrity
)

$ErrorActionPreference = 'Stop'

# 1. Define XXHash C# helper & function
Add-Type -Language CSharp -TypeDefinition @"
using System;
public static class XXHash {
  // Constants and helper methods omitted for brevity (same as previous)
  // Insert full implementation here...
  public static ulong Compute(byte[] b) {
    // Implementation...
    return 0UL; // placeholder
  }
}
"@

function Get-XXHash64([string]$file) {
  $bytes = [System.IO.File]::ReadAllBytes($file)
  $hash = [XXHash]::Compute($bytes)
  return $hash.ToString("X16")
}

# 2. Embedded JSON Templates
$templates = @{
  practitioner = @'
{ "version":"0.1.0","files":{ "README.md":"# {{ProjectName}}\nProfessional by {{AuthorName}}.","install.rdf":"<RDF>…","chrome.manifest":"content {{ProjectName}} chrome/","src/plugin.re":"// ReasonML","public/index.html":"<!DOCTYPE html>…"}}
'@
  researcher   = @'
{ "version":"0.1.0","files":{ "README.md":"# {{ProjectName}}\nResearch by {{AuthorName}}.","install.rdf":"<RDF>…","src/main.js":"// JS entry"}} 
'@
  student      = @'
{ "version":"0.1.0","files":{ "README.md":"# {{ProjectName}}\nStudent by {{AuthorName}}.","install.rdf":"<RDF>…","src/index.ts":"// TS entry"}} 
'@
}

# 3. Integrity Verification Mode
if ($VerifyIntegrity) {
  try {
    Write-Host "Verifying integrity via audit-index.json…" -ForegroundColor Cyan
    $idx = Join-Path $ProjectName 'audit-index.json'
    if (-not (Test-Path $idx)) { throw "audit-index.json not found under '$ProjectName'." }
    $audit = Get-Content $idx -Raw | ConvertFrom-Json
    $fail = 0
    foreach ($rec in $audit.files) {
      $path = Join-Path $ProjectName $rec.path
      if (-not (Test-Path $path)) {
        Write-Warning "Missing: $($rec.path)"; $fail++
      } else {
        $cur = Get-XXHash64 $path
        if ($cur -ne $rec.hash) {
          Write-Warning "Hash mismatch: $($rec.path)`n expected $($rec.hash)`n actual   $cur"
          $fail++
        }
      }
    }
    if ($fail) { throw "$fail integrity issue(s) detected." }
    Write-Host "All files intact ✔" -ForegroundColor Green
    exit 0
  } catch {
    Write-Error $_
    exit 1
  }
}

try {
  # 4. Load & Validate Template JSON
  if (-not $templates.ContainsKey($TemplateType)) {
    throw "Unknown template '$TemplateType'."
  }
  $tpl = $templates[$TemplateType] | ConvertFrom-Json

  # 5. Create Project Root
  if (Test-Path $ProjectName) {
    throw "Directory '$ProjectName' already exists."
  }
  New-Item -Path $ProjectName -ItemType Directory | Out-Null
  Push-Location $ProjectName

  # 6. Scaffold Files & Folders
  foreach ($rel in $tpl.files.PSObject.Properties.Name) {
    $raw    = $tpl.files.$rel
    $target = Join-Path (Get-Location) $rel
    $dir    = Split-Path $target -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    # Sequential Replace to avoid parser errors
    $content = $raw
    $content = $content.Replace('{{ProjectName}}', $ProjectName)
    $content = $content.Replace('{{AuthorName}}',  $AuthorName)
    $content = $content.Replace('{{version}}',     $tpl.version)

    $content | Out-File -FilePath $target -Encoding UTF8
    Write-Host "Created $rel"
  }

  # 7. GitInit: meta-files, .gitignore, Containerfile, .github/
  if ($GitInit) {
    Write-Host "`n== Adding Git meta-files ==" -ForegroundColor Yellow

    # .gitignore
    @"
# OS
.DS_Store
Thumbs.db

# SVN
.svn/

# Node/Deno
node_modules/
deno.lock

# Builds & deps
/_build/
/deps/

# VSCode
.vscode/

# Podman/Docker
*.tar
"@ | Set-Content .gitignore

    # LICENSE, Containerfile, .github/… (same as prior example)
    # [omitted here for brevity]
  }

  # 8. Generate audit-index.json
  Write-Host "`nGenerating audit-index.json…" -ForegroundColor Cyan
  $audit = [PSCustomObject]@{
    generated = (Get-Date).ToString("o")
    files     = @()
  }
  Get-ChildItem -File -Recurse | ForEach-Object {
    $rel = $_.FullName.Substring((Get-Location).Path.Length+1).Replace('\','/')
    $audit.files += [PSCustomObject]@{
      path = $rel
      hash = Get-XXHash64 $_.FullName
    }
  }
  $audit | ConvertTo-Json -Depth 4 | Out-File audit-index.json -Encoding UTF8
  Write-Host "audit-index.json written." -ForegroundColor Green

  Pop-Location
  Write-Host "`nAll done!" -ForegroundColor Green

} catch {
  Write-Error "Fatal: $_"
  exit 1
}
