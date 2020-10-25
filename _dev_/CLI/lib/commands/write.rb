# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthode pour rédiger les textes (manuels principalement)
=end

MESSAGES.merge!({
  question_write: 'Quel fichier voulez-vous écrire ?'
})

DATA_WHAT_WRITE = [
  {name:'Manuel Atelier', value: :manuel},
  {name:'Manuel Concours', value: :concours},
]

SSH_SERVER = 'icare@ssh-icare.alwaysdata.net'


class IcareCLI
class << self
  def proceed_write
    what = params[1]
    unless self.respond_to?("write_#{what}".to_sym)
      what = Q.select(MESSAGES[:question_write], required: true) do |q|
        q.choices DATA_WHAT_WRITE.collect{|d| d.merge(name:"#{d[:name]} [#{d[:value]}]")}
        q.per_page DATA_WHAT_WRITE.count
      end
    end
    return if what == :cancel
    self.send("write_#{what}".to_sym)
  end #/ proceed_write

  # Pour ouvrir la version modifiable du mode d'emploi
  def write_manuel
    `open -a Typora "#{File.join(DEV_FOLDER,'Manuel','Manuel_developper.md')}"`
  end #/ write_manuel

  def write_concours
    `open -a Typora "#{File.join(FOLD_REL_PAGES,'concours','_Manuel_Concours_.md')}"`
  end #/ write_concours

end # /<< self
end #/IcareCLI
