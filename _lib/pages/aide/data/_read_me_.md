Dossier contenant les textes d'aide

* [Comment choisir entre fichier MD et ERB ?](#commentchoisirentremdeterb)
* [Comment créer un lien d'aide vers ces fichiers](#creerunlinedaideverscesfichiers)


<a name='commentchoisirentremdeterb'></a>

## Comment choisir entre fichier MD et ERB ?

À présent, il vaut mieux choisir Markdown, qui permet tous les traitements. Pour utiliser du code ruby (les féminisations par exemple), il suffit d'utiliser `#{<code ruby>}`, par exemple `#{fem(:e)}` pour ajouter un "e" au féminin.

<a name='creerunlinedaideverscesfichiers'></a>

## Comment créer un lien d'aide vers ces fichiers

~~~ruby

Tag.aide(aide_id[, "<titre>"])

~~~


Où `aide_id` est le numéro au début du nom du fichier, juste avant le tiret.


Par exemple, pour rejoindre la page d'aide sur les raisons de l'abonnement, qui s'appelle `3-why_subscribe.erb`, utiliser :

~~~erb
<%= Tag.aide(3, "Pourquoi s'abonner") %>
~~~

Lien avec plus de définition :

    Tag.aide(<numéro>, <{hash de données}>)

Par exemple :

    Tag.aide(3, {titre: "Vers les raisons", class: 'class_css', target: :new})

On peut utiliser aussi la route :

    aide/fiche?aid=<numéro>

Donc :

    <a href="aide/fiche?aid=3">Un lien vers l’aide</a>
