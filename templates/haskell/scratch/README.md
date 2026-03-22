# scratch - Haskell Nix Template

A robust, "fully kitted out" Haskell project template using `haskell.nix` and Flakes.

## Features

- **Haskell.nix Integration:** Clean, reproducible builds using Nix.
- **Development Shell:** 
  - GHC 9.10.3 (configured via `ghc910`)
  - Integrated Tools: `cabal`, `hlint`, `hls`, `ghcid`, `fourmolu`, `doctest`, `weeder`.
  - Documentation: Local Hoogle and Haddock generation.
  - C-libraries: `zlib`, `openssl`, `xz`, `icu`.
- **Project Structure:**
  - `src/`: Library logic.
  - `app/`: Executable entry point.
  - `test/`: Test suite.
  - `bench/`: Benchmarking suite using `tasty-bench`.
- **Convenience:**
  - `direnv` support with `.envrc`.
  - Pre-configured aliases: `g` for `ghcid`, `b` for `cabal bench`.
  - Comprehensive `.gitignore`.

## Getting Started

### Prerequisites

- [Nix](https://nixos.org/download.html) with [Flakes enabled](https://nixos.wiki/wiki/Flakes).
- [direnv](https://direnv.net/) (optional but recommended).

### Initial Setup

1.  **Clone the template:**
    ```bash
    git clone <your-repo-url> my-project
    cd my-project
    ```
2.  **Allow direnv:**
    ```bash
    direnv allow
    ```
    *This will automatically trigger `nix develop` to set up your GHC, Cabal, and tools.*

### Common Commands

- **Build:** `nix build` or `cabal build`
- **Run:** `nix run` or `cabal run scratch`
- **Test:** `cabal test`
- **Benchmark:** `cabal bench`
- **Development (REPL):** `cabal repl`
- **Development (Ghcid):** `g` (alias for `ghcid -c 'cabal repl'`)
- **Format:** `fourmolu -i src/ app/ test/ bench/`

## License

This project is licensed under the **BSD-3-Clause** license. See the `LICENSE` file for details.
