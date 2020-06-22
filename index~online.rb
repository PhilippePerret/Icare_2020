#!/usr/bin/env ruby
# encoding: UTF-8
begin
  require './_lib/required'
  App.run
  # Note : Le programme ne passera jamais par ici
rescue Exception => e
  ERROR = e
  send_error(e) rescue nil
  require './_lib/pages/errors/systemique'
end
