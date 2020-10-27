# encoding: UTF-8
# frozen_string_literal: true
def log(msg)
  Logger << "[SITE] #{msg}"
end #/ log

class HTML
  def res; @res ||= [] end
end
def html
  @html ||= HTML.new
end
