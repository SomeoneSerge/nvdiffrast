{ lib
, buildPythonPackage
, python
, torch
, pybind11
, cmake
, pkg-config
, cudaPackages ? { }
, glew-egl
}:

with cudaPackages;

buildPythonPackage {
  pname = "nvdiffrast";
  version = "0.3.0";

  format = "other";

  src = lib.sourceByRegex ./. [
    "nvdiffrast(/.*)?"
    "CMakeLists.txt"
    "setup.py"
  ];

  nativeBuildInputs = [
    cuda_nvcc
    cmake
    pkg-config
  ];

  buildInputs = [
    cuda_nvcc
    cuda_cudart # CUDA_CUDART_LIBRARY
    cudnn
    cuda_nvrtc # CUDA_NVRTC_LIB
    cuda_nvtx # LIBNVTOOLSEXT
    libcusparse # cusparse.h
    libcublas # cublas_v2.h
    libcusolver # cusolverDn.h
    libcurand # CUDA_curand_LIBRARY
    libcufft # -lCUDA_cufft_LIBRARY-NOTFOUND

    pybind11
    torch.dev

    glew-egl.dev # EGL/egl.h
  ];

  checkInputs = [
    torch
  ];

  cmakeFlags = [
    "-DPython_SITEARCH=${placeholder "out"}/${python.sitePackages}"
    "-DPython_SITELIB=${placeholder "out"}/${python.sitePackages}"
    "-DTORCH_CUDA_ARCH_LIST=${builtins.concatStringsSep ";" cudaPackages.cudaFlags.cudaCapabilities}"
  ];

  pythonImportsCheck = [
    "nvdiffrast"
    "nvdiffrast.torch"
  ];

  dontUseSetuptoolsBuild = true;
  dontUsePipInstall = true;
}
