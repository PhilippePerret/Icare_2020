# encoding: UTF-8
class IdentificationRequiredError < StandardError; end
class PrivilegesLevelError < StandardError; end

def icarien_required(message = nil)
  raise IdentificationRequiredError.new(message) if user.guest?
end

def admin_required
  raise IdentificationRequiredError.new() if user.guest?
  raise PrivilegesLevelError.new() unless user.admin?
end

def super_admin_required

end
