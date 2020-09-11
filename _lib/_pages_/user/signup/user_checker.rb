# encoding: UTF-8
class User
  attr_accessor :errors

  # Retourne TRUE si l'inscription est bonne
  # Pour le moment, sert à définir la vue à afficher
  def inscription_ok?
    @inscription_is_ok ||= false
  end #/ inscription_ok?

  # = main =
  #
  # Méthode qui lance la vérification des données du candidat et
  # enregistre un fichier d'information dans son dossier de candidature
  def check_signup_and_record
    chuser = check_signup
    # save_record(chuser) unless chuser.nil? # en cas d'erreur
  end #/ check_signup_and_record

  # Méthode qui vérifie que l'inscription est bonne
  def check_signup
    self.errors = []
    @errors_fields = []
    chuser = CheckedUser.new(user).tap do |u|
      # --- VALIDATION DE TOUTES LES PROPRIÉTÉS ---
      u.valid?(:pseudo)
      u.valid?(:patronyme)
      u.valid?(:mail)
      u.valid?(:naissance)
      u.valid?(:sexe)
      u.valid?(:password)
      u.valid?(:cgu)
      u.valid?(:rgpd)
      u.valid?(:modules)
      u.valid?(:documents)
    end

    if chuser.errors.count > 0
      erreur(chuser.errors.collect{|m|Tag.li(m)}.join)
      return nil
    else
      # Les données sont valides, on doit créer le nouvel icarien
      # et créer le watcher.
      require_module('user/create')
      newuser = User.create_new(chuser) # nil si pas ok
      return nil if newuser.nil?
      chuser.id = newuser.id
      @inscription_is_ok = true # pour afficher la confirmation
      return chuser
    end
  rescue Exception => e
    error "#{e.message}"
    log(e)
  end #/ check_signup

  # Procède à l'enregistrement des informations générales de cette
  # candidature
  def save_record(chuser)
    finfos = File.join(signup_folder,'infos.yaml')
    infos = {
      user_id: chuser.id,
      mail: chuser.mail,
      modules_ids: chuser.modules_ids,
      date: Time.now.to_s
    }
    File.open(finfos,'wb'){|f| f.write infos.to_yaml}
  end #/ save_record

  # Dossier d'inscription
  def signup_folder
    @signup_folder ||= begin
      d = File.join(TEMP_FOLDER,'signups', session.id)
      `mkdir -p "#{d}"`
      d
    end
  end #/ folder

private
  def add_error ary
    @errors << ary[0]
    @errors_fields << ary[1]
  end #/ add_error

end #/User

# Une classe pour checker l'user, avec ses paramètres
class CheckedUser
REG_MAIL = /^([a-zA-Z0-9_\.-]+)@([a-zA-Z0-9_\.-]+)\.([a-z]{1,6})$/
REG_PASSWORD = /^[a-zA-Z0-9\!\?\;\:\.\…]+$/

PROPERTIES = [
  :pseudo, :patronyme, :mail, :naissance, :sexe, :mail_conf, :password, :password_conf,
  :presentation, :motivation, :extrait,
  :cgu, :rgpd
]

attr_accessor :errors
attr_reader :owner, :modules_ids
attr_accessor :id # sera défini plus tard, lors de la création de l'enregistrement
def initialize owner = nil
  @owner = owner
  self.errors = []
end #/ initialize

def method_missing method_name, *args, &block
  if PROPERTIES.include?(method_name)
    param("u#{method_name}".to_sym)
  else
    raise "Méthode introuvable : #{method_name.inspect}"
  end
end #/ missing_method


# ---------------------------------------------------------------------
#   MÉTHODES DE CHECK
# ---------------------------------------------------------------------

# Méthode générale de validation d'une propriété
# Elle permet de voir si une erreur a été générée en cours de validation
# Elle retourne false si une erreur a été trouvée et true dans le cas contraire.
def valid?(prop)
  nombre_erreurs_initiale = errors.count
  send("#{prop}_valid?".to_sym)
  return errors.count == nombre_erreurs_initiale # pas d'erreur ?
end #/ valid?


def pseudo_valid?
  if pseudo.nil?
    errors << ERRORS[:pseudo_required]
  elsif pseudo.length < 4
    errors << ERRORS[:pseudo_too_short]
  elsif pseudo.length > 50
    errors << ERRORS[:pseudo_too_long]
  elsif pseudo_exists?
    errors << ERRORS[:pseudo_already_exists]
  end
end #/ pseudo_valid?

