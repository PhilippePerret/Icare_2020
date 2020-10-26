# encoding: UTF-8
# frozen_string_literal: true
class User
  def evaluateur?
    # Pour le moment, on est évaluateur quand on est administrateur
    # TODO : Plus tard, c'est un bit des options qui permettra de le
    # savoir et on pourra être évaluateur sans être administrateur
    admin?
  end #/ evaluateur?

  # OUT   TRUE si l'user est concurrent des concours (le concours courant
  #       ou non).
  # Pour voir s'il est concurrent du concours courant, voir la méthode
  # concurrent_session_courante?
  def concurrent?
    db_count(DBTBL_CONCURRENTS, {mail: mail}) > 0
  end #/ concurrent?

  # OUT   TRUE si l'user est concurrent de la session courante du concours
  def concurrent_session_courante?
    return false if not concurrent?
    dc = db_get(DBTBL_CONCURRENTS, {mail: mail})
    db_count(DBTBL_CONCURS_PER_CONCOURS, {concurrent_id: dc[:concurrent_id], annee:Concours.current.annee}) > 0
  end #/ concurrent_session_courante?
end #/User
