#!/usr/bin/perl -w
use File::Basename qw(dirname basename);

$path = '';
$f = '';
$dir = '';
@thefiles;

if (defined($ARGV[0]) && $ARGV[0] ne '') { $path = shift(@ARGV); }
else { $path = dirname($0); }

if ($path =~ /\.html?$/i) {
    $dir = dirname($path);
    $f = basename($path);
}
else { $dir = $path; }

$dir =~ s/\//\\/ig;
if ($dir !~ /\\$/i) { $dir = $dir . "\\"; }

chdir("$dir");
#-----------------------------------------------------------------------------------------------
opendir(DIR, $dir) || die("Cannot open directory $dir");
if (defined($ARGV[0]) && $f ne "") { $thefiles[0] = $f; } #ARG1 for specific file.
else {
    @thefiles = readdir(DIR);
    closedir(DIR);
}
foreach $f (@thefiles) {
    if ( ($f =~ m/\.htm$/i) || ($f =~ m/\.html$/i) ) {
        chomp($f);
        open (IN, "<$dir$f") or die "Can't open $dir$f: $!\n";
        local $/;
        $lines = <IN>;
        close IN;
        $_ = $lines;
        
        #Substitutions
        s/<P>Disclaimer:.*?<\/P>//igs;
        
        if ($_ ne $lines) {
            open (OUT, ">$dir$f") or die "Can't open $dir$f: $!\n";
            print OUT "$_";
            close OUT;
            print "$f: Changes have been made\n";
        }
    }
}
sleep(2);
exit 0;