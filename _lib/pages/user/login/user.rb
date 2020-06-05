# encoding: UTF-8
=begin
  Module pour identifier le user
=end

class User

ERRORS = {
  unkown_user:    'Je ne vous reconnais pas. Merci de ré-essayer.'.freeze,
  mail_required:  'Pour vous identifier, il faut fournir votre mail.'.freeze,
  pwd_required:   'Pour vous identifier, votre mot de passe est requis (celui utilisé pour candidater à l’atelier).'.freeze
}

class << self

  # Retourne l'instance Form pour le formulaire d'identification
  def login_form
    @form = Form.new({id:'user-login', action:'user/login'})
    @form.rows = {
      'Votre mail'          => {name:'user_mail',     type:'text'},
      'Votre mot de passe'  => {name:'user_password', type:'password'},
      'back_to'             => {name:'back_to',       type:'hidden', value: session['back_to']}
    }
    @form.submit_button = 'S’identifier'
    @form.other_buttons = [
      {text: 'Mot de passe oublié'.freeze, route: 'user/password_forgotten'.freeze},
      {text: 'S’inscrire'.freeze, route: 'user/signup'.freeze}
    ]
    @form
  end

  # Méthode qui vérifie si c'est le bon utilisateur/icarien
  # Si c'est le bon, il est authentifié (cf. plus bas)
  # Et on le redirige vers la page naturelle.
  def check_user
    log("-> check_user")
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
    session['user_id'] = @dbuser[:id].to_s
    db_exec("UPDATE users SET session_id = ? WHERE id = ?", [session.id, @dbuser[:id]])
    User.current = User.new(@dbuser)
    notice "Soyez #{user.fem(:la)} bienvenu#{user.fem(:e)}, #{user.pseudo} !"
  end

  # Après son authentification, on redirige l'user soit vers le back_to
  # enregistré (quand il voulait atteindre une page protégée) soit vers
  # sa destination préférée après le login.
  def redirect_user
    Route.redirect_to(param(:back_to) || user.route_after_login)
  end

  # Return TRUE si un utilisateur possède le mail fourni
  def mail_exists?
    @dbuser = db_get('users', {mail: @user_mail})
    return @dbuser != nil
  end

  # Return TRUE si le mot de passe est valide, c'est-à-dire s'il correspond
  # au mail
  def password_valid?
    User.encrypte_password(@user_password, @user_mail, @dbuser[:salt]) == @dbuser[:cpassword]
  end

end #/<< self
end #/ User
