# encoding: UTF-8
# frozen_string_literal: true
require_modules(['form', 'user/modules', 'icmodules'])
class HTML
  def titre
    tit = "#{EMO_ETUDIANT.page_title}#{EMO_ETUDIANTE.page_title}#{ISPACE}Édition d’icarien"
    tit = "#{BUTTON_RETOUR}#{tit}" if param('op') == 'edit-objet'
    tit
  end #/titre

  # Liste des liens utiles en regard du titre
  def usefull_links
    [
      Tag.lien(route:'overview/icariens', text:'Salle des icariens')
    ]
  end #/ usefull_links

  def icarien
    @icarien ||= User.get(param(:uid))
  end #/ icarien

  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    case param('op')
    when 'visit-as'
      # Opération appelée pour visiter le site comme l'icarien choisi
    when 'change-user'
      # param(:uid) contient soit le pseudo soit l'id
      if param(:uid).numeric?
        param(:uid, param(:uid).to_i)
      else
        param(:uid, User.get_by_pseudo(param(:uid)).id)
      end
    when 'save-prop'
      save_property
    when 'edit-objet'
      # Édition de l'objet d'une propriété éditable, par exemple l'IcModule
      # de la propriété icmodule_id
      case param(:objet)
      when 'icmodule'
        # Édition de l'icmodule (cf. la vue)
      when 'icetape'
        # Édition de l'icétape (cf. la vue)
      end
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = case param(:op)
            when 'edit-objet'
              deserb("vues/#{param(:objet)}", self)
            else
              deserb("vues/icarien", self)
            end
  end # /build_body

  def save_property
    prop = param(:prop).to_sym
    dataprop  = DATA_PROPS[prop]
    new_value = case dataprop[:vtype]
    when NilClass   then param(prop)
    when 'integer'  then param(prop).to_i
    when 'symbol'   then param(prop).to_sym
    else raise "SYSTEMIC ERROR: Le :vtype de #{prop.inspect} devrait être défini"
    end
    cur_value = icarien.send(prop)
    if new_value != cur_value
      # message("la propriété #{prop.inspect} a changé : #{cur_value.inspect} -> #{new_value.inspect}")
      msg_success = "Propriété #{prop.inspect} mise à #{new_value.inspect} avec succès."
      if icarien.respond_to?("set_#{prop}".to_sym)
        icarien.send("set_#{prop}".to_sym, new_value)
        message(msg_success)
      elsif icarien.respond_to?("#{prop}=".to_sym)
        icarien.send("#{prop}=".to_sym, new_value)
        message(msg_success)
      else
        begin
          icarien.set(prop => new_value)
          message(msg_success)
        rescue Exception => e
          erreur(e.message)
          erreur("Il faut définir la méthode User#set_#{prop} ou User##{prop}= pour enregistrer la propriété #{prop.inspect}.")
        end
      end
    end
  end #/ save_property
end #/HTML
