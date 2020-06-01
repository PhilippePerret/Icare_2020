# encoding: UTF-8

class HTML
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
  attr_reader :page, :head, :header, :body, :footer, :messages
  def out
    cgi.out{page}
  end #/out

end
