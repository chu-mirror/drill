#!/usr/bin/perl -w

my $regex = shift @ARGV;
while (<>) {
  if (/$regex/) {
    print;
  }
}

