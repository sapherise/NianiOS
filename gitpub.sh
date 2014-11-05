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
if git branch master; then
if git merge $brc; then
git push
echo "completed"
fi
fi
fi
fi
