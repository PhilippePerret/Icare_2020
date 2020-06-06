# encoding: UTF-8
=begin
  Pour faire des essais ruby
=end
require_relative 'required'

require_module('absmodules')
require_module('icmodules')

mod = AbsModule.get(4)
eta = mod&.get_absetape_by_numero(1)

puts "Module #{mod&.name} / Nom étape : #{eta&.titre.inspect}"
