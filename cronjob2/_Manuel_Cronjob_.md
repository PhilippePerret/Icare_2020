# Manuel Cronjob



## Crontab

Le cronjob est appelé toutes les heures entre 0 et 5 heures du matin.

> Note : pourquoi ne pas l’appeler qu’une seule fois et pour de bon ? Avec un mode sans erreur qui assurerait que le travail soit exécuté.



## Les jobs



Un « job » est un travail à exécuté. Il est défini par un unique fichier dans `cronjob2/JOBS/` (ce fichier peut inclure bien sûr des fichiers qui se trouveront dans un dossier portant le même nom — sans l’extension). Donc :

~~~bash

./cronjob2/JOBS/mon_job.rb
										/mon_job/lib.rb
										        /classe.rb
~~~



## Fichiers des jobs

Le fichier doit définir une méthode d’instance de `Cronjob` qui porte pour nom l’affixe du fichier. Si le fichier s’appelle `mon_job.rb`, ce fichier doit contenir une méthode de nom `mon_job` :

~~~
.../JOBS/mon_job.rb =>  class Cronjob
													def mon_job
														...
													end #/mon_job

~~~



### Méthodes des jobs

La méthode principale du job, qui doit porter le même nom que son fichier, doit contenir au moins :

~~~ruby
class Cronjob
  def mon_job
    runnable? || return
    ...
    return true # pour marquer la fin
  end
end #/Cronjob
~~~



Le fichier doit définir aussi la méthode `data` (qui sera donc redéfinie par chaque instance job) :

~~~ruby
class Cronjob
  def data
    @data ||= {
      name: "Le nom humain de ce job",
      frequency: {définition de la fréquence}
    }
  end

  def mon_job
    ...
  end
end #/Cronjob
~~~



### Définition de la fréquence

La fréquence se définit dans `data[:frequency]` de la manière suivante :

~~~
frequency: {hour:<heure>[, day:<week day>]}

:hour			Définit l'heure à laquelle doit être joué le job. Comme le cronjob n'est
					appelé que toutes les heures, le job ne sera joué qu'une fois
:day			Définit le jour de la semaine où doit être joué le job. 0 : dimanche,
					6 : samedi.
~~~



> Tout est géré ensuite par la méthode d’instance commune `runnable?` en fonction de l’heure courante.
