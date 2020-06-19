# encoding: UTF-8
=begin
  Extension de la class AbsEtape pour modifier l'étape
=end
class AbsEtape

ABSETAPE_PROPERTIES = {
  id:             {type:'integer'},
  absmodule_id:   {type:'integer'},
  numero:         {type:'integer'},
  titre:          {type:'text'},
  objectif:       {type:'text'},
  travail:        {type:'longtext'},
  methode:        {type:'longtext'},
  liens:          {type:'longtext'},
  duree:          {type:'integer'},
  duree_max:      {type:'integer'}
}

DEFAULT_DATA = {}
ABSETAPE_PROPERTIES.each{|k,d| DEFAULT_DATA.merge!(k => nil)}

ERRORS.merge!({
  numero_etape_required: "Il faut fournir le numéro de l'étape.".freeze,
  numero_greater_than_zero: 'Le numéro doit être un positif supérieur à zéro'.freeze,
  numero_etape_exists: 'Ce numéro d’étape existe déjà.'.freeze,
  titre_etape_required: 'Le titre de l’étape est requis'.freeze,
  titre_etape_too_long: 'Le titre de l’étape est trop long (200 max / %i)'.freeze,
  titre_already_exists: 'Ce titre existe déjà dans ce module.'.freeze,
  duree_required: 'La durée de l’étape est requise'.freeze,
  duree_too_short: 'La durée de l’étape est trop courte (au moins deux jours)'.freeze,
  duree_too_long: 'La durée de l’étape est trop longue (moins de deux mois)'.freeze,
  duree_max_exceeds_duree: 'La durée ne peut excéder la durée maximale.'.freeze,
  duree_max_required: 'La durée maximale de l’étape est requise'.freeze,
  travail_required:'Le travail de l’étape est absolument requis'.freeze,

  })

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  # Méthode pour créer une nouvelle donnée
  def create_new
    admin_required
    # On récupère toutes les valeurs
    deta = {}
    AbsEtape::DEFAULT_DATA.each do |k, v|
      value = param("etape_#{k}")
      log("k: #{k.inspect}")
      type = ABSETAPE_PROPERTIES[k][:type]
      unless value.nil?
        value = case type
        when 'integer'  then value.to_i
        when 'longtext' then value.gsub(/\r\n/,"\n")
        else value
        end
      end
      deta.merge!(k.to_sym => value)
    end
    errors = []
    if deta[:numero].nil?
      errors << ERRORS[:numero_etape_required]
    else
      deta[:numero] > 0   || errors << ERRORS[:numero_greater_than_zero]
      db_count('absetapes',{numero: deta[:numero], absmodule_id:deta[:absmodule_id]}) == 0 || errors << ERRORS[:numero_etape_exists]
    end
    deta.delete(:numero) if errors.count > 0
    count_here = errors.count
    titre = param(:etape_titre) || errors << ERRORS[:titre_etape_required]
    unless titre.nil?
      titre.length <= 200 || errors << (ERRORS[:titre_etape_too_long] % [titre.length])
      titre_not_exists?(titre, deta[:absmodule_id]) || errors << ERRORS[:titre_already_exists]
    end
    deta.delete(:titre) if errors.count > count_here
    count_here = errors.count
    # Note : l'objectif peut ne pas exister et avoir une grande longueur
    deta[:duree] || errors << ERRORS[:duree_required]
    unless deta[:duree].nil?
      deta[:duree] >= 2 || errors << ERRORS[:duree_too_short]
      deta[:duree] < 61 || errors << ERRORS[:duree_too_long]
      if deta[:duree_max] && deta[:duree] > deta[:duree_max]
        errors << ERRORS[:duree_max_exceeds_duree]
      end
    end
    deta.delete(:duree) if errors.count > count_here
    count_here = errors.count
    deta[:duree_max] || errors << ERRORS[:duree_max_required]
    deta.delete(:duree_max) if errors.count > count_here

    count_here = errors.count
    deta[:travail] || errors << ERRORS[:travail_required]
    deta.delete(:travail) if errors.count > count_here

    # S'il y a des erreurs, on ne va pas plus loins
    raise errors.join(BR) if errors.count > 0

    # On crée la nouvelle étape
    new_etape = create_with_data(deta)
    # … et on la met en édition
    param(:op, 'edit-etape')
    param(:eid, new_etape.id)
  rescue Exception => e
    log(e)
    erreur e.message
    AbsEtape::DEFAULT_DATA.merge!(deta) # pour remettre les bonnes valeurs
    param(:op, 'create-etape')
  end #/ create_new

  def titre_not_exists?(titre, mid)
    db_count('absetapes', {titre:titre, absmodule_id:mid}) == 0
  end #/ titre_not_exists?
end # << self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

  attr_reader :new_data

  # = main =
  #
  # Méthode principale qui checke les données de l'étape et les enregistre
  # si elles sont bonnes.
  def check_and_save
    get_values
    check_new_values || return
    save(new_data)
    message "Étape “#{titre}” enregistrée avec succès."
  end #/ check_and_save

  def get_values
    @new_data = {}
    ABSETAPE_PROPERTIES.each do |prop, dprop|
      value = param("etape_#{prop}")
      case dprop[:type]
      when 'integer'  then value = value.to_i
      when 'longtext' then value = value&.sanitize
      end
      @new_data.merge!(prop => value)
    end
    # log("--- new_data: #{new_data.inspect}")
  end #/ get_values

  def check_new_values
    @new_data.dup.each do |prop, value|
      if value == data[prop]
        @new_data.delete(prop)
      end
    end
    if @new_data.empty?
      message MESSAGES[:no_data_change]
      return false
    else
      return true
    end
    # log("--- vraies new data: #{@new_data.inspect}")
  end #/ check_new_values

  def new_id
    @new_id ||= param(:etape_id)
  end #/ new_id
  def new_numero
    @new_numero ||= param(:etape_numero)
  end #/ new_numero
  def new_titre
    @new_titre ||= param(:etape_titre)
  end #/ new_titre
  def new_travail
    @new_travail ||= param(:etape_travail)
  end #/ new_travail
  def new_methode
    @new_methode ||= param(:etape_methode)
  end #/ new_methode
  def new_liens
    @new_liens ||= param(:etape)
  end #/ new_liens
end #/AbsEtape
