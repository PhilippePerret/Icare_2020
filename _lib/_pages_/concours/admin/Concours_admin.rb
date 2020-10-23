# encoding: UTF-8
# frozen_string_literal: true
class Concours
  attr_reader :resultat
  def save(data)
    columns = data.keys.collect{|c|"#{c} = ?"}
    columns << "updated_at = ?"
    values  = data.values
    values << Time.now.to_i.to_s
    db_exec("UPDATE #{DBTBL_CONCOURS} SET #{columns.join(', ')} WHERE annee = #{annee}", values)
  end #/ save
end #/Concours
