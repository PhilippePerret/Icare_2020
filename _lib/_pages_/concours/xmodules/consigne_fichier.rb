# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de consignation du fichier de ccandidature
  class Concours::File
=end
class HTML
  attr_reader :candidature_filename # pour le mail
  def consigne_fichier_candidature
    file = Concours::CFile.new(concurrent, ANNEE_CONCOURS_COURANTE)
    if file.consigne_file(param(:p_fichier_candidature))
      informe_concurrent_consignation_fichier(file)
      annonce_depot_fichier rescue nil # sans erreur
      informe_admin_consignation_fichier(file) # rescue nil # sans erreur
      message(MESSAGES[:merci_fichier_et_titre] % [concurrent.pseudo])
    end
  end #/ consigne_fichier_candidature

  # Envoi d'un mail à l'administration pour informer sur le dépôt d'un fichier
  def informe_admin_consignation_fichier(file)
    require_module('mail')
    MailSender.send({
      to: CONCOURS_MAIL,
      file: File.join(XMODULES_FOLDER,'mails','phase1','inform_depot_fichier.erb'),
      bind: file
    })
  rescue Exception => e
    erreur(e)
  end #/ informe_admin_consignation_fichier

  # On envoie un mail au concurrent pour lui signaler que son fichier a
  # bien été pris en compte
  def informe_concurrent_consignation_fichier(file)
    require_module('mail')
    @candidature_filename = file.original_name
    MailSender.send({
      to:   concurrent.mail,
      from: CONCOURS_MAIL,
      path: File.join(XMODULES_FOLDER,'mails','phase1','confirm_reception_fichier.erb'),
      bind: self
    })
  rescue Exception => e
    log(e)
  end #/ informe_concurrent_consignation_fichier

  def annonce_depot_fichier
    Actualite.add(type:'CONCOURSFILE', message:"<strong>#{concurrent.pseudo}</strong> envoie son fichier pour le <a href=\"concours/accueil\">Concours de Synopsis</a>. Bonne chance à #{concurrent.fem(:elle)} !")
  end #/ annonce_depot_fichier
end #/HTML

class Concours
class CFile
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE FICHIER DE CANDIDATURE
#
# ---------------------------------------------------------------------
# Méthode appelée avec le champ file du formulaire pour consigner le fichier
def consigne_file(ffile) # ffile pour "form-file"
  titre = titre_valide? # ou raise avec l'erreur
  not(ffile.nil?) || raise("Il faut fournir votre fichier de candidature !")
  ffile.size > 0  || raise("Ce fichier est vide…")
  ffile.size < 1000000 || raise("Ce fichier est trop volumineux (1Mo maximum — essayez de réduire la taille de l'image).")
  # Nom original et extension
  orname = @original_name = ffile.original_filename
  @extname = File.extname(orname)
  extension_valide?(@extname) || raise("L'extension de ce fichier est invalide. Les extensions acceptées sont : #{EXTENSIONS_VALIDES.pretty_join}.")
  File.open(path,'wb') { |f| f.write ffile.read }
  # On enregistre le titre
  db_exec(REQUEST_SAVE_DATA_PROJETS, [titre, param(:p_auteurs), concurrent.id, annee])
  # Si tout est OK, on marque que le dossier est envoyé dans les
  # specs du concurrent.
  concurrent.set_spec(0,1,{no_save:true})
  concurrent.set_spec(1,0) # au cas où
  return true # si tout est OK
rescue Exception => e
  log(e)
  return erreur(e.message)
end #/ consigne_file

private

  def titre_valide?
    tit = param('p_titre').nil_if_empty
    tit || raise(ERRORS[:titre_required])
    tit.length <= 200 || raise(ERRORS[:too_long] % ["Le titre", 200])
    tit = tit.titleize
    return tit
  end #/ titre_valide?

  def extension_valide?(ext)
    EXTENSIONS_VALIDES.include?(ext)
  end #/ extension_valide?


EXTENSIONS_VALIDES = [
  '.pdf','.odt','.doc','.docx','.txt','.rtf','.md','.markdown','.rtfd'
]

REQUEST_SAVE_DATA_PROJETS = "UPDATE #{DBTBL_CONCURS_PER_CONCOURS} SET titre = ?, auteurs = ? WHERE concurrent_id = ? AND annee = ?"
end #/File
end #/Concours
