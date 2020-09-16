# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement des watchers
=end
WATCHER_COLS = [:id, :wtype, :user_id, :objet_id, :triggered_at, :params, :vu_admin, :vu_user, :created_at, :updated_at]

TableGetter.import('watchers')

values = []
db_exec("SELECT * FROM `current_watchers`").each do |dwatcher|
  keychecked = "#{dwatcher[:objet]}::#{dwatcher[:processus]}"
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
  request = <<-SQL
START TRANSACTION;
TRUNCATE `watchers`;
ALTER TABLE `watchers`
  MODIFY COLUMN `triggered_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
  SQL
  db_exec(request)

  interro = Array.new(WATCHER_COLS.count,'?').join(VG)
  request = "INSERT INTO `watchers` (#{WATCHER_COLS.join(VG)}) VALUES (#{interro})"
  db_exec(request, values)
end

TableGetter.export('watchers')
