#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing -t --no-align -c"
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  # No user yet added
  USER_INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # User exists
  IFS="|" read GAME_COUNT BEST_SCORE <<< $($PSQL "SELECT COUNT(game_id), MIN(guesses) FROM games WHERE user_id='$USER_ID'")
  echo "Welcome back, $USERNAME! You have played $GAME_COUNT games, and your best game took $BEST_SCORE guesses."
fi
echo "Guess the secret number between 1 and 1000:"
read GUESS
while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
done
GUESSES=1
until (( $GUESS == $RANDOM_NUMBER ))
do
  if (( $GUESS > $RANDOM_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done
  GUESSES=$(( $GUESSES + 1 ))
done
GAME_INSERT_RESULT=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($GUESSES, $USER_ID)")
echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
