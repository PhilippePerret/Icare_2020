# encoding: UTF-8
# frozen_string_literal: true

module HelpersWritingMethods

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
    unless user_id.nil?
      usr = CheckedUser.get(user_id)
      usr = nil if usr.data.nil?
      usr
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
    (user_id != nil && user_id > 0) ? :true : :false
  end) == :true
end #/ has_user_id

def has_owner
  (@it_has_owner ||= begin
    (has_user_id && CheckedUser.exists?(user_id)) ? :true : :false
  end) == :true
end #/ has_owner



end #/HelpersWritingMethods
