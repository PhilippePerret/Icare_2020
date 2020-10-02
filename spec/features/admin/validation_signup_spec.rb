# encoding: UTF-8
=begin
  Validation par l'administration d'une inscription
=end
feature "Validation d'une inscription" do
  before(:all) do
    require './_lib/_watchers_processus_/_constants_' # => DATA_MATCHERS
  end

  before(:each) do
    degel('inscription_benoit')
  end
  context 'par un administrateur' do

    scenario "l'inscription peut être validée" do

      start_time = Time.now.to_i

      # === Vérifications préliminaires ===
      expect(benoit).to be_candidat
      wparams = {wtype:'paiement_module', user_id: benoit.id}
      expect(TWatchers).not_to have_watcher(wtype:'paiement_module', user_id: benoit.id),
      # expect(TWatcher.exists?(wparams)).not_to be(true),
        "Aucun watcher de paiement de module ne devrait exister pour Benoit"
      wparams = {wtype:'start_module', user_id: benoit.id}
      expect(TWatchers).not_to have_watcher(wparams),
        "Aucun watcher de démarrage de module ne devrait exister pour Benoit"

      pitch("En rejoignant mon bureau d'administrateur, je trouve une notification pour valider l'inscription de Benoit.")
      phil.rejoint_ses_notifications
      # Je trouve une notification pour valider l'inscription de Benoit
      expect(page).to have_notification(user_id: benoit.id, wtype: 'validation_inscription')
      watcher_id = $notification_id

      # === ON PROCÈDE À L'OPÉRATION ===
      within("div#watcher-#{watcher_id}") do
        click_on('Attribuer ce module')
      end
      screenshot('phil-valide-inscription-benoit')

      benoit.reset

      # Pas de watcher de paiement
      wparams = {wtype:'paiement_module', user_id: benoit.id, after:start_time}
      expect(TWatchers).not_to have_watcher(wparams),
        "Benoit ne devrait pas avoir de watcher pour payer son module"
      expect(TWatchers).to have_watcher(wtype:'start_module', user_id: benoit.id, after:start_time),
        "Le watcher pour démarrer le module devrait exister"
      pitch("Benoit a un watcher pour démarrer le module")

      expect(TActualites).to have_item(id:'REALICARIEN', user_id:benoit.id),
        "Il devrait exister une actualité annonçant la validation de l'inscription."
      pitch("Une annonce annonce (sic) la validation")

      expect(TMails).to have_mail({destinataire:benoit, after: start_time, subject: DATA_WATCHERS[:validation_inscription][:titre]}),
        "Benoit devrait recevoir un mail lui annonçant la validation de son inscription."
      pitch("Benoit reçoit un mail lui annonçant sa validation.")

      expect(benoit).to be_recu,
        "Benoit devrait être marqué reçu."
      pitch("et le statut de Benoit est passé à reçu.")

    end








    scenario 'l’inscription peut être refusée' do

      benoit.reset

      start_time  = Time.now.to_i
      benoit_id   = benoit.id

      # === Vérifications préliminaires ===
      # puts "benoit.options: #{benoit.options.inspect}"
      expect(benoit).to be_candidat
      expect(benoit).not_to have_watcher(wtype:'start_module', after: start_time),
        "Benoit ne devrait avoir aucun watcher de paiement de module"
      expect(benoit).not_to have_watcher(wtype:'start_module', after: start_time),
        "Benoit ne devrait avoir aucun watcher de démarrage de module"

      pitch("En rejoignant mon bureau d'administrateur, je trouve une notification pour valider l'inscription de Benoit. Je peux la refuser.")
      phil.rejoint_ses_notifications
      # Je trouve une notification pour valider l'inscription de Benoit
      expect(page).to have_notification(user_id: benoit.id, wtype: 'validation_inscription')
      watcher_id = $notification_id

      # === ON PROCÈDE À L'OPÉRATION ===
      expect(page).to have_link('Notifier le refus par mail')
      within("div#watcher-#{watcher_id}") do
        click_on('Notifier le refus par mail')
      end
      screenshot('phil-invalide-inscription-benoit')

      within("div#watcher-#{watcher_id}") do
        expect(page).to have_link('Détruire la candidature'),
          "La page devrait présenter un lien pour détruire la candidature"
        click_on('Détruire la candidature')
      end
      screenshot('phil-detruit-candidature')

      expect(benoit).not_to have_watcher(wtype:'start_module', after:start_time),
        "Benoit ne devrait pas avoir de watcher pour démarrer un module"
      pitch("Benoit n'a pas de watcher pour démarrer le module")

      expect(TActualites).not_to have_item(id:'REALICARIEN', user_id:benoit.id, after:start_time),
        "Il ne devrait pas exister une actualité annonçant la validation de l'inscription."
      pitch("Pas d'annonce annonçant la validation")

      expect(benoit).not_to have_mail(after:start_time, subject:DATA_WATCHERS[:validation_inscription][:titre]),
        "Benoit ne devrait pas avoir reçu de mail lui annonçant la validation de son inscription."
      pitch("Benoit ne reçoit pas de mail lui annonçant sa validation.")

      # Une candidature refusée detruit l'user dans la base de données, car
      # ça ne sert à rien de le garder puisqu'il n'a rien fait.
      expect(db_get('users', 11)).to be(nil),
        "Benoit devrait être détruit de la base de données."
      pitch("et Benoit a été détruit de la base de données.")

      expect(TWatchers).not_to have_item(id: watcher_id),
        "Le watcher de validation devrait avoir été détruit"
      pitch("Le watcher de validation a été détruit.")

    end

  end





  context 'par un icarien quelconque' do
    scenario 'il ne peut pas valider une inscription' do

      benoit.rejoint_son_bureau

      # On fabrique une fausse soumission
      qstr  = "form-id=validation-candidature-11-form&route=admin/notifications&wid=13&module_id-11=1"
      route = "admin/notifications?#{qstr}"

      # === Vérification préliminaire ===
      expect(benoit).to be_candidat,
        "Benoit devrait être candidat"

      # === TEST ===
      goto route

      # === Vérification ===
      expect(benoit).to be_candidat,
        "Benoit devrait toujours être candidat"

    end
  end

  context 'par un visiteur quelconque' do
    scenario 'l’inscription ne peut pas être validée' do
      # On fabrique une fausse soumission
      qstr  = "form-id=validation-candidature-11-form&route=admin/notifications&wid=13&module_id-11=1"
      route = "admin/notifications?#{qstr}"
      # === Vérification préliminaire ===
      expect(benoit).to be_candidat,
        "Benoit devrait être candidat"
      # === TEST ===
      goto route
      # === Vérification ===
      expect(benoit).to be_candidat,
        "Benoit devrait toujours être candidat"
    end
  end
end
