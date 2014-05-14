'use strict'

App = angular.module('App')

App.controller "LoginCtrl", ($scope, $http, $location, $rootScope) ->
    # Login Form
    $scope.login = ->
        $scope.error = false
        $scope.loading = true
        
        # set response header and send to server
        response = $http.get("/auth",
            headers:
                Authorization: $scope.username + ":" + $scope.password
        )
        
        # response was success
        response.success((user, status) ->
            $rootScope.user = user
            App.config ["$httpProvider",
                ($httpProvider) ->
                  $httpProvider.defaults.headers.common["Authorization"] = "Token " + user.api_key
            ]
            $location.path "/"
            return
        )
        # response was error
        response.error((data, status) ->
            $scope.error = true
            $scope.loading = false
            $scope.message = data['message']
            return
        )

        return
    return
return
