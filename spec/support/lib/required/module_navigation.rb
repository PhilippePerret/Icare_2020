# encoding: UTF-8
=begin

  @usage

  feature ...
    scenario ...
      extend SpecModuleNavigation

=end
module SpecModuleNavigation
  URL_OFFLINE = 'http://localhost/AlwaysData/Icare_2020'
  def goto_home
    visit URL_OFFLINE
  end #/ goto_home
end
