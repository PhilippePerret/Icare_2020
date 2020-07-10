# encoding: UTF-8
=begin
  Validation par l'administration d'une inscription
=end
require './_lib/_watchers_processus_/_constants_' # => DATA_MATCHERS
feature "Validation d'une inscription" do
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








    scenario 'l’inscription peut être refusée', only:true do

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

      pitch("En rejoignant mon bureau d'administrateur, je trouve une notification pour valider l'inscription de Benoit. Je peux la refuser.")
      phil.rejoint_ses_notifications
      # Je trouve une notification pour valider l'inscription de Benoit
      expect(page).to have_notification(user_id: benoit.id, wtype: 'validation_inscription')
      watcher_id = $notification_id

      # === ON PROCÈDE À L'OPÉRATION ===
      within("div#watcher-#{watcher_id}") do
        click_on('Notifier le refus par mail')
        click_on('détruire')
      end
      screenshot('phil-invalide-inscription-benoit')

      expect(TWatchers).not_to have_item(id: watcher_id),
        "Le watcher de validation devrait avoir été détruit"
      pitch("Le watcher de validation a été détruit.")

      expect(TWatchers).not_to have_watcher(wtype:'start_module', user_id: benoit.id, after:start_time),
        "Le watcher pour démarrer le module ne devrait pas exister"
      pitch("Benoit n'a pas de watcher pour démarrer le module")

      expect(TActualites).not_to have_item(id:'REALICARIEN', user_id:benoit.id, after:start_time),
        "Il ne devrait pas exister une actualité annonçant la validation de l'inscription."
      pitch("Pas d'annonce annonçant la validation")

      expect(TMails).not_to have_mail({destinataire:benoit, after: start_time, subject: DATA_WATCHERS[:validation_inscription][:titre]}),
        "Benoit ne devrait pas avoir reçu de mail lui annonçant la validation de son inscription."
      pitch("Benoit ne reçoit pas de mail lui annonçant sa validation.")

      expect(benoit).to be_destroyed,
        "Benoit devrait être marqué détruit."
      pitch("et le statut de Benoit est passé à détruit.")

    end

  end

  context 'par un icarien quelconque' do
    scenario 'il ne peut pas valider une inscription' do
      pending "à implémenter"
    end
  end

  context 'par un visiteur quelconque' do
    scenario 'l’inscription ne peut pas être validée' do
      pending "à implémenter"
    end
  end
end
