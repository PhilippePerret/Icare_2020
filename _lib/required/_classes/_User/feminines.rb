# encoding: UTF-8
class User
  FEMININES = {
    e:      ['e',     ''],
    la:     ['la',    'le'],
    ne:     ['ne',    'n'],
    elle:   ['elle',  'lui']
  }
  def fem(key)
    FEMININES[key][femme? ? 0 : 1]
  end

end
