# encoding: UTF-8
=begin
  Méthodes utilitaires pour la base de données
=end

# On charge le module qui permet de gérer la DB
require './_lib/required/__first/db.rb'
require './_lib/data/secret/mysql.rb'
MyDB.DBNAME = 'icare_test'

def vide_db
  vide_users
  vide_icmodules
  vide_icetapes
  vide_documents
  vide_watchers
  vide_tickets
  vide_actualites
  vide_paiements
  vide_frigos
end #/ vide_db

def vide_users
  vide_table('users', 10)
end #/ vide_users
def vide_icmodules
  vide_table('icmodules')
end #/ vide_icmodules
def vide_icetapes
  vide_table('icetapes')
end #/ vide_icmodules
def vide_documents
  vide_table('icdocuments')
end #/ vide_documents
def vide_watchers
  vide_table('watchers')
end #/ vide_watchers
def vide_tickets
  vide_table('tickets')
end #/ vide_tickets
def vide_actualites
  vide_table('actualites')
end #/ vide_actualites
def vide_paiements
  vide_table('paiements')
end #/ vide_paiements
def vide_frigos
  vide_table('frigo_users')
  vide_table('frigo_discussions')
  vide_table('frigo_messages')
end #/ vide_paiements

def vide_table dbtable, from_id = nil, reset_auto_incremente = true
  request = "DELETE FROM icare_test.#{dbtable}"
  request << " WHERE id >= #{from_id}" unless from_id.nil?
  db_exec(request)
  if MyDB.error
    raise "Une erreur SQL est survenue : #{MyDB.error.inspect}"
  end
  if reset_auto_incremente
    request = "ALTER TABLE icare_test.#{dbtable} AUTO_INCREMENT = #{from_id||0}"
    db_exec(request)
  end
end #/ vide_table
