#!/bin/sh

if test ! $(which composer)
then
  echo "  Installing composer for you."
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
fi

if test ! $(which homestead)
then
  echo "  Installing homestead for you."
  vagrant box add laravel/homestead --force
  composer global require "laravel/homestead=~2.0"
  homestead init
fi
