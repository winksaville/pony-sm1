trait StateMachine
  be send_to(dest: StateMachine tag, data: String)
  be stop()

trait HasName
  fun name(): String

trait StateMachineState is (Transitionable & HasName)
  fun send_to(state_data: StateData ref,
                dest: StateMachine tag, data: String) =>
    // Default: ignore all messages if not implemented
    None

  fun stop(state_data: StateData ref) =>
    // Default: always transition to stop
    transitionTo(state_data, state_data.done_state)

trait Transitionable
  fun enter(state_data: StateData ref, new_state: StateMachineState) =>
    None

  fun exit(state_data: StateData ref, new_state: StateMachineState) =>
    None

  fun transitionTo(state_data: StateData ref, new_state: StateMachineState) =>
    state_data.cur_state.exit(state_data, new_state)
    new_state.enter(state_data, new_state)
    state_data.cur_state = new_state

class StateData
  let sm: StateMachine tag
  let env: Env

  let initial_state: InitialState = InitialState
  let working_state: WorkingState = WorkingState
  let done_state: DoneState = DoneState

  var count: U64 = 0
  let max_count: U64
  var cur_state: StateMachineState

  new create(sm': StateMachine tag, env': Env, max_count': U64) =>
    sm = sm'
    env = env'
    max_count = max_count'
    cur_state = initial_state
    cur_state.enter(this, cur_state)

  fun log(s: String) => env.out.print(s)

class InitialState is StateMachineState
  fun name(): String =>
    "InitialState"

  fun send_to(state_data: StateData ref,
                dest: StateMachine tag, data: String) =>
    state_data.count = state_data.count + 1
    state_data.log(name() + "::send_to: data=" + data
                           + " count=" + state_data.count.string())
    transitionTo(state_data, state_data.working_state)
    dest.send_to(state_data.sm, data)

class WorkingState is StateMachineState
  fun name(): String =>
    "WorkingState"

  fun enter(state_data: StateData ref, new_state: StateMachineState) =>
    state_data.log(name() + "::enter:")

  fun exit(state_data: StateData ref, new_state: StateMachineState) =>
    state_data.log(name() + "::exit:")

  fun send_to(state_data: StateData ref,
                dest: StateMachine tag, data: String) =>
    state_data.count = state_data.count + 1
    state_data.log(name() + "::send_to: data=" + data
                           + " count=" + state_data.count.string())
    if (state_data.count >= state_data.max_count) then
      state_data.sm.stop()
    else
      dest.send_to(state_data.sm, data)
    end

  fun stop(state_data: StateData ref) =>
    state_data.log(name() + "::stop: transitionTo done_state")
    transitionTo(state_data, state_data.done_state)

class DoneState is StateMachineState
  fun name(): String =>
    "DoneState"

  fun stop(state_data: StateData ref) =>
    // Never transition away from DoneState
    state_data.log(name() + "::Stop: done")

actor Main is StateMachine
  var _state_data: StateData

  new create(env: Env) =>
    _state_data = StateData(this, env, 10)
    send_to(this, "hi")

  be send_to(dest: StateMachine tag, data: String) =>
    _state_data.cur_state.send_to(_state_data, dest, data)

  be stop() =>
    _state_data.cur_state.stop(_state_data)
