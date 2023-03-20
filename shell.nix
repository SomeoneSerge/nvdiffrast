with (import <nixpkgs> {
  config = {
    cudaSupport = true;
    cudaCapabilities = [ "8.6" ];
    allowUnfree = true;
  };
});

with cudaPackages;

let
  nvdiffrast = python3Packages.callPackage (import ./nvdiffrast.nix) { };
  py = python3.withPackages (ps: with ps; [
    torch
    imageio
  ]);
in
(mkShell.override { stdenv = cudaPackages.backendStdenv; }) {
  inputsFrom = [ nvdiffrast ];

  env.TORCH_CUDA_ARCH_LIST = builtins.concatStringsSep ";" config.cudaCapabilities;

  shellHook =
    let
      sitePackages = "$PWD/prefix/${py.sitePackages}";
    in
    ''
      mkdir -p "${sitePackages}"
      export PYTHONPATH="${sitePackages}":$PYTHONPATH
      export PYTHONUSERBASE=$PWD/prefix
    '';
}
