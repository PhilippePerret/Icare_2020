# encoding: UTF-8
# frozen_string_literal: true
IGNORES = {folders:[], paths:[], regs:[]}

class IcareCLI
class << self

  # Pour charger les données du fichier .syncignore
  # DO    Produit deux listes qui vont contenir les données des éléments
  #       à ignorer :
  #       IGNORES[:paths]   Liste des paths explicites non régulières
  #       IGNORES[:folders] Liste des dossiers à éviter
  #       IGNORES[:regs]    Liste des expressions régulières
  #
  def load_sync_ignore
    if File.exists?(IGNORE_FILE_PATH)
      code = File.read(IGNORE_FILE_PATH).encode('utf-8')
      code.split(RC).each do |line|
        next if line.start_with?('#') || line.strip == ""
        if line.match?(/[*?]/) # => une expression régulière
          line = line.gsub(/\*/, '__ASTERIS__')
          line = line.gsub(/\?/, '__INTERRO__')
          line = Regexp.escape(line)
          line = line.gsub(/__ASTERIS__/,'*')
          line = line.gsub(/__INTERRO__/,'?')
          line = line.gsub(/([*?])/, '.\1')
          IGNORES[:regs] << /#{line}/
        elsif line.end_with?('/') # => tout un dossier à ignorer
          IGNORES[:folders] << line
        else
          line = line[2..-1] if line.start_with?('./')
          IGNORES[:paths] << line
        end
      end
      # puts "IGNORES: #{IGNORES.inspect}"
    end
  end #/ load_sync_ignore

  # Pour montrer le fichier des éléments ignorés
  def show_ignore_files
    puts "(#{'icare sync aide'.jaune} pour obtenir de l'aide)"
    sleep 1
    exec("vim \"#{IGNORE_FILE_PATH}\"")
  end #/ show_ignore_files

end # /<< self
end #/IcareCLI
