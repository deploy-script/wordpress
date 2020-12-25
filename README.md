# Wordpress

This script deploys latest Wordpress on Ubuntu.

**Note:** Should be used after deploying [LAMP](https://github.com/deploy-script/lamp)
It requires `/root/passwords.txt` file, if you want to install manually, follow the `install_wordpress()` lines in the [`script.sh`](https://github.com/deploy-script/wordpress/blob/master/script.sh#L42).

## :clipboard: Features

Here is whats installed:

 - Wordpress
 - Adminer
 
## :arrow_forward: Install

Should be done after deploying [LAMP](https://github.com/deploy-script/lamp)!

```
wget https://raw.githubusercontent.com/deploy-script/wordpress/master/script.sh && bash script.sh
```
