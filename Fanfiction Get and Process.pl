#!/usr/local/bin/perl -w
#Last Edit: 06/14/14
use Tk;
use LWP::Simple qw($ua get);
use Win32::Clipboard;
use Win32::OLE qw(in); #To check if stunnel process is running
#-------------------------------------------------------------------------------------------------------------------
#Global Variables
$ua->agent('agent/2.0');
$convertMobi = 0;
$convertEpub = 0;
$convertandemail = 0;
$email_gmail = 0;
$partial_flag = 0;
$enable_ent = 1;
$complete_bool = 0;
$abandoned_bool = 0;
$localfile_bool = 0;
$fanfictionnet_bool = 0;
$open_bool = 0;
#-------------------------------------------------------------------------------------------------------------------
#Dialog Box

#Dialog Box Dimensions
my $mw = new MainWindow;
$screen_mid_y = $mw->screenheight() / 2;
$screen_mid_x = $mw->screenwidth() / 2;
$window_width = 550; #Even numbers only
$window_height = 110; #Even numbers only
$left = $screen_mid_x - $window_width / 2;
$top = $screen_mid_y - $window_height / 2;
$geo = $window_width . 'x' . $window_height . '+' . $left . '+' . $top;
$mw->geometry("$geo");
#-------------------------------------------------------------------------------------------------------------------
#Dialog Box Contents
#Use clipboard to get link.
$get_link = '';
if ($get_link !~ m/(?:.*www\.fanfiction\.net\/s\/(\d+)\/\d+(\/[^\/]+)?)|(?:^(?:file\:\/\/\/)?([A-Za-z]\:.*\/)(.*))|(?:http.*mail.google.com.*)/i) {
    $Clip = Win32::Clipboard();
    $get_link = $Clip->Get();
    if ($get_link !~ m/(?:.*www\.fanfiction\.net\/s\/(\d+)\/\d+(\/[^\/]+)?)|(?:^(?:file\:\/\/\/)?([A-Za-z]\:.*\/)(.*))|(?:http.*mail.google.com.*)/i) {
        $get_link = '<---Insert Fanfiction.net or Local File link here!--->';
    }
}
#-------------------------------------------------------------------------------------------------------------------
#Frame 1
my $frame1 = $mw->Frame()->pack(-side => 'top', -expand => 1, -fill => 'x');
my $ent = $frame1->Entry(-width => 79, -text => $get_link, -justify => 'center')->pack(-side => 'left', -expand => 1, -fill => 'x');
my $clip_button = $frame1->Button(-text=>'C',-relief=>'ridge',-activebackground => '#b4b4b4', -command =>\&get_clip)->pack(-side => 'left');
my $chk_ent = $frame1 -> Checkbutton(-variable=>\$enable_ent,-command => \&disablebox6)->pack(-side => 'left');
#Frame 2
my $frame2 = $mw->Frame()->pack(-side => 'top');
my $chk = $frame2 -> Checkbutton(-text=>'Convert to mobi',-variable=>\$convertMobi) -> pack(-side => 'left');
my $chk8 = $frame2 -> Checkbutton(-text=>'Convert to epub',-variable=>\$convertEpub) -> pack(-side => 'left');
my $chk2 = $frame2 -> Checkbutton(-text=>'Convert and Email ebook to Kindle',-variable=>\$convertandemail,-command => \&disablebox) -> pack(-side => 'left');
my $chk3 = $frame2 -> Checkbutton(-text=>'Email to samirp@gmail.com',-variable=>\$email_gmail) -> pack(-side => 'left');
#Frame 3
my $frame3 = $mw->Frame()->pack(-side => 'top');
my $chk4 = $frame3->Checkbutton(-text=>'Partial Download => Start Chapter =',-variable=>\$partial_flag,-command => \&disablebox2) -> pack(-side => 'left', -expand => 1);
my $ent2 = $frame3->Entry(-width => 3, -justify => 'center', -state => 'disabled') -> pack(-side => 'left');
my $frame4 = $mw->Frame()->pack(-side => 'top');
my $chk7 = $frame4 -> Checkbutton(-text=>'Complete?',-variable=>\$complete_bool)-> pack(-side => 'left');
my $chk5 = $frame4 -> Checkbutton(-text=>'Abandoned?',-variable=>\$abandoned_bool)-> pack(-side => 'left');
my $chk6 = $frame4 -> Checkbutton(-text=>'Open after processed?',-variable=>\$open_bool)-> pack(-side => 'left');
#Frame 4
my $frame5 = $mw->Frame()->pack(-side => 'top', -expand => 1, -fill => 'x');
my $button = $frame5->Button(-text=>'OK',-relief=>'raised',-borderwidth=>3,-activebackground => '#b4b4b4', -command =>\&process)->pack(-expand => 1, -fill => 'x');
#Keyboard Bind
$ent -> bind('<KeyRelease-Return>' => \&process); #Bind enter to start &Process
$ent2 -> bind('<KeyRelease-Return>' => \&process); #Bind enter to start &Process

