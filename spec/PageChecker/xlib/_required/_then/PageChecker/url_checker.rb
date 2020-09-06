# encoding: UTF-8
# frozen_string_literal: true
class PageChecker
class << self

  # = main =
  #
  # Méthode principale appelée pour checker l'url voulue
  def check_url
    puts "#{RC*2}Check de l'URL #{base_url}…".bleu
    page = URL.new(base_url)
    page.check
  end #/ check_url



  def base_url
    @base_url ||= CONFIG[:url][CLI.option?(:online) ? :online : :offline]
  end #/ base_url
end # /<< self
end #/PageChecker
