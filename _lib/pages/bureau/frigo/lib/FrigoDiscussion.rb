# encoding: UTF-8
=begin
  Class FrigoDiscussion

=end
class FrigoDiscussion < ContainerClass

class << self

  # Retourne la liste (formatée) des discussions de l'icarien (ou moi)
  # d'identifiant +user_id+
  # +user_id+   {Integer|User} Soit l'identifiant de l'utilisateur soit lui-même
  def discussions_of user_id
    user_id = user_id.id if user_id.is_a?(User)
    infos_discussions = db_exec(REQUEST_DISCUSSIONS_USER % [user_id])
    if MyDB.error
      return log(MyDB.error)
    end
    infos_discussions.collect do |ddis|
      has_new_messages = ddis[:has_new_messages] == 1
      mark_own = ddis[:owner_id] == user.id ? 'vous' : ddis[:owner_pseudo]
      Tag.lien(class: "block#{(has_new_messages ? ' mark-new' : '')}", route:"bureau/frigo?disid=#{ddis[:discussion_id]}", text:"#{ddis[:titre]}<span class='small ml1'>##{ddis[:discussion_id]}#{SPACE}(initiée par #{mark_own})</span>")
    end.join
  end #/ discussions_of

  def download_discussion(discussion_id)
    discussion = get(discussion_id)
    # L'user doit participer à cette discussion ou être administrateur
    discussion.participant?(user) || user.admin? || raise(ERRORS[:not_a_participant])

    folder_discussion_name  = "discussion-#{discussion_id}".freeze
    discussion_zip_name     = "#{folder_discussion_name}.zip".freeze
    discussion_zip_file     = File.join(DOWNLOAD_FOLDER, discussion_zip_name)
    File.unlink(discussion_zip_file) if File.exists?(discussion_zip_file)
    path_folder_discussion  = File.join(TEMP_FOLDER, folder_discussion_name)

    FileUtils.rm_rf(path_folder_discussion) if File.exists?(path_folder_discussion)
    `mkdir -p "#{path_folder_discussion}"`
    path_file_discussion = File.join(path_folder_discussion,'discussion.txt')
    File.open(path_file_discussion,'wb') do |f|
      f.write(discussion.for_download)
    end

    # Fenêtre de chargement
    download(path_folder_discussion, discussion_zip_name)
    # Note : on reste sur la même page
  end #/ download


  def destroy(discussion_id)
    unless param(:confirmed)
      return message("Vous devez confirmer la destruction de la discussion".freeze)
    end
    form = Form.new
    if form.conform?
      # L'user doit être le possesseur de cette discussion
      discussion = get(discussion_id)
      discussion.owner?(user) || raise(ERRORS[:destroy_require_owner])
      discussion.destroy
    end
  rescue Exception => e
    log(e)
    erreur(e.message)
  end #/ destroy
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Nombre de messages non lus
# Bien comprendre, ici, qu'il s'agit d'un nombre qui dépend directement
# de l'icarien (ou l'admin) pour lequel on affiche la liste. Cet icarien est
# indiqué dans la propriét :for des +options+ envoyées à la méthode `out`
attr_accessor :nombre_non_lus

# Retourne TRUE si +who+ est bien le créateur de la discussion
def owner?(who)
  return who.id == user_id
end #/ owner?

# Annonce la destruction de la discussion et préviens les participants
# pour qu'ils puissent la charger
# Rappel : seul l'administrateur peut détruire une discussion. Lorsque son
# propriétaire la détruit
# Cette méthode envoie un mail à chaque participant
# et produit un watcher qui me permettra de détruire la discussion.
def annonce_destruction
  require_module('watchers')
  participants.each do |follower|
    next if follower.id == owner.id # Pas d'avertissement pour le propriétaire
    follower.send_mail(subject: SUBJECT_ANNONCE_DESTROY, message: (MESSAGE_ANNONCE_DESTROY % {pseudo: follower.pseudo, titre:titre, id:id, owner_pseudo: owner.pseudo}))
  end
  owner.watchers.add('destroy_discussion', {objet_id:id, triggered_at:Time.now.to_i + 7.days})
  message("La destruction de la conversation “#{titre}” a été annoncée aux participants. Elle sera effectivement détruite dans une semaine.")
