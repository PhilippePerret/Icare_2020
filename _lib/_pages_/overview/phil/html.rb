# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def titre
    # "Pédagogue de l’atelier"
    "#{Emoji.get('humain/phil-pedagogue').page_title+ISPACE}Pédagogue de l’atelier"
  end

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
