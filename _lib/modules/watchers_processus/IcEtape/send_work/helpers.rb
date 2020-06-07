# encoding: UTF-8
=begin
  Helpers de méthode pour faire le watcher
=end
class Watcher < ContainerClass

SELECT_NOTE = <<-HTML
<select class="" name="note-document%{idoc}" id="note-document%{idoc}">
  #{(1..20).collect{|i|"<option value=\"#{i}\">#{i}</option>"}.join}
</select>
<script type="text/javascript">document.querySelector("#note-document%{idoc}").value=12</script>
HTML


  # Méthode pour construire et retourner une rangée d'envoi d'un document
  def row_document(idoc)
    <<-HTML
<div class="row row-flex">
  <span class="value">
    <button id="buttondocument#{idoc}" type="button" class="inline-block" style="width:280px;" onclick="document.querySelector('#document#{idoc}').click()">Choisir le document #{idoc}…</button>
    <span id="documentname#{idoc}" class="docname hidden" style="width:280px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"></span>
    <input type="file" name="document#{idoc}" id="document#{idoc}" onchange="AppliqueNom(this,#{idoc})" />
    <span class="libelle inline">Note estimative : </span>
    #{SELECT_NOTE % {idoc: idoc}}
    #{Tag.info_bulle('C’est la note que vous donneriez vous-même à votre document') if idoc == 1} 
  </span>
</div>
    HTML
  end #/ row_document

end #/Watcher < ContainerClass
