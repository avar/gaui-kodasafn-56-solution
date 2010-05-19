#!/usr/bin/env perl
use perl5i::latest;
use File::CountLines qw/ count_lines /;
use Term::Sk;
use Regexp::Assemble;
use Time::HiRes qw/ gettimeofday tv_interval /;

my $ordalisti = 'ordalisti.txt';
my $interactive = $ARGV[0];
my $lines     = count_lines($ordalisti);
my $matcher;

# Progress bar
{
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

say "Making giant regex...";
my $start_time = [gettimeofday()];
my $giant_regex = $ra->re;
$matcher = qr/^(?:$giant_regex)$/;

my $elapsed = tv_interval($start_time);
say sprintf "Made regex in %.4f seconds", $elapsed;
}

# Benchmark questions
open my $listi, "cat $ordalisti | iconv -f iso-8859-1 -t utf-8 |";

my $time_to_match = 0;

# Make the user ask us stuff
my %match;
if ($interactive) {
say "Ask if your word matches:";
$listi = *STDIN;
}
while (my $query = <$listi>) {
    $query->chomp;
    my $sorted = $query->split(qr//)->sort->join("");

    say "  Matching <$query> as <$sorted>..";

    # Fuzz some words so not all will match, benchmarks misses
    $sorted =~ s/a/b/g unless $interactive;

    # Check if we got a match
    my $start_time = [gettimeofday()];
    my $matched = $sorted ~~ $matcher;
    my $elapsed = tv_interval($start_time);
    $time_to_match += $elapsed;

    $match{$matched}++;

    if ($interactive) {
        say $matched
            ? "    <$query> (<$sorted>) matched a word in our db"
            : "    No match for <$query> (<$sorted>)";
    }

    say sprintf "  ..Replied %.10f seconds", $elapsed;
}

say sprintf "Matched $lines words took %.4f seconds, or %.8f seconds per word", $time_to_match, $time_to_match / $lines;
say sprintf "Out of %d queries %d matched a word in our db, %d did not", $lines, $match{'1'}, $match{''};
