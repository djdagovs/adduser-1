# Kubernetes RestClient
in kubernetes, a client can change into various resources. pods are the most common among them. if you look into definiton of every resources. their data members almost the same: at`pkg/client/unversioned`
```go
    r *Client // client object pointer
    ns string // namespace string
```
what distinguish them from each other is the funciton they can invoke up their date members.

take `pods` for example, it implement `List`, `Get`, `Delete`, `Create`, `Update`, `Watch`, `Bind`, `UpdateStatus` and `GetLogs`.

Normally a Client int the above objects at `pkg/client/unversioned/client.go` has three parts, one of which is `RESTClient` at `pkg/client/unversioned/restclient.go`

`RESTClient` has a method of `Verb(verb string) *Request` whose verbs are:

- POST
- PUT
- PATCH
- GET
- DELETE

The returned `struct Request` at `pkg/client/unversioned/request.go` has 

- `Do() Result` and 
- `Watch()(watch.Interface, error)` 

to implement `cache.ListWatch`(actually a funciton pointer table struct that implement list and watch function, but the involved interface `ListerWatcher` is in reflector.go) for observing `WatchEvent` of `Pods` or `RCs`.

For `Watch` method,

- using `req := http.NewRequest` and `client := http.DefaultClient`
- using `resp := client.Do(req)`, where `resp.body` is `io.Reader`. and this method invoke is async and is able to return immediately. Then we should just read `resp.Body` to get contents.
- return `watch.NewStreamWatcher(watchjson.NewDecoder(resp.Body,r.codec))`

For `Do` method, it just invokes `Request.request(fn func(*http.Request, *http.Response))`, where `fn` is `Request.transformResponse(resp,req)`

For `request` method,

- mostly same as `Watch` method 
- at last, invoke `fn`













