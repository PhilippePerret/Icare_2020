# encoding: UTF-8
class Travail
  attr_reader :owner
  def initialize owner
    @owner = owner
  end

  def icmodule
    @icmodule ||= owner.icmodule
  end #/ icmodule
  def absmodule
    @absmodule ||= owner.absmodule
  end #/ absmodule
  def icetape
    @icetape ||= owner.icetape
  end #/ icetape
  def absetape
    @absetape ||= owner.absetape
  end #/ absetape
end #/Travail
