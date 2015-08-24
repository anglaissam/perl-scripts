#!/usr/bin/perl -w
#-----------------------------------------------------------------------------
#Global Variables
$start = time(); #Timer
$mobidir = "C:\\Users\\Admin\\Documents\\Ebook Converted\\"; #Default Output Directory
$mobihp = $mobidir . "HP\\";
$mobinaruto = $mobidir . "Naruto\\";
$mobiincompletes = $mobidir . "Incompletes\\";
$mobipartial = $mobidir . "Partial\\";
$kindleexe = "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Extra Scripts\\kindlegen.exe"; #Amazon's Kindle Generator
$count = 0;
$total = 0;
$author = '';
$title = '';
#-----------------------------------------------------------------------------
#Obtain Directory and any one specified file if given. Defaults to Script directory.
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
}
else {
    $dir = substr($0, 0, (rindex($0,"\\"))+1);
}    # $dir. If no directory is given, defaults is directory script is placed in.
if ($dir !~ /\\$/i) { $dir = $dir . "\\"; }

opendir(DIR, $dir) || die("Warning1: Cannot open directory $dir");
if (defined($ARGV[0]) && $f ne "") { $thefiles[0] = $f; } #ARG1 for specific file.
else {
    @thefiles = readdir(DIR);
    closedir(DIR);
}
#-----------------------------------------------------------------------------
foreach $f (@thefiles) {

    if ( ($f =~ m/\.htm$/i) || ($f =~ m/\.html$/i) ) {
        chomp($f);
        $total++;
    }
}

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

if ($total == 0) {
    print "No Valid HTML files found for conversion\n";
    sleep(2);
    exit(1);
}

