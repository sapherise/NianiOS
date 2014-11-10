# !/bin/bash

msg=update
brc=Sa
if [ "$#" == "1" ]; then
	msg=$1
elif [ "$#" == "2" ]; then
	msg=$1
	brc=$2
fi

echo "commit to $brc with $msg"
if git add --all; then
if git commit -a -m "$msg"; then
echo "merge to master"
if git checkout master; then
git pull
if git merge "$brc" --no-edit; then
git push
git checkout "$brc"
git merge master
echo "completed"
fi
fi
fi
fi
