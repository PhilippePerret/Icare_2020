# encoding: UTF-8
=begin
  Extension de la class IcModule
=end
class IcModule
  # Le titre du module avec le nom du projet s'il existe
  def name_with_project
    mc = "le module “#{absmodule.name}”"
    mc << " sur son projet “#{project_name}”" if project_name
    return mc
  end #/ name_with_projet
end #/IcModule
