#!/Users/philippeperret/.rbenv/versions/2.6.3/bin/ruby
# encoding: UTF-8
begin
  require './_lib/required'
  App.run
  # Note : Le programme ne passera jamais par ici
rescue Exception => e
  ERROR = e
  File.open('./fatal_errors.log','a') do |f|
    f.write("#{Time.now} --- FATAL ERROR:\n    #{e.message}\n    #{e.backtrace.join("\n    ")}")
  end rescue nil
  send_error(e) rescue nil
  require "#{FOLD_REL_PAGES}/errors/systemique"
end