$ent -> focus; #Focus Cursor in $ent
MainLoop;
#-------------------------------------------------------------------------------------------------------------------
#Disable
sub disablebox {
    if ($convertandemail == 1) { $convertMobi = 1; $chk -> configure( -state => 'disabled' ); }
    else { $convertMobi = 0; $chk -> configure( -state => 'normal' ); }
}
sub disablebox2 {
    if ($partial_flag == 0) { $ent2 -> configure( -state => 'disabled' ); }
    else { $ent2 -> configure( -state => 'normal' ); $ent2 -> focus; }
}
sub disablebox6 {
    my $state;
    if ($enable_ent == 0) {
        $convertMobi = 0;
        $convertandemail = 0;
        $abandoned_bool = 0;
        $open_bool = 0;
        $state = 'disabled';
    }
    else { $state = 'normal'; }

    $chk -> configure( -state => "$state" );
    $chk2 -> configure( -state => "$state" );
    $chk3 -> configure( -state => "$state" );
    $chk4 -> configure( -state => "$state" );
    $chk5 -> configure( -state => "$state" );
    $chk6 -> configure( -state => "$state" );
    $chk7 -> configure( -state => "$state" );
    $chk8 -> configure( -state => "$state" );
}
#-------------------------------------------------------------------------------------------------------------------
sub get_clip {
    $Clip = Win32::Clipboard();
    $get_link = $Clip->Get();
    if ($get_link !~ m/(?:.*www\.fanfiction\.net\/s\/(\d+)\/\d+(\/[^\/]+)?)|(?:^(?:file\:\/\/\/)?([A-Za-z]\:.*\/)(.*))|(?:http.*mail.google.com.*)/i) {
        $get_link = '<---Invalid Link in Clipboard--->';
    }
    $ent ->delete(0,5000); #5000 is an arbitrary number so entire entry can be deleted
    $ent->insert(0, "$get_link");
}
#-------------------------------------------------------------------------------------------------------------------
sub process {
    $mw->withdraw; #Close Dialog
    $link = $ent->get();

    #This link regex is for files on hard drive.
    if ($link =~ m/^(?:file\:\/\/\/)?[A-Za-z]\:.*\/.*/i) { localfile(); }
    #This link regex is for fanfiction.net links
    elsif ($link =~ m/.*www\.fanfiction\.net\/s\/(\d+)\/\d+(?:\/[^\/]+)?/i) { fanfictionnet(); }
    else {
        print "Link not recognised! Must be a FanFiction.net link.\nWindow will close in 2 seconds.";
        sleep(2);
        exit(1);
    }
    exit(0);
}

sub localfile {
    $localfile_bool = 1;
    $convertedDir = "C:\\Users\\Admin\\Documents\\Ebook Converted\\";

	unless(-d $convertedDir){ mkdir $convertedDir or die "Couldn't create dir: [$convertedDir] ($!)"; }

    if (($convertMobi|$convertEpub|$convertandemail|$email_gmail|$partial_flag) == 0) {
        print "No options selected. Program is exiting.";
        sleep(2);
        exit(1);
    }

    $link =~ s/\%20/ /g;
    $link =~ s/\%27/'/g;
    $link =~ s/\%28/\(/g;
    $link =~ s/\%29/\)/g;
    $link =~ s/\%5B/[/g;
    $link =~ s/\%5D/]/g;
    $link =~ s/\%3b/;/g;
    $link =~ m/(?:^(?:file\:\/\/\/)?([A-Za-z]\:.*\/)(.*))/i;
    $dir = $1;
    $f = $2;
    $dir =~ s/\//\\/ig;
    #convert_email
    convert_email();
}

