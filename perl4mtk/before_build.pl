#!/usr/local/bin/perl

use warnings;
use strict;

my @argv;
my $is_valid_cmd = "FALSE";
my $del_build = "FALSE";
my %macro_list;

foreach my $tmp (@ARGV) {
	$tmp = lc($tmp);
	push(@argv, $tmp);
	if("new" eq $tmp || "c" eq $tmp) {
		$is_valid_cmd = "TRUE";
		$del_build = "TRUE";
	}
	elsif("resgen" eq $tmp) {
		$is_valid_cmd = "TRUE";
	}
}

if("TRUE" ne $is_valid_cmd) {
	print "Do nothing...\n";
	exit(0);
}

my ($custom, $project) = ("", "");
if(1 == @argv) {
	&read_make_ini;
}
elsif (3 == @argv) {
	$custom = $argv[0];
	$project = $argv[1];
}
else {
	exit(0);
}

if("" eq $custom || "" eq $project) {
	exit(0);
}
print "custom = $custom; project = $project\n";

unless (-e "make\\$custom\_$project.mak") {
	print "$custom\_$project.mak not exist!\n";
	exit(0);
}

my ($DWS_CUSTOM, $AUDIO_PARA_CUSTOM);
my $THEME_TYPE;
my $MAIN_LCD_SIZE;

&read_custom_make($custom, $project);
if($del_build eq "TRUE") {
	&delete_build;
	&delete_files;
}
&delete_files_resource;
&copy_cutom_file;


print "==============================================\n\n";

######################################################################
######################################################################
sub read_make_ini {
	my $ini = ".\\make.ini";
    if (($project eq "") && (-e $ini)) {
    	#print "Read file: $ini\n";
      	open (FILE_HANDLE, "<$ini") or die "cannot open $ini\n";
      	while (<FILE_HANDLE>) {
	        if (/^(\S+)\s*=\s*(\S+)/) {
				my $keyname = lc($1);  
		    	if($keyname eq "custom") {
					$custom = uc($2);
		      	}
		       	elsif($keyname eq "project") {
					$project = uc($2);
		     	}
	        }
      	}
      	close FILE_HANDLE;
    }

    #print "custom=$custom; project=$project\n";
}

sub read_custom_make {
	(2 == @_) or die "参数错误，请输入项目名";

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

		$DWS_CUSTOM = $macro_list{'DWS_CUSTOM'};
		$AUDIO_PARA_CUSTOM = $macro_list{'AUDIO_PARA_CUSTOM'};
		$THEME_TYPE = $macro_list{'THEME_TYPE'};
		$MAIN_LCD_SIZE = $macro_list{'MAIN_LCD_SIZE'};
      
      close FILE_HANDLE;
    }
}

sub copy_cutom_file {
	my $custom_60x = ".\\custom\\drv_custom";
	my $dws_file;
	my $aud_common_config;
	my $nvram_default_audio;
	
	if(-e $custom_60x) {
		$dws_file = "$custom_60x\\$DWS_CUSTOM\\codegen\\codegen.dws";
		$aud_common_config = "$custom_60x\\$AUDIO_PARA_CUSTOM\\audio\\aud_common_config.h";
		$nvram_default_audio = "$custom_60x\\$AUDIO_PARA_CUSTOM\\audio\\nvram_default_audio.c";
	} else {
		$dws_file = ".\\custom\\codegen\\$DWS_CUSTOM\\codegen.dws";
		$aud_common_config = ".\\custom\\audio_par_custom\\$AUDIO_PARA_CUSTOM\\aud_common_config.h";
		$nvram_default_audio = ".\\custom\\audio_par_custom\\$AUDIO_PARA_CUSTOM\\nvram_default_audio.c";
	}

	my $target = &find_target_folder;

	print "\n复制客制化文件...\n";
	&system_copy_file($dws_file, ".\\custom\\codegen\\$target");
	&system_copy_file($aud_common_config, ".\\custom\\common\\hal");
	&system_copy_file($nvram_default_audio, ".\\custom\\audio\\$target");

	my $theme_src = "plutommi\\Customer\\LcdResource\\MainLcd$MAIN_LCD_SIZE\\$THEME_TYPE\\*.*";
	&system_copy_file($theme_src, "plutommi\\Customer\\CustResource\\PLUTO_MMI");
	&system_copy_file($theme_src, "plutommi\\Customer\\CustResource");
	
	print "\n";
}

