# encoding: UTF-8
# frozen_string_literal: true
class User
  def evaluateur?
    # Pour le moment, on est évaluateur quand on est administrateur
    # TODO : Plus tard, c'est un bit des options qui permettra de le
    # savoir et on pourra être évaluateur sans être administrateur
    admin?
  end #/ evaluateur?

  # TODO Il faudra faire la distinction entre un concurrent icarien qui
  # est inscrit pour ce concours-ci et un icarien qui n'est pas du tout
  # inscrit. En fait, on peut avoir trois choses :
  # - un icarien jamais inscrit à aucun concours
  # - un icarien inscrit à un concours précédent
  # - un icarien inscrit à la session courante du concours (et inscrit ou
  #   non à des versions précédentes)
  def concurrent?
    db_count(DBTBL_CONCURRENTS, {mail: user.mail}) > 0
  end #/ concurrent?

end #/User
