# encoding: UTF-8
=begin
  Class FrigoDiscussion

=end
class FrigoDiscussion < ContainerClass

  # Requête pour obtenir toutes les discussion de l'user
  # TODO Pour le moment, elles sont classées par ordre de création inverse
  # (les plus récentes en premier), plus tard, on pourra mettre en premier
  # celles qui ont reçu le dernier message.
  REQUEST_DISCUSSIONS_USER = <<-SQL.freeze
  SELECT
    dis.titre AS titre, dis.id AS discussion_id, u.pseudo AS owner_pseudo
    FROM #{TABLE_USERS} AS fu
    INNER JOIN `frigo_discussions` AS dis ON dis.id = fu.discussion_id
    INNER JOIN `users` AS u ON dis.user_id = u.id
    WHERE fu.user_id = %i
    ORDER BY dis.created_at DESC
  SQL
class << self

  # Retourne la liste (formatée) des discussions de l'icarien (ou moi)
  # d'identifiant +user_id+
  # +user_id+   {Integer|User} Soit l'identifiant de l'utilisateur soit lui-même
  def discussions_of user_id
    user_id = user_id.id if user_id.is_a?(User)
    db_exec(REQUEST_DISCUSSIONS_USER % [user_id]).collect do |ddis|
      Tag.lien(route:"bureau/frigo?disid=#{ddis[:discussion_id]}", text:"#{ddis[:titre]} <span class='small'>##{ddis[:discussion_id]}</span>", class:'block')
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
      # TODO
      discussion = get(discussion_id)
      discussion.owner?(user) || raise(ERRORS[:destroy_require_owner])
      discussion.destroy
    end
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

# Retourne l'instance {User} de l'instigateur de la discussion
def owner
  @owner ||= User.get(user_id)
end #/ owner

# Retourne TRUE si +who+ est bien le créateur de la discussion
def owner?(who)
  return who.id == user_id
end #/ owner?

# Destruction complète de la discussion
# -------------------------------------
# Cela consiste à :
#  - détruire l'enregistrement dans frigo_discussions
#  - détruire les participations dans frigo_users
#  - détruire tous les messages dans frigo_messages
#  - avertir tous les participants de la suppression
def destroy
  msg = <<-HTML.freeze
<p>%s,</p>
<p>Je vous informe de #{owner.pseudo} vient de détruire la discussion “#{titre}” à laquelle vous participiez.</p>
<p>Bien à vous,</p>
<p>🤖 Le Bot de l'Atelier Icare 🦋</p>
  HTML
  participants.each do |participant|
    participant.send_mail(subject:"Suppression de discussion", message: msg % participant.pseudo)
  end
  [
    "DELETE FROM #{FrigoDiscussion::TABLE_DISCUSSIONS} WHERE id = #{id}".freeze,
    "DELETE FROM #{FrigoDiscussion::TABLE_USERS} WHERE discussion_id = #{id}".freeze,
    "DELETE FROM #{FrigoDiscussion::TABLE_MESSAGES} WHERE discussion_id = #{id}".freeze
  ].each do |request|
    db_exec(request)
  end
end #/ destroy

# Pour ajouter un message
# +params+
#   :auteur   {User} Instance de l'user qui envoie le message
#   :message  {String} Le message proprement dit (non vérifié)
def add_message(params)
  msg = params[:message].nil_if_empty
  msg || raise(ERRORS[:message_discussion_required])
  msg.length < 12000 || raise(ERRORS[:message_frigo_too_long])
  msg.length > 2 || raise(ERRORS[:message_frigo_too_short])
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

SUBJECT_NEW_MESSAGE = 'Nouveau message de %s sur votre frigo'.freeze
MESSAGE_NEW_MESSAGE = <<-HTML.freeze
<p>Bonjour %{pseudo},</p>
<p>Je vous informe que %{from} vient de laisser un message sur votre frigo concernant la discussion “%{titre}”.</p>
<p>Vous pouvez #{Tag.lien(route:'bureau/frigo?disid=%{disid}', full:true, text:'rejoindre cette discussion')}  sur votre frigo.</p>
<p>Bien à vous,</p>
<p>🤖 Le Bot de l'Atelier Icare 🦋</p>
HTML
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

