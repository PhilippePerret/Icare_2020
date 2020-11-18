# encoding: UTF-8
# frozen_string_literal: true

require './spec/support/optional_classes/TMails' # => TMails

# *** mails ***
TMAILS_FACTORY_FOLDER = File.expand_path(File.join(__dir__,'..','factory'))
TMAILS_TEMP_FOLDER = File.expand_path(File.join('./tmp/mails'))
MAIL_GABARIT = File.join(TMAILS_FACTORY_FOLDER, '_gabarit_@gmail.com-xxx.html')

`mkdir -p "#{TMAILS_TEMP_FOLDER}"`

class TMails
class << self

  # Pour créer un mail
  # +param+   {Hash} Pour construire le mail
  #     :to         Destinataire
  #     :from       Expéditeur
  #     :at         Le time d'envoi (ou courant)
  #     :subject    Sujet
  #     :content    Contenu
  def create(params)
    params.merge!(to: params.delete(:destinataire)) if params[:destinataire]
    params[:to] ||= "phil@atelier-icare.net"
    params.merge!(at: Time.now.to_f) unless params[:at]
    params[:from] ||= "atelier@atelier-icare.net"
    params.merge!(subject: "Sans sujet") unless params[:subject]
    params.merge!(content: "<p>Sans contenu</p>") unless params[:content]

    code = File.read(MAIL_GABARIT)
    [:to, :from, :subject, :content].each do |key|
      code = code.sub(/__#{key.upcase}__/, params[key])
    end
    dst_name = MAIL_FILENAME_TEMPLATE % [params[:to], params[:at].to_f]
    dst_path = File.join(TMAILS_TEMP_FOLDER, dst_name)
    File.open(dst_path,'wb'){|f| f.write(code)}
  end #/ create
end # << self

MAIL_FILENAME_TEMPLATE = "%s-%s.html"
end #/TMails
