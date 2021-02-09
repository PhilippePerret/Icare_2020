# encoding: UTF-8
# frozen_string_literal: true

def line_info(label, value)
  puts "#{label.ljust(45).vert} #{value.to_s.bleu}"
end #/ line_info


def patronimize(patro)
  patro.split(' ').each do |seg|
    seg.capitalize
  end.join(' ')
end
