# encoding: UTF-8
class User

# Nom du module courant si actif ou '---'
def module_courant_name
  @module_courant_name ||= begin
    if user.actif?
      require_module('user/modules')
      user.icmodule.name
    else
      '---'
    end
  end
end #/ module_courant_name

end #/User
