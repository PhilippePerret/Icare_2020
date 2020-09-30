# encoding: UTF-8
# frozen_string_literal: true

ERRORS.merge!({
  unkown_user:    'Je ne vous reconnais pas. Merci de ré-essayer.',
  mail_required:  'Pour vous identifier, il faut fournir votre mail.',
  pwd_required:   'Pour vous identifier, votre mot de passe est requis (celui utilisé pour candidater à l’atelier).'
})

UI_TEXTS.merge!({
  btn_login: 'S’identifier',
  btn_singup: 'S’inscrire',
  btn_forgottent_password: 'Mot de passe oublié',
})

REDIRECTIONS_AFTER_LOGIN = {
  # - SIMPLE ICARIEN -
  0 => {hname: 'Bureau de travail',       route: 'bureau/home'},
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
