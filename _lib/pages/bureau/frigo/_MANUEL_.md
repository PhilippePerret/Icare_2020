# Manuel pour les tests du frigo



## Frigo

### Matchers sur les discussions



#### `be_real_discussion`

Pour savoir si une discussion (`TDiscussion`) est une vraie discussion, c’est-à-dire :

* possède un enregistrement dans la table DB  `frigo_discussions`,
* possède au moins 2 participants (dans la table DB `frigo_users`),
* possède au moins un message (dans la table DB `frigo_messages`)

Noter que ce n’est pas un *matcher* qui implémente cette méthode mais la méthode `real_discussion?` de la class `TDiscussion`.

On peut l’utiliser facilement en connaissant le titre de la discussion ou son ID :

~~~ruby
discussion = TDiscussion.get(discussion_id) # Si on connait l'identifiant
# OU
discussion = TDiscussion.get_by_titre(titre) # Si on connait le titre de la discussion (plus souple)

expect(discussion).to be_real_discussion
# Success si les conditions ci-dessus sont réunies
~~~






## Méthodes TUser

> Rappel : `TUser` est une classe proche de `User` mais simplifiée et adaptée aux tests (par exemple, elle connait la propriété `:password`).



### Matchers Users

#### `have_discussion(titre[, {options}])`

Pour vérifier que l'user possède bien une discussion avec ce titre. Vérifie sa présence sur la porte du frigo si le test se trouve là. Sinon, vérifie seulement sa présence dans `frigo_discussions` et `frigo_users` dans la base de données.

~~~ruby
expect(benoit).to have_discussion('Discussion avec Phil'[, {options}])
~~~

Avec :

~~~ruby
options = {
  owner: true, 							# L'user doit être le propriétaire de la discussion
  with_new_messages: true,	# La discussion doit avoir une marque si elle contient des messages
  													# non lus par l'user
}
~~~



#### `have_discussion_with([users])`

Pour vérifier qu’il existe bien une discussion entre les utilisateurs.

~~~ruby
expect(benoit).to have_discussion_with([phil, marion, elie])
# Produit un succès si benoit a bien une discussion avec Phil, Marion et Élie
~~~

> Noter qu’il faut absolument la liste intégrale des participants.



#### `have_been_invited_to_discussion(titre_discussion, {:after})`

Pour tester que l’invitation d’un icarien à une discussion a bien été faite. Envoi de mail et enregistrement dans la base de données.

~~~ruby
start_time = Time.now.to_i
...
expect(benoit).to have_been_invited_to_discussion('Discussion pour voir', {after: start_time})
~~~



#### `have_pastille_frigo(nombre)`

Pour vérifier que le bureau (accueil) présente une pastille avec le nombre de nouveaux messages voulus.

~~~ruby
expect(benoit).to have_pastille_frigo(4)
# success si le bureau de Benoit affiche une pastille avec le nombre 4
~~~



#### `:have_no_pastille_frigo`

Pour vérifier que le bureau ne présente pas de pastille indiquant des nouveaux messages.

~~~ruby
expect(tuser).to have_not_pastille_frigo
~~~





### Méthodes *TDD* courante

Pour les méthodes façon « Test Driven Development », voir le fichier [./spec/support/lib/required/_tclasses/TUser_tdd.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/spec/support/lib/required/_tclasses/TUser_tdd.rb).



#### `<tuser>.rejoint_son_frigo[(checks)]`

Permet à l’user de rejoindre son frigo, qu’il soit ou non identifié.

Si checks est défini, ce sont les checks à faire :

~~~ruby
checks = {

}
~~~



#### `<tuser>.rejoint_la_discussion(titre[, checks])`

Permet à l’user de rejoindre la discussion qui porte le titre « titre » donc de se trouver sur cette page.

Noter que cette méthode est utilisable aussi bien depuis le tout départ, si l’user n’est pas identifié, que lorsqu’il l’est déjà et qu’il se trouve quelque part (n’importe où) sur le site.

Si `checks` est défini, ce sont des tests à faire :

~~~ruby
checks = {
  new_messages:	true/false,				# Si TRUE, la page doit avoir tout ce qu'il faut avec des nouveaux
  																# à commencer par 2 boutons 'Tout marquer lu', le nombre de nouveaux
  participants_nombre: {Integer},	# Vérifie que le nombre de participants soit bien indiqué
  participants_pseudos: {String},	# Vérifie que les pseudos des participants soient ceux-là.
}
~~~

