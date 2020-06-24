# encoding: UTF-8
=begin
  Module pour tester avec Marion
=end
module SpecModuleMarion
  def marion
    TUser.get_user_by_mail(get_data_user_by_index(1)[:mail])
  end #/ marion
  def identify_marion
    goto_login_form
    login_in_form(get_data_user_by_index(1))
  end #/ identify_marion

end #/SpecModuleMarion
