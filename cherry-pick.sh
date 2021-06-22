#!/bin/bash

echo "🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒🍒"
echo ""

#COLORS

Red="\033[0;31m"
Green="\033[0;32m"
Brown="\033[0;33m"
Blue="\033[0;34m"
LightGray="\033[0;37m"
NC="\033[0m"

branches=$(git for-each-ref --format='%(refname:short)' refs/heads)
currentAuthor=$(git config user.name)
currentBranch=$(git symbolic-ref --short HEAD)

arguments=$@
baseFlag="-b"
targetFlag="-t"

if [[ $arguments != *$baseFlag* || $arguments != *$targetFlag* ]]
    then
        printf "${Red}You need to specify the base branch [-b] AND the target branch [-t]${NC}\n\nExiting with status ${Red}FAILED${NC}\n"
        exit 0
fi
 
while getopts b:t: flag
do
    case $flag in
        b)
        baseBranch=$OPTARG;
        ;;
        t)
        targetBranch=$OPTARG;
        ;;
    esac
done

if [[ $branches != *$baseBranch* ]]
    then
        printf "${Red}Base branch ${NC}$baseBranch${Red} not found${NC}\n\nExiting with status ${Red}FAILED${NC}\n"
        exit 0
fi

if [[ $branches != *$targetBranch* ]]
    then
        printf "${Red}Target branch ${NC}$targetBranch${Red} not found${NC}\n\nExiting with status ${Red}FAILED${NC}\n"
        exit 0
fi

echo ""
git checkout $baseBranch
printf "${Brown}Updating ${Green}$baseBranch${NC}...\n"
git pull origin $baseBranch

echo ""
git checkout $targetBranch
printf "${Brown}Updating ${Green}$targetBranch${NC}...\n"
git pull origin $targetBranch

echo ""
newBranch="$currentBranch"-cherry-pick
printf "${Brown}Creating new branch ${Green}$newBranch${NC}...\n"
git checkout -b $newBranch

echo ""
printf "${Blue}Retrieving merged commits from $currentBranch${NC}...\n"
commitsSinceLastMerge=$(git log --pretty=%H $baseBranch..$currentBranch --author="$currentAuthor")

commitsByHash=( $commitsSinceLastMerge )
numberOfCommitsSinceLastMerge=${#commitsByHash[@]}
printf "${Brown}Preparing last $numberOfCommitsSinceLastMerge commits for cherry-picking${NC}
    \t${LightGray}Base branch:${NC} $baseBranch
    \t${Green}Target branch:${NC} $targetBranch\n"

for i in $commitsSinceLastMerge
do
    echo ""
    echo "🍒 Cherry-picking $i from $currentBranch to $newBranch... 🍒"
    git cherry-pick -n $i
done

git status

echo ""
printf "${Green}Done!${NC}\n"
exit 1
