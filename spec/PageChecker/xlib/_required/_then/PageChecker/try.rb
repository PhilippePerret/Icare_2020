# encoding: UTF-8
=begin
  PageChecker::try
=end
class PageChecker
class << self
  # ---------------------------------------------------------------------
  #
  #   Pour faire des essais quelconques
  #
  # ---------------------------------------------------------------------

  def try_something
    PageChecker.ssh_exec("cd www\nls -la")
  end #/ try_something


end #/<< self
end #/PageChecker
