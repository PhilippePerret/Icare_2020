# encoding: UTF-8
require_module('icmodules')
require_module('absmodules')
class User
  def icmodule
    @icmodule ||= data[:icmodule_id] && IcModule.get(data[:icmodule_id])
  end #/ icmodule

  def absmodule
    @absmodule ||= icmodule && icmodule.absmodule
  end #/ absmodule

  def icetape
    @icetape ||= icmodule && IcEtape.get(icmodule.data[:icetape_id])
  end #/ icetape

  def absetape
    @absetape ||= icmodule && icetape.absetape
  end #/ absetape
end #/User
