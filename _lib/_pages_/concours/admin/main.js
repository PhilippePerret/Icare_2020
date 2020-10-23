"use strict";

function LanceSimulationStep(){
  const step = document.querySelector("#current_step").value;
  window.location = "concours/admin?op=simuler_step&step="+step;
}
