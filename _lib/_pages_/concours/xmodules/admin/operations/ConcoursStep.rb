# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class ConcoursStep
  ------------------
  Gestion d'un étape du concours
=end
class ConcoursStep
class << self

end # /<< self
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
  html.res << Tag.div(class:'etape-titre', text:"ÉTAPE #{numero}. #{name_current}")
  require_relative "./step_operations/step_#{data[:step]}"
  operations.each { |dop| dop.run(options) }
  if options[:noop]
    btn_proceed = Tag.link(route:"#{route}?#{options[:query_string]}", class:"btn", text:"Procéder à l'opération")
    div_btn = Tag.div(class:"mt2 right", text: btn_proceed)
    html.res << div_btn
  end
end #/ run_operations
# ---------------------------------------------------------------------
#   Properties
# ---------------------------------------------------------------------
# Nom de l'étape
def name ; data[:name] end
def name_current ; data[:name_current] end
def name_done ; data[:name_done] end
def numero ; data[:step] end
alias :step :numero
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
attr_reader :concours, :istep, :data
attr_reader :name, :method, :info
def initialize(concours, istep, data)
  @concours = concours
  @istep = istep
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
end #/ConcoursStep
