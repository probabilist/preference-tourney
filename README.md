# Preference Tourney

Suppose you have a list of items that you want to order from your most favorite to your least favorite. This program allows you to run an unending sequence of games, pitting pairs of items against one another. You decide which of the pair you prefer. Through your decisions, R determines your preference ranking of all the items. It does this through the Glicko rating system.

## `prefTourney.R`

When you run this script, you will be presented with three choices, which are described below.

### Load file

When you choose "Load file", you tell R which file contains the items you wish to rank. The file you load must be a CSV file with seven columns labeled Player, Rating, Deviation, Games, Win, Draw, Loss, and Lag.

The Player column gives the names of the items. The Rating is a number expressing the strength of the preference. An item with a higher rating is preferred over an item with a lower rating. The Deviation is a number describing the program's confidence in the accuracy of the Rating. The smaller the Deviation, the higher the confidence. When creating a new file, or when adding items to a file, the Rating and Deviation should be set to 2200 and 300, respectively.

The Lag is the last time the item was involved in a game, written in the format "YYYY-MM-DD HH:MM:SS". For new items, the Lag should be set to the current time.

The other columns are self-explanatory, and their initial values should be 0. Note that Draw is not used in this program. Nonetheless, the column must appear in the file.

Once the file is loaded, you will be prompted with a sequence of games, pitting pairs of items from your CSV file against one another. Each time, you select the item you prefer. The items are chosen randomly. The more games an item has been involved in, the less likely it is to be chosen. You may continue as long as you wish. When you are done, the script will update your CSV file. Note that the updates will be written on top of the file, and the old contents of the file will be lost.

### Generate template

When you select this choice, R will create a CSV file listing ten movie titles. The file will already be in the correct format for the script to use. The script will then exit, giving you an opportunity to edit the template. You may change the names of the items and add or remove items as you like. When you are done editing, simply reload the script.

### View instructions

This option will simply display this README file.