# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour procéder à un test simple du site online
=end
require_relative './test/constants'
require_relative './test/checked_url'

class IcareCLI
extend Capybara::DSL
class << self
  def proceed_test
    CheckedUrl.init
    only_route = params[1]

    if option?(:infos)
      Capybara.default_driver = :selenium
    else
      Capybara.current_driver = :selenium_headless
    end

    # Le premier sert uniquement au lancement
    visit(URL_BASE)
    clear
    puts "=== TEST MINIMAL DU SITE DISTANT #{URL_BASE} ===#{RC}===".bleu
    puts "=== OPTIONS ===".bleu
    [
      only_route ? "Seulement la route : #{only_route}" : "Toutes les routes",
      option?(:infos) ? "avec backend (visualisation)" : "headless (ajoute -i/--infos pour voir dans le navigateur)",
      verbose? ? "mode verbeux" : "mode silencieux (ajouter -v/--verbose pour voir le détail)",
    ].each do |msg|
      puts "=== #{msg}".gris
    end
    puts RC

    DATA_URLS.each do |durl|
      if only_route
        next if durl[:route] != only_route
      end
      url = CheckedUrl.new(durl)
      url.tester
      # Si on voulait voir une seule route, on peut s'arrêter là
      break if only_route
    end
    puts RC * 2
    CheckedUrl.final_report
    puts RC * 2
  rescue Exception => e
    puts e.message.rouge + RC*2
    # puts e.backtrace.join(RC)
  end #/ proceed_test

end # /<< self
end #/IcareCLI
