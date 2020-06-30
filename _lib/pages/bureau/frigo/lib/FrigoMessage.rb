# encoding: UTF-8
=begin
  Class FrigoMessage
  ------------------
  Pour les messages des discussions
=end
class FrigoMessage < ContainerClass
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
def out(options = nil)
  Tag.div(text:content_formated, class:"fmessage #{user_auteur? ? 'mright' : 'mleft'}")
end #/ out

def content_formated
  Tag.div(text:auteur_formated + date_formated, class:'infos') +
  Tag.div(text:content.gsub(/\n/,'<br/>'), class:'content')
end #/ content_formated

def user_auteur?
  @user_is_auteur = auteur.id == user.id if @user_is_auteur === nil
  @user_is_auteur
end #/ user_auteur?

def auteur_formated
  @auteur_formated ||= begin
    Tag.span(text: (user_auteur? ? 'Vous' : auteur.pseudo).freeze, class:'auteur')
  end
end #/ auteur_formated
def date_formated
  @date_formated ||= begin
    Tag.span(text:", le #{formate_date(created_at,{hour:true})}", class:'date small')
  end
end #/ date_formated

def auteur
  @auteur ||= User.get(user_id)
end #/ auteur
end #/FrigoMessage
