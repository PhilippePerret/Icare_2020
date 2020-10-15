# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class SFile (pour Sync-File)
=end
class SFile
class << self

end # /<< self


# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :ini_path

# Le temps du fichier distant se fixe explicitement
attr_accessor :dis_mtime

def initialize(ini_path)
  @ini_path = ini_path
end #/ initialize

# ---------------------------------------------------------------------
#
#   Méthodes de synchronisation
#
# ---------------------------------------------------------------------

# Méthode de synchronisation quand on traite par dossier
def synchronize
  STDOUT.write " * Synchronisation de #{rel_path}".bleu
  cmd = "ssh #{SERVEUR_SSH} 'mkdir -p ./#{File.dirname(dis_path)}';scp -p #{loc_path} #{SERVEUR_SSH}:#{dis_path}"
  # puts "\n   Command : #{cmd}"
  result = `#{cmd} 2>&1`
  raise result if result != ""
  STDOUT.write "\r √ Synchronisation de #{rel_path}#{RC}".vert
rescue Exception => e
  puts "#{RC}   ÉCHEC : #{e.message}".rouge
end #/ synchronize

# Méthode appelée quand on traite un fichier unique
def synchronize_as_lonely
  puts "*** Synchronisation du fichier unique #{rel_path} ***".bleu
  # On compare avec l'état distant
  res = JSON.parse(`#{SSH_REQUEST_FILE % {dis_path: dis_path}}`)
  self.dis_mtime = res['mtime']
  if not out_of_date?
    puts "√ Le fichier est à jour".vert
    return
  end
  puts "🆘 Le fichier n'est pas à jour.".rouge
  if IcareCLI.options[:sync] || proceder_a_la_synchro?("de ce fichier")
    synchronize
  end
end #/ synchro_as_lonely
# ---------------------------------------------------------------------
#
#   Méthodes d'helper
#
# ---------------------------------------------------------------------
def resultat_comparaison
  @resultat_comparaison ||= begin
    if out_of_date?
      "#{'REQUIRE UPDATE:'.rouge} #{rel_path.bleu}"
    else
      "#{'OK:'.vert} #{rel_path.bleu}" if VERBOSE
    end
  end
end #/ resultat_comparaison

# ---------------------------------------------------------------------
#
#   Méthodes d'analyse
#
# ---------------------------------------------------------------------
def out_of_date?
  (@outofdate ||= begin
    (not(dis_exists?) || dis_mtime < loc_mtime) ? :true : :false
  end) == :true

end #/ out_of_date?

# ---------------------------------------------------------------------
#
#   Méthodes de temps
#
# ---------------------------------------------------------------------
def loc_mtime
  @loc_mtime ||= begin
    File.stat(loc_path).mtime.to_i if loc_exists?
  end
end #/ loc_mtime

def dis_exists?
  @disexists ||= dis_mtime != nil
end #/ dis_exists?
# Le path absolu au fichier distant
def dis_path
  @dis_path ||= File.join('www',rel_path)
end #/ dis_path

def loc_exists?
  @locexists ||= File.exists?(loc_path)
end #/ loc_exists?
# Le path absolu au fichier local
def loc_path
  @loc_path ||= File.expand_path(ini_path)
end #/ loc_path


# Le path relatif au fichier (distant et local)
def rel_path
  @rel_path ||= loc_path.sub(/#{APP_FOLDER}\//,'')
end #/ rel_path

end #/SFile
