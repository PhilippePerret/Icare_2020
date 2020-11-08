# encoding: UTF-8
# frozen_string_literal: true
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

  # Retourne TRUE si c'est un formulaire sans libellé
  def no_libelle?
    @is_sans_libelle = (data[:class]||'').match?(/\bnolibelle\b/) if @is_sans_libelle.nil?
    @is_sans_libelle
  end #/ no_libelle?

  # OUT   TRUE si le formulaire est "inline"
  def inline?
    return false if data[:class].nil?
    data[:class].include?('inline')
  end #/ inline?

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
      if data[:style]
        " style=\"#{data[:style]}\""
      else
        sty = []
        sty.empty? ? '' : " style=\"#{sty.join(';')}\""
      end
    end
  end #/ form_style

  # Pour voir s'il faut ajouter du style au .libelle
  def libelle_style; @libelle_style end #/ libelle_style

  # Retourne la class CSS du formulaire (tag form)
  def css
    @css ||= begin
      c = []
      c << data[:class] if data.key?(:class)
      c << 'nogrid' if inline?
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
    File.exists?(token_path)  || raise(ERRORS[:token_file_unfound] % [token])
    read_token == session.id  || raise(ERRORS[:token_data_dont_match])
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
<div class="#{row_class(dfield)}"#{row_style(dfield)}>
  #{span_libelle(style: libelle_style, label: label)}
  <span class="value#{" file" if dfield[:type] == 'file'}">
    #{value_field_for(dfield)}
    #{errorable_field(dfield) if dfield[:errorable]}
    #{explication_field(dfield) if dfield.key?(:explication)}
  </span>
</div>
        HTML
      end
    end.join(RC)
  end

  def row_class(dfield)
    c = []
    c << 'row' unless dfield[:norow]
    c << dfield[:class] if dfield[:class]
    c << 'nogrid' if inline?
    c.join(SPACE)
  end #/ row_class

  SPAN_LIBELLE = '<span class="libelle"%{style}>%{label}</span>'
  # Retourne le span pour la libelle
  # Sauf si c'est un formulaire sans libellé (nolibelle) raison pour laquelle
  # cette construction a été séparée
  def span_libelle(dspan)
    (SPAN_LIBELLE % dspan) unless no_libelle?
  end #/ span_libelle

  # Une explication du champ est peut-être donnée
  def explication_field(dfield)
    EXPLICATION_TAG % {text: dfield[:explication], style:''}
  end #/ explication_field

  def errorable_field(dfield)
    ERRORABLE_FIELD % {id: "#{dfield[:id]}-errorfield"}
  end #/ errorable_field

  def row_style(dfield)
    sty = []
    if dfield[:nogrid] || no_libelle?
      sty << 'grid-template-columns:auto!important;'
    end
    sty.empty? ? EMPTY_STRING : " style=\"#{sty.join('')}\""
  end #/ row_style

  # Méthode principale qui retourne le champ de saisie
  def value_field_for dfield
    dfield = default_values_for(dfield)
    dfield || raise(ERRORS[:data_field_required])
    field = case dfield[:type].to_sym
            when :date
              Form.date_field({
                prefix_id:dfield[:name],
                default:dfield[:value]||dfield[:default],
                from: dfield[:from], to: dfield[:to]
              })
            when :checkboxes
              traite_checkboxes(dfield)
            else
              TAGS_TYPES[dfield[:type].to_sym]
            end
    # log("field:#{field} / dfield:#{dfield}")
    field || raise(ERRORS[:unknown_tag_type] % dfield[:type])
    field % dfield
  end

  # OUT   Le field (template %{...}) pour une liste de checkboxes
  # IN    Les données du champ avec notamment :name qui va permettre de
  #       définir les NAME de chaque checkbox et :values qui définit les
  #       titre et les sous-name propres de chaque checkbox
  def traite_checkboxes(dfield)
    dfield[:values].collect do |tit,val|
      cbname  = '%{name}'
      cbid = "%{name}_#{val}"
      cbchk   = param(dfield[:name]) && param(dfield[:name])[val.to_sym] ? ' CHECKED' : '';
      Tag.div(text: CHECKBOX_TAG % {id:cbid, value:val, name:cbname, checked: cbchk, values:tit})
      # cbname  = cbid = "%{name}_#{val}"
      # cbchk   = param(dfield[:name]) && param(dfield[:name])[val.to_sym] ? ' CHECKED' : '';
      # Tag.div(text: CHECKBOX_TAG % {id:cbid, name:cbname, checked: cbchk, values:tit})
    end.join
  end #/ traite_checkboxes

  # Appliquer les valeurs par défaut manquantes et les retourne
  def default_values_for(dfield)
    dfield.merge!(type:'text') unless dfield.key?(:type)
    is_type_sans_champ = ['titre','explication','raw'].include?(dfield[:type])
    dfield.key?(:name) || is_type_sans_champ || raise(ERRORS[:name_param_required])
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
    when 'raw'
      dfield.merge!(content: dfield[:content]||dfield[:value]||dfield[:name])
    when 'checkbox'
      dfield.merge!(checked: param(dfield[:name].to_sym) ? ' CHECKED' : '')
      dfield.merge!(value:'on') if not(dfield.key?(:value))
    # when 'checkboxes'
    #
    when 'textarea'
      dfield.key?(:height) || dfield.merge!(height: 60)
      dfield.key?(:placeholder) || dfield.merge!(placeholder:'')
    when TEXT
      dfield.key?(:placeholder) || dfield.merge!(placeholder:'')
    when SELECT
      if dfield.key?(:values) && !dfield.key?(:options)
        if dfield[:values].is_a?(String)
          dfield.merge!(options: dfield[:values])
        else
          # Valeur
          curvalue = dfield[:default] || dfield[:value]
          # Il faut construire les options d'après les values
          dfield.merge!(:options => dfield[:values].collect do |paire|
            paire = [paire, paire] unless paire.is_a?(Array)
            selected = paire[0].to_s == curvalue.to_s ? SELECTED : EMPTY_STRING
            TAG_OPTION % {value:paire[0], titre:(paire[1]||paire[0]), selected:selected}
          end.join)
        end
      end
      dfield.merge!(prefix: '') unless dfield.key?(:prefix)
    when 'file'
      dfield[:button_name] ||= 'Choisir le fichier…'
    when 'explication'
      dfield[:text] ||= dfield[:value] || dfield[:name] || dfield[:content]
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
    case dbutton
    when Hash
      css = ['btn']
      unless dbutton.key?(:class)
        css << 'small noborder'
      else
        css << dbutton[:class]
      end
      dbutton[:class] = css.join(SPACE)
      dbutton[:titre] ||= dbutton.delete(:text)
      TAG_LIEN_SIMPLE % dbutton
    when String
      dbutton
    else
      raise ERRORS[:other_button_invalid]
    end
  end


end #/Form
