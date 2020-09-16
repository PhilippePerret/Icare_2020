# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthodes pratiques pour les messages
=end

def operation(msg)
  puts msg.bleu
end #/ operation

def success(msg)
  puts msg.vert
end #/ success

def failure(msg)
  puts msg.rouge
end #/ failure
