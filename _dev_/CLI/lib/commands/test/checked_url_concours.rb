# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la classe CheckedUrl pour le concours
  Suivant le phase online, on tester les différentes dispositions
=end
class CheckedUrl
class << self
  attr_accessor :current_phase
  # = main =
  #
  # Méthode principale appelée pour tester la phase courante du concours
  # de synopsis.
  def phase_concours
    define_current_phase
    puts "   = Phase du concours : #{current_phase.inspect}".bleu if IcareCLI.verbose?
    DATA_TESTS_PER_PHASE.each do |data_route|
      data_route.merge!(seek_and_do: data_route[:seek_and_do][current_phase])
      # puts "data_route: #{data_route}"
      new(data_route).tester
    end
  end #/ phase_concours

DATA_TESTS_PER_PHASE = YAML.load_file(File.join(__dir__,'_DATA_CONCOURS_PER_PHASE_.yaml'))

  # DO    Relève la phase courante sur le site distant
  def define_current_phase
    request_ssh = <<-SSH
ssh icare@ssh-icare.alwaysdata.net ruby << RUBY
Dir.chdir("www") do
  ANNEE_CONCOURS_COURANTE = Time.now.month < 11 ? Time.now.year : Time.now.year + 1
  ONLINE = true
  require './_lib/required/__first/db'
  MyDB.DBNAME = 'icare_db'
  puts db_exec("SELECT phase FROM concours WHERE annee = ?", [ANNEE_CONCOURS_COURANTE]).first[:phase]
end
RUBY
    SSH
    res = `#{request_ssh}`
    self.current_phase = res.strip.to_i
  end #/ define_current_phase
end # /<< self
end #/CheckedUrl
