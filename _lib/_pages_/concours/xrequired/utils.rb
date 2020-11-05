# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def require_xmodule(name)
    p = File.join(XMODULES_FOLDER,name)
    File.exists?(p) || File.exists?("#{p}.rb") || raise("File inconnu : #{p}")
    if File.directory?(p)
      require_folder(p)
    else
      require p
    end
  end #/ require_xmodule
end #/HTML
