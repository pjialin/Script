"====================================
"   FileName: .vimrc
"   Author:   Jialin
"   Version:  1.0.0
"   Email:    admin@pjialin.com
"   Blog: http://pjialin.com
"   Date: 2016.03.09
"=============================================
" If need plugin Please Install Vundle And Down .vimrc.bundles
" git clone https://github.com/gmarik/vundle.git .vim/bundle/vundle
"=============================================



"==================================
"    Vim基本配置
"===================================

"关闭vi的一致性模式 避免以前版本的一些Bug和局限
set nocompatible
"配置backspace键工作方式
set backspace=indent,eol,start

"显示行号
set number
"设置在编辑过程中右下角显示光标的行列信息
set ruler
"当一行文字很长时取消换行
set nowrap

"在状态栏显示正在输入的命令
set showcmd

"设置历史记录条数
set history=1000

"设置取消备份 禁止临时文件生成
set nobackup
set noswapfile

"突出现实当前行列
"set cursorline
"set cursorcolumn

"设置匹配模式 类似当输入一个左括号时会匹配相应的那个右括号
set showmatch

"设置C/C++方式自动对齐
set autoindent
set cindent

"开启语法高亮功能
syntax enable
syntax on

"指定配色方案为256色
set t_Co=256

"设置搜索时忽略大小写
set ignorecase

"设置在Vim中可以使用鼠标 防止在Linux终端下无法拷贝
"set mouse=a

"设置Tab宽度
set tabstop=4
"设置自动对齐空格数
set shiftwidth=4
"设置按退格键时可以一次删除4个空格
set softtabstop=4
"设置按退格键时可以一次删除4个空格
set smarttab
"将Tab键自动转换成空格 真正需要Tab键时使用[Ctrl + V + Tab]
set expandtab

"设置编码方式
set encoding=utf-8
"自动判断编码时 依次尝试一下编码
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1



"检测文件类型
filetype on
"针对不同的文件采用不同的缩进方式
filetype indent on
"允许插件
filetype plugin on
"启动智能补全
filetype plugin indent on

"-----------Setting----------"
"The default leader is \, but a coma is much better.
let mapleader = ','
"Macvim-specific line-height.
set linespace=15

"-----------Search----------"
set hlsearch   "exec nohlsearch to cenec search
set incsearch  "searching

"-----------Split--------"
nmap <C-H> <C-W><C-H>
nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-L> <C-W><C-L>

"-----------Mappings--------"
"Make it easy to edit the Vimrc file.
nmap <leader>ev :tabedit $MYVIMRC<cr>

"Add simple highlight removal.
nmap <leader><space> :nohlsearch<cr>

"Make NERDTreeToggle
nmap ƒ :NERDTreeToggle<cr>

"Make jj to Esc
imap jj <Esc>

"Ctrlp
"nmap <c-R> :CtrlPBufTag<cr>
nmap <D-e> :CtrlPMRUFiles<cr>


" 解决粘贴格式错乱
set pastetoggle=<F9>


"-------------Plugins--------------"
""/
"/ CtrlP
""/
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'
""


"-----------Auto-Commands-------"
augroup Soureing
    autocmd BufWritePost .vimrc source %
augroup END


"引入插件列表
if filereadable(expand("~/.vimrc.bundles"))
    source ~/.vimrc.bundles
endif



map gd gd<C-o>
