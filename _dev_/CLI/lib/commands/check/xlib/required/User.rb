# encoding: UTF-8
# frozen_string_literal: true
class User
class << self
  def exists?(uid)
    get(uid) != nil
  end #/ exists?

  def table
    @table ||= 'users'
  end #/ table
end # /<< self
end #/User
