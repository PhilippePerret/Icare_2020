# encoding: UTF-8
=begin
  Page d'identification
=end
require_module('form')
class HTML
def titre
  "🔐#{ISPACE}Identification"
end
def exec
  if URL.param(:form_id) == 'user-login'
    # debug "Soumission du formulaire d'identification"
    form = Form.new
    form.conform? || return
    User.check_user
  end
end # exec

def build_body
  @body = User.login_form.out
end # /build_body

end #HTML
