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
    [:mail, :pseudo].each do |prop|
      formkey = "user_#{prop}".to_sym
      next if param(formkey) == data[prop]
      new_data.merge!(prop => param(formkey))
    end
    debug "new_data:#{new_data.inspect}"
    if new_data.empty?
      message "Aucune donnée n'a été modiifée…"
      return
    end
  end #/ check_and_save_profil

end #/User
