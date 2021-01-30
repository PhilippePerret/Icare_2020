# Manuel de test du concours

## Introduction

Dans l’idéal, tous les tests doivent se faire dans ce dossier « per people », par type de personne concerné et par phase du concours.

Tous les tests du concours fonctionnent sous forme de `TDD` avec des phrases claires telles que :

```ruby
context "un context spécial" do
  before :all do
    @visitor = # définition du visiteur
    # La chose à faire avant…
  end
  peut_atteindre_lannonce_du_prochain_concours
end
```

La méthode `peut_atteindre_lannonce_du_prochain_concours`s'appelle un "it-case" 

```ruby
describe "Un administrateur"
    # ...
    context "en PHASE 3", phase3:true do
        peut_rejoindre_le_tableau_de_bord_du_concours
        peut_produire_les_fiches_de_lecture
    end

end
```

Et les pseudos-TDD sont définis dans un fichier séparé comme :

```ruby
def peut_rejoindre_le_tableau_de_bord_du_concours
  it "peut rejoindre le tableau de bord du concours" do
      try_identify_visitor # il faut avoir précisé @visitor = /* un admin */ 
    goto("concours/dashboard")
    expect(page).to be_concours_dashboard
  end
end
```

L'idée de ce dossier est de créer des tests qui se concentrent sur un type de visiteur possible, en fonction des phases du concours.

Les types qu'on peut avoir sont :

* un simple visiteur, sans rapport avec le concours -> **simple_visitor**
* un nouveau concurrent (donc de session courante),
* un concurrant ayant déjà participé (donc inscrit à ce concours + un précédent),
* un ancien concurrent (donc pas inscrit pour le concours courant)
* un icarien jamais inscrit
* un icarien non inscrit (donc qui a déjà été inscrit à un concours précédent)
* un icarien premier inscrit (donc qui n'a jamais participé avant)
* un icarien ré-inscrit (donc ayant déjà participé)
* un administrateur
* un membre du jury 1 du concours courant,
* un membre du jury 2 du concours courant,
* un ancien membre de jury 1,
* un ancien membre de jury 2

## Toutes les opérations possibles

« Qui ? » peut avoir la valeur :

T = tous, A = Administrateur, J = Évaluateur quelconque, J1 = Évaluateur du jury 1, J2 = Évaluateur du jury 2, C = Concurrent quelconque, CC = Concurrent courant, AC = Ancien concurrent, I = Icarien, IC = Icarien concurrent, V = Simple visiteur

| Opération                                         | phase | Qui ?  |
| ------------------------------------------------- | ----- | ------ |
| Atteindre la page d'annonce du concours           | < 1   | T      |
| Atteindre la page d'accueil du concours           | > 0   | T      |
| S’inscrire au concours                            | > 0   | V, I   |
| Atteindre l’espace personnel du concours          | > 0   | C      |
| Envoyer un dossier de candidature                 | 1     | CC, IC |
| Modifier les préférences pour les notifications   | > 0   | C      |
| Modifier les préférences pour la fiche de lecture | > 0   | C      |
| Évaluer un synopsis                               | 1, 2  | J1     |
| Évaluer un synopsis                               | 3     | J2     |
| Produire les fiches de lecture                    | 2, 3  | A      |
| Lire le règlement                                 | T     | T      |
| Consulter la FAQ                                  | T     | T      |

* Atteindre l'espace personnel
  * Modifier les préférences pour les notifications
  * Modifier les préférences pour la fiche de lecture

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
  newconc    Nouveau concurrent au concours
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
