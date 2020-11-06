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
  # OUT   True s'il y a un évaluateur connecté ou un administrateur
  def current?
    user.admin? || not(self.current.nil?)
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

  def try_reconnect_evaluator
    return true if user.admin?
    require File.join(DATA_FOLDER,'secret','concours') # => CONCOURS_DATA
    if not session['concours_evaluator_id'].nil?
      CONCOURS_DATA[:evaluators].each do |devaluator|
        if session['concours_evaluator_mail'] == devaluator[:mail]
          html.evaluator = Evaluator.new(devaluator)
          self.current = html.evaluator
          break
        end
      end
      return not(html.evaluator.nil?)
    else
      # Il faut s'identifier
      redirect_to("concours/evaluation?view=body_login")
      return false
    end
  end #/ try_reconnect_evaluator
end # /<< self
end #/Evaluator
