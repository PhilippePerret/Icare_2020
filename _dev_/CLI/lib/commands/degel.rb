# encoding: UTF-8
=begin
  Extension de IcareCLI pour les gels et degels
=end
class IcareCLI
class << self
  def proceed_degel
    main_folder_gel = File.join(APP_FOLDER,'spec','support','Gel')
    folder_gels = File.join(main_folder_gel, 'gels')
    gel_name = params[1] || begin
      liste_gels = Dir["#{folder_gels}/*"].collect{|p|File.basename(p)}
      Q.select("Dégeler…") do |q|
        q.choices liste_gels
        q.per_page liste_gels.count
      end
    end
    File.exists?(File.join(folder_gels,gel_name)) || begin
      raise("Le gel '#{gel_name}' est inconnu. Pour le créer :\n* définir son 'test' dans gels_spec\n* jouer ce test (`GEL_REMOVE_LAST=true rspec spec/gels -t <tag>`)")
    end
    require_folder(File.join(APP_FOLDER,'spec','support','Gel','lib'))
    degel(gel_name)
    puts "Dégel opéré avec succès".vert
  end #/ degel

end # /<< self
end #/IcareCLI
