# encoding: UTF-8
# frozen_string_literal: true
class TConcurrent
class << self

  def reset
    @allconcurrents = nil
  end #/ reset

  # Retourne une instance TConcurrent choisie au hasard
  def get_random
    all[rand(all.count)]
  end #/ get_a_concurrent

  def all
    @allconcurrents ||= begin
      db_exec("SELECT * FROM #{DBTABLE_CONCURRENTS}").collect { |dc| new(dc) }
    end
  end #/ all

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :patronyme, :mail, :concurrent_id, :options, :created_at, :updated_at
def initialize(data)
  data.each{|k,v|instance_variable_set("@#{k}",v)}
end #/ initialize

alias :pseudo :patronyme
alias :id :concurrent_id

def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER, self.id)
end #/ folder
end #/TConcurrent
