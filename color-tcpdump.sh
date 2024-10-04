#!/bin/bash

# Проверка, если скрипту переданы аргументы
if [ "$#" -eq 0 ]; then
    echo "Использование: $0 [опции tcpdump]"
    echo "Пример: $0 -i eth0 port 80"
    exit 1
fi

# Запуск tcpdump с переданными параметрами
sudo stdbuf -oL tcpdump "$@" | while IFS= read -r line; do
    if echo "$line" | grep -q '{'; then
        # Предполагается, что JSON находится после символа '{'
        json_part=$(echo "$line" | grep --line-buffered -o '{.*}')
        
        # Попытка форматирования JSON с помощью jq
        colored_json=$(echo "$json_part" | jq . -cC 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            # Извлечение префикса строки до JSON
            prefix=$(echo "$line" | sed "s/{.*//")
            
            # Вывод префикса и раскрашенного JSON
            echo -e "${prefix}${colored_json}"
        else
            # Если jq не смог обработать JSON, выводим строку без изменений
            echo "$line"
        fi
    else
        # Если в строке нет JSON, выводим её без изменений
        echo "$line"
    fi
done
