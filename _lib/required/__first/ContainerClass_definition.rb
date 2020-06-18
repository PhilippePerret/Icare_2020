# encoding: UTF-8
=begin

  On définit dans ce module toutes les classes qui vont hériter de
  ContainerClass pour ne pas avoir de problème de mismatch.

=end
require_relative 'ContainerClass'

class AbsEtape < ContainerClass; end
class AbsModule < ContainerClass; end
class TravailType < ContainerClass; end
class IcEtape < ContainerClass; end
class IcModule < ContainerClass; end
