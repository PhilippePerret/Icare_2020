# encoding: UTF-8
# frozen_string_literal: true
=begin
  L'envoi du rapport est un job comme les autres ;-)
=end
class Cronjob

  def data
    @data ||= {
      name: "Envoi du rapport",
      frequency: {hour: 11}
    }
  end #/ data

  def envoi_rapport
    Report.send_if_not_empty
    return true
  end #/

end #/Cronjob
