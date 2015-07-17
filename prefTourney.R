input <- function(choices){
  # `choices` is a vector of strings of length at most 9, which will be
  # displayed in a numbered list. The user will be prompted to enter their
  # choice. The user can only enter a valid digit or press return. If they
  # enter a valid digit, the function returns that digit. If they press return,
  # the functions returns NA.
  
  
  # produce error is length of choices is greater than 9.
  if(length(choices) > 9){stop("number of choices must be less than 10")}
  
  
  # display choices
  numberedChoices <- paste0("(", 1:length(choices), ") ", choices)
  lapply(numberedChoices, cat, sep = "\n")
  
  
  # repeat prompt until valid choice or return
  n <- -1
  while(n < 1 | n > length(choices)){
    n <- readline("Type choice, or press return for exit: ")
    n <- ifelse(grepl("\\D",n),-1,as.integer(n))
    if(is.na(n)){break} # exits while-loop when hitting return
  }
  return(n)
}



prefTourney <- function(){
  # Display title
  cat("------------------",
      "Preference Tourney",
      "------------------", "", sep = "\n")
  
  
  repeat{
    # prompt for main menu choice
    menuChoice <- input(c("View instructions", "Generate template",
                          "Load file"))
    
    
    # exit function if chose to exit
    if(is.na(menuChoice)){return()}
    
    
    # exit repeat if not wanting instructions
    if(menuChoice != 1){break}
    
    
    # print instructions
    
    ## get script directory
    scriptDir <- getSrcDirectory(function(x) {x})
    if (scriptDir != ""){
      scriptDir <- paste0(scriptDir, "/")
    }
    
    ## show README file
    file.show("README.md")
    
    ## display message
    cat(sep = "\n", "",
"R should be displaying the README file. If you prefer to view it externally,",
"the file is called 'README.md' and is located in the same location as this",
"script. It can be viewed in a plain text editor, or in any application that",
"processes markdown code."
    )
    invisible(readline(prompt="Press [return] to continue"))
    cat("\n")
  }
  
  if(menuChoice == 2){
    # generate template
    
    ## get script directory
    scriptDir <- getSrcDirectory(function(x) {x})
    if (scriptDir != ""){
      scriptDir <- paste0(scriptDir, "/")
    }
    
    ## build dataframe
    Player <- c("Back to the Future", "Fight Club", "Forrest Gump",
                "Pulp Fiction", "Raiders of the Lost Ark", "Star Wars",
                "The Dark Knight", "The Matrix", "The Shawshank Redemption",
                "The Terminator")
    Rating = rep(2200,10)
    Deviation = rep(300,10)
    Games = rep(0,10)
    Win = rep(0,10)
    Draw = rep(0,10)
    Loss = rep(0,10)
    Lag = rep(as.POSIXct(Sys.time()),10)
    template <- data.frame(Player, Rating, Deviation, Games, Win, Draw, Loss,
                           Lag, stringsAsFactors = FALSE)
    
    ## create template
    write.csv(template, file = paste0(scriptDir, "prefTourney.csv"),
              quote = FALSE, row.names = FALSE)
    
    
    # display message and exit function
    cat(sep = "\n", "",
"A template file, prefTourney.csv, has been created in the same location as",
"this script. After you have modified it to include your own list of items,",
"reload this script."
    )
    return()
  }
  
  
  # prompt for file
  dataFile <- file.choose()

  
  # Get players and number of games played from player/ratings file.
  playerTable <- read.csv(dataFile) # read csv as a data frame
  
  ## convert factors to characters, for better functioning and
  ## to be compatible with glicko function
  i <- sapply(playerTable, is.factor)
  playerTable[i] <- lapply(playerTable[i], as.character)
  
  ## sort playerTable by Player to match output of glicko function
  playerTable <- playerTable[order(playerTable$Player),]
  
  players <- playerTable$Player
  gamesPlayed <- playerTable$Games
  
  
  firstGame <- 1
  repeat{
    # choose two players w/o replacement, weighted relative to gamesPlayed
    pair <- sample(1:length(players), 2, prob = 1/(1 + gamesPlayed))
    
    
    # prompt for preference
    cat("\nWhich do you prefer:\n")
    preference <- input(players[pair])
    
    
    # exit repeat-loop if chooing not to continue
    if(is.na(preference)){break}
    
    
    # record result
    
    ## on first game, create variables; on later games, append variables
    if(firstGame == 1){
      homeTeam <- players[pair[1]]
      awayTeam <- players[pair[2]]
      score <- 2 - preference
    } else {
      homeTeam <- c(homeTeam, players[pair[1]])
      awayTeam <- c(awayTeam, players[pair[2]])
      score <- c(score,2 - preference)
    }
    
    
    # update number of games played
    gamesPlayed[pair] <- gamesPlayed[pair] + 1
    
    
    firstGame <- 0
  }

  
  # exit function if no games played
  if(firstGame == 1){return()}
  
  
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
  lastPlayed <- as.numeric(as.POSIXct(playerTable$Lag))
  currentTime <- as.numeric(Sys.time()) 
  playerTable$Lag <- 1 + floor((currentTime - lastPlayed)/(7*24*3600))
  
  
  # compute ratings, sorted by player
  robj <- PlayerRatings::glicko(gameList, status = playerTable, sort = FALSE)
  
  
  # update the player/ratings file
  
  ## convert Lag to date/time last played
  lagBinary <- pmin(robj$ratings$Lag, 1)
  robj$ratings$Lag <- as.POSIXct(
    lastPlayed * lagBinary + currentTime * (1 - lagBinary),
    origin = "1970-01-01")
  
  ## convert ratings to data frame
  robj.df <- do.call("rbind", lapply(robj["ratings"], as.data.frame))
  
  ## write new data to song/ratings file, without quotation marks or row names
  write.csv(robj.df, dataFile, quote = FALSE, row.names = FALSE)
}

prefTourney()