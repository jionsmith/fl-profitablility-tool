'use strict';

/* Controllers */

var profitabilityApp = angular.module('profitabilityApp');

profitabilityApp.controller('SigninCtrl', ['$scope', '$http', '$location', '$localStorage', '$routeParams', 'Auth', 
  function($scope, $http, $location, $localStorage, $routeParams, Auth) {
    $scope.email = '';
    $scope.password = '';
    $scope.errors = [];
    $scope.forgot_email = '';
    $scope.member_access_token = '';

    $scope.is_click_insights = false;
    
    $scope.init = function() {
      if (Auth.isLoggedIn()) {
        $location.path('/dashboard');
        return;
      };
      $('body').removeClass().addClass('no-bg');
    }

    $scope.init();

    $scope.signin_user = function() {
      var req = {
        method: 'POST',
        url: '/v1/users/signin',
        data: {
          email: $scope.email,
          password: $scope.password,
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $localStorage.logged_user = data.data;
        $location.path( "/dashboard" );
      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
      });
    }

    $scope.forgot_pass = function() {
      var req = {
        method: 'POST',
        url: '/v1/users/send_forgot_email',
        data: {
          forgot_email: $scope.forgot_email   
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $('#modal-forgot-pass .modal-header button.close').trigger('click');

      }, function(data) {
        $('#modal-forgot-pass .modal-header button.close').trigger('click');
        console.log(data);
      });
    }

    $scope.send_message = function() {
      $('#modal-tell-us .modal-header button.close').trigger('click');
      $('.modal-backdrop').remove();
    }

    
  }]);