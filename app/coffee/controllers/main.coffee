'use strict'

App = angular.module("App")

App.controller "MainCtrl", ($scope, $http, $location, $rootScope) ->
    if $rootScope.user
        data = {
            zipcode:  $rootScope.user.profile.zipcode
        }

        # send data to server
        response = $http.post("/api/users_in_range", data)
        
        # response was success
        response.success((data, status) ->
            $scope.users = data
            return
        )
        
        # response was error
        response.error((data, status) ->
          $scope.error = true
          $scope.loading = false
          return
        )

return
