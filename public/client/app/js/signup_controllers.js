'use strict';

/* Controllers */

var profitabilityApp = angular.module('profitabilityApp');

profitabilityApp.controller('SignupCtrl', ['$scope', '$http', '$location', '$localStorage', '$routeParams', 'Auth',
  function($scope, $http, $location, $localStorage, $routeParams, Auth) {
    $scope.name = '';
    $scope.email = '';
    $scope.password = $scope.password_confirmation = '';
    $scope.errors = [];
    $scope.organisation_name = '';
    $scope.parent_organisation_name = '';
    $scope.project_tags = [];
    $scope.project_tag_str = '';
    $scope.member_access_token = '';

    $scope.is_click_insights = false;

    // $localStorage.logged_user = null;

    $scope.init = function() {
      if ($location.$$path.indexOf('/member-signup/') !== -1 || $location.$$path.indexOf('/forgot-pass/') !== -1) {
        var req = {
          method: 'POST',
          url: '/v1/users/get_member_by_token',
          data: {
            token: $routeParams.token
          }
        }

        $http(req).then(function(data) {
          console.log(data);
          $scope.name = data.data.name;
          $scope.member_access_token = data.data.access_token;
          $scope.email = data.data.email;
          $scope.parent_organisation_name = data.data.parent_organisation_name;
        }, function(data) {
          console.log(data);
          $scope.errors = data.data.error_messages;
        });

        fitScreenHeight();
        $('body').removeClass().addClass('no-bg');
        return;
      };
      if (Auth.isLoggedIn()) {
        console.log($localStorage.logged_user);
        $scope.organisation_name = $localStorage.logged_user.organisation_name;
        if ($location.$$path != '/signup-organisation' && $location.$$path != '/signup-done' ) {
          $location.path('/dashboard');
          return;
        }
      };
      fitScreenHeight();
      $('body').removeClass().addClass('no-bg');
    }

    $scope.init();

    $scope.create_user = function() {
      var req = {
        method: 'POST',
        url: '/v1/users',
        data: {
          user: {
            name: $scope.name,
            email: $scope.email,
            password: $scope.password,
            password_confirmation: $scope.password_confirmation,
            super: true,
            admin: false
          }
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $localStorage.logged_user = data.data;
        $location.path( "/signup-organisation" );
      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
      });
    };

    $scope.update_member = function() {
      var req = {
        method: 'POST',
        url: '/v1/users/complete_member',
        headers: {
          "Authorization": $scope.member_access_token
        },
        data: {
          user: {
            name: $scope.name,
            password: $scope.password,
            password_confirmation: $scope.password_confirmation
          }

        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $localStorage.logged_user = data.data;
        $scope.name = $localStorage.logged_user.name;
        $scope.password = '';
        $scope.password_confirmation = '';
        $location.path('/dashboard');

      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
      });
    }

    $scope.project_tag_change = function() {
      if ($scope.project_tag_str == null || $scope.project_tag_str == undefined) {
        $scope.project_tags = [];
        return;
      };
      var project_tags = $scope.project_tag_str.split(",");
      $scope.project_tags = [];
      for(var i = 0; i < project_tags.length; i++) {
        if (project_tags[i].trim() != "") {
          $scope.project_tags.push(project_tags[i].trim());
        };
      }
    }

    $scope.remove_project_tag = function(index) {
      $scope.project_tags.splice(index, 1);
      $scope.project_tag_str = $scope.project_tags.join();
    }

    $scope.update_organisation = function() {
      var req = {
        method: 'POST',
        url: '/v1/users/update_organisation',
        data: {
          user: {
            id: $localStorage.logged_user.id,
            project_tags: $scope.project_tags,
            organisation_name: $scope.organisation_name
          }
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $localStorage.logged_user = data.data;
        $location.path( "/signup-done" );
      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
      });
    }

    $scope.start_insights = function() {
      $location.path("/dashboard");
    }

    $scope.send_message = function() {
      $('#modal-tell-us .modal-header button.close').trigger('click');
      $('.modal-backdrop').remove();
    }

  }]);
