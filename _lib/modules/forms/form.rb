# encoding: UTF-8
=begin
  Utilitaire pour construire les formulaires
=end
class Form
  attr_reader :data
  attr_accessor :rows
  attr_accessor :submit_button
  attr_accessor :other_buttons

  def initialize form_data = nil
    if form_data.nil?
      # <= Pas de données de formulaire
      # => C'est une SOUMISSION de formulaire qu'on peut récupérer par le
      #   paramètre :form_token et :form_id
      @token  = URL.param(:form_token)
      @id     = URL.param(:form_id)
    else
      # <= Il y a des données de formulaire
      # => C'est une CRÉATION de formulaire
      @data = form_data
    end
  end

  # Sortie du formulaire
  # --------------------
  # On en profite aussi pour enregistrer son token
  def out
    save_token
    <<-HTML
<form id="#{data[:id]}" style="#{size}" action="" method="#{data[:method]||'POST'}">
  <input type="hidden" name="form_token" value="#{token}">
  <input type="hidden" name="form_id" value="#{data[:id]}">
  <input type="hidden" name="route" value="#{data[:action]||data[:route]}">
  #{build_rows}
  <div class="buttons">
    #{build_other_buttons}
    <input type="submit" value="#{submit_button}">
  </div>
</form>
    HTML
  end

  # Pour forcer la taille du formulaire
  def size
    "width:#{data[:size] ? "#{data[:size]}px" : 'auto'};"
  end #/ size

  # Retourne un token unique pour ce formulaire
  def token
    @token ||= Time.now.to_i.to_s
  end

  def load
    Marshal.load_file(File.read(token_path))
  end
  def save_token
    File.open(token_path,'wb'){|f|f.write session.id}
    # File.open(token_path,'wb'){|f|f.write 'un numéro'}
  end
  def read_token
    File.read(token_path).force_encoding('utf-8')
  end

  def token_path
    @token_path ||= File.join(FORMS_FOLDER, "#{token}")
  end

  def conform?
    File.exists?(token_path)  || raise("Le fichier token (#{token}) du formulaire est introuvable")
    read_token == session.id  || raise("Les données du token ne matchent pas…")
    # read_token == 'un numéro'  || raise("Les données du token ne matchent pas…")
    File.unlink(token_path)
    return true
  rescue Exception => e
    # error e.message
    debug e.message
    return false
  end

  def build_rows
    rows.collect do |label, dfield|
      if dfield[:type] == 'hidden'
        value_field_for(dfield)
      else
        <<-HTML
<div class="row">
  <span class="libelle">#{label}</span>
  <span class="value">
    #{value_field_for(dfield)}
  </span>
</div>
        HTML
      end
    end.join(RC)
  end

  TAGS_TYPES = {
    text: '<input type="text" id="%{id}" name="%{name}" value="%{value}" class="%{class}" />'.freeze,
    password: '<input type="password" id="%{id}" name="%{name}" value="%{value}" class="%{class}" />'.freeze,
    hidden: '<input type="hidden" id="%{id}" name="%{name}" value="%{value}" />'.freeze
  }

  def value_field_for dfield
    dfield.key?(:name) || raise("Il faut définir le paramètre :name")
    dfield.merge!(:id => dfield[:name].gsub(/-/,'_'))
    dfield[:value] ||= dfield[:default] || ''
    dfield.key?(:class) || dfield.merge!(class: '')
    field = TAGS_TYPES[dfield[:type].to_sym]
    field || raise("Type de balise/field inconnu: #{@dfield[:type]}")
    field % dfield
  end


  def build_other_buttons
    return '' if other_buttons.nil?
    <<-HTML
<div class="other_buttons">
  #{other_buttons.collect{|dbutton| button(dbutton)}.join('')}
</div>
    HTML
  end

  def button dbutton
    '<a class="btn small noborder" href="%{route}">%{text}</a>' % dbutton
  end


end #/Form
