# encoding: UTF-8
=begin
  Extension de User pour les watchers
=end
class User
def watchers
  @watchers ||= begin
    if user.admin?
      AdminWatchers.new(self)
    else
      UserWatchers.new(self)
    end
  end
end #/ watchers
end #/User
