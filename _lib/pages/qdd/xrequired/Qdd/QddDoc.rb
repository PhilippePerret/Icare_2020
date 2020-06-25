# encoding: UTF-8
=begin
  Class QddDoc
  ------------
  Pour gérer un document comme un document QDD
=end
require_module('user/modules')
class QddDoc

LINK_DOWNLOAD_PDF = '<a href="%s" target="_blank" class="fleft"><img src="img/icones/pdf%s.jpg" class="vmiddle mr1" /></a>'.freeze
DOWNLOAD_ROUTE = 'qdd/download?qid=%i&qdt=%s'.freeze

# ---------------------------------------------------------------------
#   INSTANCES
# ---------------------------------------------------------------------
attr_reader :id, :original_name, :user_id, :absetape_id, :options
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

# Retourne les cartes, celle pour le commentaire, si existe et partagé
# et celle pour l'original, si partagé
def cards
  ary = []
  ary << card(:original) if shared?(:original)
  ary << card(:comments) if shared?(:comments)
  return ary.join
rescue Exception => e # pour mode sans erreur
  err_mess = "[QDD] Problème d'affichage avec le document ##{id} : #{e.message}".freeze
  send_error(err_mess, self.data.merge(backtrace: e.backtrace.join(RC))) #rescue nil
  "<div class='qdd-card'><div class='bold'>[#{err_mess}]</div></div>"
end #/ cards
alias :out :cards

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

# Retourne une 'carte du document'
def card(dtype = :original)
  for_original = dtype == :original
  suftype = for_original ? '' : '-comments'
  droute  = DOWNLOAD_ROUTE % [id, dtype]
  inner = ''
  inner << Tag.div(text:(LINK_DOWNLOAD_PDF % [droute, suftype]), class:'fleft')
  inner << Tag.div(text: "#{original_name} <span class='small'>(#{for_original ? 'original' : 'commentaires'})</span>", class:'filename')
  msg = "<label>par</label> #{auteur.pseudo.capitalize}, <label>module</label> “#{etape.module.name}” #{etape.ref}, <label>le</label> #{formated_date(dtype)}."
  inner << Tag.div(text:msg)
  Tag.div(text:inner, class:'qdd-card')
end #/ card

def etape
  @etape ||= QddAbsEtape.get(absetape_id)
end #/ etape
alias :absetape :etape

def absmodule
  @absmodule = etape.module
end #/ absmodule

def formated_date(dtype)
  @formated_date ||= formate_date(send("time_#{dtype}".to_sym))
end #/ formated_date

def label_auteur
  @label_auteur ||= "Auteur#{auteur.fem(:e)}"
end #/ label_auteur
def auteur
  @auteur ||= User.get(user_id)
end #/ auteur

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

QDD_FILE_NAME = '%{module}_etape_%{etape}_%{pseudo}_%{doc_id}_%{dtype}.pdf'.freeze
def name(dtype = nil)
  dtype ||= doctype
  @name ||= begin
    QDD_FILE_NAME % {
      module: absmodule.module_id.camelize,
      etape:  etape.numero,
      pseudo: auteur.pseudo.gsub(/[^a-zA-Z0-9]/,'').titleize,
      doc_id: id,
      dtype: dtype
    }
  end
end #/ name

end #/QddDoc
