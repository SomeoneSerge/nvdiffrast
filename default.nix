with (import <nixpkgs> {
  config = {
    cudaSupport = true;
    cudaCapabilities = [ "8.6" ];
    allowUnfree = true;
  };
});

python3Packages.callPackage (import ./nvdiffrast.nix) { }
