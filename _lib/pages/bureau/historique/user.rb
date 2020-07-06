# encoding: UTF-8
require_modules(['icmodules'])
class User

  # Méthode qui relève tout l'historique
  def historique
    @historique ||= begin
      histo = []

      # Inscription et fin
      histo << LineHisto.new(created_at, '🦋 Inscription à l’atelier Icare'.freeze, 0)
      if date_sortie
        histo << LineHisto.new(date_sortie 'Fin du travail à l’atelier'.freeze, 0)
      else
        histo << LineHisto.new(Time.now.to_i, 'Officiellement, toujours en activité.'.freeze, 1)
      end

      # Les modules
      IcModule.collect(user_id: id) do |icmodule|
        histo << LineHisto.new(icmodule.started_at, "⏱️ Démarrage du module “#{icmodule.absmodule.name}”", 0)
        if icmodule.ended_at
          histo << LineHisto.new(icmodule.ended_at, "⏰ Fin du module “#{icmodule.absmodule.name}”", 1)
        end
        if icmodule.pauses
          JSON.parse(icmodule.pauses).each do |dpause|
            dpause = JSON.parse(dpause) if dpause.is_a?(String) # ça arrive…
            histo << LineHisto.new(dpause['start'], "⏲️ Mise en pause du module “#{icmodule.absmodule.name}”".freeze, 1) if dpause['start']
            histo << LineHisto.new(dpause['end'], "⏲️ Reprise du module “#{icmodule.absmodule.name}”".freeze, 1) unless dpause['end'].nil?
          end
        end
      end

      # Les icetapes
      IcEtape.collect(user_id: id) do |icetape|
        histo << LineHisto.new(icetape.started_at + 100, "🔰 Démarrage de l’<b>étape #{icetape.numero}</b> “#{icetape.titre}”", 2)
        unless icetape.ended_at.nil?
          histo << LineHisto.new(icetape.ended_at, "⛳ Fin de l'<b>étape #{icetape.numero}</b> “#{icetape.titre}”", 2)
        end
      end

      # Les icdocuments
      IcDocument.collect(user_id: id) do |icdocument|
        histo << LineHisto.new(icdocument.time_original, "📋 Envoi du document “#{icdocument.name}”", 4)
        unless icdocument.time_comments.nil?
          histo << LineHisto.new(icdocument.time_comments + 100, "📝 Réception des commentaires sur “#{icdocument.name}”.", 4)
        end
      end

      # Les lectures QDD
      db_exec("SELECT icdocument_id, created_at FROM `lectures_qdd` WHERE user_id = #{id}".freeze).each do |dlecture|
        icdoc = IcDocument.get(dlecture[:icdocument_id])
        next if id == icdoc.owner.id
        histo << LineHisto.new(dlecture[:created_at], "📒 QdD : chargement et lecture du document ##{dlecture[:icdocument_id]} de #{icdoc.owner.pseudo}".freeze, 1)
      end

      # Les discussions initiés
      # TODO

      histo.sort_by { |linehisto| linehisto.time }
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

LineHisto = Struct.new(:time, :description, :level, :note) do
def out(last_date)
  <<-HTML.strip.freeze
<div class="line-histo">
  #{div_day unless last_date == date_jour}
  <div class="description step-format1" style="margin-left:#{(level||1)*16}px;">#{description}</div>
</div>
  HTML
end #/ out
def div_day
  <<-HTML.strip.freeze
<div class="day-div">
  <span class="day">#{date_jour}</span>
</div>
  HTML
end #/ div_day

def date_jour
  @date_jour ||= formate_date(time, {jour:true})
end #/ date_jour
end
