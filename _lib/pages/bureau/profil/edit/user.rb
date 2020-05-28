# encoding: UTF-8
class User
  def formulaire_profil
    form = Form.new({id:'profil-form', route:'bureau/profil/edit', size:600})
    form.rows = {
      'Votre mail': {name:'user_mail', type:'text', value:data[:mail]},
      'Votre pseudo': {name: 'user_pseudo', type:'text', default: data[:pseudo]}
    }
    form.submit_button = 'Modifier'
    form.out
  end #/ formulaire_profil
end #/User
