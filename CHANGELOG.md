# Changelog

## 0.5.0
Breaking changes:
- Rename ApiResource to ApiRoutes
- Rename entire project to ApiModel instead of APIModel
- Remove legacy ApiForm.load method in favor of ApiForm.find
- Rename ApiForm.post to ApiForm.create, and create a corresponding ApiForm.update

Fixed:
- Create concept of response parsers, with JSONParser as default parser.
- Add basic request logging that is enabled by default
- Create ApiForm.get/post/put/delete methods for more intuitive REST calling
- Add a destroy method on ApiForm with parameters
- Refactor ApiForm internally for more code reuse
- Making it possible to set the path and namespace for .findArray
- Create an ApiFormResponse that is returned by most methods of ApiForm. It contains the parsed objects and other metadata about the request and response
- Correctly deal with pluralized namespaces on save

## 0.4.0
- Change `ToArray(realmArray: myArray).get()` to `toArray(myArray)`

## 0.3.0

- Upgrade to `Realm 0.92`, meaning using `import RealmSwift`
- Create `.xcodeproj` to compile standalone `.framework`
- Add method to retrieve an API url for an object. `Object#apiUrlForResource`
- Fix a crash when `primaryKey` wasn't implemented

## 0.2.0

- More stuff

## 0.1.0

- Got it working
