# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthodes utilitaires pour les dates/times
=end


# ---------------------------------------------------------------------
#
#   Class DateString
#   ----------------
#   v. 0.1.0
#
#   Permet de gérer les dates sous forme JJ MM AAAA HH:MM:SS
#   - Les espaces peuvent être remplacées par des "/" : JJ/MM/AAAA
#   - Seuls les jours et les mois sont absolument requis. Toutes les
#     autres valeurs sont optionnelles.
#   - L'année peut être mise sur 2 chiffres. Dès qu'elle est inférieure
#     à 100, on lui ajoute 2000.
#
#   @usage
#     dstring = DateString.new(valeur)
#     dstring.valid?  -> true si ok, false otherwise
#                     dstring.error contient l'erreur de formatage
#     dstring.to_time -> La {Date} ({Time}) correspondant
# ---------------------------------------------------------------------

class DateString
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :init_value
attr_reader :jour, :mois, :annee, :heure, :minutes, :seconds
attr_reader :error
def initialize(init_value)
  @init_value ||= init_value
end #/ initialize

# OUT   La date au format {Time}
def to_time
  @to_time ||= Time.new(annee||Time.now.year, mois, jour, heure||0, minutes||0, seconds||0)
end #/ to_time

# OUT   True si la date string fournie est valide.
def valid?
  check_formatage
  error.nil?
end #/ valid?
# ---------------------------------------------------------------------
#   Méthodes de check
# ---------------------------------------------------------------------
def check_formatage
  check_value_init
  @jour, @mois, @annee, @heure, @minutes, @seconds = init_value.split(/[ \/\-:]/).collect{|m| m.to_i}
  check_jour
  check_mois
  check_annee   if not(@annee.nil?)
  check_heure   if not(@heure.nil?)
  check_minutes if not(@minutes.nil?)
  check_seconds if not(@seconds.nil?)
rescue Exception => e
  @error = e.message
end #/ check_formatage

def check_value_init
  c   = '[0-9]'
  c2  = "#{c}?#{c}"
  c4  = "#{c}#{c}(#{c}#{c})?"
  sep = '[ \/]'
  init_value.match?(/#{c2}#{sep}#{c2}(#{sep}#{c4}([ \-\/]#{c2}:#{c2}(:#{c2})?)?)?/) || raise("La date doit être fournie au format 'JJ MM[ YY[ HH:MM]]' (les espaces peuvent être remplacées par des '/').")
end #/ check_value_init
def check_jour
  raise "Le jour doit être un nombre entre 1 et 31" if jour < 1 || jour > 31
end #/ check_jour
def check_mois
  raise "Le mois doit être un nombre entre 1 et 12" if mois < 1 || mois > 12
end #/ check_mois
def check_annee
  raise "L'année doit être un nombre positif" if annee < 0
  @annee += 2000 if @annee < 100
end #/ check_annee
def check_heure
  raise "L'heure doit être un nombre entre 0 et 24" if heure < 0 || heure > 24
end #/ check_heure
def check_minutes
  raise "Les minutes doivent être un nombre entre 0 et 59" if minutes < 0 || minutes > 59
end #/ check_minutes
def check_seconds
  raise "Les secondds doivent être un nombre entre 0 et 59" if seconds < 0 || seconds > 59
end #/ check_seconds
end #/DateString
