'use strict';

var app = angular.module('myApp.settings', ['ngRoute', 'ngCookies'])

    .config(['$routeProvider', '$httpProvider', function ($routeProvider, $httpProvider) {
        $httpProvider.defaults.useXDomain = true;
        delete $httpProvider.defaults.headers.common["X-Requested-With"];
        $httpProvider.defaults.headers.common["Accept"] = 'application/x-www-form-urlencoded';
        $httpProvider.defaults.headers.common["Content-Type"] = 'application/x-www-form-urlencoded';
        $routeProvider.when('/settings', {
            templateUrl: 'app/settings/settings.html',
            controller: 'SettingsCtrl',
            css: 'app/settings/settings.css'
        });
    }])
    .controller('SettingsCtrl', function ($scope, $location, $http, $cookies) {
        $scope.user = {
            userName: '',
            password: ''
        }

        $scope.base_url = "http://cs307.cs.purdue.edu:8080/home/cs307/Intelligent-Search/Back-End/target/Back-End/rest";

        $scope.auth = function () {
            // GET request for logging into an account:
            $http({
                method: 'POST',
                url: $scope.base_url + '/settings',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                // transformRequest: function (obj) {
                //     var str = [];
                //     for (var p in obj)
                //         str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
                //     return str.join("&");
                // },
                data: $.param({name: $scope.user.userName, password: $scope.user.password})
            }).then(function successCallback(response) {
                // this callback will be called asynchronously
                // when the response is available
                var userID = response.data.user.UserID;
                if (userID != -1) {
                    $cookies.put('user', userID);
                    $cookies.put('user_name', $scope.user.userName);
                    $location.path("/dining");
                 } else {
                    alert('Settings failed');
                 }

            }, function errorCallback(response) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
                alert('Settings failed' + angular.toJson(response));
            });
        }
    });