# encoding: UTF-8
=begin
  Extension de la classe User pour le Quai des docs
=end
class User
  def nombre_lectures
    @nombre_lectures ||= db_count('lectures_qdd', {user_id:id})
  end #/ nombre_lectures
end #/User
