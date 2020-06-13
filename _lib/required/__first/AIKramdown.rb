# encoding: UTF-8
=begin
  Class AIKramdown
  ----------------
  Pour traiter les pages définies en markdown
=end
require 'kramdown'

class AIKramdown
class << self

  def kramdown(fpath, owner = nil, folder = nil)
    fpath << '.md' unless fpath.end_with?('.md') || fpath.end_with?('.mmd')
    fpath = File.join(folder, fpath) unless folder.nil?
    code = Kramdown::Document.new(file_read(fpath), kramdown_options).send(:to_html)
    code = evaluate(code, owner) unless owner.nil?
    return code
  end #/ kramdown

  def evaluate(code, owner)
    code.gsub!(/#\{(.*?)\}/) do
      eval($1, owner.bind)
    end
  end #/ evaluate

  def kramdown_options
    @kramdown_options ||= {
      header_offset:    0, # pour que '#' fasse un chapter
    }
  end #/ kramdown_options
end # /<< self

end #/AIKramdown
