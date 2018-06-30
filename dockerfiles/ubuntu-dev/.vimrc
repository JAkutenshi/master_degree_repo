" =========================================
"               Config
" =========================================
" Показывать номера строк
set number
set relativenumber
" Включить подсветку синтаксиса
syntax on
" Поиск в процессе набора
set incsearch
" Подсвечивание результатов поиска
set hlsearch
" Кодировка текста по умолчанию utf8
set termencoding=utf8
" Включаем несовместимость настроек с Vi, так как Vi нам и не понадобится
set nocompatible
" Показывать положение курсора всё время.
set ruler
" Показывать незавершённые команды в статусбаре
set showcmd
" Фолдинг по отсупам
set foldenable
set foldlevel=100
set foldmethod=indent
" Не выгружать буфер, когда переключаемся на другой
" Это позволяет редактировать несколько файлов в один и тот же момент без необходимости сохранения каждый раз
" когда переключаешься между ними
set guioptions-=T
" Сделать строку команд высотой в одну строку
set ch=1
" Включить автоотступы
set autoindent
" Не переносить строки
set nowrap
" Преобразование Таба в пробелы
 set expandtab
" Размер табуляции по умолчанию
set shiftwidth=4
set softtabstop=4
set tabstop=4
" Включаем "умные" отступы, например, авто отступ после `{`
set smartindent
" Отображение парных символов
" set showmatch
" Навигация с учетом русских символов, учитывается командами следующее/предыдущее слово и т.п.
set iskeyword=@,48-57,_,192-255
" Удаление символов бэкспэйсом в Windows
set backspace=indent,eol,start
" Подсвечивать линию текста, на которой находится курсор
"set cursorline
"highlight CursorLine guibg=lightblue ctermbg=darkBlue
"highlight CursorLine term=none cterm=none
" Увеличение размера истории
set history=200
" Дополнительная информация в строке состояния
set wildmenu
" Настройка отображения специальных символов
set list listchars=tab:→\ ,trail:·
" Включение сторонних плагинов
filetype plugin on
" Все swap файлы будут помещаться в заданную директорию (туда скидываются открытые буферы)
set dir=~/.vim/swap/
" Если установлено set backup, то помещаются в этот каталог
set backupdir=~/.vim/backup/
" Решение проблемы с буфером обмена?
set clipboard=unnamedplus
" Перенос строк
set wrap
" Цветовая схема
colorscheme monokai
