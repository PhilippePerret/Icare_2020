# encoding: UTF-8
=begin
  Requis par le module essai ou les modules de ce dossier
=end
SANDBOX = true
require './_lib/required'

FOLDER_SQL_GOODS_FOR_2020 = File.join('/','Users','philippeperret','Sites','AlwaysData','xbackups','Goods_for_2020')
`mkdir -p "#{FOLDER_SQL_GOODS_FOR_2020}"` unless File.exists?(FOLDER_SQL_GOODS_FOR_2020)
