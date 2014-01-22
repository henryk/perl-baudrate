#!/usr/bin/perl -w

# Call with 
#  set_baudrate(*filehandle, direction, baudrate)
# where direction is 1 (inspeed only), 2 (outspeed only), or 3 (both)
# returns 0 for success, -1 for I/O errors, -2 for constant definition errors, -3 for unknown architecture
sub set_baudrate(*;$$) {
  my ($fh, $direction, $baudrate) = @_;

  my %constants = (
    "TCGETS2" => 0x802C542A,
    "TCSETS2" => 0x402C542B,
    "BOTHER" => 0x00001000,
    "CBAUD" => 0x0000100F,
    "termios2_size" => 44,
    "c_ispeed_size" => 4,
    "c_ispeed_offset" => 0x24,
    "c_ospeed_size" => 4,
    "c_ospeed_offset" => 0x28,
    "c_cflag_size" => 4,
    "c_cflag_offset" => 0x8,
  );
  
  # We can't directly use pack/unpack with a specifier like "integer of x bytes"
  # Instead, check that the native int matches the corresponding *_size properties
  # Should there be a platform where that isn't the case, we need to find a different
  # way (such as using bitstrings and performing the integer conversion ourselves)
  return -2 if (length pack("I", 0) != $constants{"c_ispeed_size"});
  return -2 if (length pack("I", 0) != $constants{"c_ospeed_size"});
  return -2 if (length pack("I", 0) != $constants{"c_cflag_size"});
  
  # First: Initialize the termios2 structure to the right size
  my $to = " "x $constants{"termios2_size"};
  
  # Second: Call TCGETS2
  ioctl($fh, $constants{"TCGETS2"}, $to) or return -1;
  
  # Third: Modify the termios2 structure
  #   A: Extract and modify c_cflag
  my $cflag = unpack "I", substr($to, $constants{"c_cflag_offset"}, $constants{"c_cflag_size"});
  $cflag &= ~$constants{"CBAUD"};
  $cflag |= $constants{"BOTHER"};
  substr($to, $constants{"c_cflag_offset"}, $constants{"c_cflag_size"}) = pack "I", $cflag;
  
  #   B: Modify c_ispeed
  if($direction & 1) {
    substr($to, $constants{"c_ispeed_offset"}, $constants{"i_speed_size"}) = pack "I", $baudrate;
  }
  
  #   B: Modify c_ospeed
  if($direction & 2) {
    substr($to, $constants{"c_ospeed_offset"}, $constants{"o_speed_size"}) = pack "I", $baudrate;
  }
  
  # Fourth: Call TCSETS2
  ioctl($fh, $constants{"TCSETS2"}, $to) or return -1;
  
  return 0;
}

if(defined($ARGV[1])) {
  open(my $fh, "+<", $ARGV[0]) or die ("Couldn't open device file");
  set_baudrate($fh, 3, 0+$ARGV[1]);
} else {
  die("Usage: set-baudrate.pl devicefile baudrate");
}

