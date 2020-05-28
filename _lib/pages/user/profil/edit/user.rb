# encoding: UTF-8
class User
  def formulaire_profil
    form = Form.new({id:'profil-form', route:'user/profil/edit', size:600})
    form.rows = {
      'Votre mail':   {name:'user_mail', type:'text', value:data[:mail]},
      'Votre pseudo': {name: 'user_pseudo', type:'text', default: data[:pseudo]}
    }
    form.submit_button = 'Modifier'
    form.out
  end #/ formulaire_profil


  # Méthode appelée quand on soumet le formulaire de profil avec les nouvelles
  # informations.
  def check_and_save_profil
    new_data = {}
    {mail: :user_mail, pseudo: :user_pseudo}.each do |prop, formprop|
      next if param(formprop) == data[prop]
      new_data.merge!(prop => param(formprop))
    end
    # debug "new_data:#{new_data.inspect}"
    return message(ERRORS[:no_data_modified]) if new_data.empty?
    # Des données ont été modifiées, il faut les checker pour
    # voir si elles sont correctes
    require_module('user/checker_data')
    if User.check_data(new_data, self)
      save(new_data)
    end
  end #/ check_and_save_profil

end #/User
