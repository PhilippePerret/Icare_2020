# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class ConcoursPhase
  ------------------
  Gestion d'un étape du concours
=end
class ConcoursPhase
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :concours, :data
def initialize(concours, data)
  @concours = concours
  @data = data
end #/ initialize

# ---------------------------------------------------------------------
#   Méthodes d'action
# ---------------------------------------------------------------------
def run_operations(options = nil)
  html.res << Tag.div(class:'etape-titre', text:"ÉTAPE #{numero}. #{name}")
  require_relative "./phase_operations/phase_#{data[:phase]}"
  # On joue toutes les opérations de l'étape, sauf celle décochées
  operations.each_with_index do |dop, idx|
    if dop.method?
      html.res << dop.name
      if options[:noop]
        html.res << "<div class='ml2'><input type='checkbox' name='operation_#{idx}' id='operation_#{idx}' CHECKED /><label for='operation_#{idx}'>Cette opération doit être exécutée</label></div>"
      else
        if param("operation_#{idx}".to_sym) != 'on'
          html.res << "<div class='ml2'>OPÉRATION NON EXÉCUTÉE</div>"
          next
        end
      end
    end
    dop.run(options)
  end
  # Si on opère pas, il faut mettre un bouton de confirmation, bouton de
  # demande d'opération effective.
  if options[:noop]
    # btn_proceed = Tag.link(route:"#{route}?current_phase=#{numero}&op=change_phase&doit=1", class:"btn", text:"Procéder à l'opération")
    # div_btn = Tag.div(class:"mt2 right", text: btn_proceed)
    # html.res << div_btn
    html.res << "<input type='hidden' name='current_phase' value='#{numero}' />"
    html.res << "<input type='hidden' name='op' value='change_phase' />"
    html.res << "<input type='hidden' name='doit' value='1' />"
    html.res << "<div class='buttons'><input type='submit' class='btn main' value='Procéder aux opérations cochées' /></div>"
  end
end #/ run_operations

# Méthode appelée à la fin du changement de phase pour voir si tout
# est OK
def checke
  message("Lancer 'icare test concours' en local pour tester que la phase est bien activée et conforme.")
end #/ checke

# ---------------------------------------------------------------------
#   Properties
# ---------------------------------------------------------------------
# Nom de l'étape
def name ; data[:name] end
def name_current ; data[:name_current] end
def name_done ; data[:name_done] end
def numero ; data[:phase] end
alias :phase :numero
alias :id :numero

def operations; data[:operations].collect{|dop|Operation.new(concours, self, dop)} end

# ---------------------------------------------------------------------
#
#   CLASSE Concours::Operation
#
# ---------------------------------------------------------------------
class Operation
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE Concours::Operation
#
# ---------------------------------------------------------------------
attr_reader :concours, :iphase, :data
attr_reader :name, :method, :info
def initialize(concours, iphase, data)
  @concours = concours
  @iphase = iphase
  @data = data
  @name = data[:name]
  @method = data[:method]
end #/ initialize
def run(options = nil)
  if method?
    send(method, options)
  elsif info?
    html.res << "🥁#{ISPACE}#{name}"
  end
end #/ run
def method?
  not method.nil?
end #/ method?
def info?
  data[:info] === true
end #/ info?
end #/Operation
end #/ConcoursPhase
