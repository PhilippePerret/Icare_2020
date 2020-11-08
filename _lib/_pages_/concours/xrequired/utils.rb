# encoding: UTF-8
# frozen_string_literal: true

# OUT   Path au mail +mailp+ dans le dossier xmodules/mails/
# INT   {String} +mailp+ Chemin relatif au mail à partir du dossier
#       xmodules/mails
def mail_path(mailp)
  File.join(XMODULES_FOLDER,'mails', mailp)
end #/ mail_path

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
