# TODO sur les images

Modifier le .htaccess pour que toutes les images soient automatiquement appelées dans le dossier image. Un truc comme :

~~~bash

RewriteCond {FILENAME} ^.+\.(jp2)$
RewriteRule https://www.atelier-icare.net/img/${FILENAME} [301, L]

~~~
