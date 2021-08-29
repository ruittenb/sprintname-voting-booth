#!/usr/bin/env bash

num=0
subdir=desc

cat names-gen1.txt | while read name; do
	let num++
	wget -c https://darkandwindiefakemon.fandom.com/wiki/$name -O - | \
		awk '
			/id="Pokédex_entry"/       { inside = 1 }
			/vertical-align/ && inside { inside = 2 }
			/^<\/p>$/                  { inside = 0 }
			inside == 2                { sub(/^<[^>]*>/, ""); buffer = buffer " " $0 }
			END                        { print buffer }
		' > $subdir/$(printf "%04d-" $num)$name
done

cat $subdir/* > total-desc.txt

