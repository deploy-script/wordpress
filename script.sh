#!/bin/bash

set -eu

trap end_install EXIT

#
##
update_system() {
    #
    apt update
    apt -yqq upgrade
}

#
##
install_base_system() {
    apt -yqq install perl 2>&1

    #
    echo "UTC" > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata >/dev/null 2>/dev/null
}

#
##
get_passwords() {
    # check if existing passwords file exists
    if [ ! -f /root/passwords.txt ]; then
        echo "Error: expecting /root/passwords.txt file to exist"
        exit 1
    else
        # load existing file
        set -o allexport
        source /root/passwords.txt
        set +o allexport
    fi
}

#
##
install_wordpress() {
    #
    cd /var/www/html

    #
    rm -f index.php
    rm -f index.html

    # download
    curl -O https://wordpress.org/latest.tar.gz

    # untar
    tar -zxvf latest.tar.gz

    # change dir to wordpress
    cd wordpress

    # copy file to parent dir
    cp -rf . ..

    # move back to parent dir
    cd ..

    # remove wordpress folder
    rm -R wordpress

    # create wp config
    cp wp-config-sample.php wp-config.php

    # set database details (find and replace)
    sed -i "s/database_name_here/$dbname/g" wp-config.php
    sed -i "s/username_here/$dbuser/g" wp-config.php
    sed -i "s/password_here/$dbpass/g" wp-config.php

    # set WP salts
    perl -i -pe'
    BEGIN {
        @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
        push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
        sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
    }
    s/put your unique phrase here/salt()/ge
    ' wp-config.php

    # create uploads folder and set permissions
    mkdir -p wp-content/uploads
    chmod 775 wp-content/uploads

    # change ownership
    chown www-data:www-data . -Rf

    # remove zip file
    rm latest.tar.gz
}

#
##
install_adminer() {
    #
    wget http://www.adminer.org/latest.php -O /var/www/html/adminer.php
    chown www-data:www-data /var/www/html/index.php
}

start_install() {
    #
    . /etc/os-release

    # check is root user
    if [[ $EUID -ne 0 ]]; then
        echo "You must be root user to install scripts."
        sudo su
    fi

    # check os is ubuntu
    if [[ $ID != "ubuntu" ]]; then
        echo "Wrong OS! Sorry only Ubuntu is supported."
        exit 1
    fi

    export DEBIAN_FRONTEND=noninteractive

    echo >&2 "Deploy-Script: [OS] $PRETTY_NAME"
}

end_install() {
    # clean up apt
    apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

    # return to dialog
    export DEBIAN_FRONTEND=dialog

    # remove script
    rm -f script.sh
}

#
##
main() {
    #
    start_install

    #
    update_system
    
    #
    install_base_system

    #
    get_passwords

    #
    install_wordpress

    #
    install_adminer
    
    #
    end_install

    echo >&2 "Wordpress install completed"
}

main
