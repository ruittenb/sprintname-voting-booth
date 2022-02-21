#!/usr/bin/env bash
#
# See also https://docs.google.com/spreadsheets/d/11F5CxchGPaZFsPxI-bITquhT-3DPt2iTR22KnKcRTK8/edit
#

setup() {
    set -e # errors are fatal
    generation=${1:?Generation number (1-20) should be specified}
    imgdir=images
    descdir=desc
    test -d $imgdir
    test -d $descdir
    set +e
    typeset -a romannumerals=(O I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XIX XX)
    typeset -a starting_numbers=(0 1 198 410 518 648 796 891 981 1100 1200 1275 1425 1576 1626 1701 1801 1931 2062 2205 2350)
    generation_roman=${romannumerals[$generation]}
    starting_number=${starting_numbers[$generation]}
    namesfile=names-gen${generation}.txt
    descfile=total-desc-gen${generation}.txt
}

get_generation() {
    yes ${generation,,} | head -2501
}

get_number_sequence() {
    seq "$starting_number" 2501
}

get_names_and_images_list() {
    # TODO
    exit 2
}

get_desc_list() {
    # TODO
    exit 3
}

main() {
    setup "$@"

    # generate columns
    paste \
        <(get_number_sequence) \
        <(get_generation) \
        <(get_names_and_images_list) \
        <(get_desc_list)

}

############################################################################
# main

main "$@"

