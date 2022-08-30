# Copyright (c) Open Enclave SDK contributors.
# Licensed under the MIT License.

include ../../config.mk

CFLAGS=$(shell pkg-config oehost-$(COMPILER) --cflags)
LDFLAGS=$(shell pkg-config oehost-$(COMPILER) --libs)
INCDIR=$(shell pkg-config oehost-$(COMPILER) --variable=includedir)

build:
	@ echo "Compilers used: $(CC), $(CXX)"
	oeedger8r ../openenclavesample.edl --untrusted \
		--search-path $(INCDIR) \
		--search-path $(INCDIR)/openenclave/edl/sgx
	$(CC) -g -c $(CFLAGS) host.c
	$(CC) -g -c $(CFLAGS) openenclavesample_u.c
	$(CC) -o openenclavesamplehost openenclavesample_u.o host.o $(LDFLAGS)

clean:
	rm -f openenclavesamplehost host.o openenclavesample_u.o openenclavesample_u.c openenclavesample_u.h openenclavesample_args.h
