'use strict';

/* App Module */

var profitabilityApp = angular.module('profitabilityApp', [
  'ngRoute',
  'ngStorage',
  'ngResource'
]);


profitabilityApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/phones', {
        templateUrl: 'partials/phone-list.html',
        controller: 'PhoneListCtrl'
      }).
      when('/phones/:phoneId', {
        templateUrl: 'partials/phone-detail.html',
        controller: 'PhoneDetailCtrl'
      }).
      when('/member-signup/:token', {
        templateUrl: 'users/member-signup.html',
        controller: 'SignupCtrl'
      }).
      when('/forgot-pass/:token', {
        templateUrl: 'users/forgot-pass.html',
        controller: 'SignupCtrl'
      }).
      when('/signup', {
        templateUrl: 'users/signup.html',
        controller: 'SignupCtrl'
      }).
      when('/signup-organisation', {
        templateUrl: 'users/signup-organisation.html',
        controller: 'SignupCtrl'
      }).
      when('/signup-done', {
        templateUrl: 'users/signup-done.html',
        controller: 'SignupCtrl'
      }).
      when('/signin', {
        templateUrl: 'users/signin.html',
        controller: 'SigninCtrl'
      }).
      when('/dashboard', {
        templateUrl: 'dashboard/dashboard.html',
        controller: 'DashboardCtrl'
      }).
      when('/dashboard-empty', {
        templateUrl: 'dashboard/dashboard-empty.html',
        controller: 'DashboardCtrl'
      }).
      when('/add-client', {
        templateUrl: 'client/add-client.html',
        controller: 'ClientCtrl'
      }).
      when('/clients/:client_id', {
        templateUrl: 'client/client.html',
        controller: 'ClientCtrl'
      }).
      when('/projects/:project_id/estimate', {
        templateUrl: 'project/project-estimate.html',
        controller: 'ProjectEstimateCtrl'
      }).
      when('/projects/:project_id/actual', {
        templateUrl: 'project/project-actual.html',
        controller: 'ProjectEstimateCtrl'
      }).
      when('/settings', {
        templateUrl: 'profile/settings.html',
        controller: 'ProfileCtrl'
      }).
      when('/team', {
        templateUrl: 'profile/team.html',
        controller: 'ProfileCtrl'
      }).
      otherwise({
        redirectTo: '/dashboard'
      });
  }]);
