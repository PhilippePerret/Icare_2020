# encoding: UTF-8
=begin

  Pour obtenir des informations sur l'user quand il a été créé avec
  DATA_SPEC_SIGNUP_VALID

=end

def phil
  @phil ||= begin
    require './_lib/data/secret/phil'
    TUser.instantiate(id:1, pseudo:"Phil", mail:PHIL_MAIL, password:PHIL_PASSWORD)
  end
end #/ phil

def marion
  @marion ||= TUser.instantiate(get_data_user_by_index(1).merge(id: 10))
end #/ marion
def benoit
  @benoit ||= TUser.instantiate(get_data_user_by_index(2).merge(id: 11))
end #/ benoit
def elie
  @elie ||= TUser.instantiate(get_data_user_by_index(3).merge(id: 12))
end #/ elie

def get_icetape_user(idx)
  db_get('icetapes', get_icmodule_user(idx)[:icetape_id])
end #/ get_icetape_user

def get_icmodule_user(idx)
  db_get('icmodules', get_user_by_index(idx)[:icmodule_id])
end #/ get_icmodule_user

def get_user_by_index(idx)
  user_mail = get_data_user_by_index(idx)[:mail]
  db_get('users', {mail: user_mail})
end #/ get_user_by_index

def get_data_user_by_index(idx)
  data = {}
  DATA_SPEC_SIGNUP_VALID[idx]&.each do |k,d|
    data.merge!(k => d[:value])
  end
  return data
end #/ get_data_user_by_index
