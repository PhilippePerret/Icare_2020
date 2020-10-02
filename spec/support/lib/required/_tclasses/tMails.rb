# encoding: UTF-8
=begin
  Méthodes utiles pour les mails
=end
class TMails
class << self
  attr_reader :founds
  attr_accessor :error
  attr_accessor :raison_exclusion

  # Retourne les mails transmis à +mail_destinataire+ qui contiennent
  # le message +searched+
  def find_all(mail_destinataire, searched, options = nil)
    @founds = self.for(mail_destinataire, options)
    return @founds if searched.nil?
    @founds.select do |tmail|
      tmail.contains?(searched)
    end
  end #/ find_all

  # Retourne TRUE si un message au moins parmi les messages transmis à
  # +mail_destinataire+ contient +searched+
  # +searched+ {String} Le texte recherché (ou les options)
  def exists?(mail_destinataire, searched, options = nil)
    if searched.is_a?(Hash)
      options = searched
      searched = nil
    end
    candidats = self.find_all(mail_destinataire, searched, options)
    # if candidats.empty?
    #   puts "TMails.error: #{TMails.error}".rouge
    # else
    #   puts "candidats: #{candidats.inspect}"
    # end
    nombre_candidats = candidats.count
    options ||= {}
    if options.key?(:only_one) && options[:only_one]
      options.merge!(count: 1)
    end
    if nombre_candidats == 0
      self.error = "aucun mail trouvé"
      return false
    elsif options.key?(:count)
      if nombre_candidats == options[:count]
        return true
      else
        self.error = "le nombre de mails trouvés (#{nombre_candidats}) est différent du nombre de mails attendus (#{options[:count]})".freeze
        return false
      end
    else
      return nombre_candidats > 0
    end
  end #/ exists?
  alias :has_item? :exists?


  def has_mails?(params)
    destinataire = params[:destinataire]
    destinataire = destinataire.mail if destinataire.is_a?(TUser)
    exists?(destinataire, params[:content], params)
  end #/ has_mails?
  alias :has_mail? :has_mails?
  alias :has_item? :has_mails?

  def error= msg
    @error = msg
    return false
  end #/ error

  def for(mail_destinataire, options = nil)
    options ||= {}

    options.merge!(destinataire: mail_destinataire)

    options.merge!(expediteur: options.delete(:from)) if options.key?(:from)

    # On compose la procédure
    pr = proc do |tmail, options|
      if tmail && tmail.destinataire == options[:destinataire]
        [tmail, options]
      elsif tmail
        self.raison_exclusion = "Destinataire attendu: #{options[:destinataire].inspect}, obtenu: #{tmail.destinataire.inspect}"
        false
      end
    end

    if options.key?(:expediteur)
      pr = pr >> proc { |tmail, options| [tmail, options] if tmail && tmail.expediteur == options[:expediteur]}
    end
    if options.key?(:subject)
      # Le sujet recherché
      pr = pr >> proc do |tmail, options|
        if tmail && tmail.subject.include?(options[:subject])
          [tmail, options]
        elsif tmail
          self.raison_exclusion = "Subject attendu: #{options[:subject].inspect}, obtenu: #{tmail.subject.inspect}"
          false
        end
      end
    end
    if options.key?(:after)
      pr = pr >> proc do |tmail, options|
        if tmail && tmail.time.to_i > options[:after]
          [tmail, options]
        elsif tmail
          self.raison_exclusion = "Émis à #{tmail.time.to_i}, attendu après #{options[:after]}"
          false
        end
      end
    end
    if options.key?(:before)
      pr = pr >> proc { |tmail, options| [tmail, options] if tmail && tmail.time.to_i < options[:before]}
    end

    if options.key?(:message)
      pr = pr >> proc do |tmail, options|
        [tmail, options] if tmail && begin
          options[:message] = [options[:message]] if options[:message].is_a?(String)
          not_found = []
          options[:message].each do |str|
            tmail.contains?(str) || not_found << "'#{str}'"
          end
          self.raison_exclusion = "Ne contient pas les textes : #{not_found.inspect}."
          not_found.empty?
        end
      end
    end
    all.select do |tmail|
      choix = pr.call(tmail, options)
      # puts "Raison exclusion: #{raison_exclusion}"
      self.raison_exclusion = nil
      choix # true/false
    end
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
  def affixe
    @affixe = File.basename(path, File.extname(path))
  end #/ affixe
  def subject
    @subject ||= content.match(/Subject:(.*?)$/).to_a[1].strip
  end #/ subject
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
    @timestamp ||= split_filename[0]
  end
  def destinataire
    @destinataire ||= split_filename[1]
  end
  def split_filename
    bouts = affixe.split('-')
    [@timestamp = bouts.pop.to_i, @destinataire = bouts.join('-')]
  end #/ split_filename
  def expediteur
    @expediteur ||= content.match(/From: <(.+?)>/).to_a[1]
  end #/ expediteur
end
