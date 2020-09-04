# encoding: UTF-8
=begin
  Construction du formulaire d'inscription
=end
class HTML
  def signup_form
    form = Form.new(id:'signup-form', route:'user/signup', class:'form-libelle-250')
    form.rows = rows
    form.submit_button = "Candidater"
    form.out
  end #/ signup_form

  def cbs_modules
    request = "SELECT id, name FROM absmodules ORDER BY name".freeze
    div = '<div class="cb-module%{class}"><input type="checkbox" id="umodule_%{id}" name="umodule_%{id}"%{checked}><label for="umodule_%{id}">%{name}</label></div>'.freeze
    db_exec(request).collect do |dmodule|
      dmodule[:checked] = param("umodule_#{dmodule[:id]}".to_sym) ? ' CHECKED' : '';
      dmodule.merge!(class: dmodule[:name].length < 30 ? ' pct50' : '')
      div % dmodule
    end.join
  end #/ cbs_modules

  # Mettre en forme les rangées
  SPAN_REQUIRED = '<span class="star-required">*</span>'
  def rows
    rs = {}
    data_form.collect do |drow|
      libelle, type, name, values, extra = drow
      # Les champs requis
      if libelle.end_with?('*')
        lib_for_name = libelle[0...-1]
        libelle = lib_for_name + SPAN_REQUIRED
      else
        lib_for_name = libelle
      end
      name ||= "u#{lib_for_name.downcase}".freeze
      dat = {type:type, name:name}
      dat.merge!(values: values) unless values.nil?
      dat.merge!(extra) unless extra.nil?
      rs.merge!(libelle => dat)
    end
    return rs
  end #/ rows

  def data_form
    ary_presentation = ['Votre présentation*', 'file', 'upresentation']
    ary_motivation = ['Lettre de motivation*', 'file', 'umotivation']
    ary_extrait = ['Extrait optionnel', 'file', 'uextrait']
    ok = '<input type="hidden" name="u%s_ok" value="1" /><span class="vmiddle">ok</span>'.freeze
    if File.exists?(user.signup_folder)
      affixes = Dir["#{user.signup_folder}/*.*"].collect do |path|
        case File.basename(path,File.extname(path))
        when 'presentation'
          ary_presentation = ['Votre présentation', 'raw', ok % ['presentation']]
        when 'motivation'
          ary_motivation = ['Lettre de motivation', 'raw', ok % ['motivation']]
        when 'extrait'
          ary_extrait = ['Extrait optionnel', 'raw', ok % ['extrait']]
        end
      end
    end
    [
      ['<explirequire>',STRINGS[:explication],"Les champs marqués d'un#{SPAN_REQUIRED} sont obligatoires.".freeze],
      [(Emoji.get('objets/statue-paques').page_title+ISPACE+'Identité').freeze, STRINGS[:titre]],
      ['Pseudo*', TEXT],
      ['Patronyme',TEXT],
      ['Naissance*', SELECT, nil, (1960..(Time.now.year - 16))],
      ['Vous êtes…*', SELECT, 'usexe', [['F','une femme'],['H','un homme'],['X','autre']]],
      [(Emoji.get('objets/cadenas-cle').page_title+ISPACE+'Contact et accès au site').freeze, STRINGS[:titre]],
      ['Mail*', TEXT],
      ['Confirmer mail*', TEXT, 'umail_conf'],
      ['Mot de passe<span class="small"> (MdP)</span>*', 'password', 'upassword'],
      ['Confirmer MdP*', 'password', 'upassword_conf'],
      ['CGU*', 'checkbox', 'ucgu', '<span class="small">J’accepte les <a href="http://www.atelier-icare.net/CGU_Atelier_ICARE.pdf" target="_blank">Conditions Générales d’Utilisation</a> de l’atelier Icare.</span>'.freeze],
      ['RGPD*', 'checkbox', 'urgpd', '<span class="small">En cochant cette case vous approuvez la <a href="overview/policy" target="_blank">Politique de confidentialité</a> de l’atelier en matière de protection et d’utilisation des données.</span>'.freeze],
      [(Emoji.get('objets/porte-document').page_title+ISPACE+'Documents de présentation').freeze, STRINGS[:titre]],
      ary_presentation,
      ary_motivation,
      ary_extrait,
      [(Emoji.get('objets/pile-livres').page_title+ISPACE+'Choix des modules*').freeze, STRINGS[:titre]],
      ['explichoixdoc', STRINGS[:explication], "Choisissez le ou les modules qui vous intéressent. Noter que Phil ne vous en attribuera qu'un seul. Lors de l’étude de votre candidature, Phil pourra discuter avec vous de la pertinence du choix du module en fonction de vos aspirations.".freeze],
      ['<liendescmodules/>', 'raw', "#{FLECHE} Voir la <a href=\"modules/home\" target=\"_blank\">description des modules</a>."],
      ['<Modules optionned/>', 'raw', cbs_modules, nil, {nogrid: true}]
    ]
  end #/ data_form
end #/HTML
