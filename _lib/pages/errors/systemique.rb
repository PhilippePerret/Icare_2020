# encoding: UTF-8
=begin
  La page (entière) affichée en cas d'erreur fatale
=end
html.build_header rescue nil
html.build_head rescue nil
html.build_footer rescue nil
begin
  backtrace = if user.admin?
                ERROR.backtrace.collect{|m| "<div>#{m.gsub(/</,'&lt;')}</div>"}.join('')
              else
                # On doit envoyer l'erreur par mail et l'enregistrer
                # dans le journal d'erreur
                backtrace = ""
              end
  # ---
rescue Exception => e
end
STDOUT.write "Content-type: text/html; charset: utf-8;\n\n"
STDOUT.write <<-HTML
<!DOCTYPE html>
<html>
#{html.head rescue nil}
<body>
  <section id="header">#{html.header rescue nil}</section>
  <section id="body">
    <h1 class="titre">🚨 Une erreur est survenue</h1>
    <div>
      <div class="warning">#{ERROR.message.gsub(/</,'&lt;')}</div>
      #{backtrace}
    </div>
    <div class="center mt2 big">👩‍🏭 👨‍🏭 👨‍🚒 👩‍🚒</div>
    <p class="explication red">Le problème a été signalé, il devrait être corrigé dans les plus brefs délais par nos technicien·ne·s. Merci de votre compréhension.</p>
    <p style="text-align:center"><a href="home">Retourner à l’accueil</p>
  </section>
  #{footer rescue nil}
</body>
</html>
HTML
