#mkdir oci
#cd oci
pwd
sleep 20
ls -al
mkdir /home/steampipe/.ssh

export POWERPIPE_DATABASE=postgres://steampipe:e616_4d8c_abe4@steampipe:9193/steampipe
powerpipe mod init
#echo 'y' | powerpipe mod install github.com/turbot/steampipe-mod-oci-compliance
powerpipe server