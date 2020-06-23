# encoding: UTF-8
require_modules(['user/modules','form'])
class HTML
  def titre
    "#{RETOUR_BUREAU}🏠 Vos préférences".freeze
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
    if param(:form_id)
      # Soumission du formulaire de préférences
      form = Form.new
      save_preferences if form.conform?
    end
  end
  def build_body
    # Construction du body
    @body = deserb('body', self)
  end

  # Enregistrement des préférences de l'icarien
  def save_preferences
    # Pour savoir si les options ont été modifiées (pour enregistrer
    # seulement une fois)
    options_have_been_modified = false
    # On boucle sur les préférences et on ne prend en compte que les
    # changement
    DATA_PREFERENCES.each do |kpref, dpref|
      new_value = param("prefs-#{kpref}".freeze)
      if dpref.key?(:bit)
        log("--- Ancienne et nouvelle valeur : #{user.option(dpref[:bit]).inspect} / #{new_value.to_i}")
        next if user.option(dpref[:bit]) == new_value.to_i
        user.set_option(dpref[:bit], new_value, false)
        options_have_been_modified = true
      elsif kpref == :project_name
        next if new_value == user.project_name
        user.icmodule.set(project_name: new_value)
        message MESSAGES[:confirm_titre_projet_saved]
      end
    end
    if options_have_been_modified
      user.save(:options)
      message MESSAGES[:confirm_options_saved]
    end
  end #/ save_preferences
end #/HTML
