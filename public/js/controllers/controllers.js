var app = angular.module('dogApp', ['ngFileUpload']);

app.controller('DogCtrl', ['$scope', 'Upload', '$timeout', function ($scope, Upload, $timeout) {

    $scope.uploadFiles = function(file) {
        $scope.f = file;
        if (file && !file.$error) {
            // file.upload = Upload.upload({
            //     url: 'https://angular-file-upload-cors-srv.appspot.com/upload',
            //     file: file
            // });
            file.upload = Upload.upload({
// <<<<<<< HEAD
//         		url: 'https://angular-file-upload.s3.amazonaws.com/bigdogdata', //S3 upload url including bucket name
//         		method: 'POST',
//         		fields : {
//           			key: file.name, // the key to store the file on S3, could be file name or customized
//           			AWSAccessKeyId: <AKIAIBU4ABQ4BHBNDE6A>,
//           			acl: 'private', // sets the access to the uploaded file in the bucket: private or public
//           			policy: $scope.policy, // base64-encoded json policy (see article below)
//           			signature: $scope.signature, // base64-encoded signature based on policy string (see article below)
//           			"Content-Type": file.type != '' ? file.type : 'application/octet-stream', // content type of the file (NotEmpty)
//           			filename: file.name // this is needed for Flash polyfill IE8-9
//         		},
//         		file: file
//       		});
// =======
                 url: 'api/user/uploads',
                  method: 'POST',
                  file: file
            });

            file.upload.then(function (response) {
                $timeout(function () {
                    file.result = response.data;
                });
            }, function (response) {
                if (response.status > 0)
                    $scope.errorMsg = response.status + ': ' + response.data;
            });

            file.upload.progress(function (evt) {
                file.progress = Math.min(100, parseInt(100.0 * 
                                                       evt.loaded / evt.total));
            });
        }   
    }
}]);