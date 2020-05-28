#!/Users/philippeperret/.rbenv/versions/2.6.3/bin/ruby
# encoding: UTF-8
begin
  require './_lib/required'
  App.run
  # Note : Le programme ne passera en fait jamais par ici
rescue Exception => e
  ERROR = e
  require './_lib/pages/errors/systemique'
end
