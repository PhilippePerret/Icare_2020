require './_lib/pages/user/signup/constants_messages'
feature 'Aller sur le site'do
  scenario 'rejoint l’atelier' do
    def goto_home
      visit 'http://localhost/AlwaysData/Icare_2020'
    end #/ goto_home
    def clic_signup_button
      find('#signup-btn').click
    end #/ clic_signup_button
    def fill_formulaire_with(data)
      within('#signup-form') do
        data.each do |prop, val|
          case val[:type]
          when 'checkbox'
            if val[:value] === true
              check("u#{prop}")
            else
              uncheck("u#{prop}")
            end
          else
            fill_in("u#{prop}", with: val[:value])
          end
        end
      end
    end #/ fill_formulaire_with
    def submit_formulaire
      within('#signup-form') do
        click_on('Candidater')
      end
    end #/ submit_formulaire
    def check_messages_errors(data)
      data.each do |prop, val|
        expect(page).to have_content(val[:have]) unless val[:have].nil?
        expect(page).not.to have_content(val[:not_have]) unless val[:not_have].nil?
      end
    end #/ check_messages_errors

    #
    all_data = [
      {
        pseudo:     {value:'', have:ERRORS[:pseudo_required], have_not:nil},
      },
      # Un pseudo trop court
      {
        pseudo:     {value:'ax', have:ERRORS[:pseudo_to_short]}
      },
      # Un pseudo trop long
      {
        pseudo: {value: 'ax'*26, have:ERRORS[:pseudo_to_long]}
      },
      # Un pseudo existant
      {
        pseudo:   {value:'Phil', have:ERRORS[:pseudo_already_exists]}
      },
      # patronyme trop long
      {
        patronyme: {value: 'axy'*34, have:ERRORS[:patronyme_too_long]}
      },
      {
        patronyme: {value: 'axy'*33, not_have:ERRORS[:patronyme_too_long]}
      },
      # Sans le mail
      {
        pseudo: {value:"monBeauPseudo#{Time.new.to_i}"},
        mail:   {value:'', have:ERRORS[:mail_required]}
      },
      # Un mail existant
      {
        mail: {value:'phil@atelier-icare.net', have:ERRORS[:mail_already_exists]}
      },
      # Un mail mal formaté
      {mail: {value:'philouchezicare.net', have:ERRORS[:mail_invalid]}},
      {mail: {value:'philouchez@icarenet', have:ERRORS[:mail_invalid]}},
      {mail: {value:'phil!ou!chez@atelier-icare.net', have:ERRORS[:mail_invalid]}},
      {mail: {value:'philouchez@icare.nettification', have:ERRORS[:mail_invalid]}},
      # Confirmation de mail qui ne correspond pas
      {
        pseudo:     {value:'Pilou', have_not:ERRORS[:pseudo_required]},
        mail:       {value:'pilou@chez.lui', have_not:ERRORS[:mail_required]},
        mail_conf:  {value:'philouette@chez.lui', have:ERRORS[:conf_mail_dont_match]}
      },
      # COnfirmation du mail qui correspond
      {
        pseudo:     {value:'Pilou', have_not:ERRORS[:pseudo_required]},
        mail:       {value:'pilou@chez.lui', have_not:ERRORS[:mail_required]},
        mail_conf:  {value:'pilou@chez.lui', have_not:ERRORS[:conf_mail_dont_match]}
      },
      # Mot de passe requis
      {
        password:  {value:'', have:ERRORS[:password_required]}
      },
      # Mot de passe trop court
      {
        password: {value:'xxxxx', have:ERRORS[:password_too_short]}
      },
      # Mot de passe trop long
      {
        password: {value:'ax'*26, have:ERRORS[:password_too_long]}
      },
      # Mots de passe invalides
      {password:{value:'a b c d',   have:ERRORS[:password_invalid]}},
      {password:{value:'abc-d-e',   have:ERRORS[:password_invalid]}},
      {password:{value:'abcde-é',   have:ERRORS[:password_invalid]}},
      {password:{value:'a_b_c_d',   have:ERRORS[:password_invalid]}},
      # Confirmation ne matche pas
      {
        password: {value: 'a!b.c?d',      have_not:ERRORS[:password_invalid]},
        password_conf: {value: 'abcdefg', have:ERRORS[:conf_password_doesnt_match]}
      },
      # Sans cocher les cgu
      {
        cgu: {value: false,     have:ERRORS[:cgu_required], type:'checkbox'}
      },
      {
        cgu: {value: true, have_not:ERRORS[:cgu_required], type:'checkbox'}
      }
    ]
    all_data.each do |data|
      goto_home
      clic_signup_button
      fill_formulaire_with(data)
      submit_formulaire
      check_messages_errors(data)
      # sleep 4
    end #/
  end
end
