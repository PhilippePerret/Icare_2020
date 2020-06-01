#!/usr/bin/env ruby
# encoding: UTF-8

NEW_ROUTE = 'admin/database' # remettre à nil après pour éviter les erreurs
DATA_PAGE = {
  titre: "\#{RETOUR_ADMIN}🗄️ Base de données",
  body_erb: true,          # si true, on crée le fichier body.erb
  form: true,              # si true, on requiert le module 'forms'
  module_user: false,        # si true, on crée 'user.rb'
  icarien_required:false,    # true, une barrière sera "posée"
  admin_required: true,    # si true, une barrière sera posée
}

raise "Il faut définir la route" if NEW_ROUTE.nil?

RC = "\n"
RC2 = RC * 2

def create_route
  require './_lib/constants'
  folder = File.join(PAGES_FOLDER,NEW_ROUTE)
  raise "La route #{folder} existe déjà." if File.exists?(folder)
  `mkdir -p "#{folder}"`
  path = File.join(folder,'html.rb')
  File.open(path,'wb'){|f|f.write html_code_type}
  create_module_user(folder)  if DATA_PAGE[:module_user]
  create_body_erb(folder)     if DATA_PAGE[:body_erb]
  puts "La route a été créée avec succès."
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
    f.write <<-HTML
# encoding: UTF-8
class User

end #/User
    HTML
  end
end
def html_code_type
  <<-RUBY
# encoding: UTF-8
#{'require_module(\'form\')' if DATA_PAGE[:form]}
class HTML
  def titre
    "#{DATA_PAGE[:titre]||"TITRE MANQUANT"}".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    #{"icarien_required\n" if DATA_PAGE[:icarien_required]}#{"admin_required\n" if DATA_PAGE[:admin_required]}
  end
  # Fabrication du body
  def build_body
    @body = #{DATA_PAGE[:body_erb] ? 'deserb(\'body\', self)' : "<<-HTML#{RC2}    HTML"}
  end
end #/HTML
  RUBY
end

create_route
