# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "Destruction du profil".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    if param(:form_id)
      if param(:form_id) == 'destroy-user-form'
        form = Form.new
        destroy_user if form.conform?
      end
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end

  # Méthode principale de destruction de l'user
  def destroy_user
    require './_lib/pages/user/login/user.rb'
    pseudo = user.pseudo
    param(:user_password) || raise(ERRORS[:password_required])
    User.password_valid?({pwd:param(:user_password), owner:user})  || raise(ERRORS[:unkown_user])
    # --- OK, on procède à la destruction ---
    if user.destroy
      message(MESSAGES[:destroy_confirm] % {pseudo: pseudo})
      redirect_to(:home)
    end
  rescue Exception => e
    log(e)
    erreur e.message
  end #/ destroy_user
end #/HTML
