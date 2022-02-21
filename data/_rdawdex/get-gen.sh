#!/usr/bin/env bash
#
# See also https://docs.google.com/spreadsheets/d/11F5CxchGPaZFsPxI-bITquhT-3DPt2iTR22KnKcRTK8/edit
#

setup() {
    set -e # errors are fatal
    generation=${1:?Generation number (1-20) should be specified}
    set +e
    imgdir=images
    descdir=desc
    test -d $imgdir || mkdir $imgdir
    test -d $descdir || mkdir $descdir
    typeset -a romannumerals=(O I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XIX XX)
    typeset -a starting_numbers=(0 1 198 410 518 648 796 891 981 1100 1200 1275 1425 1576 1626 1701 1801 1931 2062 2205 2350)
    generation_roman=${romannumerals[$generation]}
    starting_number=${starting_numbers[$generation]}
    namesfile=names-gen${generation}.txt
    descfile=total-desc-gen${generation}.txt
}

fourdigit() {
    printf "%04d" "$1"
}

get_pokemon_list() {
    wget -c https://darkandwindiefakemon.fandom.com/wiki/Generation_${generation_roman} -O -
}

extract_image_urls() {
    awk '
        /href="https:\/\/static.wikia.nocookie.net\/darkandwindiefakemon\/images/ {
        gsub(/\/revision.*/, "", $0);
        gsub(/.*a href="https/, "https", $0);
        print;
    }'
}

reformat_image() {
    local filename="$1"
    local webpname="${filename$.png}"
    if !identify $filename | grep -q -s PNG; then
        echo Converting WEBP to PNG...
        mv $filename $webpname
        dwebp $webpname # saves *.png
        rm $webpname
    fi
}

# in: list of img_urls
# out: list of pokemon names
download_each_image() {
    cd $imgdir;
    local num=$starting_number
    while read img_url; do
        sleep 1
        baseimg=${img_url##*/}
        numberedname=$(fourdigit $num)-$baseimg
        wget -c $img_url -O $numberedname
        reformat_image $numberedname
        echo $baseimg | sed -e 's/\.png$//'
        let num++
    done
    cd ..
}

extract_description() {
    awk '
        /id="Pokédex_entry"/       { inside = 1 }
        /vertical-align/ && inside { inside = 2 }
        /^<\/p>$/                  { inside = 0 }
        inside == 2                { sub(/^<[^>]*>/, ""); buffer = buffer " " $0 }
        END                        { print buffer }
    '
}

remove_tags() {
    sed -e 's/<[^>]*>//g' -e 's/^ //'
}

recapitalize() {
    perl -ple 's/\b([[:upper:]]+)\b/ucfirst(lc($1))/eg'
}

# in: list of pokemon names
# out: list of pokemon descriptions
download_each_article() {
    cd $descdir
    local num=$starting_number
    while read name; do
        sleep 1
        wget -c https://darkandwindiefakemon.fandom.com/wiki/$name -O - |
            extract_description |
            remove_tags |
            recapitalize |
            tee $(fourdigit $num)-$name
        let num++
    done
    cd ..
}

main() {
    setup "$@"
    get_pokemon_list |
        extract_image_urls |
        download_each_image > $namesfile
    cat $namesfile |
        download_each_article > $descfile
    echo Please check the descriptions and images manually before continuing with the next step.
}

############################################################################
# main

main "$@"

