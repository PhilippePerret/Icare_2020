# Tests du frigo

## Expectation

~~~ruby

expect(<discussion>).to have_message_frigo(<prop>)

~~~

où :

~~~

  <discussion>    {FDiscussion} Qu'on peut obtenir par exemple par :
      FDiscussion.between([auteurs], index)
      ou par (si on connait l'identifiant)
      FDiscussion.get(<discussion id>)

  <prop> peut contenir toutes les propriétés du message, à savoir :user_id,
    :content (le contenu attendu, non strict)
    mais aussi les propriétés spéciales :
    :count    Le nombre de messages attendus
    :after    Les messages après ce temps
    :before   Les messages avant ce temps
~~~

### Discussions d'un icarien

L'expectation ci-dessous vérifie deux choses :

* que la discussion soit affichée sur le frigo de l'icarien (on doit donc s'y trouver)
* que l'icare possède cette discussion dans la base de données.

~~~ruby
expect(user).to have_discussion(titre[, options])
~~~

Avec

~~~
  <user>    {TUser}   Instance TUser de l'user
  titre     {String}  Le titre exact
  options   {Hash}    Options :
                      :with_new_messages    Mettre à true si c'est un titre
                                            avec nouveaux messages.
~~~
