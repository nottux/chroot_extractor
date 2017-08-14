if [ -f "$HOME/is_eca_up.txt" ]
then eca=$(cat "$HOME/is_eca_up.txt")
else eca=n
fi
if [ -f "$HOME/ramdisk_folder_locations.txt" -a "$eca" = n ]
then echo "Here are the locations in $HOME/ramdisk_folder_locations.txt file :"
cat "$HOME/ramdisk_folder_locations.txt"
echo You can enter short names of the locations to select them
eval $(cat "$HOME/ramdisk_folder_locations.txt" | while read -r line; do echo "$line;"; done | sed "s/\\\"/\\\\\"/g" | xargs | rev | cut -c 2- | rev)
b=y
else b=n
fi
if [ "$b" = n -a "$eca" = n ]
then echo "$HOME/ramdisk_folder_locations.txt is not found, you can create the file and enter the short names of locations like that :"
echo "location1=\"/home/someuser/somefolder\""
echo "location2=\"/home/user/some folder\""
echo "Don't use a,n,m,line and b as short name and don't use any special characters"
b=y
fi
if [ "$b" = y -a "$eca" = n ]
then echo "Enter the folder directory or short name of directory if available"
read n
fi
if [ "$eca" = y ]
then eval $(cat "$HOME/script_locations.txt" | while read -r line; do echo "$line;"; done | sed "s/\\\"/\\\\\"/g" | xargs | rev | cut -c 2- | rev)
n="fd_ramdisk"
echo "Running in chroot extracting script"
fi
m=$(eval "echo $(echo \$$n)")
if [ -n "$m" -a "$n" = $(echo $n | tr -d /) ]
then echo "$m path selected"
n=$(echo "$m")
fi
echo "Enter size of the ramdisk by megabyte"
read ra
echo "Creating a ramdisk require root privileges, please enter sudo password"
mkdir -p "$n"
eval "sudo mount -t tmpfs -o size=$ra\m tmpfs '$n'"
a=6
while [ "$a" = 6 -o "$a" = 1 -o "$a" = 2 -o "$a" = 3 -o "$a" = 4 -o "$a" = 5 ]
do echo "What would you like to do now?"
echo "1) open up ramdisk directory with pcmanfm"
echo "2) open up ramdisk directory with nautilus"
echo "3) unmount the ramdisk"
echo "4) remount the ramdisk"
echo "5) delete .Trash-1000 folder"
echo "6) repeat this dialog"
echo "enter something else to exit"
read a
if [ "$a" = 1 ]
then pcmanfm "$n"
fi
if [ "$a" = 2 ]
then nautilus "$n"
fi
if [ "$a" = 3 ]
then echo "Unmounting require root privileges, enter password if asked"
sudo umount "$n"
fi
if [ "$a" = 4 ]
then echo "Remounting require root privileges, enter password if asked"
sudo umount "$n"
eval "sudo mount -t tmpfs -o size=$ra\m tmpfs '$n'"
fi
if [ "$a" = 5 ]
then echo "Deleting require root privileges, enter password if asked"
sudo rm -r "$n/.Trash-1000"
fi
done
