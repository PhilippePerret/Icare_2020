# encoding: UTF-8
require_modules(['form', 'user/modules'])
class HTML
  def titre
    tit = "👩‍🎓👨‍🎓 Édition d’icarien"
    tit.prepend(BUTTON_RETOUR) if param('op') == 'edit-objet'
    tit.freeze
  end #/titre

  def icarien
    @icarien ||= User.get(param(:uid))
  end #/ icarien

  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    case param('op')
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
        message("Je dois éditer l'icmodule #{param(:pid)}")
      when 'icetape'
        message("Je dois éditer l'icetape #{param(:pid)}")
      end
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = case param(:op)
            when 'edit-objet'
              deserb("vues/#{param(:objet)}", self)
            else
              deserb("vues/#{STRINGS[:body]}", self)
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
      if icarien.respond_to?("set_#{prop}".to_sym)
        icarien.send("set_#{prop}".to_sym, new_value)
      elsif icarien.respond_to?("#{prop}=".to_sym)
        icarien.send("#{prop}=".to_sym, new_value)
      else
        begin
          icarien.set(prop => new_value)
        rescue Exception => e
          erreur(e.message)
          erreur("Il faut définir la méthode User#set_#{prop} ou User##{prop}= pour enregistrer la propriété #{prop.inspect}.")
        end
      end
    end
  end #/ save_property
end #/HTML
