#!/bin/bash
# This is a script to periodically backup a folder to a gzipped archive
# This script should be running at all times
# If you want to use cron or anacron instead, change the USING_CRON variable to "true"

USING_CRON="false"

MAX_NUMBER_OF_BACKUPS=5
BACKUP_INTERVAL_IN_SECONDS=5

# Folder paths should NOT end with a trailing /
TARGET_FOLDER_PATH="/home/yourUserNameHere/theRestOfTheFolderPathHere"
FOLDER_TO_STASH_ALL_BACKUPS_INTO="/home/yourUserNameHere/theRestOfTheBackupFolderPathHere"





get_timestamp (){
	date -u +%Y%m%d%H%M%S
}

create_backup (){
	tar -czf "$FOLDER_TO_STASH_ALL_BACKUPS_INTO"/"$(get_timestamp)"".tar.gz" "$TARGET_FOLDER_PATH" 
}

is_backup_folder_full (){
	if [ "$(cd "$FOLDER_TO_STASH_ALL_BACKUPS_INTO"; ls | wc -l)" -gt "$MAX_NUMBER_OF_BACKUPS" ];
	then
		echo "true"
	else
		echo "false"
	fi
}

# Returns the path of the oldest backup
get_oldest_backup_path (){
	echo "$FOLDER_TO_STASH_ALL_BACKUPS_INTO"/"$(cd $FOLDER_TO_STASH_ALL_BACKUPS_INTO; ls | head -n 1)"
}

delete_extra_backups (){
	while [ "$(is_backup_folder_full)" = "true" ];
	do
		rm -rf "$(get_oldest_backup_path)"
	done
}



main_using_sleep_loop (){
	while true;
	do
		create_backup
		echo "Created backup"
		delete_extra_backups
		echo "Deleted extra backups"
		echo "Sleeping for $BACKUP_INTERVAL_IN_SECONDS seconds"
		sleep $BACKUP_INTERVAL_IN_SECONDS
	done
}

main_using_cron (){
	create_backup
	echo "Created backup"
	delete_extra_backups
	echo "Deleted extra backups"
}

if [ "$USING_CRON" = "true" ];
then
	main_using_cron
elif [ "$USING_CRON" = "false" ];
then
	main_using_sleep_loop
else
	echo "ERROR: You have set the variable USING_CRON to an invalid value."
fi

