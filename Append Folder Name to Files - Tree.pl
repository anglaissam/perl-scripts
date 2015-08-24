#!/usr/bin/perl -w
#==============================================================================
# Open Directory and read in each file
#==============================================================================
sub tree;
$program = substr($0, (rindex($0,"\\"))+1);		#Grabs script name.
if (defined($ARGV[0]) && $ARGV[0] ne "") { $dir = $ARGV[0] }
else { $dir = substr($0, 0, (rindex($0,"\\"))+1); }	#Grabs Script Directory
if ($dir !~ m/\\$/i) { $dir = $dir . "\\"; }
#--------------------------------------------------------------------------------------------------------------------------------------------
print "Processing Directory Tree for: $dir\n";

&tree($dir);

exit (0);
#--------------------------------------------------------------------------------------------------------------------------------------------
sub tree {
    local @thefiles;
    local $dir1 = $_[0];
    $_ = $dir1;
    m/^.*\\([^\\]+)\\?$/i;
    local $folder = $1;
    opendir(DIR, "$dir1") || die("Cannot open directory: $dir1");
    @thefiles= readdir(DIR);
    closedir(DIR);

    chdir($dir1);

    print "Processing: $dir1\n";
    foreach (@thefiles) {
        unless ( ($_ eq ".") || ($_ eq "..") || ($_ eq $program) || ($_ eq "Thumbs.db") ) {
            if (-d "$dir1/$_") {
                &tree($dir1 . "$_\\");
            }
            else { system("rename","$_","$folder-$_"); }
        }
    }
   return;
}
#--------------------------------------------------------------------------------------------------------------------------------------------