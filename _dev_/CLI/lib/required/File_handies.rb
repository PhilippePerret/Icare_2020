# encoding: UTF-8
# frozen_string_literal: true

CL_LIBRE_OFFICE = '/Applications/LibreOffice.app/Contents/MacOS/soffice'

# Convertit le fichier +src+ en fichier PDF en utilisant LibreOffice
# Si +dst+ est fourni, c'est le dossier de destination (par défaut, le dossier
# du fichier +src+)
def docx2pdf(src, dst = nil)
  dst ||= File.dirname(src)
  res = `cd '#{dst}' && #{CL_LIBRE_OFFICE} --headless --convert-to pdf '#{src}'`
end #/ docx2pdf