SUBJECT_INVITATION = "Invitation à rejoindre une discussion"
MESSAGE_INVITATION = <<-HTML.freeze
<p>Bonjour %{pseudo},</p>
<p>Excusez-moi de vous déranger, mais %{owner} vous invite à rejoindre sa discussion “%{titre}”.</p>
<p>Pour participer à cette discussion, cliquer sur le bouton ci-dessous :</p>
<p style="text-align:center;">%{lien_participer}</p>
<p>Pour décliner cette invitation, il suffit de cliquer le bouton ci-dessous</p>
<p style="text-align:center">%{lien_decliner}</p>
<p>Bien à vous,</p>
<p>🤖 Le Bot de l’Atelier Icare 🦋</p>
HTML

# La requête pour créer un nouveau lien entre un user et une discussion (donc
# pour ajouter l'icarien/admin à la discussion) en vérifiant que ce lien
# n'existe pas déjà.
REQUEST_ADD_TO_DISCUSSION = <<-SQL.freeze
  INSERT INTO `#{FrigoDiscussion::TABLE_USERS}`
    (user_id, discussion_id, last_checked_at, created_at, updated_at)
  VALUES (?, ?, ?, ?, ?)
  ON DUPLICATE KEY UPDATE user_id = user_id -- peu importe
SQL

# Pour envoyer des invitations à rejoindre une discussion
# En fait, cela revient à les ajouter à la discussion et leur envoyer un
# message d'invitation.
def send_invitations_to(icariens)
  nombre_icariens = icariens&.count
  return erreur(ERRORS[:invites_required]) if nombre_icariens.to_i == 0
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
  message("#{nombre_icariens} icarien·ne·#{s} ont été invité#{es} à rejoindre la discussion “#{titre}” : #{pseudos.pretty_join}.".freeze)
end #/ send_invitations_to

# Retourne la liste des participants à cette discussion (Array de User(s))
def participants
  @participants ||= begin
    db_exec("SELECT user_id FROM #{FrigoDiscussion::TABLE_USERS} WHERE discussion_id = #{id}".freeze).collect do |ddis|
      User.get(ddis[:user_id])
    end
  end
end #/ participants

# La méthode retourne TRUE si +part+ {User} est un participant à la discussion
def participant?(part)
  return db_count(FrigoDiscussion::TABLE_USERS, {user_id:part.id, discussion_id:self.id}) > 0
end #/ participant?

# = main =
#
# Affichage de la discussion
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
  liste = messages
  liste = liste.reverse if options[:inverse]
  liste = liste.collect { |message| message.out(options) }.join
  Tag.div(text: liste, class:'messages-discussion')
end #/ liste_messages_formated


# Retourne le code de la discussion pour téléchargement
def for_download(options = nil)
  lines = []
  lines << "=== DISCUSSION ATELIER ICARE ##{id} ===#{RC}=".freeze
  lines << "= Instiga#{owner.fem(:trice)} : #{owner.pseudo}".freeze
  lines << "= Entre : #{participants.collect{|u|u.pseudo}.pretty_join}".freeze
  lines << "= Date : #{formate_date}".freeze
  lines << RC2
  messages.each do |message|
    lines << "#{message.auteur.pseudo.upcase}, #{formate_date(message.created_at,{hour:true})}#{RC}#{message.content}#{RC}"
  end
  lines << RC2
  lines << "==== ©#{Time.now.year} Atelier Icare http://www.atelier-icare.net ==="
  return lines.join(RC)
end #/ for_download

# Retourne les messages de la discussion, par order
REQUEST_GET_MESSAGES = 'SELECT * FROM `frigo_messages` WHERE discussion_id = %i ORDER BY `created_at`'.freeze
def messages
  @messages ||= begin
    db_exec(REQUEST_GET_MESSAGES % [id]).collect do |dmes|
      fmsg = FrigoMessage.instantiate(dmes)
      fmsg.discussion = self # sert à incrémenter le nombre de messages non lus
      fmsg
    end
  end
end #/ messages
end #/FrigoDiscussion < ContainerClass
