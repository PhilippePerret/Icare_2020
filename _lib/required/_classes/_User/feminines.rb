# encoding: UTF-8
class User
  FEMININES = {
    e:      ['e',     ''],
    egve:   ['ève',   'ef'],
    elle:   ['elle',  'lui'],
    Elle:   ['Elle',  'Il'],  # noter la différence avec :elle, complément
    la:     ['la',    'le'],
    ne:     ['ne',    ''],
    te:     ['te',    ''],
    x:      ['se',    'x'],
  }
  def fem(key)
    FEMININES[key][femme? ? 0 : 1]
  end

end
