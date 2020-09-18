# encoding: UTF-8
# frozen_string_literal: true
require_module('frigo')
class Watcher < ContainerClass
  def destroy
    # On met de côté les informations qui vont servir pour le mail au
    # propriétaire de la discussion
    discussion = objet
    @date_destruction = formate_date(created_at)
    @discussion_titre = discussion.titre
    discussion.destroy
    message(MESSAGES[:confirm_discussion_destroyed])
  end # / destroy

  def contre_destroy
    message(MESSAGES[:cancel_destroying_discussion])
  end #/ contre_destroy

  def discussion_titre ; @discussion_titre end
  def date_destruction ; @date_destruction end

end # /Watcher < ContainerClass
