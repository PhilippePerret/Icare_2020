# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class Evaluator
  ---------------
  Pour la gestion des évaluateurs, c'est-à-dire des membres du jury
=end
class Evaluator
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

# DO    Envoie un mail à tous les jury avec les paramètres +params+
# IN    {Hash} +params+ Paramètres pour l'envoi (cf. le manuel du concours)
def send(params)
  require_module('mail')
  destinataires = all.select do |evaluator|
    condition = true
    condition = condition && evaluator.jury == params[:jury]
    condition
  end
  MailSender.send_mailing(file:params[:file], to:destinataires, from: CONCOURS_MAIL)
end #/ send

def all
  @all ||= begin
    data.collect { |de| new(de) }
  end
end #/ all

def data
  @data ||= begin
    require('./_lib/data/secret/concours')
    CONCOURS_DATA[:evaluators]
  end
end #/ data
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data
def initialize(data)
  @data = data
end #/ initialize

# OUT   Adresse mail du jury
def mail; @mail ||= data[:mail] end

# OUT   Le jury auquel appartient l'évaluateur, 1, 2 ou les deux (3)
def jury; @jury ||= data[:jury] end
# OUT   True si l'évaluateur appartient au premier jury
def jury_1? ; jury == 1 || jury == 3 end
# OUT   True si l'évaluateur appartient au second jury
def jury_2? ; jury == 2 || jury == 3 end

# ---------------------------------------------------------------------
#
#   CONSTANTES
#
# ---------------------------------------------------------------------

end #/Evaluator
