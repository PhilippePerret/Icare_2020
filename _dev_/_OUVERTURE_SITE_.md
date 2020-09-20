# Ouverture du nouveau site Icare 2020

---------------------------------------------------------------------

## À faire APRÈS l'ouverture

### Modifications diverses

* Changer la date de prochain paiement de Charlotte

### Envoi d'un mail d'annonce

~~~html
<p>Bonjour <%= pseudo.titleize %>,</p>
<p>Je suis heureux et fier de vous annoncer la mise en place du nouveau site de l'atelier icare, que vous pouvez découvrir à l’adresse habituelle : <a href="https://www.atelier-icare.net">https://www.atelier-icare.net</a>.</p>
<% if actif? %>
<p>Puisque vous êtes acti<%= fem(:ve) %> à l’atelier, vous devriez vous familiariser rapidement à cette nouvelle version qui, au niveau de l'ergonomie, a essayé de ne pas trop s’éloigner de la version précédente.</p>
<% end %>
<p><%= actif? ? "Veuillez" : "Vous n'êtes plus acti#{fem(:ve)} mais veuillez" %>
noter le point suivant, important :</p>
<ul>
  <li>après <a href="https://www.atelier-icare.net/user/login">vous être connecté<%= fem(:e) %></a>, vous devriez <a href="https://www.atelier-icare.net/bureau/preferences">rejoindre vos préférences</a> afin de les régler car certains nouveaux paramètres sont à prendre en compte (notamment le partage de votre historique de travail).</li>
</ul>
<p>Il est fort possible que des problèmes techniques surviennent lors de vos prochaines visites. N'hésitez jamais à nous les remonter dès que vous les rencontrez, afin que nous puissions les corriger le plus rapidement possible. Merci d'avance de votre compréhension et de votre patience.</p>
<p>J’espère que vous parvenez à faire de cette période particulière une occasion de plus écrire.</p>
<p>Bien à vous,</p>
~~~


### Tâches à faire ensuite

- [ ] Sur [AlwaysData](https://admin.alwaysdata.com/), détruire les autres DB (laisser juste `icare_db`)
