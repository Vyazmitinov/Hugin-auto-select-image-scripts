There are two scripts for helping in work with Hugin on lage amount of sorce files. 
The idea is to find in folder files which can belong to one panaram and move it in separate folders. And automatically call Hugin 
for each folder.
Also Hugin generates tiff image and you need to convert it back in jpg manually. So there are convert.sh script which uses to 
search all tiff files and convert it into the jpeg files and move it into the "converted" folder. Also, If some of
jpeg files or even all of it was not used for generating panoramas, it will be copyed back to the source folder.

Requirments:
	exif
	ImageMagic
	Hugin
