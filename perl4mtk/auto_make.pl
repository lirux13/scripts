#!/usr/bin/perl -w

use strict;
use warnings;

my $src_path = "E:\\61A_1521\\src";
my $custom = "MX276_A_AIK_F2476";
my $project = "GPRS";

print "scr = $src_path, custom = $custom, project = $project\n";
chdir("$src_path");
system("m.bat $custom $project new")

#print "scr = $src_path, custom = $custom, project = $project\n";
#$src_path = "E:\\61A\\src";
#$custom = "MX276_A_FD_VF2431";
#$project = "GPRS";
