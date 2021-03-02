# encoding: UTF-8
=begin
  Constantes ROUTES pour les routes raccourcies

  Pour créer facilement un lien vers une de ces routes, utiliser :
  Tag.route(<route id>[, titre, options])

  Ce module doit rester public, c'est-à-dire qu'il doit pouvoir être
  chargé par les tests sans autre forme de procès.

=end
ROUTES = {
  aide:                 'aide/home',
  hall_of_fame:         'overview/reussites',
  parcours_fictifs:     'overview/parcours',
  phil:                 'overview/phil'
}
