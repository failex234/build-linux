FS_FILES=be-latin1.bmap us.bmap uk.bmap de-latin1.bmap fr.bmap build.sh fstab group hosts inittab issue klogd.run Makefile passwd profile rcS shadow simple.script syslogd.run udhcpc.run ../busybox ../bzImage locale.sh

../fs.tar: build.sh $(FS_FILES)
	fakeroot ./build.sh
