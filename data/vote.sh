#!/usr/bin/env bash
#
# This script requires sponge(1)

set -e -o pipefail

############################################################################
# functions

usage()
{
	{
		echo
		echo "Usage: $0 <user> <index> <vote>"
		echo "    <user> : user id, e.g. 'rene_uittenbogaard@proforto_nl'"
		echo "    <index>: pokemon number (0 - 900), e.g. 25"
		echo "    <vote> : 0, 1, 2 or 3"
		echo
	} >&2
}

main()
{
	FILE=users.json

	user=${1:?$(usage)"'user' is missing"}
	index=${2:?$(usage)"'index' is missing"}
	vote=${3:?$(usage)"'vote' is missing"}

	if [[ $index -lt 0 ]] || [[ $index -gt 900 ]]; then
		usage
		echo "Error: 'index' is out of range" >&2
		exit 1
	fi

	if ! [[ $vote =~ ^[0-3]$ ]]; then
		usage
		echo "Error: 'vote' is out of range" >&2
		exit 2
	fi

	# fetch old vote
	oldvote=$(
		jq -r ".\"$user\".ratings[$index:$((index + 1))]" $FILE
	)

	# set new vote
	jq ".\"$user\".ratings |= sub(\"(?<prematch>^.{$index}).\"; .prematch + \"$vote\")" $FILE | sponge $FILE
	#jq "to_entries[] | select(.key|startswith(\"$user\")) | .value.ratings |= sub(\"(?<prematch>^.{$index}).\"; .prematch + \"$vote\")" $FILE | sponge $FILE # Doesn't work (yet)

	# explain what we did
	echo -e "User:  $user\nIndex: $index\nVote:  $oldvote -> $vote"
}

############################################################################
# main

main "$@"

