# encoding: UTF-8
=begin
  Extension de la classe Array
=end
ET = ' et ' unless defined?(ET)
VG = ', '   unless defined?(VG)
class Array
  def pretty_join
    return '' if self.empty?
    return self.first if self.count == 1
    ary = self
    lst = ary.pop
    ary.join(VG) + ET + lst
  end #/ pretty_join

  def nil_if_empty
    if self.empty?
      nil
    else
      self
    end
  end #/ nil_if_empty

end #/Array
