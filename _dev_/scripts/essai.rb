# encoding: UTF-8
# frozen_string_literal: true

require './_lib/required/__first/extensions/Hash'

h = {
  un: {un_un: {un_un_un: "pour voir"}}
}

newh = {un: { un_un: {deux_deux: "Pour voir les deux" } } }
h1 = h.dup
h2 = h.dup

h1.merge!(newh)
h2.smart_merge!(newh)

puts h1.inspect
puts h2.inspect
