'use strict'

App = angular.module("App")

App.controller "IndexCtrl", ($scope, $http, $location, $rootScope, $cookieStore) ->
    # call this function to logout
    $scope.logout = ->
        $cookieStore.remove('api_key')
        $rootScope.user = null
        $location.path "/logout"

    # get popular interests
    $http({
        method: 'GET',
        url: '/api/fetch_popular/'
    }).success((response, status) ->
        $scope.popular = response.data
    ).error((response, status) ->
        $scope.error = true
        $scope.message = response.message
    )
