# encoding: UTF-8
# frozen_string_literal: true

VERBOSE = IcareCLI.options[:verbose]

SERVEUR_SSH = "icare@ssh-icare.alwaysdata.net"

SSH_REQUEST_FOLDER = <<-SSH
ssh #{SERVEUR_SSH} ruby << RUBY
require 'json'
folder = '%{folder}'
alist = []
Dir["\#{folder}/**/*.*"].each do |path|
  next if File.directory?(path)
  hdata = {path:path, mtime: File.stat(path).mtime.to_i}
  alist << hdata
end
puts alist.to_json
RUBY
SSH
SSH_REQUEST_FILE = <<-SSH
ssh #{SERVEUR_SSH} ruby << RUBY
require 'json'
fpath = '%{dis_path}'
hdata = {path: fpath, mtime: nil}
if File.exists?(fpath)
  hdata[:mtime] = File.stat(fpath).mtime.to_i
end
puts hdata.to_json
RUBY
SSH