#复制到哪个文件夹
sub find_target_folder {
	my $path = ".\\custom\\audio";
	my $target = "";
	opendir(HDL_FOLDER, "$path") or die "Cannot open $path\n";
	my @all_folders = readdir HDL_FOLDER;
	close HDL_FOLDER;

	if(0 == @all_folders) {
		die "$path do not have target!!!!!!\n"
	} elsif (1 == @all_folders) {
		$target = $all_folders[0];
	} else {
		foreach my $folder(@all_folders) {
			#next unless -d $folder;
			if($folder=~/^BIRD/ || $folder=~/^LEGEND/) {
				$target = $folder;
			}
		}
	}
	#print "target = $target\n";
	return $target;
}

sub find_source_verno {
	my $src = ".";
	my $verno = "";
	opendir(SRC_FOLDER, "$src") or die "Cannot open dir\n";
	foreach my $file(readdir SRC_FOLDER) {
		next if -d $file;
		next unless $file=~/\.txt$/;
		next unless $file=~/^MAUI\./;
		$file =~ s/\.txt$//;
		$file =~ s/^MAUI\.//;
		$file =~ s/\./_/g;
		$verno = $file;
	}
	close SRC_FOLDER;

	return $verno;
}


sub system_copy_file {
	#(-e $_[0]) or die "Cannot find $_[0]\n";
	(-e $_[1]) or die "Cannot find $_[1]\n";

	my $copy_cmd = "copy /y $_[0] $_[1]";
	print "  $copy_cmd\n";
	system("$copy_cmd > nul");
}


sub delete_build {
	my $dir = "build\\$custom";
	
	if(-e $dir) {
		print "删除build目录....\n";
		print "\t delete $dir";
		my $cmd = "del $dir /s /q /f";
		#print "  $cmd\n";
		system("$cmd > nul");
		$cmd = "rmdir $dir /s /q";
		#print "  $cmd\n";
		system("$cmd > nul");
	}
}

sub system_delete_folder {
	my $folder = $_[0];
	my @cmd_array;

	if(-e $folder && -d $folder) {
		push(@cmd_array, "del $folder /s /q /f");
		push(@cmd_array, "rmdir $folder /s /q");
	}

	print "\t delete $folder\n";
	foreach my $cmd(@cmd_array) {
		system("$cmd > nul");
	}
}

sub delete_files_resource {
	my @file_list = (
		"plutommi\\Customer\\res_MiscFramework.c",
		"plutommi\\Customer\\CustResource\\custimg*.c",
		"plutommi\\Customer\\CustResource\\resource_*_skins.c",
		"plutommi\\Customer\\CustResource\\custadomapext.c",
		"plutommi\\Customer\\Res_MMI_XML\\*",
		"plutommi\\Customer\\ResGenerator\\temp\\*",
		"plutommi\\Customer\\ResGenerator\\debug\\*",
		"plutommi\\Customer\\ResGenerator\\str*.bin",
		"plutommi\\Customer\\ResGenerator\\str*.compress",
		"plutommi\\Customer\\ResGenerator\\OfflineResGenerator\\lib\\common\\*.o",
		"plutommi\\Customer\\ResGenerator\\ResgenCore\\lib\\common\\*.o",
		"plutommi\\Customer\\ResGenerator\\ResgenLog\\lib\\common\\*.o",
		"plutommi\\Customer\\ResGenerator\\font_gen.exe",
		"plutommi\\Customer\\ResGenerator\\resgen_xml.exe",
		"plutommi\\Customer\\ResGenerator\\plmncreate.exe",
		"plutommi\\Customer\\ResGenerator\\ref_list_merge.exe",
		"plutommi\\Customer\\ResGenerator\\mtk_resgenerator.exe",
		"plutommi\\Customer\\CustomerInc\\mmi_rp_*.h",
		"plutommi\\Customer\\CustResource\\CustAdo*",
		"plutommi\\Customer\\CustResource\\CustFont*",
		"plutommi\\Customer\\CustResource\\CustImg*",
		"plutommi\\Customer\\CustResource\\CustMenu*",
		"plutommi\\Customer\\CustResource\\CustStr*",
	);
	
	print "\n删除其它文件....\n";
	foreach my $file(@file_list) {
		system("del $file /q /f");
	}
}


sub delete_files {
	my @file_list = (
		"*.cmm",
		"~*.c",
		"pl_lib_size\\*",
		"header_temp\\*",
		"custom\\system\\LEGEND60M_CN_11C_BB\\custom_scatstruct_fota.c",
	);
	
	print "\n删除其它文件....\n";
	foreach my $file(@file_list) {
		system("del $file /q /f");
	}
}

sub delete_files2 {
	my @file_list = (
		"custom\\audio\\*.c",
		#codegen生成的文件
		"custom\\codegen\\*.c",
		"custom\\codegen\\*.h"
	);
	
	print "\n删除其它文件....\n";
	foreach my $file(@file_list) {
		system("del $file /s /q /f");
	}
}

