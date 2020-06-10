# encoding: UTF-8

# Erreur levée lorsque le visiteur n'est pas un icarien et que la
# partie est réservée aux icariens
# @usage
#     Placer simplement le code `icarien_required` en début de méthode
class IdentificationRequiredError < StandardError; end

# Erreur levée lorsque le visiteur n'a pas le niveau Administrateur
# et qu'il essaie de rejoindre une partie d'administration.
# @usage
#     Placer simplement le code `admin_required` en début de méthode
class PrivilegesLevelError < StandardError; end
