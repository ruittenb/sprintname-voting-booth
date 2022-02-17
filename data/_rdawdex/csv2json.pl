#!/usr/bin/env perl

use strict;
use warnings;
use JSON;
use Readonly;
use IO::Handle;
use Try::Catch;
use Text::CSV qw(csv);

Readonly my $DATAFILE  => 'rdawdex-gen3.csv';
Readonly my $URL       => 'https://darkandwindiefakemon.fandom.com/wiki/';
Readonly my $RDAWBLOCK => 2000;

Readonly my $NUM    => 0;
Readonly my $GEN    => 1;
Readonly my $LETTER => 2;
Readonly my $NAME   => 3;
Readonly my $IMAGE  => 4;
Readonly my $DESC   => 5;

my @csvdata = ();
my $parser = Text::CSV->new({ binary => 1 });
open my $fh, "<:encoding(UTF-8)", $DATAFILE or die "Cannot read $DATAFILE: $!";
while (my $row = $parser->getline($fh)) {
    push @csvdata, $row;
}
my @records = ();

try {
    foreach (@csvdata) {
        my $num = 0 + $_->[$NUM];
        my $record = {
            description => $_->[$DESC],
            generation => $_->[$GEN],
            id => $num + $RDAWBLOCK,
            letter => $_->[$LETTER],
            name => $_->[$NAME],
            number => $num,
            url => $URL . $_->[$NAME],
            variants => [
                {
                    image => sprintf("rdaw/%04d", $num) . "-" . $_->[$IMAGE],
                    vname => ""
                },
            ]
        };
        push @records, $record;
    }
} catch {
    print "Caught: $_\n";
};

open FORMAT, "|-", "jq .";
print FORMAT encode_json \@records;
close FORMAT;

# vim: set ts=4 sw=4 et nu:
