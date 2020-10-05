# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour identifier le user
=end

class User
class << self

  # Retourne l'instance Form pour le formulaire d'identification
  def login_form
    @form = Form.new({id:'user-login', action:'user/login', class:'form-width-300 form-value-300'})
    @form.rows = {
      'Mail'          => {name:'user_mail',     type:'text'},
      'Mot de passe'  => {name:'user_password', type:'password'},
      'back_to'       => {name:'back_to',       type:'hidden', value: session['back_to']}
    }
    @form.submit_button = UI_TEXTS[:btn_login]
    # @form.submit_button = 'S’identifier'
    @form.other_buttons = [
      {text: UI_TEXTS[:btn_forgottent_password], route: 'user/forgot_password'},
      {text: UI_TEXTS[:btn_singup], route: 'user/signup'}
    ]
    @form
  end

  # Méthode qui vérifie si c'est le bon utilisateur/icarien
  # Si c'est le bon, il est authentifié (cf. plus bas)
  # Et on le redirige vers la page naturelle.
  def check_user
    @user_mail     = URL.param(:user_mail)
    @user_mail      || raise(ERRORS[:mail_required])
    mail_exists?    || raise(ERRORS[:unkown_user])
    @user_password = URL.param(:user_password)
    @user_password  || raise(ERRORS[:pwd_required])
    password_valid? || raise(ERRORS[:unkown_user])
    log("IDENTIFICATION RÉUSSIE")
    authentify_user
    redirect_user
    return true
  rescue Exception => e
    erreur e.message
    return false
  end

  # On authentifie l'user, c'est-à-dire qu'on le met dans la session pour
  # pouvoir le reconnaitre au prochain chargement.
  # On met également sa session en données pour comparer les deux.
  def authentify_user
    login_user(@dbuser[:id])
    notice "Soyez #{user.fem(:la)} bienvenu#{user.fem(:e)}, #{user.pseudo} !"
  end

  # Return TRUE si un utilisateur possède le mail fourni
  def mail_exists?
    @dbuser = db_get('users', {mail: @user_mail})
    return @dbuser != nil
  end

  # Après son authentification, on redirige l'user soit vers le back_to
  # enregistré (quand il voulait atteindre une page protégée) soit vers
  # sa destination préférée après le login.
  def redirect_user
    Route.redirect_to(param(:back_to) || user.route_after_login)
  end

  # Return TRUE si le mot de passe est valide, c'est-à-dire s'il correspond
  # au mail
  def password_valid?(data = nil)
    @user_password  ||= data[:pwd]
    @user_mail      ||= data[:owner].mail
    @dbuser         ||= data[:owner].data
    # log("--- Données pour check password ---")
    # log("cpassword in base: #{@dbuser[:cpassword]}")
    # log("cpassword calculé: #{User.encrypte_password(@user_password, @user_mail, @dbuser[:salt])}")
    # log("(@user_password:#{@user_password.inspect}, @user_mail:#{@user_mail.inspect}, @dbuser[:salt]:#{@dbuser[:salt].inspect})")
    User.encrypte_password(@user_password, @user_mail, @dbuser[:salt]) == @dbuser[:cpassword]
  end

end #/<< self


# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

def route_after_login
  REDIRECTIONS_AFTER_LOGIN[bit_redirection][:route]
end


end #/ User
