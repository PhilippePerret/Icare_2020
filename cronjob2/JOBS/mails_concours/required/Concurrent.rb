# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la classe Concurrent pour le cronjob
=end
require_site('./_lib/_pages_/concours/xrequired/Concurrent')
require_site('./_lib/_pages_/concours/xmodules/synopsis/Synopsis')
require_site('./_lib/_pages_/concours/xrequired/CFile')

class Concurrent
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  # OUT   Liste des concurrents {Concurrent} qui veulent être contactés
  def contactables(options = nil)
    @contactables ||= begin
      db_exec(REQUEST_CONTACTABLES, [Concours.current.annee]).collect do |dc|
        new(dc)
      end
    end
  end #/ contactables

  # OUT   Nombre total de concurrents pour cette session
  def count
    @count ||= db_count(DBTBL_CONCURS_PER_CONCOURS, {annee: Concours.current.annee})
  end #/ count

  # OUT le Nombre de vrais concurrents pour la session courante du concours
  def count_real
    @count_real ||= begin
      request = "SELECT specs FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ? AND SUBSTRING(specs,1,2) = ?"
      db_exec(request, [Concours.current.annee, '11']).count
    end
  end #/ count_real

  def send_mail_info_hebdomadaire
    require_module('mail')
    Logger << "Nombre de concurrents à contacter : #{contactables.count}"
    contactables.each do |concurrent|
      concurrent.send_mail_info
    end
  end #/ send_mail_info_hebdomadaire

  def info_hebdo_mail_path
    @info_hebdo_mail_path ||= File.join(APPFOLDER,'_lib','_pages_','concours','xmodules','mails',"phase#{Concours.current.phase}",'mail_infos_hebdomadaire.erb')
  end #/ info_hebdo_mail_path
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
def send_mail_info
  MailSender.send(to:mail, file:self.class.info_hebdo_mail_path, bind:self)
  Logger << "Mail d'information concours à #{ref}."
end #/ send_mail_info

def synopsis
  @synopsis ||= Synopsis.new(id, Concours.current.annee)
end #/ synopsis

# DÉFINI DANS concours/xrequired/Concurrent
# SINON boucle sans fin
# def cfile
#   @cfile ||= synopsis.cfile
# end #/ cfile



# ---------------------------------------------------------------------
#
#   CONSTANTES
#
# ---------------------------------------------------------------------

REQUEST_CONTACTABLES = <<-SQL
SELECT
  cc.*, cpc.annee, cpc.titre, cpc.auteurs, cpc.specs
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours cpc ON cc.concurrent_id = cpc.concurrent_id
  WHERE cpc.annee = ? AND SUBSTRING(cc.options,1,1) = 1
SQL
end #/Concurrent
