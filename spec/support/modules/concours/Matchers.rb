# encoding: UTF-8
# frozen_string_literal: true
=begin
  Matchers pour le concours
=end


RSpec::Matchers.define :have_encart_concours do
  match do |page|
    @errors = []
    unless page.has_css?('a[href="concours/accueil"]', id:"annonce")
      @errors << "devrait posséder un encart lié à l'accueil du concours"
    end
    unless page.has_css?("a > span", text: "Concours #{TConcours.current.annee}")
      @errors << "devrait afficher le texte “Concours #{TConcours.current.annee}”"
    end
    return @errors.empty?
  end
  description do
    "have encart pour rejoindre le concours"
  end
  failure_message do
    "devrait posséder l'encart pour rejoindre le concours. Erreurs : #{@errors.join(', ')}"
  end
end


RSpec::Matchers.define :be_accueil_concours do |phase|
  match do |page|
    @errors = []
    unless page.has_css?("h2.page-title", text: "Concours de synopsis de l’atelier Icare")
      @errors << "n'a pas le bon titre. Son titre est #{title_of_page}"
    end
    titre_inscription = phase < 2 ? "vous inscrire" : "Inscription au prochain concours"
    unless page.has_link?(titre_inscription, {href: 'concours/inscription'})
      @errors << "ne contient pas le lien pour s'inscrire"
    end
    titre_login = phase < 2 ? "vous identifier" : "Identifiez-vous"
    unless page.has_link?(titre_login, href: 'concours/identification')
      @errors << "ne contient pas le lien pour s'identifier"
    end
    case phase
    when 1
      unless page.has_content?("Le concours est ouvert !")
        @errors << "devrait annoncer que le concours est ouvert"
      end
    when 2
      if page.has_content?("Le concours est ouvert !")
        @errors << "ne devrait pas annoncer que le concours est ouvert"
      end
      unless page.has_content?("en cours de présélection")
        @errors << "devrait annoncer que les synopsis sont en présélection"
      end
    when 3
      if page.has_content?("en cours de présélection")
        @errors << "ne devrait pas annoncer que les synopsis sont en présélection"
      end
      unless page.has_content?("sont en finale")
        @errors << "devrait annoncer que les synopsis sélectionnés sont en final"
      end
    when 5
      if page.has_content?("sont en finale")
        @errors << "ne devrait pas annoncer que les synopsis sélectionnés sont en final"
      end
      unless page.has_content?("Les synopsis lauréats ont été choisis !")
        @errors << "devrait annoncer que les synopsis sélectionnés sont en final"
      end
    when 8
      if page.has_content?("Les synopsis lauréats ont été choisis !")
        @errors << "ne devrait pas annoncer que les synopsis sélectionnés sont en final"
      end
      unless page.has_content?("Le concours est achevé")
        @errors << "devrait annoncer que le concours est achevé"
      end
    end

    return @errors.empty?
  end
  description do
    "be la page d'accueil du concours (lancé)"
  end
  failure_message do
    "must be la page d'accueil du concours (lancé), ou alors elle n'est pas conforme : #{@errors.join(', ')}."
  end
end

# Pour vérifier que ce soit la page d'inscription
# +with_form+ peut avoir 3 valeurs :
#   true      Le formulaire doit exister
#   false     Le formulaire ne doit pas exister
#   nil       Peu importe que le formulaire existe ou non
#
RSpec::Matchers.define :be_inscription_concours do |with_form|
  match do |page|
    @errors = []
    @titre = "Inscription au concours"
    unless page.has_css?("h2.page-title", text: @titre)
      @errors << "n'a pas le bon titre (“#{@titre}”). Son titre est #{title_of_page}"
    end
    if with_form === true
      unless page.has_css?("form#concours-signup-form")
        @errors << "ne contient pas le formulaire d'inscription"
      end
    elsif with_form === false
      if page.has_css?("form#concours-signup-form")
        @errors << "ne devrait pas contenir le formulaire d'inscription"
      end
    end
    return @errors.empty?
  end
  description do
    "C'est bien la page d'inscription au concours"
  end
  failure_message do
    "Ce n'est pas la page d'inscription pour les raisons suivantes : #{@errors.join(', ')}."
  end
