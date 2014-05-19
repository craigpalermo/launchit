'use strict'

App = angular.module('App')

App.controller "AccountCtrl", ($scope, $upload, $http, $location, $rootScope) ->
    $scope.myInterests = $rootScope.user.profile.interests

    # forward click on image to file upload field
    $('#profPicContainer .text-content, img').on('click', ->
        $("#file").click()
    )

    $http.get('/api/fetch_interests').then((response) ->
        $scope.interests = response.data
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
            if $scope.selected not in $scope.myInterests
                $scope.myInterests.push($scope.selected)
                $scope.selected = ''
        )
        
    # remove interest from account
    $scope.remove_interest = (interest) ->
        data = { interest: interest }
        response = $http.post("/api/remove_interest/", data)
        response.success((data, status) ->
            index = $scope.myInterests.indexOf interest
            $scope.myInterests.splice(index, 1) if index isnt -1
        )

    # change account's profile picture
    $scope.onFileSelect = ($files) ->
        for file in $files
            $scope.upload = $upload.upload({
                url: '/api/change_avatar/',
                file: file,
            }).success((data, status, headers, config) ->
                $rootScope.user = data
                $scope.profPic = '/media/' + data.profile.avatar
            )

return
