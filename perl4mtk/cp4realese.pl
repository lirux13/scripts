#!/usr/bin/perl -w
# -*- coding: utf-8 -*-

#
# Author     : lirux
# Date       : 2014
# Description: 打包bin文件
# 

use strict;
use warnings;

my $target_path = "E:\\Allproj";
my %macro_list;
my %make_ini_list;
my %verno_list;

my $cp_type = "DEFAULT";

unless(-e "build") {
	die("Connot find build!!!!!\n\n");
}

if(@ARGV > 0) {
	$cp_type = uc($ARGV[0]);
	if($cp_type eq "L") {
		$cp_type = "LESS"
	}
	elsif($cp_type eq "M") {
		$cp_type = "MORE"
	}
}

&read_make_ini;
my $custom = $make_ini_list{"custom"};
my $project = $make_ini_list{"project"};
die "找不到编译记录" unless (defined $custom && defined $project);

&read_custom_make($custom, $project);
my $paltform = $macro_list{'PLATFORM'};
my $chip_ver = $macro_list{'CHIP_VER'};
my $sub_borad_ver = $macro_list{'SUB_BOARD_VER'};

print "\n\n";

my $custom_build = "build\\$custom";
unless (-e $custom_build) {
	die("文件不存在: $custom_build!!!!!\n");
}

my $verno_file = "make\\verno_$custom\.bld";
unless (-e "$verno_file") {
	die("文件不存在: $verno_file!!!!!\n");
}
&read_verno_file($verno_file);
my $verno = $verno_list{'VERNO'};

$verno =~ s/\./_/g;
#MX215_D_HDS_A7_YT_PCB01_gprs_MT6260_S00.V1_00_00_M140516.bin
my $bin = $custom."_".$sub_borad_ver."_".$project."_".$paltform."_".$chip_ver.".".$verno.".bin";

unless (-e "$custom_build\\$bin") {
	$bin = $custom."_".$sub_borad_ver."_".$project."_".$paltform."_".$chip_ver.".".$verno.".bin";
	die("文件夹不存在: $bin, 请确认编译是否成功!!!\n");
};

print "打包项目: $custom\n";
print "软件版本号: $verno\n";

#目标路径
my $date_time = &get_date_time;
if($cp_type eq "LESS") {
	$target_path = $target_path."\\".$custom."\\"."$custom\_$date_time\_LESS";
}
else {
	$target_path = $target_path."\\".$custom."\\"."$custom\_$date_time";
}
my $target_path_info = $target_path."\\info";

print "-----------------------------------------------\n\n";
if(-e $target_path) {
	die "文件夹已存在: $custom\_$date_time\n\n";
}
else {
	print "正在复制文件...\n";
}

opendir (BUILD_HDL, $custom_build) || die "Error in opening dir $custom_build\n";
my @file_list = readdir(BUILD_HDL);
close(BUILD_HDL);

foreach my $file (@file_list) {
	my $copy_flag = 0;

	next unless $file =~ m/$custom/;

	my $file_path = $custom_build."\\$file";
	if($file =~ m/BOOTLOADER/ || $file =~ m/^DbgInfo/) {
		if($file =~ m/\.bin$/) {
			$copy_flag = 0;
		}
		#elsif($file =~ m/$verno/) {
		#	$copy_flag = 1;
		#}
	}
	elsif(-d $file_path && $file =~ m/$verno/) {
		$copy_flag = 1;
	}
	elsif($file =~ m/\.elf$/ || $file =~ m/\.lis$/ || $file =~ m/\.sym$/) {
		$copy_flag = 1;
	}
	
	if(1 == $copy_flag) {
		#print "$file\n";
		if(-d $file_path) {
			print "$file\n";
			opendir (BIN_HDL, $file_path) || die "Error in opening dir $file_path\n";
			my @bin_file = readdir(BIN_HDL);
			close(BIN_HDL);

			$file =~ s/\.$verno//;
			my $out_path = "$target_path\\$file";
			
			foreach my $bin (@bin_file) {
				my $bin_path = $file_path."\\$bin";
				if(-d $bin_path) {
					unless ("." eq $bin || ".." eq $bin || "LESS" eq $cp_type) {
						&sys_copy($bin_path, $out_path."\\$bin");
					}
				}
				else {
					&sys_copy($bin_path, $out_path);
				}
			}
		}
		elsif("LESS" ne $cp_type){
			print "$file\n";
			&sys_copy($file_path, $target_path_info);
		}
	}
}

#复制其他文件
my $file_path = "$custom_build\\log\\ckImgSize.log";
print "ckImgSize.log\n";
&sys_copy($file_path, $target_path_info);

print "BPLGUInfoCustomAppSrcP_$paltform\_$chip_ver\_$verno\n";
if("GSM" eq $project) {
	$file_path = "tst\\database\\BPLGUInfoCustomAppSrcP_*_$verno";
}
else {
	$file_path = "tst\\database_classb\\BPLGUInfoCustomAppSrcP_*_$verno";
}

