# encoding: UTF-8
# frozen_string_literal: true
class Concurrent
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :user_id, :session_id
def initialize(ini_data)
  @user_id    = ini_data[:user_id]
  @session_id = ini_data[:session_id]
end #/ initialize
# Pour charger le concurrent depuis la table
# On doit réussir à le faire avec l'ID de session et l'user_id gardé en session
def data
  @data ||= db_get(DBTABLE_CONCURRENTS, {user_id:user_id, session_id:session_id})
end #/ load

# ---------------------------------------------------------------------
#
#   Propriétés
#
# ---------------------------------------------------------------------
def pseudo
  @pseudo ||= data[:patronyme]
end #/ pseudo

# ---------------------------------------------------------------------
#
#   Statut
#
# ---------------------------------------------------------------------

# Retourne TRUE pour savoir si le concurrent, identifié par le user_id en
# session et l'identifiant de session fourni existe véritablement dans la
# base de données.
def exists?
  data != nil
end #/ exists?

# Retourne TRUE si le concurrent veut recevoir sa fiche de lecture
def fiche_lecture?

end #/ fiche_lecture?

# Retourne TRUE si le dossier de participation a été transmis
# Deux conditions :
#   - la propriété dossier_complete dans la DB est à 1
#   - le fichier physique existe
def dossier_transmis?

end #/ dossier_complete?


end #/Concurrent
