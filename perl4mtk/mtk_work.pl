#!/usr/bin/perl -w

#Date :2014/10/31
#Author: lirux
#File Name: mtk_work.pl

use strict;
use warnings;
use Cwd;

########################################################################
my $file_name = uc($ARGV[0]);
my $CurrentPath = getcwd();
$CurrentPath =~ s/\//\\/g;
my %mak_macro_list;

system("cls");

my ($last_custom, $last_project);
my $custom_name;

if ($file_name =~ m/\.MAK/) {
	$custom_name = &get_custom_name_form_file($file_name);
} else {
	($last_custom, $last_project) = &read_make_ini;
	$file_name = $CurrentPath."\\make\\$last_custom\_$last_project\.mak";
	$file_name = uc($file_name);
	$custom_name = uc($last_custom);
	print "[$custom_name] $file_name\n";
}

my $bld_name = $CurrentPath."\\make\\Verno_".$custom_name.".bld";

if(-e $bld_name) {
	#print "$file_name\n";
	print "------------------------------------\n";
} else {
	exit;
}

&read_mtk_make($file_name);

while(1) 
{
    print "\n";
    if($custom_name eq "") {
        print "null \@ $CurrentPath:" ;
    } else {
        print "$custom_name \@ $CurrentPath:" ;
    }
    my $command = <STDIN>;
    chomp($command);

    main_proc($command);
}

########################################################################
#sub begin
########################################################################
sub main_proc {
	my $action = uc($_[0]);
	my $para = "";
	if($action =~ m/^SET/ || $action =~ m/^V/ || $action =~ m/^R/) {
		my @tmp = split "\ ", $action;
		#print "tmp = @tmp\n";
		$action = $tmp[0];
		$para = $tmp[1];
	}

	if("" ne $para) {
		print "Action = [$action], para=[$para]\n";
	} else {
		print "Action = [$action]\n";
	}
	
	if($action eq "INFO") {

		&go_to_custom_info($custom_name);

	} elsif ($action eq "MDS") {

		my $modis = ".\\MoDIS_VC9\\MoDIS.sln";
		system("start $modis");

	} elsif ($action eq "MB") {

		my $modis = ".\\MoDIS_VC9\\MoDIS\\Debug\\MoDIS.exe";
		system("start $modis");

	}elsif ($action eq "SET") {
		my $temp = $CurrentPath."\\make\\$para\_GPRS.mak";
		if(-e $temp) {
			$file_name = $temp;
			$custom_name = $para;
			unlink %mak_macro_list;
			&read_mtk_make($file_name);
		}

	}elsif ($action eq "THEME" || $action eq "T"){

		my $main_lcd_size = $mak_macro_list{MAIN_LCD_SIZE};
		my $theme_type = $mak_macro_list{THEME_TYPE};
		my $theme_path = "$CurrentPath\\plutommi\\Customer\\LcdResource\\MainLcd$main_lcd_size\\$theme_type";
		system("explorer /e, $theme_path");

	} elsif ($action eq "IMAGE" || $action eq "I" || $action eq "IZ"){

		my $main_lcd_size = $mak_macro_list{MAIN_LCD_SIZE};
		my $image_type = $mak_macro_list{IMAGE_TYPE};
		my $image_path = "$CurrentPath\\plutommi\\Customer\\Images\\PLUTO$main_lcd_size";
		my $image_file = $image_path."\\image_$image_type\.zip";

		if($action eq "IZ") {
			system("explorer /e, $image_file");
		} else {
			&system_7zip_x($image_file);
		}

	} elsif ($action eq "AUDIO" || $action eq "A" || $action eq "AZ"){

		my $audio_type = $mak_macro_list{AUDIO_TYPE};
		my $audio_path = "$CurrentPath\\plutommi\\Customer\\Audio\\PLUTO";
		my $audio_file = $audio_path."\\audio_$audio_type\.zip";

		if($action eq "AZ") {
			system("explorer /e,/select, $audio_file");
		} else {
			&system_7zip_x($audio_file);
		}
		
	} elsif ($action eq "AP"){

		my $ap = $mak_macro_list{AUDIO_PARA_CUSTOM};
		my $ap_path = "$CurrentPath\\custom\\audio_par_custom\\$ap";
		system("explorer /e, $ap_path");

	} elsif ($action eq "DWS"){

		my $dws = $mak_macro_list{DWS_CUSTOM};
		my $dws_path = "$CurrentPath\\custom\\codegen\\$dws";
		system("explorer /e, $dws_path");

	} elsif ($action eq "V"){
		my $file;
		
		if($para eq "IRU") {
			$file = "plutommi\\Customer\\ResGenerator\\debug\\image_resource_usage.htm";
		}
		
		if(defined($file) && -e $file) {
			system("start explorer $file");
		}
	} elsif ($action eq "R"){
		my $file;
		
		if($para eq "PS") {
			$file = "D:\\GreenSoft\\Adobe_Photoshop_CS5\\Photoshop.exe";
		} elsif($para eq "GEAR") {
			$file = "D:\\GreenSoft\\GIF Movie Gear\\movgear.exe"
		} elsif($para eq "GW") {
			$file = "C:\\Program Files (x86)\\GoldWave\\GoldWave.exe"
		}


		if(defined($file) && -e $file) {
			system("start $file");
		}
		
	} elsif ($action eq "LOG" || $action eq "L"){

		system("start TortoiseProc.exe /command:log  /path:$CurrentPath");

	} elsif ($action eq "MAKLOG"){

		system("start TortoiseProc.exe /command:log  /path:$file_name");

	} elsif ($action eq "UPDATE" || $action eq "U"){

		system("start TortoiseProc.exe /command:update  /path:$CurrentPath");

	} elsif ($action eq "COMMIT") {

		system("start TortoiseProc.exe /command:commit  /path:$CurrentPath");

	} 
	elsif ($action eq "EXIT" || $action eq "QUIT" || $action eq "Q"){
		exit(0);
	}

}

