#!/usr/bin/perl -w

#Date :2014/08/06
#Author: lirux
#File Name: go_to_custom_info.pl

use strict;
use warnings;

########################################################################
my $path = "D:\\我的资料库\\项目信息";
my $file_name = $ARGV[0];
my $idx = rindex($file_name, "\\") + 1;
my $temp = substr($file_name, $idx);
$idx = index($temp, "_");
my $custom = substr($temp, 0, $idx);

my $info_path = $path."\\功能机\\".$custom."客户";

$temp = substr($temp, $idx+1);
if(substr($temp, 1, 1) eq "_") {
	$temp = substr($temp, 2);
}
$idx = index($temp, "_");
if($idx > (length($temp) - 4)) {
	exit(0);
}
$temp = substr($temp, 0, $idx);

if(-e "$info_path\\$temp") {
	$info_path = "$info_path\\$temp";
}
else {
	if($temp eq "BL" || $temp eq "PL") {
		$temp = "菠萝";
	}
	elsif($temp eq "FD") {
		$temp = "富大";
	}
	elsif($temp eq "AUX") {
		$temp = "奥克斯";
	}
	elsif($temp eq "NEWCALL") {
		$temp = "赛博";
	}
	elsif($temp eq "JY") {
		$temp = "九原";
	}

	if(-e "$info_path\\$temp") {
		$info_path = "$info_path\\$temp";
	}
}

print $info_path, "\n";

if(-e $info_path) {
	system("explorer /e, $info_path");
}


########################################################################
#sub begin
########################################################################

sub go_to_custom_info {

}