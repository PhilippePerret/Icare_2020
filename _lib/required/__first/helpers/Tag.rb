# encoding: UTF-8
=begin
  Module contenant notamment la class Tag qui permet d'avoir
  des balises très facilement à l'aide de Tag.<type>
=end
class Tag
class << self

  # Un lien quelconque
  #
  # Si params[:new], on met le target à _blank
  def lien params
    params[:new] && params.merge!(target: '_blank')
    params[:target] ||= 'self'
    params = normalize_params(params, [:id, :route, :class, :titre, :title, :target])
    (TAG_LIEN % params).freeze
  end #/ lien
  alias :link :lien

  def div params
    params = {text: params} if params.is_a?(String)
    params = normalize_params(params, [:id, :text, :class, :style])
    (TAG_DIV % params).freeze
  end #/ div

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
    params = normalize_params(params, [:text, :class])
    (TAG_SPAN % params).freeze
  end #/ span

  def submit_button params
    params = {name: params} if params.is_a?(String)
    params = normalize_params(params, [:text, :class])
    (SUBMIT_BUTTON % params).freeze
  end #/ submit_button

  # Un lien de retour, avec un ↩︎ au début (comme dans les titres)
  def retour params
    (RETOUR_LINK % params).freeze
  end #/ retour

  private

    # @private
    # Pour normaliser les paramètres afin qu'ils contiennent toutes les
    # propriétés pour la templatisation
    def normalize_params(params, required)
      required.each do |prop|
        params.merge!(prop => "") unless params.key?(prop)
      end
      params
    end #/ normalize_params
end # /<< self
end #/Tag

# Constantes tags
# Note : d'autres sont définis dans ./_lib/modules/forms/constants.rb qui
# sera chargé avec 'require_module('form')'
TAG_SPAN  = '<span class="%{class}">%{text}</span>'.freeze
TAG_LIEN  = '<a href="%{route}" class="%{class}" title="%{title}" target="%{target}">%{titre}</a>'.freeze
TAG_DIV   = '<div id="%{id}" class="%{class}" style="%{style}">%{text}</div>'.freeze
TAG_LI    = '<li id="%{id}" class="%{class}" style="%{style}">%{text}</li>'.freeze

# Formulaires
HIDDEN_FIELD  = '<input type="hidden" id="%{id}" name="%{name}" value="%{value}" />'.freeze
SUBMIT_BUTTON = '<input type="submit" class="btn" value="%{name}" />'.freeze

RETOUR_LINK = "<a href='%{route}' class='small'><span style='vertical-align:sub;'>↩︎</span>&nbsp;%{titre}</a>&nbsp;".freeze

RETOUR_BUREAU = Tag.retour(route:'bureau/home'.freeze, titre:'Bureau'.freeze)
RETOUR_PROFIL = Tag.retour(route:'user/profil'.freeze, titre:'Profil'.freeze)
