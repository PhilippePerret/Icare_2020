class HTML
class << self
  def current
    @current ||= self.new
  end
end #/<< self
end
