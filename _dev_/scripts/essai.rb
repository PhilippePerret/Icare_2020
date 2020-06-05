# encoding: UTF-8
=begin
  Pour faire des essais ruby
=end
require './spec/support/lib/required/handies/mail.rb'

date = Time.new(2020, 6, 10)
options = {
  from: 'phil@atelier-icare.net',
  # from: 'philippe.perret@yahoo.fr',
  before: date
}
mails = TMails.for('marion.michel31@gmail.com', options)

mails.each do |tmail|
  puts "Mail de #{tmail.expediteur} pour #{tmail.destinataire} le #{tmail.time}"
end
