# encoding: UTF-8
# frozen_string_literal: true

module HelpersWritingMethods

# Pour une erreur particulière à mettre dans le message d'erreur
# Mais en général, puisque chaque check doit être pensé précis, ce message
# n'est pas utile. Il a été inauguré pour le check des watchers d'étape, où
# le retour doit préciser par exemple les watchers qui manquent ou qui sont en
# trop
# @usage : on utile "%{error}" dans le message de retour et on définit @error
# au cours du check
attr_reader :error

# = main =
# Procède au check de l'icarien
def check
  puts "🔬 Étude de #{ref}".jaune if VERBOSE
  self.class::CHECKCASES.each { |cc| CheckCase.new(self, cc).proceed }
end #/ check


# ---------------------------------------------------------------------
#
#   Méthodes d'helpers
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
#
#   Méthodes de données
#
# ---------------------------------------------------------------------

# Retourne le propriétaire de la chose (de l'icmodule, du document, etc.)
def owner
  @owner ||= begin
    if has_owner
      CheckedUser.get(user_id)
    end
  end
end #/ owner

# ---------------------------------------------------------------------
#
#   Méthodes de condition
#
# ---------------------------------------------------------------------

def has_user_id
  (@it_has_user_id ||= begin
    (respond_to?(:user_id) && user_id != nil && user_id > 0) ? :true : :false
  end) == :true
end #/ has_user_id

def has_owner
  (@it_has_owner ||= begin
    (has_user_id && CheckedUser.exists?(user_id)) ? :true : :false
  end) == :true
end #/ has_owner

# Retourne true si l'objet possède des watchers
def has_watchers
  (@it_has_watchers ||= begin
    (respond_to?(:watchers) && watchers.count > 0) ? :true : :false
  end) == :true
end #/ has_watchers


end #/HelpersWritingMethods
