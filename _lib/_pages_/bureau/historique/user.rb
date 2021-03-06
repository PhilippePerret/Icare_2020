# encoding: UTF-8
# frozen_string_literal: true
require_modules(['icmodules'])
class User

  # Méthode qui relève tout l'historique
  def historique
    @historique ||= begin
      histo = []

      # Inscription et fin
      # ------------------
      # 23 09 2020 Ici il s'est produit une erreur avec le +created_at+ qui
      # n'était pas défini, comme si c'était un user avec des données raccourcies
      # ce qui normalement ne peut pas arriver quand on est dans cette partie.
      histo << LineHisto.new(created_at, (EMO_PAPILLON.texte+ISPACE+'Inscription à l’atelier Icare'), 0)
      if date_sortie
        histo << LineHisto.new(date_sortie 'Fin du travail à l’atelier', 0)
      else
        histo << LineHisto.new(Time.now, 'Officiellement, toujours en activité.', 1)
      end

      # Les modules
      IcModule.collect(user_id: id) do |icmodule|
        if icmodule.started_at.nil?
          # Un module à démarrer
          histo << LineHisto.new(icmodule.created_at, (EMO_SABLIER_T+ISPACE+"Module “#{icmodule.absmodule.name}” en attente de démarrage"), 0)
        else
          histo << LineHisto.new(icmodule.started_at, (EMO_CHRONOMETRE_T+ISPACE+"Démarrage du module “#{icmodule.absmodule.name}”"), 0)
        end
        if icmodule.ended_at
          histo << LineHisto.new(icmodule.ended_at, (EMO_REVEIL_ROUGE_T+ISPACE+"Fin du module “#{icmodule.absmodule.name}”"), 1)
        end

        if icmodule.pauses
          log("icmodule.pauses: #{icmodule.pauses.inspect}")
          JSON.parse(icmodule.pauses).each do |dpause|
            dpause = JSON.parse(dpause) if dpause.is_a?(String) # ça arrive…
            histo << LineHisto.new(dpause['start'], (EMO_MINUTEUR_T+ISPACE+"Mise en pause du module “#{icmodule.absmodule.name}”"), 1) if dpause['start']
            histo << LineHisto.new(dpause['end'], (EMO_MINUTEUR_T+ISPACE+"Reprise du module “#{icmodule.absmodule.name}”"), 1) unless dpause['end'].nil?
          end
        end
      end

      # Les icetapes
      IcEtape.collect(user_id: id) do |icetape|
        histo << LineHisto.new(icetape.started_at.to_i + 100, (EMO_BLASON_T+ISPACE+"Démarrage de l’<b>étape #{icetape.numero}</b> “#{icetape.titre}”"), 2)
        unless icetape.ended_at.nil?
          histo << LineHisto.new(icetape.ended_at, (EMO_DRAPEAU_GOLF_T+ISPACE+"Fin de l'<b>étape #{icetape.numero}</b> “#{icetape.titre}”"), 2)
        end
      end

      # Les icdocuments
      IcDocument.collect(user_id: id) do |icdocument|
        histo << LineHisto.new(icdocument.time_original, (EMO_PORTE_DOCUMENT_T+ISPACE+"Envoi du document “#{icdocument.name}”"), 4)
        unless icdocument.time_comments.nil?
          histo << LineHisto.new(icdocument.time_comments.to_i + 100, (EMO_DOCUMENT_CRAYON_T+ISPACE+"Réception des commentaires sur “#{icdocument.name}”."), 4)
        end
      end

      # Les lectures QDD
      db_exec("SELECT icdocument_id, created_at FROM `lectures_qdd` WHERE user_id = #{id}").each do |dlecture|
        icdoc = IcDocument.get(dlecture[:icdocument_id])
        next if id == icdoc.owner.id
        histo << LineHisto.new(dlecture[:created_at], (EMO_LIVRE_JAUNE_T+ISPACE+"QdD : chargement et lecture du document ##{dlecture[:icdocument_id]} de #{icdoc.owner.pseudo}"), 1)
      end

      # Les discussions initiés
      # discuss = db_exec(<<-SQL.strip)
      # SELECT fd.created_at
      # FROM frigo_discussions as fd
      # INNER JOIN users as u ON fd.user_id = u.id
      # WHERE fd.user_id = #{id}
      # SQL
      request = <<-SQL
