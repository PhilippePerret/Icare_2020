# encoding: UTF-8
# frozen_string_literal: true
class Cronjob
class QDD
class << self

  # = main =
  # Méthode principale qui contrôle le Quai des Docs
  # Principalement, cela consiste à vérifier que tous les documents qui
  # sont marqués existants dans la base de document (table icdocuments) soient
  # bien présents en tant que documents physique.
  def control
    require_module('icmodules')
    errors_found = false
    nombre_documents_checked = 0
    @errors = []
    @nombre_documents_ok  = 0
    @nombre_reparations   = 0
    IcDocument.each do |idoc|
      missing_docs = 0
      missing_docs += check_document_original(idoc)
      missing_docs += check_document_comments(idoc)
      nombre_documents_checked += 1
      if missing_docs > 0
        Report << "# ERR Document #{idoc.name} (##{idoc.id})"
        @errors.each { |err| Report << "      #{err}" }
        @errors = []
        # Dans tous les cas, on indique que des documents n'ont pas été trouvés
        errors_found = true
      else
        # En cas de document conforme
        @nombre_documents_ok += 1
        if Cronjob.debug?
          Report << "= Document ##{idoc.id} (#{idoc.name}) OK"
        end
      end
    end #/ fin de boucle sur chaque document

    if errors_found
      Report << "Des erreurs de documents manquants ont été trouvés. Utiliser l'outil administrateur 'Nom de document QDD' pour pouvoir les importer sur le Quai des docs."
    end

    Report << "= Nombre documents QDD checkés : #{nombre_documents_checked}"
    Report << "  Nombre documents conformes   : #{@nombre_documents_ok}"
    Report << "  Nombre documents erronés     : #{nombre_documents_checked - @nombre_documents_ok}"
    Report << "  Nombre de réparations : #{@nombre_reparations}"

  end #/ control

  # RETOURNE 0 si le document n'a aucun problème, 1 dans le cas contraire
  def check_document_original(idoc)
    # Si le document n'existe pas, on le passe
    return 0 if idoc.option(0) == 0
    bitpartage = idoc.option(1)
    file_exists = File.exists?(idoc.qdd_path(:original))
    document_is_shared = bitpartage == 1
    sharing_is_not_defined = bitpartage == 0
    if document_is_shared && file_exists
      # <= Le document est partagé + Le document existe
      # => tout est bon, on retourne 0
      return 0
    elsif document_is_shared && not(file_exists)
      # <= Le document est partagé MAIS le document n'existe pas
      # => Ça n'est pas bon du tout, c'est une erreur
      @errors << "Le document original n'existe pas."
      return 1
    elsif sharing_is_not_defined && file_exists
      # <= Le partage n'est pas défini mais pourtant le document existe
      # => Signaler cette erreur (si NOOP) ou la corriger
      m = "Le document existe mais le partage n'est pas défini"
      if not(Cronjob.noop?)
        idoc.set_option(1,1)
        @nombre_reparations += 1
        m = "#{m} (CORRIGÉ)"
      else
        m = "#{m} (NON CORRIGÉ)"
      end
      @errors << m
      return 1
    else
      # <= Pas de partage défini, pas de fichier existant
      # => C'est bon
      return 0
    end
  end #/ check_document_original

  # RETOURNE 2 si le document a des problèmes, 0 dans le cas contraire
  def check_document_comments(idoc)
    # Si le document n'existe pas, on le passe
    return 0 if idoc.option(8) == 0
    bitpartage = idoc.option(9)
    file_exists = File.exists?(idoc.qdd_path(:comments))
    document_is_shared = bitpartage == 1
    sharing_is_not_defined = bitpartage == 0
    if document_is_shared && file_exists
      # <= Le document est partagé + Le document existe
      # => tout est bon, on retourne 0
      return 0
    elsif document_is_shared && not(file_exists)
      # <= Le document est partagé MAIS le document n'existe pas
      # => Ça n'est pas bon du tout, c'est une erreur
      @errors << "Le document commentaires n'existe pas."
      return 1
    elsif sharing_is_not_defined && file_exists
      # <= Le partage n'est pas défini mais pourtant le document existe
      # => Signaler cette erreur (si NOOP) ou la corriger
      @errors << "Le document commentaires existe mais le partage n'est pas défini (CORRIGÉ)"
      idoc.set_option(9,1) if not(Cronjob.noop?)
      return 1
    else
      # <= Pas de partage défini, pas de fichier existant
      # => C'est bon
      return 0
    end
  end #/ check_document_comments

end # /<< self
end #/QDD
end #/Cronjob
