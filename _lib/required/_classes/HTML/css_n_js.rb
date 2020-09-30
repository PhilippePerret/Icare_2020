# encoding: UTF-8
# frozen_string_literal: true

# Modifier ci-dessous le "?v=X" pour forcer l'actualisation
CSS_JS_VERSION = "?v=#{App.version}"
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
    if OFFLINE && update_css_required?
      update_all_css_file
      message("Le fichier all.css a été actualisé, il faut le téléverser.")
    end
    ([all_css_relpath] + (@all_css||[])).collect do |relcss|
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
    @table_css ||= {}
    return if @table_css.key?(path)
    @table_css.merge!(path => true)
    @all_css ||= []
    @all_css << path.sub(/#{APP_FOLDER}/,'.')
    debug "[CSS] Ajout de #{path.sub(/#{APP_FOLDER}/,'.')}"
  end

  # Pour ajouter des feuilles de style à la volée
  def add_js path, before = false
    @table_js ||= {}
    if @table_js.key?(path)
      return
    else
      @table_js.merge!(path => true)
    end
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

    # Méthode qui va actualiser le fichier css/all.css qui contient toutes
    # les feuilles de styles de base (dossier./css/required)
    def update_all_css_file
      File.delete(all_css_path) if File.exists?(all_css_path)
      ref = File.open(all_css_path,'a')
      ref.puts File.read(variables_css_path)
      get_css.each do |csspath|
        ref.puts(File.read(csspath))
      end
    ensure
      ref.close
    end #/ update_all_css_file

    # Méthode qui checke si le fichier ./css/all.css doit être actualisé
    def update_css_required?
      return true if not(File.exists?(all_css_path))
      all_css_time = File.stat(all_css_path).mtime.to_i
      get_css.each do |csspath|
        return true if File.stat(csspath).mtime.to_i > all_css_time
      end
      return true if File.stat(variables_css_path).mtime.to_i > all_css_time
      return false
    end #/ update_required?

    def get_css
      Dir["./css/required/**/*.css"]#.each{|csspath| add_css(csspath)}
    end
    def get_js
      Dir["./js/required/**/*.js"].each{|jspath| add_js(jspath, true)}
    end

    # Chemin d'accès au fichier contenant tous les CSS
    def all_css_path
      @all_css_path ||= File.join(APP_FOLDER,'css_all.css')
    end #/ all_css_path
    def all_css_relpath
      @all_css_relpath ||= './css_all.css'
    end #/ all_css_relpath
    def variables_css_path
      @variables_css_path ||= File.join(APP_FOLDER,'css','_variables.css')
    end #/ variables_css_path
end #/HTML
