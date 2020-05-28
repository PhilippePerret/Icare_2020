# encoding: UTF-8
=begin
  Module pour checker les données de l'utilisateur

  Ce module sert par exemple à la création d'une candidature ou à
  l'édition du profil.

=end
class User
  class << self

    # Vérification complète des données
    # +values+ {Hash} des données à checker
    # +user_comp+ {User} Instance éventuelle de l'user concerné, par exemple
    #     lorsque c'est son profil qui est édité. Ça peut servir pour les
    #     message d'erreur.
    def checker_data(values, user_comp = nil)
      error = []
      if values.key?(:mail)
        # TODO Il faut checker le mail
      end
      if values.key,(:pseudo)
        # TODO il faut checker le pseudo
      end
    end #/ checker_data
  end # /<< self
end #/User
