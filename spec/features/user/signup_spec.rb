# encoding: UTF-8
# frozen_string_literal: true
require_relative './_required'

# Méthode qui s'assure que le candidat créé avec les données +data+
# a bien été enregistré
# Cette méthode de test est appelée après que le formulaire a été rempli avec
# succès et qu'on est arrivé sur la page annonçant que la candidature a bien
# été reçue.
def expect_a_valid_candidat_with(datainit)
  # On prépare les data pour qu'elles soient plus utilisables
  data = {}
  datainit.each{|k,v| data.merge!(k => v[:value])}
  # On doit récupérer l'user par son mail
  # puts "Data : #{data.inspect}"
  candidat = db_get('users', {mail: data[:mail]})
  candidat || raise("Impossible de trouver le candidat dans la base de données…")
  # Les données enregistrées du candidat doivent correspondre
  candidat[:session_id] || raise("Le numéro de session doit avoir été enregistré")
  # Un dossier doit avoir été créé, avec la session (ce numéro de session est
  # enregistré dans session_id du candidat)
  folder_signup = "./tmp/signups/#{candidat[:session_id]}"
  expect(File.exists?(folder_signup)).to be(true), 'Le dossier candidature devrait avoir été créé'

  user_id   = candidat[:id]
  user_mail = candidat[:mail]

  # Un watcher doit permettre de valider (ou non) l'inscription. Ce watcher
  # doit contenir les bonnes informations et notamment le dossier physique
  # contenant les documents de présentation (dont le nom est le numéro de session
  # de l'user) et les identifiants des modules choisis.
  expect(TWatchers.exists?(user_id:user_id, wtype:'validation_inscription')).to be(true),
    "Un watcher devrait permettre de valider l'inscription"
  twatcher = TWatchers.founds.first
  # puts "--- twatcher.params: #{twatcher.params.inspect}"
  wparams = JSON.parse(twatcher.params)
  expect(wparams).to have_key("folder")
  expect(wparams["folder"]).to eq(candidat[:session_id])
  expect(wparams).to have_key("modules")
  expect(wparams["modules"]).to eq(MODULES_PER_SIGNUP[data[:pseudo]])

  # Un watcher doit lui rappeler de valider son mail
  expect(TWatchers.exists?(user_id:user_id, wtype:'validation_adresse_mail')).to be(true),
    "Un watcher devrait permettre de valider l'adresse mail"

  # Un ticket doit permettre de valider le mail
  ticket = db_get('tickets', {user_id: user_id})
  ticket ||= raise("Impossible de trouver un seul ticket pour user ##{user_id}")

  # Un mail permettant de valider le mail
  expect(TMails).to have_mail(to:data[:mail], subject:'Validation du mail', message:"?tik=#{ticket[:id]}")
    "Un mail pour valider l'adresse mail aurait dû être transmis."

  # Un mail pour confirmer l'inscription
  expect(TMails).to have_mail(to:data[:mail], subject:'Confirmation de votre candidature', message:"Votre candidature à l’atelier Icare a bien été enregistrée"),
    "Le message de confirmation de l'enregistrement de la candidature n'a pas été transmis."

  # Une actualité a dû être produite
  expect(TActualites.exists?(user_id:user_id, type:'SIGNUP', only_one: true)).to be(true),
    "Il devrait y avoir une et une seule actualité annonçant l'inscription du candidat (#{TActualites.error})"

end #/ expect_a_valid_candidat_with

feature 'Inscription à l’atelier Icare' do
  before :all do
    require "#{FOLD_REL_PAGES}/user/signup/constants_messages"
    degel('inscription_marion')
    headless
  end

  # Test d'inscriptions invalides à cause de mauvaises données
  scenario 'des données invalides ne permettent pas de s’inscrire' do

    pitch("Des données invalides ne permettent jamais de s'inscrire à l'atelier.")

    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire

    def clic_signup_button
      find('#btn-signup').click
    end #/ clic_signup_button

    # Les données à tester
    require_data('signup_data')

    # On boucle sur toutes les données à tester
    DATA_SPEC_SIGNUP_INVALID.each do |data|
      goto_home
      clic_signup_button
      fill_formulaire_with('#signup-form', data)
      submit_formulaire('#signup-form')
      check_messages_errors(data)
      # sleep 4
    end #/


  end


  scenario 'des données valides permettent de créer un candidat' do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire

    pitch("Des données valides permettent à un postulant, Benoit, de s'inscrire à l'atelier Icare.")

    def clic_signup_button
      if not page.has_css?('#btn-signup', visible: true)
        find('section#header').click
      end
      find('#btn-signup').click
    end #/ clic_signup_button

    # Les données à tester
    require_data('signup_data')

    # On boucle sur toutes les données à tester
    # Pour tester deux nouveaux candidats
    data = DATA_SPEC_SIGNUP_VALID[3]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    check_messages_errors(data)
    screenshot('apres-nouveau-candidat')

    expect_a_valid_candidat_with(data)

  end #/test d'un bon candidat

  scenario 'des données valides permettent de créer une candidate' do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire

    pitch("Des données valides permettent à MarionM de s'inscrire à l'atelier.")

    def clic_signup_button
      find('#btn-signup').click
    end #/ clic_signup_button

    # Les données à tester
    require_data('signup_data')

    # On boucle sur toutes les données à tester
    # Pour tester deux nouveaux candidats
    data = DATA_SPEC_SIGNUP_VALID[1]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    check_messages_errors(data)
    screenshot('apres-nouvelle-candidate')
    expect_a_valid_candidat_with(data)
  end #/test d'une bonne candidate
end
