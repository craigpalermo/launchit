'use strict'

App = angular.module('App')

App.controller "LoginCtrl", ($scope, $http, $location, $rootScope, $cookieStore) ->
    # Login Form
    $scope.login = ->
        $scope.error = false
        $scope.loading = true
        
        # set response header and send to server
        response = $http({
            method: "post",
            url: "/auth",
            data: {
                    username: $scope.username,
                    password: $scope.password
            }
        })
        
        # response was success
        response.success((user, status) ->
            $rootScope.user = user
            App.config ["$httpProvider",
                ($httpProvider) ->
                  $httpProvider.defaults.headers.common["Authorization"] = "Token " + user.api_key
            ]
            $cookieStore.put('api_key', user.api_key)
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
