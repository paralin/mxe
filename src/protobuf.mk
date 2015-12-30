# This file is part of MXE.
# See index.html for further information.

PKG             := protobuf
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.6.1
$(PKG)_CHECKSUM := ee445612d544d885ae240ffbcbf9267faa9f593b7b101f21d58beceb92661910
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://github.com/google/protobuf/releases/download/v$($(PKG)_VERSION)/$(PKG)-$($(PKG)_VERSION).tar.bz2
$(PKG)_DEPS     := gcc zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://code.google.com/p/protobuf/downloads/list?sort=-uploaded' | \
    $(SED) -n 's,.*protobuf-\([0-9][^<]*\)\.tar.*,\1,p' | \
    grep -v 'rc' | \
    head -1
endef

define $(PKG)_BUILD
# First step: Build for host system in order to create "protoc" binary.
    cd '$(1)' && ./configure \
        --disable-shared
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    cp '$(1)/src/protoc' '$(PREFIX)/bin/$(TARGET)-protoc'
    $(MAKE) -C '$(1)' -j 1 distclean
# Second step: Build for target system.
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-zlib \
        --with-protoc='$(PREFIX)/bin/$(TARGET)-protoc'
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install

    '$(TARGET)-g++' \
        -W -Wall -Werror -ansi -pedantic \
        '$(2).cpp' -o '$(PREFIX)/$(TARGET)/bin/test-protobuf.exe' \
        `'$(TARGET)-pkg-config' protobuf --cflags --libs`
endef
