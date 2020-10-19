# encoding: UTF-8
# frozen_string_literal: true
=begin
  Les méthodes qui simulent ou reproduisent les méthodes du site
=end

# Pour requérir un module
def require_module(dossier)
  require_folder("./_lib/modules/#{dossier}")
end #/ require_module

def debug(msg)
  puts "DEBUG: #{msg}"
end #/ debug