end

RSpec::Matchers.define :be_accueil_jury do
  match do |page|
    if not page.has_css?("h2.page-title", text: "Accueil du jury du concours")
      @errors << "la page n'a pas le titre “Accueil du jury du concours” (son titre est #{title_of_page})."
    end

    return @errors.empty?
  end
  description do
    "C'est bien la page d'accueil du concours"
  end
  failure_message do
    "Ce n'est pas la page d'accueil du concours, ou alors elle n'est pas conforme : #{@errors.join(', ')}"
  end
end

RSpec::Matchers.define :be_palmares_concours do |phase|
  match do |page|
    @errors = []
    if not page.has_css?("h2.page-title", text: "Palmarès du concours de synopsis")
      @errors << "la page devrait avoir le titre “Palmarès du concours de synopsis” (son titre est #{title_of_page})"
    end
    if phase > 2
      if not page.has_css?('h2', text: /Lauréats du Concours de Synopsis/i)
        @errors << "la page devrait contenir le sous-titre “Lauréats du Concours de Synopsis”"
      end
    end
    actual_route = route_of_page
    expected_route = 'concours/palmares'
    if not actual_route == expected_route
      @errors << "la route de la page devrait être '#{expected_route}', or c'est '#{actual_route}'"
    end
    @errors.empty?
  end
  description do
    "C'est bien la page de palmarès du concours"
  end
  failure_message do
    "Ce n'est pas la page de palmarès du concours : #{@errors.join(', ')}."
  end
end

RSpec::Matchers.define :be_espace_personnel do
  match do |page|
    @errors = []
    if not page.has_css?("h2.page-title", text: "Espace personnel")
      @errors << "la page devrait porter le titre “Espace personnel” (son titre est #{title_of_page})"
    end
    if not page.has_css?("section#concours-destruction")
      @errors << "ne contient pas la section #concours-destruction"
    end
    unless page.has_link?("Se déconnecter")
      @errors << "ne contient pas de bouton pour se déconnecter (i.e. le visiteur devrait être identifié)"
    end
    return @errors.empty?
  end
  description do
    "C'est bien la page de l'espace personnel du concours"
  end
  failure_message do
    "Ce n'est pas la page de l'espace personnel du concours : #{@errors.join(', ')}."
  end
end


RSpec::Matchers.define :be_identification_concours do
  match do |page|
    @errors = []
    if not page.has_css?("h2.page-title", text: "Identification")
      @errors << "la page n'a pas le titre “Identification” (son titre est #{title_of_page})"
    end
    if not page.has_css?("form#concours-login-form")
      @errors << "le page ne possède aucun formulaire #concours-login-form"
    end
    return @errors.empty?
  end
  description do
    "C'est bien la page d'identification du concours"
  end
  failure_message do
    "Ce n'est pas la page d'identification du concours : #{@errors.join(', ')}."
  end
end

RSpec::Matchers.define :be_indentification_jury do
  match do |page|
    @errors = []
    unless page.has_css?("h2.page-title", text: /Identification/i)
      @errors << "devrait avoir “Identification” dans son titre"
    end
    unless page.has_css?("h2.page-title", text: /membre du jury/i)
      @errors << "devrait avoir “membre du jury” dans son titre"
    end
    unless page.has_css?("form#concours-membre-login")
      @errors << "devrait contenir un formulaire d'identification valide"
    end
    return @errors.empty?
  end
  description do
    "C'est bien la page d'identification des membres du jury du concours"
  end
  failure_message do
    "Ce n'est pas la page d'identification des membres du jury du concours : #{@errors.join(', ')}"
  end
end

RSpec::Matchers.define :be_fiches_synopsis do
  match do |page|
    page.has_css?("h2.page-title", text: "Cartes des synopsis")
  end
  description do
    "C'est bien la page des cartes des synopsis"
  end
  failure_message do
    "Ce n'est pas la page des cartes des synopsis."
  end
end
RSpec::Matchers.alias_matcher :be_page_evaluation, :be_fiches_synopsis

