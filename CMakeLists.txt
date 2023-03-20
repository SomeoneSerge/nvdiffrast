cmake_minimum_required(VERSION 3.20)

project(ucor LANGUAGES CXX)

set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

find_package(Python REQUIRED COMPONENTS Development)

if(NOT DEFINED Python_SITEARCH)
  message(FATAL_ERROR "Python_SITEARCH must be set")
endif()

if(NOT DEFINED Python_SITELIB)
  message(FATAL_ERROR "Python_SITELIB must be set")
endif()

set(correctPython_SITEARCH "${Python_SITEARCH}")
set(correctPython_SITELIB "${Python_SITELIB}")

find_package(Python REQUIRED COMPONENTS Development Interpreter)
set(Python_SITEARCH "${correctPython_SITEARCH}")
set(Python_SITELIB "${correctPython_SITELIB}")

find_package(pybind11 CONFIG)

find_package(Torch REQUIRED)

# find_package(GLEW REQUIRED)
find_package(OpenGL REQUIRED COMPONENTS OpenGL EGL)

python_add_library(
  nvdiffrast_plugin
  MODULE
  WITH_SOABI
  nvdiffrast/common/cudaraster/impl/Buffer.cpp
  nvdiffrast/common/cudaraster/impl/CudaRaster.cpp
  nvdiffrast/common/cudaraster/impl/RasterImpl.cu
  nvdiffrast/common/cudaraster/impl/RasterImpl.cpp
  nvdiffrast/common/common.cpp
  nvdiffrast/common/rasterize.cu
  nvdiffrast/common/interpolate.cu
  nvdiffrast/common/texture.cu
  nvdiffrast/common/texture.cpp
  nvdiffrast/common/antialias.cu
  nvdiffrast/torch/torch_bindings.cpp
  nvdiffrast/torch/torch_rasterize.cpp
  nvdiffrast/torch/torch_interpolate.cpp
  nvdiffrast/torch/torch_texture.cpp
  nvdiffrast/torch/torch_antialias.cpp)
target_link_libraries(nvdiffrast_plugin PRIVATE pybind11::headers torch_python
                                                ${TORCH_LIBRARIES})
target_compile_features(nvdiffrast_plugin PRIVATE cxx_std_11)
set_target_properties(nvdiffrast_plugin PROPERTIES BUILD_WITH_INSTALL_RPATH
                                                   TRUE)
target_compile_definitions(
  nvdiffrast_plugin PRIVATE -DNVDR_TORCH
                            -DTORCH_EXTENSION_NAME=nvdiffrast_plugin)

python_add_library(
  nvdiffrast_plugin_gl
  MODULE
  WITH_SOABI
  nvdiffrast/common/common.cpp
  nvdiffrast/common/glutil.cpp
  nvdiffrast/common/rasterize_gl.cpp
  nvdiffrast/torch/torch_bindings_gl.cpp
  nvdiffrast/torch/torch_rasterize_gl.cpp)

target_link_libraries(
  nvdiffrast_plugin_gl PRIVATE OpenGL::OpenGL OpenGL::EGL pybind11::headers
                               torch_python ${TORCH_LIBRARIES})
target_compile_features(nvdiffrast_plugin_gl PRIVATE cxx_std_11)
set_target_properties(nvdiffrast_plugin_gl PROPERTIES BUILD_WITH_INSTALL_RPATH
                                                      TRUE)
target_compile_definitions(
  nvdiffrast_plugin_gl PRIVATE -DNVDR_TORCH
                               -DTORCH_EXTENSION_NAME=nvdiffrast_plugin_gl)

install(
  TARGETS nvdiffrast_plugin nvdiffrast_plugin_gl
  COMPONENT python
  DESTINATION ${Python_SITEARCH}/nvdiffrast)

install(
  FILES nvdiffrast/__init__.py
  COMPONENT python
  DESTINATION ${Python_SITELIB}/nvdiffrast)

install(
  FILES nvdiffrast/torch/__init__.py nvdiffrast/torch/ops.py
  COMPONENT python
  DESTINATION ${Python_SITELIB}/nvdiffrast/torch)

install(
  FILES nvdiffrast/tensorflow/__init__.py nvdiffrast/tensorflow/ops.py
        nvdiffrast/tensorflow/plugin_loader.py
  COMPONENT python
  DESTINATION ${Python_SITELIB}/nvdiffrast/tensorflow)
