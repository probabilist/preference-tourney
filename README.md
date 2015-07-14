# Preference Tourney

Suppose you have a list of items that you want to order from your most favorite to your least favorite. This program allows you to run an unending sequence of games, pitting pairs of items against one another. You decide which of the pair you prefer. Through your decisions, the program determines your preference ranking of all the items. It does this through the Glicko rating system.

## `player_table.csv`

This is a table with seven columns labeled Player, Rating, Deviation, Games, Win, Draw, Loss, and Lag.

The Player column gives the names of the items. The Rating is a number expressing the strength of the preference. An item with a higher rating is preferred over an item with a lower rating. The Deviation is a number describing the program's confidence in the accuracy of the Rating. The smaller the Deviation, the higher the confidence. When creating a new player table, or when adding items to a player table, the Rating and Deviation should be set to 2200 and 300, respectively.

The Lag is the last time the item was involved in a game, expressed as the number of seconds since 1969-12-31 19:00:00. For new items, the Lag should be set to the current time. This can be determined in R with the command, `as.numeric(Sys.time())`.

The other columns are self-explanatory, and their initial values should be 0. Note that Draw is not used in this program. Nonetheless, the column must appear in the file.

## `pref_tourney.R`

When this R script is run, you will be prompted with a sequence of games, pitting pairs of items from the player table against one another. Each time, you select the item you prefer. The items are chosen randomly. The more games an item has been involved in, the less likely it is to be chosen. You may continue as long as you wish. When you are done, the script will update the file, `player_table.csv`.

## `pref_tourney.odp`

This OpenDocument Presentation file is a flowchart of the basic structure of `pref_tourney.R`.

## `pref_tourney.pdf`

This is just a PDF export of `pref_tourney.odp`.