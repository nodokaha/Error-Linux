build_toolchain: setup
	./build_toolchain.sh

nodownload_build_toolchain: setup_nodownload
	./build_toolchain.sh

setup_nodownload:
	./setup_nodownload.sh

setup: 
	./setup.sh

clean:
	mv lfs/sources .
	rm -rf lfs
