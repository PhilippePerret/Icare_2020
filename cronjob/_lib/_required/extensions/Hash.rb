# encoding: UTF-8
=begin
  Extension de la class Hash
=end
class Hash

  # Pour remplacer toutes les clés de premier niveau par des symbols
  def to_sym
    {}.tap do |h|
      self.each { |k, v| h.merge!(k.to_sym => v)}
    end
  end #/ to_sym
  
end #/Hash
