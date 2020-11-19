# encoding: UTF-8
# frozen_string_literal: true
require_relative './TICEtape'
class TICModule
  attr_reader :data
  attr_reader :id
  attr_reader :absmodule_id, :user_id, :started_at
  attr_reader :ended_at, :options
  attr_reader :created_at, :updated_at

  def initialize(data)
    @data = data
    data.each {|k,v| instance_variable_set("@#{k}", v)}
  end #/ initialize

  # Pour définir une ou des données
  def set(data)
    db_compose_update('icmodules', id, data)
  end #/ set

end #/TICModule
