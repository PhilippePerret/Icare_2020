# encoding: UTF-8
=begin
  Méthodes utiles pour les Watchers
=end
class TActualites
  class << self
    attr_reader :founds

    # Retourne TRUE si un message au moins parmi les messages transmis à
    # +user_id+ contient +searched+
    def exists?(params)
      nombre_candidats = self.find(params).count
      if params.key?(:only_one)
        return nombre_candidats == 1
      else
        return nombre_candidats > 0
      end
    end #/ exists?

    # Retourne les mails transmis à +user_id+ qui contiennent
    # le message +searched+
    def find(params)
      pr = proc { |tactu| tactu }
      if params.key?(:type)
        pr = pr >> proc {|tactu| tactu if tactu && tactu.type == params[:type]}
      end
      if params.key?(:contains)
        pr = pr >> proc { |tactu| tactu if tactu && tactu.contains?(params[:contains])}
      end
      if params.key?(:after)
        params[:after] = Time.at(params[:after]) if params[:after].is_a?(Integer)
        pr = pr >> proc { |tactu| tactu if tactu && tactu.time > params[:after]}
      end
      if params.key?(:before)
        params[:before] = Time.at(params[:before]) if params[:before].is_a?(Integer)
        pr = pr >> proc { |tactu| tactu if tactu && tactu.time < params[:before]}
      end
      # On filtre les watchers et on les retourne
      @founds = self.for(params).select do |tactu| pr.call(tactu) end
    end #/ find

    # Retourne tous les watchers (instances TActualite) pour l'icarien
    # +params:user_id+
    def for(params = nil)
      params ||= {}
      cols = "id, user_id, type, message, created_at, updated_at"
      request = "SELECT #{cols} FROM actualites"
      user_id = params[:user_id] || params[:user].id
      request << " WHERE user_id = #{user_id}" if user_id
      request << " ORDER BY created_at"
      request << " LIMIT #{params[:limit]}" if params.key(:limit)
      db_exec(request).collect do |dactu|
        TActualite.new(*dactu.values)
      end
    end #/ for

  end # /<< self
end #/Mails

TActualite = Struct.new(:id, :user_id, :type, :message, :created_at, :updated_at) do
  def time
    @time ||= Time.at(created_at)
  end #/ time
  def contains?(searched)
    message.include?(searched)
  end #/ contains
end
