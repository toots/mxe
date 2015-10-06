# This file is part of MXE.
# See index.html for further information.

PKG             := libmysqlclient
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 6.1.6
$(PKG)_CHECKSUM := 2222433012c415871958b61bc4f3683e1ebe77e3389f698b267058c12533ea78
$(PKG)_SUBDIR   := mysql-connector-c-$($(PKG)_VERSION)-src
$(PKG)_FILE     := $($(PKG)_SUBDIR).tar.gz
$(PKG)_URL      := https://dev.mysql.com/get/Downloads/Connector-C/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc pthreads openssl

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://dev.mysql.com/downloads/connector/c/' | \
    $(SED) -n 's,.*mysql-connector-c-\([0-9\.]\+\)-win.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    # native build for tool comp_err
    # See https://bugs.mysql.com/bug.php?id=61340
    mkdir '$(1).native'
    cd '$(1).native' && cmake \
         '$(1)'
    $(MAKE) -C '$(1).native' -j '$(JOBS)' VERBOSE=1
    # cross-compilation
    mkdir '$(1).build'
    cd '$(1).build' && cmake \
        -DCMAKE_INSTALL_PREFIX=$(PREFIX)/$(TARGET) \
        -DCMAKE_TOOLCHAIN_FILE='$(CMAKE_TOOLCHAIN_FILE)' \
        -DIMPORT_COMP_ERR='$(1).native/ImportCompErr.cmake' \
        -DHAVE_GCC_ATOMIC_BUILTINS=1 \
        -DDISABLE_SHARED=1 \
        -DENABLE_DTRACE=OFF \
        -DWITH_ZLIB=system \
        '$(1)'
    $(MAKE) -C '$(1).build' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(1).build' -j 1 install VERBOSE=1
endef

$(PKG)_BUILD_SHARED =
