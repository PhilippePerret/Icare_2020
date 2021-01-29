# Tests du concours

Tous les tests du concours fonctionnent sous forme de `TDD` avec des phrases claires telles que :

```ruby
context "un context spécial" do
  before :all do
    # La chose à faire avant…
  end
  peut_atteindre_lannonce_du_prochain_concours
end
```

La méthode `peut_atteindre_lannonce_du_prochain_concours`s'appelle un "it-case" 

### Test sans navigateur

Pour ne se concentrer que sur les tests, on peut utiliser la méthode `headless(true)` (par exemple dans un `before :all`) pour ne pas ouvrir le navigateur.

Utiliser `headless(false)` pour revenir à la normal, lorsqu'on veut vraiment voir ce qui se passe à l'écran par exemple.



## Filtrage des tests



### Faire le test d'une phase particulière

```
bundle exec rspec ./spec/features/concours -t phase0
```

Utiliser `phase0`, `phase1`... `phase8` pour tester les différentes phases.

### Faire le test pour un utilisateur particulier

```
bundle exec rspec ./spec/features/concours -t <user>

Où <user> peut être :
  admin      Administrateur
  visitor    Simple visiteur
```



### Faire le test pour un utilisateur dans une phrase particulière

```
bundle exec rspec ./spec/features/concours -t <user>:<phase>

Où <user> peut être une des valeurs précédentes
Où <phase> peut être :
  phase0      Concours OFF
  phase1      Concours démarré
  phase2      En cours de première sélection
  phase3      En cours de sélection final
  phase5      Palmarès établi
  phase8      Finalisation
  phase9      Nettoyage effectué
```
