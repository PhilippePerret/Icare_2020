# encoding: UTF-8
=begin
  Constantes String pratiques (et freezées)
=end
STRINGS = {
  destroy: 'destroy'.freeze,
  discussion: 'discussion'.freeze,
  download: 'download'.freeze,
  home: 'home'.freeze,
  inviter: 'inviter'.freeze,
}

AND = ' AND '.freeze

BR = '<br/>'.freeze

EMPTY_STRING = ''.freeze
ESPACE_FINE = "<this />".freeze

ET = ' et '.freeze

ISPACE = '&nbsp;'.freeze

PV = ';'.freeze # PV pour Point Virgule

RC = '
'.freeze unless defined?(RC)
RC2 = (RC*2).freeze
RETOUR    = '<span style="vertical-align:sub;">↩︎</span>'.freeze

SELECT    = 'select'.freeze
SELECTED  = ' SELECTED'.freeze
SPACE = ' '

TEXT      = 'text'.freeze
TIRET     = '<span class="tiret">–</span>'

VG = ', '.freeze # VG pour VirGule
