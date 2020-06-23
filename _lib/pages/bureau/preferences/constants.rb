# encoding: UTF-8
=begin
  Attention : ces constantes ne sont pas à mettre dans constants.rb qui
  peut être chargé par les tests.
=end
require_modules(['user/modules'])

VALUES_REDIRECTION_AFTER_LOGIN = []
Route::REDIRECTIONS.each do |vdir, ddir|
  next if ddir[:admin] && !user.admin?
  VALUES_REDIRECTION_AFTER_LOGIN << [vdir, ddir[:hname]]
end

VALUES_SHARING = [
  [FLAG_ICARIENS, 'avec les icariens'],
  [FLAG_WORLD,    'avec tout le monde'],
  [0,             'avec personne']
]

VALUES_CONTACT = [
  [FLAG_MAIL|FLAG_FRIGO, 'par Mail et sur le frigo'],
  [FLAG_MAIL, 'par Mail seulement'],
  [FLAG_FRIGO,'sur le frigo seulement'],
  ['0','Aucun contact']
]
VALUES_FREQ_MAIL = [
  ['0', 'Mail quotidien (si actualité)'],
  ['1', 'Résumé hebdomadaire'],
  ['9', 'Jamais']
]

DATA_PREFERENCES = {
  # key = nom propriété dans le formulaire, qui sera préfixé par 'prefs-'
  # value : {label:"Label de la propriété"}
  after_login:      {label: "Après identification", if: user.actif?, type:'select', bit:18, values:VALUES_REDIRECTION_AFTER_LOGIN},
  freqs_actualites: {label: "Actualités", type:'select', bit:4, values:VALUES_FREQ_MAIL},
  contact_admin:    {label:'Contacts administration', type:'select', bit:26, values:VALUES_CONTACT},
  contact_icariens: {label:'Contacts icariens', type:'select', bit:27, values:VALUES_CONTACT},
  contact_world:    {label: 'Contacts (monde)'.freeze, type:'select', bit:28, values:VALUES_CONTACT},
  share_histo:      {label: 'Partage historique'.freeze, bit:21, values:VALUES_SHARING},
  project_name:     {label: "Titre projet", if: user.actif?, type:'text', value: user.project_name},
}
