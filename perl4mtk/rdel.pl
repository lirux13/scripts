#!/usr/bin/perl -w

#
#by lirux @2014
#

use strict;
use warnings;

#print "\$ARGV[0] = $ARGV[0], \$ARGV[1] = $ARGV[1]\n";
&smart_delete($ARGV[0], $ARGV[1]);

########################################################################

########################################################################
#sub begin
########################################################################

sub smart_delete {
	my $folder = $_[0];
	my @pattern; # = $_[1];
	my $pattern_total = 0;

	chomp($folder);
	my $i = 1;

	while (defined($_[$i]) && "" ne $_[$i]) {
		my $temp = $_[$i];
		push(@pattern, $temp);
		$i++;
		$pattern_total++;
		print "$temp\n";
	}

	unless(-e $folder) {
		print "$folder不存在!\n";
		exit(0);
	}

	opendir (FOLDER_HDL, $folder) || die "Error in opening $folder\n";
	my @file_list = readdir(FOLDER_HDL);
	close(FOLDER_HDL);

	foreach my $patt (@pattern) {
		my $path;
		if($patt =~ m/\*/) {
			$patt =~ s/\*//;
			foreach my $file (@file_list) {
				if($file =~ m/$patt/) {
					print "$file\n";
				}
			}
		}
		else {
			$path = $folder."\\"."$patt";
			unless(-e $path) {
				#print "$path 不存在!\n";
				exit(0);
			}

			if(-d $path) {
				system("del $path /s /q /f > nul");
				system("rmdir $path /s /f > nul");
			}
			else {
				system("del $path /q /f > nul");
			}
			exit(0);
		}
	}
}

