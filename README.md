perl-baudrate
=============

Perl code to set a custom serial baudrate on Linux using the TCSETS2 ioctl.

Historically, baud rates on UNIX --later: POSIX-- systems have been manipulated using the tcgetattr()/tcsetattr() functions with a struct termios and a very limited set of possible rates identified by constants such as B0, B50, B75, B110, …, through B9600. These have later been extended for select values such as B38400 and B115200. Hardware has since evolved to be able to use almost any value as a baud rate, even much higher ones. The interface however, has never been properly fixed.

Linux used a technique called "baud rate aliasing" to circumvent that problem in the past: A special mode can be set so that a request for B38400 would not actually set 38.4kBaud but instead a separately defined other baud rate with names like spd_hi for 57.6kBaud, spd_shi for 230kBaud or spd_warp for 460kBaud. These names may give you an idea how old and limited that interface is.

For this reason there is a new (and still not standard) way to set an arbitrary baud rate by actually using an integer to store the requested baud rate: TCGETS2/TCSETS2 using struct termios2.

Both documentation and example code for this method are sparse. A bug report to implement this in libc6 is still open: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=683826 Thankfully that bug report includes example C code to use the interface directly. The constant to tell the structure that an OTHER Baud rate has been set has unwisely been called BOTHER, which, being a proper english word, makes it completely impossible to find any information on the internet about this. So, to be more explicit (and hopefully be found by any future search for this topic): This is an example on how to set a custom baud rate with the BOTHER flag on Linux in Perl.

Transforming the C example into Perl code using the Perl ioctl function should be easy, right? Muahahaha. Every example on how to use Perl ioctl on the Internet (that I've reviewed) is wrong and/or broken. Even better: the perl distribution itself is broken in this instance. Quoth /usr/lib/perl/5.14.2/asm-generic/ioctls.ph on Ubuntu 13.10:
```perl
eval 'sub TCGETS2 () { &_IOR(ord(\'T\'), 0x2a, 1;}' unless defined(&TCGETS2);
```
(hint: count the number of opening and closing parenthesis.)

Even if that Perl code was syntactically correct, it's wrong in principle: The third argument to the _IOR macro should be the struct termios2 structure size. On x86_64 it's 44 bytes, not 1.

So, this code has two purposes: a) Correctly use Perl's ioctl to b) set a custom serial baud rate under Linux.

The definitions of both TCGETS2 and struct termios2 may (will) be architecture dependent, so there's a helper program in C to output the parameters for the current architecture.
