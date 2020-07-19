# encoding: UTF-8
=begin
  Constantes nombre
=end
def timeize(str)
  str = str.gsub(/today/, Time.now.strftime('%d %m %Y'))
  day, mon, year, tim = str.split(' ')
  hrs, min = (tim || Time.now.strftime('%H:%M')).split(':')
  Time.new(year.to_i, mon.to_i, day.to_i, hrs.to_i, min.to_i)
end #/ timeize

if ENV.key?('CRONJOB_TIME') # pour tester
  NOW = timeize(ENV['CRONJOB_TIME'])
  puts "Faux temps donné : #{NOW}"
else
  NOW = Time.now
end

NOW_S   = NOW.to_i
TODAY   = Time.new(NOW.year, NOW.month, NOW.day)
TODAY_S = TODAY.to_i
