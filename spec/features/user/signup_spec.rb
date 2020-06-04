# encoding: UTF-8

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
  # Un fichier d'information doit avoir été créé dans le dossier
  file_infos = File.join(folder_signup,'infos.yaml')
  expect(File.exists?(file_infos)).to be(true), 'Le fichier infos devrait exister'
  # Le fichier d'information doit contenir les informations utiles
  infos = YAML.load_file(file_infos)
  puts "infos: #{infos.inspect}"
  expect(infos).to have_key :modules_ids
  expect(infos).to have_key :user_id
  expect(infos[:user_id]).to eq(candidat[:id])
  infos[:modules_ids].each do |mod_id|
    key = "module_#{mod_id}".to_sym
    expect(data).to have_key(key)
    expect(data[key]).to be(true), "le module #{mod_id} devrait être choisi"
  end
  expect(infos).to have_key(:mail)
  expect(infos[:mail]).to eq(data[:mail])

  user_id = infos[:user_id]
  user_mail = infos[:mail]

  # Un watcher doit lui permettre de valider la candidature
  watcher = db_get('watchers', {user_id: user_id})
  watcher || raise("Impossible de trouver un watcher pour user ##{user_id}")
  expect(watcher[:wtype]).to eq('validation_inscription')

  # Un ticket doit permettre de valider le mail
  ticket = db_get('tickets', {user_id: user_id})
  ticket ||= raise("Impossible de trouver un seul ticket pour user ##{user_id}")

  # Un mail permettant de valider le mail
  expect(TMails.exists?(data[:mail], "?tik=#{ticket[:id]}".freeze)).to be(true),
    "Le message pour valider l'adresse mail n'a pas été transmis.".freeze

  # Un mail pour confirmer l'inscription
  expect(TMails.exists?(data[:mail], "Votre candidature à l’atelier Icare a bien été enregistrée".freeze)).to be(true),
    "Le message de confirmation de l'enregistrement de la candidature n'a pas été transmis.".freeze

end #/ expect_a_valid_candidat_with

feature 'Inscription à l’atelier Icare' do
  before :all do
    require './_lib/pages/user/signup/constants_messages'
  end

  # Test d'inscriptions invalides à cause de mauvaises données
  scenario 'des données invalides ne permettent pas de s’inscrire' do

    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire

    def clic_signup_button
      find('#signup-btn').click
    end #/ clic_signup_button

    # Les données à tester
    require_relative 'signup_data'

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

    def clic_signup_button
      find('#signup-btn').click
    end #/ clic_signup_button

    # Les données à tester
    require_relative 'signup_data'

    # On boucle sur toutes les données à tester
    # Pour tester deux nouveaux candidats
    data = DATA_SPEC_SIGNUP_VALID[0]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    check_messages_errors(data)
    save_and_open_page

    expect_a_valid_candidat_with(data)

  end #/test d'un bon candidat

  scenario 'des données valides permettent de créer une candidate' do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire

    def clic_signup_button
      find('#signup-btn').click
    end #/ clic_signup_button

    # Les données à tester
    require_relative 'signup_data'

    # On boucle sur toutes les données à tester
    # Pour tester deux nouveaux candidats
    data = DATA_SPEC_SIGNUP_VALID[1]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    check_messages_errors(data)
    save_and_open_page
    expect_a_valid_candidat_with(data)
  end #/test d'une bonne candidate
end
