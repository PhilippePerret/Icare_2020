# encoding: UTF-8
# frozen_string_literal: true

module ModuleHelpersObjet


  def displine(libelle, value, options = nil)
    puts prefix+' '+libelle.to_s.ljust(libelle_width,'.')+' '+value.to_s
  end #/ displine


  def code_infos
    @code_infos ||= "[icare infos #{type} #{id}]".gris
  end #/ code_infos


  def libelle_width
    @libelle_width ||= 30
  end #/ libelle_width

  def prefix
    @prefix ||= "==="
  end #/ prefix
  def prefix=(val)
    @prefix = val
  end #/ prefix=


  def owner
    @owner ||= User.get(user_id)
  end #/ owner


# ---------------------------------------------------------------------
#
#   Méthode de formatage
#
# ---------------------------------------------------------------------

def f_id
  @f_id ||= "##{id} #{code_infos}"
end #/ f_id


def f_owner
  @owner ||= begin
    if user_id.nil?
      "- indéfini -".rouge
    elsif not(User.exists?(user_id))
      "- inconnu (#{user_id})-".rouge
    else
      "#{owner.pseudo} (##{owner.id}) #{owner.code_infos}"
    end
  end
end #/ f_owner

def created_date
  @created_date ||= begin
    if created_at.nil?
      "- inconnue -".rouge
    else
      "#{formate_date(created_at)} (#{created_at})"
    end
  end
end #/ created_date
def updated_date
  @updated_date ||= begin
    if updated_at.nil?
      "- inconnue -".rouge
    else
      "#{formate_date(updated_at)} (#{updated_at})"
    end
  end
end #/ updated_date
def started_date
  @started_date ||= begin
    if started_at.nil?
      "- non définie -".rouge
    else
      "#{formate_date(started_at)} (#{started_at})"
    end
  end
end #/ started_date
def ended_date
  @ended_date ||= begin
    if ended_at.nil?
      "- non définie -".rouge
    else
      "#{formate_date(ended_at)} (#{ended_at})"
    end
  end
end #/ ended_date

# Retourne les options formatées
def f_options
  @f_options ||= begin
    "#{options}"
  end
end #/ f_options

end
