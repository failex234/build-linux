KERNEL_VERSION=4.16.2
KERNEL_URL=https://linux-libre.fsfla.org/pub/linux-libre/releases/4.16.2-gnu/linux-libre-$(KERNEL_VERSION)-gnu.tar.xz
BUSYBOX_VERSION=1.28.3
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

all: fs.tar

getkernel:
	@echo There may be a newer version of the kernel and if you want the latest
	@echo	go to https://linux-libre.fsfla.org/pub/linux-libre/releases and
	@echo	look for the latest version and change the kernel version in line 1 of
	@echo	this makefile to your wanted version.
	@echo
	@echo If you don\'t care press any key to continue.
	@read temp
	ls linux-libre-$(KERNEL_VERSION)-gnu.tar.xz || wget $(KERNEL_URL)

kernelpre: getkernel
	tar -xf linux-libre-$(KERNEL_VERSION)-gnu.tar.xz
	cp kernel-config linux-$(KERNEL_VERSION)/.config

kernel: kernelpre kernel-config
	$(MAKE) -C linux-$(KERNEL_VERSION)
	cp linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage .

getbusybox:
	@echo There may be a newer version of busybox and if you want the latest
	@echo	version go to https://www.busybox.net/downloads/ and look for the
	@echo	latest version and change the busybox version in line 3 of this makefile
	@echo	to your wanted version.
	@echo
	@echo If you don\'t care press any key to continue.
	@read temp
	ls busybox-$(BUSYBOX_VERSION).tar.bz2 || wget $(BUSYBOX_URL)

busyboxpre: getbusybox
	tar -xf busybox-$(BUSYBOX_VERSION).tar.bz2

busybox: busyboxpre bb-config
	sed '1,1i#include <sys/resource.h>' -i busybox-$(BUSYBOX_VERSION)/include/libbb.h
	cp bb-config busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) CC=musl-gcc -C busybox-$(BUSYBOX_VERSION)
	cp busybox-$(BUSYBOX_VERSION)/busybox .

fs.tar: kernel busybox
	$(MAKE) -C filesystem

image: fs.tar gen_image.sh
	sudo ./gen_image.sh

html: doc/doc.html

doc/doc.html: README.md doc/header-css.html doc/begin-div.html doc/end-div.html
	pandoc -f markdown -t html5 README.md -o doc/doc.html -H doc/header-css.html -B doc/begin-div.html -A doc/end-div.html

.PHONY: fs.tar html
