#####
#   Script that finds best server and executes:
#       cd cs61c/proj4-amz-bam
#       make
#       ./benchmark
#
#
#   Takes a while to check the load of all the servers, so we
#   can change the servers used to 15-30 or so if we want to
#   speed it up a bit.
#
#   This script also requires that passwordless authentication
#   be set up:
#
#   To do this:
#   1. On your pc, generate auth keys
#       $ ssh-keygen -t rsa
#   2. Make .ssh directory on a hive machine.
#       $ ssh cs61c-xxx@hive2.cs.berkeley.edu mkdir -p .ssh
#   3. Append the public key you created to .ssh/authorized_keys on hive
#       $ cat ~/.ssh/id_rsa.pub | ssh cs61c-xxx@hive 'cat >> .ssh/authorized_keys'
#
USERNAME='cs61c-amz'
PROJECT_ROOT='~/cs61c/proj4-amz-bam'
# command run on ssh -- you can modify this to git pull, change dir, whatever
COMMAND='uptime; cd '$PROJECT_ROOT'; make -s; ./benchmark'

for i in {1..30}
do
    LINE='ssh -o StrictHostKeyChecking=no '$USERNAME'@hive'$i
    LINE+='.cs.berkeley.edu uptime'
    # fuck sed
    echo "CONNECTING TO " $i &
    LOAD_REGEX="e: ([0-9]*\.[0-9]+)"
    SSH_RETURN="$($LINE &)"
    # ensures servers not connected to aren't added to array
    # also, interestingly, gnu sort counts '0.00' as having a lesser
    # value, that is, sorted before blank, or no value
    # '0.00' < '' < '0.01' lol
    if [[ $SSH_RETURN == *load* ]]
    then
        OUTPUT[$i]="$SSH_RETURN"
        [[ ${OUTPUT[$i]} =~ $LOAD_REGEX ]]
        PAST_LOAD_AVG="${BASH_REMATCH[1]}"
        OUTPUT[$i]="$PAST_LOAD_AVG hive$i ${OUTPUT[$i]}"
    fi
done

# using IFS to arrayize sort output by newline as delimiter
OLDIFS=$IFS
IFS=$'\n' OUT=($(for n in "${OUTPUT[@]}"; do echo $n; done | sort -n ))
# restore old IFS because of multiple kinds of fuckery
IFS=$OLDIFS


echo "LIST OF SERVERS SORTED BY AVG LOAD"
echo "----------------------------------"
# need newline IFS to print out array. using a
# subshell to prevent IFS fuckery
( IFS=$'\n'; echo "${OUT[*]}" )
echo "----------------------------------"
BEST_SERVER="${OUT[0]}"
BEST_SERVER_REGEX="hive([0-9]*)"
[[ $BEST_SERVER =~ $BEST_SERVER_REGEX ]]
BEST_SERVER="${BASH_REMATCH[1]}"

echo "RUNNING BENCHMARKS ON BEST SERVER $BEST_SERVER"
echo "----------------------------------"
ssh "$USERNAME"@hive"$BEST_SERVER".cs.berkeley.edu $COMMAND 
echo "----------------------------------"