sub get_custom_name_form_file {
	my $file = uc($_[0]);
	my $idx = rindex($file_name, "\\") + 1;
	my $temp = substr($file_name, $idx);
	$idx = index($temp, "_");
	my $custom = substr $temp, 0, rindex($temp, "_");

	return $custom;
}

sub go_to_custom_info {
	my $path = "D:\\我的资料库\\项目信息";
	my $temp = $_[0];
	my $idx = index($temp, "_");
	my $custom = substr $temp, 0, $idx;
	my $info_path = $path."\\功能机\\$custom客户";

	print "[$custom], [$temp]\n";
	$temp = substr($temp, $idx+1);
	
	if(substr($temp, 1, 1) eq "_") {
		$temp = substr($temp, 2);
	}
	$idx = index($temp, "_");
	if($idx < 1) {
		print "1-1-1-1-1-1-1-1\n";
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
		elsif($temp eq "HSL") {
			$temp = "红石榴";
		}

		if(-e "$info_path\\$temp") {
			$info_path = "$info_path\\$temp";
		}
	}

	print $info_path, "\n";

	if(-e $info_path) {
		system("explorer /e, $info_path");
	}
}

sub read_mtk_make {
	my $mak = $_[0];
    open (FILE_HANDLE, "<$mak") or die "cannot open $mak\n";
    while (<FILE_HANDLE>) {
        #push(@mak_buff, $_);
        if (/^(\S+)\s*=\s*(\S+)/) {
            my $keyname = uc($1); 
            my $keyvalue = uc($2);
          
            $mak_macro_list{$keyname} = $keyvalue;
        }
    }

    close FILE_HANDLE;
}

sub system_7zip_x {
	my $zip_7za = "plutommi\\Customer\\ResGenerator\\7za.exe";
	my $zip_flie = $_[0];
	my $out = $zip_flie;
	$out =~ s/\.zip//g;

	unless (-e $out) {
		mkdir $out;
		system("start /min $zip_7za x $zip_flie -o$out");
	}
	if(-e $out) {
		system("explorer /e, $out");
	}
	else {
		system("explorer /e,/select, $zip_flie");
	}
}

sub read_make_ini {
	my $ini = ".\\make.ini";
	my $cst="";
	my $prj="";
	#my $dt="";

    if (-e $ini) {
		#$dt = &get_file_date($ini);
    
    	#print "Read file: $ini\n";
      	open (FILE_HANDLE, "<$ini") or die "cannot open $ini\n";
      	while (<FILE_HANDLE>) {
	        if (/^(\S+)\s*=\s*(\S+)/) {
				my $keyname = lc($1);  
		    	if($keyname eq "custom") {
					$cst = uc($2);
		      	}
		       	elsif($keyname eq "project") {
					$prj = uc($2);
		     	}
	        }
      	}
      	close FILE_HANDLE;
    }

    return ($cst, $prj);
}
