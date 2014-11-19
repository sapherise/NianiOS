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
if git checkout master; then
echo "update master"
if git pull; then
echo "merge changes"
if git merge "$brc" --no-edit; then
if git push; then
git checkout "$brc"
git merge master
echo "completed"
fi
fi
fi
fi
fi
fi