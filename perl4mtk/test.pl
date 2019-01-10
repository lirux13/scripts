#!/usr/local/bin/perl

use warnings;
use strict;

my $path = ".\\make\\*.test";
#my $tt = system("dir ~*");

#正则表达式
my $test = "0_ABC_123";

#$test =~ s/[A-Z]|_//g;
$test = &get_file_size_datetime("1key_custom.00.pl");

print "$test\n\n";
exit(0);

my $dir_len = rindex($path, "\\");
my $dir = substr($path, 0, $dir_len);
my $pattern = substr($path, $dir_len+1);
print "dir = $dir, len = $dir_len\n";
print "find * : ", index($pattern, "7"), "\n";
exit(0);

opendir (DIR_HDL, "$path") || die "Cannot open $path\n"; 
my @file_list = readdir DIR_HDL;
close DIR_HDL;

foreach my $tmp(@file_list) {
	next if -d $tmp;
	print "$tmp\n";
}


sub get_file_size_datetime {
	my $file = $_[0];
	my @file_info = stat $file ;

	my $date_str;
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime $file_info[9];

	#print $sec, " ", $min, " ", $hour, " ", $day, " ", $mon, " ", $year, "\n";

	$date_str = 1900+$year;
	$mon += 1;
	if($mon < 10) {
		$date_str = $date_str."0".$mon;
	}
	else {
		$date_str = $date_str.$mon;
	}
	
	if($day < 10) {
		$date_str = $date_str."0".$day;
	}
	else {
		$date_str = $date_str.$day;
	}

	return $date_str;
}