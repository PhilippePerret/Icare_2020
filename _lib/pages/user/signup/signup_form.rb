# encoding: UTF-8
=begin
  Construction du formulaire d'inscription
=end
class HTML
  def signup_form
    form = Form.new(id:'signup-form', route:'user/signup')
    form.rows = rows
    form.submit_button = "Candidater"
    form.out
  end #/ signup_form

  def cbs_modules
    request = "SELECT id, name FROM absmodules ORDER BY name"
    div = '<div class="cb-module%{class}"><input type="checkbox" id="umodule_%{id}" name="umodule_%{id}"><label for="umodule_%{id}">%{name}</label></div>'.freeze
    db_exec(request).collect do |dmodule|
      dmodule.merge!(class: dmodule[:name].length < 30 ? ' pct50' : '')
      div % dmodule
    end.join
  end #/ cbs_modules

  # Mettre en forme les rangées
  SPAN_REQUIRED = '<span class="star-required">*</span>'
  def rows
    rs = {}
    data_form.collect do |drow|
      libelle, type, name, values = drow
      if libelle.end_with?('*')
        lib_for_name = libelle[0...-1]
        libelle = lib_for_name + SPAN_REQUIRED
      else
        lib_for_name = libelle
      end
      name ||= "u#{lib_for_name.downcase}".freeze
      dat = {type:type, name:name}
      dat.merge!(values: values) unless values.nil?
      rs.merge!(libelle => dat)
    end
    return rs
  end #/ rows

  def data_form
    [
      ['<explirequire>','explication',"Les champs marqués d'une#{SPAN_REQUIRED} sont obligatoires.".freeze],
      ['Identité', 'titre'],
      ['Pseudo*', 'text'],
      ['Patronyme','text'],
      ['Naissance*', 'select', nil, (1960..(Time.now.year - 16))],
      ['Vous êtes…*', 'select', 'usexe', [['F','une femme'],['H','un homme'],['X','autre']]],
      ['Contact et accès au site', 'titre'],
      ['Mail*', 'text'],
      ['Confirmer mail*', 'text', 'umail_conf'],
      ['Mot de passe (MdP)*', 'password', 'upassword'],
      ['Confirmer MdP*', 'password', 'upassword_conf'],
      ['<CGU/>*', 'checkbox', 'ucgu', '<span class="small">J’accepte les <a href="http://www.atelier-icare.net/CGU_Atelier_ICARE.pdf" target="_blank">Conditions Générales d’Utilisation</a> de l’atelier Icare</span>'.freeze],
      ['Documents de présentation', 'titre'],
      ['Votre présentation*', 'file', 'upresentation'],
      ['Lettre de motivation*', 'file', 'umotivation'],
      ['Extrait optionnel', 'file', 'uextrait'],
      ['Choix des modules*', 'titre'],
      ['explichoixdoc', 'explication', "Choisissez le ou les modules qui vous intéressent. Noter que Phil ne vous en attribuera qu'un seul. Lors de l’étude de votre candidature, Phil pourra discuter avec vous de la pertinence du choix du module en fonction de vos aspirations."],
      ['<Modules optionned/>', 'raw', cbs_modules]
    ]
  end #/ data_form
end #/HTML
