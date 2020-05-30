# encoding: UTF-8

JOUR = (3600 * 24).freeze
MOIS = {
  1 => {court: 'jan', long: 'janvier'},
  2 => {court: 'fév', long: 'février'},
  3 => {court: 'mars', long: 'mars'},
  4 => {court: 'avr', long: 'avril'},
  5 => {court: 'mai', long: 'mai'},
  6 => {court: 'juin', long: 'juin'},
  7 => {court: 'juil', long: 'juillet'},
  8 => {court: 'aout', long: 'aout'},
  9 => {court: 'sept', long: 'septembre'},
  10 => {court: 'oct', long: 'octobre'},
  11 => {court: 'nov', long: 'novembre'},
  12 => {court: 'déc', long: 'décembre'}
}

def formate_date(time, options = nil)
  options ||= {}
  options.key?(:mois) || options.merge!(mois: :long)
  time = Time.at(time) unless time.is_a?(Time)
  mois = MOIS[time.month][options[:mois]]
  d = time.strftime("%-d #{mois} %Y")
  if options[:duree]
    now = Time.now
    mot = now > time ? 'il y a' : 'dans' ;
    jours = ((now - time).abs.to_f / JOUR).round
    laps =  if jours == 0
              'aujourd’hui'.freeze
            else
              s = jours > 1 ? 's' : '' ;
              "#{mot} #{jours} jour#{s}".freeze
            end
    d << " <span class=\"small\">(#{laps})</span>"
  end
  return d
end #/ formate_date
