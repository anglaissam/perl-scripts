#!/usr/bin/perl -w
    # 05/31/2013 Added -i and -f flags; -i: ignore case; -f file only display
    # The new default behavior is to display the line of a match;
    # If -f is given, only the name of the file will be displayed.
#-------------------------------------------------------------------------------
use warnings;
use strict;
use File::Find;
# the location of the script is used as default
    # if no location is specified
    # NOTE: The original code used //. This requires Perl 5.12.4 or greater:
#$location //= '.';
my $location ||= '.'; # This change works with Perl 5.8.4 and greater.
# the script dies if there is nothing to search
system("cls");
print "Search (Regex): ";
my $word_to_search = <>;
die 'No word to search ...', unless defined $word_to_search;
chomp($word_to_search);
$::show_line='';
find(
sub {
    if ( -e && -f ) {
        my $status = 0;
        if ($_ =~ /\.pl$/i) {
            open my $fh, '<', $_ or die $!;
            while ( my $line = <$fh> ) {
                $::show_line=$line;
                ++$status && last if $line =~ /$word_to_search/i;
            }
            if ($status == 1) {
                print $File::Find::name;
                print "\n";
            }
        }
    }
},
$location
);
system("pause");
exit 0;