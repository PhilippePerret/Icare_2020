# encoding: UTF-8
=begin
  Constantes String pratiques (et freezées)
=end
STRINGS = {
  body: 'body'.freeze,
  destroy: 'destroy'.freeze,
  discussion: 'discussion'.freeze,
  download: 'download'.freeze,
  explication:'explication'.freeze,
  home: 'home'.freeze,
  inviter: 'inviter'.freeze,
  titre:'titre'.freeze,
  users:'users'.freeze,
}

AND = ' AND '.freeze

BR = '<br/>'.freeze

EMPTY_STRING = ''.freeze
ESPACE_FINE = "<this />".freeze
ESPERLUETTE = '&'.freeze
ET = ' et '.freeze

FLECHE  = '➵'

ISPACE    = ' '.freeze # espace insécable
ISPACE_H  = '&nbsp;'.freeze #insécable HTML

PV = ';'.freeze # PV pour Point Virgule

RC = '
'.freeze unless defined?(RC)
RC2 = (RC*2).freeze
RC3 = (RC*3).freeze
RETOUR    = '<span style="vertical-align:sub;">↩︎</span>'.freeze

SELECT    = 'select'.freeze
SELECTED  = ' SELECTED'.freeze
SPACE     = ' '

TAB       = '    '.freeze
TAB2      = (TAB*2).freeze
TAB3      = (TAB*3).freeze
TEXT      = 'text'.freeze
TIRET     = '<span class="tiret">–</span>'

VG = ', '.freeze # VG pour VirGule
