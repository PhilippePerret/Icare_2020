function clip(code){
  navigator.clipboard.writeText(code)
  .then(()=>console.log("Message copié dans le presse-papier"))
  .catch(console.err);
}

function raise(msg){
  alert(`PROBLÈME : ${msg}`) ;
  console.error(msg)
  throw new Error(msg) ;
}
