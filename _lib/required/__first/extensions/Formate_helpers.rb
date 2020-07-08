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

DAYNAMES = [
  'Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'
]

def formate_date(time = nil, options = nil)
  options ||= {}
  options.key?(:mois) || options.merge!(mois: :long)
  time ||= Time.now
  time = Time.at(time) unless time.is_a?(Time)
  mois = MOIS[time.month][options[:mois]]
  temp = "%-d #{mois} %Y"
  temp << " %H:%M".freeze if options[:time] || options[:hour]
  d = time.strftime(temp)
  if options[:jour] || options[:day]
    d.prepend(DAYNAMES[time.wday]+SPACE)
  end
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

# Formate la durée entre +date1+ et +date2+ pour qu'elle ressemble
# à "8 ans et 3 mois"
# +options+
#   :nojours      Si TRUE, on n'indique que les années et les mois
#   :long         idem
def formate_duree(date1, date2, options = nil)
  date1   ||= Time.now.to_i
  date2   ||= Time.now.to_i
  options ||= {}
  duree_secondes = date2 - date1
  nombre_annees = duree_secondes / 365.days
  reste = duree_secondes % 365.days
  nombre_mois  = reste / 30.days
  reste = reste % 30.days
  nombre_jours = reste / 1.days
  duree = []
  duree << "#{nombre_annees} an#{'s' if nombre_annees > 1}" if nombre_annees > 0
  duree << "#{nombre_mois} mois" if nombre_mois > 0
  unless options[:nojours] || options[:long]
    duree << "#{nombre_jours} jour#{'s' if nombre_jours > 1}" if nombre_jours > 0
  end
  return duree.pretty_join
end #/ formate_duree

def formate_short_duree
  raise "à implémenter"
end #/ formate_short_duree
