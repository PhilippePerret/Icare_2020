# encoding: UTF-8
=begin
  Test complet du frigo
=end
require_relative 'TFrigo_classes'
require_relative 'frigo_matchers'
require_relative 'TUser_discussions'

# ---------------------------------------------------------------------
#
#   LES UTILITAIRES
#
# ---------------------------------------------------------------------

def benoit_rejoint_son_frigo
  TFrigo.user_rejoint_son_frigo(:benoit)
end #/ benoit_rejoint_son_frigo
def marion_rejoint_son_frigo
  TFrigo.user_rejoint_son_frigo(:marion)
end #/ marion_rejoint_son_frigo
def phil_rejoint_son_frigo
  TFrigo.user_rejoint_son_frigo(:admin)
end #/ phil_rejoint_son_frigo

# ---------------------------------------------------------------------
#
#   LES TESTS
#
# ---------------------------------------------------------------------
feature "Test du frigo" do

  before(:each) do
    Capybara.reset_sessions!
  end
  let(:count_messages) { TFrigo.count_messages }
  scenario "Benoit peut initier une discussion avec Phil" do
    degel('validation_deux_inscriptions')
    # NOTE
    #   Avec ce gel, on a 3 users, Marion, Benoit et Élie, et aucun
    #   message Frigo n'a été déposé
    # NOTE
    #   Dans la suite, on utilisera le gel produit par ce test

    start_time = Time.now.to_i

    pitch <<-TXT.strip.freeze
    Benoit peut initier une conversation avec Phil
    ----------------------------------------------
    TXT

    pitch('Il rejoint son frigo…')
    benoit.rejoint_son_frigo

    # --- Vérifications préliminaires ---
    expect(TFrigo.count_messages).to eq(0),
      "Il devrait y avoir 0 messages, il y en a #{count_messages}"
    # Il n'a aucune discussion
    expect(benoit).to have_messages(count: 0),
      "Benoit ne devrait pas avoir de messages en base de données"

    expect(page).to have_content('Vous n’avez pas de discussions en cours'),
      "Benoit ne devrait pas avoir de discussion en cours…"

    pitch('… et ne trouve aucune discussion en cours'.freeze)
    expect(page).to have_selector('form#discussion-phil-form'),
      "Benoit devrait avoir un formulaire pour initier une discussion avec Phil"
    pitch('Dans le formulaire pour initier une conversation avec Phil…'.freeze)

    # === TEST : CRÉATION D'UNE DISCUSSION ===
    benoit.start_discussion_with_phil(
      'Message pour Phil',
      'Bonjour Phil, c’est Benoit et je voudrais parler.'
      )
    pitch('… il initie une conversation.')

    # === VÉRIFICATION POST OPÉRATION ===

    expect(TFrigo.count_messages).to eq(1),
      "Il devrait y avoir 1 messages, il y en a #{count_messages}"
    expect(TFrigo).to have_discussion_with([phil,benoit])
    pitch('La discussion est initiée avec Phil.')
    expect(TDiscussion.between([phil,benoit])).to have_message(user:benoit, count: 1)
    pitch('• Le message de Benoit pour cette discussion a été enregistré.')
    logout

    expect(phil).to have_messages(count: 0)
    pitch('Phil ne possède aucun message dans la base de données')

    TMails.exists?('phil@atelier-icare.net', {after: start_time})
    pitch('• Un mail a été envoyé à Phil pour l’avertir'.freeze)

    pitch("Quand Phil rejoint son bureau…".freeze)
    phil.rejoint_son_bureau
    expect(phil).to have_pastille_frigo(1)
    pitch("Il trouve une pastille lui indiquant qu'il a un nouveau message.".freeze)

    click_on 'Porte de frigo'
    expect(phil).to have_discussion('Message pour Phil', {with_new_messages: true})
    pitch("Il trouve la nouvelle discussion avec Benoit sur sa porte de frigo.")
    logout

    pitch("=== Échange de messages divers ===".freeze)
    start_time = Time.now.to_i

    pitch('Phil ajoute deux nouveaux messages'.freeze)
    phil.rejoint_la_discussion('Message pour Phil')
    phil.add_message_to_discussion('Message pour Phil', 'La réponse de Phil à Benoit.')
    phil.add_message_to_discussion('Message pour Phil', 'Une autre réponse de Phil à Benoit.')
    logout

    # = Vérification =
    TMails.exists?(benoit, {after: start_time, only_one:true, subject:'Nouveau message de Phil sur votre frigo'.freeze})
    pitch('Benoit a reçu un mail pour l’avertir du nouveau message (mais seulement 1)')
    expect(TDiscussion.get_by_titre('Message pour Phil')).to have_messages(count: 3)

    pitch('Benoit se rend sur son bureau pour trouver les messages')
    benoit.rejoint_son_bureau
    expect(benoit).to have_pastille_frigo(2)
    pitch('Benoit voit la pastille avec l’indication des 2 nouveaux messages')
    benoit.rejoint_la_discussion('Message pour Phil', {new_messages:2, participants_nombre:2, participants_pseudos:'Phil et Benoit'})

    click_on('Tout marquer lu', match: :first)
    benoit.revient_dans_son_bureau()
    expect(benoit).to have_no_pastille_frigo
    pitch('Benoit ne voit plus la pastille avec l’indication des 2 messages')

    gel('discussion-phil-benoit-3-messages')
    pitch("Note : le gel 'discussion-phil-benoit-3-messages' est produit")
  end

  scenario 'Benoit peut renoncer à inviter quelqu’un et revenir à sa discussion' do
    degel('discussion-phil-benoit-3-messages')
    pitch("Benoit rejoint la discussion avec Phil pour inviter…")
    benoit.rejoint_la_discussion('Message pour Phil')
    click_on(UI_TEXTS[:inviter_users_button], match: :first)
    expect(page).to have_css('h3', text: "#{UI_TEXTS[:inviter_users_button]} à la discussion “Message pour Phil”"),
      "La page devrait avoir le bon titre (Inviter des icariens à la discussion etc.)"
    pitch("Après avoir cliqué sur le bouton “#{UI_TEXTS[:inviter_users_button]}” il se retrouve sur la page d'invitation.")
    within('form#invitation-frigo-form') do
      click_on 'Renoncer'
      pitch('… mais il renonce')
    end
    expect(page).to have_css('div.titre-discussion', text: 'Message pour Phil'),
      "Benoit devrait se retrouver sur la page de la discussion"
    pitch('… et se retrouve sur la page de discussion avec Phil')
  end

  scenario 'Benoit peut inviter Marion à la discussion si elle l’autorise' do
    degel('discussion-phil-benoit-3-messages')
    start_time = Time.now.to_i
    pitch("Benoit rejoint la discussion avec Phil pour inviter Marion")
    benoit.rejoint_la_discussion('Message pour Phil')
    click_on(UI_TEXTS[:inviter_users_button], match: :first)
    expect(page).to have_css('h3', text: "#{UI_TEXTS[:inviter_users_button]} à la discussion “Message pour Phil”"),
      "La page devrait avoir le bon titre (Inviter des icariens à la discussion etc.)"
    pitch("Après avoir cliqué sur le bouton “#{UI_TEXTS[:inviter_users_button]}” il se retrouve sur la page d'invitation.")
    within('form#invitation-frigo-form') do
      expect(page).to have_css('option[value="10"]', text: 'Marion'),
        "Marion devrait être dans le listing des invitations"
      pitch("Et il trouve bien Marion dans le listing…")
      select('Marion', from: 'icariens')
      click_on 'Inviter'
      pitch('… qu’il peut inviter')
      screenshot('benoit-invite-marion-a-discuter')
    end

    # Tout est testé ici
    expect(marion).to have_been_invited_to_discussion('Message pour Phil')
    pitch("Marion a été correctement invitée à la discussion “Message pour Phil”")

  end

  scenario 'Benoit ne peut pas s’inviter lui-même ou inviter Phil' do
    degel('discussion-phil-benoit-3-messages')
    start_time = Time.now.to_i
    pitch("Benoit rejoint la discussion avec Phil pour inviter Marion")
    benoit.rejoint_la_discussion('Message pour Phil')
    click_on(UI_TEXTS[:inviter_users_button], match: :first)
    expect(page).to have_css('h3', text: "#{UI_TEXTS[:inviter_users_button]} à la discussion “Message pour Phil”"),
      "La page devrait avoir le bon titre (Inviter des icariens à la discussion etc.)"
    pitch("Après avoir cliqué sur le bouton “#{UI_TEXTS[:inviter_users_button]}” il se retrouve sur la page d'invitation.")
    within('form#invitation-frigo-form') do
      expect(page).not_to have_css('select[name="icariens"] option', text: 'Phil'),
        "Phil ne devrait pas être dans le listing des invitations"
      expect(page).not_to have_css('select[name="icariens"] option', text: 'Benoit'),
        "Benoit ne devrait pas être dans le listing des invitations"
      pitch("Et il ne trouve ni son nom ni Phil…")
    end
  end

  scenario 'Benoit peut inviter deux icariens à participer à la discussion' do
    degel('discussion-phil-benoit-3-messages')
    start_time = Time.now.to_i
    pitch("Benoit rejoint la discussion avec Phil pour inviter Marion et Élie")
    benoit.rejoint_la_discussion('Message pour Phil')
    click_on(UI_TEXTS[:inviter_users_button], match: :first)
    expect(page).to have_css('h3', text: "#{UI_TEXTS[:inviter_users_button]} à la discussion “Message pour Phil”"),
      "La page devrait avoir le bon titre (Inviter des icariens à la discussion etc.)"
    pitch("Après avoir cliqué sur le bouton “#{UI_TEXTS[:inviter_users_button]}” il se retrouve sur la page d'invitation.")
    within('form#invitation-frigo-form') do
      expect(page).to have_css('option[value="10"]', text: 'Marion'),
        "Marion devrait être dans le listing des invitations"
      pitch("Et il trouve bien Marion dans le listing…")
      select('Marion', from: 'icariens')
      select('Élie', from: 'icariens')
      click_on 'Inviter'
      pitch('… qu’il peut inviter')
      screenshot('benoit-invite-marion-a-discuter')
    end

    # Tout est testé ici
    expect(marion).to have_been_invited_to_discussion('Message pour Phil')
    pitch("Marion a été correctement invitée à la discussion “Message pour Phil”")
    expect(elie).to have_been_invited_to_discussion('Message pour Phil')
    pitch("Élie a été correctement invité à la discussion “Message pour Phil”")

    # === NOUVEAU DEGEL ===
    gel('marion-et-elie-invites-discussion-benoit-phil')

  end

  scenario 'Benoit ne peut pas inviter Marion à la discussion si elle interdit le contact' do
    degel('discussion-phil-benoit-3-messages')

    pitch("Benoit rejoint la discussion avec Phil pour voir s'il peut inviter Marion")
    benoit.rejoint_la_discussion('Message pour Phil')
    click_on(UI_TEXTS[:inviter_users_button], match: :first)
    expect(page).to have_css('h3', text: "#{UI_TEXTS[:inviter_users_button]} à la discussion “Message pour Phil”"),
      "La page devrait avoir le bon titre (Inviter des icariens à la discussion etc.)"
    pitch("Après avoir cliqué sur le bouton “#{UI_TEXTS[:inviter_users_button]}” il se retrouve sur la page d'invitation.")

    within('form#invitation-frigo-form') do
      expect(page).to have_css('option[value="10"]', text: /^Marion/),
        "Marion devrait être dans le listing des invitations"
      pitch("OK, il trouve Marion dans le listing.")
      screenshot('marion-dans-listing-invitation')
    end
    logout


    pitch('Marion rejoint l’atelier pour modifier ses préférences')
    marion.rejoint_son_bureau
    click_on('Préférences')
    within('form#preferences-form') do
      select('Aucun contact', from:'prefs-contact_icarien')
      click_on 'Enregistrer'
      pitch('Marion régle “Aucun contact” avec les autres icariens.')
    end
    expect(marion.option(27)).to eq(0),
      "Le bit 27 de marion devrait être réglé à 0"
    logout

    pitch("Benoit rejoint la discussion avec Phil pour inviter Marion")
    benoit.rejoint_la_discussion('Message pour Phil')
    click_on(UI_TEXTS[:inviter_users_button], match: :first)
    expect(page).to have_css('h3', text: "#{UI_TEXTS[:inviter_users_button]} à la discussion “Message pour Phil”"),
      "La page devrait avoir le bon titre (Inviter des icariens à la discussion etc.)"
    pitch("Après avoir cliqué sur le bouton “#{UI_TEXTS[:inviter_users_button]}” il se retrouve sur la page d'invitation.")

    within('form#invitation-frigo-form') do
      expect(page).not_to have_css('option[value="10"]', text: /^Marion/),
        "Marion ne devrait pas être dans le listing des invitations"
      pitch("Et il ne trouve pas Marion dans le listing.")
      screenshot('marion-pas-dans-listing-invitation')
    end
    logout

  end

  scenario 'Marion ne peut pas forcer l’invitation à la discussion de Benoit' do
    degel('marion-et-elie-invites-discussion-benoit-phil')

    pitch("En rejoignant la discussion “Message pour Phil…”")
    marion.rejoint_la_discussion('Message pour Phil')
    expect(page).not_to have_content(UI_TEXTS[:inviter_users_button])
    pitch("… Marion ne trouve pas de bouton pour inviter d'autres icariens…")

    pitch('Même en forçant l’accès aux invitations…')
    goto("bureau/frigo?op=inviter&did=1")
    screenshot("marion-tente-forcer-invitations")
    expect(page).to have_css('h2', text: 'Votre porte de frigo')
    expect(page).to have_content(ERRORS[:inviter_requires_owner])
    pitch("Marion ne parvient pas à atteindre la page des invitations.")

  end


  scenario 'Marion ne peut pas détruire la discussion de Benoit' do
    degel('marion-et-elie-invites-discussion-benoit-phil')

    pitch("En rejoignant la conversation “Message pour Phil”, Marion ne trouve pas de bouton pour la détruire.")
    marion.rejoint_la_discussion('Message pour Phil')
    expect(page).not_to have_css('a', text: 'Détruire'),
      "La page ne devrait pas contenir de bouton “Détruire”"
    expect(page).not_to have_css('a[href="bureau/frigo?op=destroy&did=1"]'),
      "La page ne devrait pas contenir un lien permettant de détruire la conversation"

    pitch("Même en essayant de la forcer par une route directe, Marion échoue.")
    goto("bureau/frigo?op=destroy&did=1")
    expect(page).not_to have_content('Détruire cette discussion'),
      "La page ne devrait pas contenir le texte “Détruire cette discussion”"
    expect(page).not_to have_css('form#form-destroy-discussion'),
      "La page ne devrait pas contenir le formulaire de destruction de la discussion"
    screenshot('marion-tries-to-destroy-discussion-benoit')
    logout

    expect(benoit).to have_discussion('Message pour Phil', {owner:true})
    pitch("Malgré les tentatives de destruction de Marion, la discussion est toujours là")

  end

  scenario 'Benoit ne peut pas détruire sa discussion, mais peut la marquer à détruire', only:true do
    degel('marion-et-elie-invites-discussion-benoit-phil')

    start_time = Time.now.to_i

    # On s'assure d'abord que la discussion soit une vraie discussion, donc
    # avec des participants et des messages
    discussion = TDiscussion.get_by_titre('Message pour Phil')
    expect(discussion).to be_real_discussion

    pitch('Benoit veut détruire sa discussion avec Phil, Élie et Marion.')
    pitch('Il rejoint la discussion…')
    benoit.rejoint_la_discussion('Message pour Phil')
    pitch('… et cliquer le bouton “Détruire”')
    click_on('Détruire')
    pitch("Il rejoint alors une page de confirmation de la destruction…")
    expect(page).to have_css('form#form-destroy-discussion'),
      "La page devrait avoir le formulaire de destruction de la discussion"
    expect(page).to have_css('a[href="bureau/frigo?op=download&disid=1"]'),
      "La page devrait présenter un lien pour télécharger la discussion"
    pitch("… avec un lien pour la télécharger")
    within('form#form-destroy-discussion') do
      click_on('Détruire cette discussion')
    end
    pitch("… et un bouton pour confirmer la destruction qu'il clique.")

    expect(discussion).to be_real_discussion
    pitch("La discussion existe toujours…")
    watcher = TWatchers.find(objet_id:discussion.id, objet:'FrigoDiscussion', owner:benoit, after: start_time)
    expect(watcher).not_to eq(nil),
      "Un watcher devrait exister pour détruire la conversation".freeze
    pitch('… mais un watcher a été initié pour la détruire dans une semaine…'.freeze)
    data_mail = {after: start_time, subject:FrigoDiscussion::SUBJECT_ANNONCE_DESTROY}
    discussion.participants.each do |part|
      expect(TMails).to be_exists(part.mail, data_mail)
    end
    pitch("… et tous les participants ont été prévenus.".freeze)
  end

  scenario 'Seul un administrateur peut détruire une discussion (avec un watcher)' do
    pending "à implémenter"
    # TODO Toutes les frigo_users ont bien été détruits
    # TODO Tous les messages ont bien été détruits
    expect(TFrigo).to have_no_discussion(1)
    pitch("La discussion est intégralement détruite (participants, messages)")
  end

  scenario 'Marion peut quitter la conversation de Benoit' do
    # TODO Il faut d'abord faire un gel du moment où elle est invitée
    # par Benoit
    pending "à implémenter"
  end

end
