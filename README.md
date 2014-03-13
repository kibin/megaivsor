Megaivsor Cover-Flow
===========

Маленький одностраничник на koa.js, умеющий работать с api Megavisor.com.

## Установка
    git clone git@github.com:kibin/megaivsor.git
    cd megaivsor && npm install && bower install

Генераторы не запускаются на версии ноды ниже 0.11.4, поэтому:

    npm install -g n && n 0.11.4

## Запуск

### Для продакшена
    gulp build && npm start

### Для разработки
    gulp
