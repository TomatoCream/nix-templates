# Docker/OCI image build
_: {
  perSystem =
    { pkgs, config, ... }:
    let
      rrrr = config.packages.default;
    in
    {
      packages.docker = pkgs.dockerTools.buildLayeredImage {
        name = "rrrr";
        tag = "latest";

        contents = [
          rrrr
          # Minimal runtime dependencies
          pkgs.cacert # SSL certificates
          pkgs.tzdata # Timezone data
        ];

        config = {
          Entrypoint = [ "${rrrr}/bin/rrrr" ];
          Env = [
            "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            "RUST_BACKTRACE=1"
          ];
          Labels = {
            "org.opencontainers.image.title" = "rrrr";
            "org.opencontainers.image.description" = "rrrr - A Rust CLI application";
            "org.opencontainers.image.source" = "https://github.com/yourusername/rrrr";
          };
        };

        # Maximum number of layers
        maxLayers = 120;
      };

      # Streamable layered image (for large images)
      packages.docker-stream = pkgs.dockerTools.streamLayeredImage {
        name = "rrrr";
        tag = "latest";

        contents = [
          rrrr
          pkgs.cacert
          pkgs.tzdata
        ];

        config = {
          Entrypoint = [ "${rrrr}/bin/rrrr" ];
          Env = [
            "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            "RUST_BACKTRACE=1"
          ];
        };
      };
    };
}
