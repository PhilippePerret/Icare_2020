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
  vide_temoignages
  vide_frigos
  vide_lectures_qdd
  vide_minifaq
  vide_connexions
  vide_unique_usage_ids
  vide_validation_pages
end #/ vide_db

def vide_validation_pages
  vide_table('validations_pages')
end #/ vide_validation_pages

def vide_connexions
  vide_table('connexions')
end #/ vide_connexions

def vide_unique_usage_ids
  vide_table('unique_usage_ids')
end #/ vide_unique_usage_ids

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
def vide_temoignages
  vide_table('temoignages')
end #/ vide_temoignages
def vide_paiements
  vide_table('paiements')
end #/ vide_paiements
def vide_frigos
  vide_table('frigo_users')
  vide_table('frigo_discussions')
  vide_table('frigo_messages')
end #/ vide_paiements

def vide_lectures_qdd
  vide_table('lectures_qdd')
end #/ vide_lectures_qdd

def vide_minifaq
  vide_table('minifaq')
end #/ vide_minifaq

def vide_table dbtable, from_id = nil, reset_auto_incremente = true
  request = "DELETE FROM icare_test.#{dbtable}"
  request << " WHERE id >= #{from_id}" unless from_id.nil?
  db_exec(request)
  if reset_auto_incremente
    request = "ALTER TABLE icare_test.#{dbtable} AUTO_INCREMENT = #{from_id||0}"
    db_exec(request)
  end
end #/ vide_table
