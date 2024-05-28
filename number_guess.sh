#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#generate random number
SECRET_NUMBER=$((1+ $RANDOM % 1000))
#initialize games played to 0
GAMES_PLAYED=0

#prompt for username
echo "Enter your username:"
read USERNAME

#check if user exists
USERNAME_QUERY=$($PSQL "SELECT games_played, best_game FROM user_data WHERE username = '$USERNAME'")

#if user does not exist
if [[ -z $USERNAME_QUERY ]]
then
  #welcome message for new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  #add to database
  INSERT_USERNAME=$($PSQL "INSERT INTO user_data(username) VALUES('$USERNAME')")
else
  #display welcome message for returning user with data
  echo "$USERNAME_QUERY" | while IFS='|' read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

TOTAL_GUESSES=0
GUESS=-1
echo "Guess the secret number between 1 and 1000:"
while [[ $GUESS != $SECRET_NUMBER ]]
do
  #get guess from user
  read GUESS
  #increment total guesses
  ((TOTAL_GUESSES++))
  #if guess is not a number
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    #error message
      echo "That is not an integer, guess again:"
  #if user did input an integer
  else
    #check if guess is higher or lower than the number
    #if number matches, it should not enter either case here, and will exit the loop  
    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi
  fi
done

#get the user data
USERNAME_QUERY=$($PSQL "SELECT games_played, best_game FROM user_data WHERE username = '$USERNAME'")
echo "$USERNAME_QUERY" | while IFS='|' read GAMES_PLAYED BAR BEST_GAME
do
  if [[ $TOTAL_GAMES -lt $BEST_GAME || -z $BEST_GAME ]]
  then
    BEST_GAME=$TOTAL_GUESSES
  fi
  UPDATE_USER=$($PSQL "UPDATE user_data SET games_played = games_played + 1, best_game = $BEST_GAME WHERE username = '$USERNAME'")
done

#display victory message
echo "You guessed it in $TOTAL_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"