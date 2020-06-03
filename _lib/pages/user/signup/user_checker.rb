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
  # Méthode principale qui vérifie que l'inscription est bonne
  def check_signup
    self.errors = []
    @errors_fields = []
    chuser = CheckedUser.new(user)

    # --- VALIDATION DE TOUTES LES PROPRIÉTÉS ---
    chuser.valid?(:pseudo)
    chuser.valid?(:mail)
    chuser.valid?(:naissance)
    chuser.valid?(:sexe)
    chuser.valid?(:password)
    chuser.valid?(:cgu)
    chuser.valid?(:modules)
    chuser.valid?(:documents)

    if chuser.errors.count
      erreur chuser.errors.join(BR)
    else
      message "Inscription valide"
    end
  rescue Exception => e
    error "#{e.message}"
    log(e)
  end #/ check_signup

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
REG_PASSWORD = /^[a-zA-Z0-9\!\?\;\:\.\…\-]+$/

PROPERTIES = [
  :pseudo, :mail, :naissance, :sexe, :mail_conf, :password, :password_conf,
  :presentation, :motivation, :extrait,
  :cgu
]

attr_accessor :errors
attr_reader :owner
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
  if pseudo
    pseudo.length > 3   || errors << 'Le pseudo doit faire au moins 4 caractères'
    pseudo.length < 50  || errors << 'Le pseudo est trop long (50 signes maximum)'
  else
    errors << 'Le pseudo est obligatoire'
  end
end #/ pseudo_valid?

def mail_valid?
  log("mail.match?(REG_MAIL): #{mail.match?(REG_MAIL).inspect}")
  if mail.nil?
    errors << 'Votre mail est requis'
  elsif mail.match?(REG_MAIL).false?
    errors << 'Ce mail est invalide'
  elsif mail != mail_conf
    errors << 'La confirmation ne correspond pas au mail donné'
  end
end #/ mail_valid?

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
    errors << 'Le mot de passe est requis'.freeze
  elsif password.length < 6
    errors << 'Votre mot de passe est trop court (6 signes minimum)'.freeze
  elsif password.length > 50
    errors << 'Votre mot de passe est trop long (50 signes maximum)'.freeze
  elsif password.match?(REG_PASSWORD).false?
    errors << 'Votre mot de passe ne doit contenir que des lettres, des chiffres et des ponctuations'
  elsif password != password_conf
    errors << 'La confirmation de votre mot de passe ne correspond pas'.freeze
  end
end #/ password_valid?

def cgu_valid?
  if cgu.nil?
    errors << 'Vous devez approuver les Conditions Générales d’Utilisation de l’atelier.'
  end
end #/ cgu_valid?

def modules_valid?
  module_ids = []
  db_exec("SELECT id FROM absmodules").each do |dmod|
    mod_id = dmod[:id]
    log("mod_id: #{mod_id}")
    module_ids << mod_id if param("umodule_#{mod_id}".to_sym)
  end

  if module_ids.count == 0
    errors << 'Vous devez choisir au moins 1 module'
  end
end #/ modules_valid?

def documents_valid?
  presentation  = param(:upresentation)

  if param(:upresentation_ok)
    # Document déjà traité
  elsif presentation.nil?
    errors << 'Le document de votre présentation est requis'.freeze
  else
    # Enregistrer le document
    SignupDocument.new(presentation, :presentation, owner).upload
  end

  motivation = param(:umotivation)
  if param(:umotivation_ok)
    # Document déjà traité
  elsif motivation.nil?
    errors << 'Votre lettre de motivation est requise'.freeze
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
