#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

secret_number=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read username

#get username info

USER_INFO=$($PSQL "SELECT username,games_played,best_game FROM users WHERE username='$username'")


#if no exists
if [[ -z $USER_INFO ]];
  then
  #if no exists
  
  echo "Welcome, $username! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$username', 0, NULL)")

  games_played=0
  best_game=9999
  else
  #if exists
  IFS='|' read username games_played best_game <<< "$USER_INFO"
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

guess_count=0
guessed_correctly=false

echo "Guess the secret number between 1 and 1000:"

# Game loop for guessing
while [[ $guessed_correctly == false ]]; do
  read guess

  # Check if input is a number
  if ! [[ $guess =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif (( guess < secret_number )); then
    echo "It's higher than that, guess again:"
    ((guess_count++))
  elif (( guess > secret_number )); then
    echo "It's lower than that, guess again:"
    ((guess_count++))
  else
    # Correct guess
    ((guess_count++))
    echo "You guessed it in $guess_count tries. The secret number was $secret_number. Nice job!"
    guessed_correctly=true
  fi
done

((games_played++))
if [[ $guess_count -lt $best_game ]]; then
  best_game=$guess_count
fi

# Update user info in the database
UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$games_played, best_game=$best_game WHERE username='$username'")

