# encoding: UTF-8
=begin
  Class Context
  -------------
  Pour gérer un contexte particulier
=end
class Context
  attr_reader :data
  attr_reader :pagechecker # pour le moment, c'est la classe PageChecker
  # +data+ Table des données à l'initialisation
  #   :titre      Le titre humain du contexte. P.e. "Administrateur"
  #   :context    L'ID du contexte (doit posséder sa méthode context_<context>)
  #   :not_deep   Liste des routes (URL sans base) qu'il ne faut pas fouiller
  #               profondément
  #   :exclude    Liste des routes (URL sans base) qu'il faut exclure complète-
  #               du traitement.
  def initialize pagechecker, data
    @data = data
    @pagechecker = pagechecker
  end #/ initialize data

  # ---------------------------------------------------------------------
  #
  #   PUBLIC METHODS
  #
  # ---------------------------------------------------------------------

  # Pour initialiser le contexte au niveau de CURL. Par exemple, pour
  # identifier un user identifié.
  def initiate
    if data[:context]
      Contexts.send("context_#{data[:context]}".to_sym)
    end
  end #/ initiate

  # Return TRUE si dans le contexte donné l'URL +url+ ne doit pas être
  # fouillée profondément (mais l'URL sera checkée)
  def deep?(iurl)
    not(table_not_deep.key?(iurl.href)) && not(table_not_deep.key?(iurl.pure_url))
  end #/ deep?

  # Return TRUE si, dans le contexte donné, l'URL +url+ doit être exclue
  def exclude?(iurl)
    table_exclusion.key?(iurl.href) || table_exclusion.key?(iurl.pure_url)
  end #/ exclude?

  def titre
    @titre ||= data[:titre] || "Contexte sans titre"
  end #/ titre

private
  def table_not_deep
    @table_not_deep ||= begin
      h = {}
      (data[:not_deep]||[]).each do |route|
        h.merge!( "#{pagechecker.base}/#{route}" => true)
      end; h;
    end
  end #/ table_not_deep

  # Table des URL à exclure
  def table_exclusion
    @table_exclusion ||= begin
      h = {}
      (data[:exclude]||[]).each do |route|
        h.merge!("#{pagechecker.base}/#{route}" => true)
      end; h;
    end
  end #/ table_exclusion

end #/Context
