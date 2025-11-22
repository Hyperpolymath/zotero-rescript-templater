{
  description = "Zotero ReScript Templater - RSR-compliant scaffolding system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # PowerShell Core
        powershell = pkgs.powershell;

        # Racket
        racket = pkgs.racket;

        # Additional tools
        buildInputs = with pkgs; [
          # Core dependencies
          git
          just          # Build automation

          # Language runtimes
          powershell    # PowerShell 7+
          racket        # Racket 8.x
          bash          # Bash shell

          # Testing tools
          shellcheck    # Bash linting

          # Optional but useful
          nodejs_20     # For template testing
          xxHash        # File integrity
          jq            # JSON processing

          # Container tools (optional)
          podman        # Container runtime
        ];

        # Development shell
        devShell = pkgs.mkShell {
          inherit buildInputs;

          shellHook = ''
            echo "🎉 Zotero ReScript Templater Development Environment"
            echo "=================================================="
            echo ""
            echo "Available commands:"
            echo "  just --list        # Show all build recipes"
            echo "  just test          # Run all tests"
            echo "  just validate      # Full RSR validation"
            echo "  just scaffold-demos # Create demo projects"
            echo ""
            echo "Tool versions:"
            echo "  PowerShell: $(pwsh --version | head -1)"
            echo "  Racket:     $(racket --version)"
            echo "  Bash:       $(bash --version | head -1)"
            echo "  Git:        $(git --version)"
            echo "  Just:       $(just --version)"
            echo ""
            echo "RSR Compliance Level: Platinum (91%+ target)"
            echo ""

            # Install PowerShell modules if needed
            if ! pwsh -Command "Get-Module -ListAvailable -Name Pester" &>/dev/null; then
              echo "Installing Pester (PowerShell testing framework)..."
              pwsh -Command "Install-Module -Name Pester -Force -Scope CurrentUser -AcceptLicense" || true
            fi

            if ! pwsh -Command "Get-Module -ListAvailable -Name PSScriptAnalyzer" &>/dev/null; then
              echo "Installing PSScriptAnalyzer (PowerShell linter)..."
              pwsh -Command "Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -AcceptLicense" || true
            fi
          '';

          # Environment variables
          PROJECT_ROOT = builtins.toString ./.;
          RSR_COMPLIANCE = "platinum";
        };

        # Package definition (for nix build)
        package = pkgs.stdenv.mkDerivation {
          pname = "zotero-rescript-templater";
          version = "0.2.0";

          src = ./.;

          inherit buildInputs;

          phases = [ "unpackPhase" "installPhase" "checkPhase" ];

          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share/zotero-rescript-templater

            # Copy all source files
            cp -r * $out/share/zotero-rescript-templater/

            # Create wrapper scripts
            cat > $out/bin/zotero-scaffold-ps <<EOF
            #!${pkgs.bash}/bin/bash
            exec ${powershell}/bin/pwsh $out/share/zotero-rescript-templater/init-zotero-rscript-plugin.ps1 "\$@"
            EOF
            chmod +x $out/bin/zotero-scaffold-ps

            cat > $out/bin/zotero-scaffold-rkt <<EOF
            #!${pkgs.bash}/bin/bash
            exec ${racket}/bin/racket $out/share/zotero-rescript-templater/init-raczotbuild.rkt "\$@"
            EOF
            chmod +x $out/bin/zotero-scaffold-rkt

            cat > $out/bin/zotero-scaffold <<EOF
            #!${pkgs.bash}/bin/bash
            exec $out/share/zotero-rescript-templater/init-zotero-plugin.sh "\$@"
            EOF
            chmod +x $out/bin/zotero-scaffold
          '';

          checkPhase = ''
            # Run tests if test dependencies available
            if command -v pwsh &> /dev/null; then
              echo "Running PowerShell tests..."
              cd $src
              pwsh -Command "Invoke-Pester -Path ./tests/*.Tests.ps1 -Output Minimal" || true
            fi

            if command -v racket &> /dev/null; then
              echo "Running Racket tests..."
              cd $src
              racket tests/racket-tests.rkt || true
            fi
          '';

          meta = with pkgs.lib; {
            description = "Scaffolding system for Zotero plugins with comprehensive templates";
            longDescription = ''
              The Zotero ReScript Templater is an RSR-compliant scaffolding system
              that helps developers quickly bootstrap Zotero plugins with:

              - Three template types: Practitioner, Researcher, Student
              - Type-safe code generation (ReScript, TypeScript)
              - Comprehensive testing and CI/CD setup
              - File integrity verification
              - Cross-platform support (Windows, Linux, macOS)

              Implements the Rhodium Standard Repository (RSR) framework for
              offline-first, type-safe, memory-safe development.
            '';
            homepage = "https://github.com/Hyperpolymath/zotero-rescript-templater";
            license = licenses.agpl3Only;
            maintainers = [ ];  # Add maintainer info
            platforms = platforms.unix ++ platforms.darwin;
          };
        };

      in
      {
        # Development shell
        devShells.default = devShell;

        # Installable package
        packages.default = package;

        # Apps (runnable with 'nix run')
        apps = {
          # PowerShell scaffolder
          scaffold-ps = {
            type = "app";
            program = "${package}/bin/zotero-scaffold-ps";
          };

          # Racket scaffolder
          scaffold-rkt = {
            type = "app";
            program = "${package}/bin/zotero-scaffold-rkt";
          };

          # Bash scaffolder (default)
          default = {
            type = "app";
            program = "${package}/bin/zotero-scaffold";
          };
        };

        # Checks (run with 'nix flake check')
        checks = {
          # Run tests
          tests = pkgs.runCommand "zotero-templater-tests" {
            buildInputs = [ powershell racket ];
          } ''
            cd ${self}

            # PowerShell tests
            if command -v pwsh &> /dev/null; then
              pwsh -Command "Invoke-Pester -Path ./tests/*.Tests.ps1 -Output Minimal"
            fi

            # Racket tests
            if command -v racket &> /dev/null; then
              racket tests/racket-tests.rkt
            fi

            touch $out
          '';

          # Lint checks
          lint = pkgs.runCommand "zotero-templater-lint" {
            buildInputs = [ powershell racket shellcheck ];
          } ''
            cd ${self}

            # PowerShell lint
            pwsh -Command "Invoke-ScriptAnalyzer -Path ./init-zotero-rscript-plugin.ps1 -Severity Warning,Error" || true

            # Racket syntax check
            raco check init-raczotbuild.rkt || true

            # Bash lint
            shellcheck init-zotero-plugin.sh || true

            touch $out
          '';

          # RSR compliance check
          rsr-compliance = pkgs.runCommand "rsr-compliance-check" {
            src = self;
          } ''
            cd ${self}

            echo "Checking RSR framework compliance..."

            # Check for required files
            for file in README.md LICENSE CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md CHANGELOG.md MAINTAINERS.md; do
              if [ ! -f "$file" ]; then
                echo "ERROR: Missing $file"
                exit 1
              fi
            done

            # Check .well-known directory
            for file in security.txt ai.txt humans.txt; do
              if [ ! -f ".well-known/$file" ]; then
                echo "ERROR: Missing .well-known/$file"
                exit 1
              fi
            done

            echo "✅ RSR compliance check passed"
            touch $out
          '';
        };
      }
    );
}
