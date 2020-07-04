# encoding: UTF-8
=begin
  Constantes propres à la section Frigo du bureau
=end
require './_lib/required/__first/helpers/Tag.rb'

class FrigoDiscussion < ContainerClass

# Requête pour obtenir toutes les discussion de l'user
REQUEST_DISCUSSIONS_USER = <<-SQL.freeze
SELECT
  dis.titre AS titre, dis.id AS discussion_id, u.pseudo AS owner_pseudo,
  u.id AS owner_id,
  fm.created_at > fu.last_checked_at AS has_new_messages
  FROM #{TABLE_USERS} AS fu
  INNER JOIN #{TABLE_DISCUSSIONS} AS dis ON dis.id = fu.discussion_id
  INNER JOIN #{TABLE_MESSAGES} AS fm ON dis.last_message_id = fm.id
  INNER JOIN `users` AS u ON dis.user_id = u.id
  WHERE fu.user_id = %i
  -- GROUP BY dis.id
  ORDER BY fm.created_at DESC
SQL

# Pour un mail de notification de nouveau message frigo
SUBJECT_NEW_MESSAGE = 'Nouveau message de %s sur votre frigo'.freeze
MESSAGE_NEW_MESSAGE = <<-HTML.freeze
<p>Bonjour %{pseudo},</p>
<p>Je vous informe que %{from} vient de laisser un message sur votre frigo concernant la discussion “%{titre}”.</p>
<p>Vous pouvez #{Tag.lien(route:'bureau/frigo?disid=%{disid}', full:true, text:'rejoindre cette discussion')}  sur votre frigo.</p>
<p>Bien à vous,</p>
<p>🤖 Le Bot de l'Atelier Icare 🦋</p>
HTML

# Pour un message d'invitation à participer à une conversation
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

# Les requêtes pour obtenir les messages (tous ou les 40 derniers)
REQUEST_GET_ALL_MESSAGES = 'SELECT * FROM `frigo_messages` WHERE discussion_id = %i ORDER BY `created_at`'.freeze
REQUEST_GET_MESSAGES = 'SELECT * FROM `frigo_messages` WHERE discussion_id = %i ORDER BY `created_at` DESC LIMIT 40'.freeze

SUBJECT_ANNONCE_DESTROY = 'Destruction d’une discusion à laquelle vous participez'
MESSAGE_ANNONCE_DESTROY = <<-HTML.freeze
<p>%{pseudo},</p>
<p>Je vous annonce par la présente que la discussion “%{titre}” instiguée par %{owner_pseudo} à laquelle vous participez va être supprimée dans une semaine.</p>
<p>Si vous voulez en conserver une trace, #{Tag.lien(route:'bureau/frigo&disid=%{id}', text:'vous pouvez la télécharger', full:true)} grâce au bouton “Télécharger” placée en dessous de cette discussion.</p>
<p>Bien à vous,</p>
<p>🤖 Le Bot de l'atelier Icare 🦋</p>
HTML
end #/FrigoDiscussion < ContainerClass
