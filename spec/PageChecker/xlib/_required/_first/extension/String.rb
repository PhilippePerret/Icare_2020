# encoding: UTF-8
# frozen_string_literal: true

RC = "\n"

class String
  def forceUTF8
    self.force_encoding("ISO-8859-5").encode("UTF-8")
  end #/ forceUTF8
end #/String
