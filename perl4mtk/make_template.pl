#!/usr/bin/perl -w

#
#by lirux @2014
#

use strict;
use warnings;

################################################
die if(@ARGV != 0 && @ARGV != 1);

my $file_name;
if(@ARGV == 1) {
	$file_name = $ARGV[0];
}
else {
	$
}

chomp($file_name);



################################################
#sub begin
################################################
sub make_perl_file {
	my $bat_file = $_[0].".bat";
	my $pl_file = "script".$_[0].".pl";

	if(-e $bat_file) {
		die "$bat_file ÒÑ´æÔÚ\n";
	}
}


