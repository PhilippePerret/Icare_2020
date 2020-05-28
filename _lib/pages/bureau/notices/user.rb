# encoding: UTF-8
class User

  def nombre_notifications
    watchers.count
  end

  def watchers
    @watchers ||= Watchers.new(self)
  end
end
