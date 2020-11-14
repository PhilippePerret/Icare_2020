# Manuel de test des calculs

Les calculs sont compliqués pour le concours du fait de :

* du fait du nombre de fiches d'évaluation à prendre en compte (toujours plusieurs)
* du fait de la valeur différentes des questions en fonction de leur profondeur

Le module `calculs_tests_methods.rb` contient les méthodes qui permettent de tester tous les cas possibles. Pour l'utiliser, il suffit de rédiger un fichier `YAML` d'attentes, à placer dans le dossier `data` et d'appeler la méthode `teste_concours_calculs_scores` avec en premier argument le nom exact du fichier. Par exemple :

~~~ruby
# Le fichier data s'appelle 'mon_test.yaml'
describe "Le test" do
  teste_concours_calculs_scores("mon_test.yaml")
end
~~~

> Noter qu'il n'y a aucun 'it' ou 'context' dans cet appel.

## Constitution du fichier YAML

Toute la réussite du test dépend de la validité du fichier `YAML`. Il doit être constitué de cette manière :

~~~YAML
:titre: Le titre du test, qui sera repris dans la documentation
:cases: # Introduit la liste des cas. Table {Hash}
  # Chaque cas doit posséder un identifiant unique
  :id_du_cas:
    # On définit ensuite pour ce cas le nombre de questions absolues pour ce
    # test. Les évaluations (:scores ci-dessous) pourront contenir un autre
    # nombre de questions, c'est toujours sur la base de ce nombre qu'on compta-
    # bilisera le nombre de réponses attendues
    :nombre_questions: 8
    # Certaines valeurs peuvent être calculées à la volée. Mais pour obtenir
    # leur valeur exacte, on a besoin de connaitre le "coefficiant 200" permet-
    # tant de transformer une note quelconque en une note sur 20 dans le cadre
    # de l'évaluation courante et du nombre de questions. Ce coefficiant peut
    # être donné de façon brute ou calculée.
    # D'abord, il faut savoir qu'une valeur sera automatiquement interprétée,
    # i.e. calculée, si elle commence par une parenthèse. Ensuite, ce coeffi-
    # ciant est constitué d'une addition des valeurs maximales et de leur
    # valeur en profondeur. L'atome de base est constitué de :
    #   (NOMBRE_QUESTIONS * 5 * VALEUR_PROFONDEUR)
    # Voir les exemples plus bas
    :coef200: (2 * 5 * 1) + (3 * 5 * 0.9) + (4 * 5 * 0.8)
    # On définit ensuite les fiches d'évaluation, appelées 'scores', qui
    # contiennent donc les réponses données par les évaluateurs aux différents
    # synopsis. L'ensemble de scores ci-dessous correspond au même synopsis.
    # Un score définit deux choses :
    #   - les notes attribuées à aux questions (sur 5)
    #   - les attentes de valeurs à obtenir
    :scores: # C'est une liste Array
      - :values: # les valeurs de question
          # Les deux questions de profondeur 0 qui correspondent au (2 * 5 * 1)
          # du :coef200
          un: "-"   # question d'identifiant 'un', non répondue ("-")
          de: 3     # note de 3 (sur 5) attribué à la question 'de'
          # Les trois questions de profondeur 1 correspondant au (3 * 5 * 0.9)
          # du :coef200
          un-de: '-'
          un-tr: '-'
          de-tr: 1
          # Les quatre questions de profondeur 2 correspondant au (4 * 5 * 0.8)
          # du :coef200
          un-de-tr: '-'
          un-qd-cohe: 2
          de-qd-un: '-'
          de-tr-adth: 1
        # On définit ensuite les attentes. Chaque clé (sauf :categories) doit
        # être une méthode ou une propriété publique de Evaluation.
        :attentes:
          # Note 1 : les valeurs ci-dessous, sauf coup de pot, devrait produire
          # des erreurs, elles sont mises à titre illustratif seulement.
          # Note 2 : pour le détail sur le sens de propriété, voir le manuel
          # du concours ou la définition de la classe.
          :note: 10.0     # la note relative attendue
          :note_abs: 13.0 # la note absolues
          :nombre_missings: 8   # Nombre de réponses manquantes
          :nombre_questions: 7  # Nombre de questions dans le score
          :nombre_reponses: 4 # nombre de réponses données
          # Définition des valeurs attendues pour les catégories (qui, dans le
          # vrai programme, correspondent au :personnage, aux :theme(s), etc.)
          # Bien que chaque catégorie contiennent plusieurs valeurs indicatives,
          # ici, on ne peut tester QUE la note sur 20 obtenues.
          # Note : bien entendu, les catégories qu'on teste ici doivent corres-
          # pondre aux catégories définies dans les :values du score ci-dessus.
          :categories:
            un: 18
            de: (3 * 5 * 1) + (1 * 5 * 0.9) # valeur calculée
~~~


### Le Coefficient 200

Exemples :

~~~YAML

# Rappel : l'atom est constitué de (NB_QUESTIONS * 5 * VALEUR_PROFONDEUR)
# La valeur de profondeur est de :
#   1 pour profondeur 0 ("un")
#   0.9 pour profondeur 1 ("un-de")
#   0.8 pour profondeur 2 ("un-de-tr")
#   0.7 pour profondeur 3 ("un-de-tr-qu")
#   0.6 pour profondeur 4 ("un-de-tr-qu-ci")

# Avec une seule question
:coef200: (1 * 5 * 1)
:scores:
  - :values:
      un: "-"

# Avec deux questions de profondeur 0
:coef200: (2 * 5 * 1)
:scores:
  - :values:
      un: "-"
      de: "-"

# Avec une seule question de profondeur 1
:coef200: (1 * 5 * 0.9)
:scores:
  - :values:
      un-de: "-"

# Avec une question de profondeur 0 et une de 1
:coef200: (1 * 5 * 1) + (1 * 5 * 0.9)
:scores:
  - :values:
      un: "-"
      un-de: "-"

# Avec une question de profondeur 0 et deux de 1
#                        v--- 2 questions
:coef200: (1 * 5 * 1) + (2 * 5 * 0.9)
#          ^--- une question      ^------- profondeur 1
#                  ^---- profondeur 0
:scores:
  - :values:
      un: "-"
      un-de: "-"
      un-tr: "-"
~~~
