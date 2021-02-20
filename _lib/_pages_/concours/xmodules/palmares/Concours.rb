# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Concours pour l'établissement des fichiers de
  palmares
=end
class Concours
class << self

  # Fabrication de la section "Palmarès des précédentes sessions" qui
  # affiche des liens vers les sessions précédentes des concours.
  def build_section_previous_sessions
    code = ['<h3>Palmarès des précédentes sessions</h3>']
    code << previous_sessions.collect{|concours| concours.lien_palmares}.join
    File.open(previous_sessions_file,'wb'){|f|f.write(code.join)}
  end #/ build_section_previous_sessions

  def previous_sessions
    @previous_sessions ||= begin
      db_exec("SELECT annee FROM #{DBTBL_CONCURS_PER_CONCOURS} GROUP BY annee ORDER BY annee DESC").collect do |dc|
        next if dc[:annee] == current.annee
        new(dc[:annee])
      end.compact
    end
  end

end # /<< self class

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Un lien pour revoir le palmarès
def lien_palmares
  @lien_palmares ||= begin
    Linker.new(route:"concours/palmares?an=#{annee}", text: "Palmarès de la session #{annee}")
  end
end

end #/Concours
