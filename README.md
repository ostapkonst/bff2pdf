# BFF 2 PDF File converter

Конвертертер для формата файлов [ЭБС IPRbooks](https://www.iprbookshop.ru/). Набор скриптов конвертирует *.bff файлы в формат *.pdf. Конвертация происходит в несколько этапов, по этой причине её продолжительность может достигать десятков минут.

## Подготовка

Установить Python 3 и пакеты зависимостей командой `pip install -r requirements.txt`.

## Использование

Обязательным параметром является `--bff_file`, который указывает на путь до *.bff файла книги.

```
Usage: run_all --bff_file [--pdf_file] [--paused]

Example: run_all --bff_file=book.bff --pdf_file=conv_book.pdf

Default: run_all --pdf_file=<bff_file>.pdf --paused=true

Options:
    --bff_file=<string>
    --pdf_file=<string>
    --paused=[true|false]
```

Опционально можно указать путь выходного файла параметром `--pdf_file`.

## Результат

Результатом работы является один многостраничный *.pdf файл, каждая страница которого представляет собой изображение.
