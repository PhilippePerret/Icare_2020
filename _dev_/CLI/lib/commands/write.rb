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
  {name:'Manuel Cronjob', value: :cronjob},
  {name:'Renoncer', value: nil}
]

SSH_SERVER = 'icare@ssh-icare.alwaysdata.net'


class IcareCLI
class << self
  def proceed_write
    what = params[1]
    unless self.respond_to?("write_#{what}".to_sym)
      what = Q.select(MESSAGES[:question_write], required: true) do |q|
        q.choices formate_choices('write', DATA_WHAT_WRITE)
        q.per_page DATA_WHAT_WRITE.count
      end
    end
    return if what.nil? || what == :cancel
    self.send("write_#{what}".to_sym)
  end #/ proceed_write

  # Pour ouvrir la version modifiable du mode d'emploi
  def write_manuel
    `open -a Typora "#{File.join(DEV_FOLDER,'Manuel','Manuel_developper.md')}"`
  end #/ write_manuel

  def write_concours
    `open -a Typora "#{File.join(FOLD_REL_PAGES,'concours','_Manuel_Concours_.md')}"`
  end #/ write_concours

  def write_cronjob
    `open -a Typora "#{File.join(APP_FOLDER,'cronjob2','_Manuel_Cronjob_.md')}"`
  end #/ write_cronjob

end # /<< self
end #/IcareCLI
