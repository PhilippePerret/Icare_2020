# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class HTML pour le concours
=end
class HTML
  # Instance {Concurrent} du concurrent courant (s'il y en a un)
  attr_accessor :concurrent

  # Instance {Evaluator} de l'évaluateur (s'il y en a un)
  attr_accessor :evaluator

  # Méthode qui va tenter de reconnecter un visiteur qui peut être soit :
  #   - admin       => rien à faire
  #   - concurrent  => rien à faire, on le reconnecte
  #   - concurrent icarien
  #   - membre jury
  #
  def try_to_reconnect_visitor(mandatory = false)
    log("-> try_to_reconnect_visitor")
    if user.admin?
      log("   <- admin")
      reconnect_admin
    elsif not(user.guest?) && session['concours_user_id'].nil?
      log("   <- icarien")
      reconnect_icarien(mandatory)
    elsif session['concours_user_id']
      log("   <- concurrent")
      reconnect_concurrent(mandatory)
    elsif session['concours_evaluator_id']
      reconnect_evaluator(mandatory)
    elsif mandatory
      log("   <- introuvable => login")
      unable_reconnection
    end
  end #/ try_to_reconnect_visitor

  def reconnect_admin
    require './_lib/_pages_/concours/evaluation/lib/Evaluator'
    Evaluator.current = self.evaluator = Evaluator.new({id:user.id, pseudo:user.pseudo, mail:user.mail, sexe:user.sexe, jury:3})
    self.evaluator.is_admin = true
    return true
  end #/ reconnect_admin

  def reconnect_concurrent(mandatory)
    self.concurrent = Concurrent.authentify(session['concours_user_id'])
    if self.concurrent
      log("RECONNEXION CONCURRENT #{concurrent.id} (#{concurrent.pseudo})")
    elsif mandatory
      return unable_reconnection
    end
  end #/ reconnect_concurrent

  def reconnect_icarien(mandatory)
    dc = db_exec("SELECT concurrent_id FROM #{DBTBL_CONCURRENTS} WHERE mail = ?", [user.mail]).first
    if not dc.nil?
      session['concours_user_id'] = dc[:concurrent_id]
      db_exec("UPDATE #{DBTBL_CONCURRENTS} SET session_id = ? WHERE concurrent_id = ?", [session.id, dc[:concurrent_id]])
      self.concurrent = Concurrent.get(dc[:concurrent_id])
    elsif mandatory
      unable_reconnection
    end
  end #/ reconnect_icarien

  def reconnect_evaluator(mandatory)
    log("-> reconnect_evaluator / session['concours_evaluator_mail'] = #{session['concours_evaluator_mail'].inspect}")
    require './_lib/_pages_/concours/evaluation/lib/Evaluator'
    require File.join(DATA_FOLDER,'secret','concours') # => CONCOURS_DATA
    CONCOURS_DATA[:evaluators].each do |devaluator|
      if session['concours_evaluator_mail'] == devaluator[:mail]
        Evaluator.current = self.evaluator = Evaluator.new(devaluator)
        return true # ok
      end
    end
    if mandatory
      redirect_to("concours/evaluation?view=login")
      return false
    end
  end #/ reconnecte_evaluator

  # En cas de reconnexion impossible
  # --------------------------------
  # Si la route courante était une route d'évaluation, on renvoie au formulaire
  # d'identification d'un évaluateur (membre du jury), sinon, au login du
  # concours (pour concurrent)
  def unable_reconnection
    erreur(ERRORS[:concours_login_required])
    redir = if route.to_s == 'concours/evaluation'
              "concours/evaluation?view=login"
            else
              "concours/identification"
            end
    # On redirige le visiteur
    return redirect_to(redir)
  end #/ unable_reconnection

end #/class HTML
