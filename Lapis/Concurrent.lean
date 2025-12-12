import Lapis.Concurrent.Channel
import Lapis.Concurrent.Actor
import Lapis.Concurrent.VfsActor
import Lapis.Concurrent.LspActor

namespace Lapis.Concurrent

-- Core concurrency primitives
export Channel (Unbounded Bounded Oneshot)
export Actor (ActorRef Actor ActorStatus ActorConfig HandleResult spawn)

-- VFS actor (used internally by ServerM)
export VfsActor (VfsRef DocumentSnapshot VfsMsg spawnVfsActor)

-- LspConfig API (alternative to ServerConfig, gives direct RequestContext access)
export LspActor (LspConfig LspRef RequestContext HandlerResult spawnLspActor)

end Lapis.Concurrent
