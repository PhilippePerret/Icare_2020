# encoding: UTF-8
require_module('qdd')
class Watcher < ContainerClass
  def cotes_n_comments
    if param(:form_id) == "cote-n-comments-#{objet_id}"
      form = Form.new
      enregistre_cote_et_commentaire if form.conform?
    end
  end # / cotes_n_comments

  # Méthode qui enregistre la cote et le commentaire
  def enregistre_cote_et_commentaire
    cote_original = param(:cote_original).to_i
    cote_comments = param(:cote_comments).to_i
    comment = param(:comment).nil_if_empty
    if cote_original == 0 && cote_comments == 0 && comment.nil?
      message("Merci à vous, cette lecture a été supprimée.")
    else
      nowstr = Time.now.to_i.to_s
      data = {
        user_id: user.id,
        icdocument_id: objet_id,
        created_at: nowstr,
        created_at: nowstr
      }
      data.merge!(cote_original: cote_original) if cote_original > 0
      data.merge!(cote_comments: cote_comments) if cote_comments > 0
      data.merge!(comments: comment) unless comment.nil?
      db_compose_insert('lectures_qdd', data)
      message("Merci #{user.pseudo}, cette lecture a été enregistrée.")
    end
  end #/ enregistre_cote_et_commentaire

end # /Watcher < ContainerClass
