#!/bin/bash

# Author: José Miguel Alemán (jmaleman.dev)
# Version: 0.1
# Created on: April 26th 2022
# Requires DDEV with Docker Engine (Started)
# Tested on: Windows 10 Pro 22H2 (64-bits)
# Documentation: https://ddev.readthedocs.io/en/latest/users/quickstart/#wordpress

### Includes
# source ./inc/appendline.bash

# ------------------------------------------------------------------------------
# Colors
# ------------------------------------------------------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

clear
# $OSTYPE (OS exec);


### Retrieve information about site/app
read -p "Project name? (Will be your folder name too): " project

mkdir $project
cd $project


### Create a DDEV project
echo ;
echo "--- Creating DDEV config..."
ddev config --webserver-type=apache-fpm --project-type=wordpress
# Copy initial config files
# cp ../config.local.yml .ddev/
cp ../wp-cli.local.yml .
# Remove initial DDEV comment
line=$(cat -n wp-config.php | sed -n "/.*@package ddevapp.*/p" | sed -r 's/^[^0-9]+([0-9]+).*/\1/g')
newline=$(($line+1))
sed -i "2,${newline}d" wp-config.php
echo -e "[${GREEN}✓${NOCOLOR}] DDEV configuration created."

# Add Extra PHP configuration
read -r -d '' EXTRAPHP <<- EOF

/** Custom configurations */

/* Environment */
if (getenv("ENVIRONMENT") === "development") {
  define(' WP_ENVIRONMENT_TYPE' , 'development');  
  define(' WP_DEBUG_DISPLAY' , true);
  define(' WP_DISABLE_FATAL_ERROR_HANDLER' , true);
  defined( 'WP_DEBUG' ) || define( 'WP_DEBUG' , true );
} else {
  define(' WP_ENVIRONMENT_TYPE' , 'production');  
  define(' WP_DEBUG_DISPLAY' , false);
  define(' WP_DISABLE_FATAL_ERROR_HANDLER' , false);
  defined( 'WP_DEBUG' ) || define( 'WP_DEBUG' , false );
}

/* Memmory */
define(' WP_MEMORY_LIMIT' , '256M');
define(' WP_MAX_MEMORY_LIMIT' , '512M');

/* Backend */
define(' WP_POST_REVISIONS' , 5);
define(' AUTOSAVE_INTERVAL' , 160); // Seconds
define(' DISALLOW_FILE_EDIT' , true);
define(' AUTOMATIC_UPDATER_DISABLED' , true);

/** End Custom configurations */
EOF
EXTRAPHP+=$'\n'

echo ;
echo "--- Including extra PHP in wp-config.php..."
# From a file...
#sed -i '/.*Include wp-settings.php.*/r ../wp-config-local.php' wp-config.php
# From stdin
line=$(cat -n wp-config.php | sed -n "/.*Include wp-settings.php.*/p" | sed -r 's/^[^0-9]+([0-9]+).*/\1/g')
newline=$(($line-1))
sed -i "${newline}r /dev/stdin" wp-config.php <<< "$EXTRAPHP"
echo -e "[${GREEN}✓${NOCOLOR}] Extra PHP configuration included."

echo ;
echo "--- DDEV starting..."
ddev start
echo -e "[${GREEN}✓${NOCOLOR}] DDEV started."

### Download WordPress Core
echo ;
echo "--- Downloading lastest WordPress Core..."
ddev wp core download --locale=es_ES --skip-content
echo -e "[${GREEN}✓${NOCOLOR}] WordPress downloaded."

### Create 'wp-config.php' file
# echo ;
# echo "--- Creating 'wp-config.php' file..."
# rm wp-config.php
# ddev wp config create --dbname=db --dbuser=db --dbpass=db --dbhost='$DDEV_HOSTNAME' --locale=es_ES --skip-check
# echo -e "[${GREEN}✓${NOCOLOR}] WordPress config file created."

### Installation
echo ;
echo "--- Installing WordPress..."
# generate password using apg
# password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 16)
password=$(ddev wp core install --url=${DDEV_PRIMARY_URL} --title=$project --admin_user=admin --admin_email=me@example.org --skip-email | grep password | sed 's/Admin password: //')
echo $password
ddev wp theme install twentytwentythree --activate
cat <<- EOF > credentials.txt
User: admin
Pass: $password
EOF
echo -e "[${GREEN}✓${NOCOLOR}] Wordpress installed."

# Remove example posts, pages, plugins and inactive themes
# echo "--- Cleaning default WordPress installation..."
# ddev wp theme delete $(ddev wp theme list --status=inactive --field=name)
# ddev wp plugin delete --all
# ddev wp post delete $(ddev wp post list --post_type='page' --format=ids) --force
# ddev wp post delete $(ddev wp post list --post_type='post' --format=ids) --force
# ddev wp comment delete $(ddev wp comment list --status=approved --format=ids)

# Rewrite permalink structure
echo ;
echo "--- Now let's set permalink structure"
ddev wp rewrite structure\ '/%postname%/' --hard
ddev wp rewrite flush --hard
echo -e "[${GREEN}✓${NOCOLOR}] Permalink setted."

### Remove wp-config-sample.php file
echo ;
echo "--- Remove wp-config-sample.php file..."
rm wp-config-sample.php
echo -e "[${GREEN}✓${NOCOLOR}] Removed."

### Remove xmlrpc.php file
echo ;
echo "--- Remove xmlrpc.php file..."
rm xmlrpc.php
echo -e "[${GREEN}✓${NOCOLOR}] Removed."


# Download random images from Unsplash into a local folder, import them and set each as featured image related to the post
# echo "Get POST_ID, download image and set it as featured image"
# GET_POST_ID="$(wp post list --post_type=post --field=ID --format=csv)"

# mkdir mediaimport
# for post_id in ${GET_POST_ID[0]}; do
#     wget https://picsum.photos/1920/1200/\?random\&grayscale -O ~/Sites/dev/$site_name/mediaimport/unsplash_$post_id.jpg;
#     sleep 1m
#     wp media import ~/Sites/dev/$site_name/mediaimport/unsplash_$post_id.jpg --post_id=$post_id --title="A dummy picture for $post_id" --featured_image
# done


# Clone Theme repository
# echo "--- Clone Theme..."
# cd ./wp-content/themes
# git clone git@bitbucket.org:lemonmakers/ruta67theme.git


# Finish
start https://$project.ddev.site/wp-admin
echo "--- Script finish!"

