# encoding: UTF-8
# frozen_string_literal: true

UI_TEXTS  = {}
MESSAGES  = {}
ERRORS    = {}

DATA_OBJETS = {
  user:     {name: "User/Icarien"},
  module:   {name: "Module icarien"},
  etape:    {name: "Étape de module icarien"},
  document: {name: "Document d'étape"}
}
DATA_OBJETS.merge!(icarien: DATA_OBJETS[:user])

require './_lib/required/__first/extensions/Formate_helpers'
require './_lib/required/__first/ContainerClass_definition'
require './_lib/required/__first/db'
MyDB.online = true
MyDB.DBNAME = 'icare_db'

Dir["#{__dir__}/required/**/*.rb"].each{|m|require(m)}
Dir["#{__dir__}/objets/**/*.rb"].each{|m|require(m)}
