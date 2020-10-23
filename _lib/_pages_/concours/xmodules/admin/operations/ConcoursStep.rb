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
  concours.res << "ÉTAPE #{data[:name_current]}"
  require_relative "./step_operations/step_#{data[:step]}"
  operations.each { |dop| dop.run(options) }
end #/ run_operations
# ---------------------------------------------------------------------
#   Properties
# ---------------------------------------------------------------------
# Nom de l'étape
def name ; data[:name] end
def name_current ; data[:name_current] end
def name_done ; data[:name_done] end

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
    send(method)
  elsif info?
    concours.res << "🥁#{ISPACE}#{name}"
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
