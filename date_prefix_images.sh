#!/usr/bin/env bash

# This script parses images and adds a prefix with the first available date and time to the filename.
# This is especially useful for images, as the metadata is usually lost after the optimization.
# Author: Sergey Musiyenko (www.sy.mk | www.musiyenko.com)

COLOR_RED="\033[1;31m"
COLOR_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_RESET="\033[0m"
TARGET=$1

# Comment out the next line to disable filename normalization
NORMALIZE_FILENAMES=1

# Check if exiftool exists
if ! command -v "exiftool" &> /dev/null
then
    echo -e "${COLOR_RED}exiftool is not installed on your system!"
    tput sgr0
    exit
fi

if [ "$#" != 1 ]; then
    echo -e "${COLOR_YELLOW}Usage: $0 [folder/file]"
    tput sgr0
    exit
fi

prefix_with_date() {
    number_of_images=$(find $TARGET -type f \( -iname '*.jpg' -or -name '*.jpeg' -or -name '*.png' \) -printf '.' | wc -c)
    iteration=1

    find $TARGET -type f \( -iname '*.jpg' -or -name '*.jpeg' \) | while read file; do
        echo -e "${COLOR_YELLOW}Processing image ${iteration}/${number_of_images}${COLOR_RESET}"
        let iteration++

        # Don't prefix already prefixed files
        if [[ "$file" =~ [[:digit:]]{8}_[[:digit:]]{6}___* ]]; then
            continue
        fi

        path="$(dirname "${file}")"
        filename="$(basename "${file%.*}")"
        extension="${file##*.}"

        if [ -n "$NORMALIZE_FILENAMES" ]; then
            filename=$(echo $filename | tr ' ' '_' | tr [:upper:] [:lower:])
            extension=$(echo $extension | tr [:upper:] [:lower:])
        fi

        creation_date_timestamp=$(exiftool -d "%Y%m%d_%H%M%S" -CreateDate "$file" | awk '{print $4}')
        modification_date_timestamp=$(exiftool -d "%Y%m%d_%H%M%S" -ModifyDate "$file" | awk '{print $4}')
        first_file_modification_date_timestamp=$(exiftool -d "%Y%m%d_%H%M%S" -FileModifyDate "$file" | awk '{print $5}')

        CREATION_DATE_FILENAME="${path}/${creation_date_timestamp}___${filename}.${extension}"
        MODIFICATION_DATE_FILENAME="${path}/${modification_date_timestamp}___${filename}.${extension}"
        FIRST_FILE_MODIFICATION_DATE_FILENAME="${path}/${first_file_modification_date_timestamp}___${filename}.${extension}"

        if [ "$creation_date_timestamp" != '' ] && [ "$creation_date_timestamp" != "0000:00:00" ]; then
            mv -n "$file" "$CREATION_DATE_FILENAME" 2>/dev/null

        elif [ "$modification_date_timestamp" != '' ] && [ "$modification_date_timestamp" != "0000:00:00" ]; then
            mv -n "$file" "$MODIFICATION_DATE_FILENAME" 2>/dev/null

        elif [ "$first_file_modification_date_timestamp" != '' ] && [ "$first_file_modification_date_timestamp" != "0000:00:00" ]; then
            mv -n "$file" "$FIRST_FILE_MODIFICATION_DATE_FILENAME" 2>/dev/null

        else
            continue
        fi
    done
}

cleanup() {
    echo -e "${COLOR_GREEN}Done."
    tput sgr0
}

main() {
    prefix_with_date
    cleanup
}

main
