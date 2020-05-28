# encoding: UTF-8

class UserLister

  attr_reader :owner
  def initialize owner
    @owner = owner
  end

  def collect &block
    items.collect do |item|
      yield item
    end
  end

  def each &block
    items.each do |item|
      yield item
    end
  end

  def items
    @items ||= begin
      db_exec(request_items).collect do |data|
        under_class.new(data)
      end
    end
  end

  def count
    items.count
  end
end
