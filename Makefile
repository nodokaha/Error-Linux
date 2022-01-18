setup:
	./setup.sh
	./build.sh

setup_nodownload:
	./setup_nodownload.sh
	./build.sh

clean:
	rm -rf usr bin boot etc lib media mnt opt proc root run sbin sources

