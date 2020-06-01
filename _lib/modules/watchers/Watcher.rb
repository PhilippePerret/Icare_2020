# encoding: UTF-8
=begin
  class Watchers
  --------------
  Pour la gestion des watchers
=end
class Watcher < ContainerClass
class << self

  # Retourne tous les watchers de l'icarien +icarien+
  # {Array de Watcher}
  def watchers_of icarien
    icarien = User.get(icarien) if icarien.is_a?(Integer)
    request = "SELECT * FROM #{table} WHERE user_id = #{icarien.id}"
    db_exec(request).collect do |dwatcher| new(dwatcher) end
  end #/ watchers_of

  def table
    @table ||= 'watchers'
  end #/ table
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Retourne true si le watcher a été vu par l'icarien
def vu?
  data[:vu] == true
end #/ vu?

end #/Watcher
