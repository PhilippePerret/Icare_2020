# encoding: UTF-8
=begin
  La page (entière) affichée en cas d'erreur fatale
=end
STDOUT.write "Content-type: text/html; charset: utf-8;\n\n"
STDOUT.write <<-HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>ATELIER ICARE — Erreur Fatale</title>
</head>
<body>
<div style='padding:3em;font-size:15.2pt;color:red;'>
  <div style='margin-bottom:2em'>🚨 #{ERROR.message.gsub(/</,'&lt;')}</div>
  #{ERROR.backtrace.collect{|m| "<div>#{m.gsub(/</,'&lt;')}</div>"}.join('')}
</div>
<p style="text-align:center"><a href="home">Retourner à l’accueil</p>
  </body>
</html>
HTML
