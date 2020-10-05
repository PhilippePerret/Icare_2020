# encoding: UTF-8
=begin
  Données de test pour l'inscription à l'atelier Icare
=end
ERRORS = {} unless defined?(ERRORS)

# # Retourne les options pour un nouvel icarien. On détaille ici les
# # choix, pour référence.
# def options_for_new_icarien
#   o = "0"*32
#   o[4]  = '1' # Mail quotidien
#   o[18] = '0' # Après l'identification, l'icarien rejoint son bureau
#   o[22] = '1' # l'icarien est averti par mail en cas de message frigo
#   o[26] = '3' # Contact par mail+frigo avec l'administration
#   o[27] = '3' # Contact par mail+frigo avec les autres icariens
#   o[28] = '0' # Contact par frigo avec le reste du monde
#   return o
# end #/ options_new_icarien
# OPTIONS_NEW_ICARIEN = options_for_new_icarien

# ---------------------------------------------------------------------
#
#   Test d'une inscription valide
#
# ---------------------------------------------------------------------

DATA_SPEC_SIGNUP_VALID = [

  # UN premier candidat valide
  {
    pseudo:     {value:'Philippe'},
    patronyme:  {value:'Philippe Perret'},
    naissance:  {value:'1964', type:'select'},
    sexe:       {value:'un homme', type:'select'},
    mail:       {value:'icareedi@gmail.com'},
    mail_conf:  {value:'icareedi@gmail.com'},
    password:   {value:'motdepasse'},
    password_conf:  {value:'motdepasse'},
    presentation:   {value:'presentation.md', type:'file'},
    motivation:     {value:'motivation.md',   type:'file'},
    cgu:            {value:true, type:'checkbox'},
    rgpd:           {value:true, type:'checkbox'},
    module_2:       {value:true, type:'checkbox'},
    module_4:       {value:true, type:'checkbox'},
    module_6:       {value:true, type:'checkbox'}
  },
  # UNE seconde candidate valide (index 1 - et rester index 1 pour les gels)
  {
    pseudo:         {value:'MarionM'},
    patronyme:      {value:'Marion De Michel'},
    naissance:      {value:'1992', type:'select'},
    sexe:           {value:'une femme', type:'select'},
    mail:           {value:'marion.michel31@gmail.com'},
    mail_conf:      {value:'marion.michel31@gmail.com'},
    password:       {value:'motdepasse'},
    password_conf:  {value:'motdepasse'},
    presentation:   {value:'presentation.md', type:'file'},
    motivation:     {value:'motivation.md',   type:'file'},
    # options:        {value:OPTIONS_NEW_ICARIEN, editable:false},
    cgu:            {value:true, type:'checkbox'},
    rgpd:           {value:true, type:'checkbox'},
    module_3:       {value:true, type:'checkbox'}
  },
  # Candidate valide pour Benoi (index 2 - et rester index 1 pour les gels)
  {
    pseudo:         {value:'Benoit'},
    patronyme:      {value:'Benoit Ackerman'},
    naissance:      {value:'1982', type:'select'},
    sexe:           {value:'un homme', type:'select'},
    mail:           {value:'benoit.ackerman@yahoo.fr'},
    mail_conf:      {value:'benoit.ackerman@yahoo.fr'},
    password:       {value:'unmotdepasse'},
    password_conf:  {value:'unmotdepasse'},
    presentation:   {value:'presentation.md', type:'file'},
    motivation:     {value:'motivation.md',   type:'file'},
    # options:        {value:OPTIONS_NEW_ICARIEN, editable:false},
    cgu:            {value:true, type:'checkbox'},
    rgpd:           {value:true, type:'checkbox'},
    module_1:       {value:true, type:'checkbox'},
    module_2:       {value:true, type:'checkbox'},
    module_4:       {value:true, type:'checkbox'}
  },
  # Candidat valide pour Élie (index 3 - et rester index 1 pour les gels)
  {
    pseudo:         {value:'Élie'},
    patronyme:      {value:'Élie Perret'},
    naissance:      {value:'1998', type:'select'},
    sexe:           {value:'un homme', type:'select'},
    mail:           {value:'elieperret@gmail.com'},
    mail_conf:      {value:'elieperret@gmail.com'},
    password:       {value:'lemotdepasse'},
    password_conf:  {value:'lemotdepasse'},
    presentation:   {value:'presentation.md', type:'file'},
    motivation:     {value:'motivation.md',   type:'file'},
    extrait:        {value:'extrait.odt',     type:'file'},
    # options:        {value:OPTIONS_NEW_ICARIEN, editable:false},
    cgu:            {value:true, type:'checkbox'},
    rgpd:           {value:true, type:'checkbox'},
    module_6:       {value:true, type:'checkbox'},
    module_7:       {value:true, type:'checkbox'},
    modules_ids:    {value: [6, 7], editable: false}
  },
  # Candidat valide pour détruit (4)
  # Pour avoir un icarien détruit et voir si ça fonctionne bien
  {
    pseudo:         {value:'Destroyed'},
    patronyme:      {value:'Wagram Destroyed'},
    naissance:      {value:'1978', type:'select'},
    sexe:           {value:'une femme', type:'select'},
    mail:           {value:'userdestroyed@gmail.com'},
    mail_conf:      {value:'userdestroyed@gmail.com'},
    password:       {value:'sonmotdepasse'},
    password_conf:  {value:'sonmotdepasse'},
    presentation:   {value:'presentation.md', type:'file'},
    motivation:     {value:'motivation.md',   type:'file'},
    extrait:        {value:'extrait.odt',     type:'file'},
    # options:        {value:OPTIONS_NEW_ICARIEN, editable:false},
    cgu:            {value:true, type:'checkbox'},
    rgpd:           {value:true, type:'checkbox'},
    module_1:       {value:true, type:'checkbox'}
  }
]

