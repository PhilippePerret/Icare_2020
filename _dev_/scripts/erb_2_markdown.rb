# encoding: UTF-8
=begin
  Pour transformer un fichier ERB en fichier MARKDOWN
=end
SRC_PATH = './_lib/pages/aide/data/80-Paiement.erb'
File.exists?(SRC_PATH) || raise("Le fichier #{SRC_PATH} est introuvable")
DST_PATH = File.join(File.dirname(SRC_PATH), "#{File.basename(SRC_PATH, File.extname(SRC_PATH))}.md")
!File.exists?(DST_PATH) || raise("Le fichier #{DST_PATH} existe. Je ne le remplace pas.")

code = File.read(SRC_PATH).force_encoding(Encoding::UTF_8)

SUBSTITUTIONS = {
  /<p class='italic'>\n?(.*?)\n?<\/p>/m  => '*\1*',
  /<h3>(.*)<\/h3>/  => '## \1',
  /<h4>(.*)<\/h4>/  => '### \1',
  /<h5>(.*)<\/h5>/  => '#### \1',
  /<%=(.*)%>/       => '#{\1}',
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
