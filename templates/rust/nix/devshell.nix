# Dev shell built from the same craneLib/toolchain as the package build
# (nix/rust.nix), so the environment developers see locally matches what
# `nix build` uses as closely as possible.
{
  pkgs,
  lib,
  rust,
}:
rust.craneLib.devShell {
  inherit (rust) checks;

  packages =
    with pkgs;
    [
      cargo-nextest
      cargo-criterion
      cargo-audit
      cargo-expand
      taplo
      bacon
      just
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [ mold ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      libiconv
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  shellHook = ''
    export RUST_SRC_PATH="${rust.rustToolchain}/lib/rustlib/src/rust/library"
  ''
  + lib.optionalString pkgs.stdenv.isLinux ''
    export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="clang"
    export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C link-arg=-fuse-ld=mold"
    export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="clang"
    export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C link-arg=-fuse-ld=mold"
  '';
}
