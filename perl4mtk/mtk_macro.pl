#!/usr/bin/perl -w

#
# Author: lirux
# Description: 检查mtk feature phone定义的宏生成头文件
# 

#use Switch;
use Cwd;
use strict;

#system("cls");
my $currentPath = GetCurrentPath();
my ($plat, $custom, $project) = ReadMakeIni();

if("" eq $custom)
{
	exit;
}

my $featuresLog = "build\\".$custom."\\log\\MMI_features.log";
unless(-e $featuresLog)
{
	print $featuresLog, " not exist!!!\n";
	#exit;
}

my $ver_file_path = "make\\Verno_".$custom.".bld";
(-e $ver_file_path) or die "$ver_file_path not exist!\n";
my $verno = ReadVernoFile($ver_file_path);

my $macro_out = "..\\MacroCustom.h";
if(-e $macro_out)
{
	system("del $macro_out");
}
open(MACRO_OUT, ">$macro_out");

my $dateTime = GetDateTime();
print MACRO_OUT "/***********************************************************\n";
print MACRO_OUT "* Custom: $custom\n";
print MACRO_OUT "* Verno : $verno\n";
print MACRO_OUT "* Date  : $dateTime\n";
print MACRO_OUT "***********************************************************/\n";
print MACRO_OUT "\n";

if (-e $featuresLog)
{
	print MACRO_OUT "/***********************************************************\n";
	print MACRO_OUT "* Macor define in MMI_features.log\n";
	print MACRO_OUT "***********************************************************/\n";
	my @featuresMacro = ReadFeaturesLog($featuresLog);
	foreach(@featuresMacro)
	{
		#print MACRO_OUT "#define ", $_, "\n";
	}
	print MACRO_OUT "\n\n"
}

my @targetMacro;

if(-e ".\\plutommi\\mmi\\TargetOption.txt")
{
print MACRO_OUT "/***********************************************************\n";
print MACRO_OUT "* Macor define in TargetOption.txt\n";
print MACRO_OUT "***********************************************************/\n";
	@targetMacro = ReadTargetOption();
}
else
{
print MACRO_OUT "/***********************************************************\n";
print MACRO_OUT "* Macor define in custom_option.txt\n";
print MACRO_OUT "***********************************************************/\n";
	@targetMacro = ReadCustomOption();
}

foreach(@targetMacro)
{
	my $out = $_;
	$out =~ s/=/    /;
	print MACRO_OUT "#define ", $out, "\n";
}

close MACRO_OUT;
##################################################
#sub begin
##################################################
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

sub GetCurrentPath {
	my $path = getcwd();
	$path =~ s/\//\\/g;
	#print $path, "\n";
	return $path;
}

sub ReadFeaturesLog {
	my $log = $_[0];
	my @macro_array;
	
	if(-e $log)
	{
		open (LOG_HANDLE, "<$log");
		while(<LOG_HANDLE>)
		{
			my $line = $_;
			if("[D]" eq substr($_, 0, 3))
			{
				$line =~ s/\[D\]/\#define/g;
				print MACRO_OUT $line;

				my @array = split(/ /, $_);
				#print $array[1], "\n";
				if("" ne $array[1])
				{
					push @macro_array, $array[1];
				}
			}
		}
		close LOG_HANDLE;
	}
	
	return @macro_array;
}

sub ReadTargetOption {
	my $file = ".\\plutommi\\mmi\\TargetOption.txt";
	my @macro_array;
	
	if(-e $file)
	{
		open (FILE_HANDLE, "<$file");
		while(<FILE_HANDLE>)
		{
			my @array = split(/\/D/, $_);
			foreach my $macro (@array)
			{
				$macro =~ s/ |"//g;
				if("" ne $macro)
				{
					#print $macro, "\n";
					push @macro_array, $macro;
				}
			}
		}
		close FILE_HANDLE;
	}
	
	return @macro_array;
}

sub ReadCustomOption {
	my $file = ".\\tools\\NVRAMStatistic\\include\\custom_option.txt";
	my @macro_array;
	
	if(-e $file)
	{
		open (FILE_HANDLE, "<$file");
		while(<FILE_HANDLE>)
		{
			my @array = split(/-D/, $_);
			foreach my $macro (@array)
			{
				$macro =~ s/ |"//g;
				if("" ne $macro)
				{
					#print $macro, "\n";
					push @macro_array, $macro;
				}
			}
		}
		close FILE_HANDLE;
	}
	
	return @macro_array;
}

sub ReadVernoFile {
	my $verFile = $_[0];
    my $verno = "";
    if (-e $verFile) 
    {
        open (FILE_HANDLE, "<$verFile");
        #print <FILE_HANDLE>;
        while (<FILE_HANDLE>) {
            if (/^(\S+)\s*=\s*(\S+)/) {
                #print("1=$1, 2=$2\n");
                if($1 eq "VERNO") {
                    $verno = $2; 
                }
            }
        }
        close FILE_HANDLE;
    }
    
    return $verno;
}

sub GetDateTime {
	my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime(time());
	my $dtStr = "";

	$year += 1900;
	$mon += 1;
	if(length($mon) == 1)
	{
		$mon = "0".$mon;
	}
	if(length($day) == 1)
	{
		$day = "0".$day;
	}
	if(length($hour) == 1)
	{
		$hour = "0".$hour;
	}
	if(length($min) == 1)
	{
		$min = "0".$min;
	}
	
	$dtStr = "$year/$mon/$day $hour:$min";
	return $dtStr;
}