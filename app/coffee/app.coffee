"use strict"
App = angular.module('App', ['ngRoute', 'ngCookies']).config([
    "$routeProvider"
    "$locationProvider"
    ($routeProvider) ->
        $routeProvider.when("/",
            templateUrl: "/static/views/home.html",
            controller:  "MainCtrl"
        ).when("/account",
            templateUrl: "/static/views/account.html",
            controller: "AccountCtrl"
        ).when("/register",
            templateUrl: "/static/views/signup.html"
        ).otherwise(redirectTo: "/")
])

App.config(['$httpProvider', ($httpProvider, $cookieStore) ->
    $httpProvider.defaults.xsrfCookieName = 'csrftoken'
    $httpProvider.defaults.xsrfHeaderName = 'X-CSRFToken'
])

App.run(['$cookieStore', ($cookieStore) ->
    # log user in if api_cookie present
    api_key = $cookieStore.get('api_key')
    if api_key and not user
        App.config ["$httpProvider",
            ($httpProvider) ->
              $httpProvider.defaults.headers.common["Authorization"] = "Token " + api_key 
        ]
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
