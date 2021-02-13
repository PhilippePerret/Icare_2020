# encoding: UTF-8
# frozen_string_literal: true

Dir.chdir(APP_FOLDER) do
  require './_lib/_pages_/concours/xrequired/constants_mini'
end

evaluator_id  = Ajax.param(:evaluator_id)
dossier_id    = Ajax.param(:dossier_id)
categorie     = Ajax.param(:categorie)
concurrent_id, annee = dossier_id.split('-')

note_path = File.join(CONCOURS_DATA_FOLDER, concurrent_id, dossier_id, "note-#{categorie}-#{evaluator_id}.md")

if File.exist?(note_path)
  Ajax << {note: File.read(note_path).force_encoding('utf-8')}
else
  Ajax << {note: ''}
end
