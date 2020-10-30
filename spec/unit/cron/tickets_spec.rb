# encoding: UTF-8
# frozen_string_literal: true
describe 'CRONJOB' do
  describe 'Les tickets' do

    def nombre_tickets
      db_count('tickets')
    end #/ nombre_tickets

    before(:each) do
      require_support('cronjob')
      require_support('ticket')

      # Il faut créer différents tickets
      TTicket.reset
      TTicket.create(nombre:10, between:(-60..-30))
      TTicket.create(nombre:15, between:(-28..0))
      TTicket.create(nombre:20, between:(0..10))

      expect(nombre_tickets).to eq(45)
      # On fige le nombre de tickets actuels
      @nombre_tickets_init = nombre_tickets.freeze

    end
    let(:nombre_tickets_init) { @nombre_tickets_init }

    context 'à l’heure prévue' do
      it 'sont supprimés s’ils sont plus vieux que 30 jours et l’auto-incrément est réajusté', only:true do
        htime = "2020/10/25/1/15"
        res = run_cronjob(noop:false, time:htime)
        expect(nombre_tickets).to eq(nombre_tickets_init - 10),
          "10 tickets trop vieux auraient dû être détruits (#{nombre_tickets} tickets dans la DB contre #{nombre_tickets - 10} attendus)"

        # L'incrément a dû être modifié
        res = db_exec("SELECT id FROM tickets ORDER BY id DESC LIMIT 1")
        max_id = res.first[:id]
        expect(db_auto_increment('tickets')).to eq(max_id + 1)

        # Un message correct se trouve dans le rapport
        expect(cron_report(htime)).to include "Nombre de tickets détruits : 10"
      end
    end #/context à l'heure prévue

    context 'à l’heure non prévue' do
      it 'ne supprime rien' do
        res = run_cronjob(noop:false, time:"2020/10/23/0/12")
        expect(nombre_tickets).to eq(nombre_tickets_init)
        res = run_cronjob(noop:false, time:"2020/10/23/2/12")
        expect(nombre_tickets).to eq(nombre_tickets_init)
        res = run_cronjob(noop:false, time:"2020/10/23/3/12")
        expect(nombre_tickets).to eq(nombre_tickets_init)
        res = run_cronjob(noop:false, time:"2020/10/23/4/12")
        expect(nombre_tickets).to eq(nombre_tickets_init)
        res = run_cronjob(noop:false, time:"2020/10/23/5/12")
        expect(nombre_tickets).to eq(nombre_tickets_init)
      end
    end # contexte à l'heure non prévue

  end #/describe les tickets

end
