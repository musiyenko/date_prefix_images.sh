# date_prefix_images.sh

When working with images, especially for web, we tend to optimize and compress them. Almost always it leads to metadata loss, such as creation/modification dates.

This script parses images and adds a prefix with the first available date and time to the filename in the following order:

1. File creation date
2. File modification date
3. Last file modification date

Example:
> image name.JPG > 20200706-092940___image_name.jpg

# Tweaks
**Filename normalization** converts spaces to underscores and uppercase letters of a filename and an extension to lowercase.

```bash
# Comment out the next line to disable filename normalization
NORMALIZE_FILENAMES=1
```

# Dependencies
<https://github.com/exiftool/exiftool>

# FAQ

## How to customize filename format?
Modify the following variables:

```bash
CREATION_DATE_FILENAME="${path}/${creation_date_timestamp}___${filename}.${extension}"

MODIFICATION_DATE_FILENAME="${path}/${modification_date_timestamp}___${filename}.${extension}"

FIRST_FILE_MODIFICATION_DATE_FILENAME="${path}/${first_file_modification_date_timestamp}___${filename}.${extension}"
```

**Attention**: don't forget to modify this check to avoid prefixing already prefixed files!

```bash
# Don't prefix already prefixed files
if [[ "$file" =~ [[:digit:]]{8}_[[:digit:]]{6}___* ]]; then
    continue
fi
```
