# encoding: UTF-8
=begin
  Utilitaire pour construire les formulaires
=end
class Form
  attr_reader :data
  attr_accessor :rows
  attr_reader :submit_button
  attr_accessor :other_buttons
  attr_accessor :options

  def submit_button=(name, options = nil)
    self.options ||= {}
    self.options.merge!(options) unless options.nil?
    @submit_button = name
  end #/ submit_button

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
      @data[:watcher_id] = @data[:watcher] if @data.key?(:watcher)
    end
  end

  # Sortie du formulaire
  # --------------------
  # On en profite aussi pour enregistrer son token
  def out
    save_token
    <<-HTML
<form id="#{data[:id]}"#{form_style}#{enctype} action="" method="#{data[:method]||'POST'}" class="#{css}">
  <input type="hidden" name="form_token" value="#{token}">
  <input type="hidden" name="form_id" value="#{data[:id]}">
  <input type="hidden" name="route" value="#{data[:action]||data[:route]}">
  #{champs_watchers if data[:watcher_id]}
  #{build_rows}
  <div class="buttons">
    #{build_other_buttons}
    #{build_submit_button}
  </div>
</form>
    HTML
  end

  INPUT_SUBMIT_BUTTON = '<input type="submit" value="%{name}" class="%{class}">'

  def build_submit_button
    INPUT_SUBMIT_BUTTON % {name:submit_button, class:options[:submit_button_class]||''}
  end #/ build_submit_button

  WATCHER_HIDDEN_FIELDS = '<input type="hidden" name="op" value="run" /><input type="hidden" name="wid" value="%{wid}" />'.freeze
  # Les deux champs :wid et :ope qui permettent de soumettre le watcher
  def champs_watchers
    WATCHER_HIDDEN_FIELDS % {wid: data[:watcher_id]}
  end #/ champs_watchers

  def enctype
    return unless files?
    ' enctype="multipart/form-data"'
  end #/ enctype

  def form_style
    @form_style ||= begin
      sty = []
      sty << "width:#{data[:size]}px;" if data.key?(:size)
      sty.empty? ? '' : " style=\"#{sty.join(';')}\""
    end
  end #/ form_style

  # Pour voir s'il faut ajouter du style au .libelle
  def libelle_style
    @libelle_style ||= begin
      sty = []
      sty << "width:#{data[:libelle_size]}px;" if data.key?(:libelle_size)
      sty.empty? ? '' : " style=\"#{sty.join(';')}\""
    end
  end #/ libelle_style

  # Retourne la class CSS du formulaire (tag form)
  def css
    @css ||= begin
      c = []
      c << data[:class] if data.key?(:class)
      c.join(' ')
    end
  end #/ css
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

  # Retourne true si le formulaire contient des champs pour des fichiers
  # En plus, la méthode ajoute le module ./js/modules/form_with_files.js
  def files?
    if @has_files.nil?
      @has_files = searchforrowfile
      html.add_js('./js/modules/form_with_files.js') if @has_files
    end
    @has_files
  end #/ files?
  def searchforrowfile
    rows.each do |label,dfield|
      return true if dfield[:type].to_s == 'file'
    end
  end #/ searchforrowfile

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
      dfield.merge!(label: label)
      case dfield[:type]
      when 'hidden'
        value_field_for(dfield)
      when 'titre', 'explication'
        value_field_for(dfield)
      else
        #
        <<-HTML
<div class="row">
  <span class="libelle"#{libelle_style}>#{label}</span>
  <span class="value#{" file" if dfield[:type] == 'file'}">
    #{value_field_for(dfield)}
  </span>
</div>
        HTML
      end
    end.join(RC)
  end


  def value_field_for dfield
    dfield = default_values_for(dfield)
    dfield || raise("dfield doit être défini".freeze)
    field = TAGS_TYPES[dfield[:type].to_sym]
    # log("field:#{field} / dfield:#{dfield}")
    field || raise("Type de balise/field inconnu: #{dfield[:type]}")
    field % dfield
  end

  # Appliquer les valeurs par défaut manquantes et les retourne
  def default_values_for(dfield)
    dfield.key?(:name) || raise("Il faut définir le paramètre :name")
    dfield.merge!(:id => dfield[:name].gsub(/-/,'_'))
    dfield[:value] ||= dfield[:default] || param(dfield[:name].to_sym) || ''
    dfield.key?(:class) || dfield.merge!(class: '')
    # - style -
    dfield.merge!(style: []) unless dfield.key?(:style)
    dfield[:style] << "width:#{dfield[:size]}px;" if dfield.key?(:size)
    dfield[:style] << "height:#{dfield[:height]}px;" if dfield.key?(:height)
    dfield[:style] = dfield[:style].join('')

    case dfield[:type].to_s
    when 'checkbox'.freeze
      dfield.merge!(checked: param(dfield[:name].to_sym) ? ' CHECKED' : '')
    when 'textarea'.freeze
      dfield.key?(:height) || dfield.merge!(height: 60)
    when 'select'.freeze
      if dfield.key?(:values) && !dfield.key?(:options)
        # Il faut construire les options d'après les values
        dfield.merge!(:options => dfield[:values].collect do |paire|
          paire = [paire, paire] unless paire.is_a?(Array)
          OPTION_TAG % {value:paire[0], titre:(paire[1]||paire[0])}
        end.join)
      end
      dfield.merge!(prefix: ''.freeze) unless dfield.key?(:prefix)
    when 'file'.freeze
      dfield[:button_name] ||= 'Choisir le fichier…'.freeze
    end
    return dfield
  end #/ default_values_for


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
