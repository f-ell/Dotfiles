let g:serenade_enable_italic = 1
let g:serenade_disable_italic_comment = 0
let g:serenade_transparent_background = 1
let g:serenade_better_performance = 1

let g:everforest_background 						= 'soft'
let g:everforest_enable_bold						= 1
let g:everforest_enable_italic 					= 1
let g:everforest_transparent_background = 1
let g:everforest_spell_foreground   		= 'colored'
let g:everforest_better_performance 		= 1

let g:gruvbox_material_background							= 'soft'
let g:gruvbox_material_enable_bold						= 1
let g:gruvbox_material_enable_italic					= 1
let g:gruvbox_material_transparent_background = 1
let g:gruvbox_material_spell_foreground				= 'colored'
let g:gruvbox_material_ui_contrast						= 'high'
let g:gruvbox_material_better_performance			= 1

set background=dark
colorscheme everforest

if has('termguicolors')
	set termguicolors
endif
set noshowmode

let g:lightline = {
			\ 'colorscheme': 'serenade',
			\ 'active': {
			\ 	'left': [ ['icon',],
			\   					['mode', 'paste', ], 
			\							['filename', 'readonly', ],
			\           ],
			\		'right': [ ['lineinfo',],
			\							 ['filetype',],
			\ 					 ],
			\ },
			\ 'component': {
			\ 	'icon': '',
			\		'micon': '',
			\ },
			\ }
