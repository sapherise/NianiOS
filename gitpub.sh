# !/bin/bash

msg=update
brc=Sa
if [ "$#" == "1" ]; then
	msg=$1
elif [ "$#" == "2" ]; then
	msg=$1
	brc=$2
fi

echo "commit to $brc"
if git add .; then
if git commit -a -m $msg; then
echo "merge to master"
if git checkout master; then
git pull
if git merge $brc; then
git push
git checkout $brc
echo "completed"
git checkout $brc
fi
fi
fi
fi
