# encoding: UTF-8
=begin
  Méthodes utiles pour les mails
=end
class TMails
  class << self

    # Retourne les mails transmis à +mail_destinataire+ qui contiennent
    # le message +searched+
    def find(mail_destinataire, searched)
      self.for(mail_destinataire).select do |tmail|
        tmail.contains?(searched)
      end
    end #/ find

    # Retourne TRUE si un message au moins parmi les messages transmis à
    # +mail_destinataire+ contient +searched+
    def exists?(mail_destinataire, searched)
      self.find(mail_destinataire, searched).count > 0
    end #/ exists?

    def for(mail_destinataire)
      all.partition do |path|
        File.basename(path).start_with?(mail_destinataire)
      end.first.collect do |path|
        TMail.new(path)
      end
    end #/ for
    def all
      Dir["./tmp/mails/*.html"]
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
end