def patronyme_valid?
  if patronyme && patronyme.length > 100
    errors << ERRORS[:patronyme_to_long]
  end
end #/ patronyme_valid?

# Retourne true si le pseudo existe déjà
def pseudo_exists?
  db_count(STRINGS[:users], {pseudo: pseudo}) > 0
end #/ pseudo_exists?

def mail_valid?
  if mail.nil?
    errors << ERRORS[:mail_required]
  elsif mail.match?(REG_MAIL).false?
    errors << ERRORS[:mail_invalid]
  elsif mail_exists?
    errors << ERRORS[:mail_already_exists]
  elsif mail != mail_conf
    errors << ERRORS[:conf_mail_dont_match]
  end
end #/ mail_valid?
# Retourne true si le pseudo existe déjà
def mail_exists?
  db_count(STRINGS[:users], {mail: mail}) > 0
end #/ pseudo_exists?

def naissance_valid?
  if naissance.nil?
    errors << 'Votre date de naissance est requise'.freeze
  elsif naissance.to_i < Time.now.year - 100
    errors << 'Vous êtes un peu vieux pour rejoindre l’atelier icare'.freeze
  elsif naissance.to_i > Time.now.year - 16
    errors << 'Vous êtes trop jeune pour rejoindre l’atelier'.freeze
  end
end #/ naissance_valid?

def sexe_valid?
  if sexe.nil?
    errors << 'Votre sexe est requis'.freeze
  elsif ['F','H','X'].include?(sexe).false?
    errors << 'Tiens, tiens, je ne connais pas ce genre…'.freeze
  end
end #/ sexe_valid?

def password_valid?
  if password.nil?
    errors << ERRORS[:password_required]
  elsif password.length < 6
    errors << ERRORS[:password_too_short]
  elsif password.length > 50
    errors << ERRORS[:password_too_long]
  elsif password.match?(REG_PASSWORD).false?
    errors << ERRORS[:password_invalid]
  elsif password != password_conf
    errors << ERRORS[:conf_password_doesnt_match]
  end
end #/ password_valid?

def cgu_valid?
  errors << ERRORS[:cgu_required] if cgu.nil?
end #/ cgu_valid?

def rgpd_valid?
  errors << ERRORS[:rgpd_required] if rgpd.nil?
end #/ rgpd_valid?

def modules_valid?
  modules_ids = []
  db_exec("SELECT id FROM absmodules".freeze).each do |dmod|
    mod_id = dmod[:id]
    modules_ids << mod_id if param("umodule_#{mod_id}".to_sym)
  end

  if modules_ids.count == 0
    errors << ERRORS[:modules_required]
  else
    @modules_ids = modules_ids # pour le watcher
  end
end #/ modules_valid?

def documents_valid?
  presentation  = param(:upresentation)

  if param(:upresentation_ok)
    # Document déjà traité
  elsif presentation.nil?
    errors << ERRORS[:presentation_required]
  elsif extension_invalid?(presentation)
    errors << ERRORS[:presentation_format_invalid]
  else
    # Enregistrer le document
    SignupDocument.new(presentation, :presentation, owner).upload
  end

  motivation = param(:umotivation)
  if param(:umotivation_ok)
    # Document déjà traité
  elsif motivation.nil?
    errors <<  ERRORS[:motivation_required]
  elsif extension_invalid?(motivation)
    errors << ERRORS[:motivation_format_invalid]
  else
    # Enregistrer le document
    SignupDocument.new(motivation, :motivation, owner).upload
  end

  extrait = param(:uextrait)
  if param(:uextrait_ok)
    # Document déjà traité
  elsif extrait
    SignupDocument.new(extrait, :extrait, owner).upload
  end
end #/ documents_valid?

VALID_EXTNAME = ['.rtf','.odt','.md','.mmd','.txt','.pdf','.doc','.docx']
def extension_invalid?(file)
  false == VALID_EXTNAME.include?(File.extname(file.original_filename))
end #/ extension_invalid?

end #/CheckedUser

class SignupDocument
  attr_reader :tempfile, :type, :owner
  def initialize tempfile, type, owner
    @tempfile = tempfile
    @type = type
    @owner = owner
  end #/ initialize

  # Méthode pour télécharger le document
  def upload
    File.open(path,'wb'){|f| f.write tempfile.read }
  end #/ upload

  def extname
    @extname ||= File.extname(tempfile.original_filename)
  end #/ extname

  def path
    @path ||= File.join(owner.signup_folder, "#{type}#{extname}")
  end #/ path

end #/SignupDocument
