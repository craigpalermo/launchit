(function() {
  "use strict";
  var App;

  App = angular.module("App", ["ngRoute"]).config([
    "$routeProvider", "$locationProvider", function($routeProvider) {
      return $routeProvider.when("/", {
        templateUrl: "/static/views/home.html"
      }).when("/register", {
        templateUrl: "/static/views/signup.html"
      }).otherwise({
        redirectTo: "/"
      });
    }
  ]);

  App.directive("activeLink", [
    "$location", function(location) {
      return {
        restrict: "A",
        link: function(scope, element, attrs, controller) {
          var clazz, path;
          clazz = attrs.activeLink;
          path = $(element).find("a").attr("href").substring(1);
          scope.location = location;
          scope.$watch("location.path()", function(newPath) {
            if (path === newPath) {
              element.addClass(clazz);
            } else {
              element.removeClass(clazz);
            }
          });
        }
      };
    }
  ]);

  "use strict";

  App.controller("LoginCtrl", function($scope, $http, $location, $rootScope) {
    $scope.login = function() {
      var response;
      $scope.error = false;
      $scope.loading = true;
      response = $http.get("/auth", {
        headers: {
          Authorization: $scope.username + ":" + $scope.password
        }
      });
      response.success(function(user, status) {
        $rootScope.user = user;
        App.config([
          "$httpProvider", function($httpProvider) {
            return $httpProvider.defaults.headers.common["Authorization"] = "Token " + user.api_key;
          }
        ]);
        $location.path("/");
      });
      response.error(function(data, status) {
        $scope.error = true;
        $scope.loading = false;
        $scope.message = data['message'];
      });
    };
  });

  "use strict";

  App.controller("MainCtrl", function($scope) {
    $scope.awesomeThings = ["HTML5 Boilerplate", "AngularJS", "Testacular", "django-restframework", "django-south", "django-compressor"];
  });

  "use strict";

  App.controller("RegistrationCtrl", function($scope, $http, $location, $rootScope) {
    return $scope.register = function() {
      var data, response;
      $scope.error = false;
      $scope.loading = true;
      data = {
        username: $scope.username,
        email: $scope.email,
        password: $scope.password,
        zipcode: $scope.zipcode
      };
      if ($scope.password !== $scope.confPassword) {
        $scope.message = "The passwords you entered don't match.";
      } else if (!("" + $scope.zipcode).match(/([0-9]){5}/)) {
        $scope.message = "Please enter a valid ZIP code.";
      } else {
        response = $http.post("/register", data);
        response.success(function(user, status) {
          $rootScope.user = user;
          App.config([
            "$httpProvider", function($httpProvider) {
              return $httpProvider.defaults.headers.common["Authorization"] = "Token " + user.api_key;
            }
          ]);
          $location.path("/");
        });
        response.error(function(data, status) {
          $scope.error = true;
          $scope.loading = false;
          $scope.message = data["message"];
        });
      }
    };
  });

  return;

}).call(this);
