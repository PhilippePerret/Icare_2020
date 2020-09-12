# encoding: UTF-8
=begin
  Extension de la classe Time
=end
class Time
class << self

  # Retourne le temps à distance de +params+ de maintenant
  #
  # +params+
  #   :months   Nombre de mois
  #   :days     Nombre de jours
  #   :years    Nombre d'années
  #
  # Retourne une instance Time
  def ilya(params)
    now = Time.now
    year = now.year   - (params[:years] ? params[:years] : 0)
    mois = now.month  - (params[:months] ? params[:months] : 0)
    jour = now.day    - (params[:days] ? params[:days] : 0)
    unless params[:hours].nil?
      heure = now.hour - (params[:hours] ? params[:hours] : 0)
    else
      heure = 0
    end
    unless params[:minutes].nil?
      minutes = now.min
    else
      minutes = 0
    end

    Time.new(year, mois, jour, heure, minutes)
  end #/ ilya
end # /<< self
end #/Time

if $0 == __FILE__
  require 'minitest/autorun'
  describe "Un jour avant" do
    it "retourne la bonne valeur" do
      n = Time.now
      ilya1jour = Time.new(n.year,n.month, n.day-1).to_i
      assert_equal(Time.ilya(days:1).to_i, ilya1jour)
    end
  end
  describe "Deux jours avant" do
    it "retourne la bonne valeur" do
      n = Time.now
      ilya1jour = Time.new(n.year,n.month, n.day-2).to_i
      assert_equal(Time.ilya(days:2).to_i, ilya1jour)
    end
  end
  describe "Un mois avant" do
    it "retourne la bonne valeur" do
      n = Time.now
      ilya1jour = Time.new(n.year,n.month-1, n.day).to_i
      assert_equal(Time.ilya(months:1).to_i, ilya1jour)
    end
  end
  describe "Un an avant" do
    it "retourne la bonne valeur" do
      n = Time.now
      ilya1jour = Time.new(n.year-1,n.month, n.day).to_i
      assert_equal(Time.ilya(years:1).to_i, ilya1jour)
    end
  end
end
