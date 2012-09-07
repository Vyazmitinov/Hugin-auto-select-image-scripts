#!/bin/bash

newSize=2500

if [ ! -e converted ] ; then
	mkdir converted
fi

echo "Find and convert all panarams from tif to jpg and move it in the convert directory"
ls | grep _pan |  while read folder; do
	# Convert and copy all tiff files to the destination folder.
	tiffFilesNumber=`ls $folder | grep .tif | wc -l`
	if [ $tiffFilesNumber -gt 0 ] ; then
		ls $folder | grep .tif | while read fn; do
			newName=${fn/.tif/.jpg}
			newName="${newName##*/}"
			convert -verbose $folder/$fn converted/$newName
		done
	fi
	# Check if we used all files for creation this panoramas.
	cd $folder
	ls | grep .jpg | while read fn; do
		imageInProject=`ls | grep ".pto.mk" | xargs cat | grep "/$fn'" | wc -l`
		if [ $imageInProject -eq 0 ] ; then
			# Copy image back into to the source folder.
			cp $fn ..
		fi
	done
	cd ..
done

echo "Resize all files and copy it into the 'convert' subdirectory"
numFiles=`ls | grep -v _pan | grep DSC | wc -l`
i=1
ls | grep -v _pan | grep DSC | while read fn; do
	echo "Resize $fn ($i of $numFiles)"
	convert -resize $newSize $fn converted/$fn
	i=`expr $i + 1`
done
