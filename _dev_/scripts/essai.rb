# encoding: UTF-8
# frozen_string_literal: true
VG = ','
ONLINE = false
require './_dev_/_VERSION_2020_/_GET_OLD_DATA_/xlib/required/db'

MyDB.DBNAME = 'icare'
lines = []
db_exec("SELECT id, pseudo, options FROM users WHERE id IN (33,66,71,27,34,100)").each do |du|
  opts = du[:options].dup
  opts[0] = '0'
  opts[3] = '1'
  puts "Pour #{du[:pseudo]} :"
  puts "init: #{du[:options]}"
  puts "now : #{opts}"
  du[:options] = opts
  lines << "UPDATE users SET options = '#{opts}' WHERE ID = #{du[:id]};"
end

puts lines.join("\n")
