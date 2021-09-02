#!/usr/bin/env bash

num=198
subdir=desc
test -d $subdir || mkdir $subdir

cat names-gen2.txt | while read name; do
	wget -c https://darkandwindiefakemon.fandom.com/wiki/$name -O - | \
		awk '
			/id="Pokédex_entry"/       { inside = 1 }
			/vertical-align/ && inside { inside = 2 }
			/^<\/p>$/                  { inside = 0 }
			inside == 2                { sub(/^<[^>]*>/, ""); buffer = buffer " " $0 }
			END                        { print buffer }
		' > $subdir/$(printf "%04d-" $num)$name
	let num++
done

cat $subdir/* > total-desc-gen2.txt

