# encoding: UTF-8
# frozen_string_literal: true
class IcareCLI
class << self
  def proceed_infos
    require_relative 'infos/required'
    what = params[1] || raise("Il faut absolument définir le type de l'objet à voir (#{DATA_OBJETS.keys.join(', ')}).")
    DATA_OBJETS.key?(what.to_sym) || raise("L'objet doit absolument être choisi parmi : #{DATA_OBJETS.keys.join(', ')}.")
    oid = params[2] || raise("Il faut absolument indiquer l'identifiant de l'objet #{what}.")
    oid = oid.to_i
    require_relative "infos/objets/#{what}"
    send("infos_for_#{what}", oid)
  rescue Exception => e
    puts e.message.rouge + RC*2
  end #/ proceed_goto
end # /<< self
end #/IcareCLI