foreach $f (@thefiles) {
    $wordcount = 0;
    $chaptercount = 0;

    if ( ($f =~ m/(.*)\.htm$/i) || ($f =~ m/(.*)\.html$/i) ) {
        $title = $1;
        $title2 = $1; #Workaround. Problem with including '+' in filename.
        if ($title =~ m/\+/i) {
            $_ = $title;
            s/\+//ig;
            $title2 = $_;
        }
        $tocdir = "$mobidir2" . "$title2\.toc.ncx";
        $opfdir = "$mobidir2" . "$title\.opf";

        $f2 = $f; #Workaround. Problem with including '+' in filename.
        if ($f =~ m/\+/i) {
            $_ = $f;
            s/\+//ig;
            $f2 = $_;
        }

        $count++;

        chomp($f);
        print "\n---------------------------\nConverting to mobi $count/$total: $f\n---------------------------\n";
        system("copy", "/a", "\"$dir$f\"", "\"$mobidir2$f2\"");
        &scripterase("$mobidir2","$f2");

        open (IN, "<$mobidir2$f2") or die "Warning2: Can't open $mobidir2$f2: $!\n";
        @lines = <IN>;
        close IN;
        open (TOC, ">$tocdir") or die "Warning3: Can't open $tocdir: $!\n";
        open (OUT, ">$mobidir2$f2") or die "Warning4: Can't open $mobidir2$f2: $!\n";
        for ( @lines ) {
        #Title
        if ($_ =~ /<H1>/i) {
            s/<H1>/<a id="start"><H1 ALIGN="CENTER">/i;
            &tocncx("start");
        }
        #Author and Part seperation
        if($_ =~ /<H2>/i) {
            s/<H2><EM>(-Fan Fiction by.*)<\/H2>/<H4 ALIGN="CENTER">$1<\/H4>/i;
            s/<H2>/<H2 ALIGN="CENTER">/i;
        }
        #Chapter Headings
        if ($_ =~ /<H3(?: ID=\"Ch\d+\")?>/i) {
            $chaptercount++;
            s/<H3(?: ID="Ch\d+")?>(.*)<\/H3>/<mbp\:pagebreak \/><a id="chap$chaptercount"\/><HR><H5 ALIGN="CENTER">$1<\/H5><HR>/i;
            &tocncx("$chaptercount");
        }
        #End
        if ($_ =~ /<\/BODY>/i) {
            s/<\/BODY>/<a id="end"\/><\/BODY>/i;
            &tocncx("end");
        }
        print OUT "$_";
    }
        close OUT;
        print TOC "<\/navMap>\n<\/ncx>";
        close TOC;

        #Obtain Word count and add in ebook info for second page
        {
            open (IN, "<$mobidir2$f2") or die "Warning5: Can't open $mobidir2$f2: $!\n";
            local $/;
            $lines = <IN>;
            close IN;

            $_ = $lines;

            #wordcount
            @words = split(/\s+/);
            foreach (@words) { $wordcount++; }

            unless ($chaptercount == 0) {
                s/(Summary:.*?<\/P>.*?<\/P>)/$1\n
                    <mbp\:pagebreak\x20\/>\n
                    <P ALIGN="CENTER"><U><EM><STRONG>eBook info:<\/STRONG><\/EM><\/U>\n\n
                    <P ALIGN="CENTER">Chapters\:\x20$chaptercount<\/P>\n
                    <P ALIGN="CENTER">\nWord Count\:\x20$wordcount<\/P>
                /isx;
            }

            open (OUT, ">$mobidir2$f2") or die "Warning6: Can't open $mobidir2$f2: $!\n";
            print OUT "$_";
            close OUT;
        }

        &opf();
        system("\"$kindleexe\" \"$opfdir\"");
        system("del /f \"$mobidir2$f2\"");
        system("del /f \"$opfdir\"");
        system("del /f \"$tocdir\"");
    }
}
$end = time();
$minutes = 0;
$seconds = ($end - $start);
while ($seconds > 59) {
    $minutes++;
    $seconds -= 60;
}
if ($minutes > 0) { print "\nTime taken: $minutes minutes $seconds seconds\n"; }
else { print "\nTime taken: $seconds seconds\n"; }
#-----------------------------
exit(0);

sub scripterase {
    $directory = shift;
    $file = shift;
    chomp($file);
    open (FILE, "<$directory$file") or die "Warning5: Can't open $directory$file: $!\n";
    local $/;
    $lines = <FILE>;
    close FILE;
    open (FILE1, ">$directory$file") or die "Warning6: Can't open $directory$file: $!\n";
    $_ = $lines;
    s/\<SCRIPT TYPE="text\/javascript"\>.*?\<\/SCRIPT\>//is;
    s/\<FORM NAME="colors".*?\<HR\>/<a id="start"\/><HR>/is; #Inserts first anchor for Kindle Chapter Markers in addition to clean
    s/&alefsym\;|&weierp\;//igs;
    m/<\/H1>\n<H2>(?:<EM>)?(?:-Fan Fiction by )?(.*?)(?:-)(?:<\/EM>)?<\/H2>/is;
    $author = $1;
    print FILE1 "$_";
    close FILE1;
}

sub tocncx {
    $order = shift;
    if ($order eq "start") {
        print TOC "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        print TOC "<!DOCTYPE ncx PUBLIC \"-//NISO//DTD ncx 2005-1//EN\" \"http://www.daisy.org/z3986/2005/ncx-2005-1.dtd\">\n";
        print TOC "<ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" version=\"2005-1\">\n";
        print TOC "<docTitle>\n<text>$f</text>\n</doctitle>\n<navMap>\n";
        print TOC "<navPoint playOrder=\"1\">\n";
    }
    elsif ($order eq "end") {
        print TOC "<navPoint playOrder=\"end\">\n";
    }
    else {
        $order++;
        print TOC "<navPoint playOrder=\"$order\">\n";
        $order--;
    }
    print TOC "<navLabel>\n";
    print TOC "<text>$order<\/text>\n";
    print TOC "<\/navLabel>\n";
    if ($order eq "start") { print TOC "<content src=\"$f2\#start\"\/>\n"; }
    if ($order eq "end") { print TOC "<content src=\"$f2\#end\"\/>\n"; }
    else { print TOC "<content src=\"$f2\#chap$order\"\/>\n"; }
    print TOC "<\/navPoint>\n";
}

sub opf {
    open (OPF, ">$opfdir") or die "Warning7: Can't open $opfdir: $!\n";
    print OPF "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
    print OPF "<package unique-identifier=\"uid\">\n";
    print OPF "<metadata>\n";
    print OPF "<dc-metadata xmlns:dc=\"http:\/\/purl.org\/metadata\/dublin_core\" xmlns:oebpackage=\"http:\/\/openebook.org\/namespaces\/oeb-package\/1.0\/\">\n";
    print OPF "<dc:Title>$title<\/dc:Title>\n";
    print OPF "<dc:Language>en-us<\/dc:Language>\n";
    print OPF "<dc:Creator>$author<\/dc:Creator>\n";
    print OPF "<\/dc-metadata>\n";
    print OPF "<x-metadata>\n";
    print OPF "<output encoding=\"utf-8\" content-type=\"text\/x-oeb1-document\"><\/output>\n";
    print OPF "<\/x-metadata>\n";
    print OPF "<\/metadata>\n";
    print OPF "<manifest>\n";
    print OPF "<item id=\"item1\" media-type=\"text\/x-oeb1-document\" href=\"$mobidir2$f2\"><\/item>\n";
    print OPF "<item id=\"toc\" media-type=\"application\/x-dtbncx+xml\" href=\"$tocdir\"><\/item>\n";
    print OPF "<\/manifest>\n";
    print OPF "<spine toc=\"toc\">\n";
    print OPF "<itemref idref=\"item1\"\/>\n";
    print OPF "<\/spine>\n";
    print OPF "<tours><\/tours>\n";
    print OPF "<guide>\n";
    print OPF "<reference type=\"start\" title=\"Startup Page\" href=\"$mobidir2$f2\#start\"><\/reference>\n";
    print OPF "<\/guide>\n";
    print OPF "<\/package>\n";
    close OPF;
}