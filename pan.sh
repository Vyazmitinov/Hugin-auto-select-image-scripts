#!/bin/bash

useTime=1
useF=1
useA=1
useRes=1

if [ "$1" != "mv" -a "$1" != "cp" -a "$1" == "help" -a "$1" == "--help" ] ; then
	echo "Usage ./pan.sh command [checkTypes]"
	echo "Where command is cp or mv"
	echo "Where checkTypes can be a list with values CreationTime, FocusDistance, Aperture and Resolution. All are selected by default."
	exit
fi

if [ -n "$2" ] ; then
	useTime=`echo $@ | grep -i CreationTime | wc -l`
	useF=`echo $@ | grep -i FocusDistance | wc -l`
	useA=`echo $@ | grep -i Aperture | wc -l`
	useRes=`echo $@ | grep -i Resolution | wc -l`
fi

maxDiff=300

unixDate=""
prevDate="0"
prevName=""
prevF=""
prevA=""
prevRes=""
folderName=""

GetTimeStamp() {
	originDate=`exif -t 0x9003 -m $1 2>&1`
	isDate=`echo "$originDate" | grep Corrupt`
	if [ ${#isDate} -ne 0 ] ; then
		return 1
	fi
	originDate=${originDate/://}
	originDate=${originDate/://}
	unixDate=`date --date="$originDate" +'%s'`
	return 0
}

numFiles=`ls | grep -v _pan | grep DSC | wc -l`
i=1
createdFolders=0
copiedFiles=0
lastPanFile=0
ls | grep -v _pan | grep -i .jpg | while read fn; do 
	GetTimeStamp $fn
	if [ $? -eq 0 ] ; then
		diff=`expr $unixDate - $prevDate`
		currF=`exif -t 0x920a -m $fn 2>&1`
		currA=`exif -t 0x9202 -m $fn 2>&1`
		currRes=`identify $fn | awk '{print $3}'`

		echo "Processing $fn ($i of $numFiles) $unixDate - $prevDate = $diff"
		# Several checks.
		timeCheck=`test $diff -le $maxDiff && echo 1`
		[ $useTime -eq 0 ] && timeCheck=1
		fCheck=`test "$currF" = "$prevF" && echo 1`
		[ $useF -eq 0 ] && fCheck=1
		aCheck=`test "$currA" = "$prevA" && echo 1`
		[ $useA -eq 0 ] && aCheck=1
		resCheck=`test "$currRes" = "$prevRes" && echo 1`
		[ $useRes -eq 0 ] && resCheck=1

		echo "Time Check: $timeCheck"
		echo "Focus Check: $fCheck"
		echo "Aperture Check: $aCheck"
		echo "Resolution Check: $resCheck"

		if [ "$timeCheck" = "1" -a "$fCheck" = "1" -a "$aCheck" = "1" -a "$resCheck" = "1" ] ; then
			# If all checks passed.
			# Need to create new folder or move to the previous
			if [ ! -e $folderName ] ; then 
				echo "Create folder $folderName"
				mkdir $folderName
				createdFolders=`expr $createdFolders + 1`
				copiedFiles=`expr $copiedFiles + 1`
				$1 -v $prevName $folderName/$prevName
			fi
			$1 -v $fn $folderName/$fn
			copiedFiles=`expr $copiedFiles + 1`
			lastPanFile=1
		else
			if [ $lastPanFile -eq 1 ] ; then
				# Last file in the panaram. Run Hugin for this folder.
				lastPanFile=0
				cd $folderName
				files=`ls -C`
				echo "Run hugin for the \"$files\""
				hugin *
				cd ..
			fi
			folderName="$fn""_pan"
		fi
		prevDate="$unixDate"
		prevName="$fn"
		prevF=currF
		prevA=currA
		prevRes=currRes
	fi
	if [ $i -eq $numFiles ] ; then
		# Print the report.
		echo "Created $createdFolders folders."
		echo "Copied $copiedFiles files."
	fi
	i=`expr $i + 1`
done
