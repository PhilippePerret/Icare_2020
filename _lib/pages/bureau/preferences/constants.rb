# encoding: UTF-8
=begin
  Attention : ces constantes ne sont pas à mettre dans constants.rb qui
  peut être chargé par les tests.
=end
require_relative 'constants_public'
require_modules(['user/modules'])

VALUES_REDIRECTION_AFTER_LOGIN = []
Route::REDIRECTIONS.each do |vdir, ddir|
  next if ddir[:admin] && !user.admin?
  VALUES_REDIRECTION_AFTER_LOGIN << [vdir, ddir[:hname]]
end

VALUES_SHARING    = DATA_SHARINGS.collect{|k,d|[k,d[:name]]}
VALUES_CONTACTS   = DATA_CONTACTS.collect{|k,d|[k,d[:name]]}
VALUES_FREQ_MAIL  = DATA_FREQ_MAIL.collect {|k,d| [k, d[:name]]}

DATA_PREFERENCES = {
  # key = nom propriété dans le formulaire, qui sera préfixé par 'prefs-'
  # value : {label:"Label de la propriété"}
  after_login:      {label: "Après identification".freeze, if: user.actif?, type:SELECT, bit:18, values:VALUES_REDIRECTION_AFTER_LOGIN},
  freqs_actus:      {label: "Actualités".freeze, type:SELECT, bit:4, values:VALUES_FREQ_MAIL},
  contact_admin:    {label:'Contacts administration'.freeze, type:SELECT, bit:26, values:VALUES_CONTACTS},
  contact_icarien:  {label:'Contacts icariens', type:SELECT, bit:27, values:VALUES_CONTACTS},
  contact_world:    {label: 'Contacts (monde)'.freeze, type:SELECT, bit:28, values:VALUES_CONTACTS},
  share_histo:      {label: 'Partage historique'.freeze, bit:21, values:VALUES_SHARING},
  project_name:     {label: "Titre projet".freeze, if: user.actif?, type:TEXT, value: user.project_name},
}
