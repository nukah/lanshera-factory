# Lanshera Harvester
## Structure
`Factory -> Workers -> Processes [ import, add, track ]`

RM project page: [dev](http://dev.sevenquark.com/projects/rb)

# Разворачивание среды

1. Установка RVM: [https://rvm.beginrescueend.com/](https://rvm.beginrescueend.com/)
2. Клонирование репозитория
`git clone git@github.com:nukah/lanshera-factory.git`
3. Установка ruby-1.9.3 и создание гемов
`https://rvm.beginrescueend.com/gemsets/basics/`
4. Установка bundler
`gem install bundler`
5. Запуск bundler в папке проекта
`bundle update`
6. Установка параметров конфига в config.yml
7. Запуск сервера Redis
8. Запуск worker-a:
`rake start`
9. Запуск тестового запроса:
`rake test:mine[ login , password ]`


_03.2012_