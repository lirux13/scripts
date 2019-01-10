#!/usr/bin/perl -w

#
#by lirux @20150313
#

use strict;
use warnings;

my $debug_flag = 1;

system("cls");

&debug_print("\$ARGV[0] = $ARGV[0]");

my $file_list = $ARGV[0];

die "参数错误" unless(-e $file_list && $file_list =~ /SearchResults/);

open (FILE_HANDLE, "<$file_list") or die "Can't open $file_list\n";
my @file_buff = <FILE_HANDLE>;
close FILE_HANDLE;

my $date_str = &get_date_time;
my $patch_name = "patch-$date_str";

die "$patch_name已存在" if -e $patch_name;

mkdir $patch_name;

my @file_list;

foreach my $line (@file_buff) {
	my $idx0 = index($line, " (");
	my $idx1 = index($line, "):");

	my $file;
	my $path;
	my $full_path;

	if($idx0 != -1 && $idx1 != -1) {
		$file = substr($line, 0, $idx0);
		$idx0 += 2;
		$path = substr($line, $idx0, $idx1-$idx0);
		$full_path = $path."\\".$file;
		my $target_path = "$patch_name\\$path";
		if(-e $full_path && !(-e "$patch_name\\$full_path")) {
			mkdir $target_path;
			sys_copy($full_path, $target_path);
		}
	}
}

if(-e $patch_name) {
	system("explorer $patch_name");
}

########################################################################

########################################################################
#sub begin
########################################################################

sub debug_print {
	if(1 == $debug_flag) {
		print @_, "\n";
	}
}

sub get_date_time {
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime(time());
	my $date_str = "";

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

	#print "当前时间: $date_str $hour:$min\n";
	
	$date_str = $date_str."_";
	if($hour < 10) {
		$date_str = $date_str."0".$hour;
	}
	else {
		$date_str = $date_str.$hour;
	}

	if($min < 10) {
		$date_str = $date_str."0".$min;
	}
	else {
		$date_str = $date_str.$min;
	}

	
	return $date_str;
}

sub sys_copy {
	my $src = $_[0];
	my $dst = $_[1];

	unless(-e $dst) {
		system("md $dst");
	}

	system("copy $src $dst > null");
}