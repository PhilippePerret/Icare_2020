# encoding: UTF-8
# frozen_string_literal: true
require 'fileutils'

# `wkhtmltopdf http://localhost/AlwaysData/Icare_2020/overview/policy ./atelier.pdf`

n = 19

case n
when 16.0..20.0 then puts "entre 20 et 16"
when 16.0...10.0 then puts "entre 16 et 10"
else
  puts "#{n.inspect} est un autre nombre"
end
