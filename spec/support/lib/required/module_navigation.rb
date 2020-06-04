# encoding: UTF-8
=begin

  @usage

  feature ...
    scenario ...
      extend SpecModuleNavigation

=end
module SpecModuleNavigation
  def goto_home
    visit 'http://localhost/AlwaysData/Icare_2020'
  end #/ goto_home
end
