"use strict";
/**
 * Toutes les méthodes pour gérer les requêtes Database
 */
class DB {
static exec(request){
  return Ajax.send("db_exec.rb", {request: request})
}

}
