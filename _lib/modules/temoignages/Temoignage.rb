# encoding: UTF-8
=begin
  Module pour la gestion des témoignages

  Noter que ça ne concerne pas seulement cette section, ça concerne
  aussi la dernière étape de chaque module (990).

=end
require_module('user/modules')
class Temoignage < ContainerClass
class << self
  def table
    @table ||= 'temoignages'.freeze
  end #/ table

  # Affichage du formulaire pour laisser un témoignage. On ne le met
  # que si l'user courant n'a pas déjà laissé un témoignage pour son
  # module courant (ou l'absence de module).
  def form
    if count(user_id: user.id, absmodule_id: user.has_module? ? user.absmodule.id : nil ) > 0
      ''
    else
      deserb('form', self.new({}))
    end
  end #/ form

  # Pour créer le témoignage
  def check_and_create
    icarien_required # barrière sécurité
    require_module('mail')
    dtem = {
      user_id: user.id,
      user_pseudo: user.pseudo,
      absmodule_id: user.actif? ? user.absmodule.id : nil,
      content: param(:temoignage_content)&.strip.nil_if_empty,
      confirmed: false
    }
    dtem[:content] || raise("Il faut écrire votre témoignage, voyons !".freeze)
    tem = create_with_data(dtem)
    message("Votre témoignage a été enregistré#{tem.f_id} ! Merci à vous !")
    # M'envoyer un mail pour m'informer du nouveau témoignage et pouvoir
    # le confirmer.
    Mail.send({from:user.mail, subjectf:'Témoignage à valider', message:deserb('mail_admin', tem)})
  rescue Exception => e
    log(e)
    erreur(e.message)
  end #/ check_and_create
end # /<< self

def plebiscite
  save(plebiscites: plebiscites + 1)
end #/ plebiscite

# Pour l'affichage des témoignages
def out
  <<-HTML
<div class="temoignage">
  <div class="right infos">
    <span class="pseudo">- #{user_pseudo}</span>,
    <span class="date">#{formate_date(created_at)} -</span>
  </div>
  #{Tag.div(text: content.strip.gsub(/\n/,'<br>'), class:'content')}
  <div class="right clear">
    <span style="margin-left:4em;font-size:1.11em;" class="fleft">#{user_pseudo.titleize}</span>
    <span>#{lien_plebiscite}</span>
  </div>
</div>
  HTML
end #/ out

def lien_plebiscite
  if user.guest?
    "👍 (#{plebiscites})"
  else
    Tag.lien(route:"#{route.to_s}?op=plebisciter&temid=#{id}", text:"+ 👍 (#{plebiscites})", class:'small')
  end
end #/ lien_plebiscite

# Retourne l'instance Ticket du ticket pour valider le témoignage directement
def ticket_validation
  require_module('ticket')
  Ticket.create(user_id:1, code:"require_module('temoignages');Temoignage.get(#{id}).validate".freeze)
end #/ ticket_validation

# Méthode appelée par le ticket pour valider le témoignage
def validate
  set(confirmed: true)
  message "Le témoignage ##{id} a été validé. <a href='overview/temoignages' class='small'>Voir les témoignages</a>.".freeze
end #/ validate

end #/Temoignage < ContainerClass
