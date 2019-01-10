#!/usr/local/bin/perl

use warnings;
use strict;

my @argv;

foreach(@ARGV) {
	push(@argv, lc($_));
}

my ($custom, $project) = ("", "");
if(1 == @argv && $argv[0] eq "new") {
	&read_make_ini;
}
elsif (3 == @argv && $argv[2] eq "new") {
	$custom = $argv[0];
	$project = $argv[1];
}


if("" eq $custom || "" eq $project) {
	exit(0);
}
print "custom = $custom; project = $project\n";

my ($DWS_CUSTOM, $AUDIO_PARA_CUSTOM);
if("" ne $project && "" ne $custom) {
	&read_custom_make($custom, $project);
}

if("" ne $project && "" ne $custom) {
	&copy_cutom_file;
}

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
		#$keyname = $1;
		#$${keyname} = $2;
          my $keyname = uc($1);  
          if($keyname eq "DWS_CUSTOM") {
			$DWS_CUSTOM = uc($2);
          }
          elsif($keyname eq "AUDIO_PARA_CUSTOM") {
			$AUDIO_PARA_CUSTOM = uc($2);
          }
        }
      }
      close FILE_HANDLE;
    }

    print "  DWS_CUSTOM = $DWS_CUSTOM\n";
    print "  AUDIO_PARA_CUSTOM = $AUDIO_PARA_CUSTOM\n";
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
	&system_copy_file("$dws_file", ".\\custom\\codegen\\$target");
	&system_copy_file("$aud_common_config", ".\\custom\\common\\hal");
	&system_copy_file("$nvram_default_audio", ".\\custom\\audio\\$target");
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
	(-e $_[0]) or die "Cannot find $_[0]\n";
	(-e $_[1]) or die "Cannot find $_[1]\n";

	my $copy_cmd = "copy /y $_[0] $_[1]";
	print "  $copy_cmd\n";
	system("$copy_cmd > nul");
}