end #/ annonce_destruction

# Pour ajouter un message
# +params+
#   :auteur   {User} Instance de l'user qui envoie le message
#   :message  {String} Le message proprement dit (non vérifié)
def add_message(params)
  msg = params[:message].nil_if_empty
  msg || raise(ERRORS[:message_discussion_required])
  msg.length < 12000 || raise(ERRORS[:message_frigo_too_long])
  msg.length > 2 || raise(ERRORS[:message_frigo_too_short])
  # Pour forcer l'actualisation
  @all_messages = nil
  @messages = nil
  # On crée le message
  msg_id = db_compose_insert(FrigoDiscussion.table_messages, {discussion_id:id, user_id: params[:auteur].id, content:msg})
  # On indique l'ID du dernier message de la discussion
  db_compose_update(FrigoDiscussion.table, id, {last_message_id: msg_id})
  # On doit avertir les suiveurs de la discussion
  notify_followers(but: params[:auteur])
  # Si c'est OK, on vide le champ pour ne pas répéter le message
  param(:frigo_message, '')
rescue Exception => e
  erreur(e.message)
end #/ add_message

# Pour notifier les participants à cette discussion qu'un nouveau message
# a été envoyé
# +params+
#   :but    {User}  Les prévenir tous sauf celui-ci, qui est l'auteur du message
#
def notify_followers(params)
  participants.each do |part|
    next if params[:but].id == part.id
    # - Il ne faut pas l'avertir s'il ne l'a pas demandé
    next if part.option(22) != 1 # pas de notification
    # - Il ne faut pas l'avertir s'il a déjà un message précédent pour ce fil
    next if part.has_message_non_lu_before_last?(self)
    part.send_mail({
      subject:(SUBJECT_NEW_MESSAGE % user.pseudo),
      message:(MESSAGE_NEW_MESSAGE % {pseudo:part.pseudo, from:user.pseudo, titre:titre, disid:self.id})
    })
    message(MESSAGES[:follower_warned_for_new_message] % part.pseudo)
  end
end #/ notify_followers

# Pour envoyer des invitations à rejoindre une discussion
# En fait, cela revient à les ajouter à la discussion et leur envoyer un
# message d'invitation.
def send_invitations_to(icariens)
  return erreur(ERRORS[:invites_required]) if icariens.nil?
  icariens = [icariens] unless icariens.is_a?(Array)
  nombre_icariens = icariens.count
  return erreur(ERRORS[:invites_required]) if nombre_icariens == 0
  nombre_hommes = 0
  lien_participer = Tag.lien(route:"bureau/frigo?disid=#{self.id}", full:true, text:'Lire la discussion'.freeze)
  lien_decliner   = Tag.lien(route:"bureau/frigo?op=decliner_invitation&did=#{self.id}", full:true, text:'Décliner cette invitation'.freeze)
  ary_values = []
  pseudos = []
  now = Time.now.to_i
  icariens.each do |iid|
    ica = User.get(iid.to_i)
    nombre_hommes += 1 unless ica.femme?
    ica.send_mail(subject:SUBJECT_INVITATION, message:(MESSAGE_INVITATION % {pseudo:ica.pseudo, owner:user.pseudo, titre:self.titre, disid:self.id, lien_participer:lien_participer, lien_decliner:lien_decliner}))
    ary_values << [ica.id, self.id, now - 100, now, now]
    pseudos << ica.pseudo
  end
  # On envoie toutes les requêtes pour créer les données
  db_exec(REQUEST_ADD_TO_DISCUSSION, ary_values)

  s = nombre_icariens > 1 ? 's' : ''
  es = nombre_icariens > 1 ? (nombre_hommes > 0 ? 's' : 'es') : ''
  a_ete = nombre_icariens > 1 ? 'ont été' : 'a été'
  message("#{nombre_icariens} icarien·ne·#{s} #{a_ete} invité#{es} à rejoindre la discussion “#{titre}” : #{pseudos.pretty_join}.".freeze)
  @participants = nil
  @anciens_participants = nil
  @auteurs_messages = nil
