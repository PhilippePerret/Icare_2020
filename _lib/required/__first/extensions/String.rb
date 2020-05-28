# encoding: UTF-8

RC = '
'.freeze

BR = '<br/>'.freeze

VG = ', '.freeze

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
