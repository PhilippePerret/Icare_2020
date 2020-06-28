# encoding: UTF-8
=begin
  Class FrigoMessage
  ------------------
  Pour les messages des discussions
=end
class FrigoMessage < ContainerClass
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
def out(options = nil)
  Tag.div(text: content, class:'fmessage')
end #/ out

end #/FrigoMessage
