# ApiModel

Interact with REST apis using realm.io to represent objects. The goal of `ApiModel` is to be easy to setup, easy to grasp, and fun to use. Boilerplate should be kept to a minimum, and also intuitive to set up.

This project is very much inspired by [@idlefingers'](https://github.com/idlefingers) excellent [api-model](https://github.com/izettle/api-model).

## Getting started

The key part is to implmenet the `ApiTransformable` protocol.

```swift
import RealmSwift
import ApiModel

class Post: Object, ApiTransformable {
    // Standard Realm boilerplate
    dynamic var id = ""
	dynamic var title = ""
	dynamic var contents = ""
	dynamic var createdAt = NSDate()

	override class func primaryKey() -> String {
        return "id"
    }

    // Define the standard namespace this class usually resides in JSON responses
    // MUST BE singular ie `post` not `posts`
    class func apiNamespace() -> String {
        return "post"
    }

    // Define where and how to get these. Routes are assumed to use Rails style REST (index, show, update, destroy)
    class func apiRoutes() -> ApiRoutes {
        return ApiRoutes(
            index: "/posts.json",
            show: "/post/:id:.json"
        )
    }

    // Define how it is converted from JSON responses into Realm objects. A host of transforms are available
    // See section "Transforms" in README. They are super easy to create as well!
    class func fromJSONMapping() -> JSONMapping {
        return [
            "id": ApiIdTransform(),
            "title": StringTransform(),
            "contents": StringTransform(),
            "createdAt": NSDateTransform()
        ]
    }

    // Define how this object is to be serialized back into a server response format
    func JSONDictionary() -> [String:AnyObject] {
        return [
            "id": id,
            "title": email,
            "contents": contents,
            "created_at": createdAt
        ]
    }
}
```

## Configuring the API

To represent the API itself, you have to create an object of the `API` class. This holds a `ApiConfiguration` object defining the host URL for all requests. After it has been created it can be accessed from the `func api() -> API` singleton function.

To set it up:

```
// Put this somewhere in your AppDelegate or together with other initialization code
var apiConfig = ApiConfiguration(host: "https://service.io/api/v1/")

ApiSingleton.setInstance(API(configuration: apiConfig))
```

If you would like to enable request logging, you can do so by setting `requestLogging` to `true`:

```swift
apiConfig.requestLogging = true
```

## Interacting with APIs

The base of `ApiModel` is the `ApiForm` wrapper class. This class wraps an `Object` type and takes care of fetching objects, saving objects and dealing with validation errors.

### Basic REST verbs

`ApiModel` supports querying API's using basic HTTP verbs.

```swift
// GET call without parameters
ApiForm<Post>.get("/v1/posts.json") { response in
    println("response.isSuccessful: \(response.isSuccessful)")
    println("Response as an array: \(response.array)")
    println("Response as a dictionary: \(response.dictionary)")
    println("Response errors?: \(response.errors)")
}

// Other supported methods:
ApiForm<Post>.get(path, parameters: [String:AnyObject]) { response // ...
ApiForm<Post>.post(path, parameters: [String:AnyObject]) { response // ...
ApiForm<Post>.put(path, parameters: [String:AnyObject]) { response // ...
ApiForm<Post>.delete(path, parameters: [String:AnyObject]) { response // ...

// no parameters

ApiForm<Post>.get(path) { response // ...
ApiForm<Post>.post(path) { response // ...
ApiForm<Post>.put(path) { response // ...
ApiForm<Post>.delete(path) { response // ...
```

Most of the time you'll want to use the `ActiveRecord`-style verbs `index/show/create/update` for interacting with a REST API, as described below.

### Fetching objects

Using the `index` of a REST resource:

`GET /posts.json`
```swift
ApiForm<Post>.findArray { posts in
    for post in posts {
        println("... \(post.title)")
    }
}
```

Using the `show` of a REST resource:

`GET /user.json`
```swift
ApiForm<User>.find { userResponse in
    if let user = userResponse {
        println("User is: \(user.email)")
    } else {
        println("Error loading user")
    }
}
```

### Storing objects

```swift
var post = Post()
post.title = "Hello world - A prologue"
post.contents = "Hello!"
post.createdAt = NSDate()

var form = ApiForm<Post>(model: post)
form.save { _ in
    if form.hasErrors {
        println("Could not save:")
        for error in form.errorMessages {
            println("... \(error)")
        }
    } else {
        println("Saved! Post #\(post.id)")
    }
}
```

`ApiForm` will know that the object is not persisted, since it does not have an `id`  set (or which ever field is defined as `primaryKey` in Realm). So a `POST` request will be made as follows:

`POST /posts.json`
```json
{
    "post": {
        "title": "Hello world - A prologue",
        "contents": "Hello!",
        "created_at": "2015-03-08T14:19:31-01:00"
    }
}
```

If the response is successful, the attributes returned by the server will be updated on the model.

`200 OK`
```json
{
    "post": {
        "id": 1
    }
}
```

The errors are expected to be in the format:

`400 BAD REQUEST`
```json
{
    "post": {
        "errors": {
            "contents": [
                "must be longer than 140 characters"
            ]
        }
    }
}
```

And this will make it possible to access the errors as follows:

```swift
form.errors["contents"] // -> [String]
// or
form.errorMessages // -> [String]
```

## Transforms

Transforms are used to convert attributes from JSON responses to rich types. The easiest way to explain is to show a simple transform.

`ApiModel` comes with a host of standard transforms. An example is the `IntTransform`:

```swift
class IntTransform: Transform {
    func perform(value: AnyObject?) -> AnyObject {
        if let asInt = value?.integerValue {
            return asInt
        } else {
            return 0
        }
    }
}
```

This takes an object and attempts to convert it into an integer. If that fails, it returns the default value 0.

Transforms can be quite complex, and even convert nested models. For example:

```swift
class User: Object, ApiTransformable {
    dynamic var id = ApiId()
    dynamic var email = ""
    let posts = List<Post>()

    static func fromJSONMapping() -> JSONMapping {
        return [
            "posts": ArrayTransform<Post>()
        ]
    }
}

ApiForm<User>.find { response in
    let user = response!.model

    println("User: \(user.email)")
    for post in user.posts {
        println("\(post.title)")
    }
}
```

Default transforms are:

- StringTransform
- IntTransform
- FloatTransform
- DoubleTransform
- BoolTransform
- NSDateTransform
- ModelTransform
- ArrayTransform
- PercentageTransform

However, it is really easy to define your own. Go nuts!

## Hooks

`ApiModel` uses [Alamofire](https://github.com/alamofire/alamofire) for sending and receiving requests. To hook into this, the `API` class currently has `before`- and `after`-hooks that you can use to modify or log the requests. An example of sending user credentials with each request:

```swift
// Put this somewhere in your AppDelegate or together with other initialization code
api().beforeRequest { request in
    if let loginToken = User.loginToken() {
        request.parameters["access_token"] = loginToken
    }
}
```

There is also a `afterRequest` which passes in a `ApiRequest` and `ApiResponse`:

```swift
api().afterRequest { request, response in
    println("... Got: \(response.status)")
    println("... \(request)")
    println("... \(response)")
}
```

## API urls

Given the setup for the `Post` model above, if you wanted to get the full url with replacements for the show resource (like `https://service.io/api/v1/posts/123.json`), you can use:

```swift
post.apiUrlForRoute(Post.apiRoutes().show)
// NOT IMPLEMENTED YET BECAUSE LIMITATIONS IN SWIFT: post.apiUrlForResource(.Show)
```

## Dealing with IDs

As a consumer of an API, you never want to make assumptions about the ID structure used for their models. Do not use `Int` or anything similar for ID types, strings are to be recommended. Therefor `ApiModel` defines a typealias to `String`, called ApiId. There is also an `ApiIdTransform` available for IDs.

## Caching and storage

It is up to you to cache and store the results of any calls. ApiModel does not do that for you, and will not do that, since strategies vary wildly depending on needs.

# Thanks to

- [idlefingers](https://www.github.com/idlefingers)
- [Pluralize.swift](https://github.com/joshualat/Pluralize.swift)

# License

The MIT License (MIT)

Copyright (c) 2015 Rootof Creations HB

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
