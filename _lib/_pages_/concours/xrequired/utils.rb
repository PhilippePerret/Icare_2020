# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def require_xmodule(name)
    require File.join(XMODULES_FOLDER,name)
  end #/ require_xmodule
end #/HTML
