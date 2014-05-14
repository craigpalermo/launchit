'use strict'

App = angular.module("App")

App.controller "RegistrationCtrl", ($scope, $http, $location, $rootScope) ->
    # Registration Form
    $scope.register = ->
        $scope.error = false
        $scope.loading = true

        data = {
            username: $scope.username
            email:    $scope.email
            password: $scope.password
            zipcode:  $scope.zipcode
        }

        # validate form fields
        if $scope.password isnt $scope.confPassword
            $scope.message = "The passwords you entered don't match."
        else if not "#{$scope.zipcode}".match(/([0-9]){5}/)
            $scope.message = "Please enter a valid ZIP code."
        else
            # send data to server
            response = $http.post("/register", data)
            
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
              $scope.message = data["message"]
              return
            )

        return

    return

return
