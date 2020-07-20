# encoding: UTF-8


def require_module(module_name)
  Cronjob.require_app_module(module_name)
end #/ require_module

def require_mail
  require './_lib/modules/mail/Mail'
  require './_lib/data/secret/phil' # => PHIL
end #/ require_mail
