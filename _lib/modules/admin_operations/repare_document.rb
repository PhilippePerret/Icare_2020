# encoding: UTF-8
# frozen_string_literal: true
class Admin::Operation

def repare_document
  require_modules(['icmodules', 'qdd'])
  @msg = []

  # reparer = cb_value
  documents_ids = short_value.split(/[ ,;]/).compact

  documents_ids.each do |document_id|
    reparer_le_document(document_id.to_i)
  end

  @msg = @msg.join('<br>')
  Ajax << {message: @msg}

rescue Exception => e
  log(e)
  Ajax << {error: (e.message)}
end


def reparer_le_document(document_id)
  return if document_id == 0
  # On prend le document en question
  docqdd  = QddDoc.get(document_id)
  doc     = IcDocument.get(document_id)

  @msg << "Diagnostic document ##{document_id} (#{doc.name})…"
  @msg << "Du : #{formate_date(doc.created_at)}"
  @msg << "Options : #{doc.options}"

  @doc_options = doc.options

  une_erreur = false

  # On boucle sur le document original et le document commentaire
  [:original, :comments].each do |key|
    key_existe  = key == :original ? 0 : 8
    key_deposed = key == :original ? 3 : 11

    le_fichier_existe     = docqdd.pdf_exists?(key)
    doc_marqued_existant  = option_is(key_existe, 1) && option_is(key_deposed, 1)
    # Si le document original est marqué existant dans les options et qu'il
    # n'existe pas, c'est une erreur qu'il faut corriger
    # if docqdd.exists?(key) && not(le_fichier_existe)
    if doc_marqued_existant && not(le_fichier_existe)
      # Quand le document original n'existe pas en tant que fichier mais
      # qu'il est marqué existant
      if noop?
        @msg << "<span class=red>Le document #{key} est marqué existant (options), mais il est introuvable en tant que fichier.</span>"
        @msg << "Je vais marquer le document #{key} comme inexistant (options)."
        une_erreur = true
      else
        doc.set_option(key_existe,  0,  {save:false})
        doc.set_option(key_deposed, 0,  {save:true})
        @msg << "J'ai marqué le document #{key} comme inexistant dans ses options."
      end
    elsif le_fichier_existe && not(doc_marqued_existant)
      # Quand le document #{key} existe en tant que fichier, mais qu'il
      # est marqué inexistant
      # => Correction nécessaire : le marquer existant
      if noop?
        @msg << "<span class=red>Le document #{key} est marqué inexistant (options), pourtant il existe en tant que fichier.</span>"
        @msg << "Je vais marquer le document #{key} comme existant (options)."
        une_erreur = true
      else
        doc.set_option(key_existe,  1,  {save:false})
        doc.set_option(key_deposed, 1,  {save:true})
        @msg << "J'ai marqué le document #{key} comme existant dans ses options."
      end
    end
  end #/fin de boucle sur :original et :comments

  unless une_erreur
    @msg << "Tout est OK avec ce document."
  end

end

def option_is(bit, val)
  @doc_options[bit] == val.to_s
end

end #/Admin::Operation
