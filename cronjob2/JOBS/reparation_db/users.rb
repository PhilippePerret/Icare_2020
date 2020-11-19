# encoding: UTF-8
# frozen_string_literal: true
class StatusError < StandardError; end

class Cronjob

  # Réparation de la table des users
  def reparation_users

    # On supprime les enregistrements vides
    destruction_users_vides

    # pour récolter toutes les données
    all_data_users

    # Destruction des modules, étapes et documents qui n'ont
    # aucun propriétaires
    destruction_modules_etapes_documents_orphelins

    # = statut de l'user =
    # On s'assure que le bit 16 (17e) soit en accord avec les données
    # annexes
    verifier_et_corriger_user_statut

  end #/ reparation_users

  def destruction_users_vides
    request = "SELECT id FROM users WHERE pseudo = '' OR pseudo IS NULL OR mail = '' OR mail IS NULL"
    res = db_exec(request)
    if res.empty?
      Report << "Aucun enregistrement user n'est à détruire (vide)"
    else
      if noop?
        Logger << "#{res.count} enregistrement(s) seraient à détruire, hors mode NOOP"
      else
        request = "DELETE FROM users WHERE id IN (#{res.collect{|du|du[:id]}.join(', ')})"
        db_exec(request)
        Report << "= Nombre d'enregistrements users détruits : #{res.count}."
      end
    end
  end #/ destruction_users_vides

  def destruction_modules_etapes_documents_orphelins
    unless @unknow_users_id.empty?
      if noop?
        Logger << "Les users suivants n'ont pas été trouvés, il faut détruire les modules/étapes/documents leur appartenant : #{@unknow_users_id.inspect}"
      end
      erasables = {}
      ['icmodules', 'icetapes', 'icdocuments'].each do |dbtable|
        erasables.merge!(dbtable => [])
        db_exec("SELECT id FROM #{dbtable} WHERE user_id IN (#{@unknow_users_id.join(', ')})").each do |d|
          erasables[dbtable] << d[:id]
        end
      end
      if noop?
        Logger << "[NOOP] Éléments qui seront détruits : #{erasables.inspect}"
      else
        eraseds = {}
        erasables.each do |dbtable, id_list|
          next if id_list.empty?
          db_exec("DELETE FROM #{dbtable} WHERE id IN (#{id_list.join(', ')})")
          eraseds.merge!(dbtable => id_list)
        end
        Report << "Destruction des éléments suivants : #{eraseds.inspect}"
      end
    end
    unless @unknow_module_id.empty?
      Logger << "Modules inconnus :\n#{@unknow_module_id.collect{|d|"User ##{d[:user][:id]} (#{d[:user][:pseudo]}) MODULE ID ##{d[:module_id]}"}.join("\n")}"
      erasables = {}
      module_ids = @unknow_module_id.collect {|d| d[:module_id]}
      etape_ids = db_exec("SELECT id FROM icetapes WHERE icmodule_id IN (#{module_ids.join(', ')})").collect{|d|d[:id]}
      erasables.merge!('icetapes' => etape_ids)
      document_ids = db_exec("SELECT id FROM icdocuments WHERE icetape_id IN (#{etape_ids.join(', ')})").collect{|d|d[:id]}
      erasables.merge!('icdocuments' => document_ids)
      if noop?
        Report << "[NOOP] Les étapes et documents suivants seront détruits : #{erasables.inspect}"
      else
        erasables.each do |dbtable, id_list|
          db_exec("DELETE FROM #{dbtable} WHERE id IN (#{id_list})")
        end
        Report << "Étapes et documents détruits : #{erasables.inspect}"
      end
    end
  end #/ destruction_modules_etapes_documents_orphelins

  def verifier_et_corriger_user_statut
    if noop?
      Logger << "Je dois vérifier et corriger le bit de statut"
    end
    all_data_users.each do |uid, duser|
      check_and_correct_user_information(duser)
    end
  end #/ verifier_et_corriger_user_statut



  # = main =
  #
  # Méthode qui va vérifier les informations de l'icarien et corriger si
  # nécessaire son statut et peut-être d'autres informations.
  def check_and_correct_user_information(duser)
    uref = "#{duser[:pseudo].upcase} ##{duser[:id]} "
    duser.merge!(ref: uref)
    # Pour mettre les réparations supplémentaires (par exemple, quelquefois,
    # il faut modifier autre chose que les options)
    duser.merge!(reparations: {})
    status = duser[:options][16].to_i
    # Logger << "Statut de #{uref} : #{status}"
    case status
    when 0
      Logger << "#{uref} ne peut pas avoir un statut 0 (non défini)"
      search_and_set_good_status(duser, 0)
    when 1 # INVITÉ
      Logger << "#{uref} ne peut pas avoir un statut 1 (invité)"
      search_and_set_good_status(duser, 1)
    when 2 # ACTIF
      should_be_actif(duser)
    when 3 # CANDIDAT
      should_be_candidat(duser)
    when 4 # inactif (ancien)
      should_be_inactif(duser)
    when 5
      should_be_destroyed(duser)
    when 6
      should_be_recu(duser)
    when 7
      search_and_set_good_status(duser)
    when 8 # en pause
      should_be_en_pause(duser)
    end
  end #/ check_and_correct_user_information

  # Un icarien actif doit avoir un module courant et ce module courant
  # doit être vraiment en cours (non fini)
  def should_be_actif(duser)
    res = can_be_status_actif(duser) # retourne TRUE ou l'erreur
    return true if res === true
    Logger << "#{duser[:ref]} ne peut pas être actif : #{res}"
    search_and_set_good_status(duser, 2)
  end #/ should_be_actif

  def should_be_candidat(duser)
    res = can_be_status_candidat(duser)
    return true if res === true
    Logger << "#{duser[:ref]} ne peut pas être un candidat : #{res}"
    search_and_set_good_status(duser, 3)
  end #/ should_be_candidat

  def should_be_inactif(duser)
    res = can_be_status_inactif(duser)
    return true if res === true
    Logger << "#{duser[:ref]} ne peut pas être inactif : #{res}"
    # Ici, on fait différemment que pour les autres méthodes : on part du
    # principe qu'un icarien marqué inactif doit vraiment l'être, sauf s'il
    # ne possède aucun module, c'est-à-dire :
    # 1) S'il possède des modules
    #   1.1) ne pas avoir d'icmodule_id défini
    #   1.2) ne pas avoir de module non achevé.
    # 2) S'il ne possède pas de modules, on le marque détruit
    # On le corrige en conséquence.

    # Cas 2)
    if duser[:modules].empty?
      opts = duser[:options]
      opts[3] = "1"
      duser[:options] = opts
      if noop?
        Logger << "[NOOP] #{duser[:ref]} serait marqué détruit"
      else
        Report << "#{duser[:ref]} marqué détruit."
      end
      set_option_status_user(duser, 5)
      return
    end

    # Cas 1.1)
    if not duser[:icmodule_id].nil?
      if noop?
        Logger << "On doit mettre son icmodule_id à NIL"
      else
        db_exec("UPDATE users SET icmodule_id = ? WHERE id = ?", [nil, duser[:id]])
        Report << "Son icmodule_id a été mis à NIL"
      end
    end

    # Cas 1.2)
    duser[:modules].each do |mid, dmod|
      if dmod[:ended_at].nil?
        # <= le module n'est pas marqué fini
        # => il faut lui trouver une date de fin
        older_time = 0
        dmod[:etapes].each do |eid, detape|
          [:ended_at, :started_at].each do |key|
            older_time = detape[key] if not(detape[key].nil?) && detape[key] > older_time
          end
          detape[:documents].each do |did, ddoc|
            [:time_original, :time_comments].each do |key|
              older_time = ddoc[key] + 1000 if not(ddoc[key].nil?) && ddoc[key] > older_time
            end
          end
        end
        older_time = dmod[:started_at] + 4000 if older_time == 0
        corrections = {ended_at: older_time}
        # On s'assure aussi que toutes ses pauses soient résolus
        unless dmod[:pauses].nil?
          fix_required = false
          pauses = JSON.parse(dmod[:pauses])
          pauses = pauses.collect do |dpause|
            if dpause['end'].nil?
              fix_required = true
              dpause['end'] = dpause['start'] + 10.days
            end
            dpause
          end
          if fix_required
            corrections.merge!(pauses: pauses.to_json)
          end
        end
        if noop?
          Logger << "Corrections à faire sur le module ##{mid} : #{corrections.inspect}"
        else
          colums = corrections.keys.collect{|c| "#{c} = ?"}
          values = corrections.values << mid
          db_exec("UPDATE icmodules SET #{colums} WHERE id = ?", values)
          Report << "Information du module ##{mid} corrigées : #{corrections.inspect}"
        end
      else
        # <= le module est marqué fini => rien à faire
      end
    end
  end #/ should_be_inactif

  def should_be_destroyed(duser)
    res = can_be_status_detruit(duser)
    return true if res === true
    Logger << "#{duser[:ref]} ne peut pas être un icarien détruit : #{res}"
    search_and_set_good_status(duser, 5)
  end #/ should_be_destroyed


  def should_be_recu(duser)
    res = can_be_status_recu(duser)
    return true if res === true
    Logger << "#{duser[:ref]} ne peut pas être un icarien tout juste reçu : #{res}"
    search_and_set_good_status(duser, 6)
  end #/ should_be_recu


  def should_be_en_pause(duser)
    res = can_be_status_en_pause(duser)
    return true if res === true
    Logger << "#{duser[:ref]} ne peut pas être un icarien en pause : #{res}"
    search_and_set_good_status(duser, 8)
  end #/ should_be_en_pause


  # Quand le statut n'est pas bon, on appelle cette méthode pour trouver
  # le bon statut
  # +bad_status+  Le mauvais status, permet de ne pas avoir à le tester pour
  #               voir si c'est le bon.
  def search_and_set_good_status(duser, bad_status = nil)
    new_status =
      if bad_status != 2 && can_be_status_actif(duser) === true
        2
      elsif bad_status != 3 && can_be_status_candidat(duser) === true
        3
      elsif bad_status != 4 && can_be_status_inactif(duser) === true
        4
      elsif bad_status != 5 && can_be_status_detruit(duser) === true
        5
      elsif bad_status != 6 && can_be_status_recu(duser) === true
        6
      elsif bad_status != 8 && can_be_status_en_pause(duser) === true
        8
      else
        nil
      end
    # On l'applique s'il est défini
    if new_status.nil?
      Logger << "# Impossible de trouver un nouveau statut à appliquer pour #{duser[:ref]}…"
    else
      set_option_status_user(duser, new_status)
    end
  end #/ search_and_set_good_status


  def can_be_status_actif(duser)
    if duser[:modules].count == 0
      return "l'icarien ne possède pas de modules"
    elsif duser[:icmodule_id].nil?
      return "l'icarien ne définit pas de module courant (:icmodule_id)"
    else
      dmodule = duser[:modules][duser[:icmodule_id]]
      if not dmodule[:ended_at].nil?
        return "le module soi-disant courant est marqué fini"
      end
    end
    return true
  end #/ can_be_status_actif


  def can_be_status_candidat(duser)
    if duser[:modules].count > 0
      return "il n'aurait pas déjà des modules d'apprentissage"
    end
    return true
  end #/ can_be_status_candidat

  # Retour TRUE si +duser+ est bien un inactif, sinon la raison qui
  # l'empêche de l'être.
  def can_be_status_inactif(duser)
    if duser[:modules].count == 0
      return "il devrait posséder au moins un module d'apprentissage"
    elsif not duser[:icmodule_id].nil?
      # TODO Ici, il faudrait la possibilité de checker s'il y a vraiment
      # un module courant et de réparer en mettant :icmodule_id à nil
      return "il ne devrait pas définir un module courant (:icmodule_id)"
    else
      duser[:modules].each do |mid, dmod|
        if dmod[:ended_at].nil?
          dmod = dmod.dup.delete(:etapes)
          return "il possède un module non terminé : #{dmod.inspect}"
        end
      end
    end
    return true
  end #/ can_be_status_inactif

  def can_be_status_detruit(duser)
    if duser[:options][3] != "1"
      return "le bit 3 (4e) de ses options devrait être à 1, il vaut #{duser[:options][3]}"
    elsif duser[:modules].count > 0
      return "il ne devrait plus posséder de modules d'apprentissage…"
    end
    return true
  end #/ can_be_status_detruit

  def can_be_status_recu(duser)
    if duser[:modules].count == 0
      return "devrait posséder un module d'apprentissage…"
    elsif duser[:modules].count > 1
      return "devrait ne posséder qu'un seul module d'apprentissage…"
    elsif not nil == duser[:modules].values.first[:started_at]
      return "son module d'apprentissage ne devrait pas être démarré…"
    end
    return true
  end #/ can_be_status_recu


  def can_be_status_en_pause(duser)
    if duser[:modules].count == 0
      return "devrait posséder au moins un module d'apprentissage"
    elsif duser[:icmodule_id].nil?
      return "devrait définir son module courant (:icmodule_id)"
    else
      dmodule = duser[:modules][duser[:icmodule_id]]
      if not nil == dmodule[:ended_at]
        return "son module d'apprentissage courant (##{dmodule[:id]}) ne devrait pas être fini"
      elsif dmodule[:pauses].nil?
        return "son module d'apprentissage (##{dmodule[:id]}) ne possède aucune pause"
      else
        if JSON.parse(dmodule[:pauses]).last["end"].nil?
          return true
        else
          return "la dernière pause du module est terminée"
        end
      end
    end
  end #/ can_be_status_en_pause






  def set_option_status_user(duser, new_status)
    opts = duser[:options]
    opts[16] = new_status.to_s
    duser[:reparations].merge!(options: opts)
    if noop?
      Logger << "[NOOP] le status de #{duser[:ref]} serait mis à #{new_status}"
    else
      values = duser[:reparations].values << duser[:id]
      colums = duser[:reparations].keys.collect{|k| "#{k} = ?"}.join(', ')
      db_exec("UPDATE users SET #{colums} WHERE id = ?", values)
      Report << "Status de #{duser[:ref]} mis à #{new_status}"
    end
  end #/ set_option_status_user

  def all_data_users
    @all_data_users ||= begin
      @unknow_users_id  = []
      @unknow_module_id = []
      h = {}
      db_exec("SELECT * FROM users WHERE id > 9").each do |du|
        h.merge!(du[:id] => du.merge(modules: {}))
      end
      h = add_data_modules_to(h)
      h = add_data_etapes_to(h)
      h = add_data_documents_to(h)
      h
    end
  end #/ all_data_users

  # Méthode qui retourne une table contenant toutes les informations concernant
  # l'user au niveau de ses modules, ses étapes et ses documents
  def add_data_modules_to(h)
    db_exec(REQUEST_USER_DATA_MODULES).each do |dm|
      next if dm[:user_id] < 10
      # Logger << "-- data module : #{dm.inspect}"
      h[dm[:user_id]][:modules].merge!(dm[:id] => dm.merge(etapes: {}))
    end
    return h
  end #/ full_data_users

  def add_data_etapes_to(h)
    db_exec(REQUEST_USER_DATA_ETAPES).each do |de|
      next if de[:user_id] < 10
      # Logger << "-- data étape : #{de.inspect}"
      if h[de[:user_id]].nil?
        @unknow_users_id << de[:user_id]
      elsif h[de[:user_id]][:modules][de[:icmodule_id]].nil?
        @unknow_module_id << {user: h[de[:user_id]], module_id: de[:icmodule_id]}
      else
        h[de[:user_id]][:modules][de[:icmodule_id]][:etapes].merge!(de[:id] => de.merge(documents: {}))
      end
    end
    return h
  end #/ add_data_etapes_to

  def add_data_documents_to(h)
    db_exec(REQUEST_USER_DATA_DOCUMENTS).each do |dd|
      next if dd[:user_id] < 10
      h[dd[:user_id]][:modules][dd[:module_id]][:etapes][dd[:icetape_id]][:documents].merge!(dd[:id] => dd)
    end
    return h
  end #/ add_data_documents_to


REQUEST_USER_DATA_MODULES = <<-SQL
SELECT
  id, user_id, started_at, ended_at, options, icetape_id
  FROM icmodules
SQL
REQUEST_USER_DATA_ETAPES = <<-SQL
SELECT
  id, user_id, icmodule_id, started_at, ended_at, status, options
  FROM icetapes
SQL
REQUEST_USER_DATA_DOCUMENTS = <<-SQL
SELECT
  d.id, d.user_id, d.icetape_id, d.time_original, d.time_comments,
  m.id AS module_id
  FROM icdocuments d
  INNER JOIN icetapes e  ON d.icetape_id = e.id
  INNER JOIN icmodules m ON e.icmodule_id = m.id
SQL

REQUEST_USER_FULL_DATA = <<-SQL
SELECT u.id,
  m.id AS module_id, m.started_at AS module_start, m.ended_at AS module_end, m.options AS module_options,
  d.id AS doc_id, d.time_original AS doc_time_original, d.time_comments AS doc_time_comments, d.options AS doc_options
  FROM users u
  INNER JOIN icmodules m ON m.user_id = u.id
  LEFT JOIN icdocuments d ON d.user_id = u.id
  LEFT JOIN icetapes e ON e.user_id = u.id
SQL
end #/Cronjob
