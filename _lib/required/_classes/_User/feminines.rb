# encoding: UTF-8
class User
  FEMININES = {
    e:      ['e',     ''],
    egve:   ['ève',   'ef'],
    elle:   ['elle',  'lui'],
    la:     ['la',    'le'],
    ne:     ['ne',    'n'],
    te:     ['te',    't'],
  }
  def fem(key)
    FEMININES[key][femme? ? 0 : 1]
  end

end
