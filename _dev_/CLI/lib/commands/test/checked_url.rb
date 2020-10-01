# encoding: UTF-8
# frozen_string_literal: true
require 'capybara'
require 'capybara/dsl'

class CheckedUrl
  include Capybara::DSL

  # ---------------------------------------------------------------------
  #
  #   CLASSE
  #
  # ---------------------------------------------------------------------
  class << self
    attr_reader :start_time, :end_time
    # Initialisation
    def init
      @successs = []
      @failures = []
      @start_time = Time.now.to_f
    end #/ init

    # Affichage du rapport final
    def final_report
      @end_time = Time.now.to_f
      puts "=== RAPPORT FINAL ===#{RC}".bleu
      puts "Durée du test : #{test_duration} secs.".gris
      meth_color = @failures.count > 0 ? :rouge : :vert
      puts "#{RC}Succès #{@successs.count} Échec #{@failures.count} Pending 0".send(meth_color)
      puts RC * 2
      if @failures.count > 0
        puts "=== ERREURS RENCONTRÉES (#{@failures.count}) ===".rouge
        puts TABU + @failures.join(RC + TABU + '- ').rouge
        puts RC * 2
      end
    end #/ final_report

    def add_success(succ)
      @successs << succ
    end #/ add_success

    def add_failure(failure)
      @failures << failure
    end #/ add_failure

    def test_duration
      (end_time - start_time).round(2).to_s
    end #/ test_duration

  end # << self
  # ---------------------------------------------------------------------
  #
  #   INSTANCE
  #
  # ---------------------------------------------------------------------

  attr_reader :name, :route, :seek_and_do
  def initialize(data)
    @data = data
    data.each{|k,v|instance_variable_set("@#{k}",v)}
  end #/ initialize
  def tester
    if verbose?
      puts "🔬 Test de : #{name}#{" (#{route})" if route}".bleu
    end
    visit("#{URL_BASE}#{"/#{route}" if route}")
    exec_seek_and_do
  end #/ tester
  def exec_seek_and_do
    (seek_and_do||[]).each do |dsad|
      sad = SeekAndDo.new(dsad.merge(page: self))
      sad.exec
    end
  end #/ exec_seek_and_do

private
  def verbose?
    IcareCLI.verbose?
  end #/ verbose?

end #/CheckedUrl

class SeekAndDo
  include Capybara::DSL
  attr_reader :page, :data, :tag, :text, :doit, :not_tag
  attr_reader :silent, :success, :failure

  # ---------------------------------------------------------------------
  #
  #   Méthodes publiques utilisables dans les data YAML
  #
  # ---------------------------------------------------------------------
  def is_page_home_valid
    @tag = 'div#actualites'; @text = nil;
    search_tag
    @tag = 'div.citation'
    search_tag
    @tag = 'div#bandeau';
    search_tag
  end #/ is_page_home_valid

  def has_title(titre)
    @tag = 'head title'; @text = titre
    search_invisible_selector
  end #/ has_title

  # ---------------------------------------------------------------------
  #
  #   Méthodes normales
  #
  # ---------------------------------------------------------------------

  def initialize(data)
    @data = data
    data.each{|k,v|instance_variable_set("@#{k}",v)}
  end #/ initialize
  def exec
    if tag || text
      search_tag
    elsif not_tag
      search_not_tag
    elsif doit
      do_operation
    end
  end #/ exec

  def search_invisible_selector
    Capybara.match = :first
    if text && tag
      if page.has_selector?(tag, text: text, visible: false)
        affiche_success  "√ contient le sélecteur <#{tag}> avec le texte “#{text}”."
      else
        affiche_failure "✖︎ devrait contenir le sélecteur <#{tag}> avec le texte “#{text}”…"
      end
    end
  end #/ search_invisible_selector

  def search_tag
    Capybara.match = :first
    if text && tag
      if page.has_css?(tag, text: text)
        affiche_success "√ contient <#{tag}> avec le texte “#{text}”."
      else
        affiche_failure "✖︎ devrait contenir <#{tag}> avec le texte “#{text}”…"
      end
    elsif text
      if page.has_content?(text)
        affiche_success "√ contient le texte “#{text}”."
      else
        affiche_failure "✖︎ devrait contenir le texte “#{text}”…"
      end
    else
      if page.has_css?(tag)
        affiche_success "√ contient <#{tag}>."
      else
        affiche_failure "✖︎ devrait contenir <#{tag}>…"
      end
    end
  end #/ search_tag

  # Pour le test d'une balise qui ne doit pas se trouver dans la page
  def search_not_tag
    if page.has_css?(not_tag)
      affiche_failure "✖︎ ne devrait pas contenir <#{not_tag}>…"
    else
      affiche_success "√ ok, ne contient pas <#{not_tag}>."
    end
  end #/ search_not_tag

  def affiche_success(common_msg)
    msg = success || common_msg
    CheckedUrl.add_success(msg)
    return if silent
    affiche_message(msg, :vert)
  end #/ affiche_success

  def affiche_failure(common_msg)
    msg = failure || common_msg
    CheckedUrl.add_failure("# #{page.name} (#{page.route}) : #{msg}")
    affiche_message(msg, :rouge)
  end #/ affiche_failure

  def affiche_message(msg, meth_color)
    if verbose?
      puts "#{TABU}#{msg}".send(meth_color)
    else
      STDOUT.write ".".send(meth_color)
    end
  end #/ affiche_message

  def do_operation
    eval(doit)
  end #/ do_operation

private

  def verbose?
    IcareCLI.verbose?
  end #/ verbose?
end #/SeekAndDo
