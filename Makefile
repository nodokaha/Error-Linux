all: build_tier3
	echo "Finish!"
	echo "Please! ./root_chroot.sh or ./user_chroot.sh !!"

build_tier3: build_tier2
	./build_tier3.sh

build_tier2: build_tier1
	./build_tier2.sh

build_tier1: build_toolchain
	./build_tier1.sh

build_toolchain: setup
	./build_toolchain.sh

setup: 
	./setup.sh

clean:
	mv lfs/sources .
	rm -rf lfs
