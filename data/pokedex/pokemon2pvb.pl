#!/usr/bin/env perl 

use strict;
use warnings;
use File::Slurp;
use JSON;
use IO qw(Handle);

STDERR->autoflush();

my $imgBaseUrl = 'https://assets.pokemon.com/assets/cms2/img/pokedex/full/%03d.png';

############################################################################
# functions

# { url = "https://bulbapedia.bulbagarden.net/wiki/Squirtle_(Pok%C3%A9mon)"
# , image = "https://img.pokemondb.net/artwork/squirtle.jpg"
# , name = "Squirtle"
# , number = 7
# }

sub gen
{
	my ($num) = @_;
	my $generation;
	for ($num)
	{
		  0 == $_              and $generation = 0;
		  1 <= $_ && $_ <= 151 and $generation = 1;
		152 <= $_ && $_ <= 251 and $generation = 2;
		252 <= $_ && $_ <= 386 and $generation = 3;
		387 <= $_ && $_ <= 493 and $generation = 4;
		494 <= $_ && $_ <= 649 and $generation = 5;
		650 <= $_ && $_ <= 721 and $generation = 6;
		722 <= $_ && $_ <= 802 and $generation = 7;
	}
	return $generation;
}

sub main
{
	my ($apiJsonText, $pvbJsonText, $apiData, $pvbData, $pokemonNum, $pokemonName);
	print qq'{ "pokedex": [\n';
	foreach (<*.json>) {
		$apiJsonText = read_file($_);
		$apiData = decode_json $apiJsonText;
		$pokemonName = ucfirst $apiData->{name};
		$pokemonNum = $apiData->{id};
		$pvbData = {
			id => $pokemonNum,
			generation => gen($pokemonNum),
			letter => substr($pokemonName, 0, 1),
			number => $pokemonNum,
			name => $pokemonName,
			url => "https://bulbapedia.bulbagarden.net/wiki/${pokemonName}_(Pok%C3%A9mon)",
			image => sprintf($imgBaseUrl, $pokemonNum),
		};
		$pvbJsonText = encode_json $pvbData;
		print STDERR "Processed $pokemonNum...\n";
		print "$pvbJsonText,\n";
	}
	print  "]\n}\n";
	return;
}

############################################################################
# main

main();

