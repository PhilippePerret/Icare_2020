# encoding: UTF-8
class IdentificationRequiredError < StandardError; end
class PrivilegesLevelError < StandardError; end

def icarien_required(message = nil)
  raise IdentificationRequiredError.new(message||MESSAGES[:ask_identify]) if user.guest?
end

def admin_required(message = nil)
  icarien_required(message)
  raise PrivilegesLevelError.new() unless user.admin?
end

def super_admin_required

end
