# ReplicationManager

In `cmd/kube-controller-manager/app/controllermanager.go`, `Controller Manager` invoke `Run` method, where there is a line `go replicationcontroller.NewReplicationManager(KubeClient, ...).Run(ConcurrentRCSyncs, util.NeverStop)`

`NewReplicationManager` method at `pkg/controller/replication/replicationcontroller.go` instantiate and initialize `type ReplicationManager`, and return it.

`type ReplicationManager` has

- syncHandler func(rcKey string) error
- rcStore cache.StoreToReplicationControllerLister
- rcController *framework.Controller
- podStore cache.StoreToPodLister
- podController *framework.Controller
- queue *workqueue.Type

in the `Run(workers int, stopCh <-chan struct{})` method of `ReplicationManager`:

- `go rm.rcController.Run(stopCh)`
- `go rm.podController.Run(stopCh)`
- for number of `workers`, `go util.Until(rm.worker, time.Second, stopCh`

til now, we need to know:

- how `ReplicationManager` to be initialized, especially its members
- how `type framework.Controller` runs
- what is `rm.worker`













