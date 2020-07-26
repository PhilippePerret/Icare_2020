# encoding: UTF-8
=begin
  Méthodes d'helper pour la minifaq
=end
class MiniFaq < ContainerClass
class << self
  # Retourne tout le bloc pour la minifaq soit de l'étape (+target_type+ =
  # :absetape) ou pour le module (+target_type+ = :absmodule) pour l'élément
  # d'identifiant +target_id+
  def full_block(target_type, target_id)
    <<-HTML
<div class="minifaq-block">
#{MiniFaq.block_reponses(target_type, target_id)}
#{MiniFaq.form(target_type,target_id)}
</div>
    HTML
  end #/ full_block
  # Le formulaire permettant de soumettre une question sur une étape ou
  # sur un module
  # +target_type+   :absmodule ou :absetape
  # +target_id+     Identifiant du module ou de l'étape
  def form(target_type, target_id)
    require_module('form')
    form = Form.new(id:'form-minifaq', route:route.to_s, value_size: '100%', class:'nolibelle noborder nomargin')
    rows = {
      'ope-minifaq' => {name:'ope', type:'hidden', value: 'minifaq-add-question'},
      'target-type' => {name:'minifaq_target_type', value:target_type, type:'hidden'},
      'target-id'   => {name:'minifaq_target_id', value:target_id, type:'hidden'},
      '<Question/>' => {name:'minifaq_question', type:'textarea', height:140, class:'w100pct', placeholder:"Question à poser sur #{target_type==:absmodule ? 'ce module' : 'cette étape'}"}
    }
    if user.guest? || user.admin?
      rows.merge!({
        '<Mail/>'       => {name:'minifaq_user_mail', type:'text', placeholder:'Votre adresse email (vérifiée par vos soins)'},
        '<explimail/>'  => {type:'raw', value:"<div class='explication small'>Cette adresse mail permettra seulement ne vous informer d'une réponse et ne sera en aucun cas conservée dans notre base de données. Vous pouvez consulter la #{StringHelper.politique_confidentialite} de l'atelier Icare.</div>"}
      })
    else
      rows.merge!({
        'user id' => {name:'minifaq_user_id', type:'hidden', value:user.id}
      })
    end
    form.rows = rows
    form.submit_button = "Poser cette question"
    form.submit_button_class = 'very small'

    '<div class="mt2 italic">Votre question, si vous n’avez pas trouvé de réponse ci-dessus :</div>'.freeze +
    form.out
  end #/ form

  # Retourne le bloc contenant toutes les questions/réponses correspondant
  # à l'élément de type +target_type+ (:absmodule ou :absetape) et d'identifiant
  # +target_id+ (identifiant du module ou de l'étape)
  def block_reponses(target_type, target_id)
    foretape = target_type == :absetape
    chose = foretape ? 'étape' : 'module'
    cette_chose = "#{foretape ? 'cette' : 'ce'} #{chose}"
    request = <<-SQL
      SELECT
        mf.question, mf.reponse, u.pseudo AS user_pseudo
      FROM
        `minifaq` mf
      LEFT JOIN users u ON u.id = mf.user_id
      WHERE
        mf.#{target_type}_id = #{target_id}
        AND mf.reponse IS NOT NULL
    SQL
    reponses = db_exec(request.strip.freeze).collect do |dquest|
      MiniFaq.instantiate(dquest)
    end
    log("réponses: #{reponses.inspect}")

    reponses.collect(&:out).join
  end #/ block_reponses
end # /<< self
end #/MiniFaq < ContainerClass
