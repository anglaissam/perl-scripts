#!/usr/bin/perl -w
$start = time(); #Timer
select((select(STDOUT), $| = 1)[0]); #Removes buffering to STDOUT so perl will print when needed.

push(@directories, "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Potter - To Clean\\");
push(@directories, "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Other - To Clean\\");
push(@directories, "C:\\Users\\Admin\\Documents\\Ebooks\\Harry Potter\\Fan Fiction\\");
push(@directories, "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Naruto - To Clean\\");
push(@directories, "C:\\Users\\Admin\\Documents\\Ebooks\\Naruto\\");
push(@directories, "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\");
push(@directories, "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Incompletes\\");
push(@directories, "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Process\\");

$total = 0;
$count = 0;
$blength = 0;

foreach $dir (@directories) {
    opendir(DIR, $dir) || die("Cannot open directory $dir");
    @thefiles = readdir(DIR);
    closedir(DIR);
    foreach $f (@thefiles) {
        if ( ($f =~ m/\.html?$/i) ) {
            $total++;
        }
    }
}
print "Multi-Directory Quick Sub starting...\n";
print "Beginning search. $total files in list.\n\n";

foreach $dir (@directories) {
    opendir(DIR, $dir) || die("Cannot open directory $dir");
    @thefiles = readdir(DIR);
    closedir(DIR);

    foreach $f (@thefiles) {
        if ( ($f =~ m/\.html?$/i) ) {
            $count++;
            $subf = substr($f, 0, 55); #Windows CMD line forces a new line after 55 characters
            print "Processing ($count/$total): $subf";
            chomp($f);
            open (IN, "<$dir$f") or die "Can't open $dir$f: $!";
            local $/;
            $lines = <IN>;
            close IN;
            $_ = $lines;
            
            #----------------------------------------------------------------------------------------------
            #Substitutions
            /(<!--[^>]*-->)/is;
            $templink = $1;
            s/$templink//igs;
            s/\<!DOCTYPE/$templink\n<!DOCTYPE/is;
            #----------------------------------------------------------------------------------------------
            
            if ($_ ne $lines) {
                open (OUT, ">$dir$f") or die "Can't open $dir$f: $!";
                print OUT "$_";
                close OUT;
                push(@modified, "$f");
            }
            $blength = length($subf) + length($total) + length($count) + 16;
            print "\b" x $blength;
        }
    }
    shift(@thefiles);
}

if (scalar(@modified) > 0) {
    foreach (@modified) { print "Modified $_\n"; }
}
#end timer
$end = time();
$minutes = 0;
$seconds = ($end - $start);
while ($seconds > 59) {
    $minutes++;
    $seconds -= 60;
}
if ($minutes > 0) { print "\nTime taken: $minutes minutes $seconds seconds\n"; }
else { print "\nTime taken: $seconds seconds\n"; }
system("pause");
exit (0);