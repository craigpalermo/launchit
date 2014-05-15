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

    # Filters
    $scope.maxDistance = 10
    $scope.distanceFilter = (distance) ->
        return parseFloat(distance, 10) <= $scope.maxDistance

App.filter "interestFilter", ->
    (input, searchText, AND_OR) ->
        if not searchText
            return input
        else
            returnArray = []
            splitext = searchText.toLowerCase().split(/\s+/)
            regexp_and = "(?=.*" + splitext.join(")(?=.*") + ")"
            regexp_or = searchText.toLowerCase().replace(/\s+/g, "|")
            re = new RegExp((if (AND_OR is "AND") then regexp_and else regexp_or), "i")
            x = 0

            while x < input.length
                t = input[x].profile.interests.toString().replace /,/, " "
                returnArray.push input[x]  if re.test(t)
                x++

            # console.log regexp_or
            # console.log regexp_and
            returnArray

return
