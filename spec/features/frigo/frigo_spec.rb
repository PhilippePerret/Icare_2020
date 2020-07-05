# encoding: UTF-8
=begin
  Test complet du frigo
=end
require_relative 'TFrigo_classes'
require_relative 'frigo_matchers'
require_relative 'TUser_discussions'

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
    expect(page).to have_total_messages_count(2)
    phil.add_message_to_discussion('Message pour Phil', 'Une autre réponse de Phil à Benoit.')
    expect(page).to have_total_messages_count(3)
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

    gel('discussion-phil-benoit-3-messages', <<-TEXT.freeze)
Dans cette discussion instanciée par Benoit avec Phil, 3 messages ont été échangés, les deux derniers émis par Phil et Benoit vient de les lire et de les marquer lus.

* Titre discussion : "Message pour Phil"
* Participants : Benoit, Phil
* Messages : 3
* Premier message de Benoit, deux suivant par Phil

    TEXT
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

    # === NOUVEAU GEL ===
    gel('marion-et-elie-invites-discussion-benoit-phil', <<-TEXT.freeze)
Benoit, qui a créé une discussion avec Phil, vient d'inviter Marion et Élie à rejoindre cette discussion. Ils ont reçus les mails mais n'ont pas encore répondu.

* Titre discussion : "Message pour Phil"
* Participants : Benoit, Phil
* Messages : 3
    TEXT
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
    expect(page).to have_titre('Discussion de frigo'.freeze)
    expect(page).to have_content(ERRORS[:inviter_requires_owner])
    pitch("Marion ne parvient pas à atteindre la page des invitations.".freeze)

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
    screenshot('marion-tries-to-destroy-discussion-benoit')
    expect(page).not_to have_content('Détruire cette discussion'),
      "La page ne devrait pas contenir le texte “Détruire cette discussion”"
    expect(page).not_to have_css('form#form-destroy-discussion'),
      "La page ne devrait pas contenir le formulaire de destruction de la discussion"
    logout

    expect(benoit).to have_discussion('Message pour Phil', {owner:true})
    pitch("Malgré les tentatives de destruction de Marion, la discussion est toujours là")

  end










  scenario 'Benoit ne peut pas détruire sa discussion, mais peut la marquer à détruire' do
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
      if part.id == discussion.owner.id
        # Le propriétaire n'a pas à recevoir ce mail
        expect(TMails).not_to be_exists(part.mail, data_mail),
          "Le propriétaire de la discussion ne devrait pas recevoir le mail d'avertissement"
      else
        expect(TMails).to be_exists(part.mail, data_mail),
          "Un participant à la discussion devrait toujours recevoir un mail d'avertissement"
          # Même s'il ne veut pas être contacté par mail
      end
    end
    pitch("… et tous les participants ont été prévenus.".freeze)

    gel('after-benoit-pre-destroy-discussion', <<-TEXT.freeze)
Dans ce gel, la discussion instanciée par Benoit, qui rassemble Marion, Élie et Phil, a été détruite par Benoit. Mais cette destruction n'est pas encore effectuée puisque c'est un watcher, qui doit se déclencher dans une semaine, qui doit permettre à Phil de la détruire.

En revanche, des mails ont été envoyé à Marion, Élie et Phil pour les avertir et leur permettre de télécharger la discussion. Dans le mail se trouve un lien direct vers la discussion.

