/*
 * get-constants.c
 *
 * Determine and print out all the constants needed for set-baudrate.pl
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
	struct termios2 *to = (struct termios2*)0;

	printf("\"TCGETS2\" => 0x%08X,\n", TCGETS2);
	printf("\"TCSETS2\" => 0x%08X,\n", TCSETS2);
	printf("\"BOTHER\" => 0x%08X,\n", BOTHER);
	printf("\"CBAUD\" => 0x%08X,\n", CBAUD);
	printf("\"termios2_size\" => %zi,\n", sizeof(*to));
	printf("\"c_ispeed_size\" => %zi,\n", sizeof(to->c_ispeed));
	printf("\"c_ispeed_offset\" => %p,\n", (void*)&(to->c_ispeed));
	printf("\"c_ospeed_size\" => %zi,\n", sizeof(to->c_ospeed));
	printf("\"c_ospeed_offset\" => %p,\n", (void*)&(to->c_ospeed));
	printf("\"c_cflag_size\" => %zi,\n", sizeof(to->c_cflag));
	printf("\"c_cflag_offset\" => %p,\n", (void*)&(to->c_cflag));

	return 0;
}
