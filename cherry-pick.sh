#!/bin/bash

#COLORS

Red="\033[0;31m"
Green="\033[0;32m"
Brown="\033[0;33m"
Blue="\033[0;34m"
LightGray="\033[0;37m"
NC="\033[0m"

exitFailed () {
    printf "🛑 ✋ Exiting with status ${Red}FAILED${NC}"
    if [ ! -z "$1" ]
    then
        printf " with the following message:\n\n$1\n\n"
    else
        printf "\n\n"
    fi
    exit 0
}
    
exitSuccess () {
    printf "🟢 SUCCESS!"
    if [ ! -z "$1" ]
    then
        printf "$1\n\n"
    fi
    exit 1
}

echo""
printf "🍒 ${Blue}Picking Cherries!${NC} 🍒\n"
echo ""

branches=$(git for-each-ref --format='%(refname:short)' refs/heads)
currentAuthor=$(git config user.name)
currentBranch=$(git symbolic-ref --short HEAD)
newBranch="$currentBranch"-cherry-pick

arguments=$@
baseFlag="-b"
targetFlag="-t"

if [[ $arguments != *$baseFlag* || $arguments != *$targetFlag* ]]
then
    exitFailed "${Red}You need to specify the base branch [-b] AND the target branch [-t]${NC}"
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
    exitFailed "${Red}Base branch ${NC}$baseBranch${Red} not found${NC}"
fi

if [[ $branches != *$targetBranch* ]]
then
    exitFailed "${Red}Target branch ${NC}$targetBranch${Red} not found${NC}"
fi

if [[ $branches == *$newBranch* ]]
then
    exitFailed "$newBranch${Red} already exists...${NC}"
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
    printf "🍒 Cherry-picking $i from $currentBranch to $newBranch... 🍒\n"
    git cherry-pick -n $i
done

conflicts=$(git diff --name-status)
if [ ! -z "$conflicts" ]
then
    printf "${Red}Please resolve the following conflicts:${NC}\n\n"
    conflicts
    echo ""
    exitFailed
fi

git status

echo ""
exitSuccess
