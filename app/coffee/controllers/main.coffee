'use strict'

App = angular.module("App")

App.controller "MainCtrl", ($scope, $http, $location, $rootScope) ->
    # set flags for the home page
    $scope.error = false
    $scope.empty = false

    if $rootScope.user
        data = {
            zipcode:  $rootScope.user.profile.zipcode
        }

        # send data to server
        response = $http.post("/api/users_in_range", data)
        
        # response was success
        response.success((data, status) ->
            $scope.users = data
            $scope.empty = if data.length then false else true
            return
        )
        
        # response was error
        response.error((data, status) ->
          $scope.error = true
          $scope.loading = false
          return
        )

    # button to change route to signup page
    $scope.goRegister = ->
        $location.path('/register')

    # only display other users whos interests match this user
    $scope.matchMyInterests = ->
        search = ""
        for item in $rootScope.user.profile.interests
            search += "#{item} "
        $scope.searchValues = search

App.filter "distanceFilter", ->
    (input, distance) ->
        if not distance
            return input
        else
            returnArray = []
            x = 0
            while x < input.length
                if input[x].distance <= parseFloat(distance)
                    returnArray.push(input[x])
                x++
            return returnArray

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