* Nombre de messages : 3 (de Benoit et de Phil)
* Participants : Benoit, Marion, Élie, Phil
    TEXT

  end












  scenario 'Seul un administrateur peut détruire une discussion (avec un watcher)' do
    degel('after-benoit-pre-destroy-discussion')

    pitch("Phil va rejoindre ses notifications pour détruire la discussion. Mais avant ça, Benoit va vérifier qu'il voit bien la notification.")

    # On récupère les informations sur la discussion qui doit être détruite
    discuss   = TDiscussion.get_by_titre('Message pour Phil')
    disid     = discuss.id.freeze
    distitre  = discuss.titre.freeze
    participants = discuss.participants
    expect(benoit).to have_discussion(distitre, {owner: true})

    # Ici, ON MODIFIE LE WATCHER DE DESTRUCTION produit pendant le gel
    # pour qu'il apparaisse sur mon bureau d'administration
    dwatcher = db_get('watchers', {objet_id: disid, wtype:'destroy_discussion', user_id: benoit.id})
    expect(dwatcher).not_to eq(nil),
      "On devrait trouver le watcher de destruction de la discussion…".freeze
    request = "UPDATE `watchers` SET triggered_at = ? WHERE id = ?".freeze
    db_exec(request, [Time.now.to_i - 10, dwatcher[:id]])

    # Le selector du watcher
    wselector = "div#watcher-#{dwatcher[:id]}".freeze

    pitch("Benoit rejoint ses notifications…")
    benoit.rejoint_ses_notifications
    expect(page).to have_css(wselector, text: 'destruction de la discussion “Message pour Phil”')
    pitch("… et en trouve une lui indiquant la destruction prochaine.".freeze)
    logout

    start_time = Time.now.to_i

    # Maintenant, je peux aller trouver le watcher
    phil.rejoint_ses_notifications
    expect(page).to have_css(wselector),
      "La page devrait montrer le watcher pour détruire la discussion"
    pitch("Phil trouve la notification sur son bureau")
    within(wselector) do
      pitch("Il clique sur le bouton pour détruire la discussion.")
      click_on("Détruire la discussion".freeze)
    end
    screenshot("after-phil-destroys-discussion")

    # === Vérifications ===
    expect(page).to have_content(MESSAGES[:confirm_discussion_destroyed]),
      "La page devrait afficher le message de confirmation de destruction"
    pitch("Un message confirme la destruction.")
    expect(TWatchers.get(dwatcher[:id])).to eq(nil),
      "Le watcher de destruction devrait avoir été détruit."
    logout



    pitch("Benoit rejoint ses notifications et…".freeze)
    benoit.rejoint_ses_notifications
    screenshot('benoit-in-notifs-after-destroying'.freeze)
    expect(page).not_to have_css(wselector),
      "Le watcher aurait dû être détruit (or, Benoit le trouve.)"
    pitch("… note (sic) que le watcher de destruction n'est plus affiché.".freeze)
    logout

    # On vérifie
    expect(TFrigo).to have_no_discussion(disid),
      "La discussion “#{distitre}” ne devrait plus exister"
    pitch("La discussion est intégralement détruite (participants, messages)")

    data_mail = {after: start_time, subject:'Destruction d’une discussion'.freeze}
    expect(TMails).to be_exists(benoit.mail, data_mail),
      "Benoit aurait dû recevoir un mail lui annonçant la destruction"
    pitch("Benoit est prévenu par un mail spécial (depuis la notification)")

    data_mail = {after: start_time, subject:FrigoDiscussion::TITRE_MAIL_DESTRUCTION}
    participants.each do |part|
      if part.id == benoit.id
        expect(TMails).not_to be_exists(part.mail, data_mail),
          "Benoit ne devrait pas recevoir le mail d'information aux participants".freeze
      else
        expect(TMails).to be_exists(part.mail, data_mail),
          "Un participant à la discussion autre que le propriétaire devrait toujours recevoir un mail d'information de destruction (#{part.pseudo} n'en a pas reçu)"
      end
    end
    pitch("Les autres participants sont prévenus par mail")

    gel('phil-has-destroyed-discussion-benoit', <<-MKD.freeze)
Dans ce gel, Phil vient de détruire la discussion instanciée par Benoit, à laquelle participaient Marion et Élie. Cette discussion, ici, n'existe plus, et les mails ont été envoyés à tout le monde. La notification (watcher) de destruction n'existe plus.

