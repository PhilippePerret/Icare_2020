"use strict";

function LanceSimulationPhase(){
  const phase = document.querySelector("#current_phase").value;
  window.location = "concours/admin?op=simuler_phase&phase="+phase;
}
