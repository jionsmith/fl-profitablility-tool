'use strict';

/* Services */

function AuthService($http, $localStorage, $location){

  /**
  * Check whether the user is logged in
  * @returns boolean
  */
  this.isLoggedIn = function isLoggedIn(){
    return ($localStorage.logged_user !== null && $localStorage.logged_user !== undefined)
  };

  this.signOut = function(){
    $localStorage.logged_user = null;
    $location.path('/signin');
  };

}

// Inject dependencies
AuthService.$inject = ['$http', '$localStorage', '$location'];

// Export
angular
  .module('profitabilityApp')
  .service('Auth', AuthService);
