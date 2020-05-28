# encoding: UTF-8
class IcModule < ContainerClass
class << self

  def table
    @table ||= 'icmodules'
  end #/ table

end # /<< self

# ---------------------------------------------------------------------
#
#     INSTANCE
#
# ---------------------------------------------------------------------

def absmodule
  @absmodule ||= AbsModule.get(data[:abs_module_id])
end #/ absmodule

end #/IcModule
