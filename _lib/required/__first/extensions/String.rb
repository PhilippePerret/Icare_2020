# encoding: UTF-8

RC = '
'.freeze

BR = '<br/>'.freeze

VG = ', '.freeze

class String

  def nil_if_empty
    if self == ''
      nil
    else
      self
    end
  end


end #/String
