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
      nombre_candidats = self.find_all(params).count
      if nombre_candidats == 0
        @error = "aucun watcher trouvé"
        false
      elsif params.key?(:only_one)
        @error = "plusieurs watchers trouvés" if nombre_candidats > 1
        return nombre_candidats == 1
      else
        return nombre_candidats > 0
      end
    end #/ exists?

    # Retourne les mails transmis à +user_id+ qui contiennent
    # le message +searched+
    def find_all(params)
      pr = proc { |obj| obj }
      if params.key?(:wtype)
        pr = pr >> proc {|obj| obj if obj && obj.wtype == params[:wtype]}
      end
      if params.key?(:after)
        pr = pr >> proc { |obj| obj if obj && obj.created_at > params[:after]}
      end
      if params.key?(:before)
        pr = pr >> proc { |obj| obj if obj && obj.created_at < params[:before]}
      end
      # On filtre les watchers
      @founds = self.for(params).select do |obj|
        pr.call(obj)
      end
    end #/ find

    def find(params)
      find_all(params).first
    end #/ find

    # Retourne tous les watchers (instances TWatcher) pour l'icarien
    # +params:user_id+
    def for(params)
      user_id = params[:user_id] || params[:user]&.id || params[:owner]&.id || params[:owner_id]
      cols = "id, user_id, wtype, objet_id, params, created_at, updated_at, triggered_at".freeze
      request = "SELECT #{cols} FROM watchers WHERE user_id = #{user_id}".freeze
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
