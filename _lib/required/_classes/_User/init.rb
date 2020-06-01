# encoding: UTF-8
class User

  # Initialisation de l'user
  # Soit par son identifiant, soit par ses données
  def initialize foo
    case foo
    when Integer  then @data = db_get('users', {id: foo})
    when Hash     then @data = foo
    else
      raise "Impossible d'instancier un.e icarien.ne avec un #{foo.class}."
    end
  end

  def bind
    binding()
  end
end #/User
