# encoding: UTF-8

RC = '
'.freeze
RC2 = (RC*2).freeze

BR = '<br/>'.freeze

VG = ', '.freeze # VG pour VirGule

PV = ';'.freeze # PV pour Point Virgule

SPACE = '&nbsp;'

RETOUR = '<span style="vertical-align:sub;">↩︎</span>'.freeze

class String

  def nil_if_empty
    if self == ''
      nil
    else
      self
    end
  end


end #/String
