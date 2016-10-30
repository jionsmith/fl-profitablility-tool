'use strict';

/* Controllers */

var profitabilityApp = angular.module('profitabilityApp');

profitabilityApp.controller('ProfileCtrl', ['$scope', '$http', '$location', '$localStorage', '$routeParams', 'Auth', 
  function($scope, $http, $location, $localStorage, $routeParams, Auth) {

    var sortableEle;


    $scope.email = '';
    $scope.name = '';
    $scope.password = '';
    $scope.password_confirmation = '';
    $scope.old_password = '';
    $scope.errors = [];
    $scope.is_super = false;
    $scope.is_admin = false;
    $scope.member_index = 0;
    $scope.invite_email = '';
    $scope.admins = [];
    $scope.members = [];

    // nothing to send
    $scope.invite_sent_status = 0;

    $scope.is_click_insights = false;

    
    $scope.init = function() {
      if (!Auth.isLoggedIn()) {
        $location.path('/signin');
        return;
      };
      if ($location.$$path == '/team') {
        $scope.load_team_members();
      } else {
        $scope.name = $localStorage.logged_user.name;
        $scope.email = $localStorage.logged_user.email;
      }

      fitScreenHeight();
      $('body').removeClass().addClass('short-header');
    }

    $scope.load_team_members = function() {
      var req = {
        method: 'GET',
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        url: '/v1/users/team_member',
        data: {
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $scope.super = data.data.super
        $scope.admins = data.data.admins
        $scope.members = data.data.members
        if ($scope.super.id == $localStorage.logged_user.id) {
          $scope.is_super = true;
        };
        for(var i = 0; i < $scope.members.length; i++) {
          if ($scope.members[i].name == null || $scope.members[i].name == '') {
            $scope.members[i].name = $scope.members[i].email;
          };
        }
        for(var i = 0; i < $scope.admins.length; i++) {
          if ($scope.admins[i].name == null || $scope.admins[i].name == '') {
            $scope.admins[i].name = $scope.admins[i].email;
          };
          if ($scope.admins[i].id == $localStorage.logged_user.id) {
            $scope.is_admin = true;
          };
        }
      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
      });
    }

    $scope.is_current_admin = function(admin_index) {
      if ($scope.admins[admin_index].id == $localStorage.logged_user.id) {
        return true;
      };
      return false;
    }

    $scope.is_current_member = function(member_index) {
      if ($scope.members[member_index].id == $localStorage.logged_user.id) {
        return true;
      };
      return false;
    }

    $scope.set_member_index = function(member_index) {
      $scope.member_index = member_index;
      console.log($scope.member_index);
    }

    $scope.make_admin = function(member_index) {
      var member = $scope.members[member_index];
      console.log(member);

      var req = {
        method: 'GET',
        url: '/v1/users/make_admin?member_id=' + member.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
          
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $scope.admins.push(member);
        $scope.members.splice(member_index, 1);
        $('#modal-make-admin .modal-header button.close').trigger('click');
      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
        $('#modal-make-admin .modal-header button.close').trigger('click');
      });
    }

    $scope.remove_member = function(member_index) {
      var member = $scope.members[member_index];
      console.log(member);

      var req = {
        method: 'GET',
        url: '/v1/users/remove_member?member_id=' + member.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
          
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $scope.members.splice(member_index, 1);
        $('#modal-remove-user .modal-header button.close').trigger('click');
      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
        $('#modal-remove-user .modal-header button.close').trigger('click');
      });
    }

    $scope.init();

    $scope.update_profile = function() {
      var req = {
        method: 'POST',
        url: '/v1/users/update_profile',
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
          user: {
            name: $scope.name,
            email: $scope.email,
            old_password: $scope.old_password,
            password: $scope.password,
            password_confirmation: $scope.password_confirmation
          }
          
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $localStorage.logged_user = data.data;
        $scope.name = $localStorage.logged_user.name;
        $scope.email = $localStorage.logged_user.email;
        $scope.password = '';
        $scope.password_confirmation = '';
        $scope.old_password = '';
        $location.path('/dashboard');

      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
      });
    }

    $scope.send_invite = function() {
      var req = {
        method: 'POST',
        url: '/v1/users/member_invite',
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
          invite_email: $scope.invite_email   
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        // $scope.invite_email = '';
        // $('#modal-add-team-member .modal-header button.close').trigger('click');
        $scope.load_team_members();
        $scope.invite_sent_status = 1; // success to send

      }, function(data) {
        console.log(data);
        $scope.invite_sent_status = 2; // failed to send
      });
    }

    $scope.sign_out = function() {
      Auth.signOut();
    }

    $scope.send_message = function() {
      $('#modal-tell-us .modal-header button.close').trigger('click');
      $('.modal-backdrop').remove();
    }

    $scope.get_member_name = function(member) {
      // if ($scope.admins[admin_index].id == $localStorage.logged_user.id) {
      //   return true;
      // };
      // return false;
      var name = member.name;
      if (member.id == $localStorage.logged_user.id) {
        name += ' (You)';
      } else {
        if (member.invite_token == null || member.invite_token == "") {
          name += ' (Joined)';
        } else {
          name += ' (Waiting to Join)';
        }
      }
      return name;
    }

    

  }]);