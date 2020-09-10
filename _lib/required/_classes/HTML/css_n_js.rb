# encoding: UTF-8

# Modifier ci-dessous le "?v=X" pour forcer l'actualisation
CSS_TAG = '<link rel="stylesheet" type="text/css" href="%{css}?v=4" />'.freeze
JAVASCRIPT_TAG = '<script src="%{js}?v=4" type="text/javascript" charset="utf-8"></script>'.freeze

class HTML
  # Retourne les lignes de tag <link> pour les css
  def css_tags
    get_css
    @all_css.collect do |relcss|
      CSS_TAG % {css: relcss}
    end.join(RC)
  end

  # Retourne les lignes de tag <link> pour les css
  def js_tags
    get_js
    @all_js.collect do |reljs|
      JAVASCRIPT_TAG % {js: reljs}
    end.join(RC)
  end

  # Pour ajouter du code JS brut dans la page
  def raw_js_add code
    @raw_js ||= ""
    @raw_js << code + RC
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
