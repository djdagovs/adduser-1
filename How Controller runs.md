# How `Controller` runs
at `pkg/controller/framework/controller.go`, the `Controller.Run` method is

```golang
func (c *Controller) Run(stopCh <-chan struct{}) {
	defer util.HandleCrash()
	r := cache.NewReflector(
		c.config.ListerWatcher,
		c.config.ObjectType,
		c.config.Queue,
		c.config.FullResyncPeriod,
	)

	c.reflectorMutex.Lock()
	c.reflector = r
	c.reflectorMutex.Unlock()

	r.RunUntil(stopCh)

	util.Until(c.processLoop, time.Second, stopCh)
}
```
what `Run` do are three parts:

- initializing `Controller.reflector`
- run `Controller.reflector`
- run `func Controller.processLoop`

I don't why the code of init `Controller.reflector` is in the `Run` method, and it should be in `NewInformer`.





## second part of `Run`

in `pkg/client/cache/reflector.go`
codes of `cache.Reflector.RunUntil`

- `go Reflector.ListAndWatch(stopCh)`

method `Reflector.ListAndWatch(stopCh <-chan struct{})`

- `Reflector.ListerWatcher.List()`, which is communication to apiserver.
- `options := api.ListOptions{ResourceVersion, TimeoutSeconds}`
- `w = Reflector.ListerWatcher.Watch(options)`, which is communication to apiserver.
- `Reflector.watchHandler(w, &resourceVersion, resyncCh, stopCh)`

method `Reflector.watchHandler(w watch.Interface, resourceVersion *string, resyncCh <-chan time.Time, stopCh <-chan struct{})`

- get `event := <-watch.Interface.ResultChan`
- switch `event.Type`
- manipulating `Reflector.store`(which is `Controller.config.Queue`). this is where the queue get its items

### How `DeltaFIFO` add, update and delete
at `pkg/client/cache/delta_fifo.go`

`Controller.Config.Queue` is `type DeltaFIFO`
```golang
type DeltaFIFO struct {
    lock sync.RWMutex
    cond sync.Cond
    items map[string]Deltas
    queue []string
    keyFunc KeyFunc
    ....
}
```
- `cond`'s lock is `lock`
- `items` map from `key(id)` => raw []byte return from `Watch()`
- `queue` queue of `key(id)`
for X in `Add` `Update` `Delete`, `DeltaFIFO` invoke `queueActionLocked(X, obj)`

- `DeltaFIFO,Keyof(obj)`, using `keyFunc` return a string of form like `namespace/resource`(such as `default/my-nginx-1as0d`) 
- according to the `DeltaType` manipulate `items` keeping to no more two
- queue `key(id)` and maybe for add and update, it notify a conditon variable upon which a thread that invoke `Pop` waiting. 


## third part of `Run`

Codes of `Controller.processLoop`
```golang
func (c *Controller) processLoop() {
	for {
		obj := c.config.Queue.Pop()
		err := c.config.Process(obj)
		if err != nil {
			if c.config.RetryOnError {
				// This is the safe way to re-enqueue.
				c.config.Queue.AddIfNotPresent(obj)
			}
		}
	}
}
```

we get the answeer of "who and when to invoke `Controller.config.Process`", but from where `Controller.config.Queue` got its items. If your don't know, see the second part of `Run`

### what `c.config.Process` do

Please remember `framework.Controller.processLoop` will use the `Pop` return data which is `raw []byte`
and use `func Process` to update `rm.podStore` and `rm.queue` according to the type `raw []byte`. But in `rm.queue`, we put only put matching `Rc` of the `Pod` while in `rm.podStore` we put `pod`













