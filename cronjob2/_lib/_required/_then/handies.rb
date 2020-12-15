# encoding: UTF-8
# frozen_string_literal: true

# Pour charger complètement la classe User dont certains modules ont
# besoin
def require_user_class
  require File.join(APP_LIB_FOLDER,'required','__first','ContainerClass_definition')
  Dir["#{APP_LIB_FOLDER}/required/_classes/_User/**/*.rb"].each{|m| require m}
end #/ require_user_class
