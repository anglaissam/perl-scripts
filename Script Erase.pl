#!/usr/bin/perl -w
if (defined($ARGV[0]) && $ARGV[0] ne "") { $thefiles[0] = $ARGV[0]; }
else {
    $f = "False";
    $dir = substr($0, 0, (rindex($0,"\\")));
    $count = 0;
    $lines = '';
    $input = '';

    opendir(DIR, $dir) || die("Cannot open directory $dir");
    foreach $t (readdir(DIR)) {
        chomp($t);
        if ($t =~ m/\.html?$/i) {
            {
                chomp($t);
                open (IN, "<$t") or die "Can't open $t: $!\n";
                local $/;
                $_ = <IN>;
                close IN;
            }
            if ($_ =~ /(?:\<SCRIPT TYPE="text\/javascript"\>.*?\<\/SCRIPT\>)|(?:\<FORM NAME="colors".*?)|(?:\<\/H2>\n<HR>)/is) {
                push(@files, $t);
            }
        }
    }
    closedir(DIR);
    if (scalar(@files) > 0) {
        print "The following are HTML files with script elements that can be erased:\n\n";

        foreach $t (@files) {
            $count++;
            print "$count: $files[$count-1]\n";
        }
        print "\nInsert number of file you wish to Clean or type \"all\" to clean all available files, \"exit\" to escape: ";
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
        print "No HTML files with script elements found.";
        @thefiles = @files;
    }
}
print "\n";
foreach $f (@thefiles) {
    chomp($f);
    print "Now cleaning $f\n";
    open (IN, "<$f") or die "Can't open $f: $!\n";
    local $/;
    $lines = <IN>;
    close IN;
    open (OUT, ">$f") or die "Can't open $f: $!\n";
    $_ = $lines;
    s/ body { font-family:"verdana" }\x20?\n//is;
    s/\<LINK.*?\>//is;
    s/(<STYLE TYPE=\"text\/css\">)/$1\n body \{\n  background-color: black;\n }/is;
    s/\n\<SCRIPT TYPE="text\/javascript"\>.*?\<\/SCRIPT\>\n//is;
    s/\<FORM NAME="colors".*?\<HR\>\n//is;
    s/\<\/H2>\n<HR>/<\/H2>/is;
    s/\n\x20body\x20\{\n\x20\x20background-color:\x20black\;\n\x20\}//is;
    print OUT "$_";
    close OUT;
}
print "\nClosing program in 2 seconds\n";
sleep(2);
exit 0;