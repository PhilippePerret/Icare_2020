# encoding: UTF-8
class TICEtape
  attr_reader :data
  attr_reader :absetape_id, :user_id, :icmodule_id, :started_at, :expected_end
  attr_reader :expected_comments, :ended_at, :status, :options, :travail_propre
  attr_reader :updated_at
  
  def initialize(data)
    @data = data
    data.each {|k,v| instance_variable_set("@#{k}", v)}
  end #/ initialize

end #/TICEtape
