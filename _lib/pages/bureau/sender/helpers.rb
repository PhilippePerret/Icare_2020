# encoding: UTF-8
=begin
  Helpers de méthode pour faire le watcher
=end
class HTML

SELECT_NOTE = <<-HTML
<select class="" name="note-document%{idoc}" id="note-document%{idoc}">
  <option value="">---</option>
  #{(1..20).collect{|i|"<option value=\"#{i}\">#{i}</option>"}.join}
</select>
HTML


  # Méthode pour construire et retourner une rangée d'envoi d'un document
  def row_document(idoc)
    <<-HTML
<div class="row mt1">
  <span class="value doc-field" data-document-id="#{idoc}">
    <button id="buttondocument#{idoc}" type="button" class="btn-choose">Choisir le document #{idoc}…</button>
    <span class="doc-name-span hidden">
      <button type="button" class="btn-remove noborder">❌</button>
      <span id="documentname#{idoc}" class="doc-name"></span>
    </span>
    <input type="file" name="document#{idoc}" id="document#{idoc}" />
    <span class="hidden span-note">
      <span class="libelle inline">Note estimative : </span>
      #{SELECT_NOTE % {idoc: idoc}}
      #{Tag.info_bulle('C’est la note que vous donneriez vous-même à votre document') if idoc == 1} 
    </span>
  </span>
</div>
    HTML
  end #/ row_document

end #/HTML
