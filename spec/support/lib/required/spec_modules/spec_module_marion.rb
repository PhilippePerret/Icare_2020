# encoding: UTF-8
=begin
  Module pour tester avec Marion
=end
module SpecModuleMarion
  def marion
    dmarion = get_user_by_index(1)
    TUser.instantiate(dmarion)
  end #/ marion
  def identify_marion
    goto_login_form
    login(data)
  end #/ identify_marion

end #/SpecModuleMarion
