#!/usr/bin/perl -w
#===============================================================================================================================
# Open Directory and read in each file
#===============================================================================================================================
sub tree;
$program = substr($0, (rindex($0,"\\"))+1);		#Grabs script name.
if (defined($ARGV[0]) && $ARGV[0] ne "") { $dir = $ARGV[0] }
else { $dir = substr($0, 0, (rindex($0,"\\"))+1); }	#Grabs Script Directory
if ($dir !~ m/\\$/i) { $dir = $dir . "\\"; }
#--------------------------------------------------------------------------------------------------------------------------------------------
$count = 0;
$_ = $dir;
m/^.*\\([^\\]+)\\?$/i;
$folder = $1;

opendir(DIR, "$dir") || die("Cannot open directory: $dir");
@foldercontent= readdir(DIR);
closedir(DIR);

foreach (@foldercontent) {
    unless ( ($_ eq ".") || ($_ eq "..") || ($_ eq $program) ) {
        if (-d "$dir/$_") { }
        else { 
            $count++;
            m/.*(\.\w+)$/i;
            print "Renaming: $_\n";
            $string = sprintf ("%s\_%05d%s", $folder, $count, $1);
            system("rename","$_","$string");
        }
    }
}

exit (0);