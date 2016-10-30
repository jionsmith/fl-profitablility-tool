'use strict';

/* Controllers */

var profitabilityApp = angular.module('profitabilityApp');

profitabilityApp.controller('ProjectEstimateCtrl', ['$scope', '$http', '$timeout', '$location', '$localStorage', '$routeParams', 'Auth',
  function($scope, $http, $timeout, $location, $localStorage, $routeParams, Auth) {

    var sortableEle;

    $scope.routeParams = $routeParams;

    $scope.resources = [];
    $scope.timelines = [];
    $scope.expenses = [];
    $scope.resource_timelines = [];
    $scope.project = {};
    $scope.updated_project = {};
    $scope.is_resource_changed = false;
    $scope.is_expense_changed = false;
    $scope.is_resource_timeline_changed = false;

    $scope.project_tags = [];

    $scope.bullet_count = 0;
    $scope.current_bullet_index = 0;
    $scope.current_min_timeline_index = 0;
    $scope.current_max_timeline_index = 0;
    $scope.resource_total_hours = [];
    $scope.total_hours = 0;
    $scope.gross_total_info = {
      gross_revenue: "0.00",
      gross_expense: "0.00",
      gross_profit: "0.00",
      gross_margin: "0.00",
    };

    $scope.is_click_insights = false;

    $scope.week_count_per_page = 4;

    $scope.resource_change = function() {
      $scope.is_resource_changed = true;
    }

    $scope.expense_change = function() {
      $scope.is_expense_changed = true;
    }

    $scope.load = function() {

      if (!Auth.isLoggedIn()) {
        $location.path('/signin');
        return;
      };

      var req = {
        method: 'GET',
        url: '/v1/projects/' + $scope.routeParams.project_id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {

        }
      }

      $http(req).then(function(data) {
        console.log(data);
        // $location.path('/projects/' + )
        $scope.project.id = data.data.project.id;
        $scope.project.name = data.data.project.name;
        $scope.project.project_tag = data.data.project.project_tag;
        $scope.project_tags = data.data.project.project_tags;
        $scope.project.category = data.data.project.category;
        $scope.project.revenue = data.data.project.revenue;
        $scope.expenses = data.data.project.expenses;
        $scope.resources = data.data.project.estimated_resources;
        $scope.timelines = data.data.project.estimated_timelines;
        $scope.resource_timelines = data.data.project.estimated_resource_timelines;
        $scope.client_id = data.data.project.client_id;

        $scope.after_load_project();
      }, function(data) {
        console.log(data);
      });
    }

    $scope.adjust_bullet_index = function() {
      $scope.bullet_count = Math.ceil($scope.timelines.length / $scope.week_count_per_page);
      if ($scope.bullet_count > 0) {
        if ($scope.current_bullet_index > $scope.bullet_count - 1) {
          $scope.current_bullet_index = $scope.bullet_count - 1
        };
        $scope.current_bullet_index = Math.min($scope.current_bullet_index, $scope.bullet_count - 1)
        $scope.current_min_timeline_index = $scope.current_bullet_index * $scope.week_count_per_page;
        $scope.current_max_timeline_index = Math.min(($scope.current_bullet_index + 1) * $scope.week_count_per_page - 1, $scope.timelines.length - 1);
      } else {
        $scope.current_min_timeline_index = 0;
        $scope.current_max_timeline_index = 0;
      }
    }

    $scope.after_load_project = function() {
      $scope.adjust_bullet_index();
      // $scope.cal_gross_total_info();
    }

    $scope.init = function() {
      $scope.load();
      fitScreenHeight();
      $('body').removeClass();
    }

    $scope.init();

    $scope.change_bullet_index = function(bullet_index) {
      if ($scope.current_bullet_index == bullet_index) {
        return;
      };
      $scope.current_bullet_index = bullet_index;
      $scope.adjust_bullet_index();
    }

    $scope.next_bullet_index = function() {
      $scope.current_bullet_index++;
      $scope.current_bullet_index = Math.min($scope.current_bullet_index, $scope.bullet_count - 1);
      $scope.adjust_bullet_index();
    }
    $scope.previous_bullet_index = function() {
      $scope.current_bullet_index--;
      $scope.current_bullet_index = Math.max($scope.current_bullet_index, 0);
      $scope.adjust_bullet_index();
    }


    $scope.cal_gross_total = function() {
      var gross_revenue = 0.0;
      if ($scope.project.category == "fixed_bid") {
        gross_revenue = parseFloat($scope.project.revenue);
      } else {
        for(var i = 0; i < $scope.resources.length; i++) {
          gross_revenue += $scope.cal_total_resource($scope.resources[i]).formatNumber();
        }
      }
      
      return gross_revenue.formatMoney();
    }

    $scope.cal_gross_expense = function() {
      var gross_expense = 0.0;
      if ($scope.project.category == "fixed_bid") {
        for (var i = 0; i < $scope.expenses.length; i++) {
          gross_expense += $scope.expenses[i].price.formatNumber();
        };
      } else {
        for(var i = 0; i < $scope.resources.length; i++) {
          gross_expense += $scope.cal_expense_resource($scope.resources[i]).formatNumber();
        }
      }
      return gross_expense.formatMoney();
    }

    $scope.cal_gross_profit = function() {
      var gross_profit = 0.0;
      if ($scope.project.category == "fixed_bid") {
        gross_profit = $scope.cal_gross_total().formatNumber() - $scope.cal_gross_expense().formatNumber();
      } else {
        for(var i = 0; i < $scope.resources.length; i++) {
          gross_profit += $scope.cal_profit_resource($scope.resources[i]).formatNumber();
        }
      }
      return gross_profit.formatMoney();
    }

    $scope.cal_gross_margin = function() {
      var gross_margin = 0.0;
      // var gross_revenue = $scope.cal_gross_total();
      var gross_revenue = $scope.cal_gross_total().formatNumber();
      // var gross_profit = $scope.cal_gross_profit();
      var gross_profit = $scope.cal_gross_profit().formatNumber();
      if (gross_revenue > 0) {
        gross_margin = gross_profit / gross_revenue * 100;
      };
      return gross_margin.formatMoney();
    }

    // $scope.cal_total_resource = function(resource_index) {
    //   var resource = $scope.resources[resource_index]
    //   var total = resource.client_rate.formatNumber() * total_hours;
    //   return total.formatMoney();
    // }
    $scope.cal_total_resource = function(resource) {
      var total_hours = $scope.cal_resource_total_hours(resource);
      var total = resource.client_rate.formatNumber() * total_hours;
      return total.formatMoney();
    }

    $scope.cal_expense_resource = function(resource) {
      var total_hours = $scope.cal_resource_total_hours(resource);
      var expense = resource.resource_rate.formatNumber() * total_hours;
      return expense.formatMoney();
    }

    $scope.cal_profit_resource = function(resource) {
      var total_hours = $scope.cal_resource_total_hours(resource);
      var profit = (resource.client_rate.formatNumber() - resource.resource_rate.formatNumber()) * total_hours;
      return profit.formatMoney();
    }


    $scope.cal_margin_resource = function(resource) {
      var total_hours = $scope.cal_resource_total_hours(resource);
      var total = total_hours * resource.client_rate.formatNumber();
      var profit = (resource.client_rate.formatNumber() - resource.resource_rate.formatNumber()) * total_hours;
      var margin = 0.0;
      if (total > 0) {
        margin = profit / total * 100;
      };
      return margin.formatMoney();
    }

    $scope.cal_resource_total_hours = function(resource) {
      var total_hours = 0;
      for(var i = 0; i < resource.resource_timelines.length; i++) {
        total_hours += resource.resource_timelines[i].hours.formatNumber();
      }
      return total_hours;
    }

    $scope.add_expense = function() {
      var expense = {
        expense: {
          name: '',
          job: '',
          price: 0.00,
          order_value: $scope.expenses.length
        }
      }

      var req = {
        method: 'POST',
        url: '/v1/projects/' + $scope.routeParams.project_id + '/expenses',
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: expense
      }
      // $scope.resources.push(resource);
      $http(req).then(function(data) {
        console.log(data);
        // $location.path('/projects/' + )
        $scope.project.id = data.data.project.id;
        $scope.project.name = data.data.project.name;
        $scope.project.project_tag = data.data.project.project_tag;

        $scope.expenses = data.data.project.expenses;
        // $scope.after_load_project();
      }, function(data) {
        console.log(data);
      });
    }

    $scope.add_resource = function() {
      var resource = {
        resource: {
          role: '',
          client_rate: 0.00,
          name: '',
          resource_rate: 0.00,
          is_estimated: true,
          order_value: $scope.resources.length
        }
      }

      var req = {
        method: 'POST',
        url: '/v1/projects/' + $scope.routeParams.project_id + '/resources',
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: resource
      }
      // $scope.resources.push(resource);
      $http(req).then(function(data) {
        console.log(data);
        // $location.path('/projects/' + )
        $scope.project.id = data.data.project.id;
        $scope.project.name = data.data.project.name;
        $scope.project.project_tag = data.data.project.project_tag;

        $scope.resources = data.data.project.estimated_resources;
        $scope.timelines = data.data.project.estimated_timelines;
        $scope.resource_timelines = data.data.project.estimated_resource_timelines;
        $scope.after_load_project();
      }, function(data) {
        console.log(data);
      });
    }

    $scope.remove_resource = function(resource_index) {
      var resource = $scope.resources[resource_index]
      var req = {
        method: 'DELETE',
        url: '/v1/projects/' + $scope.routeParams.project_id + '/resources/' + resource.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: resource
      }
      // $scope.resources.push(resource);
      $http(req).then(function(data) {
        console.log(data);
        $scope.project.id = data.data.project.id;
        $scope.project.name = data.data.project.name;
        $scope.project.project_tag = data.data.project.project_tag;

        $scope.resources = data.data.project.estimated_resources;
        $scope.timelines = data.data.project.estimated_timelines;
        $scope.resource_timelines = data.data.project.estimated_resource_timelines;
        $scope.after_load_project();
      }, function(data) {
        console.log(data);
      });
    }

    $scope.remove_expense = function(expense_index) {
      var expense = $scope.expenses[expense_index]
      var req = {
        method: 'DELETE',
        url: '/v1/projects/' + $scope.routeParams.project_id + '/expenses/' + expense.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: expense
      }
      // $scope.expenses.push(expense);
      $http(req).then(function(data) {
        console.log(data);
        $scope.project.id = data.data.project.id;
        $scope.project.name = data.data.project.name;
        $scope.project.project_tag = data.data.project.project_tag;

        $scope.expenses = data.data.project.expenses;

      }, function(data) {
        console.log(data);
      });
    }

    $scope.update_resource = function(resource, field_name) {
      if (!$scope.is_resource_changed) {
        return;
      };
      // var resource = $scope.resources[resource_index]

      var value = '';
      if (field_name == 'role') {
        value = resource.role;
      } else if(field_name == 'client_rate') {
        value = resource.client_rate;
      } else if (field_name == 'resource_rate') {
        value = resource.resource_rate;
      } else if (field_name == 'name') {
        value = resource.name;
      };

      var req = {
        method: 'PATCH',
        url: '/v1/projects/' + $scope.routeParams.project_id + '/resources/' + resource.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
          resource: {
            field_name: field_name,
            value: value
          }
        }
      }
      // $scope.resources.push(resource);
      $http(req).then(function(data) {
        console.log(data);
        // resource = data.data.resource
        // resource.client_rate = data.data.resource.client_rate;
        // resource.name = data.data.resource.name;
        // resource.resource_rate = data.data.resource.resource_rate;
        // resource.role = data.data.resource.role;

        if (field_name == 'role') {
          resource.role = data.data.value;
        } else if(field_name == 'client_rate') {
          resource.client_rate = data.data.value;
        } else if (field_name == 'resource_rate') {
          resource.resource_rate = data.data.value;
        } else if (field_name == 'name') {
          resource.name = data.data.value;
        };

        $scope.is_resource_changed = false;
      }, function(data) {
        console.log(data);
      });
    }

    $scope.update_expense = function(expense, field_name) {
      if (!$scope.is_expense_changed) {
        return;
      };
      // var expense = $scope.expenses[expense_index]

      var value = '';
      if (field_name == 'name') {
        value = expense.name;
      } else if(field_name == 'job') {
        value = expense.job;
      } else if (field_name == 'price') {
        value = expense.price;
      } else if (field_name == 'added_date') {
        value = expense.added_date;
      };

      var req = {
        method: 'PATCH',
        url: '/v1/projects/' + $scope.routeParams.project_id + '/expenses/' + expense.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
          expense: {
            field_name: field_name,
            value: value
          }
        }
      }
      // $scope.expenses.push(expense);
      $http(req).then(function(data) {
        console.log(data);
        
        if (field_name == 'name') {
          expense.name = data.data.value;
        } else if(field_name == 'job') {
          expense.job = data.data.value;
        } else if (field_name == 'price') {
          expense.price = data.data.value;
        } else if (field_name == 'added_date') {
          expense.added_date = data.data.value;
        };

        $scope.is_expense_changed = false;
      }, function(data) {
        console.log(data);
      });
    }

    $scope.convert_client_rate = function(resource) {
      resource.client_rate = resource.client_rate.formatNumber().toString();
      $scope.resource_change();
      // $scope.is_resource_changed = false;
    }

    $scope.convert_resource_rate = function(resource) {
      resource.resource_rate = resource.resource_rate.formatNumber().toString();
      $scope.resource_change();
      // $scope.is_resource_changed = false;
    }

    $scope.convert_timeline_hours = function(resource_timeline) {
      resource_timeline.hours = resource_timeline.hours.formatNumber().toString();
      $scope.resource_timeline_change();
    }

    $scope.add_timeline = function() {
      var timeline = {
        project_id: $scope.routeParams.project_id,
        is_estimated: true
      }
      var req = {
        method: 'POST',
        url: '/v1/projects/' + $scope.routeParams.project_id + '/timelines',
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
          timeline: timeline
        }
      }
      // $scope.resources.push(resource);
      $http(req).then(function(data) {
        console.log(data);
        // $location.path('/projects/' + )
        $scope.project.id = data.data.project.id;
        $scope.project.name = data.data.project.name;
        $scope.project.project_tag = data.data.project.project_tag;

        $scope.resources = data.data.project.estimated_resources;
        $scope.timelines = data.data.project.estimated_timelines;
        $scope.resource_timelines = data.data.project.estimated_resource_timelines;
        $scope.after_load_project();
      }, function(data) {
        console.log(data);
      });
    }

    $scope.remove_timeline = function(timeline_index) {
      var timeline = $scope.timelines[timeline_index]
      var req = {
        method: 'DELETE',
        url: '/v1/projects/' + $scope.routeParams.project_id + '/timelines/' + timeline.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: timeline
      }
      // $scope.timelines.push(timeline);
      $http(req).then(function(data) {
        console.log(data);
        $scope.project.id = data.data.project.id;
        $scope.project.name = data.data.project.name;
        $scope.project.project_tag = data.data.project.project_tag;

        $scope.resources = data.data.project.estimated_resources;
        $scope.timelines = data.data.project.estimated_timelines;
        $scope.resource_timelines = data.data.project.estimated_resource_timelines;
        $scope.after_load_project();
      }, function(data) {
        console.log(data);
      });
    }

    $scope.resource_timeline_change = function() {
      $scope.is_resource_timeline_changed = true;
    }

    $scope.update_resource_timeline = function(resource, timeline_index) {
      // if (!$scope.is_resource_timeline_changed) {
      //   return;
      // };
      var resource_timeline = resource.resource_timelines[timeline_index]
      var req = {
        method: 'PATCH',
        url: '/v1/resource_timelines/' + resource_timeline.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
          resource_timeline: resource_timeline
        }
      }
      // $scope.resources.push(resource);
      $http(req).then(function(data) {
        console.log(data);
        resource_timeline.hours = data.data.resource_timeline.hours
        $scope.is_resource_timeline_changed = false;
      }, function(data) {
        console.log(data);
      });
    }

    $scope.sign_out = function() {
      Auth.signOut();
    }

    $scope.send_message = function() {
      $('#modal-tell-us .modal-header button.close').trigger('click');
      $('.modal-backdrop').remove();
    }

    $scope.remove_project = function() {
      var req = {
        method: 'DELETE',
        url: '/v1/projects/' + $scope.project.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $('#modal-project-setting .modal-header button.close').trigger('click');
        $('#modal-remove-project .modal-header button.close').trigger('click');
        $('.modal-backdrop').remove();
        $location.path('/clients/' + $scope.client_id)

      }, function(data) {
        $('#modal-project-setting .modal-header button.close').trigger('click');
        $('#modal-remove-project .modal-header button.close').trigger('click');
        $('.modal-backdrop').remove();
        console.log(data);
      });
    }

    $scope.load_updated_project = function() {
      $scope.updated_project.name = $scope.project.name;
      $scope.updated_project.project_tag = $scope.project.project_tag;
    }

    $scope.update_project = function() {
      var req = {
        method: 'PUT',
        url: '/v1/projects/' + $scope.project.id,
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        data: {
          project: {
            name: $scope.updated_project.name,
            project_tag: $scope.updated_project.project_tag
          }
        }
      }

      $http(req).then(function(data) {
        console.log(data);
        $('#modal-project-setting .modal-header button.close').trigger('click');
        $('.modal-backdrop').remove();
        $scope.project.name = data.data.project.name;
        $scope.project.project_tag = data.data.project.project_tag;
      }, function(data) {
        $('#modal-project-setting .modal-header button.close').trigger('click');
        $('.modal-backdrop').remove();
        console.log(data);
      });
    }

    // $scope.blurOnEnterOnSameLevel = function($event) {
    //   if ( $event.keyCode != 13 )
    //     return
    //   $timeout(function () { jQuery($event.target).parent().next().find('input').focus() }, 0, false);
    // }

    // $scope.blurOnEnterOnOtherLevel = function($event) {
    //   if ( $event.keyCode != 13 )
    //     return
    //   $timeout(function () {
    //     var jNext = jQuery($event.target).parent().parent().next().find('input');
    //     if (jNext.length > 0) {
    //       jNext[0].focus();
    //     };
    //   }, 0, false);
    // }

    // when clicking the enter keyboard, focus next field
    $scope.blurOnEnterOnResource = function($event, resource_index) {
      if ( $event.keyCode != 13 )
        return
      if (resource_index == 3) {
        // focus other timeline
        $timeout(function () {
          var jNext = jQuery($event.target).parent().parent().next().find('input');
          if (jNext.length > 0) {
            jNext[0].focus();
          };
        }, 0, false);
      } else {
        // focus next field in same timeline
        $timeout(function () { jQuery($event.target).parent().next().find('input').focus() }, 0, false);
      }
    }

    $scope.blurOnEnterOnExpense = function($event, expense_index) {
      if ( $event.keyCode != 13 )
        return
      if (expense_index == 3) {
        // focus other timeline
        $timeout(function () {
          var jNext = jQuery($event.target).parent().parent().next().find('input');
          if (jNext.length > 0) {
            jNext[0].focus();
          };
        }, 0, false);
      } else {
        // focus next field in same timeline
        $timeout(function () { jQuery($event.target).parent().next().find('input').focus() }, 0, false);
      }
    }

    $scope.blurOnEnterOnTimeline = function($event, timeline_index) {
      if ( $event.keyCode != 13 )
        return
      if (timeline_index == 2) {
        // focus other timeline
        $timeout(function () {
          var jNext = jQuery($event.target).parent().parent().next().find('input');
          if (jNext.length > 0) {
            jNext[0].focus();
          };
        }, 0, false);
      } else {
        // focus next field in same timeline
        $timeout(function () { jQuery($event.target).parent().next().find('input').focus() }, 0, false);
      }
    }

    $scope.dragStart = function(e, ui) {
      console.log('drag start');
      ui.item.data('start', ui.item.index());
    }
    $scope.dragEnd = function(e, ui) {
      console.log('drag end');
      var start = ui.item.data('start'),
        end = ui.item.index();

      $scope.resources.splice(end, 0,
        $scope.resources.splice(start, 1)[0]);

      $scope.$apply();

      // update order status
      var params = [];
      for (var i = 0; i < $scope.resources.length; i++) {
        var param = {};
        param.id = $scope.resources[i].id
        param.value = i;
        params.push(param);
      };
      var req = {
        method: 'POST',
        headers: {
          "Authorization": $localStorage.logged_user.access_token
        },
        url: '/v1/resources/update_order',
        // url: '/v1/projects/' + $scope.routeParams.project_id + '/resources/update_order',
        data: {
          orders: params
        }
      }

      $http(req).then(function(data) {
        console.log(data);

      }, function(data) {
        console.log(data);
        $scope.errors = data.data.error_messages;
      });
    }

    sortableEle = $('#sortable').sortable({
      start: $scope.dragStart,
      update: $scope.dragEnd
    });

  }]);
