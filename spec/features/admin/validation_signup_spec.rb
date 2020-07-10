# encoding: UTF-8
=begin
  Validation par l'administration d'une inscription
=end
feature "Validation d'une inscription" do
  before(:each) do
    degel('inscription_benoit')
  end
  context 'par un administrateur' do

    scenario "l'inscription peut être validée", only:true do

      pending "à terminer"

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

      # === ON PROCÈDE À L'OPÉRATION ===

      # Un watcher de paiement a été généré
      wparams = {wtype:'paiement_module', user_id: benoit.id, after:start_time}
      expect(TWatchers).to have_watcher(wparams),
        "Le watcher pour permettre à Benoit de payer son module devrait exister"
      pitch("On doit trouver…")
      pitch("… un watcher permettant à Benoit de payer son module")
      wparams = {wtype:'start_module', user_id: benoit.id, after:start_time}
      expect(TWatchers).to have_watcher(wparams),
        "Le watcher pour démarrer le module devrait exister"
      pitch("… un watcher pour démarrer le module")
      # aparams = {id:'REALICARIEN', user_id:benoit.id}
      expect(TActualites).to have_item(id:'REALICARIEN', user_id:benoit.id),
      # expect(TActualites.exists?(aparams)).to be(true),
        "Il devrait exister une actualité annonçant la validation de l'inscription."
      pitch("… une annonce de cette validation")

      expect(benoit).to be_recu
      pitch("Benoit est devenu un candidat reçu")

    end
    scenario 'l’inscription peut être refusée' do
      pending "à implémenter"
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
