#!/bin/bash

add_new_entry(){

folderlinux=$(pwd)

folderwin=$(echo "$folderlinux" | sed -e 's/^\///' -e 's/\//\\/g' -e 's/^./\0:/')

newline=$(cat << EOF

# $1
$folderwin > $folderlinux

EOF
)

echo -e "\n$newline" >> ~/.ddev/nfs_exports.txt

}

check_ddev_entry(){
searchline=$(grep "$1" ~/.ddev/nfs_exports.txt)

if [ -z "$searchline" ]
then
  return 1
else
  return 10  
fi
}
