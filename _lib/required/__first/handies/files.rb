# encoding: UTF-8
=begin
  Ce module contient des méthodes pratiques pour les codes helpers récurrents.
=end

def full_path(relpath)
  fromCaller(relpath, Kernel.caller)
end #/ full_path

def fromCaller(relpath, from)
  File.join(File.dirname(from[0].split(':')[0]), relpath.to_s)
end #/ fromCaller

def deserb relpath, owner = nil
  Deserb.deserb(relpath, owner, Kernel.caller[0].split(':')[0])
end

def deyaml relpath
  MyYAML.my_load(relpath, Kernel.caller[0].split(':')[0])
end #/ deyaml

def first_is_older_than(file1, file2, default_if_not_exist)
  file1 = fromCaller(file1, Kernel.caller) unless File.exists?(file1)
  log("=== file1 = #{file1}")
  file2 = fromCaller(file2, Kernel.caller) unless File.exists?(file2)
  return default_if_not_exist unless File.exists?(file1) && File.exists?(file2)
  log("=== file2 = #{file2}")
  File.stat(file1).mtime < File.stat(file2).mtime
end #/ fisrt_is_older_than

def download(path, zipname = nil, options = nil)
  require_module('download')
  Downloader.new(path,zipname,options).download
end #/ download