DATA_SPEC_SIGNUP_INVALID = [
  {
    pseudo:     {value:'', have:ERRORS[:pseudo_required], have_not:nil},
  },
  # Un pseudo trop court
  {
    pseudo:     {value:'ax', have:ERRORS[:pseudo_to_short]}
  },
  # Un pseudo trop long
  {
    pseudo: {value: 'ax'*26, have:ERRORS[:pseudo_to_long]}
  },
  # Un pseudo existant
  {
    pseudo:   {value:'Phil', have:ERRORS[:pseudo_already_exists]}
  },
  # patronyme trop long
  {
    patronyme: {value: 'axy'*34, have:ERRORS[:patronyme_too_long]}
  },
  {
    patronyme: {value: 'axy'*33, not_have:ERRORS[:patronyme_too_long]}
  },
  # Sans le mail
  {
    pseudo: {value:"monBeauPseudo#{Time.new.to_i}"},
    mail:   {value:'', have:ERRORS[:mail_required]}
  },
  # Un mail existant
  {
    mail: {value:'phil@atelier-icare.net', have:ERRORS[:mail_already_exists]}
  },
  # Un mail mal formaté
  {mail: {value:'philouchezicare.net', have:ERRORS[:mail_invalid]}},
  {mail: {value:'philouchez@icarenet', have:ERRORS[:mail_invalid]}},
  {mail: {value:'phil!ou!chez@atelier-icare.net', have:ERRORS[:mail_invalid]}},
  {mail: {value:'philouchez@icare.nettification', have:ERRORS[:mail_invalid]}},
  # Confirmation de mail qui ne correspond pas
  {
    pseudo:     {value:'Pilou', have_not:ERRORS[:pseudo_required]},
    mail:       {value:'pilou@chez.lui', have_not:ERRORS[:mail_required]},
    mail_conf:  {value:'philouette@chez.lui', have:ERRORS[:conf_mail_dont_match]}
  },
  # COnfirmation du mail qui correspond
  {
    pseudo:     {value:'Pilou', have_not:ERRORS[:pseudo_required]},
    mail:       {value:'pilou@chez.lui', have_not:ERRORS[:mail_required]},
    mail_conf:  {value:'pilou@chez.lui', have_not:ERRORS[:conf_mail_dont_match]}
  },
  # Mot de passe requis
  {
    password:  {value:'', have:ERRORS[:password_required]}
  },
  # Mot de passe trop court
  {
    password: {value:'xxxxx', have:ERRORS[:password_too_short]}
  },
  # Mot de passe trop long
  {
    password: {value:'ax'*26, have:ERRORS[:password_too_long]}
  },
  # Mots de passe invalides
  {password:{value:'a b c d',   have:ERRORS[:password_invalid]}},
  {password:{value:'abc-d-e',   have:ERRORS[:password_invalid]}},
  {password:{value:'abcde-é',   have:ERRORS[:password_invalid]}},
  {password:{value:'a_b_c_d',   have:ERRORS[:password_invalid]}},
  # Confirmation ne matche pas
  {
    password: {value: 'a!b.c?d',      have_not:ERRORS[:password_invalid]},
    password_conf: {value: 'abcdefg', have:ERRORS[:conf_password_doesnt_match]}
  },
  # Sans cocher les cgu
  {
    cgu: {value: false,     have:ERRORS[:cgu_required], type:'checkbox'}
  },
  {
    cgu: {value: true, have_not:ERRORS[:cgu_required], type:'checkbox'}
  },
  # Sans cocher les rgpd
  {
    rgpd: {value: false,     have:ERRORS[:rgpd_required], type:'checkbox'}
  },
  {
    rgpd: {value: true, have_not:ERRORS[:rgpd_required], type:'checkbox'}
  },
  # Documents de présentation
  {
    presentation: {type:'file', value:'', have:ERRORS[:presentation_required]},
    motivation: {type:'file', value:'', have:ERRORS[:motivation_required]}
  },
  {
    presentation:{type:'file', value:'presentation.jpg', have:ERRORS[:presentation_format_invalid]},
    motivation:{type:'file', value:'motivation.png', have:ERRORS[:motivation_format_invalid]}
  },
  {
    presentation:{type:'file', value:'presentation.pdf', have_not:ERRORS[:presentation_format_invalid]},
    motivation:{type:'file', value:'motivation.odt', have_not:ERRORS[:motivation_format_invalid]},
    extrait:{type:'file', value:'extrait.rtf'}
  },
  # Modules d'apprentissage
  {
    module_1: {type:'checkbox', value:false, have:ERRORS[:modules_required]}
  },
  {
    module_1: {type:'checkbox', value:true, have_not:ERRORS[:modules_required]}
  },
  {
    module_1: {type:'checkbox', value:true},
    module_2: {type:'checkbox', value:true},
    module_6: {type:'checkbox', value:true, have_not:ERRORS[:modules_required]}
  }
]
