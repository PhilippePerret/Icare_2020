# encoding: UTF-8
=begin

  Pour obtenir des informations sur l'user quand il a été créé avec
  DATA_SPEC_SIGNUP_VALID

=end

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
