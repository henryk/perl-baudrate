/*
 * set-baudrate.c
 *
 * Based on direct-tcgets2-test.c in http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=683826
 *
 *  Created on: 22 Jan 2014
 *      Author: henryk
 */
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include "/usr/include/asm-generic/termbits.h"
#include "/usr/include/asm-generic/ioctls.h"

int main(int argc, const char **argv)
{
	struct termios2 to;
	int fh, r, baudrate;
	if(argc != 3) {
		fprintf(stderr, "Usage: %s devicenode baudrate\n", argv[0]);
		return -1;
	}

	fh = open(argv[1], O_RDWR | O_NOCTTY);
	if(fh < 0) {
		perror("open");
		return -1;
	}

	baudrate = atoi(argv[2]);
	r = ioctl(0, TCGETS2, &to);
	if(r) {
		perror("TCGETS2");
		return -1;
	}

	to.c_ispeed = to.c_ospeed = baudrate;
	to.c_cflag &= ~CBAUD;
	to.c_cflag |= BOTHER;
	r = ioctl(0, TCSETS2, &to);
	if(r) {
		perror("TCSETS2");
		return -1;
	}

	return 0;
}
