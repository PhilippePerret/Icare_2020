# encoding: UTF-8
=begin
  Pour l'édition des travaux-types
=end
class TravailType
attr_reader :new_data
TRAVAILTYPE_PROPERTIES = {
  id:         {type:'integer'},
  rubrique:   {type:'text'},
  name:       {type:'text'},
  titre:      {type:'text'},
  objectif:   {type:'text'},
  travail:    {type:'longtext'},
  methode:    {type:'longtext'},
  liens:      {type:'longtext'}
}

# Pour enregistrement
def check_and_save
  get_values
  check_new_values || return
  save(new_data)
  message "Travail type “#{rubrique}/#{name}” enregistré avec succès."
end #/ check_and_save

def get_values
  @new_data = {}
  TRAVAILTYPE_PROPERTIES.each do |prop, dprop|
    value = param("twork_#{prop}")
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

end #/TravailType
