# encoding: UTF-8
# frozen_string_literal: true
class User
  def evaluateur?
    # Pour le moment, on est évaluateur quand on est administrateur
    # TODO : Plus tard, c'est un bit des options qui permettra de le
    # savoir et on pourra être évaluateur sans être administrateur
    admin?
  end #/ evaluateur?
end #/User
