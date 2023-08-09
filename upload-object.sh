#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
    echo 'Для работы, скрипту необходимы следующие аргументы:
    - номерной домен аккаунта, например: 123456;
    - пароль;
    - имя контейнера;
    - [путь до файла/]имя файла.
Проверь и попробуй еще раз!'
    exit
fi

if [ ! -z "$5" ]; then
    echo 'Введен лишний аргумент. Проверь и попробуй еще раз!'
    exit
fi

LOGIN=$1
PASSWORD=$2
CONTAINER_NAME=$3
FILE_NAME=$4
REMOTE_HOST='auth.selcdn.ru'


function takeinfo {
  (echo 'GET / HTTP/1.1' 
  echo 'Host: auth.selcdn.ru' 
  echo 'user-agent: curl/7.81.0' 
  echo 'accept: */*' 
  echo 'x-auth-user: $LOGIN' 
  echo 'x-auth-key: $PASSWORD' 
  echo '' 
  #echo "Connection: close"
  ) | netcat $REMOTE_HOST 80 
}

URL_AUTH=`curl -i -XGET "https://auth.selcdn.ru/" -H "X-Auth-User: $LOGIN" -H "X-Auth-Key: $PASSWORD" | grep x-storage-url | awk '{print $2}'| grep -oP 'https://\K[^/]+'`
TOKEN=`curl -i -XGET "https://auth.selcdn.ru/" -H "X-Auth-User: $LOGIN" -H "X-Auth-Key: $PASSWORD"  | grep x-storage-token | awk '{print $2}'`
FILE_SIZE=$(stat -c %s "$FILE_NAME")
URL=/$CONTAINER_NAME/$FILE_NAME
echo $FILE_SIZE
(
  echo "PUT $URL HTTP/1.1"
  echo "Host: $URL_AUTH"
  echo "user-agent: curl/7.81.0"
  echo "accept: */*"
  echo "x-Auth-Token: $TOKEN"
  echo "content-Length: $FILE_SIZE"
#  echo "connection: close"
  echo ""
  cat "$FILE_NAME"
) | netcat $URL_AUTH 80
