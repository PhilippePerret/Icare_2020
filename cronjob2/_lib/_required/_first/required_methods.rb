# encoding: UTF-8
# frozen_string_literal: true


# Pour requérir un module comme si on se trouvait à la racine du site
def require_site(relpath)
  Dir.chdir(APPFOLDER) do
    require relpath
  end
end #/ require_site
