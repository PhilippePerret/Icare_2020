#!/usr/bin/ruby
# encoding: UTF-8
# frozen_string_literal: true

######################!/usr/bin/env ruby
def log message
  File.open('./log.txt','a'){|f| f.write "#{message}\n"}
end
alias :thislog :log

log("\n\n--- [#{Time.now}] Entrée dans ajax.rb")

require_relative 'ajax/required'
Ajax.treate_request
