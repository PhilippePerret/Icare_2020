# encoding: UTF-8
=begin
  La page (entière) affichée en cas d'erreur fatale
=end
STDOUT.write "Content-type: text/html; charset: utf-8;\n\n"
STDOUT.write "<div style='padding:3em;font-size:15.2pt;color:red;'>"
STDOUT.write "<div style='margin-bottom:2em'>🚨 #{ERROR.message.gsub(/</,'&lt;')}</div>"
STDOUT.write ERROR.backtrace.collect{|m| "<div>#{m.gsub(/</,'&lt;')}</div>"}.join('')
STDOUT.write '</div>'
STDOUT.write '<p><a href="home">Retourner à l’accueil</p>'
