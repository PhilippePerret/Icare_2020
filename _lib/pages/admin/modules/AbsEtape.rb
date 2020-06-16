# encoding: UTF-8
=begin
  Extension de la class AbsEtape pour modifier l'étape
=end
class AbsEtape
  attr_reader :new_data
  ABSETAPE_PROPERTIES = {
    id:       {type:'integer'},
    numero:   {type:'integer'},
    titre:    {type:'text'},
    travail:  {type:'longtext'},
    methode:  {type:'longtext'},
    liens:    {type:'longtext'}
  }
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
