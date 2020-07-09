#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  On peut utiliser maintenant `icare create route`
=end

unless defined?(DATA_PAGE)
  NEW_ROUTE = nil # remettre à nil après pour éviter les erreurs
  DATA_PAGE = {
    titre: "Activité de l'atelier Icare",
    usefull_links: false,       # si true, la méthode pour ajouter des liens utiles
    body_erb: true,          # si true, on crée le fichier body.erb
    form: false,              # si true, on requiert le module 'forms'
    module_user: false,        # si true, on crée 'user.rb'
    icarien_required:false,    # true, une barrière sera "posée"
    admin_required: false,    # si true, une barrière sera posée
    fichier_constantes: false ,  # si true, crée le fichier 'constants.rb' qui
                                # permet notamment de tester plus facilement les
                                # messages
  }
  RC = "\n"
  RC2 = RC * 2
else
  NEW_ROUTE = DATA_PAGE[:route]
end

raise "Il faut définir la route" if NEW_ROUTE.nil?

def create_route
  require './_lib/required/__first/constants/paths'
  folder = File.join(PAGES_FOLDER ,NEW_ROUTE)
  raise "La route #{folder} existe déjà." if File.exists?(folder)
  `mkdir -p "#{folder}"`
  path = File.join(folder,'html.rb')
  File.open(path,'wb'){|f|f.write html_code_type}
  create_module_user(folder)    if DATA_PAGE[:module_user]
  create_body_erb(folder)       if DATA_PAGE[:body_erb]
  create_constants_file(folder) if DATA_PAGE[:fichier_constantes]
  puts "La route a été créée avec succès.".bleu
end

def create_body_erb(folder)
  path = File.join(folder,'body.erb')
  File.open(path,'wb') do |f|
    f.write <<-ERB
<p>Nouvelle route</p>
    ERB
  end
end #/ create_body_erb

def create_module_user(folder)
  path = File.join(folder,'user.rb')
  File.open(path,'wb') do |f|
    f.write <<-RUBY
# encoding: UTF-8
class User

end #/User
    RUBY
  end
end

def create_constants_file(folder)
  path = File.join(folder,'constants.rb')
  File.open(path,'wb') do |f|
    f.write <<-RUBY
# encoding: UTF-8
=begin
  Constantes messages
=end
UI_TEXTS.merge!({

})
MESSAGES.merge!({

})
ERRORS.merge!({

})
    RUBY
  end
end #/ create_constants_file



def html_code_type
  ulinks = ''
  if DATA_PAGE[:usefull_links]
    ulinks = "\ndef usefull_links\n\t\t[\n\t\t\t# Ici les liens\n\t\t]\n\tend\n".freeze
  end
  <<-RUBY.freeze
# encoding: UTF-8
#{'require_module(\'form\')' if DATA_PAGE[:form]}
class HTML
  def titre
    "#{DATA_PAGE[:titre]||"TITRE MANQUANT"}".freeze
  end #/titre
  #{ulinks}
  # Code à exécuter avant la construction de la page
  def exec
    #{"icarien_required\n" if DATA_PAGE[:icarien_required]}#{"admin_required\n" if DATA_PAGE[:admin_required]}
  end # /exec

  # Fabrication du body
  def build_body
    @body = #{DATA_PAGE[:body_erb] ? 'deserb(STRINGS[:body], self)' : "<<-HTML#{RC2}    HTML"}
  end # /build_body

end #/HTML
  RUBY
end

create_route
