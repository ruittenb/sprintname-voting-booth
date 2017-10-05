#!/usr/bin/env bash

baseurl=http://pokeapi.co/api/v2/pokemon/

for ((i=1; i<803; i++))
do
	echo "Fetching $i..."
	sleep 3
	wget -qO- "$baseurl$i" > $(printf "%03d" $i).json
done

