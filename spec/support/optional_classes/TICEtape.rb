# encoding: UTF-8
# frozen_string_literal: true
class TICEtape
  attr_reader :data
  attr_reader :id
  attr_reader :absetape_id, :user_id, :icmodule_id, :started_at, :expected_end
  attr_reader :expected_comments, :ended_at, :status, :options, :travail_propre
  attr_reader :updated_at

  def initialize(data)
    dispatch(data)
  end #/ initialize

  def dispatch(data)
    @data = data
    data.each {|k,v| instance_variable_set("@#{k}", v)}
  end #/ dispatch

  # Pour définir une ou des données
  def set(data)
    db_compose_update('icetapes', id, data)
  end #/ set

  def reset
    dispatch(db_exec('SELECT * FROM icetapes WHERE id = ?',[id])[0])
  end #/ reset

end #/TICEtape
