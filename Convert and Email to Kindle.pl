#!/usr/bin/perl -w
use Win32::OLE qw(in); #To check if stunnel process is running
use File::Basename qw(dirname basename);

$mobidir = "C:\\Users\\Admin\\Documents\\Mobi Converted\\";
$mobidir2 = '';
$mobihp = $mobidir . "HP\\";
$mobinaruto = $mobidir . "Naruto\\";
$mobiincompletes = $mobidir . "Incompletes\\";
$mobipartial = $mobidir . "Partial\\";
$stunnel = "C:\\Program Files\\stunnel\\stunnel.exe";

if (defined($ARGV[0]) && $ARGV[0] ne "") {
    $f="";
    $dir = $ARGV[0];
    chomp($dir);
    if ($dir =~ /^\w:\//) {
        $_ = $dir;
        s/\//\\/ig;
        $dir = $_;
    }
    if ($dir =~ /.*\.htm$|\.html$/i) {
        $f = substr($dir, (rindex($dir,"\\"))+1,);
        $dir = substr($dir, 0, (rindex($dir,"\\"))+1);
        chdir("$dir");
    }
    $thefiles[0] = $f;
}
else {
    $f = "False";
    $dir = substr($0, 0, (rindex($0,"\\")));
    $count = 0;
    $input = '';

    opendir(DIR, $dir) || die("Cannot open directory $dir");
    foreach $t (readdir(DIR)) {
        chomp($t);
            if ($t =~ m/\.html?$/i) { push(@files, $t); }
        }
    closedir(DIR);
    if (scalar(@files) > 0) {
        print "The following are HTML files in directory:\n\n";

        foreach $t (@files) {
            $count++;
            print "$count: $files[$count-1]\n";
        }
        print "\nInsert number of file you wish to convert and email or type \"all\" to convert and email all available files, \"exit\" to escape: ";
        while ($input !~ /^(?:\d+|all|exit)$/i) {
            $input = <>;
            chomp($input);
            if (($input =~ /^\d+$/)&&($input > 0)&&($input <= scalar(@files))) { $thefiles[0] = $files[$input-1]; }
            elsif ($input =~ /^all$/i) { @thefiles = @files; }
            elsif ($input =~ /^exit$/i) { $f = 'exit'; }
            else {
                print "Invalid input, try again: ";
                $input = '';
            }
        }
    }
    else {
        print "No HTML files found.";
        @thefiles = @files;
    }
}
print "\n";
#-----------------------------------------------------------------------------
#Generate and set Output folders
if (! -d "$mobidir") { system("md","$mobidir"); }

if ($dir =~ /C:\\Users\\Admin\\Documents\\Ebooks\\Harry Potter\\Fan Fiction\\?/i) {
    if (! -d "$mobihp") { system("md","$mobihp"); }
    $mobidir2 = $mobihp;
}
elsif ($dir =~ /C:\\Users\\Admin\\Documents\\Ebooks\\Naruto\\?/i ) {
    if (! -d "$mobinaruto") { system("md","$mobinaruto"); }
    $mobidir2 = $mobinaruto;
}
elsif ($dir =~ /C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Incompletes\\?/i ) {
    if (! -d "$mobiincompletes") { system("md","$mobiincompletes"); }
    $mobidir2 = $mobiincompletes;
}
elsif ($dir =~ /C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Partial\\?/i ) {
    if (! -d "$mobipartial") { system("md","$mobipartial"); }
    $mobidir2 = $mobipartial;
}
else { $mobidir2 = $mobidir; }
#-----------------------------------------------------------------------------
foreach $f (@thefiles) {
    chomp($f);
    print "Now converting $f\n";
    my $objWMI = Win32::OLE->GetObject('winmgmts://./root/cimv2');
    my $procs = $objWMI->InstancesOf('Win32_Process');
    $stunnel_status = 0;
    foreach $p (in $procs) {
        $stunnel_status = 1 if $p->Name =~ /stunnel\.exe/;
    }
    if ($stunnel_status == 0) { system("start /B \"Process 1\" \"$stunnel\""); }
    system("C:/Users/Admin/Documents/Ebooks/Unsorted/Temp/Kindle Convert.pl","$dir\\$f");
    $_ = $f;
    m/^(.*)\.html$/i;
    $mobi = $1 . "\.mobi";
    $emailcommand = "blat -body \"convert\" -subject \"$mobi\" -attach \"\\\"$mobidir2$mobi\\\"\" -to \"samirp\@free.kindle.com\" -p gmailsmtp -server 127.0.0.1:1099";
    #$emailcommand = "blat -body \"convert\" -subject \"$mobi\" -attach \"\\\"$mobidir2$mobi\\\"\" -to \"ajay.patel_57\@free.kindle.com\" -p gmailsmtp -server 127.0.0.1:1099";
    system("$emailcommand");
}
print "\nClosing program in 2 seconds\n";
sleep(2);
exit 0;