paypal.Buttons({
  style: {shape:'rect',color:'blue',layout:'vertical',label:'pay'},
  createOrder: function(data, actions) {
    return actions.order.create({
      purchase_units: [{amount: {value: PAYPAL_MONTANT}}]
    });
  },
  onApprove: function(data, actions) {
    return actions.order.capture().then(function(details) {
      // alert('Transaction completed by ' + details.payer.name.given_name + '!');
      window.location="modules/paiement?op=ok";
    });
  }
}).render('#paypal-button-container');
