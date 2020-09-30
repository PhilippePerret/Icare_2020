# encoding: UTF-8
# frozen_string_literal: true
=begin
  Facilité pour les tests de CLI
=end

# Exécute le code icare +code+ et retourne le résultat
def cli(cmd_icare)
  cmd = ['cd "/Users/philippeperret/Sites/AlwaysData/Icare_2020"']
  cmd << "bundle exec ./_dev_/CLI/icare.rb #{cmd_icare}"
  cmd = cmd.join(';')
  res = `#{cmd} > ./resultat_check.txt`
  # puts "Retour de commande '#{cmd_icare}' : #{res.inspect}"
  # puts "/Retour de commande"
  expect(File.exists?('./resultat_check.txt')).to eq(true)
  resultat = File.read('./resultat_check.txt')
  resultat.gsub(/\[0m/,'').gsub(/\[0;[0-9]+m/,'').gsub(/\n([ ]+)?\n/,"\n")
end #/ cli
