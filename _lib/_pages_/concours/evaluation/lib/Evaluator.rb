# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class Evaluator
  ---------------
  Pour la gestion des Évaluateur
=end
class Evaluator
class << self
  attr_accessor :current
  # OUT   True s'il y a un évaluateur connecté (ou un administrateur)
  def current?
    not(self.current.nil?)
  end #/ current

  # Appelé lorsque le membre s'authentifie
  def authentify_evaluator
    if session['concours_login_tentatives'].to_i > 5
      return erreur("Trop d'erreurs, je ne peux pas vous laisser continuer.<br/>Contactez Phil si vous êtes vraiment un membre du jury.")
    end
    require File.join(DATA_FOLDER,'secret','concours') # => CONCOURS_DATA
    session['concours_login_tentatives'] ||= 0
    session['concours_login_tentatives'] += 1
    CONCOURS_DATA[:evaluators].each do |devaluator|
      if devaluator[:mail] == param(:member_mail)
        if devaluator[:password] == param(:member_password)
          message("Bienvenue à vous, #{devaluator[:pseudo]} !")
          session['concours_evaluator_id']    = devaluator[:id]
          session['concours_evaluator_mail']  = devaluator[:mail]
          session.delete('concours_login_tentatives')
          redirect_to("concours/evaluation")
        end
      end
    end
    erreur("Désolé, je ne vous remets pas… Pouvez-vous réessayer ?")
  end #/ authentify_evaluator

  # Pour déconnecter l'évaluateur courant
  def deconnect_evaluator
    current || try_to_reconnect_visitor
    pseudo = (current&.pseudo || 'cher membre').freeze
    session.delete('concours_evaluator_id')
    session.delete('concours_evaluator_mail')
    message("À très bientôt, #{pseudo} !")
    redirect_to("concours/accueil")
  end #/ deconnect_evaluator

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data_ini, :pseudo, :mail, :id
attr_accessor :is_admin, :is_concurrent

def initialize(data_ini)
  @data_ini = data_ini
  @data_ini.each{|k,v|instance_variable_set("@#{k}",v)}
end #/ initialize

def admin?
  self.is_admin === true
end #/ admin?
def concurrent?
  self.is_concurrent === true
end #/ concurrent?
def jury1?
  admin? || data_ini[:jury] & 1 > 0
end #/ jury1?
def jury2?
  admin? || data_ini[:jury] & 2 > 0
end #/ jury2?

end #/Evaluator
