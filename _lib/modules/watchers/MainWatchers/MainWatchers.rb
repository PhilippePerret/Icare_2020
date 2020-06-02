# encoding: UTF-8
=begin
  Extension de User pour les watchers
  Attention, les classes MainWatchers (AdminWatchers et UserWatchers) ne
  sont pas à confondre avec la classe Watcher d'un watcher.
=end
# ---------------------------------------------------------------------
#
#   class UserWatchers
#
# ---------------------------------------------------------------------
class MainWatchers
  attr_reader :owner
  def initialize owner
    log("-> initialize (#{owner.inspect})")
    @owner = owner
  end #/ initialize

  # Méthode qui ajoute un watcher pour l'icarien, de type
  # +wtype+ avec les données +data+
  def add wtype, data
    now = Time.now.to_i
    dwatcher = {
      wtype:      wtype.to_s, # par exemple 'commande_module'
      objet_id:   data[:objet_id],
      user_id:    owner.id,
      vu_admin:   user.admin?,
      vu_user:    !user.admin?,
      updated_at: now,
      created_at: now
    }
    # On procède à l'enregistrement dans la table
    valeurs = dwatcher.values
    columns = dwatcher.keys.join(VG)
    interro = Array.new(valeurs.count, '?').join(VG)
    request = "INSERT INTO watchers (#{columns}) VALUES (#{interro})"
    db_exec(request, valeurs)
    if MyDB.error
      log(MyDB.error)
      erreur("Une erreur est survenue… Consultez le journal de bord.")
    end
  end #/ add

  def count
    all.count
  end #/ count

  # Retourne la liste des watchers lus par l'user
  def read
    @read ||= begin
      filter_key = user.admin? ? :admin : :user
      all.select do |watcher|
        next unless watcher.vu_par?(filter_key)
        watcher
      end
    end
  end #/ read

  def unread
    log("-> unread (@unread = #{@unread.inspect})")
    @unread ||= begin
      filter_key = user.admin? ? :admin : :user
      log("filter_key: #{filter_key.inspect}")
      log("all: #{all.inspect}")
      ur = all.select do |watcher|
        log("watcher:#{watcher.inspect}")
        log("watcher.vu_par?(filter_key): #{watcher.vu_par?(filter_key).inspect}")
        next false if watcher.vu_par?(filter_key)
        watcher
      end
      log("Unread : #{ur} (key: #{filter_key.inspect})")
      ur
    end
  end #/ read

  # Nombre de watchers non vus
  def unread_count
    log("-> unread_count")
    @unread_count ||= unread.count
  end #/ unread_count

  def allmarkread
    prop = owner.admin? ? 'vu_admin'.freeze : 'vu_user'.freeze
    request = "UPDATE watchers SET #{prop} = TRUE WHERE #{prop} = FALSE"
    db_exec(request)
    message "Toutes vos notifications ont été marquées lues, #{owner.pseudo}.".freeze
  end #/ allmarkread

end #/MainWatchers

# ---------------------------------------------------------------------
#
#   Class pour l'administrateur
#
# ---------------------------------------------------------------------
class AdminWatchers < MainWatchers
  # Liste Array de tous les watchers
  def all
    @all ||= Watcher.get_all("user_id = #{owner.id}").values
    log("@all: #{@all.inspect}")
    @all
  end #/ all

end #/AdminWatchers

# ---------------------------------------------------------------------
#
#   Class pour un icarien
#
# ---------------------------------------------------------------------
class UserWatchers < MainWatchers
  # Liste Array de tous les watchers
  def all
    @all ||= Watcher.watchers_of(owner)
  end #/ all

end #/Watchers
