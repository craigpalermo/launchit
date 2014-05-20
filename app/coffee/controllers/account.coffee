'use strict'

App = angular.module('App')

App.controller "AccountCtrl", ($scope, $upload, $http, $location, $rootScope) ->
    # if not logged in, redirect to login page
    if not $rootScope.user
        $location.path '/register'

    $scope.myInterests = $rootScope.user.profile.interests

    # forward click on image to file upload field
    $('#profPicContainer .text-content, img').on('click', ->
        $("#file").click()
    )

    # get interests from db for autocomplete
    $http({
        method: 'GET',
        url: '/api/fetch_interests/'
    }).success((data, status) ->
        $scope.interests = data.data
    ).error((data, status) ->
        $scope.error = true
        $scope.message = data.message
    )

    # set image link for profile picture
    if $rootScope.user.profile.avatar isnt ''
        $scope.profPic = '/media/' + $rootScope.user.profile.avatar
    else
        $scope.profPic = 'https://placefull.com/Content/Properties/base/images/no-profile-image.png'

    # add interest to account
    $scope.add_interest = ->
        data = { interest: $scope.selected }
        response = $http.post("/api/add_interest/", data)
        response.success((data, status) ->
            $scope.error = false
            if $scope.selected not in $scope.myInterests
                $scope.myInterests.push($scope.selected)
                $scope.selected = ''
        ).error((data, status) ->
            $scope.error = true
            $scope.message = data.message
        )

    # remove interest from account
    $scope.remove_interest = (interest) ->
        data = { interest: interest }
        response = $http.post("/api/remove_interest/", data)
        response.success((data, status) ->
            index = $scope.myInterests.indexOf interest
            $scope.myInterests.splice(index, 1) if index isnt -1
        ).error((data, status) ->
            $scope.error = true
            $scope.message = data.message
        )

    # change account's profile picture
    $scope.onFileSelect = ($files) ->
        for file in $files
            $scope.upload = $upload.upload({
                url: '/api/change_avatar/',
                file: file,
            }).success((data, status, headers, config) ->
                $rootScope.user = data.user
                $scope.profPic = '/media/' + $rootScope.user.profile.avatar
            ).error((data, status) ->
                $scope.error = true
                $scope.message = data.message
            )


return
