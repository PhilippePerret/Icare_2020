# encoding: UTF-8
# frozen_string_literal: true
=begin
  Requis pour la commande db qui permet de lire des
  données en base de données (distantes par défaut)
=end
require './_lib/required/__first/ContainerClass_definition' #  => ContainerClass
require './_lib/required/__first/db'  # => MyDB
# require './_lib/required/__first/extensions/Formate_helpers' # formate_date
# require './_lib/required/__first/extensions/Time'

require_relative './String_CLI'

MyDB.DBNAME = "icare_db"
MyDB.online = true
