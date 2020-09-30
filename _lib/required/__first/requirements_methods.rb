# encoding: UTF-8
def icarien_required(message = nil)
  if user.guest?
    log("# user est un invité (guest?) et essaie d'atteindre une partie protégée")
    raise IdentificationRequiredError.new(message||MESSAGES[:ask_identify])
  end
end

def admin_required(message = nil)
  icarien_required(message)
  raise PrivilegesLevelError.new() unless user.admin?
end

def super_admin_required

end
