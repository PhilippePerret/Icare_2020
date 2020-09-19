# encoding: UTF-8
# frozen_string_literal: true
require_modules(['user/modules'])

class HTML
  def titre
    "#{Emoji.get('humain/fille-rousse-carre').page_title+Emoji.get('humain/homme-marron-moustache').page_title+Emoji.get('humain/femme-voilee').page_title+Emoji.get('humain/extraterrestre').page_title+Emoji.get('humain/homme-barbe-noire').page_title+Emoji.get('humain/jeune-homme-blond').page_title+ISPACE}Icariennes et icariens"
  end
  # Code à exécuter avant la construction de la page
  def exec
    User.dispatch_all_users
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
