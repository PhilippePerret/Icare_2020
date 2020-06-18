# encoding: UTF-8
=begin
  Module pour la gestion des témoignages

  Noter que ça ne concerne pas seulement cette section, ça concerne
  aussi la dernière étape de chaque module (990).

=end
class Temoignage < ContainerClass
class << self
  def table
    @table ||= 'temoignages'.freeze
  end #/ table
  def form
    deserb('form', self.new({}))
  end #/ form
end # /<< self

def plebiscite
  save(plebiscites: plebiscites + 1)
end #/ plebiscite

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

end #/Temoignage < ContainerClass
