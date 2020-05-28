# encoding: UTF-8
require_module('user/modules')
class User

  def travail
    @travail ||= Travail.new(self)
  end #/ travail

end #/User
