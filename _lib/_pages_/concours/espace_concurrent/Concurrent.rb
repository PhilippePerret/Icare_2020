# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la classe Concurrent
=end
class Concurrent

  # DO    Déconnecte le concurrent courant
  def logout
    session.delete('concours_user_id')
    message("À la prochaine, #{self.pseudo} !")
    redirect_to('concours')
  end #/ logout


  # IN    True si le concurrent veut recevoir la fiche de lecture
  # DO    Règle les options du concurrent pour qu'il reçoive ou non la
  #       fiche de lecture.
  def change_pref_fiche_lecture(recevoir)
    set_option(1, recevoir ? '1' : '0')
    update_options
    @fiche_lecture = nil
  end #/ change_pref_fiche_lecture

  # IN    True si le concurrent veut être informé des avancées du concours
  # DO    Règle les options du concurrent pour qu'il soit informé ou non
  def change_pref_warn_information(recevoir)
    set_option(0, recevoir ? '1' : '0')
    update_options
    @is_warned = nil
  end #/ change_pref_warn_information

end #/Concurrent
