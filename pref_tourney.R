library(PlayerRatings)

# Get players and number of games played from player/ratings file.

playerTable <- read.csv("player_table.csv") # read csv as a data frame

## convert factors to characters, for better functioning and
## to be compatible with glicko function
i <- sapply(playerTable, is.factor)
playerTable[i] <- lapply(playerTable[i], as.character)

## sort playerTable by Player
playerTable <- playerTable[order(playerTable$Player),]

players <- playerTable$Player
gamesPlayed <- playerTable$Games



firstGame <- 1

repeat{
  
  
  
  # choose two players w/o replacement, weighted relative to gamesPlayed
  pair <- sample(1:length(players), 2, prob = 1/(1 + gamesPlayed))

  
  
  # prompt for preference
  
  ## display choices
  cat("\014") # clear console
  message("(1) ", players[pair[1]])
  message("(2) ", players[pair[2]])
  
  ## repeat prompt until valid choice or return
  n <- -1
  while(n < 1 | n > 2){
    n <- readline("type choice, or return for exit: ")
    n <- ifelse(grepl("\\D",n),-1,as.integer(n))
    if(is.na(n)){break} # exits while-loop when hitting return
  }

  
  
  # exit repeat-loop if chooing not to continue
  if(is.na(n)){break}
  
  
  
  # record result
  
  ## on first game, create variables; on later games, append variables
  if(firstGame == 1){
    homeTeam <- players[pair[1]]
    awayTeam <- players[pair[2]]
    score <- 2 - n
  } else {
    homeTeam <- c(homeTeam, players[pair[1]])
    awayTeam <- c(awayTeam, players[pair[2]])
    score <- c(score,2 - n)
  }
  
  
  
  # update number of games played
  gamesPlayed[pair] <- gamesPlayed[pair] + 1
  
  
  
  firstGame <- 0
}



# if at least one game played, continue with rest of program
if(firstGame == 0){
  
  
  
  # format list of games for glicko function
  week <- rep(1,length(homeTeam)) # create the time period column
  
  ## create data frame for glicko
  gameList <- data.frame(Week = week, HomeTeam = homeTeam, AwayTeam = awayTeam,
                         Score = score)
  
  ## convert factors to characters, for better functioning and
  ## to be compatible with glicko function
  i <- sapply(gameList, is.factor)
  gameList[i] <- lapply(gameList[i], as.character)
  
  
  
  
  # format initializing status for glicko function
  
  ## convert Lag from date/time last played to weeks since played
  lastPlayed <- playerTable$Lag
  currentTime <- as.numeric(Sys.time()) 
  playerTable$Lag <- 1 + floor((currentTime - lastPlayed)/(7*24*3600))
  
  
  
  
  # compute ratings, sorted by player
  robj <- glicko(gameList, status = playerTable, sort = FALSE)
  
  
  
  
  # update the player/ratings file
  
  ## convert Lag to date/time last played
  lagBinary <- pmin(robj$ratings$Lag, 1)
  robj$ratings$Lag <- lastPlayed * lagBinary + currentTime * (1 - lagBinary)
  
  ## convert ratings to data frame
  robj.df <- do.call("rbind", lapply(robj["ratings"], as.data.frame))
  
  ## write new data to song/ratings file, without quotation marks or row names
  write.csv(robj.df, file = "player_table.csv", quote = FALSE,
            row.names = FALSE)
}