# ReplicationManager worker does what
codes of `func ReplicationManager.worker()`

```golang
func (rm *ReplicationManager) worker() {
	for {
		func() {
			key, quit := rm.queue.Get()
			if quit {
				return
			}
			defer rm.queue.Done(key)
			err := rm.syncHandler(key.(string))
			if err != nil {
				glog.Errorf("Error syncing replication controller: %v", err)
			}
		}()
	}
}
```
This time it get `key` from `rm.queue`, and using `rm.syncHandler` processing it. Remember we get `rm.syncHandler = rm.syncReplicationController`

but before analyze `syncReplicationController`, we must know who put key in the rm.queue.

## method of `syncReplicationController(key string)`

- we get the matching `rc` from key
- check if `podStoreSynced`. When `podController` first time listed, it will set it to true
- get the real number of living matching pods via `RC`
- according to the diff between `RC` replicas and number of living pods, create or delete pods