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
        
return
