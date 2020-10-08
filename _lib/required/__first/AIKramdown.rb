# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class AIKramdown
  ----------------
  Pour traiter les pages définies en markdown
=end
require 'kramdown'

class AIKramdown
class << self

  # +fpath+
  #   {String}  Le chemin relatif au fichier Markdown, dans +folder+
  #   {String}  OU le code à évaluer.
  def kramdown(fpath, owner = nil, folder = nil)
    if fpath.match?(/[\n ,']/)
      code = fpath
    else
      fpath = "#{fpath}.md" unless fpath.end_with?('.md') || fpath.end_with?('.mmd')
      fpath = File.join(folder, fpath) unless folder.nil?
      code = file_read(fpath)
    end
    code = evaluate(code, owner) unless owner.nil?
    code = Kramdown::Document.new(code, kramdown_options).send(:to_html)
    # code = evaluate(code, owner) unless owner.nil?
    return code
  end #/ kramdown

  def evaluate(code, owner)
    if code.nil?
      log('ERROR : code nil dans AIKramdown::evaluate')
      return ''
    end
    code.gsub!(/#\{(.*?)\}/) do
      # log("Évaluation de #{$1}")
      owner.bind.eval($1)
    end
    return code
  end #/ evaluate

  def kramdown_options
    @kramdown_options ||= {
      header_offset:    0, # pour que '#' fasse un chapter
    }
  end #/ kramdown_options
end # /<< self

end #/AIKramdown
