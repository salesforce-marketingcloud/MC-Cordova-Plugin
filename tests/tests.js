// exports.defineAutoTests = function () {
//   // describe('MCCordovaPlugin', function () {

//   //   it('MCCordovaPlugin', function () {
//   //     expect(MCCordovaPlugin).toBeDefined()
//   //   });
//   // });


// }

exports.defineAutoTests = function () {
  // describe('MCCordovaPlugin', function () {
  //   it('should exist', function () {
  //     expect(MCCordovaPlugin).toBeDefined();
  //   });

  describe("A suite", function () {
    it("contains spec with an expectation", function () {
      expect(true).toBe(true);
    });


    // it('should contain a getPicture function', function () {
    //   expect(navigator.camera.getPicture).toBeDefined();
    //   expect(typeof navigator.camera.getPicture === 'function').toBe(true);
    // });
  });

  // describe('Camera Constants (window.Camera + navigator.camera)', function () {
  //     it('camera.spec.1 window.Camera should exist', function () {
  //         expect(window.Camera).toBeDefined();
  //     });

  //     it('camera.spec.2 should contain three DestinationType constants', function () {
  //         expect(Camera.DestinationType.DATA_URL).toBe(0);
  //         expect(Camera.DestinationType.FILE_URI).toBe(1);
  //         expect(Camera.DestinationType.NATIVE_URI).toBe(2);
  //         expect(navigator.camera.DestinationType.DATA_URL).toBe(0);
  //         expect(navigator.camera.DestinationType.FILE_URI).toBe(1);
  //         expect(navigator.camera.DestinationType.NATIVE_URI).toBe(2);
  //     });

  //     it('camera.spec.3 should contain two EncodingType constants', function () {
  //         expect(Camera.EncodingType.JPEG).toBe(0);
  //         expect(Camera.EncodingType.PNG).toBe(1);
  //         expect(navigator.camera.EncodingType.JPEG).toBe(0);
  //         expect(navigator.camera.EncodingType.PNG).toBe(1);
  //     });

  //     it('camera.spec.4 should contain three MediaType constants', function () {
  //         expect(Camera.MediaType.PICTURE).toBe(0);
  //         expect(Camera.MediaType.VIDEO).toBe(1);
  //         expect(Camera.MediaType.ALLMEDIA).toBe(2);
  //         expect(navigator.camera.MediaType.PICTURE).toBe(0);
  //         expect(navigator.camera.MediaType.VIDEO).toBe(1);
  //         expect(navigator.camera.MediaType.ALLMEDIA).toBe(2);
  //     });

  //     it('camera.spec.5 should contain three PictureSourceType constants', function () {
  //         expect(Camera.PictureSourceType.PHOTOLIBRARY).toBe(0);
  //         expect(Camera.PictureSourceType.CAMERA).toBe(1);
  //         expect(Camera.PictureSourceType.SAVEDPHOTOALBUM).toBe(2);
  //         expect(navigator.camera.PictureSourceType.PHOTOLIBRARY).toBe(0);
  //         expect(navigator.camera.PictureSourceType.CAMERA).toBe(1);
  //         expect(navigator.camera.PictureSourceType.SAVEDPHOTOALBUM).toBe(2);
  //     });
  // });
};