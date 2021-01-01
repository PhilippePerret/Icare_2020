# encoding: UTF-8
# frozen_string_literal: true
class String

  # ---------------------------------------------------------------------
  #
  #   CLASSE
  #
  # ---------------------------------------------------------------------
  class << self

    # Utiliser :
    #
    #   String.safe(<str>)
    #
    # pour encoder de façon sûr (enfin… presque…)
    def safe(str)
      str.dup.force_encoding('utf-8')
    end #/ safe

    # Pour obtenir un nom de fichier "sûr", mais avec tous les caractères
    # problématiques remplacés par des '@'
    #
    # @usage
    #
    #   res = String.safe_path(str)
    #
    def safe_path(str)
      safe(str).gsub(/[^a-zA-Z_\.0-9\-]/,'@')
    end #/ safe_path

  end #<< self

  # ---------------------------------------------------------------------
  #
  #   INSTANCE
  #
  # ---------------------------------------------------------------------

  def numeric?
    Float(self) != nil rescue false
  end

  def nil_if_empty
    if self.strip == ''
      nil
    else
      self
    end
  end

  def sanitize
    self.gsub(/\r\n/, "\n")
  end #/ sanitize

  def titleize
    str = self.dup.downcase
    str[0] = str[0].upcase
    str
  end #/ titleize

  def patronimize
    self.split(' ').collect { |m| m.titleize }.join(' ')
  end #/ patronimize

  def camelize
    self.split('_').collect{|m| m.titleize}.join('')
  end #/ camelize

  # Supprime toutes les balises HTML (pour les textes donnés)
  def safetize
    self.gsub(/<(.+?)>/, EMPTY_STRING)
  end #/ safetize

end #/String
