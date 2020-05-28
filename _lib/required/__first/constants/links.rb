# encoding: UTF-8
=begin
  Différentes constantes qui servent souvent
=end
RETOUR_LINK = "<a href='%{route}' class='small'><span style='vertical-align:sub;'>↩︎</span>&nbsp;%{titre}</a>&nbsp;".freeze


RETOUR_BUREAU = (RETOUR_LINK % {route:'bureau/home'.freeze, titre:'Bureau'.freeze}).freeze
RETOUR_PROFIL = (RETOUR_LINK % {route:'user/profil'.freeze, titre:'Profil'.freeze}).freeze
