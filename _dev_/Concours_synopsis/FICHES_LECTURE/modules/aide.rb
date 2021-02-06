# encoding: UTF-8
# frozen_string_literal: true
puts <<-AIDE

Produire les fiches de lecture
===============================
#{'icare concours fiches_lecture[ <id concurrent>] --build[ <options>]'.jaune}

Options
-------
--reload => Recharcer les fiches d'évaluation distantes (sinon,
prendre celles qui sont déjà téléchargées)
--only_good   => Seulement les fiches qui ont la moyenne
--only_bad    => Seulement les fiches qui n'ont pas la moyenne
--not_built   => Seulement les fiches inexistantes
--only_one    => Seulement la première fiche (parmi celles retenues)
--open        => Ouvre la fiche de lecture après sa fabrication

--verbose     Mode verbeux. MAIS ATTENTION, ici, il a un sens
              particulier. Il ajoute la note aux éléments de la
              fiche, pour vérification. Il n'est donc pas à utiliser
              pour la production des fiches finales.

SI <id concurrent> est fourni, on ne fait que sa fiche

Uploader les fiches de lecture
==============================
#{'icare concours fiches_lecture --upload'.jaune}

Infos sur le fiches de lecture
==============================
#{'icare concours fiches_lecture --infos'.jaune}

Options
-------
--evaluation    Affiche l'évaluation de la première fiche trouvée
                Sans autre précision, c'est une version simplifiée, avec
                la clé et la note
--full_version  La version complète de l'évaluation de la première
                fiche trouvée.
--with_files    Affiche aussi le contenu des fichiers d'évaluation


Options générales
-----------------
-v/--verbose    Mode verbeux (mais voir le sens particulier pour la
                construction des fiches).


AIDE
