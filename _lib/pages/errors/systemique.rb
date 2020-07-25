# encoding: UTF-8
=begin
  La page (entière) affichée en cas d'erreur fatale
=end
html.build_header rescue nil
html.build_head   rescue nil
html.build_footer rescue nil
begin
  backtrace = if user.admin? || OFFLINE
                ERROR.backtrace.collect{|m| "<div>#{m.to_s.gsub(/</,'&lt;')}</div>"}.join('')
              else
                # On doit envoyer l'erreur par mail et l'enregistrer
                # dans le journal d'erreur
                backtrace = ""
              end
  # ---
rescue Exception => e
  backtrace = ""
end

message_avertissement = "Le problème a été signalé, il devrait être corrigé dans les plus brefs délais par nos technicien·ne·s. Merci de votre compréhension.".freeze
begin
  send_error(ERROR)
rescue Exception => e
  # L'erreur ne peut être envoyée par send_error, on l'écrit directement dans le
  # fichier traceur.
  begin
    msg = ERROR.message
    backtrace2 = ERROR.backtrace.join("\\n")
    if defined?(Tracer)
      trace(id:'ERROR (Tracer)'.freeze, message:"#{msg}\\n#{backtrace2}", data:{backtrace:backtrace2})
    else
      # Dans tous les cas il faut écrire quelque chose
      logfile = File.join('.','tmp','logs','tracer.log')
      File.open(logfile,'wb') do |f|
        f.puts "#{Time.now.to_f}-:-:-:-IP_USER-^-ERROR (raw)-^-#{msg}-^-{\"backtrace\":#{backtrace2.inspect}}"
      end
    end
  rescue Exception => e
    message_avertissement = "Cette erreur, à cause de sa nature fatale, n’a pas pu être transmise.".freeze
  end
end
STDOUT.write "Content-type: text/html; charset: utf-8;\n\n"
STDOUT.write <<-HTML
<!DOCTYPE html>
<html>
#{html.head rescue nil}
<body>
  <section id="header">#{html.header rescue nil}</section>
  <section id="body">
    <h1 class="titre">#{EMO_GYROPHARE.page_title} Une erreur est survenue</h1>
    <div>
      <div class="warning">#{ERROR.message.to_s.gsub(/</,'&lt;')}</div>
      #{backtrace}
    </div>
    <div class="center mt2 big">
      <img src="http://www.atelier-icare.net/img/Emojis/humain/femme-pompier.png" alt="femme-pompier" style="width:40px;">
      <img src="http://www.atelier-icare.net/img/Emojis/humain/homme-chalumeau.png" alt="homme-chalumeau" style="width:40px;">
      <img src="http://www.atelier-icare.net/img/Emojis/humain/homme-pompier.png" alt="homme-pompier" style="width:40px;">
      <img src="http://www.atelier-icare.net/img/Emojis/humain/femme-chalumeau.png" alt="femme-chalumeau" style="width:40px;">
    </div>
    <p class="explication red">#{message_avertissement}</p>
    <p style="text-align:center"><a href="home">Retourner à l’accueil</p>
  </section>
  #{footer rescue nil}
</body>
</html>
HTML
