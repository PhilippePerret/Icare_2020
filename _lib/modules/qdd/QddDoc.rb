# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class QddDoc
  ------------
  Pour gérer un document comme un document QDD
=end
require_modules(['user/modules', 'icmodules', 'absmodules'])
class QddDoc

LINK_DOWNLOAD_PDF = '<a href="%s" target="_blank" class="fleft"><img src="img/icones/pdf%s.jpg" class="vmiddle mr1" /></a>'
DOWNLOAD_ROUTE = 'qdd/download?qid=%i&qdt=%s'

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def get(doc_id)
    new(db_get('icdocuments', {id: doc_id.to_i}))
  end #/ get
end #/<< self

# ---------------------------------------------------------------------
#
#   INSTANCES
#
# ---------------------------------------------------------------------
attr_reader :id, :original_name, :user_id, :icetape_id, :options
attr_reader :updated_at, :time_original, :time_comments
attr_reader :data
def initialize data
  # log("init with data: #{data.inspect}")
  @data = data
  unless data.nil?
    data.each {|k,v| self.instance_variable_set("@#{k}", v)}
  else
    raise ERRORS[:no_initial_data_provided]
  end
end #/ initialize

def user_enable?
  return true if user.admin? # toujours
  # TODO Il ne doit pas être à l'essai avec 5 documents déjà chargés
  # TODO il faut enregistrer les téléchargements, pour ça
  shared_same_etape || shared_sharing(doctype)
end #/ user_enable?

# Par défaut, c'est :original
def doctype
  @doctype ||= (param(:qdt) || param(:fd) || 'original').to_sym
end #/ doctype

# Pour pouvoir déterminer le type (:original ou :comments) à la volée,
# sert uniquement pour la maintenance pour le moment.
def doctype= val
  @doctype = val
end #/ doctype=

# Retourne TRUE si le document de type dtype existe (normalement, c'est
# seulement utile pour le document commentaire, mais on peut imaginer qu'un
# document original a été marqué inexistant)
def exists?(dtype)
  options[dtype === :original ? 0 : 8].to_i == 1
end #/ exists?

# Retourne TRUE si le document de type +dtype+ (:original ou :comments) est
# partagé par l'auteur
def shared?(dtype)
  shared_sharing(dtype) || shared_same_etape
end #/ shared?

# Return si le fichier PDF de type +dtype+ existe
def pdf_exists?(dtype)
  File.exists?(path(dtype))
end #/ pdf_exists?

# Retourne TRUE si l'icarien qui visite est sur la même étape
def shared_same_etape
  user.actif? && user.icetape.absetape.id == absetape_id
end #/ shared_same_etape

def shared_sharing(dtype)
  options[dtype == :original ? 1 : 9].to_i == 1
end #/ shared_sharing

def icetape
  @icetape ||= IcEtape.get(icetape_id)
end #/ icetape

def absetape_id
  @absetape_id ||= icetape.absetape.id
end #/ absetape_id

def absetape
  @absetape ||= QddAbsEtape.get(absetape_id)
end #/ absetape
alias :etape :absetape

def absmodule
  @absmodule = absetape.module
end #/ absmodule
alias :module :absmodule

def formated_date(dtype)
  @formated_date ||= formate_date(send("time_#{dtype}".to_sym))
end #/ formated_date

def label_auteur
  @label_auteur ||= "Auteur#{auteur.fem(:e)}"
end #/ label_auteur
def auteur
  @auteur ||= User.get(user_id)
end #/ auteur

def pseudo_auteur
  @pseudo_auteur ||= begin
    auteur.pseudo.gsub(/[^a-zA-Z0-9]/,'')
  rescue Exception => e
    # Impossible d'obtenir le pseudo
    err = <<-ERROR
# ERREUR DANS [pseudo_auteur] (#{__FILE__}:#{__LINE__})
# AVEC user_id = #{user_id}
# AVEC auteur = #{auteur.inspect}
# MESSAGE : #{e.message}
# BACKTRACE :
# #{e.backtrace.join(RC+DIESE+SPACE)}
# RÉPARATION PROVISOIRE : mis à "indéfini"
    ERROR
    "indéfini"
  end
end #/ pseudo_auteur

# Le chemin d'accès au fichier
# Note : attention, ici, il s'agit bien d'un document unique, déterminé
# par le 'doctype' qui dit que c'est un original ou un commentaire
def path(dtype = nil)
  dtype ||= doctype
  if dtype == :original
    @path_original ||= File.join(QDD_FOLDER, absmodule.id.to_s,name(:original))
  else
    @path_comments ||= File.join(QDD_FOLDER, absmodule.id.to_s,name(:comments))
  end
end #/ path

QDD_FILE_NAME = '%{module}_etape_%{etape}_%{pseudo}_%{doc_id}_%{dtype}.pdf'
def name(dtype = nil)
  dtype ||= doctype
  @template ||= begin
    QDD_FILE_NAME % {
      module: absmodule.module_id.camelize,
      etape:  absetape.numero,
      pseudo: pseudo_auteur.dup.patronimize,
      doc_id: id,
      dtype: '%s'
    }
  end
  case dtype
  when :original
    @name_original ||= @template % dtype.to_s
  when :comments
    @name_comments ||= @template % dtype.to_s
  end
end #/ name

end #/QddDoc
