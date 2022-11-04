#!/usr/bin/env bash

########## CONSTANTS ##########
CONSTRAINTS=../formalization/*.isla
COVERAGE=coverage
COVERAGES_DIR=coverages
GRAMMAR=../formalization/rest.bnf
INP_FILE=../input.rst
ISLA="python3.10 -O -m isla"
JSON=json
POPULATION_DIR=population
RENDERER=../render_rst.py

########## HELPERS ##########

prepare () {
  rm -rf $POPULATION_DIR
  mkdir $POPULATION_DIR
  rm -rf $COVERAGES_DIR
  mkdir $COVERAGES_DIR
}

printInput () {
  echo '```rst'
  cat $1
  echo '```'
  echo 
}

########## COVERAGE / POPULATION MGMT FUNCTIONS ##########

randomPopulationMember () {
  # Echo the name of a random file in `$POPULATION_DIR`

  echo $POPULATION_DIR/$(ls $POPULATION_DIR | sort -R | tail -1)
}

getCoverage () {
  # Store the JSON coverage of the current input in file
  # `$new_coverage`, echo the name of this file.

  local cov_out=$(mktemp /tmp/new.json.XXXXXX)
  new_coverage=$(mktemp /tmp/new.json.XXXXXX)

  $COVERAGE run --source=docutils $RENDERER > /dev/null
  $COVERAGE json -o $cov_out > /dev/null
  
  # Remove metadata (e.g., time stamp), compute hash
  cat $cov_out | $JSON "files" > $new_coverage
  
  rm $cov_out
  echo $new_coverage
}

isNewCoverage () {
  # Return a 0 exit code iff the checksum of the file `$1$ already
  # exists in `$COVERAGES_DIR`.

  md5_hash=($(md5sum $1))
  find $COVERAGES_DIR -type f -exec md5sum {} + | grep $md5_hash > /dev/null
}

addToPopulationIfNewCoverage () {
  # If the current exit code is 1 (==> new coverage), copy `$INP_FILE` to
  # `$POPULATION_DIR` and the coverage files in `$1` to `$COVERAGES_DIR`,
  # where the file name is determined by the index in `$2`.

  if [ $? -eq 1 ]
  then
    echo "NEW coverage, adding input to population"
    cp $INP_FILE $POPULATION_DIR/inp_$2.rst
    cp $1 $COVERAGES_DIR/cov_$2.json
  else
    echo "NO new coverage, discarding input"
  fi
}

########## ISLa FUNCTIONS ##########

createInitialInput () {
  # Create an initial input at `$POPULATION_DIR/inp_0.rst` and
  # copy it to `$INP_FILE`

  $ISLA solve $GRAMMAR $CONSTRAINTS > $POPULATION_DIR/inp_0.rst
  cp $POPULATION_DIR/inp_0.rst $INP_FILE
}

mutateInput () {
  # Mutate the input in file `$1` and store it in `$INP_FILE`

  $ISLA mutate $1 $GRAMMAR $CONSTRAINTS -t 1 > $INP_FILE
}

##################################
########## MAIN ROUTINE ##########
##################################

main () {
  prepare
  
  # Create initial input
  createInitialInput
  
  echo "Initial input:"
  printInput $INP_FILE
  
  # Mutation loop
  cnt=1
  while true
  do
    echo 
    echo "=======================" 
    echo "Round $cnt" 
    echo "=======================" 
    echo
  
    # Choose a random population member
    next_inp=$(randomPopulationMember)
  
    # Mutate that input
    mutateInput $next_inp
    echo "New input:"
    printInput $INP_FILE
  
    # Get its coverage
    new_coverage=$(getCoverage)
  
    # Check if coverage is new
    isNewCoverage $new_coverage
  
    # If coverage is new, add input to population, store new coverage
    addToPopulationIfNewCoverage $new_coverage $cnt
    rm $new_coverage
  
    cnt=$((cnt+1))
  done
}

main "$@"