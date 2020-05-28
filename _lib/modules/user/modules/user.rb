# encoding: UTF-8
require_module('icmodules')
require_module('absmodules')
class User
  def icmodule
    @icmodule ||= IcModule.get(data[:icmodule_id])
  end #/ icmodule

  def absmodule
    @absmodule ||= icmodule.absmodule
  end #/ absmodule

  def icetape
    @icetape ||= IcEtape.get(icmodule.data[:icetape_id])
  end #/ icetape

  def absetape
    @absetape ||= icetape.absetape
  end #/ absetape
end #/User
