'use strict';

// NOTE : les lignes marquées d'une astérisque ("// *") sont ajoutées ou
// modifiées par moi.
paypal.Buttons({
  style: {shape:'rect',color:'blue',layout:'vertical',label:'pay'},
  createOrder: function(data, actions) {
    var result = actions.order.create({ // *
      purchase_units: [{amount: {value: PAYPAL_MONTANT}}]
    });
    // Normalement result.value contient le paiement_id (qui sera utilisé plus
    // bas pour le paiement). Ici, je vais essayer de l'envoyer par ajax pour
    // mémoire
    // Ajax.send("consigne_paiement", result)
    return result; // *

    // Seul code original :
    // --------------------
    // return actions.order.create({
    //   purchase_units: [{amount: {value: PAYPAL_MONTANT}}]
    // });
  },
  onApprove: function(data, actions) {
    return actions.order.capture().then(function(details) {
      document.querySelector('#paypal-button-container').remove();
      window.location=`modules/paiement?op=onApprove&paiement_id=${details.id}`;
    });
  }
}).render('#paypal-button-container');
