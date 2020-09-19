# encoding: UTF-8
# frozen_string_literal: true

# Modifier ci-dessous le "?v=X" pour forcer l'actualisation
CSS_JS_VERSION = '?v=8'
# CSS_JS_PREFIX  = App::URL
CSS_JS_PREFIX  = '.'
# CSS_JS_VERSION = ''
# CSS_JS_PREFIX  = ''
# CSS_JS_PREFIX  = '//www.atelier-icare.net/'

CSS_TAG = "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{CSS_JS_PREFIX}%{css}#{CSS_JS_VERSION}\" />"
JAVASCRIPT_TAG = "<script src=\"#{CSS_JS_PREFIX}%{js}#{CSS_JS_VERSION}\" type=\"text/javascript\" charset=\"utf-8\"></script>"

class HTML
  # Retourne les lignes de tag <link> pour les css
  def css_tags
    get_css
    @all_css.collect do |relcss|
      CSS_TAG % {css: relcss[1..-1]}
    end.join(RC)
  end

  # Retourne les lignes de tag <link> pour les css
  def js_tags
    get_js
    @all_js.collect do |reljs|
      JAVASCRIPT_TAG % {js: reljs[1..-1]}
    end.join(RC)
  end

  # Pour ajouter du code JS brut dans la page
  def raw_js_add code
    @raw_js ||= ""
    @raw_js = @raw_js.dup + code + RC
  end #/ raw_js_add

  # Pour ajouter des feuilles de style à la volée
  def add_css path
    @all_css ||= []
    @all_css << path.sub(/#{APP_FOLDER}/,'.')
    debug "[CSS] Ajout de #{path.sub(/#{APP_FOLDER}/,'.')}"
  end

  # Pour ajouter des feuilles de style à la volée
  def add_js path, before = false
    log("-> add_js(#{path})")
    @all_js ||= []
    path = path.sub(/#{APP_FOLDER}/,'.')
    if before
      @all_js.unshift(path)
    else
      @all_js << path
    end
    debug "[JS] Ajout de #{path}"
  end


  private

    def get_css
      Dir["./css/required/**/*.css"].each{|csspath| add_css(csspath)}
    end
    def get_js
      Dir["./js/required/**/*.js"].each{|jspath| add_js(jspath, true)}
    end
end #/HTML
