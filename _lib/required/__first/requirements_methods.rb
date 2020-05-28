# encoding: UTF-8
class IdentificationRequiredError < StandardError; end
class PrivilegesLevelError < StandardError; end

def icarien_required
  raise IdentificationRequiredError.new() unless user.icarien?
end

def admin_required
  raise IdentificationRequiredError.new() unless user.icarien?
  raise PrivilegesLevelError.new() unless user.admin?
end

def super_admin_required

end
