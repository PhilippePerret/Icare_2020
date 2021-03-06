# encoding: UTF-8
# frozen_string_literal: true

VERBOSE = IcareCLI.options[:verbose]

# Path au fichier qui contient les opérations à faire relevées au cours
# de la dernière analyse de synchro
OPERATIONS_PATH = File.join(THIS_FOLDER,'last_operations.msh')
IGNORE_FILE_PATH = File.join(THIS_FOLDER, '.syncignore')

require_relative './classes/usual_methods'

SSH_REQUEST_FOLDER = <<-SSH
ssh #{SSH_ICARE_SERVER} ruby << RUBY
require 'json'
folder = '%{folder}'
alist = []
# Dir["\#{folder}/*"].each do |path|
Dir["\#{folder}/**/*"].each do |path|
  next if File.directory?(path)
  hdata = {path:path, mtime: File.stat(path).mtime.to_i}
  alist << hdata
end
puts alist.to_json
RUBY
SSH

SSH_REQUEST_FILE = <<-SSH
ssh #{SSH_ICARE_SERVER} ruby << RUBY
require 'json'
fpath = '%{dis_path}'
hdata = {path: fpath, mtime: nil}
if File.exists?(fpath)
  hdata[:mtime] = File.stat(fpath).mtime.to_i
end
puts hdata.to_json
RUBY
SSH

SSH_REQUEST_DELETE_FILES = <<-SSH
ssh #{SSH_ICARE_SERVER} ruby << RUBY
require 'json'
resultat = []
%{files}.each do |fpath|
  File.delete(fpath)
  resultat << "\#{fpath} détruit" unless File.exists?(fpath)
end
puts resultat.to_json
RUBY
SSH
