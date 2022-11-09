# Ormos

**Ormos** is a web app for keeping inventory of [*Magic: the Gathering*](https://magic.wizards.com) cards.
It is an open-source, self-hosted alternative to existing services such as [Deckbox](https://deckbox.org)
and [TappedOut.net](https://tappedout.net). It also provides an interactive database of all *Magic*
cards ever printed, similar to the official [Gatherer](https://gatherer.wizards.com/) database and
others such as [Scryfall](https://scryfall.com/). Ormos is named after the *Magic* card
[Ormos, Archive Keeper](https://scryfall.com/card/jmp/13/ormos-archive-keeper).

## Dependencies

This project uses [MariaDB](https://mariadb.org) 10.6 (LTS).

You will need [Bash](https://www.gnu.org/software/bash/) and [jq](https://stedolan.github.io/jq/) in
order to generate the initial database import.

## Setup

This project uses [MTGJSON](https://mtgjson.com/) v5.2 to obtain the base card data. To generate the
database import, create a folder `mtgjson`, [download](https://mtgjson.com/downloads/all-files/) the
MTGJSON files `AtomicCards.json`, `AllPrintings.json`, and `SetList.json`, saving them in that folder,
and then run `./generate-ormos-data.sh > ormos-data.sql`. You can then create the database schema and
import the data by sourcing the files `ormos-schema.sql` and `ormos-data.sql` in MariaDB. (WARNING!
Doing this will overwrite/delete any existing data in the database/schema named `ormos`, if you already
have one. This includes your inventory data!)

```
SOURCE ormos-schema.sql;
SOURCE ormos-data.sql;
```
