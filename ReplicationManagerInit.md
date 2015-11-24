# how `ReplicationManager` is initialized

`type ReplicationManager` has

- syncHandler func(rcKey string) error
- rcStore cache.StoreToReplicationControllerLister
- rcController *framework.Controller
- podStore cache.StoreToPodLister
- podController *framework.Controller
- queue *workqueue.Type

Let us take example from `pods`( `Rc` is the same ).
```go
rm.podStore.Store, rm.podController = framework.NewInformer(
    &cache.ListWatch{
    },
    &api.Pod{},
    resyncPeriod(),
    framework.ResourceEventHandlerFuncs{
    },
)
```
in `pkg/controller/framework/controller.go`

`NewInformer` returns a `cache.Store` and a `Controller` for populating the store while also providing event notifications.

- `cache.Store` for `Get/List`
- `Controller` for `Add/Modify/Delete`

```golang

func NewInformer(
	lw cache.ListerWatcher,
	objType runtime.Object,
	resyncPeriod time.Duration,
	h ResourceEventHandler,
) (cache.Store, *Controller) {
	clientState := cache.NewStore( )
	fifo := cache.NewDeltaFIFO(..., clientState)
	cfg := &Config{
		Queue:            fifo,
		ListerWatcher:    lw,
		ObjectType:       objType,
		FullResyncPeriod: resyncPeriod,
		RetryOnError:     false,
		Process: func(obj interface{}) error {
	    // switch on type of obj, call ResourceEventHandler.OnUpdate, OnAdd, OnDelete
		},
	}
	return clientState, New(cfg)
}
 
```
Controller is :
```golang
type Controller struct {
    config Config
    reflector *cache.Reflector
    reflectorMutex sync.RWMutex
}
```

From above we know that in init of `ReplicationManager`, we pass `ResourceEventHandler` to `NewInformer`, which return a `cache.Store` and
`Controller` whose `Controller.config.Process` uses aforementioned `ResourceEventHandler`.

So, who and when to invoke `Controller.config.Process`? Don't worry. In next doc `How controller runs`, it will be explained.













