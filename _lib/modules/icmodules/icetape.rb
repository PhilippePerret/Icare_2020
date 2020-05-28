class IcEtape < ContainerClass
  class << self
    def table
      @table ||= 'icetapes'
    end #/ table
  end # /<< self


# ---------------------------------------------------------------------
#
#     INSTANCE
#
# ---------------------------------------------------------------------

def absetape
  @absetape ||= AbsEtape.get(data[:abs_etape_id])
end #/ absmodule


end #/IcEtape
