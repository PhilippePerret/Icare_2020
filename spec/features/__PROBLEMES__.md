

Pour des raisons inconnues :

* Penser à utiliser `feature` au lieu de `description` pour ne pas avoir à `include Capybara::DSL`

Dans la définition d'un module, cet ordre bloque capybara (sans erreur)

~~~ruby
module PeopleMatchersModule
  include Capybara::DSL
  include RSpec::Matchers
~~~

Il faut obligatoirement utiliser :

~~~ruby
module PeopleMatchersModule
  include RSpec::Matchers
  include Capybara::DSL
~~~
