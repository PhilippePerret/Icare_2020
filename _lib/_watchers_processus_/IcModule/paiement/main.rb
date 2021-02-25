# encoding: UTF-8
class Watcher < ContainerClass
  def paiement
    icarien_required
    # On ne doit jamais passer par là, car le paiement sera
    # traiter dans la section module et le watcher sera détruit à ce moment-là.
  end
end # /Watcher < ContainerClass
