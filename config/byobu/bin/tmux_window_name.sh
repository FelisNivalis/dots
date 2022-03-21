#!/usr/bin/env bash

# # # # # # # # # #
# Orginal Author: Jason Cox <jasonxoc@gmail.com> https://www.linkedin.com/in/jason-cox-98444748/
# Date: 7/11/2019
# Rep: https://github.com/jasonxoc/nerdfonts-tmux
#
# Notes: This is made for me, uses macos commands
#      : Search: https://www.nerdfonts.com/cheat-sheet
#
# # # # # # # # # #

window_name="$1"
active_window="$2"

# Vim
vim_icon=""
vim_box_icon=""

# Configuration
conf_icon_active=""
conf_icon=""

# Languages
python_icon=""
ruby_icon=""
java_icon=""
js_icon=""
php_icon=""
php_icon_alt=""
css_icon=""
dotnet_icon=""
dotnet_icon_alt=""
xml_icon=""
html_icon=""
html_icon_alt=""
node_icon=""

# Frameworks
magento_icon=""
rails_icon=""
rails_icon_alt=""

# Platforms
apple_icon=""
windows_icon=""
windows_icon_alt=""
linux_icon=""
debian_icon=""
ubuntu_icon=""
ubuntu_icon_alt=""
android_icon=""
android_icon_alt=""
aws_icon=""
aws_icon_alt=""
angular_icon=""
bing_icon=""
bootstrap_icon=""
bash_icon=""

finder_icon=""
finder_icon_alt=$apple_icon

# Chat / Messaging
discord_icon="ﭮ"
discord_icon_alt=""
discord_icon_alt_active=""
discord_icon=$discord_icon_alt
discord_icon_active=$discord_icon_alt_active
chat_icon=""
chat_unread_icon=""
gmail_icon=""
mail_icon=""
mail_unread_icon="ﯬ"
irc_icon=""
irc_icon_active=""

irc_unread_icon=""

# Version Control
git_sync_icon=""
git_face_icon=""
git_commit_icon=""
git_icon=""

# Dbs
pgsql_icon=""
mysql_icon=""
db_icon=""
redis_icon=""
solr_icon=""
mongo_icon=""

# Shell
ssh_icon_active=""
ssh_icon=""
sh_icon=""
sh_icon_active=""

# Media
music_icon=""
music_icon_alt=""
photos_icon="ﯛ"
photos_icon_alt=""

# Coding
devcode_icon=""
log_icon=""

model_icon=""
model_icon_alt=""
controller_icon=""
controller_icon_alt=""
controller_icon_alt=""

view_icon=""
view_icon_alt="ﰦ"
templates_icon=""


# Random Icons
home_icon=""
apps_icon=""
atom_icon=""
box_bracket_icons=""
atlassian_icon=""
firefox_icon=""
flame_icon=""
ionic_icon=""
keys_icon=""
desktop_icon=""
box_icon=""
box_icon_active=""
braces_icon=""
brackets_icon=""
parenthesis_icon=""
tags_icon=""
cloud_icon=""
cloud_icon_active=""
chart_icon=""
iris_icon=""
bomb_icon="ﮏ"
blur_icon=""
biohazard_icon=""
television_icon=""
building_icon=""
infinity_icon="﮼"
rightarrow_icon=""
leftarrow_icon=""
evernote_icon=""

if [[ $active_window -gt 0 ]]; then
    sh_icon=$sh_icon_active
    ssh_icon=$ssh_icon_active
    conf_icon=$conf_icon_active
    irc_icon=$irc_icon_active
    discord_icon=$discord_icon_active
fi

case $window_name in
    git) icons=${git_icon};;&

    e:*|e-*) # Python Environments
        vim_icon="${vim_box_icon}"
        icons="$python_icon $icons" ;;&

    *ssh*) # SSH
        vim_icon="${vim_box_icon}"
        icons="${icons} ${ssh_icon}" ;;&

    # Databases
    *"pgsql"*|*"postgres"*|*"psql"*) icons="${icons} ${db_icon} ${pgsql_icon}" ;;&
    *"mysql"*) icons="${icons} ${db_icon} ${mysql_icon}" ;;&
    *"db") icons="${db_icon} $icons" ;;&
    *"solr"*) icons="${icons} ${solr_icon}" ;;&
    *"redis"*) icons="${icons} ${redis_icon}" ;;&
    *"mongo"*) icons="${icons} ${mongo_icon}" ;;&

    # Editors
    *"vim"*|*"vi") icons="${icons} ${vim_icon}" ;;&

    # Chat / Messaging
    *"discord"*|*"dscd"*) icons="${icons} ${discord_icon}" ;;&
    *"irc"*|*" chat"*|*"chat") icons="${icons} ${chat_icon}" ;;&

    # File Managers
    *"rngr"*|*"ranger") icons="${icons} ${finder_icon}" ;;&

    # Code / Configurations
    *" code"|"code") icons="${icons} ${devcode_icon}" ;;&
    *" log"|*"logs") icons="${icons} ${log_icon}" ;;&
    *"conf"|*"etc"*|*"dotfiles"|*" conf"*) icons="${icons} ${conf_icon}" ;;&

    # Languages:
    *"nvm"*|*"node") icons="${icons} ${node_icon}" ;;&
    *"js"*|*"javascript"*) icons="${icons} ${js_icon}" ;;&
    *"css"*|*"style") icons="${icons} ${css_icon}" ;;&
    *"java"*) icons="${icons} ${java_icon}" ;;&
    *"ruby"*) icons="${icons} ${ruby_icon}" ;;&
    *"rails") icons="${icons} ${ruby_icon}" ;;&
    *"php"*) icons="${icons} ${php_icon}" ;;&
    *".sh"*) icons="${icons} ${bash_icon}" ;;&

    # MVC Coding
    *"model"*|*" mdl"*) icons="${icons} ${mode_icon}" ;;&
    *" cont"*|*"controller"*) icons="${icons} ${controller_icon}" ;;&
    *"tpl"*|*" view"*|*"html"*) icons="${icons} ${view_icon}" ;;&

    # Platforms
    *"aws"|*"amzn"*) icons="${icons} ${aws_icon}" ;;&
esac

icons="$(echo $icons | sed 's/^ *//g')"
echo "${icons:-$sh_icon} $window_name"
