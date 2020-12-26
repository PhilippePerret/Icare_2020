# encoding: UTF-8
=begin
  Page d'identification
=end
require_module('form')
class HTML
def titre
  "#{Emoji.get('objets/cadenas-cle').page_title+ISPACE}Identification"
end
def exec
  if param(:form_id) == 'user-login'
    # debug "Soumission du formulaire d'identification"
    if Form.new.conform?
      User.check_user
    else
      log('Le formulaire #user-login n’est pas conforme')
      return
    end
  end
end # exec

def build_body
  @body = deserb('body', self)
end # /build_body

end #HTML
