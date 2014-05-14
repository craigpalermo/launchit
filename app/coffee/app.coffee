"use strict"
App = angular.module("App", ["ngRoute"]).config([
  "$routeProvider"
  "$locationProvider"
  ($routeProvider) ->
    $routeProvider.when("/",
        templateUrl: "/static/views/home.html",
        controller:  "MainCtrl"
    ).when("/register",
        templateUrl: "/static/views/signup.html"
    ).otherwise(redirectTo: "/")
])

App.directive "activeLink", [
  "$location"
  (location) ->
    return (
      restrict: "A"
      link: (scope, element, attrs, controller) ->
        clazz = attrs.activeLink
        path = $(element).find("a").attr("href").substring(1)
        scope.location = location
        scope.$watch "location.path()", (newPath) ->
          if path is newPath
            element.addClass clazz
          else
            element.removeClass clazz
          return

        return
    )
]