SELECT
  fd.id         AS id,
  fd.titre      AS titre,
  uo.pseudo     AS owner_pseudo,
  uo.id         AS owner_id,
  fd.created_at AS create_time
FROM frigo_users AS fu
INNER JOIN frigo_discussions AS fd ON fu.discussion_id = fd.id
INNER JOIN users AS uo ON fd.user_id = uo.id
WHERE fu.user_id = #{id}
      SQL
      begin
        discuss = db_exec(request)
      rescue MyDBError => e
        raise e.message
      end
      # D'abord, on rassemble les informations dans la discussion
      hdiscuss = {}
      discuss.each do |ddis|
        # log("ddis: #{ddis.inspect}")
        hdiscuss.key?(ddis[:id]) || hdiscuss.merge!(ddis[:id] => {id: ddis[:id], created_at:ddis[:create_time], owner:{id:ddis[:owner_id], pseudo:ddis[:owner_pseudo]}, titre:ddis[:titre], participants:[]})
        request = <<-SQL
        SELECT
          u.pseudo,
          fu.created_at AS join_time
          FROM frigo_users AS fu
          INNER JOIN users AS u ON u.id = fu.user_id
          WHERE fu.discussion_id = #{ddis[:id]}
        SQL
        begin
          parts = db_exec(request)
        rescue MyDBError => e
          raise e
        end
        parts.each do |duser|
          hdiscuss[ddis[:id]][:participants] << {pseudo: duser[:pseudo], join_time:duser[:join_time]}
        end
      end
      # Maintenant, on a toutes les informations rassemblées dans
      # chaque discussion, on peut définir les évènements
      hdiscuss.each do |discuss_id, ddis|
        # log("ddis: #{ddis.inspect}")
        create_time = ddis[:created_at].to_i
        userisowner = ddis[:owner][:id] == user.id
        auteur_discussion = userisowner ? 'vous' : ddis[:owner][:pseudo]
        # L'évènement de création
        histo << LineHisto.new(create_time, (EMO_BULLE_EXCLAMATION_T+ISPACE+"Discussion “#{ddis[:titre]}” initiée par #{auteur_discussion} <span class='small'>(avec #{ddis[:participants].collect{|dp|dp[:pseudo] == user.pseudo ? 'vous' : dp[:pseudo]}.pretty_join})</span>"),0,'nooverflow')
        ddis[:participants].each do |dpart|
          next if dpart[:pseudo] == ddis[:owner][:pseudo]
          histo << LineHisto.new(dpart[:join_time], "#{EMO_BULLE_MESSAGE.texte}#{ISPACE}#{dpart[:pseudo] == user.pseudo ? 'Vous rejoignez' : "#{dpart[:pseudo]} rejoint"} la discussion “#{ddis[:titre]}” initiée par #{auteur_discussion}.", 1, 'nooverflow')
        end
      end

      # ---------------------------------------------------------------------
      #
      #   Toutes les informations sont rassemblées, on peut procéder au
      #   classement des évènements.
      #
      # ---------------------------------------------------------------------

      histo.sort_by { |linehisto| linehisto.time || begin
        # Une erreur : un temps non défini
        erreur("Le temps de #{linehisto.description} n'est pas défini")
        Time.now.to_i
      end }
    end
  end #/ historique

end #/User


# ---------------------------------------------------------------------
#
#   CLASS (STRUCTURE) LineHisto
#   ---------------------------
#   Pour les lignes d'historique
#
# ---------------------------------------------------------------------

LineHisto = Struct.new(:time_str, :description, :level, :css) do
# Le temps en entier (depuis que les temps sont enregistrés en string)
# Noter que parfois :time_str est un {Time}.
def time
  @time ||= time_str.to_i
end #/ time
def out(last_date)
  added_classes = css.nil? ? '': " #{css}"
  <<-HTML.strip
<div class="line-histo">
  #{div_day unless last_date == date_jour}
  <div class="step format1#{added_classes} level#{level||1}">#{description}</div>
</div>
  HTML
end #/ out
def div_day
  <<-HTML.strip
<div class="day-div">
  <span class="day">#{date_jour}</span>
</div>
  HTML
end #/ div_day

def date_jour
  @date_jour ||= formate_date(time, {jour:true})
end #/ date_jour
end
