if [ -f "$HOME/script_locations.txt" ]
then echo "scripts exist and here are the script file locations :"
rdc=y
cat "$HOME/script_locations.txt"
echo "if something is wrong then exit and fix it"
eval $(cat "$HOME/script_locations.txt" | while read -r line; do echo "$line;"; done | sed "s/\\\"/\\\\\"/g" | xargs | rev | cut -c 2- | rev)
else echo "$HOME/script_locations.txt is not found, you can create the file and enter the short names of files like that :"
rdc=n
echo "Don't use a short name smaller than 4 characters and don't use any special characters"
echo "location1=\"/home/someuser/somefolder/somescript\""
echo "location2=\"/home/user/some folder/some script\""
echo "Use sc_ramdisk for ramdisk script directory"
echo "and fd_ramdisk for ramdisk folder directory"
fi
if [ -f "$HOME/chroot_file_locations.txt" ]
then echo "Here are the files in $HOME/chroot_file_locations.txt file :"
cat "$HOME/chroot_file_locations.txt"
echo You can enter short names of the files to select them
eval $(cat "$HOME/chroot_file_locations.txt" | while read -r line; do echo "$line;"; done | sed "s/\\\"/\\\\\"/g" | xargs | rev | cut -c 2- | rev)
else echo "$HOME/chroot_file_locations.txt is not found, you can create the file and enter the short names of files like that :"
echo "location1=\"/home/someuser/somefolder/somefile\""
echo "location2=\"/home/user/some folder/some file\""
echo "Don't use a short name smaller than 4 characters and don't use any special characters"
fi
echo "Enter the file directory or short name of directory if available"
read n
m=$(eval "echo $(echo \$$n)")
if [ -n "$m" -a "$n" = $(echo $n | tr -d /) ]
then echo "$m file selected"
n=$(echo "$m")
fi
#END#
if [ "$rdc" = y ]
then echo "Need to create a ramdisk folder?"
read rd
else rd=n
fi
if [ "$rd" = n -o "$rd" = N -o "$rd" = No -o "$rd" = no -o "$rd" = NO ]
then b=n
echo "Please enter a folder directory to extract"
read fd
mkdir -p "$fd"
cd "$fd"
echo n > $HOME/is_eca_up.txt
else b=e
fi
if [ "$rd" = y -o "$rd" = Y -o "$rd" = Yes -o "$rd" = yes -o "$rd" = YES ]
then echo "Launching the ramdisk creator script"
b=y
echo y > $HOME/is_eca_up.txt
echo "when you finish mounting ramdisk, hit enter to exit"
sh "$sc_ramdisk"
cd "$fd_ramdisk"
fi
if [ "$b" = e ]
then echo "wrong entry, ending"
exit
fi
echo "Extracting a chroot file require root privileges, please enter sudo password"
sudo tar --same-owner -xvf "$n"
echo n > $HOME/is_eca_up.txt
a=2
while [ "$a" = 2 -o "$a" = 1 -o "$a" = 3 ]
do echo "What would you like to do now?"
if [ "$b" = y ]
then echo "1) unmount the ramdisk and exit"
fi
echo "2) repeat this dialog"
echo "3) create a .tar archive containing the chroot folder"
if [ -f "$HOME/tar_locations.txt" -a "$a" = 3 ]
then echo "Here are the folders in $HOME/tar_locations.txt file :"
cat "$HOME/tar_locations.txt"
echo You can enter short names of the folders to select them
eval $(cat "$HOME/tar_locations.txt" | while read -r line; do echo "$line;"; done | sed "s/\\\"/\\\\\"/g" | xargs | rev | cut -c 2- | rev)
else wrn=y
fi
if [ "$wrn" = y -a "$a" = 3 ]
then echo "$HOME/tar_locations.txt is not found, you can create the file and enter the short names of files like that :"
echo "location1=\"/home/someuser/somefolder\""
echo "location2=\"/home/user/some folder\""
echo "Don't use a short name smaller than 4 characters and don't use any special characters"
echo $wrn
fi
if [ "$a" = 3 ]
then echo "Be sure there is nothing else except your chroot folder in the folder where you extracted your chroot archive"
echo "Enter the folder directory or short name of directory if available"
read n
m=$(eval "echo $(echo \$$n)")
fi
if [ -n "$m" -a "$n" = $(echo $n | tr -d /) -a "$a" = 3 ]
then echo "$m folder selected"
echo "enter .tar archive name"
read tar
n=$(echo "$m/$tar")
fi
if [ "$a" = 3 ]
then sudo tar -C $(pwd) -cvpf "$n" $(ls)
echo "finshed archiving, if you want to see menu again enter 2"
fi
read a
if [ "$a" = 1 -a "$b" = y ]
then echo "Unmounting require root privileges, enter password if asked"
cd ..
sudo umount "$fd_ramdisk"
exit
fi
if [ "$a" = 1 -a "$b" = n ]
then echo "Wrong entry try again"
fi
wrn=n
done
