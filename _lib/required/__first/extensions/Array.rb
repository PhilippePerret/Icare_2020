# encoding: UTF-8
=begin
  Extension de la classe Array
=end
ET = ' et ' unless defined?(ET)
VG = ', '   unless defined?(VG)
class Array
  def pretty_join
    ary = self
    lst = ary.pop
    ary.join(VG) + ET + lst
  end #/ pretty_join
end #/Array
