#!/usr/bin/env perl

use strict;
use warnings;

my $base = "https://veekun.com/dex/pokemon/"; # append name

my @pokies = qw(
	carbink goomy sliggoo goodra klefki phantump trevenant
	pumpkaboo gourgeist bergmite avalugg noibat noivern xerneas yveltal
	zygarde diancie hoopa volcanion rowlet dartrix decidueye litten
	torracat incineroar popplio brionne primarina pikipek trumbeak
	toucannon yungoos gumshoos grubbin charjabug vikavolt crabrawler
	crabominable oricorio cutiefly ribombee rockruff lycanroc wishiwashi
	mareanie toxapex mudbray mudsdale dewpider araquanid fomantis
	lurantis morelull shiinotic salandit salazzle stufful bewear bounsweet
	steenee tsareena comfey oranguru passimian wimpod golisopod sandygast
	palossand pyukumuku type%3A%20null silvally minior komala turtonator
	togedemaru mimikyu bruxish drampa dhelmise jangmo-o hakamo-o kommo-o
	tapu%20koko tapu%20lele tapu%20bulu tapu%20fini
	cosmog cosmoem solgaleo lunala nihilego buzzwole pheromosa xurkitree
	celesteela kartana guzzlord necrozma magearna marshadow
);

sub main {
	my $current = 703;
	my $filename;
	foreach my $pokie (@pokies) {
		$filename = "$current-$pokie.html";
		system qq!curl $base$pokie | ./filter.pl > $filename ! and die "Error";
		$current++;
	}
}

main();
