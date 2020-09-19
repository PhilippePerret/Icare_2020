# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes String pratiques (et freezées)
=end
STRINGS = {
  body: 'body',
  destroy: 'destroy',
  discussion: 'discussion',
  download: 'download',
  explication:'explication',
  home: 'home',
  inviter: 'inviter',
  small:'small',
  titre:'titre',
  users:'users',
}

AND = ' AND '

BR = '<br/>'

CHECKED = ' CHECKED'

DIESE = '#'

EMPTY_STRING = ''
ESPACE_FINE = "<this />"
ESPERLUETTE = '&'
ET = ' et '

FLECHE  = '➵'

ISPACE    = ' ' # espace insécable
ISPACE_H  = '&nbsp;' #insécable HTML

PV = ';' # PV pour Point Virgule

RC = '
' unless defined?(RC)
RC2 = (RC*2)
RC3 = (RC*3)
RETOUR    = '<span style="vertical-align:sub;">↩︎</span>'

SELECT    = 'select'
SELECTED  = ' SELECTED'
SPACE     = ' '

TAB       = '    '
TAB2      = (TAB*2)
TAB3      = (TAB*3)
TEXT      = 'text'
TIRET     = '<span class="tiret">–</span>'

VG  = ', ' # VG pour VirGule
VGE = ', ' # VG pour VirGule E pour espace
# Note : VG et VGE sont identiques, c'est pour la compatibilité
