read -p "Enter DMG/PKG path: " package

if [ ! -f $package ]; then
    echo "File does not exist"
    exit 1
fi

if [[ $package == *.pkg ]]; then
    echo "Is a PKG"
    # Copy pkg into extracted directory
    xattr -d com.apple.quarantine $package
    mkdir "./extracted"
    cp $package "./extracted/"
elif [[ $package == *.dmg ]]; then
    echo "Is a DMG"

    # Mount DMG
    hdiutil mount $package -mountpoint "/Volumes/${package##*/}"
    # Extract files into extracted directory
    cp -a "/Volumes/${package##*/}/." "./extracted/"
else
    echo "Unrecognized file type"
    exit 1
fi

for file in "./extracted/"*; do
    echo $file
    if [[ $file != *.pkg ]]; then 
        continue 
    fi

    pkgutil --expand-full $file ./"$file"_extracted/

    for file2 in "$file"_extracted/*; do
        if [[ $file2 != *.pkg ]]; then 
            continue 
        fi

        filename=$(basename "$file2")

        mv "$file2/Payload" "./${filename%.*}/"
        xattr -d com.apple.quarantine -r "./${filename%.*}/"
    done
done

rm -r "./extracted"

if [[ $package == *.dmg ]]; then
    # Unmount DMG
    hdiutil unmount "/Volumes/${package##*/}"
fi