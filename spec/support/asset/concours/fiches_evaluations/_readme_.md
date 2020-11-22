Ce dossier contient des fiches d'évaluation à dupliquer.

Pour obtenir une fiche au hasard, utiliser :

~~~ruby
  # (require_support('concours'))
  
  une_fiche = Dir["#{CONCOURS_FOLDER_FICHES_EVALUATIONS}/evaluation-pres-*.json"].shuffle.first
~~~
