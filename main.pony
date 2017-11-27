trait StateMachine
  be send_to(dest: StateMachine tag, data: String)
  be stop()

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

class StateData
  let state_machine: StateMachine tag
  let env: Env
  let initial_state: InitialState = InitialState
  let working_state: WorkingState = WorkingState
  let done_state: DoneState = DoneState

  var count: U64 = 0
  let max_count: U64
  var cur_state: StateMachineState

  new create(state_machine': StateMachine tag, env': Env, max_count': U64) =>
    state_machine = state_machine'
    env = env'
    max_count = max_count'
    cur_state = initial_state

  fun ref transitionTo(new_state: StateMachineState) =>
    cur_state = new_state

class InitialState is StateMachineState
  fun send_to(state_data: StateData ref,
                  dest: StateMachine tag, data: String) =>
    state_data.count = state_data.count + 1
    state_data.env.out.print("InitialState::send_to: data=" + data
                           + " count=" + state_data.count.string())
    state_data.transitionTo(state_data.working_state)
    state_data.state_machine.send_to(dest, data)

class WorkingState is StateMachineState
  fun send_to(state_data: StateData ref,
                  dest: StateMachine tag, data: String) =>
    state_data.count = state_data.count + 1
    state_data.env.out.print("WorkingState::send_to: data=" + data
                           + " count=" + state_data.count.string())
    if (state_data.count >= state_data.max_count) then
      state_data.state_machine.stop()
    else
      dest.send_to(state_data.state_machine, data)
    end

class DoneState is StateMachineState

actor Main is StateMachine
  var _state_data: StateData

  new create(env: Env) =>
    _state_data = StateData(this, env, 10)
    send_to(this, "hi")

  be send_to(dest: StateMachine tag, data: String) =>
    _state_data.cur_state.send_to(_state_data, dest, data)

  be stop() =>
    _state_data.cur_state.stop(_state_data)