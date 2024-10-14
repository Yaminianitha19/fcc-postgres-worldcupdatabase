#!/bin/bash

if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear previous data
$PSQL "TRUNCATE TABLE games, teams;"

# Read and insert data from games.csv
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals; do
  # Skip the header
  if [[ $year != "year" ]]; then
    
    # Insert unique teams
    for team in "$winner" "$opponent"; do
      # Insert team if not exists
      $PSQL "INSERT INTO teams (name) VALUES ('$team') ON CONFLICT (name) DO NOTHING;"
    done

    # Get IDs for winner and opponent
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

    # Insert the game
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
  fi
done
