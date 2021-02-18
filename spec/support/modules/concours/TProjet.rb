# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class TProjet
  -------------
  Pour manipuler le projet (i.e. participation d'un concurrent à une session
  particulière du concours)
=end
class TProjet
attr_reader :concurrent_id, :annee
def initialize(concurrent_id, annee)
  @concurrent_id = concurrent_id
  @annee = annee
end #/ initialize
end #/Synopsis
