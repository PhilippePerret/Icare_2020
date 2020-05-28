# encoding: UTF-8
class User
  def redirection_apres_login
    "Rediriger vers : #{redirection.downcase}"
  end #/ redirection_apres_login

  def redirection
    Route::REDIRECTIONS[bit_redirection][:hname].downcase
  end #/ redirection
end #/User
