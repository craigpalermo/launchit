"use strict"
App = angular.module('App', ['ngRoute', 'ui.bootstrap', 'ngCookies', 'angularFileUpload']).config([
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

App.run(['$cookieStore', '$http', '$rootScope', ($cookieStore, $http, $rootScope) ->
    # log user in if api_key cookie is present
    api_key = $cookieStore.get('api_key')
    if api_key and not $rootScope.user
        App.config ["$httpProvider",
            ($httpProvider) ->
              $httpProvider.defaults.headers.common["Authorization"] = "Token " + api_key
        ]
        response = $http.post('/api/login', { api_key: api_key })
        response.success((user, status) ->
            $rootScope.user = user

            # populate the main page with other users after logging in
            data = {
                zipcode:  $rootScope.user.profile.zipcode
            }

            response = $http.post("/api/users_in_range", data)
            
            response.success((data, status) ->
                $rootScope.users = data.data
                return
            ).error((data, status) ->
                return
            )
        )
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
