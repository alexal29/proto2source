#!/bin/bash -e

printUsage() {
    echo "subdir_clone: git clone only sub directory @ Alex"
    echo " "
    echo "Usage: subdir_clone.sh \$target"
}

if [ $# -eq 0 ] || [ $1 == '-h' ] || [ $1 == '--help' ]; then
    printUsage
		exit 0
fi


IFS='/' read -r -a array <<< "$1"

repo="${array[0]}/$(printf "/%s" "${array[@]:1:4}")"

dir=(${array[4]})

target=$(printf "/%s" "${array[@]:5}")
target=${target:1}

git clone \
  --depth 1  \
  --filter=blob:none  \
  --sparse \
  $repo \
; cd $dir; git sparse-checkout set $target \
; mv $target ../; cd .. ; rm -rf $dir