sub fanfictionnet {
    $fanfictionnet_bool = 1;
    $dir = "C:\\Users\\Admin\\AppData\\Local\\Temp\\"; #temp folder
    $ebookdirC = "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\";
	$ebookdir = "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Incompletes\\";
    $convertedDirC = "C:\\Users\\Admin\\Documents\\Ebook Converted\\";
	$convertedDir = "C:\\Users\\Admin\\Documents\\Ebook Converted\\Incompletes\\";


    $StoryID = $1;
    $Count = 1;

	#Create Primary Directories (Order matters since higher directories need to be made first)
	unless(-d $ebookdirC){ mkdir $ebookdirC or die "Couldn't create dir: [$ebookdirC] ($!)"; }
	unless(-d $ebookdir){ mkdir $ebookdir or die "Couldn't create dir: [$ebookdir] ($!)"; }
	unless(-d $convertedDirC){ mkdir $convertedDirC or die "Couldn't create dir: [$convertedDirC] ($!)"; }
    unless(-d $convertedDir){ mkdir $convertedDir or die "Couldn't create dir: [$convertedDir] ($!)"; }

    #Declare start chapter
    if ($partial_flag == 1) {
        $Begin = ($ent2->get()); #Ensure value is an int.
        if ($Begin !~ m/^\d+$/) { $Begin = 1; print "Begin chapter is set to a non Integer value. Defaulting Start chapter to 1\n\n"; }
        if ($Begin < 1) { $Begin = 1; print "Begin chapter is set to a value less than 1. Defaulting Start chapter to 1\n\n"; }
        if ($Begin != 1) {
            print "Partial mode active. Start chapter is set to $Begin\n";
            $ebookdir = "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Partial\\";
            $ebookdirC = "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Partial\\";
            $convertedDir = "C:\\Users\\Admin\\Documents\\Ebook Converted\\Partial\\";
            $convertedDirC = "C:\\Users\\Admin\\Documents\\Ebook Converted\\Partial\\";
        }
    }
    else { $Begin = 1; }

    #Check and create directories again since directories could have been modified above
	unless(-d $ebookdirC){ mkdir $ebookdirC or die "Couldn't create dir: [$ebookdirC] ($!)"; }
	unless(-d $ebookdir){ mkdir $ebookdir or die "Couldn't create dir: [$ebookdir] ($!)"; }
	unless(-d $convertedDirC){ mkdir $convertedDirC or die "Couldn't create dir: [$convertedDirC] ($!)"; }
    unless(-d $convertedDir){ mkdir $convertedDir or die "Couldn't create dir: [$convertedDir] ($!)"; }

    $Chapters = $Begin;
    $Title = '', $Author = '', $Summary = '', $Header = '', $f = '';
    $tlength = 10;
    $dash = "-" x $tlength;

    if ($enable_ent == 1) {
        if ($convertMobi == 1) { print "Convert to Mobi Option Activated.\n"; }
        if ($convertEpub == 1) { print "Convert to Epub Option Activated.\n"; }
        if ($convertandemail == 1) { print "Email Option Activated.\n"; }
        for($Count = $Begin; $Count <= $Chapters; $Count++) {
            $retrycount = 0;
            START:
            $CurrentPage = "http://www.fanfiction.net/s/$StoryID/$Count/";
            my $PageSource=get($CurrentPage) or die 'Unable to get page';
            if ($Count == $Begin) {
                if ($PageSource =~ m/\<span class='gui_warning'\>Story Not Found/i) {
                    print "Error: Story not found. Story has most likely been removed from site\nClosing in 3 seconds.";
                    sleep(3);
                    exit(1);
                }
                if ($PageSource =~ m/Status:\s+Complete\s+-\s+id:/i) { $complete_bool = 1; }
                if ($PageSource =~ m/Chapters: (\d+)(?:\s+)- Words/i) { $Chapters = $1; }
                if ($PageSource =~ m/var title = '(.*)'/i) {
                    $Title = $1;
                    $Title =~ s/\+/ /ig;
                    $Title =~ s/\%26/&/g;
                    $Title =~ s/\%21/!/g;
                    $Title =~ s/\%27/'/g;
                    $Title =~ s/\%28/\(/g;
                    $Title =~ s/\%29/\)/g;
                    $Title =~ s/\%2C/,/g;
                    $Title =~ s/\%3F/?/g;
                    $Title =~ s/\%3A/;/g; #3A is a colon(:), which can't be used in filenames.
                    $Title =~ s/\:/;/ig;
                    $Title =~ s/\\('|")/$1/g;
                    $Title =~ s/\%E2\%80\%93/-/g;
                    $Title =~ s/\%C5\%8D/&#333\;/g;
                    $Title =~ s/%C5%AB/&#363\;/g;
                    $Title =~ s/%C5%8C/&#332\;/g;
                    $Title =~ s/%C4%AB/&#299\;/g;
                    $Title =~ s/%C4%93/&#275\;/g;
					$Title =~ s/%C3%AD/&iacute\;/g;
					$Title =~ s/%C3%BE/&thorn\;/g;
                    $Title1 = $Title; #Title1 refers to "filename Title" rather than "Book Title"
                    $Title1 =~ s/["?*\/\\:]//g; #Characters that windows filenames cannot contain
					$Title1 =~ s/&iacute\;/i/g;
					$Title1 =~ s/&thorn\;/th/g;
                    $Title1 =~ s/\&#333\;/o/g;
                    $Title1 =~ s/\&#363\;/u/g;
                    $Title1 =~ s/\&#332\;/O/g;
                    $Title1 =~ s/\&#299\;/i/g;
                    $Title1 =~ s/\&#275\;/e/g;
                    $tlength = length($Title1);
                    $dash = "-" x $tlength;
                    print "$dash\n$Title1\n$dash\n"
                }
                #if ($PageSource =~ m/Author:\x20?\<\/span\>\x20?\<a class[^>]*\>(.*?)<\/a>/i) {
                if ($PageSource =~ m/By:\<\/span\> ?\<a class='xcontrast_txt' href='[^\>]*'>(.*?)\<\/a\>/i) {
                    $Author = $1;
                    $Author =~ s/\\('|")/$1/ig;
                }
                if ($PageSource =~ m/\<div style='margin-top\:2px' class='xcontrast\_txt'\>(.*?)\<\/div\>/i) {

                    $Summary = $1;
                    $Summary =~ s/\\('|")/$1/ig;
                }

                if (($Chapters > "1")&&($complete_bool == 0)) { $f="$Title1 (Fan Fiction) - $Author.html"; }
                elsif (($Chapters == "1")&&($complete_bool == 0)) { $f="O - $Title1 (Fan Fiction) - $Author.html"; }
                else { $f="$Title1 (Fan Fiction) - $Author.html"; }

                open (HTML, ">$dir$f");
                binmode HTML, ":utf8";

                if ($Title ne "") {
                    print HTML "<!--$link-->\n<HTML>\n<Head>\n<Title>$Title1 (Fan Fiction) - $Author</Title>\n</Head>\n<Body>";
                    print HTML "<H1>$Title</H1>\n";
                    print HTML "<H2>-Fan Fiction by $Author-</H2>\n\n";
                    print HTML "<P>Summary: $Summary</P>\n\n";
                }
            }
            if ($PageSource =~m/<option  value=$Count selected>\d+\. ?(.*?)\</i) {
                if ($1 =~ m/^Chapter \d+$/i) { $Header = "<H3 ID=\"Ch$Count\">Chapter $Count</H3>"; }
                else { $Header = "<H3 ID=\"Ch$Count\">Chapter $Count - $1</H3>"; }
            }
            else { $Header = "<H3 ID=\"Ch$Count\">Chapter $Count</H3>"; }

            #Chapter Content
            if ($PageSource =~ m/<div class='storytext xcontrast_txt nocopy' id='storytext'>(.*?)<\/div>/is) {
                $Text = $1;
                $Text =~ s/<B>/<STRONG>/ig;
                $Text =~ s/<i>/<EM>/ig;
                $Text =~ s/<\/B>/<\/STRONG>/ig;
                $Text =~ s/<\/i>/<\/EM>/ig;
            }
            elsif ($retrycount < 10) {
                $retrycount++;
                print " ::Error Found. Retry attempt($retrycount/10) in 1 seconds.\n";
                sleep(1);
                goto START;
            }
            else {
                print " ::Error: Chapter $Count Text not found. Script may need updating.\n\n";
                system("pause");
                exit (1);
            }
            if ($Chapters > "1") { print HTML "$Header\n$Text"; }
            else { print HTML "$Text"; }

            $subf = "Chapter $Count of $Chapters Processed";
            $subf = substr($subf, 0, 55); #Windows CMD line forces a new line after 55 characters
            $blength = length($subf) + length($Chapters) + length($Count) + 16;
            print "\b" x $blength;
            print "$subf";
            if ($Count == $Chapters) { print "\n"; }
        }
        print HTML "</Body>\n</HTML>";
        close HTML;
        print "-----------------------------\nPerforming Tidy Operation:\n\n";
        system("move","\"$dir$f\"","\"$ebookdir\""); #Move completed book from temp folder to ebook directory
        $dir = $ebookdir;
        system("C:/Program Files/Tidy/tidy", "-o", "$dir$f", "-config", "C:/Program Files/Tidy/config.txt", "$dir$f");

        #Rename if abandoned or complete. This is done after moving to ebookdir so that duplicate ebooks can be avoided.
        if (($Chapters > "1")&&($abandoned_bool == 1)) {
            $fnew = "[Abandoned] - $Title1 (Fan Fiction) - $Author.html";
            system("ren","\"$dir$f\"","\"$fnew\"");
            $f = $fnew;
        }
        elsif (($Chapters > "1")&&($complete_bool == 1)) {
            $fnew = "[C] - $Title1 (Fan Fiction) - $Author.html";
            system("ren","\"$dir$f\"","\"$fnew\"");
            $f = $fnew;
            system("move","\"$dir$f\"","\"$ebookdirC\"");
            $dir = $ebookdirC;
            $convertedDir = $convertedDirC;
        }
        elsif (($Chapters == "1")&&($complete_bool == 1)) {
            $fnew = "[C] - O - $Title1 (Fan Fiction) - $Author.html";
            system("ren","\"$dir$f\"","\"$fnew\"");
            $f = $fnew;
            system("move","\"$dir$f\"","\"$ebookdirC\"");
            $dir = $ebookdirC;
            $convertedDir = $convertedDirC;
        }
        convert_email();
    }
    if ($enable_ent == 0) {
        print "No options have been selected.\nWindow will close in 2 seconds.";
        sleep(2);
        exit(1);
    }
    exit(0);
}

sub convert_email {
    $epubParam = '--language en  --chapter-mark pagebreak --no-default-epub-cover --chapter "//*[((name()=\'h1\' or name()=\'h2\' or name()=\'h3\') and re:test(., \'\s*((chapter|book|section|part)\s+)|((prolog|prologue|epilogue)(\s+|$))\', \'i\')) or @class = \'chapter\']" --page-breaks-before "//*[((name()=\'h1\' or name()=\'h2\' or name()=\'h3\') and re:test(., \'\s*((chapter|book|section|part)\s+)|((prolog|prologue|epilogue)(\s+|$))\', \'i\')) or @class = \'chapter\']"';
    #$mobiParam = '--language en  --chapter-mark pagebreak --chapter "//*[((name()=\'h1\' or name()=\'h2\' or name()=\'h3\') and re:test(., \'\s*((chapter|book|section|part)\s+)|((prolog|prologue|epilogue)(\s+|$))\', \'i\')) or @class = \'chapter\']" --page-breaks-before "//*[((name()=\'h1\' or name()=\'h2\' or name()=\'h3\') and re:test(., \'\s*((chapter|book|section|part)\s+)|((prolog|prologue|epilogue)(\s+|$))\', \'i\')) or @class = \'chapter\']"';
    $dropboxConverted = "C:\\Users\\Admin\\Desktop\\Dropbox\\New Ebook Converted\\";
	$tempFolder = "C:\\Users\\Admin\\AppData\\Local\\Temp\\";
	$htmlFolder = $dir;

    unless(-d $dropboxConverted){ mkdir $dropboxConverted or die "Couldn't create dir: [$dropboxConverted] ($!)"; }

    if (-e "$dir$f") {

        system("cls");
        print "-" x 75;
        print "\n";

        if ($convertMobi == 1) { print "Convert to Mobi Option Activated.\n"; }
        if ($convertEpub == 1) { print "Convert to Epub Option Activated.\n"; }
        if ($convertandemail == 1) { print "Email to Kindle Option Activated.\n"; }
        if ($email_gmail == 1) { print "Email to Gmail option Activated.\n"; }
        if (($convertMobi == 1) || ($convertEpub == 1) || ($convertandemail == 1)) { print "-" x 75; print "\n"; }
        if ($fanfictionnet_bool == 1) {
            system("C:/Users/Admin/Documents/Ebooks/Unsorted/Temp/Ebook.pl", "$dir$f");
        }

        if (($convertMobi == 1) || ($convertEpub == 1) ||($email_gmail == 1)) { start_stunnel(); }

        #Convert to designated ebook type, and email if option is activated.
        if (($convertMobi == 1)||($convertEpub == 1)) {
			#Create a temp file that can be modified
			system("copy","\"$dir$f\"","\"$tempFolder$f\"");
			$dir = $tempFolder;

			#Erase/Replace HTML ebook elements
			&scripterase("$dir","$f");

			if ($localfile_bool == 1) {
                #Setup special Ebook Dirs.
                if ($dir =~ m/C\:\\Users\\Admin\\Documents\\Ebooks\\Naruto/i) {
                    $convertedDir = "C:\\Users\\Admin\\Documents\\Ebook Converted\\Naruto\\";
                }
                if ($dir =~ m/C\:\\Users\\Admin\\Documents\\Ebooks\\Harry Potter\\Fan Fiction/i) {
                    $convertedDir = "C:\\Users\\Admin\\Documents\\Ebook Converted\\HP\\";
                }
                if ($dir =~ m/C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\Incompletes\\/i) {
                    $convertedDir = "C:\\Users\\Admin\\Documents\\Ebook Converted\\Incompletes\\";
                }
				unless(-d $convertedDir){ mkdir $convertedDir or die "Couldn't create dir: [$convertedDir] ($!)"; }
            }

            $_ = $f;
            m/^(.*)\.html$/i;
            $mobi = $1 . "\.mobi"; #define mobi file name
            $epub = $1 . "\.epub"; #define epub file name
            if ($convertMobi == 1) {
                system("C:/Users/Admin/Documents/Ebooks/Unsorted/Temp/Kindle Convert.pl","$dir$f");
                #system("ebook-convert","$dir$f","$convertedDir$mobi","$mobiParam");
            }
            if ($convertEpub == 1) {
                system("ebook-convert","$dir$f","$convertedDir$epub","$epubParam");
            }
            sleep(2);
            if ($convertMobi == 1) { system("copy","\"$convertedDir$mobi\"","\"$dropboxConverted\""); }#place copy in dropbox recent folder
            if ($convertEpub == 1) { system("copy","\"$convertedDir$epub\"","\"$dropboxConverted\""); }#place copy in dropbox recent folder
            print "$convertedDir$epub\n";

            if ($convertandemail == 1) {
                #mobi
                if (-e "$convertedDir$mobi") {
                    $emailcommand = "blat -body \"convert\" -subject \"$mobi\" -attach \"\\\"$convertedDir$mobi\\\"\" -to \"samirp\@free.kindle.com\" -p gmailsmtp -server 127.0.0.1:1099";
                    system("$emailcommand");
                }
                else {
                    print "\nError: $convertedDir$mobi does not exist.\n";
                    system ("pause");
                    exit(1);
                }
            }
        }
        #Email HTML to gmail.
        if ($email_gmail == 1) {
            $emailcommand = "blat -body \"eBook:\n\n$dir$f\" -subject \"Ebook\: $f\" -attach \"\\\"$dir$f\\\"\" -to \"samirp\@gmail.com\" -p gmailsmtp -server 127.0.0.1:1099";
            system("$emailcommand");
        }
        #-----------------------------------------------------------------------------------------------------
        if ($open_bool == 1) {
			system("$htmlFolder$f");
		}
        #-----------------------------------------------------------------------------------------------------
    }
    else {
        print "Error: $dir$f does not exist. Closing in 3 seconds.";
        sleep(3);
        exit(1);
    }
}

sub start_stunnel {
    my $stunnel = "C:\\Program Files\\stunnel\\stunnel.exe";
    my $stunnel_status = 0;
    my $objWMI = Win32::OLE->GetObject('winmgmts://./root/cimv2');
    my $procs = $objWMI->InstancesOf('Win32_Process');
    foreach $p (in $procs) {
        $stunnel_status = 1 if $p->Name =~ /stunnel\.exe/;
    }
    if ($stunnel_status == 0) { system("start /B \"Process 1\" \"$stunnel\""); }
}

sub scripterase {
	print "Removing HTML Elements...";
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
    #$author = $1;
    print FILE1 "$_";
    close FILE1;
	print "Complete\n\n";
}