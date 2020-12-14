# encoding: UTF-8
# frozen_string_literal: true
class Admin::Operation
def travail_propre
  require_modules(['user/modules','mail'])
  msg = []
  owner.actif? || raise('On ne peut définir le travail propre que d’un icarien actif, voyons !')

  if long_value.nil?
    # Si le travail propre est nil, c'est qu'il faut le charger
    @long_value = owner.icetape.travail_propre
    if @long_value.nil?
      msg << "Il n'y a pas de travail propre défini pour l'étape courante de #{owner.pseudo}."
    else
      param(long_value: @long_value)
      msg << "Le travail propre a été chargé et mis dans le champ pour édition."
    end
  else
    if simulation?
      msg << "Je dois définir le travail propre de l'étape ##{owner.icetape.id}"
    else
      owner.icetape.set(travail_propre: long_value)
      msg << "Le travail propre a été défini pour #{owner.pseudo}."
      msg << "Pour le voir, il suffit de visiter comme… #{owner.pseudo} depuis le bureau."
    end

    if simulation?
      msg << "#{owner.pseudo} reçoit le mail suivant : #{message_annonce_travail_propre}"
    else
      owner.send_mail(
        subject:        'Travail propre pour votre étape',
        message:        message_annonce_travail_propre,
        formated:       true,
        force_offline:  false
      )
    end
    msg << "Un mail a été envoyé à #{owner.pseudo} pour l'avertir."
  end
  msg = msg.join("<br/>")
  Ajax << {message: msg}
rescue Exception => e
  log(e)
  Ajax << {error: e.message}
end #/ travail_propre

def message_annonce_travail_propre
  <<-HTML
<p>Bonjour #{owner.pseudo},</p>
<p>Phil vient de définir un <strong>travail propre</strong> pour votre étape de travail courante.</p>
<p>Vous pouvez le trouver sur #{Tag.link(route:'bureau/home', full:true, distant: true, text:'votre bureau')}.</p>
  HTML
end

end #/class Admin::Operation
