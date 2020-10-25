# encoding: UTF-8
# frozen_string_literal: true
require 'fileutils'

DESTROY_CONCOURS_REQUEST = <<-SQL
START TRANSACTION;
DELETE FROM #{DBTBL_CONCURRENTS} WHERE concurrent_id = "%{id}";
DELETE FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = "%{id}";
COMMIT
SQL

class Concurrent
  # *** main ***
  # Pour détruire le concurrent
  def destroy
    check_confirmation || return
    destroy_folder
    destroy_in_db
    destroy_in_session
    redirect_to_accueil
  end #/ destroy

  # Méthode qui vérifie que le numéro d'inscription fourni correspond
  # bien au numéro du visiteur courant
  def check_confirmation
    if param(:c_numero) == self.id
      return true
    else
      return erreur(ERRORS[:invalid_num_for_destroy])
    end
  end #/ check_confirmation

  def destroy_folder
    FileUtils.rm_rf(self.folder) if File.exists?(self.folder)
  end #/ destroy_folder

  def destroy_in_db
    db_exec(DESTROY_CONCOURS_REQUEST % {id: self.id})
  end #/ destroy_in_db

  def destroy_in_session
    session.delete('concours_user_id')
  end #/ destroy_in_session

  def redirect_to_accueil
    message(MESSAGES[:concours_confirm_destroyed])
    redirect_to('concours/accueil')
  end #/ redirect_to_accueil

end #/Concurrent
