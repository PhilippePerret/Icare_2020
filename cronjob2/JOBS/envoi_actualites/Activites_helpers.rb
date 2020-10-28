# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module permettant de mettre en forme les mails
=end
class Cronjob

# *** Helpers pour les mails ***

# OUT   Code HTML de la section des actualités quotidiennes (en fait,
#       les actualités de la veille)
def section_actualites_quotidienne
  news = actualites_veille.collect{|d| Activite.new(d.values)}
  mise_en_forme_news(news)
end #/ section_actualites_quotidienne
# OUT   Code HTML de l'actualité de la semaine
def section_actualites_semaine
  news = actualites_semaine.collect{|d| Activite.new(d.values)}
  mise_en_forme_news(news)
end #/ section_actualites_semaine

def mise_en_forme_news(news)
  news.sort_by! { |activ| activ.created_at }
  puts "--- news: #{news.inspect}"
  str = []
  current_day = nil
  news.each do |activ|
    if activ.human_day != current_day
      current_day = activ.human_day
      str << "<div class=\"date-news\" style=\"\">#{current_day}</div>"
    end
    str << activ.out
  end
  return str.join("\n")
end #/ mise_en_forme_news

end #/Cronjob

Activite = Struct.new(:id, :type, :user_id, :message, :created_at) do
def out
  Tag.div(text: message, class:"message", style:"font-size:0.9em;")
end #/ out

def human_day
  @human_day ||= formate_date(created_at, jour:true)
end #/ human_day

end
