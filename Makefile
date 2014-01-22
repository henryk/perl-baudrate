CFLAGS=-Wall -Werror -pedantic --std=gnu99
all: set-baudrate get-constants
clean:
	rm -f set-baudrate get-constants
	