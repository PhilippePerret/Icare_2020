# encoding: UTF-8
# frozen_string_literal: true
module FemininesMethods

  FEMININES = {
    e:      ['e',     ''],
    egve:   ['ève',   'ef'],
    elle:   ['elle',  'lui'],
    Elle:   ['Elle',  'Il'],  # noter la différence avec :elle, complément
    ere:    ['ère',   'er'],  # fi[er|ère]
    la:     ['la',    'le'],
    ne:     ['ne',    ''],
    te:     ['te',    ''],
    trice:  ['trice', 'teur'],
    ve:     ['ve',    'f'],
    x:      ['se',    'x'],
  }
  def fem(key)
    FEMININES[key][femme? ? 0 : 1]
  end

end # module FemininesMethods
