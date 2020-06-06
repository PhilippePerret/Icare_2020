# encoding: UTF-8
=begin
  Méthodes utiles pour les Watchers
=end
class TWatchers
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
      pr = proc { |tmail| tmail }
      if params.key?(:wtype)
        pr = pr >> proc {|tmail|
          puts "tmail.wtype = #{tmail.inspect}"
          tmail if tmail && tmail.wtype == params[:wtype]}
      end
      if params.key?(:after)
        params[:after] = Time.at(params[:after]) if params[:after].is_a?(Integer)
        pr = pr >> proc { |tmail| tmail if tmail && tmail.time > params[:after]}
      end
      if params.key?(:before)
        params[:before] = Time.at(params[:before]) if params[:before].is_a?(Integer)
        pr = pr >> proc { |tmail| tmail if tmail && tmail.time < params[:before]}
      end
      # On filtre les watchers
      @founds = self.for(params).select do |tmail|
        pr.call(tmail)
      end
    end #/ find

    # Retourne tous les watchers (instances TWatcher) pour l'icarien
    # +params:user_id+
    def for(params)
      user_id = params[:user_id] || params[:user].id
      cols = "id, user_id, wtype, objet_id, params, created_at, updated_at, triggered_at"
      request = "SELECT #{cols} FROM watchers WHERE user_id = #{user_id}"
      db_exec(request).collect do |dwatcher|
        TWatcher.new(*dwatcher.values)
      end
    end #/ for

  end # /<< self
end #/Mails

TWatcher = Struct.new(:id, :user_id, :wtype, :objet_id, :params, :created_at, :updated_at, :triggered_at) do
  def time
    @time ||= Time.at(created_at)
  end #/ time
end
