# encoding: UTF-8
=begin
  Méthodes utiles pour les mails
=end
class TMails
  class << self
    attr_reader :founds
    attr_reader :error

    # Retourne les mails transmis à +mail_destinataire+ qui contiennent
    # le message +searched+
    def find(mail_destinataire, searched, options = nil)
      @founds = self.for(mail_destinataire, options).select do |tmail|
        tmail.contains?(searched)
      end
    end #/ find

    # Retourne TRUE si un message au moins parmi les messages transmis à
    # +mail_destinataire+ contient +searched+
    def exists?(mail_destinataire, searched, options = nil)
      nombre_candidats = self.find(mail_destinataire, searched, options).count
      if nombre_candidats == 0
        error = "aucun mail trouvé"
      elsif options && options[:only_one]
        return error= "plusieurs mails trouvés (cf. TMails.founds)" if nombre_candidats > 1
        return true
      else
        return nombre_candidats > 0
      end
    end #/ exists?

    def error= msg
      @error = msg
      return false
    end #/ error

    def for(mail_destinataire, options = nil)
      options ||= {}
      options.merge!(destinataire: mail_destinataire)
      options.merge!(expediteur: options.delete(:from)) if options.key?(:from)
      # On compose la procédure
      pr = proc { |tmail, options| [tmail, options] if tmail && tmail.destinataire == options[:destinataire] }
      if options.key?(:expediteur)
        pr = pr >> proc { |tmail, options| [tmail, options] if tmail && tmail.expediteur == options[:expediteur]}
      end
      if options.key?(:after)
        options[:after] = Time.at(options[:after]) if options[:after].is_a?(Integer)
        pr = pr >> proc { |tmail, options| [tmail, options] if tmail && tmail.time > options[:after]}
      end
      if options.key?(:before)
        options[:before] = Time.at(options[:before]) if options[:before].is_a?(Integer)
        pr = pr >> proc { |tmail, options| [tmail, options] if tmail && tmail.time < options[:before]}
      end
      all.select do |tmail| pr.call(tmail, options) end
    end #/ for
    def all
      Dir["./tmp/mails/*.html"].collect{|path| TMail.new(path)}
    end #/ all
  end # /<< self
end #/Mails

TMail = Struct.new(:path) do
  def filename
    @filename ||= File.basename(path)
  end #/ filename
  def content
    @content ||= File.read(path).force_encoding('utf-8')
  end #/ content
  def contains?(searched)
    content.include?(searched)
  end #/ contains?
  def time
    @time ||= Time.at(timestamp)
  end #/ time
  def timestamp
    @timestamp ||= filename.split('-')[1].to_i
  end #/ timestamp
  def destinataire
    @destinataire ||= filename.split('-')[0]
  end #/ destinataire
  def expediteur
    @expediteur ||= content.match(/From: <(.+?)>/).to_a[1]
  end #/ expediteur
end
