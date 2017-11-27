# My first state machine in pony

Not sure I like it, it's very verbose and too much dereferencing:
```Pony
trait StateMachine
  be send_to(dest: StateMachine tag, data: String)
  be stop()

trait StateMachineState is Transitionable
  fun send_to(state_data: StateData ref,
                dest: StateMachine tag, data: String) =>
    // Default: ignore all messages if not implemented
    state_data.env.out.print("StateMachineState::send_to: ignore data=" + data
                           + " count=" + state_data.count.string())

  fun stop(state_data: StateData ref) =>
    // Default: always transition to stop
    state_data.env.out.print("StateMachineState::stop: count="
                            + state_data.count.string())
    transitionTo(state_data, state_data.done_state)

trait Transitionable
  fun enter(state_data: StateData ref, new_state: StateMachineState) =>
    state_data.enter_count = state_data.enter_count + 1
    state_data.env.out.print("StateMachineState::enter:"
                           + " enter_count=" + state_data.enter_count.string())

  fun exit(state_data: StateData ref, new_state: StateMachineState) =>
    state_data.exit_count = state_data.exit_count + 1
    state_data.env.out.print("StateMachineState::exit:"
                           + " exit_count=" + state_data.exit_count.string())

  fun transitionTo(state_data: StateData ref, new_state: StateMachineState) =>
    state_data.cur_state.exit(state_data, new_state)
    new_state.enter(state_data, new_state)
    state_data.cur_state = new_state

```
But it does transition through three states so a start.
