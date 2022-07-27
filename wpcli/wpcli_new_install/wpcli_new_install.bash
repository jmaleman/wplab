#!/bin/bash

# Author: José Miguel Alemán (jmaleman.dev)
# Version: 0.1
# Created on: April 26th 2022
# Requires WP-CLI, cURL, wget, DDEV with Docker Engine (Started)
# Tested on: Windows 10 (64-bits)

### Includes
source ./inc/appendline.bash

clear

### Retrieve information about site/app
read -p "Project? (Will be your folder name too): " project

mkdir $project
cd $project

### Download WordPress Core
echo ;
echo "--- Downloading lastest WordPress Core..."
wp core download --locale=es_ES

### Delete wp-config-sample.php file
echo ;
echo "--- Remove wp-config-sample.php file..."
rm wp-config-sample.php

### Delete xmlrpc.php file
echo ;
echo "--- Remove xmlrpc.php file..."
rm xmlrpc.php

echo ;
while true; do
    read -n1 -p "Do you want DDEV as local web server? [Y/n]: " yn
    case $yn in
        ""  ) ;;&
        Y|y )
            docker_status=$(ddev start 2>&1 > /dev/null )
            if echo "$docker_status" | grep -q "not connect"
            then
                echo ""
                echo "Docker not initialized. Start Docker before run this script."
            else
                echo ""
                read -p "Need more project information before install.Pulse a key..." null
                read -p "Project title?: " project_title
                read -p "Project admin user?: " project_admin_user
                read -p "Project admin password?: " project_admin_pass
                read -p "Project admin_email?: " project_admin_email                
                # Add new NFS new entry        
                check_ddev_entry $project

                if [ $? -eq 1 ]
                then
                # Add entry
                add_new_entry $project
                fi                        
                ddev config --project-type="wordpress" --project-name=$project --webserver-type="apache-fpm" --omit-containers="ddev-ssh-agent"
                ddev start
                # Core installation
                echo ""
                echo "--- Installing WordPress..."
                ddev wp core install --url=https://$project.ddev.site --title=$project_title --admin_user=$project_admin_user --admin_password=$project_admin_pass --admin_email=$project_admin_email                
            fi            
            
        break;;
        N|n ) exit;;
        *   ) echo "Please answer [Y/n].";;
    esac
done


### Update wp-config.php for DEV
echo "--- Config before install..."
# Debug
ddev wp config set WP_DEBUG true --raw
ddev wp config set WP_DEBUG_DISPLAY true --raw
ddev wp config set WP_DISABLE_FATAL_ERROR_HANDLER true --raw
# Others
ddev wp config set WP_POST_REVISIONS 10 --raw 



# Remove example posts, pages, plugins and inactive themes
echo "--- Cleaning default WordPress installation..."
ddev wp theme delete $(wp theme list --status=inactive --field=name)
ddev wp plugin delete --all
ddev wp post delete $(wp post list --post_type='page' --format=ids) --force
ddev wp post delete $(wp post list --post_type='post' --format=ids) --force
ddev wp comment delete $(wp comment list --status=approved --format=ids)

# Rewrite permalink structure
echo "--- Now let's set permalink structure"
ddev wp rewrite structure '/%postname%/' --hard
ddev wp rewrite flush --hard


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

