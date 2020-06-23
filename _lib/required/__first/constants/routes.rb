# encoding: UTF-8
=begin
  Constantes ROUTES pour les routes raccourcies

  Pour créer facilement un lien vers une de ces routes, utiliser :
  Tag.route(<route id>[, titre, options])

  Ce module doit rester public, c'est-à-dire qu'il doit pouvoir être
  chargé par les tests sans autre forme de procès.
  
=end
ROUTES = {
  aide:             'aide/home',
  hall_of_fame:     'overview/reussites',
  parcours_fictifs: 'overview/parcours',
  phil:             'overview/phil'
}

class Route
  REDIRECTIONS = {
    # - SIMPLE ICARIEN -
    0 => {hname: 'Bureau de travail',       route: :bureau},
    4 => {hname: 'Notifications',           route: 'bureau/notifications'},
    5 => {hname: 'Travail en cours',        route: 'bureau/travail'},
    2 => {hname: 'Profil',                  route: :profil},
    3 => {hname: 'Dernière page consultée', route: :last_page},
    1 => {hname: 'Accueil du site',         route: :home},
    # - ADMINISTRATEUR -
    7 => {hname: 'Tableau de bord', route: 'admin/home', admin: true},
    8 => {hname: 'Console', route: 'admin/console', admin: true},
    9 => {hname: 'Notifications', route: 'admin/notifications', admin: true}
  }
end #/Route
