if exists('g:loaded_yankitute') || &cp || v:version < 700
  finish
endif
let g:loaded_yankitute = 1

command! -nargs=? -range -register Yankitute execute yankitute#execute(<q-args>, <line1>, <line2>, '<register>')
