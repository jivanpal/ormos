#!/bin/bash -e

cd ${BASH_SOURCE%/*}/mtgjson

echo "INSERT INTO card_name (name) VALUES"
cat AtomicCards.json \
| jq -r '
    .data
    | keys[]
    | "( \(. | @sh) ),"
' \
| sed -E "s/\'\\\'\'/\\\'/g ; $ s/,$/;/"
echo

echo "INSERT INTO card_oracle (id, name, text) VALUES"
cat AtomicCards.json \
| jq -r '
    .data
    | to_entries
    | map(.value)
    | flatten[]
    | select(
        ( .identifiers | has("scryfallOracleId") )
        and (
            (has("side") | not)
            or .side == "a"
        )
    )
    | "( UUID_TO_BIN(\(.identifiers.scryfallOracleId | @sh), TRUE), \(.name | @sh), \(if has("text") then .text else "" end | @sh) ),"
' \
| sed -E "s/\'\\\'\'/\\\'/g ; $ s/,$/;/"
echo

echo "INSERT INTO expansion_type (type) VALUES"
cat SetList.json \
| jq -r '
    .data
    | map(.type)
    | unique[]
    | @sh
    | "(\(.)),"
' \
| sed -E "s/\'\\\'\'/\\\'/g ; $ s/,$/;/"
echo

echo "INSERT INTO expansion (code, name, release_date, type) VALUES"
cat SetList.json \
| jq -r '
    .data[]
    | "( \(.code | @sh), \(.name | @sh), \(.releaseDate | @sh), \(.type | @sh) ),"
' \
| sed -E "s/\'\\\'\'/\\\'/g ; $ s/,$/;/"
echo

echo "INSERT INTO card_printing (id, oracle_id, expansion_code, collector_number) VALUES"
cat AllPrintings.json \
| jq -r '
    .data
    | to_entries
    | map(.value.cards)
    | flatten[]
    | select(
        ( .identifiers | has("scryfallOracleId") )
        and (
            (has("side") | not)
            or .side == "a"
        )
    )
    | "( UUID_TO_BIN( \(.identifiers.scryfallId | @sh), TRUE ), UUID_TO_BIN( \(.identifiers.scryfallOracleId | @sh), TRUE ), \(.setCode | @sh), \(.number | @sh) ),"
' \
| sed -E "s/\'\\\'\'/\\\'/g ; $ s/,$/;/"
echo