RSpec::Matchers.define :be_fiches_lecture_jury do
  match do |page|
    page.has_css?("h2.page-title", text: "Fiches de lecture")
  end
  description do
    "C'est bien la page des fiches de lecture"
  end
  failure_message do
    "Ce n'est pas la page des fiches de lecture."
  end
end

RSpec::Matchers.define :be_fiches_lecture_concurrent do
  match do |page|
    @errors = []
    expected_titre = "Vos fiches de lecture"
    actual_titre = title_of_page
    if not page.has_css?("h2.page-title", text: expected_titre)
      @errors << "la page ne porte pas le titre “#{expected_titre}” (son titre est #{actual_titre})"
    end
    expected_route = "concours/fiches_lecture"
    actual_route = route_of_page.freeze
    if not(actual_route == expected_route)
      @errors << "la route de la page devrait être '#{expected_route}', or c'est '#{actual_route}'."
    end
    return @errors.empty?
  end
  description do
    "C'est bien la page des fiches de lecture du concurrent"
  end
  failure_message do
    "Ce n'est pas la page des fiches de lecture du concurrent : #{@errors.join(', ')}."
  end
end

RSpec::Matchers.define :be_formulaire_synopsis do |options=nil|
  match do |page|
    raisons = []
    ok = page.has_css?("h2.page-title", text: "Édition du synopsis")
    if ok
      raisons << "C'est la page de l'édition du synopsis mais"
    else
      raisons << "Ce n'est pas la page d'édition du synopsis"
    end
    if ok && options && options[:conformite]
      ok = ok && page.has_css?('h3', text: "Signalement de non conformité")
      if not ok
        raisons << "la section de signalement de non conformité est introuvable…"
      end
      ok = ok && page.has_css?('form#non-conformite-form')
      if not ok
        raisons << "le formulaire pour signaler la non conformité est introuvable…"
      end
    end
    @raisons = raisons.join(' ')
    return ok
  end
  description do
    "C'est bien la page de l'édition du synopsis"
  end
  failure_message do
    @raisons
  end
end

RSpec::Matchers.define :be_checklist_page_for do |syno_id|
  match do |page|
    # puts "page: #{page.html}"
    ok = true
    r = [] # pour mettre les raisons d'erreurs
    if not page.has_css?("h2.page-title", text: "Évaluation de #{syno_id}")
      r << "le titre devrait être “Évaluation du synopsis #{syno_id}”"
      ok = false
    end
    if not page.has_css?("div#checklist")
      r << "la page devrait contenir un div#checklist"
      ok = false
    end
    if not page.has_css?("div#checklist form#checklist-form")
      r << "la page devrait contenir le formulaire form#checklist-form"
      ok = false
    end
    if not page.has_css?("div#checklist div#row-buttons")
      r << "le formulaire devrait contenir la rangée des boutons"
      ok = false
    end
    if not page.has_css?("div#checklist div#row-buttons button", text: "Enregistrer")
      r << "le formulaire devrait contenir le bouton pour Enregistrer l'évaluation"
      ok = false
    end
    if not page.has_css?("form#checklist-form input[value=\"#{syno_id}\"]", id: "synoid", visible:false)
      r << "le formulaire devrait contenir le champ 'synoid' avec l'identifiant du synopsis évalué"
      ok = false
    end
    @raisons = r
    return ok
  end
  description do
    "C'est bien la page pour évaluer le synopsis ##{syno_id}"
  end
  failure_message do
    "Ce n'est pas la page pour évaluer le synopsis ##{syno_id} pour les raisons suivantes : #{@raisons.join(', ')}"
  end
end


RSpec::Matchers.define :be_faq_concours do
  match do |page|
    @errors = []
    @titre = "FAQ du concours"
    unless page.has_css?("h2.page-title", text: @titre)
      @errors << "n'a pas le bon titre (“#{@titre}”)"
    end
    unless page.has_css?("div.qr")
      @errors << "ne contient pas de div question/réponse…"
    end
    return @errors.empty?
  end
  description do
    "C'est bien la Foire Aux Questions du concours"
  end
  failure_message do
    "Ce n'est pas la Foire Aux Question du concours, pour les raisons suivantes : #{@errors.join(', ')}."
  end
end
