# encoding: UTF-8
# frozen_string_literal: true
def icarien_required(message = nil)
  if user.guest?
    log("# user est un invité (guest?) et essaie d'atteindre une partie protégée")
    erreur(message||MESSAGES[:ask_identify])
    requri = ENV['REQUEST_URI'] # pour retourner exactement au même endroit, avec query-string
    if ONLINE
      requri = requri[1..-1] if requri.start_with?('/')
    else
      requri = requri.sub(/\/AlwaysData\/Icare_2020\//,'')
    end
    log("REQUEST URI pour retour : #{requri}")
    session['back_to'] = requri
    redirect_to(:identification)
  end
end

def admin_required(message = nil)
  icarien_required(message)
  raise PrivilegesLevelError.new() unless user.admin?
end

def super_admin_required

end
