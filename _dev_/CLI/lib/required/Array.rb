class Array
  def pretty_join
    ary = self.dup
    dernier = ary.pop
    if ary.empty?
      dernier
    else
      ary.join(', ') + ' et ' + dernier
    end
  end #/ pretty_join
end #/Array
