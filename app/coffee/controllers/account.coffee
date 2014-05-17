'use strict'

App = angular.module('App')

App.controller "AccountCtrl", ($scope, $http, $location, $rootScope) ->
    $scope.myInterests = $rootScope.user.profile.interests

    $scope.add_interest = ->
        data = { interest: $scope.interest }
        response = $http.post("/api/add_interest/", data)
        response.success((data, status) ->
            $scope.myInterests.push($scope.interest)
            $scope.interest = ''
        )
        
    $scope.remove_interest = (interest) ->
        data = { interest: interest }
        response = $http.post("/api/remove_interest/", data)
        response.success((data, status) ->
            index = $scope.myInterests.indexOf interest
            $scope.myInterests.splice(index, 1) if index isnt -1
        )

return
