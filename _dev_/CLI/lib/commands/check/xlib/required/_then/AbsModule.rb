# encoding: UTF-8
# frozen_string_literal: true
class AbsModule < ContainerClass
class << self
  def exists?(aid)
    get(aid) != nil
  end #/ exists?

  def table
    @table ||= 'absmodules'
  end #/ table
end # /<< self
end #/AbsModule < ContainerClass
