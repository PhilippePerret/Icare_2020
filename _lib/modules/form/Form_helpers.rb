# encoding: UTF-8
class Form
# Retourne la date (Instance Date/Time) du formulaire de date de name
# +field_name+.
# Quand il a été produit avec un champ de type 'date' par exemple
# En fait c'est un alias de `data_field_value`
def get_date(field_name)
  Form.date_field_value(field_name)
end #/ get_date

class << self

  # Retourne un "champ de date", c'est-à-dire trois menus qui
  # permettent de définir ou d'afficher une date
  #
  # Note : pour récupérer la valeur de ce champ, utiliser la
  # méthode `Form.date_field_value(<prefix id>)`
  #
  # +params+
  #   params[:prefix_id]    Préfixe auquel il sera ajouté '-day', '-month',
  #                         et '-year' pour avoir l'identifiant des menus
  #   :format_mois          Le format du mois, :long (defaut) ou :court
  def date_field params
    now = Time.now
    if params[:default] # Si une date est fournie
      defaut = params[:default]
      defaut = Time.at(defaut.to_i) unless defaut.is_a?(Time)
      params.merge!(default_day:    defaut.day)
      params.merge!(default_month:  defaut.month)
      params.merge!(default_year:   defaut.year)
    end
    params.key?(:format_mois) || params.merge!(format_mois: :long)
    css = ['date-fields']
    css << params.delete(:class) if params.key?(:class)
    SPAN_DATE_FIELDS % {
      prefix_id:      params[:prefix_id],
      select_day:     date_field_jour(params),
      select_month:   date_field_mois(params),
      select_year:    date_field_annee(params),
      class:          css.join(' ')
    }
  end #/ date_field

  # Retourne la valeur de ce champ de date
  def date_field_value(prefix_id)
    jour  = param("#{prefix_id}_day".to_sym).to_i
    mois  = param("#{prefix_id}_month".to_sym).to_i
    annee = param("#{prefix_id}_year".to_sym).to_i
    log({jour:jour, mois:mois, annee:annee})
    Time.new(annee,mois,jour)
  end #/ date_field_value

  def date_field_jour djour
    options = (1..31).collect do |ijour|
      selected = ijour == djour[:default_day] ? SELECTED : EMPTY_STRING
      TAG_OPTION % {value:ijour, titre: ijour.to_s.rjust(2,'0'), selected:selected}
    end.join('')
    id    = "#{djour[:prefix_id]}-day"
    name  = "#{djour[:prefix_id]}_day"
    TAG_SELECT % {options:options, prefix:'day', id:id, name:name, class:djour[:class], style:''}
  end #/ date_field_jour

  def date_field_mois dmois
    options = (1..12).collect do |imois|
      selected = imois == dmois[:default_month] ? SELECTED : EMPTY_STRING
      TAG_OPTION % {value:imois, titre:MOIS[imois][dmois[:format_mois]], selected:selected}
    end.join('')
    id = "#{dmois[:prefix_id]}-month"
    name = "#{dmois[:prefix_id]}_month"
    TAG_SELECT % {options:options, prefix:'month', id:id, name:name, class:dmois[:class], style:''}
  end #/ date_field_mois


  def date_field_annee dannee
    first_year = dannee[:from] || dannee[:default_year] || Time.now.year
    to_year = dannee[:to] || (first_year + 10)
    options = (first_year..to_year).collect do |annee|
      selected = annee == dannee[:default_year] ? SELECTED : EMPTY_STRING
      TAG_OPTION % {value:annee, titre:annee, selected: selected}
    end.join('')
    id = "#{dannee[:prefix_id]}-year"
    name = "#{dannee[:prefix_id]}_year"
    TAG_SELECT % {options:options, prefix:'year', id:id, name:name, class:dannee[:class], style:''}
  end #/ date_field_annee
end # /<< self
end #/Form
