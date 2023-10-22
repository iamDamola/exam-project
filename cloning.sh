clone_laravel(){
    echo "Cloning Laravel from github"
    mkdir /var/www/html/laravel && cd /var/www/html/laravel
    sudo chown -R vagrant:www-data /var/www/html/laravel
    git clone "https://github.com/laravel/laravel" /var/www/html/laravel
    cd /var/www/html/laravel
    composer install --no-dev
    echo "laravel application cloned"
}