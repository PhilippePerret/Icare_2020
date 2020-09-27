# encoding: UTF-8
# frozen_string_literal: true
class AbsEtape < ContainerClass
class << self
  def exists?(aid)
    get(aid) != nil
  end #/ exists?

  def table
    @table ||= 'absetapes'
  end #/ table
end # /<< self
end #/AbsEtape < ContainerClass