&sys_copy($file_path, $target_path_info);

if($cp_type eq "MORE") {
	my $target_path_more = $target_path."\\more";
	print "MMI_features_switch.h\n";
	$file_path = "$custom_build\\MMI_features_switch.h";
	&sys_copy($file_path, $target_path_more);
	print "$custom\_$project\.mak\n";
	$file_path = "$custom_build\\$custom\_$project\.mak";
	&sys_copy($file_path, $target_path_more);
}
print "Copy done...\n";
print "-----------------------------------------------\n";

&read_log_ckImgSize($target_path);

my $zip_7za = "plutommi\\Customer\\ResGenerator\\7za.exe";
my $target_zip = $target_path.".zip";

if(-e $zip_7za) {
	print "Compressing...";
	#system("start /min $zip_7za a -tzip $target_zip $target_path");
	system("start $zip_7za a -tzip $target_zip $target_path");
}

my $file_size = 0;
my @file_info;
$file_info[7] = 0;

do {
	$file_size = $file_info[7];
	&delay_seconds("3");
	@file_info = stat($target_zip);
}while($file_size != $file_info[7]);
print "\n";

if(-e $target_zip) {
	system("explorer /e,/select,$target_zip");
}
else {
	system("explorer /e,/select,$target_path");
}


######################################################################
######################################################################
sub sys_copy {
	my $src = $_[0];
	my $dst = $_[1];

	unless(-e $dst) {
		system("md $dst");
	}

	system("copy $src $dst > null");
}

sub read_make_ini {
	my $ini = ".\\make.ini";
    #if (-e $ini) {
    	#print "Read file: $ini\n";
      	open (FILE_HANDLE, "<$ini") or die "cannot open $ini\n";
      	while (<FILE_HANDLE>) {
	        if (/^(\S+)\s*=\s*(\S+)/) {
				my $keyname = lc($1);
		     	$make_ini_list{$keyname} = uc($2);
	        }
      	}
      	close FILE_HANDLE;
    #}
}

sub read_verno_file {
	my $verno_bld = $_[0];
  	open (FILE_HANDLE, "<$verno_bld") or die "Cannot open $verno_bld\n";
  	while (<FILE_HANDLE>) {
    	if (/^(\S+)\s*=\s*(\S+)/) {
      	my $keyname = uc($1);
      	if(defined($${keyname}) && $${keyname} ne ""){
        	next;
      	}

      	$verno_list{$keyname} = uc($2);
    	}
  	}
  	close FILE_HANDLE;
}

sub get_date_time() {
	#my ($week, $mon, $day, $ht, $year) = split(" ", localtime(time()));
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime(time());
	my $date_str = "";

	#$year += 1900;
	$date_str = 1900+$year; #substr($year, 1, 2);
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

sub read_custom_make {
	(2 == @_) or die "Error para!!!";

	my $mak = ".\\make\\$_[0]_$_[1].mak";

    if (-e $mak) {
      open (FILE_HANDLE, "<$mak") or die "cannot open $mak\n";
      while (<FILE_HANDLE>) {

        if (/^(\S+)\s*=\s*(\S+)/) {
          my $keyname = uc($1); 
          my $keyvalue = uc($2);
          
          $macro_list{$keyname} = $keyvalue;
        }
      }

      close FILE_HANDLE;
    }
}

sub read_log_ckImgSize {
	my $log_file = $_[0]."\\info\\ckImgSize.log";
	my $max_size = 0;
	my $actual_size = 0;
	
    if (-e $log_file) {
    	print "\n";
      	open (FILE_HANDLE, "<$log_file") or die "cannot open $log_file\n";
      	while (<FILE_HANDLE>) {
	        if($_ =~ m/The\ Boundary/ || $_ =~ m/Actual\ VIVA/) {
	        	my $line = $_;
	        	chomp($line);		
				$line =~ s/[a-z,A-Z,\ ,=]//g;
				
				if($_ =~ m/The\ Boundary/) {
					$max_size = $line;
				}
				elsif($_ =~ m/Actual\ VIVA/) {
					$actual_size = $line;
					last;
				}
	        }
      	}
      	close FILE_HANDLE;

      	print "The Boundary of VIVA bin = $max_size bytes\n";
		print "Actual VIVA End Address  = $actual_size bytes\n";

		my $remain = ($max_size - $actual_size)/1024;
		
		my $len = length($remain);
		my $point_index = rindex($remain, ".");
		if($len - $point_index > 2) {
			$remain = substr($remain, 0, $point_index+3);
		}
		print "Remain space: $remain KB (", $max_size - $actual_size, " bytes)\n\n";
    }
}

sub delay_seconds {
	my $delay_sec = $_[0];
	my $sec_first = time();
	my $sec = $sec_first;

	while(($sec - $sec_first) < $delay_sec) {
		$sec = time();
	}
	
	print ".";
}