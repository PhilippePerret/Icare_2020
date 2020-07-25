# encoding: UTF-8
=begin
  Conformisation des watchers
=end
puts "Conformisation des watchers…".bleu

# watchers
#       Gros travail de transformation car la structure change et les données
#       changent. En sachant que le gros des changements tient dans le watcher
#       permettant d'attribuer une note à un document QDD téléchargé.
#       - Relever en DISTINCT les objets et les processus pour voir tous ceux
#         qui sont utilisés
#       - Faire le script de transformation (old data -> new data)
#         Créer la nouvelle table.
#       Script complet:
#         - récupérer les données distantes (en changeant le nom)
#         - relever les objet(s) et processus différent
#         - faire les tables de correspondance
#         - alimenter la table watchers local
#         - charger la table watchers en distant
values = []
WATCHER_COLS = [:id, :wtype, :user_id, :objet_id, :triggered_at, :params, :vu_admin, :vu_user, :created_at, :updated_at]
db_exec("SELECT * FROM `current_watchers`".freeze).each do |dwatcher|
  keychecked = "#{dwatcher[:objet]}::#{dwatcher[:processus]}".freeze
  datawatcher = TABLECORS_WATCHERS[keychecked]
  if datawatcher.key?(:error)
    puts datawatcher[:error].rouge
    ERRORS_TRANS_DATA << datawatcher[:error]
    next
  end
  dwatcher.merge!({
    wtype:    datawatcher[:wtype],
    vu_admin: datawatcher[:vu_admin],
    vu_user:  datawatcher[:vu_user]
  })
  values << WATCHER_COLS.collect { |prop| dwatcher[prop] }
end
unless values.empty?
  db_exec('TRUNCATE `watchers`')
  interro = Array.new(WATCHER_COLS.count,'?').join(VG)
  request = "INSERT INTO `watchers` (#{WATCHER_COLS.join(VG)}) VALUES (#{interro})".freeze
  db_exec(request, values)
  `mysqldump -u root icare watchers > "#{FOLDER_GOODS_SQL}/watchers.sql"`
  puts "🗄️ Dumping des watchers opéré avec succès".vert
end
db_exec("DROP TABLE `current_watchers`".freeze)
