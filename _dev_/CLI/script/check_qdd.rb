# encoding: UTF-8
=begin
  Module qui permet de checker la validité des documents QDD
=end
require './_lib/required'
require_folder('./_lib/pages/qdd/xrequired/Qdd')
require './_lib/pages/qdd/download/QddDoc'

PDF_TO_OMIT = {
  'SuiviLent_etape_1_Freddy_914_comments' => true
}

class QDDChecker

  # Méthode qui prend les fichiers PDF très vieux de AllQDD, qui, d'après
  # le timestamp en début de nom retrouver la date, essaie de retrouver le
  # document dans la base pour voir de quel document il peut s'agir, vérifie
  # s'il existe et propose de le remettre
  def check_allqdd
    nombre_documents = 0
    pdfs_in_qdd_folder = Dir["#{QDD_FOLDER}/**/*.pdf"]
    puts "NOMBRE DE DOCUMENTS PDF : #{pdfs_in_qdd_folder.count}".freeze
    puts "NOMBRE D'ENREGISTREMENTS: #{db_count('icdocuments')}".freeze

    # On prend les documents PDF et on regarde qu'ils correspondent à leur
    # enregistrement
    pdfs_in_qdd_folder.each do |pdf|
      npdf = File.basename(pdf)
      apdf = File.basename(pdf, File.extname(pdf))
      next if PDF_TO_OMIT[apdf]
      absmodule_id = File.basename(File.dirname(pdf)).to_i
      hmodule, rien, numero, pseudo, doc_id, dtype = apdf.split('_')
      numero = numero.to_i
      ddoc = db_get('icdocuments', doc_id.to_i)
      if ddoc.nil?
        puts "ERREUR Enregistrement introuvable : #{apdf.inspect}"
        # On récupère l'auteur d'après son pseudo
        duser = db_get('users', "pseudo = '#{pseudo}' OR pseudo = '#{pseudo.downcase}'")
        unless duser.nil?
          user_id = duser[:id]
          puts "AUTEUR : #{duser[:pseudo]} ##{user_id}"
          # On peut chercher tous les documents de l'auteur, qui
          # concernent l'étape

          # … puis le module
          request = "SELECT * FROM icdocuments WHERE user_id = #{user_id} AND absmodule_id = #{absmodule_id}"
          qdocs = db_exec(request).collect {|ddoc| QddDoc.new(ddoc)}
          # Je vais rechercher un ou plusieurs documents qui auraient le même
          # numéro d'étape. S'il y en a un seul, c'est un problème de nommage,
          # sinon, il faut proposer les candidats pour corriger "à la main"
          candidats = qdocs.select do |qd|
            qd.absetape.numero == numero
          end
          if candidats.count == 1
            # Parfait ! un seul candidat => il faut changer le nom
            qd = candidats.first
            puts "IL FAUT METTRE '#{qd.name(:comments)}' à la place de '#{npdf}'"
          else
            puts "PLUSIEURS CANDIDATS POSSIBLES :#{RC}#{candidats.collect{|qd| qd.name(:comments)}.join(RC)}"
          end
          # … puis en général
        end
        break
      else
        qdoc = QddDoc.new(ddoc)
        dbname = qdoc.name(dtype.to_sym)
        if dbname != npdf
          puts "ERREUR SUR : #{npdf} / nom d'après base : #{dbname}"
          break
        else
          puts "OK #{npdf}"
        end
      end
    end

  end #/ check_allqdd

  def check
    check_if_records_have_pdf
  end #/ check

  # Méthode qui s'assure que tous les enregistrements possèdent un
  # document QDD
  def check_if_records_have_pdf
    errors = []
    db_exec("SELECT * FROM icdocuments").each do |datadoc|
      qdoc = QddDoc.new(datadoc)
      errors << qdoc.check_original if qdoc.exists?(:original)
      errors << qdoc.check_comments if qdoc.exists?(:comments)
    end
    errors = errors.compact # supprimer les nil
    if errors.empty?
      puts "Tous les enregistrements possèdent leur PDF"
    else
      puts "Des erreurs ont été trouvés : "
      puts errors.join(RC)
      puts "#{RC2}NOMBRE D'ERREURS TROUVÉES : #{errors.count}"
    end
  end #/ check_if_records_have_pdf
end #/QDDChecker

# ---------------------------------------------------------------------
#   Extention de la class QddDoc pour le check
# ---------------------------------------------------------------------
class QddDoc
  ERROR_UNFOUND_PDF = 'fichier PDF %s inexistant : %s'.freeze
  def check_original
    fpath = path(:original)
    if File.exists?(fpath)
      # OK pour l'instant on ne fait rien
      return nil
    else
      return ERROR_UNFOUND_PDF % ['original', fpath]
    end
  end #/ check_original

  def check_comments
    fpath = path(:comments)
    if File.exists?(fpath)
      return nil
    else
      return ERROR_UNFOUND_PDF % ['comments', fpath]
    end
  end #/ check_comments
end #/QddDoc

checker = QDDChecker.new
# checker.check
checker.check_allqdd
