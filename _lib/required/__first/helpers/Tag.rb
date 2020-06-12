# encoding: UTF-8
=begin
  Module contenant notamment la class Tag qui permet d'avoir
  des balises très facilement à l'aide de Tag.<type>
=end
class Tag
class << self

  # Un lien vers une aide
  #
  # Usage :     `Tag.aide(id: '<mon-id-aide>'[, titre:, class: ...])`
  # +<nom-id-aide>+ correspond au numéro ou au nom du fichier d'aide à afficher
  def aide params
    if params.is_a?(String) || params.is_a?(Integer)
      params = {id: params.to_s}
    end
    Tag.lien(titre:params[:titre]||'aide', route:"aide/fiche?aid=#{params[:id]}")
  end #/ aide

  # Un lien quelconque
  #
  # Si params[:new], on met le target à _blank
  def lien params
    params[:new] && params.merge!(target: '_blank')
    params[:target] ||= '_self'
    params[:titre] = params[:text] if params.key?(:text)
    params = normalize_params(params, [:id, :route, :class, :titre, :title, :target, :style])
    (TAG_LIEN % params).freeze
  end #/ lien
  alias :link :lien

  def route route_id, titre = nil, params = nil
    params ||= {}
    params.merge!(text: titre)
    params.merge!(route: ROUTES[route_id]||route_id)
    Tag.lien(params)
  end #/ route

  def div params
    params = {text: params} if params.is_a?(String)
    params = normalize_params(params, [:id, :text, :class, :style])
    (TAG_DIV % params).freeze
  end #/ div

  def info_bulle(message, options = nil)
    options ||= {}
    if options.key?(:text)
      options.merge!(class: 'texte')
    elsif options.key?(:aide)
      options.merge!(class:'texte', text: message)
    else
      options.merge!(class: 'picto', text:'(?)')
    end
    options.merge!(aide: message) unless options.key?(:aide)
    (TAG_INFO_BULLE % options).freeze
  end #/ info_bulle

  def li params
    params = {text: params} if params.is_a?(String)
    params = normalize_params(params, [:id, :text, :class, :style])
    (TAG_LI % params).freeze
  end #/ li

  # Un champ HIDDEN
  def hidden params
    params = normalize_params(params, [:id, :name, :route])
    (HIDDEN_FIELD % params).freeze
  end #/ hidden

  # Un SPAN
  def span params
    params = normalize_params(params, [:text, :class, :style, :title])
    (TAG_SPAN % params).freeze
  end #/ span

  def submit_button params, options = nil
    options ||= {}
    if params.is_a?(String)
      params = options.merge({name: params})
    end
    params.merge!(options) unless options.nil?
    css = [params[:class] || options[:class]].compact
    css << 'btn'
    params[:class] = css.join(' ')
    params = normalize_params(params, [:text, :class])
    (SUBMIT_BUTTON % params).freeze
  end #/ submit_button

  # Un lien de retour, avec un ↩︎ au début (comme dans les titres)
  def retour params
    (RETOUR_LINK % params).freeze
  end #/ retour

  # Renvoie une pastille (span.pastille) avec le +nombre+ ou
  # un string vide
  # +options+
  #   :linked   Si true, on met un lien pour rejoindre la section
  #             des notifications.
  def pastille_nombre(nombre, options = nil)
    return '' if nombre == 0
    if options && options[:linked]
      nombre = self.lien(route:"#{user.admin? ? 'admin' : 'bureau'}/notifications", text:nombre)
    end
    pasti = TAG_PASTILLE % [nombre.to_s]
    return pasti
  end #/ pastille

  # Retourne le lien vers le bureau suivant que c'est l'administrateur
  # ou un icarien qui visite
  def lien_bureau
    home_bureau = user.admin? ? 'admin/home' : 'bureau/home'
    "<a href=\"#{home_bureau}\">Bureau</a>".freeze
  end #/ bureau

  def aname(ancre)
    TAG_ANCHOR % [ancre]
  end #/ aname

  private

    # @private
    # Pour normaliser les paramètres afin qu'ils contiennent toutes les
    # propriétés pour la templatisation
    def normalize_params(params, required)
      required.each do |prop|
        params.merge!(prop => "") unless params.key?(prop)
      end
      if params.key?(:route) && params[:full]
        params[:route] = "#{App::URL}/#{params[:route]}"
      end
      params
    end #/ normalize_params
end # /<< self
end #/Tag

# Constantes tags
# Note : d'autres sont définis dans ./_lib/modules/forms/constants.rb qui
# sera chargé avec 'require_module('form')'
TAG_SPAN  = '<span class="%{class}" style="%{style}" title="%{title}">%{text}</span>'.freeze
TAG_INFO_BULLE  = '<span class="info-bulle %{class}"><span class="info-bulle-clip">%{text}</span><span class="info-bulle-aide">%{aide}</span><span>'.freeze
TAG_LIEN  = '<a href="%{route}" id="%{id}" class="%{class}" title="%{title}" target="%{target}" style="%{style}">%{titre}</a>'.freeze
TAG_DIV   = '<div id="%{id}" class="%{class}" style="%{style}">%{text}</div>'.freeze
TAG_LI    = '<li id="%{id}" class="%{class}" style="%{style}">%{text}</li>'.freeze
TAG_ANCHOR    = '<a name="%s"></a>'.freeze
TAG_PASTILLE  = '<span class="pastille">%s</span>'.freeze

# Formulaires
HIDDEN_FIELD  = '<input type="hidden" id="%{id}" name="%{name}" value="%{value}" />'.freeze
SUBMIT_BUTTON = '<input type="submit" class="%{class}" value="%{name}" />'.freeze

RETOUR_LINK = "<a href='%{route}' class='small'><span style='vertical-align:sub;'>↩︎</span>&nbsp;%{titre}</a>&nbsp;".freeze

RETOUR_BUREAU = Tag.retour(route:'bureau/home'.freeze, titre:'Bureau'.freeze)
RETOUR_PROFIL = Tag.retour(route:'user/profil'.freeze, titre:'Profil'.freeze)
