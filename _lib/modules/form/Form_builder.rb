# encoding: UTF-8
=begin
  Utilitaire pour construire les formulaires
=end
class Form
  attr_reader :id
  attr_reader :data
  attr_accessor :rows
  attr_reader :submit_button
  attr_accessor :submit_button_class
  attr_accessor :other_buttons
  attr_accessor :options

  def submit_button= name
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

  def build_submit_button
    INPUT_SUBMIT_BUTTON % {name:submit_button, class:submit_button_class||''}
  end #/ build_submit_button

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
      sty << "width:#{form_size};" unless form_size.nil?
      sty.empty? ? '' : " style=\"#{sty.join(';')}\""
    end
  end #/ form_style

  # La dimension du formulaire
  # Elle sera calculée en fonction de la définition ou non des libelle_size,
  # et :value_size ou de sa définition explicite
  def form_size
    @form_size ||= begin
      if data.key?(:size)
        "#{data[:size]}px"
      elsif libelle_size || value_size
        "calc(#{libelle_size||DEFAULT_LIBELLE_WIDTH} + #{value_size||'auto'})"
      else
        nil
      end
    end
  end #/ form_size
  def libelle_size
    @libelle_size ||= begin
      # Quand défini dans les arguments d'instanciation (data)
      "#{data[:libelle_size]}px" unless data[:libelle_size].nil? # si défini explicitement
    end
  end #/ libelle_size
  def libelle_size= value
    @libelle_size = value.is_a?(Integer) ? "#{value}px" : value
  end #/ libelle_size
  def value_size
    @value_size ||= begin
      if data[:value_size].nil?
        DEFAULT_VALUE_WIDTH
      else
        # Quand défini dans les arguments d'instanciation (data)
        "#{data[:value_size]}px"
      end
    end
  end #/ value_size
  def value_size= value
    @value_size = value.is_a?(Integer) ? "#{value}px" : value
  end #/ value_size=

  # Pour voir s'il faut ajouter du style au .libelle
  def libelle_style
    @libelle_style ||= begin
      sty = []
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
<div class="row"#{row_style}>
  <span class="libelle"#{libelle_style}>#{label}</span>
  <span class="value#{" file" if dfield[:type] == 'file'}">
    #{value_field_for(dfield)}
  </span>
</div>
        HTML
      end
    end.join(RC)
  end

  # Maintenant que le div.row est un display:grid, on peut définir la largeur
  # des libellés et des champs value par libelle_size et value_size, mais ils
  # affecteront la propriété :grid-template-columns du row
  def row_style
    sty = []
    if libelle_size || value_size
      sty << "grid-template-columns:#{libelle_size||'auto'} #{value_size||'auto'};"
    end
    sty.empty? ? EMPTY_STRING : " style=\"#{sty.join('')}\""
  end #/ row_style

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
    dfield.merge!(type:'text') unless dfield.key?(:type)
    is_type_sans_champ = ['titre','explication','raw'].include?(dfield[:type])
    dfield.key?(:name) || is_type_sans_champ || raise("Il faut définir le paramètre :name")
    unless is_type_sans_champ
      dfield.key?(:id) || dfield.merge!(id: dfield[:name])
      dfield[:value] ||= dfield[:default] || param(dfield[:name].to_sym) || ''
    end
    dfield.key?(:class) || dfield.merge!(class: '')
    # - style -
    if dfield.key?(:style)
      dfield[:style] = [dfield[:style]]
    else
      dfield.merge!(style: [])
    end
    dfield[:style] << "width:#{dfield[:size]}px;" if dfield.key?(:size)
    dfield[:style] << "height:#{dfield[:height]}px;" if dfield.key?(:height)
    dfield[:style] = dfield[:style].join('')

    case dfield[:type].to_s
    when 'raw'.freeze
      dfield.merge!(content: dfield[:content]||dfield[:value]||[dfield[:name]])
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
