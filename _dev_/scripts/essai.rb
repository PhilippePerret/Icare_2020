# encoding: UTF-8
# frozen_string_literal: true
require './_lib/required/__first/extensions/HTMLHelper'

table = HTMLHelper::Table.new(id: 'ma-table')
table << ['pour', 'voir']
table << ['et', 'revoir']

puts table.output
