'use strict';

/* Controllers */

var profitabilityApp = angular.module('profitabilityApp');

profitabilityApp.controller('DashboardCtrl', ['$scope', '$http', '$location', '$localStorage', '$routeParams', 'Auth',
  function($scope, $http, $location, $localStorage, $routeParams, Auth) {


    $scope.clients = [];

    $scope.gross_info = {
      revenue: 0.0,
      expense: 0.0,
      profit: 0.0,
      margin: 0.0
    }
    $scope.selected_client = null;

    $scope.is_click_insights = false;

    $scope.predicate = '';
    $scope.reverse = false;

    $scope.order = function(predicate) {
      $scope.reverse = ($scope.predicate === predicate) ? !$scope.reverse : false;
      $scope.predicate = predicate;
    };

    $scope.init = function() {

      if (!Auth.isLoggedIn()) {
        $location.path('/signin');
        return;
      };

      var req = {
        method: 'GET',
        url: '/v1/users/clients',
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {

        }
      }

      $http(req).then(function(data) {
        // console.log(data);
        $scope.clients = data.data.clients;

        for(var i = 0; i < $scope.clients.length; i++) {
          $scope.clients[i].estimated_gross_info.gross_margin = parseFloat($scope.clients[i].estimated_gross_info.gross_margin);
        }

        console.log($scope.clients);

        $scope.load_gross_info();
        console.log($scope.gross_info);

        if ($scope.clients.length == 0) {
          $('#dashboard-wizard').modal('show');
        };
        fitScreenHeight();
        $('body').removeClass();

      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
      });

    }

    $scope.load_gross_info = function() {
      var total_revenue = 0.0
      var total_expense = 0.0
      var total_profit = 0.0
      var total_margin = 0.0

      for(var i = 0; i < $scope.clients.length; i++) {
        total_revenue += parseFloat($scope.clients[i].estimated_gross_info.gross_revenue.toString());
        total_expense += parseFloat($scope.clients[i].estimated_gross_info.gross_expense.toString());
        total_profit += parseFloat($scope.clients[i].estimated_gross_info.gross_profit.toString());
      }

      if (total_revenue > 0) {
        total_margin = total_profit / total_revenue * 100;
      };
      $scope.gross_info = {
        revenue: total_revenue.formatMoney(),
        expense: total_expense.formatMoney(),
        profit: total_profit.formatMoney(),
        margin: total_margin.formatMoney()
      }
    }

    $scope.init();

    $scope.add_client = function() {
      $location.path("/add-client");
    }

    $scope.goto_client = function(client_id) {
      $location.path("/clients/" + client_id)
    }


    $scope.show_display_gross_revenue = function(client) {
      return client.estimated_gross_info.gross_revenue.toString().formatNumber().formatMoney();
    }

    $scope.show_display_gross_expense = function(client) {
      return client.estimated_gross_info.gross_expense.toString().formatNumber().formatMoney();
    }

    $scope.show_display_gross_profit = function(client) {
      return client.estimated_gross_info.gross_profit.toString().formatNumber().formatMoney();
    }

    $scope.show_display_gross_margin = function(client) {
      return client.estimated_gross_info.gross_margin.toString().formatNumber().formatMoney();
    }

    $scope.remove_client = function() {
      if ($scope.selected_client == null) {
        $('#modal-remove-client .modal-header button.close').trigger('click');
        return;
      };

      var req = {
        method: 'DELETE',
        url: '/v1/users/clients/' + $scope.selected_client.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        var client_index = $scope.clients.indexOf($scope.selected_client);
        $scope.clients.splice(client_index, 1);
        $scope.selected_client = null;
        $scope.load_gross_info();
        $('#modal-remove-client .modal-header button.close').trigger('click');

      }, function(data) {
        console.log(data);
      });

      // console.log(client);
    }

    $scope.set_client = function(client) {
      $scope.selected_client = client;
      console.log($scope.selected_client);
    }

    $scope.sign_out = function() {
      Auth.signOut();
    }

    $scope.send_message = function() {
      $('#modal-tell-us .modal-header button.close').trigger('click');
      $('.modal-backdrop').remove();
    }

  }]);
