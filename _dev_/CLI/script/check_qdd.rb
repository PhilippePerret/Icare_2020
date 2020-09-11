# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui permet de checker la validité des documents QDD

  On peut lancer ce script en toute sécurité puisqu'aucune modification n'est
  opérée. Il faut les faire à la main.

  Ce script fait deux choses :

  1.  Il vérifie que les fichiers PDF correspondent bien TOUS à un enregistrement
      dans la table 'icdocuments'
  2.  Il vérifie que tous les enregistrements de la table 'icdocuments' trouvent
      bien leur document PDF lorsque ça doit être le cas.

  Note : beaucoup de documents :originaux n'étaient
  pas enregistrés au début de l'atelier, donc on se contente de tester les
  documents commentaire.

=end
require './_lib/required'
require_folder("#{FOLD_REL_PAGES}/qdd/xrequired/Qdd")
require "#{FOLD_REL_PAGES}/qdd/download/QddDoc"

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
      puts "AFFIXE TRAITÉ : #{apdf.inspect}"
      hmodule, rien, numero, pseudo, doc_id, dtype = apdf.split('_')
      numero = numero.to_i
      ddoc = db_get('icdocuments', doc_id.to_i)
      if ddoc.nil?
        puts "ERREUR Enregistrement introuvable : #{apdf.inspect}#{RC}#{pdf}"
        pseudo ||= begin
          if rien.nil?
            # On essaie avec un nom "<timestamp>-<pseudo>-<numéro étape>"
            time, pseudo, numero = apdf.split('-')
            pseudo
          end
        end
        # On récupère l'auteur d'après son pseudo
        duser = db_get('users', "pseudo = '#{pseudo}' OR pseudo = '#{pseudo.downcase}'")
        if duser.nil?
          puts "IMPOSSIBLE DE TROUVER L'AUTEUR"
          break
        else
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
            puts "IL FAUT METTRE '#{absmodule_id}/#{qd.name(:comments)}' à la place de '#{absmodule_id}/#{npdf}'"
          elsif candidats.count == 0
            puts "AUCUN CANDIDATS POSSIBLES parmi :"
            qdocs.each do |qd|
              puts "#{qd.name(:comments)}"
            end
          else
            puts "PLUSIEURS CANDIDATS POSSIBLES :#{RC}#{candidats.collect{|qd| qd.name(:comments)}.join(RC)}"
            puts candidats.inspect
          end
          # … puis en général
        end
        break
      else
        # Les données existent, il y a juste une erreur de nom
        qdoc = QddDoc.new(ddoc)
        # puts "ddoc:#{ddoc.inspect}"
        dbname = qdoc.name(dtype.to_sym)
        if dbname != npdf
          puts "ERREUR SUR : #{absmodule_id}/#{npdf} / nom d'après base : #{absmodule_id}/#{dbname}"
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
      # errors << qdoc.check_original if qdoc.exists?(:original)
      if qdoc.exists?(:comments) && qdoc.shared_sharing(:comments) && !qdoc.pdf_exists?(:comments)
        errors << QddDoc::ERROR_UNFOUND_PDF % [':comments', qdoc.name(:comments)]
      end
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
  ERROR_UNFOUND_PDF = 'fichier PDF %s partagé mais inexistant : %s'.freeze
  def check_original
    puts "Check original  de document ##{id}"
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
# checker.check_allqdd
checker.check_if_records_have_pdf
