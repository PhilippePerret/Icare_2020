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

# Instance discussion du message, qui est stipulé explicitement pour le
# moment (on pourrait aussi utiliser FrigoDiscussion.get(discussion_id) mais
# je ne suis pas certain que les autres méthodes obtiennent la même instance…)
attr_accessor :discussion

# Retourne le div du message formaté.
# +options+
#   :for    {User} Le follower pour lequel on doit afficher le message.
#           Si le message n'est pas de lui et que sa date de création est
#           supérieur à la date de dernier check de cette discussion, on met
#           le message en exergue.
def out(options)
  @user_is_auteur = user_id == options[:for].id
  css = ['fmessage'.freeze]
  css << (user_auteur? ? 'mright' : 'mleft')
  if !user_auteur? && created_at > options[:last_check]
    css << 'exergue'.freeze
    # Incrémenter le nombre de messages non lu
    discussion.nombre_non_lus += 1
  end
  Tag.div(text:content_formated, class:css.join(SPACE))
end #/ out

# Renvoie true si l'auteur qui visualise la discussion est l'auteur du
# message courant.
def user_auteur? ; @user_is_auteur end

def content_formated
  Tag.div(text:auteur_formated + date_formated, class:'infos') +
  Tag.div(text:content.gsub(/\n/,'<br/>'), class:'content')
end #/ content_formated


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

# L'auteur du message
def auteur
  @auteur ||= User.get(user_id)
end #/ auteur
end #/FrigoMessage
