# encoding: UTF-8
# frozen_string_literal: true

UI_TEXTS.merge!({
  # *** Titres ***
  titre_page_inscription: "Inscription au concours",
  concours_titre_participant: "Participation au concours",
  #  *** boutons ***
  concours_bouton_signup: "S’inscrire",
  concours_bouton_sidentifier: "S’identifier",
  concours_bouton_send_dossier: "Transmettre ce dossier",
  bouton_recup_numero: "Me renvoyer mon numéro d'inscription"
})

ERRORS.merge!({
  concours_mail_required: "Votre mail est requis, pour récupérer votre numéro d'inscription.",
  concours_mail_unknown: "Désolé, mais le mail '%s' est inconnu de nos services…",
  concours_login_required: "Identifiez-vous pour pouvoir rejoindre cette page."
})

MESSAGES.merge!({
  concours_signed_confirmation: "Confirmation de votre inscription au concours de synopsis",
  concours_new_signup_titre: "Nouvelle inscription au concours de synopsis",
  concours_sujet_retrieve_numero: "Récupération de votre numéro d'inscription au concours"
})

ANNEE_CONCOURS_COURANTE = Time.now.month < 3 ? Time.now.year : Time.now.year + 1

DBTABLE_CONCOURS = "concours"
DBTABLE_CONCURRENTS = "concours_concurrents"
DBTBL_CONCURS_PER_CONCOURS = "concurrents_per_concours"

# Lien conduisant au règlement du concours de l'année en cours
REGLEMENT_LINK  = "<a href=\"public/Concours_ICARE_#{ANNEE_CONCOURS_COURANTE}.pdf\" target=\"_blank\">Réglement du concours</a>"

REQUEST_CHECK_CONCURRENT = "SELECT * FROM #{DBTABLE_CONCURRENTS} WHERE concurrent_id = ? AND mail = ?"

CONCOURS_KNOWLEDGE_VALUES = [
  ["none", "Vous avez entendu parler de ce concours par…"],
  ["google", "une recherche google"],
  ["forum", "un forum d'écriture"],
  ["facebook", "un groupe Facebook"],
  ["someone", "bouche à oreille"],
  ["medias", "les médias"],
  ["autre", "un autre moyen"]
]
class Linker
  attr_reader :default_text, :route
  def initialize(withdata)
    @default_text = withdata[:text]
    @route        = withdata[:route]
  end #/ initialize
  def to_str
    default_template % {route: real_route, text: default_text || route}
  end #/ to_str
  def real_route
    finpath = "#{@path_absolu ? "#{App.url}/" : ""}#{route}"
    @path_absolu = nil
    finpath
  end #/ real_route
  alias :to_s :to_str
  def with(data)
    data = {text: data} if data.is_a?(String)
    @path_absolu = true if data[:absolute]
    data.merge!(text: default_text) unless data[:text]
    default_template % data.merge!(route: real_route)
  end #/ with
  def absolute # pour utilisation avec .with(...) ensuite
    @path_absolu = true
    return self
  end #/ absolute
  def default_template
    @default_template ||= Tag.link(route: '%{route}', text: '%{text}')
  end #/ default_template
end #/Linker
CONCOURS_LINK   = Linker.new(route:"concours/accueil", text:"Concours de Synopsis de l'atelier ICARE")
DOSSIER_LINK    = Linker.new(route:"concours/dossier", text:"dossier de candidature")
CONCOURS_SIGNUP = Linker.new(route:'concours/inscription', text:"formulaire d'inscription")
CONCOURS_LOGIN  = Linker.new(route:'concours/identification', text:"formulaire d'identification")
