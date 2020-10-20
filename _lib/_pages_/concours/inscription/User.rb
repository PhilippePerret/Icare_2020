# encoding: UTF-8
# frozen_string_literal: true
class User
  def concurrent_concours?
    db_count(DBTBL_CONCURRENTS, {mail: user.mail}) > 0
  end #/ concurrent_concours?
end #/User
