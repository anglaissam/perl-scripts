#!/usr/bin/perl -w
use File::Basename qw(dirname basename);

$path = '';
$f = '';
$dir = '';

if (defined($ARGV[0]) && $ARGV[0] ne '') { $path = shift(@ARGV); }
else { $path = dirname($0); }

if ($path =~ /\.html?$/i) {
    $dir = dirname($path);
    $f = basename($path);
}
else { $dir = $path; }

$dir =~ s/\//\\/ig;
if ($dir !~ /\\$/i) { $dir = $dir . "\\"; }
#===============================================================================================================================
    # Open Directory and read in each file
#===============================================================================================================================
$count = 0;
$totalwc = 0;
$fout = "C:\\Users\\Admin\\AppData\\Local\\Temp\\Word Count.txt"; #Place txt into %temp% folder
$HTMLcount = 0;
$HTMLflag = 'false';

if ($f ne '') { $htmlfiles[0] = $f; } #ARG1 for specific file.
else {
    opendir(DIR, $dir) || die("Cannot open directory");
    @htmlfiles = grep /\.html?$/i, readdir(DIR);
    closedir(DIR);
}

foreach $f (@htmlfiles) { if ($f =~ m/\.HTML$/) { $HTMLflag = "true"; } }
$HTMLcount = scalar(@htmlfiles);
if ($HTMLcount > 0) {
    open (OUT, ">$fout") or die "Can't open $fout: $!\n";
    
    foreach $f (@htmlfiles) {
        chomp($f);
        open (IN, "<$dir$f") or die "Can't open $dir$f: $!\n";
        local $/;
        $lines = <IN>;
        close IN;
        
        $_ = $lines;
        s/(<STYLE TYPE=\"text\/css\">)/$1\n body \{\n  background-color: black;\n }/is;
        s/\n\<SCRIPT TYPE="text\/javascript"\>.*?\<\/SCRIPT\>\n//is;
        s/\<FORM NAME="colors".*?\<HR\>\n//is;
        s/^.*?\<Body\>//isg;
        s/(\<(\/?[^\>]+)\>)//sgi while ($_ =~ m/(\<(\/?[^\>]+)\>)/i);
        @words = split(/\s+/);
        foreach (@words) { $count++; }
        $totalwc = $totalwc + $count;
        print OUT "$f\t$count\n";
        
        $count=0;
    }
    print OUT "\nTotal Word Count = $totalwc\n";
    close OUT;
    if ($HTMLflag eq "true") { system("rename", "*.HTML", "*.html"); }
    system("start /B \"Process 1\" \"$fout\"");
}
else { print "No HTML files found in directory. Closing window in 2 seconds.\n\n"; sleep(2); }
exit(0);