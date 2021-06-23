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
    else
        printf "\n\n"
    fi
    exit 1
}

echo""
printf "🍒 ${Blue}Picking Cherries!${NC} 🍒\n\n"

branches=$(git for-each-ref --format='%(refname:short)' refs/heads)
currentAuthor=$(git config user.name)
currentBranch=$(git symbolic-ref --short HEAD)
newBranch="$currentBranch"-cherry-pick

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

if [ -z $baseBranch ] || [ -z $targetBranch ]
then
    exitFailed "${Red}You need to specify the base branch [-b] AND the target branch [-t]${NC}"
fi

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

git checkout $baseBranch
printf "${Brown}Updating ${Green}$baseBranch${NC}...\n"
git pull origin $baseBranch

echo ""
git checkout $targetBranch
printf "${Brown}Updating ${Green}$targetBranch${NC}...\n"
git pull origin $targetBranch

echo ""
printf "${Brown}Creating new branch ${Green}$newBranch${NC} from \'"$(git symbolic-ref --short HEAD)"\'...\n"
git checkout -b $newBranch

echo ""
printf "${Brown}Retrieving commits from ${NC}$currentBranch${Brown}...${NC}\n"
commitsSinceLastMerge=($(git log --pretty=%H $baseBranch..$currentBranch --author="$currentAuthor"))

numberOfCommitsSinceLastMerge=${#commitsSinceLastMerge[@]}
printf "${Brown}Preparing last $numberOfCommitsSinceLastMerge commits for cherry-picking${NC}
    \t${LightGray}Base branch:${NC} $baseBranch
    \t${Green}Target branch:${NC} $targetBranch\n\n"

for ((i=$numberOfCommitsSinceLastMerge-1; i>-1; i--))
do
    printf "🍒 ${Brown}Cherry-picking ${NC}${commitsSinceLastMerge[$i]}\n"
    git cherry-pick -n ${commitsSinceLastMerge[$i]}
done

if [ ! -z "$(git diff --name-status)" ]
then
    echo ""
    printf "${Red}Please resolve merge:${NC}\n\n"
    git diff --name-status
    echo ""
    exitFailed
fi

echo ""
git status

exitSuccess
