# My first state machine in pony

Not sure I like it, its very verbose and too much dereferencing:
```Pony
trait StateMachineState
  fun send_to(state_data: StateData ref,
                  dest: StateMachine tag, data: String) =>
    state_data.env.out.print("send_to: data=" + data
                           + " count=" + state_data.count.string())
    dest.send_to(state_data.state_machine,
        "data: count=" + state_data.count.string())

  fun stop(state_data: StateData ref) =>
    state_data.env.out.print("stop: transitionTo done_state")
    state_data.transitionTo(state_data.done_state)
```
But it does transition through three states so a start.