end #/ send_invitations_to

# La méthode retourne TRUE si +part+ {User} est un participant à la discussion
def participant?(part)
  return db_count(FrigoDiscussion::TABLE_USERS, {user_id:part.id, discussion_id:self.id}) > 0
end #/ participant?

# = main =
#
# Affichage de la discussion
# --------------------------
#
# +options+
#   :for        {User} L'user pour lequel on doit afficher la discussion. Par
#               défaut c'est utilisateur courant.
#   :ordre      :inverse/:chrono    Affichage inverse (dernier message au-dessus) ou chronologique
#   :from       Time. Seulement depuis ce temps
#   :new_from   {Time} Les nouveaux seront signalés à partir de cette date
#               Note : c'est le `last_checked_at` de l'user sur la discussion.
def out(options = nil)
  options ||= {}
  options[:for] ||= user
  self.nombre_non_lus = 0
  content = Tag.div(text:titre, class:'titre-discussion') + liste_messages_formated(options)
  Tag.div(text: content, class:'discussion')
end #/ out

def liste_messages_formated(options)
  liste = messages(false)
  liste = liste.reverse if options[:inverse]
  # S'il y a plus de deux participants, il faut indiquer les autres participants
  # par une couleur particulière. Ce sera la propriété :color_discussion pour
  # l'auteur.
  if auteurs_messages.count > 2
    auteurs_messages.each do |auteur|
      next if auteur.id == user.id
      auteur.color_discussion = "rgb(#{rand(255)},#{rand(255)},#{rand(255)})"
    end
  end
  liste = liste.collect { |message| message.out(options) }.join
  Tag.div(text: liste, class:'messages-discussion')
end #/ liste_messages_formated

# Retourne la liste des participants en indiquant ceux qui ont quitté
# discussion depuis
def liste_complete_participants
  lp = participants.collect{|u|u.pseudo}.pretty_join
  unless anciens_participants.empty?
    lp << " (ex #{anciens_participants.collect{|u|u.pseudo}.pretty_join})"
  end
  lp
end #/ liste_complete_participants

# Retourne le code de la discussion pour téléchargement
def for_download(options = nil)
  lines = []
  lines << "=== DISCUSSION ATELIER ICARE ##{id} ===#{RC}=".freeze
  lines << "= Instiga#{owner.fem(:trice)} : #{owner.pseudo}".freeze
  lines << "= Entre : #{participants.collect{|u|u.pseudo}.pretty_join}".freeze
  lines << "= Date : #{formate_date}".freeze
  lines << RC2
  messages(true).each do |message|
    lines << "#{message.auteur.pseudo.upcase}, #{formate_date(message.created_at,{hour:true})}#{RC}#{message.content}#{RC}"
  end
  lines << RC2
  lines << "==== ©#{Time.now.year} Atelier Icare http://www.atelier-icare.net ==="
  return lines.join(RC)
end #/ for_download

# Retourne les messages de la discussion, par order
def messages(all = false)
  prop, request = all ? [:all_messages, REQUEST_GET_ALL_MESSAGES] : [:messages, REQUEST_GET_MESSAGES]
  instance_variable_get("@#{prop}") || begin
    msgs = db_exec(request % [id]).collect do |dmes|
      fmsg = FrigoMessage.instantiate(dmes)
      fmsg.discussion = self # sert à incrémenter le nombre de messages non lus
      fmsg
    end
    msgs.reverse! unless all
    instance_variable_set("@#{prop}", msgs)
  end
  instance_variable_get("@#{prop}")
end #/ messages

end #/FrigoDiscussion < ContainerClass
