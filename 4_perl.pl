#!/usr/bin/env perl
use perl5i::latest;
use File::CountLines qw/ count_lines /;
use Term::Sk;
use Regexp::Assemble;
use Time::HiRes qw/ gettimeofday tv_interval /;

my $ordalisti = 'ordalisti.txt';
my $lines     = count_lines($ordalisti);

# Progress bar
my $progress = Term::Sk->new('%d Elapsed: %8t %21b %4p %2d (%8c of %11m)', {
    # Start at line 1, not 0
    base => 1,
    target => $lines,
    # Every 0.1 seconds for long files
    freq => ($lines < 10_000 ? 10 : 'd'),
}) or die "Error in Term::Sk->new: (code $Term::Sk::errcode) $Term::Sk::errmsg";

# Convert to UTF-8
open my $listi, "cat $ordalisti | iconv -f iso-8859-1 -t utf-8 |";

# Make giant optimized regex
my $ra = Regexp::Assemble->new;
while (my $ord = <$listi>) {
    $ord->chomp;
    my $sorted = $ord->split(qr//)->sort->join("");
    $progress->up;
    $ra->add( $sorted->quotemeta );
}
$progress->close;
my $giant_regex = $ra->re;
my $matcher = qr/^(?:$giant_regex)$/;

# Make the user ask us stuff
say "Ask if your word matches:";
while (my $query = <STDIN>) {
    $query->chomp;
    my $sorted = $query->split(qr//)->sort->join("");
    my $start_time = [gettimeofday()];

    # Check if we got a match
    my $matched = $sorted ~~ $matcher;
    given ($matched) {
        when (1) {
            say "<$query> (<$sorted>) matched a word in our db";
        }
        default {
            say "No match for <$query> (<$sorted>)";
        }
    }

    my $elapsed = tv_interval($start_time);
    say sprintf "Replied %.10f seconds", $elapsed;
}

