# encoding: UTF-8
=begin
  Class CJActualites
  ------------------
  Gestion des actualités
=end

# Pour l'envoi des mails
require_mail

class CJActualites
class << self

  def traite_mail_quotidien
    puts "* Production et envoi du mail quotidien"
    if actualites_veille.count == 0
      return rapport("Pas d'actualité de la veille => Pas de mail quotidien d'actualité")
    else
      rapport("Nombre d'actualités pour la veille : #{actualites_veille.count}")
    end
    # Les données pour le mail
    datamail = {subject:"Activité du #{Time.veille.to_s(heure:false)}".freeze, message: nil}
    # puts "datamail quotidien : #{datamail.inspect}"

    # Envoyer le mail à l'administrateur
    datamail.merge!({to: PHIL[:mail], message: mail_quotidien  % {pseudo: 'Phil'}})
    Mail.send(datamail)

    nombre_envois_quotidien = 0
    CJUser.each do |cuser|
      next if cuser.destroyed?
      next unless cuser.mail_quotidien?
      datamail.merge!(to:cuser.mail, message:(mail_quotidien % {pseudo: cuser.pseudo}))
      Mail.send(datamail)
      nombre_envois_quotidien += 1
    end
    rapport("Nombre d'envois des actualités quotidiennes : #{nombre_envois_quotidien}")
  end #/ mail_quotidien

  def traite_mail_hebdomadaire
    rapport "* Production et envoi du mail hebdomadaire"
    if actualites_semaine.count == 0
      return rapport("Aucune actualité pour la semaine passée")
    else
      rapport("Nombre d'actualités pour la semaine passée : #{actualites_semaine.count}")
    end
    # Les données d'envoi
    datamail = {subject:'Activités de la semaine'.freeze, message: nil, to: nil}
    # puts "datamail hebdo : #{datamail.inspect}"

    # Il m'est toujours envoyé
    Mail.send(datamail.merge!(to:PHIL[:mail], message:mail_hebdo % {pseudo:'Phil'}))

    nombre_envois_hebdo = 0
    CJUser.each do |cuser|
      next if cuser.destroyed?
      next unless cuser.mail_hebdomadaire?
      datamail.merge!({
        to:cuser.mail, message:(mail_hebdo % {pseudo:cuser.pseudo})
      })
      nombre_envois_hebdo += 1
    end
    rapport("Nombre d'envois du rapport d'activités hebdomadaire : #{nombre_envois_hebdo}")
  end #/ mail_hebdomadaire

  GABARIT_MAIL_QUOTIDIEN = <<-HTML.strip.freeze
<p>%{pseudo},</p>
<p>Veuillez trouver ci-joint la liste des activités du %{date}.</p>
%{actualites}
<p>Bien à vous,</p>
<p>🤖 Le bot de l’atelier</p>
  HTML

GABARIT_MAIL_HEBDOMADAIRE = <<-HTML.strip.freeze
<p>Veuillez trouver ci-joint la liste des activités de la semaine.</p>
%{actualites}
<p>Bien à vous,</p>
<p>🤖 Le bot de l’atelier</p>
  HTML

  def mail_quotidien; @mail_quotidien ||= compose_mail_quotidien end
  def compose_mail_quotidien
    m = []
    owners_veille.each do |uid, cuser|
      m << cuser.actualites_formated(:veille)
    end
    GABARIT_MAIL_QUOTIDIEN % {actualites: m.join, pseudo:'%{pseudo}', date: Time.veille.to_s(jour:true, heure:false)}
  end #/ compose_mail_quotidien

  def mail_hebdo; @mail_hebdo ||= compose_mail_hebdo end
  def compose_mail_hebdo
    m = []
    owners_hebdo.each do |uid, cuser|
      m << cuser.actualites_formated(:hebdo)
    end
    GABARIT_MAIL_HEBDOMADAIRE % {actualites: m.join, pseudo:'%{pseudo}'}
  end #/ compose_mail_hebdo

  # Tous les users qui possèdent des actualités de la veille
  def owners_veille
    @owners_veille ||= {}
  end #/ owners_veille

  def add_owners_veille(owner)
    return if owners_veille.key?(owner.id)
    owners_veille.merge!(owner.id => owner)
  end #/ add_owners_veille

  # Tous les users qui possèdent des actualités de la semaine passée
  def owners_hebdo
    @owners_hebdo ||= {}
  end #/ owners_hebdo
  def add_owners_hebdo(owner)
    return if owners_hebdo.key?(owner.id)
    owners_hebdo.merge!(owner.id => owner)
  end #/ add_owners_hebdo

  # Retourne les actualités de la veille
  def actualites_veille
    @actualites_veille ||= begin
      request = <<-SQL.strip.freeze
  SELECT id, user_id, message, type, created_at
    FROM actualites
    WHERE created_at > "#{Time.veille.to_i}"
    ORDER BY user_id
      SQL
      db_exec(request).collect { |dactu| new(dactu, :veille) }
    end
  end #/ actualites_veille

  def actualites_semaine
    @actualites_semaine ||= begin
      from_time = NOW_S - 7.days
      request = <<-SQL.strip.freeze
  SELECT user_id, message, type, created_at
    FROM actualites
    WHERE created_at > "#{from_time}"
    ORDER BY user_id
      SQL
      db_exec(request).collect { |dactu| new(dactu, :hebdo) }
    end
  end #/ actualites_semaine


  # Retourne

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :id, :user_id, :type, :message, :created_at
def initialize data, ttype # ttype = :veille ou :hebdo
  data.each { |k,v| instance_variable_set("@#{k}",v) }
  # On ajoute l'actualité à l'user
  @ttype = ttype
  owner.send("add_actualite_#{ttype}".to_sym, self)
  self.class.send("add_owners_#{ttype}".to_sym, owner)
  # On ajoute ce propriétaire à la liste des propriétaires qui ont des
  # actulités
end #/ initialize

# La table de données qui sera utilisée pour composer les lignes des
# mails d'actualité.
def line_data
  @line_data ||= {message:message, date:Time.at(created_at.to_i).to_s(simple:true)}
end #/ line_data

def owner
  @owner ||= CJUser.get(user_id)
end #/ owner
end #/CJActualites
