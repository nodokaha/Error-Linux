all: build_tier4
	echo "Finish!"
	echo "Please! ./root_chroot.sh or ./user_chroot.sh !!"

build_tier4: build_tier3
	./build_tier4.sh

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
	sudo chown $(shell users):$(shell users) -R lfs
	mv lfs/sources .
	rm -rf lfs

create-img:
	sudo modprobe nbd
	sudo qemu-img create -f qcow2 error.img 4G
	sudo qemu-nbd -c /dev/nbd0 error.img
	sudo parted /dev/nbd0 --script "mklabel msdos mkpart primary 1M 257M mkpart primary 257M 4G print quit"
	sudo mkfs.vfat /dev/nbd0p1 -n "BOOT"
	sudo mkfs.ext4 /dev/nbd0p2 -L "ROOT"
	sudo mount -o loop /dev/nbd0p2 /mnt
	sudo mkdir -p /mnt/boot
	sudo mount -o loop /dev/nbd0p1 /mnt/boot
	sudo rm -rf lfs/build
	sudo mv lfs/* /mnt/
	
