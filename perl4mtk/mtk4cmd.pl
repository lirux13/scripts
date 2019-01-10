#!/usr/bin/perl -w

########################################################
#by lirux
#@2014-05-15
#file name: mtk4si.pl
########################################################

use strict;
use warnings;

my %macro_list;
my $target_mak = "";
my ($plat, $custom, $project) = ("", "", "GPRS");

if(@ARGV > 0) {
	$custom = uc($ARGV[0]);
}

if(@ARGV > 1) {
	$project = uc($ARGV[1]);
}

if("" eq $custom) {
	($plat, $custom, $project) = &ReadMakeIni();
	$target_mak = "make\\"."$custom\_$project\.mak";
}

unless(-e $target_mak) {
	die "指定的mak文件不存在: $target_mak\n\n";
}

&read_custom_make($target_mak);
my $lcd_size = $macro_list{'MAIN_LCD_SIZE'};
my $theme = $macro_list{'THEME_TYPE'};


my @cmd_array = (
	"EXIT",
	"IMAGE_TYPE",
	"AUDIO_TYPE",
	"THEME_TYPE",
	"DWS_CUSTOM",
	"AUDIO_PARA_CUSTOM",
);

system("cls");

while(1) {
	my @seq = ("A", "B", "C", "D", "E");
	my $idx = 0;
	system("CLS");

	print "custom = $custom, project = $project\n";
	
	foreach my $cmd (@cmd_array) {
		$idx++;
		if($idx == @cmd_array) {
			$idx = 0;
		}
		print "    $idx\. $cmd_array[$idx]\n";
	}
	print "==============================\n";
	print "请选择命令:";
	
	my $sel = <STDIN>;
	$sel =~ s/\n//;
	$sel = uc($sel);

	my $tmp = $sel;
	$tmp =~ s/[0-9]//g;
	if("" eq $tmp) {
		if($sel < @cmd_array) {
			$sel = $cmd_array[$sel];
		}
	}

	print "($sel)\n";
	if("IMAGE_TYPE" eq $sel) {
		
	}
	elsif("THEME_TYPE" eq $sel) {
		my $path = "plutommi\\Customer\\LcdResource";
		&sys_explorer("$path\\MainLcd$lcd_size\\$theme");
	}
	elsif("EXIT" eq $sel) {
		exit(0);
	}
	else {
		print "无效命令!\n"	
	}
	system("PAUSE");
}




########################################################
# sub
########################################################
sub read_custom_make {
	die "参数错误" if(1 != @_);
	my $mak = $_[0];

    open (FILE_HANDLE, "<$mak") or die "Can not open $mak\n";
    while (<FILE_HANDLE>) {
        if (/^(\S+)\s*=\s*(\S+)/) {
            my $keyname = uc($1); 
            my $keyvalue = uc($2);
			$macro_list{$keyname} = $keyvalue;
        }
    }

    close FILE_HANDLE;
}

sub ReadMakeIni {
    my ($plat, $custom, $project);
    if (-e "make.ini") 
    {
        open (FILE_HANDLE, "<make.ini");
        #print <FILE_HANDLE>;
        while (<FILE_HANDLE>) {
            if (/^(\S+)\s*=\s*(\S+)/) {
                    #print("1=$1, 2=$2\n");
                if($1 eq "custom") {
                    $custom = $2; 
                } elsif($1 eq "project") {
                    $project = $2;
                } elsif($1 eq "plat") {
                    $plat = $2;
                }
            }
        }
        close FILE_HANDLE;
       
    }
    
    $plat = uc($plat);
    $custom = uc($custom);
    $project = uc($project);
    #print ("plat=$plat[1]; custom=$custom;  project=$project\n");
    return ($plat, $custom, $project);
}

sub sys_explorer {
	my $cmd = "explorer $_[0]";
	system("$cmd");
}