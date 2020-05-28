# encoding: UTF-8
=begin
  Page d'identification
=end
require_module('forms')
class HTML
def titre
  "Identification"
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
  @body = <<-HTML
  #{User.login_form.out}
  HTML
end # exec
end #HTML
