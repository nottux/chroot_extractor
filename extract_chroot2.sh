if [ -f "$HOME/mountedlist.txt.OLD" ]
then rm "$HOME/mountedlist.txt.OLD"
fi
if [ -f "$HOME/mountedlist.txt" ]
then mv "$HOME/mountedlist.txt" "$HOME/mountedlist.txt.OLD"
fi
if [ -f "$HOME/chroot_folder_locations.txt" ]
then echo "Here are the folders in $HOME/chroot_folder_locations.txt file :"
cat "$HOME/chroot_folder_locations.txt"
echo You can enter short names of the files to select them
eval $(cat "$HOME/chroot_folder_locations.txt" | while read -r line; do echo "$line;"; done | sed "s/\\\"/\\\\\"/g" | xargs | rev | cut -c 2- | rev)
else echo "$HOME/chroot_folder_locations.txt is not found, you can create the file and enter the short names of files like that :"
exs=n
echo "location1=\"/home/someuser/somefolder\""
echo "location2=\"/home/user/some folder\""
echo "Don't use a short name smaller than 4 characters and don't use any special characters"
fi
echo "Enter the file directory or short name of folder directory if available"
read n
m=$(eval "echo $(echo \$$n)")
if [ -n "$m" -a "$n" = $(echo $n | tr -d /) ]
then echo "$m folder selected"
n=$(echo "$m")
echo "List of .tar archives :"
ls $n | grep .tar
echo "Enter the name of the .tar archive to continue"
read tar
exs=y
kep=$(echo "$n")
n=$(echo "$n/$tar")
fi
whl=y
while [ $whl = y ]
do echo "Do you want to create a ramdisk ?"
read chs
if [ "$chs" = n -o "$chs" = N -o "$chs" = No -o "$chs" = no -o "$chs" = NO ]
then b=n
else b=e
fi
if [ "$chs" = y -o "$chs" = Y -o "$chs" = Yes -o "$chs" = yes -o "$chs" = YES ]
then b=y
fi
if [ "$b" = e ]
then echo "wrong entry, enter yes or no"
else whl=n
fi
done
if [ -f "$HOME/ramdisk_folder_locations.txt" ]
then nxt=y
else echo "$HOME/ramdisk_folder_locations.txt is not found, you can create the file and enter the short names of files like that :"
nxt=n
echo "location1=\"/home/someuser/somefolder\""
echo "location2=\"/home/user/some folder\""
echo "Don't use a short name smaller than 4 characters and don't use any special characters"
fi
if [ $b = y -a $nxt = y ]
then echo "Here are the folders in $HOME/ramdisk_folder_locations.txt file :"
eval $(cat "$HOME/ramdisk_folder_locations.txt" | while read -r line; do echo "$line;"; done | sed "s/\\\"/\\\\\"/g" | xargs | rev | cut -c 2- | rev)
cat "$HOME/ramdisk_folder_locations.txt"
echo "Enter a ramdisk directory or short name of ramdisk directory"
fi
if [ $b = y -a $nxt = n ]
then echo "Enter a ramdisk directory"
fi
nxt=h
if [ $b = y ]
then read rmd
nxt=e
rms=$(eval "echo $(echo \$$rmd)")
else rms=n
rmd=n
fi
if [ $nxt = e -a -n "$rms" -a "$rmd" = $(echo $rmd | tr -d /) ]
then echo "$rms folder selected"
rmd=$(echo "$rms")
fi
if [ $b = y ]
then echo "Enter size of the ramdisk by megabyte"
read ra
echo "Creating a ramdisk require root privileges, please enter sudo password when required"
mkdir -p "$rmd"
eval "sudo mount -t tmpfs -o size=$ra\m tmpfs '$rmd'"
fi
if [ $b = n ]
then echo "Please enter a directory to extract archive, be sure it's empty"
read rmd
fi
echo "Extracting require root privileges, please enter sudo password when required"
cd "$rmd"
sudo tar --same-owner -xvf "$n"
a=1
while [ "$a" = 1 -o "$a" = 2 -o "$a" = 3 -o "$a" = 4 -o "$a" = 5 ]
do echo "What do you want to do ?"
bt=e
echo "1) Repeat this dialog"
echo "2) Archive the chroot folder"
if [ $b = y ]
then echo "3) Unmount the ramdisk and exit"
fi
echo "4) Mount system folders"
echo "5) Unmount system folders"
echo "Enter something else to exit"
read a
if [ "$a" = 2 -a $exs = y ]
then echo "Do you want to backup to chroot folder ?"
read chs
else chs=n
fi
if [ "$chs" = n -o "$chs" = N -o "$chs" = No -o "$chs" = no -o "$chs" = NO ]
then bt=n
else bt=e
fi
if [ "$chs" = y -o "$chs" = Y -o "$chs" = Yes -o "$chs" = yes -o "$chs" = YES ]
then bt=y
fi
if [ "$bt" = e ]
then echo "wrong entry, try again"
a=1
fi
if [ "$a" = 2 ]
then echo "Enter the new archive name without .tar extension"
read nam
fi
if [ $bt = n -a "$a" = 2 ]
then echo "Enter a directory, don't put / to end"
read dir
fi
if [ $bt = y -a "$a" = 2 ]
then dir=$(echo "$kep")
fi
if [ "$a" = 2 ]
then sudo tar -C $(pwd) -cvpf "$dir/$nam.tar" $(ls)
echo "Archiving finished, press 1 to see dialog again"
fi
if [ "$a" = 3 -a $b = n ]
then echo "Wrong entry, try again"
a=1
fi
if [ "$a" = 3 -a $b = y ]
then echo "Unmounting and exiting"
cd ..
sudo umount "$rmd"
fi
if [ "$a" = 4 ]
then echo "Enter the directory without adding / sing to beginning"
echo "Like dev for /dev or usr/lib for /usr/lib"
echo "Mount history will be saved to $HOME/mountedlist.txt file"
echo "Older mount history will be in $HOME/mountedlist.txt.OLD file"
echo "Here is the mount list :"
cat "$HOME/mountedlist.txt"
read mnt
echo "/$mnt mounted to $(pwd)/$(ls)/$mnt" >> "$HOME/mountedlist.txt"
echo "Mounting requires root permissions"
sudo mount --bind "/$mnt" "$(ls)/$mnt"
fi
if [ "$a" = 5 ]
then echo "Enter the directory without adding / sing to beginning"
echo "Like dev for chrootfolder/dev or usr/lib for chrootfolder/usr/lib"
echo "Mount history will be saved to $HOME/mountedlist.txt file"
echo "Older mount history will be in $HOME/mountedlist.txt.OLD file"
echo "Here is the mount list :"
cat "$HOME/mountedlist.txt"
read mnt
echo "$(pwd)/$(ls)/$mnt unmounted" >> "$HOME/mountedlist.txt"
echo "Unmounting requires root permissions"
sudo umount "$(ls)/$mnt"
fi
done
