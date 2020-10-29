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
  news = actualites_veille.collect{|d| Activite.new(*d.values)}
  mise_en_forme_news(news)
end #/ section_actualites_quotidienne
# OUT   Code HTML de l'actualité de la semaine
def section_actualites_semaine
  news = actualites_semaine.collect{|d| Activite.new(*d.values)}
  mise_en_forme_news(news)
end #/ section_actualites_semaine

def mise_en_forme_news(news)
  news.sort_by! { |activ| activ.created_at }
  # Logger << "--- news: #{news.inspect}"
  str = []
  current_day = nil
  news.each do |activ|
    if activ.human_day != current_day
      current_day = activ.human_day
      str << "<div class=\"date-news\" style=\"#{date_news_style}\">#{current_day}</div>"
    end
    str << activ.out
  end
  return "<fieldset>#{str.join("\n")}</fieldset>"
end #/ mise_en_forme_news

def date_news_style
  @date_news_style ||= "font-weight:bold;text-align:center;margin-top:1em;margin-bottom:0.5em;"
end #/ date_news_style

end #/Cronjob

Activite = Struct.new(:id, :type, :user_id, :message, :created_at) do
def out
  "<li class=\"activite\" style=\"font-size:0.9em;margin-left:1.5em;\">#{message}</li>"
end #/ out

def human_day
  @human_day ||= formate_date(created_at, jour:true)
end #/ human_day

end
