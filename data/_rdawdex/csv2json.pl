#!/usr/bin/env perl

use strict;
use warnings;
use JSON;
use Readonly;
use IO::Handle;
use Try::Catch;
use Text::CSV qw(csv);

Readonly my $DATAFILE => 'fakemon.csv';
Readonly my $URL      => 'https://darkandwindiefakemon.fandom.com/wiki/';

Readonly my $NUM    => 0;
Readonly my $GEN    => 1;
Readonly my $LETTER => 2;
Readonly my $NAME   => 3;
Readonly my $IMAGE  => 4;
Readonly my $DESC   => 5;

my @csvdata = ();
my $parser = Text::CSV->new({ binary => 1 });
open my $fh, "<:encoding(UTF-8)", $DATAFILE or die "Cannot read $DATAFILE: $!";
while (my $row = $parser->getline ($fh)) {
    push @csvdata, $row;
}
my @records = ();

try {
    foreach (@csvdata) {
        my $num = $_->[$NUM];
        my $record = {
            description => $_->[$DESC],
            generation => $_->[$GEN],
            id => $num,
            letter => $_->[$LETTER],
            name => $_->[$NAME],
            number => $_->[$NUM],
            url => $URL . $_->[$NAME],
            variants => [
                {
                    image => sprintf("%04d", 0+$num) . "-" . $_->[$IMAGE],
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
