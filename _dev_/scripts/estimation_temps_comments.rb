# encoding: UTF-8

require_relative 'required'

puts "QDD_FOLDER : #{QDD_FOLDER}"



require './_lib/required'
require_folder("#{FOLD_REL_PAGES}/qdd/xrequired/Qdd")
require "#{FOLD_REL_PAGES}/qdd/download/QddDoc"

MyDB.DBNAME = 'icare'

PDF_TO_OMIT = {
  'SuiviLent_etape_1_Freddy_914_comments' => true
}

REG_COUNT = /Count.([0-9]+)/
DIX_HEURES = 10 * 3600
UN_JOUR = 3600 * 24


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
    nombre_total_pages = 0
    nombre_total_jours = 0

    pdfs_in_qdd_folder.each do |pdf|
      npdf = File.basename(pdf)
      apdf = File.basename(pdf, File.extname(pdf))
      # next if PDF_TO_OMIT[apdf]
      absmodule_id = File.basename(File.dirname(pdf)).to_i
      puts "AFFIXE TRAITÉ : #{apdf.inspect}"
      hmodule, rien, numero, pseudo, doc_id, dtype = apdf.split('_')
      numero = numero.to_i
      ddoc = db_get('icdocuments', doc_id.to_i)
      unless ddoc.nil? || ddoc[:time_original].nil? || ddoc[:time_comments].nil?
        pdf_code = File.open(pdf,'rb'){|f| f.read}
        # puts "--- pdf_code: #{pdf_code.inspect}"
        idx = pdf_code.index(/\bCount/)
        next if idx.nil?
        pdf_code = pdf_code[idx..(idx+20)]
        # === NOMBRE PAGES ===
        nombre_pages = pdf_code.match(REG_COUNT).to_a[1].to_i
        nombre_pages = nombre_pages.to_f / 2 if dtype == 'comments'
        duree_comments = ddoc[:time_comments] - ddoc[:time_original]
        if duree_comments < DIX_HEURES
          puts "Durée commentaire trop court : #{npdf} (#{duree_comments})"
          next
        end
        nombre_jours = duree_comments.to_f / UN_JOUR
        puts "ddoc[:time_original]: #{ddoc[:time_original]} / ddoc[:time_comments]: #{ddoc[:time_comments]}"
        puts "Document '#{npdf}' / pages: #{nombre_pages.inspect} / durée : #{nombre_jours}"

        nombre_total_pages += nombre_pages
        nombre_total_jours += nombre_jours
        # exit
      end
    end


    puts "\n\nNOMBRE TOTAL PAGES: #{nombre_total_pages}\nNOMBRE TOTAL JOURS: #{nombre_total_jours}"
    puts "\n\nNOMBRE DE JOURS PAR PAGE : #{(nombre_total_jours.to_f / nombre_total_pages).round(2)}"

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

checker = QDDChecker.new
checker.check_allqdd
