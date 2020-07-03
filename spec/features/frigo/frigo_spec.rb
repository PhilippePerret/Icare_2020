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
  before(:all) do
    degel('validation_deux_inscriptions')
    # Note : avec ce gel, on a 3 users, Marion, Benoit et Élie, et aucun
    # message Frigo n'a été déposé
  end
  before(:each) do
    Capybara.reset_sessions!
  end
  let(:count_messages) { TFrigo.count_messages }
  scenario "Benoit peut initier une discussion avec Phil", only:true do

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

    benoit.rejoint_la_discussion('Message pour Phil')

  end

  scenario 'Marion peut initier une discussion avec Phil' do
    marion_rejoint_son_frigo
    logout
  end

end