Discussion ID: ##{disid}
Titre discussion : "#{distitre}"
Messages avant destruction : 3
Participants : Benoit (créateur), Phil, Marion, Élie
    MKD

  end







  scenario 'Marion peut quitter la conversation de Benoit' do
    degel('marion-et-elie-invites-discussion-benoit-phil')

    marion.rejoint_la_discussion('Message pour Phil'.freeze)

    # Vérification pré-test pour voir si les choses sont OK
    expect(page).to have_new_messages_count(3)
    expect(page).to have_total_messages_count(3)
    expect(page).to have_participants_count(4)
    expect(page).to have_participants_pseudos('Phil, Marion, Benoit et Élie')
    pitch("Marion trouve un affichage correct du nombre de messages et de participants")

    pitch("Marion laisse deux messages…")
    marion.add_message_to_discussion('Message pour Phil', 'Le premier message de Marion.')
    marion.add_message_to_discussion('Message pour Phil', 'Le second message de Marion.')
    expect(page).to have_css('span.total-messages-count', text:'5'),
      "Le nombre total de messages (affiché) devrait être de 5"
    pitch("… et peut voir que le nombre de messages a changé.")

    pitch("Marion quitte la discussion")
    expect(page).to have_css('a[href="bureau/frigo?op=quitter_discussion&did=1"]', text:'Quitter cette discussion'),
      "La page devrait présenter un bouton pour quitter la conversation"
    click_on('Quitter cette discussion'.freeze)
    # === Vérifications ===
    expect(page).to have_content('Vous avez bien quitté la discussion “Message pour Phil”')
    pitch('Un message lui confirme que c’est fait')
    expect(page).to have_titre('Votre porte de frigo')
    pitch('Elle se retrouve sur sa porte de frigo')
    logout

    pitch("Benoit va venir sur la discussion pour voir les changements")
    benoit.rejoint_la_discussion('Message pour Phil')
    screenshot('bon-comptes-apres-marion-quit-discuss')
    expect(page).to have_new_messages_count(2)
    expect(page).to have_total_messages_count(5)
    expect(page).to have_participants_count(3)
    expect(page).to have_participants_pseudos("Phil, Benoit et Élie (ex Marion)".freeze)
    pitch('Il trouve le bon nombre de messages (nouveaux et total) et le bon affichage des pseudos (malgré le départ de Marion)')

    discuss = TDiscussion.get_by_titre('Message pour Phil')
    gel('marion-a-quitte-discussion-benoit', <<-TEXT.freeze)
Dans ce gel, marion a quitté la conversation initiée entre Benoit et Phil, mais en laissant deux messages.

Discussion : ##{discuss.id}
Titre : #{discuss.titre}
Participants : Benoit, Phil, Élie (ex Marion)
Nombre de messages : 5
    TEXT
  end




  scenario 'tous les titres du frigo sont bons' do
    degel('marion-a-quitte-discussion-benoit') # celui-là ou un autre

    pitch("Benoit rejoint son bureau et…")
    benoit.rejoint_son_bureau
    expect(page).to have_css('div.goto#goto-frigo', text: 'Porte de frigo')
    pitch('… trouve le div-goto “Porte de frigo”')
    pitch('Il clique sur ce div-goto…')
    click_on 'Porte de frigo'
    expect(page).to have_titre('Votre porte de frigo', {retour:{route:'bureau/home', text:'Bureau'}})
    pitch('… et arrive sur le frigo proprement dit avec le titre “Votre porte de frigo” et un lien pour retourner au bureau')
    within('h2.page-title') do
      click_on 'Bureau'
    end
    pitch('Benoit, en cliquant sur le lien retour, revient sur le bureau'.freeze)
    expect(page).to have_titre('Votre bureau')
    click_on 'Porte de frigo'
    pitch('Benoit clique sur la discussion “Message pour Phil”…')
    click_on 'Message pour Phil'
    pitch('… et rejoint la page de la discussion'.freeze)
    expect(page).to have_css('div.titre-discussion', text:'Message pour Phil')
    pitch('… qui contient le titre de la discussion'.freeze)
    expect(page).to have_titre('Discussion de frigo', {retour:{route:'bureau/frigo', text:'Frigo'}})
    pitch('… qui contient le titre “Discussion de frigo” avec un lien retour vers la porte de frigo.'.freeze)
    pitch('Benoit clique sur le lien retour…'.freeze)
    within('h2.page-title') do
      click_on 'Frigo'
    end
    expect(page).to have_titre('Votre porte de frigo'.freeze)
    pitch('… et revient sur sa porte de frigo.'.freeze)
  end

end
