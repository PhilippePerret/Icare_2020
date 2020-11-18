# RSpec

Pour requérir des choses pour tout un dossier, il suffit de mettre un fichier `_required.rb` à sa racine. Il sera joué au lancement de tous les tests que contient le dossier.

Voir par exemple l'utilisation dans `./spec/features/_required.rb`.

## Tests de téléchargement

Utiliser le profil adéquat grâce à :

~~~ruby
use_profile_downloader
~~~

Penser à utiliser l'une ou l'autre des lignes suivantes pour revenir au profil normal (sans message de déprécation)

~~~ruby
use_profile_downloader(false)

# ou

headless(true/false)
~~~
