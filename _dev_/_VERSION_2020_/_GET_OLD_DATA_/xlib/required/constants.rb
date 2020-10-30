# encoding: UTF-8
# frozen_string_literal: true

GOD_FOLDER          = THISFOLDER
GOD_LIB_FOLDER      = File.join(GOD_FOLDER,'xlib')
GOD_DATA_FOLDER     = File.join(GOD_LIB_FOLDER,'data')
GOD_SCRIPTS_FOLDER  = File.join(GOD_LIB_FOLDER,'db_scripts')
# Dossiers Icare
ALWAYSDATA_FOLDER       = '/Users/philippeperret/Sites/AlwaysData'
ICARE_FOLDER            = File.join(ALWAYSDATA_FOLDER, 'Icare_2020')
FOLDER_GOODS_SQL        = File.join(ALWAYSDATA_FOLDER,'xbackups','Goods_for_2020')
FOLDER_CURRENT_ONLINE   = File.join(ALWAYSDATA_FOLDER,'xbackups','Version_current_online')

SSH_ICARE_SERVER = "icare@ssh-icare.alwaysdata.net"

TABU = "     "

# Liste des tables qui contiennent des `user_id`
TABLES_WITH_USER_ID = [
  ['actualites'],
  ['connexions', 'id'],
  ['icdocuments'],
  ['icetapes'],
  ['icmodules'],
  ['lectures_qdd'],
  ['minifaq'],
  ['paiements'],
  ['temoignages'],
  ['tickets'],
  ['watchers']
]
