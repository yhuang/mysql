#!/bin/bash -e

function main {
	# Output of "aws s3 ls s3://br-ops/dumps/bleacherreport_production/"

	# 2015-01-23 19:19:58  136198752 bleacherreport_production_201501241003.sql.bz2
	# 2015-01-24 19:20:19  136033954 bleacherreport_production_201501251002.sql.bz2
	# 2015-01-25 19:21:04  135936386 bleacherreport_production_201501261003.sql.bz2
	# 2015-01-26 19:20:07  136096966 bleacherreport_production_201501271002.sql.bz2
	# 2015-01-27 19:21:40  135603300 bleacherreport_production_201501281002.sql.bz2
	# 2015-01-28 19:20:30  135956249 bleacherreport_production_201501291002.sql.bz2
	# 2015-01-29 19:20:08  135957474 bleacherreport_production_201501301002.sql.bz2
	# 2015-01-30 19:20:12  135754732 bleacherreport_production_201501311002.sql.bz2
	# 2015-01-31 19:20:21  135563343 bleacherreport_production_201502011002.sql.bz2
	# 2015-02-01 19:20:26  135200986 bleacherreport_production_201502021002.sql.bz2

	# cut -f1,5 -d " "
	#
	# Extract the first and fifth column of the output.
	#
	# Note: The third column is empty as denoted by the double spacing between the timestamp 
	# in the second column and the file size in the third column.  As a result, the actual 
	# filename resides in the fifth column.

	# sort -r | head -n 1
	# 
	# To get the latest snapshot, the output needs to be sorted in reverse lexicographical
	# order and then extract the first line.

	# Given the example in the comments, the value of the local variable output should be:
	#
	# 2015-02-01 bleacherreport_production_201502021002.sql.bz2	
	local output=`aws s3 ls s3://br-ops/dumps/bleacherreport_production/ | cut -f1,5 -d " " | sort -r | head -n 1`
	
	# Split the local variable output into a two-element array:
	#
	# ${output[0]} => "2015-02-01"
	# ${output[1]} => "bleacherreport_production_201502021002.sql.bz2"
	read -a columns <<<$output

	local snapshot=snapshots/${columns[1]}

	if [ ! -e $snapshot ]; then
		aws s3 cp s3://br-ops/dumps/bleacherreport_production/${columns[1]} $snapshot
	else
		echo "The latest BReport snapshot '${snapshot}' is already on the local file system."
		echo
	fi

	docker pull bleacher/mysql:empty

	echo
	echo "Launching the empty_db container from the bleacher/mysql:empty image..."
	echo
	docker run -d --name empty_db -e MYSQL_ROOT_PASSWORD=s -p :49256:3306 bleacher/mysql:empty
	sleep 10

	echo "Creating the br1 database inside the new empty_db container..."
	echo
	mysql -h 127.0.0.1 -u root -P 49256 -p -e 'create database br1;'
	
	echo "Dumping the latest snapshot into the br1 database..."
	echo 
	bzip2 -dc $snapshot | mysql -h 127.0.0.1 -u root -P 49256 -p br1

	echo "Writing the updated br1 database out to a new Docker image..."
	echo
	docker commit -m "DB Snapshot from ${columns[0]}" empty_db bleacher/mysql:${columns[0]}
	docker commit -m "DB Snapshot from ${columns[0]}" empty_db bleacher/mysql:latest

	echo "Pushing the new Docker image to the Hub..."
	echo
	docker push bleacher/mysql:${columns[0]}
	docker push bleacher/mysql:latest

	echo "Stopping and removing the empty_db container..."
	echo
	
	docker rm -f empty_db > /dev/null 2>&1
}

main

# Exit with 0 status to indicate success
exit 0