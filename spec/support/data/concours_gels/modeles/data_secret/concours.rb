# encoding: UTF-8
# frozen_string_literal: true
CODE_SECRET_FILE = <<-RUBY

CONCOURS_MAIL = "concours@atelier-icare.net"

CONCOURS_DATA = {
  evaluators: %{current_evaluators},
  # [
  #   {pseudo: "Phil",    id:1, jury:3, mail:'phil@atelier-icare.net', password: "19ElieSalome64", sexe:'H'},
  #   {pseudo: "Marion",  id:2, jury:3, mail:'marion.michel31@free.fr', password: '1piscine', sexe:'F'},
  #   {pseudo: "Benoit",  id:3, jury:3, mail:'benoit.ackerman@yahoo.fr', password: 'bozoleclown', sexe:'H'}
  # ],
  previous_sessions: {
    2020 => [
      {pseudo: "Phil",    jury:3, mail:'phil@atelier-icare.net', password: "19ElieSalome64", sexe:'H'},
      {pseudo: "Marion",  jury:3, mail:'marion.michel31@free.fr', password: '1piscine', sexe:'F'},
      {pseudo: "Benoit",  id:3, jury:3, mail:'benoit.ackerman@yahoo.fr', password: 'bozoleclown', sexe:'H'}
    ]
  },
  me: {mail: "phil@atelier-icare.net", concurrent_id: "20201024120049"},
}

RUBY
