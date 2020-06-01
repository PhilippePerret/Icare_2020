# encoding: UTF-8
=begin
  Extension de la classe AbsModule pour l'affichage des modules
=end
class AbsModule < ContainerClass
  def out
    log("-> AbsModule#out (self)")
    "Module #{name}"
  end #/ out
end #/AbsModule
