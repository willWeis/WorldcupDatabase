#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Path to your data file
DATA_FILE="games.csv"

# Initialize associative arrays for team name to ID mapping
declare -A team_ids

# Read the data file to insert teams into the teams table
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  # Skip the header row
  if [ "$year" != "year" ]; then
    # Insert winner team if not already inserted
    if [ -z "${team_ids[$winner]}" ]; then
      $PSQL "INSERT INTO teams (name) VALUES ('$winner');"
      team_ids[$winner]=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
    fi
    # Insert opponent team if not already inserted
    if [ -z "${team_ids[$opponent]}" ]; then
      $PSQL "INSERT INTO teams (name) VALUES ('$opponent');"
      team_ids[$opponent]=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
    fi
  fi
done < $DATA_FILE

# Read the data file again to insert games into the games table
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  # Skip the header row
  if [ "$year" != "year" ]; then
    # Get the IDs for winner and opponent
    winner_id=${team_ids[$winner]}
    opponent_id=${team_ids[$opponent]}

    # Convert goals to integers
    winner_goals=$(($winner_goals))
    opponent_goals=$(($opponent_goals))

    # Insert the data into the games table with mapped IDs and converted goals
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
  fi
done < $DATA_FILE

# Ensure the script ends with a zero exit code
exit 0