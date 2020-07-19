class Time
  WDAYS = {
    0 => {short:'dim', long:'dimanche'},
    1 => {short:'lun', long:'lundi'},
    2 => {short:'mar', long:'mardi'},
    3 => {short:'mer', long:'mercredi'},
    4 => {short:'jeu', long:'jeudi'},
    5 => {short:'ven', long:'vendredi'},
    6 => {short:'sam', long:'samedi'}
  }
  MONTHS = {
    1 => {short:'jan',  long:'janvier'},
    2 => {short:'fév',  long:'février'},
    3 => {short:'mars', long:'mars'},
    4 => {short:'avr',  long:'avril'},
    5 => {short:'mai',  long:'mai'},
    6 => {short:'juin', long:'juin'},
    7 => {short:'juil', long:'juillet'},
    8 => {short:'aout', long:'aout'},
    9 => {short:'sept', long:'septembre'},
    10=> {short:'oct',  long:'octobre'},
    11=> {short:'nov',  long:'novembre'},
    12=> {short:'déc',  long:'décembre'}
  }

  # Pour formater un temps
  # Par défaut :
  #     JJ mois AAAA H:MM
  # +options+
  #   day/jour        Si true, on ajoute 'lundi', 'mardi', etc.
  #   heure: false    Pour ne pas écrire l'heure. Sinon elle est écrite
  #   simple: true    Format de type JJ MM YYYY H:MM
  def to_s(options = nil)
    # Options par défaut
    options ||= {}
    options.merge!(long: true) unless options.key?(:long) || options.key?(:short)
    options.merge!(long: !options.delete(:short)) if options.key?(:short)
    options.merge!(heure: true) unless options.key?(:heure)
    options.merge!(jour: options.delete(:day)) if options.key?(:day)
    # La clé pour la longueur des éléments textuels (mois et jour semaine)
    key_long = options[:long] ? :long : :short
    # Les valeurs
    mois      = options[:simple] ? self.strftime("%m") : MONTHS[self.month][key_long]
    wday      = options[:jour] ? "#{WDAYS[self.wday][key_long]} ".freeze : ''.freeze
    heure     = options[:heure] ? ' %H:%M'.freeze : ''.freeze
    mot_liaison_time = (options[:simple]||!options[:heure]) ? '' : ' à'
    date = self.strftime("#{wday}%d #{mois} %Y#{mot_liaison_time}#{heure}").freeze
  end #/ to_s

  # Retourne le temps ({Time}) de départ de la veille
  # Noter qu'il faut absolument que ces méthodes se servent de NOW, qui
  # peut être défini par ENV en cas de test
  def self.veille
    Date.today.prev_day.to_time
  end #/ veille_start

end #/Time
