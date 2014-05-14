"use strict"

App.controller "MainCtrl", ($scope, $http) ->
    $scope.submit = ->
        data = {
            zipcode:  $scope.zipcode
            range:    $scope.range
        }

        # send data to server
        response = $http.post("/zips", data)
        
        # response was success
        response.success((data, status) ->
            console.log "here"
            for key, value of data
                  console.log "#{key} and #{value}"
        )
        
        # response was error
        response.error((data, status) ->
          $scope.error = true
          $scope.loading = false
          return
        )

    return

return
