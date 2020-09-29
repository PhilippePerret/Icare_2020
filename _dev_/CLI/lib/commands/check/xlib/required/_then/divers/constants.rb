# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module des constants
=end

VERBOSE = IcareCLI.option?(:verbose)

MESSAGES.merge!({
  question_check: "Qu'est que je dois checker ?"
})

DATA_WHAT_CHECK = [
  {name: "Tout (user, modules, etc.)", value: :all},
  {name: "Les icariens",  value: :user},
  {name: "Les modules",   value: :module},
  {name: "Les documents", value: :document},
  {name: "Les étapes",    value: :etape},
  {name: "Renoncer",      value: :cancel}
]

values_yes_no = [
  {name: "oui", value: true},
  {name: "non", value: false}
]
DATA_INTERACTIVE = [
  {
    question: "Données à checker",
    values: [
        {name: "données distantes", value: false},
        {name: "données locales", value: true}
    ],
    optionkey: :local,
    default: 1
  },
  {
    question: "Mode verbeux",
    values: values_yes_no,
    optionkey: :verbose,
    default: 1
  },
  {
    question: "Réparer les erreurs",
    values: values_yes_no,
    optionkey: :reparer,
    default: 2
  },
  {
    question: "Simuler les réparations",
    values: values_yes_no,
    optionkey: :simuler,
    default: 2
  }
]

WATCHER_WTYPE_PER_STATUS = {
  1 => {wtype: 'send_work'},
  2 => {wtype: 'download_work'},
  3 => {wtype: 'send_comments'},
  4 => {wtype: 'download_comments', maybe: 'changement_etape'},
  5 => {wtype: 'qdd_depot', maybe: 'changement_etape'},
  6 => {wtype: 'qdd_sharing', maybe: 'changement_etape'},
  7 => {wtype: nil},
  8 => {wtype: nil}
}

# class DataCheckedError < StandardError
#   class << self
#     attr_reader :errors # liste de toutes les erreurs
#     attr_accessor :current_owner # pour définir le propriétaire courant de l'erreur
#     def add_error(err)
#       @errors ||= []
#       @errors << err
#     end #/ add_error
#   end #/<< self
#
#   attr_reader :owner # le propriétaire de l'erreur (module, étape, etc.)
#   attr_reader :message
#   def initialize err_msg, values = nil
#     if values.nil?
#       @message = err_msg
#     else
#       @message = err_msg % values
#     end
#     @owner = self.class.current_owner
#     self.class.add_error(self)
#   end #/ initialize
#   def full_message
#     "##{TABU}ERREUR : #{@message}"
#   end #/ message
# end

TABU = "    "

# POINT_VERT = ".".vert
POINT_ROUGE = ".".rouge

SSH_SERVER = 'icare@ssh-icare.alwaysdata.net'
