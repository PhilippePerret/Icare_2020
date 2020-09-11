# encoding: UTF-8
=begin
  Pour transformer un fichier ERB en fichier MARKDOWN
=end
# Copier ici le chemin relatif du fichier à transformer
# (note : le nom du fichier transformé sera le même avec l'extension md)
SRC_PATH = './_lib/_pages_/overview/home/body-ERB.erb'
# Nombre de niveau à retirer aux titres (H3 => H1)
LEVEL_TITLE_MOINS = 0 # 1 par défaut


LEVEL_TITLE_MOINS = 1 unless defined?(LEVEL_TITLE_MOINS)
File.exists?(SRC_PATH) || raise("Le fichier #{SRC_PATH} est introuvable")
DST_PATH = File.join(File.dirname(SRC_PATH), "#{File.basename(SRC_PATH, File.extname(SRC_PATH))}.md")
!File.exists?(DST_PATH) || raise("Le fichier #{DST_PATH} existe. Je ne le remplace pas.")

code = File.read(SRC_PATH).force_encoding(Encoding::UTF_8)

SUBSTITUTIONS = {
  /<p class='italic'>\n?(.*?)\n?<\/p>/m  => '*\1*',
  /<h1>(.*)<\/h1>/  => "# \\1".freeze,
  /<h2>(.*)<\/h2>/  => "#{'#'*(2-LEVEL_TITLE_MOINS)} \\1".freeze,
  /<h3>(.*)<\/h3>/  => "#{'#'*(3-LEVEL_TITLE_MOINS)} \\1".freeze,
  /<h4>(.*)<\/h4>/  => "#{'#'*(4-LEVEL_TITLE_MOINS)} \\1".freeze,
  /<h5>(.*)<\/h5>/  => "#{'#'*(5-LEVEL_TITLE_MOINS)} \\1".freeze,
  /<%= ?(.*?)( +)?%>/       => '#{\1}',
  /<\/?p>/          => '',
  /^(.*?)<li>(.*?)<\/li>/ => '* \2',
  /<\/?ul>/               => '',
  /\n\n+/                 => "\n\n",
  /<(em|i)>(.*?)<\/(em|i)>/ => '*\2*',
  /<(strong|b)>(.*?)<\/(strong|b)>/ => '**\2**',
}
SUBSTITUTIONS.each do |pattern, remp|
  code.gsub!(pattern,remp)
end

puts "Nouveau code:\n#{code}"

File.open(DST_PATH,'wb').write(code)
