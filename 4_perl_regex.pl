#!/usr/bin/env perl
use open qw/ :encoding(utf8) :std /;
use strict;
use warnings;
use File::CountLines qw/ count_lines /;
use Term::Sk;
use Regexp::Assemble;
use Time::HiRes qw/ gettimeofday tv_interval /;

sub say { print shift, "\n" }

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
});


# Convert to UTF-8
open my $listi, "cat $ordalisti | iconv -f iso-8859-1 -t utf-8 |";

# Make giant optimized regex

my $ra = Regexp::Assemble->new;
while (my $ord = <$listi>) {
    chomp $ord;
    my $sorted = join('', sort split //, $ord);
    $progress->up;
    $ra->add( quotemeta $sorted );
}
$progress->close;

say "Making giant regex...";
my $start_time = [gettimeofday()];
my $giant_regex = $ra->re;
#use re 'debug';
$matcher = qr/^(?:$giant_regex)$/;
#no re 'debug';

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
    chomp $query;
    my $sorted = join '', sort split //, $query;

    say "  Matching <$query> as <$sorted>..";

    # Fuzz some words so not all will match, benchmarks misses
    $sorted =~ s/a/b/g unless $interactive;

    # Check if we got a match
    my $start_time = [gettimeofday()];
    my $matched = $sorted =~ $matcher;
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
