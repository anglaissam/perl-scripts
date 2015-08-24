#!/usr/bin/perl -w
if (defined($ARGV[0]) && $ARGV[0] ne "") {
    $f="";
    $dir = $ARGV[0];
    chomp($dir);
    if ($dir =~ /^\w:\//) {
        $_ = $dir;
        s/\//\\/ig;
        $dir = $_;
    }
    if ($dir =~ /.*\.htm$|\.html$/) {
        $f = substr($dir, (rindex($dir,"\\"))+1,);
        $dir = substr($dir, 0, (rindex($dir,"\\"))+1);
    }
}
else {
    $dir = substr($0, 0, (rindex($0,"\\"))+1);
}    # $dir. If no directory is given, defaults is directory script is placed in.
if ($dir !~ /\\$/i) { $dir = $dir . "\\"; }
#====================================================================================================================================
# Open Directory and read in each file
#====================================================================================================================================
opendir(DIR, $dir) || die("Cannot open directory $dir");
if (defined($ARGV[0]) && $f ne "") { $thefiles[0] = $f; } #ARG1 for specific file.
else {
    @thefiles = readdir(DIR);
    closedir(DIR);
}

$HTMLflag = "false";

foreach $f (@thefiles) {
    if ($f =~ m/\.HTML$/) { $HTMLflag = "true"; }
    if ($f =~ m/\.html?$/i) {
        chomp($f);
        print "Tidying $f\n";
        system("C:/Program Files/Tidy/tidy", "-o", "$dir$f", "-config", "C:/Program Files/Tidy/config.txt", "$dir$f");
    }
}
if ($HTMLflag eq "true") { system("rename", "*.HTML", "*.html"); }
exit(0);