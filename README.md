# BFF 2 PDF File converter
Конвертертер для формата файлов ЭБС IPRbooks. Набор скриптов конвертирует .bff файлы в формат .pdf. Конвертация происходит в несколько этапов, по этой причине её продолжительность может достигать десятков минут.

## Использование
Обязательными параметрами являются: --book_id и --bff_file. Первый — идентификаторм книги. Второй — путь до .bff файла.

	Usage: run_all --book_id --bff_file [--pdf_file] [--paused]
	
	Example: run_all --book_id=1 --bff_file=book.bff
	
	Default: run_all --pdf_file=book.pdf --paused=true
	
	Options:
	    --book_id=<number>
	    --bff_file=<string>
	    --pdf_file=<string>
	    --paused=[true|false]

Опционально можно указать путь выходного файла параметром --pdf_file.

## Результат
Результатом работы является один многостраничный .pdf файл, каждая страница которого представляет собой изображение.
