/**
Pour obtenir la liste de valeurs ci-dessous, il faut lancer ce script d'une ligne en console :
var h = {}; document.querySelectorAll('#checklist div.line-note select').forEach(m => {Object.assign(h, { [m.getAttribute('name')]: m.value } )  }); console.log(h)

*/

// Pour remettre les notes au formulaire de "LE SECRET"
var h = {"po":"4","po-fO":"3","po-fU":"4","po-adth":"1","po-ti":"4","po-ti-fO":"1","po-ti-fU":"4","po-ti-adth":"1","po-p":"3","po-p-fO":"2","po-p-fU":"4","po-p-adth":"2","po-p-cohe":"4","po-p-idio":"1","po-p-prota":"3","po-p-prota-fO":"1","po-p-prota-fU":"4","po-p-prota-adth":"x","po-p-prota-cohe":"5","po-p-prota-idio":"2","po-p-anta":"3","po-p-anta-fO":"2","po-p-anta-fU":"4","po-p-anta-adth":"x","po-p-anta-cohe":"3","po-p-anta-idio":"2","po-p-psec":"x","po-p-psec-fO":"x","po-p-psec-fU":"x","po-p-psec-adth":"x","po-p-psec-cohe":"x","po-p-psec-idio":"x","po-p-autp":"x","po-p-autp-fO":"x","po-p-autp-fU":"x","po-p-autp-adth":"x","po-p-autp-cohe":"x","po-p-autp-idio":"x","po-p-dials":"x","po-p-dials-fO":"x","po-p-dials-fU":"x","po-p-dials-adth":"x","po-p-dials-cohe":"x","po-p-dials-idio":"x","po-f":"3","po-f-fO":"x","po-f-fU":"x","po-f-adth":"x","po-f-pfa":"3","po-f-3acts":"3","po-f-foncact":"3","po-f-pvts":"3","po-i":"3","po-i-fO":"2","po-i-fU":"3","po-i-adth":"1","po-i-cohe":"4","po-i-menee":"3","po-i-predic":"2","po-i-mainint":"x","po-i-mainint-fO":"x","po-i-mainint-fU":"x","po-i-mainint-adth":"x","po-i-mainint-cohe":"x","po-i-mainint-menee":"x","po-i-mainint-predic":"x","po-i-secint":"x","po-i-secint-fO":"x","po-i-secint-fU":"x","po-i-secint-adth":"x","po-i-secint-cohe":"x","po-i-secint-menee":"x","po-i-secint-predic":"x","po-i-autint":"x","po-i-autint-fO":"x","po-i-autint-fU":"x","po-i-autint-adth":"x","po-i-autint-cohe":"x","po-i-autint-menee":"x","po-i-autint-predic":"x","po-t":"4","po-t-fO":"3","po-t-fU":"4","po-t-adth":"1","po-t-cla":"5","po-t-cohe":"4","po-t-antithese":"x","po-t-thprinc":"x","po-t-thprinc-fO":"x","po-t-thprinc-fU":"x","po-t-thprinc-adth":"x","po-t-thprinc-cla":"x","po-t-thprinc-cohe":"x","po-t-thprinc-antithese":"x","po-t-thsec":"x","po-t-thsec-fO":"x","po-t-thsec-fU":"x","po-t-thsec-adth":"x","po-t-thsec-cla":"x","po-t-thsec-cohe":"x","po-t-thsec-antithese":"x","po-r":"4","po-r-cla":"4","po-r-cla-fO":"x","po-r-cla-fU":"x","po-r-cla-adth":"x","po-r-ortho":"3","po-r-ortho-fO":"x","po-r-ortho-fU":"x","po-r-ortho-adth":"x","po-r-style":"4","po-r-style-fO":"x","po-r-style-fU":"x","po-r-style-adth":"x","po-r-sim":"5","po-r-sim-fO":"x","po-r-sim-fU":"x","po-r-sim-adth":"x","po-r-emo":"4","po-r-emo-fO":"x","po-r-emo-fU":"x","po-r-emo-adth":"x"}
for (var key in h){
  document.querySelector(`select[name="${key}"]`).value = h[key]
}
